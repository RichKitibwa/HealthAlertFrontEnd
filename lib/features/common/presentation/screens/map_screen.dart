import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart' show CacheStore;
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/widgets/back_handling_pop_scope.dart';
import '../../../vht/presentation/screens/vht_navigation_bar.dart';
import '../../../ambulance/presentation/screens/ambulance_navigation_bar.dart';

class MapScreen extends StatefulWidget {
  final String title;
  final double? destinationLat;
  final double? destinationLng;
  final String? destinationLabel;
  final String destinationType;

  const MapScreen({
    super.key,
    this.title = 'Navigation',
    this.destinationLat,
    this.destinationLng,
    this.destinationLabel,
    this.destinationType = 'clinic', 
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _loadingLocation = true;
  String? _locationError;
  String? _locationErrorDetail;
  bool _hasFittedBounds = false;
  bool _autoFollowUser = true;
  bool _mapReady = false;
  StreamSubscription<Position>? _positionSubscription;

  static const LatLng _defaultCenter = LatLng(0.3476, 32.5825);
  static const double _defaultZoom = 15.0;
  static const double _avgSpeedKmh = 40.0;

  final Distance _distanceCalculator = const DistanceHaversine();

  /// Tile cache for offline use: tiles you view are stored and work without internet (global OSM).
  static Future<CacheStore> _getTileCacheStore() async {
    final dir = await getApplicationDocumentsDirectory();
    return FileCacheStore('${dir.path}${Platform.pathSeparator}MapTiles');
  }

  late final Future<CacheStore> _cacheStoreFuture = _getTileCacheStore();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _applyLastKnownPositionImmediately();
  }

  /// Immediately center the map on the device's last known position so the
  /// user sees their approximate area while high-accuracy GPS is acquired.
  Future<void> _applyLastKnownPositionImmediately() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted && _currentLocation == null) {
        final latlng = LatLng(last.latitude, last.longitude);
        setState(() => _currentLocation = latlng);
        // Center immediately if map is already ready, otherwise onMapReady handles it
        if (_mapReady) {
          _mapController.move(latlng, _defaultZoom);
        }
      }
    } catch (_) {
      // Last known position is not critical — GPS will follow.
    }
  }

  /// Move map to user's current location (or best available) immediately.
  void _centerOnCurrentLocationNow() {
    if (!_mapReady) return;
    final loc = _currentLocation;
    if (loc == null) return;
    final dest = _destinationPoint;
    if (dest != null) {
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: [loc, dest],
          padding: const EdgeInsets.all(48),
          maxZoom: 16,
        ),
      );
    } else {
      _mapController.move(loc, _defaultZoom);
    }
    _hasFittedBounds = true;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _loadingLocation = false;
            _locationError = 'disabled';
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _loadingLocation = false;
              _locationError = 'denied';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _loadingLocation = false;
            _locationError = 'deniedForever';
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _loadingLocation = false;
          // Allow re-fit with the precise location even if last-known was used.
          _hasFittedBounds = false;
        });
        // Center on accurate GPS immediately
        _centerOnCurrentLocationNow();
        _fitBoundsWhenReady();
        _startLocationStream();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
          _locationError = 'couldNotGet';
          _locationErrorDetail = e.toString();
        });
      }
    }
  }

  void _fitBoundsWhenReady() {
    if (!_mapReady) return;
    final dest = _destinationPoint;
    if (_currentLocation != null && dest != null && !_hasFittedBounds) {
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: [_currentLocation!, dest],
          padding: const EdgeInsets.all(48),
          maxZoom: 16,
        ),
      );
      _hasFittedBounds = true;
    }
  }

  void _centerMapOnUserIfNoDestination() {
    if (!_mapReady) return;
    if (_currentLocation == null || _destinationPoint != null) return;
    _mapController.move(_currentLocation!, _defaultZoom);
    _hasFittedBounds = true;
  }

  void _startLocationStream() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (!mounted) return;
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      if (_autoFollowUser) {
        final dest = _destinationPoint;
        if (dest != null) {
          // Keep both user and destination in view during navigation.
          _mapController.fitCamera(
            CameraFit.coordinates(
              coordinates: [_currentLocation!, dest],
              padding: const EdgeInsets.fromLTRB(48, 80, 48, 160),
              maxZoom: 16,
            ),
          );
        } else {
          // No destination — simply follow the user.
          _mapController.move(_currentLocation!, _mapController.camera.zoom);
        }
      }
    });
  }

  LatLng? get _destinationPoint {
    if (widget.destinationLat != null && widget.destinationLng != null) {
      return LatLng(widget.destinationLat!, widget.destinationLng!);
    }
    return null;
  }

  double? get _distanceKm {
    final dest = _destinationPoint;
    if (_currentLocation == null || dest == null) return null;
    final meters = _distanceCalculator(_currentLocation!, dest);
    return meters / 1000;
  }

  double? get _etaMinutes {
    final km = _distanceKm;
    if (km == null) return null;
    return (km / _avgSpeedKmh) * 60;
  }

  List<Marker> get _markers {
    final markers = <Marker>[];
    final role = CurrentUserSession.role ?? '';

    // Current user location marker
    if (_currentLocation != null) {
      markers.add(
        Marker(
          point: _currentLocation!,
          width: 56,
          height: 56,
          child: _buildCurrentLocationMarker(role),
        ),
      );
    }

    // Destination marker
    final dest = _destinationPoint;
    if (dest != null) {
      final destType = widget.destinationType.toLowerCase();
      markers.add(
        Marker(
          point: dest,
          width: 56,
          height: 56,
          child: _buildDestinationMarker(destType),
        ),
      );
    }

    return markers;
  }

  Widget _buildCurrentLocationMarker(String role) {
    IconData icon;
    Color bg;
    Color iconColor = Colors.white;

    if (role == 'Ambulance Driver' || role == 'Ambulance') {
      icon = Icons.emergency;
      bg = const Color(0xFFDC2626); // Red for ambulance
    } else if (role == 'VHT') {
      icon = Icons.person_pin_circle;
      bg = const Color(0xFF16A34A); // Green for VHT
    } else {
      icon = Icons.my_location;
      bg = Colors.blue;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: bg.withAlpha(100),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: 26),
    );
  }

  Widget _buildDestinationMarker(String destType) {
    IconData icon;
    Color bg;

    switch (destType) {
      case 'vht':
        icon = Icons.personal_injury_rounded; // VHT / patient pickup
        bg = const Color(0xFF16A34A); // Green
        break;
      case 'clinic':
      case 'hospital':
        icon = Icons.local_hospital_rounded;
        bg = const Color(0xFF1D4ED8); // Blue for clinic/hospital
        break;
      default:
        icon = Icons.location_on_rounded;
        bg = Colors.red;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: bg.withAlpha(100),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        // Pin pointer
        Container(
          width: 3,
          height: 8,
          color: bg,
        ),
      ],
    );
  }

  List<Polyline> get _polylines {
    final dest = _destinationPoint;
    if (_currentLocation == null || dest == null) return [];

    return [
      Polyline(
        points: [_currentLocation!, dest],
        strokeWidth: 4,
        color: Colors.blue,
        pattern: StrokePattern.dashed(segments: [12.0, 8.0]),
      ),
    ];
  }

  Future<void> _openGoogleMaps() async {
    final dest = _destinationPoint;
    if (dest == null) return;

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${dest.latitude},${dest.longitude}&travelmode=driving',
    );

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.couldNotOpenGoogleMaps),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _centerOnUser() {
    setState(() => _autoFollowUser = true);
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, _defaultZoom);
    } else {
      _getCurrentLocation();
    }
  }

  Widget? _buildBottomNavigationBar() {
    final role = CurrentUserSession.role;
    final mapIndex = role == 'VHT' ? 3 : (role == 'Ambulance Driver' || role == 'Ambulance' ? 2 : null);
    
    if (mapIndex == null) return null;
    
    if (role == 'VHT') {
      return VhtNavigationBar(
        currentIndex: mapIndex,
        onItemSelected: (index) {},
      );
    } else if (role == 'Ambulance Driver' || role == 'Ambulance') {
      return AmbulanceNavigationBar(
        currentIndex: mapIndex,
        onItemSelected: (index) {},
      );
    }
    
    return null;
  }

  Color _appBarColor() {
    final role = CurrentUserSession.role ?? '';
    if (role == 'Ambulance Driver' || role == 'Ambulance') {
      return const Color(0xFFDC2626); // Red for ambulance
    } else if (role == 'VHT') {
      return const Color(0xFF16A34A); // Green for VHT
    } else if (role == 'Clinic Staff' || role == 'Clinic') {
      return const Color(0xFF1D4ED8); // Blue for clinic
    }
    return AppColors.primary;
  }

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      final role = CurrentUserSession.role?.toLowerCase() ?? '';
      String route = '/login';
      if (role == 'admin') route = '/admin-dashboard';
      else if (role == 'vht') route = '/vht-dashboard';
      else if (role.contains('clinic')) route = '/clinic-dashboard';
      else if (role.contains('ambulance')) route = '/ambulance-dashboard';
      Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
    }
  }

  String _getLocationErrorMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_locationError) {
      case 'disabled':
        return l10n.locationServicesDisabled;
      case 'denied':
        return l10n.locationPermissionDenied;
      case 'deniedForever':
        return l10n.locationPermissionPermanentlyDenied;
      case 'couldNotGet':
        return '${l10n.couldNotGetLocation} ${_locationErrorDetail ?? ''}';
      default:
        return _locationError ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackHandlingPopScope(
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: _appBarColor(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.liveMapCachedOffline,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withAlpha(200),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handleBack(context),
        ),
      ),
      body: FutureBuilder<CacheStore>(
        future: _cacheStoreFuture,
        builder: (context, cacheSnapshot) {
          final tileProvider = cacheSnapshot.hasData
              ? CachedTileProvider(
                  store: cacheSnapshot.data!,
                  maxStale: const Duration(days: 30),
                )
              : null;
          return Stack(
            children: [
                FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _defaultCenter,
                  initialZoom: _defaultZoom,
                  onMapReady: () {
                    setState(() => _mapReady = true);
                
                    if (_currentLocation != null) {
                      _hasFittedBounds = false;
                      _centerOnCurrentLocationNow();
                    }
                    _fitBoundsWhenReady();
                  },
                  // Disable auto-follow when user manually pans the map
                  onPositionChanged: (camera, hasGesture) {
                    if (hasGesture && _autoFollowUser) {
                      setState(() => _autoFollowUser = false);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.healthapp.frontend',
                    tileProvider: tileProvider,
                  ),
                  PolylineLayer(polylines: _polylines),
                  MarkerLayer(markers: _markers),
                ],
              ),

          if (_loadingLocation)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                                Text(
                                  AppLocalizations.of(context)!.gettingYourLocation,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (_locationError != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getLocationErrorMessage(context),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _buildBottomInfoCard(),
          ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnUser,
        backgroundColor: _autoFollowUser ? Colors.blue : Colors.white,
        tooltip: _autoFollowUser ? 'Following your location' : 'Center on my location',
        child: Icon(
          _autoFollowUser ? Icons.my_location : Icons.location_searching,
          color: _autoFollowUser ? Colors.white : (_currentLocation != null ? Colors.blue : Colors.grey),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    ),
    );
  }

  Widget _buildBottomInfoCard() {
    final l10n = AppLocalizations.of(context)!;
    final dest = _destinationPoint;
    final distanceKm = _distanceKm;
    final etaMinutes = _etaMinutes;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.destinationLabel != null) ...[
              Row(
                children: [
                  Icon(
                    widget.destinationType.toLowerCase() == 'vht'
                        ? Icons.personal_injury_rounded
                        : Icons.local_hospital_rounded,
                    color: widget.destinationType.toLowerCase() == 'vht'
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF1D4ED8),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.destination,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          widget.destinationLabel!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (distanceKm != null && etaMinutes != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoChip(
                    icon: Icons.straighten,
                    label: l10n.estimatedArrival.split(' ').first, // "Estimated"
                    value: distanceKm < 1
                        ? '${(distanceKm * 1000).round()} m'
                        : '${distanceKm.toStringAsFixed(1)} km',
                  ),
                  _InfoChip(
                    icon: Icons.access_time,
                    label: 'ETA',
                    value: etaMinutes < 60
                        ? '${etaMinutes.round()} min'
                        : '${(etaMinutes / 60).toStringAsFixed(1)} hr',
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (dest != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _openGoogleMaps,
                  icon: const Icon(Icons.navigation, size: 20),
                  label: Text(l10n.navigateWithGoogleMaps),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
