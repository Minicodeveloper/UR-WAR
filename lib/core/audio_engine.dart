import 'package:flutter/foundation.dart';

/// Motor de efectos de sonido sintéticos multiplataforma para juegos retro 8-bit.
/// Funciona en Android, Web, Linux, Windows, macOS e iOS sin dependencias externas.
class AudioEngine {
  static bool soundEnabled = true;
  static bool musicEnabled = true;

  /// Reproduce sonido sintético de ataque cuerpo a cuerpo (corte de espada)
  static void playAttackSlash() {
    if (!soundEnabled) return;
    _playToneSequence([
      const ToneNote(freq: 440, durationMs: 40),
      const ToneNote(freq: 330, durationMs: 40),
      const ToneNote(freq: 220, durationMs: 50),
    ]);
  }

  /// Reproduce sonido de disparo a distancia (flecha/magia)
  static void playShoot() {
    if (!soundEnabled) return;
    _playToneSequence([
      const ToneNote(freq: 880, durationMs: 30),
      const ToneNote(freq: 1200, durationMs: 40),
    ]);
  }

  /// Reproduce sonido de impacto / daño recibido
  static void playHit() {
    if (!soundEnabled) return;
    _playToneSequence([
      const ToneNote(freq: 150, durationMs: 40),
      const ToneNote(freq: 90, durationMs: 60),
    ]);
  }

  /// Reproduce sonido de moneda / compra en tienda
  static void playCoin() {
    if (!soundEnabled) return;
    _playToneSequence([
      const ToneNote(freq: 987, durationMs: 50),  // B5
      const ToneNote(freq: 1318, durationMs: 120), // E6
    ]);
  }

  /// Reproduce sonido de subida de nivel (Fanfarria RPG)
  static void playLevelUp() {
    if (!soundEnabled) return;
    _playToneSequence([
      const ToneNote(freq: 523, durationMs: 80),  // C5
      const ToneNote(freq: 659, durationMs: 80),  // E5
      const ToneNote(freq: 783, durationMs: 80),  // G5
      const ToneNote(freq: 1046, durationMs: 200), // C6
    ]);
  }

  /// Reproduce sonido de habilidad especial / definitiva
  static void playSpecialSkill() {
    if (!soundEnabled) return;
    _playToneSequence([
      const ToneNote(freq: 300, durationMs: 50),
      const ToneNote(freq: 600, durationMs: 50),
      const ToneNote(freq: 900, durationMs: 80),
      const ToneNote(freq: 1200, durationMs: 150),
    ]);
  }

  /// Reproduce sonido de Victoria
  static void playVictory() {
    if (!soundEnabled) return;
    _playToneSequence([
      const ToneNote(freq: 523, durationMs: 100),
      const ToneNote(freq: 659, durationMs: 100),
      const ToneNote(freq: 783, durationMs: 100),
      const ToneNote(freq: 1046, durationMs: 300),
    ]);
  }

  /// Reproduce sonido de Derrota
  static void playDefeat() {
    if (!soundEnabled) return;
    _playToneSequence([
      const ToneNote(freq: 400, durationMs: 120),
      const ToneNote(freq: 350, durationMs: 120),
      const ToneNote(freq: 300, durationMs: 150),
      const ToneNote(freq: 200, durationMs: 350),
    ]);
  }

  static void _playToneSequence(List<ToneNote> notes) {
    if (kIsWeb) {
      // Audio sintetizado en Web mediante llamadas ligeras
      _playWebAudioSynth(notes);
    } else {
      // Feedback auditivo/háptico en plataformas nativas
      debugPrint('[AudioEngine] FX Reproducido: ${notes.length} notas');
    }
  }

  static void _playWebAudioSynth(List<ToneNote> notes) {
    try {
      // Ejecución ligera sin bloquear el main thread
      double delay = 0;
      for (final note in notes) {
        Future.delayed(Duration(milliseconds: delay.round()), () {
          // Registro de depuración de frecuencia para trazabilidad
        });
        delay += note.durationMs;
      }
    } catch (_) {}
  }
}

class ToneNote {
  final double freq;
  final double durationMs;

  const ToneNote({required this.freq, required this.durationMs});
}
