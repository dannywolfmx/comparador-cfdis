import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/widgets/modern/modern_buttons.dart';

class CFDIExportWidget extends StatelessWidget {
  final List<CFDI> cfdis;
  final VoidCallback? onExportComplete;
  
  const CFDIExportWidget({
    super.key,
    required this.cfdis,
    this.onExportComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.file_download_outlined,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Exportar Datos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Exportar ${cfdis.length} CFDIs filtrados',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Opciones de exportación
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ModernButton(
                  text: 'Excel',
                  icon: Icons.table_chart_outlined,
                  style: ModernButtonStyle.outlined,
                  onPressed: () => _exportToExcel(context),
                ),
                ModernButton(
                  text: 'CSV',
                  icon: Icons.text_fields_outlined,
                  style: ModernButtonStyle.outlined,
                  onPressed: () => _exportToCSV(context),
                ),
                ModernButton(
                  text: 'JSON',
                  icon: Icons.code_outlined,
                  style: ModernButtonStyle.outlined,
                  onPressed: () => _exportToJSON(context),
                ),
                ModernButton(
                  text: 'PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  style: ModernButtonStyle.filled,
                  onPressed: () => _exportToPDF(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToCSV(BuildContext context) async {
    try {
      final csv = _generateCSV(cfdis);
      await _saveFile(context, csv, 'cfdis_export.csv', 'CSV');
    } catch (e) {
      _showErrorDialog(context, 'Error al exportar CSV: $e');
    }
  }

  Future<void> _exportToJSON(BuildContext context) async {
    try {
      final jsonData = _generateJSON(cfdis);
      await _saveFile(context, jsonData, 'cfdis_export.json', 'JSON');
    } catch (e) {
      _showErrorDialog(context, 'Error al exportar JSON: $e');
    }
  }

  Future<void> _exportToExcel(BuildContext context) async {
    try {
      // Por simplicidad, usaremos CSV como base para Excel
      final csv = _generateCSV(cfdis);
      await _saveFile(context, csv, 'cfdis_export.xlsx', 'Excel');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nota: El archivo se exportó como CSV compatible con Excel'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      _showErrorDialog(context, 'Error al exportar Excel: $e');
    }
  }

  Future<void> _exportToPDF(BuildContext context) async {
    try {
      // Simulamos la exportación PDF
      await Future.delayed(const Duration(seconds: 2));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidad PDF en desarrollo - próxima versión'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      _showErrorDialog(context, 'Error al exportar PDF: $e');
    }
  }

  String _generateCSV(List<CFDI> cfdis) {
    final buffer = StringBuffer();
    
    // Headers
    buffer.writeln(
      'UUID,RFC_Emisor,Nombre_Emisor,RFC_Receptor,Nombre_Receptor,Fecha,Serie,Folio,Tipo_Comprobante,Forma_Pago,Metodo_Pago,Moneda,Subtotal,Descuento,Total,Lugar_Expedicion'
    );
    
    // Data
    for (final cfdi in cfdis) {
      final row = [
        _escapeCsv(cfdi.timbreFiscalDigital?.uuid ?? ''),
        _escapeCsv(cfdi.emisor?.rfc ?? ''),
        _escapeCsv(cfdi.emisor?.nombre ?? ''),
        _escapeCsv(cfdi.receptor?.rfc ?? ''),
        _escapeCsv(cfdi.receptor?.nombre ?? ''),
        _escapeCsv(_formatDate(cfdi.fecha)),
        _escapeCsv(cfdi.serie ?? ''),
        _escapeCsv(cfdi.folio ?? ''),
        _escapeCsv(_formatTipoComprobante(cfdi.tipoDeComprobante)),
        _escapeCsv(_getFormaPagoNombre(cfdi.formaPago)),
        _escapeCsv(_getMetodoPagoNombre(cfdi.metodoPago)),
        _escapeCsv(cfdi.moneda ?? ''),
        _escapeCsv(cfdi.subTotal ?? ''),
        _escapeCsv(cfdi.descuento ?? ''),
        _escapeCsv(cfdi.total ?? ''),
        _escapeCsv(cfdi.lugarExpedicion ?? ''),
      ];
      
      buffer.writeln(row.join(','));
    }
    
    return buffer.toString();
  }

  String _generateJSON(List<CFDI> cfdis) {
    final data = cfdis.map((cfdi) => {
      'uuid': cfdi.timbreFiscalDigital?.uuid,
      'emisor': {
        'rfc': cfdi.emisor?.rfc,
        'nombre': cfdi.emisor?.nombre,
        'regimenFiscal': cfdi.emisor?.regimenFiscal,
      },
      'receptor': {
        'rfc': cfdi.receptor?.rfc,
        'nombre': cfdi.receptor?.nombre,
        'domicilioFiscal': cfdi.receptor?.domicilioFiscalReceptor,
        'regimenFiscal': cfdi.receptor?.regimenFiscalReceptor,
        'usoCFDI': cfdi.receptor?.usoCFDI,
      },
      'comprobante': {
        'fecha': cfdi.fecha,
        'serie': cfdi.serie,
        'folio': cfdi.folio,
        'tipoComprobante': cfdi.tipoDeComprobante,
        'formaPago': cfdi.formaPago,
        'metodoPago': cfdi.metodoPago,
        'moneda': cfdi.moneda,
        'tipoCambio': cfdi.tipoCambio,
        'lugarExpedicion': cfdi.lugarExpedicion,
      },
      'totales': {
        'subtotal': cfdi.subTotal,
        'descuento': cfdi.descuento,
        'total': cfdi.total,
      },
      'timbrado': {
        'uuid': cfdi.timbreFiscalDigital?.uuid,
        'fechaTimbrado': cfdi.timbreFiscalDigital?.fechaTimbrado,
        'rfcProvCertif': cfdi.timbreFiscalDigital?.rfcProvCertif,
        'noCertificadoSAT': cfdi.timbreFiscalDigital?.noCertificadoSAT,
      },
    }).toList();
    
    return const JsonEncoder.withIndent('  ').convert({
      'metadata': {
        'exportDate': DateTime.now().toIso8601String(),
        'totalCFDIs': cfdis.length,
        'version': '1.0',
      },
      'cfdis': data,
    });
  }

  Future<void> _saveFile(
    BuildContext context,
    String content,
    String fileName,
    String format,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/${timestamp}_$fileName');
      
      await file.writeAsString(content, encoding: utf8);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$format exportado exitosamente'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Abrir carpeta',
              onPressed: () => _openFileLocation(file.path),
            ),
          ),
        );
        
        onExportComplete?.call();
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Error al guardar archivo: $e');
      }
    }
  }

  Future<void> _openFileLocation(String filePath) async {
    try {
      // En Windows, abrir la carpeta contenedora
      if (Platform.isWindows) {
        await Process.run('explorer', ['/select,', filePath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['-R', filePath]);
      } else if (Platform.isLinux) {
        final directory = File(filePath).parent.path;
        await Process.run('xdg-open', [directory]);
      }
    } catch (e) {
      print('Error al abrir ubicación del archivo: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error de Exportación'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('\n') || value.contains('"')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _formatDate(String? fecha) {
    if (fecha == null) return '';
    try {
      final dateTime = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return fecha;
    }
  }

  String _formatTipoComprobante(String? tipo) {
    if (tipo == null) return '';
    switch (tipo.toUpperCase()) {
      case 'I':
        return 'Ingreso';
      case 'E':
        return 'Egreso';
      case 'T':
        return 'Traslado';
      case 'N':
        return 'Nómina';
      case 'P':
        return 'Pago';
      default:
        return tipo;
    }
  }

  String _getFormaPagoNombre(String? clave) {
    if (clave == null) return '';
    final formaPagos = {
      '01': 'Efectivo',
      '02': 'Cheque nominativo',
      '03': 'Transferencia electrónica',
      '04': 'Tarjeta de crédito',
      '05': 'Monedero electrónico',
      '06': 'Dinero electrónico',
      '08': 'Vales de despensa',
      '12': 'Dación en pago',
      '13': 'Pago por subrogación',
      '14': 'Pago por consignación',
      '15': 'Condonación',
      '17': 'Compensación',
      '23': 'Novación',
      '24': 'Confusión',
      '25': 'Remisión de deuda',
      '26': 'Prescripción o caducidad',
      '27': 'A satisfacción del acreedor',
      '28': 'Tarjeta de débito',
      '29': 'Tarjeta de servicios',
      '30': 'Aplicación de anticipos',
      '31': 'Intermediario pagos',
      '99': 'Por definir',
    };
    return formaPagos[clave] ?? clave;
  }

  String _getMetodoPagoNombre(String? clave) {
    if (clave == null) return '';
    switch (clave) {
      case 'PUE':
        return 'Pago en una sola exhibición';
      case 'PPD':
        return 'Pago en parcialidades o diferido';
      default:
        return clave;
    }
  }
}
