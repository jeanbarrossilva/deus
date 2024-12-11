use std::time::Duration;

use super::particle::Particle;

/// Subatomic, nucleon particle with a positive electronic charge of +1 e.
pub struct Proton {
  /// Interval between the Big Bang and this particle's existence.
  time: Duration
}

impl Proton {
  /// Instantiates a proton.
  ///
  /// # Arguments
  ///
  /// * `time` - Interval between the Big Bang and this particle's existence.
  pub fn new(time: Duration) -> Self {
    Proton { time }
  }
}

impl<'a> Particle<'a> for Proton {
  fn symbol() -> &'a str {
    "p"
  }

  fn time(&self) -> Duration {
    self.time
  }
}

#[cfg(test)]
mod tests {
  use std::time::Duration;

  use super::Proton;

  #[test]
  fn instantiates() {
    assert_eq!(Duration::ZERO, Proton::new(Duration::ZERO).time)
  }
}
