using System;
using System.Collections.Generic;
using System.IO;

namespace Ecl.SsgConverter {

  /// <summary>
  /// The set of input parameters for a Symstream skeleton.
  /// </summary>
  public sealed class StreamGenerationStatements {

    /// <summary>
    /// The raw list of SGS data.
    /// </summary>
    private List<String> m_Lines = new List<String>();

    /// <summary>
    /// Initializes a new instance of the SymstreamInterpreter class.
    /// </summary>
    /// <param name="lines">The raw list of SGS data.</param>
    public StreamGenerationStatements (IReadOnlyList<String> lines) {
      m_Lines.AddRange(lines);
    } // Constructor StreamGenerationStatements

    /// <summary>
    /// Initializes a new instance of the SymstreamInterpreter class.
    /// </summary>
    /// <param name="sgsFilePath">The file system path to the file containing the SGS data.</param>
    public StreamGenerationStatements (String sgsFilePath) {
      // open & read SGS data
      String[] lines = File.ReadAllLines(sgsFilePath);
      m_Lines.AddRange(lines);
    } // Constructor StreamGenerationStatements

    /// <summary>
    /// Gets the number of occurrences of the specified label.
    /// </summary>
    /// <param name="label">The label for which to count the number of occurrences.</param>
    /// <returns>The number of occurrences of the specified label.</returns>
    public Int32 this[String label] {
      get {
        Int32 n = 0;
        foreach (String line in m_Lines) {
          if (line.StartsWith(label, StringComparison.OrdinalIgnoreCase)) {
            n++;
          }
        }
        return n;
      }
    }

    /// <summary>
    /// Gets the number of fields following the nth occurrence of the specified label.
    /// </summary>
    /// <param name="label">The name of the label for which to count the number of fields.</param>
    /// <param name="n">The 1-based index of the label for which to count the number of fields.</param>
    /// <returns>The number of fields following the specified label.</returns>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1023:IndexersShouldNotBeMultidimensional", Justification = "This nicely matches the original use of SGS labels.")]
    public Int32 this[String label, Int32 n] {
      get {
        Int32 i = 0;
        String theLine = null;
        foreach (String line in m_Lines) {
          if (line.StartsWith(label, StringComparison.OrdinalIgnoreCase)) {
            i++;
            if (i == n) {
              theLine = line;
              break;
            }
          }
        }

        if (!String.IsNullOrEmpty(theLine)) {
          String[] parts = theLine.Split(null);
          return parts.Length - 1;
        }

        return 0;
      }
    }

    /// <summary>
    /// Gets the number of subfields in the specified field.
    /// </summary>
    /// <param name="label">The name of the label for which to count the number of subfields.</param>
    /// <param name="n">The 1-based index of the label for which to count the number of subfields.</param>
    /// <param name="f">The 1-based index of the field for which to count the number of subfields.</param>
    /// <returns>The number of subfields in the specified field.</returns>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1023:IndexersShouldNotBeMultidimensional", Justification = "This nicely matches the original use of SGS labels.")]
    public Int32 this[String label, Int32 n, Int32 f] {
      get {
        Int32 i = 0;
        String theLine = null;
        foreach (String line in m_Lines) {
          if (line.StartsWith(label, StringComparison.OrdinalIgnoreCase)) {
            i++;
            if (i == n) {
              theLine = line;
              break;
            }
          }
        }

        if (!String.IsNullOrEmpty(theLine)) {
          String[] parts = theLine.Split(null);
          if (parts.Length > f) {
            parts = parts[f - 1].Split(',');
            return parts.Length;
          }
        }

        return 0;
      }
    }

