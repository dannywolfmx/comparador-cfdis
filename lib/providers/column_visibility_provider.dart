import 'package:flutter/foundation.dart';

/// Provider para gestionar la visibilidad de columnas en la tabla de CFDIs
class ColumnVisibilityProvider with ChangeNotifier {
  /// Mapa que contiene el estado de visibilidad de las columnas
  final Map<String, bool> _columnVisibility = {
    'emisor': true,
    'receptor': true,
    'fecha': true,
    'total': true,
    'tipo': true,
    'uuid': true,
  };

  /// Verifica si una columna está visible
  bool isVisible(String columnId) {
    return _columnVisibility[columnId] ?? false;
  }

  /// Cambia la visibilidad de una columna
  void toggleVisibility(String columnId) {
    if (_columnVisibility.containsKey(columnId)) {
      _columnVisibility[columnId] = !_columnVisibility[columnId]!;
      notifyListeners();
    }
  }

  /// Establece la visibilidad de una columna
  void setVisibility(String columnId, bool isVisible) {
    if (_columnVisibility.containsKey(columnId)) {
      _columnVisibility[columnId] = isVisible;
      notifyListeners();
    }
  }

  /// Restablece todas las columnas a su valor predeterminado (todas visibles)
  void resetToDefault() {
    for (var key in _columnVisibility.keys) {
      _columnVisibility[key] = true;
    }
    notifyListeners();
  }

  /// Obtiene un mapa con todas las columnas y sus estados de visibilidad
  Map<String, bool> get allColumns => Map.unmodifiable(_columnVisibility);

  /// Obtiene una lista con los IDs de las columnas visibles
  List<String> get visibleColumns => _columnVisibility.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();
}
