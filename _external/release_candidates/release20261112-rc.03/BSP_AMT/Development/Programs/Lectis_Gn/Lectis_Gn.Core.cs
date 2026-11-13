using System;
using System.Diagnostics;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;
using Federale.BSP.BusinessLogic.Database;

namespace Federale.BSP.BusinessLogic.Lectis_Gn {

  public sealed partial class Lectis_Gn {
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
        m_LocDef.P_Len.IntValue = m_Fd_Parm_In_Rec.Pi_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "KY") {
        m_LocDef.P_Off.IntValue = m_Fd_Parm_Ky_Rec.Pk_Off.IntValue;
        m_LocDef.P_Klen.IntValue = m_Fd_Parm_Ky_Rec.Pk_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "MD") {
        m_LocDef.P_Keys.Value = m_Fd_Parm_Md_Rec.Pm_Keys.Value;
        m_LocDef.P_Nolist.Value = m_Fd_Parm_Md_Rec.Pm_Nolist.Value;
        m_LocDef.P_Y2k.Value = m_Fd_Parm_Md_Rec.Pm_Y2k.Value;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "CD") {
        m_LocDef.P_Op.Value = m_Fd_Parm_Cd_Rec.Pc_Op.Value;
        m_LocDef.P_Rel.Value = m_Fd_Parm_Cd_Rec.Pc_Rel.Value;
        m_LocDef.P_Litlen.IntValue = m_Fd_Parm_Cd_Rec.Pc_Litlen.IntValue;
        m_LocDef.P_Lit.Value = m_Fd_Parm_Cd_Rec.Pc_Lit.Value;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "CD" && m_Fd_Parm_Cd_Rec.Pc_Op.Value == 'C') {
        m_LocDef.P_Litn.IntValue = m_Fd_Parm_Cd_Rec.Pc_Litn.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "YD") {
        Prf_Yd_Copy();
      }
      goto lab_Parm_Lect;
    lab_Parm_Fin:
      CloseFile(Parmf);
    lab_Ouvert:
      OpenPrintFile(m_PrnDef.Imp, 69, true);
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp1.Value);
      NewPage(m_Fd_Zprint);
      if (m_LocDef.P_Keys.Value == 1) {
        goto lab_Key_Open;
      }
      OpenFile(Lecin, AmtCobolFileOpenMode.Input, false);
    lab_Lecture:
      m_LocDef.Recin.StrValue = AmtConstRuntime.SpacesValueString;
      if (!ReadSequentialFile(Lecin, m_Fd_Lecin_Rec, m_LocDef.Recin)) {
        goto lab_Fin;
      }
      Prf_Load_Wrec();
      m_LocDef.Ctr.IntValue = m_LocDef.Ctr.IntValue + 1;
      if (m_LocDef.P_Nolist.Value == 1) {
        goto lab_Lecture;
      }
      Prf_Cond_Test();
      if (m_LocDef.Cond_Ok.Value == 0) {
        goto lab_Lecture;
      }
    lab_Suite:
      m_LocDef.Filco.Value = m_LocDef.Ctr.IntValue;
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Tit.Value, 1);
      m_LocDef.Zpr.Value = m_LocDef.Wrec.Value;
      Prf_Impres();
      goto lab_Lecture;
    lab_Key_Open:
      OpenFile(Leccrd, AmtCobolFileOpenMode.Input, false);
      m_LocDef.Zl_Len.IntValue = m_LocDef.P_Klen.IntValue;
      if (m_LocDef.P_Y2k.Value == 1) {
        m_LocDef.Zl_Len.IntValue = m_LocDef.P_Z5.IntValue;
      }
    lab_Key_Loop:
      m_LocDef.Crdrec.StrValue = AmtConstRuntime.SpacesValueString;
      if (!ReadSequentialFile(Leccrd, m_Fd_Leccrd_Rec, m_LocDef.Crdrec)) {
        goto lab_Fin;
      }
      m_LocDef.Zl1.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Cc_Len.IntValue = m_LocDef.Ws_Crd_Len.IntValue;
      if (m_LocDef.Cc_Len.IntValue > m_LocDef.Zl_Len.IntValue) {
        m_LocDef.Cc_Len.IntValue = m_LocDef.Zl_Len.IntValue;
      }
      if (m_LocDef.Cc_Len.IntValue > 0) {
        m_LocDef.Zl1.Replace(1, Substring(m_LocDef.Crdrec.ToAlphaValue(), 1, m_LocDef.Cc_Len.IntValue), m_LocDef.Cc_Len.IntValue);
      }
      m_LocDef.Symk_W.StrValue = AmtConstRuntime.SpacesValueString;
      if (m_LocDef.P_Y2k.Value == 0) {
        goto lab_Key_Plain;
      }
      Prf_Format_Cle();
      m_LocDef.Symk_W.Replace(1, Substring(m_LocDef.Tab_Output.ToAlphaValue(), 1, m_LocDef.P_Klen.IntValue), m_LocDef.P_Klen.IntValue);
      goto lab_Key_Find;
    lab_Key_Plain:
      m_LocDef.Symk_W.Replace(1, Substring(m_LocDef.Zl1.ToAlphaValue(), 1, m_LocDef.P_Klen.IntValue), m_LocDef.P_Klen.IntValue);
    lab_Key_Find:
      Prf_Search_Key();
      if (m_LocDef.Swi.IntValue == 1) {
        m_LocDef.Ctr.IntValue = m_LocDef.Ctr.IntValue + 1;
      }
      if (m_LocDef.Swi.IntValue != 1) {
        m_LocDef.Zpr.Value = m_LocDef.Wrec.Value;
        Prf_Impres();
      }
      m_LocDef.Swi.IntValue = 0;
      goto lab_Key_Loop;
    lab_Fin:
      m_Fd_Zprint.Zprint.StrValue = AmtConstRuntime.SpacesValueString;
      PrintBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value);
      NewPage(m_Fd_Zprint);
      OS2200.Display(NoTrunc("** FIN DU TRAVAIL **"), true);
      if (m_LocDef.P_Keys.Value == 0) {
        OS2200.Display(NoTrunc("NOMBRE DE RECORDS LUS ** ") & NoTrunc(m_LocDef.Ctr.ToAlphaValue()), true);
      }
      if (m_LocDef.P_Keys.Value == 1) {
        OS2200.Display(NoTrunc("NOMBRE D INVALID KEY **") & NoTrunc(m_LocDef.Ctr.ToAlphaValue()), true);
      }
      ClosePrintFile(m_PrnDef.Imp);
      if (m_LocDef.P_Keys.Value == 0) {
        CloseFile(Lecin);
      }
      if (m_LocDef.P_Keys.Value == 1) {
        CloseFile(Leccrd);
      }
      StopRun();
    lab_Yd_Copy:
      Prf_Yd_Copy();
    lab_Load_Wrec:
      Prf_Load_Wrec();
    lab_Cond_Test:
      Prf_Cond_Test();
    lab_Search_Key:
      Prf_Search_Key();
    lab_Impres:
      Prf_Impres();
    lab_Format_Cle:
      Prf_Format_Cle();
    lab_Move_Char:
      Prf_Move_Char();
    } // Amt_Main

    private void Prf_Yd_Copy () {
      m_LocDef.P_Nd.IntValue = m_Fd_Parm_Yd_Rec.Py_Nd.IntValue;
      m_LocDef.P_Z5.IntValue = m_Fd_Parm_Yd_Rec.Py_Z5.IntValue;
      m_LocDef.Da.IntValue = 1;
    lab_Yd_Copy_Loop:
      if (m_LocDef.Da.IntValue > m_LocDef.P_Nd.IntValue) {
        goto lab_Yd_Copy_Exit;
      }
      m_LocDef.Yp[m_LocDef.Da.IntValue].IntValue = m_Fd_Parm_Yd_Rec.Py_Pos[m_LocDef.Da.IntValue].IntValue;
      m_LocDef.Da.IntValue = m_LocDef.Da.IntValue + 1;
      goto lab_Yd_Copy_Loop;
    lab_Yd_Copy_Exit: { }
      // Cobol EXIT
    } // Prf_Yd_Copy

    private void Prf_Load_Wrec () {
      m_LocDef.Wrec.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Cp_Len.IntValue = m_LocDef.Ws_In_Len.IntValue;
      if (m_LocDef.Cp_Len.IntValue > m_LocDef.P_Len.IntValue) {
        m_LocDef.Cp_Len.IntValue = m_LocDef.P_Len.IntValue;
      }
      if (m_LocDef.Cp_Len.IntValue > 0) {
        m_LocDef.Wrec.Replace(1, Substring(m_LocDef.Recin.ToAlphaValue(), 1, m_LocDef.Cp_Len.IntValue), m_LocDef.Cp_Len.IntValue);
      }
    lab_Load_Wrec_Exit: { }
      // Cobol EXIT
    } // Prf_Load_Wrec

    private void Prf_Cond_Test () {
      m_LocDef.Cond_Ok.Value = 0;
      if (m_LocDef.P_Op.Value == 'K') {
        goto lab_Cond_Key;
      }
      if (m_LocDef.P_Rel.Value == "EQ" && m_LocDef.Ctr.IntValue == m_LocDef.P_Litn.IntValue) {
        m_LocDef.Cond_Ok.IntValue = 1;
      }
      if (m_LocDef.P_Rel.Value == "NE" && m_LocDef.Ctr.IntValue != m_LocDef.P_Litn.IntValue) {
        m_LocDef.Cond_Ok.IntValue = 1;
      }
      if (m_LocDef.P_Rel.Value == "GT" && m_LocDef.Ctr.IntValue > m_LocDef.P_Litn.IntValue) {
        m_LocDef.Cond_Ok.IntValue = 1;
      }
      if (m_LocDef.P_Rel.Value == "LT" && m_LocDef.Ctr.IntValue < m_LocDef.P_Litn.IntValue) {
        m_LocDef.Cond_Ok.IntValue = 1;
      }
      if (m_LocDef.P_Rel.Value == "GE" && m_LocDef.Ctr.IntValue >= m_LocDef.P_Litn.IntValue) {
        m_LocDef.Cond_Ok.IntValue = 1;
      }
      if (m_LocDef.P_Rel.Value == "LE" && m_LocDef.Ctr.IntValue <= m_LocDef.P_Litn.IntValue) {
        m_LocDef.Cond_Ok.IntValue = 1;
      }
      goto lab_Cond_Test_Exit;
    lab_Cond_Key:
      m_LocDef.W_A.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.W_B.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Kp.IntValue = m_LocDef.P_Off.IntValue + 1;
      m_LocDef.W_A.Replace(1, Substring(m_LocDef.Wrec.ToAlphaValue(), m_LocDef.Kp.IntValue, m_LocDef.P_Klen.IntValue), m_LocDef.P_Klen.IntValue);
      m_LocDef.W_B.Replace(1, Substring(m_LocDef.P_Lit.ToAlphaValue(), 1, m_LocDef.P_Litlen.IntValue), m_LocDef.P_Litlen.IntValue);
      if (m_LocDef.P_Rel.Value == "EQ" && m_LocDef.W_A.Value == m_LocDef.W_B.Value) {
        m_LocDef.Cond_Ok.IntValue = 1;
      }
      if (m_LocDef.P_Rel.Value == "NE" && m_LocDef.W_A.Value != m_LocDef.W_B.Value) {
        m_LocDef.Cond_Ok.IntValue = 1;
      }
      if (m_LocDef.P_Rel.Value == "GT" && m_LocDef.W_A.Value > m_LocDef.W_B.Value) {
        m_LocDef.Cond_Ok.IntValue = 1;
      }
      if (m_LocDef.P_Rel.Value == "LT" && m_LocDef.W_A.Value < m_LocDef.W_B.Value) {
        m_LocDef.Cond_Ok.IntValue = 1;
      }
      if (m_LocDef.P_Rel.Value == "GE" && m_LocDef.W_A.Value >= m_LocDef.W_B.Value) {
        m_LocDef.Cond_Ok.IntValue = 1;
      }
      if (m_LocDef.P_Rel.Value == "LE" && m_LocDef.W_A.Value <= m_LocDef.W_B.Value) {
        m_LocDef.Cond_Ok.IntValue = 1;
      }
    lab_Cond_Test_Exit: { }
      // Cobol EXIT
    } // Prf_Cond_Test

    private void Prf_Search_Key () {
      m_LocDef.Swi.IntValue = 1;
      m_LocDef.Kp.IntValue = m_LocDef.P_Off.IntValue + 1;
      OpenFile(Lecin, AmtCobolFileOpenMode.Input, false);
    lab_Sk_Loop:
      m_LocDef.Recin.StrValue = AmtConstRuntime.SpacesValueString;
      if (!ReadSequentialFile(Lecin, m_Fd_Lecin_Rec, m_LocDef.Recin)) {
        goto lab_Sk_Close;
      }
      Prf_Load_Wrec();
      if (Substring(m_LocDef.Wrec.Value, m_LocDef.Kp.IntValue, m_LocDef.P_Klen.IntValue) == Substring(m_LocDef.Symk_W.Value, 1, m_LocDef.P_Klen.IntValue)) {
        m_LocDef.Swi.IntValue = 0;
        goto lab_Sk_Close;
      }
      goto lab_Sk_Loop;
    lab_Sk_Close:
      CloseFile(Lecin);
    lab_Sk_Exit: { }
      // Cobol EXIT
    } // Prf_Search_Key

    private void Prf_Impres () {
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp1.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp2.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp3.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp4.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp5.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp6.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp7.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp8.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp9.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp10.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp11.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp12.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp13.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp14.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp15.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp16.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp17.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp18.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp19.Value, 1);
      m_LocDef.Ctrli.Add(100);
      if (m_LocDef.P_Len.IntValue == m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      if (m_LocDef.P_Len.IntValue < m_LocDef.Ctrli.IntValue) {
        goto lab_Raz;
      }
      PrintSourceBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, m_LocDef.Zp20.Value, 1);
    lab_Raz:
      m_LocDef.Zp1.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp2.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp3.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp4.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp5.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp6.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp7.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp8.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp9.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp10.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp11.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp12.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp13.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp14.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp15.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp16.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp17.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp18.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp19.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Zp20.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Ctrli.IntValue = 0;
      m_Fd_Zprint.Zprint.Setto("*");
      PrintBuffer(m_PrnDef.Imp, null, m_Fd_Zprint.Value, 1);
    lab_Fiimpres: { }
      // Cobol EXIT
    } // Prf_Impres

    private void Prf_Format_Cle () {
      m_LocDef.Tab_Input.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Tab_Output.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Tab_Input.Replace(1, Substring(m_LocDef.Zl1.ToAlphaValue(), 1, m_LocDef.P_Z5.IntValue), m_LocDef.P_Z5.IntValue);
      m_LocDef.Indexi.IntValue = 1;
      m_LocDef.Indexo.IntValue = 1;
      m_LocDef.Sw_Avant.IntValue = m_LocDef.Yp[1].IntValue - 1;
      for (Int32 I_Loop_385 = m_LocDef.Sw_Avant.ToInt32(); I_Loop_385 > 0; I_Loop_385--) {
        Prf_Move_Char();
      }
      m_LocDef.Da.IntValue = 1;
    lab_Date_Loop:
      if (m_LocDef.Da.IntValue > m_LocDef.P_Nd.IntValue) {
        goto lab_Format_Cle_Exit;
      }
      if (m_LocDef.Tab_I[m_LocDef.Indexi.IntValue].Value != '2') {
        m_LocDef.Indexi.IntValue = m_LocDef.Indexi.IntValue + 2;
        for (Int32 I_Loop_391 = 2; I_Loop_391 > 0; I_Loop_391--) {
          Prf_Move_Char();
        }
        goto lab_Date_Tail;
      }
      m_LocDef.Indexi.IntValue = m_LocDef.Indexi.IntValue + 1;
      if (m_LocDef.Tab_I[m_LocDef.Indexi.IntValue].Value != '0') {
        goto lab_Date_Tail;
      }
      if (m_LocDef.Tab_I[m_LocDef.Indexi.IntValue + 1].Value == '0') {
        m_LocDef.Ws_Mark.StrValue = ";";
        goto lab_Date_Put;
      }
      if (m_LocDef.Tab_I[m_LocDef.Indexi.IntValue + 1].Value == '1') {
        m_LocDef.Ws_Mark.StrValue = "_";
        goto lab_Date_Put;
      }
      if (m_LocDef.Tab_I[m_LocDef.Indexi.IntValue + 1].Value == '2') {
        m_LocDef.Ws_Mark.StrValue = "|";
        goto lab_Date_Put;
      }
      if (m_LocDef.Tab_I[m_LocDef.Indexi.IntValue + 1].Value == '3') {
        m_LocDef.Ws_Mark.StrValue = "~";
        goto lab_Date_Put;
      }
      goto lab_Date_Tail;
    lab_Date_Put:
      m_LocDef.Tab_O[m_LocDef.Indexo.IntValue].Value = m_LocDef.Ws_Mark.Value;
      m_LocDef.Indexi.IntValue = m_LocDef.Indexi.IntValue + 2;
      m_LocDef.Indexo.IntValue = m_LocDef.Indexo.IntValue + 1;
      Prf_Move_Char();
    lab_Date_Tail:
      m_LocDef.W3.IntValue = m_LocDef.Yp[m_LocDef.Da.IntValue].IntValue;
      if (m_LocDef.Da.IntValue == m_LocDef.P_Nd.IntValue) {
        m_LocDef.Dcnt.IntValue = m_LocDef.P_Klen.IntValue - m_LocDef.W3.IntValue + 2;
      } else {
        m_LocDef.Dcnt.IntValue = m_LocDef.Yp[m_LocDef.Da.IntValue + 1].IntValue - m_LocDef.W3.IntValue - 4;
      }
      if (m_LocDef.Dcnt.IntValue > 0) {
        for (Int32 I_Loop_416 = m_LocDef.Dcnt.ToInt32(); I_Loop_416 > 0; I_Loop_416--) {
          Prf_Move_Char();
        }
      }
      m_LocDef.Da.IntValue = m_LocDef.Da.IntValue + 1;
      goto lab_Date_Loop;
    lab_Format_Cle_Exit: { }
      // Cobol EXIT
    } // Prf_Format_Cle

    private void Prf_Move_Char () {
      m_LocDef.Tab_O[m_LocDef.Indexo.IntValue].Value = m_LocDef.Tab_I[m_LocDef.Indexi.IntValue].Value;
      m_LocDef.Indexi.IntValue = m_LocDef.Indexi.IntValue + 1;
      m_LocDef.Indexo.IntValue = m_LocDef.Indexo.IntValue + 1;
    lab_Move_Char_Exit: { }
      // Cobol EXIT
    } // Prf_Move_Char

  } // Class Lectis_Gn

} // Namespace Federale.BSP.BusinessLogic.Lectis_Gn

