using System.Diagnostics;
using Asysco.Amt.Runtime.Database;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Condis2_Gn {

  public class LocalDefinitions: AmtBaseDefinitions {
    #region Members
    private Condis2_Gn m_ParentObject;
    private readonly AmtVarAlpha m_Recin;
    private readonly AmtVarAlpha m_Ws_In;
    private readonly AmtVarAlpha m_Ws_Out;
    private readonly AmtVarNumericBinary9 m_Ws_In_Len;
    private readonly AmtNativeInt m_Cp_Len;
    private readonly AmtNativeInt m_P_Inlen;
    private readonly AmtNativeInt m_P_Outlen;
    private readonly AmtNativeInt m_N_Grp;
    private readonly AmtNativeInt m_N_Case;
    private readonly AmtNativeInt m_N_Oth;
    private readonly AmtNativeInt m_N_Ts;
    private readonly AmtNativeInt m_N_Op;
    private readonly AmtNativeInt m_N_Co;
    private readonly AmtNativeInt m_G;
    private readonly AmtNativeInt m_I;
    private readonly AmtNativeInt m_J;
    private readonly AmtNativeInt m_Ws_N2;
    private readonly AmtStructure m_Grp_Tab;
    private readonly AmtStructure m_Grp_Ent;
    private readonly AmtVarAlpha m_G_Kind;
    private readonly AmtVarNumericBinary9 m_G_Cn;
    private readonly AmtVarNumericBinary9 m_G_T1;
    private readonly AmtVarNumericBinary9 m_G_Tn;
    private readonly AmtVarNumericBinary9 m_G_O1;
    private readonly AmtVarNumericBinary9 m_G_On;
    private readonly AmtStructure m_Ts_Tab;
    private readonly AmtStructure m_Ts_Ent;
    private readonly AmtVarNumericBinary9 m_T_Pos;
    private readonly AmtVarNumericBinary9 m_T_Len;
    private readonly AmtVarAlpha m_T_Val;
    private readonly AmtStructure m_Op_Tab;
    private readonly AmtStructure m_Op_Ent;
    private readonly AmtVarAlpha m_O_Type;
    private readonly AmtVarNumericBinary9 m_O_Is;
    private readonly AmtVarNumericBinary9 m_O_Il;
    private readonly AmtVarNumericBinary9 m_O_Os;
    private readonly AmtVarNumericBinary9 m_O_Ol;
    private readonly AmtVarAlpha m_O_Code;
    private readonly AmtVarNumericBinary9 m_O_Cx;
    private readonly AmtStructure m_Co_Tab;
    private readonly AmtVarAlpha m_Co_Val;
    private readonly AmtStructure m_Nb_Case_Tab;
    private readonly AmtVarNumericOS2200 m_Nb_Case;
    private readonly AmtNativeInt m_Nb_Rec_Case_0;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_22a_200x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_22a_201x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_22a_202x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_22a_203x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_22b_200x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_22b_201x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_22b_202x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_22b_203x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_66a_200x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_66a_201x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_66a_202x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_66a_203x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_66b_200x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_66b_201x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_66b_202x;
    private readonly AmtVarAlpha m_Ws_Record_Transforme_66b_203x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_22a_200x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_22a_201x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_22a_202x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_22a_203x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_22b_200x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_22b_201x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_22b_202x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_22b_203x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_66a_200x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_66a_201x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_66a_202x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_66a_203x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_66b_200x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_66b_201x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_66b_202x;
    private readonly AmtNativeInt m_Nb_Rec_Transforme_66b_203x;
    private readonly AmtNativeInt m_Nb_Rec_Lu;
    private readonly AmtNativeInt m_Nb_Rec_Ecrit;
    private readonly AmtNativeInt m_Nb_Rec_Other;
    private readonly AmtVarNumericOS2200 m_Nb_Rec_Nonecrit;
    private readonly AmtStructure m_Ws_A6;
    private readonly AmtStructure m_Ws_A6_Yy;
    private readonly AmtVarAlpha m_Ws_A6_Y1;
    private readonly AmtVarAlpha m_Ws_A6_Y2;
    private readonly AmtVarAlpha m_Ws_A6_Mm;
    private readonly AmtVarAlpha m_Ws_A6_Jj;
    private readonly AmtStructure m_Ws_A8;
    private readonly AmtStructure m_Ws_A8_Yyy;
    private readonly AmtVarAlpha m_Ws_A8_Ss;
    private readonly AmtVarAlpha m_Ws_A8_Y4;
    private readonly AmtVarAlpha m_Ws_A8_Mm;
    private readonly AmtVarAlpha m_Ws_A8_Jj;
    private readonly AmtStructure m_Ws_A8_Bis;
    private readonly AmtVarAlpha m_Ws_A8_Yy;
    private readonly AmtVarAlpha m_Ws_A8_Yymmjj;
    private readonly AmtStructure m_Ws_A4;
    private readonly AmtVarAlpha m_Ws_A4_Ss;
    private readonly AmtStructure m_Ws_A4_Aa;
    private readonly AmtVarAlpha m_Ws_A4_A1;
    private readonly AmtVarAlpha m_Ws_A4_A2;
    private readonly AmtStructure m_Ws_A2;
    private readonly AmtVarAlpha m_Ws_A2_A1;
    private readonly AmtVarAlpha m_Ws_A2_A2;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Recin { [DebuggerStepThrough()] get { return m_Recin; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Ws_In { [DebuggerStepThrough()] get { return m_Ws_In; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Ws_Out { [DebuggerStepThrough()] get { return m_Ws_Out; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Ws_In_Len { [DebuggerStepThrough()] get { return m_Ws_In_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Cp_Len { [DebuggerStepThrough()] get { return m_Cp_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Inlen { [DebuggerStepThrough()] get { return m_P_Inlen; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Outlen { [DebuggerStepThrough()] get { return m_P_Outlen; } }

    /// <summary>AmtNativeInt 4</summary>
    public AmtNativeInt N_Grp { [DebuggerStepThrough()] get { return m_N_Grp; } }

    /// <summary>AmtNativeInt 4</summary>
    public AmtNativeInt N_Case { [DebuggerStepThrough()] get { return m_N_Case; } }

    /// <summary>AmtNativeInt 4</summary>
    public AmtNativeInt N_Oth { [DebuggerStepThrough()] get { return m_N_Oth; } }

    /// <summary>AmtNativeInt 4</summary>
    public AmtNativeInt N_Ts { [DebuggerStepThrough()] get { return m_N_Ts; } }

    /// <summary>AmtNativeInt 4</summary>
    public AmtNativeInt N_Op { [DebuggerStepThrough()] get { return m_N_Op; } }

    /// <summary>AmtNativeInt 4</summary>
    public AmtNativeInt N_Co { [DebuggerStepThrough()] get { return m_N_Co; } }

    /// <summary>AmtNativeInt 4</summary>
    public AmtNativeInt G { [DebuggerStepThrough()] get { return m_G; } }

    /// <summary>AmtNativeInt 4</summary>
    public AmtNativeInt I { [DebuggerStepThrough()] get { return m_I; } }

    /// <summary>AmtNativeInt 4</summary>
    public AmtNativeInt J { [DebuggerStepThrough()] get { return m_J; } }

    /// <summary>AmtNativeInt 2</summary>
    public AmtNativeInt Ws_N2 { [DebuggerStepThrough()] get { return m_Ws_N2; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Grp_Tab { [DebuggerStepThrough()] get { return m_Grp_Tab; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Grp_Ent { [DebuggerStepThrough()] get { return m_Grp_Ent; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha G_Kind { [DebuggerStepThrough()] get { return m_G_Kind; } }

    /// <summary>AmtVarNumericBinary9 4</summary>
    public AmtVarNumericBinary9 G_Cn { [DebuggerStepThrough()] get { return m_G_Cn; } }

    /// <summary>AmtVarNumericBinary9 4</summary>
    public AmtVarNumericBinary9 G_T1 { [DebuggerStepThrough()] get { return m_G_T1; } }

    /// <summary>AmtVarNumericBinary9 4</summary>
    public AmtVarNumericBinary9 G_Tn { [DebuggerStepThrough()] get { return m_G_Tn; } }

    /// <summary>AmtVarNumericBinary9 4</summary>
    public AmtVarNumericBinary9 G_O1 { [DebuggerStepThrough()] get { return m_G_O1; } }

    /// <summary>AmtVarNumericBinary9 4</summary>
    public AmtVarNumericBinary9 G_On { [DebuggerStepThrough()] get { return m_G_On; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ts_Tab { [DebuggerStepThrough()] get { return m_Ts_Tab; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ts_Ent { [DebuggerStepThrough()] get { return m_Ts_Ent; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 T_Pos { [DebuggerStepThrough()] get { return m_T_Pos; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 T_Len { [DebuggerStepThrough()] get { return m_T_Len; } }

    /// <summary>AmtVarAlpha 238</summary>
    public AmtVarAlpha T_Val { [DebuggerStepThrough()] get { return m_T_Val; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Op_Tab { [DebuggerStepThrough()] get { return m_Op_Tab; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Op_Ent { [DebuggerStepThrough()] get { return m_Op_Ent; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha O_Type { [DebuggerStepThrough()] get { return m_O_Type; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 O_Is { [DebuggerStepThrough()] get { return m_O_Is; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 O_Il { [DebuggerStepThrough()] get { return m_O_Il; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 O_Os { [DebuggerStepThrough()] get { return m_O_Os; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 O_Ol { [DebuggerStepThrough()] get { return m_O_Ol; } }

    /// <summary>AmtVarAlpha 4</summary>
    public AmtVarAlpha O_Code { [DebuggerStepThrough()] get { return m_O_Code; } }

    /// <summary>AmtVarNumericBinary9 4</summary>
    public AmtVarNumericBinary9 O_Cx { [DebuggerStepThrough()] get { return m_O_Cx; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Co_Tab { [DebuggerStepThrough()] get { return m_Co_Tab; } }

    /// <summary>AmtVarAlpha 238</summary>
    public AmtVarAlpha Co_Val { [DebuggerStepThrough()] get { return m_Co_Val; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Nb_Case_Tab { [DebuggerStepThrough()] get { return m_Nb_Case_Tab; } }

    /// <summary>AmtVarNumericOS2200 6</summary>
    public AmtVarNumericOS2200 Nb_Case { [DebuggerStepThrough()] get { return m_Nb_Case; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Case_0 { [DebuggerStepThrough()] get { return m_Nb_Rec_Case_0; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_22a_200x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_22a_200x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_22a_201x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_22a_201x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_22a_202x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_22a_202x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_22a_203x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_22a_203x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_22b_200x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_22b_200x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_22b_201x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_22b_201x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_22b_202x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_22b_202x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_22b_203x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_22b_203x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_66a_200x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_66a_200x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_66a_201x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_66a_201x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_66a_202x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_66a_202x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_66a_203x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_66a_203x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_66b_200x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_66b_200x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_66b_201x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_66b_201x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_66b_202x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_66b_202x; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Record_Transforme_66b_203x { [DebuggerStepThrough()] get { return m_Ws_Record_Transforme_66b_203x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_22a_200x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_22a_200x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_22a_201x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_22a_201x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_22a_202x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_22a_202x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_22a_203x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_22a_203x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_22b_200x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_22b_200x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_22b_201x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_22b_201x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_22b_202x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_22b_202x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_22b_203x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_22b_203x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_66a_200x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_66a_200x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_66a_201x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_66a_201x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_66a_202x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_66a_202x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_66a_203x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_66a_203x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_66b_200x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_66b_200x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_66b_201x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_66b_201x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_66b_202x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_66b_202x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Transforme_66b_203x { [DebuggerStepThrough()] get { return m_Nb_Rec_Transforme_66b_203x; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Lu { [DebuggerStepThrough()] get { return m_Nb_Rec_Lu; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Ecrit { [DebuggerStepThrough()] get { return m_Nb_Rec_Ecrit; } }

    /// <summary>AmtNativeInt 6</summary>
    public AmtNativeInt Nb_Rec_Other { [DebuggerStepThrough()] get { return m_Nb_Rec_Other; } }

    /// <summary>AmtVarNumericOS2200 6</summary>
    public AmtVarNumericOS2200 Nb_Rec_Nonecrit { [DebuggerStepThrough()] get { return m_Nb_Rec_Nonecrit; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_A6 { [DebuggerStepThrough()] get { return m_Ws_A6; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_A6_Yy { [DebuggerStepThrough()] get { return m_Ws_A6_Yy; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_A6_Y1 { [DebuggerStepThrough()] get { return m_Ws_A6_Y1; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_A6_Y2 { [DebuggerStepThrough()] get { return m_Ws_A6_Y2; } }

    /// <summary>AmtVarAlpha 2</summary>
    public AmtVarAlpha Ws_A6_Mm { [DebuggerStepThrough()] get { return m_Ws_A6_Mm; } }

    /// <summary>AmtVarAlpha 2</summary>
    public AmtVarAlpha Ws_A6_Jj { [DebuggerStepThrough()] get { return m_Ws_A6_Jj; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_A8 { [DebuggerStepThrough()] get { return m_Ws_A8; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_A8_Yyy { [DebuggerStepThrough()] get { return m_Ws_A8_Yyy; } }

    /// <summary>AmtVarAlpha 2</summary>
    public AmtVarAlpha Ws_A8_Ss { [DebuggerStepThrough()] get { return m_Ws_A8_Ss; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_A8_Y4 { [DebuggerStepThrough()] get { return m_Ws_A8_Y4; } }

    /// <summary>AmtVarAlpha 2</summary>
    public AmtVarAlpha Ws_A8_Mm { [DebuggerStepThrough()] get { return m_Ws_A8_Mm; } }

    /// <summary>AmtVarAlpha 2</summary>
    public AmtVarAlpha Ws_A8_Jj { [DebuggerStepThrough()] get { return m_Ws_A8_Jj; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_A8_Bis { [DebuggerStepThrough()] get { return m_Ws_A8_Bis; } }

    /// <summary>AmtVarAlpha 2</summary>
    public AmtVarAlpha Ws_A8_Yy { [DebuggerStepThrough()] get { return m_Ws_A8_Yy; } }

    /// <summary>AmtVarAlpha 6</summary>
    public AmtVarAlpha Ws_A8_Yymmjj { [DebuggerStepThrough()] get { return m_Ws_A8_Yymmjj; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_A4 { [DebuggerStepThrough()] get { return m_Ws_A4; } }

    /// <summary>AmtVarAlpha 2</summary>
    public AmtVarAlpha Ws_A4_Ss { [DebuggerStepThrough()] get { return m_Ws_A4_Ss; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_A4_Aa { [DebuggerStepThrough()] get { return m_Ws_A4_Aa; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_A4_A1 { [DebuggerStepThrough()] get { return m_Ws_A4_A1; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_A4_A2 { [DebuggerStepThrough()] get { return m_Ws_A4_A2; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ws_A2 { [DebuggerStepThrough()] get { return m_Ws_A2; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_A2_A1 { [DebuggerStepThrough()] get { return m_Ws_A2_A1; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_A2_A2 { [DebuggerStepThrough()] get { return m_Ws_A2_A2; } }
    #endregion Properties

    // Constructor
    public LocalDefinitions (Condis2_Gn parentObject)
      : base(parentObject) {
      m_ParentObject = parentObject;
      m_Recin = new AmtVarAlpha(4001);
      m_Ws_In = new AmtVarAlpha(4000);
      m_Ws_Out = new AmtVarAlpha(4000);
      m_Ws_In_Len = new AmtVarNumericBinary9(5, false);
      m_Ws_In_Len.InitialValue = 0;
      m_Cp_Len = new AmtNativeInt(6, false);
      m_Cp_Len.InitialValue = 0;
      m_P_Inlen = new AmtNativeInt(6, false);
      m_P_Inlen.InitialValue = 0;
      m_P_Outlen = new AmtNativeInt(6, false);
      m_P_Outlen.InitialValue = 0;
      m_N_Grp = new AmtNativeInt(6, false);
      m_N_Grp.InitialValue = 0;
      m_N_Case = new AmtNativeInt(6, false);
      m_N_Case.InitialValue = 0;
      m_N_Oth = new AmtNativeInt(6, false);
      m_N_Oth.InitialValue = 0;
      m_N_Ts = new AmtNativeInt(6, false);
      m_N_Ts.InitialValue = 0;
      m_N_Op = new AmtNativeInt(6, false);
      m_N_Op.InitialValue = 0;
      m_N_Co = new AmtNativeInt(6, false);
      m_N_Co.InitialValue = 0;
      m_G = new AmtNativeInt(6, false);
      m_G.InitialValue = 0;
      m_I = new AmtNativeInt(6, false);
      m_I.InitialValue = 0;
      m_J = new AmtNativeInt(6, false);
      m_J.InitialValue = 0;
      m_Ws_N2 = new AmtNativeInt(2, false);
      m_Ws_N2.InitialValue = 0;
      m_Grp_Tab = new AmtStructure();
      {
        m_Grp_Ent = new AmtStructure(m_Grp_Tab);
        m_Grp_Ent.SetArrayBoundaries(100);
        {
          m_G_Kind = new AmtVarAlpha(1, m_Grp_Ent);
          m_G_Cn = new AmtVarNumericBinary9(4, false, m_Grp_Ent);
          m_G_T1 = new AmtVarNumericBinary9(4, false, m_Grp_Ent);
          m_G_Tn = new AmtVarNumericBinary9(4, false, m_Grp_Ent);
          m_G_O1 = new AmtVarNumericBinary9(4, false, m_Grp_Ent);
          m_G_On = new AmtVarNumericBinary9(4, false, m_Grp_Ent);
        }
      }
      m_Ts_Tab = new AmtStructure();
      {
        m_Ts_Ent = new AmtStructure(m_Ts_Tab);
        m_Ts_Ent.SetArrayBoundaries(200);
        {
          m_T_Pos = new AmtVarNumericBinary9(5, false, m_Ts_Ent);
          m_T_Len = new AmtVarNumericBinary9(5, false, m_Ts_Ent);
          m_T_Val = new AmtVarAlpha(238, m_Ts_Ent);
        }
      }
      m_Op_Tab = new AmtStructure();
      {
        m_Op_Ent = new AmtStructure(m_Op_Tab);
        m_Op_Ent.SetArrayBoundaries(600);
        {
          m_O_Type = new AmtVarAlpha(1, m_Op_Ent);
          m_O_Is = new AmtVarNumericBinary9(5, false, m_Op_Ent);
          m_O_Il = new AmtVarNumericBinary9(5, false, m_Op_Ent);
          m_O_Os = new AmtVarNumericBinary9(5, false, m_Op_Ent);
          m_O_Ol = new AmtVarNumericBinary9(5, false, m_Op_Ent);
          m_O_Code = new AmtVarAlpha(4, m_Op_Ent);
          m_O_Cx = new AmtVarNumericBinary9(4, false, m_Op_Ent);
        }
      }
      m_Co_Tab = new AmtStructure();
      {
        m_Co_Val = new AmtVarAlpha(238, m_Co_Tab);
        m_Co_Val.SetArrayBoundaries(300);
      }
      m_Nb_Case_Tab = new AmtStructure();
      {
        m_Nb_Case = new AmtVarNumericOS2200(6, m_Nb_Case_Tab);
        m_Nb_Case.SetArrayBoundaries(100);
      }
      m_Nb_Rec_Case_0 = new AmtNativeInt(6, false);
      m_Ws_Record_Transforme_22a_200x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_22a_201x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_22a_202x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_22a_203x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_22b_200x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_22b_201x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_22b_202x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_22b_203x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_66a_200x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_66a_201x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_66a_202x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_66a_203x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_66b_200x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_66b_201x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_66b_202x = new AmtVarAlpha(1);
      m_Ws_Record_Transforme_66b_203x = new AmtVarAlpha(1);
      m_Nb_Rec_Transforme_22a_200x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_22a_201x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_22a_202x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_22a_203x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_22b_200x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_22b_201x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_22b_202x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_22b_203x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_66a_200x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_66a_201x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_66a_202x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_66a_203x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_66b_200x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_66b_201x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_66b_202x = new AmtNativeInt(6, false);
      m_Nb_Rec_Transforme_66b_203x = new AmtNativeInt(6, false);
      m_Nb_Rec_Lu = new AmtNativeInt(6, false);
      m_Nb_Rec_Ecrit = new AmtNativeInt(6, false);
      m_Nb_Rec_Other = new AmtNativeInt(6, false);
      m_Nb_Rec_Nonecrit = new AmtVarNumericOS2200(6);
      m_Ws_A6 = new AmtStructure();
      {
        m_Ws_A6_Yy = new AmtStructure(m_Ws_A6);
        {
          m_Ws_A6_Y1 = new AmtVarAlpha(1, m_Ws_A6_Yy);
          m_Ws_A6_Y2 = new AmtVarAlpha(1, m_Ws_A6_Yy);
        }
        m_Ws_A6_Mm = new AmtVarAlpha(2, m_Ws_A6);
        m_Ws_A6_Jj = new AmtVarAlpha(2, m_Ws_A6);
      }
      m_Ws_A8 = new AmtStructure();
      {
        m_Ws_A8_Yyy = new AmtStructure(m_Ws_A8);
        {
          m_Ws_A8_Ss = new AmtVarAlpha(2, m_Ws_A8_Yyy);
          m_Ws_A8_Yyy.AddAlphaFiller(1);
        }
        m_Ws_A8_Y4 = new AmtVarAlpha(1, m_Ws_A8);
        m_Ws_A8_Mm = new AmtVarAlpha(2, m_Ws_A8);
        m_Ws_A8_Jj = new AmtVarAlpha(2, m_Ws_A8);
      }
      m_Ws_A8_Bis = new AmtStructure();
      {
        m_Ws_A8_Bis.Redefines(m_Ws_A8);
        m_Ws_A8_Yy = new AmtVarAlpha(2, m_Ws_A8_Bis);
        m_Ws_A8_Yymmjj = new AmtVarAlpha(6, m_Ws_A8_Bis);
      }
      m_Ws_A4 = new AmtStructure();
      {
        m_Ws_A4_Ss = new AmtVarAlpha(2, m_Ws_A4);
        m_Ws_A4_Aa = new AmtStructure(m_Ws_A4);
        {
          m_Ws_A4_A1 = new AmtVarAlpha(1, m_Ws_A4_Aa);
          m_Ws_A4_A2 = new AmtVarAlpha(1, m_Ws_A4_Aa);
        }
      }
      m_Ws_A2 = new AmtStructure();
      {
        m_Ws_A2_A1 = new AmtVarAlpha(1, m_Ws_A2);
        m_Ws_A2_A2 = new AmtVarAlpha(1, m_Ws_A2);
      }
      AllocateStructures();
    } // Constructor LocalDefinitions

    public override void ResetParent () {
      m_ParentObject = null;
      ResetDatabase();
    } // ResetParent

    public void ApplyNewParent (Condis2_Gn parentObject) {
      m_ParentObject = parentObject;
      ApplyNewDatabase(parentObject);
    } // ApplyNewParent

    public void InitLocalDefinitions () {
      m_Recin.Initialise();
      m_Ws_In.Initialise();
      m_Ws_Out.Initialise();
      m_Ws_In_Len.Initialise();
      m_Cp_Len.Initialise();
      m_P_Inlen.Initialise();
      m_P_Outlen.Initialise();
      m_N_Grp.Initialise();
      m_N_Case.Initialise();
      m_N_Oth.Initialise();
      m_N_Ts.Initialise();
      m_N_Op.Initialise();
      m_N_Co.Initialise();
      m_G.Initialise();
      m_I.Initialise();
      m_J.Initialise();
      m_Ws_N2.Initialise();
      m_Grp_Tab.Initialise();
      m_Ts_Tab.Initialise();
      m_Op_Tab.Initialise();
      m_Co_Tab.Initialise();
      m_Nb_Case_Tab.Initialise();
      m_Nb_Rec_Case_0.Initialise();
      m_Ws_Record_Transforme_22a_200x.Initialise();
      m_Ws_Record_Transforme_22a_201x.Initialise();
      m_Ws_Record_Transforme_22a_202x.Initialise();
      m_Ws_Record_Transforme_22a_203x.Initialise();
      m_Ws_Record_Transforme_22b_200x.Initialise();
      m_Ws_Record_Transforme_22b_201x.Initialise();
      m_Ws_Record_Transforme_22b_202x.Initialise();
      m_Ws_Record_Transforme_22b_203x.Initialise();
      m_Ws_Record_Transforme_66a_200x.Initialise();
      m_Ws_Record_Transforme_66a_201x.Initialise();
      m_Ws_Record_Transforme_66a_202x.Initialise();
      m_Ws_Record_Transforme_66a_203x.Initialise();
      m_Ws_Record_Transforme_66b_200x.Initialise();
      m_Ws_Record_Transforme_66b_201x.Initialise();
      m_Ws_Record_Transforme_66b_202x.Initialise();
      m_Ws_Record_Transforme_66b_203x.Initialise();
      m_Nb_Rec_Transforme_22a_200x.Initialise();
      m_Nb_Rec_Transforme_22a_201x.Initialise();
      m_Nb_Rec_Transforme_22a_202x.Initialise();
      m_Nb_Rec_Transforme_22a_203x.Initialise();
      m_Nb_Rec_Transforme_22b_200x.Initialise();
      m_Nb_Rec_Transforme_22b_201x.Initialise();
      m_Nb_Rec_Transforme_22b_202x.Initialise();
      m_Nb_Rec_Transforme_22b_203x.Initialise();
      m_Nb_Rec_Transforme_66a_200x.Initialise();
      m_Nb_Rec_Transforme_66a_201x.Initialise();
      m_Nb_Rec_Transforme_66a_202x.Initialise();
      m_Nb_Rec_Transforme_66a_203x.Initialise();
      m_Nb_Rec_Transforme_66b_200x.Initialise();
      m_Nb_Rec_Transforme_66b_201x.Initialise();
      m_Nb_Rec_Transforme_66b_202x.Initialise();
      m_Nb_Rec_Transforme_66b_203x.Initialise();
      m_Nb_Rec_Lu.Initialise();
      m_Nb_Rec_Ecrit.Initialise();
      m_Nb_Rec_Other.Initialise();
      m_Nb_Rec_Nonecrit.Initialise();
      m_Ws_A6.Initialise();
      m_Ws_A8.Initialise();
      m_Ws_A4.Initialise();
      m_Ws_A2.Initialise();
      AmtRtDbsSupport.InitDbsClients(m_DbsClientList);
    } // InitLocalDefinitions

    public void AllocateStructures () {
      m_Grp_Tab.AllocStructure();
      m_Ts_Tab.AllocStructure();
      m_Op_Tab.AllocStructure();
      m_Co_Tab.AllocStructure();
      m_Nb_Case_Tab.AllocStructure();
      m_Ws_A6.AllocStructure();
      m_Ws_A8.AllocStructure();
      m_Ws_A8_Bis.AllocStructure();
      m_Ws_A4.AllocStructure();
      m_Ws_A2.AllocStructure();
    } // AllocateStructures

  } // Class LocalDefinitions

} // Namespace Federale.BSP.BusinessLogic.Condis2_Gn

