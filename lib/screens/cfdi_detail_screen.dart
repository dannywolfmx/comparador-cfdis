import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/models/concepto.dart';
import 'package:comparador_cfdis/models/pago.dart';
import 'package:comparador_cfdis/widgets/accessibility/accessible_widget.dart';
import 'package:comparador_cfdis/services/accessibility_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/cfdi.dart';
import '../services/file_service.dart';
import '../bloc/cfdi_bloc.dart';

class CFDIDetailScreen extends StatefulWidget {
  final CFDI cfdi;

  const CFDIDetailScreen({
    Key? key,
    required this.cfdi,
  }) : super(key: key);

  @override
  State<CFDIDetailScreen> createState() => _CFDIDetailScreenState();
}

class _CFDIDetailScreenState extends State<CFDIDetailScreen>
    with AccessibilityMixin {
  CFDI get cfdi => widget.cfdi;

  @override
  Widget build(BuildContext context) {
    return AccessibilityWrapper(
      screenName:
          'Detalle del CFDI ${cfdi.timbreFiscalDigital?.uuid ?? 'sin UUID'}',
      child: Scaffold(
        appBar: AppBar(
          title: Semantics(
            label: 'Detalle del CFDI',
            hint: 'Pantalla de información completa del documento fiscal',
            child: const Text('Detalle del CFDI'),
          ),
          leading: AccessibleIconButton(
            icon: Icons.arrow_back,
            onPressed: () {
              Navigator.of(context).pop();
              announceMessage('Regresando a la lista de CFDIs');
            },
            tooltip: 'Regresar a la lista',
            semanticLabel: 'Regresar a la lista de CFDIs',
          ),
          actions: [
            // Botón de impresión
            AccessibleIconButton(
              icon: Icons.print,
              onPressed: () => _imprimirCFDI(context),
              tooltip: 'Imprimir CFDI',
              semanticLabel: 'Imprimir documento CFDI',
              semanticHint: 'Abre las opciones de impresión para este CFDI',
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
              _buildTimbreFiscalSection(),

              // Sección de Complemento de Pagos (si existe)
              if (cfdi.isPagoCFDI) ...[
                const Divider(height: 32),
                _buildSectionTitle('Complemento de Pagos'),
                _buildComplementoPagoSection(),
              ],
            ],
          ),
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
  }

  Widget _buildUuidSection(BuildContext context) {
    return Semantics(
      label: 'Sección de identificación del CFDI',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AccessibleText(
                text: 'UUID del CFDI:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                isHeader: true,
                semanticLabel: 'Encabezado: UUID del CFDI',
              ),
              const SizedBox(height: 8),
              AccessibleText(
                text: cfdi.timbreFiscalDigital?.uuid ?? 'No disponible',
                style: const TextStyle(fontSize: 15),
                semanticLabel:
                    'UUID: ${cfdi.timbreFiscalDigital?.uuid ?? 'No disponible'}',
                semanticHint:
                    'Identificador único universal del documento fiscal',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  AccessibleButton(
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
                            announceMessage('UUID copiado al portapapeles');
                            provideFeedback(AccessibilityFeedback.success);
                          }
                        : null,
                    tooltip: 'Copiar UUID al portapapeles',
                    semanticLabel: 'Copiar UUID',
                    semanticHint:
                        'Copia el identificador único del CFDI al portapapeles',
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 8),
                        Text('Copiar UUID'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AccessibleButton(
                    onPressed: cfdi.filePath != null
                        ? () async {
                            final success =
                                await FileService.openFileWithDefaultApp(
                              cfdi.filePath!,
                            );
                            if (!success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No se pudo abrir el archivo'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              announceMessage(
                                'Error: No se pudo abrir el archivo XML',
                              );
                              provideFeedback(AccessibilityFeedback.error);
                            } else {
                              announceMessage('Abriendo archivo XML');
                              provideFeedback(AccessibilityFeedback.success);
                            }
                          }
                        : null,
                    tooltip: 'Abrir archivo XML original',
                    semanticLabel: 'Abrir XML',
                    semanticHint: 'Abre el archivo XML original de este CFDI',
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_new),
                        SizedBox(width: 8),
                        Text('Abrir XML'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                        ClipboardData(text: cfdi.timbreFiscalDigital!.uuid!),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('UUID copiado al portapapeles'),
                        ),
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
                color: tipoColor.withValues(alpha: 0.2),
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
    return Semantics(
      label: 'Sección: $title',
      hint: 'Información detallada de $title',
      header: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
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
          'Régimen Fiscal',
          _getRegimenFiscalNombre(emisor.regimenFiscal),
        ),
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
        _buildDetailItem(
          'Régimen Fiscal',
          _getRegimenFiscalNombre(receptor.regimenFiscalReceptor),
        ),
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
          'Método de Pago',
          _getMetodoPagoNombre(cfdi.metodoPago),
        ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          concepto.descripcion,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Importe: \$${concepto.importe}',
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información principal
                _buildConceptoInfoRow('Cantidad', concepto.cantidad.toString()),
                _buildConceptoInfoRow('Unidad', concepto.unidad),
                _buildConceptoInfoRow(
                  'Valor unitario',
                  '\$${concepto.valorUnitario}',
                ),
                const Divider(),

                // Información detallada
                _buildConceptoInfoRow(
                  'Clave Prod/Serv',
                  concepto.claveProdServ,
                ),
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
              concepto.descripcion,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cantidad: ${concepto.cantidad}'),
                Text('Unidad: ${concepto.unidad}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Valor unitario: \$${concepto.valorUnitario}'),
                Text(
                  'Importe: \$${concepto.importe}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              'Clave Prod/Serv: ${concepto.claveProdServ}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
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
          'Subtotal',
          cfdi.subTotal != null ? '\$${cfdi.subTotal}' : null,
        ),
        _buildDetailItem(
          'Total',
          cfdi.total != null ? '\$${cfdi.total}' : null,
          isHighlighted: true,
        ),
      ],
    );
  }

  Widget _buildTimbreFiscalSection() {
    final tfd = cfdi.timbreFiscalDigital;
    if (tfd == null) {
      return const Text('No hay información del timbre fiscal digital');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem('UUID', tfd.uuid),
        _buildDetailItem(
          'Fecha de Timbrado',
          _formatearFecha(tfd.fechaTimbrado),
        ),
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
          final int index = entry.key;
          final Pago pago = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (complemento.pagos!.length > 1)
                Text(
                  'Pago ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              const SizedBox(height: 8),

              _buildDetailItem(
                'Fecha de Pago',
                _formatearFecha(pago.fechaPago),
              ),
              _buildDetailItem(
                'Forma de Pago',
                _getFormaPagoNombre(pago.formaDePagoP),
              ),
              _buildDetailItem(
                'Monto',
                pago.monto != null ? '\$${pago.monto}' : null,
              ),
              _buildDetailItem('Moneda', pago.monedaP),
              if (pago.tipoCambioP != null && pago.tipoCambioP != '1')
                _buildDetailItem('Tipo de Cambio', pago.tipoCambioP),

              // Mostrar documentos relacionados si existen
              if (pago.documentosRelacionados != null &&
                  pago.documentosRelacionados!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Documentos Relacionados:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),

                // Listar cada documento relacionado
                ...pago.documentosRelacionados!
                    .map(
                      (doc) => Card(
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
                                      builder: (context) => IconButton(
                                        icon: const Icon(
                                          Icons.description_outlined,
                                          size: 20,
                                        ),
                                        tooltip: 'Abrir CFDI relacionado',
                                        onPressed: () => _searchRelatedCFDI(
                                          context,
                                          doc.idDocumento!,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              _buildDetailItem(
                                'Serie/Folio',
                                doc.serie != null || doc.folio != null
                                    ? '${doc.serie ?? ''} ${doc.folio ?? ''}'
                                    : null,
                              ),
                              _buildDetailItem(
                                'Parcialidad',
                                doc.numParcialidad,
                              ),
                              _buildDetailItem(
                                'Saldo Anterior',
                                doc.impSaldoAnt != null
                                    ? '\$${doc.impSaldoAnt}'
                                    : null,
                              ),
                              _buildDetailItem(
                                'Importe Pagado',
                                doc.impPagado != null
                                    ? '\$${doc.impPagado}'
                                    : null,
                              ),
                              _buildDetailItem(
                                'Saldo Insoluto',
                                doc.impSaldoInsoluto != null
                                    ? '\$${doc.impSaldoInsoluto}'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
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

  Widget _buildDetailItem(
    String label,
    String? value, {
    bool isHighlighted = false,
  }) {
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
    // Use the allCfdis list directly without needing the BlocProvider
    final state = context.read<CFDIBloc>().state;

    if (state is! CFDILoaded) return;

    final allCfdis = state.cfdis;

    final relatedCFDI = _findCFDIByUUID(uuid, allCfdis);

    if (relatedCFDI != null && relatedCFDI.timbreFiscalDigital?.uuid != null) {
      // CFDI found, navigate to it, passing the full list again
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, secondaryAnimation) {
            return BlocProvider.value(
              value: BlocProvider.of<CFDIBloc>(context),
              child: CFDIDetailScreen(
                cfdi: relatedCFDI,
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
    } else {
      // CFDI not found, show message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se encontró el CFDI con UUID: $uuid entre los CFDIs cargados',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Método auxiliar para buscar un CFDI por UUID en una lista
  CFDI? _findCFDIByUUID(String uuid, List<CFDI> cfdis) {
    for (var cfdi in cfdis) {
      if (cfdi.timbreFiscalDigital?.uuid == uuid) {
        return cfdi;
      }
    }
    return null;
  }
}
