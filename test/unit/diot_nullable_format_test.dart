import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/models/diot_record.dart';

void main() {
  group('DIOT Nullable Format Tests', () {
    test('should export null values as empty strings', () {
      final record = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        // Campos con null - deben exportarse como campos vacíos
        valorActosFronteraNorte: null,
        valorActos16Porciento: 1500.00,  // Campo con valor - debe exportarse como "1500.00"
        valorActosFronteraSur: null,
        // Los demás campos quedarán null por defecto
      );

      final exportLine = record.toPipeDelimitedString();
      
      print('Export line: $exportLine');
      
      // Verificar que contiene el valor y no contiene "0" innecesarios
      expect(exportLine.contains('1500.00'), isTrue, reason: 'Debe contener el valor 1500.00');
      
      // Contar campos vacíos consecutivos (||)
      final doubleBarCount = exportLine.split('||').length - 1;
      expect(doubleBarCount, greaterThan(0), reason: 'Debe haber campos vacíos (||) para valores null');
    });

    test('should distinguish between null and zero values', () {
      final record = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActosFronteraNorte: 0.0,  // Cero explícito - debe mostrarse como "0.00"
        valorActos16Porciento: null,  // Null - debe ser campo vacío
        valorActosFronteraSur: 0.0,  // Cero explícito - debe mostrarse como "0.00"
      );

      final exportLine = record.toPipeDelimitedString();
      
      print('Export line with zeros: $exportLine');
      
      // Verificar que contiene "0.00" para ceros explícitos
      expect(exportLine.contains('0.00'), isTrue, reason: 'Debe contener "0.00" para valores de cero explícitos');
      
      // Verificar que hay campos vacíos para null
      expect(exportLine.contains('||'), isTrue, reason: 'Debe haber campos vacíos para valores null');
    });

    test('should handle helper getters correctly', () {
      final record = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActosFronteraNorte: null,
        valorActos16Porciento: 1500.00,
        valorActosFronteraSur: null,
      );

      // Verificar que los helper getters funcionan correctamente
      expect(record.safeValorActosFronteraNorte, equals(0.0), reason: 'Helper debe devolver 0.0 para null');
      expect(record.safeValorActos16Porciento, equals(1500.00), reason: 'Helper debe devolver el valor real');
      expect(record.safeValorActosFronteraSur, equals(0.0), reason: 'Helper debe devolver 0.0 para null');
    });

    test('_formatNullableNumericValue should format correctly', () {
      // Creamos un record con valores específicos y verificamos el output
      final recordWithValues = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: null,
        valorActosFronteraNorte: 0.0,
        valorActosFronteraSur: 123.45,
      );

      final exportLine = recordWithValues.toPipeDelimitedString();
      
      // Verificar que:
      // - null se convierte en campo vacío
      // - 0.0 se convierte en "0.00"  
      // - 123.45 se convierte en "123.45"
      expect(exportLine.contains('0.00'), isTrue, reason: 'Cero debe formatearse como "0.00"');
      expect(exportLine.contains('123.45'), isTrue, reason: 'Valor decimal debe formatearse correctamente');
      expect(exportLine.contains('||'), isTrue, reason: 'Null debe crear campo vacío (||)');
    });
  });
}
