import 'package:flutter/material.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/widgets/modern/modern_card.dart';
import 'package:comparador_cfdis/widgets/cfdi_export_widget.dart';
import 'package:comparador_cfdis/theme/app_dimensions.dart';
import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CFDIDashboard extends StatelessWidget {
  final List<CFDI> cfdis;

  const CFDIDashboard({
    super.key,
    required this.cfdis,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = AppLayout.isMobile(context);

    // Calcular estadísticas
    final stats = _calculateStats(cfdis);
    final summaryMetrics = _calculateSummaryMetrics(cfdis);

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppLayout.getHorizontalPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.dashboard_outlined,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard de CFDIs',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Resumen de ${cfdis.length} comprobantes fiscales',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Botones de acción integrados
              _buildDashboardActions(context),
            ],
          ),

          const SizedBox(height: 24),

          // Panel de resumen financiero integrado
          _buildFinancialSummaryPanel(context, summaryMetrics, isMobile),

          const SizedBox(height: 24),

          // Grid de estadísticas
          if (isMobile)
            _buildMobileGrid(context, stats)
          else
            _buildDesktopGrid(context, stats),

          const SizedBox(height: 24),

          // Gráficos y análisis adicionales
          _buildAnalysisSection(context, stats),

          const SizedBox(height: 24),

          // Widget de exportación
          CFDIExportWidget(cfdis: cfdis),
        ],
      ),
    );
  }

  Widget _buildMobileGrid(BuildContext context, CFDIStats stats) {
    return Column(
      children: [
        _buildStatCard(
          context,
          title: 'Total General',
          value: _formatCurrency(stats.totalAmount),
          icon: Icons.account_balance_wallet,
          color: Colors.green,
          isMain: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Ingresos',
                value: _formatCurrency(stats.ingresoAmount),
                subtitle: '${stats.ingresoCount} docs',
                icon: Icons.trending_up,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Egresos',
                value: _formatCurrency(stats.egresoAmount),
                subtitle: '${stats.egresoCount} docs',
                icon: Icons.trending_down,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Pagos',
                value: '${stats.pagoCount}',
                subtitle: _formatCurrency(stats.pagoAmount),
                icon: Icons.payment,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Traslados',
                value: '${stats.trasladoCount}',
                subtitle: _formatCurrency(stats.trasladoAmount),
                icon: Icons.local_shipping,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopGrid(BuildContext context, CFDIStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 2.2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          context,
          title: 'Total General',
          value: _formatCurrency(stats.totalAmount),
          icon: Icons.account_balance_wallet,
          color: Colors.green,
          isMain: true,
        ),
        _buildStatCard(
          context,
          title: 'Ingresos',
          value: _formatCurrency(stats.ingresoAmount),
          subtitle: '${stats.ingresoCount} documentos',
          icon: Icons.trending_up,
          color: Colors.blue,
        ),
        _buildStatCard(
          context,
          title: 'Egresos',
          value: _formatCurrency(stats.egresoAmount),
          subtitle: '${stats.egresoCount} documentos',
          icon: Icons.trending_down,
          color: Colors.red,
        ),
        _buildStatCard(
          context,
          title: 'Pagos',
          value: '${stats.pagoCount}',
          subtitle: _formatCurrency(stats.pagoAmount),
          icon: Icons.payment,
          color: Colors.orange,
        ),
        _buildStatCard(
          context,
          title: 'Traslados',
          value: '${stats.trasladoCount}',
          subtitle: _formatCurrency(stats.trasladoAmount),
          icon: Icons.local_shipping,
          color: Colors.purple,
        ),
        _buildStatCard(
          context,
          title: 'Otros',
          value: '${stats.otherCount}',
          subtitle: _formatCurrency(stats.otherAmount),
          icon: Icons.description,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    bool isMain = false,
  }) {
    final theme = Theme.of(context);

    return ModernCard(
      padding: EdgeInsets.all(isMain ? 20 : 16),
      color: isMain ? color.withValues(alpha: 0.1) : theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isMain ? 28 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: isMain
                          ? theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            )
                          : theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(BuildContext context, CFDIStats stats) {
    final theme = Theme.of(context);
    final isMobile = AppLayout.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análisis Detallado',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (isMobile)
          Column(
            children: [
              _buildEmisoresTopCard(context, stats),
              const SizedBox(height: 16),
              _buildReceptoresTopCard(context, stats),
              const SizedBox(height: 16),
              _buildDateRangeCard(context, stats),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildEmisoresTopCard(context, stats),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildReceptoresTopCard(context, stats),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateRangeCard(context, stats),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEmisoresTopCard(BuildContext context, CFDIStats stats) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Top Emisores',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stats.topEmisores
              .take(5)
              .map(
                (emisor) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          emisor.nombre.length > 25
                              ? '${emisor.nombre.substring(0, 25)}...'
                              : emisor.nombre,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '${emisor.count}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildReceptoresTopCard(BuildContext context, CFDIStats stats) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Top Receptores',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stats.topReceptores
              .take(5)
              .map(
                (receptor) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          receptor.nombre.length > 25
                              ? '${receptor.nombre.substring(0, 25)}...'
                              : receptor.nombre,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '${receptor.count}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildDateRangeCard(BuildContext context, CFDIStats stats) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.date_range,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Período',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDateInfoRow(context, 'Fecha más antigua:', stats.fechaInicio),
          _buildDateInfoRow(context, 'Fecha más reciente:', stats.fechaFin),
          const SizedBox(height: 8),
          Text(
            'Rango: ${stats.diasRango} días',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardActions(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          context,
          icon: Icons.add_to_photos,
          label: 'Añadir',
          onPressed: () {
            context.read<CFDIBloc>().add(LoadCFDIsFromFile());
          },
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          context,
          icon: Icons.create_new_folder,
          label: 'Cargar',
          onPressed: () {
            context.read<CFDIBloc>().add(LoadCFDIsFromDirectory());
          },
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    final isMobile = AppLayout.isMobile(context);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isMobile ? 16 : 18),
      label: Text(
        label,
        style: TextStyle(fontSize: isMobile ? 12 : 14),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryPanel(
    BuildContext context,
    SummaryMetrics metrics,
    bool isMobile,
  ) {
    final theme = Theme.of(context);

    return ModernCard(
      padding: const EdgeInsets.all(20),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Resumen Financiero',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isMobile)
            _buildMobileSummaryGrid(context, metrics)
          else
            _buildDesktopSummaryGrid(context, metrics),
        ],
      ),
    );
  }

  Widget _buildMobileSummaryGrid(BuildContext context, SummaryMetrics metrics) {
    return Column(
      children: [
        // Primera fila - métricas principales
        Row(
          children: [
            Expanded(
              child: _buildSummaryMetric(
                context,
                title: 'Subtotal',
                value: _formatCurrency(metrics.subtotal),
                icon: Icons.account_balance,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryMetric(
                context,
                title: 'Descuento',
                value: _formatCurrency(metrics.descuento),
                icon: Icons.discount,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Segunda fila - Sub. - Desc. e IVA
        Row(
          children: [
            Expanded(
              child: _buildSummaryMetric(
                context,
                title: 'Sub. - Desc.',
                value: _formatCurrency(metrics.subtotalMenosDescuento),
                icon: Icons.calculate,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryMetric(
                context,
                title: 'IVA (16%)',
                value: _formatCurrency(metrics.iva),
                icon: Icons.receipt,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Tercera fila - totales destacados
        Row(
          children: [
            Expanded(
              child: _buildSummaryMetric(
                context,
                title: 'Total',
                value: _formatCurrency(metrics.total),
                icon: Icons.price_check,
                color: Colors.teal,
                isHighlighted: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryMetric(
                context,
                title: 'Total + IVA',
                value: _formatCurrency(metrics.totalConIva),
                icon: Icons.calculate_outlined,
                color: Colors.purple,
                isHighlighted: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopSummaryGrid(
    BuildContext context,
    SummaryMetrics metrics,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryMetric(
            context,
            title: 'Subtotal',
            value: _formatCurrency(metrics.subtotal),
            icon: Icons.account_balance,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryMetric(
            context,
            title: 'Descuento',
            value: _formatCurrency(metrics.descuento),
            icon: Icons.discount,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryMetric(
            context,
            title: 'Sub. - Desc.',
            value: _formatCurrency(metrics.subtotalMenosDescuento),
            icon: Icons.calculate,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryMetric(
            context,
            title: 'IVA (16%)',
            value: _formatCurrency(metrics.iva),
            icon: Icons.receipt,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryMetric(
            context,
            title: 'Total',
            value: _formatCurrency(metrics.total),
            icon: Icons.price_check,
            color: Colors.teal,
            isHighlighted: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryMetric(
            context,
            title: 'Total + IVA (16%)',
            value: _formatCurrency(metrics.totalConIva),
            icon: Icons.calculate_outlined,
            color: Colors.purple,
            isHighlighted: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryMetric(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isHighlighted = false,
    bool isMainMetric = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isMainMetric ? 20 : 16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(color: color.withValues(alpha: 0.3), width: 2)
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: isMainMetric ? 28 : 24,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: isMainMetric ? 16 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isHighlighted ? color : theme.colorScheme.onSurface,
              fontSize: isMainMetric ? 24 : (isHighlighted ? 20 : 18),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  SummaryMetrics _calculateSummaryMetrics(List<CFDI> cfdis) {
    if (cfdis.isEmpty) {
      return SummaryMetrics.empty();
    }

    double subtotal = 0;
    double descuento = 0;
    double total = 0;

    for (final cfdi in cfdis) {
      subtotal += double.tryParse(cfdi.subTotal ?? '0') ?? 0;
      descuento += double.tryParse(cfdi.descuento ?? '0') ?? 0;
      total += double.tryParse(cfdi.total ?? '0') ?? 0;
    }

    final subtotalMenosDescuento = subtotal - descuento;
    final iva = subtotalMenosDescuento * 0.16; // IVA del 16%
    final totalConIva = subtotalMenosDescuento * 1.16; // Total con IVA

    return SummaryMetrics(
      subtotal: subtotal,
      descuento: descuento,
      subtotalMenosDescuento: subtotalMenosDescuento,
      iva: iva,
      total: total,
      totalConIva: totalConIva,
    );
  }

  CFDIStats _calculateStats(List<CFDI> cfdis) {
    if (cfdis.isEmpty) {
      return CFDIStats.empty();
    }

    double totalAmount = 0;
    double ingresoAmount = 0;
    double egresoAmount = 0;
    double pagoAmount = 0;
    double trasladoAmount = 0;
    double otherAmount = 0;

    int ingresoCount = 0;
    int egresoCount = 0;
    int pagoCount = 0;
    int trasladoCount = 0;
    int otherCount = 0;

    final Map<String, int> emisorMap = {};
    final Map<String, int> receptorMap = {};

    DateTime? fechaMinima;
    DateTime? fechaMaxima;

    for (final cfdi in cfdis) {
      // Calcular totales por tipo
      final total = double.tryParse(cfdi.total ?? '0') ?? 0;
      totalAmount += total;

      final tipo = cfdi.tipoDeComprobante?.toUpperCase();
      switch (tipo) {
        case 'I':
          ingresoAmount += total;
          ingresoCount++;
          break;
        case 'E':
          egresoAmount += total;
          egresoCount++;
          break;
        case 'P':
          pagoAmount += total;
          pagoCount++;
          break;
        case 'T':
          trasladoAmount += total;
          trasladoCount++;
          break;
        default:
          otherAmount += total;
          otherCount++;
      }

      // Contar emisores y receptores
      final emisorNombre = cfdi.emisor?.nombre ?? 'Sin nombre';
      emisorMap[emisorNombre] = (emisorMap[emisorNombre] ?? 0) + 1;

      final receptorNombre = cfdi.receptor?.nombre ?? 'Sin nombre';
      receptorMap[receptorNombre] = (receptorMap[receptorNombre] ?? 0) + 1;

      // Determinar rango de fechas
      if (cfdi.fecha != null) {
        try {
          final fecha = DateTime.parse(cfdi.fecha!);
          if (fechaMinima == null || fecha.isBefore(fechaMinima)) {
            fechaMinima = fecha;
          }
          if (fechaMaxima == null || fecha.isAfter(fechaMaxima)) {
            fechaMaxima = fecha;
          }
        } catch (_) {}
      }
    }

    // Ordenar emisores y receptores por count
    final topEmisores = emisorMap.entries
        .map((e) => EntityCount(nombre: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final topReceptores = receptorMap.entries
        .map((e) => EntityCount(nombre: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final fechaInicioStr = fechaMinima != null
        ? DateFormat('dd/MM/yyyy').format(fechaMinima)
        : 'N/A';

    final fechaFinStr = fechaMaxima != null
        ? DateFormat('dd/MM/yyyy').format(fechaMaxima)
        : 'N/A';

    final diasRango = fechaMinima != null && fechaMaxima != null
        ? fechaMaxima.difference(fechaMinima).inDays + 1
        : 0;

    return CFDIStats(
      totalAmount: totalAmount,
      ingresoAmount: ingresoAmount,
      egresoAmount: egresoAmount,
      pagoAmount: pagoAmount,
      trasladoAmount: trasladoAmount,
      otherAmount: otherAmount,
      ingresoCount: ingresoCount,
      egresoCount: egresoCount,
      pagoCount: pagoCount,
      trasladoCount: trasladoCount,
      otherCount: otherCount,
      topEmisores: topEmisores,
      topReceptores: topReceptores,
      fechaInicio: fechaInicioStr,
      fechaFin: fechaFinStr,
      diasRango: diasRango,
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}

class CFDIStats {
  final double totalAmount;
  final double ingresoAmount;
  final double egresoAmount;
  final double pagoAmount;
  final double trasladoAmount;
  final double otherAmount;

  final int ingresoCount;
  final int egresoCount;
  final int pagoCount;
  final int trasladoCount;
  final int otherCount;

  final List<EntityCount> topEmisores;
  final List<EntityCount> topReceptores;

  final String fechaInicio;
  final String fechaFin;
  final int diasRango;

  CFDIStats({
    required this.totalAmount,
    required this.ingresoAmount,
    required this.egresoAmount,
    required this.pagoAmount,
    required this.trasladoAmount,
    required this.otherAmount,
    required this.ingresoCount,
    required this.egresoCount,
    required this.pagoCount,
    required this.trasladoCount,
    required this.otherCount,
    required this.topEmisores,
    required this.topReceptores,
    required this.fechaInicio,
    required this.fechaFin,
    required this.diasRango,
  });

  factory CFDIStats.empty() {
    return CFDIStats(
      totalAmount: 0,
      ingresoAmount: 0,
      egresoAmount: 0,
      pagoAmount: 0,
      trasladoAmount: 0,
      otherAmount: 0,
      ingresoCount: 0,
      egresoCount: 0,
      pagoCount: 0,
      trasladoCount: 0,
      otherCount: 0,
      topEmisores: [],
      topReceptores: [],
      fechaInicio: 'N/A',
      fechaFin: 'N/A',
      diasRango: 0,
    );
  }
}

class EntityCount {
  final String nombre;
  final int count;

  EntityCount({required this.nombre, required this.count});
}

class SummaryMetrics {
  final double subtotal;
  final double descuento;
  final double subtotalMenosDescuento;
  final double iva;
  final double total;
  final double totalConIva;

  SummaryMetrics({
    required this.subtotal,
    required this.descuento,
    required this.subtotalMenosDescuento,
    required this.iva,
    required this.total,
    required this.totalConIva,
  });

  factory SummaryMetrics.empty() {
    return SummaryMetrics(
      subtotal: 0,
      descuento: 0,
      subtotalMenosDescuento: 0,
      iva: 0,
      total: 0,
      totalConIva: 0,
    );
  }
}
