import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/models/diot_record.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

/// Servicio para exportar lotes DIOT a archivos de texto
class DIOTExportService {
  /// Exporta un lote DIOT a archivo de texto con formato SAT
  static Future<String> exportToFile(
    DIOTBatch batch, {
    String? customPath,
  }) async {
    // Validar que el lote esté listo para exportar
    if (!batch.isReadyForExport) {
      throw Exception('El lote no está listo para exportar');
    }

    // Determinar ruta del archivo
    final filePath = customPath ?? await _selectExportPath(batch);

    // Generar contenido del archivo
    final content = _generateDIOTContent(batch);

    // Escribir archivo
    final file = File(filePath);
    await file.writeAsString(
      content,
      encoding: const Utf8Codec(),
    );

    return filePath;
  }

  /// Exporta solo registros válidos (sin errores)
  static Future<String> exportValidRecordsOnly(
    DIOTBatch batch, {
    String? customPath,
  }) async {
    // Filtrar solo registros válidos
    final validRecords = batch.records
        .where(
          (record) =>
              record.validationErrors.isEmpty && !record.requiresUserInput,
        )
        .toList();

    if (validRecords.isEmpty) {
      throw Exception('No hay registros válidos para exportar');
    }

    // Crear lote temporal con solo registros válidos
    final tempBatch = batch.copyWith(records: validRecords);

    return exportToFile(tempBatch, customPath: customPath);
  }

  /// Genera vista previa del contenido DIOT
  static String generatePreview(DIOTBatch batch, {int maxLines = 10}) {
    final content = _generateDIOTContent(batch);
    final lines = content.split('\n');

    if (lines.length <= maxLines) {
      return content;
    }

    final previewLines = lines.take(maxLines).toList();
    previewLines.add('... (${lines.length - maxLines} líneas adicionales)');

    return previewLines.join('\n');
  }

  /// Valida el formato del archivo antes de exportar
  static List<String> validateExportFormat(DIOTBatch batch) {
    final errors = <String>[];

    // Validar que hay registros
    if (batch.records.isEmpty) {
      errors.add('No hay registros para exportar');
      return errors;
    }

    // Validar cada registro
    for (int i = 0; i < batch.records.length; i++) {
      final record = batch.records[i];
      final lineErrors = _validateRecordFormat(record, i + 1);
      errors.addAll(lineErrors);
    }

    // Validar estructura general
    if (batch.configuration.year < 2020) {
      errors.add('Año de configuración inválido');
    }

    if (batch.configuration.month < 1 || batch.configuration.month > 12) {
      errors.add('Mes de configuración inválido');
    }

    return errors;
  }

  /// Calcula estadísticas del archivo a exportar
  static DIOTExportStatistics calculateExportStatistics(DIOTBatch batch) {
    final validRecords = batch.records
        .where(
          (r) => r.validationErrors.isEmpty && !r.requiresUserInput,
        )
        .length;

    final totalValue = batch.records.fold<double>(
      0,
      (sum, record) =>
          sum +
          (record.valorActos16Porciento ?? 0) +
          (record.valorActosFronteraNorte ?? 0) +
          (record.valorActosFronteraSur ?? 0),
    );

    final totalIVA = batch.records.fold<double>(
      0,
      (sum, record) =>
          sum +
          (record.ivaAcreditableExclusivo16 ?? 0) +
          (record.ivaAcreditableProporcion16 ?? 0) +
          (record.ivaAcreditableExclusivoFronteraNorte ?? 0) +
          (record.ivaAcreditableProporcionFronteraNorte ?? 0) +
          (record.ivaAcreditableExclusivoFronteraSur ?? 0) +
          (record.ivaAcreditableProporcionFronteraSur ?? 0),
    );

    return DIOTExportStatistics(
      totalRecords: batch.records.length,
      validRecords: validRecords,
      invalidRecords: batch.records.length - validRecords,
      totalValue: totalValue,
      totalIVA: totalIVA,
      estimatedFileSize: _estimateFileSize(batch),
    );
  }

  /// Genera el contenido del archivo DIOT en formato pipe-delimited
  static String _generateDIOTContent(DIOTBatch batch) {
    final lines = <String>[];

    // Ordenar registros por RFC para consistencia
    final sortedRecords = List.from(batch.records)
      ..sort((a, b) => a.rfc.compareTo(b.rfc));

    // Generar línea para cada registro
    for (final record in sortedRecords) {
      lines.add(record.toPipeDelimitedString());
    }

    return lines.join('\n');
  }

  /// Selecciona la ruta de exportación
  static Future<String> _selectExportPath(DIOTBatch batch) async {
    // Generar nombre de archivo sugerido
    final year = batch.configuration.year;
    final month = batch.configuration.month.toString().padLeft(2, '0');
    final suggestedName = 'DIOT_${year}_$month.txt';

    // Usar file_picker para seleccionar ubicación
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar archivo DIOT',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result == null) {
      throw Exception('Operación cancelada por el usuario');
    }

