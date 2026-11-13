using System;
using System.Diagnostics;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;
using Company.AFBUS_2200COBOL.BusinessLogic.Database;

namespace Company.AFBUS_2200COBOL.BusinessLogic.Scan_Gn {

  public sealed partial class Scan_Gn {
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
      Open_Files();
    } // Main

    private void Open_Files () {
    lab_Parm_Read:
      m_LocDef.M_Name.StrValue = AmtConstRuntime.SpacesValueString;
      OpenFile(Parmf, AmtCobolFileOpenMode.Input, false);
    lab_Parm_Lect:
      if (!ReadSequentialFile(Parmf, m_Fd_Parm_Rec)) {
        goto lab_Parm_Fin;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "IN") {
        m_LocDef.P_Len.IntValue = m_Fd_Parm_Len_Rec.Pl_Len.IntValue;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "MN") {
        m_LocDef.M_Name.Value = m_Fd_Parm_Name_Rec.Pn_Text.Value;
      }
      if (m_Fd_Parm_Rec.P_Type.Value == "MX") {
        m_LocDef.P_Max.IntValue = m_Fd_Parm_Max_Rec.Px_Max.IntValue;
      }
      goto lab_Parm_Lect;
    lab_Parm_Fin:
      CloseFile(Parmf);
      m_LocDef.N_Chunk.IntValue = (m_LocDef.P_Len.IntValue + 99) / 100;
    lab_First_Read:
      OpenFile(Tapein, AmtCobolFileOpenMode.Input, false);
      OpenPrintFile(m_PrnDef.Prt, 0);
    lab_Lr:
      m_LocDef.Recin.StrValue = AmtConstRuntime.SpacesValueString;
      if (!ReadSequentialFile(Tapein, m_Fd_Rec_In, m_LocDef.Recin)) {
        goto lab_End_Out;
      }
      m_LocDef.Rec_Area.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Cp_Len.IntValue = m_LocDef.Ws_In_Len.IntValue;
      if (m_LocDef.Cp_Len.IntValue > m_LocDef.P_Len.IntValue) {
        m_LocDef.Cp_Len.IntValue = m_LocDef.P_Len.IntValue;
      }
      if (m_LocDef.Cp_Len.IntValue > 0) {
        m_LocDef.Rec_Area.Replace(1, Substring(m_LocDef.Recin.ToAlphaValue(), 1, m_LocDef.Cp_Len.IntValue), m_LocDef.Cp_Len.IntValue);
      }
      m_LocDef.Rec_In_Ct.IntValue = m_LocDef.Rec_In_Ct.IntValue + 1;
    lab_Test_Fields:
      if (m_LocDef.P_Max.IntValue > 0 && m_LocDef.Rec_In_Ct.IntValue >= m_LocDef.P_Max.IntValue) {
        goto lab_Lr;
      }
    lab_Found_Rec:
      m_LocDef.Rec_Found_Ct.IntValue = m_LocDef.Rec_Found_Ct.IntValue + 1;
      m_LocDef.Line_Cnt.IntValue = 0;
      m_LocDef.Five_Ct.IntValue = m_LocDef.Five_Ct.IntValue + 1;
      if (m_LocDef.Five_Ct.IntValue > 9) {
        m_LocDef.F_Ct.Value = m_LocDef.Rec_In_Ct.IntValue;
        PrintSourceBuffer(m_PrnDef.Prt, null, m_Fd_Prt_Line.Value, m_LocDef.F_Line.Value, String.Empty, 1);
        m_LocDef.Five_Ct.IntValue = 1;
      } else {
        m_LocDef.Ct_Ct.Value = m_LocDef.Rec_In_Ct.IntValue;
        PrintSourceBuffer(m_PrnDef.Prt, null, m_Fd_Prt_Line.Value, m_LocDef.Ct_Line.Value, String.Empty, 1);
      }
      m_LocDef.Line_Cnt.IntValue = m_LocDef.Line_Cnt.IntValue + 1;
      m_LocDef.Skip.IntValue = 1;
      m_LocDef.K.IntValue = 1;
    lab_Print_Chunk:
      if (m_LocDef.K.IntValue > m_LocDef.N_Chunk.IntValue) {
        goto lab_Print_End;
      }
      m_LocDef.Kp.IntValue = (m_LocDef.K.IntValue - 1) * 100 + 1;
      m_LocDef.Ws_Chunk.Value = Substring(m_LocDef.Rec_Area.Value, m_LocDef.Kp.IntValue, 100);
      PrintSourceBuffer(m_PrnDef.Prt, null, m_Fd_Prt_Line.Value, m_LocDef.Ws_Chunk.Value, String.Empty, m_LocDef.Skip.IntValue);
      m_LocDef.Line_Cnt.IntValue = m_LocDef.Line_Cnt.IntValue + 1;
      m_LocDef.Skip.IntValue = 1;
      m_LocDef.K.IntValue = m_LocDef.K.IntValue + 1;
      goto lab_Print_Chunk;
    lab_Print_End:
      m_LocDef.Rec_Area.StrValue = AmtConstRuntime.SpacesValueString;
      m_LocDef.Skip.IntValue = 1;
      goto lab_Lr;
    lab_End_Out:
      m_LocDef.M_Ct.Value = m_LocDef.Rec_In_Ct.IntValue;
      m_LocDef.Fn_Ct.Value = m_LocDef.Rec_Found_Ct.IntValue;
      PrintSourceBuffer(m_PrnDef.Prt, null, m_Fd_Prt_Line.Value, m_LocDef.M_Line.Value, String.Empty, 10);
      CloseFile(Tapein);
      ClosePrintFile(m_PrnDef.Prt);
      StopRun();
    } // Open_Files

  } // Class Scan_Gn

} // Namespace Company.AFBUS_2200COBOL.BusinessLogic.Scan_Gn

