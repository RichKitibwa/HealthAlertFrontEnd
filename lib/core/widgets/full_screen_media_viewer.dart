// Full-screen media viewer for images and videos

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FullScreenMediaViewer extends StatefulWidget {
  final File? imageFile;
  final File? videoFile;

  const FullScreenMediaViewer({
    Key? key,
    this.imageFile,
    this.videoFile,
  }) : super(key: key);

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;
  File? _videoThumbnail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.videoFile != null) {
      _initializeVideo();
      _generateThumbnail();
    }
  }

  Future<void> _generateThumbnail() async {
    if (widget.videoFile == null) return;
    
    try {
      if (!widget.videoFile!.existsSync()) return;
      
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: widget.videoFile!.path,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
        timeMs: 1000,
      );

      if (thumbnailPath != null && mounted) {
        final thumbFile = File(thumbnailPath);
        if (thumbFile.existsSync()) {
          setState(() {
            _videoThumbnail = thumbFile;
          });
        }
      }
    } catch (e) {
      // Ignore thumbnail generation errors, will show loading indicator
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.videoFile == null) return;
    
    // Check if file exists
    if (!widget.videoFile!.existsSync()) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Video file not found at: ${widget.videoFile!.path}';
        });
      }
      return;
    }
    
    try {
      // Get absolute path to ensure proper file access
      final videoFile = widget.videoFile!;
      final videoPath = videoFile.absolute.path;
      
      // Verify file is readable
      if (!await videoFile.exists()) {
        throw Exception('Video file does not exist: $videoPath');
      }
      
      // Check file size
      final fileSize = await videoFile.length();
      if (fileSize == 0) {
        throw Exception('Video file is empty');
      }
      
      // Dispose any existing controller first
      await _videoController?.dispose();
      _videoController = null;
      
      // Small delay to ensure controller is fully disposed
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Try to check if video_player plugin is available
      try {
        // Create new controller with absolute path
        _videoController = VideoPlayerController.file(File(videoPath));
      } catch (controllerError) {
        throw Exception('Failed to create VideoPlayerController: ${controllerError.toString()}. This might indicate the video_player plugin is not properly installed. Please rebuild the app.');
      }
      
      // Initialize with timeout and better error handling
      try {
        await _videoController!.initialize().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Video initialization timed out after 15 seconds');
          },
        );
      } on PlatformException catch (platformError) {
        // Handle platform-specific errors
        throw Exception('Platform error: ${platformError.message}. Code: ${platformError.code}. Details: ${platformError.details}. Please ensure video_player plugin is properly installed and rebuild the app.');
      } on UnimplementedError catch (unimplementedError) {
        // Handle unimplemented errors specifically
        throw Exception('Video player not implemented: ${unimplementedError.message}. The video_player plugin may not be properly linked. Please: 1) Run "flutter clean", 2) Run "flutter pub get", 3) Fully rebuild the app (not hot reload).');
      } catch (initError) {
        // Re-throw with more context
        throw Exception('VideoPlayerController.initialize() failed: ${initError.toString()}');
      }
      
      if (mounted && _videoController != null) {
        // Check if initialization was successful
        if (_videoController!.value.hasError) {
          final errorDesc = _videoController!.value.errorDescription ?? 'Unknown error';
          throw Exception('Video initialization error: $errorDesc');
        }
        
        if (!_videoController!.value.isInitialized) {
          throw Exception('Video controller not initialized properly');
        }
        
        setState(() {
          _isVideoInitialized = true;
          _isVideoPlaying = _videoController!.value.isPlaying;
          _errorMessage = null;
        });
        
        _videoController!.addListener(_onVideoControllerUpdate);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
          _errorMessage = 'Failed to load video: ${e.toString()}';
        });
      }
      
      // Clean up on error
      try {
        await _videoController?.dispose();
      } catch (_) {
        // Ignore disposal errors
      }
      _videoController = null;
    }
  }
  
  void _onVideoControllerUpdate() {
    if (!mounted || _videoController == null) return;
    
    setState(() {
      _isVideoPlaying = _videoController!.value.isPlaying;
      
      // Check for errors during playback
      if (_videoController!.value.hasError) {
        _errorMessage = _videoController!.value.errorDescription ?? 'Video playback error';
        _isVideoInitialized = false;
      }
    });
  }

  void _toggleVideoPlayback() {
    if (_videoController == null || !_isVideoInitialized) return;
    
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoControllerUpdate);
    _videoController?.dispose();
    _videoController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Media content (behind everything)
            Center(
              child: widget.imageFile != null
                  ? InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.file(
                        widget.imageFile!,
                        fit: BoxFit.contain,
                      ),
                    )
                  : widget.videoFile != null
                      ? _buildVideoPlayer()
                      : const SizedBox(),
            ),

            // Close button (on top, should be clickable)
            // Positioned after video player so it's on top
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),

            // Video controls
            if (widget.videoFile != null && _isVideoInitialized)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: FloatingActionButton(
                    onPressed: _toggleVideoPlayback,
                    backgroundColor: Colors.black54,
                    child: Icon(
                      _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),

            // Error message
            if (_errorMessage != null)
              Center(
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
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_errorMessage != null) {
      return const SizedBox(); // Error is shown in the main stack
    }

    if (!_isVideoInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (_videoThumbnail != null && _videoThumbnail!.existsSync())
            Image.file(
              _videoThumbnail!,
              fit: BoxFit.contain,
            ),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Loading video...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing video...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
        if (!_isVideoPlaying)
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 64,
              ),
            ),
          ),
        // Gesture detector for video tap to play/pause
        GestureDetector(
          onTap: _toggleVideoPlayback,
          behavior: HitTestBehavior.translucent,
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ],
    );
  }
}
