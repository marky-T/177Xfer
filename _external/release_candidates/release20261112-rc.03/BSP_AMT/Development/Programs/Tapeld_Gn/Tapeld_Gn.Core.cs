using System.Diagnostics;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;
using Federale.BSP.BusinessLogic.Database;

namespace Federale.BSP.BusinessLogic.Tapeld_Gn {

  public sealed partial class Tapeld_Gn {
    #region Members
    private LocalDefinitions m_LocDef;
    private PrintDefinitions m_PrnDef;
    private QueryObjects m_Tables;
    #endregion Members

    #region Properties
    internal LocalDefinitions LocDef { [DebuggerStepThrough()] get { return m_LocDef; } }
    internal PrintDefinitions PrnDef { [DebuggerStepThrough()] get { return m_PrnDef; } }
    #endregion Properties

    public void Main () {
      Amt_Main();
    } // Main

    private void Amt_Main () {
    lab_Debut:
      OpenFile(Parmf, AmtCobolFileOpenMode.Input, false);
    lab_Parm_Lect:
      if (!ReadSequentialFile(Parmf, m_Fd_Parm_Rec)) {
        goto lab_Parm_Fin;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "IN") {
        m_LocDef.P_Inlen.IntValue = m_Fd_Parm_Len_Rec.Pl_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "OU") {
        m_LocDef.P_Outlen.IntValue = m_Fd_Parm_Len_Rec.Pl_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "MV") {
        m_LocDef.N_Mv.IntValue = m_LocDef.N_Mv.IntValue + 1;
        m_LocDef.Mv_Is[m_LocDef.N_Mv.IntValue].IntValue = m_Fd_Parm_Move_Rec.Pm_Is.IntValue;
        m_LocDef.Mv_Il[m_LocDef.N_Mv.IntValue].IntValue = m_Fd_Parm_Move_Rec.Pm_Il.IntValue;
        m_LocDef.Mv_Os[m_LocDef.N_Mv.IntValue].IntValue = m_Fd_Parm_Move_Rec.Pm_Os.IntValue;
        m_LocDef.Mv_Ol[m_LocDef.N_Mv.IntValue].IntValue = m_Fd_Parm_Move_Rec.Pm_Ol.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "FX") {
        m_LocDef.N_Fx.IntValue = m_LocDef.N_Fx.IntValue + 1;
        m_LocDef.Fx_Os[m_LocDef.N_Fx.IntValue].IntValue = m_Fd_Parm_Fixe_Rec.Px_Os.IntValue;
        m_LocDef.Fx_Len[m_LocDef.N_Fx.IntValue].IntValue = m_Fd_Parm_Fixe_Rec.Px_Len.IntValue;
        m_LocDef.Fx_Txt[m_LocDef.N_Fx.IntValue].Value = m_Fd_Parm_Fixe_Rec.Px_Txt.Value;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "ST") {
        m_LocDef.P_Stitre.StrValue = "Y";
      }
      goto lab_Parm_Lect;
    lab_Parm_Fin:
      CloseFile(Parmf);
      OpenFile(Tapein, AmtCobolFileOpenMode.Input, false);
      OpenPrintFile(m_PrnDef.Tapeout, 0);
    lab_Lect:
      m_Fd_Recout.Recout.StrValue = AmtConstRuntime.SpacesValueString;
      if (m_LocDef.P_Stitre.Value != 'Y' || m_LocDef.N_Fx.IntValue == 0) {
        goto lab_Lect_Read;
      }
      if (m_LocDef.Lnctr.IntValue <= 57) {
        goto lab_Lect_Read;
      }
      m_LocDef.I.IntValue = 1;
    lab_Title_Move:
      if (m_LocDef.I.IntValue > m_LocDef.N_Fx.IntValue) {
        goto lab_Title_Write;
      }
      m_Fd_Recout.Recout.Replace(m_LocDef.Fx_Os[m_LocDef.I.IntValue].ToInt32(), Substring(m_LocDef.Fx_Txt[m_LocDef.I.IntValue].Value, 1, m_LocDef.Fx_Len[m_LocDef.I.IntValue].IntValue), m_LocDef.Fx_Len[m_LocDef.I.IntValue].IntValue);
      m_LocDef.I.IntValue = m_LocDef.I.IntValue + 1;
      goto lab_Title_Move;
    lab_Title_Write:
      NewPage(m_Fd_Recout);
      PrintBuffer(m_PrnDef.Tapeout, null, m_Fd_Recout.Value);
      m_Fd_Recout.Recout.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Lnctr.IntValue = 5;
    lab_Lect_Read:
      m_LocDef.Recin.StrValue = AmtConstRuntime.SpacesValueString;
      if (!ReadSequentialFile(Tapein, m_Fd_Recin_Fd, m_LocDef.Recin)) {
        goto lab_Finw;
      }
      m_LocDef.Ws_In.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Cp_Len.IntValue = m_LocDef.Ws_In_Len.IntValue;
      if (m_LocDef.Cp_Len.IntValue > m_LocDef.P_Inlen.IntValue) {
        m_LocDef.Cp_Len.IntValue = m_LocDef.P_Inlen.IntValue;
      }
      if (m_LocDef.Cp_Len.IntValue > 0) {
        m_LocDef.Ws_In.Replace(1, Substring(m_LocDef.Recin.ToAlphaValue(), 1, m_LocDef.Cp_Len.IntValue), m_LocDef.Cp_Len.IntValue);
      }
      if (m_LocDef.N_Mv.IntValue == 0) {
        m_Fd_Recout.Recout.Value = Substring(m_LocDef.Ws_In.Value, 1, m_LocDef.P_Inlen.IntValue);
      }
      m_LocDef.I.IntValue = 1;
    lab_Mv_Loop:
      if (m_LocDef.I.IntValue > m_LocDef.N_Mv.IntValue) {
        goto lab_Mv_End;
      }
      m_Fd_Recout.Recout.Replace(m_LocDef.Mv_Os[m_LocDef.I.IntValue].ToInt32(), Substring(m_LocDef.Ws_In.ToAlphaValue(), m_LocDef.Mv_Is[m_LocDef.I.IntValue].IntValue, m_LocDef.Mv_Il[m_LocDef.I.IntValue].IntValue), m_LocDef.Mv_Ol[m_LocDef.I.IntValue].IntValue);
      m_LocDef.I.IntValue = m_LocDef.I.IntValue + 1;
      goto lab_Mv_Loop;
    lab_Mv_End:
      m_LocDef.Nb_Lus.IntValue = m_LocDef.Nb_Lus.IntValue + 1;
      m_LocDef.Lnctr.IntValue = m_LocDef.Lnctr.IntValue + 1;
      PrintBuffer(m_PrnDef.Tapeout, null, m_Fd_Recout.Value);
      goto lab_Lect;
    lab_Finw:
      OS2200.Display(NoTrunc("*CFH-COPY  FIN*"), true);
      OS2200.Display(NoTrunc("*NB-ENREG-LUS =") & NoTrunc(m_LocDef.Nb_Lus.ToAlphaValue()), true);
      CloseFile(Tapein);
      ClosePrintFile(m_PrnDef.Tapeout);
      OS2200.Display(NoTrunc(m_LocDef.Rec_Skipped.ToAlphaValue()), true);
      StopRun();
    } // Amt_Main

  } // Class Tapeld_Gn

} // Namespace Federale.BSP.BusinessLogic.Tapeld_Gn

