import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/cfdi_parser.dart';
import 'package:comparador_cfdis/models/cfdi.dart';

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
      // Given
      const invalidXml = '<invalid>xml</invalid>';
      
      // When
      final result = CFDIParser.parseXmlString(invalidXml);
      
      // Then
      expect(result, isNull);
    });

    test('should handle empty XML string', () {
      // Given
      const emptyXml = '';
      
      // When
      final result = CFDIParser.parseXmlString(emptyXml);
      
      // Then
      expect(result, isNull);
    });
  });
}
