using System;

namespace Ecl.SsgConverter.Expressions {

  /// <summary>
  /// A Symstream literal value.
  /// </summary>
  public sealed class SymstreamExpressionPrimitive :SymstreamExpression {

    private String m_Image;
    private PrimitiveType m_PrimitiveType;

    /// <summary>
    /// Gets the primitive's text as found in the source code.
    /// </summary>
    public String Image { get { return m_Image; } }

    /// <summary>
    /// Gets the primitive's type.
    /// </summary>
    public PrimitiveType PrimitiveType { get { return m_PrimitiveType; } }

    /// <summary>
    /// Initializes a new instance of the SymstreamExpressionPrimitive class.
    /// </summary>
    /// <param name="image">The primitive's text as found in the source code.</param>
    /// <param name="type">The primitive's type.</param>
    public SymstreamExpressionPrimitive (String image, PrimitiveType type) {
      m_Image = image;
      m_PrimitiveType = type;
    } // Constructor SymstreamExpressionPrimitive
  } // Class SymstreamExpressionPrimitive
} // namespace Ecl.SsgConverter.Expressions
