import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/models/diot_record.dart';

void main() {
  group('DIOT Nullable Format Tests', () {
    test('should export null values as empty strings', () {
      const record = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        // Campos con null - deben exportarse como campos vacíos
        valorActosFronteraNorte: null,
        valorActos16Porciento:
            1500.00, // Campo con valor - debe exportarse como "1500" (entero)
        valorActosFronteraSur: null,
        // Los demás campos quedarán null por defecto
      );

      final exportLine = record.toPipeDelimitedString();

      print('Export line: $exportLine');

      // Verificar que contiene el valor como entero según DIOT 2025
      expect(
        exportLine.contains('1500'),
        isTrue,
        reason: 'Debe contener el valor 1500 como entero',
      );

      // Contar campos vacíos consecutivos (||)
      final doubleBarCount = exportLine.split('||').length - 1;
      expect(
        doubleBarCount,
        greaterThan(0),
        reason: 'Debe haber campos vacíos (||) para valores null',
      );
    });

    test('should distinguish between null and zero values', () {
      const record = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActosFronteraNorte:
            0.0, // Cero explícito - según DIOT 2025 se exporta como campo vacío
        valorActos16Porciento: null, // Null - debe ser campo vacío
        valorActosFronteraSur:
            0.0, // Cero explícito - según DIOT 2025 se exporta como campo vacío
      );

      final exportLine = record.toPipeDelimitedString();

      print('Export line with zeros: $exportLine');

      // Verificar que hay campos vacíos para null y para ceros según DIOT 2025
      expect(
        exportLine.contains('||'),
        isTrue,
        reason: 'Debe haber campos vacíos para valores null y cero',
      );

      // Verificar que NO contiene "0" explícitos (según especificación DIOT 2025)
      final fields = exportLine.split('|');
      // Los campos de valores deberían estar vacíos
      expect(
        fields[7], // valorActosFronteraNorte
        isEmpty,
        reason: 'Cero debe formatearse como campo vacío según DIOT 2025',
      );
    });

    test('should handle helper getters correctly', () {
      const record = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActosFronteraNorte: null,
        valorActos16Porciento: 1500.00,
        valorActosFronteraSur: null,
      );

      // Verificar que los helper getters funcionan correctamente
      expect(
        record.safeValorActosFronteraNorte,
        equals(0.0),
        reason: 'Helper debe devolver 0.0 para null',
      );
      expect(
        record.safeValorActos16Porciento,
        equals(1500.00),
        reason: 'Helper debe devolver el valor real',
      );
      expect(
        record.safeValorActosFronteraSur,
        equals(0.0),
        reason: 'Helper debe devolver 0.0 para null',
      );
    });

    test('_formatNullableNumericValue should format correctly', () {
      // Creamos un record con valores específicos y verificamos el output
      const recordWithValues = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: null,
        valorActosFronteraNorte: 0.0,
        valorActosFronteraSur: 123.45,
      );

      final exportLine = recordWithValues.toPipeDelimitedString();

      // Verificar que según DIOT 2025:
      // - null se convierte en campo vacío
      // - 0.0 se convierte en campo vacío (no "0")
      // - 123.45 se convierte en "123" (entero)
      expect(
        exportLine.contains('123'),
        isTrue,
        reason: 'Valor decimal debe formatearse como entero',
      );
      expect(
        exportLine.contains('||'),
        isTrue,
        reason: 'Null y cero deben crear campos vacíos (||)',
      );

      // Verificar que NO contiene decimales o ceros explícitos
      expect(
        exportLine.contains('0.00'),
        isFalse,
        reason: 'No debe contener decimales según DIOT 2025',
      );
      expect(
        exportLine.contains('123.45'),
        isFalse,
        reason: 'No debe contener decimales según DIOT 2025',
      );
    });
  });
}
