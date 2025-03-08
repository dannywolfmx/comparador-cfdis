import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  /// Permite al usuario seleccionar un archivo XML
  static Future<File?> pickXmlFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
      dialogTitle: 'Seleccionar archivo CFDI (XML)',
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }

    return null;
  }

  /// Permite al usuario seleccionar múltiples archivos XML
  static Future<List<File>> pickMultipleXmlFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['xml'],
      dialogTitle: 'Seleccionar archivos CFDI (XML)',
    );

    if (result != null) {
      return result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();
    }

    return [];
  }

  /// Obtiene el nombre de un archivo sin extensión
  static String getFileNameWithoutExtension(File file) {
    String fileName = path.basename(file.path);
    return path.basenameWithoutExtension(fileName);
  }
}
