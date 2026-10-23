using System;
using System.Runtime.Serialization;

namespace Ecl.SsgConverter {

  /// <summary>
  /// The exception that is thrown when a input operation fails.
  /// </summary>
  [Serializable]
  public class SymstreamException :Exception {

    /// <summary>
    /// Initializes a new instance of the SymstreamException class.
    /// </summary>
    public SymstreamException () {
      // This makes CodeAnalysis happy.
    } // Constructor SymstreamException

    /// <summary>
    /// Initializes a new instance of the SymstreamException class.
    /// </summary>
    /// <param name="message">The message that describes the issue.</param>
    public SymstreamException (String message)
      : base(message) {
    } // Constructor SymstreamException

    /// <summary>
    /// Initializes a new instance of the SymstreamException class.
    /// </summary>
    /// <param name="message">The message that describes the issue.</param>
    /// <param name="innerException">The exception that caused the current exception or null of there is none.</param>
    public SymstreamException (String message, Exception innerException)
      : base(message, innerException) {
    } // Constructor SymstreamException

  } // Class SymstreamException
} // namespace Ecl.SsgConverter
