import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CFDISummaryCard extends StatelessWidget {
  const CFDISummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CFDIBloc, CFDIState>(
      builder: (context, state) {
        if (state is! CFDILoaded) {
          return const SizedBox.shrink();
        }

        // Formato para valores monetarios
        String formatCurrency(double value) {
          return '\$${value.toStringAsFixed(2).replaceAll(RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))'), ',')}';
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.12),
                Theme.of(context).primaryColor.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Si el espacio es muy reducido, mostrar versión compacta
              if (constraints.maxWidth < 800) {
                return _buildCompactLayout(context, state, formatCurrency);
              }
              // Versión completa para pantallas grandes
              return _buildFullLayout(context, state, formatCurrency);
            },
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(0, 32),
      ),
    );
  }

  Widget _buildCompactMetric(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isHighlighted ? 14 : 13,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 32,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.3),
    );
  }

  Widget _buildFullLayout(BuildContext context, CFDILoaded state, String Function(double) formatCurrency) {
    return Row(
      children: [
        // Botones de acción
        Row(
          children: [
            _buildActionButton(
              context,
              icon: Icons.add_to_photos,
              label: 'Añadir archivo',
              onPressed: () {
                context.read<CFDIBloc>().add(LoadCFDIsFromFile());
              },
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context,
              icon: Icons.create_new_folder,
              label: 'Cargar directorio',
              onPressed: () {
                context.read<CFDIBloc>().add(LoadCFDIsFromDirectory());
              },
              color: Colors.green,
            ),
          ],
        ),
        
        const SizedBox(width: 24),
        
        // Métricas en fila horizontal
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCompactMetric(
                context,
                label: 'SubTotal',
                value: formatCurrency(state.cfdiInformation.subtotal),
                icon: Icons.account_balance,
                color: Colors.blue,
              ),
              _buildVerticalDivider(),
              _buildCompactMetric(
                context,
                label: 'Descuento',
                value: formatCurrency(state.cfdiInformation.descuento),
                icon: Icons.discount,
                color: Colors.orange,
              ),
              _buildVerticalDivider(),
              _buildCompactMetric(
                context,
                label: 'Sub. - Desc.',
                value: formatCurrency(
                  state.cfdiInformation.subtotal - state.cfdiInformation.descuento,
                ),
                icon: Icons.calculate,
                color: Colors.green,
              ),
              _buildVerticalDivider(),
              _buildCompactMetric(
                context,
                label: 'IVA (16%)',
                value: formatCurrency(
                  (state.cfdiInformation.subtotal - state.cfdiInformation.descuento) * 0.16,
                ),
                icon: Icons.receipt,
                color: Colors.indigo,
              ),
              _buildVerticalDivider(),
              _buildCompactMetric(
                context,
                label: 'Total',
                value: formatCurrency(state.cfdiInformation.total),
                icon: Icons.price_check,
                color: Colors.teal,
                isHighlighted: true,
              ),
              _buildVerticalDivider(),
              _buildCompactMetric(
                context,
                label: 'Total + IVA',
                value: formatCurrency(
                  (state.cfdiInformation.subtotal - state.cfdiInformation.descuento) * 1.16,
                ),
                icon: Icons.calculate_outlined,
                color: Colors.purple,
                isHighlighted: true,
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 24),
        
        // Contador de CFDIs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.article,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${state.cfdis.length} CFDIs',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context, CFDILoaded state, String Function(double) formatCurrency) {
    return Column(
      children: [
        // Primera fila: Botones de acción y contador
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildCompactActionButton(
                  context,
                  icon: Icons.add_to_photos,
                  onPressed: () {
                    context.read<CFDIBloc>().add(LoadCFDIsFromFile());
                  },
                  color: Colors.blue,
                ),
                const SizedBox(width: 6),
                _buildCompactActionButton(
                  context,
                  icon: Icons.create_new_folder,
                  onPressed: () {
                    context.read<CFDIBloc>().add(LoadCFDIsFromDirectory());
                  },
                  color: Colors.green,
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.article,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${state.cfdis.length} CFDIs',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Segunda fila: Métricas principales
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMiniMetric(
              context,
              label: 'SubTotal',
              value: formatCurrency(state.cfdiInformation.subtotal),
              color: Colors.blue,
            ),
            _buildMiniMetric(
              context,
              label: 'Descuento',
              value: formatCurrency(state.cfdiInformation.descuento),
              color: Colors.orange,
            ),
            _buildMiniMetric(
              context,
              label: 'IVA (16%)',
              value: formatCurrency(
                (state.cfdiInformation.subtotal - state.cfdiInformation.descuento) * 0.16,
              ),
              color: Colors.indigo,
            ),
          ],
        ),
        
        const SizedBox(height: 6),
        
        // Tercera fila: Totales destacados
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMiniMetric(
              context,
              label: 'Total',
              value: formatCurrency(state.cfdiInformation.total),
              color: Colors.teal,
              isHighlighted: true,
            ),
            _buildMiniMetric(
              context,
              label: 'Total + IVA',
              value: formatCurrency(
                (state.cfdiInformation.subtotal - state.cfdiInformation.descuento) * 1.16,
              ),
              color: Colors.purple,
              isHighlighted: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        color: Colors.white,
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        tooltip: icon == Icons.add_to_photos ? 'Añadir archivo' : 'Cargar directorio',
      ),
    );
  }

  Widget _buildMiniMetric(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isHighlighted ? 12 : 11,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
