using System;
using System.ComponentModel;
using Asysco.Amt.Runtime.Printing;

namespace Company.AFBUS_2200COBOL.BusinessLogic.Assurfed_Utilit_Cfh_Copy {

  public partial class PrintDefinitions: AmtTextPrintDocument, IDisposable {
    #region Members
    private Assurfed_Utilit_Cfh_Copy m_ParentObject;
    #endregion Members

    // Constructor
    public PrintDefinitions (Assurfed_Utilit_Cfh_Copy parentObject)
      : base() {
      m_ParentObject = parentObject;
      InitializeComponent();
    } // Constructor PrintDefinitions

    // Constructor
    public PrintDefinitions (IContainer container, Assurfed_Utilit_Cfh_Copy parentObject)
      : base() {
      m_ParentObject = parentObject;
      InitializeComponent();
      container.Add(this);
    } // Constructor PrintDefinitions

  } // Class PrintDefinitions

} // Namespace Company.AFBUS_2200COBOL.BusinessLogic.Assurfed_Utilit_Cfh_Copy

