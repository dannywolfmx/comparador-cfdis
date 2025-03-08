class ImpuestoConcepto {
  final String impuesto;
  final String tipoFactor;
  final double tasaOCuota;
  final double base;
  final double importe;
  final bool esTraslado;

  ImpuestoConcepto({
    required this.impuesto,
    required this.tipoFactor,
    required this.tasaOCuota,
    required this.base,
    required this.importe,
    required this.esTraslado,
  });

  factory ImpuestoConcepto.fromJson(
      Map<String, dynamic> json, bool esTraslado) {
    return ImpuestoConcepto(
      impuesto: json['Impuesto'] ?? '',
      tipoFactor: json['TipoFactor'] ?? '',
      tasaOCuota: double.tryParse(json['TasaOCuota'] ?? '0.0') ?? 0.0,
      base: double.tryParse(json['Base'] ?? '0.0') ?? 0.0,
      importe: double.tryParse(json['Importe'] ?? '0.0') ?? 0.0,
      esTraslado: esTraslado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Impuesto': impuesto,
      'TipoFactor': tipoFactor,
      'TasaOCuota': tasaOCuota,
      'Base': base,
      'Importe': importe,
    };
  }
}
