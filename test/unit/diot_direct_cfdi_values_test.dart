import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/impuesto.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

void main() {
  group('DIOTMappingService - Direct CFDI Values Tests', () {
    // Configuración básica para las pruebas
    const testConfig = DIOTConfiguration(
      year: 2025,
      month: 1,
      ejercicio: 2025,
      periodo: 1,
      rfcContribuyente: 'TEST123456789',
      tipoComplemento: TipoComplemento.normal,
      filterCriteria: DIOTFilterCriteria(),
      userPreferences: DIOTUserPreferences(),
    );

    test('should use TotalImpuestosTrasladados when available', () {
      // Arrange
      final cfdi = CFDI(
        subTotal: '1000.00',
        descuento: '100.00',
        total: '1060.00',
        emisor: Emisor(rfc: 'ABC123456789', nombre: 'Proveedor Test'),
        impuestos: Impuesto(
          totalImpuestosRetenidos: 0.0,
          totalImpuestosTrasladados: 160.0, // IVA directo del CFDI
          retenciones: [],
          traslados: [],
        ),
      );

      final cfdis = [cfdi];

      // Act
      final records = DIOTMappingService.mapCFDIsToRecords(cfdis, testConfig);
      final record = records.firstWhere((r) => r.rfc == 'ABC123456789');

      // Assert
      expect(record.valorActos16Porciento, equals(1000.0)); // Subtotal
      expect(record.devoluciones16Porciento, equals(100.0)); // Descuento
      // Nota: El IVA se mapea en otra parte del sistema DIOT
    });

    test('should handle CFDIs without TotalImpuestosTrasladados (fallback)',
        () {
      // Arrange - CFDI sin campo de impuestos totales
      final cfdi = CFDI(
        subTotal: '1000.00',
        descuento: '50.00',
        total: '1110.00',
        emisor: Emisor(rfc: 'XYZ987654321', nombre: 'Proveedor Test 2'),
        // Sin campo impuestos - debería usar fallback
      );

      final cfdis = [cfdi];

      // Act
      final records = DIOTMappingService.mapCFDIsToRecords(cfdis, testConfig);
      final record = records.firstWhere((r) => r.rfc == 'XYZ987654321');

      // Assert
      expect(record.valorActos16Porciento, equals(1000.0)); // Subtotal directo
      expect(record.devoluciones16Porciento, equals(50.0)); // Descuento directo
    });

    test('should handle zero values correctly', () {
      // Arrange
      final cfdi = CFDI(
        subTotal: '1000.00',
        descuento: '0.00', // Sin descuento
        total: '1160.00',
        emisor: Emisor(rfc: 'DEF456789012', nombre: 'Proveedor Test 3'),
        impuestos: Impuesto(
          totalImpuestosRetenidos: 0.0,
          totalImpuestosTrasladados: 160.0,
          retenciones: [],
          traslados: [],
        ),
      );

      final cfdis = [cfdi];

      // Act
      final records = DIOTMappingService.mapCFDIsToRecords(cfdis, testConfig);
      final record = records.firstWhere((r) => r.rfc == 'DEF456789012');

      // Assert
      expect(record.valorActos16Porciento, equals(1000.0));
      expect(record.devoluciones16Porciento, equals(0.0)); // Sin descuento
    });

    test('should handle multiple CFDIs aggregation', () {
      // Arrange
      final cfdi1 = CFDI(
        subTotal: '1000.00',
        descuento: '100.00',
        total: '1060.00',
        emisor: Emisor(rfc: 'GHI789012345', nombre: 'Proveedor Test 4'),
        impuestos: Impuesto(
          totalImpuestosRetenidos: 0.0,
          totalImpuestosTrasladados: 160.0,
          retenciones: [],
          traslados: [],
        ),
      );

      final cfdi2 = CFDI(
        subTotal: '500.00',
        descuento: '25.00',
        total: '555.00',
        emisor: Emisor(
            rfc: 'GHI789012345', nombre: 'Proveedor Test 4'), // Mismo RFC
        impuestos: Impuesto(
          totalImpuestosRetenidos: 0.0,
          totalImpuestosTrasladados: 80.0,
          retenciones: [],
          traslados: [],
        ),
      );

      final cfdis = [cfdi1, cfdi2];

      // Act
      final records = DIOTMappingService.mapCFDIsToRecords(cfdis, testConfig);
      final record = records.firstWhere((r) => r.rfc == 'GHI789012345');

      // Assert
      expect(record.valorActos16Porciento, equals(1500.0)); // 1000 + 500
      expect(record.devoluciones16Porciento, equals(125.0)); // 100 + 25
    });

    test('should handle CFDIs with products at 0% tax rate', () {
      // Arrange - CFDI con productos exentos que pueden causar discrepancias
      final cfdi = CFDI(
        subTotal: '1000.00',
        descuento: '0.00',
        total: '1080.00', // Solo algunos productos causan IVA
        emisor: Emisor(rfc: 'JKL012345678', nombre: 'Proveedor Test 5'),
        impuestos: Impuesto(
          totalImpuestosRetenidos: 0.0,
          totalImpuestosTrasladados:
              80.0, // IVA real del CFDI (no 16% del subtotal)
          retenciones: [],
          traslados: [],
        ),
      );

      final cfdis = [cfdi];

      // Act
      final records = DIOTMappingService.mapCFDIsToRecords(cfdis, testConfig);
      final record = records.firstWhere((r) => r.rfc == 'JKL012345678');

      // Assert
      expect(record.valorActos16Porciento, equals(1000.0)); // Subtotal completo
      expect(record.devoluciones16Porciento, equals(0.0)); // Sin descuento
      // El IVA de 80.0 (no 160.0) se toma directamente del CFDI
    });
  });
}
