class Impuesto {
  final double totalImpuestosRetenidos;
  final double totalImpuestosTrasladados;
  final List<Map<String, dynamic>> retenciones;
  final List<Map<String, dynamic>> traslados;

  Impuesto({
    required this.totalImpuestosRetenidos,
    required this.totalImpuestosTrasladados,
    required this.retenciones,
    required this.traslados,
  });

  factory Impuesto.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> retenciones = [];
    if (json['Retenciones'] != null &&
        json['Retenciones']['Retencion'] != null) {
      final retencionesData = json['Retenciones']['Retencion'];
      if (retencionesData is List) {
        retenciones = List<Map<String, dynamic>>.from(retencionesData);
      } else {
        retenciones = [Map<String, dynamic>.from(retencionesData)];
      }
    }

    List<Map<String, dynamic>> traslados = [];
    if (json['Traslados'] != null && json['Traslados']['Traslado'] != null) {
      final trasladosData = json['Traslados']['Traslado'];
      if (trasladosData is List) {
        traslados = List<Map<String, dynamic>>.from(trasladosData);
      } else {
        traslados = [Map<String, dynamic>.from(trasladosData)];
      }
    }

    return Impuesto(
      totalImpuestosRetenidos:
          double.tryParse(json['TotalImpuestosRetenidos'] ?? '0.0') ?? 0.0,
      totalImpuestosTrasladados:
          double.tryParse(json['TotalImpuestosTrasladados'] ?? '0.0') ?? 0.0,
      retenciones: retenciones,
      traslados: traslados,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (totalImpuestosRetenidos > 0) {
      data['TotalImpuestosRetenidos'] = totalImpuestosRetenidos;
    }

    if (totalImpuestosTrasladados > 0) {
      data['TotalImpuestosTrasladados'] = totalImpuestosTrasladados;
    }

    if (retenciones.isNotEmpty) {
      data['Retenciones'] = {'Retencion': retenciones};
    }

    if (traslados.isNotEmpty) {
      data['Traslados'] = {'Traslado': traslados};
    }

    return data;
  }
}
