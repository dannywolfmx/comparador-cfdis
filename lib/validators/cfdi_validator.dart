import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/constants/app_constants.dart';

class CFDIValidator {
  static ValidationResult validateCFDI(CFDI cfdi) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // Validar campos obligatorios
    if (cfdi.version == null || cfdi.version!.isEmpty) {
      errors.add('La versión del CFDI es obligatoria');
    }
    
    if (cfdi.fecha == null || cfdi.fecha!.isEmpty) {
      errors.add('La fecha del CFDI es obligatoria');
    }
    
    if (cfdi.total == null || cfdi.total!.isEmpty) {
      errors.add('El total del CFDI es obligatorio');
    }
    
    // Validar RFC del emisor
    if (cfdi.emisor?.rfc != null) {
      if (!_isValidRFC(cfdi.emisor!.rfc!)) {
        errors.add('El RFC del emisor no es válido: ${cfdi.emisor!.rfc}');
      }
    } else {
      errors.add('El RFC del emisor es obligatorio');
    }
    
    // Validar RFC del receptor
    if (cfdi.receptor?.rfc != null) {
      if (!_isValidRFC(cfdi.receptor!.rfc!)) {
        errors.add('El RFC del receptor no es válido: ${cfdi.receptor!.rfc}');
      }
    } else {
      errors.add('El RFC del receptor es obligatorio');
    }
    
    // Validar UUID
    if (cfdi.timbreFiscalDigital?.uuid != null) {
      if (!_isValidUUID(cfdi.timbreFiscalDigital!.uuid!)) {
        errors.add('El UUID no es válido: ${cfdi.timbreFiscalDigital!.uuid}');
      }
    } else {
      warnings.add('El UUID del timbre fiscal no está presente');
    }
    
    // Validar montos
    if (cfdi.total != null && cfdi.subTotal != null) {
      try {
        final total = double.parse(cfdi.total!);
        final subTotal = double.parse(cfdi.subTotal!);
        
        if (total < subTotal) {
          errors.add('El total no puede ser menor al subtotal');
        }
      } catch (e) {
        errors.add('Error al validar montos: formato numérico inválido');
      }
    }
    
    // Validar tipo de comprobante
    if (cfdi.tipoDeComprobante != null) {
      if (!_isValidTipoComprobante(cfdi.tipoDeComprobante!)) {
        warnings.add('Tipo de comprobante no reconocido: ${cfdi.tipoDeComprobante}');
      }
    }
    
    // Validar moneda
    if (cfdi.moneda != null && cfdi.moneda != AppConstants.defaultCurrency) {
      if (cfdi.tipoCambio == null || cfdi.tipoCambio!.isEmpty) {
        warnings.add('Se requiere tipo de cambio para moneda extranjera');
      }
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  static bool _isValidRFC(String rfc) {
    if (rfc.length < AppConstants.minRfcLength || 
        rfc.length > AppConstants.maxRfcLength) {
      return false;
    }
    
    // Patrón básico de RFC (puede ser mejorado)
    final rfcPattern = RegExp(r'^[A-Z&Ñ]{3,4}[0-9]{6}[A-Z0-9]{3}$');
    return rfcPattern.hasMatch(rfc);
  }
  
  static bool _isValidUUID(String uuid) {
    if (uuid.length != AppConstants.uuidLength) {
      return false;
    }
    
    final uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidPattern.hasMatch(uuid);
  }
  
  static bool _isValidTipoComprobante(String tipo) {
    const validTypes = ['I', 'E', 'T', 'N', 'P'];
    return validTypes.contains(tipo.toUpperCase());
  }
  
  static List<ValidationResult> validateCFDIList(List<CFDI> cfdis) {
    return cfdis.map((cfdi) => validateCFDI(cfdi)).toList();
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  
  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
  
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}
