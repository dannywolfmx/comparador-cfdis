// Custom exceptions for better error handling
class CFDIException implements Exception {
  final String message;
  final String? code;
  
  const CFDIException(this.message, [this.code]);
  
  @override
  String toString() => 'CFDIException: $message${code != null ? ' (Code: $code)' : ''}';
}

class CFDIFileSystemException extends CFDIException {
  const CFDIFileSystemException(String message) : super(message, 'FS001');
}

class CFDIParseException extends CFDIException {
  const CFDIParseException(String message) : super(message, 'PARSE001');
}

class CFDIValidationException extends CFDIException {
  const CFDIValidationException(String message) : super(message, 'VALID001');
}

class CFDIGenericException extends CFDIException {
  const CFDIGenericException(String message) : super(message, 'GEN001');
}
