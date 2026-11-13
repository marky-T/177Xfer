using System.Diagnostics;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;
using Federale.BSP.BusinessLogic.Database;

namespace Federale.BSP.BusinessLogic.Baba_Gn {

  public sealed partial class Baba_Gn {
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
        m_LocDef.P_Inlen.IntValue = m_Fd_Parm_File_Rec.Pf_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "OU") {
        m_LocDef.N_Out.IntValue = m_LocDef.N_Out.IntValue + 1;
        m_LocDef.Out_Len[m_LocDef.N_Out.IntValue].IntValue = m_Fd_Parm_File_Rec.Pf_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "MD") {
        m_LocDef.P_Mode.Value = m_Fd_Parm_Mode_Rec.Pd_Mode.Value;
        m_LocDef.P_Seq.Value = m_Fd_Parm_Mode_Rec.Pd_Seq.Value;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "KF") {
        m_LocDef.N_Kf.IntValue = m_LocDef.N_Kf.IntValue + 1;
        m_LocDef.Kf_Pos[m_LocDef.N_Kf.IntValue].IntValue = m_Fd_Parm_Key_Rec.Pk_Pos.IntValue;
        m_LocDef.Kf_Len[m_LocDef.N_Kf.IntValue].IntValue = m_Fd_Parm_Key_Rec.Pk_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "RQ") {
        m_LocDef.N_Rq.IntValue = m_LocDef.N_Rq.IntValue + 1;
        m_LocDef.Rq_Len[m_LocDef.N_Rq.IntValue].IntValue = m_Fd_Parm_Req_Rec.Pr_Len.IntValue;
        m_LocDef.Rq_Val[m_LocDef.N_Rq.IntValue].Value = m_Fd_Parm_Req_Rec.Pr_Val.Value;
      }
      goto lab_Parm_Lect;
    lab_Parm_Fin:
      CloseFile(Parmf);
      OpenFile(Fi1, AmtCobolFileOpenMode.Input, false);
      OpenFile(Fo1, AmtCobolFileOpenMode.Output, false);
      if (m_LocDef.N_Out.IntValue > 1) {
        OpenFile(Fo2, AmtCobolFileOpenMode.Output, false);
      }
    lab_Lect:
      m_LocDef.Recin.StrValue = AmtConstRuntime.SpacesValueString;
      if (!ReadSequentialFile(Fi1, m_Fd_Fi1_Rec, m_LocDef.Recin)) {
        goto lab_Finw;
      }
      m_LocDef.Nb_Lus.IntValue = m_LocDef.Nb_Lus.IntValue + 1;
      if (m_LocDef.Nb_Lus.IntValue >= 99999999) {
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
      m_LocDef.Ws_Key.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Kp.IntValue = 1;
      m_LocDef.I.IntValue = 1;
    lab_Key_Loop:
      if (m_LocDef.I.IntValue > m_LocDef.N_Kf.IntValue) {
        goto lab_Key_End;
      }
      m_LocDef.Ws_Key.Replace(m_LocDef.Kp.ToInt32(), Substring(m_LocDef.Ws_In.ToAlphaValue(), m_LocDef.Kf_Pos[m_LocDef.I.IntValue].IntValue, m_LocDef.Kf_Len[m_LocDef.I.IntValue].IntValue), m_LocDef.Kf_Len[m_LocDef.I.IntValue].IntValue);
      m_LocDef.Kp.IntValue = m_LocDef.Kp.IntValue + m_LocDef.Kf_Len[m_LocDef.I.IntValue].IntValue;
      m_LocDef.I.IntValue = m_LocDef.I.IntValue + 1;
      goto lab_Key_Loop;
    lab_Key_End:
      m_LocDef.Key_Len.IntValue = m_LocDef.Kp.IntValue - 1;
      m_LocDef.Dup.StrValue = "N";
      if (m_LocDef.P_Seq.Value == 'N' || m_LocDef.Nb_Lus.IntValue == 1 || m_LocDef.Key_Len.IntValue == 0) {
        goto lab_Seq_End;
      }
      if (Substring(m_LocDef.Ws_Key.Value, 1, m_LocDef.Key_Len.IntValue) < Substring(m_LocDef.Prev_Key.Value, 1, m_LocDef.Key_Len.IntValue)) {
        goto lab_Seq_Abort;
      }
      if (m_LocDef.P_Seq.Value == 'M' && Substring(m_LocDef.Ws_Key.Value, 1, m_LocDef.Key_Len.IntValue) == Substring(m_LocDef.Prev_Key.Value, 1, m_LocDef.Key_Len.IntValue)) {
        m_LocDef.Dup.StrValue = "Y";
      }
    lab_Seq_End:
      m_LocDef.Prev_Key.Value = m_LocDef.Ws_Key.Value;
      m_LocDef.Target.IntValue = 1;
      if (m_LocDef.P_Seq.Value == 'M') {
        if (m_LocDef.Dup.Value == 'Y') {
          m_LocDef.Target.IntValue = 2;
          goto lab_Route_End;
        } else {
          goto lab_Route_End;
        }
      }
      if (m_LocDef.P_Mode.Value == "ALL") {
        goto lab_Route_End;
      }
      m_LocDef.I.IntValue = 1;
    lab_Rq_Loop:
      if (m_LocDef.I.IntValue > m_LocDef.N_Rq.IntValue) {
        goto lab_Rq_None;
      }
      if (m_LocDef.Rq_Len[m_LocDef.I.IntValue].IntValue == m_LocDef.Key_Len.IntValue && m_LocDef.Key_Len.IntValue > 0) {
        if (Substring(m_LocDef.Ws_Key.Value, 1, m_LocDef.Key_Len.IntValue) == Substring(m_LocDef.Rq_Val[m_LocDef.I.IntValue].Value, 1, m_LocDef.Key_Len.IntValue)) {
          goto lab_Rq_Found;
        }
      }
      m_LocDef.I.IntValue = m_LocDef.I.IntValue + 1;
      goto lab_Rq_Loop;
    lab_Rq_Found:
      if (m_LocDef.P_Mode.Value == 'E') {
        m_LocDef.Target.IntValue = 2;
      }
      goto lab_Route_End;
    lab_Rq_None:
      if (m_LocDef.P_Mode.Value == 'R') {
        m_LocDef.Target.IntValue = 2;
      }
    lab_Route_End:
      if (m_LocDef.Target.IntValue > m_LocDef.N_Out.IntValue) {
        m_LocDef.Nb_Elim.IntValue = m_LocDef.Nb_Elim.IntValue + 1;
        goto lab_Lect;
      }
      m_LocDef.Recout.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Recout.Replace(1, Substring(m_LocDef.Ws_In.ToAlphaValue(), 1, m_LocDef.P_Inlen.IntValue), m_LocDef.Out_Len[m_LocDef.Target.IntValue].IntValue);
      if (m_LocDef.Target.IntValue == 1) {
        WriteSequentialFile(Fo1, m_Fd_Fo1_Rec, m_LocDef.Recout.Value);
        m_LocDef.Nb_Out1.IntValue = m_LocDef.Nb_Out1.IntValue + 1;
      } else {
        WriteSequentialFile(Fo2, m_Fd_Fo2_Rec, m_LocDef.Recout.Value);
        m_LocDef.Nb_Out2.IntValue = m_LocDef.Nb_Out2.IntValue + 1;
      }
      goto lab_Lect;
    lab_Seq_Abort:
      m_LocDef.Nb_Prev.IntValue = m_LocDef.Nb_Lus.IntValue - 1;
      m_LocDef.Disp_Message.StrValue = " HAS SEQUENCE ERROR AT  ";
      m_LocDef.Disp_Ct.Value = m_LocDef.Nb_Prev.IntValue;
      OS2200.Display(NoTrunc(m_LocDef.Display_Line.Value), true);
      m_LocDef.Disp_Message.StrValue = "               AND AT   ";
      m_LocDef.Disp_Ct.Value = m_LocDef.Nb_Lus.IntValue;
      OS2200.Display(NoTrunc(m_LocDef.Display_Line.Value), true);
      CloseFile(Fi1);
      CloseFile(Fo1);
      if (m_LocDef.N_Out.IntValue > 1) {
        CloseFile(Fo2);
      }
      CallProgram("ABORT", "");
      StopRun();
    lab_Finw:
      m_LocDef.Disp_Message.StrValue = "     RECORDS  READ      ";
      m_LocDef.Disp_Ct.Value = m_LocDef.Nb_Lus.IntValue;
      OS2200.Display(NoTrunc(m_LocDef.Display_Line.Value), true);
      m_LocDef.Disp_Message.StrValue = "    RECORDS WRITTEN 1   ";
      m_LocDef.Disp_Ct.Value = m_LocDef.Nb_Out1.IntValue;
      OS2200.Display(NoTrunc(m_LocDef.Display_Line.Value), true);
      m_LocDef.Disp_Message.StrValue = "    RECORDS WRITTEN 2   ";
      m_LocDef.Disp_Ct.Value = m_LocDef.Nb_Out2.IntValue;
      OS2200.Display(NoTrunc(m_LocDef.Display_Line.Value), true);
      m_LocDef.Disp_Message.StrValue = "    RECORDS ELIMINATED  ";
      m_LocDef.Disp_Ct.Value = m_LocDef.Nb_Elim.IntValue;
      OS2200.Display(NoTrunc(m_LocDef.Display_Line.Value), true);
      CloseFile(Fi1);
      CloseFile(Fo1);
      if (m_LocDef.N_Out.IntValue > 1) {
        CloseFile(Fo2);
      }
      StopRun();
    } // Amt_Main

  } // Class Baba_Gn

} // Namespace Federale.BSP.BusinessLogic.Baba_Gn

