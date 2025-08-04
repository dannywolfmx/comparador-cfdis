import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

void main() {
  group('DIOT Mapping Service - Correct Discount Handling', () {
    test('Should map discounts correctly to devoluciones field', () {
      print('=== TEST: Mapeo correcto de descuentos a campo devoluciones ===');

      // Crear CFDI simulando el caso del usuario
      final cfdi = CFDI(
        subTotal: '2359.53', // Va en valorActos16Porciento
        descuento: '717.68', // Va en devoluciones16Porciento
        total: '1861.16', // Total final
        emisor: Emisor(rfc: 'XAXX010101000'),
      );

      print('CFDI Input:');
      print('  Subtotal: \$2359.53 → valorActos16Porciento');
      print('  Descuento: \$717.68 → devoluciones16Porciento');
      print('  Total: \$1861.16');

      // Crear configuración DIOT básica
      const config = DIOTConfiguration(
        year: 2025,
        month: 1,
        ejercicio: 2025,
        periodo: 1,
        rfcContribuyente: 'XAXX010101000',
        tipoComplemento: TipoComplemento.normal,
        filterCriteria: DIOTFilterCriteria(),
        userPreferences: DIOTUserPreferences(
          rfcToTipoTercero: {},
          rfcToTipoOperacion: {},
          rfcToClasificacionRegional: {},
          rfcToClasificacionIVA: {},
          rfcToEfectosFiscales: {},
          rfcToExtranjeroInfo: {},
        ),
      );

      // Usar el mapping service
      final records = DIOTMappingService.mapCFDIsToRecords([cfdi], config);
      expect(records.isNotEmpty, true);

      final record = records.first;

      print('');
      print('DIOT Mapping Result:');
      print(
          '  valorActos16Porciento: \$${record.valorActos16Porciento?.toStringAsFixed(2)}');
      print(
          '  devoluciones16Porciento: \$${record.devoluciones16Porciento?.toStringAsFixed(2)}');

      // Verificar que el mapeo es correcto
      expect(
        record.valorActos16Porciento,
        closeTo(2359.53, 0.01),
        reason: 'El valor de actos debe ser el subtotal completo',
      );

      expect(
        record.devoluciones16Porciento,
        closeTo(717.68, 0.01),
        reason: 'Las devoluciones deben contener el descuento del CFDI',
      );

      print('');
      print('✅ CORRECTO: Descuento mapeado apropiadamente como devolución');
      print('✅ CORRECTO: Valor de actos mantiene el subtotal original');
    });

    test('Should handle CFDIs without discount correctly', () {
      print('=== TEST: Manejo correcto de CFDIs sin descuento ===');

      // CFDI sin descuento
      final cfdi = CFDI(
        subTotal: '1000.00',
        // Sin campo descuento
        total: '1160.00',
        emisor: Emisor(rfc: 'XAXX010101000'),
      );

      const config = DIOTConfiguration(
        year: 2025,
        month: 1,
        ejercicio: 2025,
        periodo: 1,
        rfcContribuyente: 'XAXX010101000',
        tipoComplemento: TipoComplemento.normal,
        filterCriteria: DIOTFilterCriteria(),
        userPreferences: DIOTUserPreferences(
          rfcToTipoTercero: {},
          rfcToTipoOperacion: {},
          rfcToClasificacionRegional: {},
          rfcToClasificacionIVA: {},
          rfcToEfectosFiscales: {},
          rfcToExtranjeroInfo: {},
        ),
      );

      final records = DIOTMappingService.mapCFDIsToRecords([cfdi], config);
      final record = records.first;

      // Sin descuento, debe usar el subtotal y cero devoluciones
      expect(
        record.valorActos16Porciento,
        closeTo(1000.00, 0.01),
        reason: 'Sin descuento, debe usar el subtotal completo',
      );

      expect(
        record.devoluciones16Porciento,
        closeTo(0.00, 0.01),
        reason: 'Sin descuento, devoluciones debe ser cero',
      );

      print('✅ CORRECTO: Sin descuento usa subtotal y cero devoluciones');
    });

    test('Should handle multiple CFDIs with mixed discount scenarios', () {
      print('=== TEST: Múltiples CFDIs con escenarios mixtos de descuento ===');

      final cfdis = [
        CFDI(
          subTotal: '1000.00',
          descuento: '100.00',
          emisor: Emisor(rfc: 'XAXX010101000'),
        ), // Subtotal: 1000.00, Descuento: 100.00
        CFDI(
          subTotal: '500.00',
          emisor: Emisor(rfc: 'XAXX010101000'),
        ), // Subtotal: 500.00, Sin descuento
        CFDI(
          subTotal: '2359.53',
          descuento: '717.68',
          emisor: Emisor(rfc: 'XAXX010101000'),
        ), // Subtotal: 2359.53, Descuento: 717.68
      ];

      const subtotalTotal = 1000.00 + 500.00 + 2359.53; // = 3859.53
      const descuentoTotal = 100.00 + 0.00 + 717.68; // = 817.68

      const config = DIOTConfiguration(
        year: 2025,
        month: 1,
        ejercicio: 2025,
        periodo: 1,
        rfcContribuyente: 'XAXX010101000',
        tipoComplemento: TipoComplemento.normal,
        filterCriteria: DIOTFilterCriteria(),
        userPreferences: DIOTUserPreferences(
          rfcToTipoTercero: {},
          rfcToTipoOperacion: {},
          rfcToClasificacionRegional: {},
          rfcToClasificacionIVA: {},
          rfcToEfectosFiscales: {},
          rfcToExtranjeroInfo: {},
        ),
      );

      final records = DIOTMappingService.mapCFDIsToRecords(cfdis, config);
      final record = records.first;

      expect(
        record.valorActos16Porciento,
        closeTo(subtotalTotal, 0.01),
        reason: 'Debe sumar correctamente los subtotales de múltiples CFDIs',
      );

      expect(
        record.devoluciones16Porciento,
        closeTo(descuentoTotal, 0.01),
        reason: 'Debe sumar correctamente los descuentos de múltiples CFDIs',
      );

      print(
          '✅ CORRECTO: Total de subtotales = \$${subtotalTotal.toStringAsFixed(2)}');
      print(
          '✅ CORRECTO: Total de descuentos = \$${descuentoTotal.toStringAsFixed(2)}');
    });
  });
}
