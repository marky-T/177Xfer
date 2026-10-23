using System;
using System.Collections.Generic;
using PowerShell.Generator;

namespace Ecl.SsgConverter {

  /// <summary>
  /// Interface for converting non-directive content lines found within SSG templates.
  /// The SsgConverter delegates blocks of content lines (ECL, SQL, JCL, etc.) to an
  /// implementation of this interface for project-specific conversion.
  /// </summary>
  public interface IContentLineConverter {

    /// <summary>
    /// Converts a block of content lines to a PowerShell instruction block.
    /// </summary>
    /// <param name="lines">The raw content lines (may contain SSG variable references like [*VAR]).</param>
    /// <param name="containingFile">The name of the SSG file being processed (for diagnostics).</param>
    /// <returns>A PowerShell AST instruction block, or null if the lines could not be converted.</returns>
    PsAstInstrBlock Convert(IReadOnlyList<String> lines, String containingFile);
  }
}
