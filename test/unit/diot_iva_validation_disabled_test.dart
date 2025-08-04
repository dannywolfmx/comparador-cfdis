import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/diot_2025_validation_service.dart';
import 'package:comparador_cfdis/models/diot_record.dart';

void main() {
  group('DIOT2025ValidationService - IVA Validation Disabled Tests', () {
    test(
        'should NOT validate IVA consistency for 16% rate with products at 0% tax',
        () {
      // Arrange - Record with products at different tax rates (0% and 16%)
      const record = DIOTRecord(
        rfc: 'ABC123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        // Subtotal includes products at 0% and 16% tax rates
        valorActos16Porciento: 2360.00, // Total subtotal from CFDI
        devoluciones16Porciento: 0.0,
        // Real IVA from CFDI (only for products with 16% rate)
        ivaAcreditableExclusivo16: 219.31, // Real IVA from CFDI
        // If we calculated 16% of subtotal: 2360 * 0.16 = 377.60
        // But real IVA is 219.31 because some products are at 0% tax
      );

      // Act
      final errors = DIOT2025ValidationService.validateRecord2025(record);

      // Assert
      final ivaErrors = errors
          .where(
            (e) =>
                e.field == 'iva_16_porciento' ||
                e.message.contains('IVA proporcionado') ||
                e.message.contains('difiere del esperado'),
          )
          .toList();

      expect(
        ivaErrors,
        isEmpty,
        reason: 'IVA consistency validation should be disabled. '
            'CFDI values are already correct per SAT standards.',
      );
    });

    test('should NOT validate IVA consistency for frontera norte', () {
      // Arrange
      const record = DIOTRecord(
        rfc: 'DEF456789012',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActosFronteraNorte: 1000.0,
        // IVA that doesn't match 8% calculation due to mixed tax rates
        ivaAcreditableExclusivoFronteraNorte: 60.0, // Real from CFDI
        // Expected would be: 1000 * 0.08 = 80.0, but real is 60.0
      );

      // Act
      final errors = DIOT2025ValidationService.validateRecord2025(record);

      // Assert
      final ivaErrors = errors
          .where(
            (e) =>
                e.field == 'iva_frontera_norte' ||
                e.message.contains('frontera norte'),
          )
          .toList();

      expect(
        ivaErrors,
        isEmpty,
        reason: 'IVA frontera norte validation should be disabled',
      );
    });

    test('should NOT validate IVA consistency for frontera sur', () {
      // Arrange
      const record = DIOTRecord(
        rfc: 'GHI789012345',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActosFronteraSur: 500.0,
        // IVA that doesn't match 8% calculation due to mixed tax rates
        ivaAcreditableExclusivoFronteraSur: 30.0, // Real from CFDI
        // Expected would be: 500 * 0.08 = 40.0, but real is 30.0
      );

      // Act
      final errors = DIOT2025ValidationService.validateRecord2025(record);

      // Assert
      final ivaErrors = errors
          .where(
            (e) =>
                e.field == 'iva_frontera_sur' ||
                e.message.contains('frontera sur'),
          )
          .toList();

      expect(
        ivaErrors,
        isEmpty,
        reason: 'IVA frontera sur validation should be disabled',
      );
    });

    test('should still perform other validations (non-IVA related)', () {
      // Arrange - Record with invalid RFC format
      const record = DIOTRecord(
        rfc: 'INVALID_RFC', // Invalid RFC format - should be validated
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 1000.0,
        ivaAcreditableExclusivo16: 160.0,
      );

      // Act
      final errors = DIOT2025ValidationService.validateRecord2025(record);

      // Assert
      final nonIVAErrors = errors
          .where(
            (e) =>
                !e.message.contains('IVA proporcionado') &&
                !e.message.contains('difiere del esperado'),
          )
          .toList();

      expect(
        nonIVAErrors,
        isNotEmpty,
        reason: 'Non-IVA validations (like RFC format) should still work',
      );
    });

    test('should allow exact scenario from user report', () {
      // Arrange - Exact case from user: IVA 219.31 vs expected 377.52
      const record = DIOTRecord(
        rfc: 'USER123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        clasificacionIVA: ClasificacionIVA.exclusivoActividades,
        valorActos16Porciento: 2359.50, // Would give ~377.52 at 16%
        devoluciones16Porciento: 0.0,
        ivaAcreditableExclusivo16: 219.31, // Real IVA from CFDI
      );

      // Act
      final errors = DIOT2025ValidationService.validateRecord2025(record);

      // Assert
      final ivaConsistencyErrors = errors
          .where(
            (e) =>
                e.message.contains('IVA proporcionado') &&
                e.message.contains('difiere del esperado'),
          )
          .toList();

      expect(
        ivaConsistencyErrors,
        isEmpty,
        reason: 'Should accept real CFDI IVA values without validation errors',
      );

      // Verify no IVA-related errors at all
      final anyIVAErrors = errors
          .where(
            (e) =>
                e.message.toLowerCase().contains('iva') &&
                (e.message.contains('proporcionado') ||
                    e.message.contains('esperado') ||
                    e.message.contains('difiere')),
          )
          .toList();

      expect(
        anyIVAErrors,
        isEmpty,
        reason: 'No IVA consistency errors should be generated',
      );
    });
  });
}
