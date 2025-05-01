import 'dart:io';
import 'package:comparador_cfdis/utils/log.dart';
import 'package:logger/logger.dart';
import 'package:xml/xml.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../models/cfdi.dart';

class CFDIParser {
  //Logger
  static final _logger = Logger();

  // Namespace prefijos comunes en CFDI
  static const Map<String, String> _namespaces = {
    'cfdi': 'http://www.sat.gob.mx/cfd/4',
    'tfd': 'http://www.sat.gob.mx/TimbreFiscalDigital',
    'pago10': 'http://www.sat.gob.mx/Pagos',
    'pago20': 'http://www.sat.gob.mx/Pagos20',
    'nomina12': 'http://www.sat.gob.mx/nomina12',
  };

  /// Parsea un archivo XML a un objeto CFDI
  static Future<CFDI?> parseXmlFile(File file) async {
    try {
      final content = await file.readAsString();
      final document = XmlDocument.parse(content);
      final jsonData = xmlToJson(document);
      return CFDI.fromJson(jsonData, filePath: file.path);
    } catch (e) {
      _logger.e('Error al parsear XML a CFDI: $e');
      return null;
    }
  }

  /// Parsea una cadena XML a un objeto CFDI
  static CFDI? parseXmlString(String xmlString, {String? filePath}) {
    try {
      final document = XmlDocument.parse(xmlString);
      final jsonData = xmlToJson(document);
      return CFDI.fromJson(jsonData, filePath: filePath);
    } catch (e) {
      _logger.e('Error al parsear XML a CFDI: $e');
      return null;
    }
  }

  /// Convierte un documento XML a un Map<String, dynamic> (JSON)
  static Map<String, dynamic> xmlToJson(XmlDocument document) {
    // Encuentra el elemento raíz del CFDI
    final comprobante =
        findElementWithNamespace(document.rootElement, 'cfdi:Comprobante') ??
            document.rootElement;

    // Convertir el comprobante a JSON
    Map<String, dynamic> json = _processElement(comprobante);

    // Asegurarse de que la versión esté presente en el nivel superior
    if (comprobante.getAttribute('version') != null &&
        !json.containsKey('Version')) {
      json['Version'] = comprobante.getAttribute('version');
    } else if (comprobante.getAttribute('Version') != null &&
        !json.containsKey('Version')) {
      json['Version'] = comprobante.getAttribute('Version');
    }

    // Buscar y añadir TimbreFiscalDigital si existe
    // Primero buscamos el complemento que contiene el TimbreFiscalDigital
    final complemento = findElementWithName(comprobante, 'Complemento');

    if (complemento != null) {
      // Buscamos el TimbreFiscalDigital dentro del complemento
      final tfd =
          findElementWithNamespace(complemento, 'tfd:TimbreFiscalDigital');

      if (tfd != null) {
        json['TimbreFiscalDigital'] = _processElement(tfd);
      } else {
        // Si no lo encontramos con namespace, intentamos buscarlo por el nombre local
        final tfdAlt = findElementWithName(complemento, 'TimbreFiscalDigital');
        if (tfdAlt != null) {
          json['TimbreFiscalDigital'] = _processElement(tfdAlt);
        }
      }
    } else {
      // Si no hay complemento, intentamos buscar directamente en todo el documento
      final tfd = findElementWithNamespace(
          document.rootElement, 'tfd:TimbreFiscalDigital');
      if (tfd != null) {
        json['TimbreFiscalDigital'] = _processElement(tfd);
      } else {
        // Búsqueda recursiva en todo el documento
        final tfdRecursive =
            findElementRecursive(document.rootElement, 'TimbreFiscalDigital');
        if (tfdRecursive != null) {
          json['TimbreFiscalDigital'] = _processElement(tfdRecursive);
        }
      }
    }

    return json;
  }

  /// Encuentra un elemento con un namespace específico
  static XmlElement? findElementWithNamespace(
      XmlElement element, String qualifiedName) {
    if (element.qualifiedName == qualifiedName) {
      return element;
    }

    for (var child in element.childElements) {
      final found = findElementWithNamespace(child, qualifiedName);
      if (found != null) {
        return found;
      }
    }

    return null;
  }

