using System;
using System.Diagnostics;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Support;
using Asysco.Amt.Runtime.Vars;
using Federale.BSP.BusinessLogic.Database;

namespace Federale.BSP.BusinessLogic.Archiformat_Gn {

  public sealed partial class Archiformat_Gn {
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
      if (m_Fd_Parm_Rec.P_Type.Value == "TB") {
        m_LocDef.Ws_0_Nm_Base.Value = m_Fd_Parm_Tb_Rec.Pt_Base.Value;
        m_LocDef.Ws_9_Nm_Base.Value = m_Fd_Parm_Tb_Rec.Pt_Base.Value;
        m_LocDef.Ws_0_Nm_Table.Value = m_Fd_Parm_Tb_Rec.Pt_Table.Value;
        m_LocDef.Ws_9_Nm_Table.Value = m_Fd_Parm_Tb_Rec.Pt_Table.Value;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "KY") {
        m_LocDef.Ws_1_Nm_Cle.Value = m_Fd_Parm_Ky_Rec.Pk_Name.Value;
        m_LocDef.Ws_1_Typ_Cle.Value = m_Fd_Parm_Ky_Rec.Pk_Type.Value;
        m_LocDef.P_K.IntValue = m_Fd_Parm_Ky_Rec.Pk_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "RZ") {
        m_LocDef.P_Rsz.IntValue = m_Fd_Parm_Rz_Rec.Pr_Rsz.IntValue;
        m_LocDef.P_T.IntValue = m_Fd_Parm_Rz_Rec.Pr_Cols.IntValue;
      }
      goto lab_Parm_Lect;
    lab_Parm_Fin:
      CloseFile(Parmf);
      m_LocDef.P_E.IntValue = m_LocDef.P_K.IntValue + m_LocDef.P_Rsz.IntValue;
      m_LocDef.P_D.IntValue = m_LocDef.P_E.IntValue + 1;
      m_LocDef.P_C.IntValue = m_LocDef.P_E.IntValue + 2;
      m_LocDef.P_B.IntValue = m_LocDef.P_E.IntValue + 1 + m_LocDef.P_T.IntValue;
      OpenFile(Fic_Report, AmtCobolFileOpenMode.Input, false);
      OpenFile(Fic_Descript, AmtCobolFileOpenMode.Input, false);
      OpenFile(Fic_Unload, AmtCobolFileOpenMode.Input, false);
      OpenFile(Fic_Format, AmtCobolFileOpenMode.Output, false);
      Prf_100_Type0();
      Prf_101_Type1();
      Prf_102_Type2();
      Prf_103_Type3();
      Prf_104_Type4();
      Prf_105_Type9();
      Prf_106_Tot();
      CloseFile(Fic_Report);
      CloseFile(Fic_Descript);
      CloseFile(Fic_Unload);
      CloseFile(Fic_Format);
      StopRun();
    // *------------ ENREGISTREMENT DE TYPE 0 ----------------
    lab_100_Type0:
      Prf_100_Type0();
    // *------------ ENREGISTREMENT DE TYPE 1 -----------------
    lab_101_Type1:
      Prf_101_Type1();
    // *------------ ENREGISTREMENT DE TYPE 2 -----------------
    lab_102_Type2:
      Prf_102_Type2();
    lab_102_Col:
      Prf_102_Col();
    // *recherche [Y] et ensuite [E] pour NULL
    lab_102_Null:
      Prf_102_Null();
    // *------------ ENREGISTREMENT DE TYPE 3 -----------------
    lab_103_Type3:
      Prf_103_Type3();
    lab_103_Col:
      Prf_103_Col();
    // *------------ ENREGISTREMENT DE TYPE 4 -----------------
    lab_104_Type4:
      Prf_104_Type4();
    lab_104_Rec:
      Prf_104_Rec();
    // *------------ ENREGISTREMENT DE TYPE 9 -----------------
    lab_105_Type9:
      Prf_105_Type9();
    // *----------------- RAPPORT  -----------------
    lab_106_Tot:
      Prf_106_Tot();
    // *--------------- LECTURE DU REPORT --------------
    lab_200_Lec_Report:
      Prf_200_Lec_Report();
    // *--------------- LECTURE DU DESCRIPT ------------
    lab_201_Lec_Descript:
      Prf_201_Lec_Descript();
    // *--------------- LECTURE DE L'UNLOAD --------------
    lab_202_Lec_Unload:
      Prf_202_Lec_Unload();
    } // Amt_Main

