import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/impuesto.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

void main() {
  group('DIOT Currency Conversion Tests', () {
    const testConfig = DIOTConfiguration(
      year: 2025,
      month: 6,
      ejercicio: 2025,
      periodo: 6,
      rfcContribuyente: 'MERC640209B90',
      tipoComplemento: TipoComplemento.normal,
      filterCriteria: DIOTFilterCriteria(),
      userPreferences: DIOTUserPreferences(),
    );

    test('Should convert USD CFDI to MXN using TipoCambio', () async {
      print('=== TEST: Conversión USD a MXN usando TipoCambio ===');

      // CFDI en dólares americanos
      final cfdiUSD = CFDI(
        version: '4.0',
        fecha: '2025-06-19T10:31:09',
        moneda: 'USD',
        tipoCambio: '20.5', // 1 USD = 20.5 MXN
        subTotal: '1000.00', // $1,000 USD
        descuento: '100.00', // $100 USD descuento
        total: '1060.00', // $1,060 USD total
        tipoDeComprobante: 'I',
        emisor: Emisor(rfc: 'XEXX010101001', nombre: 'Proveedor Internacional'),
        impuestos: Impuesto(
          totalImpuestosRetenidos: 0.0,
          totalImpuestosTrasladados: 160.0, // $160 USD de IVA
          retenciones: [],
          traslados: [],
        ),
      );

      // Mapear a DIOT (debería convertir a pesos)
      final records =
          DIOTMappingService.mapCFDIsToRecords([cfdiUSD], testConfig);
      expect(records.length, 1);

      final record = records.first;

      print('📊 VALORES ORIGINALES (USD):');
      print('  Subtotal: \$1,000.00 USD');
      print('  Descuento: \$100.00 USD');
      print('  IVA: \$160.00 USD');
      print('  Tipo de cambio: 20.5');

      print('');
      print('📊 VALORES CONVERTIDOS (MXN):');
      print('  valorActos16Porciento: \$${record.valorActos16Porciento}');
      print('  devoluciones16Porciento: \$${record.devoluciones16Porciento}');
      print(
        '  ivaAcreditableExclusivo16: \$${record.ivaAcreditableExclusivo16}',
      );

      print('');
      print('🔍 VERIFICACIÓN:');
      print('  Subtotal esperado: \$20,500.00 MXN (1000 * 20.5)');
      print('  Descuento esperado: \$2,050.00 MXN (100 * 20.5)');
      print('  IVA esperado: \$3,280.00 MXN (160 * 20.5)');

      // Verificar conversiones
      expect(
        record.valorActos16Porciento,
        20500.0,
        reason: 'Subtotal debe convertirse: 1000 USD * 20.5 = 20,500 MXN',
      );
      expect(
        record.devoluciones16Porciento,
        2050.0,
        reason: 'Descuento debe convertirse: 100 USD * 20.5 = 2,050 MXN',
      );
      expect(
        record.ivaAcreditableExclusivo16,
        3280.0,
        reason: 'IVA debe convertirse: 160 USD * 20.5 = 3,280 MXN',
      );

      print('');
      print('✅ ÉXITO: Conversión USD a MXN funciona correctamente');
    });

    test('Should handle MXN CFDI without conversion', () async {
      print('=== TEST: CFDI en MXN sin conversión ===');

      // CFDI en pesos mexicanos (no requiere conversión)
      final cfdiMXN = CFDI(
        version: '4.0',
        fecha: '2025-06-19T10:31:09',
        moneda: 'MXN',
        tipoCambio: '1', // Sin conversión
        subTotal: '1000.00', // $1,000 MXN
        descuento: '100.00', // $100 MXN descuento
        total: '1060.00', // $1,060 MXN total
        tipoDeComprobante: 'I',
        emisor: Emisor(rfc: 'XAXX010101000', nombre: 'Proveedor Nacional'),
        impuestos: Impuesto(
          totalImpuestosRetenidos: 0.0,
          totalImpuestosTrasladados: 160.0, // $160 MXN de IVA
          retenciones: [],
          traslados: [],
        ),
      );

      final records =
          DIOTMappingService.mapCFDIsToRecords([cfdiMXN], testConfig);
      final record = records.first;

      print('📊 VALORES MXN (sin conversión):');
      print('  valorActos16Porciento: \$${record.valorActos16Porciento}');
      print('  devoluciones16Porciento: \$${record.devoluciones16Porciento}');
      print(
        '  ivaAcreditableExclusivo16: \$${record.ivaAcreditableExclusivo16}',
      );

      // Los valores deben mantenerse igual (sin conversión)
      expect(record.valorActos16Porciento, 1000.0);
      expect(record.devoluciones16Porciento, 100.0);
      expect(record.ivaAcreditableExclusivo16, 160.0);

      print('✅ ÉXITO: CFDIs en MXN no se convierten');
    });

    test('Should handle multiple CFDIs with different currencies', () async {
      print('=== TEST: Múltiples CFDIs con diferentes monedas ===');

      final cfdiMXN = CFDI(
        version: '4.0',
        moneda: 'MXN',
        tipoCambio: '1',
        subTotal: '1000.00',
        descuento: '0',
        emisor: Emisor(rfc: 'XAXX010101000'),
        impuestos: Impuesto(
          totalImpuestosRetenidos: 0.0,
          totalImpuestosTrasladados: 160.0,
          retenciones: [],
          traslados: [],
        ),
      );

      final cfdiUSD = CFDI(
        version: '4.0',
        moneda: 'USD',
        tipoCambio: '20.0',
        subTotal: '500.00', // $500 USD
        descuento: '50.00', // $50 USD
        emisor: Emisor(rfc: 'XAXX010101000'), // Mismo RFC para agrupar
        impuestos: Impuesto(
          totalImpuestosRetenidos: 0.0,
          totalImpuestosTrasladados: 80.0, // $80 USD
          retenciones: [],
          traslados: [],
        ),
      );

      final records =
          DIOTMappingService.mapCFDIsToRecords([cfdiMXN, cfdiUSD], testConfig);
      final record = records.first; // Agrupados por mismo RFC

      print('📊 CFDI 1 (MXN): Subtotal \$1,000, IVA \$160');
      print('📊 CFDI 2 (USD): Subtotal \$500, IVA \$80 (TC: 20.0)');
      print('');
      print('📊 TOTAL AGREGADO (todo en MXN):');
      print('  valorActos16Porciento: \$${record.valorActos16Porciento}');
      print('  devoluciones16Porciento: \$${record.devoluciones16Porciento}');
      print(
        '  ivaAcreditableExclusivo16: \$${record.ivaAcreditableExclusivo16}',
      );

      // Verificar agregación correcta:
      // Subtotal: 1000 MXN + (500 USD * 20) = 1000 + 10000 = 11000 MXN
      // Descuento: 0 MXN + (50 USD * 20) = 0 + 1000 = 1000 MXN
      // IVA: 160 MXN + (80 USD * 20) = 160 + 1600 = 1760 MXN
      expect(record.valorActos16Porciento, 11000.0);
      expect(record.devoluciones16Porciento, 1000.0);
      expect(record.ivaAcreditableExclusivo16, 1760.0);

      print('✅ ÉXITO: Agregación multi-moneda funciona correctamente');
    });

    test('Should handle EUR currency conversion', () async {
      print('=== TEST: Conversión EUR a MXN ===');

      final cfdiEUR = CFDI(
        version: '4.0',
        moneda: 'EUR',
        tipoCambio: '22.8', // 1 EUR = 22.8 MXN
        subTotal: '1000.00', // €1,000
        descuento: '200.00', // €200
        emisor: Emisor(rfc: 'XEXX010101002'),
        impuestos: Impuesto(
          totalImpuestosRetenidos: 0.0,
          totalImpuestosTrasladados: 180.0, // €180
          retenciones: [],
          traslados: [],
        ),
      );

      final records =
          DIOTMappingService.mapCFDIsToRecords([cfdiEUR], testConfig);
      final record = records.first;

      print('📊 VALORES ORIGINALES (EUR):');
      print('  Subtotal: €1,000.00');
      print('  Descuento: €200.00');
      print('  IVA: €180.00');
      print('  Tipo de cambio: 22.8');

      print('');
      print('📊 VALORES CONVERTIDOS (MXN):');
      print('  valorActos16Porciento: \$${record.valorActos16Porciento}');
      print('  devoluciones16Porciento: \$${record.devoluciones16Porciento}');
      print(
        '  ivaAcreditableExclusivo16: \$${record.ivaAcreditableExclusivo16}',
      );

      // Verificar conversiones EUR a MXN
      expect(record.valorActos16Porciento, 22800.0); // 1000 * 22.8
      expect(record.devoluciones16Porciento, 4560.0); // 200 * 22.8
      expect(record.ivaAcreditableExclusivo16, 4104.0); // 180 * 22.8

      print('✅ ÉXITO: Conversión EUR a MXN funciona correctamente');
    });
  });
}
