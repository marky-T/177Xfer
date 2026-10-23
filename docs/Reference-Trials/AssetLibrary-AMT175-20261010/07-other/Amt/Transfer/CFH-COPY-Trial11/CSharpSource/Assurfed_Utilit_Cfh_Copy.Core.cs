using System.Diagnostics;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;
using Company.AFBUS_2200COBOL.BusinessLogic.Database;

namespace Company.AFBUS_2200COBOL.BusinessLogic.Assurfed_Utilit_Cfh_Copy {

  public sealed partial class Assurfed_Utilit_Cfh_Copy {
    #region Members
    private LocalDefinitions m_LocDef;
    private QueryObjects m_Tables;
    #endregion Members

    #region Properties
    internal LocalDefinitions LocDef { [DebuggerStepThrough()] get { return m_LocDef; } }
    #endregion Properties

    public void Main () {
      Amt_Main();
    } // Main

    private void Amt_Main () {
    lab_Debut:
      OpenFile(Tapein, AmtCobolFileOpenMode.Input, false);
      OpenFile(Tapeout, AmtCobolFileOpenMode.Output, false);
    lab_Lect:
      m_Fd_Recout.Recout.StrValue = AmtConstRuntime.SpacesValueString;
      if (!ReadSequentialFile(Tapein, m_Fd_Recin)) {
        goto lab_Finw;
      }
      m_Fd_Recout.Recout.Value = m_Fd_Recin.Recin.Value;
      m_LocDef.Nb_Lus.IntValue = m_LocDef.Nb_Lus.IntValue + 1;
      WriteSequentialFile(Tapeout, m_Fd_Recout);
      goto lab_Lect;
    lab_Finw:
      OS2200.Display(NoTrunc("*CFH-COPY  FIN*"), true);
      OS2200.Display(NoTrunc("*NB-ENREG-LUS =") & NoTrunc(m_LocDef.Nb_Lus.ToAlphaValue()), true);
      CloseFile(Tapein);
      CloseFile(Tapeout);
      OS2200.Display(NoTrunc(m_LocDef.Rec_Skipped.ToAlphaValue()), true);
      StopRun();
    } // Amt_Main

  } // Class Assurfed_Utilit_Cfh_Copy

} // Namespace Company.AFBUS_2200COBOL.BusinessLogic.Assurfed_Utilit_Cfh_Copy

