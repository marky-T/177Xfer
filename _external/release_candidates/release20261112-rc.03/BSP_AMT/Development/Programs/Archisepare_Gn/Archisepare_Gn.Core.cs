using System.Diagnostics;
using Asysco.Amt.Runtime.Cobol;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;
using Federale.BSP.BusinessLogic.Database;

namespace Federale.BSP.BusinessLogic.Archisepare_Gn {

  public sealed partial class Archisepare_Gn {
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
      if (m_Fd_Parm_Rec.P_Type.Value == "KY") {
        m_LocDef.P_K1.IntValue = m_Fd_Parm_Ky_Rec.Pk_K1.IntValue;
        m_LocDef.P_Off.IntValue = m_Fd_Parm_Ky_Rec.Pk_Off.IntValue;
        m_LocDef.P_K2.IntValue = m_Fd_Parm_Ky_Rec.Pk_K2.IntValue;
        m_LocDef.P_Rsz.IntValue = m_Fd_Parm_Ky_Rec.Pk_Rsz.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "TN") {
        m_LocDef.P_Base.Value = m_Fd_Parm_Tn_Rec.Pt_Base.Value;
        m_LocDef.P_Table.Value = m_Fd_Parm_Tn_Rec.Pt_Table.Value;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "FN") {
        m_LocDef.P_Archi.Value = m_Fd_Parm_Fn_Rec.Pn_Archi.Value;
        m_LocDef.P_Narchi.Value = m_Fd_Parm_Fn_Rec.Pn_Narchi.Value;
      }
      goto lab_Parm_Lect;
    lab_Parm_Fin:
      CloseFile(Parmf);
      m_LocDef.P_Kst.IntValue = m_LocDef.P_Off.IntValue + 1;
      m_LocDef.P_Ksu.IntValue = 19 - m_LocDef.P_K2.IntValue;
      m_LocDef.P_Ksc.IntValue = 19 - m_LocDef.P_K1.IntValue;
      m_LocDef.P_Don.IntValue = 3 + m_LocDef.P_K2.IntValue;
      OpenFile(Fkey, AmtCobolFileOpenMode.Input, false);
      OpenFile(Funl, AmtCobolFileOpenMode.Input, false);
      OpenFile(Farc, AmtCobolFileOpenMode.Output, false);
      OpenFile(Fnar, AmtCobolFileOpenMode.Output, false);
      Prf_Lec_Key();
      Prf_Lec_Unl();
    // * 102-SEPARE: sorted key match, as in the source.
    lab_Separe:
      if (m_LocDef.Lecunloadf.IntValue == 1) {
        goto lab_Type9;
      }
      if (m_LocDef.Lecrchf.IntValue == 1) {
        goto lab_Narchi;
      }
      if (m_LocDef.Key_C_N.IntValue == m_LocDef.Key_U_N.IntValue) {
        goto lab_Archi;
      }
      if (m_LocDef.Key_C_N.IntValue > m_LocDef.Key_U_N.IntValue) {
        goto lab_Narchi;
      }
      Prf_Lec_Key();
      goto lab_Separe;
    lab_Archi:
      m_LocDef.Ws_Out.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Ws_Out.Replace(1, "4A", 2);
      m_LocDef.Ws_Out.Replace(3, Substring(m_LocDef.Key_U_X.ToAlphaValue(), m_LocDef.P_Ksu.IntValue, m_LocDef.P_K2.IntValue), m_LocDef.P_K2.IntValue);
      m_LocDef.Ws_Out.Replace(m_LocDef.P_Don.ToInt32(), Substring(m_LocDef.Ws_Unl.ToAlphaValue(), 1, m_LocDef.P_Rsz.IntValue), m_LocDef.P_Rsz.IntValue);
      WriteSequentialFile(Farc, m_Fd_Farc_Rec, m_LocDef.Ws_Out.Value);
      m_LocDef.Cptarchi.Add(1);
      Prf_Lec_Unl();
      if (m_LocDef.Key_U_N.IntValue != m_LocDef.Key_C_N.IntValue) {
        Prf_Lec_Key();
      }
      goto lab_Separe;
    lab_Narchi:
      m_LocDef.Ws_Out.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Ws_Out.Replace(1, Substring(m_LocDef.Ws_Unl.ToAlphaValue(), 1, m_LocDef.P_Rsz.IntValue), m_LocDef.P_Rsz.IntValue);
      WriteSequentialFile(Fnar, m_Fd_Fnar_Rec, m_LocDef.Ws_Out.Value);
      m_LocDef.Cptnarchi.Add(1);
      Prf_Lec_Unl();
      goto lab_Separe;
      /* * Type-9 trailer: 69 bytes, cut at the record length (32 + rsz)
     * * by the runtime, as WRITE FROM cuts it in the source.
     */
    lab_Type9:
      m_LocDef.Nm_Bas9.Value = m_LocDef.P_Base.Value;
      m_LocDef.Nm_Tab9.Value = m_LocDef.P_Table.Value;
      m_LocDef.Date_I.Value = AcceptDate("YYYYMMDD");
      m_LocDef.Dt_Ach9.Value = m_LocDef.Date_I.Value;
      m_LocDef.Cptach1.Value = m_LocDef.Cptarchi.IntValue;
      m_LocDef.Cptach2.Value = m_LocDef.Cptarchi.IntValue;
      m_LocDef.Ws_Out.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Ws_Out.Replace(1, m_LocDef.Ligne_Type9.Value, 69);
      WriteSequentialFile(Farc, m_Fd_Farc_Rec, m_LocDef.Ws_Out.Value);
      m_LocDef.Annee_Fr.Value = m_LocDef.Annee_I.Value;
      m_LocDef.Mois_Fr.Value = m_LocDef.Mois_I.Value;
      m_LocDef.Jour_Fr.Value = m_LocDef.Jour_I.Value;
      m_LocDef.Cptluf.Value = m_LocDef.Cptlu.Value;
      m_LocDef.Cptarchif.Value = m_LocDef.Cptarchi.Value;
      m_LocDef.Cptnarchif.Value = m_LocDef.Cptnarchi.Value;
      OS2200.Display(NoTrunc("Archisepare              Rapport             ") & NoTrunc(m_LocDef.Date_Fr.Value), true);
      OS2200.Display(NoTrunc(" "), true);
      OS2200.Display(NoTrunc("Enregistrement lu : ") & NoTrunc(m_LocDef.Cptluf.ToAlphaValue()), true);
      m_LocDef.Ws_Msg.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Ws_Ptr.IntValue = 1;
      CobolString(m_LocDef.Ws_Msg, m_LocDef.Ws_Ptr, new AmtCobolStrParam("Enregistrement ecrit dans "), new AmtCobolStrParam(m_LocDef.P_Archi, AmtConstRuntime.SpacesValueString), new AmtCobolStrParam(" : "));
      m_LocDef.Ws_Ptr.IntValue = m_LocDef.Ws_Ptr.IntValue - 1;
      OS2200.Display(NoTrunc(Substring(m_LocDef.Ws_Msg.ToAlphaValue(), 1, m_LocDef.Ws_Ptr.IntValue)) & NoTrunc(m_LocDef.Cptarchif.ToAlphaValue()), true);
      m_LocDef.Ws_Msg.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Ws_Ptr.IntValue = 1;
      CobolString(m_LocDef.Ws_Msg, m_LocDef.Ws_Ptr, new AmtCobolStrParam("Enregistrement ecrit dans "), new AmtCobolStrParam(m_LocDef.P_Narchi, AmtConstRuntime.SpacesValueString), new AmtCobolStrParam(" : "));
      m_LocDef.Ws_Ptr.IntValue = m_LocDef.Ws_Ptr.IntValue - 1;
      OS2200.Display(NoTrunc(Substring(m_LocDef.Ws_Msg.ToAlphaValue(), 1, m_LocDef.Ws_Ptr.IntValue)) & NoTrunc(m_LocDef.Cptnarchif.ToAlphaValue()), true);
      CloseFile(Fkey);
      CloseFile(Funl);
      CloseFile(Farc);
      CloseFile(Fnar);
      StopRun();
    // * 100-LEC-CHERCHEUSE: the key as a number (PIC 9 compare).
    lab_Lec_Key:
      Prf_Lec_Key();
    // * 101-LEC-UNLOAD: the record padded to rsz, and its key.
    lab_Lec_Unl:
      Prf_Lec_Unl();
    } // Amt_Main

