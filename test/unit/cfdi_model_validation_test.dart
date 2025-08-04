
import 'package:test/test.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/complemento_pago.dart';

void main() {
  group('CFDI Model Validation', () {
    test('CFDI should handle null values gracefully', () {
      final cfdi = CFDI.fromJson({});
      expect(cfdi.version, isNull);
      expect(cfdi.total, isNull);
      expect(cfdi.fecha, isNull);
      expect(cfdi.emisor, isNull);
      expect(cfdi.receptor, isNull);
      expect(cfdi.conceptos, isNull);
    });

    

    test('isPagoCFDI should be true for "P" type', () {
      final cfdi = CFDI(tipoDeComprobante: 'P');
      expect(cfdi.isPagoCFDI, isTrue);
    });

    test('isPagoCFDI should be true for "p" type (lowercase)', () {
      final cfdi = CFDI(tipoDeComprobante: 'p');
      expect(cfdi.isPagoCFDI, isTrue);
    });

    test('isPagoCFDI should be true if complementoPago exists', () {
      final cfdi = CFDI(complementoPago: ComplementoPago());
      expect(cfdi.isPagoCFDI, isTrue);
    });

    test('isPagoCFDI should be false for other types', () {
      final cfdi = CFDI(tipoDeComprobante: 'I');
      expect(cfdi.isPagoCFDI, isFalse);
    });
  });
}
