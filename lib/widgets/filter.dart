import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/widgets/filtros/forma_de_pago.dart';
import 'package:comparador_cfdis/widgets/filtros/metodo_de_pago.dart';
import 'package:comparador_cfdis/widgets/filtros/tipo_comprobante.dart';
import 'package:comparador_cfdis/widgets/filtros/uso_de_cfdi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterColumn extends StatefulWidget {
  const FilterColumn({super.key});

  @override
  State<FilterColumn> createState() => _FilterColumnState();
}

class _FilterColumnState extends State<FilterColumn> {
  bool _expandedFormaPago = false;
  bool _expandedMetodoPago = false;
  bool _expandedUsoCFDI = false;
  bool _expandedTipoComprobante = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withBlue(
                  (Theme.of(context).primaryColor.blue * 0.8).round(),
                ),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtros',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                // Botón para limpiar todos los filtros
                BlocBuilder<CFDIBloc, CFDIState>(
                  builder: (context, state) {
                    if (state is! CFDILoaded) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: 'Limpiar filtros',
                      onPressed: () {
                        setState(() {});
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white30, height: 1, thickness: 1),
          // Filtros con BlocBuilder
          BlocBuilder<CFDIBloc, CFDIState>(builder: (context, state) {
            return Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filtro por forma de pago
                      _buildExpandableFilter(
                        title: 'Forma de pago',
                        icon: Icons.payment,
                        expanded: _expandedFormaPago,
                        onTap: () => setState(() {
                          _expandedFormaPago = !_expandedFormaPago;
                        }),
                        child: const FiltroFormaPago(),
                      ),

                      // Filtro por método de pago
                      _buildExpandableFilter(
                        title: 'Método de pago',
                        icon: Icons.account_balance_wallet,
                        expanded: _expandedMetodoPago,
                        onTap: () => setState(() {
                          _expandedMetodoPago = !_expandedMetodoPago;
                        }),
                        child: const FiltroMetodoDePago(),
                      ),

                      // Filtro por uso de CFDI
                      _buildExpandableFilter(
                        title: 'Uso de CFDI',
                        icon: Icons.description,
                        expanded: _expandedUsoCFDI,
                        onTap: () => setState(() {
                          _expandedUsoCFDI = !_expandedUsoCFDI;
                        }),
                        child: const FiltroUsoDeCFDI(),
                      ),

                      // Filtro por tipo de comprobante
                      _buildExpandableFilter(
                        title: 'Tipo de comprobante',
                        icon: Icons.receipt,
                        expanded: _expandedTipoComprobante,
                        onTap: () => setState(() {
                          _expandedTipoComprobante = !_expandedTipoComprobante;
                        }),
                        child: const FiltroTipoComprobante(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Contador de CFDIs
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(8),
            child: BlocBuilder<CFDIBloc, CFDIState>(
              builder: (context, state) {
                if (state is! CFDILoaded) {
                  return const SizedBox.shrink();
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Add the CFDIInformation
                    Text(
                      'SubTotal: ${state.cfdiInformation.subtotal}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Descuento: ${state.cfdiInformation.descuento}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total: ${state.cfdiInformation.total}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.article, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Total: ${state.count} CFDIs',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableFilter({
    required String title,
    required IconData icon,
    required bool expanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(icon, color: Colors.white),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
          ),
          if (expanded)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: child,
              ),
            ),
        ],
      ),
    );
  }
}
