using System.Diagnostics;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;
using Federale.BSP.BusinessLogic.Database;

namespace Federale.BSP.BusinessLogic.Fusba_Gn {

  public sealed partial class Fusba_Gn {
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
        m_LocDef.N_In.IntValue = m_LocDef.N_In.IntValue + 1;
        if (m_LocDef.N_In.IntValue == 1) {
          m_LocDef.P_Len1.IntValue = m_Fd_Parm_File_Rec.Pf_Len.IntValue;
        } else {
          m_LocDef.P_Len2.IntValue = m_Fd_Parm_File_Rec.Pf_Len.IntValue;
        }
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "OU") {
        m_LocDef.N_Out.IntValue = m_LocDef.N_Out.IntValue + 1;
        m_LocDef.Out_Len[m_LocDef.N_Out.IntValue].IntValue = m_Fd_Parm_File_Rec.Pf_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "MD") {
        m_LocDef.P_Mode.Value = m_Fd_Parm_Mode_Rec.Pd_Mode.Value;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "K1") {
        m_LocDef.N_K1.IntValue = m_LocDef.N_K1.IntValue + 1;
        m_LocDef.K1_Pos[m_LocDef.N_K1.IntValue].IntValue = m_Fd_Parm_Key_Rec.Pk_Pos.IntValue;
        m_LocDef.K1_Len[m_LocDef.N_K1.IntValue].IntValue = m_Fd_Parm_Key_Rec.Pk_Len.IntValue;
        m_LocDef.Kl.IntValue = m_LocDef.Kl.IntValue + m_Fd_Parm_Key_Rec.Pk_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "K2") {
        m_LocDef.N_K2.IntValue = m_LocDef.N_K2.IntValue + 1;
        m_LocDef.K2_Pos[m_LocDef.N_K2.IntValue].IntValue = m_Fd_Parm_Key_Rec.Pk_Pos.IntValue;
        m_LocDef.K2_Len[m_LocDef.N_K2.IntValue].IntValue = m_Fd_Parm_Key_Rec.Pk_Len.IntValue;
        m_LocDef.Kl2.IntValue = m_LocDef.Kl2.IntValue + m_Fd_Parm_Key_Rec.Pk_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "FM") {
        m_LocDef.N_Fm.IntValue = m_LocDef.N_Fm.IntValue + 1;
        m_LocDef.Fm_Ipos[m_LocDef.N_Fm.IntValue].IntValue = m_Fd_Parm_Move_Rec.Pm_Ipos.IntValue;
        m_LocDef.Fm_Ilen[m_LocDef.N_Fm.IntValue].IntValue = m_Fd_Parm_Move_Rec.Pm_Ilen.IntValue;
        m_LocDef.Fm_Opos[m_LocDef.N_Fm.IntValue].IntValue = m_Fd_Parm_Move_Rec.Pm_Opos.IntValue;
        m_LocDef.Fm_Olen[m_LocDef.N_Fm.IntValue].IntValue = m_Fd_Parm_Move_Rec.Pm_Olen.IntValue;
      }
      goto lab_Parm_Lect;
    lab_Parm_Fin:
      CloseFile(Parmf);
      // * Keys of different lengths: the shorter one is space-padded.
      if (m_LocDef.Kl2.IntValue > m_LocDef.Kl.IntValue) {
        m_LocDef.Kl.IntValue = m_LocDef.Kl2.IntValue;
      }
      OpenFile(Fi1, AmtCobolFileOpenMode.Input, false);
      OpenFile(Fi2, AmtCobolFileOpenMode.Input, false);
      OpenFile(Fo1, AmtCobolFileOpenMode.Output, false);
      if (m_LocDef.N_Out.IntValue > 1) {
        OpenFile(Fo2, AmtCobolFileOpenMode.Output, false);
      }
      Prf_Read_1();
      Prf_Read_2();
    lab_Fusion:
      if (m_LocDef.Eof1.Value == 'Y' && m_LocDef.Eof2.Value == 'Y') {
        goto lab_Finw;
      }
      if (Substring(m_LocDef.Key1.Value, 1, m_LocDef.Kl.IntValue) < Substring(m_LocDef.Key2.Value, 1, m_LocDef.Kl.IntValue)) {
        Prf_Read_1();
        goto lab_Fusion;
      }
      if (Substring(m_LocDef.Key1.Value, 1, m_LocDef.Kl.IntValue) > Substring(m_LocDef.Key2.Value, 1, m_LocDef.Kl.IntValue)) {
        m_LocDef.Target.IntValue = 1;
        Prf_Write_Master();
        Prf_Read_2();
        goto lab_Fusion;
      }
      if (m_LocDef.P_Mode.Value == 'C') {
        m_LocDef.Target.IntValue = 2;
        Prf_Write_Master();
        Prf_Read_2();
        goto lab_Fusion;
      }
      if (m_LocDef.P_Mode.Value == 'D') {
        m_LocDef.Nb_Del.IntValue = m_LocDef.Nb_Del.IntValue + 1;
        Prf_Read_2();
        goto lab_Fusion;
      }
      Prf_Write_Updated();
      if (m_LocDef.P_Mode.Value == 'U') {
        Prf_Read_1();
        Prf_Read_2();
        goto lab_Fusion;
      }
      /* * M (FUSBA2): the same update record serves every master with
       * * this key; read file 1 when the master key moves on.
       */
      m_LocDef.Prev_Key2.Value = m_LocDef.Key2.Value;
      Prf_Read_2();
      if (Substring(m_LocDef.Key2.Value, 1, m_LocDef.Kl.IntValue) > Substring(m_LocDef.Prev_Key2.Value, 1, m_LocDef.Kl.IntValue)) {
        Prf_Read_1();
      }
      goto lab_Fusion;
    lab_Read_1:
      Prf_Read_1();
    lab_Read_2:
      Prf_Read_2();
    lab_Write_Master:
      Prf_Write_Master();
    lab_Write_Updated:
      Prf_Write_Updated();
    lab_Finw:
      m_LocDef.Disp_Message.StrValue = "   RECORDS READ FILE 1  ";
      m_LocDef.Disp_Ct.Value = m_LocDef.Nb_Lus1.IntValue;
      OS2200.Display(NoTrunc(m_LocDef.Display_Line.Value), true);
      m_LocDef.Disp_Message.StrValue = "   RECORDS READ FILE 2  ";
      m_LocDef.Disp_Ct.Value = m_LocDef.Nb_Lus2.IntValue;
      OS2200.Display(NoTrunc(m_LocDef.Display_Line.Value), true);
      m_LocDef.Disp_Message.StrValue = "    RECORDS WRITTEN 1   ";
      m_LocDef.Disp_Ct.Value = m_LocDef.Nb_Out1.IntValue;
      OS2200.Display(NoTrunc(m_LocDef.Display_Line.Value), true);
      m_LocDef.Disp_Message.StrValue = "    RECORDS WRITTEN 2   ";
      m_LocDef.Disp_Ct.Value = m_LocDef.Nb_Out2.IntValue;
      OS2200.Display(NoTrunc(m_LocDef.Display_Line.Value), true);
      m_LocDef.Disp_Message.StrValue = "    RECORDS UPDATED     ";
      m_LocDef.Disp_Ct.Value = m_LocDef.Nb_Maj.IntValue;
      OS2200.Display(NoTrunc(m_LocDef.Display_Line.Value), true);
      m_LocDef.Disp_Message.StrValue = "    RECORDS DELETED     ";
      m_LocDef.Disp_Ct.Value = m_LocDef.Nb_Del.IntValue;
      OS2200.Display(NoTrunc(m_LocDef.Display_Line.Value), true);
      CloseFile(Fi1);
      CloseFile(Fi2);
      CloseFile(Fo1);
      if (m_LocDef.N_Out.IntValue > 1) {
        CloseFile(Fo2);
      }
      StopRun();
    } // Amt_Main

    private void Prf_Read_1 () {
      m_LocDef.Recin.StrValue = AmtConstRuntime.SpacesValueString;
      if (!ReadSequentialFile(Fi1, m_Fd_Fi1_Rec, m_LocDef.Recin)) {
        m_LocDef.Eof1.StrValue = "Y";
      }
      if (m_LocDef.Eof1.Value == 'Y') {
        m_LocDef.Key1.Value = AmtConstRuntime.HighValueString;
        goto lab_Read_1_End;
      }
      m_LocDef.Nb_Lus1.IntValue = m_LocDef.Nb_Lus1.IntValue + 1;
      m_LocDef.Rec1.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Cp_Len.IntValue = m_LocDef.Ws_Len1.IntValue;
      if (m_LocDef.Cp_Len.IntValue > m_LocDef.P_Len1.IntValue) {
        m_LocDef.Cp_Len.IntValue = m_LocDef.P_Len1.IntValue;
      }
      if (m_LocDef.Cp_Len.IntValue > 0) {
        m_LocDef.Rec1.Replace(1, Substring(m_LocDef.Recin.ToAlphaValue(), 1, m_LocDef.Cp_Len.IntValue), m_LocDef.Cp_Len.IntValue);
      }
      m_LocDef.Key1.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Kp.IntValue = 1;
      m_LocDef.I.IntValue = 1;
    lab_Key1_Loop:
      if (m_LocDef.I.IntValue > m_LocDef.N_K1.IntValue) {
        goto lab_Read_1_End;
      }
      m_LocDef.Key1.Replace(m_LocDef.Kp.ToInt32(), Substring(m_LocDef.Rec1.ToAlphaValue(), m_LocDef.K1_Pos[m_LocDef.I.IntValue].IntValue, m_LocDef.K1_Len[m_LocDef.I.IntValue].IntValue), m_LocDef.K1_Len[m_LocDef.I.IntValue].IntValue);
      m_LocDef.Kp.IntValue = m_LocDef.Kp.IntValue + m_LocDef.K1_Len[m_LocDef.I.IntValue].IntValue;
      m_LocDef.I.IntValue = m_LocDef.I.IntValue + 1;
      goto lab_Key1_Loop;
    lab_Read_1_End: { }
      // Cobol EXIT
    } // Prf_Read_1

    private void Prf_Read_2 () {
      m_LocDef.Recin.StrValue = AmtConstRuntime.SpacesValueString;
      if (!ReadSequentialFile(Fi2, m_Fd_Fi2_Rec, m_LocDef.Recin)) {
        m_LocDef.Eof2.StrValue = "Y";
      }
      if (m_LocDef.Eof2.Value == 'Y') {
        m_LocDef.Key2.Value = AmtConstRuntime.HighValueString;
        goto lab_Read_2_End;
      }
      m_LocDef.Nb_Lus2.IntValue = m_LocDef.Nb_Lus2.IntValue + 1;
      m_LocDef.Rec2.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Cp_Len.IntValue = m_LocDef.Ws_Len2.IntValue;
      if (m_LocDef.Cp_Len.IntValue > m_LocDef.P_Len2.IntValue) {
        m_LocDef.Cp_Len.IntValue = m_LocDef.P_Len2.IntValue;
      }
      if (m_LocDef.Cp_Len.IntValue > 0) {
        m_LocDef.Rec2.Replace(1, Substring(m_LocDef.Recin.ToAlphaValue(), 1, m_LocDef.Cp_Len.IntValue), m_LocDef.Cp_Len.IntValue);
      }
      m_LocDef.Key2.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Kp.IntValue = 1;
      m_LocDef.I.IntValue = 1;
    lab_Key2_Loop:
      if (m_LocDef.I.IntValue > m_LocDef.N_K2.IntValue) {
        goto lab_Read_2_End;
      }
      m_LocDef.Key2.Replace(m_LocDef.Kp.ToInt32(), Substring(m_LocDef.Rec2.ToAlphaValue(), m_LocDef.K2_Pos[m_LocDef.I.IntValue].IntValue, m_LocDef.K2_Len[m_LocDef.I.IntValue].IntValue), m_LocDef.K2_Len[m_LocDef.I.IntValue].IntValue);
      m_LocDef.Kp.IntValue = m_LocDef.Kp.IntValue + m_LocDef.K2_Len[m_LocDef.I.IntValue].IntValue;
      m_LocDef.I.IntValue = m_LocDef.I.IntValue + 1;
      goto lab_Key2_Loop;
    lab_Read_2_End: { }
      // Cobol EXIT
    } // Prf_Read_2

    private void Prf_Write_Master () {
      m_LocDef.Recout.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Recout.Replace(1, Substring(m_LocDef.Rec2.ToAlphaValue(), 1, m_LocDef.P_Len2.IntValue), m_LocDef.Out_Len[m_LocDef.Target.IntValue].IntValue);
      if (m_LocDef.Target.IntValue == 1) {
        WriteSequentialFile(Fo1, m_Fd_Fo1_Rec, m_LocDef.Recout.Value);
        m_LocDef.Nb_Out1.IntValue = m_LocDef.Nb_Out1.IntValue + 1;
      } else {
        WriteSequentialFile(Fo2, m_Fd_Fo2_Rec, m_LocDef.Recout.Value);
        m_LocDef.Nb_Out2.IntValue = m_LocDef.Nb_Out2.IntValue + 1;
      }
    } // Prf_Write_Master

    private void Prf_Write_Updated () {
      m_LocDef.Recout.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Recout.Replace(1, Substring(m_LocDef.Rec2.ToAlphaValue(), 1, m_LocDef.P_Len2.IntValue), m_LocDef.Out_Len[1].IntValue);
      m_LocDef.I.IntValue = 1;
    lab_Move_Loop:
      if (m_LocDef.I.IntValue > m_LocDef.N_Fm.IntValue) {
        goto lab_Move_End;
      }
      m_LocDef.Recout.Replace(m_LocDef.Fm_Opos[m_LocDef.I.IntValue].ToInt32(), Substring(m_LocDef.Rec1.ToAlphaValue(), m_LocDef.Fm_Ipos[m_LocDef.I.IntValue].IntValue, m_LocDef.Fm_Ilen[m_LocDef.I.IntValue].IntValue), m_LocDef.Fm_Olen[m_LocDef.I.IntValue].IntValue);
      m_LocDef.I.IntValue = m_LocDef.I.IntValue + 1;
      goto lab_Move_Loop;
    lab_Move_End:
      WriteSequentialFile(Fo1, m_Fd_Fo1_Rec, m_LocDef.Recout.Value);
      m_LocDef.Nb_Out1.IntValue = m_LocDef.Nb_Out1.IntValue + 1;
      m_LocDef.Nb_Maj.IntValue = m_LocDef.Nb_Maj.IntValue + 1;
    lab_Write_Updated_End: { }
      // Cobol EXIT
    } // Prf_Write_Updated

  } // Class Fusba_Gn

} // Namespace Federale.BSP.BusinessLogic.Fusba_Gn