    /// <summary>
    /// Gets or sets the contents of the specified subfield.
    /// </summary>
    /// <param name="label">The name of the label for which to address the subfield.</param>
    /// <param name="n">The 1-based index of the label for which to address the subfield.</param>
    /// <param name="f">The 1-based index of the field for which to address the subfield.</param>
    /// <param name="s">The 1-based index of the subfield for which to obtain the contents.</param>
    /// <returns>The contents of the specified subfield.</returns>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1023:IndexersShouldNotBeMultidimensional", Justification = "This nicely matches the original use of SGS labels.")]
    public String this[String label, Int32 n, Int32 f, Int32 s] {

      get {
        if (String.IsNullOrEmpty(label)) {
          throw new ArgumentNullException(nameof(label));
        }

        if (s < 1) {
          throw new ArgumentOutOfRangeException(nameof(s));
        }

        Int32 i = 0;
        String theLine = null;
        foreach (String line in m_Lines) {
          if (line.StartsWith(label, StringComparison.OrdinalIgnoreCase)) {
            i++;
            if (i == n) {
              theLine = line;
              break;
            }
          }
        }

        if (!String.IsNullOrEmpty(theLine)) {
          String[] fields = theLine.Split(null);
          if (fields.Length > f) {
            String[] subfields = fields[f].Split(',');
            return subfields[s - 1];
          }
        }

        return String.Empty;
      }

      set {
        if (String.IsNullOrEmpty(label)) {
          throw new ArgumentNullException(nameof(label));
        }

        if (s < 1) {
          throw new ArgumentOutOfRangeException(nameof(s));
        }

        Int32 lineIndex = 0;
        Int32 labelIndex = 0;
        String theLine = null;
        for (; lineIndex < m_Lines.Count; lineIndex++) {
          if (m_Lines[lineIndex].StartsWith(label, StringComparison.OrdinalIgnoreCase)) {
            labelIndex++;
            if (labelIndex == n) {
              theLine = m_Lines[lineIndex].Trim();
              break;
            }
          }
        }

        if (String.IsNullOrEmpty(theLine)) {
          throw new SymstreamException(String.Format("No SGS label \"{0}\" with index {1} exists.", label, n));
        }

        String[] fields = theLine.Split(null);
        if (fields.Length > f) {
          String[] subfields = fields[f].Split(',');
          subfields[s - 1] = value;

          // rebuild field
          String modifiedField = subfields[0];
          for (Int32 i = 1; i < subfields.Length; i++) {
            modifiedField += ", " + subfields[i];
          }

          fields[f] = modifiedField;

          // rebuild line
          String modifiedLine = label.ToUpperInvariant();
          foreach (String field in fields) {
            modifiedLine += " " + field;
          }

          m_Lines[lineIndex] = modifiedLine;
        }
      }
    }

    /// <summary>
    /// Returns the value identified by the provided comma delimited string which may be bracketed.
    /// </summary>
    /// <param name="s">A comma delimited string, possibly enclosed in brackets.</param>
    /// <returns>The value identified by the provided string.</returns>
    public String GetValueFromBracketedString (String s) {

      if (s == null) {
        throw new ArgumentNullException(nameof(s));
      }

      s = s.Trim('[', ']');
      String[] splitIndexes = s.Split(',');
      if (splitIndexes.Length > 4) {
        throw new SymstreamException("Extended SGS subfield references are not supported.");
      } else if (splitIndexes.Length > 3) {
        return this[splitIndexes[0], Int32.Parse(splitIndexes[1]), Int32.Parse(splitIndexes[2]), Int32.Parse(splitIndexes[3])];
      } else if (splitIndexes.Length > 2) {
        return this[splitIndexes[0], Int32.Parse(splitIndexes[1]), Int32.Parse(splitIndexes[2])].ToString();
      } else if (splitIndexes.Length > 1) {
        return this[splitIndexes[0], Int32.Parse(splitIndexes[1])].ToString();
      } else {
        return this[splitIndexes[0]].ToString();
      }
    } // GetValueFromBracketedString

    /// <summary>
    /// Adds extra lines to the raw collection.
    /// </summary>
    /// <param name="newLines">The lines to be added.</param>
    public void Add (IReadOnlyList<String> newLines) {
      m_Lines.AddRange(newLines);
    } // Add
  } // Class StreamGenerationStatements
} // namespace Ecl.SsgConverter
