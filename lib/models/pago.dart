import 'package:comparador_cfdis/models/documento_relacionado.dart';

class Pago {
  String? fechaPago;
  String? formaDePagoP;
  String? monedaP;
  String? tipoCambioP;
  String? monto;
  String? numeroCuentaOrd;
  String? rfcEmisorCtaOrd;
  String? nombreBancoOrdExt;
  String? numeroCuentaBen;
  String? rfcEmisorCtaBen;
  String? bancoOrdExt;
  List<DocumentoRelacionado>? documentosRelacionados;

  Pago({
    this.fechaPago,
    this.formaDePagoP,
    this.monedaP,
    this.tipoCambioP,
    this.monto,
    this.numeroCuentaOrd,
    this.rfcEmisorCtaOrd,
    this.nombreBancoOrdExt,
    this.numeroCuentaBen,
    this.rfcEmisorCtaBen,
    this.bancoOrdExt,
    this.documentosRelacionados,
  });

  factory Pago.fromMap(Map<String, dynamic> map) {
    // Manejar los documentos relacionados
    final List<DocumentoRelacionado> docsRelacionados = [];
    if (map['DoctoRelacionado'] != null) {
      if (map['DoctoRelacionado'] is List) {
        for (var docData in map['DoctoRelacionado']) {
          docsRelacionados.add(DocumentoRelacionado.fromMap(docData));
        }
      } else if (map['DoctoRelacionado'] is Map) {
        docsRelacionados
            .add(DocumentoRelacionado.fromMap(map['DoctoRelacionado']));
      }
    }

    return Pago(
      fechaPago: map['FechaPago']?.toString(),
      formaDePagoP: map['FormaDePagoP']?.toString(),
      monedaP: map['MonedaP']?.toString(),
      tipoCambioP: map['TipoCambioP']?.toString(),
      monto: map['Monto']?.toString(),
      numeroCuentaOrd:
          map['NumOperacion']?.toString() ?? map['NumeroCuentaOrd']?.toString(),
      rfcEmisorCtaOrd: map['RfcEmisorCtaOrd']?.toString(),
      nombreBancoOrdExt: map['NomBancoOrdExt']?.toString(),
      numeroCuentaBen: map['CtaBeneficiario']?.toString() ??
          map['NumeroCuentaBen']?.toString(),
      rfcEmisorCtaBen: map['RfcEmisorCtaBen']?.toString(),
      bancoOrdExt: map['BancoOrdExt']?.toString(),
      documentosRelacionados:
          docsRelacionados.isNotEmpty ? docsRelacionados : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (fechaPago != null) 'FechaPago': fechaPago,
      if (formaDePagoP != null) 'FormaDePagoP': formaDePagoP,
      if (monedaP != null) 'MonedaP': monedaP,
      if (tipoCambioP != null) 'TipoCambioP': tipoCambioP,
      if (monto != null) 'Monto': monto,
      if (numeroCuentaOrd != null) 'NumeroCuentaOrd': numeroCuentaOrd,
      if (rfcEmisorCtaOrd != null) 'RfcEmisorCtaOrd': rfcEmisorCtaOrd,
      if (nombreBancoOrdExt != null) 'NomBancoOrdExt': nombreBancoOrdExt,
      if (numeroCuentaBen != null) 'NumeroCuentaBen': numeroCuentaBen,
      if (rfcEmisorCtaBen != null) 'RfcEmisorCtaBen': rfcEmisorCtaBen,
      if (bancoOrdExt != null) 'BancoOrdExt': bancoOrdExt,
      if (documentosRelacionados != null && documentosRelacionados!.isNotEmpty)
        'DoctoRelacionado':
            documentosRelacionados!.map((e) => e.toMap()).toList(),
    };
  }
}
