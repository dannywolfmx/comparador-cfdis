import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/impuesto.dart';
import 'package:comparador_cfdis/models/emisor.dart';
import 'package:comparador_cfdis/models/conceptos.dart';
import 'package:comparador_cfdis/models/concepto.dart';
import 'package:comparador_cfdis/models/traslado_concepto.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';

void main() {
  group('DIOT CFDI IVA Direct Value Tests', () {
    test('Should use TotalImpuestosTrasladados from CFDI, not calculate it',
        () {
      print('=== TEST: Usar TotalImpuestosTrasladados del CFDI ===');

      // Crear CFDI con productos mixtos (algunos 0%, algunos 16%)
      // Subtotal: $2359.53, TotalImpuestosTrasladados: $219.31 (del CFDI real)
      final cfdi = CFDI(
        subTotal: '2359.53',
        descuento: '717.68',
        total: '1861.16',
        emisor: const Emisor(
          rfc: 'ABC123456789',
          nombre: 'Proveedor Test',
        ),
        impuestos: Impuesto(
          totalImpuestosRetenidos: 0.0,
          totalImpuestosTrasladados: 219.31, // ❗ VALOR REAL DEL SAT
          retenciones: [],
          traslados: [],
        ),
        conceptos: Conceptos(
          concepto: [
            // Producto 1: Con IVA 16%
            Concepto(
              cantidad: 1,
              claveProdServ: '50202306',
              descripcion: 'Producto con IVA',
              valorUnitario: 1000.0,
              importe: 1000.0,
              traslados: [
                TrasladoConcepto(
                  base: 1000.0,
                  impuesto: '002', // IVA
                  tipoFactor: 'Tasa',
                  tasaOCuota: 0.16,
                  importe: 160.0, // 16% de 1000
                ),
              ],
            ),
            // Producto 2: Con IVA 0% (exento)
            Concepto(
              cantidad: 1,
              claveProdServ: '50202306',
              descripcion: 'Producto exento',
              valorUnitario: 1359.53,
              importe: 1359.53,
              traslados: [
                TrasladoConcepto(
                  base: 1359.53,
                  impuesto: '002', // IVA
                  tipoFactor: 'Tasa',
                  tasaOCuota: 0.0, // 0%
                  importe: 0.0,
                ),
              ],
            ),
          ],
        ),
      );

      // Configuración DIOT
      final configuration = DIOTConfiguration(
        year: 2025,
        userPreferences: UserPreferences(
          rfcToTipoTercero: {},
          rfcToTipoOperacion: {},
          rfcToClasificacionRegional: {},
          rfcToClasificacionIVA: {},
          rfcToEfectosFiscales: {},
          rfcToExtranjeroInfo: {},
        ),
      );

      // Mapear CFDI a registro DIOT
      final records =
          DIOTMappingService.mapCFDIsToRecords([cfdi], configuration);
      expect(records.length, 1);

      final record = records.first;

      print('Datos del CFDI:');
      print('  Subtotal: \$${cfdi.subTotal}');
      print(
          '  TotalImpuestosTrasladados: \$${cfdi.impuestos!.totalImpuestosTrasladados}');
      print('  Descuento: \$${cfdi.descuento}');

      print('');
      print('Valores mapeados en DIOT:');
      print('  valorActos16Porciento: \$${record.valorActos16Porciento}');
      print(
          '  ivaAcreditableExclusivo16: \$${record.ivaAcreditableExclusivo16}');
      print('  devoluciones16Porciento: \$${record.devoluciones16Porciento}');

      // Verificar que usa el TotalImpuestosTrasladados del CFDI
      expect(
        record.ivaAcreditableExclusivo16,
        219.31,
        reason:
            'Debe usar TotalImpuestosTrasladados del CFDI (219.31), no calcular',
      );

      // Verificar otros valores
      expect(
        record.valorActos16Porciento,
        2359.53,
        reason: 'Valor de actos debe ser el subtotal',
      );
      expect(
        record.devoluciones16Porciento,
        717.68,
        reason: 'Devoluciones debe ser el descuento',
      );

      print('');
      print('✅ CORRECTO: Sistema usa TotalImpuestosTrasladados del CFDI');
      print('   - No calcula IVA manualmente');
      print('   - Respeta valores ya validados por SAT');
      print('   - Maneja correctamente productos con tasas mixtas');
    });

    test(
        'Should fall back to calculation only when TotalImpuestosTrasladados is not available',
        () {
      print(
          '=== TEST: Fallback a cálculo cuando TotalImpuestosTrasladados no disponible ===');

      // CFDI sin TotalImpuestosTrasladados (campo en 0 o ausente)
      final cfdi = CFDI(
        subTotal: '1000.00',
        total: '1160.00',
        emisor: const Emisor(
          rfc: 'ABC123456789',
          nombre: 'Proveedor Test',
        ),
        impuestos: Impuesto(
          totalImpuestosRetenidos: 0.0,
          totalImpuestosTrasladados: 0.0, // ❗ NO HAY TOTAL DISPONIBLE
          retenciones: [],
          traslados: [],
        ),
        conceptos: Conceptos(
          concepto: [
            Concepto(
              cantidad: 1,
              claveProdServ: '50202306',
              descripcion: 'Producto con IVA',
              valorUnitario: 1000.0,
              importe: 1000.0,
              traslados: [
                TrasladoConcepto(
                  base: 1000.0,
                  impuesto: '002', // IVA
                  tipoFactor: 'Tasa',
                  tasaOCuota: 0.16,
                  importe: 160.0, // 16% de 1000
                ),
              ],
            ),
          ],
        ),
      );

      final configuration = DIOTConfiguration(
        year: 2025,
        userPreferences: UserPreferences(
          rfcToTipoTercero: {},
          rfcToTipoOperacion: {},
          rfcToClasificacionRegional: {},
          rfcToClasificacionIVA: {},
          rfcToEfectosFiscales: {},
          rfcToExtranjeroInfo: {},
        ),
      );

      final records =
          DIOTMappingService.mapCFDIsToRecords([cfdi], configuration);
      final record = records.first;

      print(
          'TotalImpuestosTrasladados: \$${cfdi.impuestos!.totalImpuestosTrasladados}');
      print(
          'IVA calculado desde conceptos: \$${record.ivaAcreditableExclusivo16}');

      // En este caso debe usar el fallback (calculado desde conceptos)
      expect(
        record.ivaAcreditableExclusivo16,
        160.0,
        reason:
            'Debe calcular desde conceptos cuando TotalImpuestosTrasladados no está disponible',
      );

      print('✅ CORRECTO: Fallback a cálculo funciona correctamente');
    });

    test('Should demonstrate the original problem scenario', () {
      print('=== TEST: Demostrar escenario del problema original ===');

      // Escenario exacto del usuario: subtotal 2359.53, IVA real 219.31
      final cfdi = CFDI(
        subTotal: '2359.53',
        descuento: '717.68',
        total: '1861.16',
        emisor: const Emisor(
          rfc: 'ABC123456789',
          nombre: 'Proveedor Original',
        ),
        impuestos: Impuesto(
          totalImpuestosRetenidos: 0.0,
          totalImpuestosTrasladados: 219.31, // 🎯 VALOR REAL DEL PROBLEMA
          retenciones: [],
          traslados: [],
        ),
        conceptos: Conceptos(concepto: []),
      );

      final configuration = DIOTConfiguration(
        year: 2025,
        userPreferences: UserPreferences(
          rfcToTipoTercero: {},
          rfcToTipoOperacion: {},
          rfcToClasificacionRegional: {},
          rfcToClasificacionIVA: {},
          rfcToEfectosFiscales: {},
          rfcToExtranjeroInfo: {},
        ),
      );

      final records =
          DIOTMappingService.mapCFDIsToRecords([cfdi], configuration);
      final record = records.first;

      print('PROBLEMA ORIGINAL:');
      print('  "IVA PROPORCIONADO (\$219.31) difiere del esperado (\$377.52)"');
      print('');
      print('ANÁLISIS:');
      print('  Subtotal: \$2359.53');
      print(
          '  IVA esperado (16%): \$${(2359.53 * 0.16).toStringAsFixed(2)} ← INCORRECTO');
      print('  IVA real del CFDI: \$219.31 ← CORRECTO (del SAT)');
      print('');
      print('RESULTADO ACTUAL:');
      print('  Sistema usa: \$${record.ivaAcreditableExclusivo16}');

      expect(
        record.ivaAcreditableExclusivo16,
        219.31,
        reason: 'Debe usar el valor real del CFDI, no el calculado',
      );

      print('');
      print('✅ PROBLEMA RESUELTO:');
      print('   - Sistema ya no calcula IVA erróneamente');
      print('   - Usa valor real del CFDI validado por SAT');
      print('   - Maneja productos con tasas mixtas correctamente');
    });
  });
}