    private void Prf_100_Type0 () {
      m_LocDef.Ws_0_Dt_Ach.Value = AcceptDate("YYYYMMDD");
      while (!(Substring(m_LocDef.Lgn_Rep.Value, 4, 21) == "DD-PROCESS-TIME-STAMP")) {
        CancellationToken.ThrowIfCancellationRequested();
        Prf_200_Lec_Report();
      }
      Prf_200_Lec_Report();
      m_LocDef.Ws_0_Dt_Maj_Aa.Value = Substring(m_LocDef.Lgn_Rep.Value, 7, 2);
      if (m_LocDef.Ws_0_Dt_Maj_Aa.Value > 90) {
        m_LocDef.Ws_0_Dt_Maj_Ss.IntValue = 19;
      } else {
        m_LocDef.Ws_0_Dt_Maj_Ss.IntValue = 20;
      }
      m_LocDef.Ws_0_Dt_Maj_Mm.Value = Substring(m_LocDef.Lgn_Rep.Value, 10, 2);
      m_LocDef.Ws_0_Dt_Maj_Jj.Value = Substring(m_LocDef.Lgn_Rep.Value, 13, 2);
      WriteSequentialFile(Fic_Format, m_Fd_Lgn_For, m_LocDef.Ws_Don_0.Value);
    lab_100_Exit: { }
      // Cobol EXIT
    } // Prf_100_Type0

    private void Prf_101_Type1 () {
      m_LocDef.Ws_1_Lg_Cle.Value = m_LocDef.P_K.IntValue;
      WriteSequentialFile(Fic_Format, m_Fd_Lgn_For, m_LocDef.Ws_Don_1.Value);
    lab_101_Exit: { }
      // Cobol EXIT
    } // Prf_101_Type1

    private void Prf_102_Type2 () {
      while (!(Substring(m_LocDef.Lgn_Rep.Value, 1, 7) == "Columns")) {
        CancellationToken.ThrowIfCancellationRequested();
        Prf_200_Lec_Report();
      }
      for (Int32 I_Loop_207 = 2; I_Loop_207 > 0; I_Loop_207--) {
        Prf_200_Lec_Report();
      }
      m_LocDef.Cpt_Char.IntValue = 0;
      m_LocDef.Cpt_Char.IntValue = m_LocDef.Cpt_Char.IntValue + AmtInspect.Count(m_LocDef.Lgn_Rep.Value, AmtInspectOption.Chars, AmtBeforeAfter.Before, "Allowed");
      m_LocDef.I_Buf.IntValue = m_LocDef.Cpt_Char.IntValue;
      Prf_200_Lec_Report();
      for (Int32 I_Loop_214 = 2; I_Loop_214 > 0; I_Loop_214--) {
        Prf_201_Lec_Descript();
      }
      m_LocDef.Cpt_Char.IntValue = 0;
      m_LocDef.Cpt_Char.IntValue = m_LocDef.Cpt_Char.IntValue + AmtInspect.Count(m_LocDef.Lgn_Des.Value, AmtInspectOption.Chars, AmtBeforeAfter.Before, "TION.");
      m_LocDef.Cpt_Char.IntValue = m_LocDef.Cpt_Char.IntValue + 6;
      for (Int32 I_Loop_220 = m_LocDef.P_T.ToInt32(); I_Loop_220 > 0; I_Loop_220--) {
        Prf_102_Col();
      }
    lab_102_Exit: { }
      // Cobol EXIT
    } // Prf_102_Type2

    private void Prf_102_Col () {
      m_LocDef.Ws_2_Nm_Chp.Value = Substring(m_LocDef.Lgn_Des.Value, m_LocDef.Cpt_Char.IntValue, 30);
      m_LocDef.Ws_2_Typ_Chp.Value = Substring(m_LocDef.Lgn_Des.Value, 6, 7);
      m_LocDef.Ws_2_Lg_Chp.Value = Substring(m_LocDef.Lgn_Des.Value, 13, 10);
      m_LocDef.Table_Null.Value = m_LocDef.Lgn_Rep.Value;
      m_LocDef.I.IntValue = m_LocDef.I_Buf.IntValue + 3;
      m_LocDef.Fl_Null.IntValue = 0;
      m_LocDef.I_Tot.IntValue = m_LocDef.I.IntValue + 2;
      while (!(m_LocDef.I.IntValue >= m_LocDef.I_Tot.IntValue)) {
        CancellationToken.ThrowIfCancellationRequested();
        Prf_102_Null();
      }
      if (m_LocDef.Fl_Null.IntValue == 1) {
        m_LocDef.Ws_2_Null.StrValue = "NULL";
      } else {
        m_LocDef.Ws_2_Null.StrValue = AmtConstRuntime.SpacesValueString;
      }
      WriteSequentialFile(Fic_Format, m_Fd_Lgn_For, m_LocDef.Ws_Don_2.Value);
      Prf_200_Lec_Report();
      Prf_201_Lec_Descript();
    lab_102_Col_Exit: { }
      // Cobol EXIT
    } // Prf_102_Col

