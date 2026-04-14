// Minimal stubs used when the real `meta` and `super_annotations`
// packages are not yet available. They provide just enough types for the
// annotation library to compile.

/// Dummy immutable annotation – does nothing at runtime.
class Immutable {
  const Immutable();
}

/// Abstract base class mimicking `ClassAnnotation` from `super_annotations`.
/// The real package provides richer functionality, but for compilation we only
/// need the `apply` method signature.
abstract class ClassAnnotation {
  void apply(Object target, Object output);
}

/// Placeholder for a class description used by `apply`.
class Class {}

/// Placeholder for a library builder used by `apply`.
class LibraryBuilder {}
