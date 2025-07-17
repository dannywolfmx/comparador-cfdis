import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:comparador_cfdis/widgets/filtros/forma_de_pago.dart';
import 'package:comparador_cfdis/widgets/filtros/metodo_de_pago.dart';
import 'package:comparador_cfdis/widgets/filtros/tipo_comprobante.dart';
import 'package:comparador_cfdis/widgets/filtros/uso_de_cfdi.dart';
import 'package:comparador_cfdis/widgets/filter_template_panel.dart';
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF333333),
            Color(0xFF222222),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtros',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                BlocBuilder<CFDIBloc, CFDIState>(
                  builder: (context, state) {
                    if (state is! CFDILoaded) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: const Icon(Icons.refresh,
                          color: Colors.white, size: 20),
                      tooltip: 'Limpiar filtros',
                      onPressed: () {
                        context.read<CFDIBloc>().add(ClearFilters());
                      },
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
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
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Panel de plantillas de filtros
                      const FilterTemplatePanel(),

                      const SizedBox(height: 8),

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

                      // Contador de CFDIs al final
                      const SizedBox(height: 16),
                      BlocBuilder<CFDIBloc, CFDIState>(
                        builder: (context, state) {
                          if (state is! CFDILoaded) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.article,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${state.count} CFDIs',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
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
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            minLeadingWidth: 16,
            leading: Icon(icon, color: Colors.white, size: 18),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
              size: 18,
            ),
          ),
          if (expanded)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: child,
              ),
            ),
        ],
      ),
    );
  }
}