    private void Prf_102_Null () {
      if (m_LocDef.Tnull[m_LocDef.I.IntValue].Value == 'Y') {
        m_LocDef.I.IntValue = m_LocDef.I.IntValue + 1;
        if (m_LocDef.Tnull[m_LocDef.I.IntValue].Value == 'E') {
          m_LocDef.Fl_Null.IntValue = 1;
        }
      }
      m_LocDef.I.IntValue = m_LocDef.I.IntValue + 1;
    lab_102_Null_Exit: { }
      // Cobol EXIT
    } // Prf_102_Null

    private void Prf_103_Type3 () {
      while (!(Substring(m_LocDef.Lgn_Rep.Value, 1, 13) == "Primary Key :")) {
        CancellationToken.ThrowIfCancellationRequested();
        Prf_200_Lec_Report();
      }
      m_LocDef.Cpt_Char.IntValue = 0;
      m_LocDef.Cpt_Char.IntValue = m_LocDef.Cpt_Char.IntValue + AmtInspect.Count(m_LocDef.Lgn_Rep.Value, AmtInspectOption.Chars, AmtBeforeAfter.Before, "PK_");
      m_LocDef.Cpt_Char.IntValue = m_LocDef.Cpt_Char.IntValue + 1;
      m_LocDef.Ws_3_Nm_Idx.Value = Substring(m_LocDef.Lgn_Rep.Value, m_LocDef.Cpt_Char.IntValue, 30);
      for (Int32 I_Loop_260 = 2; I_Loop_260 > 0; I_Loop_260--) {
        Prf_200_Lec_Report();
      }
      while (!(Substring(m_LocDef.Lgn_Rep.Value, 1, 10) == AmtConstRuntime.SpacesValueString)) {
        CancellationToken.ThrowIfCancellationRequested();
        Prf_103_Col();
      }
    lab_103_Exit: { }
      // Cobol EXIT
    } // Prf_103_Type3

    private void Prf_103_Col () {
      m_LocDef.Cpt_Char.IntValue = 0;
      m_LocDef.Cpt_Char.IntValue = m_LocDef.Cpt_Char.IntValue + AmtInspect.Count(m_LocDef.Lgn_Rep.Value, AmtInspectOption.Chars, AmtBeforeAfter.Before, ",");
      m_LocDef.Cpt_Char.IntValue = m_LocDef.Cpt_Char.IntValue - 4;
      m_LocDef.Ws_3_Nm_Chp.Value = Substring(m_LocDef.Lgn_Rep.Value, 5, m_LocDef.Cpt_Char.IntValue);
      m_LocDef.Cpt_Char.IntValue = m_LocDef.Cpt_Char.IntValue + 7;
      m_LocDef.Ws_3_Tri.Value = Substring(m_LocDef.Lgn_Rep.Value, m_LocDef.Cpt_Char.IntValue, 3);
      WriteSequentialFile(Fic_Format, m_Fd_Lgn_For, m_LocDef.Ws_Don_3.Value);
      Prf_200_Lec_Report();
    lab_103_Col_Exit: { }
      // Cobol EXIT
    } // Prf_103_Col

    private void Prf_104_Type4 () {
      while (!(m_LocDef.Unloadf.IntValue == 1)) {
        CancellationToken.ThrowIfCancellationRequested();
        Prf_104_Rec();
      }
    lab_104_Exit: { }
      // Cobol EXIT
    } // Prf_104_Type4

    private void Prf_104_Rec () {
      Prf_202_Lec_Unload();
      if (m_LocDef.Unloadf.IntValue != 1) {
        WriteSequentialFile(Fic_Format, m_Fd_Lgn_For, m_LocDef.Ws_Don_4.Value);
        m_LocDef.Cpt_Ach.Add(1);
      }
    lab_104_Rec_Exit: { }
      // Cobol EXIT
    } // Prf_104_Rec

    private void Prf_105_Type9 () {
      m_LocDef.Ws_9_Dt_Ach.Value = AcceptDate("YYYYMMDD");
      m_LocDef.Ws_9_Cpt_Ach.Value = m_LocDef.Cpt_Ach.IntValue;
      WriteSequentialFile(Fic_Format, m_Fd_Lgn_For, m_LocDef.Ws_Don_9.Value);
    lab_105_Exit: { }
      // Cobol EXIT
    } // Prf_105_Type9

