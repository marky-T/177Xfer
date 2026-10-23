# Environments for the generic-program pipeline. Paths follow AMT's own set-up names:
#   SYSROOT      = the AMT system folder (machine AMTSYSTEM; CC job files use %SYSROOT%)
#   AppName / AppBasepath = AMTSYSAPPLICATION APPNAME / APPBASEPATH (%APPROOT%; programs are %APPROOT%\programs)
#   Basepath     = the CC Basepaths configuration set (AMTSYSBASEPATH fields), only the fields we use
#   ScriptFolder = our folder under the Basepath ScriptPath (CC scans subfolders)
# %SYSROOT%, %APPROOT%, %WORKROOT% are expanded by Get-GnEnvironment (GnEnvironment.ps1).
@{
  Work = @{
    WorkRoot    = 'E:\Repos\ssg4-work'
    GenericWork = '%WORKROOT%\generic'
    SgsCards    = '%WORKROOT%\sgs-cards'
    # all calls expanded after the T3-045 landing (2026-10-21 17:37); allcalls\expanded-fix predates it
    Expanded    = '%WORKROOT%\allcalls\expanded-landed2'
    MockRoot    = 'E:\AMT_Work\MockTest'
    MockRebuild = 'E:\AMT_Work\Rebuild177a-spike\AFBUS_2200COBOL\Binaries\Programs'
    RebuildRoot = 'E:\AMT_Work\Rebuild177a-spike'
    LionDevelopment = 'E:\AMT_Work\Apps177\Development'
    PackageRoot = 'E:\AMT_Work\Delivery'
    MockRef     = 'E:\AMT_Work\MockTest\Ref'
  }
  Profiles = @{
    'CC-Trial' = @{
      Description  = 'Our trial application in the VM''s Control Center'
      SYSROOT      = 'E:\Repos\Federale_InternalRelease\AmtTools'
      AppName      = 'AFBUS_2200COBOL_AMT'
      # LionDev application the generic programs are generated in (namespace Company.<LionApp>, references <LionApp>.Application/Database)
      LionApp      = 'AFBUS_2200COBOL'
      AppBasepath  = 'E:\Repos\AMT\Apps\AFBUS_2200COBOL_AMT\Binaries'
      ScriptFolder = 'SSG4'
      Basepath     = @{
        ScriptPath  = '%SYSROOT%\Basepaths\Scripts'
        ExtractPath = '%SYSROOT%\Basepaths\Extracts'
        PrintPath   = '%SYSROOT%\Basepaths\Prints'
        LogPath     = '%SYSROOT%\Basepaths\Logs'
      }
    }
    'CC-Federale' = @{
      Description  = 'Release target: the client application (shares the default Basepaths set with CC-Trial on this VM)'
      SYSROOT      = 'E:\Repos\Federale_InternalRelease\AmtTools'
      AppName      = 'FEDERALE_APP'
      # to be confirmed: FEDERALE_APP's application DLLs are AFBUS.Application/Database
      LionApp      = 'AFBUS'
      # AFBUS generation set's Local Source folder + \Development (separate from the trial's Apps177)
      LionDevelopment = 'E:\AMT_Work\AppsAFBUS177\Development'
      AppBasepath  = 'E:\Repos\Federale_InternalRelease\AFBUS_AMT\Binaries'
      # own folder: Settings\AmtSettings.xml carries AppName, so it cannot share CC-Trial's SSG4
      ScriptFolder = 'SSG4FED'
      Basepath     = @{
        ScriptPath  = '%SYSROOT%\Basepaths\Scripts'
        ExtractPath = '%SYSROOT%\Basepaths\Extracts'
        PrintPath   = '%SYSROOT%\Basepaths\Prints'
        LogPath     = '%SYSROOT%\Basepaths\Logs'
      }
    }
    'Repo-BSP' = @{
      Description  = 'Federale_InternalRelease main since 2026-10-20: the application is BSP (BSP_AMT, Federale.BSP.BusinessLogic); no runtime of it on this VM'
      SYSROOT      = 'E:\Repos\Federale_InternalRelease\AmtTools'
      AppName      = 'FEDERALE_APP'
      LionApp      = 'BSP'
      LionDevelopment = 'E:\AMT_Work\AppsBSP177\Development'
      AppBasepath  = 'E:\Repos\Federale_InternalRelease-wt-ssg4\BSP_AMT\Binaries'
      ScriptFolder = 'SSG4BSP'
      Basepath     = @{
        ScriptPath  = '%SYSROOT%\Basepaths\Scripts'
        ExtractPath = '%SYSROOT%\Basepaths\Extracts'
        PrintPath   = '%SYSROOT%\Basepaths\Prints'
        LogPath     = '%SYSROOT%\Basepaths\Logs'
      }
    }
    'Mock' = @{
      Description  = 'Mock system (AMT_MOCKSYS, mock file controller on 18132); never Federale''s AmtTools'
      SYSROOT      = 'E:\AMT_Work\MockSystem'
      AppName      = 'AFBUS_2200COBOL'
      LionApp      = 'AFBUS_2200COBOL'
      AppBasepath  = 'E:\AMT_Work\Rebuild177a\AFBUS_2200COBOL\Binaries'
      ScriptFolder = 'SSG4'
      Basepath     = @{
        ScriptPath  = 'E:\AMT_Work\MockTest\Scripts'
        ExtractPath = 'E:\AMT_Work\MockTest\Extracts'
        PrintPath   = 'E:\AMT_Work\MockTest\Prints'
        LogPath     = 'E:\AMT_Work\MockTest\Logs'
      }
    }
  }
}
