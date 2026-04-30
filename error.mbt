///|
pub(all) enum KdlSeverity {
  Error
  Warning
} derive(Eq)

///|
pub impl Show for KdlSeverity with output(self, logger) {
  match self {
    Error => logger.write_string("Error")
    Warning => logger.write_string("Warning")
  }
}

///|
pub struct KdlDiagnostic {
  input : String
  span_start : Int
  span_len : Int
  message : String?
  label : String?
  help : String?
  severity : KdlSeverity
} derive(Eq)

///|
pub impl Show for KdlDiagnostic with output(self, logger) {
  logger.write_string("KdlDiagnostic { input: ")
  logger.write_object(self.input)
  logger.write_string(", span_start: ")
  logger.write_object(self.span_start)
  logger.write_string(", span_len: ")
  logger.write_object(self.span_len)
  logger.write_string(", message: ")
  logger.write_object(self.message)
  logger.write_string(", label: ")
  logger.write_object(self.label)
  logger.write_string(", help: ")
  logger.write_object(self.help)
  logger.write_string(", severity: ")
  logger.write_object(self.severity)
  logger.write_string(" }")
}

///|
pub fn KdlDiagnostic::new(
  input : String,
  span_start : Int,
  span_len : Int,
  message : String?,
  label : String?,
  help : String?,
  severity : KdlSeverity,
) -> KdlDiagnostic {
  { input, span_start, span_len, message, label, help, severity }
}

///|
pub struct KdlError {
  input : String
  diagnostics : Array[KdlDiagnostic]
} derive(Eq)

///|
pub impl Show for KdlError with output(self, logger) {
  logger.write_string("KdlError { input: ")
  logger.write_object(self.input)
  logger.write_string(", diagnostics: ")
  logger.write_object(self.diagnostics)
  logger.write_string(" }")
}

///|
pub fn KdlError::new(input : String) -> KdlError {
  { input, diagnostics: [] }
}

///|
pub fn KdlError::push(self : KdlError, diag : KdlDiagnostic) -> Unit {
  self.diagnostics.push(diag)
}

///|
pub fn KdlError::is_empty(self : KdlError) -> Bool {
  self.diagnostics.length() == 0
}
