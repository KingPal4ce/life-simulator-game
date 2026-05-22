import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

abstract interface class ILocalStorageService {
  Future<void> init();
  void saveSession(PlayerStats stats, String previousOutcome);
  PlayerStats? loadStats();
  String? loadPreviousOutcome();
  void clearSession();
}

class LocalStorageService implements ILocalStorageService {
  static const String boxName = 'gameBox';
  static const String sessionKey = 'session';
  static const String previousOutcomeKey = 'previousOutcome';

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  @override
  void saveSession(PlayerStats stats, String previousOutcome) {
    final box = Hive.box(boxName);
    box.put(sessionKey, jsonEncode(stats.toJson()));
    box.put(previousOutcomeKey, previousOutcome);
  }

  @override
  PlayerStats? loadStats() {
    final box = Hive.box(boxName);
    final savedState = box.get(sessionKey);
    if (savedState != null) {
      try {
        return PlayerStats.fromJson(jsonDecode(savedState));
      } catch (e) {
        debugPrint('LocalStorageService: failed to load stats: $e');
        return null;
      }
    }
    return null;
  }

  @override
  String? loadPreviousOutcome() {
    final box = Hive.box(boxName);
    return box.get(previousOutcomeKey);
  }

  @override
  void clearSession() {
    final box = Hive.box(boxName);
    box.delete(sessionKey);
    box.delete(previousOutcomeKey);
  }
}
