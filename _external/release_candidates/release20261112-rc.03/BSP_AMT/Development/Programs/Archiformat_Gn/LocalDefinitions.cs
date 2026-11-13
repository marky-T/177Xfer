using System.Diagnostics;
using Asysco.Amt.Runtime.Database;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Archiformat_Gn {

  public class LocalDefinitions: AmtBaseDefinitions {
    #region Members
    private Archiformat_Gn m_ParentObject;
    private readonly AmtVarAlpha m_Lgn_Rep;
    /* * The source's 132-byte record areas. Inputs are read at 4001
     * * (T3-040); the areas keep their last record at end of file.
     */
    private readonly AmtVarAlpha m_Lgn_Des;
    private readonly AmtVarNumericBinary9 m_Ws_Rep_Len;
    private readonly AmtVarNumericBinary9 m_Ws_Des_Len;
    private readonly AmtVarAlpha m_Recin;
    private readonly AmtVarAlpha m_Ws_Unl;
    private readonly AmtVarNumericBinary9 m_Ws_Unl_Len;
    private readonly AmtNativeInt m_Cp_Len;
    private readonly AmtNativeInt m_P_K;
    private readonly AmtNativeInt m_P_Rsz;
    private readonly AmtNativeInt m_P_T;
    private readonly AmtNativeInt m_P_B;
    private readonly AmtNativeInt m_P_C;
    private readonly AmtNativeInt m_P_D;
    private readonly AmtNativeInt m_P_E;
    private readonly AmtStructure m_Ws_Don_0;
    // *enregistrement type 0
    private readonly AmtVarAlpha m_Ws_0_Typ;
    private readonly AmtVarAlpha m_Ws_0_Nm_Base;
    private readonly AmtVarAlpha m_Ws_0_Nm_Table;
    private readonly AmtVarNumericOS2200 m_Ws_0_Dt_Ach;
    private readonly AmtStructure m_Ws_0_Dt_Maj;
    private readonly AmtVarNumericOS2200 m_Ws_0_Dt_Maj_Ss;
    private readonly AmtVarNumericOS2200 m_Ws_0_Dt_Maj_Aa;
    private readonly AmtVarNumericOS2200 m_Ws_0_Dt_Maj_Mm;
    private readonly AmtVarNumericOS2200 m_Ws_0_Dt_Maj_Jj;
    private readonly AmtStructure m_Ws_Don_1;
    // *enregistrement type 1
    private readonly AmtVarAlpha m_Ws_1_Typ;
    private readonly AmtVarAlpha m_Ws_1_Nm_Cle;
    private readonly AmtStructure m_Ws_1_Cle;
    private readonly AmtVarAlpha m_Ws_1_Typ_Cle;
    private readonly AmtVarNumericOS2200 m_Ws_1_Lg_Cle;
    private readonly AmtStructure m_Ws_Don_2;
    // *enregistrement type 2
    private readonly AmtVarAlpha m_Ws_2_Typ;
    private readonly AmtVarAlpha m_Ws_2_Nm_Chp;
    private readonly AmtVarAlpha m_Ws_2_Typ_Chp;
    private readonly AmtVarAlpha m_Ws_2_Lg_Chp;
    private readonly AmtVarAlpha m_Ws_2_Null;
    private readonly AmtStructure m_Ws_Don_3;
    // *enregistrement type 3
    private readonly AmtVarAlpha m_Ws_3_Typ;
    private readonly AmtVarAlpha m_Ws_3_Nm_Idx;
    private readonly AmtVarAlpha m_Ws_3_Nm_Chp;
    private readonly AmtVarAlpha m_Ws_3_Tri;
    private readonly AmtStructure m_Ws_Don_4;
    // *enregistrement type 4 (cut at a = b + 1 by the record length)
    private readonly AmtVarAlpha m_Ws_4_Typ;
    private readonly AmtVarAlpha m_Ws_4_Don;
    private readonly AmtStructure m_Ws_Don_9;
    // *enregistrement type 9
    private readonly AmtVarAlpha m_Ws_9_Typ;
    private readonly AmtVarAlpha m_Ws_9_Nm_Base;
    private readonly AmtVarAlpha m_Ws_9_Nm_Table;
    private readonly AmtVarNumericOS2200 m_Ws_9_Dt_Ach;
    private readonly AmtVarNumericOS2200 m_Ws_9_Cpt_Ach;
    private readonly AmtVarAlpha m_Ws_9_Cpt_5;
    private readonly AmtNativeInt m_Unloadf;
    private readonly AmtStructure m_Table_Null;
    private readonly AmtVarAlpha m_Tnull;
    private readonly AmtNativeInt m_I;
    private readonly AmtNativeInt m_I_Buf;
    private readonly AmtNativeInt m_I_Tot;
    private readonly AmtNativeInt m_Fl_Null;
    private readonly AmtNativeInt m_Cpt_Char;
    private readonly AmtVarNumericOS2200 m_Cpt_Ach;
    private readonly AmtVarNumericOS2200 m_Cpt_Lu;
    private readonly AmtVarNumericOS2200 m_Cpt_Achf;
    private readonly AmtVarNumericOS2200 m_Cpt_Luf;
    private readonly AmtStructure m_Dt_I;
    private readonly AmtVarNumericOS2200 m_Aa_I;
    private readonly AmtVarNumericOS2200 m_Mm_I;
    private readonly AmtVarNumericOS2200 m_Jj_I;
    private readonly AmtStructure m_Dt_Fr;
    private readonly AmtVarNumericOS2200 m_Jj_Fr;
    private readonly AmtVarNumericOS2200 m_Mm_Fr;
    private readonly AmtVarNumericOS2200 m_Aa_Fr;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 132</summary>
    public AmtVarAlpha Lgn_Rep { [DebuggerStepThrough()] get { return m_Lgn_Rep; } }

    /// <summary>AmtVarAlpha 132</summary>
    public AmtVarAlpha Lgn_Des { [DebuggerStepThrough()] get { return m_Lgn_Des; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Ws_Rep_Len { [DebuggerStepThrough()] get { return m_Ws_Rep_Len; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Ws_Des_Len { [DebuggerStepThrough()] get { return m_Ws_Des_Len; } }

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Recin { [DebuggerStepThrough()] get { return m_Recin; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Ws_Unl { [DebuggerStepThrough()] get { return m_Ws_Unl; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Ws_Unl_Len { [DebuggerStepThrough()] get { return m_Ws_Unl_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Cp_Len { [DebuggerStepThrough()] get { return m_Cp_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_K { [DebuggerStepThrough()] get { return m_P_K; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Rsz { [DebuggerStepThrough()] get { return m_P_Rsz; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_T { [DebuggerStepThrough()] get { return m_P_T; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_B { [DebuggerStepThrough()] get { return m_P_B; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_C { [DebuggerStepThrough()] get { return m_P_C; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_D { [DebuggerStepThrough()] get { return m_P_D; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_E { [DebuggerStepThrough()] get { return m_P_E; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_Don_0 { [DebuggerStepThrough()] get { return m_Ws_Don_0; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_0_Typ { [DebuggerStepThrough()] get { return m_Ws_0_Typ; } }

    /// <summary>AmtVarAlpha 6</summary>
    public AmtVarAlpha Ws_0_Nm_Base { [DebuggerStepThrough()] get { return m_Ws_0_Nm_Base; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Ws_0_Nm_Table { [DebuggerStepThrough()] get { return m_Ws_0_Nm_Table; } }

    /// <summary>AmtVarNumericOS2200 8</summary>
    public AmtVarNumericOS2200 Ws_0_Dt_Ach { [DebuggerStepThrough()] get { return m_Ws_0_Dt_Ach; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_0_Dt_Maj { [DebuggerStepThrough()] get { return m_Ws_0_Dt_Maj; } }

    /// <summary>AmtVarNumericOS2200 2</summary>
    public AmtVarNumericOS2200 Ws_0_Dt_Maj_Ss { [DebuggerStepThrough()] get { return m_Ws_0_Dt_Maj_Ss; } }

    /// <summary>AmtVarNumericOS2200 2</summary>
    public AmtVarNumericOS2200 Ws_0_Dt_Maj_Aa { [DebuggerStepThrough()] get { return m_Ws_0_Dt_Maj_Aa; } }

    /// <summary>AmtVarNumericOS2200 2</summary>
    public AmtVarNumericOS2200 Ws_0_Dt_Maj_Mm { [DebuggerStepThrough()] get { return m_Ws_0_Dt_Maj_Mm; } }

    /// <summary>AmtVarNumericOS2200 2</summary>
    public AmtVarNumericOS2200 Ws_0_Dt_Maj_Jj { [DebuggerStepThrough()] get { return m_Ws_0_Dt_Maj_Jj; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_Don_1 { [DebuggerStepThrough()] get { return m_Ws_Don_1; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_1_Typ { [DebuggerStepThrough()] get { return m_Ws_1_Typ; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Ws_1_Nm_Cle { [DebuggerStepThrough()] get { return m_Ws_1_Nm_Cle; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_1_Cle { [DebuggerStepThrough()] get { return m_Ws_1_Cle; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_1_Typ_Cle { [DebuggerStepThrough()] get { return m_Ws_1_Typ_Cle; } }

    /// <summary>AmtVarNumericOS2200 4.2</summary>
    public AmtVarNumericOS2200 Ws_1_Lg_Cle { [DebuggerStepThrough()] get { return m_Ws_1_Lg_Cle; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_Don_2 { [DebuggerStepThrough()] get { return m_Ws_Don_2; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_2_Typ { [DebuggerStepThrough()] get { return m_Ws_2_Typ; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Ws_2_Nm_Chp { [DebuggerStepThrough()] get { return m_Ws_2_Nm_Chp; } }

    /// <summary>AmtVarAlpha 7</summary>
    public AmtVarAlpha Ws_2_Typ_Chp { [DebuggerStepThrough()] get { return m_Ws_2_Typ_Chp; } }

    /// <summary>AmtVarAlpha 10</summary>
    public AmtVarAlpha Ws_2_Lg_Chp { [DebuggerStepThrough()] get { return m_Ws_2_Lg_Chp; } }

    /// <summary>AmtVarAlpha 8</summary>
    public AmtVarAlpha Ws_2_Null { [DebuggerStepThrough()] get { return m_Ws_2_Null; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_Don_3 { [DebuggerStepThrough()] get { return m_Ws_Don_3; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_3_Typ { [DebuggerStepThrough()] get { return m_Ws_3_Typ; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Ws_3_Nm_Idx { [DebuggerStepThrough()] get { return m_Ws_3_Nm_Idx; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Ws_3_Nm_Chp { [DebuggerStepThrough()] get { return m_Ws_3_Nm_Chp; } }

    /// <summary>AmtVarAlpha 8</summary>
    public AmtVarAlpha Ws_3_Tri { [DebuggerStepThrough()] get { return m_Ws_3_Tri; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_Don_4 { [DebuggerStepThrough()] get { return m_Ws_Don_4; } }

    /// <summary>AmtVarAlpha 2</summary>
    public AmtVarAlpha Ws_4_Typ { [DebuggerStepThrough()] get { return m_Ws_4_Typ; } }

    /// <summary>AmtVarAlpha 3998</summary>
    public AmtVarAlpha Ws_4_Don { [DebuggerStepThrough()] get { return m_Ws_4_Don; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_Don_9 { [DebuggerStepThrough()] get { return m_Ws_Don_9; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_9_Typ { [DebuggerStepThrough()] get { return m_Ws_9_Typ; } }

    /// <summary>AmtVarAlpha 6</summary>
    public AmtVarAlpha Ws_9_Nm_Base { [DebuggerStepThrough()] get { return m_Ws_9_Nm_Base; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Ws_9_Nm_Table { [DebuggerStepThrough()] get { return m_Ws_9_Nm_Table; } }

    /// <summary>AmtVarNumericOS2200 8</summary>
    public AmtVarNumericOS2200 Ws_9_Dt_Ach { [DebuggerStepThrough()] get { return m_Ws_9_Dt_Ach; } }

    /// <summary>AmtVarNumericOS2200 11</summary>
    public AmtVarNumericOS2200 Ws_9_Cpt_Ach { [DebuggerStepThrough()] get { return m_Ws_9_Cpt_Ach; } }

    /// <summary>AmtVarAlpha 12</summary>
    public AmtVarAlpha Ws_9_Cpt_5 { [DebuggerStepThrough()] get { return m_Ws_9_Cpt_5; } }

    /// <summary>AmtNativeInt 1</summary>
    public AmtNativeInt Unloadf { [DebuggerStepThrough()] get { return m_Unloadf; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Table_Null { [DebuggerStepThrough()] get { return m_Table_Null; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Tnull { [DebuggerStepThrough()] get { return m_Tnull; } }

    /// <summary>AmtNativeInt 2</summary>
    public AmtNativeInt I { [DebuggerStepThrough()] get { return m_I; } }

    /// <summary>AmtNativeInt 2</summary>
    public AmtNativeInt I_Buf { [DebuggerStepThrough()] get { return m_I_Buf; } }

    /// <summary>AmtNativeInt 2</summary>
    public AmtNativeInt I_Tot { [DebuggerStepThrough()] get { return m_I_Tot; } }

    /// <summary>AmtNativeInt 1</summary>
    public AmtNativeInt Fl_Null { [DebuggerStepThrough()] get { return m_Fl_Null; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt Cpt_Char { [DebuggerStepThrough()] get { return m_Cpt_Char; } }

    /// <summary>AmtVarNumericOS2200 11</summary>
    public AmtVarNumericOS2200 Cpt_Ach { [DebuggerStepThrough()] get { return m_Cpt_Ach; } }

    /// <summary>AmtVarNumericOS2200 11</summary>
    public AmtVarNumericOS2200 Cpt_Lu { [DebuggerStepThrough()] get { return m_Cpt_Lu; } }

    /// <summary>AmtVarNumericOS2200 11</summary>
    public AmtVarNumericOS2200 Cpt_Achf { [DebuggerStepThrough()] get { return m_Cpt_Achf; } }

    /// <summary>AmtVarNumericOS2200 11</summary>
    public AmtVarNumericOS2200 Cpt_Luf { [DebuggerStepThrough()] get { return m_Cpt_Luf; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Dt_I { [DebuggerStepThrough()] get { return m_Dt_I; } }

    /// <summary>AmtVarNumericOS2200 4</summary>
    public AmtVarNumericOS2200 Aa_I { [DebuggerStepThrough()] get { return m_Aa_I; } }

    /// <summary>AmtVarNumericOS2200 2</summary>
    public AmtVarNumericOS2200 Mm_I { [DebuggerStepThrough()] get { return m_Mm_I; } }

    /// <summary>AmtVarNumericOS2200 2</summary>
    public AmtVarNumericOS2200 Jj_I { [DebuggerStepThrough()] get { return m_Jj_I; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Dt_Fr { [DebuggerStepThrough()] get { return m_Dt_Fr; } }

    /// <summary>AmtVarNumericOS2200 2</summary>
    public AmtVarNumericOS2200 Jj_Fr { [DebuggerStepThrough()] get { return m_Jj_Fr; } }

    /// <summary>AmtVarNumericOS2200 2</summary>
    public AmtVarNumericOS2200 Mm_Fr { [DebuggerStepThrough()] get { return m_Mm_Fr; } }

    /// <summary>AmtVarNumericOS2200 4</summary>
    public AmtVarNumericOS2200 Aa_Fr { [DebuggerStepThrough()] get { return m_Aa_Fr; } }
    #endregion Properties

    // Constructor
    public LocalDefinitions (Archiformat_Gn parentObject)
      : base(parentObject) {
      m_ParentObject = parentObject;
      m_Lgn_Rep = new AmtVarAlpha(132);
      m_Lgn_Des = new AmtVarAlpha(132);
      m_Ws_Rep_Len = new AmtVarNumericBinary9(5, false);
      m_Ws_Rep_Len.InitialValue = 0;
      m_Ws_Des_Len = new AmtVarNumericBinary9(5, false);
      m_Ws_Des_Len.InitialValue = 0;
      m_Recin = new AmtVarAlpha(4001);
      m_Ws_Unl = new AmtVarAlpha(4000);
      m_Ws_Unl_Len = new AmtVarNumericBinary9(5, false);
      m_Ws_Unl_Len.InitialValue = 0;
      m_Cp_Len = new AmtNativeInt(6, false);
      m_Cp_Len.InitialValue = 0;
      m_P_K = new AmtNativeInt(6, false);
      m_P_K.InitialValue = 0;
      m_P_Rsz = new AmtNativeInt(6, false);
      m_P_Rsz.InitialValue = 0;
      m_P_T = new AmtNativeInt(6, false);
      m_P_T.InitialValue = 0;
      m_P_B = new AmtNativeInt(6, false);
      m_P_B.InitialValue = 0;
      m_P_C = new AmtNativeInt(6, false);
      m_P_C.InitialValue = 0;
      m_P_D = new AmtNativeInt(6, false);
      m_P_D.InitialValue = 0;
      m_P_E = new AmtNativeInt(6, false);
      m_P_E.InitialValue = 0;
      m_Ws_Don_0 = new AmtStructure();
      {
        m_Ws_0_Typ = new AmtVarAlpha(1, m_Ws_Don_0);
        m_Ws_0_Typ.InitialValue = "0";
        m_Ws_0_Nm_Base = new AmtVarAlpha(6, m_Ws_Don_0);
        m_Ws_0_Nm_Table = new AmtVarAlpha(30, m_Ws_Don_0);
        m_Ws_0_Dt_Ach = new AmtVarNumericOS2200(8, m_Ws_Don_0);
        m_Ws_0_Dt_Maj = new AmtStructure(m_Ws_Don_0);
        {
          m_Ws_0_Dt_Maj_Ss = new AmtVarNumericOS2200(2, m_Ws_0_Dt_Maj);
          m_Ws_0_Dt_Maj_Aa = new AmtVarNumericOS2200(2, m_Ws_0_Dt_Maj);
          m_Ws_0_Dt_Maj_Mm = new AmtVarNumericOS2200(2, m_Ws_0_Dt_Maj);
          m_Ws_0_Dt_Maj_Jj = new AmtVarNumericOS2200(2, m_Ws_0_Dt_Maj);
        }
      }
      m_Ws_Don_1 = new AmtStructure();
      {
        m_Ws_1_Typ = new AmtVarAlpha(1, m_Ws_Don_1);
        m_Ws_1_Typ.InitialValue = "1";
        m_Ws_1_Nm_Cle = new AmtVarAlpha(30, m_Ws_Don_1);
        m_Ws_1_Cle = new AmtStructure(m_Ws_Don_1);
        {
          m_Ws_1_Typ_Cle = new AmtVarAlpha(1, m_Ws_1_Cle);
          m_Ws_1_Lg_Cle = new AmtVarNumericOS2200(4, 2, "99.99", m_Ws_1_Cle);
        }
      }
      m_Ws_Don_2 = new AmtStructure();
      {
        m_Ws_2_Typ = new AmtVarAlpha(1, m_Ws_Don_2);
        m_Ws_2_Typ.InitialValue = "2";
        m_Ws_2_Nm_Chp = new AmtVarAlpha(30, m_Ws_Don_2);
        m_Ws_2_Typ_Chp = new AmtVarAlpha(7, m_Ws_Don_2);
        m_Ws_2_Lg_Chp = new AmtVarAlpha(10, m_Ws_Don_2);
        m_Ws_2_Null = new AmtVarAlpha(8, m_Ws_Don_2);
      }
      m_Ws_Don_3 = new AmtStructure();
      {
        m_Ws_3_Typ = new AmtVarAlpha(1, m_Ws_Don_3);
        m_Ws_3_Typ.InitialValue = "3";
        m_Ws_3_Nm_Idx = new AmtVarAlpha(30, m_Ws_Don_3);
        m_Ws_3_Nm_Chp = new AmtVarAlpha(30, m_Ws_Don_3);
        m_Ws_3_Tri = new AmtVarAlpha(8, m_Ws_Don_3);
      }
      m_Ws_Don_4 = new AmtStructure();
      {
        m_Ws_4_Typ = new AmtVarAlpha(2, m_Ws_Don_4);
        m_Ws_4_Typ.InitialValue = "4A";
        m_Ws_4_Don = new AmtVarAlpha(3998, m_Ws_Don_4);
      }
      m_Ws_Don_9 = new AmtStructure();
      {
        m_Ws_9_Typ = new AmtVarAlpha(1, m_Ws_Don_9);
        m_Ws_9_Typ.InitialValue = "9";
        m_Ws_9_Nm_Base = new AmtVarAlpha(6, m_Ws_Don_9);
        m_Ws_9_Nm_Table = new AmtVarAlpha(30, m_Ws_Don_9);
        m_Ws_9_Dt_Ach = new AmtVarNumericOS2200(8, m_Ws_Don_9);
        m_Ws_9_Cpt_Ach = new AmtVarNumericOS2200(11, true, "+99999999999", m_Ws_Don_9);
        m_Ws_9_Cpt_5 = new AmtVarAlpha(12, m_Ws_Don_9);
        m_Ws_9_Cpt_5.InitialValue = "+00000000000";
      }
      m_Unloadf = new AmtNativeInt(1, false);
      m_Unloadf.InitialValue = 0;
      m_Table_Null = new AmtStructure();
      {
        m_Tnull = new AmtVarAlpha(1, m_Table_Null);
        m_Tnull.SetArrayBoundaries(70);
      }
      m_I = new AmtNativeInt(2, false);
      m_I_Buf = new AmtNativeInt(2, false);
      m_I_Tot = new AmtNativeInt(2, false);
      m_Fl_Null = new AmtNativeInt(1, false);
      m_Cpt_Char = new AmtNativeInt(3, false);
      m_Cpt_Ach = new AmtVarNumericOS2200(11);
      m_Cpt_Ach.InitialValue = 0;
      m_Cpt_Lu = new AmtVarNumericOS2200(11);
      m_Cpt_Lu.InitialValue = 0;
      m_Cpt_Achf = new AmtVarNumericOS2200(11, "ZZZZZZZZZZ9");
      m_Cpt_Luf = new AmtVarNumericOS2200(11, "ZZZZZZZZZZ9");
      m_Dt_I = new AmtStructure();
      {
        m_Aa_I = new AmtVarNumericOS2200(4, m_Dt_I);
        m_Mm_I = new AmtVarNumericOS2200(2, m_Dt_I);
        m_Jj_I = new AmtVarNumericOS2200(2, m_Dt_I);
      }
      m_Dt_Fr = new AmtStructure();
      {
        m_Jj_Fr = new AmtVarNumericOS2200(2, m_Dt_Fr);
        m_Dt_Fr.AddAlphaFiller(1, "/");
        m_Mm_Fr = new AmtVarNumericOS2200(2, m_Dt_Fr);
        m_Dt_Fr.AddAlphaFiller(1, "/");
        m_Aa_Fr = new AmtVarNumericOS2200(4, m_Dt_Fr);
      }
      AllocateStructures();
    } // Constructor LocalDefinitions

    public override void ResetParent () {
      m_ParentObject = null;
      ResetDatabase();
    } // ResetParent

    public void ApplyNewParent (Archiformat_Gn parentObject) {
      m_ParentObject = parentObject;
      ApplyNewDatabase(parentObject);
    } // ApplyNewParent

    public void InitLocalDefinitions () {
      m_Lgn_Rep.Initialise();
      m_Lgn_Des.Initialise();
      m_Ws_Rep_Len.Initialise();
      m_Ws_Des_Len.Initialise();
      m_Recin.Initialise();
      m_Ws_Unl.Initialise();
      m_Ws_Unl_Len.Initialise();
      m_Cp_Len.Initialise();
      m_P_K.Initialise();
      m_P_Rsz.Initialise();
      m_P_T.Initialise();
      m_P_B.Initialise();
      m_P_C.Initialise();
      m_P_D.Initialise();
      m_P_E.Initialise();
      m_Ws_Don_0.Initialise();
      m_Ws_Don_1.Initialise();
      m_Ws_Don_2.Initialise();
      m_Ws_Don_3.Initialise();
      m_Ws_Don_4.Initialise();
      m_Ws_Don_9.Initialise();
      m_Unloadf.Initialise();
      m_Table_Null.Initialise();
      m_I.Initialise();
      m_I_Buf.Initialise();
      m_I_Tot.Initialise();
      m_Fl_Null.Initialise();
      m_Cpt_Char.Initialise();
      m_Cpt_Ach.Initialise();
      m_Cpt_Lu.Initialise();
      m_Cpt_Achf.Initialise();
      m_Cpt_Luf.Initialise();
      m_Dt_I.Initialise();
      m_Dt_Fr.Initialise();
      AmtRtDbsSupport.InitDbsClients(m_DbsClientList);
    } // InitLocalDefinitions

    public void AllocateStructures () {
      m_Ws_Don_0.AllocStructure();
      m_Ws_Don_1.AllocStructure();
      m_Ws_Don_2.AllocStructure();
      m_Ws_Don_3.AllocStructure();
      m_Ws_Don_4.AllocStructure();
      m_Ws_Don_9.AllocStructure();
      m_Table_Null.AllocStructure();
      m_Dt_I.AllocStructure();
      m_Dt_Fr.AllocStructure();
    } // AllocateStructures

  } // Class LocalDefinitions

} // Namespace Federale.BSP.BusinessLogic.Archiformat_Gn

