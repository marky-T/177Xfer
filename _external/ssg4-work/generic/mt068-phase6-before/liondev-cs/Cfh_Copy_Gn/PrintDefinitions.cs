using System;
using System.ComponentModel;
using Asysco.Amt.Runtime.Printing;

namespace Company.AFBUS_2200COBOL.BusinessLogic.Cfh_Copy_Gn {

  public partial class PrintDefinitions: AmtTextPrintDocument, IDisposable {
    #region Members
    private Cfh_Copy_Gn m_ParentObject;
    #endregion Members

    // Constructor
    public PrintDefinitions (Cfh_Copy_Gn parentObject)
      : base() {
      m_ParentObject = parentObject;
      InitializeComponent();
    } // Constructor PrintDefinitions

    // Constructor
    public PrintDefinitions (IContainer container, Cfh_Copy_Gn parentObject)
      : base() {
      m_ParentObject = parentObject;
      InitializeComponent();
      container.Add(this);
    } // Constructor PrintDefinitions

  } // Class PrintDefinitions

} // Namespace Company.AFBUS_2200COBOL.BusinessLogic.Cfh_Copy_Gn

