import 'package:comparador_cfdis/models/pago.dart';
import 'package:comparador_cfdis/models/totales_pagos.dart';

class ComplementoPago {
  String? version;
  List<Pago>? pagos;
  TotalesPagos? totales;

  ComplementoPago({
    this.version,
    this.pagos,
    this.totales,
  });

  factory ComplementoPago.fromMap(Map<String, dynamic> map) {
    // Extraer los pagos
    final List<Pago> pagosLista = [];
    if (map['Pagos'] != null) {
      if (map['Pagos']['Pago'] is List) {
        for (var pagoDato in map['Pagos']['Pago']) {
          pagosLista.add(Pago.fromMap(pagoDato));
        }
      } else if (map['Pagos']['Pago'] is Map) {
        pagosLista.add(Pago.fromMap(map['Pagos']['Pago']));
      }
    } else if (map['Pago'] != null) {
      if (map['Pago'] is List) {
        for (var pagoDato in map['Pago']) {
          pagosLista.add(Pago.fromMap(pagoDato));
        }
      } else if (map['Pago'] is Map) {
        pagosLista.add(Pago.fromMap(map['Pago']));
      }
    }

    // Extraer los totales (si existe)
    TotalesPagos? totalesPagos;
    if (map['Pagos'] != null && map['Pagos']['Totales'] != null) {
      totalesPagos = TotalesPagos.fromMap(map['Pagos']['Totales']);
    } else if (map['Totales'] != null) {
      totalesPagos = TotalesPagos.fromMap(map['Totales']);
    }

    return ComplementoPago(
      version: map['Version']?.toString(),
      pagos: pagosLista,
      totales: totalesPagos,
    );
  }

  // Add the fromJson method that was missing
  factory ComplementoPago.fromJson(Map<String, dynamic> json) {
    return ComplementoPago.fromMap(json);
  }

  Map<String, dynamic> toMap() {
    return {
      'Version': version,
      'Pagos': {
        if (pagos != null) 'Pago': pagos!.map((e) => e.toMap()).toList(),
        if (totales != null) 'Totales': totales!.toMap(),
      },
    };
  }

  // Also add toJson method for consistency
  Map<String, dynamic> toJson() {
    return toMap();
  }
}
