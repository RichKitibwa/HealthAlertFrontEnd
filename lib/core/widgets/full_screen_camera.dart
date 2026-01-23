// Full-screen camera view
// Opens when user taps camera icon, provides full-screen camera experience

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/file_utils.dart';

class FullScreenCamera extends StatefulWidget {
  final bool allowVideo;
  final Function(File? image, File? video)? onMediaCaptured;

  const FullScreenCamera({
    Key? key,
    this.allowVideo = true,
    this.onMediaCaptured,
  }) : super(key: key);

  @override
  State<FullScreenCamera> createState() => _FullScreenCameraState();
}

class _FullScreenCameraState extends State<FullScreenCamera> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isRecording = false;
  int _selectedCameraIndex = 0;
  DateTime? _recordingStartTime;
  String? _errorMessage;
  bool _isDisposed = false;
  String _mode = 'photo'; // 'photo' or 'video'
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty && !_isDisposed) {
        await _initializeController(_cameras![_selectedCameraIndex]);
      } else if (mounted && (_cameras == null || _cameras!.isEmpty)) {
        setState(() {
          _errorMessage = 'No cameras available. Please use gallery picker or test on a real device.';
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage = 'Camera initialization failed: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _initializeController(CameraDescription camera) async {
    if (_isDisposed) return;

    await _controller?.dispose();
    
    // Use medium preset for faster initialization, still good quality
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: widget.allowVideo,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = _controller!.value.isInitialized;
          if (!_isInitialized) {
            _errorMessage = 'Camera failed to initialize.';
          }
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = false;
          _errorMessage = 'Camera initialization failed: ${e.toString()}';
        });
      }
      await _controller?.dispose();
      _controller = null;
    }
  }

  Future<void> _takePicture() async {
    if (_isDisposed || _controller == null || !_controller!.value.isInitialized || !mounted) return;

    setState(() {
      _errorMessage = null;
    });

    try {
      final image = await _controller!.takePicture();
      
      final compressedFile = await FileUtils.compressImage(
        File(image.path),
        maxWidth: 1280,
        maxHeight: 720,
        quality: 85,
      );

      final finalFile = compressedFile ?? File(image.path);
      final fileSize = await FileUtils.getFileSize(finalFile);
      final fileSizeKB = fileSize / 1024;
      final maxSizeKB = 500;

      if (fileSizeKB > maxSizeKB) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image size (${fileSizeKB.toStringAsFixed(1)}KB) exceeds maximum (${maxSizeKB}KB)'),
              backgroundColor: Colors.red,
            ),
          );
        }
        await finalFile.delete();
        return;
      }

      if (mounted && widget.onMediaCaptured != null) {
        widget.onMediaCaptured!(finalFile, null);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error capturing image: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _startVideoRecording() async {
    if (_isDisposed || _controller == null || !_controller!.value.isInitialized || !mounted) return;

    setState(() {
      _errorMessage = null;
    });

    try {
      await _controller!.startVideoRecording();
      if (mounted) {
        final startTime = DateTime.now();
        setState(() {
          _isRecording = true;
          _recordingStartTime = startTime;
        });
        
        // Start timer to update UI every second
        _recordingTimer?.cancel();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted && !_isDisposed && _isRecording) {
            final elapsed = DateTime.now().difference(startTime);
            if (elapsed.inSeconds >= 15) {
              timer.cancel();
              _stopVideoRecording();
            } else {
              setState(() {
                // Trigger rebuild to update timer display
              });
            }
          } else {
            timer.cancel();
          }
        });
        
        // Auto-stop after 15 seconds (backup)
        Future.delayed(const Duration(seconds: 15), () {
          if (mounted && _isRecording && !_isDisposed) {
            _stopVideoRecording();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error starting video: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_isDisposed || _controller == null || !_isRecording || !mounted) return;

    // Cancel timer
    _recordingTimer?.cancel();
    _recordingTimer = null;

    try {
      final video = await _controller!.stopVideoRecording();
      final videoFile = File(video.path);
      final fileSize = await FileUtils.getFileSize(videoFile);
      final fileSizeMB = fileSize / (1024 * 1024);
      final maxSizeMB = 5.0;

      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordingStartTime = null;
        });

        if (fileSizeMB > maxSizeMB) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Video size (${fileSizeMB.toStringAsFixed(2)}MB) exceeds maximum (${maxSizeMB}MB)'),
              backgroundColor: Colors.red,
            ),
          );
          await videoFile.delete();
          return;
        }

        if (widget.onMediaCaptured != null) {
          widget.onMediaCaptured!(null, videoFile);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordingStartTime = null;
          _errorMessage = 'Error stopping video: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_isDisposed || _cameras == null || _cameras!.length < 2 || !mounted) return;

    setState(() {
      _isInitialized = false;
    });

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    
    final previousController = _controller;
    _controller = null;
    
    await previousController?.dispose();
    
    if (mounted && !_isDisposed) {
      await _initializeController(_cameras![_selectedCameraIndex]);
    }
  }

  String _getRecordingDuration() {
    if (_recordingStartTime == null) return '';
    final duration = DateTime.now().difference(_recordingStartTime!);
    final seconds = duration.inSeconds;
    if (seconds >= 15) return '15s';
    return '${seconds}s';
  }

  void _switchMode(String mode) {
    if (_isRecording) return; // Don't allow mode switch while recording
    setState(() {
      _mode = mode;
    });
  }

  void _handleCaptureButton() {
    if (_mode == 'video') {
      if (_isRecording) {
        _stopVideoRecording();
      } else {
        _startVideoRecording();
      }
    } else {
      _takePicture();
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    
    if (widget.allowVideo) {
      // Show bottom sheet to choose image or video
      final choice = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Pick Image'),
                onTap: () => Navigator.pop(context, 'image'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Pick Video'),
                onTap: () => Navigator.pop(context, 'video'),
              ),
            ],
          ),
        ),
      );

      if (choice == 'video') {
        final video = await picker.pickVideo(source: ImageSource.gallery);
        if (video != null) {
          final videoFile = File(video.path);
          final fileSize = await FileUtils.getFileSize(videoFile);
          final fileSizeMB = fileSize / (1024 * 1024);
          final maxSizeMB = 5.0;

          if (fileSizeMB > maxSizeMB) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Video size (${fileSizeMB.toStringAsFixed(2)}MB) exceeds maximum (${maxSizeMB}MB)'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          if (mounted && widget.onMediaCaptured != null) {
            widget.onMediaCaptured!(null, videoFile);
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            Navigator.pop(context);
          }
        }
        return;
      }
    }

    // Pick image
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 720,
      imageQuality: 85,
    );

    if (image != null) {
      final imageFile = File(image.path);
      final compressedFile = await FileUtils.compressImage(
        imageFile,
        maxWidth: 1280,
        maxHeight: 720,
        quality: 85,
      );

      final finalFile = compressedFile ?? imageFile;
      final fileSize = await FileUtils.getFileSize(finalFile);
      final fileSizeKB = fileSize / 1024;
      final maxSizeKB = 500;

      if (mounted) {
        if (fileSizeKB > maxSizeKB) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image size (${fileSizeKB.toStringAsFixed(1)}KB) exceeds maximum (${maxSizeKB}KB)'),
              backgroundColor: Colors.red,
            ),
          );
          await finalFile.delete();
          return;
        }

        if (widget.onMediaCaptured != null) {
          widget.onMediaCaptured!(finalFile, null);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _controller?.dispose();
    _controller = null;
    // Restore system UI when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide system UI for full-screen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Full-screen camera preview - fills entire screen
            if (_isInitialized && _controller != null && _controller!.value.isInitialized)
              Positioned.fill(
                child: CameraPreview(_controller!),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

          // Top controls (close button)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 32),
                    onPressed: () {
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                      Navigator.pop(context);
                    },
                  ),
                  if (_cameras != null && _cameras!.length > 1)
                    IconButton(
                      icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
                      onPressed: _switchCamera,
                    ),
                ],
              ),
            ),
          ),

          // Recording timer overlay
          if (_isRecording && _recordingStartTime != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getRecordingDuration(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom controls
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mode switcher
                  if (widget.allowVideo)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _switchMode('photo'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                color: _mode == 'photo' ? Colors.white : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Photo',
                                style: TextStyle(
                                  color: _mode == 'photo' ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _switchMode('video'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                color: _mode == 'video' ? Colors.white : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Video',
                                style: TextStyle(
                                  color: _mode == 'video' ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Capture controls
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Gallery button
                        IconButton(
                          icon: const Icon(Icons.photo_library, color: Colors.white, size: 32),
                          onPressed: _pickFromGallery,
                          tooltip: 'Pick from gallery',
                        ),
                        
                        // Capture button
                        GestureDetector(
                          onTap: _handleCaptureButton,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _mode == 'video' && !_isRecording ? Colors.red : Colors.white,
                              border: Border.all(
                                color: _isRecording ? Colors.red : (_mode == 'video' ? Colors.red : Colors.grey.shade300),
                                width: 4,
                              ),
                            ),
                            child: _isRecording
                                ? const Icon(Icons.stop, color: Colors.white, size: 36)
                                : Icon(
                                    _mode == 'video' ? Icons.videocam : Icons.camera_alt,
                                    color: _mode == 'video' && !_isRecording ? Colors.white : Colors.black,
                                    size: 36,
                                  ),
                          ),
                        ),
                        
                        // Switch camera button (if multiple cameras) or spacer
                        if (_cameras != null && _cameras!.length > 1)
                          IconButton(
                            icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
                            onPressed: _switchCamera,
                            tooltip: 'Switch camera',
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Error message
          if (_errorMessage != null)
            SafeArea(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                          Navigator.pop(context);
                        },
                        child: const Text('Close', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
