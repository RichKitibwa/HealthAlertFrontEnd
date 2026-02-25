// Voice note recording and playback widget

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../l10n/app_localizations.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceNoteWidget extends StatefulWidget {
  final Function(File? audioFile)? onAudioRecorded;

  const VoiceNoteWidget({
    Key? key,
    this.onAudioRecorded,
  }) : super(key: key);

  @override
  State<VoiceNoteWidget> createState() => _VoiceNoteWidgetState();
}

class _VoiceNoteWidgetState extends State<VoiceNoteWidget> with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _hasRecording = false;
  File? _audioFile;
  
  DateTime? _recordingStartTime;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  
  Timer? _recordingTimer;
  Timer? _playbackTimer;
  
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _player.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _playbackDuration = position;
        });
      }
    });
    
    _player.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });
    
    _player.playerStateStream.listen((state) {
      if (mounted) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
            _playbackDuration = Duration.zero;
          });
          _playbackTimer?.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _animationController.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<bool> _checkPermissions() async {
    final microphoneStatus = await Permission.microphone.request();
    return microphoneStatus.isGranted;
  }

  Future<void> _startRecording() async {
    if (!await _checkPermissions()) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.microphonePermissionRequired),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${tempDir.path}/voice_note_$timestamp.m4a';
      
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );
        
        final startTime = DateTime.now();
        setState(() {
          _isRecording = true;
          _recordingStartTime = startTime;
          _recordingDuration = Duration.zero;
        });
        
        _animationController.forward();
        
        _recordingTimer?.cancel();
        _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (mounted && _isRecording) {
            setState(() {
              _recordingDuration = DateTime.now().difference(startTime);
            });
          } else {
            timer.cancel();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting recording: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      if (path != null && mounted) {
        final file = File(path);
        setState(() {
          _isRecording = false;
          _hasRecording = true;
          _audioFile = file;
        });
        
        _animationController.reset();
        _recordingTimer?.cancel();
        
        if (widget.onAudioRecorded != null) {
          widget.onAudioRecorded!(file);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping recording: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _togglePlayback() async {
    if (_audioFile == null || !_audioFile!.existsSync()) return;
    
    if (_isPlaying) {
      await _player.pause();
      setState(() {
        _isPlaying = false;
      });
      _playbackTimer?.cancel();
    } else {
      try {
        await _player.setFilePath(_audioFile!.path);
        await _player.play();
        setState(() {
          _isPlaying = true;
        });
        
        _playbackTimer?.cancel();
        _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (mounted && _isPlaying) {
            setState(() {
              // Position is updated via stream
            });
          } else {
            timer.cancel();
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error playing audio: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _seekTo(Duration position) {
    _player.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.voiceNoteOptional,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            height: 19 / 16,
            color: Color(0xFF0077CC),
          ),
        ),
        const SizedBox(height: 8),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE3E8EF)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Recording/Playback UI
              if (_isRecording)
                // Recording state
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _animation.value,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.recordingWithDuration(_formatDuration(_recordingDuration)),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Animated waveform line
                    SizedBox(
                      height: 28,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: WaveformPainter(_animation.value),
                            size: Size.infinite,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.stop_circle, size: 36, color: Colors.red),
                        onPressed: _stopRecording,
                      ),
                    ),
                  ],
                )
              else if (_hasRecording && _audioFile != null)
                // Playback state - compact row layout
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 36,
                          width: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                              size: 32,
                              color: const Color(0xFF0077CC),
                            ),
                            onPressed: _togglePlayback,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                            ),
                            child: Slider(
                              value: _playbackDuration.inMilliseconds.toDouble().clamp(
                                0.0,
                                _totalDuration.inMilliseconds > 0
                                  ? _totalDuration.inMilliseconds.toDouble()
                                  : 1.0,
                              ),
                              max: _totalDuration.inMilliseconds > 0
                                ? _totalDuration.inMilliseconds.toDouble()
                                : 1.0,
                              onChanged: (value) {
                                _seekTo(Duration(milliseconds: value.toInt()));
                              },
                              activeColor: const Color(0xFF0077CC),
                            ),
                          ),
                        ),
                        Text(
                          '${_formatDuration(_playbackDuration)}/${_formatDuration(_totalDuration)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF667085),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          height: 28,
                          width: 28,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _hasRecording = false;
                                _audioFile = null;
                                _isPlaying = false;
                                _playbackDuration = Duration.zero;
                                _totalDuration = Duration.zero;
                              });
                              _player.stop();
                              if (widget.onAudioRecorded != null) {
                                widget.onAudioRecorded!(null);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                // Initial state - compact mic row
                InkWell(
                  onTap: _startRecording,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.mic,
                          size: 28,
                          color: Color(0xFF0077CC),
                        ),
                        SizedBox(width: 8),
                        Text(
                          l10n.tapToRecordVoiceNote,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom painter for animated waveform
class WaveformPainter extends CustomPainter {
  final double animationValue;

  WaveformPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0077CC)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    final barWidth = 4.0;
    final spacing = 6.0;
    final maxHeight = size.height * 0.8;
    
    for (double x = 0; x < size.width; x += barWidth + spacing) {
                    final normalizedX = (x / size.width) * 2 * math.pi;
      final height = (math.sin(normalizedX + animationValue * 2 * math.pi) * 0.5 + 0.5) * maxHeight;
      
      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

