import 'package:flutter/foundation.dart';
import 'audio_engine.dart';

class SaveData {
  int highScore;
  int totalKills;
  int totalGoldGathered;
  int unlockedCampaignLevel;
  bool soundEnabled;
  bool musicEnabled;

  SaveData({
    this.highScore = 0,
    this.totalKills = 0,
    this.totalGoldGathered = 0,
    this.unlockedCampaignLevel = 1,
    this.soundEnabled = true,
    this.musicEnabled = true,
  });
}

class SaveSystem {
  static final SaveData _data = SaveData();

  static SaveData get data => _data;

  static void initialize() {
    // Carga inicial de datos de preferencias
    AudioEngine.soundEnabled = _data.soundEnabled;
    AudioEngine.musicEnabled = _data.musicEnabled;
  }

  static void updateHighScore(int score) {
    if (score > _data.highScore) {
      _data.highScore = score;
      save();
    }
  }

  static void addMatchStats({required int kills, required int gold, required int score}) {
    _data.totalKills += kills;
    _data.totalGoldGathered += gold;
    if (score > _data.highScore) {
      _data.highScore = score;
    }
    save();
  }

  static void unlockLevel(int levelIndex) {
    if (levelIndex > _data.unlockedCampaignLevel) {
      _data.unlockedCampaignLevel = levelIndex;
      save();
    }
  }

  static void setSoundEnabled(bool enabled) {
    _data.soundEnabled = enabled;
    AudioEngine.soundEnabled = enabled;
    save();
  }

  static void setMusicEnabled(bool enabled) {
    _data.musicEnabled = enabled;
    AudioEngine.musicEnabled = enabled;
    save();
  }

  static void save() {
    debugPrint('[SaveSystem] Guardando datos de progreso: Récord=${_data.highScore}, Bajas Totales=${_data.totalKills}');
  }
}
