import 'package:flutter/material.dart';

Map<String, Color> colorMap = {
  'I': Colors.green,
  'E': Colors.red,
  'T': Colors.blue,
  'N': Colors.purple,
  'P': Colors.orange,
};

Map<String, String> tipoMap = {
  'I': 'Ingreso',
  'E': 'Egreso',
  'T': 'Traslado',
  'N': 'Nómina',
  'P': 'Pago',
};

class FormatTipoComprobante {
  final String tipoComprobante;
  final Color color;

  FormatTipoComprobante(String? tipo)
      : tipoComprobante = tipo != null
            ? (tipoMap[tipo.toUpperCase()] ?? tipo)
            : 'Desconocido',
        color = tipo != null
            ? (colorMap[tipo.toUpperCase()] ?? Colors.grey)
            : Colors.grey;
}
