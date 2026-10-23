namespace Ecl.SsgConverter.Expressions {

  /// <summary>
  /// What is to be searched according to a search conditional expression.
  /// </summary>
  public enum SearchObject {

    /// <summary>
    /// Look in a row for an occurrence of the value that results from the FOR expression.
    /// </summary>
    Row,

    /// <summary>
    /// Look in a column for an occurrence of the value that results from the FOR expression.
    /// </summary>
    Column,

    /// <summary>
    /// Look in a particular subfield of any field in a particular row for
    /// an occurrence of the value that results from the FOR expression.
    /// </summary>
    Keyword
  }
} // namespace Ecl.SsgConverter.Expressions
