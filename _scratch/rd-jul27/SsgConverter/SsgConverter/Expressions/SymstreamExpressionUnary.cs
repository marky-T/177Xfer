namespace Ecl.SsgConverter.Expressions {

  /// <summary>
  /// A Symstream unary expression (one with one operand).
  /// </summary>
  public sealed class SymstreamExpressionUnary :SymstreamExpression {

    private UnaryOperator m_UnaryOperator;
    private SymstreamExpression m_Operand;

    /// <summary>
    /// Gets the operator;
    /// </summary>
    public UnaryOperator UnaryOperator { get { return m_UnaryOperator; } }

    /// <summary>
    /// Gets the operand;
    /// </summary>
    public SymstreamExpression Operand { get { return m_Operand; } }

    /// <summary>
    /// Initializes a new instance of the SymstreamExpressionUnary class.
    /// </summary>
    /// <param name="unaryOperator">The operator.</param>
    /// <param name="operand">The operand.</param>
    public SymstreamExpressionUnary (UnaryOperator unaryOperator, SymstreamExpression operand) {

      m_UnaryOperator = unaryOperator;
      m_Operand = operand;
    } // Constructor SymstreamExpressionUnary
  } // Class SymstreamExpressionUnary
} // namespace Ecl.SsgConverter.Expressions
