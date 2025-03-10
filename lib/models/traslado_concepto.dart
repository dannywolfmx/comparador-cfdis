import 'dart:developer' as developer;

class TrasladoConcepto {
  final double base;
  final String impuesto;
  final String tipoFactor;
  final double tasaOCuota;
  final double importe;

  TrasladoConcepto({
    required this.base,
    required this.impuesto,
    required this.tipoFactor,
    required this.tasaOCuota,
    required this.importe,
  });

  factory TrasladoConcepto.fromJson(Map<String, dynamic> json) {
    // Manejar casos de claves en minúsculas y mayúsculas
    double base;
    try {
      base = double.parse((json['Base'] ?? json['base'] ?? '0.0')
          .toString()
          .replaceAll(',', ''));
    } catch (e) {
      developer.log('Error parsing base: ${e.toString()}');
      base = 0.0;
    }

    String impuesto = (json['Impuesto'] ?? json['impuesto'] ?? '').toString();
    String tipoFactor =
        (json['TipoFactor'] ?? json['tipoFactor'] ?? '').toString();

    double tasaOCuota;
    try {
      tasaOCuota = double.parse(
          (json['TasaOCuota'] ?? json['tasaOCuota'] ?? '0.0')
              .toString()
              .replaceAll(',', ''));
    } catch (e) {
      developer.log('Error parsing tasaOCuota: ${e.toString()}');
      tasaOCuota = 0.0;
    }

    double importe;
    try {
      importe = double.parse((json['Importe'] ?? json['importe'] ?? '0.0')
          .toString()
          .replaceAll(',', ''));
    } catch (e) {
      developer.log('Error parsing importe: ${e.toString()}');
      importe = 0.0;
    }

    return TrasladoConcepto(
      base: base,
      impuesto: impuesto,
      tipoFactor: tipoFactor,
      tasaOCuota: tasaOCuota,
      importe: importe,
    );
  }

  // Agregar método para comparar traslados
  bool equals(TrasladoConcepto other) {
    return impuesto == other.impuesto &&
        tipoFactor == other.tipoFactor &&
        tasaOCuota == other.tasaOCuota;
  }

  Map<String, dynamic> toJson() {
    return {
      'Base': base,
      'Impuesto': impuesto,
      'TipoFactor': tipoFactor,
      'TasaOCuota': tasaOCuota,
      'Importe': importe,
    };
  }
}
