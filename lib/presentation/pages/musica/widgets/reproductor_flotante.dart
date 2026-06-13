import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ReproductorFlotante extends StatefulWidget {
  final Map<String, dynamic> cancion;
  final String audioUrl;
  final VoidCallback onFinished;

  const ReproductorFlotante({
    super.key,
    required this.cancion,
    required this.audioUrl,
    required this.onFinished,
  });

  @override
  State<ReproductorFlotante> createState() => _ReproductorFlotanteState();
}

class _ReproductorFlotanteState extends State<ReproductorFlotante> {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _completeSub;

  String? _lastUrl;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioListeners();
    _playAudio();
  }

  void _initAudioListeners() {
    _durationSub = _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _stateSub = _audioPlayer.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _playerState = s);
    });

    _completeSub = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _position = Duration.zero;
          _playerState = PlayerState.completed;
        });
        widget.onFinished();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ReproductorFlotante oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _playAudio();
    }
  }

  Future<void> _playAudio() async {
    if (widget.audioUrl.isEmpty) return;
    
    try {
      _lastUrl = widget.audioUrl;
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(widget.audioUrl));
    } catch (e) {
      debugPrint('[REPRODUCTOR] >> Error al reproducir audio: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_playerState == PlayerState.playing) {
        await _audioPlayer.pause();
      } else if (_playerState == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        if (_lastUrl != null) {
          await _audioPlayer.play(UrlSource(_lastUrl!));
        }
      }
    } catch (e) {
      debugPrint('[REPRODUCTOR] >> Error al pausar/reproducir: $e');
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _stateSub?.cancel();
    _completeSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.cancion['nombre'] ?? 'Sin título';
    final artista = widget.cancion['artista_nombre'] ?? 'Artista desconocido';

    final isPlaying = _playerState == PlayerState.playing;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 16,
            offset: Offset(0, -4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fila: Carátula, Info del Tema, Controles de Reproducción
            Row(
              children: [
                // Carátula ficticia musical con micro-animación pulsante si está sonando
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C6FF7).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF7C6FF7).withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.music_note_rounded,
                      color: isPlaying ? const Color(0xFFE74C3C) : const Color(0xFF7C6FF7),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        artista,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Botón Play / Pause
                IconButton(
                  onPressed: _togglePlayPause,
                  icon: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF7C6FF7),
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Barra de progreso y Tiempos
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: const Color(0xFF7C6FF7),
                    inactiveTrackColor: Colors.white10,
                    thumbColor: const Color(0xFF7C6FF7),
                    overlayColor: const Color(0xFF7C6FF7).withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _position.inMilliseconds.toDouble().clamp(
                          0.0,
                          _duration.inMilliseconds.toDouble(),
                        ),
                    max: _duration.inMilliseconds.toDouble() > 0
                        ? _duration.inMilliseconds.toDouble()
                        : 1.0,
                    onChanged: (value) async {
                      final position = Duration(milliseconds: value.toInt());
                      await _audioPlayer.seek(position);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
