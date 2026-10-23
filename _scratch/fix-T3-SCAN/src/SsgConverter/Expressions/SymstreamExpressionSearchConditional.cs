using System;

namespace Ecl.SsgConverter.Expressions {

  /// <summary>
  /// A Symstream search conditional expression.
  /// </summary>
  public sealed class SymstreamExpressionSearchConditional :SymstreamExpression {

    private SearchObject m_SearchObject;
    private SearchDirection m_SearchDirection;
    private String m_FromClause;
    private String m_ForExpression;
    private String m_Comments;
    private SymstreamExpression m_ForExpressionObject = null;

    /// <summary>
    /// Gets the search object.
    /// </summary>
    public SearchObject SearchObject { get { return m_SearchObject; } }

    /// <summary>
    /// Gets the search direction.
    /// </summary>
    public SearchDirection SearchDirection { get { return m_SearchDirection; } }

    /// <summary>
    /// Gets the FROM clause.
    /// </summary>
    public String FromClause { get { return m_FromClause; } }

    /// <summary>
    /// Gets the FOR expression.
    /// </summary>
    public String ForExpression { get { return m_ForExpression; } }

    /// <summary>
    /// Gets the (optional) comments.
    /// </summary>
    public String Comments { get { return m_Comments; } }

    /// <summary>
    /// Gets or sets the FOR expression as a SymstreamExpression object
    /// (to be assigned by the expression parser).
    /// </summary>
    public SymstreamExpression ForExpressionObject { get { return m_ForExpressionObject; } set { m_ForExpressionObject = value; } }

    /// <summary>
    /// Initializes a new instance of the SymstreamExpressionSearchConditional class.
    /// </summary>
    /// <param name="text">The search conditional as text.</param>
    public SymstreamExpressionSearchConditional (String text) {

      if (String.IsNullOrEmpty(text)) {
        throw new ArgumentNullException(nameof(text));
      }

      // Format:
      //   {ROW|COLUMN|KEYWORD} SEARCH ({ASC|ASCENDING|DESC|DESCENDING})
      //     FROM label(,start-stmt)(,start-field)(,start-subfield) FOR expression

      // search object
      if (text.StartsWith("ROW ", StringComparison.OrdinalIgnoreCase)) {
        m_SearchObject = Expressions.SearchObject.Row;
      } else if (text.StartsWith("COLUMN ", StringComparison.OrdinalIgnoreCase)) {
        m_SearchObject = Expressions.SearchObject.Column;
      } else if (text.StartsWith("KEYWORD ", StringComparison.OrdinalIgnoreCase)) {
        m_SearchObject = Expressions.SearchObject.Keyword;
      } else {
        throw new SymstreamException(String.Format("Expected ROW, COLUMN or KEYWORD at start of search conditional:\r\n{0}.", text));
      }

      // search direction
      m_SearchDirection = Expressions.SearchDirection.Ascending;
      if (text.IndexOf(" DESC", StringComparison.OrdinalIgnoreCase) > -1 || text.IndexOf(" DESCENDING", StringComparison.OrdinalIgnoreCase) > -1) {
        m_SearchDirection = Expressions.SearchDirection.Descending;
      }

      // FROM clause & FOR expression
      Int32 firstFrom = text.IndexOf(" FROM ", StringComparison.OrdinalIgnoreCase);
      if (firstFrom > -1) {
        String fromClauseAndForExpression = text.Substring(firstFrom + 6).Trim();
        Int32 firstFor = fromClauseAndForExpression.IndexOf(" FOR ", StringComparison.OrdinalIgnoreCase);
        if (firstFor > -1) {
          m_FromClause = fromClauseAndForExpression.Substring(0, firstFor);
          String forExpressionAndComments = fromClauseAndForExpression.Substring(firstFor + 5).Trim();
          Int32 firstPeriod = forExpressionAndComments.IndexOf(".");
          if (firstPeriod > -1) {
            // there is some comment text
            m_ForExpression = forExpressionAndComments.Substring(0, firstPeriod).Trim();
            m_Comments = forExpressionAndComments.Substring(firstPeriod + 1).Trim();
          } else {
            m_ForExpression = forExpressionAndComments.Trim();
            m_Comments = String.Empty;
          }
        } else {
          throw new SymstreamException(String.Format("Missing FOR expression in search conditional:\r\n{0}.", text));
        }
      } else {
        throw new SymstreamException(String.Format("Missing FROM clause in search conditional:\r\n{0}.", text));
      }
    } // Constructor SymstreamExpressionSearchConditional
  } // Class SymstreamExpressionSearchConditional
} // namespace Ecl.SsgConverter.Expressions
