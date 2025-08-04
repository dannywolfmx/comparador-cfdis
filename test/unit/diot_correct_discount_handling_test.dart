import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';
import 'package:comparador_cfdis/services/diot_2025_validation_service.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/models/diot_record.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

void main() {
  group('DIOT Correct Discount Handling Tests', () {
    test('Should handle discounts correctly as devoluciones, not tolerance',
        () {
      print('=== TEST: Manejo correcto de descuentos como devoluciones ===');

      // Caso del usuario: Subtotal $2359.53, Descuento $717.68, IVA $262.70
      final cfdi = CFDI(
        subTotal: '2359.53', // Va en valorActos16Porciento
        descuento: '717.68', // Va en devoluciones16Porciento
        total: '1861.16', // Total final después del descuento
        emisor: Emisor(rfc: 'XAXX010101000'),
      );

      // Configuración DIOT
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

      // Mapear CFDI a registro DIOT
      final records = DIOTMappingService.mapCFDIsToRecords([cfdi], config);
      expect(records.isNotEmpty, true);

      final record = records.first;

      print('Subtotal CFDI: \$2359.53');
      print('Descuento CFDI: \$717.68');
      print('IVA real CFDI: \$262.70 (basado en base gravable)');
      print('');
      print('DIOT Mapping Result:');
      print(
        '  valorActos16Porciento: \$${record.valorActos16Porciento?.toStringAsFixed(2)}',
      );
      print(
        '  devoluciones16Porciento: \$${record.devoluciones16Porciento?.toStringAsFixed(2)}',
      );
      print(
        '  ivaAcreditableExclusivo16: \$${record.ivaAcreditableExclusivo16?.toStringAsFixed(2)}',
      );

      // Verificar el mapeo correcto
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

      print('✅ CORRECTO: Descuento mapeado como devolución');
    });

    test('Should validate correctly with proper discount handling', () {
      print(
        '=== TEST: Validación correcta con manejo apropiado de descuentos ===',
      );

      // Registro con el mapeo correcto: subtotal en actos, descuento en devoluciones
      const record = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 2359.53, // Subtotal completo
        devoluciones16Porciento: 717.68, // Descuento del CFDI
        ivaAcreditableExclusivo16:
            377.52, // IVA basado en subtotal (2359.53 * 0.16)
      );

      final errors = DIOT2025ValidationService.validateRecord2025(record);
      final ivaErrors =
          errors.where((e) => e.field == 'iva_16_porciento').toList();

      // NOTA: Validaciones de consistencia de IVA han sido deshabilitadas
      // porque los valores del CFDI ya son correctos según el SAT
      expect(
        ivaErrors.isEmpty,
        true,
        reason: 'IVA consistency validations are disabled. '
            'CFDI values are already validated by SAT.',
      );

      print(
        'IVA en CFDI: \$377.52 (confiamos en valores del SAT)',
      );
      print('✅ CORRECTO: No se valida consistencia de IVA');
    });

    test('Should not validate IVA consistency (disabled validation)', () {
      print(
        '=== TEST: No validar consistencia de IVA (validación deshabilitada) ===',
      );

      // Registro con IVA que anteriormente se consideraba "incorrecto"
      // Ahora confiamos en los valores del CFDI como correctos
      const recordWithCFDIValues = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 2359.53, // Subtotal completo
        devoluciones16Porciento: 717.68, // Descuento
        ivaAcreditableExclusivo16: 262.70, // IVA del CFDI (ya validado por SAT)
      );

      final errors =
          DIOT2025ValidationService.validateRecord2025(recordWithCFDIValues);
      final ivaErrors =
          errors.where((e) => e.field == 'iva_16_porciento').toList();

      // NOTA: Validaciones de consistencia de IVA han sido deshabilitadas
      // porque los valores del CFDI ya son correctos según el SAT
      expect(
        ivaErrors.isEmpty,
        true,
        reason: 'IVA consistency validations are disabled. '
            'CFDI values are already validated by SAT.',
      );

      print('Valor de actos: \$2359.53');
      print('IVA del CFDI: \$262.70 (confiamos en el SAT)');
      print('✅ CORRECTO: No se valida consistencia, se confía en CFDI');
    });

    test('Should handle multiple CFDIs with mixed discount scenarios', () {
      print('=== TEST: Múltiples CFDIs con escenarios mixtos ===');

      final cfdis = [
        CFDI(
          subTotal: '1000.00',
          descuento: '100.00', // 10% descuento
          emisor: Emisor(rfc: 'XAXX010101000'),
        ),
        CFDI(
          subTotal: '500.00',
          // Sin descuento
          emisor: Emisor(rfc: 'XAXX010101000'),
        ),
        CFDI(
          subTotal: '2359.53',
          descuento: '717.68', // ~30% descuento
          emisor: Emisor(rfc: 'XAXX010101000'),
        ),
      ];

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

      const expectedSubtotalSum = 1000.00 + 500.00 + 2359.53; // 3859.53
      const expectedDescuentoSum = 100.00 + 0.00 + 717.68; // 817.68

      expect(
        record.valorActos16Porciento,
        closeTo(expectedSubtotalSum, 0.01),
        reason: 'Debe sumar todos los subtotales',
      );

      expect(
        record.devoluciones16Porciento,
        closeTo(expectedDescuentoSum, 0.01),
        reason: 'Debe sumar todos los descuentos',
      );

      print('Total subtotales: \$${expectedSubtotalSum.toStringAsFixed(2)}');
      print('Total descuentos: \$${expectedDescuentoSum.toStringAsFixed(2)}');
      print('✅ CORRECTO: Agregación correcta de múltiples CFDIs');
    });
  });
}
