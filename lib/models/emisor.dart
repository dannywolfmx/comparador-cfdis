class Emisor {
  final String rfc;
  final String nombre;
  final String regimenFiscal;

  Emisor({
    required this.rfc,
    required this.nombre,
    required this.regimenFiscal,
  });

  factory Emisor.fromJson(Map<String, dynamic> json) {
    return Emisor(
      rfc: json['Rfc'] ?? '',
      nombre: json['Nombre'] ?? '',
      regimenFiscal: json['RegimenFiscal'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Rfc': rfc,
      'Nombre': nombre,
      'RegimenFiscal': regimenFiscal,
    };
  }
}
