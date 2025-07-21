class TimbreFiscal {
  final String version;
  final String uuid;
  final DateTime fechaTimbrado;
  final String rfcProvCertif;
  final String selloCFD;
  final String selloSAT;
  final String noCertificadoSAT;

  TimbreFiscal({
    required this.version,
    required this.uuid,
    required this.fechaTimbrado,
    required this.rfcProvCertif,
    required this.selloCFD,
    required this.selloSAT,
    required this.noCertificadoSAT,
  });

  factory TimbreFiscal.fromJson(Map<String, dynamic> json) {
    return TimbreFiscal(
      version: json['Version'] ?? '',
      uuid: json['UUID'] ?? '',
      fechaTimbrado: DateTime.parse(
        json['FechaTimbrado'] ?? DateTime.now().toIso8601String(),
      ),
      rfcProvCertif: json['RfcProvCertif'] ?? '',
      selloCFD: json['SelloCFD'] ?? '',
      selloSAT: json['SelloSAT'] ?? '',
      noCertificadoSAT: json['NoCertificadoSAT'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Version': version,
      'UUID': uuid,
      'FechaTimbrado': fechaTimbrado.toIso8601String(),
      'RfcProvCertif': rfcProvCertif,
      'SelloCFD': selloCFD,
      'SelloSAT': selloSAT,
      'NoCertificadoSAT': noCertificadoSAT,
    };
  }
}
