namespace Ecl.SsgConverter.Expressions {

  /// <summary>
  /// A primitive's type.
  /// </summary>
  public enum PrimitiveType {

    /// <summary>
    /// Symstream reserved global variable.
    /// </summary>
    /// <remarks>
    /// We would rather name this ReservedGlobalVariable as this is what
    /// the documentation calls it but apparently FxCop doesn't like it.
    /// </remarks>
    SystemVariable,

    /// <summary>
    /// Literal number.
    /// </summary>
    LiteralNumber,

    /// <summary>
    /// Literal string.
    /// </summary>
    LiteralString,

    /// <summary>
    /// Identifier.
    /// </summary>
    Identifier,

    /// <summary>
    /// Bracketed reference (SGS).
    /// </summary>
    BracketedReference
  }
} // namespace Ecl.SsgConverter.Expressions
