class TotalesPagos {
  String? montoTotalPagos;
  String? montoTotalPagosMonedaExtranjera;
  String? tipoCambioP;

  TotalesPagos({
    this.montoTotalPagos,
    this.montoTotalPagosMonedaExtranjera,
    this.tipoCambioP,
  });

  factory TotalesPagos.fromMap(Map<String, dynamic> map) {
    return TotalesPagos(
      montoTotalPagos: map['MontoTotalPagos']?.toString(),
      montoTotalPagosMonedaExtranjera:
          map['MontoTotalPagosMonedaExtranjera']?.toString(),
      tipoCambioP: map['TipoCambioP']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (montoTotalPagos != null) 'MontoTotalPagos': montoTotalPagos,
      if (montoTotalPagosMonedaExtranjera != null)
        'MontoTotalPagosMonedaExtranjera': montoTotalPagosMonedaExtranjera,
      if (tipoCambioP != null) 'TipoCambioP': tipoCambioP,
    };
  }
}