    return result;
  }

  /// Valida el formato de un registro individual
  static List<String> _validateRecordFormat(DIOTRecord record, int lineNumber) {
    final errors = <String>[];

    // Validar campos requeridos según tipo de tercero
    switch (record.tipoTercero) {
      case TipoTercero.nacional:
        if (record.rfc.isEmpty) {
          errors
              .add('Línea $lineNumber: RFC requerido para proveedor nacional');
        }
        break;
      case TipoTercero.extranjero:
        if (record.numeroIdentificacionFiscal == null ||
            record.numeroIdentificacionFiscal!.isEmpty) {
          errors.add(
            'Línea $lineNumber: Número de identificación fiscal requerido',
          );
        }
        if (record.nombreExtranjero == null ||
            record.nombreExtranjero!.isEmpty) {
          errors.add('Línea $lineNumber: Nombre del extranjero requerido');
        }
        if (record.paisResidenciaFiscal == null ||
            record.paisResidenciaFiscal!.isEmpty) {
          errors.add('Línea $lineNumber: País de residencia fiscal requerido');
        }
        break;
      case TipoTercero.global:
        if (record.rfc != DIOTConstants.rfcProveedorGlobal) {
          errors.add(
            'Línea $lineNumber: RFC global debe ser ${DIOTConstants.rfcProveedorGlobal}',
          );
        }
        break;
    }

    // Validar longitudes de campos
    if (record.nombreExtranjero != null &&
        record.nombreExtranjero!.length >
            DIOTConstants.maxNombreExtranjeroLength) {
      errors.add('Línea $lineNumber: Nombre extranjero excede longitud máxima');
    }

    // Validar valores numéricos
    final numericFields = [
      record.valorActosFronteraNorte,
      record.valorActosFronteraSur,
      record.valorActos16Porciento,
      record.ivaAcreditableExclusivo16,
      record.ivaRetenido,
    ];

    for (final value in numericFields) {
      if ((value ?? 0) < 0) {
        errors.add(
          'Línea $lineNumber: Valores numéricos no pueden ser negativos',
        );
        break;
      }
      if ((value ?? 0) > DIOTConstants.maxNumericValue) {
        errors.add('Línea $lineNumber: Valor excede máximo permitido');
        break;
      }
    }

    return errors;
  }

  /// Estima el tamaño del archivo en bytes
  static int _estimateFileSize(DIOTBatch batch) {
    if (batch.records.isEmpty) return 0;

    // Calcular tamaño promedio de una línea
    final sampleLine = batch.records.first.toPipeDelimitedString();
    final avgLineSize = utf8.encode(sampleLine).length;

    // Estimar tamaño total (líneas + saltos de línea)
    return (avgLineSize + 1) * batch.records.length;
  }

  /// Crea archivo de log de exportación
  static Future<void> createExportLog(
    DIOTBatch batch,
    String exportPath,
    DIOTExportStatistics stats,
  ) async {
    final logPath = exportPath.replaceAll('.txt', '_log.txt');
    final logContent = _generateExportLog(batch, exportPath, stats);

    final logFile = File(logPath);
    await logFile.writeAsString(logContent, encoding: const Utf8Codec());
  }

  /// Genera contenido del log de exportación
  static String _generateExportLog(
    DIOTBatch batch,
    String exportPath,
    DIOTExportStatistics stats,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('=== LOG DE EXPORTACIÓN DIOT ===');
    buffer.writeln('Fecha de exportación: ${DateTime.now()}');
    buffer.writeln('Archivo generado: ${path.basename(exportPath)}');
    buffer.writeln(
      'Período: ${batch.configuration.month}/${batch.configuration.year}',
    );
    buffer.writeln('');

    buffer.writeln('=== ESTADÍSTICAS ===');
    buffer.writeln('Total de registros procesados: ${stats.totalRecords}');
    buffer.writeln('Registros válidos exportados: ${stats.validRecords}');
    buffer.writeln('Registros con errores: ${stats.invalidRecords}');
    buffer.writeln('Valor total: \$${stats.totalValue.toStringAsFixed(2)}');
    buffer.writeln('IVA total: \$${stats.totalIVA.toStringAsFixed(2)}');
    buffer.writeln('Tamaño estimado: ${stats.estimatedFileSize} bytes');
    buffer.writeln('');

    // Agregar errores si los hay
    if (batch.globalValidationErrors.isNotEmpty) {
      buffer.writeln('=== ERRORES GLOBALES ===');
      for (final error in batch.globalValidationErrors) {
        buffer
            .writeln('${error.severity.name.toUpperCase()}: ${error.message}');
      }
      buffer.writeln('');
    }

    // Agregar registros con errores
    final recordsWithErrors =
        batch.records.where((r) => r.validationErrors.isNotEmpty);
    if (recordsWithErrors.isNotEmpty) {
      buffer.writeln('=== REGISTROS CON ERRORES ===');
      for (final record in recordsWithErrors) {
        buffer.writeln('RFC: ${record.rfc}');
        for (final error in record.validationErrors) {
          buffer.writeln('  - ${error.message}');
        }
        buffer.writeln('');
      }
    }

    return buffer.toString();
  }
}

/// Estadísticas de exportación
class DIOTExportStatistics {
  final int totalRecords;
  final int validRecords;
  final int invalidRecords;
  final double totalValue;
  final double totalIVA;
  final int estimatedFileSize;

  const DIOTExportStatistics({
    required this.totalRecords,
    required this.validRecords,
    required this.invalidRecords,
    required this.totalValue,
    required this.totalIVA,
    required this.estimatedFileSize,
  });

  String get formattedFileSize {
    if (estimatedFileSize < 1024) {
      return '$estimatedFileSize bytes';
    } else if (estimatedFileSize < 1024 * 1024) {
      return '${(estimatedFileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(estimatedFileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
