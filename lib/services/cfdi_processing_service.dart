import 'dart:isolate';
import 'dart:io';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/services/cfdi_parser.dart';
import 'package:comparador_cfdis/constants/app_constants.dart';

class CFDIProcessingService {
  static Future<List<CFDI>> processCFDIsInIsolate(List<String> filePaths) async {
    final receivePort = ReceivePort();
    
    await Isolate.spawn(
      _processCFDIsInBackground,
      {
        'sendPort': receivePort.sendPort,
        'filePaths': filePaths,
      },
    );
    
    return await receivePort.first as List<CFDI>;
  }
  
  static void _processCFDIsInBackground(Map<String, dynamic> params) async {
    final sendPort = params['sendPort'] as SendPort;
    final filePaths = params['filePaths'] as List<String>;
    
    final List<CFDI> cfdis = [];
    
    for (final filePath in filePaths) {
      try {
        final file = File(filePath);
        final cfdi = await CFDIParser.parseXmlFile(file);
        if (cfdi != null) {
          cfdis.add(cfdi);
        }
      } catch (e) {
        // Log error but continue processing
        print('Error processing file $filePath: $e');
      }
    }
    
    sendPort.send(cfdis);
  }
  
  // Procesar CFDIs en lotes para evitar sobrecarga de memoria
  static Future<List<CFDI>> processInBatches(
    List<String> filePaths, {
    int batchSize = 20,
  }) async {
    final List<CFDI> allCfdis = [];
    
    for (int i = 0; i < filePaths.length; i += batchSize) {
      final batch = filePaths.skip(i).take(batchSize).toList();
      final batchCfdis = await processCFDIsInIsolate(batch);
      allCfdis.addAll(batchCfdis);
      
      // Pequeña pausa para permitir que la UI responda
      await Future.delayed(const Duration(milliseconds: 10));
    }
    
    return allCfdis;
  }
  
  // Método para validar archivos antes de procesarlos
  static Future<List<String>> validateFiles(List<String> filePaths) async {
    final validFiles = <String>[];
    
    for (final filePath in filePaths) {
      final file = File(filePath);
      if (await file.exists() && 
          filePath.toLowerCase().endsWith(AppConstants.xmlExtension)) {
        // Verificar que el archivo no esté vacío
        final stat = await file.stat();
        if (stat.size > 0) {
          validFiles.add(filePath);
        }
      }
    }
    
    return validFiles;
  }
}
