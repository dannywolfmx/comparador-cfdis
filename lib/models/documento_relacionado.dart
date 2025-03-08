class DocumentoRelacionado {
  String? idDocumento;
  String? serie;
  String? folio;
  String? monedaDR;
  String? equivalenciaDR;
  String? numParcialidad;
  String? impSaldoAnt;
  String? impPagado;
  String? impSaldoInsoluto;
  String? metodoDePagoDR;

  DocumentoRelacionado({
    this.idDocumento,
    this.serie,
    this.folio,
    this.monedaDR,
    this.equivalenciaDR,
    this.numParcialidad,
    this.impSaldoAnt,
    this.impPagado,
    this.impSaldoInsoluto,
    this.metodoDePagoDR,
  });

  factory DocumentoRelacionado.fromMap(Map<String, dynamic> map) {
    return DocumentoRelacionado(
      idDocumento: map['IdDocumento']?.toString(),
      serie: map['Serie']?.toString(),
      folio: map['Folio']?.toString(),
      monedaDR: map['MonedaDR']?.toString(),
      equivalenciaDR: map['EquivalenciaDR']?.toString(),
      numParcialidad: map['NumParcialidad']?.toString(),
      impSaldoAnt: map['ImpSaldoAnt']?.toString(),
      impPagado: map['ImpPagado']?.toString(),
      impSaldoInsoluto: map['ImpSaldoInsoluto']?.toString(),
      metodoDePagoDR: map['MetodoDePagoDR']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idDocumento != null) 'IdDocumento': idDocumento,
      if (serie != null) 'Serie': serie,
      if (folio != null) 'Folio': folio,
      if (monedaDR != null) 'MonedaDR': monedaDR,
      if (equivalenciaDR != null) 'EquivalenciaDR': equivalenciaDR,
      if (numParcialidad != null) 'NumParcialidad': numParcialidad,
      if (impSaldoAnt != null) 'ImpSaldoAnt': impSaldoAnt,
      if (impPagado != null) 'ImpPagado': impPagado,
      if (impSaldoInsoluto != null) 'ImpSaldoInsoluto': impSaldoInsoluto,
      if (metodoDePagoDR != null) 'MetodoDePagoDR': metodoDePagoDR,
    };
  }
}
