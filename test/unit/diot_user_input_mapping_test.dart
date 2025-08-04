import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';
import 'package:comparador_cfdis/models/diot_record.dart';

void main() {
  group('DIOTMappingService - User Input Tests', () {
    test('updateRecordWithUserInput correctly maps devoluciones field', () {
      // Arrange
      const originalRecord = DIOTRecord(
        rfc: 'TEST123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 1000.0,
        devoluciones16Porciento: 50.0, // Valor inicial
        requiresUserInput: true,
      );

      final userInput = <String, dynamic>{
        'tipoTercero': TipoTercero.extranjero,
        'devoluciones': 150.0, // Nuevo valor de devoluciones
        'nombreExtranjero': 'Foreign Company',
      };

      // Act
      final updatedRecord = DIOTMappingService.updateRecordWithUserInput(
        originalRecord,
        userInput,
      );

      // Assert
      expect(updatedRecord.devoluciones16Porciento, equals(150.0));
      expect(updatedRecord.tipoTercero, equals(TipoTercero.extranjero));
      expect(updatedRecord.nombreExtranjero, equals('Foreign Company'));
      expect(updatedRecord.requiresUserInput, isFalse);

      // Verificar que otros campos se mantienen
      expect(updatedRecord.rfc, equals('TEST123456789'));
      expect(updatedRecord.valorActos16Porciento, equals(1000.0));
    });

    test('updateRecordWithUserInput handles null devoluciones value', () {
      // Arrange
      const originalRecord = DIOTRecord(
        rfc: 'TEST123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 1000.0,
        devoluciones16Porciento: 50.0, // Valor inicial
        requiresUserInput: true,
      );

      final userInput = <String, dynamic>{
        'tipoTercero': TipoTercero.extranjero,
        // Sin campo 'devoluciones'
        'nombreExtranjero': 'Foreign Company',
      };

      // Act
      final updatedRecord = DIOTMappingService.updateRecordWithUserInput(
        originalRecord,
        userInput,
      );

      // Assert
      expect(updatedRecord.devoluciones16Porciento,
          equals(50.0)); // Mantiene valor original
      expect(updatedRecord.tipoTercero, equals(TipoTercero.extranjero));
      expect(updatedRecord.nombreExtranjero, equals('Foreign Company'));
    });

    test('updateRecordWithUserInput handles zero devoluciones value', () {
      // Arrange
      const originalRecord = DIOTRecord(
        rfc: 'TEST123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 1000.0,
        devoluciones16Porciento: 50.0, // Valor inicial
        requiresUserInput: true,
      );

      final userInput = <String, dynamic>{
        'devoluciones': 0.0, // Cero explícito
        'tipoTercero': TipoTercero.extranjero,
      };

      // Act
      final updatedRecord = DIOTMappingService.updateRecordWithUserInput(
        originalRecord,
        userInput,
      );

      // Assert
      expect(updatedRecord.devoluciones16Porciento, equals(0.0));
      expect(updatedRecord.tipoTercero, equals(TipoTercero.extranjero));
    });

    test('updateRecordWithUserInput handles integer devoluciones value', () {
      // Arrange
      const originalRecord = DIOTRecord(
        rfc: 'TEST123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 1000.0,
        devoluciones16Porciento: 50.0,
        requiresUserInput: true,
      );

      final userInput = <String, dynamic>{
        'devoluciones': 200, // Valor entero
        'tipoTercero': TipoTercero.extranjero,
      };

      // Act
      final updatedRecord = DIOTMappingService.updateRecordWithUserInput(
        originalRecord,
        userInput,
      );

      // Assert
      expect(updatedRecord.devoluciones16Porciento, equals(200.0));
      expect(updatedRecord.tipoTercero, equals(TipoTercero.extranjero));
    });
  });
}
