import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationService {
  static const String _keyDefaultDirectory = 'default_directory';
  static const String _keyPageSize = 'page_size';
  static const String _keyAutoSave = 'auto_save';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyColumnVisibility = 'column_visibility';
  
  static late SharedPreferences _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Directory settings
  static String? get defaultDirectory => _prefs.getString(_keyDefaultDirectory);
  static Future<void> setDefaultDirectory(String path) async {
    await _prefs.setString(_keyDefaultDirectory, path);
  }
  
  // Page size settings
  static int get pageSize => _prefs.getInt(_keyPageSize) ?? 50;
  static Future<void> setPageSize(int size) async {
    await _prefs.setInt(_keyPageSize, size);
  }
  
  // Auto save settings
  static bool get autoSave => _prefs.getBool(_keyAutoSave) ?? true;
  static Future<void> setAutoSave(bool value) async {
    await _prefs.setBool(_keyAutoSave, value);
  }
  
  // Theme settings
  static String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';
  static Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }
  
  // Column visibility settings
  static List<String> get visibleColumns {
    return _prefs.getStringList(_keyColumnVisibility) ?? [
      'serie',
      'folio',
      'fecha',
      'emisor',
      'receptor',
      'total',
      'tipoComprobante',
    ];
  }
  
  static Future<void> setVisibleColumns(List<String> columns) async {
    await _prefs.setStringList(_keyColumnVisibility, columns);
  }
  
  // Reset all settings
  static Future<void> reset() async {
    await _prefs.clear();
  }
}
