import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/diot_2025_validation_service.dart';
import 'package:comparador_cfdis/models/diot_record.dart';

void main() {
  group('DIOT 2025 - Discount Scenario Validation (Corrected)', () {
    test('Should not validate IVA consistency (old incorrect approach)', () {
      print('=== TEST: No validar consistencia de IVA (enfoque anterior) ===');

      // ANTERIORMENTE CONSIDERADO INCORRECTO: IVA calculado sobre base gravable
      // AHORA: Confiamos en los valores del CFDI ya validados por el SAT
      const record = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 2359.53, // Subtotal completo
        ivaAcreditableExclusivo16: 262.70, // IVA del CFDI (ya validado por SAT)
      );

      print('VALORES DEL CFDI (confiamos en el SAT):');
      print('  Valor de actos: \$2359.53 (subtotal)');
      print('  IVA del CFDI: \$262.70 (ya validado por SAT)');

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

      print('✅ CORRECTO: No se valida consistencia, se confía en CFDI');
    });

    test('Should not validate IVA consistency (correct approach)', () {
      print('=== TEST: No validar consistencia de IVA (enfoque correcto) ===');

      // ENFOQUE CON DEVOLUCIONES: IVA calculado sobre subtotal, descuentos en devoluciones
      // AHORA: Confiamos en los valores del CFDI ya validados por el SAT
      const record = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 2359.53, // Subtotal completo
        devoluciones16Porciento: 717.68, // Descuento como devolución
        ivaAcreditableExclusivo16: 377.52, // IVA del CFDI
      );

      print('VALORES DEL CFDI (confiamos en el SAT):');
      print('  Valor de actos: \$2359.53 (subtotal)');
      print('  Devoluciones: \$717.68 (descuento)');
      print('  IVA del CFDI: \$377.52 (ya validado por SAT)');

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

      print('✅ CORRECTO: No se valida consistencia, se confía en CFDI');
    });

    test('Should not validate tolerances (validation disabled)', () {
      print('=== TEST: No validar tolerancias (validación deshabilitada) ===');

      final testCases = [
        {
          'description': 'Diferencia de redondeo (\$0.01)',
          'baseAmount': 1000.0,
          'actualIVA': 160.01, // Diferencia mínima
        },
        {
          'description': 'Diferencia dentro del 5%',
          'baseAmount': 1000.0,
          'actualIVA': 156.0, // ~2.5% menos del esperado
        },
        {
          'description': 'Diferencia mayor al 5%',
          'baseAmount': 1000.0,
          'actualIVA': 140.0, // 12.5% menos del esperado
        },
        {
          'description': 'IVA exacto',
          'baseAmount': 1000.0,
          'actualIVA': 160.0, // Exacto
        }
      ];

      for (final testCase in testCases) {
        final description = testCase['description'] as String;
        final baseAmount = testCase['baseAmount'] as double;
        final actualIVA = testCase['actualIVA'] as double;

        final record = DIOTRecord(
          rfc: 'XAXX010101000',
          tipoTercero: TipoTercero.nacional,
          tipoOperacion: TipoOperacion.enajenacionBienes,
          efectosFiscales: EfectosFiscales.si,
          valorActos16Porciento: baseAmount,
          ivaAcreditableExclusivo16: actualIVA,
        );

        final errors = DIOT2025ValidationService.validateRecord2025(record);
        final hasIVAError = errors.any(
          (e) => e.field == 'iva_16_porciento',
        );

        // NOTA: Validaciones de consistencia de IVA han sido deshabilitadas
        // porque los valores del CFDI ya son correctos según el SAT
        expect(
          hasIVAError,
          false,
          reason: 'IVA consistency validations are disabled. '
              'CFDI values are already validated by SAT.',
        );

        print('  ✅ $description - No se valida consistencia');
      }
    });

    test('Should not validate IVA for cases without discounts', () {
      print('=== TEST: No validar IVA para casos sin descuentos ===');

      const record = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 1000.0,
        ivaAcreditableExclusivo16: 160.0, // IVA del CFDI
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

      print('✅ Casos sin descuento: No se valida consistencia');
    });
  });
}
