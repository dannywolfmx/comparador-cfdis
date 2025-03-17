import 'concepto.dart';
import 'package:comparador_cfdis/models/complemento_pago.dart';

class CFDI {
  String? version;
  String? serie;
  String? folio;
  String? fecha;
  String? sello;
  String? formaPago;
  String? noCertificado;
  String? certificado;
  String? condicionesDePago;
  String? descuento;
  String? subTotal;
  String? moneda;
  String? tipoCambio;
  String? total;
  String? tipoDeComprobante;
  String? metodoPago;
  String? lugarExpedicion;
  Emisor? emisor;
  Receptor? receptor;
  Conceptos? conceptos;
  TimbreFiscalDigital? timbreFiscalDigital;
  ComplementoPago? complementoPago;
  String? filePath;

  CFDI({
    this.version,
    this.serie,
    this.folio,
    this.fecha,
    this.sello,
    this.formaPago,
    this.noCertificado,
    this.certificado,
    this.condicionesDePago,
    this.descuento,
    this.subTotal,
    this.moneda,
    this.tipoCambio,
    this.total,
    this.tipoDeComprobante,
    this.metodoPago,
    this.lugarExpedicion,
    this.emisor,
    this.receptor,
    this.conceptos,
    this.timbreFiscalDigital,
    this.complementoPago,
    this.filePath,
  });

  factory CFDI.fromJson(Map<String, dynamic> json, {String? filePath}) {
    // Process the payment complement if present
    ComplementoPago? complementoPagoObj;

    // Look for Complemento/Pagos in different possible structures
    if (json['Complemento'] != null) {
      var complemento = json['Complemento'];
      if (complemento is Map) {
        if (complemento['Pagos'] != null) {
          complementoPagoObj = ComplementoPago.fromJson(complemento['Pagos']);
        } else if (complemento['pago20:Pagos'] != null) {
          complementoPagoObj =
              ComplementoPago.fromJson(complemento['pago20:Pagos']);
        } else if (complemento['pago10:Pagos'] != null) {
          complementoPagoObj =
              ComplementoPago.fromJson(complemento['pago10:Pagos']);
        }
      }
    }

    return CFDI(
      version: json['Version'],
      serie: json['Serie'],
      folio: json['Folio'],
      fecha: json['Fecha'],
      sello: json['Sello'],
      formaPago: json['FormaPago'],
      noCertificado: json['NoCertificado'],
      certificado: json['Certificado'],
      condicionesDePago: json['CondicionesDePago'],
      descuento: json['Descuento'],
      subTotal: json['SubTotal'],
      moneda: json['Moneda'],
      tipoCambio: json['TipoCambio'],
      total: json['Total'],
      tipoDeComprobante: json['TipoDeComprobante'],
      metodoPago: json['MetodoPago'],
      lugarExpedicion: json['LugarExpedicion'],
      emisor: json['Emisor'] != null ? Emisor.fromJson(json['Emisor']) : null,
      receptor:
          json['Receptor'] != null ? Receptor.fromJson(json['Receptor']) : null,
      conceptos: json['Conceptos'] != null
          ? Conceptos.fromJson(json['Conceptos'])
          : null,
      timbreFiscalDigital: json['TimbreFiscalDigital'] != null
          ? TimbreFiscalDigital.fromJson(json['TimbreFiscalDigital'])
          : null,
      complementoPago: complementoPagoObj,
      filePath: filePath,
    );
  }

  // Getter to determine if this is a payment CFDI
  bool get isPagoCFDI {
    return tipoDeComprobante?.toUpperCase() == 'P' || complementoPago != null;
  }
}

class Emisor {
  String? rfc;
  String? nombre;
  String? regimenFiscal;

  Emisor({this.rfc, this.nombre, this.regimenFiscal});

  factory Emisor.fromJson(Map<String, dynamic> json) {
    return Emisor(
      rfc: json['Rfc'],
      nombre: json['Nombre'],
      regimenFiscal: json['RegimenFiscal'],
    );
  }
}

class Receptor {
  String? rfc;
  String? nombre;
  String? domicilioFiscalReceptor;
  String? regimenFiscalReceptor;
  String? usoCFDI;

  Receptor({
    this.rfc,
    this.nombre,
    this.domicilioFiscalReceptor,
    this.regimenFiscalReceptor,
    this.usoCFDI,
  });

  factory Receptor.fromJson(Map<String, dynamic> json) {
    return Receptor(
      rfc: json['Rfc'],
      nombre: json['Nombre'],
      domicilioFiscalReceptor: json['DomicilioFiscalReceptor'],
      regimenFiscalReceptor: json['RegimenFiscalReceptor'],
      usoCFDI: json['UsoCFDI'],
    );
  }
}

class Conceptos {
  List<Concepto>? concepto;

  Conceptos({this.concepto});

  factory Conceptos.fromJson(Map<String, dynamic> json) {
    List<Concepto> conceptos = [];
    if (json['Concepto'] is List) {
      for (var item in json['Concepto']) {
        conceptos.add(Concepto.fromJson(item));
      }
    } else {
      conceptos.add(Concepto.fromJson(json['Concepto']));
    }
    return Conceptos(concepto: conceptos);
  }
}

class TimbreFiscalDigital {
  String? version;
  String? uuid;
  String? fechaTimbrado;
  String? rfcProvCertif;
  String? selloCFD;
  String? noCertificadoSAT;
  String? selloSAT;

  TimbreFiscalDigital({
    this.version,
    this.uuid,
    this.fechaTimbrado,
    this.rfcProvCertif,
    this.selloCFD,
    this.noCertificadoSAT,
    this.selloSAT,
  });

  factory TimbreFiscalDigital.fromJson(Map<String, dynamic> json) {
    return TimbreFiscalDigital(
      version: json['Version'],
      uuid: json['UUID'],
      fechaTimbrado: json['FechaTimbrado'],
      rfcProvCertif: json['RfcProvCertif'],
      selloCFD: json['SelloCFD'],
      noCertificadoSAT: json['NoCertificadoSAT'],
      selloSAT: json['SelloSAT'],
    );
  }
}
