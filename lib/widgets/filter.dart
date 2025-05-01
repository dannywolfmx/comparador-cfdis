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
  bool _expandedResumen = true;

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
                      onPressed: () {},
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

          // Contador de CFDIs y Resumen
          _buildExpandableFilter(
            title: 'Resumen de CFDIs',
            icon: Icons.summarize,
            expanded: _expandedResumen,
            onTap: () => setState(() {
              _expandedResumen = !_expandedResumen;
            }),
            child: BlocBuilder<CFDIBloc, CFDIState>(
              builder: (context, state) {
                if (state is! CFDILoaded) {
                  return const SizedBox.shrink();
                }

                // Formato para valores monetarios
                String formatCurrency(double value) {
                  return '\$${value.toStringAsFixed(2).replaceAll(RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))'), ',')}';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Grid para mostrar información más compacta
                    GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 3.0,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      children: [
                        // Subtotal
                        _buildCompactInfoTile(
                          icon: Icons.account_balance,
                          label: 'SubTotal:',
                          value: formatCurrency(state.cfdiInformation.subtotal),
                        ),

                        // Descuento
                        _buildCompactInfoTile(
                          icon: Icons.discount,
                          label: 'Descuento:',
                          value:
                              formatCurrency(state.cfdiInformation.descuento),
                          valueColor: Colors.amber,
                        ),

                        // Subtotal - Descuento
                        _buildCompactInfoTile(
                          icon: Icons.calculate,
                          label: 'SubT. - Desc.:',
                          value: formatCurrency(state.cfdiInformation.subtotal -
                              state.cfdiInformation.descuento),
                          valueColor: Colors.greenAccent,
                        ),

                        // Total con icono
                        _buildCompactInfoTile(
                          icon: Icons.price_check,
                          label: 'Total:',
                          value: formatCurrency(state.cfdiInformation.total),
                          valueColor: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),

                    // SubTotal - Descuento + IVA
                    _buildInfoRow(
                      icon: Icons.price_check,
                      label: 'SubTotal - Desc. + IVA:',
                      value: formatCurrency((state.cfdiInformation.subtotal -
                              state.cfdiInformation.descuento) *
                          1.16),
                      valueColor: Colors.greenAccent,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),

                    // Contador de CFDIs con diseño compacto
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.article,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
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

  // Widget para mostrar información en el formato de mosaico compacto
  Widget _buildCompactInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.white,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: fontWeight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para construir las filas de información
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.white,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Si el espacio es reducido, usamos una disposición vertical
          if (constraints.maxWidth < 240) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                    ),
                  ),
                ),
              ],
            );
          }

          // Disposición horizontal para espacios más amplios
          return Row(
            children: [
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Expanded(
                flex: 3,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
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
