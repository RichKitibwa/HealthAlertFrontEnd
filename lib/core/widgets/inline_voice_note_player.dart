import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../l10n/app_localizations.dart';

class InlineVoiceNotePlayer extends StatefulWidget {
  final String voiceNoteUrl;

  const InlineVoiceNotePlayer({Key? key, required this.voiceNoteUrl})
      : super(key: key);

  @override
  State<InlineVoiceNotePlayer> createState() => _InlineVoiceNotePlayerState();
}

class _InlineVoiceNotePlayerState extends State<InlineVoiceNotePlayer> {
  late final AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _player.processingState == ProcessingState.idle) {
        _player.setUrl(widget.voiceNoteUrl);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        if (_player.processingState == ProcessingState.idle) {
          await _player.setUrl(widget.voiceNoteUrl);
        }
        await _player.play();
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.couldNotPlayVoiceNote),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPlaying = _player.playing;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.purple.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple.withAlpha(30)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _togglePlayback,
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.purple,
              size: 36,
            ),
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _StaticWaveBars(),
                const SizedBox(height: 4),
                Text(l10n.tapToPlay, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                const SizedBox(height: 6),
                StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, posSnap) {
                    return StreamBuilder<Duration?>(
                      stream: _player.durationStream,
                      builder: (context, durSnap) {
                        final pos = posSnap.data ?? Duration.zero;
                        final dur = durSnap.data ?? Duration.zero;
                        final totalMs = dur.inMilliseconds;
                        final prog = totalMs > 0
                            ? (pos.inMilliseconds / totalMs).clamp(0.0, 1.0)
                            : 0.0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                                activeTrackColor: Colors.purple,
                                inactiveTrackColor: Colors.purple.withAlpha(60),
                                thumbColor: Colors.purple,
                              ),
                              child: Slider(
                                value: prog,
                                onChanged: totalMs > 0
                                    ? (v) {
                                        _player.seek(Duration(milliseconds: (v * totalMs).round()));
                                      }
                                    : null,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(pos),
                                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                ),
                                Text(
                                  dur.inMilliseconds > 0 ? _formatDuration(dur) : _formatDuration(Duration.zero),
                                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticWaveBars extends StatelessWidget {
  const _StaticWaveBars();

  @override
  Widget build(BuildContext context) {
    const barCount = 24;
    const barHeight = 20.0;
    const barWidth = 3.0;
    const spacing = 2.0;
    final heights = List.generate(barCount, (i) {
      final t = i / barCount;
      return 4.0 + (math.sin(t * math.pi * 3) * 0.5 + 0.5) * (barHeight - 8);
    });

    return SizedBox(
      height: barHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(barCount, (i) {
          return Container(
            width: barWidth,
            height: heights[i],
            margin: const EdgeInsets.symmetric(horizontal: spacing / 2),
            decoration: BoxDecoration(
              color: Colors.purple.withAlpha(180),
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
      ),
    );
  }
}
