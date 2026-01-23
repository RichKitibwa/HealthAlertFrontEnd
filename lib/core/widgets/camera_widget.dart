// Camera widget with full-screen camera experience
// Shows camera icon or captured media preview

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../utils/file_utils.dart';
import 'full_screen_camera.dart';
import 'full_screen_media_viewer.dart';

class CameraWidget extends StatefulWidget {
  final Function(File? image, File? video)? onMediaCaptured;
  final bool allowVideo;
  final double? maxWidth;
  final double? maxHeight;

  const CameraWidget({
    Key? key,
    this.onMediaCaptured,
    this.allowVideo = true,
    this.maxWidth,
    this.maxHeight,
  }) : super(key: key);

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  File? _capturedImage;
  File? _capturedVideo;
  String? _imageSizeInfo;
  String? _videoSizeInfo;
  File? _videoThumbnail;

  Future<void> _generateVideoThumbnail(File videoFile) async {
    try {
      if (!videoFile.existsSync()) return;
      
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: videoFile.parent.path,
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
      // Ignore thumbnail generation errors, will show icon instead
      if (mounted) {
        setState(() {
          _videoThumbnail = null;
        });
      }
    }
  }

  Future<void> _openFullScreenViewer() async {
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FullScreenMediaViewer(
          imageFile: _capturedImage,
          videoFile: _capturedVideo,
        ),
        fullscreenDialog: true,
        opaque: true,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _openFullScreenCamera() async {
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FullScreenCamera(
          allowVideo: widget.allowVideo,
          onMediaCaptured: (image, video) {
            setState(() {
              _capturedImage = image;
              _capturedVideo = video;
              _imageSizeInfo = null;
              _videoSizeInfo = null;
            });

            // Update file size info
            if (image != null) {
              FileUtils.getFileSize(image).then((fileSize) {
                final fileSizeKB = fileSize / 1024;
                if (mounted) {
                  setState(() {
                    _imageSizeInfo = 'Image: ${fileSizeKB.toStringAsFixed(1)}KB';
                  });
                }
              });
            }

            if (video != null) {
              FileUtils.getFileSize(video).then((fileSize) {
                final fileSizeMB = fileSize / (1024 * 1024);
                if (mounted) {
                  setState(() {
                    _videoSizeInfo = 'Video: ${fileSizeMB.toStringAsFixed(2)}MB';
                  });
                }
              });
              _generateVideoThumbnail(video);
            }

            if (widget.onMediaCaptured != null) {
              widget.onMediaCaptured!(image, video);
            }
          },
        ),
        fullscreenDialog: true,
        opaque: true,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If media captured, show preview
    if (_capturedImage != null || _capturedVideo != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: widget.maxWidth ?? double.infinity,
              maxHeight: widget.maxHeight ?? 300,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE3E8EF),
              ),
            ),
              child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: _openFullScreenViewer,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _capturedImage != null
                        ? Image.file(
                            _capturedImage!,
                            fit: BoxFit.cover,
                          )
                        : _capturedVideo != null
                            ? _buildVideoThumbnail()
                            : const SizedBox(),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _capturedImage = null;
                            _capturedVideo = null;
                            _imageSizeInfo = null;
                            _videoSizeInfo = null;
                            _videoThumbnail = null;
                          });
                          if (widget.onMediaCaptured != null) {
                            widget.onMediaCaptured!(null, null);
                          }
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ),
                    if (_capturedVideo != null)
                      const Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_imageSizeInfo != null || _videoSizeInfo != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _imageSizeInfo ?? _videoSizeInfo ?? '',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF667085),
                ),
              ),
            ),
        ],
      );
    }

    // Show camera icon button
    return SizedBox(
      width: widget.maxWidth ?? double.infinity,
      height: widget.maxHeight ?? 300,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openFullScreenCamera,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE3E8EF),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0077CC).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 48,
                    color: Color(0xFF0077CC),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tap to open camera',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    if (_videoThumbnail != null && _videoThumbnail!.existsSync()) {
      return Image.file(
        _videoThumbnail!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    
    return Container(
      color: Colors.black87,
      width: double.infinity,
      height: double.infinity,
      child: const Center(
        child: Icon(
          Icons.videocam,
          size: 64,
          color: Color(0xFF0077CC),
        ),
      ),
    );
  }
}
