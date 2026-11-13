import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  String _apiKey = '';
  bool _isDemoMode = true; // Default to demo mode to prevent accidental quota burning

  String get apiKey => _apiKey;
  bool get isDemoMode => _isDemoMode;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _apiKey = _prefs.getString(ApiConstants.apiKeyStorageKey) ?? '';
    _isDemoMode = _prefs.getBool(ApiConstants.demoModeStorageKey) ?? true;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key.trim();
    await _prefs.setString(ApiConstants.apiKeyStorageKey, _apiKey);
    if (_apiKey.isNotEmpty) {
      // Auto-switch to live mode when key is entered
      _isDemoMode = false;
      await _prefs.setBool(ApiConstants.demoModeStorageKey, false);
    }
    notifyListeners();
  }

  Future<void> setDemoMode(bool value) async {
    _isDemoMode = value;
    await _prefs.setBool(ApiConstants.demoModeStorageKey, value);
    notifyListeners();
  }
}

