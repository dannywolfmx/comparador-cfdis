// Nuevo widget adaptativo que elige entre tabla y lista según el tamaño
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/screens/cfdi_list_screen.dart';
import 'package:comparador_cfdis/widgets/cfdi_list.dart';
import 'package:flutter/material.dart';

class AdaptiveCFDIView extends StatelessWidget {
  final List<CFDI> cfdis;

  const AdaptiveCFDIView({Key? key, required this.cfdis}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para obtener las restricciones de tamaño disponible
    return LayoutBuilder(
      builder: (context, constraints) {
        // Si el ancho es menor que un umbral (por ejemplo, 600), mostramos lista
        if (constraints.maxWidth < 600) {
          return CFDIListView(cfdis: cfdis);
        } else {
          // Si hay espacio suficiente, mostramos la tabla
          return CFDITableView(cfdis: cfdis);
        }
      },
    );
  }
}
