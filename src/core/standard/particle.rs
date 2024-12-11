use std::time::Duration;

/// "Particle" is a general term which has distinct meanings in the various fields of science;
/// therefore, it is described in this program as a size-varied object which has a location in both
/// space and time and contains a combination of chemical and physical properties.
pub trait Particle<'a> {
  /// International Union of Pure and Applied Physics' (IUPAP) Commision on Symbols, Units,
  /// Nomenclature, Atomic Masses, and Fundamental Constants' (SUNAMCO) standardized symbol for this
  /// particle. It will be a Greek representation when applicable, resorting to a Latin-alphabet one
  /// when the prior does not have an UTF-8 equivalent.
  fn symbol() -> &'a str;

  /// Interval between the Big Bang and this particle's existence.
  fn time(&self) -> Duration;
}
