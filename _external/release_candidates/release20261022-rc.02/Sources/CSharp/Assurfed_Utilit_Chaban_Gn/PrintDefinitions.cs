using System;
using System.ComponentModel;
using Asysco.Amt.Runtime.Printing;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Chaban_Gn {

  public partial class PrintDefinitions: AmtTextPrintDocument, IDisposable {
    #region Members
    private Assurfed_Utilit_Chaban_Gn m_ParentObject;
    #endregion Members

    // Constructor
    public PrintDefinitions (Assurfed_Utilit_Chaban_Gn parentObject)
      : base() {
      m_ParentObject = parentObject;
      InitializeComponent();
    } // Constructor PrintDefinitions

    // Constructor
    public PrintDefinitions (IContainer container, Assurfed_Utilit_Chaban_Gn parentObject)
      : base() {
      m_ParentObject = parentObject;
      InitializeComponent();
      container.Add(this);
    } // Constructor PrintDefinitions

  } // Class PrintDefinitions

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Chaban_Gn

