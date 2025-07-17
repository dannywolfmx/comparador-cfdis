// Widget para mostrar CFDIs en formato de lista (para pantallas pequeñas)
import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/format_tipo_comprobante.dart';
import 'package:comparador_cfdis/screens/cfdi_detail_screen.dart';
import 'package:comparador_cfdis/widgets/cfdi_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CFDIListView extends StatelessWidget {
  final List<CFDI> cfdis;

  const CFDIListView({Key? key, required this.cfdis}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Lista de CFDIs
        Expanded(
          child: ListView.builder(
            itemCount: cfdis.length,
            itemBuilder: (context, index) {
              final cfdi = cfdis[index];
              final emisor = cfdi.emisor;
              final receptor = cfdi.receptor;
              final timbreFiscal = cfdi.timbreFiscalDigital;

              // Formato de fecha
              String? fechaFormateada;
              if (cfdi.fecha != null) {
                try {
                  final fechaObj = DateTime.parse(cfdi.fecha!);
                  fechaFormateada =
                      '${fechaObj.day}/${fechaObj.month}/${fechaObj.year}';
                } catch (_) {
                  fechaFormateada = cfdi.fecha;
                }
              }

              var formatTipoComprobante =
                  FormatTipoComprobante(cfdi.tipoDeComprobante);

              return _content(emisor, receptor, fechaFormateada, cfdi,
                  timbreFiscal, formatTipoComprobante, context);
            },
          ),
        ),

        // Barra de resumen en la parte inferior
        const CFDISummaryCard(),
      ],
    );
  }

  Widget _content(
      Emisor? emisor,
      Receptor? receptor,
      String? fechaFormateada,
      CFDI cfdi,
      TimbreFiscalDigital? timbreFiscal,
      FormatTipoComprobante formatTipoComprobante,
      BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _mostrarDetalles(cfdi, context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: formatTipoComprobante.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    formatTipoComprobante.tipoComprobante.substring(0, 1),
                    style: TextStyle(
                      color: formatTipoComprobante.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emisor?.nombre ?? 'Sin emisor',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (receptor?.nombre != null)
                      Text(
                        'Para: ${receptor!.nombre}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (fechaFormateada != null)
                      Text(
                        'Fecha: $fechaFormateada',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (cfdi.total != null)
                          Text(
                            '\$${cfdi.total}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        )
                      ],
                    ),
                    if (timbreFiscal?.uuid != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'UUID: ${timbreFiscal!.uuid}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalles(CFDI cfdi, BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, secondaryAnimation) {
          // Pass the complete list of CFDIs along with the selected CFDI
          return BlocProvider.value(
            value: BlocProvider.of<CFDIBloc>(context),
            child: CFDIDetailScreen(
              cfdi: cfdi,
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final curvedAnimation =
              CurvedAnimation(parent: animation, curve: Curves.ease);
          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }
}