  /// Encuentra un elemento por su nombre local (sin namespace)
  static XmlElement? findElementWithName(XmlElement element, String localName) {
    // Buscar en este elemento
    if (element.name.local == localName) {
      return element;
    }

    // Buscar en hijos directos
    for (var child in element.childElements) {
      if (child.name.local == localName) {
        return child;
      }
    }

    // Buscar recursivamente en los hijos
    for (var child in element.childElements) {
      final result = findElementWithName(child, localName);
      if (result != null) {
        return result;
      }
    }

    return null;
  }

  /// Busca recursivamente un elemento con el nombre dado en cualquier nivel del documento
  static XmlElement? findElementRecursive(
      XmlElement element, String localName) {
    // Comprobar si este elemento tiene el nombre buscado
    if (element.name.local == localName) {
      return element;
    }

    // Buscar en todos los hijos recursivamente
    for (var child in element.childElements) {
      final found = findElementRecursive(child, localName);
      if (found != null) {
        return found;
      }
    }

    return null;
  }

  /// Procesa un elemento XML y sus atributos
  static Map<String, dynamic> _processElement(XmlElement element) {
    Map<String, dynamic> result = {};
    Map<String, List<Map<String, dynamic>>> nodeLists = {};

    // Procesa atributos
    for (var attribute in element.attributes) {
      String name = attribute.name.local;
      // Convertir el nombre del atributo a formato PascalCase como en el CFDI
      name = name[0].toUpperCase() + name.substring(1);
      result[name] = attribute.value;
    }

    // Procesa elementos hijos
    for (var child in element.childElements) {
      String name = child.name.local;
      name = name[0].toUpperCase() + name.substring(1);

      final childData = _processElement(child);

      // Verificar si ya existe un nodo con este nombre
      if (result.containsKey(name)) {
        // Si ya existe, convertirlo a una lista si aún no lo es
        if (nodeLists.containsKey(name)) {
          nodeLists[name]!.add(childData);
        } else {
          // Crear una nueva lista con el elemento existente y el nuevo
          nodeLists[name] = [result[name] as Map<String, dynamic>, childData];
          // Reemplazar el elemento en result con la lista
          result[name] = nodeLists[name];
        }
      } else {
        // Para elementos normales que aparecen por primera vez
        result[name] = childData;
      }
    }

    // Si este elemento es TimbreFiscalDigital y no tiene UUID, intenta usar el valor textual
    if (element.name.local == 'TimbreFiscalDigital' &&
        !result.containsKey('UUID')) {
      final text = element.innerText.trim();
      if (text.isNotEmpty) {
        result['UUID'] = text;
      }
    }

    return result;
  }

  /// Permite al usuario seleccionar archivos XML y los convierte a CFDIs
  static Future<List<CFDI>> pickAndParseXmls() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
      allowMultiple: true,
    );

    List<CFDI> cfdis = [];

    if (result != null) {
      for (var fileInfo in result.files) {
        if (fileInfo.path != null) {
          final file = File(fileInfo.path!);
          final cfdi = await parseXmlFile(file);
          if (cfdi != null) {
            cfdis.add(cfdi);
          }
        }
      }
    }

    return cfdis;
  }

  /// Permite al usuario seleccionar un directorio y parsea todos los XML dentro
  static Future<List<CFDI>> parseDirectoryCFDIs() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return [];
    }

    final directory = Directory(selectedDirectory);
    final List<CFDI> cfdis = [];

    try {
      final files = directory.listSync().where((entity) =>
          entity is File &&
          path.extension(entity.path).toLowerCase() == '.xml');

      for (var file in files) {
        final cfdi = await parseXmlFile(file as File);
        if (cfdi != null) {
          cfdis.add(cfdi);
        }
      }
    } catch (e) {
      Log.logError('Error al leer los archivos XML del directorio: $e');
    }

    return cfdis;
  }
}
