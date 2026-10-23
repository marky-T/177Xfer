namespace Ecl.SsgConverter {

  /// <summary>
  /// A type of SQL command.
  /// </summary>
  /// <remarks>
  /// Directives postfixed with [] may contain SGS which must be expanded before the directive is processed.
  /// </remarks>
  public enum DirectiveId {
    /// <summary>
    /// Not a Symstream directive.
    /// </summary>
    None,

    /// <summary>
    /// ABORT
    /// </summary>
    Abort,

    /// <summary>
    /// ACCEPT []
    /// </summary>
    Accept,

    /// <summary>
    /// ADD []
    /// </summary>
    Add,

    /// <summary>
    /// BRKPT []
    /// </summary>
    Brkpt,

    /// <summary>
    /// CLEAR []
    /// </summary>
    Clear,

    /// <summary>
    /// COPY
    /// </summary>
    Copy,

    /// <summary>
    /// CORRECT
    /// </summary>
    Correct,

    /// <summary>
    /// CREATE
    /// </summary>
    Create,

    /// <summary>
    /// CSF []
    /// </summary>
    Csf,

    /// <summary>
    /// DEFINE
    /// </summary>
    Define,

    /// <summary>
    /// DISPLAY []
    /// </summary>
    Display,

    /// <summary>
    /// DIVIDE
    /// </summary>
    Divide,

    /// <summary>
    /// DLOC []
    /// </summary>
    Dloc,

    /// <summary>
    /// DO
    /// </summary>
    Do,

    /// <summary>
    /// DUMP
    /// </summary>
    Dump,

    /// <summary>
    /// EDIT
    /// </summary>
    Edit,

    /// <summary>
    /// EJECT
    /// </summary>
    Eject,

    /// <summary>
    /// ELSE
    /// </summary>
    Else,

    /// <summary>
    /// ELSEIF
    /// </summary>
    ElseIf,

    /// <summary>
    /// ELSF (deprecated form of ELSE, still valid)
    /// </summary>
    Elsf,

    /// <summary>
    /// END (may be used instead of ENDIF (deprecated but still valid)
    /// </summary>
    End,

    /// <summary>
    /// ENDCORRECT
    /// </summary>
    EndCorrect,

    /// <summary>
    /// ENDDEFINE
    /// </summary>
    EndDefine,

    /// <summary>
    /// ENDDO
    /// </summary>
    EndDo,

    /// <summary>
    /// ENDIF
    /// </summary>
    EndIf,

    /// <summary>
    /// EXIT []
    /// </summary>
    Exit,

    /// <summary>
    /// IF
    /// </summary>
    If,

    /// <summary>
    /// INCREMENT
    /// </summary>
    Increment,

    /// <summary>
    /// ITERATE []
    /// </summary>
    Iterate,

    /// <summary>
    /// LIST
    /// </summary>
    List,

    /// <summary>
    /// LOOP
    /// </summary>
    Loop,

    /// <summary>
    /// MERGE
    /// </summary>
    Merge,

    /// <summary>
    /// MESSAGE []
    /// </summary>
    Message,

    /// <summary>
    /// MULTIPLY
    /// </summary>
    Multiply,

    /// <summary>
    /// PCONTROL []
    /// </summary>
    Pcontrol,

    /// <summary>
    /// PROCESS
    /// </summary>
    Process,

    /// <summary>
    /// REMOVE
    /// </summary>
    Remove,

    /// <summary>
    /// RESTORE []
    /// </summary>
    Restore,

    /// <summary>
    /// RETURN []
    /// </summary>
    Return,

    /// <summary>
    /// SAVE []
    /// </summary>
    Save,

    /// <summary>
    /// SET []
    /// </summary>
    Set,

    /// <summary>
    /// SORT []
    /// </summary>
    Sort,

    /// <summary>
    /// UNLIST
    /// </summary>
    Unlist,

    /// <summary>
    /// WAIT []
    /// </summary>
    Wait
  }
} // namespace Ecl.SsgConverter
