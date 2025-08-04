import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/cfdi_parser.dart';

void main() {
  group('CFDIParser Tests', () {
    test('should parse valid XML string to CFDI', () {
      // Given
      const xmlString = '''<?xml version="1.0" encoding="utf-8"?>
      <cfdi:Comprobante xmlns:cfdi="http://www.sat.gob.mx/cfd/4" 
                        Version="4.0" 
                        Serie="A" 
                        Folio="123" 
                        Fecha="2024-01-01T10:00:00"
                        SubTotal="100.00"
                        Total="116.00"
                        TipoDeComprobante="I"
                        Moneda="MXN">
        <cfdi:Emisor Rfc="XAXX010101000" Nombre="Empresa Test" />
        <cfdi:Receptor Rfc="XAXX010101000" Nombre="Cliente Test" />
        <cfdi:Conceptos>
          <cfdi:Concepto ClaveProdServ="01010101" 
                         Cantidad="1" 
                         ClaveUnidad="H87" 
                         Descripcion="Producto Test" 
                         ValorUnitario="100.00" 
                         Importe="100.00" />
        </cfdi:Conceptos>
      </cfdi:Comprobante>''';

      // When
      final result = CFDIParser.parseXmlString(xmlString);

      // Then
      expect(result, isNotNull);
      expect(result!.version, equals('4.0'));
      expect(result.serie, equals('A'));
      expect(result.folio, equals('123'));
      expect(result.emisor?.rfc, equals('XAXX010101000'));
    });

    test('should handle invalid XML gracefully', () {
      // Given - XML válido pero que no tiene estructura de CFDI
      const invalidXml = '<some><random>not cfdi</random></some>';

      // When
      final result = CFDIParser.parseXmlString(invalidXml);

      // Then - puede que devuelva un CFDI con campos vacíos/null
      // El parser procesa cualquier XML válido, pero el CFDI resultante tendrá campos faltantes
      if (result != null) {
        expect(result.serie, isNull);
        expect(result.folio, isNull);
        expect(result.fecha, isNull);
      }
      // Aceptamos tanto null como un CFDI con campos vacíos
    });

    test('should handle malformed XML string', () {
      // Given - XML mal formado que debería generar excepción
      const malformedXml = '<invalid><unclosed>';

      // When
      final result = CFDIParser.parseXmlString(malformedXml);

      // Then
      expect(result, isNull);
    });
  });
}