    private void Prf_106_Tot () {
      m_LocDef.Cpt_Achf.Value = m_LocDef.Cpt_Ach.Value;
      m_LocDef.Cpt_Luf.Value = m_LocDef.Cpt_Lu.Value;
      m_LocDef.Dt_I.Value = m_LocDef.Ws_0_Dt_Ach.ToStructureValue();
      m_LocDef.Aa_Fr.Value = m_LocDef.Aa_I.Value;
      m_LocDef.Mm_Fr.Value = m_LocDef.Mm_I.Value;
      m_LocDef.Jj_Fr.Value = m_LocDef.Jj_I.Value;
      OS2200.Display(NoTrunc("ARCHIFORMAT          RAPPORT          ") & NoTrunc(m_LocDef.Dt_Fr.Value), true);
      OS2200.Display(NoTrunc("Enregistrements lus:") & NoTrunc(m_LocDef.Cpt_Luf.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("Enregistrements 4 \u00E9crits:") & NoTrunc(m_LocDef.Cpt_Achf.ToAlphaValue()), true);
    lab_106_Exit: { }
      // Cobol EXIT
    } // Prf_106_Tot

    private void Prf_200_Lec_Report () {
      if (!ReadSequentialFile(Fic_Report, m_Fd_Fic_Report_Rec)) {
        OS2200.Display(NoTrunc("fin du report"), true);
        goto lab_200_Exit;
      }
      m_LocDef.Lgn_Rep.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Cp_Len.IntValue = m_LocDef.Ws_Rep_Len.IntValue;
      if (m_LocDef.Cp_Len.IntValue > 132) {
        m_LocDef.Cp_Len.IntValue = 132;
      }
      if (m_LocDef.Cp_Len.IntValue > 0) {
        m_LocDef.Lgn_Rep.Replace(1, Substring(m_Fd_Fic_Report_Rec.Fic_Report_Rec.ToAlphaValue(), 1, m_LocDef.Cp_Len.IntValue), m_LocDef.Cp_Len.IntValue);
      }
    lab_200_Exit: { }
      // Cobol EXIT
    } // Prf_200_Lec_Report

    private void Prf_201_Lec_Descript () {
      if (!ReadSequentialFile(Fic_Descript, m_Fd_Fic_Descript_Rec)) {
        OS2200.Display(NoTrunc("fin de la description"), true);
        goto lab_201_Exit;
      }
      m_LocDef.Lgn_Des.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Cp_Len.IntValue = m_LocDef.Ws_Des_Len.IntValue;
      if (m_LocDef.Cp_Len.IntValue > 132) {
        m_LocDef.Cp_Len.IntValue = 132;
      }
      if (m_LocDef.Cp_Len.IntValue > 0) {
        m_LocDef.Lgn_Des.Replace(1, Substring(m_Fd_Fic_Descript_Rec.Fic_Descript_Rec.ToAlphaValue(), 1, m_LocDef.Cp_Len.IntValue), m_LocDef.Cp_Len.IntValue);
      }
    lab_201_Exit: { }
      // Cobol EXIT
    } // Prf_201_Lec_Descript

    private void Prf_202_Lec_Unload () {
      m_LocDef.Recin.StrValue = AmtConstRuntime.SpacesValueString;
      if (!ReadSequentialFile(Fic_Unload, m_Fd_Fic_Unload_Rec, m_LocDef.Recin)) {
        m_LocDef.Unloadf.IntValue = 1;
        goto lab_202_Exit;
      }
      m_LocDef.Ws_Unl.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Cp_Len.IntValue = m_LocDef.Ws_Unl_Len.IntValue;
      if (m_LocDef.Cp_Len.IntValue > m_LocDef.P_B.IntValue) {
        m_LocDef.Cp_Len.IntValue = m_LocDef.P_B.IntValue;
      }
      if (m_LocDef.Cp_Len.IntValue > 0) {
        m_LocDef.Ws_Unl.Replace(1, Substring(m_LocDef.Recin.ToAlphaValue(), 1, m_LocDef.Cp_Len.IntValue), m_LocDef.Cp_Len.IntValue);
      }
      m_LocDef.Ws_4_Don.Replace(1, Substring(m_LocDef.Ws_Unl.ToAlphaValue(), 1, m_LocDef.P_E.IntValue), m_LocDef.P_E.IntValue);
      m_LocDef.Ws_4_Don.Replace(m_LocDef.P_D.ToInt32(), Substring(m_LocDef.Ws_Unl.ToAlphaValue(), m_LocDef.P_C.IntValue, m_LocDef.P_T.IntValue), m_LocDef.P_T.IntValue);
      m_LocDef.Cpt_Lu.Add(1);
    lab_202_Exit: { }
      // Cobol EXIT
    } // Prf_202_Lec_Unload

  } // Class Archiformat_Gn

} // Namespace Federale.BSP.BusinessLogic.Archiformat_Gn

