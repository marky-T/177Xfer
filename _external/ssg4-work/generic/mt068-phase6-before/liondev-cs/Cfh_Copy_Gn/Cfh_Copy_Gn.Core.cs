using System.Diagnostics;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Support;
using Asysco.Amt.Runtime.Vars;
using Company.AFBUS_2200COBOL.BusinessLogic.Database;

namespace Company.AFBUS_2200COBOL.BusinessLogic.Cfh_Copy_Gn {

  public sealed partial class Cfh_Copy_Gn {
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
      OpenFile(Parmf, AmtCobolFileOpenMode.Input, false);
    lab_Parm_Lect:
      if (!ReadSequentialFile(Parmf, m_Fd_Parm_Rec)) {
        goto lab_Parm_Fin;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "IN") {
        m_LocDef.Ws_Inname.Value = m_Fd_Parm_File_Rec.Pf_Name.Value;
        m_LocDef.P_Inlen.IntValue = m_Fd_Parm_File_Rec.Pf_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "OU") {
        m_LocDef.Ws_Outname.Value = m_Fd_Parm_File_Rec.Pf_Name.Value;
        m_LocDef.P_Outlen.IntValue = m_Fd_Parm_File_Rec.Pf_Len.IntValue;
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
      if (m_Fd_Parm_Rec.P_Type.Value == "SK") {
        m_LocDef.P_Skip.IntValue = m_Fd_Parm_Skip_Rec.Ps_N.IntValue;
      }
      goto lab_Parm_Lect;
    lab_Parm_Fin:
      CloseFile(Parmf);
      m_LocDef.Ix_In.IntValue = 1;
      m_LocDef.Ix_Out.IntValue = 1;
    lab_Find_In:
      if (m_LocDef.Ix_In.IntValue > 1) {
        goto lab_Finw;
      }
      if (m_LocDef.In_Nm[m_LocDef.Ix_In.IntValue].Value == m_LocDef.Ws_Inname.Value) {
        goto lab_Find_Out;
      }
      m_LocDef.Ix_In.IntValue = m_LocDef.Ix_In.IntValue + 1;
      goto lab_Find_In;
    lab_Find_Out:
      if (m_LocDef.Ix_Out.IntValue > 1) {
        goto lab_Finw;
      }
      if (m_LocDef.Out_Nm[m_LocDef.Ix_Out.IntValue].Value == m_LocDef.Ws_Outname.Value) {
        goto lab_Open_Files;
      }
      m_LocDef.Ix_Out.IntValue = m_LocDef.Ix_Out.IntValue + 1;
      goto lab_Find_Out;
    lab_Open_Files:
      switch (m_LocDef.Ix_In.ToInt32()) {
        case 1: {
            goto lab_Oi_1;
          }
      }
    lab_Oi_1:
      OpenFile(Fi1, AmtCobolFileOpenMode.Input, false);
      goto lab_Oi_End;
    lab_Oi_End:
      switch (m_LocDef.Ix_Out.ToInt32()) {
        case 1: {
            goto lab_Oo_1;
          }
      }
    lab_Oo_1:
      OpenFile(Fo1, AmtCobolFileOpenMode.Output, false);
      goto lab_Oo_End;
    lab_Oo_End:
    lab_Lect:
      m_LocDef.Ws_Out.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Recin.StrValue = AmtConstRuntime.SpacesValueString;
      switch (m_LocDef.Ix_In.ToInt32()) {
        case 1: {
            goto lab_Rd_1;
          }
      }
    lab_Rd_1:
      if (!ReadSequentialFile(Fi1, m_Fd_Fi1_Rec, m_LocDef.Recin)) {
        goto lab_Finw;
      }
      goto lab_Rd_End;
    lab_Rd_End:
      m_LocDef.Ws_In.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Cp_Len.IntValue = m_LocDef.Ws_In_Len.IntValue;
      if (m_LocDef.Cp_Len.IntValue > m_LocDef.P_Inlen.IntValue) {
        m_LocDef.Cp_Len.IntValue = m_LocDef.P_Inlen.IntValue;
      }
      if (m_LocDef.Cp_Len.IntValue > 0) {
        m_LocDef.Ws_In.Replace(1, Substring(m_LocDef.Recin.ToAlphaValue(), 1, m_LocDef.Cp_Len.IntValue), m_LocDef.Cp_Len.IntValue);
      }
      if (m_LocDef.N_Mv.IntValue == 0) {
        m_LocDef.Ws_Out.Replace(1, Substring(m_LocDef.Ws_In.ToAlphaValue(), 1, m_LocDef.P_Inlen.IntValue), m_LocDef.P_Outlen.IntValue);
      }
      m_LocDef.I.IntValue = 1;
    lab_Mv_Loop:
      if (m_LocDef.I.IntValue > m_LocDef.N_Mv.IntValue) {
        goto lab_Fx_Start;
      }
      m_LocDef.Ws_Out.Replace(m_LocDef.Mv_Os[m_LocDef.I.IntValue].ToInt32(), Substring(m_LocDef.Ws_In.ToAlphaValue(), m_LocDef.Mv_Is[m_LocDef.I.IntValue].IntValue, m_LocDef.Mv_Il[m_LocDef.I.IntValue].IntValue), m_LocDef.Mv_Ol[m_LocDef.I.IntValue].IntValue);
      m_LocDef.I.IntValue = m_LocDef.I.IntValue + 1;
      goto lab_Mv_Loop;
    lab_Fx_Start:
      m_LocDef.I.IntValue = 1;
    lab_Fx_Loop:
      if (m_LocDef.I.IntValue > m_LocDef.N_Fx.IntValue) {
        goto lab_Rec_End;
      }
      m_LocDef.Ws_Out.Replace(m_LocDef.Fx_Os[m_LocDef.I.IntValue].ToInt32(), Substring(m_LocDef.Fx_Txt[m_LocDef.I.IntValue].Value, 1, m_LocDef.Fx_Len[m_LocDef.I.IntValue].IntValue), m_LocDef.Fx_Len[m_LocDef.I.IntValue].IntValue);
      AmtInspect.Replace(m_LocDef.Ws_Out, AmtInspectOption.All, "<", ";", m_LocDef.Fx_Os[m_LocDef.I.IntValue].ToInt32(), m_LocDef.Fx_Len[m_LocDef.I.IntValue].ToInt32());
      m_LocDef.I.IntValue = m_LocDef.I.IntValue + 1;
      goto lab_Fx_Loop;
    lab_Rec_End:
      m_LocDef.Nb_Lus.IntValue = m_LocDef.Nb_Lus.IntValue + 1;
      if (m_LocDef.Nb_Lus.IntValue < m_LocDef.P_Skip.IntValue) {
        m_LocDef.Rec_Skipped.Add(1);
        goto lab_Lect;
      }
      m_LocDef.Ws_Out_Len.IntValue = m_LocDef.P_Outlen.IntValue;
      m_LocDef.Recout.Value = m_LocDef.Ws_Out.Value;
      switch (m_LocDef.Ix_Out.ToInt32()) {
        case 1: {
            goto lab_Wr_1;
          }
      }
    lab_Wr_1:
      WriteSequentialFile(Fo1, m_Fd_Fo1_Rec, m_LocDef.Recout.Value);
      goto lab_Wr_End;
    lab_Wr_End:
      goto lab_Lect;
    lab_Finw:
      OS2200.Display(NoTrunc("*CFH-COPY  FIN*"), true);
      OS2200.Display(NoTrunc("*NB-ENREG-LUS =") & NoTrunc(m_LocDef.Nb_Lus.ToAlphaValue()), true);
      if (m_LocDef.Ix_In.IntValue > 1) {
        goto lab_Ci_End;
      }
      switch (m_LocDef.Ix_In.ToInt32()) {
        case 1: {
            goto lab_Ci_1;
          }
      }
    lab_Ci_1:
      CloseFile(Fi1);
      goto lab_Ci_End;
    lab_Ci_End:
      if (m_LocDef.Ix_Out.IntValue > 1) {
        goto lab_Co_End;
      }
      switch (m_LocDef.Ix_Out.ToInt32()) {
        case 1: {
            goto lab_Co_1;
          }
      }
    lab_Co_1:
      CloseFile(Fo1);
      goto lab_Co_End;
    lab_Co_End:
      OS2200.Display(NoTrunc(m_LocDef.Rec_Skipped.ToAlphaValue()), true);
      StopRun();
    } // Amt_Main

  } // Class Cfh_Copy_Gn

} // Namespace Company.AFBUS_2200COBOL.BusinessLogic.Cfh_Copy_Gn