    private void Prf_Lec_Key () {
      m_LocDef.Recin.StrValue = AmtConstRuntime.SpacesValueString;
      if (!ReadSequentialFile(Fkey, m_Fd_Fkey_Rec, m_LocDef.Recin)) {
        m_LocDef.Lecrchf.IntValue = 1;
        goto lab_Lec_Key_Exit;
      }
      m_LocDef.Ws_Keyrec.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Cp_Len.IntValue = m_LocDef.Ws_Key_Len.IntValue;
      if (m_LocDef.Cp_Len.IntValue > m_LocDef.P_K1.IntValue) {
        m_LocDef.Cp_Len.IntValue = m_LocDef.P_K1.IntValue;
      }
      if (m_LocDef.Cp_Len.IntValue > 0) {
        m_LocDef.Ws_Keyrec.Replace(1, Substring(m_LocDef.Recin.ToAlphaValue(), 1, m_LocDef.Cp_Len.IntValue), m_LocDef.Cp_Len.IntValue);
      }
      m_LocDef.Key_C_X.Setto("0");
      m_LocDef.Key_C_X.Replace(m_LocDef.P_Ksc.ToInt32(), Substring(m_LocDef.Ws_Keyrec.ToAlphaValue(), 1, m_LocDef.P_K1.IntValue), m_LocDef.P_K1.IntValue);
    lab_Lec_Key_Exit: { }
      // Cobol EXIT
    } // Prf_Lec_Key

