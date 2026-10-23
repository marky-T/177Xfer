using System.Diagnostics;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;
using Federale.AFBUS.BusinessLogic.Database;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Condis2_Gn {

  public sealed partial class Assurfed_Utilit_Condis2_Gn {
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
      if (m_Fd_Parm_Rec.P_Type.Value == "FI") {
        m_LocDef.P_Inlen.IntValue = m_Fd_Parm_Len_Rec.Pl_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "FO") {
        m_LocDef.P_Outlen.IntValue = m_Fd_Parm_Len_Rec.Pl_Len.IntValue;
      }
      m_TestA = m_Fd_Parm_Rec.P_Type.ToString();
      if (m_TestA == "CA" || m_TestA == "OT" || m_TestA == "NG") {
        m_LocDef.N_Grp.IntValue = m_LocDef.N_Grp.IntValue + 1;
        m_LocDef.G_Kind[m_LocDef.N_Grp.IntValue].Value = Substring(m_Fd_Parm_Rec.P_Type.Value, 1, 1);
        m_LocDef.G_Cn[m_LocDef.N_Grp.IntValue].Value = 0;
        m_LocDef.G_T1[m_LocDef.N_Grp.IntValue].IntValue = m_LocDef.N_Ts.IntValue + 1;
        m_LocDef.G_Tn[m_LocDef.N_Grp.IntValue].IntValue = m_LocDef.N_Ts.IntValue;
        m_LocDef.G_O1[m_LocDef.N_Grp.IntValue].IntValue = m_LocDef.N_Op.IntValue + 1;
        m_LocDef.G_On[m_LocDef.N_Grp.IntValue].IntValue = m_LocDef.N_Op.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "CA") {
        m_LocDef.N_Case.IntValue = m_LocDef.N_Case.IntValue + 1;
        m_LocDef.G_Cn[m_LocDef.N_Grp.IntValue].IntValue = m_LocDef.N_Case.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "OT") {
        m_LocDef.N_Oth.IntValue = m_LocDef.N_Oth.IntValue + 1;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "TS") {
        m_LocDef.N_Ts.IntValue = m_LocDef.N_Ts.IntValue + 1;
        m_LocDef.T_Pos[m_LocDef.N_Ts.IntValue].IntValue = m_Fd_Parm_Val_Rec.Pv_Pos.IntValue;
        m_LocDef.T_Len[m_LocDef.N_Ts.IntValue].IntValue = m_Fd_Parm_Val_Rec.Pv_Len.IntValue;
        m_LocDef.T_Val[m_LocDef.N_Ts.IntValue].Value = m_Fd_Parm_Val_Rec.Pv_Txt.Value;
        m_LocDef.G_Tn[m_LocDef.N_Grp.IntValue].IntValue = m_LocDef.N_Ts.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "MV") {
        m_LocDef.N_Op.IntValue = m_LocDef.N_Op.IntValue + 1;
        m_LocDef.O_Type[m_LocDef.N_Op.IntValue].StrValue = "M";
        m_LocDef.O_Is[m_LocDef.N_Op.IntValue].IntValue = m_Fd_Parm_Move_Rec.Pm_Is.IntValue;
        m_LocDef.O_Il[m_LocDef.N_Op.IntValue].IntValue = m_Fd_Parm_Move_Rec.Pm_Il.IntValue;
        m_LocDef.O_Os[m_LocDef.N_Op.IntValue].IntValue = m_Fd_Parm_Move_Rec.Pm_Os.IntValue;
        m_LocDef.O_Ol[m_LocDef.N_Op.IntValue].IntValue = m_Fd_Parm_Move_Rec.Pm_Ol.IntValue;
        m_LocDef.O_Code[m_LocDef.N_Op.IntValue].Value = m_Fd_Parm_Move_Rec.Pm_Code.Value;
        m_LocDef.G_On[m_LocDef.N_Grp.IntValue].IntValue = m_LocDef.N_Op.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "CO") {
        m_LocDef.N_Op.IntValue = m_LocDef.N_Op.IntValue + 1;
        m_LocDef.N_Co.IntValue = m_LocDef.N_Co.IntValue + 1;
        m_LocDef.O_Type[m_LocDef.N_Op.IntValue].StrValue = "K";
        m_LocDef.O_Os[m_LocDef.N_Op.IntValue].IntValue = m_Fd_Parm_Val_Rec.Pv_Pos.IntValue;
        m_LocDef.O_Ol[m_LocDef.N_Op.IntValue].IntValue = m_Fd_Parm_Val_Rec.Pv_Len.IntValue;
        m_LocDef.Co_Val[m_LocDef.N_Co.IntValue].Value = m_Fd_Parm_Val_Rec.Pv_Txt.Value;
        m_LocDef.O_Cx[m_LocDef.N_Op.IntValue].IntValue = m_LocDef.N_Co.IntValue;
        m_LocDef.G_On[m_LocDef.N_Grp.IntValue].IntValue = m_LocDef.N_Op.IntValue;
      }
      goto lab_Parm_Lect;
    lab_Parm_Fin:
      CloseFile(Parmf);
      OpenFile(Fi1, AmtCobolFileOpenMode.Input, false);
      OpenFile(Fo1, AmtCobolFileOpenMode.Output, false);
      m_LocDef.Nb_Rec_Lu.IntValue = 0;
      m_LocDef.Nb_Rec_Ecrit.IntValue = 0;
      m_LocDef.Nb_Rec_Nonecrit.Value = 0;
      m_LocDef.Nb_Rec_Transforme_22a_200x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_22a_201x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_22a_202x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_22a_203x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_22b_200x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_22b_201x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_22b_202x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_22b_203x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_66a_200x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_66a_201x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_66a_202x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_66a_203x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_66b_200x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_66b_201x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_66b_202x.IntValue = 0;
      m_LocDef.Nb_Rec_Transforme_66b_203x.IntValue = 0;
      m_LocDef.Nb_Rec_Case_0.IntValue = 0;
      m_LocDef.Nb_Case_Tab.Value = AmtConstRuntime.ZerosValueString;
      m_LocDef.Nb_Rec_Other.IntValue = 0;
    lab_Trt:
      m_LocDef.Recin.StrValue = AmtConstRuntime.SpacesValueString;
      if (!ReadSequentialFile(Fi1, m_Fd_Fi1_Rec, m_LocDef.Recin)) {
        goto lab_Fin_Trt;
      }
      m_LocDef.Ws_In.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Cp_Len.IntValue = m_LocDef.Ws_In_Len.IntValue;
      if (m_LocDef.Cp_Len.IntValue > m_LocDef.P_Inlen.IntValue) {
        m_LocDef.Cp_Len.IntValue = m_LocDef.P_Inlen.IntValue;
      }
      if (m_LocDef.Cp_Len.IntValue > 0) {
        m_LocDef.Ws_In.Replace(1, Substring(m_LocDef.Recin.ToAlphaValue(), 1, m_LocDef.Cp_Len.IntValue), m_LocDef.Cp_Len.IntValue);
      }
      m_LocDef.Ws_Out.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Ws_Record_Transforme_22a_200x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_22a_201x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_22a_202x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_22a_203x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_22b_200x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_22b_201x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_22b_202x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_22b_203x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_66a_200x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_66a_201x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_66a_202x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_66a_203x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_66b_200x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_66b_201x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_66b_202x.StrValue = "N";
      m_LocDef.Ws_Record_Transforme_66b_203x.StrValue = "N";
      m_LocDef.Nb_Rec_Lu.IntValue = m_LocDef.Nb_Rec_Lu.IntValue + 1;
      m_LocDef.G.IntValue = 0;
    lab_Grp_Next:
      m_LocDef.G.IntValue = m_LocDef.G.IntValue + 1;
      if (m_LocDef.G.IntValue > m_LocDef.N_Grp.IntValue) {
        goto lab_Grp_End;
      }
      m_LocDef.J.IntValue = m_LocDef.G_T1[m_LocDef.G.IntValue].IntValue;
    lab_Tst_Loop:
      if (m_LocDef.G_Kind[m_LocDef.G.IntValue].Value != 'C') {
        goto lab_Op_Start;
      }
      if (m_LocDef.J.IntValue > m_LocDef.G_Tn[m_LocDef.G.IntValue].IntValue) {
        goto lab_Op_Start;
      }
      if (Substring(m_LocDef.Ws_In.Value, m_LocDef.T_Pos[m_LocDef.J.IntValue].IntValue, m_LocDef.T_Len[m_LocDef.J.IntValue].IntValue) != Substring(m_LocDef.T_Val[m_LocDef.J.IntValue].Value, 1, m_LocDef.T_Len[m_LocDef.J.IntValue].IntValue)) {
        goto lab_Grp_Next;
      }
      m_LocDef.J.IntValue = m_LocDef.J.IntValue + 1;
      goto lab_Tst_Loop;
    lab_Op_Start:
      m_LocDef.I.IntValue = m_LocDef.G_O1[m_LocDef.G.IntValue].IntValue;
    lab_Op_Loop:
      if (m_LocDef.I.IntValue > m_LocDef.G_On[m_LocDef.G.IntValue].IntValue) {
        goto lab_Op_End;
      }
      if (m_LocDef.O_Type[m_LocDef.I.IntValue].Value == 'K') {
        m_LocDef.Ws_Out.Replace(m_LocDef.O_Os[m_LocDef.I.IntValue].ToInt32(), Substring(m_LocDef.Co_Val[m_LocDef.O_Cx[m_LocDef.I.IntValue].IntValue].Value, 1, m_LocDef.O_Ol[m_LocDef.I.IntValue].IntValue), m_LocDef.O_Ol[m_LocDef.I.IntValue].IntValue);
      } else if (m_LocDef.O_Code[m_LocDef.I.IntValue].Value == AmtConstRuntime.SpacesValueString) {
        m_LocDef.Ws_Out.Replace(m_LocDef.O_Os[m_LocDef.I.IntValue].ToInt32(), Substring(m_LocDef.Ws_In.ToAlphaValue(), m_LocDef.O_Is[m_LocDef.I.IntValue].IntValue, m_LocDef.O_Il[m_LocDef.I.IntValue].IntValue), m_LocDef.O_Ol[m_LocDef.I.IntValue].IntValue);
      } else {
        Prf_Date_Op();
      }
      m_LocDef.I.IntValue = m_LocDef.I.IntValue + 1;
      goto lab_Op_Loop;
    lab_Op_End:
      if (m_LocDef.G_Kind[m_LocDef.G.IntValue].Value == 'N') {
        goto lab_Grp_Next;
      }
      if (m_LocDef.G_Kind[m_LocDef.G.IntValue].Value == 'C') {
        m_LocDef.Nb_Case[m_LocDef.G_Cn[m_LocDef.G.IntValue].IntValue].Add(1);
      } else {
        m_LocDef.Nb_Rec_Other.IntValue = m_LocDef.Nb_Rec_Other.IntValue + 1;
      }
      Prf_Write_Rec_Output();
      goto lab_Trt;
    lab_Grp_End:
      /* *    no group matched: written only when the call has no CASE and
       * *    no OTHERWISE (CASE-NON-PREVU otherwise).
       */
      if (m_LocDef.N_Case.IntValue == 0 && m_LocDef.N_Oth.IntValue == 0) {
        m_LocDef.Nb_Rec_Case_0.IntValue = m_LocDef.Nb_Rec_Case_0.IntValue + 1;
        Prf_Write_Rec_Output();
      }
      goto lab_Trt;
    lab_Date_Op:
      Prf_Date_Op();
    lab_Fin_Trt:
      OS2200.Display(NoTrunc("NB ENREGISTREMENTS LUS    = ") & NoTrunc(m_LocDef.Nb_Rec_Lu.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB ENREGISTREMENTS ECRITS = ") & NoTrunc(m_LocDef.Nb_Rec_Ecrit.ToAlphaValue()), true);
      m_LocDef.Nb_Rec_Nonecrit.IntValue = m_LocDef.Nb_Rec_Lu.IntValue - m_LocDef.Nb_Rec_Ecrit.IntValue;
      if (m_LocDef.Nb_Rec_Nonecrit.Value > 0) {
        OS2200.Display(NoTrunc("*******************************"), true);
        OS2200.Display(NoTrunc("*   attention                 *"), true);
        OS2200.Display(NoTrunc("*   certains records ne       *"), true);
        OS2200.Display(NoTrunc("*   respectent aucun case     *"), true);
        OS2200.Display(NoTrunc("*   et ne figurent donc pas   *"), true);
        OS2200.Display(NoTrunc("*   sur le fichier output     *"), true);
        OS2200.Display(NoTrunc("*******************************"), true);
      }
      m_LocDef.J.IntValue = 1;
    lab_Dsp_Case:
      if (m_LocDef.J.IntValue > m_LocDef.N_Case.IntValue) {
        goto lab_Dsp_End;
      }
      m_LocDef.Ws_N2.IntValue = m_LocDef.J.IntValue;
      if (m_LocDef.J.IntValue < 10) {
        OS2200.Display(NoTrunc("NB ENREGISTREMENTS CONDITION NO ") & NoTrunc(Substring(m_LocDef.Ws_N2.ToAlphaValue(), 2, 1)) & NoTrunc(" = ") & NoTrunc(m_LocDef.Nb_Case[m_LocDef.J.IntValue].ToAlphaValue()), true);
      } else {
        OS2200.Display(NoTrunc("NB ENREGISTREMENTS CONDITION NO ") & NoTrunc(m_LocDef.Ws_N2.ToAlphaValue()) & NoTrunc(" = ") & NoTrunc(m_LocDef.Nb_Case[m_LocDef.J.IntValue].ToAlphaValue()), true);
      }
      m_LocDef.J.IntValue = m_LocDef.J.IntValue + 1;
      goto lab_Dsp_Case;
    lab_Dsp_End:
      OS2200.Display(NoTrunc("NB ENREGISTREMENTS OTHER = ") & NoTrunc(m_LocDef.Nb_Rec_Other.ToAlphaValue()), true);
      OS2200.Display(NoTrunc(" "), true);
      OS2200.Display(NoTrunc(" "), true);
      OS2200.Display(NoTrunc(" "), true);
      OS2200.Display(NoTrunc(" "), true);

      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (22A) 0X --> ;X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_22a_200x.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (22A) 1X --> _X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_22a_201x.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (22A) 2X --> |X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_22a_202x.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (22A) 3X --> ~X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_22a_203x.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (22B) ;X --> 0X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_22b_200x.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (22B) _X --> 1X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_22b_201x.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (22B) |X --> 2X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_22b_202x.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (22B) ~X --> 3X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_22b_203x.ToAlphaValue()), true);

      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (66A) 0X --> ;X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_66a_200x.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (66A) 1X --> _X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_66a_201x.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (66A) 2X --> |X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_66a_202x.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (66A) 3X --> ~X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_66a_203x.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (66B) ;X --> 0X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_66b_200x.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (66B) _X --> 1X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_66b_201x.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (66B) |X --> 2X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_66b_202x.ToAlphaValue()), true);
      OS2200.Display(NoTrunc("NB RECORDS AYANT SUBI TRANSFO (66B) ~X --> 3X    = ") & NoTrunc(m_LocDef.Nb_Rec_Transforme_66b_203x.ToAlphaValue()), true);

      CloseFile(Fi1);
      CloseFile(Fo1);
      StopRun();
    lab_Transfo_Date_4_2:
      Prf_Transfo_Date_4_2();
    lab_Transfo_Date_2_4:
      Prf_Transfo_Date_2_4();
    lab_Transfo_Date_22a:
      Prf_Transfo_Date_22a();
    lab_Transfo_Date_66a:
      Prf_Transfo_Date_66a();
    lab_Transfo_Date_66b:
      Prf_Transfo_Date_66b();
    lab_Transfo_Date_68:
      Prf_Transfo_Date_68();
    lab_Transfo_Date_86:
      Prf_Transfo_Date_86();
    lab_Transfo_Date_22b:
      Prf_Transfo_Date_22b();
    lab_Write_Rec_Output:
      Prf_Write_Rec_Output();
    } // Amt_Main

    private void Prf_Date_Op () {
      if (m_LocDef.O_Code[m_LocDef.I.IntValue].Value == "D42") {
        m_LocDef.Ws_A4.Value = Substring(m_LocDef.Ws_In.Value, m_LocDef.O_Is[m_LocDef.I.IntValue].IntValue, 4);
        Prf_Transfo_Date_4_2();
        m_LocDef.Ws_Out.Replace(m_LocDef.O_Os[m_LocDef.I.IntValue].ToInt32(), m_LocDef.Ws_A2.Value, 2);
      }
      if (m_LocDef.O_Code[m_LocDef.I.IntValue].Value == "D24") {
        m_LocDef.Ws_A2.Value = Substring(m_LocDef.Ws_In.Value, m_LocDef.O_Is[m_LocDef.I.IntValue].IntValue, 2);
        Prf_Transfo_Date_2_4();
        m_LocDef.Ws_Out.Replace(m_LocDef.O_Os[m_LocDef.I.IntValue].ToInt32(), m_LocDef.Ws_A4.Value, 4);
      }
      if (m_LocDef.O_Code[m_LocDef.I.IntValue].Value == "D22A") {
        m_LocDef.Ws_A2.Value = Substring(m_LocDef.Ws_In.Value, m_LocDef.O_Is[m_LocDef.I.IntValue].IntValue, 2);
        Prf_Transfo_Date_22a();
        m_LocDef.Ws_Out.Replace(m_LocDef.O_Os[m_LocDef.I.IntValue].ToInt32(), m_LocDef.Ws_A2.Value, 2);
      }
      if (m_LocDef.O_Code[m_LocDef.I.IntValue].Value == "D22B") {
        m_LocDef.Ws_A2.Value = Substring(m_LocDef.Ws_In.Value, m_LocDef.O_Is[m_LocDef.I.IntValue].IntValue, 2);
        Prf_Transfo_Date_22b();
        m_LocDef.Ws_Out.Replace(m_LocDef.O_Os[m_LocDef.I.IntValue].ToInt32(), m_LocDef.Ws_A2.Value, 2);
      }
      if (m_LocDef.O_Code[m_LocDef.I.IntValue].Value == "D66A") {
        m_LocDef.Ws_A6.Value = Substring(m_LocDef.Ws_In.Value, m_LocDef.O_Is[m_LocDef.I.IntValue].IntValue, 6);
        Prf_Transfo_Date_66a();
        m_LocDef.Ws_Out.Replace(m_LocDef.O_Os[m_LocDef.I.IntValue].ToInt32(), m_LocDef.Ws_A6.Value, 6);
      }
      if (m_LocDef.O_Code[m_LocDef.I.IntValue].Value == "D66B") {
        m_LocDef.Ws_A6.Value = Substring(m_LocDef.Ws_In.Value, m_LocDef.O_Is[m_LocDef.I.IntValue].IntValue, 6);
        Prf_Transfo_Date_66b();
        m_LocDef.Ws_Out.Replace(m_LocDef.O_Os[m_LocDef.I.IntValue].ToInt32(), m_LocDef.Ws_A6.Value, 6);
      }
      if (m_LocDef.O_Code[m_LocDef.I.IntValue].Value == "D68") {
        m_LocDef.Ws_A6.Value = Substring(m_LocDef.Ws_In.Value, m_LocDef.O_Is[m_LocDef.I.IntValue].IntValue, 6);
        Prf_Transfo_Date_68();
        m_LocDef.Ws_Out.Replace(m_LocDef.O_Os[m_LocDef.I.IntValue].ToInt32(), m_LocDef.Ws_A8.Value, 8);
      }
      if (m_LocDef.O_Code[m_LocDef.I.IntValue].Value == "D86") {
        m_LocDef.Ws_A8.Value = Substring(m_LocDef.Ws_In.Value, m_LocDef.O_Is[m_LocDef.I.IntValue].IntValue, 8);
        Prf_Transfo_Date_86();
        m_LocDef.Ws_Out.Replace(m_LocDef.O_Os[m_LocDef.I.IntValue].ToInt32(), m_LocDef.Ws_A6.Value, 6);
      }
    lab_Date_Op_Exit: { }
      // Cobol EXIT
    } // Prf_Date_Op

    private void Prf_Transfo_Date_4_2 () {
      // ******************
      m_LocDef.Ws_A2.Value = m_LocDef.Ws_A4_Aa.Value;
      if ((m_LocDef.Ws_A4.Value > "1999") && (m_LocDef.Ws_A4.Value < "2010")) {
        m_LocDef.Ws_A2_A1.StrValue = ";";
      }
      if ((m_LocDef.Ws_A4.Value > "2009") && (m_LocDef.Ws_A4.Value < "2020")) {
        m_LocDef.Ws_A2_A1.StrValue = "_";
      }
      if ((m_LocDef.Ws_A4.Value > "2019") && (m_LocDef.Ws_A4.Value < "2030")) {
        m_LocDef.Ws_A2_A1.StrValue = "|";
      }
      if ((m_LocDef.Ws_A4.Value > "2029") && (m_LocDef.Ws_A4.Value < "2040")) {
        m_LocDef.Ws_A2_A1.StrValue = "~";
      }
    lab_Transfo_Date_4_2_Exit: { }
      // ******************
      // Cobol EXIT
    } // Prf_Transfo_Date_4_2

    private void Prf_Transfo_Date_2_4 () {
      // ******************
      if (m_LocDef.Ws_A2.Value == "00") {
        m_LocDef.Ws_A4.StrValue = "0000";
        goto lab_Transfo_Date_2_4_Exit;
      }
      if (m_LocDef.Ws_A2.Value == "  ") {
        m_LocDef.Ws_A4.StrValue = "    ";
        goto lab_Transfo_Date_2_4_Exit;
      }
      if (m_LocDef.Ws_A2_A1.Value == ';') {
        m_LocDef.Ws_A4_Ss.StrValue = "20";
        m_LocDef.Ws_A4_A1.StrValue = "0";
        m_LocDef.Ws_A4_A2.Value = m_LocDef.Ws_A2_A2.Value;
        goto lab_Transfo_Date_2_4_Exit;
      }
      if (m_LocDef.Ws_A2_A1.Value == '_') {
        m_LocDef.Ws_A4_Ss.StrValue = "20";
        m_LocDef.Ws_A4_A1.StrValue = "1";
        m_LocDef.Ws_A4_A2.Value = m_LocDef.Ws_A2_A2.Value;
        goto lab_Transfo_Date_2_4_Exit;
      }
      if (m_LocDef.Ws_A2_A1.Value == '|') {
        m_LocDef.Ws_A4_Ss.StrValue = "20";
        m_LocDef.Ws_A4_A1.StrValue = "2";
        m_LocDef.Ws_A4_A2.Value = m_LocDef.Ws_A2_A2.Value;
        goto lab_Transfo_Date_2_4_Exit;
      }
      if (m_LocDef.Ws_A2_A1.Value == '~') {
        m_LocDef.Ws_A4_Ss.StrValue = "20";
        m_LocDef.Ws_A4_A1.StrValue = "3";
        m_LocDef.Ws_A4_A2.Value = m_LocDef.Ws_A2_A2.Value;
        goto lab_Transfo_Date_2_4_Exit;
      }
      m_LocDef.Ws_A4_Ss.StrValue = "19";
      m_LocDef.Ws_A4_Aa.Value = m_LocDef.Ws_A2.Value;
      goto lab_Transfo_Date_2_4_Exit;
    lab_Transfo_Date_2_4_Exit: { }
      // ******************
      // Cobol EXIT
    } // Prf_Transfo_Date_2_4

    private void Prf_Transfo_Date_22a () {
      // ******************
      if (m_LocDef.Ws_A2_A1.Value == '0') {
        m_LocDef.Ws_A2_A1.StrValue = ";";
        m_LocDef.Ws_Record_Transforme_22a_200x.StrValue = "Y";
        goto lab_Transfo_Date_22a_Exit;
      }
      if (m_LocDef.Ws_A2_A1.Value == '1') {
        m_LocDef.Ws_A2_A1.StrValue = "_";
        m_LocDef.Ws_Record_Transforme_22a_201x.StrValue = "Y";
        goto lab_Transfo_Date_22a_Exit;
      }
      if (m_LocDef.Ws_A2_A1.Value == '2') {
        m_LocDef.Ws_A2_A1.StrValue = "|";
        m_LocDef.Ws_Record_Transforme_22a_202x.StrValue = "Y";
        goto lab_Transfo_Date_22a_Exit;
      }
      if (m_LocDef.Ws_A2_A1.Value == '3') {
        m_LocDef.Ws_A2_A1.StrValue = "~";
        m_LocDef.Ws_Record_Transforme_22a_203x.StrValue = "Y";
        goto lab_Transfo_Date_22a_Exit;
      }
    lab_Transfo_Date_22a_Exit: { }
      // ******************
      // Cobol EXIT
    } // Prf_Transfo_Date_22a

    private void Prf_Transfo_Date_66a () {
      // ******************
      if (!IsNumeric(m_LocDef.Ws_A6)) {
        goto lab_Transfo_Date_66a_Exit;
      }
      if ((m_LocDef.Ws_A6_Mm.Value > "15") || (m_LocDef.Ws_A6_Mm.Value == "00")) {
        goto lab_Transfo_Date_66a_Exit;
      }
      if ((m_LocDef.Ws_A6_Jj.Value > "35") || (m_LocDef.Ws_A6_Jj.Value == "00")) {
        goto lab_Transfo_Date_66a_Exit;
      }
      if (m_LocDef.Ws_A6_Y1.Value == '0') {
        m_LocDef.Ws_A6_Y1.StrValue = ";";
        m_LocDef.Ws_Record_Transforme_66a_200x.StrValue = "Y";
        goto lab_Transfo_Date_66a_Exit;
      }
      if (m_LocDef.Ws_A6_Y1.Value == '1') {
        m_LocDef.Ws_A6_Y1.StrValue = "_";
        m_LocDef.Ws_Record_Transforme_66a_201x.StrValue = "Y";
        goto lab_Transfo_Date_66a_Exit;
      }
      if (m_LocDef.Ws_A6_Y1.Value == '2') {
        m_LocDef.Ws_A6_Y1.StrValue = "|";
        m_LocDef.Ws_Record_Transforme_66a_202x.StrValue = "Y";
        goto lab_Transfo_Date_66a_Exit;
      }
      if (m_LocDef.Ws_A6_Y1.Value == '3') {
        m_LocDef.Ws_A6_Y1.StrValue = "~";
        m_LocDef.Ws_Record_Transforme_66a_203x.StrValue = "Y";
        goto lab_Transfo_Date_66a_Exit;
      }
    lab_Transfo_Date_66a_Exit: { }
      // ******************
      // Cobol EXIT
    } // Prf_Transfo_Date_66a

    private void Prf_Transfo_Date_66b () {
      // ******************
      if (m_LocDef.Ws_A6_Y1.Value == ';') {
        m_LocDef.Ws_A6_Y1.StrValue = "0";
        m_LocDef.Ws_Record_Transforme_66b_200x.StrValue = "Y";
        goto lab_Transfo_Date_66b_Exit;
      }
      if (m_LocDef.Ws_A6_Y1.Value == '_') {
        m_LocDef.Ws_A6_Y1.StrValue = "1";
        m_LocDef.Ws_Record_Transforme_66b_201x.StrValue = "Y";
        goto lab_Transfo_Date_66b_Exit;
      }
      if (m_LocDef.Ws_A6_Y1.Value == '|') {
        m_LocDef.Ws_A6_Y1.StrValue = "2";
        m_LocDef.Ws_Record_Transforme_66b_202x.StrValue = "Y";
        goto lab_Transfo_Date_66b_Exit;
      }
      if (m_LocDef.Ws_A6_Y1.Value == '~') {
        m_LocDef.Ws_A6_Y1.StrValue = "3";
        m_LocDef.Ws_Record_Transforme_66b_203x.StrValue = "Y";
        goto lab_Transfo_Date_66b_Exit;
      }
    lab_Transfo_Date_66b_Exit: { }
      // ******************
      // Cobol EXIT
    } // Prf_Transfo_Date_66b

    private void Prf_Transfo_Date_68 () {
      // ******************
      m_LocDef.Ws_A8_Yymmjj.Value = m_LocDef.Ws_A6.Value;
      m_LocDef.Ws_A8_Yy.StrValue = "19";
      if (m_LocDef.Ws_A6.Value == "      ") {
        m_LocDef.Ws_A8.StrValue = "        ";
        goto lab_Transfo_Date_68_Exit;
      }
      if (m_LocDef.Ws_A6.Value == "000000") {
        m_LocDef.Ws_A8.StrValue = "00000000";
        goto lab_Transfo_Date_68_Exit;
      }
      if (m_LocDef.Ws_A6_Y1.Value == ';') {
        m_LocDef.Ws_A8_Yyy.StrValue = "200";
        m_LocDef.Ws_A8_Y4.Value = m_LocDef.Ws_A6_Y2.Value;
        m_LocDef.Ws_A8_Mm.Value = m_LocDef.Ws_A6_Mm.Value;
        m_LocDef.Ws_A8_Jj.Value = m_LocDef.Ws_A6_Jj.Value;
        goto lab_Transfo_Date_68_Exit;
      }
      if (m_LocDef.Ws_A6_Y1.Value == '_') {
        m_LocDef.Ws_A8_Yyy.StrValue = "201";
        m_LocDef.Ws_A8_Y4.Value = m_LocDef.Ws_A6_Y2.Value;
        m_LocDef.Ws_A8_Mm.Value = m_LocDef.Ws_A6_Mm.Value;
        m_LocDef.Ws_A8_Jj.Value = m_LocDef.Ws_A6_Jj.Value;
        goto lab_Transfo_Date_68_Exit;
      }
      if (m_LocDef.Ws_A6_Y1.Value == '|') {
        m_LocDef.Ws_A8_Yyy.StrValue = "202";
        m_LocDef.Ws_A8_Y4.Value = m_LocDef.Ws_A6_Y2.Value;
        m_LocDef.Ws_A8_Mm.Value = m_LocDef.Ws_A6_Mm.Value;
        m_LocDef.Ws_A8_Jj.Value = m_LocDef.Ws_A6_Jj.Value;
        goto lab_Transfo_Date_68_Exit;
      }
      if (m_LocDef.Ws_A6_Y1.Value == '~') {
        m_LocDef.Ws_A8_Yyy.StrValue = "203";
        m_LocDef.Ws_A8_Y4.Value = m_LocDef.Ws_A6_Y2.Value;
        m_LocDef.Ws_A8_Mm.Value = m_LocDef.Ws_A6_Mm.Value;
        m_LocDef.Ws_A8_Jj.Value = m_LocDef.Ws_A6_Jj.Value;
        goto lab_Transfo_Date_68_Exit;
      }
    lab_Transfo_Date_68_Exit: { }
      // ******************
      // Cobol EXIT
    } // Prf_Transfo_Date_68

    private void Prf_Transfo_Date_86 () {
      // ******************
      m_LocDef.Ws_A6.Value = m_LocDef.Ws_A8_Yymmjj.Value;
      if (!IsNumeric(m_LocDef.Ws_A8)) {
        goto lab_Transfo_Date_86_Exit;
      }
      if ((m_LocDef.Ws_A8_Mm.Value > "15") || (m_LocDef.Ws_A8_Mm.Value == "00")) {
        goto lab_Transfo_Date_86_Exit;
      }
      if ((m_LocDef.Ws_A8_Jj.Value > "35") || (m_LocDef.Ws_A8_Jj.Value == "00")) {
        goto lab_Transfo_Date_86_Exit;
      }
      if (m_LocDef.Ws_A8_Yyy.Value == "200") {
        m_LocDef.Ws_A6_Y1.StrValue = ";";
        m_LocDef.Ws_A6_Y2.Value = m_LocDef.Ws_A8_Y4.Value;
        m_LocDef.Ws_A6_Mm.Value = m_LocDef.Ws_A8_Mm.Value;
        m_LocDef.Ws_A6_Jj.Value = m_LocDef.Ws_A8_Jj.Value;
        goto lab_Transfo_Date_86_Exit;
      }
      if (m_LocDef.Ws_A8_Yyy.Value == "201") {
        m_LocDef.Ws_A6_Y1.StrValue = "_";
        m_LocDef.Ws_A6_Y2.Value = m_LocDef.Ws_A8_Y4.Value;
        m_LocDef.Ws_A6_Mm.Value = m_LocDef.Ws_A8_Mm.Value;
        m_LocDef.Ws_A6_Jj.Value = m_LocDef.Ws_A8_Jj.Value;
        goto lab_Transfo_Date_86_Exit;
      }
      if (m_LocDef.Ws_A8_Yyy.Value == "202") {
        m_LocDef.Ws_A6_Y1.StrValue = "|";
        m_LocDef.Ws_A6_Y2.Value = m_LocDef.Ws_A8_Y4.Value;
        m_LocDef.Ws_A6_Mm.Value = m_LocDef.Ws_A8_Mm.Value;
        m_LocDef.Ws_A6_Jj.Value = m_LocDef.Ws_A8_Jj.Value;
        goto lab_Transfo_Date_86_Exit;
      }
      if (m_LocDef.Ws_A8_Yyy.Value == "203") {
        m_LocDef.Ws_A6_Y1.StrValue = "~";
        m_LocDef.Ws_A6_Y2.Value = m_LocDef.Ws_A8_Y4.Value;
        m_LocDef.Ws_A6_Mm.Value = m_LocDef.Ws_A8_Mm.Value;
        m_LocDef.Ws_A6_Jj.Value = m_LocDef.Ws_A8_Jj.Value;
        goto lab_Transfo_Date_86_Exit;
      }
      if (m_LocDef.Ws_A8_Ss.Value == "19") {
        m_LocDef.Ws_A6.Value = m_LocDef.Ws_A8_Yymmjj.Value;
        goto lab_Transfo_Date_86_Exit;
      }
    lab_Transfo_Date_86_Exit: { }
      // ******************
      // Cobol EXIT
    } // Prf_Transfo_Date_86

    private void Prf_Transfo_Date_22b () {
      // ******************
      if (m_LocDef.Ws_A2_A1.Value == ';') {
        m_LocDef.Ws_A2_A1.StrValue = "0";
        m_LocDef.Ws_Record_Transforme_22b_200x.StrValue = "Y";
        goto lab_Transfo_Date_22b_Exit;
      }
      if (m_LocDef.Ws_A2_A1.Value == '_') {
        m_LocDef.Ws_A2_A1.StrValue = "1";
        m_LocDef.Ws_Record_Transforme_22b_201x.StrValue = "Y";
        goto lab_Transfo_Date_22b_Exit;
      }
      if (m_LocDef.Ws_A2_A1.Value == '|') {
        m_LocDef.Ws_A2_A1.StrValue = "2";
        m_LocDef.Ws_Record_Transforme_22b_202x.StrValue = "Y";
        goto lab_Transfo_Date_22b_Exit;
      }
      if (m_LocDef.Ws_A2_A1.Value == '~') {
        m_LocDef.Ws_A2_A1.StrValue = "3";
        m_LocDef.Ws_Record_Transforme_22b_203x.StrValue = "Y";
        goto lab_Transfo_Date_22b_Exit;
      }
    lab_Transfo_Date_22b_Exit: { }
      // ******************
      // Cobol EXIT
    } // Prf_Transfo_Date_22b

    private void Prf_Write_Rec_Output () {
      // *******************
      m_LocDef.Nb_Rec_Ecrit.IntValue = m_LocDef.Nb_Rec_Ecrit.IntValue + 1;
      if (m_LocDef.Ws_Record_Transforme_22a_200x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_22a_200x.IntValue = m_LocDef.Nb_Rec_Transforme_22a_200x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_22a_201x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_22a_201x.IntValue = m_LocDef.Nb_Rec_Transforme_22a_201x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_22a_202x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_22a_202x.IntValue = m_LocDef.Nb_Rec_Transforme_22a_202x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_22a_203x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_22a_203x.IntValue = m_LocDef.Nb_Rec_Transforme_22a_203x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_22b_200x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_22b_200x.IntValue = m_LocDef.Nb_Rec_Transforme_22b_200x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_22b_201x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_22b_201x.IntValue = m_LocDef.Nb_Rec_Transforme_22b_201x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_22b_202x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_22b_202x.IntValue = m_LocDef.Nb_Rec_Transforme_22b_202x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_22b_203x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_22b_203x.IntValue = m_LocDef.Nb_Rec_Transforme_22b_203x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_66a_200x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_66a_200x.IntValue = m_LocDef.Nb_Rec_Transforme_66a_200x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_66a_201x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_66a_201x.IntValue = m_LocDef.Nb_Rec_Transforme_66a_201x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_66a_202x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_66a_202x.IntValue = m_LocDef.Nb_Rec_Transforme_66a_202x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_66a_203x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_66a_203x.IntValue = m_LocDef.Nb_Rec_Transforme_66a_203x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_66b_200x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_66b_200x.IntValue = m_LocDef.Nb_Rec_Transforme_66b_200x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_66b_201x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_66b_201x.IntValue = m_LocDef.Nb_Rec_Transforme_66b_201x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_66b_202x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_66b_202x.IntValue = m_LocDef.Nb_Rec_Transforme_66b_202x.IntValue + 1;
      }
      if (m_LocDef.Ws_Record_Transforme_66b_203x.Value == 'Y') {
        m_LocDef.Nb_Rec_Transforme_66b_203x.IntValue = m_LocDef.Nb_Rec_Transforme_66b_203x.IntValue + 1;
      }

      WriteSequentialFile(Fo1, m_Fd_Fo1_Rec, m_LocDef.Ws_Out.Value);
    lab_Write_Rec_Output_Exit: { }
      // ************************
      // Cobol EXIT
    } // Prf_Write_Rec_Output

  } // Class Assurfed_Utilit_Condis2_Gn

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Condis2_Gn

