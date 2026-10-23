using System;
using System.ComponentModel;
using Asysco.Amt.Runtime.Printing;

namespace Company.AFBUS_2200COBOL.BusinessLogic.Assurfed_Utilit_Cfh_Copy {

  public partial class PrintDefinitions: AmtTextPrintDocument, IDisposable {
    #region Members

    /// <summary>
    /// Required designer variable.
    /// </summary>
    private IContainer m_Components;
    #endregion Members

    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    /// <param name="disposing">true if managed resources should be disposed; otherwise, false</param>
    protected override void Dispose (Boolean disposing) {
      if (disposing && (m_Components != null)) {
        m_Components.Dispose();
      }
      base.Dispose(disposing);
    } // Dispose

    #region Text Layout Print Designer generated code

    public void InitializeComponent () {

      // PrintDefinitions

      LayoutWidth = 132;
      SetupReadWriteLayouts();
    } // InitializeComponent

    #endregion Text Layout Print Designer generated code

  } // Class PrintDefinitions

} // Namespace Company.AFBUS_2200COBOL.BusinessLogic.Assurfed_Utilit_Cfh_Copy