    private void Prf_Lec_Unl () {
      m_LocDef.Recin.StrValue = AmtConstRuntime.SpacesValueString;
      if (!ReadSequentialFile(Funl, m_Fd_Funl_Rec, m_LocDef.Recin)) {
        m_LocDef.Lecunloadf.IntValue = 1;
        goto lab_Lec_Unl_Exit;
      }
      m_LocDef.Cptlu.Add(1);
      m_LocDef.Ws_Unl.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Cp_Len.IntValue = m_LocDef.Ws_Unl_Len.IntValue;
      if (m_LocDef.Cp_Len.IntValue > m_LocDef.P_Rsz.IntValue) {
        m_LocDef.Cp_Len.IntValue = m_LocDef.P_Rsz.IntValue;
      }
      if (m_LocDef.Cp_Len.IntValue > 0) {
        m_LocDef.Ws_Unl.Replace(1, Substring(m_LocDef.Recin.ToAlphaValue(), 1, m_LocDef.Cp_Len.IntValue), m_LocDef.Cp_Len.IntValue);
      }
      m_LocDef.Key_U_X.Setto("0");
      m_LocDef.Key_U_X.Replace(m_LocDef.P_Ksu.ToInt32(), Substring(m_LocDef.Ws_Unl.ToAlphaValue(), m_LocDef.P_Kst.IntValue, m_LocDef.P_K2.IntValue), m_LocDef.P_K2.IntValue);
    lab_Lec_Unl_Exit: { }
      // Cobol EXIT
    } // Prf_Lec_Unl

  } // Class Archisepare_Gn

} // Namespace Federale.BSP.BusinessLogic.Archisepare_Gn

