namespace Ecl.SsgConverter.Expressions {

  /// <summary>
  /// A Symstream binary expression (one with two operands).
  /// </summary>
  public sealed class SymstreamExpressionBinary :SymstreamExpression {

    private SymstreamExpression m_Left;
    private BinaryOperator m_BinaryOperator;
    private SymstreamExpression m_Right;

    /// <summary>
    /// Gets the left operand.
    /// </summary>
    public SymstreamExpression Left { get { return m_Left; } }

    /// <summary>
    /// Gets the operator.
    /// </summary>
    public BinaryOperator BinaryOperator { get { return m_BinaryOperator; } }

    /// <summary>
    /// Gets the right operand.
    /// </summary>
    public SymstreamExpression Right { get { return m_Right; } }

    /// <summary>
    /// Initializes a new instance of the SymstreamExpressionBinary class.
    /// </summary>
    /// <param name="left">The left operand.</param>
    /// <param name="binaryOperator">The operator.</param>
    /// <param name="right">The right operand.</param>
    public SymstreamExpressionBinary (SymstreamExpression left, BinaryOperator binaryOperator, SymstreamExpression right) {
      m_Left = left;
      m_BinaryOperator = binaryOperator;
      m_Right = right;
    } // Constructor SymstreamExpressionBinary
  } // Class SymstreamExpressionBinary
} // namespace Ecl.SsgConverter.Expressions
