class Receptor {
  final String rfc;
  final String nombre;
  final String usoCFDI;
  final String domicilioFiscalReceptor;
  final String regimenFiscalReceptor;

  Receptor({
    required this.rfc,
    required this.nombre,
    required this.usoCFDI,
    required this.domicilioFiscalReceptor,
    required this.regimenFiscalReceptor,
  });

  factory Receptor.fromJson(Map<String, dynamic> json) {
    return Receptor(
      rfc: json['Rfc'] ?? '',
      nombre: json['Nombre'] ?? '',
      usoCFDI: json['UsoCFDI'] ?? '',
      domicilioFiscalReceptor: json['DomicilioFiscalReceptor'] ?? '',
      regimenFiscalReceptor: json['RegimenFiscalReceptor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Rfc': rfc,
      'Nombre': nombre,
      'UsoCFDI': usoCFDI,
      'DomicilioFiscalReceptor': domicilioFiscalReceptor,
      'RegimenFiscalReceptor': regimenFiscalReceptor,
    };
  }
}
