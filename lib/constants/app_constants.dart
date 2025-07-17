// Application constants
class AppConstants {
  // File extensions
  static const String xmlExtension = '.xml';
  static const List<String> supportedExtensions = ['xml'];
  
  // CFDI Namespaces
  static const Map<String, String> cfdiNamespaces = {
    'cfdi': 'http://www.sat.gob.mx/cfd/4',
    'tfd': 'http://www.sat.gob.mx/TimbreFiscalDigital',
    'pago10': 'http://www.sat.gob.mx/Pagos',
    'pago20': 'http://www.sat.gob.mx/Pagos20',
    'nomina12': 'http://www.sat.gob.mx/nomina12',
  };
  
  // UI Constants
  static const int defaultPageSize = 50;
  static const int maxSearchResults = 1000;
  static const Duration defaultTimeout = Duration(seconds: 30);
  
  // Error Messages
  static const String noDirectorySelected = 'No se seleccionó ningún directorio';
  static const String noCfdisFound = 'No se encontraron CFDIs en el directorio seleccionado';
  static const String invalidXmlFormat = 'El archivo XML no tiene un formato válido';
  static const String fileReadError = 'Error al leer el archivo';
  
  // Validation Rules
  static const int minRfcLength = 12;
  static const int maxRfcLength = 13;
  static const int uuidLength = 36;
  
  // Currency
  static const String defaultCurrency = 'MXN';
  static const double defaultExchangeRate = 1.0;
}
