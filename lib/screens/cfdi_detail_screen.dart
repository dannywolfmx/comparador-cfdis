import 'package:comparador_cfdis/models/concepto.dart';
import 'package:comparador_cfdis/models/pago.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cfdi.dart';
import '../services/file_service.dart';
import '../bloc/cfdi_bloc.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CFDIDetailScreen extends StatelessWidget {
  final CFDI cfdi;

  const CFDIDetailScreen({Key? key, required this.cfdi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del CFDI'),
        actions: [
          // Botón de impresión
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Imprimir CFDI',
            onPressed: () => _imprimirCFDI(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de UUID con botones de Copiar y Abrir XML
            _buildUuidSection(context),

            // Sección de UUID y tipo de comprobante
            _buildHeaderSection(context),

            const Divider(height: 32),

            // Sección de Emisor
            _buildSectionTitle('Emisor'),
            _buildEmisorSection(),

            const Divider(height: 32),

            // Sección de Receptor
            _buildSectionTitle('Receptor'),
            _buildReceptorSection(),

            const Divider(height: 32),

            // Sección de detalles generales
            _buildSectionTitle('Detalles Generales'),
            _buildGeneralDetailsSection(),

            const Divider(height: 32),

            // Sección de Conceptos (productos/servicios)
            _buildSectionTitle('Conceptos'),
            _buildConceptosSection(),

            const Divider(height: 32),

            // Sección de Totales
            _buildSectionTitle('Totales'),
            _buildTotalsSection(),

            const Divider(height: 32),

            // Sección de Timbre Fiscal Digital
            _buildSectionTitle('Timbre Fiscal Digital'),
            _buildTFDSection(),

            // Sección de Complemento de Pagos (si existe)
            if (cfdi.isPagoCFDI) ...[
              const Divider(height: 32),
              _buildSectionTitle('Complemento de Pagos'),
              _buildComplementoPagoSection(),
            ],
          ],
        ),
      ),
    );
  }

  // Método para manejar la impresión
  Future<void> _imprimirCFDI(BuildContext context) async {
    // Mostrar un indicador de carga mientras se genera el PDF
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generando documento para imprimir...'),
            ],
          ),
        );
      },
    );

    try {
      // Generar el PDF
      final pdf = await _generarPDF(context);

      // Cerrar el diálogo de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Primero intentamos con el método de impresión estándar
      if (context.mounted) {
        try {
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => pdf,
            name: 'CFDI_${cfdi.timbreFiscalDigital?.uuid ?? "Detalle"}',
          );
        } catch (printingError) {
          // Si falla, intentamos con un método alternativo
          debugPrint('Error en método principal de impresión: $printingError');
          if (context.mounted) {
            // Método alternativo usando sharePdf que es más compatible con algunas plataformas
            await Printing.sharePdf(
                bytes: pdf,
                filename:
                    'CFDI_${cfdi.timbreFiscalDigital?.uuid ?? "Detalle"}.pdf');
          }
        }
      }
    } catch (e) {
      // Cerrar el diálogo de carga en caso de error
      if (context.mounted) {
        Navigator.of(context).pop();

        // Mostrar mensaje de error detallado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al preparar la impresión: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Registrar el error para depuración
      debugPrint('Error de impresión: $e');
    }
  }

  // Método para generar el PDF
  Future<Uint8List> _generarPDF(BuildContext context) async {
    final pdf = pw.Document();

    // Obtener la fuente predeterminada
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();

    // Crear el documento PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPDFHeader(fontBold),
        build: (context) => [
          // Información principal
          _buildPDFEmisorReceptor(font, fontBold),
          pw.SizedBox(height: 20),

          // Detalles generales
          _buildPDFSection('Detalles Generales', font, fontBold),
          _buildPDFGeneralDetails(font),
          pw.SizedBox(height: 20),

          // Conceptos
          _buildPDFSection('Conceptos', font, fontBold),
          _buildPDFConceptos(font, fontBold),
          pw.SizedBox(height: 20),

          // Totales
          _buildPDFSection('Totales', font, fontBold),
          _buildPDFTotals(font, fontBold),
          pw.SizedBox(height: 20),

          // Timbre fiscal
          _buildPDFSection('Timbre Fiscal Digital', font, fontBold),
          _buildPDFTFD(font),

          // Si es un CFDI de pago, incluir el complemento
          if (cfdi.isPagoCFDI) ...[
            pw.SizedBox(height: 20),
            _buildPDFSection('Complemento de Pagos', font, fontBold),
            _buildPDFComplementoPago(font, fontBold),
          ],
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
          child: pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
        ),
      ),
    );

    return pdf.save();
  }

  // Construir el encabezado del PDF
  pw.Widget _buildPDFHeader(pw.Font fontBold) {
    final tipoComprobante = _formatTipoComprobante(cfdi.tipoDeComprobante);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Detalle de CFDI',
              style: pw.TextStyle(font: fontBold, fontSize: 20)),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(tipoComprobante,
                style: pw.TextStyle(font: fontBold, fontSize: 14)),
          ),
        ]),
        pw.Divider(),
        if (cfdi.timbreFiscalDigital?.uuid != null)
          pw.Text('UUID: ${cfdi.timbreFiscalDigital!.uuid!}',
              style: pw.TextStyle(font: fontBold, fontSize: 11)),
        if (cfdi.fecha != null)
          pw.Text('Fecha: ${_formatearFecha(cfdi.fecha!)}',
              style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  // Construir la sección de Emisor/Receptor para PDF
  pw.Widget _buildPDFEmisorReceptor(pw.Font font, pw.Font fontBold) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Columna Emisor
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('EMISOR:', style: pw.TextStyle(font: fontBold)),
              pw.SizedBox(height: 5),
              pw.Text(cfdi.emisor?.nombre ?? "N/A",
                  style: pw.TextStyle(font: font)),
              pw.Text('RFC: ${cfdi.emisor?.rfc ?? "N/A"}',
                  style: pw.TextStyle(font: font)),
              pw.Text(
                  'Régimen: ${_getRegimenFiscalNombre(cfdi.emisor?.regimenFiscal)}',
                  style: pw.TextStyle(font: font, fontSize: 10)),
            ],
          ),
        ),
        // Columna Receptor
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('RECEPTOR:', style: pw.TextStyle(font: fontBold)),
              pw.SizedBox(height: 5),
              pw.Text(cfdi.receptor?.nombre ?? "N/A",
                  style: pw.TextStyle(font: font)),
              pw.Text('RFC: ${cfdi.receptor?.rfc ?? "N/A"}',
                  style: pw.TextStyle(font: font)),
              pw.Text('Uso CFDI: ${_getUsoCFDINombre(cfdi.receptor?.usoCFDI)}',
                  style: pw.TextStyle(font: font, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  // Construir título de sección para PDF
  pw.Widget _buildPDFSection(String title, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey200,
      ),
      child: pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 14)),
    );
  }

  // Construir detalles generales para PDF
  pw.Widget _buildPDFGeneralDetails(pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildPDFDetailRow('Versión', cfdi.version ?? 'N/A', font),
        _buildPDFDetailRow(
            'Forma de Pago', _getFormaPagoNombre(cfdi.formaPago), font),
        _buildPDFDetailRow(
            'Método de Pago', _getMetodoPagoNombre(cfdi.metodoPago), font),
        _buildPDFDetailRow('Moneda', cfdi.moneda ?? 'N/A', font),
        if (cfdi.tipoCambio != null && cfdi.tipoCambio != '1')
          _buildPDFDetailRow('Tipo de Cambio', cfdi.tipoCambio ?? 'N/A', font),
        _buildPDFDetailRow(
            'Lugar de Expedición', cfdi.lugarExpedicion ?? 'N/A', font),
      ],
    );
  }

  // Construir fila de detalle para PDF
  pw.Widget _buildPDFDetailRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text('$label:', style: pw.TextStyle(font: font)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: font)),
          ),
        ],
      ),
    );
  }

  // Construir sección de conceptos para PDF
  pw.Widget _buildPDFConceptos(pw.Font font, pw.Font fontBold) {
    final conceptos = cfdi.conceptos?.concepto;

    if (conceptos == null || conceptos.isEmpty) {
      return pw.Text('No hay conceptos disponibles',
          style: pw.TextStyle(font: font));
    }

    return pw.Column(
      children: [
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(1), // Cantidad
            1: const pw.FlexColumnWidth(5), // Descripción
            2: const pw.FlexColumnWidth(2), // Valor Unit.
            3: const pw.FlexColumnWidth(2), // Importe
          },
          children: [
            // Encabezado
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildPDFTableCell('Cant.', font, isHeader: true),
                _buildPDFTableCell('Descripción', font, isHeader: true),
                _buildPDFTableCell('Valor Unit.', font, isHeader: true),
                _buildPDFTableCell('Importe', font, isHeader: true),
              ],
            ),
            // Filas de conceptos
            ...conceptos
                .map((concepto) => pw.TableRow(
                      children: [
                        _buildPDFTableCell(
                            concepto.cantidad.toString() ?? 'N/A', font),
                        _buildPDFTableCell(
                            concepto.descripcion ?? 'Sin descripción', font),
                        _buildPDFTableCell(
                            '\$${concepto.valorUnitario.toString() ?? 'N/A'}',
                            font),
                        _buildPDFTableCell(
                            '\$${concepto.importe ?? 'N/A'}', font),
                      ],
                    ))
                .toList(),
          ],
        ),
      ],
    );
  }

  // Construir celda de tabla para PDF
  pw.Widget _buildPDFTableCell(String text, pw.Font font,
      {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }

  // Construir sección de totales para PDF
  pw.Widget _buildPDFTotals(pw.Font font, pw.Font fontBold) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          if (cfdi.subTotal != null)
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('Subtotal: ', style: pw.TextStyle(font: font)),
                pw.Text('\$${cfdi.subTotal}', style: pw.TextStyle(font: font)),
              ],
            ),
          pw.SizedBox(height: 5),
          if (cfdi.total != null)
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('Total: ', style: pw.TextStyle(font: fontBold)),
                  pw.Text('\$${cfdi.total}',
                      style: pw.TextStyle(font: fontBold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Construir sección de Timbre Fiscal Digital para PDF
  pw.Widget _buildPDFTFD(pw.Font font) {
    final tfd = cfdi.timbreFiscalDigital;

    if (tfd == null) {
      return pw.Text('No hay información del timbre fiscal digital',
          style: pw.TextStyle(font: font));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildPDFDetailRow('UUID', tfd.uuid ?? 'N/A', font),
        _buildPDFDetailRow('Fecha de Timbrado',
            _formatearFecha(tfd.fechaTimbrado ?? ''), font),
        _buildPDFDetailRow('RFC PAC', tfd.rfcProvCertif ?? 'N/A', font),
        _buildPDFDetailRow(
            'No. Certificado SAT', tfd.noCertificadoSAT ?? 'N/A', font),
      ],
    );
  }

  // Construir sección de complemento de pago para PDF
  pw.Widget _buildPDFComplementoPago(pw.Font font, pw.Font fontBold) {
    final complemento = cfdi.complementoPago;

    if (complemento == null ||
        complemento.pagos == null ||
        complemento.pagos!.isEmpty) {
      return pw.Text('No hay información de pagos',
          style: pw.TextStyle(font: font));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildPDFDetailRow(
            'Versión del Complemento', complemento.version ?? 'N/A', font),

        // Totales del complemento
        if (complemento.totales != null) ...[
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              border: pw.Border.all(color: PdfColors.blue200),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Totales del Complemento',
                    style: pw.TextStyle(font: fontBold)),
                pw.SizedBox(height: 5),
                _buildPDFDetailRow(
                    'Monto Total',
                    complemento.totales!.montoTotalPagos != null
                        ? '\$${complemento.totales!.montoTotalPagos}'
                        : 'N/A',
                    font),
              ],
            ),
          ),
        ],

        // Detalles de cada pago
        pw.SizedBox(height: 10),
        ...complemento.pagos!.asMap().entries.map((entry) {
          int index = entry.key;
          Pago pago = entry.value;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (complemento.pagos!.length > 1)
                pw.Text('Pago ${index + 1}',
                    style: pw.TextStyle(font: fontBold)),
              pw.SizedBox(height: 5),
              _buildPDFDetailRow(
                  'Fecha de Pago', _formatearFecha(pago.fechaPago ?? ''), font),
              _buildPDFDetailRow('Forma de Pago',
                  _getFormaPagoNombre(pago.formaDePagoP), font),
              _buildPDFDetailRow('Monto',
                  pago.monto != null ? '\$${pago.monto}' : 'N/A', font),
              _buildPDFDetailRow('Moneda', pago.monedaP ?? 'N/A', font),
              if (pago.tipoCambioP != null && pago.tipoCambioP != '1')
                _buildPDFDetailRow(
                    'Tipo de Cambio', pago.tipoCambioP ?? 'N/A', font),
              pw.SizedBox(height: 10),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildUuidSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'UUID del CFDI:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              cfdi.timbreFiscalDigital?.uuid ?? 'No disponible',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar UUID'),
                  onPressed: cfdi.timbreFiscalDigital?.uuid != null
                      ? () {
                          Clipboard.setData(
                            ClipboardData(
                              text: cfdi.timbreFiscalDigital!.uuid!,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('UUID copiado al portapapeles'),
                            ),
                          );
                        }
                      : null,
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Abrir XML'),
                  onPressed: cfdi.filePath != null
                      ? () async {
                          final success =
                              await FileService.openFileWithDefaultApp(
                                  cfdi.filePath!);
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No se pudo abrir el archivo'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final tipoComprobante = _formatTipoComprobante(cfdi.tipoDeComprobante);
    final tipoColor = _getColorForTipoComprobante(cfdi.tipoDeComprobante);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila para UUID con botón para copiar
        Row(
          children: [
            Expanded(
              child: Text(
                'UUID: ${cfdi.timbreFiscalDigital?.uuid ?? 'No disponible'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copiar UUID',
              onPressed: cfdi.timbreFiscalDigital?.uuid != null
                  ? () {
                      Clipboard.setData(
                          ClipboardData(text: cfdi.timbreFiscalDigital!.uuid!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('UUID copiado al portapapeles')),
                      );
                    }
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Tipo de comprobante con indicador de color
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: tipoColor.withOpacity(0.2),
                border: Border.all(color: tipoColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tipoComprobante,
                style: TextStyle(
                  color: tipoColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            if (cfdi.serie != null || cfdi.folio != null)
              Text(
                'Serie/Folio: ${cfdi.serie ?? ''} ${cfdi.folio ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Fecha de emisión
        if (cfdi.fecha != null)
          Text(
            'Fecha de Emisión: ${_formatearFecha(cfdi.fecha!)}',
            style: const TextStyle(fontSize: 15),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildEmisorSection() {
    final emisor = cfdi.emisor;
    if (emisor == null) {
      return const Text('No hay información del emisor');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem('Nombre', emisor.nombre),
        _buildDetailItem('RFC', emisor.rfc),
        _buildDetailItem(
            'Régimen Fiscal', _getRegimenFiscalNombre(emisor.regimenFiscal)),
      ],
    );
  }

  Widget _buildReceptorSection() {
    final receptor = cfdi.receptor;
    if (receptor == null) {
      return const Text('No hay información del receptor');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem('Nombre', receptor.nombre),
        _buildDetailItem('RFC', receptor.rfc),
        _buildDetailItem('Domicilio Fiscal', receptor.domicilioFiscalReceptor),
        _buildDetailItem('Régimen Fiscal',
            _getRegimenFiscalNombre(receptor.regimenFiscalReceptor)),
        _buildDetailItem('Uso de CFDI', _getUsoCFDINombre(receptor.usoCFDI)),
      ],
    );
  }

  Widget _buildGeneralDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem('Versión', cfdi.version),
        _buildDetailItem('Forma de Pago', _getFormaPagoNombre(cfdi.formaPago)),
        _buildDetailItem(
            'Método de Pago', _getMetodoPagoNombre(cfdi.metodoPago)),
        _buildDetailItem('Moneda', cfdi.moneda),
        if (cfdi.tipoCambio != null && cfdi.tipoCambio != '1')
          _buildDetailItem('Tipo de Cambio', cfdi.tipoCambio),
        _buildDetailItem('Lugar de Expedición', cfdi.lugarExpedicion),
      ],
    );
  }

  Widget _buildConceptosSection() {
    final conceptos = cfdi.conceptos?.concepto;
    final tipoDoc = cfdi.tipoDeComprobante?.toUpperCase() ?? '';
    final esIngresoOEgreso = tipoDoc == 'I' || tipoDoc == 'E';

    //Imprime en el debug el valor de conceptos

    if (conceptos == null || conceptos.isEmpty) {
      return const Text('No hay conceptos disponibles');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mostrar el número de conceptos
        Text(
          '${conceptos.length} ${conceptos.length == 1 ? 'concepto' : 'conceptos'} en este CFDI',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 10),

        // Lista de conceptos
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: conceptos.length,
          itemBuilder: (context, index) {
            final concepto = conceptos[index];

            return esIngresoOEgreso
                ? _buildDetailedConceptoCard(concepto, index)
                : _buildSimpleConceptoCard(concepto, index);
          },
        ),
      ],
    );
  }

  Widget _buildDetailedConceptoCard(Concepto concepto, int index) {
    // Calcular el total del concepto
    double? total = concepto.cantidad * concepto.valorUnitario;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          concepto.descripcion ?? 'Sin descripción',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Importe: \$${concepto.importe ?? total.toStringAsFixed(2) ?? 'N/A'}',
          style: TextStyle(
              color: Colors.green.shade700, fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información principal
                _buildConceptoInfoRow(
                    'Cantidad', concepto.cantidad.toString() ?? 'N/A'),
                _buildConceptoInfoRow(
                    'Unidad', concepto.unidad ?? concepto.claveUnidad ?? 'N/A'),
                _buildConceptoInfoRow(
                    'Valor unitario', '\$${concepto.valorUnitario ?? 'N/A'}'),
                const Divider(),

                // Información detallada
                _buildConceptoInfoRow(
                    'Clave Prod/Serv', concepto.claveProdServ),
                if (concepto.claveUnidad != concepto.unidad)
                  _buildConceptoInfoRow('Clave Unidad', concepto.claveUnidad),

                // Impuestos y otros detalles (si estuvieran disponibles en el modelo)
                // Esto sería implementado si el modelo CFDI tiene estos campos
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleConceptoCard(Concepto concepto, int index) {
    // Versión simplificada para tipos de CFDI que no son de ingreso o egreso
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              concepto.descripcion ?? 'Sin descripción',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cantidad: ${concepto.cantidad ?? 'N/A'}'),
                Text(
                    'Unidad: ${concepto.unidad ?? concepto.claveUnidad ?? 'N/A'}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Valor unitario: \$${concepto.valorUnitario ?? 'N/A'}'),
                Text('Importe: \$${concepto.importe ?? 'N/A'}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Text('Clave Prod/Serv: ${concepto.claveProdServ}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildConceptoInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem(
            'Subtotal', cfdi.subTotal != null ? '\$${cfdi.subTotal}' : null),
        _buildDetailItem('Total', cfdi.total != null ? '\$${cfdi.total}' : null,
            isHighlighted: true),
      ],
    );
  }

  Widget _buildTFDSection() {
    final tfd = cfdi.timbreFiscalDigital;
    if (tfd == null) {
      return const Text('No hay información del timbre fiscal digital');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem('UUID', tfd.uuid),
        _buildDetailItem(
            'Fecha de Timbrado', _formatearFecha(tfd.fechaTimbrado)),
        _buildDetailItem('RFC PAC', tfd.rfcProvCertif),
        _buildDetailItem('No. Certificado SAT', tfd.noCertificadoSAT),
      ],
    );
  }

  Widget _buildComplementoPagoSection() {
    final complemento = cfdi.complementoPago;
    if (complemento == null ||
        complemento.pagos == null ||
        complemento.pagos!.isEmpty) {
      return const Text('No hay información de pagos');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Versión del Complemento: ${complemento.version ?? 'N/A'}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),

        // Mostrar totales si existen
        if (complemento.totales != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Colors.blue.shade50,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Totales del Complemento',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailItem(
                    'Monto Total',
                    complemento.totales!.montoTotalPagos != null
                        ? '\$${complemento.totales!.montoTotalPagos}'
                        : null,
                    isHighlighted: true,
                  ),
                  if (complemento.totales!.montoTotalPagosMonedaExtranjera !=
                      null)
                    _buildDetailItem(
                      'Monto Total en Moneda Extranjera',
                      '\$${complemento.totales!.montoTotalPagosMonedaExtranjera}',
                    ),
                  if (complemento.totales!.tipoCambioP != null)
                    _buildDetailItem(
                      'Tipo de Cambio',
                      complemento.totales!.tipoCambioP!,
                    ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Mostrar cada pago
        ...complemento.pagos!.asMap().entries.map((entry) {
          int index = entry.key;
          Pago pago = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (complemento.pagos!.length > 1)
                Text('Pago ${index + 1}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),

              _buildDetailItem(
                  'Fecha de Pago', _formatearFecha(pago.fechaPago)),
              _buildDetailItem(
                  'Forma de Pago', _getFormaPagoNombre(pago.formaDePagoP)),
              _buildDetailItem(
                  'Monto', pago.monto != null ? '\$${pago.monto}' : null),
              _buildDetailItem('Moneda', pago.monedaP),
              if (pago.tipoCambioP != null && pago.tipoCambioP != '1')
                _buildDetailItem('Tipo de Cambio', pago.tipoCambioP),

              // Mostrar documentos relacionados si existen
              if (pago.documentosRelacionados != null &&
                  pago.documentosRelacionados!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Documentos Relacionados:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),

                // Listar cada documento relacionado
                ...pago.documentosRelacionados!
                    .map((doc) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Modificar la línea del UUID para incluir el botón de búsqueda
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 140,
                                      child: Text(
                                        'UUID:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        doc.idDocumento ?? 'N/A',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (doc.idDocumento != null)
                                      Builder(
                                        builder: (buttonContext) => IconButton(
                                          icon: const Icon(
                                              Icons.description_outlined,
                                              size: 20),
                                          tooltip: 'Abrir CFDI relacionado',
                                          onPressed: () => _searchRelatedCFDI(
                                              buttonContext, doc.idDocumento!),
                                        ),
                                      ),
                                  ],
                                ),
                                _buildDetailItem(
                                    'Serie/Folio',
                                    doc.serie != null || doc.folio != null
                                        ? '${doc.serie ?? ''} ${doc.folio ?? ''}'
                                        : null),
                                _buildDetailItem(
                                    'Parcialidad', doc.numParcialidad),
                                _buildDetailItem(
                                    'Saldo Anterior',
                                    doc.impSaldoAnt != null
                                        ? '\$${doc.impSaldoAnt}'
                                        : null),
                                _buildDetailItem(
                                    'Importe Pagado',
                                    doc.impPagado != null
                                        ? '\$${doc.impPagado}'
                                        : null),
                                _buildDetailItem(
                                    'Saldo Insoluto',
                                    doc.impSaldoInsoluto != null
                                        ? '\$${doc.impSaldoInsoluto}'
                                        : null),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ],

              if (index < complemento.pagos!.length - 1)
                const Divider(height: 24),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDetailItem(String label, String? value,
      {bool isHighlighted = false}) {
    if (value == null || value.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                fontSize: isHighlighted ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares para formatear datos
  String _formatearFecha(String? fechaStr) {
    if (fechaStr == null) return 'N/A';
    try {
      final fecha = DateTime.parse(fechaStr);
      return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fechaStr;
    }
  }

  String _formatTipoComprobante(String? tipo) {
    if (tipo == null) return 'N/A';
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

  Color _getColorForTipoComprobante(String? tipo) {
    if (tipo == null) return Colors.grey;
    switch (tipo.toUpperCase()) {
      case 'I':
        return Colors.green;
      case 'E':
        return Colors.red;
      case 'T':
        return Colors.blue;
      case 'N':
        return Colors.purple;
      case 'P':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getFormaPagoNombre(String? clave) {
    if (clave == null) return 'N/A';
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
    if (clave == null) return 'N/A';
    switch (clave) {
      case 'PUE':
        return 'Pago en una sola exhibición';
      case 'PPD':
        return 'Pago en parcialidades o diferido';
      default:
        return clave;
    }
  }

  String _getRegimenFiscalNombre(String? clave) {
    if (clave == null) return 'N/A';
    final regimenes = {
      '601': 'General de Ley',
      '603': 'Agricultores, Ganaderos, Silvicultores',
      '605': 'Consolidación',
      '606': 'Simplificado de confianza',
      '608': 'Sin obligaciones fiscales',
      '609': 'Arrendamiento',
      '610': 'Residentes en el Extranjero',
      '611': 'Ingresos por Dividendos',
      '612': 'Personas Físicas con Actividades Empresariales',
      '614': 'Sin obligaciones fiscales',
      '616': 'Sin obligaciones fiscales',
      '621': 'Incorporación Fiscal',
      '622': 'Actividades Agrícolas, Ganaderas, Silvícolas',
      '623': 'Opcional para Grupos de Sociedades',
      '624': 'Coordinados',
      '625': 'Actividades Agrícolas, Ganaderas, Silvícolas',
      '626': 'Simplificado de Confianza',
    };
    return regimenes[clave] ?? clave;
  }

  String _getUsoCFDINombre(String? clave) {
    if (clave == null) return 'N/A';
    final usosCFDI = {
      'G01': 'Adquisición de mercancías',
      'G02': 'Devoluciones, descuentos o bonificaciones',
      'G03': 'Gastos en general',
      'I01': 'Construcciones',
      'I02': 'Mobiliario y equipo de oficina',
      'I03': 'Equipo de transporte',
      'I04': 'Equipo de computo',
      'I05': 'Dados, troqueles, moldes, matrices y herramental',
      'I06': 'Comunicaciones telefónicas',
      'I07': 'Comunicaciones satelitales',
      'I08': 'Otra maquinaria y equipo',
      'D01': 'Honorarios médicos, dentales y gastos hospitalarios',
      'D02': 'Gastos médicos por incapacidad o discapacidad',
      'D03': 'Gastos funerales',
      'D04': 'Donativos',
      'D05': 'Intereses reales de crédito hipotecario',
      'D06': 'Aportaciones voluntarias al SAR',
      'D07': 'Primas por seguros de gastos médicos',
      'D08': 'Gastos de transportación escolar',
      'D09': 'Depósitos en cuentas para el ahorro',
      'D10': 'Pagos por servicios educativos',
      'P01': 'Por definir',
      'S01': 'Sin efectos fiscales',
    };
    return usosCFDI[clave] ?? clave;
  }

  // Método para buscar y navegar al CFDI relacionado por UUID
  void _searchRelatedCFDI(BuildContext context, String uuid) {
    final relatedCFDI = CFDIBloc.findCFDIByUUID(uuid);

    if (relatedCFDI != null && relatedCFDI.timbreFiscalDigital?.uuid != null) {
      // CFDI encontrado, navegar a él
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CFDIDetailScreen(cfdi: relatedCFDI),
        ),
      );
    } else {
      // CFDI no encontrado, mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'No se encontró el CFDI con UUID: $uuid entre los CFDIs cargados'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
