import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class LocalStorageService {
  static const String boxName = 'gameBox';
  static const String sessionKey = 'session';
  static const String previousOutcomeKey = 'previousOutcome';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  void saveSession(PlayerStats stats, String previousOutcome) {
    final box = Hive.box(boxName);
    box.put(sessionKey, jsonEncode(stats.toJson()));
    box.put(previousOutcomeKey, previousOutcome);
  }

  PlayerStats? loadStats() {
    final box = Hive.box(boxName);
    final savedState = box.get(sessionKey);
    if (savedState != null) {
      try {
        return PlayerStats.fromJson(jsonDecode(savedState));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String? loadPreviousOutcome() {
    final box = Hive.box(boxName);
    return box.get(previousOutcomeKey);
  }

  void clearSession() {
    final box = Hive.box(boxName);
    box.delete(sessionKey);
    box.delete(previousOutcomeKey);
  }
}
