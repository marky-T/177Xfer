using System.Diagnostics;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;
using Federale.BSP.BusinessLogic.Database;

namespace Federale.BSP.BusinessLogic.Chaban_Gn {

  public sealed partial class Chaban_Gn {
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
        m_LocDef.P_Card.IntValue = m_Fd_Parm_File_Rec.Pf_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "OU") {
        m_LocDef.P_Len.IntValue = m_Fd_Parm_File_Rec.Pf_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "NB") {
        m_LocDef.N_Rec.IntValue = m_Fd_Parm_Nb_Rec.Pn_Rec.IntValue;
        m_LocDef.N_Per.IntValue = m_Fd_Parm_Nb_Rec.Pn_Per.IntValue;
      }
      goto lab_Parm_Lect;
    lab_Parm_Fin:
      CloseFile(Parmf);
      OpenFile(Fi1, AmtCobolFileOpenMode.Input, false);
      OpenFile(Fo1, AmtCobolFileOpenMode.Output, false);
      m_LocDef.R.IntValue = 0;
    lab_Rec_Loop:
      if (m_LocDef.R.IntValue >= m_LocDef.N_Rec.IntValue) {
        goto lab_Finw;
      }
      m_LocDef.Ws_Rec.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Kp.IntValue = 1;
      m_LocDef.C.IntValue = 0;
    lab_Card_Loop:
      if (m_LocDef.C.IntValue >= m_LocDef.N_Per.IntValue) {
        goto lab_Rec_Write;
      }
      m_LocDef.Recin.StrValue = AmtConstRuntime.SpacesValueString;
      if (!ReadSequentialFile(Fi1, m_Fd_Fi1_Rec, m_LocDef.Recin)) {
        goto lab_Finw;
      }
      m_LocDef.Nb_Cards.IntValue = m_LocDef.Nb_Cards.IntValue + 1;
      m_LocDef.Cp_Len.IntValue = m_LocDef.Ws_In_Len.IntValue;
      if (m_LocDef.Cp_Len.IntValue > m_LocDef.P_Card.IntValue) {
        m_LocDef.Cp_Len.IntValue = m_LocDef.P_Card.IntValue;
      }
      if (m_LocDef.Cp_Len.IntValue > 0) {
        m_LocDef.Ws_Rec.Replace(m_LocDef.Kp.ToInt32(), Substring(m_LocDef.Recin.ToAlphaValue(), 1, m_LocDef.Cp_Len.IntValue), m_LocDef.Cp_Len.IntValue);
      }
      m_LocDef.Kp.IntValue = m_LocDef.Kp.IntValue + m_LocDef.P_Card.IntValue;
      m_LocDef.C.IntValue = m_LocDef.C.IntValue + 1;
      goto lab_Card_Loop;
    lab_Rec_Write:
      WriteSequentialFile(Fo1, m_Fd_Fo1_Rec, m_LocDef.Ws_Rec.Value);
      m_LocDef.Nb_Out.IntValue = m_LocDef.Nb_Out.IntValue + 1;
      m_LocDef.R.IntValue = m_LocDef.R.IntValue + 1;
      goto lab_Rec_Loop;
    lab_Finw:
      m_LocDef.Disp_Message.StrValue = "    DATA CARDS READ     ";
      m_LocDef.Disp_Ct.Value = m_LocDef.Nb_Cards.IntValue;
      OS2200.Display(NoTrunc(m_LocDef.Display_Line.Value), true);
      m_LocDef.Disp_Message.StrValue = "    RECORDS WRITTEN     ";
      m_LocDef.Disp_Ct.Value = m_LocDef.Nb_Out.IntValue;
      OS2200.Display(NoTrunc(m_LocDef.Display_Line.Value), true);
      CloseFile(Fi1);
      CloseFile(Fo1);
      StopRun();
    } // Amt_Main

  } // Class Chaban_Gn

} // Namespace Federale.BSP.BusinessLogic.Chaban_Gn

