import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';
import 'package:comparador_cfdis/models/diot_record.dart';

void main() {
  group('DIOTMappingService - User Input Tests', () {
    test('updateRecordWithUserInput preserves CFDI devoluciones value', () {
      // Arrange - Record con descuento del CFDI
      const originalRecord = DIOTRecord(
        rfc: 'TEST123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 1000.0,
        devoluciones16Porciento: 50.0, // Valor del CFDI (tiene prioridad)
        requiresUserInput: true,
      );

      final userInput = <String, dynamic>{
        'tipoTercero': TipoTercero.extranjero,
        'devoluciones': 150.0, // Input del usuario (DEBE SER IGNORADO)
        'nombreExtranjero': 'Foreign Company',
      };

      // Act
      final updatedRecord = DIOTMappingService.updateRecordWithUserInput(
        originalRecord,
        userInput,
      );

      // Assert - Los descuentos del CFDI tienen prioridad
      expect(
        updatedRecord.devoluciones16Porciento,
        equals(50.0),
        reason: 'Debe preservar el valor del CFDI, no el input del usuario',
      );
      expect(updatedRecord.tipoTercero, equals(TipoTercero.extranjero));
      expect(updatedRecord.nombreExtranjero, equals('Foreign Company'));

      // Verificar que otros campos se mantienen
      expect(updatedRecord.rfc, equals('TEST123456789'));
      expect(updatedRecord.valorActos16Porciento, equals(1000.0));

      print('✅ CORRECTO: Descuentos del CFDI no se sobrescriben');
    });

    test('updateRecordWithUserInput handles null devoluciones value', () {
      // Arrange
      const originalRecord = DIOTRecord(
        rfc: 'TEST123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 1000.0,
        devoluciones16Porciento: 50.0, // Valor del CFDI
        requiresUserInput: true,
      );

      final userInput = <String, dynamic>{
        'tipoTercero': TipoTercero.extranjero,
        // Sin campo 'devoluciones' - debe preservar valor del CFDI
        'nombreExtranjero': 'Foreign Company',
      };

      // Act
      final updatedRecord = DIOTMappingService.updateRecordWithUserInput(
        originalRecord,
        userInput,
      );

      // Assert - Mantiene valor del CFDI
      expect(
        updatedRecord.devoluciones16Porciento,
        equals(50.0),
        reason: 'Debe mantener valor del CFDI cuando no hay input del usuario',
      );
      expect(updatedRecord.tipoTercero, equals(TipoTercero.extranjero));
      expect(updatedRecord.nombreExtranjero, equals('Foreign Company'));

      print('✅ CORRECTO: Preserva descuentos del CFDI cuando no hay input');
    });

    test('updateRecordWithUserInput handles zero devoluciones value', () {
      // Arrange
      const originalRecord = DIOTRecord(
        rfc: 'TEST123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 1000.0,
        devoluciones16Porciento: 50.0, // Valor del CFDI
        requiresUserInput: true,
      );

      final userInput = <String, dynamic>{
        'devoluciones': 0.0, // Input del usuario (DEBE SER IGNORADO)
        'tipoTercero': TipoTercero.extranjero,
      };

      // Act
      final updatedRecord = DIOTMappingService.updateRecordWithUserInput(
        originalRecord,
        userInput,
      );

      // Assert - Debe preservar valor del CFDI
      expect(
        updatedRecord.devoluciones16Porciento,
        equals(50.0),
        reason: 'Debe preservar valor del CFDI incluso con input cero',
      );
      expect(updatedRecord.tipoTercero, equals(TipoTercero.extranjero));

      print('✅ CORRECTO: Preserva descuentos del CFDI incluso con input cero');
    });

    test('updateRecordWithUserInput handles integer devoluciones value', () {
      // Arrange
      const originalRecord = DIOTRecord(
        rfc: 'TEST123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 1000.0,
        devoluciones16Porciento: 50.0, // Valor del CFDI
        requiresUserInput: true,
      );

      final userInput = <String, dynamic>{
        'devoluciones': 200, // Input del usuario (DEBE SER IGNORADO)
        'tipoTercero': TipoTercero.extranjero,
      };

      // Act
      final updatedRecord = DIOTMappingService.updateRecordWithUserInput(
        originalRecord,
        userInput,
      );

      // Assert - Debe preservar valor del CFDI
      expect(
        updatedRecord.devoluciones16Porciento,
        equals(50.0),
        reason: 'Debe preservar valor del CFDI incluso con input entero',
      );
      expect(updatedRecord.tipoTercero, equals(TipoTercero.extranjero));

      print(
          '✅ CORRECTO: Preserva descuentos del CFDI incluso con input entero');
    });
  });
}
