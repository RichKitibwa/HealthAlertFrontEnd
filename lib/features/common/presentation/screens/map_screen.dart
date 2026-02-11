import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

/// Robust navigation map for ambulance drivers.
/// Shows current location, destination, route polyline, and navigation info.
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
    this.destinationType = 'clinic', // 'clinic' or 'vht'
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _loadingLocation = true;
  String? _locationError;
  bool _hasFittedBounds = false;

  static const LatLng _defaultCenter = LatLng(0.3476, 32.5825);
  static const double _defaultZoom = 14.0;
  static const double _avgSpeedKmh = 40.0;

  final Distance _distanceCalculator = const DistanceHaversine();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _loadingLocation = false;
            _locationError = 'Location services are disabled.';
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
              _locationError = 'Location permissions denied.';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _loadingLocation = false;
            _locationError = 'Location permissions permanently denied.';
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _loadingLocation = false;
        });
        _fitBoundsWhenReady();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
          _locationError = 'Could not get location: $e';
        });
      }
    }
  }

  void _fitBoundsWhenReady() {
    final dest = _destinationPoint;
    if (_currentLocation != null && dest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _hasFittedBounds) return;
        final points = [_currentLocation!, dest];
        _mapController.fitCamera(
          CameraFit.coordinates(
            coordinates: points,
            padding: const EdgeInsets.all(48),
            maxZoom: 16,
          ),
        );
        _hasFittedBounds = true;
      });
    }
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
    final meters = _distanceCalculator(
      _currentLocation!,
      dest,
    );
    return meters / 1000;
  }

  double? get _etaMinutes {
    final km = _distanceKm;
    if (km == null) return null;
    return (km / _avgSpeedKmh) * 60;
  }

  List<Marker> get _markers {
    final markers = <Marker>[];

    if (_currentLocation != null) {
      markers.add(
        Marker(
          point: _currentLocation!,
          width: 48,
          height: 48,
          child: const Icon(
            Icons.local_shipping,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    }

    final dest = _destinationPoint;
    if (dest != null) {
      final isVht = widget.destinationType.toLowerCase() == 'vht';
      markers.add(
        Marker(
          point: dest,
          width: 48,
          height: 48,
          child: Icon(
            isVht ? Icons.health_and_safety : Icons.local_hospital,
            color: isVht ? Colors.green : Colors.red,
            size: 40,
          ),
        ),
      );
    }

    return markers;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open Google Maps: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _centerOnUser() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
    } else {
      _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.vhtAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: _defaultZoom,
              onMapReady: () {
                _fitBoundsWhenReady();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.healthapp.frontend',
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
                          'Getting your location...',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
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
                          _locationError!,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnUser,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.my_location,
          color: _currentLocation != null ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildBottomInfoCard() {
    final dest = _destinationPoint;
    final distanceKm = _distanceKm;
    final etaMinutes = _etaMinutes;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                        ? Icons.health_and_safety
                        : Icons.local_hospital,
                    color: widget.destinationType.toLowerCase() == 'vht'
                        ? Colors.green
                        : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Destination',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
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
                    label: 'Distance',
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
                  label: const Text('Navigate with Google Maps'),
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
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
