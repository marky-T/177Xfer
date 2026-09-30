#-------------------------------------------------------------------------------
# AMT PowerShell Library for converted ECL
#-------------------------------------------------------------------------------
[String]$global:LibraryVersionDate = "Amt PS ECL library version: 60.409, date: 2022-03-11"

# Enable strict mode so an error message is shown when trying to retrieve a variable that has not (yet) been set.
# note: Do not change the order of Set-PsDebug and Set-Strictmode, it will not work if swapped.
Set-PsDebug -Strict
Set-StrictMode -Version 2

# note: This must be early in the script to make it work if 
#       an error occurs before the entire script is read.
function HandleTrapAndAbort {
  <#
    .SYNOPSIS
      Handles a runtime exception.
    .DESCRIPTION
      Handles a trapped exception by outputing information and terminating the script.
    .PARAMETER Message
    .PARAMETER Message
      [String] The introductory message.
    .PARAMETER ErrorObject
      [Object] The error object containing information to be output.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Message,
    [Object]$ErrorObject
  )

  # show error message & stack trace)
  Add-ErrorMsg ($Message + "  " +  $ErrorObject.ToString())
  Add-ErrorMsg $ErrorObject.ScriptStackTrace

  # shutdown")
  Abort "Script aborted."
} # HandleTrapAndAbort


function HandleExceptionAndAbort {
  <#
    .SYNOPSIS
      Handles a runtime exception.
    .DESCRIPTION
      Handles a caught exception by outputing information and terminating the script.
    .PARAMETER Message
      [String] The introductory message.
    .PARAMETER ErrorObject
      [Object] The error object containing information to be output.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Message,
    [Object]$ErrorObject
  )

  # show error message & stack trace)
  Add-ErrorMsg ($Message + "  " +  $ErrorObject.ToString())
  Add-ErrorMsg $ErrorObject.ScriptStackTrace

  Abort "Script aborted."
} # HandleExceptionAndAbort


# Register Exit event to make sure Cleanup is called when the script exits
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
  Cleanup $false
}

#-------------------------------------------------------------------------------
# Constants
#-------------------------------------------------------------------------------
[Int32]$global:Const_Exclusive       = 1
[Int32]$global:Const_ExclusiveBatch  = 2
[Int32]$global:Const_SharedReadWrite = 3
[Int32]$global:Const_SharedRead      = 4
[Int32]$global:Const_ReadBufSize     = 2048

[Int32]$global:Const_FileEnc_Autodetect = 0
[Int32]$global:Const_FileEnc_ASCII      = 1
[Int32]$global:Const_FileEnc_Unicode    = 2

[Int32]$global:Const_JobSummary_Default       = 0
[Int32]$global:Const_JobSummary_Conditional   = 1
[Int32]$global:Const_JobSummary_Suppressed    = 2
[Int32]$global:Const_JobSummary_Unconditional = 3
[Int32]$global:Const_JobSummary_AbortOnly     = 4

[Int32]$global:Const_JobType_Script       = 1
[Int32]$global:Const_JobType_Batch        = 2
[Int32]$global:Const_JobType_Report       = 3
[Int32]$global:Const_JobType_Executable   = 4
[Int32]$global:Const_JobType_CobolProgram = 5

[Int32]$global:Const_JobState_Idle                =  0
[Int32]$global:Const_JobState_Queued              =  1  # Queued for future start in current timeframe.
[Int32]$global:Const_JobState_Running             =  2  # Started manual or by scheduler.
[Int32]$global:Const_JobState_Killed              =  3  # Job was killed.
[Int32]$global:Const_JobState_Done                =  4  # Job has ended the normal way.
[Int32]$global:Const_JobState_Suspended           =  5  # Queued job has not started on time.
[Int32]$global:Const_JobState_Skipped_By_Op       =  6  # Suspended job skipped through control center.
[Int32]$global:Const_JobState_Run_Manual          =  7  # Manually started through control center.
[Int32]$global:Const_JobState_Run_Forced          =  8  # Forced start manual, start this job even when jobserver halted.
[Int32]$global:Const_JobState_Run_Debug           =  9  # When a report is started from Visual Studio.
[Int32]$global:Const_JobState_Del_Queue           = 10  # Job is deleted from queue.
[Int32]$global:Const_JobState_Error               = 11  # Job ended in error.
[Int32]$global:Const_JobState_Aborted             = 12  # The Job was aborted on purpose in the bussness-logic.
[Int32]$global:Const_JobState_WaitForFile         = 13  # Waiting for a file.
[Int32]$global:Const_JobState_WaitForInputRequest = 14  # Waiting for request.
[Int32]$global:Const_JobState_WaitForJob          = 15  # Waiting for another job to finish.
[Int32]$global:Const_JobState_WaitForReport       = 16  # Waiting for a report to finish, for future use.
[Int32]$global:Const_JobState_Reserved1           = 17  # Reserved for future use.
[Int32]$global:Const_JobState_RecoverCP           = 18  # This job (report) is a request to recover from a saved critical point.
[Int32]$global:Const_JobState_Undefined           = 19  # State is undefined.
[Int32]$global:Const_JobState_WaitForQueue        = 20  # Waiting for queue start time.
[Int32]$global:Const_JobState_WaitForDebugger     = 21  # Waiting for a lion debugger to start debug session of Job.
[Int32]$global:Const_JobState_AbortedWithRecover  = 22  # The job was aborted and may be recovered.
[Int32]$global:Const_JobState_KilledWithRecover   = 27  # The job was killed but can be recovered.

[Int32]$global:Const_GeneralErrorExitCode = 1

#-------------------------------------------------------------------------------
# Global variables
#-------------------------------------------------------------------------------
[xml]$global:AmtSettings     = $null

[String]$global:JobPath      = ""       # Path to the current job
[Object]$global:Com          = $null
[String]$global:Station      = $null
[String]$global:User         = ""
[String]$global:WindowsUser  = ""
[String]$global:SystemPath   = ""
[String]$global:MyEnv        = ""
[Boolean]$global:Development = $false

[String]$global:ExtractPath  = ""
[String]$global:TempFolder   = ""                  # Temporary folder for the current job
[String]$global:Message      = ""                  # Used to store a message for later use
[Boolean]$global:AbortCalled = $false              # Used to check whether dot-sourced scripts has called Abort. So it's parent must also abort.
[Boolean]$global:CleanedUp   = $false              # Used to check whether cleanup is already done before.
[Boolean]$global:SkipWriteToEventLog = $false      # Make sure we don't recursive call the same routine

[String]$global:JobName             = "[Unknown]"  # Job name as defined in the ECL.  note: This is RUNID !
[String]$global:CurrentScriptBaseName = ""         # The base name of the executing converted script (might come in handy).
[Int32]$global:RequestId            = 0
[Int32]$global:JobNumber            = 0
[Int32]$global:BatchId              = 0
[String]$global:Initiator           = "BATCH"
[String]$global:InitiatingUser      = "BATCH"
[Boolean]$global:SPO                = $false
[Boolean]$global:UseExtension       = $true
[String]$global:Extension           = ".DAT"
[Int32]$global:MyTaskValue          = 0
[Int32]$global:TaskFault            = 0
[Int32]$global:ErrorCode            = 0
[String]$global:ErrorDescription    = ""
[Boolean]$global:IgnoreTaskFault    = $false       # Leave this value to false. It will be set 
                                                   # temporarily to true when a routine calls routines
                                                   # that call On-Taskfault and On-Taskfault should not
                                                   # be called.
[Boolean]$global:DelFilesBeforeCopy = $false       # Set to $true if the destination files of a 
                                                   # COPY or RENAME need to be removed first. Is
                                                   # needed if ReadOnly files can be present.

[Boolean]$global:InCleanup          = $false       # Prevent endless loop in Abort

[Int32]$global:RecoverId            = -1           # The recovery point from which to recover (this is a process job id).
[Boolean]$global:Recover            = $false       # The user/starter indicated a recovery from a recovery point should be attempted.
[Boolean]$global:Recovered          = $false       # A recovery attempt has been made for the specified report in this script run.
[Boolean]$global:Overwrite          = $false       # The user/starter indicated a recovery point should be deleted.
[Boolean]$global:Overwritten        = $false       # An overwrite attempt has been made for the specified report in this script run.
[Boolean]$global:Restart            = $false       # This script was started with a RESTART label value.
[String]$global:RestartLabel        = $false       # The restart label if one was provided.
[Boolean]$global:RestartLabelVisited = $false      # This tells whether a provided restart label was visited or not.


[Object]$global:LockedFilesList = New-Object 'System.Collections.Generic.Dictionary[String, Object]'  # List of locked files (PowerShell dictionary)
[Boolean]$global:JobWait        = $false
[Object]$global:GlobalFilesList = New-Object 'System.Collections.Generic.List[String]' # List of global files
[Object]$global:TaskObjectsList = New-Object 'System.Collections.Generic.Dictionary[String, Boolean]'  # List of Task objects and it's initialisation state

# Printing
[Boolean]$global:Banner          = $false
[String] $global:DefaultPrinter  = ""              # Printer for whole job
[Boolean]$global:NoDateSubDir    = $true

# QUAL
[String]$global:DefaultQual  = ""
[String]$global:ProjectQual  = ""
[String]$global:QualPath     = ""
[String]$global:ImpliedQual  = ""
[Boolean]$global:FirstQual   = $true

# JUMP
[Int32]$global:JumpCount     = 0                   # Number of statements to skip in a JUMP statement
[String]$global:JumpLabel    = ""                  # Name of the label where the JUMP statement will jump to

# SSG
[Int32]$global:InSsg                 = 0           # > 0 when subroutine ssg (replacement for SSG in main run) is executing  
[Boolean]$global:SsgOptionB          = $false      # True when SSG option B is used
[Object]$global:SgsLabels            = $null       # The current set of SGS values (System.Collections.Generic.Dictionary[String, Object])
[Object]$global:SgsLabelStack        = New-Object 'System.Collections.Stack'
[String]$global:GlobalSgsLabels      = ""
[String]$global:CommandLineSgsLabels = ""
[String[]]$global:CmdSgsLabelArray   = $null

# Run condition word
[Boolean]$global:Rcw              = $false
[Int32[]]$global:RcwBits          = New-Object Int32[] 36   # Zero-based array containing the bitsequence (0-35) of the run condition word
[Boolean]$global:WarningRCW24d35  = $false

# SETC
[Boolean]$global:SetcA       = $true    # True means normal termination of the run.
                                        # False means continue after a terminating error.

# ASG
[Object]$global:FileHandle   = $null

[Boolean]$global:UseFound    = $false   # True when a Use Name is found when calling Check-UseName.
                                        # (Set to False before calling CheckUseName.)

[Object]$global:UseNameObject = $null   # Object containing Use name and file info 
 #Member Usename                        # The usename of the file/usename
 #Member Filename                       # The file/usename
 #Member FileObject                     # The FileObject with all info regarding this file

[Object]$global:UseNamesList = New-Object 'System.Collections.Generic.List[Object]' # List of UseNameObjects

[Object]$global:FileObject = $null      # File object containing info about a catalogued/assigned file
 #Member Filename                       # The name of the file
 #Member Cyclename                      # The name of the file including file cycle
 #Member FileHandle                     # The handle of the file; Null -> no handle (after delete -1); >= 0 handle
 #Member DeleteOnFree                   # True or False for deleting the file after a free command False -> no delete; True -> delete
 #Member Copyname                       # The name of the copied file If it is exclusive assigned. Empty when it is a temporary file
 #Member DeleteOnError                  # True or False for deleting the file If a job has gone into error
 #Member ChangeReadOnly                 # -> 0 no read property change, 
                                        # -> 1 read property of a file must be set after the free or termination, 
                                        # -> 2 remove read property.
 #Member IsAssigned                     # True if the file was assigned, false when only cataloged
 #Member IsCataloged                    # True if the file was cataloged
 #Member CHG_N_name                     # The CHG,N statement that has been done for an assigned file
 #Member IsASG_I                        # True If ASG,I file (Free at next task termination)

[Object]$global:FilesList = New-Object 'System.Collections.Generic.List[Object]' # List of FileObjects


# Wait-ForFile
[Object]$global:WaitStartTime     = $Null   # Contains the start DatTime of a wait loop.
[Int32]$WaitInterval              = 0       # Contains the display interval for a wait loop.
[Int32]$global:RepeatMsgTime      = 300

# File Control Error
[Int32]$global:FileControlErrNo   = 0       # Contains the error code when an error occurs during file handling.
[String]$global:FileControlErrMsg = ""      # Contains the error message when an error occurs during file handling.

# XQT
[String]$global:XqtReport         = ""
[Object]$global:AcceptFile        = $null
[Boolean]$global:AcceptOpen       = $false

# SYM
[Boolean]$global:DelJobLogFile    = $false
[Boolean]$global:SymDF            = $false
[String]$global:SymJobLogPrinter  = ""

# Dynamic ECL
[String]$global:TempPs1File       = "" 

# Dataline statements (the if is a hack to work around an unresolved issue in the STA test environment)
if (-not ([System.Management.Automation.PSTypeName]'EclDatalineStatement').Type) {
Add-Type -TypeDefinition @"
  public enum EclDatalineStatement {
    None, 
    Data, 
    Sort, 
    Xqt, 
    Ssg, 
    Dd,
    RdmsLoad
  }
"@
}
[EclDatalineStatement]$global:PreviousStatement = [EclDatalineStatement]::None

# IPF  (the if is a hack to work around an unresolved issue in the STA test environment)
if (-not ([System.Management.Automation.PSTypeName]'IpfObjectSpaceType').Type) {
Add-Type -TypeDefinition @"
  public enum IpfObjectSpaceType {
    Workspace, 
    Lookspace
  }
"@
}

[Object]$global:IpfWorkSpace = $null    # Holds a number of workspace specific system variables and a list of lines and linenumbers
[Object]$global:IpfLookSpace = $null    # Similar to workspace

[IpfObjectSpaceType]$global:IpfSwitch = [IpfObjectSpaceType]::Workspace

[String]$global:IpfOutFilename = ""     # contains file set by Ipf-Out command.

#-------------------------------------------------------------------------------
# IPF System Variables
#-------------------------------------------------------------------------------
# These will be initialized to their default values at the start of every IPF 
# session when Initialize-IpfSystemVariables is called. The values assigned here 
# will never be used, we just need to assign something to keep PowerShell happy.

[String]  $global:IpfSv_Device          = ""      #
[String]  $global:IpfSv_JobId           = ""      #
[String]  $global:IpfSv_ChangeString    = ""      #
[String]  $global:IpfSv_Language        = ""      #
[String]  $global:IpfSv_LocateString    = ""      #
[String]  $global:IpfSv_SqlAuxiliary    = ""      #
[String]  $global:IpfSv_SqlError        = ""      #
[String]  $global:IpfSv_SqlReturnCode   = ""      #
[String]  $global:IpfSv_WorkDirectory   = ""      #

[Int32]   $global:IpfSv_CommandLines    = 0       #
[Int32]   $global:IpfSv_CurrentColumn   = 0       #
[Int32]   $global:IpfSv_EndColumn       = 0       #
[Int32]   $global:IpfSv_Jumps           = 0       #
[Int32]   $global:IpfSv_LineInteger     = 0       #
[Int32]   $global:IpfSv_LineFraction    = 0       #
[Int32]   $global:IpfSv_Results         = 0       #
[Int32]   $global:IpfSv_StartColumn     = 0       #

[Decimal] $global:IpfSv_TopImage        = 0       #
[Decimal] $global:IpfSv_BottomImage     = 0       #
[Decimal] $global:IpfSv_CurrentImage    = 0       #
[Decimal] $global:IpfSv_Increment       = 0       #
[Decimal] $global:IpfSv_MatchLine       = 0       #

[char]    $global:IpfSv_CommentChar     = " "     #
[char]    $global:IpfSv_ContChar        = " "     #
[char]    $global:IpfSv_DelimChar       = " "     #
[char]    $global:IpfSv_MultiCmdChar    = " "     #
[char]    $global:IpfSv_OmniPresentChar = " "     #

[Boolean] $global:IpfSv_CaseSensitive   = $false  #
[Boolean] $global:IpfSv_CommandError    = $false  #
[Boolean] $global:IpfSv_Completions     = $false  #
[Boolean] $global:IpfSv_FullScreen      = $false  #
[Boolean] $global:IpfSv_ProcDebug       = $false  #
[Boolean] $global:IpfSv_ProcId	        = $false  #
[Boolean] $global:IpfSv_ReadOnly        = $false  #
[Boolean] $global:IpfSv_SqlFileDisplay  = $false  #
[Boolean] $global:IpfSv_SqlScreen       = $false  #

# "enumerations"
[String]  $global:IpfSv_Conflict        = ""      # {SEGMENT | ERROR | OVERWRITE}
[String]  $global:IpfSv_DataManager     = ""      # {UNSPECIFIED | RDMS}
[String]  $global:IpfSv_Display         = ""      # {NONUMBER | NUMBER}
[String]  $global:IpfSv_Matching        = ""      # {OFF | PARTIAL | FULL}
[String]  $global:IpfSv_Output          = ""      # {BRIEF | FULL | COMPRESS | SCALE}
[String]  $global:IpfSv_RetainPosition  = ""      # {RESET | PRESERVE}

#-------------------------------------------------------------------------------
# AmtSettings.xml variables
#-------------------------------------------------------------------------------
[String]$global:AppName                 = ""
[String]$global:SysIniFile              = $null
[String]$global:ComScriptDll            = $null
[String]$global:ApplicationKind         = ""
[String]$global:DefaultDontPrint        = $true

# Logging
[Boolean]$global:UseJobLog              = $true
[String] $global:JobLogFile             = ""
[String] $global:JobLogFileOrig         = ""
[Boolean]$global:LogTimes               = $true
[Boolean]$global:LogEventError          = $true
[Boolean]$global:LogEventInfo           = $false
[Boolean]$global:LogEventWarning        = $false
[Int32]$global:JobSummaryValue          = $global:Const_JobSummary_Default
[Int32]$global:JobSummaryLineNr         = 0
[Int32]$global:JobSummaryLinesPP        = 66      # Lines per page in jobsummary 
[Int32]$global:JobSummaryPageNr         = 0
[Boolean]$global:JobSummaryPageSkip     = $false

[Boolean]$global:JobLogFileAvailable    = $false  # True as soon as the joblog file is available for writing.
[Object]$global:JobLogObj               = $null   # Job log object.
[Boolean]$global:KeepJobLogDevelopment  = $true
[String]$global:BrkptFilename            = ""
[String]$global:RemoveFromFilename      = ""      # String (containg path) that can be removed from filename if 
                                                  # this filename is used in the logged message.
[Object]$global:StartDateTimeObj        = $null   # DateTime object containg start date and time of the script.
[Boolean]$global:FirstExtractFile       = $true
[Boolean]$global:Debug                  = $false  # For report debugging, has nothing to do with verbose logging.
[Boolean]$global:DeleteEmptyFolders     = $false  # This switch will delete the folders that don't contain any file.

[String]$global:HdgText                 = ""      # Page heading text (set by @HDG statement)

#Logging severity of a message. 
if (-not ([System.Management.Automation.PSTypeName]'LoggingSeverity').Type) {
Add-Type -TypeDefinition @"
  public enum LoggingSeverity {
    Error   = 0,             
    Warning = 1, 
    Info    = 2,
    Debug   = 3, 
  }
"@
}
[LoggingSeverity]$global:LoggingSeverity = [LoggingSeverity]::Info   # To mimic ECl like logging as far as possible 



#-------------------------------------------------------------------------------
# Email
#-------------------------------------------------------------------------------
[Int32]  $global:MailLogLevel           = 0       # Set in AmtSettings.XML. 
                                                  # 0: None, 1: Only errors,
                                                  # 2: Warnings and errors, 3: Info, warnings and errors.
[String] $global:MailTestAddress        = ""      # Set in AmtSettings.XML. 
                                                  # When filled, this mail address will be used for all mails.
                                                  # When not filled in the development environment, NO mails will be sent.
[String] $global:MailFrom               = ""      # Set in AmtSettings.XML. Sender address.
[String] $global:MailServer             = ""      # Set in AmtSettings.XML. 
[Int32]  $global:MailPort               = 0       # Set in AmtSettings.XML. 
[String] $global:MailLogon              = ""      # Set in AmtSettings.XML. SMTP auth user.
[String] $global:MailPassword           = ""      # Set in AmtSettings.XML. SMTP auth password.
[Boolean]$global:MailUseSSL             = $false  # Set in AmtSettings.XML. Use SSL
[String] $global:MailRecipient          = ""      # Set in AmtSettings.XML. Recipient of logging E-mails

#-------------------------------------------------------------------------------
# FTP
#-------------------------------------------------------------------------------
[Boolean]$global:FTPCreateFolders       = $false # If $true create missing folders on remote FTP server (for PUT command only)
[Boolean]$global:FTPTestSettings        = $false # If $true override FTP settings with test settings (as defined in settings file)
[String] $global:FTPTestDest            = ""
[String] $global:FTPTestHost            = ""
[String] $global:FTPTestUser            = "" 
[String] $global:FTPTestPassword        = ""
[String] $global:FTPCommandFile         = ""     # Is defined as global, to enable multipe FTP calls in one job to be merged
                                           # into one FTP command (for performance/timing reasons).
[String] $global:FTPLogFile             = ""
[Boolean]$global:FTPDeleteFiles         = $false

#-------------------------------------------------------------------------------
# COM objects
#-------------------------------------------------------------------------------
[Object]$global:AmtMessage              = $null
[Object]$global:AmtFile                 = $null
[Object]$global:AmtPath                 = $null
[Object]$global:AmtReport               = $null
[Object]$global:AmtPrint                = $null
[Object]$global:AmtScript               = $null
[Object]$global:AmtSort                 = $null
[Object]$global:AmtDatabase             = $null

#-------------------------------------------------------------------------------
# Import extra (customer specific) libraries
#-------------------------------------------------------------------------------
Import-Module -Name "$PSScriptRoot\AmtPsCustomerLib.psm1" -Scope Global -Force -DisableNameChecking -ErrorAction Stop -ArgumentList $args

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------


function GetAmtSetting {
  <#
    .SYNOPSIS
      Gets a setting from AmtSettings.xml
    .PARAMETER Name
      [String] The setting's name.
    .PARAMETER Type
      [Type] The setting's type.
    .PARAMETER Default
      [String] The setting's default value.
    .OUTPUTS
      [Int] The output value.
  #>
  
  param (
    [Parameter(Mandatory=$true)][String]$Name,
    [Type]$Type=[String],
    [Object]$Default=$null
  )

  [System.Xml.XmlNode]$Node = $global:AmtSettings.Amt.AmtSettings.SelectSingleNode($Name)
  if ($Node -ne $Null) {
    if ($Type -eq [Boolean]) {
      return [System.Convert]::ToBoolean($Node.InnerText)
    } elseif ($Type -eq [Int32]) {
      return [System.Convert]::ToInt32($Node.InnerText)
    } else {
      return $Node.InnerText
    }
  } else {
    return $Default
  }
}


function Initialize {
  <#
    .SYNOPSIS
      Initialize Library
  #>
  
  param (
    [Parameter(Mandatory=$true)][String]$AmtSettingsFile
  )

  #Set $LASTEXITCODE system variable at start of script, the batchcontroller checks for it,
  #in rare cases it might not be there (when cleanup called from the Exit event)
  $global:LASTEXITCODE = 0

  # Check if ECL options file exists
  $OptionsFilePath = "$PSScriptRoot\EclOptions.psm1"
  if (Test-Path $OptionsFilePath) {
    # . $OptionsFilePath
    Import-Module -Name $OptionsFilePath -Force -DisableNameChecking -ErrorAction Stop
  } else {
    Write-Host "Could not find ECL options file: $OptionsFilePath" -fore red
    [Console]::Error.WriteLine("Could not find ECL options file (Exit 1).")
    # note: This will do nothing in PowerShell ISE, it tells BatchController there was an error.
    Call-Exit-One
  }

  # Check if AmtSettings XML file exists
  if (Test-Path $AmtSettingsFile) {
    $global:AmtSettings = [xml](Get-Content $AmtSettingsFile)
    if ($global:AmtSettings -eq $null) {
      Write-Host "Get-Content of AmtSettings file ($AmtSettingsFile) failed" -fore red
      [Console]::Error.WriteLine("Get-Content of AmtSettings file ($AmtSettingsFile) failed (Exit 1).")
      # note: This will do nothing in PowerShell ISE, it tells BatchController there was an error.
      Call-Exit-One
    }
  } else {
    Write-Host "Could not find settings file: $AmtSettingsFile" -fore red
    [Console]::Error.WriteLine("Could not find settings file: $AmtSettingsFile (Exit 1).")
    # note: This will do nothing in PowerShell ISE, it tells BatchController there was an error.
    Call-Exit-One
  }

  # Get general settings from AmtSettings.xml
  [String]$global:AppName                   = GetAmtSetting "AppName"
  [String]$global:SysIniFile                = GetAmtSetting "IniFile"
  [String]$global:ComScriptDll              = GetAmtSetting "ComScript"
  [String]$global:ApplicationKind           = GetAmtSetting "ApplicationKind"

  [Boolean]$global:UseJobLog                = GetAmtSetting "UseJobLog"                ([Boolean])
  [Boolean]$global:LogTimes                 = GetAmtSetting "LogTimes"                 ([Boolean])
  [Boolean]$global:LogEventError            = GetAmtSetting "LogEventError"            ([Boolean])
  [Boolean]$global:LogEventInfo             = GetAmtSetting "LogEventInfo"             ([Boolean])
  [Boolean]$global:LogEventWarning          = GetAmtSetting "LogEventWarning"          ([Boolean])
  [Boolean]$global:DefaultDontPrint         = GetAmtSetting "DefaultDontPrint"         ([Boolean]) $true
  [Boolean]$global:UseUnicode               = GetAmtSetting "UseUnicode"               ([Boolean]) $true
  [Boolean]$global:DeleteEmptyFolders       = GetAmtSetting "DeleteEmptyFolders"       ([Boolean]) $false
      
  [String]$global:DefaultPrinter            = GetAmtSetting "DefaultPrinter"
  [String]$global:DefaultBDFolder           = GetAmtSetting "DefaultBDFolder"

  # Mail settings
  [Int32]$global:MailLogLevel               = GetAmtSetting "MailLogLevel"             ([Int32])
  [String]$global:MailTestAddress           = GetAmtSetting "MailTestAddress"
  [String]$global:MailFrom                  = GetAmtSetting "MailFrom"
  [String]$global:MailServer                = GetAmtSetting "MailServer"
  [Int32]$global:MailPort                   = GetAmtSetting "MailPort"                 ([Int32])
  [String]$global:MailLogon                 = GetAmtSetting "MailLogon"
  [String]$global:MailPassword              = GetAmtSetting "MailPassword"
  [Boolean]$global:MailUseSSL               = GetAmtSetting "MailUseSSL"               ([Boolean])
  [String]$global:MailRecipient             = GetAmtSetting "MailRecipient"

  # FTP Settings
  [Boolean]$global:FTPCreateFolders         = GetAmtSetting "FTPCreateFolders"         ([Boolean])
  [Boolean]$global:FTPTestSettings          = GetAmtSetting "FTPTestSettings"          ([Boolean])
  [String]$global:FTPTestDest               = GetAmtSetting "FTPTestDest"
  [String]$global:FTPTestHost               = GetAmtSetting "FTPTestHost"
  [String]$global:FTPTestUser               = GetAmtSetting "FTPTestUser"
  [String]$global:FTPTestPassword           = GetAmtSetting "FTPTestPassword"
  [Boolean]$global:FTPDeleteFiles           = GetAmtSetting "FTPDeleteFiles"           ([Boolean])

  # Settings for clone reports
  if (Get-Member -inputobject $global:AmtSettings.Amt -name "CloneReports" -Membertype Properties) {
  	$global:CloneReports = $global:AmtSettings.Amt.CloneReports.OrginalReport
  } else {
  	$global:CloneReports = $null
  }

  if ($global:AmtSettings.Amt.AmtSettings.SelectSingleNode("LoggingSeverity") -ne $null) {
    $global:Loggingseverity = [Enum]::Parse([Type][Loggingseverity], $global:AmtSettings.Amt.AmtSettings.LoggingSeverity)
  }
  $global:WarningRcw2435 = GetAmtSetting "WarningRcw2435"       ([Boolean]) $false

  # Create COM object of ComScript module
  Add-Type -Path $global:ComScriptDll
  $global:Com = New-Object Asysco.Amt.Scripting.Comscript
  Check-RuntimeError $global:Com.ErrorCode "Init Create Com" "Failed initializing COM object" $global:Com.ErrorDescription

  $global:Initiator        = Get-Initiator
  $global:InitiatingUser   = Get-InitiatingUser

  # Connect to the application
  Connect-Application

  $global:FTPPath          = ((Add-BackSlash $global:SystemPath) + (GetAmtSetting "FTPPath")).TrimEnd('\')
  $global:StartDateTimeObj = Get-Date
  $global:RequestId        = Get-RequestId
  $global:JobNumber        = Get-JobNumber
  $global:BatchId          = Get-BatchId
  
  $global:AmtPath    = $global:Com.CreatePath()        # AMT Path object
  Check-RuntimeError $global:Com.ErrorCode "Init Create Com" "Failed initializing Comscript Path object" $global:Com.ErrorDescription
  
  # AMT path object is available, create and use an initial log (until the file controller is up and running).
  Create-InitialJobLog
  
  $global:AmtMessage = $global:Com.CreateMessage()     # Message object
  Check-RuntimeError $global:Com.ErrorCode "Init Create Com" "Failed initializing Comscript Message object" $global:Com.ErrorDescription
  $global:AmtFile    = $global:Com.CreateFileObject()  # File object
  Check-RuntimeError $global:Com.ErrorCode "Init Create Com" "Failed initializing Comscript File object" $global:Com.ErrorDescription
  $global:AmtScript  = $global:Com.CreateJob()         # Used for scripts
  Check-RuntimeError $global:Com.ErrorCode "Init Create Com" "Failed initializing Comscript Job object" $global:Com.ErrorDescription
  $global:AmtReport  = $global:Com.CreateJob()         # Used for reports
  Check-RuntimeError $global:Com.ErrorCode "Init Create Com" "Failed initializing Comscript Report object" $global:Com.ErrorDescription
  $global:AmtPrint   = $global:Com.CreatePrint()
  Check-RuntimeError $global:Com.ErrorCode "Init Create Com" "Failed initializing Comscript Print object" $global:Com.ErrorDescription
  $global:AmtDatabase = $global:Com.CreateDatabase()
  Check-RuntimeError $global:Com.ErrorCode "Init Create Com" "Failed initializing Comscript Database object" $global:Com.ErrorDescription
  
  $global:Development = $global:Com.Development

  Init-JobLog
  Get-PathsForCurrentApp

  Initialize-IpfSystemVariables

  # Initialize Sort library
  Sort-Init | Out-Null

  # Create temporary folder for each job
  Create-TempFolder
  [String]$StartedMessage = "Script Started: $($global:JobName)"
  
  # Read Global SGS values (available to any job)
  $SgsFileName = "$PSScriptRoot\..\P`$SGS\_ALL_"
  if ([System.IO.File]::Exists($SgsFileName)) {
    $global:GlobalSgsLabels = [System.IO.File]::ReadAllText($SgsFileName)
  }

  # pick up command line arguments and validate
  foreach ($arg in $args) {

    $SeverityIsValid    = $false
    $RecoverIsValid     = $false
    $OverwriteIsValid   = $false
    $SgsIsValid         = $false
    $SetcIsValid        = $false

    if ($arg.GetType().Name -ne 'String') {
     continue 
    }
  
    if ($arg.StartsWith("/loggingseverity:", [System.StringComparison]::OrdinalIgnoreCase)) {
      $StartedMessage += " parameter: $($arg)"
      $global:Loggingseverity = [Enum]::Parse([Type][Loggingseverity], $arg.Substring(17))
      $SeverityIsValid = $true
    } elseif ($arg.StartsWith("/severity:", [System.StringComparison]::OrdinalIgnoreCase)) {
      $StartedMessage += " parameter: $($arg)"
      $global:Loggingseverity = [Enum]::Parse([Type][Loggingseverity], $arg.Substring(10))
      $SeverityIsValid = $true
    } elseif ($arg.StartsWith("/s:", [System.StringComparison]::OrdinalIgnoreCase)) {
      $StartedMessage += " parameter: $($arg)"
      $global:Loggingseverity = [Enum]::Parse([Type][Loggingseverity], $arg.Substring(3))
      $SeverityIsValid = $true
    }

    # recover (from whatever recovery point)
    if ($arg.Equals("/recover", [System.StringComparison]::OrdinalIgnoreCase) -or $arg.Equals("/r", [System.StringComparison]::OrdinalIgnoreCase)) {
      $global:Recover = $true
      $RecoverIsValid = $true
    }

    # recover (from specific process job)
    if ($arg.StartsWith("/recover:", [System.StringComparison]::OrdinalIgnoreCase)) {
      $global:Recover = $true
      if (-not [Int32]::TryParse($arg.Substring(9), [ref] $global:RecoverId)) {
        Abort "The specified recover id must be numeric."
      }

      $RecoverIsValid = $true
    }

    if ($arg.StartsWith("/r:", [System.StringComparison]::OrdinalIgnoreCase)) {
      $global:Recover = $true
      if (-not [Int32]::TryParse($arg.Substring(3), [ref] $global:RecoverId)) {
        Abort "The specified recover id must be numeric."
      }

      $RecoverIsValid = $true
    }

    # overwrite (any recovery point)
    if ($arg.Equals("/overwrite", [System.StringComparison]::OrdinalIgnoreCase) -or $arg.Equals("/o", [System.StringComparison]::OrdinalIgnoreCase)) {
      $global:Overwrite = $true
      $OverwriteIsValid = $true
    }

    # overwrite (a specific process job)
    if ($arg.StartsWith("/overwrite:", [System.StringComparison]::OrdinalIgnoreCase)) {
      $global:Overwrite = $true
      if (-not [Int32]::TryParse($arg.Substring(11), [ref] $global:RecoverId)) {
        Abort "The specified recover id must be numeric."
      }

      $OverwriteIsValid = $true
    }

    if ($arg.StartsWith("/o:", [System.StringComparison]::OrdinalIgnoreCase)) {
      $global:Overwrite = $true
      if (-not [Int32]::TryParse($arg.Substring(3), [ref] $global:RecoverId)) {
        Abort "The specified recover id must be numeric."
      }

      $OverwriteIsValid = $true
    }

	if ($global:Recover -and $global:Overwrite) {
        Abort "Recover and Overwrite cannot be combined."
	}

    if ($arg.StartsWith("SGS:", [System.StringComparison]::OrdinalIgnoreCase)) {
      # Assume SGS:
      $validate = $arg.substring(4,$arg.length - 4)
      $validateCommand = $validate.split(' ')
      if ($validateCommand.count -eq 2) {
        $sgsCommand = $validateCommand[0]
        $SgsLabel = $validateCommand[1]
        if ($sgsCommand -ceq "BREAK" -or $sgsCommand  -ceq "RESTART") {
          $SgsIsValid = $true
        } else {
          Abort "SGS only supports BREAK or RESTART."
        }
      } else {
        Abort "SGS command $arg not correct."
      }
    }

    if ($arg.StartsWith("/setc:", [System.StringComparison]::OrdinalIgnoreCase)) {
      # Assume Setc: (MWA)
      $StartedMessage += " parameter: $($arg)"
      Setc "" $arg.substring(6, $arg.length - 6)
      $SetcIsValid = $true
    }

    # something should have been approved except when the script handles arguments too.
    if ((-not $SeverityIsValid ) -and
        (-not $RecoverIsValid  ) -and
        (-not $OverwriteIsValid) -and
        (-not $SgsIsValid      ) -and
        (-not $SetcIsValid     )) {
      Add-WarningMsg "Argument $arg is unknown to the script library."
    }
  }

  # Read SGS command line overrides.
  # SGS labels on the command line are expected to be in this format: "SGS:LABELNAME 1,2 3 4"
  # (that is the SGS format as documented, prefixed with "SGS:" and double-quoted to make it one argument)
  # Multiple SGS overrides may be passed as such.
  foreach ($arg in $args) {
    if ($arg.GetType().Name -eq 'String') {
      $arg = $arg.TrimStart()
      if ($arg.StartsWith("SGS:")) {
        $global:CommandLineSgsLabels = $global:CommandLineSgsLabels + $arg.Substring(4) + "`r`n"
      }
    }
  }
  Add-InformationMsg $StartedMessage

} # Initialize


function Call-Exit-One {
  <#
    .SYNOPSIS
     This function does a hard Exit 1. If a normal Exit 1 is used it will end the started script 
     and return to the mother script, which will continue but with the aborted flag set. This will 
     cause multiple "(Exit 1)" messages.
     With [Environment]::Exit(1), the script is brutally stopped at one. No further processing is done.
     Exception is made for debuggers like PowerGui and or PowerShell ISE.
  #>

  # if not debugging (in PowerShell ISE, PowerGui, VS Code PowerShell extension or PowerShell command window)
  $HostNameCommandWindow = "ConsoleHost"
  $HostNamePowerShellISE = "Windows PowerShell ISE Host"
  $HostNamePowerGui      = "PowerGUIScriptEditorHost"
  $HostNameVSCode        = "Visual Studio Code Host"

  $Global:AmtExitCode = 1
 
  if (($Host.name -ne $HostNamePowerShellISE) -and
      ($Host.name -ne $HostNamePowerGui     ) -and
      ($Host.name -ne $HostNameVSCode       )) {
    [Environment]::Exit(1)
  } else {
    Exit 1
  }
} # Call-Exit-One


function Connect-Application {
  <#
    .SYNOPSIS
      Connect to the application which is specified in AmtSettings.xml
  #>

  if(!$AppName) {
    Abort "Connect-Application: Application not specified. Please check AmtSettings.xml"
  }

  # Connect to the application
  $global:Com.SysIniFile      = $global:SysIniFile
  $global:Com.AppName         = $global:AppName 
  $global:Com.Station         = "BATCH"
  $global:Com.JobName         = $global:JobName.ToUpper()
  $global:Com.ApplicationKind = $global:ApplicationKind
  $global:Com.Connect()
  
  if ($global:Com.ErrorCode -ne 0) {
    Abort "Could not connect to application ""$($global:AppName)"", ERROR: $($global:Com.ErrorDescription)"
  } else {
    Write-JobLog ("Successfully connected to application ""$($global:AppName)""") ([LoggingSeverity]::Info)
  }
  
  # Get general settings from Com object
  $global:Station       = $global:Com.Station
  $global:User          = $global:Com.User
  $global:SystemPath    = $global:Com.SystemPath
  $global:MyEnv         = $global:Com.Environment
  $global:Development   = $global:Com.Development
  $global:AmtPath       = $global:Com.CreatePath()

  # If information set by batchcontroller take this information
  if ($global:Initiator -ne "BATCH") {
    $global:Station = $global:Initiator
    $global:Com.Station = $global:Initiator
  }
  if ($global:InitiatingUser -ne "BATCH") {
    $global:User = $global:InitiatingUser
    $global:Com.User = $global:InitiatingUser
  }  
} # Connect-Application


function Set-Jobname{
  <#
    .SYNOPSIS
      Set job name
    .PARAMETER Jobname
      [String] Job name
  #>
  
  param (
    [Parameter(Mandatory=$true)][String]$Jobname
  )

  $global:Jobname = $Jobname
} # Set-JobName

#-------------------------------------------------------------------------------
# IPF System Functions
#-------------------------------------------------------------------------------
[reflection.assembly]::LoadWithPartialName("System") | Out-Null

Function Ipf-AreaValueFromName {
  <#
    .SYNOPSIS
      Outputs the condition word's area value from its name.
    .PARAMETER Name
      [String] The area name.
    .OUTPUTS
      [String] The area value.
  #>

  param (
    [String]$Name
  )

  Abort "Function AreaValueFromName has not been implemented yet."

  # obtain the area value from the script library, output as a [Int64]

  Switch ($Name) {
    "W"  { return  1 }
    "H1" { return  2 }
    "H2" { return  3 }
    "T1" { return  4 }
    "T2" { return  5 }
    "T3" { return  6 }
    "S1" { return  7 }
    "S2" { return  8 }
    "S3" { return  9 }
    "S4" { return 10 }
    "S5" { return 11 }
    "S6" { return 12 }

    default { Abort ($Name + " is not a valid area name.") }
  }
} # Ipf-AreaValueFromName

Function IpfSf-Abs {
  <#
    .SYNOPSIS
      Outputs the absolute value of $Value.
    .PARAMETER Value
      [Int] The input value.
    .OUTPUTS
      [Int] The output value.
  #>

  param (
    [Int32]$Value
  )

  return [math]::Abs($Value)
} # IpfSf-Abs

Function IpfSf-Ascii
{
  <#
    .SYNOPSIS
      Outputs the ASCII value of the provided character.
    .PARAMETER Character
      [Char] The input character
    .OUTPUTS
      [Int] The output value.
  #>

  param (
    [Char]$Character
  )

  return [Byte][Char]$Character
} # IpfSf-Ascii

Function IpfSf-Character {
  <#
    .SYNOPSIS
      Outputs the character with the provided ASCII value.
    .PARAMETER Value
      [Int] The ASCII value.
    .OUTPUTS
      [Char] The output character.
  #>

  param (
    [Int32]$Value
  )

  return [char]$Value
} # IpfSf-Character

Function IpfSf-Condition {
  <#
    .SYNOPSIS
      Outputs the (masked) value of the specified condition word area.
    .PARAMETER AreaName
      [String] The condition word area's name.
    .PARAMETER MaskValue
      [Long] The mask value.
    .PARAMETER LogicalFunction
      [String] The logical operation to perform on the area value and the mask.
    .OUTPUTS
      [Long] The (masked) value of the specified condition word area.
  #>

  param (
    [String]$AreaName, [Int64]$MaskValue = 0, [String]$LogicalFunction = ""
  )

  [Int64]$AreaValue = (Ipf-AreaValueFromName $AreaName)

  If ($LogicalFunction = "LAND") {
    $maskValue -and $AreaValue
  } ElseIf ($LogicalFunction = "LOR") {
    $maskValue -or $AreaValue
  } ElseIf ($LogicalFunction = "LXOR") {
    $maskValue -xor $AreaValue
  } ElseIf (($MaskValue -eq 0) -and ($LogicalFunction -eq "")) {
    Switch ($Name) {
      "W"  {  return (Ipf-AreaValueFromName "W")  }
      "H1" {  return (Ipf-AreaValueFromName "H1") }
      "H2" {  return (Ipf-AreaValueFromName "H2") }
      "T1" {  return (Ipf-AreaValueFromName "T1") }
      "T2" {  return (Ipf-AreaValueFromName "T2") }
      "T3" {  return (Ipf-AreaValueFromName "T3") }
      "S1" {  return (Ipf-AreaValueFromName "S1") }
      "S2" {  return (Ipf-AreaValueFromName "S2") }
      "S3" {  return (Ipf-AreaValueFromName "S3") }
      "S4" {  return (Ipf-AreaValueFromName "S4") }
      "S5" {  return (Ipf-AreaValueFromName "S5") }
      "S6" {  return (Ipf-AreaValueFromName "S6") }

      default { Abort ($Name + " is not a valid area name.") }
    }
  } Else {
    Abort ($LogicalFunction + " is not a valid logical function name.")
  }
} # IpfSf-Condition

Function IpfSf-FieldStatus {
  <#
    .SYNOPSIS
      Outputs the status of the specified field on the form that 
      was read during the last SEND_FORM or SEND_MESSAGE command.
    .PARAMETER IpfFieldName
      [String] The IPF field's name.
    .OUTPUTS
      [String] The status of the specified field on the form that was read 
      during the last SEND_FORM or SEND_MESSAGE command.
  #>

  param (
    [String]$IpfFieldName
  )

  Abort ("IPF system function FieldStatus has not been implemented yet.")
} # IpfSf-FieldStatus

Function IpfSf-File {
  <#
    .SYNOPSIS
      Outputs the fully qualified name of the directory or data file.
    .PARAMETER FileName
      [String] The file name to be expanded.
    .OUTPUTS
      [String] The fully qualified name of the directory or data file.
  #>

  param (
    [String]$FileName
  )

  # From Interactive Processing Facility (IPF 1100) Command Language User's Guide:
  # >DISPLAY $FILE(filea.) 
  # >ABC*FILEA(1). 

  if ($FileName.EndsWith(".")) {
    $Filename = $Filename.Substring(0, $Filename.Length - 1)  # Strip dot at end
  }

  # We need the absolute cycle number so we have to find the file on windows
  [String]$WindowsFile = Get-AssignedFile $FileName
  if (($global:FileObject -ne $null) -and ($global:FileObject.FileHandle -ne $null)) {
    $WindowsFile = $global:FileObject.FileHandle.FullName
  } else {
    [Object]$FileInfo = $global:AmtFile.GetFileInfo($WindowsFile, 1)
    if ($FileInfo.Exists) {
      $WindowsFile = $FileInfo.FullName
    }
  }

  [Int32]$Cycle = 1
  if ($WindowsFile -ne "") {

    [String]$CycleString = Find-Cycle $WindowsFile
    if (($CycleString -eq "") -and ($FileInfo)) {
      # $CycleString has no cycle number, => get the cycle number from $FileInfo
      $fn = $FileInfo.Name 
      $CycleString = $fn.substring($fn.length - 3, 3)
    }

    if ($CycleString -ne "") {
      try {
        $Cycle =[Convert]::ToInt32($CycleString)
      } catch {
        $Cycle = 1
      }
    }
  }

  [String]$CycleString = "(" + $Cycle.ToString() + ")"

  return ($global:ImpliedQual + "*" + $FileName + $CycleString +  ".") 
} # IpfSf-File

Function IpfSf-Fraction {
  <#
    .SYNOPSIS
      Outputs the fractional portion of the provided floating point value.
    .PARAMETER Number
      [Double] The floating point value for which to output the fractional portion.
    .OUTPUTS
      [Double] The fractional portion of the provided floating point value.
  #>

  param (
    [Double]$Number
  )

  If ($Number -ge 0) {
    return ($Number - [math]::Floor($Number))
  } Else {
    return ($Number - [math]::Ceiling($Number))
  }
} # IpfSf-Fraction

Function IpfSf-Integer {
  <#
    .SYNOPSIS
      Outputs the integer portion of the provided numeric expression.
    .PARAMETER Number
      [Double] The number for which to output the integer portion.
    .OUTPUTS
      The integer portion of the provided numeric expression.
  #>

  param (
    [Double]$Number
  )

  If ($Number -ge 0) {
    return ([math]::Floor($Number))
  } Else {
    return ([math]::Ceiling($Number))
  }
} # IpfSf-Integer

Function IpfSf-Length {
  <#
    .SYNOPSIS
      Outputs the length of the provided string.
    .PARAMETER String
      [String] The input string.
    .OUTPUTS
      The length of the provided string.
  #>

  param (
    [String]$String
  )

  return $String.Length
} # IpfSf-Length

Function IpfSf-LowerCase {
  <#
    .SYNOPSIS
      Outputs the lowercased input string.
    .PARAMETER String
      [String] The input string.
    .OUTPUTS
      The lowercased input string.
  #>

  param (
    [String]$String
  )

  return $String.ToLowerInvariant()
} # IpfSf-LowerCase

Function IpfSf-Number {
  <#
    .SYNOPSIS
      Outputs the provided string as a floating point value.
    .PARAMETER NumberAsString
      [String] The number as a string.
    .OUTPUTS
      A floating point value that is the numeric value as stated in the provided text.
  #>

  param (
    [String]$NumberAsString
  )

  try {
    return [Convert]::ToDouble($NumberAsString)
  } Catch {
    HandleExceptionAndAbort "IpfSf-Number could not convert `"$NumberAsString`" to a number." $_
  }
} # IpfSf-Number

Function IpfSf-Pad {
  <#
    .SYNOPSIS
      Pads the provided string with the provided character until 
      it has the specified length and outputs the result.
    .PARAMETER String
      [String] The string to be padded.
    .PARAMETER Length
      [Int] The target length of the resulting output..
    .PARAMETER Character
      [String] The padding character.
    .OUTPUTS
      The padded string.
  #>

  param (
    [String]$String, [Int]$Length, [String]$Side = "RIGHT", [String]$Character = " "
  )

  # The documentation is unclear about the meaning of ALL but the example for the Trim function
  # suggests it should pad within the string as well, like inserting padding characters evenly
  # until length has been reached. This is too cumbersome though, we will just do RIGHT instead.

  Switch ($Side) {
    "RIGHT" { return ($String + ($Character * ($Length - $String.Length))) }
    "LEFT"  { return (($Character * ($Length - $String.Length)) + $String) }
    "BOTH"  { return (($Character * [Math]::Floor(($Length - $String.Length) / 2))) + $String + (($Character * [Math]::Ceiling(($Length - $String.Length) / 2))) }
    "ALL"   { return ($String + ($Character * ($Length - $String.Length))) }
    default { Abort ($Side + " is not a valid side value (valid values are RIGHT, LEFT, BOTH, or ALL).") }
  }
} # IpfSf-Pad

Function IpfSf-Search {
  <#
    .SYNOPSIS
      Outputs the 1-based character index of the specified character in the provided string.
    .PARAMETER String1
      [String] The string to search.
    .PARAMETER String2
      [String] The string to look for.
    .PARAMETER Start
      [Int] The 1-based index that tells at what character to begin the search.
    .OUTPUTS
      [Int] The 1-based character index of the specified character in the provided string.
  #>

  param (
    [String]$String1, [String]$String2, [Int32]$Start = 1
  )

  # note: IPF's Search assumes a 1-based character index, hence the - 1 and + 1

  return ($String1.IndexOf($String2, $Start - 1) + 1)
} # IpfSf-Search

Function IpfSf-String {
  <#
    .SYNOPSIS
      Outputs the provided floating point value as a string.
    .PARAMETER Number
      [Double] The input number.
    .OUTPUTS
      [String] The provided floating point value as a string.
  #>

  param (
    [double]$Number
  )

  return $Number.ToString()
} # IpfSf-String

Function IpfSf-Substring {
  <#
    .SYNOPSIS
      Outputs the specified portion of the provided string (the specification is 1-based).
    .PARAMETER String
      [String] The input string.
    .PARAMETER Start
      [Int32] The input string.
    .PARAMETER Length
      [Int32] The input string.
    .OUTPUTS
      The resulting substring.
  #>

  param (
    [String]$String, [Int32]$Start, [Int32]$Length = -1
  )

  # note: IPF's Search assumes a 1-based character index, hence the + 1 and - 1
  if ($Start -lt 1) {
    $Start = 1
  } elseif ($Start -gt $String.Length) {
    [String]$StrLen = $String.Length
    Add-WarningMsg "Ipfsf-Substring Start ($Start) is greater than the length of String ($StrLen), an empty string is returned."
    return ""
  }

  If ($Length -eq -1) {
    ($Length = $String.Length - $Start + 1) | Out-Null
  } elseif ($Start - 1 + $Length -gt $String.Length) {
    [String]$StrLen = $String.Length
    Add-WarningMsg "Ipfsf-Substring Start ($Start) + Length ($Length) is larger than String length ($StrLen), Length adjusted."
    ($Length = $String.Length - $Start + 1)  | Out-Null
  }

  return ($String.Substring($Start - 1, $Length))
} # IpfSf-Substring

Function IpfSf-Text {
  <#
    .SYNOPSIS
      Outputs the image at line number $LineNumber in your current editing object 
      (workspace or lookspace). If no line number is specified, the value of 
      IPF system variable $C is assumed.
    .PARAMETER LineNumber
      [Decimal] The line number for which to retrieve the image.
    .OUTPUTS
      [String] The requested image (line from the workspace or lookspace).
  #>

  param (
    [Decimal]$LineNumber=$global:IpfSv_CurrentImage
  )

  [Object]$Objectspace = $null
  if ($global:IpfSwitch -eq [IpfObjectSpaceType]::Workspace) {
    $Objectspace = $global:IpfWorkSpace
  } else {
    $Objectspace = $global:IpfLookSpace
  }

  [Object]$Result = Get-ObjectSpaceLine $LineNumber

  if ($Result -eq $null) {
    return ""
  } else {
    return $Result.Line
  }
} # IpfSf-Text

Function IpfSf-Trim {
  <#
    .SYNOPSIS
      Outputs a string that is the input string with the specified character trimmed off.
    .PARAMETER String
      [String] The string to be trimmed.
    .PARAMETER Side
      [String] The way to trim ("RIGHT", "LEFT", "BOTH" or "ALL").
    .PARAMETER Character
      [String] The character to be trimmed off.
      
    .OUTPUTS
      
  #>

  param (
    [String]$String, [String]$Side = "RIGHT", [String]$Character = " "
  )

  # The documentation is unclear about the meaning of ALL, it is assumed 
  # we should combine LEFT and RIGHT with the same number of characters.

  Switch ($Side) {
    "RIGHT" { return ($String.TrimEnd($Character)) }
    "LEFT"  { return ($String.TrimStart($Character)) }
    "BOTH"  { return ($String.Trim($Character)) }
    "ALL"   { return ($String.Replace($Character, "")) }
    default { Abort ($Side + " is not a valid side value (valid values are RIGHT, LEFT, BOTH, or ALL).") }
  }
} # IpfSf-Trim

Function IpfSf-UpperCase {
  <#
    .SYNOPSIS
      Outputs the uppercased input string.
    .PARAMETER String
      [String] The input string.
    .OUTPUTS
      The uppercased input string.
  #>

  param (
    [String]$String
  )

  return $String.ToUpperInvariant()
} # IpfSf-UpperCase

# --- end of IPF System Functions ---


function Accept {
  <#
    .SYNOPSIS
      Sends the Message to the Control Center and then waits for an answer.
    .DESCRIPTION
      Sends the Message to the Control Center and then waits for an answer.
      If the answer is received from the Control Center, it is returned.
      If the answer is "X" then the script aborts immediately.
    .PARAMETER Message
      [String] String containing the message
    .PARAMETER Jobname
      [String] The name of the Job or any other name you prefer     
    .OUTPUTS
      [String] String with the answer as provided by the operator of the Control Center
  #>

  param (
    [String]$Message,
    [String]$Jobname
  )

  [String]$Result = ""

  if ($Message -eq "") {
    $Message = "*"
  }

  Write-JobLog "" ([LoggingSeverity]::Debug)
  Add-InformationMsg "Accept: $Message"

  # Let operator know an ACCEPT is coming in
  $global:AmtMessage.AddMsgInformation("Awaiting user input for $global:AppName, $global:Jobname") | Out-Null
  $Result = $global:AmtMessage.AddRequest($Message)
  if ($global:AmtMessage.ErrorCode -ne 0) {
    Abort "ERROR in ACCEPT: $global:Jobname : $global:AmtMessage.ErrorDescription"
  }

  Add-InformationMsg "Input request < $Message > response < $Result >"
  Write-JobLog "Input request < $Message > response < $Result >" ([LoggingSeverity]::Info)

 if ($Result.ToUpper() -eq "X") {
    # A call to standard error so an error will be generated wich can be tested
    # by a script that started this script.
    Abort "I have been X'd by the operator."
  }

  return $Result  
} # Accept


function Add-AcceptFile {
  <#
    .SYNOPSIS
      Add an accept file.
    .DESCRIPTION
      Add an accept file to the task object, so it can be using in a Report.
    .PARAMETER Filename
      [String] The filename
    .PARAMETER ObjTask
      [Object] Task object
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Filename,
    [Object]$ObjTask
  )

  $ObjTask = Get-TaskObject $ObjTask
  $Filename = Check-File $Filename $global:UseExtension

  if (-not (Create-Folders $Filename $ObjTask)) {
    Write-JobLog "Add-AcceptFile: could not create folders for filename $Filename" ([LoggingSeverity]::Error)
  }

  $ObjTask.SetTVCustom('Accept_File', $AcceptFilePath)
  $ObjTask.AddAcceptFile($Filename)
} # Add-AcceptFile



function Check-RuntimeError {
  <#
    .SYNOPSIS 
      Check if the supplied error number <> 0, if so log the message and terminate the 
      script.
    .PARAMETER ErrorNr
      Error Number, is <> 0 if an error has occured
    .PARAMETER ErrorSource
      Description of where the error is originating
    .PARAMETER Msg
      Message to be shown.
    .PARAMETER ErrorDescription
      The error description
  #>

  param (
    [Int32]$ErrorNr,
    [String]$ErrorSource,
    [String]$Msg,
    [String]$ErrorDescription
  )
  
  if ($ErrorNr -ne 0) {
    Add-ErrorMsg "${ErrorSource}: ${Msg}: ${ErrorNr}: $ErrorDescription"
    
    if ($global:JobLogFile -ne "") {
      Add-Content $global:JobLogFile "ERROR: ${ErrorSource}: ${Msg}: ${ErrorNr}: $ErrorDescription"
    }

    [Console]::Error.WriteLine("$msg (Exit 1).")
    # note: This will do nothing in PowerShell ISE, it tells BatchController there was an error.
    Call-Exit-One
  }
} # Check-RuntimeError


function Create-InitialJobLog {
  <#
    .SYNOPSIS
      Create initial job log. 
    .DESCRIPTION
      The logging is written to this file until the filecontroller is up and running. 
      This initial job log is used to be able to log before starting up the file controller.
  #>
  
  [String]$LogPath = Add-BackSlash $global:AmtPath.LoggingPath
  [String]$Folder = $LogPath + (Get-TimeDate "YYYYMMDD" (Get-Date))
  $global:JobLogFile = $Folder + "\" + $global:Jobname + "_" + (Get-UniqueNumber) + ".log"
  $global:JobLogFileOrig = $global:JobLogFile
  
  if (-not(Test-Path $Folder)) {
    New-Item $Folder -type directory | out-null
  }
  New-Item $global:JobLogFile -ItemType file -force | out-null
  
  [String]$DateTime = Get-TimeDate "YYYY-MM-DD HH:MM:SS" (Get-Date)
  Add-Content $global:JobLogFile "$($global:Jobname) started $DateTime"
  Add-Content $global:JobLogFile "$($global:LibraryVersionDate)"
  Add-Content $global:JobLogFile "PowerShell engine version: $($(Get-Host).Version.ToString())"

  Add-Content $global:JobLogFile ""
} # Create-InitialJobLog


function Create-JobLogFile {
  <#
    .SYNOPSIS
      Create new job log file.
    .DESCRIPTION
      This function is mainly used by function Brkpt.
  #>

  [String]$Folder = (Add-BackSlash $global:AmtPath.LoggingPath) + (Get-TimeDate "YYYYMMDD" (Get-Date))
  $global:JobLogFile = $Folder + "\" + $global:Jobname + "_" + (Get-UniqueNumber) + ".log"
  $global:JobLogFileOrig = $global:JobLogFile

  Init-JobLog
} # Create-JobLogFile

function Close-JobLog {
  <#
    .SYNOPSIS
      Close the job logging
    .DESCRIPTION
      Close job logging file.
  #>

  if ($global:JobLogObj -ne $null) {
    if (-not (Close-TextFile $global:JobLogObj)) {
      Add-ErrorMsg "Error closing logfile: $global:JobLogFile"
	}
	$global:JobLogObj = $null
    $global:JobLogFileAvailable = $false
  }
} # Close-JobLog

function Init-JobLog {
  <#
    .SYNOPSIS
      Initialise job logging
    .DESCRIPTION
      Initialise job logging, creates the log file and writes the startdate/time
      into the log file.
  #>

  Close-JobLog
  [Int32]$i = 0
  for ($i = 0; $i -lt 10; $i++) {
    # Try 10 times to create or open the joblog file.

    if (-not (Create-Folders $global:JobLogFile $null)) {
      Write-JobLog "Create-Folders failed for global:JobLogFile (attempt $i)." ([LoggingSeverity]::Error)
    }

    if (File-Exists ($global:JobLogFile)) {
      [Boolean]$Append = $true
      $global:JobLogObj = Open-TextFile $global:JobLogFile $global:Const_ExclusiveBatch $global:Const_FileEnc_Autodetect $Append
    } else {
      [Boolean]$Unicode = $false
      [Boolean]$Overwrite = $true
      $global:JobLogObj = Create-TextFile $global:JobLogFile $global:Const_ExclusiveBatch $Unicode $Overwrite
    }
    if ($global:ErrorCode -eq 0) {
      break
    }
    Start-Sleep -Seconds 1
  } # for
  
  if ($global:ErrorCode -ne 0) {
    $global:UseJobLog = $false
    [String]$ErrorMsg = "Error creating/opening joblog: {0}" -f $global:ErrorDescription
    Add-ErrorMsg $ErrorMsg
  } else {
    $global:JobLogFileAvailable = $true
    if ($global:RemoveFromFilename -eq "") {
      $global:RemoveFromFilename = Get-PrimaryExtractPath
    }
  }
} # Init-JobLog


function Write-JobLog {
  <#
    .SYNOPSIS
      Writes a message to the job log and to the console.
    .DESCRIPTION
      Adds the supplied message string to the Job log.
    .PARAMETER Message
      [String] The message to add to the Job log.
    .PARAMETER Severity
      [LoggingSeverity] A value indicating whether the message is a debug message or not.
    .PARAMETER Raw
      [Boolean] Do not prefix the message with anything or filter it, just literally output it.
  #>

  param (
    [String]$Message,
    [LoggingSeverity]$Severity=[LoggingSeverity]::Info,
    [Boolean]$Raw=$false
  )

  if ($Severity -le $global:LoggingSeverity) {
    # job log
    if (($global:UseJobLog) -and ($global:JobLogFileAvailable) -and ($global:JobLogObj -ne $null)) {

      if (-not $Raw) {
        $Message = $Message.Replace($global:RemoveFromFilename, "")
        if ($global:LogTimes) {
          $DateTime = Get-TimeDate "YYYY-MM-DD HH:MM:SS" (Get-Date)
          $Message = $DateTime + " " + $Message
        }
      }

      [Void]$global:JobLogObj.WriteLineAsync($Message, $true)
    }

    # console

    if (($global:Com -eq $null) -or ($global:Com.Station -ne "BATCH")) {
      Write-Host $Message
    }
  }
} # Write-JobLog


function Get-JobNumber {
  <#
    .SYNOPSIS
      Returns the job number.
    .DESCRIPTION
      Tries to retrieve the job number from environment variable AMTPROCESSJOBID.
      Retrieves the job number from the COM module If AMTPROCESSJOBID does not exist.
    .OUTPUTS
      Job number.
  #>
  
  $JobNr = Get-EnvVariable "AMTPROCESSJOBID"
  
  if (($JobNr -eq "") -or ($JobNr -eq $null)) {
    $JobNr = $global:Com.ProcessId
  }

  Write-JobLog "GetJobNumber: $JobNumber" ([LoggingSeverity]::Debug)

  return $JobNr
}  # Get-JobNumber


function Get-RequestId {
  <#
    .SYNOPSIS
      Returns the request ID.
    .DESCRIPTION
      Tries to retrieve the request ID from environment variable AMTREQUESTID.
      Returns 0 if AMTREQUESTID does not exist.
    .OUTPUTS
      Request ID.
  #>
  
  $RequestId = Get-EnvVariable "AMTREQUESTID"
  
  if (($RequestId -eq "") -or ($RequestId -eq $null)) {
    $RequestId = 0
  }
  
  Write-JobLog "GetRequestId: $RequestId" ([LoggingSeverity]::Debug)

  return $RequestId
}  # Get-RequestId


function Get-Initiator {
  <#
    .SYNOPSIS
      Returns the station name of the initiator.
    .DESCRIPTION
      Tries to retrieve the initiator from environment variable INITSTATION.
    .OUTPUTS
      Initiator.
  #>

  $Init = Get-EnvVariable "INITSTATION"

  if (($Init -ne "") -and ($Init -ne $null)) {
    Write-JobLog "GetInitiator: $Init" ([LoggingSeverity]::Debug)
    return $Init
  } else {
    Write-JobLog "GetInitiator: $global:Initiator" ([LoggingSeverity]::Debug)
    return $Initiator
  }
}  # Get-Initiator


function Get-BatchId {
  <#
    .SYNOPSIS
      Returns the batch ID.
    .DESCRIPTION
      Tries to retrieve the batch ID from Comscript
    .OUTPUTS
      Batch ID.
  #>

  $BatchId = $global:Com.BatchId
  
  if (($BatchId -ne "") -and ($BatchId -ne $null)) {
    Write-JobLog "GetBatchId: $BatchId" ([LoggingSeverity]::Debug)
    return $BatchId
  } else {
    Write-JobLog "GetBatchId: $global:BatchId" ([LoggingSeverity]::Debug)
    return $global:BatchId
  }
}  # Get-BatchId


function Get-InitiatingUser {
  <#
    .SYNOPSIS
      Returns the username of the initiator.
    .DESCRIPTION
      Tries to retrieve the initiating user from environment variable INITUSER.
    .OUTPUTS
      [String] Username of the initiator.
  #>

  $InitUser = Get-EnvVariable "INITUSER"
  
  if (($InitUser -ne "") -and ($InitUser -ne $null)) { 
    Write-JobLog "GetInitiatingUser: $InitUser" ([LoggingSeverity]::Debug)
    return $InitUser
  } else {
    Write-JobLog "GetInitiatingUser: $global:InitiatingUser" ([LoggingSeverity]::Debug)
    return $global:InitiatingUser
  }
} # Get-InitiatingUser


function Get-EnvVariable {
  <#
    .SYNOPSIS
      Returns specified environment variable.
    .DESCRIPTION
      Returns specified environment variable.
      Note: Returns empty string if the environment variable does not exist.
    .PARAMETER Name
      [String] Name of the environment variable.
    .OUTPUT
      [String] Contents of environment variable.
      Returns empty string if the environment variable does not exist.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$name
  )
  
  return [Environment]::GetEnvironmentVariable($name,[EnvironmentVariableTarget]"Process")
}  # Get-EnvVariable


function Add-BackSlash {
  <#
    .SYNOPSIS
     Add '\' to the end of the path, but only if it doesn't exist yet.
    .DESCRIPTION
     Adds a '\' to the input parameter, but only if it doesn't end with a '\' yet.
    .PARAMETER Path
     [String] Path to which the '\' will be added.
    .OUTPUTS
     [String] Path with '\' at the end.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Path
  )

  [String]$Result = $Path

  # Check if '\' doesn't already exist at the end
  if (-not($Path.EndsWith("\"))) {
    $Result = $Result + "\"
  }

  return $Result
} # Add-BackSlash


function Get-TimeDate {
  <#
    .SYNOPSIS
      Convert provided time and date into the specified format
    .PARAMETER Format
      [String] String specifying the format
    .PARAMETER TimeDate
      [Object] TimeDate object containing a date and time.
    .OUTPUTS
      [String] String containing formatted time and date.
  #>

  param (
    [String]$Format,
    [Object]$TimeDate
  )
  
  [String]$Day    = ""
  [String]$Month  = ""
  [String]$Year   = ""
  [String]$Hour   = ""
  [String]$Minute = ""
  [String]$Second = ""
  [String]$Result = ""
  
  if ($TimeDate -eq $null) {
    # TimeDate object not specified, get current time and date.
    $TimeDate = Get-Date 
  }
  
  if ($Format -eq "DD/MM/YYYY HH:MM:SS") {
    $Day = "{0:D2}" -f $TimeDate.Day
    $Month = "{0:D2}" -f $TimeDate.Month
    $Year = $TimeDate.Year
    $Hour = "{0:D2}" -f $TimeDate.Hour
    $Minute = "{0:D2}" -f $TimeDate.Minute
    $Second = "{0:D2}" -f $TimeDate.Second
    $Result = "{0}/{1}/{2} {3}:{4}:{5}" -f $Day,$Month,$Year,$Hour,$Minute,$Second
  } elseif ($Format -eq "YYYY-MM-DD HH:MM:SS") {
    $Day = "{0:D2}" -f $TimeDate.Day
    $Month = "{0:D2}" -f $TimeDate.Month
    $Year = $TimeDate.Year
    $Hour = "{0:D2}" -f $TimeDate.Hour
    $Minute = "{0:D2}" -f $TimeDate.Minute
    $Second = "{0:D2}" -f $TimeDate.Second
    $Result = "{0}-{1}-{2} {3}:{4}:{5}" -f $Year,$Month,$Day,$Hour,$Minute,$Second
  } elseif ($Format -eq "MM/DD/YYYY HH:MM:SS") {
    $Day = "{0:D2}" -f $TimeDate.Day
    $Month = "{0:D2}" -f $TimeDate.Month
    $Year = $TimeDate.Year
    $Hour = "{0:D2}" -f $TimeDate.Hour
    $Minute = "{0:D2}" -f $TimeDate.Minute
    $Second = "{0:D2}" -f $TimeDate.Second
    $Result = "{0}/{1}/{2} {3}:{4}:{5}" -f $Month,$Day,$Year,$Hour,$Minute,$Second
  } elseif ($Format -eq "HHMMSSMM") {
    $Hour = "{0:D2}" -f $TimeDate.Hour
    $Minute = "{0:D2}" -f $TimeDate.Minute
    $Second = "{0:D2}" -f $TimeDate.Second
    $Millisecond = "{0:D2}" -f $TimeDate.MilliSecond
    $Result = "{0}{1}{2}{3}" -f $Hour,$Minute,$Second,$Millisecond
  } elseif ($Format -eq "HHMMSS") {
    $Hour = "{0:D2}" -f $TimeDate.Hour
    $Minute = "{0:D2}" -f $TimeDate.Minute
    $Second = "{0:D2}" -f $TimeDate.Second
    $Result = "{0}{1}{2}" -f $Hour,$Minute,$Second
  } elseif ($Format -eq "HH:MM:SS") {
    $Hour = "{0:D2}" -f $TimeDate.Hour
    $Minute = "{0:D2}" -f $TimeDate.Minute
    $Second = "{0:D2}" -f $TimeDate.Second
    $Result = "{0}:{1}:{2}" -f $Hour,$Minute,$Second
  } elseif ($Format -eq "DDMMYY") {
    $Day = "{0:D2}" -f $TimeDate.Day
    $Month = "{0:D2}" -f $TimeDate.Month
    $Year = $TimeDate.Year
    $Result = "{0}{1}{2}" -f $Day,$Month,$Year.Substring(2)
  } elseif ($Format -eq "DDMMYYYY") {
    $Day = "{0:D2}" -f $TimeDate.Day
    $Month = "{0:D2}" -f $TimeDate.Month
    $Year = $TimeDate.Year
    $Result = "{0}{1}{2}" -f $Day,$Month,$Year
  } elseif ($Format -eq "MM/DD/YY") {
    $Day = "{0:D2}" -f $TimeDate.Day
    $Month = "{0:D2}" -f $TimeDate.Month
    $Year = $TimeDate.Year
    $Result = "{0}/{1}/{2}" -f $Month,$Day,$Year.Substring(2)
  } elseif ($Format -eq "MM/DD/YYYY") {
    $Day = "{0:D2}" -f $TimeDate.Day
    $Month = "{0:D2}" -f $TimeDate.Month
    $Year = $TimeDate.Year
    $Result = "{0}/{1}/{2}" -f $Month,$Day,$Year
  } elseif ($Format -eq "MMDDYY") {
    $Day = "{0:D2}" -f $TimeDate.Day
    $Month = "{0:D2}" -f $TimeDate.Month
    $Year = $TimeDate.Year
    $Result = "{0}{1}{2}" -f $Month,$Day,$Year.Substring(2)
  } elseif ($Format -eq "MMDDYYYY") {
    $Day = "{0:D2}" -f $TimeDate.Day
    $Month = "{0:D2}" -f $TimeDate.Month
    $Year = $TimeDate.Year
    $Result = "{0}{1}{2}" -f $Month,$Day,$Year
  } elseif ($Format -eq "YYYYMMDDHHMMSS") {
    $Day = "{0:D2}" -f $TimeDate.Day
    $Month = "{0:D2}" -f $TimeDate.Month
    $Year = $TimeDate.Year
    $Hour = "{0:D2}" -f $TimeDate.Hour
    $Minute = "{0:D2}" -f $TimeDate.Minute
    $second = "{0:D2}" -f $TimeDate.Second
    $Result = "{0}{1}{2}{3}{4}{5}" -f $Year,$Month,$Day,$Hour,$Minute,$second
  } elseif ($Format -eq "YYDDD") {
    $Year = $TimeDate.Year
    $DayOfYear = $TimeDate.DayOfYear
    $Result = "{0}{1}" -f $Year.Substring(2),$DayOfYear
  } elseif ($Format -eq "YYYYMMDD") {
    $Day = "{0:D2}" -f $TimeDate.Day
    $Month = "{0:D2}" -f $TimeDate.Month
    $Year = $TimeDate.Year
    $Result = "{0}{1}{2}" -f $Year,$Month,$Day
  } elseif ($Format -eq "YYMMDD") {
    $Day = "{0:D2}" -f $TimeDate.Day
    $Month = "{0:D2}" -f $TimeDate.Month
    $Year = $TimeDate.Year
    $Result = "{0}{1}{2}" -f $Year.Substring(2),$Month,$Day
  } elseif ($Format -eq "YYYYDDD") {
    $Year = $TimeDate.Year
    $DayOfYear = $TimeDate.DayOfYear
    $Result = "{0}{1}" -f $Year,$DayOfYear
  } elseif ($Format -eq "HHMM") {
    $Hour = "{0:D2}" -f $TimeDate.Hour
    $Minute = "{0:D2}" -f $TimeDate.Minute
    $Result = "{0}{1}" -f $Hour,$Minute
  } elseif ($Format -eq "HH:MM") {
    $Hour = "{0:D2}" -f $TimeDate.Hour
    $Minute = "{0:D2}" -f $TimeDate.Minute
    $Result = "{0}:{1}" -f $Hour,$Minute
  } elseif ($Format -eq "DISPLAY") {
  } elseif ($Format -eq "MONTH") {
    # Return name of the month as string
    $DateTimeInfo = New-Object system.Globalization.DateTimeFormatInfo
    $MonthNames = $DateTimeInfo.MonthNames
    $Result = $MonthNames[$TimeDate.Month - 1]
  } elseif ($Format -eq "DAY") {
    # Return name of the day as string
    $Result = $TimeDate.DayOfWeek
  } elseif ($Format -eq "DAYNUMBER") {
    # Return number of the day of the week, Sunday = 0, Monday = 1 etc.
    $DayNr = [Int32]$TimeDate.DayOfWeek
    $Result = "{0}" -f $DayNr
  } else {
    Write-JobLog "" ([LoggingSeverity]::Error)
    Write-JobLog "Get-TimeDate: Incorrect format $Format supplied" ([LoggingSeverity]::Error)
  }
  return $Result
} # Get-TimeDate


function Get-UniqueNumber {
  <#
    .SYNOPSIS 
      Generate a unique number
    .DESCRIPTION
      Returns a unique number. This is created by taking the jobnumber, current date 
      and current time.
    .OUTPUTS
      [String] A unique number
  #>

  [String]$Result = [String]$global:JobNumber + [String](Get-TimeDate "YYYYMMDD" (Get-Date)) + [String](Get-TimeDate "HHMMSSMM" (Get-Date))

  return $Result
} # Get-UniqueNumber


function Get-PathsForCurrentApp {
  <#
    .SYNOPSIS
      Get the paths from the current application.
  #>

  $global:AmtPath.AppName = $global:AppName
  $PrimaryExtractPath     = Get-PrimaryExtractPath ""
  $global:ExtractPath     = $global:AmtPath.ExtractPath.ToUpperInvariant().TrimEnd('\')  
  $global:JobPath         = $global:AmtPath.ScriptPath.ToUpperInvariant()
}  # Get-PathsForCurrentApp


function Get-PrimaryExtractPath {
  <#
    .SYNOPSIS
      Returns the primary extractpath without the last directory and without suffix.
    .PARAMETER User
      [String] User
    .OUTPUTS
      [String] Primary extractpath without the last directory and without suffix.
  #>

  param (
    [String]$User
  )

  if (($User -eq "GLOBAL") -or ($global:SPO -and $User -eq "")) {
    $Path = $global:AmtPath.ExtractPathByAppName("GLOBAL")
    $PrimaryExtractPath = $Path.Substring(0, $global:AmtPath.ExtractPathByAppName("GLOBAL").LastIndexOfAny("\")).ToUpperInvariant()
    
    if ($PrimaryExtractPath -eq "") {
      Add-ErrorMsg "Primary extract path of application GLOBAL not found."
      
      $Path = $global:AmtPath.ExtractPath
      $PrimaryExtractPath = $Path.Substring(0, $global:AmtPath.ExtractPath.LastIndexOfAny("\")).ToUpperInvariant()
      return $PrimaryExtractPath
    }
  } else {
    $Path = $global:AmtPath.ExtractPath
    $PrimaryExtractPath = $Path.Substring(0, $global:AmtPath.ExtractPath.LastIndexOfAny("\")).ToUpperInvariant()
    return $PrimaryExtractPath
  }
}  # GetPrimaryExtractPath


function Create-Folders {
  <#
    .SYNOPSIS
      Create all subfolders preceding the actual file in $filename.
    .DESCRIPTION
      Go through the folder, starting at the highest level. Try to create the 
      folder if it doesn't exist.
    .PARAMETER Filename
      [String] Filename
    .PARAMETER ObjTask
      [Object] Task object
    .OUTPUTS 
      $true if folders were created succesfully, otherwise $false
  #>

  param (
    [String]$Filename, # Complete path with filename
    [Object]$ObjTask   # Task object
  )

  [Boolean]$Result = $false

  Write-JobLog "" ([LoggingSeverity]::Debug)
  Write-JobLog "Create-Folders: $Filename" ([LoggingSeverity]::Debug)

  if (-not(Is-FullyQualifiedFile $Filename)) {
    if ($global:FirstQual) {
      $Filename = Check-File $Filename $false #no qualifier set, must be a system file
    } else {
      $Filename = Check-Qual $Filename 
    }
  }

  [Int32]$Pos = $Filename.LastIndexOf("\") 
  if ($Pos -ne -1) {
    [String]$Folder = $Filename.Substring(0, $Pos)
    if (-not(Folder-Exists $Folder)) {
      Write-JobLog "Create-Folders: Creating folder $Folder" ([LoggingSeverity]::Debug)
      if (-not (Create-Folder $Folder)) {
        Add-ErrorMsg "Could not create folder $Folder"
      }
      if ($global:ErrorCode -ne 0) {
        Add-ErrorMsg "Create-Folders: creating folder $Folder failed : $($global:ErrorDescription)"
        if ($ObjTask -ne $null) {
          Set-CompletedOk $ObjTask $false
          Set-TaskValue $objTask 2
        }
        $Result = $false
      } else {
        $Result = $true
      }    
    } else {
      # Folder already exists, just return True
      $Result = $true
    }
  }

  return $Result
} # Create-Folders


function Create-Folder {
  <#
    .SYNOPSIS
      Creates a folder or folder tree specified in Foldername. The anme of the 
      folder should contain the full path. Returns true on success and false on failure.
    .PARAMETER Foldername
      [String] String containing folder name (full path)
    .OUTPUTS
      [Boolean] true on success, false on failure.
  #>

  param (
    [String]$Foldername
  )

  [Boolean]$Result = $false
  $Result = $global:AmtFile.CreateFolder($Foldername)
  $global:ErrorCode = $global:AmtFile.ErrorCode
  $global:ErrorDescription = $global:AmtFile.ErrorDescription
  Set-FileControlError $global:AmtFile.ErrorCode $global:ErrorDescription
  return $Result
} # Create-Folder


function Delete-Folder {
  <#
    .SYNOPSIS
      Deletes a folder or folder tree specified in Foldername. 
      Returns true on success and false on failure.
    .PARAMETER Foldername
      [String] String containing folder name 
    .PARAMETER AbortOnDeleteError
      [Boolean] When $false, don't abort when folder could not be deleted, useful for retry. Default = $true,
    .OUTPUTS
      [Boolean] true on success, false on failure.
  #>

  Param (
    [String]$Foldername,
    [Boolean]$AbortOnDeleteError = $true
  )

  [Boolean]$Result = $true
  if ($Foldername -eq "") {
    return $Result
  }

  if ((-not ($Foldername.StartsWith($global:ExtractPath, [System.StringComparison]::OrdinalIgnoreCase))) -and (-not ($Foldername.StartsWith($global:TempFolder, [System.StringComparison]::OrdinalIgnoreCase)))) {
    $Foldername = (Add-BackSlash $global:ExtractPath) + $Foldername
  }

  if (-not ($global:AmtFile.FolderExists($Foldername))) {
    return $Result
  }

  Set-FileControlError 0
  if ($global:AmtFile.DeleteFolder($Foldername, 50)) {
    return $Result
  }

  [String]$Files = $global:AmtFile.GetFiles($Foldername, $true)
  if ($global:AmtFile.ErrorCode -ne 0) {
    [String]$FCError = $global:AmtFile.ErrorDescription
    # check if the folder is deleted in the meantime. If it is deleted, no error message is required.
    if (-not ($global:AmtFile.FolderExists($Foldername))) {
      return $Result
    }
    Abort "Error calling GetFiles. $FCError"
  }
  if (-not [String]::IsNullOrEmpty($Files)) {
    [String[]]$FileList = $Files.Split(",")
    foreach ($File in $FileList) {
      Delete-File $File
      if (-not (Check-FileControlError 0)) {
        [String]$FCError = $global:AmtFile.ErrorDescription
        if ($AbortOnDeleteError) {
          Abort "Error deleting file: $File $FCError"
        } else {
          Write-JobLog ("Error deleting file: $File $FCError") ([LoggingSeverity]::Error)
          return $false 
        }
      }
    }
  }

  [String]$Folders = $global:AmtFile.GetDirectories($Foldername, $true)
  if ($global:AmtFile.ErrorCode -ne 0) {
    $FCError = $global:AmtFile.ErrorDescription
    Abort "Error calling GetFolders. $FCError"
  }

  if (-not [String]::IsNullOrEmpty($FolderList)) {
    [String[]]$FolderList = $Folders.Split(",")
    foreach ($Folder in $FolderList) {
      if (-not ($global:AmtFile.DeleteFolder($Folder, 100))) {
        [String] $FCError = $global:AmtFile.ErrorDescription
        if ($AbortOnDeleteError) {
          Abort "Error deleting folder: $Folder $FCError"
        } else {
          Write-JobLog ("Error deleting folder: $Folder $FCError") ([LoggingSeverity]::Error)
          return $false
        }
	  }  
    }
  }

  if (-not ($global:AmtFile.DeleteFolder($Foldername, 50))) {
    $FCError = $global:AmtFile.ErrorDescription
    if ($AbortOnDeleteError) {
      Abort "Error deleting folder: $Foldername $FCError"
    } else {
      Write-JobLog ("Error deleting folder: $Foldername $FCError") ([LoggingSeverity]::Error)
      return $false 
    }
  }
  return $Result
} # Delete-Folder


function Create-TextFile {
  <#
    .SYNOPSIS
      Creates a text file specified by filename and returns a TextStream or Text File object.
    .DESCRIPTION
      When a file with the name specified already exists and Overwrite is set to true, this 
      file will be overwritten. Otherwise the creation of the Text Stream Object will fail 
      and the properties ErrorCode and ErrorDescription will be set.
    .PARAMETER Filename
      [String] Name of the file to create
    .PARAMETER Sharemode
      [Int32] Share mode
    .PARAMETER Unicode
      [Boolean] If true the file is encoded as Unicode file
    .PARAMETER Overwrite
      [Boolean] If true overwrite the file if it already exists
    .OUTPUTS
      [Object] An AMT Text Stream object.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Filename,
    [Parameter(Mandatory=$true)][Int32]$Sharemode,
    [Parameter(Mandatory=$true)][Boolean]$Unicode,
    [Parameter(Mandatory=$true)][Boolean]$Overwrite
  )

  [Object]$Result = $null
  Replace-Asterisks ([Ref]$Filename)
  $Result = $global:AmtFile.CreateTextFile($Filename, $Sharemode, $Unicode, $Overwrite)
  $global:ErrorCode = $global:AmtFile.ErrorCode 
  $global:ErrorDescription = $global:AmtFile.ErrorDescription
  Set-FileControlError $global:AmtFile.ErrorCode $global:ErrorDescription
  return $Result
} # Create-TextFile


function Open-TextFile {
  <#
    .SYNOPSIS
      Opens the file specified by filename, returns a Text File object or
      a AMT Text Stream object.
    .PARAMETER Filename
      [String] Name of the file to create
    .PARAMETER Sharemode
      [Int32] Share mode
    .PARAMETER FileEncoding
      [Int32] Can be 1 for ASCII file, 2 for Unicode file, 0 for autodetect
    .PARAMETER Append
      [Boolean] If true the file will be opened for appending and the open
                will fail when the specified file does not exist. When
                append is set to false, a new empty file will be created 
                thereby overwriting any existing file with the same name.
    .OUTPUTS
      [Object] An AMT Text Stream object.    
  #>
  
  param (
    [String]$Filename,
    [Int32]$ShareMode,
    [Int32]$FileEncoding,
    [Boolean]$Append
  )
  
  [Object]$Result = $null
  Replace-Asterisks ([Ref]$Filename)
  $Result = $global:AmtFile.OpenTextFile($Filename, $ShareMode, $FileEncoding, $Append)
  $global:ErrorCode = $global:AmtFile.ErrorCode
  $global:ErrorDescription = $global:AmtFile.ErrorDescription
  Set-FileControlError $global:AmtFile.ErrorCode $global:ErrorDescription

  # if the file was not there or not accessible, the returned object will be $null in which case we want to stop
  if ($Result -eq $null) {
    Abort ("File " + $FileName + " could not be opened. " + $global:ErrorDescription + " (code " + $global:ErrorCode + ")")
  }

  return $Result
} # Open-TextFile


function Close-TextFile {
  <#
    .SYNOPSIS 
      Close the text file
    .PARAMETER FileObj
      [Object] FileObj of file to close
    .OUTPUTS
      [Boolean] True if file object was closed successfully, otherwise false
  #>

  param (
    [Object]$FileObj
  )

  [Boolean]$Result = $false

  if ($FileObj -ne $null) {
    $Result = $FileObj.Close()
    $global:ErrorCode = $global:AmtFile.ErrorCode
    $global:ErrorDescription = $global:AmtFile.ErrorDescription
    Set-FileControlError $global:AmtFile.ErrorCode $global:ErrorDescription
  }

  return $Result
} # Close-TextFile


function Fco-FreeFile {
  
  <#
    .SYNOPSIS 
      Free a file
    .PARAMETER FileHandle
      [Object] FileHandle of file to free
  #>

  param (
    [Object]$FileHandle
  )

  Set-FileControlError 0
  
  if ($FileHandle -ne $null) {
    $FileHandle = $global:AmtFile.Free($FileHandle.FileId)  # Free returns FileInfo object like Assign
    #$global:AmtFile.Close($FileHandle.FileId)
    $global:ErrorCode = $global:AmtFile.ErrorCode
    $global:ErrorDescription = $global:AmtFile.ErrorDescription    
    Set-FileControlError $global:AmtFile.ErrorCode $global:ErrorDescription

    if (-not(Check-FileControlError 0)) {
      Abort $global:ErrorDescription
    }
  }
} # Fco-FreeFile


function Fco-RenameFile {

  <#
    .SYNOPSIS 
      Rename a file.
    .DESCRIPTION
      Rename a file with FileNameOld to FileNameNew. 
      File should be assigned before calling and freed after calling to get an exclusive lock.
    .PARAMETER FileNameOld
      [String] Old file name.
    .PARAMETER FileNameNew
      [String] New file name.
  #>

  param (
    [String]$FileNameOld,
    [String]$FileNameNew
  )

  Replace-Asterisks ([Ref]$FileNameOld)
  Replace-Asterisks ([Ref]$FileNameNew)

  $global:AmtFile.RenameFile($FileNameOld, $FileNameNew, 1) | Out-Null
  $global:ErrorCode = $global:AmtFile.ErrorCode
  $global:ErrorDescription = $global:AmtFile.ErrorDescription    
  Set-FileControlError $global:AmtFile.ErrorCode $global:ErrorDescription

  if (-not(Check-FileControlError 0)) {
    # it could be a cycle file, => construct a file cycle name and find the highest number
    $BaseNameStart = $FileNameOld.LastIndexOf("\") + 1
    $ExtensionStart = $FileNameOld.IndexOf($global:Extension, $BaseNameStart)
    $Basename = $FileNameOld.Substring($BaseNameStart, $ExtensionStart - $BaseNameStart)
    $CycleFolder = $FileNameOld.Substring(0, $ExtensionStart) + $global:Extension + ".AmtFileCycle"

    if (-not $global:AmtFile.FolderExists($CycleFolder)) {
      # wrong store, try the other one
      if ($CycleFolder.Contains('\TPF$')) {
        $CycleFolder = $CycleFolder.Replace($global:TempFolder, $global:ExtractPath)
      } else {
        $CycleFolder = $CycleFolder.Replace($global:ExtractPath, $global:TempFolder)
      }
    }

    if ($global:AmtFile.FolderExists($CycleFolder)) {

      $Files = $global:AmtFile.GetFiles($CycleFolder, $false)

      if ($Files -eq "") {
        Abort "Fco-RenameFile: No files found in $CycleFolder"
      }

      [String[]]$SplitFiles = $Files.Split(',', [StringSplitOptions]::RemoveEmptyEntries)
      $FileNameOld = $CycleFolder + "\" + $SplitFiles[$SplitFiles.Length - 1]
    } else {
      Abort "Fco-RenameFile: No cycle folder found in for $BaseName"
    }

    # now try again
    $global:AmtFile.RenameFile($FileNameOld, $FileNameNew, 1) | Out-Null
    $global:ErrorCode = $global:AmtFile.ErrorCode
    $global:ErrorDescription = $global:AmtFile.ErrorDescription
    Set-FileControlError $global:AmtFile.ErrorCode $global:ErrorDescription

    if (-not(Check-FileControlError 0)) {
      # OK, time to give up
      Abort "Rename failed: $global:ErrorDescription"
    }
  }

} # FcoRenameFile


function Delete-File {
  <#
    .SYNOPSIS 
      Delete a file
    .PARAMETER Filename
      [String] Filename of file to delete
    .OUTPUTS
      [Boolean] True if file was deleted successfully, otherwise false
  #>

  param (
    [String]$Filename
  )

  [Boolean]$Result = $false
  Set-FileControlError 0
  Replace-Asterisks ([Ref]$Filename)

  if ($global:AmtFile.DeleteFile($Filename, 100)) {
    $Result = $true
  } else {
    $global:ErrorCode = $global:AmtFile.ErrorCode
    $global:ErrorDescription = $global:AmtFile.ErrorDescription
    Set-FileControlError $global:AmtFile.ErrorCode $global:AmtFile.ErrorDescription
    if (Check-FileControlError 13) {  # 13 = File does not exist
      $Result = $true
	  Set-FileControlError 0
    } elseif (Check-FileControlError 95) {  # Timeout
      Add-WarningMsg "Timeout deleting $Filename"
      # TODO: DelAttachedFile(s_FileName)
      # ??? This does not seem to apply to our implementation.
      $Result = $false
    }
  }
} # Delete-File


function Is-FullyQualifiedFile {
  <#
    .SYNOPSIS
      Checks if $filename is qualified by checking if first two chars are "\\" or
      if 2nd and 3rd chars = ":\".
    .PARAMETER Filename
      [String] Filename to check
    .OUTPUTS
      [Boolean] True if fully qualified file, otherwise false
  #>

  param (
    [String]$Filename
  )

  [Boolean]$Result = $false
  
  if ($Filename.StartsWith("\\")) {
    $Result = $true
  } elseif ($Filename.Substring(1,2) -eq ":\") {
    $Result = $true
  }
  return $Result  
} # FullyQualifiedFile


function Check-File {
  <# 
    .SYNOPSIS
      Check and add extractpath to a filename.
    .PARAMETER Filename
      [String] File to check
    .PARAMETER UseExtension
      [Boolean] True if extension must be used.
    .OUTPUTS
      [String] Checked filename.
  #>

  param (
    [String]$Filename,
    [Boolean]$UseExtension
  )

  if ($Filename -eq "") {
    return
  }

  if (-not (Is-FullyQualifiedFile $Filename)) {
    $Filename = (Add-BackSlash $global:ExtractPath) + $Filename
  }

  if (($UseExtension) -and ($Filename.IndexOf('.', $Filename.LastIndexOf('\')) -lt 0)) {
    $Filename = (Add-FileExtension $Filename $global:UseExtension)
  }

  return $Filename
} # Check-File


function File-Exists {
  <#
    .SYNOPSIS 
      Checks if a file exists.
    .DESCRIPTION
        Checks if a file exists.
    .PARAMETER File
      [String] String containing filename
    .OUTPUTS
      [Boolean] True if the file exists, else false
  #>

  param (
    [String]$File
  )

  [Boolean]$Result = $false
  if ($File -eq "") {
    return $Result
  }

  Replace-Asterisks ([Ref]$File)

  if ($global:AmtFile.FileExists($File)) {
    $Result = $true
  } else {
    $Result = $false
  }

  Write-JobLog "" ([LoggingSeverity]::Debug)
  Write-JobLog "File-Exists: $File, result: $Result" ([LoggingSeverity]::Debug)

  return $Result
} # File-Exists


function Folder-Exists {
  <#
    .SYNOPIS
      Checks if a folder exists
    .PARAMETER Folder
      [String] String containing folder name (entire path)
    .OUTPUTS
      [Boolean] True if folder exists, otherwise false
  #>

  param (
    [String]$Folder
  )

  [Boolean]$Result = $false
  if ($global:AmtFile.FolderExists($Folder)) {
    $Result = $true
  }

  return $Result
} # Folder-Exists


function Check-FileName {
  <#
    .SYNOPSIS
      Checks and returns the (corrected) filename.
    .DESCRIPTION
      Input filename without path including any eltname
      Output filename  + blank eltname or Filename (directory) + non blank eltname with a "/" replaced by a "."
    .PARAMETER Filename
      [String]Filename
    .PARAMETER Eltname
      [String]Eltname
    .PARAMETER Cycle
      [String]Cycle
  #>

  param (
    [Ref]$Filename,
    [Ref]$Eltname,
    [String]$Cycle = ''
  )

  Replace-Asterisks ([Ref]$Filename.Value)

  [String]$FileNameOrg = $Filename.Value
  [Int32]$Pos = $FileNameOrg.IndexOf(".")
  if ($Pos -gt -1) {
    $Filename.Value = $FileNameOrg.Substring(0, $Pos)
    $Eltname.Value = $FileNameOrg.Substring($Pos + 1)
  }

  if ($Eltname.Value.IndexOf("/") -gt -1) {
    $Eltname.Value = $Eltname.Value.Replace("/", ".")
  }

  if ($Cycle -ne '') {
    $Filename.Value = $Filename.Value + '(' + $Cycle + ')'
  }
} # Check-FileName


function Add-FileExtension {
  <#
    .SYNOPSIS
      Add extension defined in $global:Extension to the filename.
    .DESCRIPTION
      Add file extension as defined in $global:Extension to the supplied filename. 
      The extension will only be added if $UseExtension is $true. Returns the 
      modified $Filename.
    .PARAMETER Filename
      [String] Filename to add extension to.
    .PARAMETER UseExtension
      [Boolean] Only add the extension if this parameter is $true.
    .OUTPUTS
      [String] String containing file with extension
  #>

  param (
    [String]$Filename,
    [Boolean]$UseExtension
  )

  [String]$Result = ""

  # check if file is index file
  $i = $Filename.LastIndexOfAny("\")
  if ($i -gt -1) {
    if ($Filename.Substring($i).ToUpper() -eq "KEY01") {
      $Filename = $Filename.Substring(0, $i) + $global:extension + ".Index"
      $Result = $Filename
      return $Result
    }
  }

  $Result = $Filename
  if ($UseExtension) {
    if (-not $Filename.EndsWith($global:Extension)) {
	  if ($Filename.EndsWith(')')) {
	    # c:\amt\files\extract\abc(1)
		# c:\amt\files\extract\abc.dat(1)
		$i = $Filename.LastIndexOf('(')
		[String]$Test = $Filename.Substring(0, $i)
		if (-not $Test.EndsWith($global:Extension)) {
		  # c:\amt\files\extract\abc(1)
		  $Result = $FileName.Insert($i, $global:Extension) # c:\amt\files\extract\abc.dat(1)
		} else {
		  # c:\amt\files\extract\abc.dat(1)
		  # So already extention added
		}
	  } else {
	    $Result = $Filename + $global:Extension  
	  }
    }
  }

  return $Result
} # Add-FileExtension

function Find-AssignedFileInList {
  <#
    .SYNOPSIS 
      Checks if a file exists in the list of assigned files
    .DESCRIPTION
      Checks global list of files for the file 
    .PARAMETER Filename
      [String] String containing filename with or without cycle.
    .OUTPUTS
      [Boolean] True if the file exists, else false
  #>

  param (
    [String]$Filename
  )

  [Boolean]$Result = $false
  for ([Int32]$I = 0; $I -lt $global:FilesList.Count; $I++) {
    if ($global:FilesList[$I].Filename -eq $Filename) {
      $Result = $true
      $global:FileObject = $global:FilesList[$I]
      Write-JobLog "Found assigned file : $Filename" ([LoggingSeverity]::Debug)
      return $Result
    }
  }
  return $Result
}

function Get-GobalFullFilename { 
  <#
    .SYNOPSIS 
      Gets the right filename from the $global:FileObject
    .DESCRIPTION
      If a filehandle exists, the full name is returned otherwise the copyname or WindowsFilename.
      Can be called after sucessful Find-AssignedFileInList.
    .OUTPUTS
      [String] Full file name for further processing.
  #>

  if (($global:FileObject.FileHandle -ne $null) -and ($global:FileObject.FileHandle.FullName -ne "")) {
    return $global:FileObject.FileHandle.FullName
  } elseif ($global:FileObject.Copyname -ne "") {
    return $global:FileObject.Copyname
  } else {
    return $global:FileObject.WindowsFilename
  }
}


function Check-ShortName {
  <#
    .SYNOPSIS
      Find a file in the list of files by it's short name.
    .PARAMETER ShortName
      [String] The short name to look for.
    .OUTPUTS
      [Boolean] True if ithe file was found, $global:FileObject contains the right file then.
  #>

  param (
    [String]$ShortName
  )

  If ($ShortName.IndexOf('\') -gt -1) {
    return $false    #there should be no path/qualifier in the name
  }
  If ($ShortName.IndexOf('/') -gt -1) {
    return $false    #there should be no path/qualifier in the name
  }
  if ($ShortName.EndsWith($global:Extension)) {
    $ShortName = $ShortName.Substring(0,$Result.Length - $global:Extension.Length)
  }
  foreach ($FileObject in $global:FilesList) {
    if ($FileObject.ShortName -eq $ShortName) {
      $global:FileObject = $FileObject
      return $true
    }
  }
  return $false
}

function Get-Folders {
  <#
    .SYNOPSIS
      Returns a comma separated list of folders in the folder specified by FolderName. 
      The name of the folder should contain the full path. 
    .PARAMETER $Folder
      [String] String containing folder name
    .PARAMETER Recursive
      [Boolean] True if folder should be searched recursively
    .OUTPUTS
      [String] Comman separated list of folders
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Folder,
    [Parameter(Mandatory=$true)][Boolean]$Recursive
  )

  [String]$Result = $global:AmtFile.GetDirectories($Folder, $Recursive)

  Return $Result
} # Get-Folders


function Get-Files {
  <#
    .SYNOPSIS
      Returns a comma separated list of files in the folder. The folder variable
      should contain the full path. When recursive is set to True, the files in subfolders
      will also be listed.
    .PARAMETER Folder
      [String] String containing folder name
    .PARAMETER Recursive
      [Boolean] True if folder should be searched recursively
    .OUTPUTS
      [String] Comma separated list of files. 
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Folder,
    [Parameter(Mandatory=$true)][Boolean]$Recursive
  )

  if (-not($Folder.EndsWith("\"))) {
    $Folder += "\"
  }

  [String]$Result = $global:AmtFile.GetFiles($Folder, $Recursive)
  Return $Result
} # Get-Files


function Delete-EmptyFoldersInPath {
  <#
    .SYNOPSIS
      Deletes the last folder in the specified path that is empty.
      Path is typically a full name of a file that no longer exists.
    .PARAMETER Path
      [String] A file system path.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Path
  )

  if (-not $global:DeleteEmptyFolders) {
    return  # Empty Folders can be retained  
  }
  [String]$Folder = $Path
  if ((-not ($Folder.StartsWith($global:ExtractPath, [StringComparison]::OrdinalIgnoreCase))) -and
      (-not ($Folder.StartsWith($global:TempFolder, [StringComparison]::OrdinalIgnoreCase)))) {
    $Folder = (Add-BackSlash ($global:ExtractPath)) + $Path 
  }
  if (-not (Folder-Exists $Folder)) {
    $Folder = $Folder.SubString(0, $Folder.LastIndexOf("\"))
    if (-not (Folder-Exists $Folder)) {
      return  # Folder does not exist
    }
  }

  $Folder = Add-BackSlash ($Folder)
  if (($Folder -eq (Add-BackSlash ($global:ExtractPath))) -or
      ($Folder -eq (Add-BackSlash ($global:TempFolder)))) {
    return
  }

  [String]$Files = $global:AmtFile.GetFiles($Folder, $false)  
  if ($global:AmtFile.ErrorCode -ne 0) {
    [String]$FCError = $global:AmtFile.ErrorDescription
    # check if the folder is deleted in the meantime. If it is deleted, no error message is required.
    if (-not ($global:AmtFile.FolderExists($Folder))) {
      return 
    }
    Abort "Error calling GetFiles. $FCError"
  }
  if ($Files -ne "") {
    return   # Folder is not empty
  }
  [String]$Folders = $global:AmtFile.GetDirectories($Folder, $false)
  if ($global:AmtFile.ErrorCode -ne 0) {
    [String]$FCError = $global:AmtFile.ErrorDescription
    # check if the folder is deleted in the meantime. If it is deleted, no error message is required.
    if (-not ($global:AmtFile.FolderExists($Folder))) {
      return 
    }
    Abort "Error calling GetDirectories. $FCError"
  }
  if ($Folders -ne "") {
    return # Folder is not empty
  }

  # No files and folders found: try to delete this folder
  if (-not(Delete-Folder $Folder $false)) {
    # Retry to delete the folder (Max 10 times)
    [Int32]$Loop = 0
    While ($Loop -lt 10) {
      Start-Sleep -Milliseconds 100
      if (-not(Folder-Exists $Folder)) {
        break
      }
      if (Delete-Folder $Folder $false) {
        break
      }
      $Loop++
    }#While
  }        
  
} # Delete-EmptyFoldersInPath


function Get-JobValue {
  <#
    .SYNOPSIS 
      Get Job value custom Task Value
    .PARAMETER ObjTask
      [Object] Task object
    .OUTPUTS
      [Int32] Value of Custom Task value
  #>

  param (
    [Parameter(Mandatory=$true)][Object]$ObjTask
  )

  [Int32]$Result = 0
  [String]$Value = $ObjTask.GetTVCustom("JOBVALUE")
  if (![Int32]::TryParse($Value, [ref]$Result)) {
    $Result = 0
  }

  Write-JobLog "Get-JobValue, $($ObjTask.JobText) : $Result" ([LoggingSeverity]::Debug)

  return $Result
} # Get-JobValue


function Create-Taskobject {
  <#
    .SYNOPSIS 
      Create a Task Object
    .DESCRIPTION
      Creates a Task Object with the JobText property set to the $Name parameter. 
      This $Name is stored so that the name of the task variable can be retrieved
      for logging purposes.
    .PARAMETER Name
      Task Object Variable name. 
    .OUTPUTS
      [Object] Task Object with JobText set to $Name parameter
  #>

  Param(
    [Parameter(Mandatory=$true)][String]$Text
  )

  [Object]$TaskObj = $global:Com.CreateJob()
  $TaskObj.JobText = $Text

  return $TaskObj
} # Create-Taskobject


function Get-TaskObject {
  <#
    .SYNOPSIS 
      Get the Task Object
    .DESCRIPTION
      Get the Task Object. If the passed Task object is null, the AmtReport task
      object is returned.
    .PARAMETER ObjTask
      [Object] Task Object, can be $null
    .OUTPUTS
      [Object] Task Object
  #>

  param (
    [Object]$ObjTask
  )

  [Object]$Result = $null
  if ($ObjTask -eq $null) {
    $Result = $global:AmtReport
  } else {
    $Result = $ObjTask
  }  

  return $Result
} # Get-TaskObject


function Check-ClearTaskObject {
  <#
    .SYNOPSIS
      Clear the task object if it must be cleared.
    .DESCRIPTION
      This function checks if the task object exists in the TaskObjects List. 
      If it exists, check if it is set to be cleared. 
      If set to be cleared: clear it.
      Add the task object to the list if doesn't exist yet.
    .PARAMETER TaskObj
      [Object] Task object      
  #>

  param (
    [Object]$TaskObj
  )

  if ($global:TaskObjectsList.ContainsKey($TaskObj.JobText)) {
    if ($global:TaskObjectsList.Item($TaskObj.JobText) -eq $false) {
      # Task object not yet cleared, so clear it.
      Clear-TaskObject -ObjTask $TaskObj
      $global:TaskObjectsList.Item($TaskObj.JobText) = $true
    }
  } else {
    # Task object doesn't exist in the list, add it.
    $global:TaskObjectsList.Add($TaskObj.JobText, $true)
    $TaskObj.TaskValue = 0 # TASKVALUE is 0 by default
  }  
} # Check-ClearTaskObject


function Clear-TaskObject {
  <#
    .SYNOPSIS
      Clear all taskvariable values.
    .PARAMETER ObjTask
      [Object] Task Object
  #>

  param (
    [Parameter(Mandatory=$true)][Object]$ObjTask
  )

  $ObjTask.Initialize()
  $ObjTask.TaskValue = 0 # TASKVALUE is 0 by default
} # Clear-TaskObject


function Parse-Options {
  <#
    .SYNOPSIS
      Tries to parse a string of comma separated options to an Enum.
    .PARAMETER Options
      [String] Comma separated options
    .PARAMETER Enum
      [Object] Option Enum to parse to. Could be of any existing type.
    .EXAMPLE
      [MsgOptions]$MsgOptions = ParseOptions "A, B, C" ([MsgOptions])
    .OUTPUTS
      Parsed Enum object
  #>

  param (
    [String]$Options,
    [Parameter(Mandatory=$true)][Object]$Enum
  )

  if ($Options -eq "") {
    return $Enum::None
  }

  try {
    return [Enum]::Parse([Type]$Enum, $Options)
  } catch [Exception] {
    Abort "Invalid options for $($Enum.ToString()): $Options"
  }
} # Parse-Options


function Remove-Flag {
  <#
    .SYNOPSIS
      Removes the specified flag from the specified Enum
    .PARAMETER Flag
      [Object] Flag to remove
    .PARAMETER Enum
      [Enum] Enum to remove the flag from
    .EXAMPLE
      Remove-Flag ([MsgOptions]::W) ([Ref]$MsgOptions)
  #>

  param (
    [Parameter(Mandatory=$true)][Object]$Flag,
    [Parameter(Mandatory=$true)][Ref]$Enum
  )

  # Extra check to make sure that the Enum and the Flag are of the same type
  if ($Flag.GetType() -eq $Enum.Value.GetType()) {
    $Enum.Value = $Enum.Value -band (-bnot $Flag)
  } else {
    Abort "Remove-Flag: Flag and Enum are not of the same type."
  }
} # Remove-Flag


function Add-Flag {
  <#
    .SYNOPSIS
      Adds the specified flag to the specified Enum
    .PARAMETER Flag
      [Object] Flag to remove
    .PARAMETER Enum
      [Enum] Enum to remove the flag from
    .EXAMPLE
      Add-Flag ([MsgOptions]::W) ([Ref]$MsgOptions)
  #>

  param (
    [Parameter(Mandatory=$true)][Object]$Flag,
    [Parameter(Mandatory=$true)][Ref]$Enum
  )

  # Extra check to make sure that the Enum and the Flag are of the same type
  if ($Flag.GetType() -eq $Enum.Value.GetType()) {
    $Enum.Value = $Enum.Value -bor $Flag
  } else {
    Abort "Add-Flag: Flag and Enum are not of the same type."
  }
} # Add-Flag


function Cleanup {
  <#
    .SYNOPSIS 
      Clean up method, cleans up global files etc.
    .DESCRIPTION
      This routine is called before the end of the script.
    .PARAMETER Boolean
      [Boolean] True if script ended in error
  #>

  param (
    [Boolean]$HadError
  )

  if (-not $global:CleanedUp) {
    $global:InCleanup = $true
    try {
      # Cleanup files
      for ([Int32]$Index = $global:FilesList.Count - 1; $Index -ge 0; $Index--) {
        $global:FileObject = $global:FilesList[$Index]
        if ($global:FileObject.IsAssigned) {
          if (($global:FileObject.Filename -ne $global:JobLogFile) -and   
              ($global:FileObject.Copyname -ne $global:JobLogFile)) {
            [String]$Filename = $global:FileObject.Filename
            if (($global:FileObject.FileHandle -ne $null) -and ($global:FileObject.FileHandle.FullName -ne "")) {
              $Filename = $global:FilesList[$Index].FileHandle.FullName
            }
            Release-File $Filename $false $HadError $false
          }
        }
      }

      Set-FileControlError 0  # reset any errors

      if ($global:UseJobLog) {
        Write-JobLog "" ([LoggingSeverity]::Warning)
        $Msg = "End Job. Start: {0}" -f (Get-TimeDate "YYYY-MM-DD HH:MM:SS" $global:StartDateTimeObj)
        Write-JobLog $Msg ([LoggingSeverity]::Warning)
        $EndDateTimeObj = Get-Date
        $Msg = "         End:   {0}" -f (Get-TimeDate "YYYY-MM-DD HH:MM:SS" $EndDateTimeObj)
        Write-JobLog $Msg ([LoggingSeverity]::Error)

        if ($global:Restart -and (-not $global:RestartLabelVisited)) {
          $Msg = "The job was restarted but the provided label was never visited, => the specified restart label is invalid."
          Write-JobLog $Msg ([LoggingSeverity]::Warning)
        }

        if (-not $HadError) {
          # Send a Done message as the last message before Exit but after any error messages that could happen in the Cleanup
          # note: Doing this any further down may result in failure to write to the job log file, in the code directly following 
          #       the job log file may be moved to the master file directory.
          Add-InformationMsg "Script Done: $($global:JobName)"
        }

        if ($global:JobLogFile -ne $global:JobLogFileOrig) {
          #In Brkpt mode a file separate assigned file is used as Job Log, 
          #make sure it get's copied from the temp folder before it is too late.
          for ([Int32]$Index = 0; $Index -lt $global:FilesList.Count; $Index++) {
            $global:FileObject = $global:FilesList[$Index]
            if ($global:FileObject.IsAssigned) {
              if (($global:FileObject.Filename -eq $global:JobLogFile) -or
                  ($global:FileObject.Copyname -eq $global:JobLogFile)) {
                [String]$Filename = $global:FileObject.Filename
                if (($global:FileObject.FileHandle -ne $null) -and ($global:FileObject.FileHandle.FullName -ne "")) {
                  $Filename = $global:FilesList[$Index].FileHandle.FullName
                }
                break
              }  
            }
          }
          Close-JobLog
          Release-File $Filename $false $HadError $false
        } else {
          Close-JobLog
          if ($global:DelJobLogFile) {
            #SYM D encountered before cleanup, delete the joblog.
            Delete-File $global:JobLogFile
            $global:DelJobLogFile = $false
          }
        }
      }     
	  $global:Com.RemoveNonPrintedFiles($global:BatchId) | Out-Null
	  
      $global:FilesList.Clear()
      Set-FileControlError 0  # reset any errors

      if ($global:AmtFile -ne $null) {
        $global:AmtFile.CloseAllFiles() | Out-Null
	  }

      Delete-Folder $global:TempFolder $false | Out-Null
    } finally {
      if ($global:Com -ne $null) {
        $global:Com.Dispose()
        $global:Com = $null
      }

      $global:InCleanup = $false
      $global:CleanedUp = $true
    }
  }

  # we must still call Exit or the script will continue to run!
  # but if aborted the script should report the error back
  # to OpCon. This is done through the TaskValue EXITCODE
  if ($global:AbortCalled) {
    [Console]::Error.WriteLine('Abort was called (Exit 1).')
    # note: This will do nothing in PowerShell ISE, it tells BatchController there was an error.
    Call-Exit-One
  } else {
    if ($global:Restart -and (-not $global:RestartLabelVisited)) {
      # a restart label was passed in but we never made it to a label by that name so the label must be invalid
      # an error message has been written to the job log before it was closed, now exit with error
      [Console]::Error.WriteLine('An invalid restart label was provided (Exit 1).')
      # note: This will do nothing in PowerShell ISE, it tells BatchController there was an error.
      Call-Exit-One
    }

    $Global:AmtExitCode = 0
    Exit 0
  }
} # Cleanup


function Abort {
  <#
    .SYNOPSIS
      Sends error message to the control center and then ends the script.
    .PARAMETER Message
      [String] A string containing the message
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Message
  )

  $global:AbortCalled = $true
  Add-ErrorMsg "$global:AppName  - $global:Jobname : $Message"

  if ($global:InCleanup) {
    return
  }

  Cleanup $true
} # Abort

# Function is needed for sort library.
function Display {
  <#
    .SYNOPSIS
      Sends a message to the Control Center.
    .PARAMETER Message
      [String] Message
  #>
  param (
    [String]$Message
  )
  
  Add-InformationMsg -Message $Message
} # Display

function Add-InformationMsg {
  <#
    .SYNOPSIS
      Sends an informational message to the Control Center.
    .PARAMETER Message
      [String] Message
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Message
  )

  # AMT
  if ($global:AmtMessage -ne $null) {
    [Void]$global:AmtMessage.AddMsgInformation($Message)
  }

  # job log
  if (($global:LoggingSeverity -ge [LoggingSeverity]::Info) -and
      ($global:UseJobLog) -and ($global:JobLogFileAvailable) -and ($global:JobLogObj -ne $null)) {
    $JobLogMsg = $Message.Replace($global:RemoveFromFilename, "")
    if ($global:LogTimes) {
      $DateTime = Get-TimeDate "YYYY-MM-DD HH:MM:SS" (Get-Date)
      $JobLogMsg = $DateTime + " Info: " + " " + $JobLogMsg
    }

    [Void]$global:JobLogObj.WriteLine($JobLogMsg, $true)
  }

  # console
  if (($global:Com -eq $null) -or ($global:Com.Station -ne "BATCH")) {
    Write-Host "Info: $Message" -ForegroundColor Green
  }

  # event log
  if ($global:LogEventInfo) {
    Asy-WriteEventLog $global:JobName $Message "Application" 0 ([System.Diagnostics.EventLogEntryType]::Information)
  }
} # Add-InformationMsg


function Add-ErrorMsg {
  <#
    .SYNOPSIS
      Sends an error message to the Control Center.
    .PARAMETER Message
      [String] Message
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Message
  )

  # AMT
  if ($global:AmtMessage -ne $null) {
    [Void]$global:AmtMessage.AddMsgError($Message)
  }

  # job log
  if (($global:UseJobLog) -and ($global:JobLogFileAvailable) -and ($global:JobLogObj -ne $null)) {
    $JobLogMsg = $Message.Replace($global:RemoveFromFilename, "")
    if ($global:LogTimes) {
      $DateTime = Get-TimeDate "YYYY-MM-DD HH:MM:SS" (Get-Date)
      $JobLogMsg = $DateTime + " Error: " + " " + $JobLogMsg
    }

    [Void]$global:JobLogObj.WriteLine($JobLogMsg, $true)
  }

  # console
  Write-Host "Error: $Message" -ForegroundColor Red

  # event log
  if ($global:LogEventError) {
    Asy-WriteEventLog $global:JobName $Message "Application" 0 ([System.Diagnostics.EventLogEntryType]::Error)
  }
} # Add-ErrorMsg


function Add-WarningMsg {
  <#
    .SYNOPSIS
      Sends a warning message to the Control Center.
    .PARAMETER Message
      [String] Message
  #>
  param (
    [Parameter(Mandatory=$true)][String]$Message
  )

  # AMT  
  if ($global:AmtMessage -ne $null) {
    [Void]$global:AmtMessage.AddMsgWarning($Message)
  }

  # job log
  if (($global:LoggingSeverity -ge [LoggingSeverity]::Warning) -and 
      ($global:UseJobLog) -and ($global:JobLogFileAvailable) -and ($global:JobLogObj -ne $null)) {
    $JobLogMsg = $Message.Replace($global:RemoveFromFilename, "")
    if ($global:LogTimes) {
      $DateTime = Get-TimeDate "YYYY-MM-DD HH:MM:SS" (Get-Date)
      $JobLogMsg = $DateTime + " Warning: " + " " + $JobLogMsg
    }
    
    [Void]$global:JobLogObj.WriteLine($JobLogMsg, $true)
  }

  # console
  Write-Host "Warning: $Message" -ForegroundColor Magenta

  # event log
  if ($global:LogEventWarning) {
    Asy-WriteEventLog $global:JobName $Message "Application" 0 ([System.Diagnostics.EventLogEntryType]::Warning)
  }
} # Add-WarningMsg


function Asy-WriteEventLog {
  <#
    .SYNOPSIS
      Writes an event to the specified event log.
    .DESCRIPTION
      Writes an event to an event log. The event will be written to the Application log file 
      if LogName is not provided. If EventID is not provided, it will be set to 0. The EntryType
      can be set to Error, Warning and Information.
    .PARAMETER SourceName
      [String] Name of the source script
    .PARAMETER Message
      [String] Message to write to the Event Log
    .PARAMETER LogName
      [String] Name of the log file (default: Application)
    .PARAMETER EventID
      [Int32] Event ID (default: 0)
    .PARAMETER EntryType
      [System.Diagnostics.EventLogEntryType] Error | Warning | Information
  #>

  param (
    [Parameter(Mandatory=$true)][String]$SourceName,
    [Parameter(Mandatory=$true)][String]$Message,
    [String]$LogName = "Application",
    [Int32]$EventID = 0,
    [System.Diagnostics.EventLogEntryType]$EntryType = [System.Diagnostics.EventLogEntryType]::Error
  )

  if ($global:SkipWriteToEventLog) {
    return # The Abort causes this method to be called again. Causing recursion
  }

  try {
	[Asysco.Amt.Libs.Support.AmtEventLog]::WriteToEventLog($SourceName, $Message, $EventID, $EntryType, 0)
  } catch [Exception] {
    $global:SkipWriteToEventLog = $true
    Abort "Could not write to the Windows Event Log: $_"
    $global:SkipWriteToEventLog = $false
  }
} # Asy-WriteEventLog


function Get-CompletedOk {
  <#
    .SYNOPSIS
      Gets the GetCompletedOK switch from the taskvariable and returns true or false.
    .PARAMETER TaskObj
      Task object
    .OUTPUTS
      [Boolean] True or false.
  #>

  param (
    [Parameter(Mandatory=$true)][Object]$TaskObj  # Task object
  )
  
  [Boolean]$Result = $false
  if ($TaskObj.Wait) {
    $Result = $TaskObj.ProcessOK
  } else {
    if ($TaskObj.Running() -eq $true) {
      $Result = $false
    } else {
      $Result = $TaskObj.ProcessOK
    }
  }

  Write-JobLog "Get-CompletedOK $($TaskObj.JobText) : $Result" ([LoggingSeverity]::Debug)
  return $Result
} # Get-CompletedOk


function Set-CompletedOk {
  <#
    .SYNOPSIS
      Sets the CompletedOk switch in the task variable.
    .PARAMETER TaskObj
      [Object] Task object, can be $null
    .PARAMETER Value
      [Boolean] True or false.
  #>

  param (
    [object]$TaskObj, # Task object
    [Parameter(Mandatory=$true)][Boolean]$Value   # True if completed OK
  )

  $TaskObj = Get-TaskObject $TaskObj
  $TaskObj.ProcessOk = $Value
} # Set-CompletedOk


function Msg {
  <#
    .SYNOPSIS
      ECL equivalent: @MSG / @@MSG
    .DESCRIPTION
      Sends a message to the Control Center.

      Supported options: W, N.
      W: Holds up your run until the operator responds to your message.
         Note: If the operator replies with an 'X', the run is aborted.
      N: Suppresses message display.
         Note: Overrides option W.
    .PARAMETER Options
      [String] Options, comma separated
    .PARAMETER Message
      [String] The message to send to the Control Center.
  #>

  param (
    [String]$Options,
    [String]$Message
  )

  if (Process-Skip "MSG [$($Options)]") {
    return
  }

  Check-FinishStatement

  Write-Joblog "Msg: $Message" ([LoggingSeverity]::Info)
  Write-Joblog "Msg Options: $Options" ([LoggingSeverity]::Info)

  [MsgOptions]$MsgOptions = Parse-Options $Options ([MsgOptions])

  if ($MsgOptions -eq [MsgOptions]::None) {
    Add-InformationMsg $Message
  }

  if ($MsgOptions.HasFlag([MsgOptions]::N)) {
    # Option N overrides W, so remove it from options
    Remove-Flag ([MsgOptions]::W) ([Ref]$MsgOptions)

    # Write only to the job log
    Write-Joblog "" ([LoggingSeverity]::Error)
    Write-Joblog $Message ([LoggingSeverity]::Error)
  }

  if ($MsgOptions.HasFlag([MsgOptions]::W)) {
    # Wait for operator input
    $Result = Accept $Message
  }
} # Msg


function Qual {
  <#
    .SYNOPSIS
      ECL equivalent: @QUAL / @@QUAL
    .DESCRIPTION
      The @QUAL statement lets you use implied directory-ids or qualifier names for 
      subsequent control statements involving references to external file names.
      
      Supported options: D or R. You can only use one option.
      D: Specifies the default directory-id or qualifier.
      R: Reverts your run’s default and implied directory-id and qualifier back to the 
         values they had when your run started.
    .PARAMETER Options
      [String] D or R
    .PARAMETER Qualifier
      [String] Qualifier
  #>

  param (
    [String]$Options,
    [String]$Qualifier
  )

  if (Process-Skip "QUAL [$($Options)]") {
    return
  }

  Check-FinishStatement

  Write-Joblog "QUAL: $Qualifier" ([LoggingSeverity]::Info)
  Write-Joblog "QUAL Options: $Options" ([LoggingSeverity]::Info)

  [QualOptions]$QualOptions = Parse-Options $Options ([QualOptions])

  if ($QualOptions.HasFlag([QualOptions]::D)) {
    if ($Qualifier -eq "") {
      Abort "Qualifier must be specified."
    }

    $global:DefaultQual = $Qualifier
    $global:QualPath = (Add-BackSlash $global:ExtractPath) + $Qualifier
  } else {
    if ($QualOptions.HasFlag([QualOptions]::R)) {
      if ($Qualifier -ne "") {
        Abort "Qualifier may not be specified."
      }

      $global:DefaultQual = $global:ProjectQual
      $global:QualPath = (Add-BackSlash $global:ExtractPath) + $global:DefaultQual
    } else {
      if ($QualOptions -eq [QualOptions]::None) {
        if ($Qualifier -eq "") {
          Abort "Qualifier must be specified."
        }

        if ($global:FirstQual) {
          $global:ProjectQual = $Qualifier
          $global:DefaultQual = $global:ProjectQual
          $global:ImpliedQual = $Qualifier
          $global:QualPath    = (Add-BackSlash $global:ExtractPath) + $Qualifier
          $global:FirstQual   = $false
        } else {
          $global:ImpliedQual = $Qualifier
        }
      } else {
        Abort "Invalid options: $Options" 
      }
    }
  }
  $global:QualPath = $global:QualPath.ToUpperInvariant()
} # Qual


function Log {
  <#
    .SYNOPSIS
      ECL equivalent: @LOG / @@LOG
    .DESCRIPTION
      Adds a message to the job summary.
    .PARAMETER Message
      [String] Message to add to the job summary
  #>

  param (
    [String]$Message
  )

  if (Process-Skip "LOG: $Message") {
    return
  }

  Check-FinishStatement

  Write-Joblog "LOG: $Message" ([LoggingSeverity]::Error)
} # Log


function Site {
  <#
    .SYNOPSIS
      ECL equivalent: @SITE / @@SITE
  #>

  if (Process-Skip "SITE") {
    return
  }

  Check-FinishStatement

  Write-Joblog "SITE:" ([LoggingSeverity]::Info)
  Write-JobLog "Date: $global:StartDateTimeObj    Job: $global:JobName    Application: $global:AppName    Computer: $global:Station" ([LoggingSeverity]::Info)
} # Site


function Check-Cycle {
  <#
    .SYNOPSIS
      Checks and extracts the file cycle part from a filename.
    .DESCRIPTION
      If present, the file cycle part will be extracted from the filename.
      Reference variable $Cycle will then contain the extracted file cycle.
    .PARAMETER Filename
      [Ref] Name of file (Unisys format including possible cycle).
    .PARAMETER Cycle
      [Ref] The reference variable where the cycle will be added to.
    .OUTPUTS
      Filename without cycle part.
      And if present, the cycle without parentheses.
  #>

  param (
    [Ref]$Filename,
    [Ref]$Cycle
  )

  [String]$Plus = ""
  [Int32]$Pos = $Filename.Value.LastIndexOfAny("(")

  if ($Pos -gt 0) {
    # Extract cycle part from filename
    $Cycle.Value = $Filename.Value.Substring($Pos + 1)
    $Cycle.Value = $Cycle.Value.Substring(0, $Cycle.Value.Length - 1) # Remove last character -> ')'

    if (!($Filename.Value.EndsWith(")"))) {
      Abort "Check-Cycle: invalid filename"
    }

    $Filename.Value = $Filename.Value.Substring(0, $Pos) # Remove cycle part from filename
    
    if ($Cycle.Value.StartsWith("+")) {
      # Temporarily remove plus sign
      $Plus = "+"
      $Cycle.Value = $Cycle.Value.Substring(1)
    }

    if ($Cycle.Value -ne "") {
      if (Is-Numeric $Cycle.Value) {
        if ($Cycle.Value -eq 0) {
          $Cycle.Value = ""
        } else {
          $Cycle.Value = ($Plus + $Cycle.Value)
        }
      }
    }
  } else {
    $Cycle = ""
  }
} # Check-Cycle


function Find-Cycle {
  <#
    .SYNOPSIS
      Checks and returns the file cycle part from a filename.
    .DESCRIPTION
      If present, the file cycle part is returned from the filename.
    .PARAMETER Filename
      [String] Name of file (including possible cycle).
    .OUTPUTS
      Cycle without parentheses or empty string when no cycle found
  #>

  param (
    [String]$Filename
  )

  [String]$Result = ""
  [Int32]$Start = $Filename.LastIndexOfAny("(")
  if ($Start -gt -1) {
    [Int32]$End = $Filename.LastIndexOfAny(")")
    if ($End -gt $Start) {
      $Result = $Filename.Substring($Start + 1, $End - $Start - 1)
    }
  }
  return $Result
} # Find-Cycle


function Format-Cycle {
  <#
    .SYNOPSIS
      Returns the formatted file cycle so the file cycle consist of 3 digits.
    .PARAMETER Cycle
      [String] File cycle.
    .EXAMPLE
      +1 is formatted to +001
  #>

  param (
    [String]$Cycle
  )

  [String]$Sign = ""
  if (($Cycle.StartsWith("+")) -or ($Cycle.StartsWith("-"))) {
    $Sign = $Cycle.Substring(0, 1)
    $Cycle = $cycle.Substring(1)
  }

  switch ($Cycle.Length) {
    1 {
      $Cycle = "00" + $Cycle
      break
    }

    2 {
      $Cycle = "0" + $Cycle
      break
    }

    default {
      # Already 3 digits, 
      break
    }
  }

  return $Sign + $Cycle
} # Format-Cycle


function Strip-Cycle {
  <#
    .SYNOPSIS
      Checks and returns the filename without the filecycle part
    .DESCRIPTION
      If a cycle exists, filename without cycle is returned otherwise just the filename is returned.
    .PARAMETER Filename
      [String] Name of file (including possible cycle).
    .PARAMETER Cyclename
      [Ref] Name of the original file when it had a cycle, empty string when no cycle found
    .OUTPUTS
      Filename without a cycle
  #>

  param (
    [String]$Filename,
    [Ref]$Cyclename
  )

  [String]$NewFilename = $Filename
  [String]$NewCyclename = ""
  [Int32]$CycleStart = $NewFilename.LastIndexOf("(")
  if ($CycleStart -gt -1) {
    [Int32]$CycleEnd = $NewFilename.LastIndexOf(")")
    $NewCyclename = $NewFilename
    $NewFilename = $NewFilename.Substring(0, $CycleStart) + $NewFilename.Substring($CycleEnd + 1)
  }

  $Cyclename.Value = $NewCyclename
  return $NewFilename
} # Strip-Cycle


function Is-Numeric {
  <#
    .SYNOPSIS
      Check if supplied string is a numeric
    .PARAMETER InStr
      [String] Input String
    .OUTPUTS
      [Boolean] True if input string is a numeric, otherwise false
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Str
  )

  [Int32]$x = 0
  return [Int32]::TryParse($Str, [ref]$x)
} # Is-Numeric


function Jump {
  <#
    .SYNOPSIS
      ECL equivalent: @JUMP
    .DESCRIPTION
      The JUMP statement advances control to the specified labeled statement in the runstream.
      Parameter Value can either be a label name or an integer value between 1-999999. 
      Note: JUMP "4" would mean; jump to the 4th statement from the current one.
            So 3 statements will be skipped, and the 4th will be executed.
    .PARAMETER Value
      [String] Either a label name or an integer value between 1-999999.               
    .EXAMPLE
      Jump "4"
      Jump "TESTLABEL"
  #>

  param (
    [String]$Value
  )

  if (Process-Skip "JUMP: $Value") {
    return
  }
  Check-FinishStatement

  Write-JobLog "JUMP: $Value" ([LoggingSeverity]::Info)

  if (Is-Numeric $Value) {
    if (($Value -lt 1) -or ($Value -gt 999999)) {
      Abort "Numeric JUMP value must be between 1-999999: $Value"
    }

    $global:JumpCount  = [Int32]$Value
    $global:JumpLabel = ""
  } else {
    $global:JumpCount  = 0
    $global:JumpLabel = $Value
  }
} # Jump


function Asy-Label {
  <#
    .SYNOPSIS
      ECL equivalent: @<LABEL>
    . DESCRIPTION
      Handles label statement.
    .PARAMETER Label
      [String] name of the label to handle.
  #>

  param (
    [String]$Label
  )

  [String]$Statement = "LABEL: $Label"
  $Label = $Label.ToUpperInvariant()

  if ($Label -eq $global:RestartLabel) {
    $global:RestartLabelVisited = $true
  }

  Skip-Statement

  if (Check-Jump) {
    if ($Label -eq $global:JumpLabel) {
      $global:JumpLabel = ""
    }

    if (Check-Jump) {
      Write-JobLog "Skipped $Statement" ([LoggingSeverity]::Info)
      return
    }

    if ($global:Rcw) {
      $global:Rcw = $false
      return
    }
  }

  Write-JobLog $Statement ([LoggingSeverity]::Info)
} # Asy-Label


function Process-Skip {
  <#
    .SYNOPSIS
      Processes statement skipping.
    .PARAMETER Statement
      [String] Statement
    .OUTPUTS
      [Boolean] True or false whether the statement must be skipped or not.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Statement
  )

  [Boolean]$Skip = $false

  Skip-Statement

  if (Check-Jump) {
    $Skip = $true
  } elseif ($global:Rcw) {
    $global:Rcw = $false
    $Skip = $true
  } elseif (($global:InSsg -gt 0) -and ($global:SsgOptionB)) {
    $Skip = $true
  }

  if ($Skip) {
    Write-JobLog "Skipped $Statement" ([LoggingSeverity]::Info)
    return $true
  } else {
    return $false
  }
} # Process-Skip


function Skip-Statement {
  <#
    .SYNOPSIS
      Skips a statement and decreases the skip count when a JUMP statement is active.
      When zero, the JUMP statement is finished.
  #>

  if ($global:JumpCount -gt 0) {
    $global:JumpCount--
  }
} # Skip-Statement


function Check-Jump {
  <#
    .SYNOPSIS
      Checks whether a JUMP statement is in progress.
    .OUTPUTS
      [Boolean] True or false whether a JUMP statement is in progress.
  #>

  if (($global:JumpLabel -eq "") -and ($global:JumpCount -eq 0)) {
    return $false
  } else {
    return $true
  }
} # Check-Jump


function Setc {
  <#
    .SYNOPSIS
      ECL equivalent: @SETC
    .DESCRIPTION
      The @SETC statement stores values in the condition word.
    .PARAMETER Options
      [String] Options, comma separated.
    .PARAMETER Set
      [String] Value to store in the condition word. 
  #>

  param (
    [String]$Options,
    [String]$Set
  )

  [String]$Value    = ""
  [String]$Region   = ""
  [Int32]$Section   = 0
  [String]$Operator = ""
  [Int32]$SlashPos  = -1

  if (Process-Skip "SETC [$($Options)]: $Set") {
    return
  }

  Check-FinishStatement

  $Region = $Region.ToUpperInvariant()
  Write-Joblog "SETC: $Set" ([LoggingSeverity]::Info)
  Write-Joblog "SETC Options: $Options" ([LoggingSeverity]::Info)

  [SetcOptions]$SetcOptions = Parse-Options $Options ([SetcOptions])

  if (($SetcOptions -eq [SetcOptions]::None) -or 
      ($SetcOptions.HasFlag([SetcOptions]::A))) {
    # Clear bit 5 of the run condition word
    $global:RcwBits[5] = 0
  } elseif ($SetcOptions.HasFlag([SetcOptions]::I)) {
    # Set bit 5 of the run condition word
    $global:RcwBits[5] = 1
  } else {
    Add-Warning "Invalid options: $Options" 
  }

  $SlashPos = $Set.IndexOf("/")
  if ($SlashPos -gt 0) {
    # Check for operators
    [String]$Op = $Set.Substring(0, $SlashPos)
    if (($Op -eq "AND") -or
        ($OP -eq "OR") -or
        ($OP -eq "XOR")) {
      $Operator = $Op
      $Set = $Set.Substring($SlashPos + 1)
    }

    $SlashPos = $Set.IndexOf("/")
    if ($SlashPos -gt 0) {
      if ($Set.Length -gt $SlashPos + 2) {
        $Value   = $Set.Substring(0, $SlashPos)
        $Region  = $Set.Substring($SlashPos + 1, 1)
        $Section = $Set.Substring($SlashPos + 2, 1)
      } else {
        Abort "Invalid SETC statement, please check."
      }
    } else {
      $Value   = $Set
      $Region  = "T"
      $Section = 2
    }
  } else {
    $Value   = $Set
    $Region  = "T"
    $Section = 2
  }

  switch ($Region) {
    "T" {
      Set-ThirdWord $Section $Value $Operator
      break
    }

    "S" {
      Set-SixthWord $Section $Value $Operator
      break
    }

    default {
      Abort "Invalid region: $Region"
      break
    }
  }

  # Check bit 5 of the run condition word
  if ($global:RcwBits[5] -eq 0) {
    $global:SetcA = $true
  } else {
    $global:SetcA = $false
  }
} # Setc


function Set-ThirdWord {
  <#
    .SYNOPSIS
      Sets the appropriate bits, represented by the number at the correct position of the bitsequence.
      This will be applied for regions T1, T2 and T3 of the run condition word.
    .PARAMETER Section
      [Int32] Section number of the run condition word.
    .PARAMETER Value
      [String] Value to set.
    .PARAMETER Operator
      [String] Operator to use.
  #>

  param (
    [Int32]$Section,
    [String]$Value,
    [String]$Operator
  )

  [String]$BitSequence = ""
  [String]$BitRcw      = ""
  [Int32]$Offset       = 0
  [Boolean]$Set        = $false

  # Value can have up to 4 digits. If its less, add zero's in front of it
  if ($Value.Length -gt 4) {
    Abort "Value may not exceed 4 digits."
  }

  switch ($Value.Length) {
    1 {
      $Value = "000" + $Value
      break
    }
    2 {
      $Value = "00" + $Value
      break
    }
    3 {
      $Value = "0" + $Value
      break
    }
  }

  for ([Int32]$I = 0; $I -lt $Value.Length; $I++) {
    $BitSequence += ConvertTo-Bit($Value.Substring($I, 1))
  }

  switch ($Section) {
    1 {
      $Offset = 0
      break
    }

    2 {
      $Offset = 12
      break
    }

    3 {
      $Offset = 24
      break
    }

    default {
      Abort "Subportion $Section not allowed. Value must be in range 1-3."
      break
    }
  }

  if ($Operator -ne "") {
    [String]$BitRcw = Get-CurrentRcw ("S" + $Section)

    for ([Int32]$I = 0; $I -lt $BitSequence.Length; $I++) {
      if ($Operator -eq "AND") {
        $Set = $false
        if (($BitRcw.Substring($I, 1) -eq "1") -and ($BitSequence.Substring($I, 1) -eq "1")) {
          $Set = $true
        }
      } elseif ($Operator -eq "OR") {
        $Set = $false
        if (($BitRcw.Substring($I, 1) -eq "1") -or ($BitSequence.Substring($I, 1) -eq "1")) {
          $Set = $true
        }
      } elseif ($Operator -eq "XOR") {
        $Set = $true
        if ($BitRcw.Substring($I, 1) -eq $BitSequence.Substring($I, 1)) {
          $Set = $false
        }
      }

      if ($Set) {
        $global:RcwBits[$I + $Offset] = 1
      } else {
        $global:RcwBits[$I + $Offset] = 0
      }
    }
  } else {
    for ([Int32]$I = 0; $I -lt $BitSequence.Length; $I++) {
      $global:RcwBits[$I + $Offset] = [Int32]$BitSequence.Substring($I, 1)
    }
  }
} # Set-ThirdWord


function Set-SixthWord {
  <#
    .SYNOPSIS
      Sets the appropriate bits, represented by the number at the correct position of the bitsequence.
      This will be applied for regions S3, S4, S5 and S6 of the run condition word.
    .PARAMETER Section
      [Int32] Section number of the run condition word.
    .PARAMETER Value
      [String] Value to set.
    .PARAMETER Operator
      [String] Operator to use.
  #>

  param (
    [Int32]$Section,
    [String]$Value,
    [String]$Operator
  )

  [String]$BitSequence = ""
  [String]$BitRcw      = ""
  [Int32]$Offset       = 0
  [Boolean]$Set        = $false


  # Value can have up 2 digits. If it's less, add zero's in front of it.
  if ($Value.Length -gt 2) {
    Abort "Value may not exceed 2 digits."
  }

  switch ($Value.Length) {
    1 {
      $Value = "0" + $Value
      break
    }
  }

  for ([Int32]$I = 0; $I -lt $Value.Length; $I++) {
    $BitSequence += ConvertTo-Bit($Value.Substring($I, 1))
  }

  switch ($Section) {
    1 {
      $Offset = 0
      break
    }
    2 {
      $Offset = 6
      break
    }
    3 {
      $Offset = 12
      break
    }
    4 {
      $Offset = 18
      break
    }
    5 {
      $Offset = 24
      break
    }
    6 {
      $Offset = 30
      break
    }
    default {
      Abort "Subportion $Section not allowed. Value must be in range 1-6."
      break
    }
  }

  if ($Operator -ne "") {
    [String]$BitRcw = Get-CurrentRcw ("S" + $Section)

    for ([Int32]$I = 0; $I -lt $BitSequence.Length; $I++) {
      if ($Operator -eq "AND") {
        $Set = $false
        if (($BitRcw.Substring($I, 1) -eq "1") -and ($BitSequence.Substring($I, 1) -eq "1")) {
          $Set = $true
        }
      } elseif ($Operator -eq "OR") {
        $Set = $false
        if (($BitRcw.Substring($I, 1) -eq "1") -or ($BitSequence.Substring($I, 1) -eq "1")) {
          $Set = $true
        }
      } elseif ($Operator -eq "XOR") {
        $Set = $true
        if ($BitRcw.Substring($I, 1) -eq $BitSequence.Substring($I, 1)) {
          $Set = $false
        }
      }

      if ($Set) {
        $global:RcwBits[$I + $Offset] = 1
      } else {
        $global:RcwBits[$I + $Offset] = 0
      }
    }
  } else {
    for ([Int32]$I = 0; $I -lt $BitSequence.Length; $I++) {
      $global:RcwBits[$I + $Offset] = [Int32]$BitSequence.Substring($I, 1)
    }
  }
} # Set-SixthWord


function ConvertTo-Bit {
  <#
    .SYNOPSIS
      Converts a string containing a number from 0-7 to a bitsequence.
      Note: "000" is returned when the number to convert is 0, or if it exceeds 7.
    .PARAMETER Number
      [String] String containing the number to convert.
    .OUTPUTS
      [String] Converted bitsequence as string.
  #>

  param (
    [String]$Number
  )

  [String]$Bits = "000"

  switch ($Number) {
    "0" {
      $Bits = "000"
      break
    }
    "1" {
      $Bits = "001"
      break
    }
    "2" {
      $Bits = "010"
      break
    }
    "3" {
      $Bits = "011"
      break
    }
    "4" {
      $Bits = "100"
      break
    }
    "5" {
      $Bits = "101"
      break
    }
    "6" {
      $Bits = "110"
      break
    }
    "7" {
      $Bits = "111"
      break
    }
    default {
      $Bits = "000"
      break
    }
  }

  return $Bits
} # ConvertTo-Bit


function ConvertTo-Number {
  <#
    .SYNOPSIS
      Converts a string containing a bitsequence from 000-111 to a number.
    .PARAMETER Number
      [String] String containing the bitsequence to convert.
    .OUTPUTS
      [String] Converted number as string.
  #>

  param (
    [String]$Bits
  )

  [String]$Number = ""
  switch ($Bits) {
    "000" {
      $Number = "0"
      break
    }

    "001" {
      $Number = "1"
      break
    }

    "010" {
      $Number = "2"
      break
    }

    "011" {
      $Number = "3"
      break
    }

    "100" {
      $Number = "4"
      break
    }

    "101" {
      $Number = "5"
      break
    }

    "110" {
      $Number = "6"
      break
    }

    "111" {
      $Number = "7"
      break
    }

    default {
      Abort "ConvertTo-Number: Bitsequence must be between 000-111: $Bits"
      break
    }
  }

  return $Number
} # ConvertTo-Number


function Get-CurrentRcw {
  <#
    .SYNOPSIS
      Returns a string containing the bitsequence of the provided region from the run condition word.
    .PARAMETER Region
      [String] Region to return the bitsequence of.
    .OUTPUTS
      [String] Bitsequence as string.
  #>

  param (
    [String]$Region
  )

  [Int32]$Min = 0
  [Int32]$Max = 0
  [String]$Bits = ""

  switch ($Region) {
    "W" {
      $Min = 0
      $Max = 35
      break
    }

    "H1" {
      $Min = 0
      $Max = 17
      break
    }

    "H2" {
      $Min = 18
      $Max = 35
      break
    }

    "T1" {
      $Min = 0
      $Max = 11
      break
    }

    "T2" {
      $Min = 12
      $Max = 23
      break
    }

    "T3" {
      $Min = 24
      $Max = 35
      break
    }

    "S1" {
      $Min = 0
      $Max = 5
      break
    }

    "S2" {
      $Min = 6
      $Max = 11
      break
    }

    "S3" {
      $Min = 12
      $Max = 17
      break
    }

    "S4" {
      $Min = 18
      $Max = 23
      break
    }

    "S5" {
      $Min = 24
      $Max = 29
      break
    }

    "S6" {
      $Min = 30
      $Max = 35
      break
    }

    default {
      Abort "Get-CurrentRcw: Region invalid or not supported: $Region"
      break
    }
  }

  # Make a string from the run condition word between index $Min and $Max
  for ([Int32]$I = $Min; $I -le $Max; $I++) {
    $Bits += $global:RcwBits[$I]
  }

  return $Bits
} # Get-CurrentRcw


function Test {
  <#
    .SYNOPSIS
      ECL equivalent: @TEST
    .DESCRIPTION
      Tests the run condition word.
      The following test conditions are supported: TE, TN E,TG ,TLE ,TEP and TOP.
    .PARAMETER Line
      [String] Line containing the test.
  #>

  param (
    [String]$Line
  )

  if (Process-Skip "TEST: $Line") {
    return
  }

  Check-FinishStatement

  Write-Joblog "TEST: $Line" ([LoggingSeverity]::Info)
  $Line = $Line.ToUpperInvariant()

  [String]$BitRcw      = ""
  [String]$OctalRcw    = ""
  [String]$Test        = ""
  [String]$Condition   = ""
  [String]$Value       = ""
  [String]$Region      = ""
  [String]$BitSequence = ""
  [Boolean]$Result     = $false

  # Display the run condition word
  if ($Line -eq "O") {  
    $BitRcw = Get-CurrentRcw "W"

    # Convert the run condition array to octal numbers
    for ([Int32]$I = 0; $I -lt $BitRcw.Length; $I += 3) {
      if (($I % 6) - 1 -eq 0) {
        $OctalRcw += (ConvertTo-Number $BitRcw.Substring($I, 3))
      }
    }

    Write-JobLog "|  T1 |  T2 |  T3 |" ([LoggingSeverity]::Info)
    Write-JobLog "|S1|S2|S3|S4|S5|S6|" ([LoggingSeverity]::Info)
    Write-JobLog $OctalRcw ([LoggingSeverity]::Info)

    return
  }

  [Int32]$Sections = Get-NrOfSections $Line ","
  for ([Int32]$I = 0; $I -lt $Sections; $I++) {
    $OctalRcw = ""

    # Format te/6/t2,te/6/t2 or te/6/t2
    if ($Line.IndexOf(",") -gt 0) {
      $Test = $Line.Substring(0, $Line.IndexOf(","))
    } else {
      $Test = $Line
    }

    # One test condition
    $Condition = $Test.Substring(0, $Test.IndexOf("/"))
    $Test = $Test.Substring($Test.IndexOf("/") + 1)

    if ($Test.IndexOf("/") -eq -1) {
      $Value = $Test
      $Region = ""
    } else {
      $Value = $Test.Substring(0, $Test.IndexOf("/"))
      $Test = $Test.Substring($Test.IndexOf("/") + 1)
      $Region = $Test
    }

    # If no region is specified then T2 region is assumed
    if ($Region -eq "") {
      $Region = "T2"
    }

    $BitRcw = Get-CurrentRcw $Region

    # Convert the run condition array to octal numbers to compare
    for ([Int32]$J = 0; $J -lt $BitRcw.Length; $J += 3) {
      $OctalRcw += (ConvertTo-Number $BitRcw.Substring($J, 3))
    }

    $BitSequence = Get-BitSequence $Region ([Ref]$Value)

    switch ($Condition) {
      "TE" {
        $Result = [Int32]$OctalRcw -eq [Int32]$Value  # Test for equal
        break
      }

      "TNE" {
        $Result = [Int32]$OctalRcw -ne [Int32]$Value  # Test for not equal
        break
      }

      "TG" {
        $Result = [Int32]$OctalRcw -gt [Int32]$Value  # Test for greater than
        break
      }

      "TLE" {
        $Result = [Int32]$OctalRcw -le [Int32]$Value  # Test for less or equal
        break
      }

      "TOP" {
        $Result = $true                               # Test for odd parity

        for ([Int32]$J = 0; $J -lt $BitSequence.Length; $J++) {
          if (($BitSequence.Substring($J, 1) -eq "1") -and ($BitRcw.Substring($J, 1) -eq "0")) {
            $Result = $false
            break
          }
        }
        break
      }

      "TEP" {
        $Result = $true                               # Test for even parity

        for ([Int32]$J = 0; $J -lt $BitSequence.Length; $J++) {
          if (($BitSequence.Substring($J, 1) -eq "1") -and ($BitRcw.Substring($J, 1) -eq "1")) {
            $Result = $false
            break
          }
        }
        break
      }

      default {
        $Result = $false
        break
      }
    }

    $global:Rcw = $Result
    if ($global:Rcw) {
      return
    }

    if ($Line.IndexOf(",") -gt 0) {
      $Line = $line.Substring($Line.IndexOf(",") + 1)
    } else {
      $Line = ""
    }
  }
} # Test


function Get-NrOfSections {
  <#
    .SYNOPSIS
      Returns the number of sections delimited by the provided delimiter.
    .PARAMETER Line
      [String] Line to check.
    .PARAMETER Delimiter
      [String] Delimiter to check for.
    .OUTPUTS
      [Int32] Number of delimited sections.
  #>

  param (
    [String]$Line,
    [String]$Delimiter
  )

  if ($Line -eq "") {
    return 0
  }

  [Int32]$Count = 1
  [Int32]$Pos   = $Line.IndexOf($Delimiter)

  while ($Pos -gt -1) {
    $Count++

    # Get the remaining section
    $Line = $Line.Substring($Pos + 1)
    $Pos = $Line.IndexOf($Delimiter)
  }

  return $Count
} # Get-NrOfSections


function Get-BitSequence {
  <#
    .SYNOPSIS
      Returns the bits depending on Third or Sixth portion and octal value.
      If needed, the octal value will be padded with zero's.
    .PARAMETER $Region
      [String] $Region of run condition word.
    .PARAMETER $Value
      [Ref] Octal value as String.
    .OUTPUTS
      [String] Bit sequence.
  #>

  param (
    [String]$Region,
    [Ref]$Value
  )

  [String]$BitSequence = ""
  $Region = $Region.ToUpperInvariant()

  if ($Region.Substring(0,1) -eq "S") {
    # Region S
    switch ($Value.Value.Length) {
      1 {
        $Value.Value = "0" + $Value.Value
        break
      }
      default {
        Abort "Get-BitSequence: Value must be in range of 1-2 digits."
        break
      }
    }
  } else {
    # Region W, H or T
    switch ($Value.Value.Length) {  
      1 {
        $Value.Value = "000" + $Value.Value
        break
      }
      2 {
        $Value.Value = "00" + $Value.Value
        break
      }
      3 {
        $Value.Value = "0" + $Value.Value
        break
      }
      default {
         Abort "Get-BitSequence: Value must be in range of 1-4 digits."
         break
      }
    }
  }

  for ([Int32]$I = 0; $I -lt $Value.Value.Length; $I++) {
    $BitSequence += ConvertTo-Bit $Value.Value.Substring($I, 1)
  }

  return $BitSequence
} # Get-BitSequence


function Check-AddFileName {
  <#
    .SYNOPSIS
      Change filename on an @ADD or *ADD SGS statement to a fully qualified path
    .PARAMETER AddFile
      [String] AddFile
    .OUTPUTS
      Full qualified filename
  #>

  param (
    [Parameter(Mandatory=$true)][String]$AddFile
  )

  $AddFile = $AddFile.ToUpperInvariant()

  if ($AddFile.EndsWith(".")) {
    $AddFile = $AddFile.Substring(0, $AddFile.Length - 1)  # Strip dot at end
  }

  [String]$Filename = Get-AssignedFile $AddFile 
  if (!(Check-FileControlError 0)) {
    if ($AddFile.StartsWith("TPF$.")) {
      $Filename = (Add-BackSlash $global:TempFolder) +  $AddFile.SubString(5)
    } else {
      $Filename = Check-ProgramFile $AddFile
      if ((Check-FileControlError 53)) {
        $Filename = Get-JobFileName $AddFile
      }
    }
  }

  return $Filename
} # Check-AddFileName


function Add-ParameterFile {
  <#
    .SYNOPSIS
      ECL equivalent: @ADD 
    .DESCRIPTION
      The @ADD statement lets you include canned runstreams or data for repetitive functions.
      This routine should only be called for parameter files, script files will be dot sourced
    .PARAMETER AddFile
      [String] AddFile
  #>

  param (
    [Parameter(Mandatory=$true)][String]$AddFile
  )

  if (Process-Skip "ADD: $AddFile") {
    return
  }

  # Don't call Check-FinishStatement here, just read the contents of the file

  Write-Joblog "ADD: $AddFile" ([LoggingSeverity]::Info)
  [String]$Filename = Check-AddFileName $AddFile
  [String]$Cyclename = ""
  if (!(Find-AssignedFileInList $Filename)) {
    # Check if the file exists as a normal file
    if (!(File-Exists $Filename)) {
      Abort "File not found.`r`nFileName: $Filename`r`nCycleName: $CycleName nor as non file cycle" 
    }
  } else {
    $Filename = Get-GobalFullFilename
  }

  # Read the file line by line and use Dataline to translate the parameters in the file
  [String]$Line = ""
  [Boolean]$Append = $false
  [Object]$AddFileStream = Open-TextFile $Filename $global:Const_SharedRead $global:Const_FileEnc_Autodetect $Append

  while (-not ($AddFileStream.EndOfFile)) {
    $Line = $AddFileStream.ReadLine()
    Write-JobLog ($Filename + ": " + $Line) ([LoggingSeverity]::Info)
    DataLineOrNoStatement $Line
  }

  [Boolean]$CloseResult = Close-TextFile $AddFileStream
} # Add-ParameterFile


function Asg {
  <#
    .SYNOPSIS
      ECL equivalent: @ASG / @@ASG
    .DESCRIPTION
      The @ASG statement is used to name a file, state its I/O facility requirements, and assign 
      it to the requesting run under the given external file name.
    .PARAMETER Options
      [String] 
    .PARAMETER AsgFile
      [String] AsgFile
  #>

  param (
    [String]$Options,
    [Parameter(Mandatory=$true)][String]$AsgFile
  )

  if (Process-Skip "ASG [$($Options)]: $AsgFile") {
    return
  }

  Check-FinishStatement

  Write-Joblog "ASG: $AsgFile" ([LoggingSeverity]::Info)
  Write-Joblog "ASG Options: $Options" ([LoggingSeverity]::Info)
  $AsgFile = $AsgFile.ToUpperInvariant().Trim()

  Replace-Asterisks ([Ref]$AsgFile)
  $AsgFile = $AsgFile.Replace("/", "\")

  [String]$Filename = $AsgFile
  [String]$File     = ""
  [String]$UseName  = ""
  [Boolean]$Tasg    = $false

  [AsgOptions]$AsgOptions = Parse-Options $Options ([AsgOptions])

  if ($Filename.EndsWith(".")) {
    $Filename = $Filename.Substring(0, $Filename.Length - 1)  # Strip dot at end
  }  

  if ($Filename.Contains(".")) {
    Abort "File extensions are not allowed."
  }

  if ($Filename -eq "") {
    Abort "No filename specified."
  }

  if ($AsgOptions.HasFlag([AsgOptions]::P)) {
    Write-JobLog "Ignored option P." ([LoggingSeverity]::Info)
  }

  if ($AsgOptions.HasFlag([AsgOptions]::Q)) {
    $Tasg = $true
  }

  if ($Tasg) {
    if ($AsgOptions.HasFlag([AsgOptions]::C)) {
      Abort "Option C found for TASG (Option Q). This is not valid."
    }

    if ($AsgOptions.HasFlag([AsgOptions]::R)) {
      Write-JobLog "Option R found for TASG (Option Q). Option R be ignored." ([LoggingSeverity]::Info)
    }

    if ($AsgOptions.HasFlag([AsgOptions]::T)) {
      Abort "Option T found for TASG (Option Q). This is not valid."
    }

    if ($AsgOptions.HasFlag([AsgOptions]::U)) {
      Abort "Option U found for TASG (Option Q). This is not valid."
    }

    $global:RcwBits[35] = 0
    $global:RcwBits[34] = 0
  }

  if ($AsgOptions.HasFlag([AsgOptions]::F)) {
    if (!$Tasg) {
      Write-JobLog "Option F found without option Q. Option F will be ignored." ([LoggingSeverity]::Info)
      Remove-Flag ([AsgOptions]::F) ([Ref]$AsgOptions)
    } else {
      $global:RcwBits[33] = 0
    }
  }

  Set-FileControlError 0

  $File = $Filename
  $File = Check-UseName $File 

  if ($global:UseFound) {
    $UseName = $Filename
  } else {
    $UseName = ""
  }

  $Filename = $File

  if ($AsgOptions.HasFlag([AsgOptions]::T)) {
    $Filename = Process-CreateTempFile $Filename $AsgFile ($AsgOptions.HasFlag([AsgOptions]::I))
  } else {
    if ((!$AsgOptions.HasFlag([AsgOptions]::C)) -and (!$AsgOptions.HasFlag([AsgOptions]::D))) {

      $Filename = (Get-AssignedFile $Filename $true)
      if (!(Check-FileControlError 0)) {

        if (Check-FileControlError 502) {
          Write-Joblog "File only known as plus cycle, Ignored" ([LoggingSeverity]::Info)
          return
        }

        $Filename = (Check-ProgramFile $Filename)
        if (Check-FileControlError 501) {
          Write-JobLog "Assign of program file, Ignored." ([LoggingSeverity]::Info)
          return
        }

        if ($AsgFile.Substring(0,1) -eq "\") {
          $Filename = ((Add-BackSlash $global:JobPath) + (Add-BackSlash $global:ImpliedQual)) + $AsgFile
        } else {
          $Filename = (Add-BackSlash $global:JobPath) + $AsgFile
        }

        if (Folder-Exists $Filename) {
          [Int32]$Pos = $Filename.LastIndexOfAny("\")
          $File = $Filename.Substring(0, $Pos)

          if ((Check-FileControlError 0) -and 
              ((Add-BackSlash $File.ToUpperInvariant()) -eq (Add-BackSlash $global:JobPath.ToUpperInvariant()))) {
            # It is a folder in JobPath
            Write-JobLog "Assign of file containing jobs, Ignored" ([LoggingSeverity]::Info)
          }

          return
        }

        if ($Tasg) {
          # Set bit 34 & 35 of the run condition word
          $global:RcwBits[35] = 1
          $global:RcwBits[34] = 1
          Write-JobLog "File not found.`r`nFileName: $FileName" ([LoggingSeverity]::Info)
          return
        } else {
          Abort "File not found.`r`nFileName: $FileName"
        }
      }

      # Check whether the file has already been assigned or not
      for ([Int32]$I = 0; $I -lt ($global:FilesList.Count); $I++) {
        if ((($global:FilesList[$I].Copyname -eq $Filename) -or
             (($global:FilesList[$I].FileHandle -ne $null) -and ($global:FilesList[$I].FileHandle.FullName -eq $Filename))) -and
             ($global:FilesList[$I].IsAssigned)) {
          Write-JobLog "File is already assigned. Ignored." ([LoggingSeverity]::Info)
          return
        }
      }
    }
  }

  if (!$AsgOptions.HasFlag([AsgOptions]::T)) {
    #[String]$CycleName = ""
    Assign-Options $FileName $UseName $AsgOptions $AsgFile
    for ([Int32]$I = 0; $I -lt ($global:UseNamesList.Count); $I++) {
      if ($global:UseNamesList[$I].FileObject -eq $global:FileObject) {
        if ($global:UseNamesList[$I].FileName -ne $Filename) {
          $global:UseNamesList[$I].Filename = $Filename
        }
      }
    }
  }
} # Asg


function Assign-Options {
  <#
    .SYNOPSIS
      Assigns a file according to the assign options.
    .DESCRIPTION
      This function is being called by the Asg statement.
    .PARAMETER Filename
      [String] Name of the file to assign.
    .PARAMETER UseName
      [String] UseName of the file.
    .PARAMETER AsgOptions
      [AsgOptions] ASG options object.
    .PARAMETER AsgFile
	  [String] The filename as used in the Asg statement without windows path
  #>

  param (
    [String]$Filename,
    [String]$UseName,
    [AsgOptions]$AsgOptions,
	[String]$AsgFile
  )

  [String]$Message  = ""
  [Boolean]$Tasg    = $false
  [Boolean]$OptionZ = $AsgOptions.HasFlag([AsgOptions]::Z)
  [Boolean]$OptionI = $AsgOptions.HasFlag([AsgOptions]::I)
  [Boolean]$OptionR = $AsgOptions.HasFlag([AsgOptions]::R)

  
  if ($AsgOptions.HasFlag([AsgOptions]::Q)) {
    $Tasg = $true
  }

  # Add option A when option X is used
  if (($AsgOptions.HasFlag([AsgOptions]::X)) -and (!$AsgOptions.HasFlag([AsgOptions]::A))) {
    Add-Flag ([AsgOptions]::A) ([Ref]$AsgOptions)
  }

  if ($AsgOptions.HasFlag([AsgOptions]::A)) {
    [Boolean]$FileExists = (File-Exists $Filename) 
    if (-not $FileExists) {
      $Message = "File [$($Filename)] does not exist."
      if ($Tasg) {
        $global:RcwBits[35] = 1
        $global:RcwBits[33] = 1
        Add-WarningMsg $Message
      } else {
        Abort $Message
      }
    }

    if (($AsgOptions.HasFlag([AsgOptions]::X)) -and (Get-ReadOnly $Filename $FileExists)) {
      Remove-Flag ([AsgOptions]::X) ([Ref]$AsgOptions)
      $Message = "File [$($Filename)] is Read Only. Option X is ignored."
      Write-JobLog $Message ([LoggingSeverity]::Info)
    }

    if ($AsgOptions.HasFlag([AsgOptions]::X)) {
      if ($AsgOptions.HasFlag([AsgOptions]::D)) {
        # Only A,X,D
          Assign-ExclusiveFile $Filename $true $false $AsgFile $OptionZ $OptionI $AsgOptions $FileExists
      } elseif ($AsgOptions.HasFlag([AsgOptions]::K)) {
        # Only A,X,K
          Assign-ExclusiveFile $Filename $true $true $AsgFile $OptionZ $OptionI $AsgOptions $FileExists
      } else {
        # Only A,X
        Assign-ExclusiveFile $Filename $false $false $AsgFile $OptionZ $OptionI $AsgOptions $FileExists
      }
    } else {
      if ($AsgOptions.HasFlag([AsgOptions]::D)) {
        # Only A,D
        Assign-ReadWriteFile $Filename $true $false $AsgFile $OptionZ $OptionI $OptionR $AsgOptions $FileExists
      } elseif ($AsgOptions.HasFlag([AsgOptions]::K)) {
        # Only A,K
        Assign-ReadWriteFile $Filename $true $true $AsgFile $OptionZ $OptionI $OptionR $AsgOptions $FileExists
      } else {
        # Only A
        Assign-ReadWriteFile $Filename $false $false $AsgFile $OptionZ $OptionI $OptionR $AsgOptions $FileExists
      }
    }

    if (Check-FileControlError 70) {
      # File in use
      if ($Tasg) {
        $global:RcwBits[34] = 1
      }

      $Message = "File [$($Filename)] in use."
      Write-JobLog $Message ([LoggingSeverity]::Info)
      return
    } elseif (Check-FileControlError 71) {
      # File does not exist
      if ($Tasg) {
        $global:RcwBits[35] = 1
      }

      $Message = "File [$($Filename)] does not exist."
      Write-JobLog $Message ([LoggingSeverity]::Info)
      return
    }
  } else {
    # Conditional with or without ReadOnly
    if ($AsgOptions.HasFlag([AsgOptions]::C)) {
      #Lock-Lockfile $Filename
      $Filename = Process-ConditionalFile $Filename 
      if (!(Check-FileControlError 0)) {
        Abort $global:FileControlErrMsg
      }

      #$Filename = Strip-Cycle $Filename $Cyclename

      if ($AsgOptions.HasFlag([AsgOptions]::R)) {
        # Only C,R
        Assign-ConditionalFile $Filename $true $AsgFile $OptionI $AsgOptions
      } else {
        # Only C
        Assign-ConditionalFile $Filename $false $AsgFile $OptionI $AsgOptions
      }
      #Free-LockFile
    } else {
      # Unconditional with or without ReadOnly
      if ($AsgOptions.HasFlag([AsgOptions]::U)) {
        #Lock-LockFile $Filename
        $Filename = Process-ConditionalFile $Filename 

        if (!(Check-FileControlError 0)) {
          Abort $global:FileControlErrMsg
        }

        #$Filename = Strip-Cycle $Filename $Cyclename

        if ($AsgOptions.HasFlag([AsgOptions]::R)) {
          # Only U,R
          Assign-UnconditionalFile $Filename $true $AsgFile $OptionI $AsgOptions
        } else {
          # Only U
          Assign-UnconditionalFile $Filename $false $AsgFile $OptionI $AsgOptions
        }

        #Free-LockFile
      } else {
        # No A, X, C or U option
        [Boolean]$FileExists = (File-Exists $Filename) 
        if ($FileExists) {
          if ($AsgOptions.HasFlag([AsgOptions]::D)) {
            # Only D
            Assign-ReadWriteFile $Filename $true $false $AsgFile $OptionZ $OptionI $OptionR $AsgOptions $true
            
            if (!(Check-FileControlError 0)) {
              Write-JobLog "File not assigned." ([LoggingSeverity]::Info)
            }
          } else {
            if ($AsgOptions.HasFlag([AsgOptions]::K)) {
              # Only K
              Assign-ReadWriteFile $Filename $true $true $AsgFile $OptionZ $OptionI $OptionR $AsgOptions $true
              
              if (!(Check-FileControlError 0)) {
                Write-JobLog "File not assigned." ([LoggingSeverity]::Info)
              }
            } else {
              # None
              Assign-ReadWriteFile $Filename $false $false $AsgFile $OptionZ $OptionI $OptionR $AsgOptions $true

              if (!(Check-FileControlError 0)) {
                Write-JobLog "File not assigned." ([LoggingSeverity]::Info)
              }
            }
          }

          if (Check-FileControlError 70) {
            # File in use and Z option
            if ($Tasg) {
              $global:RcwBits[34] = 1
            }

            $Message = "File [$($Filename)] in use."
            Write-JobLog $Message ([LoggingSeverity]::Info)
            return
          } elseif (Check-FileControlError 71) {
            # File does not exist
            if ($Tasg) {
              $global:RcwBits[35] = 1
            }

            $Message = "File [$($Filename)] does not exist."
            Write-JobLog $Message ([LoggingSeverity]::Info)
            return
          }
        } else {
          Create-TempFile $Filename $AsgFile $OptionI
        }
      }
    }
  }
} # Assign-Options


function Asy-Cat {
  <#
    .SYNOPSIS
      ECL equivalent @CAT
    .DESCRIPTION
      Catalogs a file in the master directory without assigning it to a run.
      @CAT is the same as @ASG,C followed by an @FREE. 
    .PARAMETER Options
      [String]
    .PARAMETER CatFile
      [String]
    .PARAMETER AbortOnFailure
      [Boolean] If $true the function will aborts in case of a failure, if $false a boolean 
      value is returned indicating either success ($true) or failure ($false).
    .OUTPUTS
      [Boolean] $true on success, $false on failure if AbortOnFailure = $true.
  #>

  param (
    [String]$Options,
    [Parameter(Mandatory=$true)][String]$CatFile,
    [Boolean]$AbortOnFailure=$true
  )

  if (Process-Skip "CAT [$($Options)]: $CatFile") {
    return $true
  }

  Check-FinishStatement

  Write-Joblog "CAT: $CatFile" ([LoggingSeverity]::Info)
  Write-Joblog "CAT Options: $Options" ([LoggingSeverity]::Info)
  $CatFile = $CatFile.ToUpperInvariant().Trim()

  [CatOptions]$CatOptions = Parse-Options $Options ([CatOptions])

  Replace-Asterisks ([Ref]$CatFile)

  # Catalog Data File
  [String]$Filename = Process-ConditionalFile $CatFile
  if (-not (Check-FileControlError 0)) {
    if ($AbortOnFailure) {
      Abort $global:FileControlErrMsg
    } else {
      Set-FileControlError 0
      return $false
    }
  }

  [Boolean]$Result = Create-EmptyFile $Filename

  if ($CatOptions.HasFlag([CatOptions]::R)) {
    if (-not (Get-ReadOnly $Filename $true)) {
      Set-ReadOnly $Filename
    }
  }

  #[String]$Cyclename = ""
  #$Filename = Strip-Cycle $Filename ([Ref]$Cyclename)

  if ($global:FileHandle -ne $null) {
    #Make sure we get the absolute cycle when catalogging a +1 
    $Filename = $global:FileHandle.FullName
  }
  if ($global:UseFound) {
    # note: use name was checked in Process-ConditionalFile
    for ([Int32]$I = 0; $I -lt $global:UseNamesList.Count; $I++) {
      if ($global:UseNamesList[$I].Usename -eq $CatFile) {
        $global:UseNamesList[$I].Filename = $Filename
        $global:UseNamesList[$I].FileObject = $global:FileObject
        #$global:UseNamesList[$I].Cyclename = $Cyclename
      }
    }
  }

  # set IsCataloged to $true for any matching assigned file item
  $FileName = Check-UseName $FileName
  foreach ($FileObject in $global:FilesList) {
    if (($FileObject.FileName -eq $FileName) -or 
        (($FileObject.FileHandle -ne $null) -and ($FileObject.FileHandle.FullName -eq $Filename))) {
      $FileObject.IsCataloged = $true
      break
    }
  }

  return $true
} # Asy-Cat


function Cycle {
  <#
    .SYNOPSIS
      ECL equivalent: @CYCLE.
    .DESCRIPTION
      Sets the maximum range of absolute F-cycle numbers to be retained for a cataloged file,
      or the maximum number of element cycles for a program file symbolic element.    
    .PARAMETER Filename
      [String] 
    .PARAMETER Number
      [String] Maximum number of cycles or empty string
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Filename,
    [String]$Number
  )

  if (Process-Skip "CYCLE $Filename $Number") {
    return
  }

  Check-FinishStatement

  Write-Joblog "CYCLE: $Filename $Number" ([LoggingSeverity]::Info)
  $Filename = $Filename.ToUpperInvariant().Trim()

  Replace-Asterisks ([Ref]$Filename)
  $Filename = Get-AssignedFile $Filename
  #[String]$Cyclename = ""
  if (-not (File-Exists $FileName)) {
    Write-JobLog "CycleFile $Filename does not exist." ([LoggingSeverity]::Error)
    return
  } else {
    #if (($global:FileObject -ne $null) -and ($global:FileObject.FileHandle -ne $null)) {
      # if this is a cycled file, we must reference it by its full name
    #  $Filename = $global:FileObject.FileHandle.FullName
    #} 
  }

  if ($Number -ne "") { 
    [Int32]$INumber = [Convert]::ToInt32($Number)
    $global:AmtFile.ChangeCycle($Filename, $INumber, 1) | Out-Null
    $global:ErrorCode = $global:AmtFile.ErrorCode 
    $global:ErrorDescription = $global:AmtFile.ErrorDescription
    Set-FileControlError $global:AmtFile.ErrorCode $global:ErrorDescription

    if (!(Check-FileControlError 0)) {
      Abort $global:FileControlErrMsg
    }

	if (($INumber -eq 0) -and ($global:FileObject -ne $null)) {
      $global:FilesList.Remove($global:FileObject) | Out-Null
	}
  } else {
    Add-WarningMsg "@CYCLE without number not implemented yet ($Filename)."
    # TODO: display file cycles
  }
} # Cycle


function Asy-Copy {
  <#
    .SYNOPSIS
      ECL equivalent: @COPY.
    .DESCRIPTION
      The @COPY statement is used to copy files and elements.
    .PARAMETER Options
      [String] Options
    .PARAMETER FileFrom
      [String] Input file or element to be copied.
    .PARAMETER FileTo
      [String] Output file or element into which the input file or element is to be copied.
    .PARAMETER AbortOnFailure
      [Boolean] If $true the function will aborts in case of a failure, if $false a boolean 
      value is returned indicating either success ($true) or failure ($false).
    .OUTPUTS
      [Boolean] $true on success, $false on failure if AbortOnFailure = $true.
  #>

  param (
    [String]$Options,
    [String]$FileFrom,
    [String]$FileTo,
    [Boolean]$AbortOnFailure=$true
  )

  if (-not (Check-FileControlError 0)) {
    Abort "Asy-Copy was called with a file error condition already set."
  }

  if (Process-Skip "COPY [$($Options)]: $FileFrom to $FileTo") {
    return $true
  }

  Check-FinishStatement

  Write-Joblog "COPY [$($Options)]: $FileFrom to $FileTo" ([LoggingSeverity]::Info)
  $FileFrom = $FileFrom.ToUpperInvariant().Trim()
  $FileTo = $FileTo.ToUpperInvariant().Trim()

  Replace-Asterisks ([Ref]$FileFrom)
  Replace-Asterisks ([Ref]$FileTo)

  [String]$Msg = ""
  [String]$File = ""
  [String]$EltFrom = ""
  [String]$EltTo = ""
  [CopyOptions]$CopyOptions = Parse-Options $Options ([CopyOptions])

  if ($FileFrom.StartsWith(".")) {
    # Elt
    $EltFrom = $FileFrom.Substring(1)
    $FileFrom = Add-BackSlash $global:TempFolder
    Check-FileName ([Ref]$FileFrom) ([Ref]$EltFrom)
  } else {
    Check-FileName ([Ref]$FileFrom) ([Ref]$EltFrom)

    if ($EltFrom -ne "") {
      $FileFrom = Get-ProgramFileName $FileFrom $EltFrom
      if (Check-FileControlError 53) {
        if (-not ($CopyOptions.HasFlag([CopyOptions]::C))) {
          $File = Get-FileName $FileFrom
          if ($AbortOnFailure) {
            Abort "Programfile $File does not exist."
          } else {
            $global:ErrorCode = 1
            Set-FileControlError 0
            return $false
          }
        } else {
          Set-FileControlError 0
        }
      }
    } else {
      $FileFrom = Get-AssignedFile $FileFrom
      if (Check-FileControlError 53) {
        if (-not ($CopyOptions.HasFlag([CopyOptions]::C))) {
          $File = Get-FileName $FileFrom
          if ($AbortOnFailure) {
            Abort "File $File not found."
          } else {
            $global:ErrorCode = 1
            Set-FileControlError 0
            return $false
          }
        } else {
          Set-FileControlError 0
        }
      }
    }
  }

  if (($FileTo -eq "") -or ($FileTo -eq "TPF$")) {
    $EltTo = $EltFrom
    $FileTo = $global:TempFolder
    if (($CopyOptions.HasFlag([CopyOptions]::A)) -or
        ($CopyOptions.HasFlag([CopyOptions]::O)) -or
        ($CopyOptions.HasFlag([CopyOptions]::R)) -or
        ($CopyOptions.HasFlag([CopyOptions]::S))) {
      Add-InformationMsg "Copying program file to temp - skipped"
      return $true
     }
  } else {
    if ($FileTo.StartsWith(".")) {
      # ELT
      $EltTo = $FileTo.Substring(1)
      $FileTo = $global:TempFolder
    } 
  }

  Check-FileName ([Ref]$FileTo) ([Ref]$EltTo)
  if (($EltTo -ne "") -or ($EltFrom.Contains("*")) -or ($EltFrom.Contains("?"))) {
    # When wildcards in EltFrom, FileTo must be a programfile
    $FileTo = Get-ProgramFileName $FileTo $EltTo
  } else {
    $FileTo = Get-AssignedFile $FileTo
  }

  if ($FileFrom -eq "") {
    $Msg = "No FromFile is specified."
    if ($CopyOptions.HasFlag([CopyOptions]::C)) {
      # Executive Control Language (ECL) and FURPUR Reference Manual says:
      # Use of the C option on any FURPUR command will prevent execution of ER ERR$ on
      # error exit if FURPUR is running in breakpoint or batch. The C option should be 
      # used with caution because a bad result of an erroring FURPUR command could be 
      # input to a process later on in the runstream.
      Write-JobLog $Msg ([LoggingSeverity]::Info)
      return $false
    } else {
      if ($AbortOnFailure) {
        Abort $Msg
      } else {
        $global:ErrorCode = 1
        Set-FileControlError 0
        return $false
      }
    }
  }

  if ($FileTo -eq "") {
    $Msg = "No ToFile is specified."
    if ($CopyOptions.HasFlag([CopyOptions]::C)) {
      # Executive Control Language (ECL) and FURPUR Reference Manual says:
      # Use of the C option on any FURPUR command will prevent execution of ER ERR$ on
      # error exit if FURPUR is running in breakpoint or batch. The C option should be 
      # used with caution because a bad result of an erroring FURPUR command could be 
      # input to a process later on in the runstream.
      Write-JobLog $Msg ([LoggingSeverity]::Info)
      return $false
    } else {
      if ($AbortOnFailure) {
        Abort $Msg
      } else {
        $global:ErrorCode = 1
        Set-FileControlError 0
        return $false
      }
    }
  }

  [String]$Dot1 = ""
  [String]$Dot2 = ""

  if ($Filefrom -eq $global:TempFolder) {
    $Dot1 = "."
  }

  if ($FileTo -eq $global:TempFolder) {
    $Dot2 = "."
  }

  [String]$Statement = (Get-FileName $FileFrom + $Dot1 + $EltFrom) + " -> "
  $Statement += (Get-FileName $FileTo + $Dot2 + $EltTo)
  Write-JobLog $Statement ([LoggingSeverity]::Info)

  Copy-File $FileFrom $EltFrom $FileTo $EltTo $CopyOptions
  if (-not (Check-FileControlError 0)) {
    Add-WarningMsg "Copy $Statement failed."
    $global:ErrorCode = 1
    Set-FileControlError 0
    return $false
  } else {
    return $true
  }
} # Asy-Copy


function NoStatement {
  <#
    .SYNOPSIS
      Handles unrecognized lines.
    .DESCRIPTION
      If a line in the original ECL script is not recognized as 
	  either an ECL statement or a data line belonging to a prior 
	  statement, it is passed here.
    .PARAMETER Line
      [String] Line
  #>

  param (
    [String]$Line
  )

  # Have your way with it

} # NoStatement


function DataLineOrNoStatement {
  <#
    .SYNOPSIS
      Add data to ECL @SORT, @DATA or @XQT statement
    .DESCRIPTION
      Some Ecl statements use lines with input parameters after the statement.
      In Powershell this data must be stored in a variable 
    .PARAMETER Data
      [String] Data
  #>

  param (
    [String]$Data
  )

  $Statement = "DataLine: $Data"

  if ((Check-Jump) -or ($global:Rcw)) {
    $Skip = $true
    Write-JobLog "Skipped $Statement" ([LoggingSeverity]::Debug)
    return
  } elseif (($global:InSsg -gt 0) -and ($global:SsgOptionB)) {
    $Skip = $true
    Write-JobLog ":::: $Statement" ([LoggingSeverity]::Debug)
    return
  }

  Write-JobLog "$Statement" ([LoggingSeverity]::Debug)
  if ($global:PreviousStatement -eq [EclDatalineStatement]::Xqt) {
    Accept-Write $Data
  } elseif ($global:PreviousStatement -eq [EclDatalineStatement]::RdmsLoad) {
    Add-WarningMsg "Data line for RDMSLOAD statement missed."
  } elseif ($global:PreviousStatement -eq [EclDatalineStatement]::Sort) {
    Add-WarningMsg "Data line for SORT statement missed."
  } elseif ($global:PreviousStatement -eq [EclDatalineStatement]::Data) {
    Add-WarningMsg "Data line for DATA statement missed."
  } elseif ($global:PreviousStatement -eq [EclDatalineStatement]::Ssg) {
    AddTo-SgsList $Data
  } elseif ($global:PreviousStatement -eq [EclDatalineStatement]::Dd) {
    # note: Code for DD data lines is currently generated in the converter.
  } else {
    NoStatement $Data
  }
} # DatalineOrNoStatement


function Delete {
  <#
    .SYNOPSIS
      ECL equivalent: @DELETE 
    .DESCRIPTION
      The Delete command deletes cataloged files, deletes program file elements (changes
      elements from current to deleted), or undeletes program file elements (changes
      elements from deleted to current).    
    .PARAMETER Options
      [String] Options
    .PARAMETER DeleteFile
      [String] DeleteFile
  #>

  param (
    [String]$Options,
    [Parameter(Mandatory=$true)][String]$DeleteFile
  )

  if (-not (Check-FileControlError 0)) {
    Abort "Delete was called with a file error condition already set."
  }

  if (Process-Skip "DELETE [$($Options)]: $DeleteFile") {
    return
  }

  Check-FinishStatement

  Write-Joblog "DELETE: $DeleteFile" ([LoggingSeverity]::Info)
  Write-Joblog "DELETE Options: $Options" ([LoggingSeverity]::Info)

  [String]$Filename = $DeleteFile.ToUpperInvariant().Trim()
  [DeleteOptions]$DeleteOptions = Parse-Options $Options ([DeleteOptions])

  [Boolean]$IsProgramFile = $false
  [String]$Cycle = ""
  [String]$Eltname = ""
  Check-Cycle ([Ref]$Filename) ([Ref]$Cycle)
  Check-FileName ([Ref]$Filename) ([Ref]$Eltname) $Cycle

  if (-not $DeleteOptions.HasFlag([DeleteOptions]::C) -and $DeleteOptions -ne [DeleteOptions]::None) {
    Abort "Invalid option $Options"
  }

  if ($Filename -eq "") {
    if ($Eltname -ne "") {
      $Filename = $global:TempFolder
    } else {
      Abort "No Filename is specified."
    }
  }

  if ($Eltname -ne "") {
    $Filename = Get-ProgramFileName $Filename $Eltname
  } else {
    $Filename = Get-AssignedFile $Filename 
    if (-not (Check-FileControlError 0)) {
      $Filename = Check-ProgramFile $Filename
      if (Check-FileControlError 501) {
        $IsProgramFile = $true
      }
    }
  }

  if (-not (Check-FileControlError 0)) {
    if ($DeleteOptions.HasFlag([DeleteOptions]::C)) {
      Add-WarningMsg "File not found.`r`nFileName: $Filename"
      Set-FileControlError 0
      return
    } else {
      Abort "File not found.`r`nFileName: $FileName"
    }
    return
  }

  if (($IsProgramFile) -and ($Eltname -eq "")) {  # Program file
    Delete-File $Filename
  } else {
    if ($Eltname -ne "") {
      Delete-File $Filename + $Eltname
    } else {
      # Check if file is still assigned, release if so
      Release-File $Filename $true $false $true
      if (Check-FileControlError 53) {
        #File not found, no problem - Don't display a warning here! It is possible to delete an unassigned file.
        Set-FileControlError 0
      }

      if (File-Exists $Filename) {
        Delete-File $Filename
        Delete-EmptyFoldersInPath($Filename)
        Write-JobLog ((Get-FileName $Filename) + " deleted.") ([LoggingSeverity]::Info)
      }
    }
  }
} # Delete


function Elt {
  <#
    .SYNOPSIS
      ECL equivalent: @ELT
    .DESCRIPTION
      The @ELT statement ...    
     .PARAMETER Options
      [String] Options
    .PARAMETER InputElement
      [String] InputElement
    .PARAMETER OutputElement
      [String] OutputElement
    .PARAMETER Sentinel
      [String] Sentinel
    .PARAMETER ReservedField
      [String] ReservedField
    .PARAMETER Subtype
      [String] Subtype
    .PARAMETER DataLines
      [String[]] DataLines
  #>

  param (
    [String]$Options,
    [Parameter(Mandatory=$true)][String]$InputElement,
    [Parameter(Mandatory=$false)][String]$OutputElement="",
    [Parameter(Mandatory=$false)][String]$Sentinel="",
    [Parameter(Mandatory=$false)][String]$ReservedField="",
    [Parameter(Mandatory=$false)][String]$Subtype="",
    [Parameter(Mandatory=$false)][String[]]$DataLines=""
  )

  [String]$Statement = "ELT [$($Options)]: $InputElement, $OutputElement, $Sentinel, $ReservedField, $Subtype"

  if (Process-Skip $Statement) {
    return
  }

  Check-FinishStatement

  # TODO: Options are ignored (), they may be important for post-STA clients.

  # Symbolic Input/Output Routine (SIR$) Options
  #
  # G  Input is compressed symbolic in columns 1 through 80 of the symbolic image.
  #    Applies with the I option only.
  #
  # H  Input contains sequence numbers in columns 73 through 80 of the symbolic images.
  #    Applies with the I option.
  #
  # I  Reads images from the runstream and inserts them into a new symbolic element.
  #
  # J  Input contains compressed symbolic images in columns 1 through 72 of the images
  #    and sequence numbers in columns 73 through 80. These sequence numbers are not
  #    checked by the K option. Applies with the I option only.
  #
  # K  Checks sequence numbers in columns 73 through 80. Valid only with the H and I
  #    options.
  #
  # P  Outputs symbolic in Fieldata. ASCII images are converted to Fieldata. See Q option.
  #
  # Q  Outputs symbolic in ASCII. Fieldata images are converted to ASCII. If you specify
  #    both P and Q options, the output is native mode, and no conversion takes place. If
  #    you specify neither the P nor Q options, the output is native mode and correction
  #    images, if any, are converted to the current source input type.
  #
  # U  Reads change images from the runstream, applies them to the input symbolic
  #    element, and produces a new cycle of the input symbolic.
  #
  # W  Lists change images.
  #
  # Element type options:
  #
  # O  Inserts images following the @ELT statement into an omnibus element as they
  #    appear in the runstream. The element is not formatted by ELT. Use only with
  #    the I option.
  #
  # S  Identifies element as a symbolic element. The ELT processor assumes this
  #    options whenever you do not specify an element type option. If O is not
  #    specified, S is the default. The S option is assumed if an element type option is
  #    omitted.
  #
  # Image handling options:
  #
  # D  Indicates that the symbolic input images following the @ELT statement can
  #    include control statements that are to be transferred as element data. For more
  #    information on the D option, see the subsection headed "Input Termination
  #    Sentinel."
  #
  # E  Ejects a page whenever a slash (/) appears in column one.
  #
  # L  Generates a listing of the complete symbolic element. The listing provides line
  #    numbers, cycle information, and identification of the newly added and deleted
  #    images.
  #
  # V  Prints, for symbolic elements only, both the input and updated line numbers
  #    with the correction lines. Inserted or replaced lines will have a plus sign (+)
  #    following the inserted line number.
  #
  # X  Takes error exit (ERR$) upon occurrence of an error. See the Exec Executive
  #    Requests Programming Reference Manual for information on ERR$.


  if ($OutputElement -eq "") {
    # Only InputElement specified, => just push the provided data lines into the specified file
    [String]$Filename = Get-AssignedFile (Convert-FileReference $InputElement)

    [Object]$FileStream = Create-TextFile $Filename $global:Const_ExclusiveBatch $global:UseUnicode $true

    if ($FileStream -eq $null) {
      abort "Failed to create element file $InputFile ."
    }

    foreach ($Line in $DataLines) {
      $FileStream.WriteLine($Line, $false) | Out-Null
    }

    $FileStream.Close() | Out-Null
    return
  }

  Abort "The OutputElement parameter is not supported yet."
} # Elt


function Ers {
  <#
    .SYNOPSIS
      ECL equivalent: @ERS
    .DESCRIPTION
      The @ERS statement releases mass storage from cataloged or temporary,
      sector-addressable or word-addressable files.    
     .PARAMETER Options
      [String] Options
    .PARAMETER Filename
      [String] Filename
  #>

  param (
    [String]$Options,
    [Parameter(Mandatory=$true)][String]$Filename
  )

  $Filename = $Filename.ToUpperInvariant().Trim()

  [String]$Statement = "ERS [$($Options)]: $Filename"

  if (Process-Skip $Statement) {
    return
  }

  Check-FinishStatement

  Write-JobLog $Statement ([LoggingSeverity]::Info)

  If ($FileName.Contains(".")) {
    Abort("File extensions are not allowed.")
  }

  [String]$Cycle = ""
  Check-Cycle ([Ref]$Filename) ([Ref]$Cycle)
  [String]$File = Get-AssignedFile $Filename
  if (Check-FileControlError 0) {
    $Filename = $File
    Erase-File $Filename
  } else {  # Maybe programfile
    if (($Filename -eq "TPF$") -or ($Filename.Trim() -eq "")) {
      $Filename = $global:TempFolder
    } else {
      $Filename = Get-ProgramFileName $Filename ""
      $Filename = $Filename.Substring(0, $Filename.Length - 1)  #Remove \
    }

    if (Check-FileControlError 0) {
      if ($Cycle -ne "") {
        Abort "File cycle not allowed for program files"
      }
      Delete-File $Filename
    } else {
      Add-WarningMsg "File not Found`r`nFileName: $FileName"
      Set-FileControlError 0
    }
  }
} # Ers


function Ed-Insert {
  <#
    .SYNOPSIS
      ECL equivalent: @ED,I / @ED,IQ
    .DESCRIPTION
      Creates a file and optionally writes content lines to it.
      Replaces the OS2200 @ED text editor INSERT mode.
    .PARAMETER Options
      [String] ED option letters (I, IQ, etc.)
    .PARAMETER Filename
      [String] Target file reference
    .PARAMETER Content
      [String[]] Lines to write into the file (optional — empty means create empty file)
  #>

  param (
    [String]$Options = "",
    [Parameter(Mandatory=$true)][String]$Filename,
    [String[]]$Content = @()
  )

  [String]$Statement = "ED-INSERT [$($Options)]: $Filename"

  if (Process-Skip $Statement) {
    return
  }

  Check-FinishStatement

  Write-JobLog $Statement ([LoggingSeverity]::Info)

  $Filename = $Filename.ToUpperInvariant().Trim()
  [String]$FilePath = Get-AssignedFile $Filename

  [Object]$FileStream = Create-TextFile $FilePath $global:Const_ExclusiveBatch $global:UseUnicode $true

  if ($FileStream -eq $null) {
    Abort "Ed-Insert: Failed to create file $FilePath"
  }

  foreach ($Line in $Content) {
    $FileStream.WriteLine($Line, $false) | Out-Null
  }

  $FileStream.Close() | Out-Null
} # Ed-Insert


function Ed-Update {
  <#
    .SYNOPSIS
      ECL equivalent: @ED,U / @ED,UQ / @ED,UQN
    .DESCRIPTION
      Applies editor commands (find/replace, delete, etc.) to an existing file.
      Replaces the OS2200 @ED text editor UPDATE mode.
    .PARAMETER Options
      [String] ED option letters (U, UQ, UQN, etc.)
    .PARAMETER Filename
      [String] Target file reference
    .PARAMETER Commands
      [String[]] Editor commands to apply (c /old/new/A, D+, F pattern, etc.)
  #>

  param (
    [String]$Options = "",
    [Parameter(Mandatory=$true)][String]$Filename,
    [String[]]$Commands = @()
  )

  [String]$Statement = "ED-UPDATE [$($Options)]: $Filename"

  if (Process-Skip $Statement) {
    return
  }

  Check-FinishStatement

  Write-JobLog $Statement ([LoggingSeverity]::Info)

  $Filename = $Filename.ToUpperInvariant().Trim()
  [String]$FilePath = Get-AssignedFile $Filename

  # Read current content via file controller
  [Object]$ReadStream = Open-TextFile $FilePath $global:Const_SharedRead $global:Const_FileEnc_Autodetect $false
  [System.Collections.Generic.List[String]]$Lines = New-Object 'System.Collections.Generic.List[String]'
  while (-not $ReadStream.EndOfFile) {
    $Lines.Add($ReadStream.ReadLine())
  }
  Close-TextFile $ReadStream | Out-Null

  # Process each editor command
  foreach ($Cmd in $Commands) {
    [String]$CmdUpper = $Cmd.ToUpperInvariant().Trim()

    # Change command: c /old/new/ [A] [G]
    if ($Cmd -match '^[Cc]\s*/([^/]*)/\s*([^/]*)/?\s*(.*)$') {
      [String]$SearchText = $Matches[1]
      [String]$ReplaceText = $Matches[2]
      [String]$Flags = $Matches[3].ToUpperInvariant()
      [Boolean]$All = $Flags.Contains("A") -or $Flags.Contains("G")

      if ($All) {
        for ([Int32]$i = 0; $i -lt $Lines.Count; $i++) {
          $Lines[$i] = $Lines[$i].Replace($SearchText, $ReplaceText)
        }
      } else {
        for ([Int32]$i = 0; $i -lt $Lines.Count; $i++) {
          if ($Lines[$i].Contains($SearchText)) {
            $Lines[$i] = $Lines[$i].Replace($SearchText, $ReplaceText)
            break
          }
        }
      }
    }
    # Find + Delete: F pattern followed by D+ removes matching lines
    elseif ($CmdUpper.StartsWith("F ") -or $CmdUpper.StartsWith("F`t")) {
      [String]$Pattern = $Cmd.Substring(2).Trim()
      [System.Collections.Generic.List[String]]$Filtered = New-Object 'System.Collections.Generic.List[String]'
      foreach ($L in $Lines) {
        if (-not $L.Contains($Pattern)) {
          $Filtered.Add($L)
        }
      }
      $Lines = $Filtered
    }
    # Delete command (D, D+) — handled as part of Find above in batch mode
    elseif ($CmdUpper -match '^D\+?$') {
      Write-JobLog "  Ed-Update: Delete command '$Cmd' (handled with preceding Find)" ([LoggingSeverity]::Info)
    }
    # List commands (LNP!, LPS, LP) — no-op in target
    elseif ($CmdUpper.StartsWith("LNP") -or $CmdUpper.StartsWith("LPS") -or $CmdUpper.StartsWith("LP")) {
      Write-JobLog "  Ed-Update: List command '$Cmd' (no-op in target)" ([LoggingSeverity]::Info)
    }
    else {
      Write-JobLog "  Ed-Update: Unhandled editor command '$Cmd'" ([LoggingSeverity]::Warning)
    }
  }

  # Write back via file controller
  [Object]$WriteStream = Create-TextFile $FilePath $global:Const_ExclusiveBatch $global:UseUnicode $true
  if ($WriteStream -eq $null) {
    Abort "Ed-Update: Failed to write file $FilePath"
  }
  foreach ($Line in $Lines) {
    $WriteStream.WriteLine($Line, $false) | Out-Null
  }
  $WriteStream.Close() | Out-Null
} # Ed-Update


function Fin {
  <#
    .SYNOPSIS
      ECL equivalent: @FIN
    .DESCRIPTION
      The @FIN statement identifies the end of a run.
  #>

  Check-FinishStatement
  Write-JobLog "FIN" ([LoggingSeverity]::Info)

  # TODO: 
  # FileObject.CloseAllFiles() | Out-Null

  if ($global:WarningRcw2435) {
    if ($global:RcwBits[24] -eq 1) {
      $global:LASTEXITCODE = 1
      Add-WarningMsg "SWITCH-13 is set."
    }

    if ($global:RcwBits[35] -eq 1) {
      $global:LASTEXITCODE = 1
      Add-WarningMsg "SWITCH-24 is set."
    }
  }

  Cleanup $false

} # Fin


function Chg {
  <#
    .SYNOPSIS
      ECL equivalent: @CHG
    .DESCRIPTION
      The @CHG statement changes file attributes.
      Option V = set read-only, W = set write-only (clear read-only), Z = clear both modes.
      Uses the file controller's SetAttributes method to apply the change.
    .PARAMETER Options
      [String] Options (V, W, or Z)
    .PARAMETER ChgFile
      [String] File reference
  #>

  param (
    [String]$Options,
    [Parameter(Mandatory=$true)][String]$ChgFile
  )

  if (Process-Skip "CHG [$($Options)]: $ChgFile") {
    return
  }

  Check-FinishStatement

  Write-Joblog "CHG: $ChgFile" ([LoggingSeverity]::Info)
  Write-Joblog "CHG Options: $Options" ([LoggingSeverity]::Info)
  $ChgFile = $ChgFile.ToUpperInvariant().Trim()

  Replace-Asterisks ([Ref]$ChgFile)

  [String]$Filename = $ChgFile
  if ($Filename.EndsWith(".")) {
    $Filename = $Filename.Substring(0, $Filename.Length - 1)
  }

  $Filename = Check-UseName $Filename
  [String]$WindowsFile = Get-AssignedFile $Filename $true

  if (!(Check-FileControlError 0)) {
    Write-JobLog "CHG: File [$($ChgFile)] not found. Ignored." ([LoggingSeverity]::Warning)
    Set-FileControlError 0
    return
  }

  # Determine the file attributes based on options
  [String]$Opt = $Options.ToUpperInvariant()
  if ($Opt.Contains("V")) {
    # V = set read-only mode
    $global:AmtFile.SetAttributes($WindowsFile, [System.IO.FileAttributes]::ReadOnly)
    Write-JobLog "CHG: Set read-only for [$($WindowsFile)]" ([LoggingSeverity]::Info)
  } elseif ($Opt.Contains("Z")) {
    # Z = clear read-only and write-only modes
    $global:AmtFile.SetAttributes($WindowsFile, [System.IO.FileAttributes]::Normal)
    Write-JobLog "CHG: Clear modes for [$($WindowsFile)]" ([LoggingSeverity]::Info)
  } elseif ($Opt.Contains("W")) {
    # W = set write-only (clear read-only)
    $global:AmtFile.SetAttributes($WindowsFile, [System.IO.FileAttributes]::Normal)
    Write-JobLog "CHG: Set write-only for [$($WindowsFile)]" ([LoggingSeverity]::Info)
  } else {
    Write-JobLog "CHG: Unsupported options [$($Options)] for [$($WindowsFile)]. Ignored." ([LoggingSeverity]::Warning)
  }

  if ($global:AmtFile.ErrorCode -ne 0) {
    Add-WarningMsg "CHG: SetAttributes failed for [$($WindowsFile)]: $($global:AmtFile.ErrorDescription)"
    Set-FileControlError $global:AmtFile.ErrorCode $global:AmtFile.ErrorDescription
  }

} # Chg


function Free {
  <#
    .SYNOPSIS
      ECL equivalent: @FREE / @@FREE
    .DESCRIPTION
      The @FREE statement releases files, reels, internal file names, and the exclusive use of
      files from your run.    
    .PARAMETER Options
      [String] Options
    .PARAMETER FreeFile
      [String] FreeFile
  #>

  param (
    [String]$Options,
    [Parameter(Mandatory=$true)][String]$FreeFile
  )

  if (Process-Skip "FREE [$($Options)]: $FreeFile") {
    return
  }

  Check-FinishStatement

  Write-Joblog "FREE: $FreeFile" ([LoggingSeverity]::Info)
  Write-Joblog "FREE Options: $Options" ([LoggingSeverity]::Info)
  $FreeFile = $FreeFile.ToUpperInvariant().Trim()

  [String]$Filename = $FreeFile

  [FreeOptions]$FreeOptions = Parse-Options $Options ([FreeOptions])

  if ($Filename -eq "") {
    Abort "No filename specified."
  }

  # A -> (UseName)  The usename is being released not the filename
  # B -> (UseName)  The usenames are being released and If it is the only one for the filename then the file also
  # D -> (FileName, UseName) The filename is being released and deleted
  #                          Inhibits the cataloging of a file that was assigned (ASG) with a C or U option. 
  # I -> (Inhibits the cataloging of a file that was assigned (ASG) with a C or U option.)
  # R -> (FileName, UseName) Release the file not the usename, tempfile deleted
  # X -> (FileName, UseName) Release exclusive lock, tempfile deleted

  # If an assign is being done first check if the s_FileName is UseName, if so use the correct filename

  [String]$Usename = $Filename
  $Filename = Check-UseName $Filename 

  if ($Filename -eq "TPF$") {   # don't delete tpf$ file, only empty it
    Ers "" "TPF$"
    return
  }

  if ($FreeOptions -eq [FreeOptions]::None) {
    $Filename = Get-AssignedFile $Filename 
    if ($global:UseFound) {
      Release-Use $Usename $Filename
      if (Check-FileControlError 53) { # No usename found 
        Write-JobLog "File not assigned or USEed: Ignored." ([LoggingSeverity]::Info)
        Set-FileControlError 0
      }
    } else {
      Release-File $Filename $false $false $true
      if (Check-FileControlError 53) {  
        Release-Use $UseName ""
        if (Check-FileControlError 53) { # No usename found 
          Write-JobLog "File not assigned or USEed: Ignored" ([LoggingSeverity]::Info)
        }
        Set-FileControlError 0
      }
    }

    return
  } else {
    if ((-not ($FreeOptions.HasFlag([FreeOptions]::A))) -and
        (-not ($FreeOptions.HasFlag([FreeOptions]::B))) -and
        (-not ($FreeOptions.HasFlag([FreeOptions]::D))) -and
        (-not ($FreeOptions.HasFlag([FreeOptions]::I))) -and
        (-not ($FreeOptions.HasFlag([FreeOptions]::R))) -and
        (-not ($FreeOptions.HasFlag([FreeOptions]::X)))) {
      Abort "Invalid options: $Options"  
    }
  }

  if ($FreeOptions.HasFlag([FreeOptions]::A)) {
    Release-Use $Usename ""
    if (Check-FileControlError 53) { # No usename found 
      Add-WarningMsg "Unknown Use name."
      Set-FileControlError 0
    }
  }

  $Filename = Get-AssignedFile $Filename
  if (Check-FileControlError 53) {
    if ((-not ($FreeOptions.HasFlag([FreeOptions]::D))) -and
        (-not ($FreeOptions.HasFlag([FreeOptions]::I)))) {
      Add-WarningMsg "File not found.`r`nFileName: $FileName"
      Set-FileControlError 0
      return
    }
  }

  if ($FreeOptions.HasFlag([FreeOptions]::B)) {
    Release-Use $Usename $Filename
    if (Check-FileControlError 53) { # No usename found 
      Add-WarningMsg "Unknown Use name."
      Set-FileControlError 0
    }
  }

  if ($FreeOptions.HasFlag([FreeOptions]::D)) {
    Release-File $Filename $true $false $true
    if (Check-FileControlError 53) { 
      Add-WarningMsg "File $Filename was not assigned, it could not be released."
      Set-FileControlError 0
    }
  }

  if ($FreeOptions.HasFlag([FreeOptions]::I)) {
    [Int32]$J = 0
    for ($J = 0; $J -lt $global:FilesList.Count; $J++) {
      if ($global:Files[$J].Copyname -eq $Filename) {
        break
      }
    }

    if ($global:FilesList[$J].Copyname -eq $Filename) {
      if (($global:FilesList[$Index].DeleteOnFree) -and ($global:FilesList[$Index].IsCataloged)) {
        Release-File $Filename $true $false $true 
      } else {
        Release-File $Filename $false $false $true 
      }

      if (Check-FileControlError 53) { 
        Add-WarningMsg "File $Filename was not assigned, it could not be released."
        Set-FileControlError 0
      }
    }
  }

  if ($FreeOptions.HasFlag([FreeOptions]::R)) {
    Release-File $Filename $false $false $false
    if (Check-FileControlError 53) { 
      Add-WarningMsg "File $Filename was not assigned, it could not be released."
      Set-FileControlError 0
    } else {
      <# 
      TODO: # filecycle still needed in usename
      For j = 0 To UBound(a_UseNames,2) - 1 
        s_File = GetFileName(s_FileName)
        i_pos = InStrRev(s_File,"\")
        s_File = Left(s_File, i_pos - 1)
        If (a_UseNames(1,j) = s_File) and (a_UseNames(2,j) = "+001") Then
          ' cycle +1 is not valid anymore after a FREE so replace with absolute cycle 
          a_UseNames(2,j) = NormCycle(s_New_CU_Cycle) 
        End If
      Next
      #>
    }
  }

  if ($FreeOptions.HasFlag([FreeOptions]::X)) {
    Write-JobLog "X option can not be implemented, file stays in exclusive use." ([LoggingSeverity]::Info)
  }
} # Free


function FreeM {

  <#
    .SYNOPSIS
      ECL equivalent: @FREEM
    .DESCRIPTION
      The @FREEM processor frees all currently assigned files for the run.
      This is a third-party OS2200 utility (not a standard ECL mnemonic).
      Internally calls CloseAllFiles on the file controller.
    .PARAMETER Options
      [String] Options (e.g. M = mass storage only, A = all no exceptions)
  #>

  param (
    [String]$Options
  )

  if (Process-Skip "FREEM [$($Options)]") {
    return
  }

  Check-FinishStatement

  Write-Joblog "FREEM: Close all files (Options: $Options)" ([LoggingSeverity]::Info)

  if ($global:AmtFile -ne $null) {
    $global:AmtFile.CloseAllFiles() | Out-Null
  }

  $global:FilesList.Clear()
  Set-FileControlError 0

} # FreeM


function Hdg {

  <#
    .SYNOPSIS
      ECL equivalent: @HDG / @@HDG
    .DESCRIPTION
      The @HDG statement lets you specify a heading to be printed on every page of the
      printout (jobsummary), as well as page numbers and the date when the file was created.    
    .PARAMETER Options
      [String] Options
    .PARAMETER Heading
      [String] Heading
    .PARAMETER Printcontrol
      [String] Printcontrol
  #>

  param (
    [String]$Options,
    [String]$Heading,
    [String]$Printcontrol
  )

  [String]$Statement = "HDG [$($Options)]: $Heading $Printcontrol"
  if (Process-Skip $Statement) {
    return
  }

  Check-FinishStatement

  [HdgOptions]$HdgOptions = Parse-Options $Options ([HdgOptions])  

  # Call CloseData()

  if ($HdgOptions.ToString().Length -gt 1 -and -not $HdgOptions.HasFlag([HdgOptions]::None)) {
    Write-JobLog $Statement ([LoggingSeverity]::Warning)
    Add-WarningMsg "Only one option is allowed."
    return
  }

  if ($HdgOptions.HasFlag([HdgOptions]::P)) {
    $global:JobSummaryPageNr = 0  # Reset Page counter
  }

  if (-not ($HdgOptions.HasFlag([HdgOptions]::N))) {
    $global:JobSummaryPageSkip = $true
  }

  if ($PrintControl -ne "") {

    $PrintControl = $Printcontrol.Trim()

    if ($PrintControl.StartsWith("A")) {             # A
      Abort "Unsupported print control function: A"
    } elseif ($PrintControl.StartsWith("B")) {       # B,lpi,ctid,eltname
      Abort "Unsupported print control function: B"
    } elseif ($PrintControl.StartsWith("H")) {       # H,options,page,text
      Abort "Unsupported print control function: H"
    } elseif ($PrintControl.StartsWith("M")) {       # M,length,top,bottom,lpi

      [Int32]$LinesPPSave = $global:JobSummaryLinesPP
      [Int32]$Comma1 = $Printcontrol.IndexOf(",")
      [Int32]$Comma2 = $Printcontrol.IndexOf(",", $Comma1 + 1)
      $global:JobSummaryLinesPP = $Printcontrol.Substring($Comma1 + 1, $Comma2 - $Comma1 - 1)

      if (($global:JobSummaryLinesPP -lt 20) -or ($global:JobSummaryLinesPP -gt 200)) {
        $global:JobSummaryLinesPP = $LinesPPSave
      }
    } elseif ($PrintControl.StartsWith("R")) {       # R,length,top,bottom,lpi
      Abort "Unsupported print control function: R"
    } elseif ($PrintControl.StartsWith("S")) {       # R,text
      Abort "Unsupported print control function: S"
    } elseif ($PrintControl.StartsWith("U")) {       # U
      Abort "Unsupported print control function: U"
    } elseif ($PrintControl.StartsWith("W")) {       # W,line width
      Abort "Unsupported print control function: W"
    } else {
      Abort "Unrecognized print control function: $PrintControl"
    }
  }

  $global:HdgText = $Heading
  Write-JobLog $Statement ([LoggingSeverity]::Info)
} # Hdg

function Sym {
  <#
    .SYNOPSIS
      ECL equivalent: @SYM
    .DESCRIPTION
      Queues previously created print files ot a printer, group of printers, or user id, for printing.
    .PARAMETER Options
      [String] Options
    .PARAMETER FileName
      [String] Identifies the file to be queued
    .PARAMETER NrOfPrints
      [Int32] Indicates how many copies of the file are to be printed
    .PARAMETER Printer
      [String] Indentifies on which device the file is to be printed
    .PARAMETER Banner
      [String] Specifies the banner to appear on the first page of the printout
  #>

  param (
      [String]$Options,
      [Parameter(Mandatory=$true)][String]$FileName,
      [Int32]$NrOfPrints,
      [String]$Printer,
      [String]$Banner
  )

  if (Process-Skip "SYM [$($Options)]: $($Filename),$($NrOfPrints),$($Printer)") {
    return
  }

  Check-FinishStatement

  Write-Joblog "SYM [$($Options)]: $($Filename),$($NrOfPrints),$($Printer)" ([LoggingSeverity]::Info)

  # note: $FileName may be a compound containing "FileName,NrOfPrints,Printer,PartNames,Banner" 
  #       as comma separated parts. If so, put the parts in their variables before continuing.
  if ($FileName.Contains(",")) {
    [String[]] $parts = $FileName.Split(",")
    if ($parts.Length -gt 0) { $FileName   = $parts[0] }
    if ($parts.Length -gt 1) { [Int32]::TryParse($parts[1], [ref] $NrOfPrints) | Out-Null}
    if ($NrOfPrints -eq 0) { $NrOfPrints = 1 }
    if ($parts.Length -gt 2) { $Printer    = $parts[2] }
    # note: part names are ignored
    if ($parts.Length -gt 4) { $Banner     = $parts[4] }
  }

  $Options = $Options.ToUpperInvariant()
  $FileName = $FileName.ToUpperInvariant().Trim()

  [Boolean]$PrintDollar = $false
  if (($FileName -eq "PRINT`$") -or ($FileName -eq "")) {
    # PRINT$ is the primary print file
    if ($global:JobLogFile -ne $global:JobLogFileOrig) {
      Add-WarningMsg "SYM PRINT$ while in breakpoint mode, this is not allowed."
      return
    }

    $FileName = $global:JobLogFile
    $PrintDollar = $true
  }

  #[String]$Cyclename = ""
  #$Filename = Strip-Cycle $Filename ([Ref]$Cyclename)
  if ($FileName -ne $global:JobLogFile) {
    $Filename = Get-AssignedFile $FileName 
    if (-not (File-Exists $FileName)) {
      Add-WarningMsg "SYM: File $Filename not found"
      return
     } else {
      if (($global:FileObject -ne $null) -and ($global:FileObject.WindowsFilename.StartsWith($global:TempFolder))) {
        Add-WarningMsg "SYM of non catalogued file not allowed" 
        return
      }
    }
    $global:FileHandle = $global:AmtFile.GetFileInfo($Filename, 1)  
    $Filename = $global:FileHandle.FullName

  }

  [SymOptions]$SymOptions = Parse-Options $Options ([SymOptions])

  if ($SymOptions.HasFlag([SymOptions]::D)) {
    if ($SymOptions.HasFlag([SymOptions]::F)) {
      # DF, delete the jobsummary
      $global:SymDF = $true
      if (File-Exists $global:JobLogFile)  {
        Delete-File $global:JobLogFile
      }
      return
    } else {
      # Only D, remove jobsummary when BRKPT or @FIN
      $global:DelJobLogFile = $true
      return
    }
  }

  if ($FileName -eq $global:JobLogFile) {
    if ($Printer -ne "") {
      $global:SymJobLogPrinter = $Printer
    } else {
      $global:SymJobLogPrinter = $global:DefaultPrinter
    }

    if ($PrintDollar) {
      # When SYM contains the name of the joblog files instead of PRINT$ the file must be printed
      # after the jobsummary file is closed.
      return
    }
  }

  # Set number of copies
  $global:AmtPrint.ClearSettings()
  if ($NrOfPrints -eq "") {
    $global:AmtPrint.NumCopies = 1
  } else {
    $global:AmtPrint.NumCopies = $NrOfPrints
  }

  # Set printer
  [String]$SymPrinter = ""
  if ($Printer -ne "") {
    $SymPrinter = $Printer
  } else {
    $SymPrinter = $global:DefaultPrinter
  }

  # Set Banner.
  if ($Banner -ne "") {
     $global:AmtPrint.BannerId = $Banner
   } else {
     $global:AmtPrint.BannerId = $JobName
   }

  if ($SymPrinter -ne "") { 
    # Perform the actual print    
    $global:AmtPrint.ForcePrint = $true
    $global:AmtPrint.SubDirectories = $false
    if ($SymOptions.HasFlag([SymOptions]::U)) {
      $global:AmtPrint.RemoveFiles = $false
    } else {
      $global:AmtPrint.RemoveFiles = $true
    }
    $global:AmtPrint.WaitTimeOut = 60
    $global:AmtPrint.Wait = $true
    $global:AmtPrint.PrintFile($FileName, $Printer) | Out-Null
    if ($global:AmtPrint.ErrorCode -ne 0) {
      Abort "Print Error (FileName=$FileName, Printer=$Printer): $($global:AmtPrint.ErrorDescription)"
    }
    if ($FileName -ne $global:JobLogFile) {
      Write-JobLog ("Printed on printer $SymPrinter : " + $FileName) ([LoggingSeverity]::Info)
      Delete-EmptyFoldersInPath $FileName
    }
  }
} # Sym


function Brkpt {
  <#
    .SYNOPSIS
      ECL equivalent: @BRKPT
    .DESCRIPTION
      Diverts output from the PRINT$ file to a user defined file, so it redirects the joblog file.
    .PARAMETER FileName
      [String] Specifies the file to which the joblog is redirected
  #>

  param (
      [String]$FileName # Not mandatory, it can be an empty string
  )

  Replace-Asterisks ([Ref]$Filename)

  if (Process-Skip "BRKPT $($Filename)") {
    return
  }

  Check-FinishStatement

  Write-Joblog "BRKPT : $($Filename)" ([LoggingSeverity]::Info)

  #[String]$Cyclename = ""
  $FileName = $FileName.ToUpperInvariant().Trim()
  if ($FileName -eq "") {
    if (File-Exists $global:JobLogFile) {
      if ($global:JobLogFile -eq $global:JobLogFileOrig) {
        if ($global:DelJobLogFile) {
          # SYM,D encountered before this BRKPT statement
          Close-JobLog
          Delete-File $global:JobLogFile
          $global:DelJobLogFile = $false
          Create-JobLogFile
          $global:JobLogFileAvailable = $true
        }
      } else {
        Close-JobLog
        $global:JobLogFile = $global:JobLogFileOrig
        #$Cyclename = "" 
        if (-not($global:SymDF)) {
          if (-not(File-Exists $global:JobLogFile)) {
            Create-JobLogFile
          } else {
            Write-JobLog "`f"  ([LoggingSeverity]::Info) # Write form feed			
            $global:JobLogObj = Open-TextFile $global:JobLogFile $global:Const_ExclusiveBatch $global:Const_FileEnc_Autodetect $true
            if ($global:ErrorCode -ne 0) {
              Add-ErrorMsg "BRKPT: Could not open JobLogFile $($global:JobLogFile)"
              return
            }
            # Set Banner.
            $global:AmtPrint.BannerId = $global:JobName
            # TODO: lineNr and PageNr
          }
          $global:JobLogFileAvailable = $true
        }
      }
    }
  } else {
    if ($global:DelJobLogFile) {
      # SYM,D encountered before this BRKPT statement
      if ($global:JobLogFile -eq $global:JobLogFileOrig) {
        Close-JobLog
        Delete-File $global:JobLogFile
      }
    }
    $FileName = Get-AssignedFile $FileName 
    if (Check-FileControlError 0) {
      $global:JobLogFile = $FileName
      Init-JobLog # Open joblog file
      if ($global:KeepJobLogDevelopment -and $global:Development) {
        $global:BrkptFilename = $FileName
      }
    }
  }
} # Brkpt

function Use {
  <#
    .SYNOPSIS
      ECL equivalent: @USE <UseName>, <UseName or Filename>
    .DESCRIPTION
      The @USE statement lets you reference a file by more than one file name.
    .PARAMETER UseName
      [String] UseName to use.
    .PARAMETER Filename
      [String] Original filename.
  #>

  param (
    [String]$UseName,
    [String]$Filename
  )

  if (Process-Skip "USE: $($UseName),$($Filename)") {
    return
  }

  Replace-Asterisks ([Ref]$Filename)

  Check-FinishStatement

  Write-Joblog "USE: $($UseName),$($Filename)" ([LoggingSeverity]::Info)

  [String]$Qual      = ""
  [Boolean]$Found    = $false
  [Int32]$Pos = -1

  if ($UseName -eq "") {
    Abort "No Use Name specified."
  }

  if ($UseName.IndexOf(".") -gt -1) {
    if ($UseName.EndsWith(".")) {
      $UseName = $UseName.Substring(0, $UseName.Length - 1)  #Remove dot at end of usename
    } else {
      Abort "File extensions are not allowed."
    }
  }

  if ($Filename -eq "") {
    Abort "No filename specified."
  }

  if ($Filename.EndsWith(".")) {
    $Filename = $Filename.Substring(0, $Filename.Length - 1)  # Strip dot at end
  }  

  if ($Filename.IndexOf(".") -gt -1) {
    Abort "File extensions are not allowed."
  }

  $Pos = $Filename.IndexOf("\")
  if ($Pos -gt -1) {
    $Qual = $Filename.Substring(0, $Pos)
  }

  # Check if Filename is a previous UseName
  if ($Qual -eq "") {
    for ([Int32]$I = 0; $I -lt $global:UseNamesList.Count; $I++) {
      if ($global:UseNamesList[$I].Usename -eq $Filename) {
        $global:UseNamesList[$I].Filename = $Filename
        $global:UseNamesList[$I].FileObject = $global:FileObject
        return
      }
    }
  }

  [String]$File = $Filename
  $Filename = Get-AssignedFile $Filename 

  if (Check-FileControlError 53) {
    # File not found

    $Filename = Get-ProgramFileName $File ""

    if (Check-FileControlError 0) {
      # Remove '\' at the end
      $Filename = $Filename.Substring(0, $Filename.Length - 1)
      $File = $Filename.Substring($global:ExtractPath.Length)
      $Found = $true
    }
  }

  #[String]$Cyclename = ""
  #[Boolean]$HasCycle = ($File.IndexOf("(") -gt -1)
  for ([Int32]$I = 0; $I -lt $global:FilesList.Count; $I++) {
    if ($global:FilesList[$I].Filename -eq $File) {
      if ($Found) {
        $File = $Filename.Substring($global:ExtractPath.Length)
      }
      break
    }
  }

  if (!$Found) {
    $File = $Filename
    $Pos = $File.LastIndexOfAny("\")
    if ($Pos -eq ($File.Length - 1)) {
      $File = $File.Substring(0, $Pos) # remove trailing \
    }

    if (!(Check-FileControlError 53)) {
    } else {
      $Pos = $File.IndexOf("\")
      $File = $Qual + $File.Substring($Pos + 1)
    }
  }

  for ([Int32]$I = 0; $I -lt $global:UseNamesList.Count; $I++) {
    if ($global:UseNamesList[$I].Usename -eq $UseName) {
      if ($global:UseNamesList[$I].Filename -eq $Filename) {
        # Entry already exists
      } else {
        $global:UseNamesList[$I].Filename = $Filename
        $global:UseNamesList[$I].FileObject = $global:FileObject
        #$global:UseNamesList[$I].Cyclename = $Cyclename
      }
      return
    }
  }

  if ($UseName -eq $File) {
    Write-JobLog "Use name and filename are the same. Ignored." ([LoggingSeverity]::Info)
  } else {
    # Add new entry
    #$global:UseNames += ,@($UseName, $File)
    $global:UseNameObject = New-Object PSObject
    $global:UseNameObject | Add-Member -Name Usename          -Value $UseName            -MemberType NoteProperty   # The usename of the file/usename
    $global:UseNameObject | Add-Member -Name Filename         -Value $Filename           -MemberType NoteProperty   # The file/usename
    $global:UseNameObject | Add-Member -Name FileObject       -Value $global:FileObject  -MemberType NoteProperty   # The file object
    $global:UseNameObject | Add-Member -Name IsSentToProgram  -Value $false              -MemberType NoteProperty   # Is this USE info sent to program
    #$global:UseNameObject | Add-Member -Name Cyclename -Value $Cyclename -MemberType NoteProperty   # The filename including cycle
    $global:UseNamesList.Add($global:UseNameObject)
  }
} # Use


function Xqt {

  <#
    .SYNOPSIS
      ECL equivalent: @XQT 
    .DESCRIPTION
      The @XQT statement initiates the execution of an absolute element or object module.
      In Amt start of a report is prepared.
    .PARAMETER Options
      [String] Options
    .PARAMETER Report
      [String] Report to be started.
  #>

  param (
    [String]$Options,
    [Parameter(Mandatory=$true)][String]$Report
  )

  if (Process-Skip "XQT [$($Options)]: $Report") {
    return
  }

  Check-FinishStatement

  Write-Joblog "XQT: $Report" ([LoggingSeverity]::Info)
  Write-Joblog "XQT Options: $Options" ([LoggingSeverity]::Info)
  $Report = $Report.ToUpperInvariant().Trim()

  #Not needed - [XqtOptions]$XqtOptions = Parse-Options $Options ([XqtOptions])

  $global:PreviousStatement = [EclDatalineStatement]::Xqt

  [Object]$ObjTask = $null
  $ObjTask = Get-TaskObject $ObjTask
  Check-ClearTaskObject -TaskObj $ObjTask

  $global:XqtReport = $Report
  $ObjTask.SetTVCustom("OPT", $Options)

  # TODO: Redim a_PrintsXqt(0)
} # Xqt


function End-Xqt {
  <#
    .SYNOPSIS
      Finish a prepared @XQT statement
    .DESCRIPTION
      After an Xqt and zero or more Datalines and AddExtractfiles the Report is started here.
  #>

  [String]$Statement = "End-Xqt"
  if ((Check-Jump) -or ($global:Rcw)) {
    Write-JobLog "Skipped $Statement" ([LoggingSeverity]::Info)
    return
  }

  if ($global:FirstExtractFile) {
    Write-JobLog "" ([LoggingSeverity]::Info)
  }

  Write-JobLog $Statement ([LoggingSeverity]::Info)

  if ($global:InSsg -gt 0) {
    $global:PreviousStatement = [EclDatalineStatement]::Ssg
  } else {
    $global:PreviousStatement = [EclDatalineStatement]::None
  }

  [String]$Report = $global:XqtReport
  $Report = Check-ReportName $Report

  [Object]$ObjTask = $null
  $ObjTask = Get-TaskObject $ObjTask
  Initialize-TaskObject $ObjTask

  # note: $global:RecoverId may be changed by GetRecoveryPointCount, => save the original
  $SpecifiedRecoverId = $global:RecoverId

  [String]$ReportJobLogFile = ""
  if ($global:UseJobLog) {
    $ReportJobLogFile = $global:JobLogFile
  }

  if ($global:UseJobLog) {
    if ($global:LogTimes) {
      $ObjTask.SetTVCustom("JOBFILENAME", $ReportJobLogFile + "; ")
    } else {
      $ObjTask.SetTVCustom("JOBFILENAME", $ReportJobLogFile + ";NO")
    }  
    $ObjTask.SetTVCustom("JOBSUMMARY", $ReportJobLogFile)
  }

  foreach ($FileObject in $global:FilesList) {
    # Add files to the task object so the report can make the link between logical and physical files
    [String]$Filename = $FileObject.ShortName   #Old: Get-Filename $FileObject.WindowsFilename  

    <# Not needed anymore when using ShortName
    # Remove possible extension
    [Int32]$DotPos = $Filename.IndexOf(".")
    if ($DotPos -gt -1) {
      $Filename = $Filename.Substring(0, $DotPos)
    }

    # Remove possible backslash
    [Int32]$SlashPos = $Filename.IndexOf("\")
    if (($SlashPos -gt -1) -and ($SlashPos -le $Filename.Length)) {
      $Filename = $Filename.Substring($SlashPos + 1)
    }
    #>

    if ($Filename -ne "") {
      [Boolean]$FilenameIsUsename = $false
      [String[]]$UseFilenames = @()
      for ([Int32]$I = 0; $I -lt $global:UseNamesList.Count; $I++) {
        if ($global:UseNamesList[$I].FileObject -eq $FileObject) {
          $UseFilenames += $global:UseNamesList[$I].Usename
          $global:UseNamesList[$I].IsSentToProgram = $true;
        }
        if ($Filename -eq $global:UseNamesList[$I].Usename) {
          #It is possible that the (short) filename is also a usename for a file (different or the same one)
          #Don't store the filename in that case
          $FilenameIsUsename = $true
        }
      }
      <#
      if ($UseFilenames.Count -le 0) {
        # it may be a cycle file in which case there may not be 
        # a match because of the parenthesized suffix
        # In a separate loop, filename may have duplicates to be filtered by Fullname first.
        for ([Int32]$I = 0; $I -lt $global:UseNamesList.Count; $I++) {
          if ($global:UseNamesList[$I].Filename -eq $FileObject.FileName) {
            $UseFilenames += $global:UseNamesList[$I].Usename
          }
        }
      }
      #>
      # Add the usefile information to the task value list.
	  [String]$FullName = ""                                            
	  [String]$FullName27 = ""                                          
	  if ($FileObject.FileHandle -ne $null) {                           
	    if ($FileObject.FileHandle.FullName -ne $null) {                
		  $FullName = $FileObject.FileHandle.FullName                   
		  if ($FullName.Length -gt 27) {                                
		    $FullName27 = $FileObject.FileHandle.FullName.SubString(27) 
		  }                                                             
		}                                                               
	  }                                                                 
      if ($UseFilenames.Count -gt 0) {
        foreach ($UseFilename in $UseFilenames) {
          $ObjTask.SetTVCustom($UseFilename, $FullName)                 
          $ObjTask.SetTVCustom($UseFilename + "_ASGOPTIONS", $FileObject.AsgOptions + "|" + $FileObject.Filename)
          Write-JobLog ($UseFilename.PadRight(12) + "`t" + $FullName27) ([LoggingSeverity]::Debug)             
          $ObjTask.SetTVCustom($UseFilename + '_ISUSEFILE', 'T')
        }
      }

      # Add logical file and its physical filepath as task value
      # $ObjTask.SetTVCustom($Filename, $FileObject.Filename)
      if (($FileObject.FileHandle -ne $null) -and ($ObjTask.GetTVCustom($Filename) -eq '') -and (-not $FilenameIsUsename)) {      
        $ObjTask.SetTVCustom($Filename, $FullName)                                                             
        $ObjTask.SetTVCustom($Filename + "_ASGOPTIONS", $FileObject.AsgOptions + "|" + $FileObject.Filename)
        Write-JobLog ($Filename.PadRight(12) + "`t" + $FullName27) ([LoggingSeverity]::Debug)                  
      }
    }
  }

  # Go through the global usenames list and determine which use name was not sent to the program and then sent that file to the program.
  # This can happen if the USE is done without an assign being done first.
  foreach ($useNameItem in $global:UseNamesList) {
    if (-not $useNameItem.IsSentToProgram) {
      [String]$Filename = (Add-FileExtension $useNameItem.FileName $global:UseExtension)
      $ObjTask.SetTVCustom($useNameItem.Usename, $Filename)
      $ObjTask.SetTVCustom($useNameItem.Usename + '_ISUSEFILE', 'T')
    }
    $useNameItem.IsSentToProgram = $false #reset
  }

  # should this report's recovery point be deleted?
  if ($global:Overwrite -and -not $global:Overwritten) {

    if (-not $global:Restart) {
      Abort "Recovery options are only valid in restart mode."
	}

    [Int32]$RecoveryPointCount = GetRecoveryPointCount $global:Com.AppId $Report $global:RecoverId
    if ($RecoveryPointCount -gt 1) {
      [String]$Msg = "The overwrite request cannot be fulfilled, the recovery point specification does not identify a single existing recovery point."
      [Int32[]]$ProcessJobIds = $global:Com.GetRecoverableProcessJobs($global:Com.AppId, $Report)
      $Msg += "`r`nReport name    : $Report"
      $Msg += "`r`nRecovery points: $ProcessJobIds"
      Abort $Msg
    }

    if ($RecoveryPointCount -eq 0) {
      if ($SpecifiedRecoverId -eq -1) {
        Add-WarningMsg "No recovery point found to be deleted, continuing..." 
      } else {
        Abort "No recovery point with id=$SpecifiedRecoverId exists."
	  }
    } else {
      # delete the recovery point
      [String]$Response = (Accept "Are you sure you want to delete recovery point $global:RecoverId ? (y/n)" $Report).ToUpperInvariant()
      if ($Response -ne "Y") {
        Abort "Aborted in response to the user's answer to confirm the deletion of recovery point $global:RecoverId."
      }

      $global:Com.DeleteRecoverableProcessJobs($global:Com.AppId, $Report, $global:RecoverId)

      # we do not want to do this again for this script run
      $global:Overwritten = $true

      # check if it is gone
      [Int32[]]$ProcessJobIds = $global:Com.GetRecoverableProcessJobs($global:Com.AppId, $Report)
      if ($ProcessJobIds.Contains($global:RecoverId)) {
        Abort "The recovery point for job $global:RecoverId could not be deleted."
      } else {
        Add-InformationMsg "The recovery point for job $global:RecoverId was successfully deleted."
	  }
    }

    # we are done deleting, reset RecoverId to -1
    $global:RecoverId = -1
  }

  [Int32]$RecoveryPointCount = GetRecoveryPointCount $global:Com.AppId $Report

  # if this is to be a restart without recovery, we should not have any recovery points for this report
  if ($global:Restart -and ($RecoveryPointCount -gt 0) -and (-not $global:Recover) -and (-not $global:overwritten)) {
    [String]$Msg = "One or more recovery points were found for report $Report."
    [Int32[]]$ProcessJobIds = $global:Com.GetRecoverableProcessJobs($global:Com.AppId, $Report)
    $Msg += "`r`nEither use the /r(ecover) option to recover from the recovery point or the /o(verwrite) option to delete the recovery point(s)."
    $Msg += "`r`nRecovery point id(s): $ProcessJobIds"
    Abort $Msg
  }

  # should this report be recovered?
  if ($global:Recover -and -not $global:Recovered) {

    if (-not $global:Restart) {
      Abort "Recovery options are only valid in restart mode."
    }

    [Int32[]]$ProcessJobIds = $global:Com.GetRecoverableProcessJobs($global:Com.AppId, $Report)
    [Boolean]$NoRecoveryPointSpecifiedAndNotExactlyOneAvailable = ($SpecifiedRecoverId -eq -1) -and ($RecoveryPointCount -ne 1)
    [Boolean]$RecoveryPointSpecifiedAndNotAvailable = ($SpecifiedRecoverId -ne -1) -and (-not $ProcessJobIds.Contains($SpecifiedRecoverId))

    if ($NoRecoveryPointSpecifiedAndNotExactlyOneAvailable -or $RecoveryPointSpecifiedAndNotAvailable) {
      [String]$Msg = "The recovery request cannot be fulfilled, the recovery point specification does not identify a single existing recovery point."
      $Msg += "`r`nReport name    : $Report"
      $Msg += "`r`nRecovery points: $ProcessJobIds"
      Abort $Msg
    }

    # recover from recovery point
    $ObjTask.RecoverCriticalReport = $true

    # we do not want to do this again for this script run
    # $global:RecoverId will be reset to -1 after first use
    $global:Recovered = $true
  }

  for ([Int32]$I = 12; $I -le 35; $I++) {
    [Int32]$Sw = $I - 11
    if ($global:RcwBits[$I] -eq 1) {
      $ObjTask.SetTVCustom("SW$Sw", "T")
    } else {
      $ObjTask.SetTVCustom("SW$Sw", "F")
    }
  }

  $ObjTask.SetTVCustom("QUAL", $global:DefaultQual)
  $ObjTask.SetTVCustom("TPF", $global:TempFolder)

  if ($global:AcceptOpen) {
    $global:AcceptFile.Close() | Out-Null
    $global:AcceptOpen = $false
    [String]$AcceptFilePath = "$global:TempFolder\Accept_File"
    # Check whether an extension has to be added
    $AcceptFilePath = Add-FileExtension $AcceptFilePath $global:UseExtension
    Add-AcceptFile $AcceptFilePath $ObjTask
  }

  $global:FirstExtractFile = $true

  # Cloning support
  if ($global:CloneReports) {
    $Original = $global:CloneReports | where { $_.Clone -eq $Report }
    if ($Original -and $Original.Name -ne "") {
   	  $ObjTask.AlternativeReportName = $Report
      $Report = $Original.Name
    } else {
  	  $ObjTask.AlternativeReportName = ""
    }
  }

  function ReportOrAlternative {
    if ($ObjTask.AlternativeReportName -eq $null -or $ObjTask.AlternativeReportName -eq "") {
      return $Report
    } else {
      return $ObjTask.AlternativeReportName
    }
  }

  $IsReport = $false
  [Object]$ReportStartDate = Get-Date
  #For AMT Lion a Do While Loop may start here so a report can be restarted multiple times.
  #For AMT Cobol we don't need this so it was removed.

  # Check if the report is available as report or executable, if so add job request with this type.
  # First try jobtype Report
  [Int32]$JobId = $global:Com.JobIdByJobName($Report, $global:Const_JobType_Report)
  if ($JobId -ne -1) {
    $IsReport = $true

    if ($global:Debug) {
      Write-JobLog "Starting report: $Report (Debug)" ([LoggingSeverity]::Info)
    } else {
      Write-JobLog "Starting report: $Report" ([LoggingSeverity]::Info)
    }  

    if ($ObjTask.RecoverCriticalReport) {
      # do not try to recover a report that is not recoverable
      [Int32]$Rpc = GetRecoveryPointCount $global:Com.AppId (ReportOrAlternative)
      if ($Rpc -eq 0) {
        Abort "There is no recovery point for report $Report, the report cannot be recovered."
      }
    }


    $RequestId = $ObjTask.AddJobRequest($Report, $global:Const_JobType_Report, $global:RecoverId)
  } else {
    # Try jobtype Executable
    $JobId = $global:Com.JobIdByJobName($Report, $global:Const_JobType_Executable)
    if ($JobId -ne -1) {
      if ($global:Debug) {
        Write-JobLog "Starting executable: $Report (Debug)" ([LoggingSeverity]::Info)
      } else {
        Write-JobLog "Starting executable: $Report" ([LoggingSeverity]::Info)
      }  

      if ($ObjTask.RecoverCriticalReport) {
        # do not try to recover a report that is not recoverable
        [Int32]$Rpc = GetRecoveryPointCount $global:Com.AppId (ReportOrAlternative)
        if ($Rpc -eq 0) {
          Abort "There is no recovery point for report $Report, the report cannot be recovered."
        }
      }

      $RequestId = $ObjTask.AddJobRequest($Report, $global:Const_JobType_Executable, $global:RecoverId)
    } else {
      # Try jobtype COBOL Program
      $JobId = $global:Com.JobIdByJobName($Report, $global:Const_JobType_CobolProgram)
      if ($JobId -ne -1) {
        if ($global:Debug) {
          Write-JobLog "Starting Cobol program: $Report (Debug)" ([LoggingSeverity]::Info)
        } else {
          Write-JobLog "Starting Cobol program: $Report" ([LoggingSeverity]::Info)
        }  
        
        if ($ObjTask.RecoverCriticalReport) {
          # do not try to recover a report that is not recoverable
          [Int32]$Rpc = GetRecoveryPointCount $global:Com.AppId (ReportOrAlternative)
          if ($Rpc -eq 0) {
            Abort "There is no recovery point for report $Report, the report cannot be recovered."
          }
        }

        $RequestId = $ObjTask.AddJobRequest($Report, $global:Const_JobType_CobolProgram, $global:RecoverId)
      } else {                
        #Joblog was not closed, don't open it again....
        #$global:JobLogObj = Open-TextFile $global:JobLogFile $global:Const_ExclusiveBatch $global:Const_FileEnc_Autodetect $true
        Abort "Report [$Report] not found (JobIdByJobName returned -1)"
      }
    }
  }

  if ($ObjTask.running -eq $true) {
	Write-Host "Job not finished. Waiting...."
  }
  while($ObjTask.running -eq $true) { # Extra check. The job should be done already here.    
    Start-Sleep -Milliseconds 100
  }

  # get result
  $JobState = $ObjTask.JobState

  #The AMT Lion loop should end here.

  if ($JobState -ne $global:Const_JobState_Done) {
    Abort ("The report failed with JobState `"{0}`"." -f (JobStateName($JobState)))
  }

  if ($global:UseJobLog) {
    [Object]$Timespan = New-TimeSpan -Start $ReportStartDate -End $(Get-Date)
    [String]$Msg = "End Report. Time {0:D2}:{1:D2}:{2:D2}" -f  $Timespan.Hours, $Timespan.Minutes, $Timespan.Seconds
    Write-JobLog $Msg ([LoggingSeverity]::Info)
  }

  $global:MyTaskValue = Get-JobValue $ObjTask

  $ObjTask.ClearBatchFiles()
  $ObjTask.ClearPrintFileNames()

  if ($global:Recover) {
    if ($global:RecoverId -eq -1) {
      # note: Only if this is not a recovery run, CompletedOk will be valid
      #       if it is a recovery run, the status of the earlier failed run 
      #       will be returned.
      if (-not(Get-CompletedOk $ObjTask)) {
        if ($global:SetcA) {
          Abort "Error in report '$Report'. "
        } else {
          $global:Message = "Error in report '$Report'. Job continued."
          Add-ErrorMsg $global:Message
        }
      }
    } else {
      # Check for the existence of processjob with id = $global:RecoverId.
      # If it is still there, the recovery failed and we want to abort. If 
      # it is gone, the recovery succeeded.
      [Int32[]]$ProcessJobIds = $global:Com.GetRecoverableProcessJobs($global:Com.AppId, $Report)
      if ($ProcessJobIds.Contains($global:RecoverId)) {
        Abort "The recovery of job $global:RecoverId failed."
      } else {
        Add-InformationMsg "The recovery of job $global:RecoverId succeeded."
      }
    }
  }

  for ([Int32]$I = 1; $I -le 24; $I++) {
    [String]$TCValue = $ObjTask.GetTVCustom("SW$I")
    [Int32]$IRcw = $I + 11
    if ($TCValue -eq "T") {
      $global:RcwBits[$IRcw] = 1
      Write-JobLog "SW$I T" ([LoggingSeverity]::Debug)
    } else {
      $global:RcwBits[$IRcw] = 0
      Write-JobLog "SW$I F" ([LoggingSeverity]::Debug)
    }
  }

  Process-AssignedInProgram $ObjTask
  Process-FreedInProgram $ObjTask

  Free-AsgI 

  # Set boolean to FALSE (to indicate it is not cleared) for resetting the task object.
  if ($global:TaskObjectsList.ContainsKey($ObjTask.JobText)) {
    $global:TaskObjectsList.Item($ObjTask.JobText) = $false
  }

  if (($ObjTask.ErrorCode -ne 0) -and ($global:RecoverId -eq -1)) { 
    # $ObjTask.ErrorCode will be from a prior failed run in case of a recovery
    Abort "Error in Xqt: $($ObjTask.ErrorCode) : $($ObjTask.ErrorDescription)"
  }

  # In case this was a recovery run, reset recovery id to -1 so we will not 
  # try to recover any reports that are executed later in this script run.
  $global:RecoverId = -1
} # End-Xqt


function Accept-Write {
  <#
    .DESCRIPTION
      Write line into Accept file for the XQT statement
    .PARAMETER Line
      [String] Line to write
  #>

  param (
    [String]$Line
  )

  Set-FileControlError 0

  [String]$Statement = "Accept-Write Accept_File"
  if ((Check-Jump) -or ($global:Rcw)) {
    $Statement = "Skipped  $Statement"
    Write-JobLog $Statement ([LoggingSeverity]::Debug)
    return
  }

  if (-not ($global:AcceptOpen)) {
    [String]$AcceptFilePath = "$global:TempFolder\Accept_File"
    # Check whether an extension has to be added
    $AcceptFilePath = Add-FileExtension $AcceptFilePath $global:UseExtension
    $global:AcceptFile = Create-TextFile $AcceptFilePath $global:Const_ExclusiveBatch $false $true
    $global:AcceptOpen = $true
  }
  $global:AcceptFile.WriteLine($Line, $true) | Out-Null
  Write-JobLog $Line ([LoggingSeverity]::Info)

  $global:ErrorCode = $global:AmtFile.ErrorCode
  $global:ErrorDescription = $global:AmtFile.ErrorDescription    
  Set-FileControlError $global:AmtFile.ErrorCode

  if (-not(Check-FileControlError 0)) {
    Abort $global:ErrorDescription
  }
} # Accept-Write


function Check-FinishStatement {
  <#
    .DESCRIPTION
      Check if there is a statement (with datalines) pending and finish it.
  #>

  if ($global:PreviousStatement -eq [EclDatalineStatement]::None) {
    return
  }

  switch ($global:PreviousStatement) {
    ([EclDatalineStatement]::Data) { 
      # nothing to do
    }  

    ([EclDatalineStatement]::Sort) { 
      Sort-Execute
    }  

    ([EclDatalineStatement]::Xqt) { 
      End-Xqt 
    }
  }
  $global:PreviousStatement = [EclDatalineStatement]::None
} # Check-FinishStatement


function Check-ReportName {
  <#
    .SYNOPSIS
      Check and modify the name of the report.
    .DESCRIPTION
      Check and modify the name of the report.
      Replace "\","/" and "-" with "_", etc.
    .PARAMETER ReportName
      [String] The name of the report.
    .OUTPUTS
      [String] Checked and corrected report name
  #>

  param (
    [Parameter(Mandatory=$true)][String]$ReportName
  )

  $ReportName = $ReportName.Trim()
  $ReportName = $ReportName.Replace('\','_')
  $ReportName = $ReportName.Replace('/','_')
  $ReportName = $ReportName.Replace('-','_')

  [Int32]$Index = $ReportName.IndexOf(".")
  if ($Index -gt -1) {
    if ($ReportName.EndsWith(".")) {
      $ReportName = $ReportName.Substring(0, $ReportName.Length - 1)  # strip dot at end
    } elseif ($ReportName.Substring($Index).ToUpperInvariant() -ne ".EXE") {
      $ReportName = $ReportName.Substring($Index + 1)  # strip path info, we know where the reports are
    }
  }

  if ($ReportName.Length -gt 40) {
    $ReportName = $ReportName.Substring(0, 40)
  }

  # If report name starts with number, precede it with "ASY_"
  if ($ReportName[0] -match "[0-9]") {
    $ReportName = "ASY_" + $ReportName
  }

  $ReportName = $ReportName.Trim()
  return $ReportName
} # Check-ReportName


function Check-UseName {
  <#
    .SYNOPSIS
      Checks if a filename is a use name. If true, return the corresponding filename.
      s_FileName: String containing file name or UseName plus updated Cycle
    .PARAMETER Filename
      [String] String containing a Filename or UseName to check.
    .OUTPUTS
      Corresponding filename.
  #>

  param (
    [String]$Filename
  )

  $global:UseFound = $false

  if ($Filename.IndexOf("\") -gt -1) {
    # Can't be a UseName
    return $Filename
  }

  [Boolean]$Found = $false
  [String]$File   = $Filename
  [Int32]$I       = 0

  for ($I = 0; $I -lt $global:UseNamesList.Count; $I++) {
    if ($global:UseNamesList[$I].Usename -eq $Filename) {
      $Found = $true
      $global:UseFound = $true
      break
    }
  }

  if ($Found) {
    $File = $global:UseNamesList[$I].Filename
    $global:FileObject = $global:UseNamesList[$I].FileObject
    if ($File.IndexOf("\") -gt -1) {
      # Can't be a use name, so must be the filename
    } else {
      # Use name which uses another UseName so search again
      $File = Check-UseName $File 
      $global:UseFound = $true
    }
  }

  return $File
} # Check-UseName


function Get-FileName {
  <#
    .SYNOPSIS
      Removes the extract path or temporary folder from a filepath, 
      so only the filename is returned.
    .PARAMETER Filename
      [String] Filename
  #>

  param (
    [String]$Filename
  )

  if ($Filename.StartsWith($global:TempFolder)) {
    return $Filename.Substring($global:TempFolder.Length + 1)
  } elseif ($Filename.StartsWith($global:ExtractPath)) {
    return $Filename.Substring($global:ExtractPath.Length + 1)
  } else {
    return $Filename
  }
} # Get-FileName


function Create-TempFolder {
  <#
    .SYNOPSIS
      Creates a temporary folder for the running job.
  #>

  [String]$Tpf = (Add-BackSlash $global:ExtractPath) + "TPF`$"
  $Tpf += Get-UniqueNumber

  if (!(Folder-Exists $Tpf)) {
    if (-not (Create-Folder $Tpf)) {
      Add-ErrorMsg "Could not create folder $Tpf"
    }
  }

  $global:TempFolder = $Tpf
} # Create-TempFolder

function Filename-ToShortName {
  <#
    .SYNOPSIS
      Create a short name without qualifier and extension from filename
    .PARAMETER Filename
      [String] The name of the file.
    .OUTPUTS
      [String] Short name

  #>
  param (
    [String]$Filename
  )

  [String]$ShortName = $Filename.Replace("/", "\").Trim()
  [Int32]$Index = $ShortName.LastIndexOf('\')
  if ($Index -gt -1) {
    $ShortName = $ShortName.Substring($Index + 1)
  }
  if ($ShortName.EndsWith(')')) {
    $Index = $ShortName.LastIndexOf('(')
    if ($Index -gt -1) {
      $ShortName = $ShortName.Substring(0, $Index)
    }
  }
  if ($ShortName.IndexOf($global:Extension) -gt -1) {
    $ShortName = $ShortName.Substring(0, $ShortName.Length - $global:Extension.Length)
  }
  return $ShortName
}


function AddTo-FileArray {
  <#
    .SYNOPSIS
      Adds file information to the assigned file array.
    .PARAMETER Filename
      [String] The name of the file as used in the script
    .PARAMETER FileDeleteFin
      [Boolean] True or False for deleting the file after a free command False -> no delete; True -> delete.
    .PARAMETER FileCopy
      [String] The name of the copied file if it is exclusive assigned. Empty when it is a temporary file.
    .PARAMETER FileDeleteError
      [String] True or False for deleting the file If a job has gone into error.
    .PARAMETER FileRead
      [String] Whether the file is being read or not.
     .PARAMETER WindowsFilename
      [String] Filename as with windows path
    .PARAMETER Cataloged
      [Boolean] True if cataloged file, else false.
    .PARAMETER AsgI
      [Boolean] True if ASG,I is used, else false.
    .PARAMETER AsgOptions
      [String] The ASG Options
  #>

  param (
    [String]$Filename,
    [Boolean]$FileDeleteFin,
    [String]$FileCopy,
    [Boolean]$FileDeleteError,
    [Boolean]$FileRead,
    [Boolean]$Assigned,
    [String]$WindowsFilename,
    [Boolean]$Cataloged,
    [Boolean]$AsgI,
    [String]$AsgOptions
  )

  [Int32]$Read = 0
  if ($FileRead) {
    $Read = 1
  } else {
    $Read = 0
  }

  [String]$ShortName = Filename-ToShortName $Filename
  #[String]$BasePath = Get-PathName ([Ref]$ShortName)

  # Check if file was already added
  for ([Int32]$I = 0; $I -lt $global:FilesList.Count; $I++) {
    if (($global:FilesList[$I].Filename -eq $Filename) -or
        (($global:FilesList[$I].FileHandle -ne $null) -and ($global:FilesList[$I].FileHandle.FullName -eq $WindowsFilename))) {

      $global:FileObject = $global:FilesList[$I]

      [Boolean]$IsNewFile = $false
      if ($FileCopy -ne "") {
        # it is probably a +1 cycle, it has nothing to do with the old entry
        $IsNewFile = $true  
      }

      #if (($IsNewFile) -or ($CycleName -ne "")) {
      #  $global:FileObject.Cyclename      = $CycleName
      #}

      $global:FileObject.FileHandle      = $global:FileHandle
      $global:FileObject.DeleteOnFree    = $FileDeleteFin
      $global:FileObject.Copyname        = $FileCopy
      $global:FileObject.DeleteOnError   = $FileDeleteError
      $global:FileObject.ChangeReadOnly  = $Read

      if ($IsNewFile -or (-not ($global:FileObject.IsAssigned))) {
        $global:FileObject.IsAssigned    = $Assigned
      }

      if ($IsNewFile -or (-not ($global:FileObject.IsCataloged))) {
        # do not reset this property on Asg if Cat was already done
        $global:FileObject.IsCataloged   = $Cataloged
      }

      $global:FileObject.CHG_N_name      = ""
      $global:FileObject.IsASG_I         = $AsgI
      $global:FileObject.ShortName       = $ShortName
      $global:FileObject.WindowsFilename = $WindowsFilename

      return
    }
  }

  # Add new entry to the files list
  $global:FileObject = New-Object PSObject
  $global:FileObject | Add-Member -Name Filename        -Value $Filename          -MemberType NoteProperty
  #$global:FileObject | Add-Member -Name Cyclename      -Value $Cyclename         -MemberType NoteProperty
  $global:FileObject | Add-Member -Name FileHandle      -Value $global:FileHandle -MemberType NoteProperty
  $global:FileObject | Add-Member -Name DeleteOnFree    -Value $FileDeleteFin     -MemberType NoteProperty
  $global:FileObject | Add-Member -Name Copyname        -Value $FileCopy          -MemberType NoteProperty
  $global:FileObject | Add-Member -Name DeleteOnError   -Value $FileDeleteError   -MemberType NoteProperty
  $global:FileObject | Add-Member -Name ChangeReadOnly  -Value $Read              -MemberType NoteProperty
  $global:FileObject | Add-Member -Name IsAssigned      -Value $Assigned          -MemberType NoteProperty
  $global:FileObject | Add-Member -Name IsCataloged     -Value $Cataloged         -MemberType NoteProperty
  $global:FileObject | Add-Member -Name CHG_N_name      -Value ""                 -MemberType NoteProperty
  $global:FileObject | Add-Member -Name IsASG_I         -Value $AsgI              -MemberType NoteProperty
  $global:FileObject | Add-Member -Name ShortName       -Value $ShortName         -MemberType NoteProperty
  $global:FileObject | Add-Member -Name WindowsFilename -Value $WindowsFilename    -MemberType NoteProperty
  $global:FileObject | Add-Member -Name AsgOptions      -Value $AsgOptions        -MemberType NoteProperty
  $global:FilesList.Add($global:FileObject)


} # AddTo-FileArray


function Check-Qual {
  <#
    .SYNOPSIS
      Checks whether a filename already contains the qualifier. If not, it will be added.
    .PARAMETER Filename
      [String] The name of the file.
    .OUTPUTS
      [String] <path>\<filename>\<filename>
  #>

  param (
    [String]$Filename
  )

  if ($global:FirstQual) {
    Abort "Check-Qual: No project qualifier set."
  }

  [Int32]$Pos = -1
  [String]$Result = $Filename

  if ($Filename -eq "") {
    return $Result
  }

  if (($Filename.Substring(0,1) -eq "\") -and ($Filename.Substring(0,2) -ne "\\")) {
    $Filename = (Add-BackSlash $global:ImpliedQual) + $Filename
  }

  if ($Filename.IndexOf("/") -gt -1) {
    $Filename = $Filename.Replace("/", "\")  #Qual/Filename
  }

  if ($Filename.Contains($global:QualPath)) {
    $Result = $Filename
  } else {
    if ($Filename.Contains($global:ExtractPath)) {
      $Pos = $global:QualPath.Length + 1
      $Result = $Filename
    } else {
      if ($Filename.IndexOf("\") -eq -1) {
        $Result = (Add-BackSlash $global:QualPath)
        $Result += $Filename
      } else {
        $Pos = $Filename.IndexOf("\") + 1
        $Result = (Add-BackSlash $global:ExtractPath)
        $Result += $Filename
      }
    }
  }

  return $Result
} # Check-Qual


function Assign-ReadWriteFile {
  <#
    .SYNOPSIS
      ECL equivalent: ASG,A <Filename>
    .DESCRIPTION
      Locks the original file.
      When the file is readonly or the R option is used the lock is not executed.
    .PARAMETER Filename
      [String] File to be assigned
    .PARAMETER FileDeleteFin
      [Boolean] True or False for deleting the file after a free command.
    .PARAMETER FileDeleteError
      [Boolean] True or False for deleting the file If a job has gone into error.
    .PARAMETER AsgFile
      [String] Filename as used in the script on the Asg statement
    .PARAMETER OptionZ
      [Boolean] True/False whether ASG option Z is set.
    .PARAMETER OptionI
      [Boolean] True/False whether ASG option I is set.
    .PARAMETER OptionR
      [Boolean] True/False whether ASG option R is set.
    .PARAMETER AsgOptions
      [String] The ASG Options
    .PARAMETER FileExists
      [Boolean] True when the file exists, this should be the case
  #>

  param (
    [String]$Filename,
    [Boolean]$FileDeleteFin,
    [Boolean]$FileDeleteError,
    [String]$AsgFile,
    [Boolean]$OptionZ,
    [Boolean]$OptionI,
    [Boolean]$OptionR,
    [String]$AsgOptions,
    [Boolean]$FileExists
  )

  [Int32]$Counter = 0
  $global:FileHandle = $null  
  Set-FileControlError 0

  if (-not $FileExists) {
    $global:Message = (Get-FileName $Filename) + " does not exist."
    Set-FileControlError 71 "File does not exist."
    return
  }

  [String]$AssignFile = $Filename
  #if (($global:FileObject -ne $null) -and ($global:FileObject.FileHandle -ne $null)) {
    # when file is a cycled file, we must reference it with it's fullname
  #  $AssignFile = $global:FileObject.FileHandle.FullName
  #} 

  [Boolean]$ReadOnly = Get-ReadOnly $Filename $FileExists
  if (($ReadOnly) -or ($OptionR)) {
    $global:FileHandle = Fco-AssignFile $AssignFile $global:Const_SharedRead $true
  } else {
    # Changed from: $global:Const_SharedReadWrite
	# to exclusiveBatch after ko/ef discussion that reports should also be able to access the file.
    $global:FileHandle = Fco-AssignFile $AssignFile $global:Const_ExclusiveBatch $true
  }

  while (!(Check-FileControlError 0)) {
    $Counter = Wait-ForFile $Filename $Counter

    if ($OptionZ) {
      if (Check-FileInUse $Filename) {
        Set-FileControlError 70 "File in use by another process."
        return
      }
    }

    if (($ReadOnly) -or ($OptionR)) {
      $global:FileHandle = Fco-AssignFile $AssignFile $global:Const_SharedRead $true
    } else {
      $global:FileHandle = Fco-AssignFile $AssignFile $global:Const_ExclusiveBatch $true
    }
  }

  [String]$PathName = Get-PathName ([Ref]$Filename)  # Removes path from filename

  AddTo-FileArray $AsgFile $FileDeleteFin "" $FileDeleteError $false $true ((Add-BackSlash $PathName) + $Filename) $true $OptionI $AsgOptions
  #                                                         FileRead Assigned  WindowsFilename                   Cataloged
} # Assign-ReadWriteFile


function Process-ConditionalFile {
  <#
    .SYNOPSIS
      Process conditional file for ASG,C / ASG,U
    .DESCRIPTION
      Create complete filename.
      Input: Original filename without extractpath and _nnn.DAT
      Output: Complete filename
    .PARAMETER Filename
      [String] File to be assigned
    .PARAMETER Cycle
      [Ref] File cycle.
  #>

  param (
    [String]$Filename
    #[Ref]$Cycle
  )

  Set-FileControlError 0

  # if an assign is being done first check if the s_FileName is UseName, if so use the correct filename
  $Filename = Check-UseName $Filename 
  # After getting the correct filename or usename add the qualifier to the name
  $Filename = Check-Qual $Filename

  [String]$CycleNew = Find-Cycle $Filename
  if ($CycleNew -ne "") {    
    if ($CycleNew.StartsWith("+")) {
      if ($CycleNew -gt 1) {
        Abort "+ cycle > 1"
      }
    } else {
      if ($CycleNew.StartsWith("-")) {
        Abort "Negative Cycle not allowed"
      }
    }
  }

  $Filename = (Add-FileExtension $Filename $global:UseExtension)
  if (File-Exists $Filename) {
    [Object]$FileInfo = $global:AmtFile.GetFileInfo($Filename, 1)  
    if (-not ($FileInfo.Exists)) {
      #File-Exists returnd true but the FileInfo Exists returns false, 
      #likely to be an empt cycles folder, Delete-File makes the file-controller to delete the folder
      Delete-File $Filename
      if (File-Exists $Filename) {
        #Still exists, something is wrong.
        Set-FileControlError 58 "File [$($Filename)] already exists."
      }
    } else {
      Set-FileControlError 58 "File [$($Filename)] already exists."
    }
  }

  return $Filename
} # Process-ConditionalFile


function Assign-ConditionalFile {
  <#
    .SYNOPSIS
      ECL equivalent: ASG,C <Filename>
    .DESCRIPTION
      Create file in TPF$ The original file will be created when the file is freed.
      If the file has no plus cycle, the file will be assigned to avoid other runs 
      from doing an ASG,C or ,U on the same file.
    .PARAMETER Filename
      [String] File to be assigned
    .PARAMETER ReadOnly
      [Boolean] True or False whether the file is read only.
    .PARAMETER AsgFile
      [String] Filename as used in the script on the Asg statement.
    .PARAMETER OptionI
      [Boolean] True/False whether ASG option I is set.
    .PARAMETER AsgOptions
      [String] The ASG Options
  #>

  param (
    [String]$Filename,
    [Boolean]$ReadOnly,
    [String]$AsgFile,
    [Boolean]$OptionI,
    [String]$AsgOptions
  )

  $global:FileHandle = $null
  [Int32]$Pos = -1
  [String]$PathName = Get-PathName ([Ref]$Filename)  # Removes path from filename

  [String]$AssignFile = $Filename
  # Check same filenames having a plus cycle 
  [String]$Cycle = Find-Cycle $AssignFile
  if ($Cycle.StartsWith("+")) { 
    Check-MorePlus $AssignFile
  }

  $Pos = $AssignFile.IndexOf($global:TempFolder)
  if ($Pos -gt -1) {
    $AssignFile = $AssignFile.Substring($global:TempFolder.Length + 1)
  }

  $Pos = $AssignFile.IndexOf($global:ExtractPath)
  if ($Pos -gt -1) {
    $AssignFile = $AssignFile.Substring($global:ExtractPath.Length + 1)
  }

  [Boolean]$Result = Create-EmptyFile ((Add-BacKSlash $global:TempFolder) + $AssignFile)

  if (-not ($Cycle.StartsWith("+"))) {
    # Absolute cycle so the file must be assigned to avoid another run to use the same file name.
    [String]$File = $global:FileHandle.FullName
    $global:FileHandle = Fco-AssignFile $File $global:Const_ExclusiveBatch $false

    if (Check-FileControlError 95) {
      # File in use so another run has also an ASG,C on this file, reject request.
      Abort "Another process has executed an conditional assign for the same file."
    }
  }

  [String]$TempFile = (Add-BackSlash $global:TempFolder) + $Filename
  AddTo-FileArray $AsgFile $false $TempFile $true $ReadOnly $true ((Add-BackSlash $PathName) + $Filename) $false $OptionI $AsgOptions
#                       FileDeleteFin   FileDeleteError     Assigned  WindowsFilename                   Cataloged

} # Assign-ConditionalFile


function Assign-UnconditionalFile {
  <#
    .SYNOPSIS
      ECL equivalent: ASG,U <Filename>
    .DESCRIPTION
      Create file in TPF$ The original file will be created when the file is freed.
    .PARAMETER Filename
      [String] File to be assigned
    .PARAMETER ReadOnly
      [Boolean] True or False whether the file is read only.
    .PARAMETER AsgFile
      [String] Filename as used in the script on the Asg statement.
    .PARAMETER OptionI
      [Boolean] True/False whether ASG option I is set.
    .PARAMETER AsgOptions
      [String] The ASG Options
  #>

  param (
    [String]$Filename,
    [Boolean]$ReadOnly,
    [String]$AsgFile,
    [Boolean]$OptionI,
    [String]$AsgOptions
  )

  $global:FileHandle = $null
  [Int32]$Pos = -1
  [String]$PathName = Get-PathName ([Ref]$Filename)  # Removes path from filename

  [String]$AssignFile = $Filename
  
  # Check same filenames having a plus cycle 
  [String]$Cycle = Find-Cycle $AssignFile
  if ($Cycle.StartsWith("+")) { 
    Check-MorePlus $AssignFile
  }

  $Pos = $AssignFile.IndexOf($global:TempFolder)
  if ($Pos -gt -1) {
    $AssignFile = $AssignFile.Substring($global:TempFolder.Length + 1)
  }

  $Pos = $AssignFile.IndexOf($global:ExtractPath)
  if ($Pos -gt -1) {
    $AssignFile = $AssignFile.Substring($global:ExtractPath.Length + 1)
  }

  [Boolean]$Result = Create-EmptyFile ((Add-BacKSlash $global:TempFolder) + $AssignFile)

  if (-not ($Cycle.StartsWith("+"))) {
    # Absolute cycle so the file must be assigned to avoid another run to use the same file name.
    [String]$File = $global:FileHandle.FullName
    $global:FileHandle = Fco-AssignFile $File $global:Const_ExclusiveBatch $false

    if (Check-FileControlError 95) {
      # File in use so another run has also an ASG,C on this file, reject request.
      Abort "Another process has executed an conditional assign for the same file."
    }
  }

  [String]$TempFile = (Add-BackSlash $global:TempFolder) + $Filename
  AddTo-FileArray $AsgFile $false $TempFile $false $ReadOnly $true ((Add-BackSlash $PathName) + $Filename) $false $OptionI $AsgOptions
} # Assign-UnconditionalFile


function Check-MorePlus {
  <#
    .SYNOPSIS
      Checks whether the provided file has previously been assigned with a plus cycle,
      because his is not allowed.
    .PARAMETER Filename
      [String] File to be checked.
  #>

  param (
    [String]$Filename
  )

  [String]$FileNoExt = $global:ExtractPath + $Filename.Substring(0, $Filename.Length - 8)

  for ([Int32]$I = 0; $I -lt $global:FilesList.Count; $I++) {
    if ((Find-Cycle $global:FilesList[$I].Filename).StartsWith("+")) {
      [String]$File = $global:FilesList[$I].Filename
      if (($File.Substring(0, $File.Length -8) -eq $FileNoExt) -and ($global:FilesList[$I].IsAssigned)) {
        Abort "Plus cycle already assigned."
      }
    }
  }
} # Check-MorePlus


function Create-EmptyFile {
  <#
    .SYNOPSIS
      Creates an empty file which is not assigned to the job.
    .PARAMETER Filename
      [String] File to be created.
    .PARAMETER AbortOnFailure
      [Boolean] If $true the function will aborts in case of a failure, if $false a boolean 
      value is returned indicating either success ($true) or failure ($false).
    .OUTPUTS
      [Boolean] $true on success, $false on failure if AbortOnFailure = $true.
  #>

  param (
    [String]$Filename,
    [Boolean]$AbortOnFailure=$true
  )

  Set-FileControlError 0
  [Int32]$Pos = $Filename.LastIndexOfAny("\")
  Replace-Asterisks ([Ref]$Filename)

  $Folder = $Filename.Substring(0, $Pos)
  if (!(Folder-Exists $Folder)) {
    if (-not (Create-Folder $Folder)) {
      Add-ErrorMsg "Could not create folder $Folder"
    }
  }

  if ($Filename.Substring($Pos + 1).IndexOf("(") -gt -1) {
    $global:FileHandle = $global:AmtFile.CreateFileCycle($Filename, -1, $global:Const_ExclusiveBatch, $global:UseUnicode, $false, 1)
    if ($global:FileHandle -ne $null) {
      if (-not $global:AmtFile.Close($global:FileHandle.FileId)) {
        Add-ErrorMsg "$global:AmtFile.Close failed."
      }
    }
  } else {
    [Object]$FileStream = $global:AmtFile.CreateTextFile($Filename, $global:Const_ExclusiveBatch, $global:UseUnicode, $false)
    Set-FileControlError $global:AmtFile.ErrorCode $global:AmtFile.ErrorDescription
    if ($FileStream -ne $null) {
      $FileStream.Close() | Out-Null
    }
    Set-FileControlError $global:AmtFile.ErrorCode $global:AmtFile.ErrorDescription
    $global:FileHandle = $global:AmtFile.GetFileInfo($Filename, 1)
    if (!(Check-FileControlError 0)) {
      if ($AbortOnFailure) {
        Abort $global:FileControlErrMsg
      } else {
        Set-FileControlError 0
        return $false
      }
    }
  }

  $global:ErrorCode = $global:AmtFile.ErrorCode 
  $global:ErrorDescription = $global:AmtFile.ErrorDescription
  Set-FileControlError $global:ErrorCode $global:ErrorDescription

  if (!(Check-FileControlError 0)) {
    if ($AbortOnFailure) {
      Abort $global:FileControlErrMsg
    } else {
      Set-FileControlError 0
      return $false
    }
  }

  return $true
} # Create-EmptyFile


function Assign-ExclusiveFile {
  <#
    .SYNOPSIS
      ECL equivalent: ASG,X <Filename>
    .DESCRIPTION
      Locks the original file and copy it into TPF$.
    .PARAMETER Filename
      [String] File to be assigned
    .PARAMETER FileDeleteFin
      [Boolean] True or False for deleting the file after a free command.
    .PARAMETER FileDeleteError
      [Boolean] True or False for deleting the file If a job has gone into error.
    .PARAMETER AsgFile
      [String] Filename as used in the script on the Asg statement.
    .PARAMETER OptionZ
      [Boolean] True/False whether ASG option Z is set.
    .PARAMETER OptionI
      [Boolean] True/False whether ASG option I is set.
    .PARAMETER AsgOptions
      [String] The ASG Options
    .PARAMETER FileExists
      [Boolean] True if the file exists
  #>

  param (
    [String]$Filename,
    [Boolean]$FileDeleteFin,
    [Boolean]$FileDeleteError,
    [String]$AsgFile,
    [Boolean]$OptionZ,
    [Boolean]$OptionI,
    [String]$AsgOptions,
    [Boolean]$FileExists
  )

  [Int32]$Counter = 0
  $global:FileHandle = 0
  Set-FileControlError 0

  if (-not $FileExists) {
    $global:Message = (Get-FileName $Filename) + " does not exist."
    Set-FileControlError 70 "File in use by another process."
    return
  }

  [String]$AssignFile = $Filename
  #if (($global:FileObject -ne $null) -and ($global:FileObject.FileHandle -ne $null)) {
  #  $AssignFile = $global:FileObject.FileHandle.FullName
  #}

  $global:FileHandle = Fco-AssignFile $AssignFile $global:Const_ExclusiveBatch $true
  while (!(Check-FileControlError 0)) {
    $Counter = Wait-ForFile $Filename $Counter

    if ($OptionZ) {
      $global:Message = "File in use by another run. File not assigned."
      Set-FileControlError 70 "File in use by another process."
      return
    }

    $global:FileHandle = Fco-AssignFile $AssignFile $global:Const_ExclusiveBatch $true
  }

  [Boolean]$ReadOnly = Get-ReadOnly $Filename $FileExists
  [String]$PathName = Get-PathName ([Ref]$Filename)  # Removes path from filename

  AddTo-FileArray $AsgFile $FileDeleteFin "" $FileDeleteError $false $true ((Add-BackSlash $PathName) + $Filename) $true $OptionI $AsgOptions
} # Assign-ExclusiveFile


function Process-CreateTempFile {
  <#
    .SYNOPSIS
      ECL Equivalent ASG, T <Filename>
    .DESCRIPTION
      Option T specifies that the file is temporary. The file can have any name, as long as the name 
      is not assigned to your current run.
    .PARAMETER Filename
      [String] File to assign
    .PARAMETER AsgFile
      [String] Filename as used in the script on the Asg statement.
    .PARAMETER OptionI
      [Boolean] True/False whether ASG option I is used.
    .OUTPUTS
      [String] Directory with \ at the end.
  #>

  param (
    [String]$Filename,
    [String]$AsgFile,
    [Boolean]$OptionI
  )

  [String]$File = ""

  # if an assign is being done first check if the s_FileName is UseName, if so then use the correct filename
  $Filename = Check-UseName $Filename 

  # After getting the correct filename  add path and qualifier to the name.
  $Filename = Check-Qual $Filename

  # Check If an assigned file with the same name is already assigned
  for ([Int32]$I = 0; $I -lt $global:FilesList.Count; $I++) {
    $File = $global:FilesList[$I].WindowsFilename
    [Int32]$Pos = $File.LastIndexOfAny("_")

    if ($Pos -gt -1) {
      $File = $File.Substring(0, $Pos)
    }

    if (($File -eq $Filename) -and ($global:FilesList[$I].IsAssigned)) {
      Write-JobLog "$(Get-FileName $Filename) is already assigned and will be ignored." ([LoggingSeverity]::Info)
      return ""
    }
  }

  # Check if tempfile already exixts.
  [String]$PathName = Get-PathName ([Ref]$Filename)  # Removes path from $Filename
  [String]$FilenameTemp = (Add-BackSlash $global:TempFolder) + $Filename
  $FilenameTemp = (Add-FileExtension $FilenameTemp $global:UseExtension)

  for ([Int]$I = 0; $I -lt $global:FilesList.Count; $I++) {
    if (($global:FilesList[$I].WindowsFilename -eq $FilenameTemp) -and ($global:FilesList[$I].IsAssigned)) {
      Write-JobLog "$(Get-FileName $Filename) is already assigned and will be ignored." ([LoggingSeverity]::Info)
      return ""
    }
  }

  [String]$Temp = (Add-FileExtension $Filename $global:UseExtension)
  Create-TempFile $Temp $AsgFile $OptionI

  [String]$Result = (Add-BackSlash $global:TempFolder) + $Filename
  $Result = (Add-FileExtension $Result $global:UseExtension)

  return $Result
} # Process-CreateTempFile


function Create-TempFile {
  <#
    .SYNOPSIS
      Creates a temporary file in TPF$.
    .PARAMETER Filename
      [String] File to assign.
    .PARAMETER AsgFile
      [String] Filename as used in the script on the Asg statement.
    .PARAMETER OptionI
      [Boolean] True/False whether ASG option I is used.
  #>

  param (
    [String]$Filename,
    [String]$AsgFile,
    [Boolean]$OptionI
  )

  $global:FileHandle = $null
  [String]$PathName = Get-PathName ([Ref]$Filename)  # Removes path from $Filename
  [String]$Temp = (Add-BackSlash $global:TempFolder) + $Filename
  [Boolean]$Result = Create-EmptyFile $Temp
  AddTo-FileArray $AsgFile $true "" $true $false $true $Temp $false $OptionI "T"
} # Create-TempFile


function Get-PathName {
  <#
    .SYNOPSIS
      Returns but also removes the pathname of a filename that was assigned to the job.
    .PARAMETER Filename
      [String] File to check.
    .OUTPUTS
      [String] Pathname or empty string if no pathname is found.
  #>

  param (
    [Ref]$Filename
  )

  [String]$Pathname = ""
  [String]$TempWithBackSlash = Add-BackSlash $global:TempFolder
  [String]$ExtractWithBackSlash = Add-BackSlash $global:ExtractPath
  [String]$JobsWithBackSlash = Add-BackSlash $global:JobPath

  [Int32]$Pos = $TempWithBackSlash.Length

  if (($Pos -gt 0) -and ($Filename.Value.ToUpperInvariant().Contains($TempWithBackSlash.ToUpperInvariant()))) {
    $Pathname = $Filename.Value.Substring(0, $Pos)
    $Filename.Value = $Filename.Value.Substring($Pos)
  } else {
    $Pos = $ExtractWithBackSlash.Length
    if (($Pos -gt 0) -and ($Filename.Value.ToUpperInvariant().Contains($ExtractWithBackSlash.ToUpperInvariant()))) {
      $Pathname = $Filename.Value.Substring(0, $Pos)
      $Filename.Value = $Filename.Value.Substring($Pos)
    } else {
      $Pos = $JobsWithBackSlash.Length
      if (($Pos -gt 0) -and ($Filename.Value.ToUpperInvariant().Contains($JobsWithBackSlash.ToUpperInvariant()))) {
        $Pathname = $Filename.Value.Substring(0, $Pos)
        $Filename.Value = $Filename.Value.Substring($Pos)
      } else {
        $Pathname = ""
      }
    }
  }

  return $Pathname
} # Get-PathName


function Fco-AssignFile {
  <#
    .SYNOPSIS
      Assigns the specified file to the current job.
    .PARAMETER Filename
      [String] Name of the file to be assigned.
    .PARAMETER ShareMode
      [Int32] Share mode
    .PARAMETER Exists
      [Boolean] True/False whether the file exists.
    .Outputs
      FileInfo object from the FileController.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Filename,
    [Parameter(Mandatory=$true)][Int32]$ShareMode,
    [Boolean]$Exists
  )

  [Object]$Result = $null
  Set-FileControlError 0
  Replace-Asterisks ([Ref]$Filename)

  if ($Exists) {
    if (-not (File-Exists $Filename)) {
      Abort "Fco-AssignFile: File [$($Filename)] does not exist."
    }
  }

  $Result = $global:AmtFile.Assign($Filename, $ShareMode, $global:UseUnicode, $Exists, 1)
  $global:ErrorCode = $global:AmtFile.ErrorCode
  $global:ErrorDescription = $global:AmtFile.ErrorDescription    
  Set-FileControlError $global:ErrorCode $global:ErrorDescription

  if (!(Check-FileControlError 0)) {
    if ((!(Check-FileControlError 95)) -and (!(Check-FileControlError 91)) -and (!(Check-FileControlError 90))) {
      Abort ($global:FileControlErrMsg + " [$($Filename)]")
    }
  }

  return $Result
} # Fco-AssignFile


function Get-AssignedFile {
  <#
    .SYNOPSIS
      Checks and returns the complete filepath of an assigned file.
    .PARAMETER Filename
      [String] The name of the file.
    .PARAMETER Assigning
      [Boolean] True if we are coming from @ASG
    .OUTPUTS
      - If Filename is assigned and not read only, the complete filename 
        (path including TPF$, cycle, .DAT) is returned.
      - If Filename is only used, the complete filename (path, _nnn.DAT) of the used file
        is returned.
      - If Filename not is assigned and not used, the complete filename (path, cycle, .DAT) 
        is returned.
      - If Filename is a program file, the complete directoryname  including path is returned.
  #>

  param (
    [String]$Filename,
    [Boolean]$Assigning = $false
  )
  $global:FileObject = $null

  if (($Filename.IndexOf("\") -gt -1) -and ($global:AmtFile.FileExists($Filename))) {
    # Filename is good, don't mess with it
    return $Filename
  }

  Replace-Asterisks ([Ref]$Filename)
  $Filename = $Filename.Replace("/", "\")

  if ($Filename.StartsWith($global:TempFolder.ToUpperInvariant())) {
    # Filename is already complete
    return $Filename
  }

  # remove any dot at the end 
  if ($Filename.EndsWith(".")) {
    $Filename = $Filename.Substring(0, $Filename.Length - 1)
  }  

  $Filename = Check-UseName $Filename 

  if ($global:UseFound -and (File-Exists $FileName))  {
    if ($global:FileObject -ne $null) {
      return Get-GobalFullFilename
    } else {
      #when Use file was not assigned, $global:FileObject is null
      return $Filename
    }
  }

  [String]$Result = $Filename.ToUpperInvariant()

  if ((-not $Assigning) -and (-not $global:UseFound) -and 
      ($Filename.IndexOf("\") -le -1) -and ($Filename.IndexOf("/") -le -1)) {
    #Not a usename then a name without qualifiers could be just the 12 char max filename
    if (Check-ShortName $Result) {
      return Get-GobalFullFilename  #Found it in the list, no need to check further
    }
  }

  #Now check if we have assigned the file
  if (Find-AssignedFileInList $Result)  {
    return Get-GobalFullFilename
  }

  #Not found, try different folders
  $Filename = Check-Qual $Filename
  [String]$Result = $Filename.ToUpperInvariant()

  # set fallback result
  [String]$InitialResult = $Result
  #[String]$Cyclename = ""

  # try public folder
  if ($global:UseExtension) {
    $Result = (Add-FileExtension $Result $global:UseExtension)
  }

  if (File-Exists $Result)  {
    return $Result
  }

  # try temp folder
  [String]$PathName = Get-PathName ([Ref]$Filename)  # Removes path from $Filename
  $Result = (Add-BackSlash $global:TempFolder) + $Filename

  if ($global:UseExtension) {
    $Result = (Add-FileExtension $Result $global:UseExtension)
  }

  if (File-Exists $Result)  {
    return $Result
  }

  # try job folder
  $Result = (Add-BackSlash $global:JobPath) + $Filename
  if (File-Exists $Result)  {
    return $Result
  } else {
    # not found, => remove any extension and try again with a .ps1 extension
    if ($Result.EndsWith($global:Extension)) {
      $Result = $Result.Substring(0,$Result.Length - 4)
    } else {
      # it may also end with something like .dat(1), if so, remove that extension
      [Int32]$LastDot = $Result.LastIndexOf(".")
      if ($LastDot -gt -1 -and $Result.Length -gt ($LastDot + 1)) {
        [String]$AfterDot = $Result.Substring($LastDot + 1)
        if ($AfterDot.StartsWith($global:Extension + "(")) {
          $Result = $Result.Substring(0, $LastDot)
        }
      }
    }

    $Result = $Result + ".ps1"
    if (File-Exists $Result)  {
      return $Result
    } else {
      return $InitialResult
    }
  }
} # Get-AssignedFile


function Check-FileInUse {
  <#
    .SYNOPSIS
      Checks whether or not a file is in use by another process.
    .PARAMETER Filename
      [String] File to be checked.
    .OUTPUTS
      [Boolean] True/False.
  #>

  param (
    [String]$Filename
  )

  #[String]$Cyclename = ""
  Replace-Asterisks ([Ref]$Filename)

  if (-not (File-Exists $Filename)) {
    Write-Joblog "Check-FileInUse: File [$($Filename)] does not exist." ([LoggingSeverity]::Info)
  }

  return $global:AmtFile.FileInUse($Filename)
} # Check-FileInUse


function Get-ReadOnly {
  <#
    .SYNOPSIS
      Checks whether or not a file is read-only.
    .PARAMETER Filename
      [String] The name of the file.
    .PARAMETER FileExists
      [Boolean] If File Exists we don't have to check again
    .OUTPUTS
      [Boolean] True/False.
  #>

  param (
    [String]$Filename,
    [Boolean]$FileExists = $false
  )

  Replace-Asterisks ([Ref]$Filename)

  if (-not $FileExists) {
    if (-not (File-Exists $Filename)) {
      Add-WarningMsg "Get-ReadOnly: File [$($Filename)] does not exist."
    }
  }

  try {
    [Object]$FileInfo = $global:AmtFile.GetFileInfo($Filename, 1)
    return $FileInfo.ReadOnly
  } catch [Exception] {
    Abort "Get-ReadOnly: Could not retrieve file info for file [$($Filename)]"
  }
} # Get-ReadOnly


function Get-ReadOnlyFolder {
  <#
    .SYNOPSIS
      Checks whether or not a folder is read-only.
    .PARAMETER FolderName
      [String] The name of the folder.
    .OUTPUTS
      [Boolean] True/False.
  #>

  param (
    [String]$FolderName
  )

  if (-not(Folder-Exists $FolderName)) {
    Add-Warning "Get-ReadOnlyFolder: Folder [$($FolderName)] does not exist."
  }

  try {
    [Object]$FolderObj = Get-Item $FolderName
    return ($FolderObj.Attributes -and [System.IO.FileAttributes]::ReadOnly)
  } catch [Exception] {
    Abort "Get-ReadOnly: Could not retrieve folder info for folder [$($FolderName)]"
  }
} # Get-ReadOnlyFolder


function Set-ReadOnly {
  <#
    .SYNOPSIS
      Clears the Read Only attribute of a file or directory.
    .DESCRIPTION
      For now, clear the Read Only attribute through PowerShell instead of the FileController.
    .PARAMETER Filename
      [String] File or directory to clear the Read Only attribute.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Filename
  )

  # For now, set the Read Only attribute through PowerShell instead of the FileController.
  try {
    Set-ItemProperty $Filename -name IsReadOnly -value $true
  } catch [Exception] {
    Abort "Set-ReadOnly: Could not set Read Only property of $($Filename): $_.Exception.Message"
  }
} # Set-ReadOnly


function Clear-ReadOnly {
  <#
    .SYNOPSIS
      Clears the Read Only attribute of a file or directory.
    .DESCRIPTION
      For now, clear the Read Only attribute through PowerShell instead of the FileController.
    .PARAMETER Filename
      [String] File or directory to clear the Read Only attribute.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Filename
  )

  # For now, clear the Read Only attribute through PowerShell instead of the FileController.
  try {
    Set-ItemProperty $Filename -name IsReadOnly -value $false
  } catch [Exception] {
    Abort "Clear-ReadOnly: Could not clear Read Only property of $($Filename): $_.Exception.Message"
  }
} # Clear-ReadOnly


function Wait-ForFile {
  <#
    .SYNOPSIS
      Waits for a file not to be in use.
    .PARAMETER Filename
      [String] Name of the file to be assigned.
    .PARAMETER Counter
      [Int32] Counter value.
    .OUTPUTS
      [Int32] New counter value.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Filename,
    [Parameter(Mandatory=$true)][Int32]$Counter
  )

  [Int32]$Interval = 0
  [String]$IntervalKind = ""

  if ($Counter -eq 0) {
    Write-JobLog ((Get-FileName $Filename) + " is in use by another process: " + (Get-Date)) ([LoggingSeverity]::Info)
    $global:WaitStartTime = (Get-Date)
    $global:WaitInterval  = 2 * $global:RepeatMsgTime
    $Counter += 1
  } else {
    if ($Counter -gt $global:WaitInterval) {
      $Interval = ((Get-Date) - $global:WaitStartTime).TotalSeconds
      if ($Interval -lt 120) {
        $IntervalKind = "Second(s)"
      } else {
        $Interval = ((Get-Date) - $global:WaitStartTime).TotalMinutes
        if ($Interval -lt 120) {
          $IntervalKind = "Minute(s)"
        } else {
          $Interval = ((Get-Date) - $global:WaitStartTime).TotalHours
          if ($Interval -lt 120) {
            $IntervalKind = "Hour(s)"
          }
        }
      }

      Add-InformationMsg ((Get-FileName $Filename) + " is in use by another process for $Interval $IntervalKind")
      if ($global:WaitInterval -gt 3600) {
        $global:WaitInterval += 3600
      } else {
        $global:WaitInterval *= 2
      }
    }

    $Counter += 1
    [Int32]$SecDiff = ((Get-Date) - $global:WaitStartTime).TotalSeconds + $global:RepeatMsgTime
    if ($SecDiff -lt $Counter) {
      # Make sure there is at least one second between calls to this routine.
      Start-Sleep -Seconds 1
    } else {
      if ($SecDiff -gt $Counter) {
        # Make sure $Counter holds the seconds since the first call.
        $Counter = $SecDiff
      }
    }

    if (!(File-Exists $Filename)) {
      Abort "Wait-ForFile: $Filename does not exist."
    }
  }

  return $Counter
} # Wait-ForFile


function Check-FileControlError {
  <#
    .SYNOPSIS
      Checks whether a specific error has occured.
    .PARAMETER ErrNo
      [Int32]  Error number to check.
  #>

  param (
    [Parameter(Mandatory=$true)][Int32]$ErrNo
  )

  return ($global:FileControlErrNo -eq $ErrNo)
} # Check-FileControlError


function Set-FileControlError {
  <#
    .SYNOPSIS
      Sets the file control error to the specifified error number and description.
    .DESCRIPTION
      53  File not found
      58  File already exists
      70  Permission denied
      76  Path not found
      501 Illegal assignment (trying to assign program file)
      502 File only known as plus cycle
    .PARAMETER ErrNo
      [Int32]  Error number.
    .PARAMETER ErrMsg
      [String] Error message.
  #>

  param (
    [Parameter(Mandatory=$true)][Int32]$ErrNo,
    [String]$ErrMsg
  )

  $global:FileControlErrNo = $ErrNo

  if ($ErrNo -eq 0) {
    $global:FileControlErrMsg = ""
  } elseif ($ErrMsg -ne "") {
    $global:FileControlErrMsg = $ErrMsg
  } 
} # Set-FileControlError


function Check-ProgramFile {
  <#
    .SYNOPSIS
      Checks if a file could be a program file (directory must exist and no _nnn.Dat files)
    .PARAMETER Filename
      [String]  Complete filename, path + _nnn.DAT
    .PARAMETER Cycle
      [String] File cycle.
  #>

  param (
    [String]$Filename
  )

  [String]$Result = $Filename
  [Int32]$Pos     = -1
  [String]$Dir    = ""
  [Object]$Folder = $null
  Set-FileControlError 0

  # Cannot be a program file if a cycle is present
  [String]$Cycle = Find-Cycle $Filename
  if ($Cycle.Trim() -eq "") {
    $Pos = $Filename.LastIndexOfAny("\")
    if ($Pos -gt -1) {
      $Dir = $Filename.Substring(0, $Pos)
      $Folder = (Get-Folder $Dir)

      if (Check-FileControlError 76) {
        Set-FileControlError 53 "File not found."
        return
      } else {
        if (!(Check-FileControlError 0)) {
          Abort $global:FileControlErrMsg
        }
      }

      foreach ($File in $Folder.GetFiles()) {
        [String]$Name = $File.Name.ToUpperInvariant()

        if ($Name.EndsWith($global:Extension)) {
          [Int32]$Pos = $Name.LastIndexOfAny("_")  # abc_001.DAT
          if ($Pos -eq $Filename.Length - 7) {
            # Datafile found
            Set-FileControlError 53 "File not found."
            return
          }
        }
      }

      $Result = $Dir
      Set-FileControlError 501 "Program file can not be assigned."
    } else {
      Set-FileControlError 53 "File not found."
    }
  } else {
    Set-FileControlError 53 "File not found."
  }
} # Check-ProgramFile


function Get-Folder {
  <#
    .SYNOPSIS
      Returns the folder object of the specified folder path.
    .PARAMETER Folder
      [String]  Complete folder path.
  #>

  param (
    [String]$Folder
  )
  Set-FileControlError 0

  if (!(Folder-Exists $Folder)) {
    Set-FileControlError 76 "Path not found: [$($Folder)]."

    # Return a valid folder object
    return (Get-Item $global:TempFolder)
  }

  try {
    return (Get-Item $Folder)
  } catch [Exception] {
    Abort "Get-Folder: Could not retrieve folder info of [$($Folder)]: $_.Exception.Message"
  }
} # Get-Folder


function Get-ProgramFileName {
  <#
    .SYNOPSIS
      Returns the program filename.
    .DESCRIPTION
      If the directory does not exist, error 53 is raised.
      If eltname id filled and directory\eltname does not exist error 53 is raised.
    .PARAMETER Filename
      [String]  Complete with folder path.
    .PARAMETER EltName
      [String] Elt name.
    .OUTPUTS
      [String] Directory with \ at the end.
  #>

  param (
    [String]$Filename,
    [String]$Eltname
  )

  [String]$Result = Add-BackSlash $Filename

  if ($Filename.StartsWith($global:ExtractPath)) {
    # Filename already complete
    return
  }

  $Filename = Check-UseName $Filename 

  if ($Filename.IndexOf("\") -eq -1) {
    if (($Filename.Substring(0,1) -eq "\") -and ($Filename.SubString(0,2) -ne "\\")) {
      $Filename = (Add-BackSlash $global:ExtractPath) + ($global:ImpliedQual + $Filename)
    } else {
      $Filename = (Add-BackSlash $global:QualPath) + $Filename
    }
  } else {
    $Filename = (Add-BackSlash $global:ExtractPath) + $Filename
  }

  if ($Filename -eq "\") {
    $Filename = ""
  }

  if ($Eltname -eq "") {
    if (!(Folder-Exists $Filename)) {
      Set-FileControlError 53 "File not found."
      $Filename = Add-BackSlash $Filename
    }
  } else {
    [String]$File = (Add-BackSlash $Filename) + $Eltname
    if (!(File-Exists $File)) {
      Set-FileControlError 53 "File not found."
    }
  }

  return Add-BackSlash $Filename
} # Get-ProgramFileName


function Get-JobFileName {
  <#
    .SYNOPSIS
      Check if a filename is in the jobfolder and return full path
    .PARAMETER Filename
      [String] filename with or without path
  #>

  param (
    [String]$Filename
  )
  
  Set-FileControlError 0
  if (($Filename.StartsWith("\")) -and (!$Filename.StartsWith("\\"))) {
    $Filename = (Add-BackSlash $global:JobPath) + (Add-BackSlash $global:ImpliedQual) + $Filename
  } else {
    $Filename = Get-FileName $Filename  #Strip extract/temp folder
 
    if (!$Filename.StartsWith($global:JobPath)) {
      $Filename = (Add-BackSlash $global:JobPath) + $Filename
    } 
  }
  if (!(File-Exists $Filename)) {
    $Filename = $Filename + ".ps1"
    if (!(File-Exists $Filename)) {
      Set-FileControlError 53 "File not found."
    }
  }

  return $Filename
} # Get-JobFileName


function Copy-File {
  <#
    .SYNOPSIS
      Handles file copies.
    .PARAMETER SrcFile
      [String] Source file.
    .PARAMETER SrcElt
      [String] Source ELT.
    .PARAMETER DestFile
      [String] Destination file.
    .PARAMETER DestElt
      [String] Destination ELT.
    .PARAMETER Options
      [CopyOptions] Options
  #>

  param (
    [String]$SrcFile,
    [String]$SrcElt,
    [String]$DestFile,
    [String]$DestElt,
    [CopyOptions]$Options
  )

  [String]$Message = ""
  [String]$File = ""

  Set-FileControlError 0
  [Boolean]$WriteJobSummary = $global:UseJobLog

  [String]$Filename = $SrcFile + $SrcElt
  #[String]$Cyclename = ""
  if (-not (File-Exists $Filename)) {
    $Message = (Get-FileName $SrcFile + $SrcElt) + " not found"

    if ($Options.HasFlag([CopyOptions]::C)) {
      Add-WarningMsg $Message
      Set-FileControlError 53 "File not found."
      return
    } else {
      Abort "Copy-File: $Message"
    }
  }

  if ($DestElt -eq "") {
    $Filename = $DestFile
    #$Cyclename = ""
    if (-not (File-Exists $Filename)) {
      if ($Options.HasFlag([CopyOptions]::X)) {
        $global:UseJobLog = $false  # 
        $File = Get-FileName $DestFile
        [Int32]$Pos = $File.LastIndexOfAny("\")
        [String]$Temp1 = $File.Substring(0, $Pos)
        [String]$Temp2 = "(" + $File.Substring($File.Length -6, 3) + ")" 
        Cat "" ($Temp1 + $Temp2)  # qual\file\(nnn)
        $global:UseJobLog = $WriteJobSummary
      } else {
        $Message = (Get-FileName $DestFile + $DestElt) + " not found."

        if ($Options.HasFlag([CopyOptions]::C)) {
          Add-WarningMsg $Message
          Set-FileControlError 53, "File not found."
          return
        } else {
          Abort "Copy-File $Message"
        }
      }
    }
  } else {
    if (-not (Folder-Exists $DestFile)) {
      $Message = (Get-FileName $DestFile) + " not found."
      if ($Options.HasFlag([CopyOptions]::C)) {
          Add-Warning $Message
          Set-FileControlError 53, "File not found."
          return
      } else {
        Abort "Copy-File $Message"
      }
    }
  }

  if ($DestElt -eq "") {
    if (Get-ReadOnly $DestFile $true) {
      $Message = (Get-FileName $DestFile) + " is Read Only."
      if ($Options.HasFlag([CopyOptions]::C)) {
          Add-WarningMsg $Message
          Set-FileControlError 70, "File not Read Only."
          return
      } else {
        Abort "Copy-File $Message"
      }
    }
  }
  # TODO: Else part with Get-ReadOnlyFolder still needed?

  Fco-CopyFile ($SrcFile + $SrcElt) ($DestFile + $DestElt) $True

  if (-not (Check-FileControlError 0)) {
    $Message = "COPY failed: $global:FileControlErrMsg"

    if ($Options.HasFlag([CopyOptions]::C)) {
      Add-WarningMsg $Message
    } else {
      Abort "Copy-File: $Message"
    }
  } else {

    if (Get-ReadOnly ($DestFile + $DestElt) $true) {
      Clear-ReadOnly ($DestFile + $DestElt)
    }
  }
} # Copy-File


function Fco-CopyFile {
  <#
    .SYNOPSIS
      Copies a file through the FileController.
    .PARAMETER Source
      [String] Source file.
    .PARAMETER Destination
      [String] Destination file.
    .PARAMETER Overwrite
      [Boolean] True/False whether to overwrite possible existing file.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Source,
    [Parameter(Mandatory=$true)][String]$Destination,
    [Parameter(Mandatory=$true)][Boolean]$Overwrite

  )

  Replace-Asterisks ([Ref]$Source)
  Replace-Asterisks ([Ref]$Destination)

  $global:AmtFile.CopyFile($Source, $Destination, $Overwrite, 1)
  Set-FileControlError $global:AmtFile.ErrorCode $global:AmtFile.ErrorDescription
} # Fco-CopyFile


function Erase-File {
  <#
    .SYNOPSIS
      Erase a file
    .DESCRIPTION
      Erase a file, overwrite it with an empty file
    .PARAMETER Filename
      [String Filename
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Filename
  )

  Replace-Asterisks ([Ref]$Filename)
  if (-not (Get-ReadOnly($Filename))) {
    [Object]$FileObj = $global:AmtFile.CreateTextFile($Filename, $global:Const_Exclusive, $global:UseUnicode, $true)
    Set-FileControlError $global:AmtFile.ErrorCode ""
    if (-not (Check-FileControlError 0)) {
      Add-ErrorMsg $global:AmtFile.ErrorDescription
    }
    $FileObj.Close() | Out-Null
  } else {
    Add-WarningMsg "File is read-only, it is not erased."
  }
} # Erase-File


function Release-Use {
  <#
    .SYNOPSIS
      Remove entry from UseNames
    .DESCRIPTION
      Remove entry from UseNames and, If FileName is filled, check If there are still usenames
      attached to that file, If not release the file 
    .PARAMETER UseName
      [String] UseName
    .PARAMETER FileName
      [String] FileName
  #>

  param (
    [String]$UseName,
    [String]$Filename
  )

  Set-FileControlError 0

  [Boolean]$Found = $false
  [Int32]$I = 0

  # Only the UseName will be removed
  if ($Filename -eq "") {
    for ($I = 0; $I -lt $global:UseNamesList.Count; $I++) {
      if ($global:UseNamesList[$I].Usename -eq $UseName) {
        $global:UseNamesList.RemoveAt($I)
        return
      }
    }
    Set-FileControlError 53 "File Not Found"
  } else {
    for ($I = 0; $I -lt $global:UseNamesList.Count; $I++) {
      if ($global:UseNamesList[$I].Usename -eq $UseName) {
        $Found = $true
        break
      }
    }

    if (-not $Found) {
      Set-FileControlError 53 "File Not Found"
      return
    }

    [String]$File = $global:UseNamesList[$I].Filename
    $global:UseNamesList.RemoveAt($I)

    $Found = $false
    for ($I = 0; $I -lt $global:UseNamesList.Count; $I++) {
      if (($global:UseNamesList[$I].Filename -eq $File)) {
        $Found = $true
        break
      }
    }

    if (-not $Found) {
      Release-File $Filename $false $false $false
      if (Check-FileControlError 53) { 
        Add-WarningMsg "File $Filename was not assigned, it could not be released."
        Set-FileControlError 0
      }
    }
  }
} # Release-Use


function Release-File {
  <#
    .SYNOPSIS
      "Free" a file
    .DESCRIPTION
      Delete comes from the FREE command and tells If the file must be deleted
      If Delete is false then global:Files[Index,2] tells if the file must be deleted 
      Filename must be a "complete" filename 
    .PARAMETER FileName
      [String] FileName
    .PARAMETER DeleteFile
      [Boolean] DeleteFile 
    .PARAMETER HadError
      [Boolean] HadError
    .PARAMETER DeleteUsenames
      [Boolean] DeleteUsenames 
    .PARAMETER FileIndex
      [Int32] FileIndex in $global:FilesList
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Filename,
    [Boolean]$DeleteFile,
    [Boolean]$HadError,
    [Boolean]$DeleteUsenames,
    [Int32]$FileIndex = -1
  )

  Set-FileControlError 0

  [Int32]$Index = $FileIndex
  if ($FileIndex -eq -1) {
    # try to find it with tight criteria in order not to pick the wrong one
    for ([Int32]$I = $global:FilesList.Count - 1; $I -ge 0; $I--) {
      if (($global:FilesList[$I].Copyname -eq $Filename) -or 
          (($global:FilesList[$I].FileHandle -ne $null) -and ($global:FilesList[$I].FileHandle.FullName -eq $Filename))) {
        $Index = $I
        $global:FileObject = $global:FilesList[$I]
        break
      }
    }

    # if not found with copyname or fullname, try windowsname
    if ($Index -eq -1) {
      for ([Int32]$I = $global:FilesList.Count - 1; $I -ge 0; $I--) {
        if (($global:FilesList[$I].Copyname -eq "") -and ($global:FilesList[$I].WindowsFileName -eq $Filename)) {
          $Index = $I
          $global:FileObject = $global:FilesList[$I]
          break
        }
      }
    }
  }

  if ($Index -eq -1) {
    Set-FileControlError 53 "File Not Found"
    return
  }

  if (-not $global:FilesList[$Index].IsAssigned) {
    # the file was not assigned, there is nothing to free
    return
  }

  # Save file and cycle to be able to delete usenames for this file
  [String]$FileUse = $global:FilesList[$Index].Filename
  if (($global:FilesList[$Index].FileHandle -ne $null) -and ($global:FilesList[$Index].FileHandle.FullName -ne "")) {
    $FileUse = $global:FilesList[$Index].FileHandle.FullName
  }

  [Int32]$Pos = $FileUse.IndexOf("\")
  if ($Pos -ge $FileUse.Length - 1) {  # Ends with \
    $FileUse = $FileUse.Substring(0, $Pos)
  }

  if ($DeleteFile -and $global:KeepJobLogDevelopment -and $global:Development -and 
      ($global:BrkptFilename -ne "") -and ($global:BrkptFilename -eq $global:FilesList[$Index].FileHandle.FullName)) {
    $DeleteFile = $false  #Keep the joblog on development    
  }

  
  if (($global:FilesList[$Index].DeleteOnFree) -or ($DeleteFile)) {
    if (($HadError) -and (-not ($global:FilesList[$Index].DeleteOnError))) {
      # File assigned with D option not deleted when error termination
      Fco-FreeFile $global:FilesList[$Index].FileHandle
    } else {
      if ($global:FilesList[$Index].FileHandle -ne $null) { # File must be deleted
        Fco-FreeFile $global:FilesList[$Index].FileHandle
      }

      if (($global:FilesList[$Index].IsCataloged) -or ((-not ($global:FilesList[$Index].IsCataloged)) -and ($global:FilesList[$Index].Copyname -eq ""))) { # File is catalogued or is temp file
        [String]$FullName = $global:FilesList[$Index].FileHandle.FullName
        Delete-File $FullName
        if (-not (Check-FileControlError 0)) {
          Abort $global:ErrorDescription
        }
        Delete-EmptyFoldersInPath $FullName
      }
    }
  } Else {
    if ((-not ($global:FilesList[$Index].DeleteOnFree)) -and (-not ($global:FilesList[$Index].IsCataloged))) {
      # Conditional files, C or U option. When error C option not cataloged
	  $FullFileName = $global:FilesList[$Index].FileHandle.FullName
      if ($HadError) {
        if (-not ($global:FilesList[$Index].DeleteOnError)) {  # C option file          
          Create-OriginalFile ($Index)
        }
      } else {
        Create-OriginalFile ($Index)
      }
	  $global:AmtScript.ChangeCobolPrintfile($FullFileName, $global:FilesList[$Index].FileHandle.FullName)
    } Else {
      # Temporary files and read only files are not copied to TPF$ dir, in that case Copyname is space
      if ($global:FilesList[$Index].Copyname -ne "") {
        #Assign the new file
        [Object]$FileHandle = Fco-AssignFile $global:FilesList[$Index].WindowsFilename $global:Const_ExclusiveBatch $true
        Set-FileControlError 0

        #Rename the file
        Fco-RenameFile $global:FilesList[$Index].Copyname $global:FilesList[$Index].WindowsFilename  # - from temp to original filename
        
        #Release the file
        Fco-FreeFile $FileHandle
      }
    }

    if ($global:FilesList[$Index].ChangeReadOnly -eq 1) {  # Read only property must be set
      if (-not (Get-ReadOnly ($global:FilesList[$Index].WindowsFilename) $true)) {
        Set-ReadOnly ($global:FilesList[$Index].WindowsFilename)
      }
    }

    if ($global:FilesList[$Index].ChangeReadonly -eq 2) {  # Read only property must be removed
      if (Get-ReadOnly ($global:FilesList[$Index].WindowsFilename) $true) {
        Clear-ReadOnly ($global:FilesList[$Index].WindowsFilename)
      }
    }

    if ($global:FilesList[$Index].FileHandle -ne $null) {
      Fco-FreeFile ($global:FilesList[$Index].FileHandle)
    }
  }

  if ($global:FilesList[$Index].CHG_N_name -ne "") {  
    # A change filename has been done and the file was assigned, 
    # do the change now when the file is free 
    Add-WarningMsg "@ASG N option not supported yet"
    [String]$ChgFile = $global:FilesList[$Index].CHG_N_name
    [Int32]$Pos = $ChgFile.IndexOf(",")
    [String]$OldFile = $ChgFile.Substring(0, $Pos)
    [String]$NewFile = $ChgFile.Substring($Pos + 1)
    # TODO: Call ChgNOption(s_FileOld,s_FileNew,True)
  }

  # Remove the usenames for this file
  if ($DeleteUsenames) {
    for ([Int32]$I = 0; $I -lt $global:UsenamesList.Count; $I++) {
      if ($global:UsenamesList[$I].Filename -eq $FileUse) {
        $global:UsenamesList.RemoveAt($I)
      }
    }
  }

  # remove from file list
  $global:FilesList.RemoveAt($Index)

}  # Release-File


function Create-OriginalFile {
  <#
    .SYNOPSIS
      Create original file on @FREE
    .DESCRIPTION
      Create the "original" file for files that are assigned with the U or C option and are freed
    .PARAMETER FileName
      [String] FileName
  #>

  param (
    [Int32]$FileIndex
  )

  if ($global:FilesList[$FileIndex].Copyname -eq "") {
    return
  }

  [String]$AssignFile = $global:FilesList[$FileIndex].WindowsFilename
  #if ($global:FilesList[$FileIndex].Cyclename -ne "") {
  #  $AssignFile = $global:FilesList[$FileIndex].Cyclename  # make sure new file is created with a cycle
  #}
  [String]$TempFile = $global:FilesList[$FileIndex].FileHandle.FullName
  
  if (Create-EmptyFile $AssignFile) {
    $AssignFile = $global:FileHandle.FullName  # set to full path - absolute cycle
  }
  [Object]$FileHandle = Fco-AssignFile $AssignFile $global:Const_ExclusiveBatch $true
  [Int32]$Counter = 0
  while (-not (Check-FileControlError 0)) {
    $Counter = Wait-ForFile $AssignFile $Counter
    $FileHandle = Fco-AssignFile $AssignFile $global:Const_ExclusiveBatch $true
  }
  if ($FileHandle -ne $null) {
    Fco-RenameFile $TempFile $AssignFile  # Use tempfile here because CopyName might not have the right filename when file has cycles
    $global:FilesList[$FileIndex].FileHandle.FullName = $AssignFile
    $global:FilesList[$FileIndex].Copyname = ""  # Once file is renamed, CopyName is of no use anymore, can even cause errors
    $global:FilesList[$FileIndex].IsCataloged = $true
    if ($global:FilesList[$FileIndex].ChangeReadOnly -eq 1) {
      if (-not (Get-ReadOnly $AssignFile $true)) {
        Set-ReadOnly $AssignFile
      }
    }
    if ($global:FilesList[$FileIndex].ChangeReadOnly -eq 2) {
      if (Get-ReadOnly $AssignFile $true) {
        Clear-ReadOnly $AssignFile
      }
    }
    Fco-FreeFile $FileHandle
  }
} # Create-OriginalFile


function Free-AsgI {

  <#
    .DESCRIPTION
      Frees files assigned with asg,i (free after termination next task)  
  #>

  [String]$Filename = ""
  for ([Int32]$I = $global:FilesList.Count - 1; $I -ge 0; $I--) {
    if ($global:FilesList[$I].IsAsg_I) {
      $Filename = $global:FilesList[$I].WindowsFilename
      Release-File $Filename $false $false $true $I
      if (Check-FileControlError 53) { 
        Add-WarningMsg "File $Filename was not assigned, it could not be released."
        Set-FileControlError 0
      }
    }  
  }
} # Free-AsgI


function Check-Date {
  <#
    .SYNOPSIS
      Checks if Date is valid and converts it to the right format for Start-Job
    .PARAMETER Date
      [ref] Input Date. Format "mm/dd/yy", "mm/dd/yyyy" or Julian: "yyddd", "yyyydd", "yyyymmdd"
            Output format "yyyymmdd"
    .OUTPUTS
      [Boolean] True if date is a valid date.
  #>

  param (
    [Parameter(Mandatory=$true)][ref]$Date
  )

  [Boolean]$Result = $false
  [String]$DateInterval = ""
  [Object]$NewDate = $null
  [String]$Year = 0
  [String]$Day = 0

  if ($Date.Value -ne "") {
    if ($Date.Value.IndexOf("+") -gt -1) {
      # Date interval
      $DateInterval = $Date.Value.Substring($Date.Value.IndexOf("+") + 1)
      if (-not(Is-Numeric $DateInterval)) {
        $Result = $false
      } else {
        $NewDate = (Get-Date).AddDays($DateInterval)
        $Date.Value = Get-TimeDate "YYYYMMDD" $NewDate
        $Result = $true
      }
    } else {
      if ($Date.Value.IndexOf("/") -gt -1) {
        # Gregorian style
        try {
          $NewDate = Get-Date $Date.Value
          $Date.Value = Get-TimeDate "YYYYMMDD" $NewDate
          $Result = $true
        } catch {
          $Result = $false
        }
      } else {
        # Julian or YYYMMDD
        if ($Date.Value.Length -eq 5) {
          # YYDDD
          $Year = $Date.Value.Substring(0,2)
          $Day = $Date.Value.Substring(2)
          if ($Day -gt 366) {
            $Result = $false
          } else {
            try {
              $NewDate = Get-Date "1/1/$Year"
              $NewDate = $NewDate.AddDays($Day - 1)
              $Date.Value = Get-TimeDate "YYYYMMDD" $NewDate
              $Result = $true
            } catch {
              $Result = $false
            }
          }
        } elseif ($Date.Value.Length -eq 7) {
          # YYYYDDD
          $Year = $Date.Value.Substring(0,4)
          $Day = $Date.Value.Substring(4)
          try {
            $NewDate = Get-Date "1/1/$Year"
            $NewDate = $NewDate.AddDays($Day - 1)
            $Date.Value = Get-TimeDate "YYYYMMDD" $NewDate
            $Result = $true
          } catch {
            $Result = $false
          }
        } elseif ($Date.Value.Length -eq 8) {
          if (-not(Is-Numeric $Date.Value)) {
            $Result = $false
          } else {
            $Result = $true
          }
        } else {
          $Result = $false
        }        
      }
    }
  } else {
    # Get date of today
    $Date.Value = Get-TimeDate "YYYYMMDD" (Get-Date)
    $Result = $true
  }

  return $Result  
} # Check-Date


function Check-Time {
  <#
    .SYNOPSIS
      Checks if Time is valid and converts it to the right format for Start-Job.
    .PARAMETER Time
      HH:MM -> HHMM or +HH:MM which is a time interval
    .PARAMETER Date
      Date was created by Check-Date, so it is in format "yyyymmdd".
    .OUTPUTS
      [Boolean] True if Time is a valid time.
  #>

  param (
    [Parameter(Mandatory=$true)][ref]$Time,
    [Parameter(Mandatory=$true)][ref]$Date
  )

  [Boolean]$Result = $false
  [Object]$PSDate = $null
  [String]$TimeInterval = ""
  [Int32]$Pos = 0
  [String]$Hour = ""
  [String]$Min = "" 
  [Object]$NewDate = $null

  # Get Date with Mont,Day and Year defined by Date parameter.
  # This results in a TimeDate object with the current time and the date set
  # to the Date parameter.
  [Object]$PSDate = Get-Date -Month ($Date.Value.Substring(4,2)) -Day ($Date.Value.Substring(6,2)) -Year ($Date.Value.Substring(0,4))

  if ($Time.Value -ne "") {
    if ($Time.Value.Indexof("+") -gt -1) {
      # Time interval (also in format HH:MM)
      $TimeInterval = $Time.Value.Substring($Time.Value.IndexOf("+") + 1).Trim()
      $TimeInterval = "{0:D2}" -f $TimeInterval
      $Hour = $TimeInterval.Substring(0,2)
      $Min = $TimeInterval.Substring(3,2)
      try {
        $NewDate = $PSDate.AddHours($Hour)
        $NewDate = $NewDate.AddMinutes($Min)
        $Time.Value = Get-TimeDate "HHMM" $NewDate
        $Date.Value = Get-TimeDate "YYYYMMDD" $NewDate
        $Result = $true
      } catch {
        $Result = $false
      }
    } elseif ($Time.Value.Length -ge 4) {
      # Format HH:MM or HHMM
      $Pos = $Time.Value.IndexOf(":")
      if ($Pos -gt -1) {
        # Format "HH:MM"
        $Hour = "{0:D2}" -f $Time.Value.Substring(0,2)
        $Min = "{0:D2}" -f $Time.Value.Substring(3,2)
      } else {
        # Format "HHMM"
        $Hour = "{0:D2}" -f $Time.Value.Substring(0,2)
        $Min = "{0:D2}" -f $Time.Value.Substring(2,2)
      }

      if ((-not(Is-Numeric $Hour)) -or (-not(Is-Numeric $Min))) {
        $Result = $false
      } else {
        if (($Hour -gt 24) -or ($Hour -lt 0) -or ($Min -gt 60) -or ($Min -lt 0)) {
          $Result = $false
        } else {
          $Time.Value = "$Hour$min"
          return $true
        }
      }      
    } else {
      $Result = $false
    }
  } else {
    # Get current time
    $Time.Value = Get-TimeDate "HHMM" (Get-Date)
    $Result = $true
  }

  return $Result
} # Check-Time


function UnloadSql {
  <#
    .SYNOPSIS
      Unload a sql select query into a file
    .DESCRIPTION
      Rdms UNLOAD
    .PARAMETER Data
      [String] Filename (FileId) To use
      [String] SqlQuery The query to execute
      [String] Format (INTERNAL or EXTERNAL)
      [Bool] WithDescription Create a description block in the file
  #>

  param (
    [String]$Filename,
    [String]$SqlQuery,
    [String]$Format,
    [Bool]$WithDescription
  )

  Replace-Asterisks ([Ref]$Filename)
  $FullFilename = Get-AssignedFile $Filename
  for ([Int32]$I = 0; $I -lt ($global:FilesList.Count); $I++) {
    if (($global:FilesList[$I].WindowsFilename -eq $FullFilename) -or ($global:FilesList[$I].Copyname -eq $FullFilename)) {
      $FileHandle = $global:FilesList[$I].FileHandle
      break
    }
  }

  if ($FileHandle -eq $null) {
    Abort "UnloadSql: File not assigned $Filename"
  }

  $FileStream = $global:AmtFile.OpenTextFile($FileHandle.FullName, $global:Const_ExclusiveBatch, 0, $true)
  $global:ErrorCode = $global:AmtFile.ErrorCode
  $global:ErrorDescription = $global:AmtFile.ErrorDescription
  Set-FileControlError $global:AmtFile.ErrorCode $global:ErrorDescription

  # if the file was not there or not accessible, the returned object will be $null in which case we want to stop
  if ($FileStream -eq $null) {
    Abort ("File " + $FileHandle.FullName + " could not be opened. " + $global:ErrorDescription + " (code " + $global:ErrorCode + ")")
  }

  if ($Format.ToUpper() -eq "INTERNAL") {
    $ForInternal = $true
  } else {
    $ForInternal = $false
  }

  $SqlQuery = UpperAllButLiterals($SqlQuery)

  Write-JobLog "Unload query:" ([LoggingSeverity]::Info)
  Write-JobLog $SqlQuery ([LoggingSeverity]::Info)

  [Int32]$Rows = $global:AmtDatabase.RdmsUnloadQuery($FileStream, $SqlQuery, $ForInternal, $WithDescription)
  if ($global:AmtDatabase.ErrorCode -ne 0) {
    $global:ErrorCode = $global:AmtDatabase.ErrorCode
    $global:ErrorDescription = $global:AmtDatabase.ErrorDescription
    Set-IpfDatabaseError
    return 
  }  else {
    # Discussed with Urban.
    # Only IpfSv_SqlAuxiliary should be set. If it's 0 records then DRIPF\SQLERROR will call HUGO, but DRIPF\SQLANTAL will not.
    $global:IpfSv_SqlError = "0"
    $global:IpfSv_SqlReturnCode = "0"
    $global:IpfSv_SqlAuxiliary = $Rows
  }

  $FileStream.Close() | Out-Null
  if ($global:AmtFile.ErrorCode -ne 0) {
    $global:ErrorCode = $global:AmtDatabase.ErrorCode
    $global:ErrorDescription = $global:AmtDatabase.ErrorDescription
  }

  return
} # UnloadSql


function QlpExecute {
  <#
    .SYNOPSIS
      Execute a QLP (Query Language Processor) report — runs a SQL query and writes formatted results to a file.
    .DESCRIPTION
      Replacement for the OS 2200 @QLP processor. Executes the SQL SELECT query via OpenQuery,
      formats each result row according to the QLP DETAIL specification (column positions),
      respects PAGE and MARGINS settings, and writes the formatted report to the output file.
    .PARAMETER OutputFile
      The file alias (set via @USE) or filename to write the report to.
    .PARAMETER SqlQuery
      The SQL SELECT query to execute.
    .PARAMETER DetailSpec
      The QLP DETAIL specification string, e.g. "LINE PLUS 1 COL 01 NO_SIN_ACT col plus 1 no_dos_arp".
      Defines column positions for each result row.
    .PARAMETER PageLines
      Number of lines per page (from PAGE IS n LINES). Default 66.
    .PARAMETER PageColumns
      Number of columns per page (from PAGE IS n ... m COLUMNS). Default 132.
    .PARAMETER MarginTop
      Top margin lines. Default 0.
    .PARAMETER MarginBottom
      Bottom margin lines. Default 0.
    .PARAMETER MarginLeft
      Left margin columns. Default 0.
    .PARAMETER MarginRight
      Right margin columns. Default 0.
  #>

  param (
    [String]$OutputFile,
    [String]$SqlQuery,
    [String]$DetailSpec = "",
    [Int32]$PageLines = 66,
    [Int32]$PageColumns = 132,
    [Int32]$MarginTop = 0,
    [Int32]$MarginBottom = 0,
    [Int32]$MarginLeft = 0,
    [Int32]$MarginRight = 0
  )

  Write-JobLog "QlpExecute: Executing QLP report to file $OutputFile" ([LoggingSeverity]::Info)
  Write-JobLog "QlpExecute: Query: $SqlQuery" ([LoggingSeverity]::Info)

  # --- Resolve and open the output file (same pattern as UnloadSql) ---
  Replace-Asterisks ([Ref]$OutputFile)
  $FullFilename = Get-AssignedFile $OutputFile
  $FileHandle = $null
  for ([Int32]$I = 0; $I -lt ($global:FilesList.Count); $I++) {
    if (($global:FilesList[$I].WindowsFilename -eq $FullFilename) -or ($global:FilesList[$I].Copyname -eq $FullFilename)) {
      $FileHandle = $global:FilesList[$I].FileHandle
      break
    }
  }

  if ($FileHandle -eq $null) {
    Abort "QlpExecute: File not assigned $OutputFile"
  }

  $FileStream = $global:AmtFile.OpenTextFile($FileHandle.FullName, $global:Const_ExclusiveBatch, 0, $true)
  $global:ErrorCode = $global:AmtFile.ErrorCode
  $global:ErrorDescription = $global:AmtFile.ErrorDescription
  Set-FileControlError $global:AmtFile.ErrorCode $global:ErrorDescription

  if ($FileStream -eq $null) {
    Abort ("QlpExecute: File " + $FileHandle.FullName + " could not be opened. " + $global:ErrorDescription + " (code " + $global:ErrorCode + ")")
  }

  # --- Execute the SQL query via OpenQuery to get a DataTable ---
  $SqlQuery = UpperAllButLiterals($SqlQuery)

  [System.Data.DataTable]$ResultTable = $global:AmtDatabase.OpenQuery($SqlQuery)
  if ($global:AmtDatabase.ErrorCode -ne 0) {
    $global:ErrorCode = $global:AmtDatabase.ErrorCode
    $global:ErrorDescription = $global:AmtDatabase.ErrorDescription
    Set-IpfDatabaseError
    $FileStream.Close() | Out-Null
    return
  }

  if ($ResultTable -eq $null -or $ResultTable.Rows.Count -eq 0) {
    Write-JobLog "QlpExecute: Query returned 0 rows" ([LoggingSeverity]::Info)
    $global:IpfSv_SqlError = "0"
    $global:IpfSv_SqlReturnCode = "0"
    $global:IpfSv_SqlAuxiliary = 0
    $FileStream.Close() | Out-Null
    return
  }

  # --- Parse the DETAIL spec to extract column layout ---
  # Format: "LINE PLUS 1 COL 01 NO_SIN_ACT col plus 1 no_dos_arp"
  # Each column is identified by its name (matching a SELECT column).
  # COL nn = absolute column position; col plus n = relative to previous column end.
  [System.Collections.ArrayList]$ColumnDefs = New-Object System.Collections.ArrayList
  if ($DetailSpec -ne "") {
    [String]$Upper = $DetailSpec.ToUpper()
    # Remove the LINE PLUS n prefix
    if ($Upper -match "^LINE\s+PLUS\s+\d+\s*") {
      $Upper = $Upper.Substring($Matches[0].Length)
      $DetailSpec = $DetailSpec.Substring($Matches[0].Length)
    }

    # Parse column definitions: COL nn <name> or COL PLUS n <name>
    # We work through the remaining spec token by token
    [String[]]$Tokens = $Upper -split '\s+'
    [Int32]$Pos = 0
    while ($Pos -lt $Tokens.Count) {
      if ($Tokens[$Pos] -eq "COL") {
        $Pos++
        if ($Pos -lt $Tokens.Count -and $Tokens[$Pos] -eq "PLUS") {
          # Relative position: COL PLUS n <columnname>
          $Pos++
          [Int32]$RelativePos = 0
          if ($Pos -lt $Tokens.Count) { [Int32]::TryParse($Tokens[$Pos], [Ref]$RelativePos) | Out-Null; $Pos++ }
          if ($Pos -lt $Tokens.Count -and $Tokens[$Pos] -ne "COL") {
            [void]$ColumnDefs.Add(@{ Name = $Tokens[$Pos]; Absolute = -1; Relative = $RelativePos })
            $Pos++
          }
        } else {
          # Absolute position: COL nn <columnname>
          [Int32]$AbsolutePos = 1
          if ($Pos -lt $Tokens.Count) { [Int32]::TryParse($Tokens[$Pos], [Ref]$AbsolutePos) | Out-Null; $Pos++ }
          if ($Pos -lt $Tokens.Count -and $Tokens[$Pos] -ne "COL") {
            [void]$ColumnDefs.Add(@{ Name = $Tokens[$Pos]; Absolute = $AbsolutePos; Relative = -1 })
            $Pos++
          }
        }
      } else {
        $Pos++
      }
    }
  }

  # If no DETAIL spec was parsed, fall back to writing all columns space-separated
  if ($ColumnDefs.Count -eq 0) {
    foreach ($Col in $ResultTable.Columns) {
      [void]$ColumnDefs.Add(@{ Name = $Col.ColumnName.ToUpper(); Absolute = -1; Relative = 1 })
    }
  }

  # --- Format and write each row ---
  [Int32]$UsableWidth = $PageColumns - $MarginLeft - $MarginRight
  [Int32]$UsableHeight = $PageLines - $MarginTop - $MarginBottom
  [Int32]$LineCount = 0
  [Int32]$RowCount = 0
  [String]$LeftPad = ""
  if ($MarginLeft -gt 0) { $LeftPad = "".PadRight($MarginLeft) }

  # Write top margin for first page
  for ([Int32]$M = 0; $M -lt $MarginTop; $M++) {
    $FileStream.Write("`r`n")
    $LineCount++
  }

  foreach ($Row in $ResultTable.Rows) {
    # Check for page break
    if ($UsableHeight -gt 0 -and $LineCount -ge ($PageLines - $MarginBottom)) {
      # Write bottom margin
      while ($LineCount -lt $PageLines) {
        $FileStream.Write("`r`n")
        $LineCount++
      }
      # Start new page — write top margin
      $LineCount = 0
      for ([Int32]$M = 0; $M -lt $MarginTop; $M++) {
        $FileStream.Write("`r`n")
        $LineCount++
      }
    }

    # Build the detail line according to column layout
    [String]$Line = $LeftPad
    [Int32]$CurrentCol = $MarginLeft

    foreach ($ColDef in $ColumnDefs) {
      # Get the value from the DataTable row by column name
      [String]$Value = ""
      try {
        $Value = $Row[$ColDef.Name].ToString().TrimEnd()
      } catch {
        # Column name not found in result set — try case-insensitive match
        foreach ($ResultCol in $ResultTable.Columns) {
          if ($ResultCol.ColumnName.ToUpper() -eq $ColDef.Name) {
            $Value = $Row[$ResultCol.ColumnName].ToString().TrimEnd()
            break
          }
        }
      }

      if ($ColDef.Absolute -ge 0) {
        # Absolute column position (1-based)
        [Int32]$TargetCol = $MarginLeft + $ColDef.Absolute - 1
        if ($TargetCol -gt $CurrentCol) {
          $Line += "".PadRight($TargetCol - $CurrentCol)
          $CurrentCol = $TargetCol
        }
      } elseif ($ColDef.Relative -ge 0) {
        # Relative to current position
        if ($ColDef.Relative -gt 0) {
          $Line += "".PadRight($ColDef.Relative)
          $CurrentCol += $ColDef.Relative
        }
      }

      $Line += $Value
      $CurrentCol += $Value.Length
    }

    $FileStream.Write($Line + "`r`n")
    $LineCount++
    $RowCount++
  }

  $FileStream.Close() | Out-Null
  if ($global:AmtFile.ErrorCode -ne 0) {
    $global:ErrorCode = $global:AmtFile.ErrorCode
    $global:ErrorDescription = $global:AmtFile.ErrorDescription
  }

  $global:IpfSv_SqlError = "0"
  $global:IpfSv_SqlReturnCode = "0"
  $global:IpfSv_SqlAuxiliary = $RowCount

  Write-JobLog "QlpExecute: Written $RowCount rows to $($FileHandle.FullName)" ([LoggingSeverity]::Info)

  return
} # QlpExecute


function LockTable {
  <#
    .SYNOPSIS
      Lock a table
    .DESCRIPTION
      Rdms LOCK
    .PARAMETER Data
      [String] TableName to lock
  #>

  param (
    [String]$TableName
  )

  $global:AmtDatabase.RdmsLockTable($TableName)
  if ($global:AmtDatabase.ErrorCode -ne 0) {
    $global:ErrorCode = $global:AmtDatabase.ErrorCode
    $global:ErrorDescription = $global:AmtDatabase.ErrorDescription
  }

  Set-IpfDatabaseError
  return
} # LockTable


function UnlockTable {
  <#
    .SYNOPSIS
      UnLocks a table (Executes a commit)
    .DESCRIPTION
      Rdms UNLOCK
    .PARAMETER Data
      [String] TableName to unlock
  #>

  param (
    [String]$TableName
  )

  $global:AmtDatabase.RdmsUnlockTable($TableName)
  if ($global:AmtDatabase.ErrorCode -ne 0) {
    $global:ErrorCode = $global:AmtDatabase.ErrorCode
    $global:ErrorDescription = $global:AmtDatabase.ErrorDescription
  }

  Set-IpfDatabaseError
  return
} # UnlockTable


function ExecuteQuery {
  <#
    .SYNOPSIS
      Runs a SQL Query
    .DESCRIPTION
      Execute a Sql Query 
    .PARAMETER Data
      [String] SqlQuery to execute
  #>

  param (
    [String]$SqlQuery
  )

  $global:AmtDatabase.ExecuteQuery($SqlQuery)
  if ($global:AmtDatabase.ErrorCode -ne 0) {
    $global:ErrorCode = $global:AmtDatabase.ErrorCode
    $global:ErrorDescription = $global:AmtDatabase.ErrorDescription
  }

  Set-IpfDatabaseError  
  return  
} # ExecuteQuery


function StartTransaction {
  <#
    .SYNOPSIS
      StartTransaction
    .DESCRIPTION
      Starts a database transaction
  #>

  $global:AmtDatabase.StartTransaction()
  if ($global:AmtDatabase.ErrorCode -ne 0) {
    $global:ErrorCode = $global:AmtDatabase.ErrorCode
    $global:ErrorDescription = $global:AmtDatabase.ErrorDescription
  }

  Set-IpfDatabaseError
  return  
} # StartTransaction


function Rollback {
  <#
    .SYNOPSIS
      Rollback
    .DESCRIPTION
      Rolls back a database transaction
  #>

  $global:AmtDatabase.Rollback()
  if ($global:AmtDatabase.ErrorCode -ne 0) {
    $global:ErrorCode = $global:AmtDatabase.ErrorCode
    $global:ErrorDescription = $global:AmtDatabase.ErrorDescription
  }

  Set-IpfDatabaseError
  return  
} # Rollback


function Commit {
  <#
    .SYNOPSIS
      COMMIT
    .DESCRIPTION
      Commits a database transaction
  #>

  $global:AmtDatabase.Commit()
  if ($global:AmtDatabase.ErrorCode -ne 0) {
    $global:ErrorCode = $global:AmtDatabase.ErrorCode
    $global:ErrorDescription = $global:AmtDatabase.ErrorDescription
  }

  Set-IpfDatabaseError
  return  
} # Commit


function Set-IpfDatabaseError {
  <#
    .SYNOPSIS
      Set Ipf systemvars after database command
    .DESCRIPTION
      Ipf systemvars may be handled by an Ipf error handling routine
  #>

  if ($global:ErrorCode -eq 0) {
    # Database action went OK
    $global:IpfSv_SqlError = "0"
    $global:IpfSv_SqlReturnCode = "0"
  } else {
    # Something went wrong
    Add-ErrorMsg "ERROR: Database: $global:ErrorCode  $global:ErrorDescription"
    $global:IpfSv_SqlError = "1"
    $global:IpfSv_SqlReturnCode = "6003"
  }
} # Set-IpfDatabaseError


function Prt {
  <#
    .SYNOPSIS
      Generates a listing of the text of a symbolic element, the table of contents of a program
      file, information regarding temporary files, or the master file directory items of catalogued
      files.      
    .PARAMETER Options
      [String] Options
    .PARAMETER Filename
      [String] Filename
  #>

  param (
    [String]$Options,
    [String]$FileName
  )

  if (Process-Skip "PRT [$($Options)]: $($Filename)") {
    return
  }

  Write-Joblog "PRT [$($Options)]: $($Filename)" ([LoggingSeverity]::Info)

  $Options = $Options.ToUpperInvariant()
  $FileName = $FileName.ToUpperInvariant().Trim()

  [PrtOptions]$PrtOptions = Parse-Options $Options ([PrtOptions]) 

  [String]$FileNameOrig = $FileName
  [String]$EltName = ""
  [String]$Cycle = ""
  $FileName = Get-JobFileName $Filename
  if (-not (Check-FileControlError 0)) {
    Set-FileControlError 0
    $FileName = $FileNameOrig
    Check-Cycle ([ref]$FileName) ([ref]$Cycle)
    Check-FileName ([ref]$FileName) ([ref]$EltName) $Cycle
    $FileNameOrig = $FileName
  }

  [Boolean]$S = $false
  if ($Options = "") {
    $S = $true
  }

  # Option S
  if ($S -or ($PrtOptions.HasFlag([PrtOptions]::S))) {
    if ($EltName -ne "") {
      if ($FileNameOrig -ne "") {
        $FileName = Get-ProgramFileName $global:TempFolder $EltName
      } else {
        $FileName = Get-ProgramFileName $FileNameOrig $EltName
      }
    } else {
      $FileName = Get-JobFileName $FileNameOrig
      if (-not(Check-FileControlError 0)) {
        Set-FileControlError 0
        $FileName = Get-AssignedFile $FileNameOrig 
      }
    } 
    
    if (-not(Check-FileControlError 0)) {
      Set-FileControlError 0
      Write-JobLog "PRT: File not found.`r`nFileName: $FileName" ([LoggingSeverity]::Error)
    } else {
      PrtS $FileName $EltName $($PrtOptions.HasFlag([PrtOptions]::N))
    }       
  }

  # Option F
  if ($PrtOptions.HasFlag([PrtOptions]::F)) {
    if ($EltName -ne "") {
      if ($FileNameOrig -eq "") {
        $FileName = Get-ProgramFileName $global:TempFolder $EltName
      } else {
        $FileName = Get-ProgramFileName $FileNameOrig $EltName
      }
      if (Check-FileControlError 0) {
        PrtF $($FileName + $EltName) $false $($PrtOptions.HasFlag([PrtOptions]::N))
      } else {
        Set-FileControlError 0
        Write-JobLog "PRT: File not found.`r`nFileName: $FileName" ([LoggingSeverity]::Error)
      }
    } else {
      $FileName = Get-AssignedFile $FileNameOrig
      if (-not(Check-FileControlError 0)) {
        Set-FileControlError 0
        $FileName = Check-ProgramFile $FileName $Cycle
        if (Check-FileControlError 501) {  # Program file
          Set-FileControlError 0
          PrtF $FileName $true $($PrtOptions.HasFlag([PrtOptions]::N))
        }
      } else {
        PrtF $FileName $false $($PrtOptions.HasFlag([PrtOptions]::N))
      }
    }
  }

  # Option T or O
  if (($PrtOptions.HasFlag([PrtOptions]::T)) -or ($PrtOptions.HasFlag([PrtOptions]::O))) {
    if ($EltName -ne "") {
	  # nothing we can do, => just display the options and the file name 
      Write-JobLog "PRT - Options: $Options   FileName: $FileName" ([LoggingSeverity]::Error)
      return
    }

    if ($FileNameOrig -eq "") {
      PrtTO $global:TempFolder $true ($PrtOptions.HasFlag([PrtOptions]::N)) ($PrtOptions.HasFlag([PrtOptions]::L)) $true
    } else {
      $FileName = Get-AssignedFile $FileNameOrig
      $File = Get-FileName $FileName
      $File = $File.Substring(0, $File.LastIndexOfAny("\") - 1)

      [String]$FolderName = ""
      if ($PrtOptions.HasFlag([PrtOptions]::T)) {
        $FolderName = $global:TempFolder + "\" + $File
        if (-not(Folder-Exists $FolderName)) {
          $FolderName = "TPF`$\" + (Get-FileName $FolderName)
          Write-JobLog "PRT: TPF`$ file not found.`r`nFileName: $FileName`r`nFolderName: $FolderName" ([LoggingSeverity]::Error)
        } else {
          PrtTO $FolderName $false ($PrtOptions.HasFlag([PrtOptions]::N)) ($PrtOptions.HasFlag([PrtOptions]::L)) $false
        }
      }

      if ($PrtOptions.HasFlag([PrtOptions]::O)) {
        if (-not(Check-FileControlError 0)) {
          Set-FileControlError 0
          $FileName = Check-ProgramFile $FileName $Cycle
          if (Check-FileControlError 501) {
          Set-FileControlError 0
            PrtTO $FileName $true ($PrtOptions.HasFlag([PrtOptions]::N)) ($PrtOptions.HasFlag([PrtOptions]::L)) $true
          } else {
            Write-JobLog "PRT: File $FileName not found." ([LoggingSeverity]::Error)
          }
        } else {
          $FolderName = $global:ExtractPath + $FileName
          if (-not(Folder-Exists $FolderName)) {
            Write-JobLog "PRT: Folder $FolderName not found." ([LoggingSeverity]::Error)
          } else {
            PrtTO $FolderName $false ($PrtOptions.HasFlag([PrtOptions]::N)) ($PrtOptions.HasFlag([PrtOptions]::L)) $true
          }
        }
      }
    }
  }

  # Option I
  if ($PrtOptions.HasFlag([PrtOptions]::I)) {
    PrtI ($PrtOptions.HasFlag([PrtOptions]::N))
  }
} # Prt


function PrtS {
  <#
    .SYNOPSIS
      PRT S option
    .PARAMETER FileName
      [String] File name
    .PARAMETER EltName
      [String] Elt name
    .PARAMETER N
      [Boolean] True if N option is set
  #>

  param (
    [String]$FileName,
    [String]$EltName,
    [Boolean]$N
  )

  [String]$File = $FileName + $EltName
  if (-not(File-Exists $File)) {
    Write-JobLog "PrtS: File $File not found.`r`nFile: $File" ([LoggingSeverity]::Error)
    return
  }

  [Object]$FileObj = Open-TextFile $File $global:Const_SharedRead $global:Const_FileEnc_Autodetect $true
  [String]$Line = ""
  [Int32]$I = 0
  [String]$StrI = ""
  while (!$FileObj.eof) {
    $Line = $FileObj.ReadLine()
    $I += 1
    if ($N) {
      $StrI = "     "
    } else {
      $StrI = [String]$I
      if ($I -lt 10) {
        $StrI = $StrI + ".   "
      } else {
        if ($I -lt 100) {
          $StrI = $StrI + ".  "
        } else {
          $StrI = $StrI + ". "
        }
      }
    }
    Write-JobLog $($StrI + $Line) ([LoggingSeverity]::Error)
  } # while
  [Boolean]$CloseResult = Close-TextFile ($FileObj)

  if ($I -eq 0) {
    Write-JobLog "PrtS: $File is empty." ([LoggingSeverity]::Error)
  }
} # PrtS


function FormatFileDate {

  <#
    .SYNOPSIS
      FormatFileDate, format a string YYYYMMDDHHmmss into a readable datetime
    .PARAMETER FileName
      [String] File name
  #>

  param (
    [String]$Datetime
  )

  [String]$Result = $Datetime.Substring(0, 4) + "-" + 
                    $Datetime.Substring(4, 2) + "-" + 
                    $Datetime.Substring(6, 2) + " " +
                    $Datetime.Substring(8, 2) + ":" +
                    $Datetime.Substring(10, 2) + ":" +
                    $Datetime.Substring(12, 2)
  return $Result
}


function PrtF {
  <#
    .SYNOPSIS
      PRT F option
    .PARAMETER FileName
      [String] File name
    .PARAMETER ProgramFile
      [Boolean] Program File
    .PARAMETER N
      [Boolean] True if N option is set
  #>

  param (
    [String]$FileName,
    [Boolean]$ProgramFile,
    [Boolean]$N
  )

  Replace-Asterisks ([Ref]$FileName)

  [Object]$FolderObj = $null
  [String]$Attribute = ""

  if ($ProgramFile) {
    if (-not(Folder-Exists $FileName)) {
      Write-JobLog "PrtF Folder $FileName not found." ([LoggingSeverity]::Error)
      return
    }

    if (Get-ReadOnlyFolder $FileName) {
      $Attribute = "Read Only"
    } else {
      $Attribute = "         "
    }
  } else {
    if (-not(File-Exists $FileName)) {
      Write-JobLog "PrtF File $FileName not found." ([LoggingSeverity]::Error)
      return
    }

    if (Get-ReadOnly $FileName $true) {
      $Attribute = "Read Only"
    } else {
      $Attribute = "         "
    }
  }

  [Object]$FileInfo = $global:AmtFile.GetFileInfo($FileName, 1)
  [String]$Temp = $FileInfo.FullName
  [String]$Folder = Get-PathName ([Ref]$temp)
  $Folder = [RegEx]::Escape($Folder)     #Otherwise backslashes will not get printed

  
  Write-JobLog((Get-FileName $FileName) + "   Size: " + $FileInfo.FileSize + " Bytes   ")
  Write-JobLog("  Path:          " + $Folder)
  Write-JobLog("  Created:       " + (FormatFileDate $FileInfo.CreationTime))
  Write-JobLog("  Last Accessed: " + (FormatFileDate $FileInfo.LastAccessTime))
  Write-JobLog("  Last Modified: " + (FormatFileDate $FileInfo.LastWriteTime))
  [String]$Info = $Attribute.Trim()

  if ($global:FileObject -ne $null) {
    #File was found in the list of assigned files
    if ($global:FileObject.ChangeReadOnly -eq 1) {
      $Info += "  Read Only"  
    } 
    if ($global:FileObject.ChangeReadOnly -eq 2) {
      $Info += "  Read Only will be removed"
    } 
    if ($global:FileObject.IsCataloged) {
      if ($global:FileObject.DeleteOnFree) {
        $Info += "  Delete at normal Termination or when Freed"
      }
      if ($global:FileObject.DeleteOnError) {
        $Info += "  Delete at Error Termination or when Freed"
      }
    } else {
      if ($global:FileObject.DeleteOnError) {
        $Info += "  Catalog at normal Termination or when Freed"
      } else {
        $Info += "  Catalog at Termination or when Freed"
      }
    }
  }
  if ($Info -ne "") {
    Write-JobLog($Info) # PrtF
  }
} # PrtF


function PrtI {
  <#
    .SYNOPSIS
      PRT with S option.
    .DESCRIPTION
      Provides a listing of the master file directory items for one, a group, or all 
      cataloged files; information regarding temporary files; information concerning 
      currently assigned files; the table of contents of a program file; or the text 
      of a symbolic element.

      That is, on OS2200. In this environment we display the (assigned) files list and the use list.
    .PARAMETER N
      [Boolean] True if N option is set
  #>

  param (
    [Boolean]$N
  )

  Add-InformationMsg "Assigns"
  foreach ($FileObject in $global:FilesList) {
    Add-InformationMsg ("  {0}{1}" -f "Filename       : ", $FileObject.Filename      )
    Add-InformationMsg ("  {0}{1}" -f "WindowsFilename: ", $FileObject.Cyclename     )
    Add-InformationMsg ("  {0}{1}" -f "FileHandle     : ", $FileObject.FileHandle    )
    Add-InformationMsg ("  {0}{1}" -f "DeleteOnFree   : ", $FileObject.DeleteOnFree  )
    Add-InformationMsg ("  {0}{1}" -f "Copyname       : ", $FileObject.Copyname      )
    Add-InformationMsg ("  {0}{1}" -f "DeleteOnError  : ", $FileObject.DeleteOnError )
    Add-InformationMsg ("  {0}{1}" -f "ChangeReadOnly : ", $FileObject.ChangeReadOnly)
    Add-InformationMsg ("  {0}{1}" -f "IsAssigned     : ", $FileObject.IsAssigned    )
    Add-InformationMsg ("  {0}{1}" -f "IsCataloged    : ", $FileObject.IsCataloged   )
    Add-InformationMsg ("  {0}{1}" -f "CHG_N_name     : ", $FileObject.CHG_N_name    )
    Add-InformationMsg ("  {0}{1}" -f "IsASG_I        : ", $FileObject.IsASG_I       )
    Add-InformationMsg ("  -----------------------------------------------------------------------")
  }

  Add-InformationMsg "Uses"
  foreach ($UseNameObject in $global:UseNamesList) {
    Add-InformationMsg ("  {0}{1}" -f "Use name  : ", $UseNameObject.Usename    )
    Add-InformationMsg ("  {0}{1}" -f "Path      : ", $UseNameObject.Filename   )
    Add-InformationMsg ("  {0}{1}" -f "FileObject: ", $UseNameObject.FileObject )
    #Add-InformationMsg ("  {0}{1}" -f "Cycle   : ", $UseNameObject.Cyclename)
    Add-InformationMsg ("  -----------------------------------------------------------------------")
  }
} # PrtI


function PrtTO {
  <#
    .SYNOPSIS
      PRT F option
    .PARAMETER FolderName
      [String] Folder name
    .PARAMETER ProgramFile
      [Boolean] Program File
    .PARAMETER N
      [Boolean] True if N option is set
    .PARAMETER L
      [Boolean] True if L option is set
    .PARAMETER O
      [Boolean] True if O option is set
  #>

  param (
    [String]$FolderName,
    [Boolean]$ProgramFile,
    [Boolean]$N,
    [Boolean]$L,
    [Boolean]$O
  )

  [String]$DispFolderName = ""
  if ($FolderName.Contains($global:TempFolder)) {
    $DispFolderName = "TPF`$\" + (Get-FileName $FolderName)
  } else {
    $DispFolderName = Get-FileName $FolderName
  }

  [String]$FilesCVS = $global:AmtFile.GetFiles($FolderName, $false)
  [String[]]$FilesArray = $FilesCVS.Split(",")
  [Boolean]$Found = $false
  [Int32]$I = 0
  [String]$StrI = ""
  [Int32]$Pos = 0
  [String]$Info = ""
  [String]$Bytes = 0
  [Object]$FileInfo = $null
  [String]$Unit = ""
  [String]$SizeStr = ""

  $ResultArr = New-Object 'String[,]' 2,32

  foreach ($File in $FilesArray) {
    if ($File -ne "`$@`$@") {
      if ($ProgramFile) {
        $Found = $true
        $I = $I + 1

        if ($N) {
          $StrI = "     "
        } else {
          $StrI = [String]$I
          if ($I -lt 10) {
            $StrI = $StrI + ".   "
          } else {
            if ($I -lt 100) {
              $StrI = $StrI + ".  "
            } else {
              $StrI = $StrI + ". "
            }
          }
        }

        if ($L) {
          $Pos = 25 - $File.Length
          if ($Pos -ge 0) {
            $Info = " " * $Pos
          }
          $FileInfo = $global:AmtFile.GetFileInfo($FolderName + "\" + $File, 1)
          [Int32]$FileSize = $FileInfo.FileSize
          Compute-Size $FileSize ([ref]$Unit) ([ref]$SizeStr)
          $Pos = 7 - $SizeStr.Length
          $Info = $Info + "   Size: " + $SizeStr + (" " * $Pos) + $Unit + "   Modified: " + $FileInfo.LastWriteTime
        }
        Write-JobLog ($StrI + $File + $Info) ([LoggingSeverity]::Error)
      } else {
        # NOT ProgramFile
        if ($File.EndsWith($global:Extension)) {
          [String]$Cycle = $File.Substring($File.Length - 7, 3)
          [Int32]$CycleInt = ""
          if (-not([Int32]::TryParse($Cycle, [ref]$CycleInt))) {
            if (($Cycle -eq "++1") -and (-not($FolderName.Contains($global:TempFolder)))) {
              Write-JobLog "PrtTO: Invalid filename found: $File" ([LoggingSeverity]::Error)    
            }
            break
          }

          if ($CycleInt -eq 0) {
            Abort "000 Cycle found, Not allowed"
          }

          # if ($I -gt ($global:MaxRange - 1)) {
          #   Abort "$DispFolderName has more than $($global:MaxRange) Cycles"
          # }
          $Found = $true
          # TODO: update a_array(0,$I) with $File
          $ResultArr[0, $I] = $File
          $Info = $File

          if ($L) {
            $FileInfo = $global:AmtFile.GetFileInfo($FolderName + "\" + $File, 1)
            [Int32]$FileSize = $FileInfo.FileSize
            Compute-Size $FileSize ([ref]$Unit) ([ref]$SizeStr)
            $Pos = 7 - $SizeStr.Length
            $ResultArr[1, $I] = "Size: " + $SizeStr + (" " * $Pos) + $Unit + "   Modified: " + $FileInfo.LastWriteTime
            if ($FileInfo.ReadOnly) {
              $ResultArr[1, $I] = $ResultArr[1, $I] + "  ReadOnly"
            }
          }
          $I = $I + 1
        }
      }
    }
  } # foreach

  if (-not($Found)) {
    if ($ProgramFile) {
      Add-WarningMsg "PrtTO: ProgramFile is empty."
    } else {
      Add-WarningMsg "PrtTO: File not found.`r`nProgramFile: $ProgramFile"
    }
    return
  }

  if ($ProgramFile) {
    return
  }

  if ($O) {
    # Sort the ResultArr
    Add-WarningMsg "PrtTO: Not fully implemented yet."
  }

  $I = 0
  [Int32]$NrOfItems = $ResultArr.Length / 2
  for ($I = 0; $I -lt $NrOfItems; $I++) {
    $Info = ""
    $File = $ResultArr[0,$I]
    if ($L) {
      # Go though a_files...
    }

    if ($N) {
      $StrI = "    "
    } else {
      $StrI = [String]($I + 1)
      if ($I -lt 9) {
        $StrI = $StrI + ".  "
      } else {
        $StrI = $StrI + ". "
      }
    }

    Write-JobLog ($StrI + $DispFolderName + "\" + $File + "  " + $ResultArr[1, $I]) ([LoggingSeverity]::Error)
    if ($Info -ne "") {
      $Pos = $DispFolderName.Length + 1 + $File.Length + 2
      Write-JobLog (" " * $Pos) + $Info ([LoggingSeverity]::Error)
    }
  } # for
} # PrtTO


function Compute-Size {
  <#
    .SYNOPSIS
      Compute the display of file size in GB, MB, KB or B.
    .PARAMETER FileSize
      [Int32] File size in bytes
    .PARAMETER Unit
      [ref][String] output variable containing the determined Unit
    .PARAMETER SizeStr
      [ref][String] Output variable containing formatted size string
  #>

  param (
    [Int32]$FileSize,
    [ref]$Unit,
    [ref]$SizeStr
  )

  $Unit.Value = " B"
  if ($FileSize -gt 99999999999) {
    $Unit.Value = "GB" 
    $FileSize = $FileSize / [Math]::pow(2,30)
  } elseif ($FileSize -gt 99999999) {
    $Unit.Value = "MB" 
    $FileSize = $FileSize / [Math]::pow(2,20)
  } elseif ($FileSize -gt 99999) {
    $Unit.Value = "KB" 
    $FileSize = $FileSize / [Math]::pow(2,10)
  }

  $SizeStr.Value = "{0:N0}" -f $FileSize
} # Compute-Size


function Asy-SendMail {
  <#
    .SYNOPSIS 
      Send an e-mail message.
    .PARAMETER From
      [String] The sender's email address
    .PARAMETER To
      [String] The recipient's email address
    .PARAMETER Subject
      [String] The subject line.
    .PARAMETER Body
      [String] The message text.
    .PARAMETER FileName
      [String] The file reference of the file to be attached.
    .PARAMETER TaskObj
      Task Object, which has CompletedOK set to True if mail was send successfully,
      otherwise CompletedOK is set to False.
  #>

  param (
    [String]$From="",
    [Parameter(Mandatory=$true)][String]$To,
    [Parameter(Mandatory=$true)][String]$Subject,
    [Parameter(Mandatory=$true)][String]$Body,
    [String]$FileName="",
    [Object]$TaskObj=$null
  )

  if ($TaskObj -eq $null) {
    $TaskObj = Create-Taskobject "Temp"
  }

  Set-CompletedOK $TaskObj $true
  [Int32]$OldEmailLogLevel = $global:MailLogLevel

  if ($global:Development) {
    $Subject += ". TEST"
    if ($global:MailTestAddress -eq "") {
      $global:MailLogLevel = 0
      Add-WarningMsg "**** Development environment and MailTestAddress not filled, mail not sent."
      Write-JobLog "**** From    : $From" ([LoggingSeverity]::Warning)
      Write-JobLog "**** To      : $To" ([LoggingSeverity]::Warning)
      Write-JobLog "**** Subject : $Subject" ([LoggingSeverity]::Warning)
      Write-JobLog "**** Body    : $Body" ([LoggingSeverity]::Warning)
      Write-JobLog "**** FileName: $FileName" ([LoggingSeverity]::Warning)
      $global:MailLogLevel = $OldEmailLogLevel
      return
    } else {
      $To = $global:MailTestAddress
    }
  } 

  # create AmtEmail object
  $AmtEmail = New-Object PsObject -Property @{
    Message = $global:Com.CreateAmtEmail()
    Server = $global:MailServer
    Port = $global:MailPort
    Error = $false
  }

  # add method AddAttachment
  $AmtEmail | Add-Member -MemberType ScriptMethod -Name AddAttachment {
    <#
      .SYNOPSIS
        Add Attachment.
    #>
    param (
      [Parameter(Mandatory=$true)][String]$Filename
    )

    if (!$this.Error) {
      $this.Message.AddLocalAttachment($Filename)
      $this.CheckError()
    }
  } # AddAttachment

  # add method Send
  $AmtEmail | Add-Member -MemberType ScriptMethod -Name Send {
    <#
      .SYNOPSIS
        Send Email.
    #>
    if (!$this.Error) {
      $this.Message.SmtpLogOn($this.Server, $this.Port, $global:MailLogon, $global:MailPassword)
      $this.CheckError()
      if (!$this.Error) {
        $this.Message.SendMessage()
        $this.CheckError()
        if (!$this.Error) {
          # Close the connection
          $this.Message.SmtpLogOff()
          $this.CheckError()
        }
      }
    }
    $this = $null
  } # SendMessage

  # add method CheckError
  $AmtEmail | Add-Member -MemberType ScriptMethod -Name CheckError {
    <#
      .SYNOPSIS
        Check Error.
    #>
    if (($this.Message.LastErrorMessage -ne $null) -and ($this.Message.LastErrorMessage -ne "")) {
      # Something went wrong
      $this.Error = $true
      Add-ErrorMsg "AmtEmail: $($this.Message.LastErrorMessage)"
      Set-CompletedOk $TaskObj $false
    }
  } # CheckError


  # Set From, To, Subject, Body
  if ($From -eq "") {
    $AmtEmail.Message.From = $global:MailFrom
  } else {
    $AmtEmail.Message.From = $From
  }

  $AmtEmail.Message.To = $To
  $AmtEmail.Message.Subject = $Subject
  $AmtEmail.Message.Content = $Body

  # Set Attachment
  [String]$TempFilepath = ""
  if ($FileName -ne "") {
    [String]$WindowsFileName = Get-AssignedFile $FileName
    [Asysco.Amt.Scripting.IFileInfo]$fi = $global:AmtFile.GetFileInfo($WindowsFileName, 2)

    # move the file to local storage before attaching it
    [Byte[]]$ba = @()
    [Asysco.Amt.Scripting.IFileBinaryStream]$bs = $global:AmtFile.OpenBinaryFile($WindowsFileName, $global:Const_Exclusive)
    if ($bs -ne $Null) {
      try {
        $ba = $bs.Read(0, $fi.FileSize)
      } finally {
        $bs.Close()
      }

      $TempFilepath = $env:TEMP + "\" + [System.IO.Path]::GetFileName($WindowsFileName)
      [System.IO.File]::WriteAllBytes($TempFilepath, $ba)
      $AmtEmail.AddAttachment($TempFilepath)
    } else {
      $NoAttachmentWarning = "File $Filename was not attached, '$WindowsFileName' could not be opened."
      Add-WarningMsg $NoAttachmentWarning
      $AmtEmail.Message.Content = ($Body + "`r`n`r`n" + "note: $NoAttachmentWarning")
    }
  }

  $AmtEmail.Send()

  # delete any local attachment file
  if ([System.IO.File]::Exists($TempFilepath)) {
    [System.IO.File]::Delete($TempFilepath)
  }

  $global:MailLogLevel = $OldEmailLogLevel
} # Asy-SendMail


function StartSSG { 
  <#
    .SYNOPSIS
      Start an SSG statement.
    .DESCRIPTION
      Called on SSG statement in ECL. 
      Prepare script library to expect SSG statements.
  #>

  Check-FinishStatement
  Write-JobLog "Start SSG" ([LoggingSeverity]::Debug)
  $global:PreviousStatement = [EclDatalineStatement]::Ssg
  $global:InSsg = $global:InSsg + 1

  #First push any old list to the stack
  if ($global:SgsLabels -ne $null) {
    $global:SgsLabelStack.Push($global:SgsLabels)
  }

  # Create new SGS set
  $global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
  # Dictionary of Sgs's (SSG labels)
  # [Label Name, List of Labels containing list of Fields containing list of Subfields
  # One or more labels, each label having zero, one or more fields, containing zero, one or more subfields.
  # Example: LABEL1 subfield1.1 subfield2.1, subfield2.2 subfield3.1,,subfield3.3

  # Add SGS labels with global scope
  AddTo-SgsList $global:GlobalSgsLabels

  # Read & add SGS values with job-scope
  $SgsJob = "$PSScriptRoot\..\P`$SGS\$JobName"
  if ([System.IO.File]::Exists($SgsJob)) {
	Add-Sgs $SgsJob
  }

  # override SGS values specified on command line
  if ($global:CommandLineSgsLabels -ne "") {
    $global:CmdSgsLabelArray = @{}
    [String[]] $SGSs = $global:CommandLineSgsLabels.Split("`r`n", [System.StringSplitOptions]::RemoveEmptyEntries)
    foreach ($SGS in $SGSs) {
      $Label = ""
      [Int32] $firstSpace = $SGS.IndexOf(" ")
      if ($firstSpace -gt -1) {
        $Label = $SGS.Substring(0, $firstSpace)
      } else {
        $Label = $SGS
      }
      $global:SgsLabels.Remove($Label) | Out-Null
      AddTo-SgsList $SGS
      $global:CmdSgsLabelArray += $Label  # Store labelname for check in AddTo-SgsList
    }
  }

   # are we in restart mode?
  If ((CompareTypeSafe (GetSgsValue("RESTART")) "GreaterThan" 0)) {
    $global:RestartLabel = GetSgsValue("RESTART,1,1,1").ToUpperInvariant()
    $global:Restart = $true
  }

  # TODO: Gen-SystemSgses
} # StartSSG


function EndSSG { 
  <#
    .SYNOPSIS
      End an SSG statement.
    .DESCRIPTION
      Called at the end of an SSG statement in ECL. 
      Reset variables.
  #>

  Write-JobLog "End SSG" ([LoggingSeverity]::Debug)

  $global:InSsg = $global:InSsg - 1
  if ($global:InSsg -lt 0) {
    Abort "InSsg is less than zero, => unbalanced calls of StartSSG and EndSSG." 
  }

  if ($global:SgsLabelStack.Count -eq 0) {
    $global:SgsLabels = $null
  } else {
    $global:SgsLabels = $global:SgsLabelStack.Pop()
  }

  $global:SsgOptionB = $false
  $global:PreviousStatement = [EclDatalineStatement]::None
} # EndSSG


function Invoke-Ssg {
  <#
    .SYNOPSIS
      Invoke a converted SSG skeleton script.
    .DESCRIPTION
      Sets up the SGS context, loads SGS data, executes the converted SSG PowerShell script,
      and tears down the SGS context. This replaces the original @SSG ECL statement.
    .PARAMETER Options
      [String] SSG option letters (M, N, I, A, B, etc.)
    .PARAMETER Skeleton
      [String] Name of the converted SSG script (without .ps1 extension)
    .PARAMETER SgsFile
      [String] SGS data file to load (file reference or path)
    .PARAMETER Parameters
      [String[]] Additional parameters passed to the SSG script
  #>

  param (
    [String]$Options = "",
    [Parameter(Mandatory=$true)][String]$Skeleton,
    [String]$SgsFile = "",
    [String[]]$Parameters = @()
  )

  if (Process-Skip "SSG: $Skeleton") {
    return
  }

  Write-JobLog "Invoke-Ssg: $Skeleton (Options=$Options, SgsFile=$SgsFile)" ([LoggingSeverity]::Info)

  # Handle option B (batch/background mode flag)
  if ($Options.Contains("B") -or $Options.Contains("b")) {
    $global:SsgOptionB = $true
  }

  # Set up SGS context (pushes current labels, creates fresh SGS dictionary, loads globals + job SGS)
  StartSSG

  # Load additional SGS data file if specified
  if ($SgsFile -ne "") {
    [String]$SgsFilePath = Check-AddFileName $SgsFile
    if (File-Exists $SgsFilePath) {
      Add-Sgs $SgsFilePath
    } else {
      Write-JobLog "Invoke-Ssg: SGS file not found: $SgsFilePath (continuing without)" ([LoggingSeverity]::Warning)
    }
  }

  # Resolve and call the converted SSG script (path is relative to calling script)
  [String]$CallerDir = [System.IO.Path]::GetDirectoryName((Get-PSCallStack)[1].ScriptName)
  [String]$ScriptPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($CallerDir, "$Skeleton.ps1"))
  if (!(Test-Path $ScriptPath)) {
    Abort "Invoke-Ssg: Converted SSG script not found: $ScriptPath"
  }

  & $ScriptPath -Parameters $Parameters

  # Tear down SGS context
  EndSSG
} # Invoke-Ssg


function Get-NextSgsPart {
  <#
    .SYNOPSIS
      Retrieve a part of value of an Sgs label
    .PARAMETER SgsReference
      [String] Sgs reference to search in
    .PARAMETER
      [Ref][Int32] Start position to start search, returns new startpos or -1 on last part
    .OUTPUT
      [String] containing part of the reference or empty string
  #>

  param (
    [String]$SgsReference,
    [Ref]$StartIndex
  )

  [Int32]$StartPos = $StartIndex.Value
  if (($StartPos -eq 0) -and ($SgsReference.StartsWith("["))) {
    $StartPos = 1
  }

  [Int32]$EndPos = $SgsReference.IndexOf(",", $StartPos)
  if ($EndPos -eq -1) {   #No more commas found, get the last part of the reference without ]
    if ($SgsReference.EndsWith("]")) {
      $EndPos = $SgsReference.Length - 1
    } else {
      $EndPos = $SgsReference.Length  
    }
    $StartIndex.Value = -1
  } else {
    $StartIndex.Value = $EndPos + 1  # skip comma
  }

  return $SgsReference.Substring($StartPos, $EndPos - $StartPos)
} # Get-NextSgsPart


function GetSgsValue { 
  <#
    .SYNOPSIS
      Retrieve a value of an Sgs label
    .PARAMETER SgsReference
      [String] Sgs reference to a label surrounded by []
    .OUTPUT
      [String] containing value of a subfield or a count.
  #>

  param (
    [String]$SgsReference
  )

  [Int32]$StartIndex = 0
  [String]$LabelName = Get-NextSgsPart $SgsReference ([Ref]$StartIndex)

  if ($Labelname -eq "INFO$") {
    # Update the INFO$ SGS reference
    Update-InfoSgs
  }

  if ($StartIndex -eq -1) {   
    # label name without field references [LABEL], return number of labels found
    if ($global:SgsLabels.ContainsKey($LabelName)) {
      return $global:SgsLabels.Item($LabelName).Count
    } else {
      return 0
    }
  }

  if ($global:SgsLabels.ContainsKey($LabelName)) {
    [String]$Part = Get-NextSgsPart $SgsReference ([Ref]$StartIndex)
    [Int32]$N = [Convert]::ToInt32($Part) - 1  # Sgs labels start at 1, .Net lists at 0
    if ($StartIndex -eq -1) {  
      # Only field reference [LABEL,n], return number of fields for n-th value of this label
      if ($global:SgsLabels.ContainsKey($LabelName)) {
        return $global:SgsLabels.Item($LabelName)[$N].Count
      } else {
        return 0
      }
    }

    [String]$Part = Get-NextSgsPart $SgsReference ([Ref]$StartIndex)
    [Int32]$F = [Convert]::ToInt32($Part) - 1
    if ($StartIndex -eq -1) {  
      # Field and subfield reference [LABEL,n,f], return number of subfields for f-th field for n-th value of this label
      if ($global:SgsLabels.ContainsKey($LabelName)) {
        return $global:SgsLabels.Item($LabelName)[$N][$F].Count
      } else {
        return 0
      }
    }

    [String]$Part = Get-NextSgsPart $SgsReference ([Ref]$StartIndex)
    [Int32]$S = [Convert]::ToInt32($Part) - 1
    # Label with all references [LABEL,n,f,s], return number value of s-th subfield for f-th field for n-th value of this label
    if ($StartIndex -eq -1) {  
      if ($global:SgsLabels.ContainsKey($LabelName)) {
        if (($global:SgsLabels.Item($LabelName)[$N] -eq $null) -or ($global:SgsLabels.Item($LabelName)[$N][$F] -eq $null)) {
          return $null
        } else {
          return $global:SgsLabels.Item($LabelName)[$N][$F][$S]
        }
      } else {
        return ""
      }
    }

    [String]$FunctionNameOrIndex = Get-NextSgsPart $SgsReference ([Ref]$StartIndex)
    # Extended subfield reference [LABEL,n,f,s,FUNCTION], return number of subfields for f-th field for n-th value of this label, post-processed by function
    if ($FunctionNameOrIndex -eq "SUBSTR$" -or $FunctionNameOrIndex -eq "0") {
      [String]$Part = Get-NextSgsPart $SgsReference ([Ref]$StartIndex)
      [Int32]$Start = [Convert]::ToInt32($Part)
      [String]$Part = Get-NextSgsPart $SgsReference ([Ref]$StartIndex)
      [Int32]$Length = [Convert]::ToInt32($Part)
      return (IpfSf-Substring ($global:SgsLabels.Item($LabelName)[$N][$F][$S]) $Start $Length)
    } elseif ($FunctionNameOrIndex -eq "LSTR$" -or $FunctionNameOrIndex -eq "16") {
      [String]$Part = Get-NextSgsPart $SgsReference ([Ref]$StartIndex)
      [Int32]$Length = [Convert]::ToInt32($Part)
      return (IpfSf-Substring ($global:SgsLabels.Item($LabelName)[$N][$F][$S]) 1 $Length)
    } else {
      [String]$Msg = "Unsupported extended SGS reference found: $FunctionNameOrIndex not supported yet."
      Add-ErrorMsg $Msg
    }
  } else {
    # note: SGS labels do not have to be defined, it is common to have undefined ones 
    #       which will return 0. We may want to know about them in debugging scenarios
    #       but we should not raise an error condition.
    return $null
  }
} # GetSgsValue


function Update-InfoSgs {
  <#
    .SYNOPSIS
      Updates the INFO$ SGS reference with the latest values.
      Currently only the run condition is stored in the INFO$ SGS reference.  
  #>

  if (-not $global:SgsLabels.ContainsKey('INFO$')) {
    # If it doesn't already exist, create the INFO$ SGS reference according to the manual
    [String]$Info = "INFO$ run-id,grun-id acct-num proj,implied-qual,default-qual user-id,privileged-state run-mode,brkpt-mode run-cond initial-dir-id,implied-dir-id,default-dir-id"
    AddTo-SgsList $info
  }

  # Reset INFO$ SGS reference values
  $global:SgsLabels.'INFO$'[0][0][0] = ""  # empty run-id
  $global:SgsLabels.'INFO$'[0][0][1] = ""  # empty grun-id
  $global:SgsLabels.'INFO$'[0][1][0] = ""  # empty acct-num
  $global:SgsLabels.'INFO$'[0][2][0] = ""  # empty proj
  $global:SgsLabels.'INFO$'[0][2][1] = ""  # empty implied-qual
  $global:SgsLabels.'INFO$'[0][2][2] = ""  # empty default-qual
  $global:SgsLabels.'INFO$'[0][3][0] = ""  # empty user-id
  $global:SgsLabels.'INFO$'[0][3][1] = ""  # empty privileged-state
  $global:SgsLabels.'INFO$'[0][3][1] = ""  # empty privileged-state
  $global:SgsLabels.'INFO$'[0][4][0] = ""  # empty run-mode
  $global:SgsLabels.'INFO$'[0][4][1] = ""  # empty brkpt-mode
  $global:SgsLabels.'INFO$'[0][5][0] = ""  # empty run-cond
  $global:SgsLabels.'INFO$'[0][6][0] = ""  # empty initial-dir-id
  $global:SgsLabels.'INFO$'[0][6][1] = ""  # empty implied-dir-id
  $global:SgsLabels.'INFO$'[0][6][2] = ""  # empty default-dir-id

  # Retrieve the current Run Condition Word and convert it to octal
  [String]$RunCondition = Get-CurrentRcw "W"
  [String]$OctalRcw = ""
  for ([Int32]$I = 0; $I -lt $RunCondition.Length; $I += 3) {
    $OctalRcw += (ConvertTo-Number $RunCondition.Substring($I, 3))
  }

  # Store the 12 digit octal value of the Run Condition Word in the fifth INFO$ field
  $global:SgsLabels.'INFO$'[0][5][0] = $OctalRcw
} # Update-InfoSgs


function AddTo-SgsList {
  <#
    .SYNOPSIS
      Add one or more Sgs labels to the dictionary
    .PARAMETER Sgslabels
      [String] One or more SGS labels separated by linebreaks
  #>

  param (
    [String]$SgsLabels
  )

  ForEach ($Line in $SgsLabels -Split "`r`n") {
    $Line = $line.TrimStart()
    if ($Line -eq "") {
      continue
    }

    [String[]]$Parts = $Line.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)

    [String]$Label = $Parts[0]
    [Object]$FieldsList = New-Object 'System.Collections.Generic.List[Object]'
    if ($Parts.Length -gt 1) {
      # start on 1 (0 is label)
      for ([Int32]$I = 1; $I -lt $Parts.Length; $I++) {
        [Object]$SubFieldsList = New-Object 'System.Collections.Generic.List[String]'
        [String[]]$SubFields = $Parts[$I].Split(",")
        foreach ($SubField in $SubFields) {
          $SubFieldsList.Add($SubField)
        }
        $FieldsList.Add($SubFieldsList)
      }
    }

    if (-not ($global:SgsLabels.ContainsKey($Label))) {
      [Object]$Labels = New-Object 'System.Collections.Generic.List[Object]'
      $Labels.Add($FieldsList)
      $global:SgsLabels.Add($Label, $Labels)
    } else {
      if (($global:CommandLineSgsLabels -eq "") -or (-not ($global:CmdSgsLabelArray -and $global:CmdSgsLabelArray.Contains($Label)))) {
        # Don't add the label when commandline already specified it. Commandline is always leading.
        $global:SgsLabels.Item($Label).Add($FieldsList)
      }
    }
  }
} # AddTo-SgsList


function AddTo-SgsListFromFile {
  <#
    .SYNOPSIS
      Add the Sgs labels that are in the specified file to the dictionary.
    .PARAMETER File
      [String] The file reference of the file containing the SGS labels to be added.
  #>

  param (
    [String]$File
  )

  # get a Windows path
  [String]$Filename = Get-AssignedFile $File

  # get the SGS labels from the file
  [String]$SgsLabels = ""
  [Boolean]$Append = $false
  [Object]$FileStream = Open-TextFile $Filename $global:Const_SharedRead $global:Const_FileEnc_Autodetect $Append
  while (-not ($FileStream.EndOfFile)) {
    $SgsLabels = ($SgsLabels + $FileStream.ReadLine() + "`r`n")
  }
  [Boolean]$CloseResult = Close-TextFile $FileStream

  # add the labels to the SGS dictionary
  AddTo-SgsList $SgsLabels
  
} # AddTo-SgsListFromFile


function Sort-SgsList {
  <#
    .SYNOPSIS
      Sort the SGS list according to the specified parameters.
    .PARAMETER Options
      [String] The sort options.
    .PARAMETER Label
      [String] The label name one based index telling where to start removing (1 = first SGS named Label, 1 = second SGS named Label, et cetera).
    .PARAMETER StartSgs
      [String] A 1-based label sequence number indicating the label where to start sorting.
    .PARAMETER StartField
      [String] A 1-based field sequence number indicating the field to sort on.
    .PARAMETER StartSubfield
      [String] A 1-based subfield sequence number indicating the subfield to sort on.
  #>

  param (
    [String]$Options="",
    [String]$Label="",
    [Int32]$StartSgs=0,
    [Int32]$StartField=0,
    [Int32]$StartSubfield=0
  )

  # See *SORT directive in SSG Programming Reference Manual
  #
  # Options:
  #   A  Do not terminate in error if the item to sort does not exist.
  #   D  Sort the values in descending order.
  #   L  Sort across all fields.
  #   X  Sort numerically. The subfield values must be numeric characters.
  #

  # note: Our SGS list is currently a dictionary, it cannot be sorted. Until 
  #       it is reworked to a custom object (that can also have multiple labels 
  #       with the same name as it should), there is not much we can do.

  Add-WarningMsg "Sort-SgsList is not functional."

} # Sort-SgsList


function RemoveFrom-SgsList {
  <#
    .SYNOPSIS
      Remove one or more Sgs labels to the dictionary.
    .PARAMETER Label
      [String] The SGS label name.
    .PARAMETER Start
      [String] The one based index telling where to start removing (1 = first SGS named Label, 1 = second SGS named Label, et cetera).
    .PARAMETER Number
      [String] The number of labels to remove.
  #>

  param (
    [String]$Label,
    [Int32]$Start,
    [Int32]$Number
  )

  # note: The current implementation does not support multiple labels 
  #       with the same name so we have to ignore $Start and $Number.

  if (($Start -ne 1) -or ($Number -gt 1)) {
    Add-WarningMsg "RemoveFrom-SgsList does not support multiple labels having the same name (Start=$Start, Number=$Number)."
  }

  # just remove any SGS value with the specified label.
  $global:SgsLabels.Remove($Label) | Out-Null
} # RemoveFrom-SgsList


function Add-Sgs {
  <#
    .SYNOPSIS
      ECL, SSG equivalent: *ADD SGS
    .DESCRIPTION
      Include a file containing SGS labels
    .PARAMETER AddFile
      [String] AddFile
  #>

  param (
    [Parameter(Mandatory=$true)][String]$AddFile
  )

  [String]$Filename = Check-AddFileName $AddFile
  #[String]$Cyclename = ""
  if (!(File-Exists $Filename)) {
    Abort "File not found.`r`nFileName: $FileName"
  }

  # Read the file line by line and use Dataline to translate the parameters in the file
  [String]$Line = ""
  [Boolean]$Append = $false
  [Object]$AddFileStream = Open-TextFile $Filename $global:Const_SharedRead $global:Const_FileEnc_Autodetect $Append

  while (-not ($AddFileStream.EndOfFile)) {
    $Line = $AddFileStream.ReadLine()
    AddTo-SgsList $Line
  }

  [Boolean]$CloseResult = Close-TextFile $AddFileStream
} # Add-Sgs


function SearchConditional { 
  <#
    .SYNOPSIS
      Searches SGS data.
    .DESCRIPTION
      Performs a Row, Column, or Keyword Search Conditional (section 5.2.25.6 in SGS Programming Reference Manual).
    .PARAMETER SearchObject
      [String] The type of search ("Row", "Column" or "Keyword").
    .PARAMETER SearchDirection
      [String] The direction of the search ("Ascending" or "Descending").
    .PARAMETER FromClause
      [String] The argument behind FROM.
    .PARAMETER ForExpressionValue
      [String] The argument behind FOR.
  #>

  param (
    [String]$SearchObject,
    [String]$SearchDirection,
    [String]$FromClause,
    [String]$ForExpressionValue
  )

  # note: This implementation is limited, it does not support start-stmt, start-field or start-subfield.

  if ($SearchObject -eq "Column") {
    if ($SearchDirection -eq "Descending") {
      # TODO: implement descending column search
      return $false
    } else {
      # Ascending is the default
      [Boolean]$SkipTillFrom = $false
      if ($global:SgsLabels.ContainsKey($FromClause)) {
        [Boolean]$SkipTillFrom = $true
      }

      foreach ($kvp in $global:SgsLabels.GetEnumerator()) {

        $Key = $kvp.Key
        $Value = $kvp.Value

        if ($SkipTillFrom -and ($Key -ne $FromClause)) {
          continue
        } else {
          $SkipTillFrom = $false
        }

        # check label
        if ($Key -eq $ForExpressionValue) {
          return $true
        }

        # check fields & subfields (both field and subfields are in the subfields list)
        foreach ($SubfieldsList in $Value) {
          foreach ($Subfield in $SubfieldsList) {
            if ($Subfield -eq $ForExpressionValue) {
              return $true
            }
          }
        }

        # no match found
        return $false
      }
    }
  } elseif ($SearchObject -eq "Row") {
    # TODO: implement row search
    return $false
  } elseif ($SearchObject -eq "Keyword") {
    # TODO: implement keyword search
    return $false
  } else {
    return $false
  }
} # SearchConditional


function Asy-Sort {
  <#
    .SYNOPSIS 
      ECL equivalent: @SORT
  #>

  if (Process-Skip "SORT") {
    return
  }

  Check-FinishStatement
  Write-Joblog "SORT" ([LoggingSeverity]::Info)

  Sort-Reset
  $global:PreviousStatement = [EclDatalineStatement]::Sort
} # Asy-Sort


function Initialize-IpfSystemVariables {
  <#
    .SYNOPSIS
      Initialize all IPF system variables to their default values.
  #>
  $global:IpfSv_WorkDirectory   = ""
  $global:IpfSv_Language        = "SYM"
  $global:IpfSv_ChangeString    = ""
  $global:IpfSv_LocateString    = ""
  $global:IpfSv_SqlReturnCode   = "0"  # note: This should have been "0000" but current error handling will break 
                                       #       if that value is used so be careful if you want to fix this.
  $global:IpfSv_SqlAuxiliary    = "0"
  $global:IpfSv_SqlError        = ""
  $global:IpfSv_Device          = ""
  $global:IpfSv_JobId           = "job-id"
  $global:IpfSv_CommandLines    = 1
  $global:IpfSv_CurrentColumn   = 1
  $global:IpfSv_EndColumn       = 0
  $global:IpfSv_Jumps           = 0
  $global:IpfSv_LineInteger     = 4
  $global:IpfSv_LineFraction    = 2
  $global:IpfSv_Results         = 0
  $global:IpfSv_StartColumn     = 0

  $global:IpfSv_TopImage        = 0.0
  $global:IpfSv_BottomImage     = 0.0
  $global:IpfSv_CurrentImage    = 0.0
  $global:IpfSv_Increment       = 10.0
  $global:IpfSv_MatchLine       = 0.0

  $global:IpfSv_DelimChar       = "`""
  $global:IpfSv_CommentChar     = "@"
  $global:IpfSv_ContChar        = "&"
  $global:IpfSv_MultiCmdChar    = ";"
  $global:IpfSv_OmniPresentChar = "*"

  $global:IpfSv_CaseSensitive   = $true
  $global:IpfSv_Completions     = $false
  $global:IpfSv_SqlScreen       = $false
  $global:IpfSv_ProcDebug       = $false
  $global:IpfSv_ProcId          = $false
  $global:IpfSv_SqlFileDisplay  = $true
  $global:IpfSv_FullScreen      = $false
  $global:IpfSv_ReadOnly        = $false
  $global:IpfSv_CommandError    = $false

  $global:IpfSv_Conflict        = "Segment"
  $global:IpfSv_Switch          = "Workspace"
  $global:IpfSv_DataManager     = "Unspecified"

  $global:IpfSv_RetainPosition  = "Reset"
  $global:IpfSv_Output          = "Full"
  $global:IpfSv_Display         = "NoNumber"
  $global:IpfSv_Matching        = "Off"

} # Initialize-IpfSystemVariables


function Read-FileContent {
  <#
    .SYNOPSIS
      ECL @Ipf equivalent OLD
    .DESCRIPTION
      Read file content into a buffer ([String]) using filecontroller.
      File might be assigned already
    .PARAMETER Filename
      [String] Filename to read
    .OUTPUTS
      [String[]] File content
  #>

  param (
    [String]$Filename
  )

  $Filename = Get-AssignedFile $Filename
  [String[]]$Result = $null

  [Object]$IpfFile = Open-TextFile $Filename $global:Const_SharedRead $global:Const_FileEnc_Autodetect $false
  if ($IpfFile -eq $null) {
    Add-ErrorMsg "Read-FileContent: Could not open file $Filename, reason: $($global:ErrorDescription)"
    return $Result    
  }

  while (-not ($IpfFile.EndOfFile)) {
    $Result += $IpfFile.ReadLine() 
  }

  [Boolean]$CloseResult = Close-TextFile $IpfFile
  return $Result
} # Read-FileContent


function Write-FileContent {
  <#
    .SYNOPSIS
      ECL @Ipf equivalent REPLACE (REP)
    .DESCRIPTION
      Replace file content with buffer content using filecontroller
      File might be assigned already
    .PARAMETER Filename
      [String] Filename to write to
    .PARAMETER Buffer
      [String] Buffef to write
  #>

  param (
    [String]$Filename,
    [String]$Buffer
  )

  $Filename = Get-AssignedFile $Filename
  [Object]$IpfFile = Open-TextFile $Filename $global:Const_ExclusiveBatch $global:Const_FileEnc_Autodetect $false
  if ($IpfFile -ne $null) {
    # note: We do not want the result of $IpfFile.Write into the runstream, it would 
    #       result in an array of objects being returned which is not a [Boolean].
    $IpfFile.Write($Buffer, $true) | Out-Null
    [Boolean]$CloseResult = Close-TextFile $IpfFile
    return $true
  } else {
    return $false
  }
} # Write-FileContent


function New-LineObject {
  <#
    .SYNOPSIS
      ECL @Ipf create new object containing Line number and line
    .PARAMETER LineNumber
      [Decimal] $Line number
    .PARAMETER Line
      [String] Line of data
    .OUTPUTS
      [Object] containing both parameters
  #>

  param (
    [Decimal]$LineNumber,
    [String]$line
  )

  [Object]$Result = New-Object -TypeName PSObject -Property @{
    LineNumber = $LineNumber
    Line = $Line
  }

  return $Result
} # New-LineObject


function Create-WorkLookSpace {
  <#
    .SYNOPSIS
      ECL @Ipf create new workspace or lookspace objects
    .DESCRIPTION
      called on IPF NEW, OLD statements to create a new object containing IPF properties
    .PARAMETER Object
      [IpfObjectSpaceType] Object space type to create 
    .PARAMETER Filename
      [String] Filename of the space
    .PARAMETER Data
      [String[]] Optional data to put in the space when a file was read
  #>

  param (
    [IpfObjectSpaceType]$Object,
    [String]$Filename, 
    [String[]]$Data
  )

  [Object]$NewSpace = New-Object -TypeName PSObject -Property @{
    CurrentImage = 0
    CurrentColumn = 0
    Filename = $Filename
    FileLength = 0
    #LanguageType
    Lines = New-Object 'System.Collections.Generic.SortedList[Decimal,Object]'
    #
    # note: We must use Decimal for image numbers, not Double. Double is not exact which is 
    #       a problem when inserting lines, applying so called "segmenting". When looking 
    #       for an open slot, the collection will report that line 7 + 1/10 does not exist 
    #       while line 7.1 actually does exist.
  }

  #  if data is supplied, insert it
  if ($Data -ne $null) {
    $NewSpace.FileLength = $Data.Length 
    [Decimal]$LineNo = $global:IpfSv_Increment
    foreach ($Line in $Data) {
     $NewSpace.Lines.Add($LineNo, (New-LineObject $LineNo $Line))
     $NewSpace.CurrentImage = $LineNo
     $LineNo += $global:IpfSv_Increment
    }
  }

  if ($Object -eq [IpfObjectSpaceType]::Workspace) {
    $global:IpfWorkSpace = $NewSpace
  } else {
    $global:IpfLookSpace = $NewSpace
  }

  UpdateSpacePointers
} # Create-WorkLookSpace


function Ipf-Condition {

  <#
    .SYNOPSIS
      IPF command CONDITION.
    .DESCRIPTION
      Changes the value of the Run Condition Word.
    .PARAMETER Data
      [String] Area
    .PARAMETER
      [String] Value 
    .PARAMETER
      [String] Function
  #>

  param (
    [String]$Area,
    [Int32]$Value,
    [String]$Function
  )

  # make sure all input is uppercase
  $Area = $Area.ToUpperInvariant($Area)
  $Function = $Function.ToUpperInvariant($Function)

  # using the SetC function to achieve out goal
  # @SETC[,options] [f/]value[/j]

  # constructing the f/-part
  $f = ""
  if ($Area -eq "LAND") { $f = "AND/"}
  if ($Area -eq "LOR" ) { $f = "OR/" }
  if ($Area -eq "LXOR") { $f = "XOR/"}

  $v = $Value

  # constructing the /j-part
  $j = "/" + $Function

  # note: SetC must support more than the specs dictate. For ECL, SetC only 
  #       needs to support T1, T2, S2, S3 and S4. For our purpose, it must 
  #       also support T3, S5 and S6. SetC does support the full range using 
  #       ThirdWord and SixthWord functions.

  SetC "" ($f + $v + $l)
} # Ipf-Condition


function Ipf-Attach {
  <#
    .SYNOPSIS
      ECL @Ipf equivalent ATTACH
    .DESCRIPTION
      Assigns a cataloged file to the IPF session. To us this means checking 
      if the file is available and setting COMMANDERROR accordingly.
    .PARAMETER File
      [String] The file reference of the file to attach.
    .PARAMETER Actions
      [String] Any special actions to be taken when attaching the file.
  #>

  # Actions are passed in as a comma-separated collection of words. Possible 
  # action values are: None, Wait, Exclusive, Purge, Recover and Existence.
  #
  # None
  # ~~~~
  # The default value, indicates that no special action should be taken
  # when attaching the file. IPF 1100 attaches the file if it is available and
  # the file remains accessible to other users. Do not specify NONE in
  # combination with the other choices of the ACTION keyword parameter
  # list, because it is then meaningless since it will be overridden by the
  # other specified choices.
  # 
  # Wait
  # ~~~~
  # Indicates that you want to wait until the file is available and can be
  # attached to your session.
  #
  # Exclusive
  # ~~~~~~~~~
  # Indicates that you want the file attached exclusively to your session. If
  # you specify this choice, no one else will be able to access the specified
  # file until it is freed from your session.
  # 
  # Purge
  # ~~~~~
  # Indicates that you want the file purged from the Master File Directory if
  # the session terminates normally or if the file is freed before the session
  # terminates.
  # 
  # Recover
  # ~~~~~~~
  # Indicates that the file is to be attached even if it has been disabled.
  #
  # Existence
  # ~~~~~~~~~
  # Indicates that you want the file attached only for the purpose of
  # determining if it already exists. The file is attached regardless of
  # whether it is exclusively attached to another session, disabled, or
  # stored on tape for long-term storage. The file is attached in a
  # read-and-write inhibited condition. Therefore, you have to free the file
  # before attempting to read from or update it in any way.

  # note: Implemented Existence, Wait and Exclusive only. Recover and Purge are not yet implemented.

  param (
    [String]$File,
    [String]$Actions
  )

  $global:IpfSv_CommandError = $false

  [String]$Filename = Get-AssignedFile (Convert-FileReference $File)

  # configuration constants
  [Int32]$SleepTime = 2  # the number of seconds to wait before trying again
  [TimeSpan]$Timeout = [TimeSpan]::FromSeconds(60)  # the number of seconds to wait before giving up

  if ($Actions.contains("Existence")) {
    # only check if it is there, any additional options are ignored
    if ($global:AmtFile.FileExists($Filename)) {
      $global:IpfSv_CommandError = $false
    } else {
      $global:IpfSv_CommandError = $true
    }

    return
  }

  if ($Actions.contains("Wait")) {

    # wait for the file to become available
    # if it takes too long we will assume the file is not 
    [DateTime]$StartTime = [DateTime]::Now

    if ($Actions.contains("Exclusive")) {

      # wait till we can successfully open the file exclusively for our batch
      while ($true) {  # mode 2 = ExclusiveBatch

        # refresh $FileName (we do not know where exactly the file will be created, public or as cycle)
        $Filename = Get-AssignedFile (Convert-FileReference $File)

        # try to claim it
        [Object]$BinaryFileStream = $global:AmtFile.OpenBinaryFile($Filename, 2)
        if ($BinaryFileStream -ne $null) {
          # we got it, => just leave and forget about it, cleanup will close all files
          return
        }

        # time to give up?
        [TimeSpan]$Span = [DateTime]::Now - [DateTime]$StartTime
        if ($Span -gt $Timeout) {
          $global:IpfSv_CommandError = $true
          return
        }

        Start-Sleep -s $SleepTime
      }
    } else {

      # wait for the file to pop into existence
      while ($true) {

        # refresh $FileName (we do not know where exactly the file will be created, public or as cycle)
        $Filename = Get-AssignedFile (Convert-FileReference $File)

        # is it there yet?
        if ($global:AmtFile.FileExists($Filename)) {
          # we got it
          return
        }

        # time to give up?
        [TimeSpan]$Span = [DateTime]::Now - [DateTime]$StartTime
        if ($Span -gt $Timeout) {
          $global:IpfSv_CommandError = $true
          return
        }

        Start-Sleep -s $SleepTime
      }

      return
    }
  }
} # Ipf-Attach


function Ipf-Generate {
  <#
    .SYNOPSIS
      ECL @Ipf equivalent GENERATE
      This is an EDIT command. See also EDIT 1100 User's Guide.
    .DESCRIPTION
      Insert a string in workspace
    .PARAMETER Value
      [String] The string value to write
    .PARAMETER
      [Int32] Repeat 
    .PARAMETER
      [String] Start_AsString
    .PARAMETER
      [String] Increment
    .PARAMETER Conflict_AsString
      [String] Indicates the action that should be taken if the generated images overlap existing images.
    .PARAMETER RetainPosition_AsString
      [String] Determines if the image pointer is in the same position when the command is processed.
  #>

  param (
    [String]$Value,
    [String]$Repeat_AsString,
    [String]$Start_AsString,
    [String]$Increment_AsString,
    [String]$Conflict,
    [String]$RetainPosition
  )

  $global:IpfSv_CommandError = $false

  # type & initialize input
  #
  [Int32]$Repeat = 0
  if ($Repeat_AsString -eq "") {
    $Repeat = 1
  } else {
    $Repeat = $Repeat_AsString
  }

  [Decimal]$Start = 0
  if ($Start_AsString -eq "") {
    $Start = $global:IpfSv_CurrentImage
  } else {
    $Start = $Start_AsString
  }

  [Decimal]$Increment = 0
  if ($Increment_AsString -eq "") {
    $Increment = $global:IpfSv_Increment
  } else {
    $Increment = $Increment_AsString
  }

  if ($Conflict -eq "") {
    $Conflict = $global:IpfSv_Conflict
  }

  if ($RetainPosition -eq "") {
    $RetainPosition = $global:IpfSv_RetainPosition
  }

  [Decimal]$RetainedPosition = $global:IpfWorkSpace.CurrentImage

  [Decimal]$ImageNumber = $Start
  [Decimal]$SegementInc = 1

  for ([Int32]$I = 0; $I -lt $Repeat; $I++) {

    # note: Segmenting is described in "Interactive Processing Facility (IPF 1100) EDIT 1100 User's Guide" 
    #       section 3.26 .

    if (-not $global:IpfWorkSpace.Lines.ContainsKey($ImageNumber)) {
      # all well, no clonflict, add the line and proceed
      $global:IpfWorkSpace.Lines.Add($ImageNumber,(New-LineObject $ImageNumber $Value))
      $global:IpfWorkSpace.CurrentImage = $ImageNumber
      $ImageNumber += $Increment
      continue
    }

    # conflict! now what?

    if ($Conflict -eq "Error") {
      # not good, abort with error
      Abort "Conflict generating images."
    }

    if ($Conflict -eq "Overwrite") {
      # don't care, just replace the image that is there
      $global:IpfWorkSpace.Lines.Add($ImageNumber,(New-LineObject $ImageNumber $Value))
      $global:IpfWorkSpace.CurrentImage = $ImageNumber
      $ImageNumber += $Increment
      continue
    }

    # segment: generate non-conflicting new line number
    [Decimal]$ImageNumberProposal = $ImageNumber + $SegementInc
    while ($global:IpfWorkSpace.Lines.ContainsKey($ImageNumberProposal)) {
      $SegementInc = $SegementInc / 10
      if ($SegementInc -lt 0.0000000001) {
        DumpIpfWorkspace
        Abort "Maximum segmenting depth exceeded."
      }
      $ImageNumberProposal = $ImageNumber + $SegementInc
    }

    # add line using now non-conflicting new line number
    $ImageNumber = $ImageNumberProposal
    $global:IpfWorkSpace.Lines.Add($ImageNumber,(New-LineObject $ImageNumber $Value))
    $global:IpfWorkSpace.CurrentImage = $ImageNumber
    # note: We do not increment $ImageNumber to make sure we will return to the segmenting section 
    #       for more segmenting with the same increment ($SegementInc) in case more repetitions 
    #       are pending. This should keep all new lines in one continuous block.
  }

  if ($RetainPosition -eq "Preserve") {
    $global:IpfWorkSpace.CurrentImage = $RetainedPosition
  }

  UpdateSpacePointers
} # Ipf-Generate


function Ipf-Go {
  <#
    .SYNOPSIS
      ECL @Ipf equivalent GO
      This is an EDIT command. See also EDIT 1100 User's Guide.
    .DESCRIPTION
      position the current image pointer to a specific line number 
      within the workspace.
    .PARAMETER ColumnNumber
      [Int32] The new value for $CURRENTCOLUMN.
    .PARAMETER Base_AsString
      [String] The line number to go to (initially).
    .PARAMETER Offset
      [Int32] The number of lines to step to reach the final position (may be either positive or negative).
    .PARAMETER String
      [String] The string to look for.
  #>

  param (
    [Int32]$ColumnNumber,
    [String]$Base_AsString,
    [Int32]$Offset,
    [String]$String
  )

  $global:IpfSv_CommandError = $false

  # note: The converter will generate the default values ($Base = $global:IpfSv_CurrentImage 
  #       and $Offset = 1 respectively) in case the GO command has no ACTION parameter.

  [Object]$ObjectSpace = $null
  if ($global:IpfSwitch -eq [IpfObjectSpaceType]::Workspace) {
    $ObjectSpace = $global:IpfWorkSpace
  } else {
    $ObjectSpace = $global:IpfLookSpace 
  }

  # type & initialize input
  #
  if ($ColumnNumber -eq 0) {
    $ColumnNumber = $global:IpfSv_CurrentColumn
  } else {
    $global:IpfSv_CurrentColumn = $ColumnNumber
  }

  # set image number where to start searching (in case ACTION is a literal string)
  [Decimal]$Start = $global:IpfSv_CurrentImage

  [Decimal]$Base = 0
  if ($Base_AsString -eq "") {
    $Base = $global:IpfSv_CurrentImage
  } else {
    if (Is-Numeric $Base_AsString) {
      # as documented
      $Base = $Base_AsString
    } else {
      # This should never occur. But if it does, we can handle it.
      Add-WarningMsg "Ipf-Go received a non-numeric base expression. => Using it as a search string to locate image."
      $Start = $global:IpfSv_TopImage
      $String = $Base_AsString
    }
  }

  if ($String -ne "") {
    # Search for $String starting at $C, and position $C to the line number where the string is found.
    # It is not clear what to do if the string is not found, => do nothing.
    foreach ($Key in $ObjectSpace.Lines.Keys) {

      # first move to current image (where the search should start)
      if ($Key -lt $Start) {
        continue
      }

      if ($ObjectSpace.Lines[$Key].Line.Contains($String)) {
        $ObjectSpace.CurrentImage = $Key
		$global:IpfSv_CurrentImage = $ObjectSpace.CurrentImage
        return
      }
    }
  } else {
    $ObjectSpace.CurrentImage = $global:IpfSv_TopImage
    $global:IpfSv_CurrentImage = $ObjectSpace.CurrentImage

    for ([Int32]$i = 0; $i -lt $ObjectSpace.Lines.Keys.Count; $i++) {

      [Decimal]$Key = $ObjectSpace.Lines.Keys[$i]

      if ($Key -lt $Base) {
        continue
      }

      # we are now at $Base. From here, apply offset.

      $i = $i + $Offset

      if ($i -lt 0) {
        $Key = $global:IpfSv_TopImage
      } elseif ($i -gt $ObjectSpace.Lines.Count - 1) {
        $Key = $global:IpfSv_BottomImage
      } else {
        $Key = $ObjectSpace.Lines.Keys[$i]
      }

      $ObjectSpace.CurrentImage = $Key
      $global:IpfSv_CurrentImage = $ObjectSpace.CurrentImage
      return
    }

    $ObjectSpace.CurrentImage = $global:IpfSv_BottomImage
    $global:IpfSv_CurrentImage = $ObjectSpace.CurrentImage
  }
} # Ipf-Go


function Ipf-Locate {
  <#
    .SYNOPSIS
      ECL @Ipf equivalent LOCATE
      This is an EDIT command. See also EDIT 1100 User's Guide.
    .DESCRIPTION
      Locate a string in (part of) the workspace
    .PARAMETER String
      [String] String to search for
    .PARAMETER Range
      [String] The line\column range over which to search (\ is the column delimiter).
    .PARAMETER Repeat
      [String] The maximum number of lines containing matches to find. The default is 1.
    .PARAMETER Display
      [String] Whether or not to display line numbers with the found images. The default 
               is the current value of the system variable $DISPLAY. (Number | NoNumber)
    .PARAMETER Output
      [String] Whether or not to display the found images. (Brief | Full | Compress | Scale)
    .PARAMETER Matching
      [String] Whether pattern-matching characters have special meaning in the string. 
               The default for this keyword parameter is the value of the system variable $MATCHING.
               (Off | Partial | Full)
    .PARAMETER RetainPosition
      [String] Whether IPF 1100 keeps the current image pointer ($C) in the same position when the 
               command is processed. The default is the value of the system variable $RETAINPOSITION 
               (initially set to RESET). (Reset | Preserve)


    # TODO: pattern matching support
  #>

  param (
    [String]$String,
    [String]$Range,
    [String]$Repeat,     # Can be an integer or string ("A" or "ALL")
    [String]$Display,
    [String]$Output,
    [String]$Matching,
    [String]$RetainPosition
  )

  $global:IpfSv_CommandError = $false

  # type & initialize input
  #
  if ($String -eq "") {
    $String = $global:IpfSv_LocateString
  }

  if ($Range -eq "") {
    $Range = "ALL"
  }

  if ($Repeat -eq "") {
    $Repeat = 1
  }

  if ($Display -eq "") {
    $Display = $global:IpfSv_Display
  }

  if ($Output -eq "") {
    $Output = $global:IpfSv_Output
  }

  if ($Matching -eq "") {
    $Matching = $global:IpfSv_Matching
  }

  if ($RetainPosition -eq "") {
    $RetainPosition = $global:IpfSv_RetainPosition
  }

  [Object]$ObjectSpace = $null
  if ($global:IpfSwitch -eq [IpfObjectSpaceType]::Workspace) {
    $Objectspace = $global:IpfWorkSpace
  } else {
    $Objectspace = $global:IpfLookSpace 
  }

  [Decimal]$RetainedPosition = $Objectspace.CurrentImage

  $global:IpfSv_Results = 0

  # Get range values
  [Decimal]$LineFrom = -1
  [Decimal]$LineTo   = -1
  [Int32]$ColumnFrom = -1
  [Int32]$ColumnTo   = -1

  Get-Range $Range ([ref]$LineFrom) ([ref]$LineTo) ([ref]$ColumnFrom) ([ref]$ColumnTo)

  [Boolean]$Found = $false
  foreach ($LineObject in $ObjectSpace.Lines.Values) {
    
    [String]$Line = $LineObject.Line

    if ($LineObject.LineNumber -ge $LineFrom -and $LineObject.LineNumber -le $LineTo) {
      [Int32]$ColumnIndex = $Line.IndexOf($String)
      if ($ColumnIndex -gt -1) {
        $Found = $true

        $global:IpfSv_StartColumn = $ColumnIndex + 1             # one based
        $global:IpfSv_EndColumn = $ColumnIndex + $String.Length  # one based
        $global:IpfSv_MatchLine = $LineObject.LineNumber
        $global:IpfSv_LocateString = $String
        $global:IpfSv_Results++

        $ObjectSpace.CurrentImage = $LineObject.LineNumber

        # display output
        if ($Display -ne "Brief") {
          # never mind Scale or Compress, that seems only useful on a character terminal
          [String]$Msg = ""
          if ($Display -eq "Number") {
            $Msg = $LineObject.LineNumber + " "
          }
          $Msg += $LineObject.Line
          Add-InformationMsg($Msg)
        }

        if (($Repeat -ne "ALL") -and ($Repeat -ne "A") -and ($global:IpfSv_Results -ge $Repeat)) {
          break
        }
      }
    }
  }

  # TODO: Pattern matching support.

  # if not found, set CurrentImage to TopImage
  # and CommandError to true
  if (($Found -eq $false) -and ($Objectspace.Lines.Count -gt 0)) {
    $ObjectSpace.CurrentImage = $Objectspace.Lines.Keys[0]
    $global:IpfSv_CommandError = $true
  }

  if ($RetainPosition -eq "Preserve") {
    $Objectspace.CurrentImage = $RetainedPosition
  }

  UpdateSpacePointers
} # Ipf-Locate


function Ipf-Merge {
  <#
    .SYNOPSIS
      ECL @Ipf equivalent MERGE
      This is an EDIT command. See also EDIT 1100 User's Guide.
    .DESCRIPTION
      The MERGE command copies all or part of the specified images of the workspace
      or another file into another file or workspace.
    .PARAMETER FromFile
      [String] Name of the file the images should be copied from. If empty string, the workspace
      will be used.
    .PARAMETER ToFile
      [String] Name of the file the specified images should be copied to. If empty string, the 
      workspace will be used.
    .PARAMETER Range
      [String] Line or column range of images that should be merged. If empty all images will be merged.
    .PARAMETER Start
      [Int32] Image number to start merging with
    .PARAMETER Increment
      [Int32] Increment
    .PARAMETER Conflict
      [String] Indicates the action that should be taken if the merged images overlap existing images.
    .PARAMETER Source
      [String] Whether or not to delete the images in the file or workspace where the images
               are copied from. If empty, RETAIN is used.
    .PARAMETER RetainPosition
      [String] Determines if the image pointer is in the same position when the command is processed.
  #>

  param (
    [String]$FromFile,
    [String]$ToFile,
    [String]$Range,
    [String]$Start_AsString,
    [String]$Increment_AsString,
    [String]$Conflict,
    [String]$Source,
    [String]$RetainPosition
  )

  $global:IpfSv_CommandError = $false

  # type & initialize input
  #
  if ($Range -eq "") {
    $Range = "ALL"
  }

  [Decimal]$Start = 0
  if ($Start_AsString -eq "") {
    $Start = $global:IpfSv_CurrentImage
  } else {
    $Start = $Start_AsString
  }

  [Decimal]$Increment = 0
  if ($Increment_AsString -eq "") {
    $Increment = $global:IpfSv_Increment
  } else {
    $Increment = $Increment_AsString
  }

  if ($Conflict -eq "") {
    $Conflict = $global:IpfSv_Conflict
  }

  if ($Source -eq "") {
    $Source = "Retain"
  }

  if ($RetainPosition -eq "") {
    $RetainPosition = $global:IpfSv_RetainPosition
  }

  # note: MERGE applies to the workspace only
  [Decimal]$RetainedPosition = $global:IpfWorkSpace.CurrentImage

  # Get range values
  [Decimal]$LineFrom = -1
  [Decimal]$LineTo   = -1
  [Int32]$ColumnFrom = -1
  [Int32]$ColumnTo   = -1

  Get-Range $Range ([ref]$LineFrom) ([ref]$LineTo) ([ref]$ColumnFrom) ([ref]$ColumnTo)

  # FROM
  if ($FromFile -ne "") {
    # add/insert FromFile's content into the workspace
    $FromFile = Get-AssignedFile (Convert-FileReference $FromFile)

    # read only the lines within the specified line range
    [Object]$FromFileStream = Open-TextFile $FromFile $global:Const_SharedRead $global:Const_FileEnc_Autodetect $false
    [Object]$Lines = New-Object 'System.Collections.Generic.List[String]'
    [Decimal]$LineNumber=0
    while ($LineNumber -le $LineTo -and -not ($FromFileStream.EndOfFile)) {
      [String]$Line = $FromFileStream.ReadLine()
      $LineNumber++
      if (($LineNumber -ge $LineFrom) -and ($LineNumber -le $LineTo)) {
        $Lines.Add($Line)
      }
    }
    [Boolean]$CloseResult = Close-TextFile $FromFileStream


    [Decimal]$ImageNumber = $Start
    [Decimal]$SegementInc = 1

    foreach ($Value in $Lines) {

      # note: We are using (almost) the same code as in Ipf-Generate here. Calling Ipf-Generate is no option 
      #       because it would start a new segmenting effort on each call, potentially interleaving 
      #       new lines with existing ones.

      # note: Segmenting is described in "Interactive Processing Facility (IPF 1100) EDIT 1100 User's Guide" 
      #       section 3.26 .

      if (-not $global:IpfWorkSpace.Lines.ContainsKey($ImageNumber)) {
        # all well, no clonflict, add the line and proceed
        $global:IpfWorkSpace.Lines.Add($ImageNumber,(New-LineObject $ImageNumber $Value))
        $global:IpfWorkSpace.CurrentImage = $ImageNumber
        $ImageNumber += $Increment
        continue
      }

      # conflict! now what?

      if ($Conflict -eq "Error") {
        # not good, abort with error
        Abort "Conflict generating images."
      }

      if ($Conflict -eq "Overwrite") {
        # don't care, just replace the image that is there
        $global:IpfWorkSpace.Lines.Add($ImageNumber,(New-LineObject $ImageNumber $Value))
        $global:IpfWorkSpace.CurrentImage = $ImageNumber
        $ImageNumber += $Increment
        continue
      }

      # segment: generate non-conflicting new line number
      [Decimal]$ImageNumberProposal = $ImageNumber + $SegementInc
      while ($global:IpfWorkSpace.Lines.ContainsKey($ImageNumberProposal)) {
        $SegementInc = $SegementInc / 10
        if ($SegementInc -lt 0.0000000001) {
          DumpIpfWorkspace
          Abort "Maximum segmenting depth exceeded."
        }
        $ImageNumberProposal = $ImageNumber + $SegementInc
      }

      # add line using now non-conflicting new line number
      $ImageNumber = $ImageNumberProposal
      $global:IpfWorkSpace.Lines.Add($ImageNumber,(New-LineObject $ImageNumber $Value))
      $global:IpfWorkSpace.CurrentImage = $ImageNumber
      # note: We do not increment $ImageNumber to make sure we will return to the segmenting section 
      #       for more segmenting with the same increment ($SegementInc) in case more repetitions 
      #       are pending. This should keep all new lines in one continuous block.
    }

    $global:IpfSv_CurrentImage = $global:IpfWorkSpace.CurrentImage
  }

  # TO
  if ($ToFile -ne "") {
    # write the workspace content to ToFile
    $ToFile = Convert-FileReference $ToFile

    # It does not say anywhere that the existing content of ToFile should be preserved
    # or appended to. It looks like we should just copy the specified range of the 
    # workspace to ToFile.
    #[String[]] $FileData = Read-FileContent $ToFile
    [String[]] $FileData =  @()

    foreach ($LineObject in $global:IpfWorkSpace.Lines.Values) {
      if (($LineObject.LineNumber -ge $LineFrom) -and ($LineObject.LineNumber -le $LineTo)) {
        $FileData += $LineObject.Line
      }
    }

    [Boolean]$WriteResult = Write-FileContent $ToFile ($FileData | Out-String)

    if ($Source -eq "Retain") {
      $global:IpfWorkSpace.CurrentImage = $RetainedPosition
    }

    if ($Source -eq "Delete") {
      # "$C is the image before the first image deleted in your workspace."  Huh?
    }
  }


  # in case of file-to-file merge, preserve CurrentImage
  if ((($FromFile -ne "") -and ($ToFile -ne "")) -or ($RetainPosition -eq "Preserve")) {
    $global:IpfWorkSpace.CurrentImage = $RetainedPosition
  }

  UpdateSpacePointers
} # Ipf-Merge


function Ipf-New {
  <#
    .SYNOPSIS
      ECL @Ipf equivalent NEW
    .DESCRIPTION
      Create a new workspace
    .PARAMETER Filename
      [String] Filename of the new workspace
  #>

  param (
    [String]$Filename
  )

  $global:IpfSv_CommandError = $false

  Write-JobLog "Ipf-New, filename: $Filename" ([LoggingSeverity]::Info)

  $Filename = Convert-FileReference $Filename
  Create-WorkLookSpace ([IpfObjectSpaceType]::Workspace) $Filename

  $global:IpfSv_StartColumn = 0
  $global:IpfSv_EndColumn = 0
  $global:IpfSv_MatchLine = 0
  $global:IpfSv_Results = 0

  UpdateSpacePointers
} # Ipf-New


function Ipf-Old {
  <#
    .SYNOPSIS
      ECL @Ipf equivalent OLD
    .DESCRIPTION
      Read a file into workspace or lookspace
    .PARAMETER Filename
      [String] Filename to read
    .PARAMETER Objectspace
      [String] Objectspace to use
  #>
  
  param (
    [String]$Filename,
    [String]$Object
  )

  $global:IpfSv_CommandError = $false

  Write-JobLog "Ipf-Old, filename: $Filename, objectspace: $Object" ([LoggingSeverity]::Info)

  $Filename = Get-AssignedFile (Convert-FileReference $Filename)

  if (-not $global:AmtFile.FileExists($Filename)) {
    # don't bother, set CommandError and leave
    $global:IpfSv_CommandError = $true
    return
  }

  [IpfObjectSpaceType]$IpfObject = $global:IpfSwitch 
  if ($Object -ne "") {
    try {
      $IpfObject = [Enum]::Parse([IpfObjectSpaceType], $Object)
    } catch [Exception] {
      $IpfObject = $global:IpfSwitch  
    }
  }

  Create-WorkLookSpace $IpfObject $Filename (Read-FileContent $Filename)
  $global:IpfSwitch = $IpfObject

  $global:IpfSv_StartColumn = 0
  $global:IpfSv_EndColumn = 0
  $global:IpfSv_MatchLine = 0
  $global:IpfSv_Results = 0

  UpdateSpacePointers
} # Ipf-Old


function Ipf-Replace {

  <#
    .SYNOPSIS
      ECL @Ipf equivalent REPLACE
    .DESCRIPTION
      Replace contents of a file with contents of workspace
    .PARAMETER Filename
      [String] Filename to write
  #>

  param (
    [String]$Filename
  )

  $global:IpfSv_CommandError = $false

  Write-JobLog "Ipf-Replace, filename: $Filename" ([LoggingSeverity]::Info)

  if ($global:IpfSwitch -eq [IpfObjectSpaceType]::Lookspace) {
    Abort "Replace on Lookspace is not allowed"
  }

  $Filename = Get-AssignedFile (Convert-FileReference $Filename)
  if ($Filename -eq "") {
    $Filename = $global:IpfWorkSpace.Filename
  }

  [String[]]$Lines = @()
  foreach ($LineObject in $global:IpfWorkSpace.Lines.Values) {
    $Lines += $LineObject.Line
  }

  $global:IpfSv_CommandError = -not (Write-FileContent $Filename ($Lines | Out-String))
} # Ipf-Replace


function Ipf-Switch {

  <#
    .SYNOPSIS
      ECL @Ipf equivalent SWITCH
    .DESCRIPTION
      Set the object space type.
    .PARAMETER Object
      [String] Object space to use.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Object
  )

  $global:IpfSv_CommandError = $false

  Write-JobLog "Ipf-Switch, object: $Object" ([LoggingSeverity]::Info)
  try {
    $global:IpfSwitch = [Enum]::Parse([IpfObjectSpaceType], $Object)
    $global:IpfSv_Switch = $Object
  } catch [Exception] {
    Abort "Invalid Objectspace $Object for SWITCH command"     
  }
} # Ipf-Switch


function Convert-FileReference {
  <#
    .SYNOPSIS
      Converts an ECL file reference to a Windows file system path.
    .DESCRIPTION
      Typically this is done by Asysco.Conversion.Ecl.EclFileMapping.ConvertFileReference but 
      in some cases file references are dynamically build by IPF expressions. If so, we have 
      to map the file reference at runtime.
    .PARAMETER $FileRef
      [String] The file reference to be mapped to the Windows environment.
    .OUTPUTS
      [String] The resulting Windows file system path.
  #>

  param (
    [string]$FileRef
  )

  $Path = ""
  $Element = ""

  $Index = $FileRef.IndexOf('.')

  if ($Index -gt -1) {
    $Path = $FileRef.Substring(0, $Index)  # before first .
    $ElementIndex = $FileRef.IndexOf('.', $Index + 1)
    if ($ElementIndex -gt -1) {
      $Element = $FileRef.Substring($Index + 1, $ElementIndex)
    } else {
      $Element = $FileRef.Substring($Index + 1)
    }
  } else {
    $Path = $FileRef
  }

  $Index = $Path.IndexOf('#')
  if ($Index -gt -1) {
    Add-WarningMsg "Directory id found in path (ignored): $Path"
    $Path = $Path.Substring($Index + 1)
  }

  $Cycle = ""
  $Index = $Path.IndexOf('(')
  if ($Index -gt -1) {
    $EndPos = $Path.IndexOf(')')
    $Cycle = $Path.Substring($Index, $EndPos - $Index + 1)
    $Path = $Path.Substring(0, $Index)  # Remove cycle and everything behind it (read-key, write-key)
  }

  $Index = $Path.IndexOf('/')  # read-key, write-key
  if ($Index -gt -1) {
    $Path = $Path.Substring(0, $Index)
  }

  if ($Element -ne $null -and $Element -ne "") {

    $Index = $Element.IndexOf('(')
    if ($Index -gt -1) {
      # remove S-cycle
      $Element = $Element.Substring(0, $Index)
    }

    $Path = $Path + "\" + $Element
  }

  # TODO: check temp file (TPF$, READ$, PRINT$, DIAG$)
  Return ($Path + $Cycle)
} # Convert-FileReference


function Ipf-Create {
  <#
    .SYNOPSIS
      IPF CREATE command: Catalogs a file on the system.
    .DESCRIPTION
      This needs to be done at runtime because the File can be 
      an IPF expression which can not be resolved earlier.
    .PARAMETER File
      [String] The name of the file.
    .PARAMETER Access
      [String] The file's access type ("PRIVATE" or "PUBLIC").
    .PARAMETER Life
      [String] The file's life span ("PERMANENT" or "TEMPORARY").
  #>

  param (
    [string]$File,
    [string]$Access,
    [string]$Life
  )

  $global:IpfSv_CommandError = $false

  if ($Life -eq "TEMPORARY") {
    $File = Check-Qual $File
    $File = $File.Trim(".")

    [String]$PathName = Get-PathName ([Ref]$File)  # Removes path from $Filename
    [String]$FilenameTemp = (Add-BackSlash $global:TempFolder) + $File
    $FilenameTemp = (Add-FileExtension $FilenameTemp $global:UseExtension)

    $global:IpfSv_CommandError = -not (Create-EmptyFile $FilenameTemp $false)
  } else  {
    $global:IpfSv_CommandError = -not (Asy-Cat "" (Convert-FileReference $File) $false)
  }
} # Ipf-Create


function Ipf-Copy {
  <#
    .SYNOPSIS
      IPF COPY command: Copies data from one file to another.
    .DESCRIPTION
      This needs to be done at runtime because the From and/or To 
      can be an IPF expression which can not be resolved earlier.
    .PARAMETER Options
      [String] A string containing a character for each ECL copy option.
    .PARAMETER From
      [String] The name of the file to copy the specified images from.
    .PARAMETER To
      [String] The name of the file to copy the specified images to.
    .PARAMETER FileTypes
      [String] The type(s) of file(s) to copy. This is a comma separated list of FileTypes names,
               anything equal to or less than "(Symbolic, Relocatable, Absolute, Omnibus)".
               Search for individual words to determine if a file type is included.
    .PARAMETER Retain
      [Boolean] A value indicating whether or not the printed file should be kept or removed.
  #>

  param (
    [string]$Options,
    [string]$From,
    [string]$To,
    [string]$FileTypes,
    [string]$Retain
  )

  # delegate to AsyCopy ignoring $FileTypes and $Retain
  $global:IpfSv_CommandError = -not (Asy-Copy $Options $From $To $false)
} # Ipf-Copy


function Ipf-Free {
  <#
    .SYNOPSIS
      IPF FREE command: Frees the assignment of a file or dismounts a volume from a device.
    .DESCRIPTION
      This needs to be done at runtime because the FileName can 
      be an IPF expression which can not be resolved earlier.
    .PARAMETER Options
      [String] A string containing free optiona.
    .PARAMETER FileName
      [String] The name of the file.
    .PARAMETER Actions
      [String] Any special actions to take. This is a comma separated list of FreeActions names,
               anything equal to or less than "(Exclusive, File, Name, RetainDrive)".
               Search for individual words to determine if a free action is included.
  #>

  param (
    [string]$Options,
    [string]$FileName,
    [string]$Actions
  )

  $global:IpfSv_CommandError = $false

  Free $Options (Get-AssignedFile (Convert-FileReference $FileName))
} # Ipf-Free


function Ipf-List {
  <#
    .SYNOPSIS 
      Display information about a directory, or a file included in a directory.
    .PARAMETER Filename
      [String] Name of the file or directory to list
    .PARAMETER Order
      [String] Specifies the order in which the files should be listed. Default value 
      is "FIRST" which means that the files are listed starting with the first file 
      inserted into the directory.
    .PARAMETER Count
      [String] Specifies maximum number of filenames to be listed. Default is ALL.
    .PARAMETER Type
      [String] Will list information of items of this type only. Defautl is ALL.
    .PARAMETER SubType
      [String] Will list information of items of this subtype only. Default is ALL.
    .PARAMETER Form
      [String] Defines the amount of detail wanted in the directory listing. Default is SHORT,
      which lists each file the name, type and subtype. Value LONG will list the name, type,
      subtype, size and the last updated date and time.
  #>

  param (
    [String]$Filename,
    [String]$Order,
    [String]$Count,
    [String]$Type,
    [String]$SubType,
    [String]$Form
  )

  $global:IpfSv_CommandError = $false

  Write-Joblog "Ipf-List, filename:$Filename, order:$Order, count:$Count, type:$Type, subtype:$SubType, form:$Form" ([LoggingSeverity]::Info)


  if ($Filename -eq "") {
    # TODO: No filename specified, use work directory 
  } else {
    $Filename = Get-AssignedFile (Convert-FileReference $Filename)
  }

  if ($Order -eq "") {
    $Order = "FIRST"
  }

  if ($Count -eq "") {
    $Count = "ALL"
  }

  if ($Type -eq "") {
    $Type = "ALL"
  }

  if ($SubType -eq "") {
    $SubType = "ALL"
  }

  if ($Form -eq "") {
    $Form = "SHORT"
  }

  [Object]$IpfFileObj = $null
  if ($global:IpfOutFilename -ne "") {
    # Output of list must be written to $global:IpfOutFilename
    $IpfFileObj = Open-TextFile $global:IpfOutFilename $global:Const_ExclusiveBatch $global:Const_FileEnc_Autodetect $true
    if ($global:AmtFile.ErrorCode -ne 0) {
      Abort "Ipf-List: Could not open IPF Out file: $($global:IpfOutFilename), error message: $($global:AmtFile.ErrorDescription)"
    }
  }

  [Boolean]$Flush = $true
  if (Folder-Exists $Filename) {
    # List information from all files in the folder. 
    [String]$Files = $global:AmtFile.GetFiles($Filename, $false)
    if ($global:AmtFile.ErrorCode -ne 0) {
      Abort "Ipf-List: Error calling GetFiles, error: $($global:AmtFile.ErrorDescription)"
    }

    [String[]]$FilesArr = $Files.Split(",")
    foreach ($File in $FilesArr) {
      if ($Form -eq "SHORT") {
        # List Name, Type and Subtype. Note that in Windows only name is available, so
        # we only list the filename
        if ($IpfFileObj -ne $null) {
          [Boolean]$WriteResult = $IpfFileObj.Write($File, $Flush)
        } else {
          Write-JobLog $File ([LoggingSeverity]::Warning)
        }
      } else {
        # List Name, Type, Subtype, Size, Last update date and time. In Windows the Type
        # and Subtype are not available.
        [Object]$FileInfo = $global:AmtFile.GetFileInfo($Filename + "\" + $File, 1)
        if ($IpfFileObj -ne $null) {
          [Boolean]$WriteResult = $IpfFileObj.Write("$File $($FileInfo.FileSize) $($FileInfo.LastAccessTime)", $Flush)
        } else {
          Write-JobLog "$File $($FileInfo.FileSize) $($FileInfo.LastAccessTime)" ([LoggingSeverity]::Warning)
        }
      }
    }
  } elseif (File-Exists $Filename) {
    # List info about file.
    if ($Form -eq "SHORT") {
      if ($IpfFileObj -ne $null) {
        [Boolean]$WriteResult = $IpfFileObj.Write($File, $Flush)
      } else {
        Write-JobLog $File ([LoggingSeverity]::Warning)
      }
    } else {
      [Object]$FileInfo = $global:AmtFile.GetFileInfo($Filename, 1)
      if ($IpfFileObj -ne $null) {
        [Boolean]$WriteResult = $IpfFileObj.Write("$($FileInfo.Name) $($FileInfo.FileSize) $($FileInfo.LastAccessTime)", $Flush)
      } else {
        Write-JobLog "$($FileInfo.Name) $($FileInfo.FileSize) $($FileInfo.LastAccessTime)" ([LoggingSeverity]::Warning)
      }
    }
  } else {
    Add-ErrorMsg "Ipf-List: File or folder $Filename does not exist"
  }

  if ($IpfFileObj -ne $null) {
    [Boolean]$CloseResult = Close-TextFile $IpfFileObj
  }
} # Ipf-List


function Ipf-Renumber {
  <#
    .SYNOPSIS 
      The RENUMBER command assigns new image numbers to the specified images.
      This is an EDIT command. See also EDIT 1100 User's Guide.
    .PARAMETER Range
      [String] Specifies range of images that will be renumbered. Default is ALL. 
      Note, currently only ALL is supported. 
    .PARAMETER Start
      [String] The new line number that will be assigned to the first image. Default value is 10.
    .PARAMETER Increment
      [String] The value that is added to generate the line number of each subsequent image. The default
      value is the value of the global variable $global:IpfSv_Increment.
    .PARAMETER Conflict
      [String] Indicates the action that should be taken if the renumbered images overlap existing images.
    .PARAMETER RetainPosition
      [String] Determines if the image pointer is in the same position when the command is processed.
  #>

  param (
    [String]$Range,
    [String]$Start_AsString,
    [String]$Increment_AsString,
    [String]$Conflict,
    [String]$RetainPosition
  )

  $global:IpfSv_CommandError = $false

  # type & initialize input
  #
  if ($Range -eq "") {
    $Range = "ALL"
  }

  [Decimal]$Start = 0
  if ($Start_AsString -eq "") {
    $Start = 10
  } else {
    $Start = $Start_AsString
  }

  [Decimal]$Increment = 0
  if ($Increment_AsString -eq "") {
    $Increment = $global:IpfSv_Increment
  } else {
    $Increment = $Increment_AsString
  }

  if ($Conflict -eq "") {
    $Conflict = $global:IpfSv_Conflict
  }

  if ($RetainPosition -eq "") {
    $RetainPosition = $global:IpfSv_RetainPosition
  }
  
  # Renumber applies to the workspace only
  [Decimal]$RetainedPosition = $global:IpfWorkSpace.CurrentImage

  Write-Joblog "Ipf-Renumber, Range:$Range, Start:$Start, Increment:$Increment" ([LoggingSeverity]::Info)

  # create a new lines object
  $NewLines = New-Object 'System.Collections.Generic.SortedList[Double,Object]'

  # populate the new lines object
  [Decimal]$ImageNumber = $Start
  foreach ($Line in $global:IpfWorkSpace.Lines.Values) {

    if ($RetainPosition -eq "Preserve" -and $global:IpfSv_CurrentImage -eq $Line.LineNumber) {
      $global:IpfWorkSpace.CurrentImage = $ImageNumber
    }

    $NewLines.Add($ImageNumber, (New-LineObject $ImageNumber $Line.Line))

    if ($RetainPosition -eq "Reset") {
      $global:IpfWorkSpace.CurrentImage = $ImageNumber
    }

    $ImageNumber += $Increment
  }

  # assign the new lines object to the lines object reference of the workspace
  $global:IpfWorkSpace.Lines = $NewLines

  if ($RetainPosition -eq "Preserve") {
    $global:IpfWorkSpace.CurrentImage = $RetainedPosition
  }

  UpdateSpacePointers  
} # Ipf-Renumber


function Ipf-Out {
  <#
    .SYNOPSIS
      Redirects the standard output data path
    .DESCRIPTION
      Output redirected to filename. This is currently mainly used for the LIST command, 
      to store it's output in a file.
    .PARAMETER Filename
      [String] Name of existing data file where the ouput data images are redirected to. To
      redirect the output back to the terminal, use TERMINAL.
    .PARAMETER Type
      [String] Indicates the type of output data images that should be send to the data file.
    .PARAMETER Echo
      [String] Specifies whether the images should simultaneously display at the terminal when
      going to the specified file.
  #>
  
  param (
    [String]$Filename,
    [String]$Type,
    [String]$Echo
  )

  $global:IpfSv_CommandError = $false

  Write-Joblog "Ipf-Out, filename:$Filename, Type:$Type, Echo:$Echo" ([LoggingSeverity]::Info)

  if ($Filename -eq "TERMINAL") {
    # No longer redirected.
    $global:IpfOutFilename = ""
  } else {
    $Filename = Get-AssignedFile (Convert-FileReference $Filename)
    $global:IpfOutFilename = $Filename

    [Object]$FileObj = Create-TextFile $Filename $global:Const_ExclusiveBatch $false $true
    if ($global:AmtFile.ErrorCode -ne 0) {
      Abort "Ipf-Out: ERROR: Could not create file: $Filename, error: $($global:AmtFile.ErrorDescription)"
    }

    [Boolean]$CloseResult = Close-TextFile $FileObj
    if ($global:AmtFile.ErrorCode -ne 0) {
      Abort "Ipf-Out: ERROR: Could not close file: $Filename, error: $($global:AmtFile.ErrorDescription)"
    }
  }
} # Ipf-Out


function Ipf-Save {
  <#
    .SYNOPSIS
      Copy the workspace into a file. An error will be reported if the file already exists.
    .PARAMETER Filename
      [String] Name of the file where the workspace should be saved. If not specified the current
      name of the workspace is used.
  #>

  param (
    [String]$Filename
  )

  $global:IpfSv_CommandError = $false

  Write-JobLog "Ipf-Save, filename: $Filename" ([LoggingSeverity]::Info)

  $Filename = Convert-FileReference $Filename
  if ($Filename -eq "") {
    $Filename = $global:IpfWorkSpace.Filename
  }

  if (File-Exists (Get-AssignedFile $Filename)) {
    Add-ErrorMsg "Ipf-Save: File $(Get-AssignedFile $Filename) already exists."
    return
  }

  [String[]]$Lines = @()
  foreach ($LineObject in $global:IpfWorkSpace.Lines.Values) {
    $Lines += $LineObject.Line
  }

  [Boolean]$Result = Write-FileContent $Filename ($Lines | Out-String)
} # Ipf-Save


function Ipf-Change {
  <#
    .SYNOPSIS
      ECL equivalent: CHANGE
      This is an EDIT command. See also EDIT 1100 User's Guide.
    .DESCRIPTION
      Use the CHANGE command to change occurrences of one string to another in all or part of
      the specified images, and to optionally display those images where a change was made.
    .PARAMETER String
    [String] The change string.
    .PARAMETER Range
    [String] The line\column Range. Can also be "A" or "ALL".
    .PARAMETER Repeat
    [Object] Max number of lines with occurrences to change over de specified range. 
             Can also be "A" or "ALL".
    .PARAMETER Incidents
    [Object] Number of occurrences to replace per line. Can also be "A" or "ALL".
    .PARAMETER Display
    [String] This controls whether or not changed images should display with line numbers.
             NOTE: Ignored for now.
    .PARAMETER Output
    [String] This controls whether or not changed images are displayed.
             NOTE: Ignored for now.
    .PARAMETER Matching
    [String] This controls whether you can use pattern-matching characters.
             NOTE: Ignored for now.
    .PARAMETER RetainPosition
    [String] Determines whether the current image pointer ($C) is keeped in the same position 
             when the command is processed. NOTE: Ignored for now.

    # TODO: pattern matching support
  #>

  param (
    [String]$String,
    [String]$Range,
    [String]$Repeat,     # Can be an integer or string ("A" or "ALL")
    [String]$Incidents,  # Can be an integer or string ("A" or "ALL")
    [String]$Display,
    [String]$Output,
    [String]$Matching,
    [String]$RetainPosition
  )

  $global:IpfSv_CommandError = $false

  # type & initialize input
  #
  if ($String -eq "") {
    $String = $global:IpfSv_ChangeString
  }

  if ($Range -eq "") {
    $Range = [String]$global:IpfSv_CurrentImage
  }

  if ($Repeat -eq "") {
    $Repeat = "1"
  }

  if ($Incidents -eq "") {
    $Incidents = "1"
  }

  if ($Display -eq "") {
    $Display = $global:IpfSv_Display
  }

  if ($Output -eq "") {
    $Output = $global:IpfSv_Output
  }

  if ($Matching -eq "") {
    $Matching = $global:IpfSv_Matching
  }

  if ($RetainPosition -eq "") {
    $RetainPosition = $global:IpfSv_RetainPosition
  }


  # CHANGE applies to the workspace only
  [Decimal]$RetainedPosition = $global:IpfWorkSpace.CurrentImage

  Write-JobLog "Ipf-Change String: $String, Range: $Range, Repeat: $Repeat, Incidents: $Incidents, Display: $Display, Output: $Output, Matching: $Matching, Retain: $RetainPosition" ([LoggingSeverity]::Info)

  if ($global:IpfSwitch -eq [IpfObjectSpaceType]::Lookspace) {
    Abort "Change on Lookspace is not allowed."
  }

  $String = $String.Trim()
  $Range = $Range.ToUpperInvariant()

  # Number of lines in the WorkSpace
  $LineCount = $global:IpfWorkSpace.Lines.Count

  if (($Incidents -eq "A") -or ($Incidents -eq "ALL")) {
    # Replace all occurrences from a line
    $Incidents = [Int32]::MaxValue
  }

  if (($Repeat -eq "A") -or ($Repeat -eq "ALL")) {
    # Repeat for all lines
    $Repeat = [Int32]$LineCount
  }

  $global:IpfSv_Results = 0

  # Get range values
  [Decimal]$LineFrom = -1
  [Decimal]$LineTo   = -1
  [Int32]$ColumnFrom = -1
  [Int32]$ColumnTo   = -1

  Get-Range $Range ([ref]$LineFrom) ([ref]$LineTo) ([ref]$ColumnFrom) ([ref]$ColumnTo)

  [String]$Old = ""
  [String]$New = ""

  # get old and new strings
  if (($String.StartsWith("(")) -and ($String.EndsWith(")"))) {
    # Form 2, => remove parenthesis, split and remove delim chars if present
    [String]$UnparenthesizedString = $String.Substring(1)
    $UnparenthesizedString = $UnparenthesizedString.Substring(0, $UnparenthesizedString.Length - 1)
    # split on comma
    $Parts = @()
    $Parts = $UnparenthesizedString.Split(',')
    $Old = $Parts[0]
    if ($Parts.Length -lt 2) {
      Abort "The CHANGE string (format 2) is not formatted correctly: $String"
    }
    $New = $Parts[1]
    # parts may be quoted
    if ($Old.StartsWith($IpfSv_DelimChar) -and $Old.EndsWith($IpfSv_DelimChar) -and ($Old.Replace([String]$IpfSv_DelimChar, "").Length -eq $Old.Length - 2)) {
      $Old = $Old.Substring(1)
      $Old = $Old.Substring(0, $Old.Length - 1)
    }
    if ($New.StartsWith($IpfSv_DelimChar) -and $New.EndsWith($IpfSv_DelimChar) -and ($New.Replace([String]$IpfSv_DelimChar, "").Length -eq $New.Length - 2)) {
      $New = $New.Substring(1)
      $New = $New.Substring(0, $New.Length - 1)
    }
  } elseif ($String[0] -eq $String[$String.Length - 1]) {
    # Form 1, => strip outer delimiters
    [String]$Delimiter = $String[0]
    [String]$InnerString = $String.Substring(1)
    $InnerString = $InnerString.Substring(0, $InnerString.Length - 1)
    $Parts = @()
    $Parts = $InnerString.Split($Delimiter)
    if ($Parts.Length -ne 2) {
      Abort "The CHANGE string (format 1) is not formatted correctly: $String"
    }
    $Old = $Parts[0]
    $New = $Parts[1]
  } else {
    Abort "The CHANGE string is not formatted correctly: $String"
  }

  # Keep track of repeat
  [Int32]$RepeatCounter = $Repeat

  [Boolean]$Hit = $false

  # Check & replace each line in the provided range
  for ($Index = 0; $Index -lt $global:IpfWorkSpace.Lines.Count; $Index++) {
  
    [Object]$CurrentLine = $global:IpfWorkSpace.Lines.Values[$Index]

    if (($CurrentLine.LineNumber -lt $LineFrom) -or ($CurrentLine.LineNumber -gt $LineTo)) {
      continue
    }

    if ($ColumnFrom -gt $CurrentLine.Line.Length - 1) {
      continue
    }

    if ($RepeatCounter -lt 1) {
      # No more repeats left, so exit the loop
      break
    }

    # this may not be used, just in case we will have a hit we want to know at what position
    $StartColumn = $CurrentLine.Line.IndexOf($Old)    # 0-based
    $EndColumn = $StartColumn + $New.Length - 1  # 0-based

    # Apply the change on a temporary string
    [String]$Temp = $CurrentLine.Line
    [Int32]$TempLen = $Temp.Length
    [Int32]$TempTo = $ColumnTo
    if ($TempTo -gt $TempLen - 1) {
      $TempTo = $TempLen - 1
    }

    $Temp = $Temp.Substring(0, $TempTo + 1)

    $ClippedTemp = $Temp.Substring($ColumnFrom)
    for ([Int32]$Count = 1; $Count -le $Incidents; $Count++) {

      # Hard coded hack to support single occurrence of full pattern matching (P$JOBC\BCROSS and P$JOBC\BCROSX)
      # Please remove when pattern matching is properly implemented.
      # --- begin
      if ($matching -eq "Full" -and $Old -eq "??" -and $Range -eq "A\1:2") {
        # strip the first 2 characters
        if ($ClippedTemp.Length -gt 2) {
          $ClippedTemp = $ClippedTemp.Substring(3)
        } else {
          $ClippedTemp = ""
        }
      }
      # --- end

      # note: we want to replace one instance of $Old only
      [Int32]$FirstOldIndex = $ClippedTemp.IndexOf($Old)
      if ($FirstOldIndex -gt -1) {
        [Int32]$SearchLength = $FirstOldIndex + $Old.Length
        $PartToBeModified = $ClippedTemp.Substring(0, $SearchLength)
        if ($PartToBeModified.Contains($Old)) {
          $Hit = $true
        }
        $PartWithSingleReplacement = $PartToBeModified.Replace($Old, $New)
        if ($ClippedTemp.Length -gt $SearchLength) {
          $ClippedTemp = $PartWithSingleReplacement + $ClippedTemp.Substring($SearchLength)
        } else {
          $ClippedTemp = $PartWithSingleReplacement
        }
      } else {
        break
      }
    }

    $Temp = $Temp.Substring(0, $ColumnFrom) + $ClippedTemp

    $global:IpfSv_ChangeString = "(" + $Old + "," + $New + ")"

    # grab the part after the change from the original line and append it to $Temp
    # (but don't try this if there is no remaining part to prevent an index out of bounds)
    if ($TempTo -lt $CurrentLine.Line.Length - 1) {
      $Temp += $CurrentLine.Line.Substring($TempTo + 1)
    }

    if ($Temp -ne $CurrentLine.Line) {
      # Match found so apply the change and decrement repeat
      $CurrentLine.Line = $Temp
      $RepeatCounter--
      $global:IpfWorkSpace.CurrentImage = $CurrentLine.LineNumber
      $global:IpfSv_Matchline = $CurrentLine.LineNumber
      $global:IpfSv_StartColumn = $StartColumn + 1    # one based
      $global:IpfSv_EndColumn = $EndColumn + 1        # one based
      $global:IpfSv_Results++

      # display output
      if ($Display -ne "Brief") {
        # never mind Scale or Compress, that seems only useful on a character terminal
        [String]$Msg = ""
        if ($Display -eq "Number") {
          $Msg = $CurrentLine.LineNumber + " "
        }
        $Msg += $CurrentLine.Line
        Add-InformationMsg($Msg)
      }
    }
  }

  if ($RetainPosition -eq "Preserve") {
    $global:IpfWorkSpace.CurrentImage = $RetainedPosition
  }

  $global:IpfSv_CommandError = -not $Hit

  UpdateSpacePointers
} # Ipf-Change


function Ipf-Mode {
  <#
    .SYNOPSIS
      Set the editing mode.
      This is an EDIT command. See also EDIT 1100 User's Guide.
    .PARAMETER Format
      [String] The chosen editing mode (either "Line", "Screen" or an empty string for the default).
    .PARAMETER ModeType
      [String] The chosen mode type (either "Browse" for read-only access, "Update" for write-access or an empty string for the default).
  #>

  param (
    [String]$Format,
    [String]$ModeType
  )

  $global:IpfSv_CommandError = $false

  if ($Format -eq "") {
    if ($global:IpfSv_FullScreen) {
      $Format = "Screen"
    } else {
      $Format = "Line"
    }
  }

  if ($ModeType -eq "") {
    if ($global:IpfSv_ReadOnly) {
      $Format = "Browse"
    } else {
      $Format = "Update"
    }
  }

  $global:IpfSv_ReadOnly = ($Format -eq "Browse")

  # there is not much we can or need to do
} # Ipf-Mode


function Ipf-Describe {
  <#
    .SYNOPSIS
      Displays information about the specified directories or data files.
    .PARAMETER FileNames
      [String[]] The names of the files to be described.
  #>

  param (
    [String[]]$FileNames
  )

  $global:IpfSv_CommandError = $false

  # just display the file names that were described in the original system
  foreach ($FileName in $FileNames) {
    Add-InformationMsg "Describe: $FileName"
  }
} # Ipf-Describe


function Get-Range {
  <#
    .SYNOPSIS
      Retrieves the lines numbers and (0-based) column indexes from a range parameter.
    .PARAMETER Range
      [String] String containing the range value.
    .PARAMETER LineFrom
      [Ref] Will contain the from line number after processing.
    .PARAMETER LineTo
      [Ref] Will contain the to line number after processing.
    .PARAMETER ColumnFrom
      [Ref] Contains the from column after processing.
    .PARAMETER ColumnTo
      [Ref] Contains the to column after processing (inclusive).
  #>

  param (
    [String]$Range=[String]$global:IpfSv_CurrentImage,
    [Ref][Decimal]$LineFrom,
    [Ref][Decimal]$LineTo,
    [Ref][Int32]$ColumnFrom,
    [Ref][Int32]$ColumnTo
  )

  $Range = $Range.ToUpperInvariant()

  # default values
  $LineFrom.Value   = $global:IpfSv_CurrentImage
  $LineTo.Value     = $global:IpfSv_CurrentImage
  $ColumnFrom.Value = 1
  $ColumnTo.Value   = [Int32]::MaxValue

  [String]$LinePart    = ""
  [String]$ColumnPart  = ""
  [String[]]$LineParts = @()

  [Object]$ObjectSpace = $null
  if ($global:IpfSwitch -eq [IpfObjectSpaceType]::Workspace) {
    $ObjectSpace = $global:IpfWorkSpace
  } else {
    $ObjectSpace = $global:IpfLookSpace
  }

  try {
    # Handle <line>\<column>
    if ($Range.IndexOf('\') -eq 0) {
      # Only column specified, so it is a change on the current line
      $ColumnPart = $Range.Substring(1)
      $LineFrom.Value = $ObjectSpace.CurrentImage
      $LineTo.Value = $ObjectSpace.CurrentImage
    } elseif ($Range.IndexOf('\') -gt 0) {
      # Line and column part
      $LinePart = $Range.Split('\')[0].Trim()
      $ColumnPart = $Range.Split('\')[1].Trim()
    } else {
      # Only a line part
      $LinePart = $Range
    }

    # Handle <from line> : <to line>
    if ($Linepart -ne "") {
      if ($Linepart.IndexOf(':') -gt -1) {
        $LineParts = $LinePart.Split(':')
        $LinePart = $LineParts[0].Trim()
      }

      switch ($LinePart) {
        "A" {
          $LineFrom.Value = 0
          $LineTo.Value = [Decimal]::MaxValue
          break
        }
        "ALL" {
          $LineFrom.Value = 0
          $LineTo.Value = [Decimal]::MaxValue
          break
        }
        default {
          if ($LineParts.Count -gt 1) {
            # From and to line numbers
            $LineFrom.Value = [Decimal]$LineParts[0].Trim()
            $LineTo.Value = [Decimal]$LineParts[1].Trim()
          } else {
            # Only a from line number
            $LineFrom.Value = [Decimal]$LinePart
            $LineTo.Value = [Decimal]$LinePart
          }
          break
        }
      }
    }

    # Handle <from column> : <to column>
    if ($ColumnPart -ne "") {
      if ($Columnpart.IndexOf(':') -gt -1) {
        # From and To column specified
        $ColumnFrom.Value = $ColumnPart.Split(':')[0].Trim()
        $ColumnTo.Value = $ColumnPart.Split(':')[1].Trim()
      } else {
        # Only from column specified
        $ColumnFrom.Value = $ColumnPart
      }
    }

    # ECL column index is 1-based, PowerShell is 0-based
    $ColumnFrom.Value--
    $ColumnTo.Value--
  } catch [Exception] {
    Abort "Get-Range: Could not handle range [$($Range)]: $($_.Exception.Message)"
  }
} # Get-Range


function Get-ObjectSpaceLine {
  <#
    .SYNOPSIS
      Searches the active space (Workspace/Lookspace) for the provided line number 
      and returns corresponding Line object.
    .PARAMETER LineNo
      [Int32] Line number
    .OUTPUTS
      Line object or $null when the line number could not be found.
  #>

  param (
    [Parameter(Mandatory=$true)][Decimal]$LineNo
  )

  [Object]$ObjectSpace = $null
  if ($global:IpfSwitch -eq [IpfObjectSpaceType]::Workspace) {
    $Objectspace = $global:IpfWorkSpace
  } else {
    $Objectspace = $global:IpfLookSpace 
  }

  [Int32]$Index = 0
  [Object]$Result = $null

  if ($Objectspace.Lines.ContainsKey($LineNo)) {
    $Result = $Objectspace.Lines[$LineNo]
  }

  return $Result
} # Get-ObjectSpaceLine


function Ipf-Site {
  <#
    .SYNOPSIS
      Print all or part of the specified images in the workspace at the onsite or remote printer.
      This is an EDIT command. See also EDIT 1100 User's Guide.
    .PARAMETER Device
      [String] The device where the workspace is to be printed.
    .PARAMETER Range
      [String] The line/column range of images that should be printed.
    .PARAMETER Display
      [String] Indicates whether the lines should be displayed with the printed images.
    .PARAMETER Count
      [String] Number of copies to send to the print device.
    .PARAMETER RetainPosition
      [String] Determines if the current image pointer should be kept after the Ipf-Site call.
    .PARAMETER Banner
      [String] The banner on the first page of output. Default value is JOBID global var.
  #>

  param (
    [String]$Device,
    [String]$Range,
    [String]$Display,
    [String]$Count_AsString,
    [String]$RetainPosition,
    [String]$Banner
  )

  $global:IpfSv_CommandError = $false

  # type & initialize input
  #
  if ($Device -eq "") {
    $Device = $global:IpfSv_Device
  }

  if ($Range -eq "") {
    $Range = "ALL"
  }

  if ($Display -eq "") {
    $Display = $global:IpfSv_Display
  }

  [Int32]$Count = 0
  if ($Count_AsString -eq "") {
    $Count = 1
  } else {
    $Count = [Int32]$Count_AsString
  }

  if ($RetainPosition -eq "") {
    $RetainPosition = $global:IpfSv_RetainPosition
  }

  if ($Banner -eq "") {
    $Banner = $global:JobName
    if ($Banner.Length -gt 5) {
      $Banner = $Banner.Substring(0, 6)
    }
  }


  Write-JobLog "Ipf-Site, Device:$Device, Range:$Range, Display:$Display, Count:$Count, RetainPosition:$RetainPosition, Banner:$Banner" ([LoggingSeverity]::Info)

  # Get range values
  [Decimal]$LineFrom = -1
  [Decimal]$LineTo   = -1
  [Int32]$ColumnFrom = -1
  [Int32]$ColumnTo   = -1

  Get-Range $Range ([ref]$LineFrom) ([ref]$LineTo) ([ref]$ColumnFrom) ([ref]$ColumnTo)


  # Store the images to be printed in a temporary file.
  [String]$TempFile = $global:TempFolder + "\" + $global:JobName + "_PRINT_" + (Get-UniqueNumber)
  [Object]$FileObj = Create-TextFile $TempFile $global:Const_ExclusiveBatch $false $true
  if ($global:AmtFile.ErrorCode -ne 0) {
    Add-ErrorMsg "Ipf-Site, could not create print file, error: $($global:AmtFile.ErrorDescription)"
    return
  }

  # This function works on the IPF Workspace.
  [Object]$ObjectSpace = $global:IpfWorkSpace

  [Decimal]$RetainedPosition = $Objectspace.CurrentImage

  # Print all images by default
  [String[]]$Lines = @()
  foreach ($LineObject in $ObjectSpace.Lines.Values) {
    if ($LineObject.LineNumber -ge $LineFrom -and $LineObject.LineNumber -le $LineTo) {
      # note: not sure how to deal with column ranges, ignore for now

      if ($Display -eq "Number") {
        $Lines += ($LineObject.LineNumber + "  " + $LineObject.Line)
      } else {
        $Lines += $LineObject.Line
      }

      $global:IpfWorkSpace.CurrentImage = $LineObject.LineNumber
    }
  }

  [Boolean]$WriteResult = Write-FileContent $TempFile ($Lines | Out-String)
  [Boolean]$CloseResult = Close-TextFile $FileObj

  # Create the bannerfile
  [String]$BannerFile = $global:TempFolder + "\" + $global:JobName + "_BANNER_" + (Get-UniqueNumber)
  [Object]$FileObj = Create-TextFile $BannerFile $global:Const_ExclusiveBatch $false $true
  if ($global:AmtFile.ErrorCode -ne 0) {
    Add-ErrorMsg "Ipf-Site, could not create banner file, error: $($global:AmtFile.ErrorDescription)"
    return
  }

  Write-BigChars $Banner $FileObj

  [Boolean]$CloseResult = Close-TextFile $FileObj

  $global:AmtPrint.ClearSettings()
  $global:AmtPrint.NumCopies = $Count
  $global:AmtPrint.ForcePrint = $true
  $global:AmtPrint.Wait = $true
  $global:AmtPrint.BannerFile = $BannerFile
  $global:AmtPrint.WaitTimeOut = 5 # Wait for max 5 seconds.

  [Int32]$PrintResult = $global:AmtPrint.PrintFile($TempFile, $Device)
  if ($global:AmtPrint.ErrorCode -ne 0) {
    Add-ErrorMsg "Ipf-Site: Error printing: $($global:AmtPrint.ErrorDescription)"
  }

  if ($RetainPosition -eq "Preserve") {
    $Objectspace.CurrentImage = $RetainedPosition
  }

  UpdateSpacePointers
} # Ipf-Site


function Ipf-Delete {
  <#
    .SYNOPSIS
      This is an EDIT command. See also EDIT 1100 User's Guide.
    .DESCRIPTION
      Use the DELETE command to delete all or part of the specified images from the
      workspace.
    .PARAMETER Range
    [String] The line\column Range. Can also be "A" or "ALL".
    .PARAMETER Output
    [String] This controls whether or not changed images are displayed.
             NOTE: Ignored for now.
    .PARAMETER RetainPosition
    [String] Determines whether the current image pointer is kept in the same position 
             when the command is processed. NOTE: Ignored for now.
  #>

  param (
    [String]$Range,
    [String]$Output,
    [String]$RetainPosition
  )

  $global:IpfSv_CommandError = $false

  # type & initialize input
  #
  if ($Range -eq "") {
    $Range = [String]$global:IpfSv_CurrentImage
  }

  if ($Output -eq "") {
    $Output = $global:IpfSv_Output
  }

  if ($RetainPosition -eq "") {
    $RetainPosition = $global:IpfSv_RetainPosition
  }


  # DELETE applies to the workspace only
  [Decimal]$RetainedPosition = $global:IpfWorkSpace.CurrentImage

  Write-Joblog "Ipf-Delete Range: $Range, Output: $Output, RetainPosition: $RetainPosition" ([LoggingSeverity]::Info)

  if ($global:IpfSwitch -eq [IpfObjectSpaceType]::Lookspace) {
    Abort "Delete on Lookspace is not allowed."
  }

  # Number of lines in the WorkSpace
  $LineCount = $global:IpfWorkSpace.Lines.Count

  try {
    # Get range values
    [Decimal]$LineFrom = -1
    [Decimal]$LineTo   = -1
    [Int32]$ColumnFrom = -1
    [Int32]$ColumnTo   = -1

    Get-Range $Range ([ref]$LineFrom) ([ref]$LineTo) ([ref]$ColumnFrom) ([ref]$ColumnTo)

    for ($Index = $global:IpfWorkSpace.Lines.Count - 1; $Index -ge 0; $Index--) {

      [Object]$CurrentLine = $global:IpfWorkSpace.Lines.Values[$Index]

      if (($CurrentLine.LineNumber -lt $LineFrom) -or ($CurrentLine.LineNumber -gt $LineTo)) {
        continue
      }

      $FirstChar = $ColumnFrom
      $LastChar = $ColumnTo

      if ($FirstChar -gt $CurrentLine.Line.Length - 1) {
        # if FirstChar is greater than Line.Length - 1, there is nothing to delete
        continue
      }

      if ($LastChar -gt $CurrentLine.Line.Length - 1) {
        # LastChar cannot be greater than Line.Length - 1
        $LastChar = $CurrentLine.Line.Length - 1
      }

      $CurrentLine.Line = $CurrentLine.Line.Remove($FirstChar, $LastChar - $FirstChar + 1)
      $global:IpfWorkSpace.CurrentImage = $CurrentLine.LineNumber

      if ($CurrentLine.Line -eq "") {
        # remove the empty line
        $global:IpfWorkSpace.Lines.RemoveAt($Index)

        if ($Index -gt 1) {
          $global:IpfWorkSpace.CurrentImage = $global:IpfWorkSpace.Lines.Values[$Index - 1].LineNumber
        } else {
          $global:IpfWorkSpace.CurrentImage = $global:IpfWorkSpace.Lines.Values[$Index].LineNumber
        }
      }
    }

    if ($RetainPosition -eq "Preserve") {
      $global:IpfWorkSpace.CurrentImage = $RetainedPosition
    }

    UpdateSpacePointers
  } catch [Exception] {
    Abort "Ipf-Delete: $($_.Exception.Message)"
  }
} # Ipf-Delete

# Display function needed for sort library.
function Display {
  <#
    .SYNOPSIS
      Sends a message to the Control Center.
    .PARAMETER Message
      [String] Message
  #>
  param (
    [String]$Message
  )
  if (-not [String]::IsNullOrEmpty($Message)) {
    if (($Null -eq $global:Com) -or ($global:Com.Station -ne $global:Initiator)) {
      Write-Host $Message
    }     
    Write-JobLog -Message $Message
    if($Null -ne $global:AmtMessage) {
      [Void]$global:AmtMessage.AddMsgInformation("$global:AppName $global:JobName : $Message")
    }
  }
} # Display

function Ipf-Display {
  <#
    .SYNOPSIS
      The IPF DISPLAY command.
    .DESCRIPTION
      Writes text to the standard output.
    .PARAMETER Value
      [String] The text to be output.
    .PARAMETER MessageClass
      [String] The output stream to direct the value to.
  #>

  param (
    [String]$Value="",
    [String]$MessageClass="Data"
  )


  switch ($MessageClass) {

    "Data"  { # The standard output data stream.
	  # note: this may be re-directed by a @BRKPT to end up in an input file, => make sure not to mess with the value.
      Write-JobLog $Value ([LoggingSeverity]::Error) $true
      break
    }

    "Remark"  { # The standard error data stream.
      Add-InformationMsg $Value
      break
    }

    "Warning"  { # The standard error data stream.
      Add-WarningMsg $Value
      break
    }

    "Error"  { # The standard error data stream.
      Add-ErrorMsg $Value
      break
    }

    "Command"  { # The terminal (when $FULLSCREEN=FALSE) or the command region (when $FULLSCREEN=TRUE). => console
      Write-Host $Value
      break
    }

    "Operator"  { # The system console.
      Write-Host $Value
      break
    }

    default {
      abort "Unexpected MessageClass argument: $MessageClass"
    }
  }

} # Ipf-Display


function Ipf-Top {
  <#
    .SYNOPSIS
      Use the TOP command to move the image pointer to the first image in your workspace.
      This is an EDIT command. See also EDIT 1100 User's Guide.
  #>

  $global:IpfSv_CommandError = $false

  [Object]$ObjectSpace = $null
  if ($global:IpfSwitch -eq [IpfObjectSpaceType]::Workspace) {
    $Objectspace = $global:IpfWorkSpace
  } else {
    $Objectspace = $global:IpfLookSpace 
  }

  if ($Objectspace -ne $null) {
    if ($Objectspace.Lines.Count -gt 0) {
      $Objectspace.CurrentImage = $Objectspace.Lines.Keys[0]
      $global:IpfSv_CurrentImage = $Objectspace.CurrentImage
    }
  }
} # Ipf-Top 


function Ipf-Bottom {
  <#
    .SYNOPSIS
      Use the BOTTOM command to move the image pointer to the last image in your workspace.
      This is an EDIT command. See also EDIT 1100 User's Guide.
  #>

  $global:IpfSv_CommandError = $false

  [Object]$ObjectSpace = $null
  if ($global:IpfSwitch -eq [IpfObjectSpaceType]::Workspace) {
    $Objectspace = $global:IpfWorkSpace
  } else {
    $Objectspace = $global:IpfLookSpace 
  }

  if ($Objectspace -ne $null) {
    if ($Objectspace.Lines.Count -gt 0) {
      $Objectspace.CurrentImage = $Objectspace.Lines.Keys[$Objectspace.Lines.Count - 1]
      $global:IpfSv_CurrentImage = $Objectspace.CurrentImage
    }
  }
} # Ipf-Bottom


function Ipf-LogOff {
  <#
    .SYNOPSIS
      The LOGOFF command terminates the IPF session.
  #>

  $global:IpfSv_CommandError = $false

  # Reset IPF system variables
  Initialize-IpfSystemVariables

  # Remove WorkSpace and Lookspace
  $global:IpfWorkSpace = $null
  $global:IpfLookSpace = $null
} # Ipf-LogOff


function Ipf-Print {
  <#
    .SYNOPSIS
      ECL equivalent: PRINT
      This is an EDIT command. See also EDIT 1100 User's Guide.
    .DESCRIPTION
      Use the PRINT command to display all or part of the specified images.
    .PARAMETER Range
      [String] The line\column Range. Can also be "A" or "ALL".
    .PARAMETER Display
      [String] Indicates whether the lines should be displayed with the printed images.
    .PARAMETER Output
      [String] This controls whether or not changed images are displayed.
               NOTE: Ignored for now.
    .PARAMETER RetainPosition
      [String] Determines whether the current image pointer ($C) is keeped in the same position 
               when the command is processed. NOTE: Ignored for now.
  #>

  param (
    [String]$Range,
    [String]$Display,
    [String]$Output,
    [String]$RetainPosition
  )

  $global:IpfSv_CommandError = $false

  # type & initialize input
  #
  if ($Range -eq "") {
    $Range = [String]$global:IpfSv_CurrentImage
  }

  if ($Display -eq "") {
    $Display = $global:IpfSv_Display
  }

  if ($Output -eq "") {
    $Output = $global:IpfSv_Output
  }

  if ($RetainPosition -eq "") {
    $RetainPosition = $global:IpfSv_RetainPosition
  }


  [Decimal]$RetainedPosition = $global:IpfWorkSpace.CurrentImage

  Write-Joblog "Ipf-Print Range: $Range, Display: $Display, Output: $Output, RetainPosition: $RetainPosition" ([LoggingSeverity]::Info)

  $Range = $Range.ToUpperInvariant()
  $Display = $Display.ToUpperInvariant()
  $Output = $Output.ToUpperInvariant()
  [String[]]$Ranges = @()

  [Object]$ObjectSpace = $null
  if ($global:IpfSwitch -eq [IpfObjectSpaceType]::Workspace) {
    $Objectspace = $global:IpfWorkSpace
  } else {
    $Objectspace = $global:IpfLookSpace
  }

  # Number of lines in the WorkSpace
  $LineCount = $ObjectSpace.Lines.Count

  # Split range-list
  if ($Range.IndexOf(',') -gt -1) {
    # Multiple ranges
    $Ranges = $Range.Split(',')
  } else {
    # A single range
    $Ranges += $Range
  }

  foreach ($TempRange in $Ranges) {
    $TempRange = $TempRange.Trim()

    try {
      # Get range values
      [Decimal]$LineFrom = -1
      [Decimal]$LineTo   = -1
      [Int32]$ColumnFrom = -1
      [Int32]$ColumnTo   = -1

      Get-Range $TempRange ([ref]$LineFrom) ([ref]$LineTo) ([ref]$ColumnFrom) ([ref]$ColumnTo)

      if ($LineTo -gt $LineCount) {
        # LineTo cannot be greater than total number of lines in the active space
        $LineTo = $LineCount
      }

      for ($Index = 0; $Index -lt $ObjectSpace.Lines.Count; $Index++) {

        [Object]$CurrentLine = $Objectspace.Lines.Values[$Index]

        if (($CurrentLine.LineNumber -lt $LineFrom) -or ($CurrentLine.LineNumber -gt $LineTo)) {
          continue
        }

        [String]$Prefix = ""
        if ($Display -eq "NUMBER") {
          # Prefix the line with its line number
          $Prefix = [String]$CurrentLine.LineNumber
          $Prefix += " "
        }

        if ($ColumnFrom -le 0) {
          # No column range specified, so just print the whole line
          [String]$Msg = $Prefix + $CurrentLine.Line
          Add-InformationMsg $Msg
        } else {
          # Column range specified so display a part of the line
          [Int32]$TempTo = $ColumnTo

          if (($TempTo -gt $CurrentLine.Line.Length - 1)) {
            $TempTo = $CurrentLine.Line.Length - 1
          }

          [String] $Msg = $Prefix + $CurrentLine.Line.SubString($ColumnFrom, $TempTo - $ColumnFrom + 1)
          Add-InformationMsg $Msg
        }
      }

      if ($RetainPosition -eq "Preserve") {
        $Objectspace.CurrentImage = $RetainedPosition
      }

      UpdateSpacePointers
    } catch [Exception] {
      Abort "Ipf-Print: $($_.Exception.Message)"
    }
  }
} # Ipf-Print


function Check-Abort {
  <#
    .SYNOPSIS
      Checks whether Abort is called in a dot-sourced script. 
      If so, the script will start Cleanup and exit afterwards.
  #>

  if ($global:AbortCalled) {
    Cleanup
  }
} # Check-Abort


function Replace-Asterisks {
  <#
    .SYNOPSIS
      Replaces asterisks (*) with underscores (_).
  #>

  param (
    [Ref]$Filename
  )

  $Filename.Value = $Filename.Value.Replace("*", "\")
} # Replace-Asterisks


function UpperAllButLiterals {
  <#
    .SYNOPSIS
      Converts a string to uppercase leaving anything within quotes as is.
    .PARAMETER S
      [String] The string to be converted.
  #>
  param (
    [String]$S
  )

  [String]$SUppered = ""
  [Boolean]$InSingleQuotes = $false
  [Boolean]$InDoubleQuotes = $false

  for ([Int32]$i = 0; $i -lt $S.Length; $i++) {
    if ($S[$i] -eq "`'") { 
      $InSingleQuotes = -not $InSingleQuotes
    }

    if ($S[$i] -eq "`"") { 
      $InDoubleQuotes = -not $InDoubleQuotes
    }

    if ((-not $InSingleQuotes) -and (-not $InDoubleQuotes)) {
      $SUppered += $S.Substring($i, 1).ToUpperInvariant()
    } else {
      $SUppered += $S[$i]
    }
  }

  return $SUppered
} # UpperAllButLiterals


function Call-ExternalProgram {
  <#
    .SYNOPSIS
      Dummy function mimic call an external program.
    .DESCRIPTION
      Does not do anything yet
    .PARAMETER Filename
      [String] The name of the program file.
    .PARAMETER Options
      [String] The command's options.
    .PARAMETER End
      [String] A value indicating whether the processor or compiler is to begin executing immediately or not.
    .PARAMETER ArgumentSet
      [String[]] The set of arguments directly following the file name as a CrLf-separated list.
  #>

  param (
    [String]$Filename,
    [String]$Options,
    [String]$End,
    [String[]]$ArgumentSet
  )

  Add-InformationMsg "Ipf call to $Filename skipped."

  # Start-Process $Filename -ArgumentList $ArgumentSet

} # Call-ExternalProgram


function UpdateSpacePointers {
  <#
    .SYNOPSIS
      Updates object space related system variables.
    .DESCRIPTION
      Updates $global:IpfSv_TopImage, $global:IpfSv_BottomImage, $global:IpfSv_CurrentImage after mutations to the current object space.
  #>

  [Object]$ObjectSpace = $null
  if ($global:IpfSwitch -eq [IpfObjectSpaceType]::Workspace) {
    $ObjectSpace = $global:IpfWorkSpace
  } else {
    $ObjectSpace = $global:IpfLookSpace
  }

  $global:IpfSv_TopImage = 0
  $global:IpfSv_BottomImage = 0
  foreach ($LineObject in $ObjectSpace.Lines.Values) {
    if ($global:IpfSv_TopImage -eq 0) {
      $global:IpfSv_TopImage = $LineObject.LineNumber
	}

    $global:IpfSv_BottomImage = $LineObject.LineNumber
  }

  $global:IpfSv_CurrentImage = $ObjectSpace.CurrentImage
} # UpdateSpacePointers


function Condense {
  <#
    .SYNOPSIS
      Condenses an object.
    .DESCRIPTION
      If it is a string, whitespace at the end will be removed. 
      If it is not a string, the original value will be output.
      This enables compliance with OS2200 behavior regarding string comparison expressions.
      (where " " equals "").

      While we're at it, also take into account the value of $global:IpfSv_CaseSensitive 
      to make the comparison case insensitive if needed.
     .PARAMETER Message
      The expression to be condensed.
  #>

  param (
    $Object
  )

  if ($Object.GetType().FullName -eq "System.String") {
    if ($global:IpfSv_CaseSensitive) {
      return $Object.TrimEnd()
    } else {
      return $Object.TrimEnd().ToUpperInvariant()
    }
  } else {
    return [String]$Object
  }
} # Condense


function Time {
  <#
    .SYNOPSIS
      ECL equivalent: @TIME
    .DESCRIPTION
      The @TIME statement outputs the current date and time to the run log.
      Used between batch steps to record timing information.
  #>

  if (Process-Skip "TIME") {
    return
  }

  Check-FinishStatement

  [String]$timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
  Write-Joblog "TIME: $timestamp" ([LoggingSeverity]::Info)

  [EclDatalineStatement]$global:PreviousStatement = [EclDatalineStatement]::None
} # Time


function UnknownProcessorCall {
  <#
    .SYNOPSIS
      Called for any ECL unknown processor call.
    .DESCRIPTION
      This signals the current statement, telling what kind of data lines to expect.
    .PARAMETER Processor
      The processor's name.
    .PARAMETER RawOptions
      The processor's raw options (whatever is immediately behind the comma attached to the processor).
    .PARAMETER Operands
      The processor call statement's operands.
  #>

  param (
   [String]$Processor,
   [String]$RawOptions,
   [String[]]$Operands
  )

  if (Process-Skip "UnknownProcessorCall $Processor") {
    return
  }

  Check-FinishStatement

   if ($Processor -eq "DD") {
     [EclDatalineStatement]$global:PreviousStatement = [EclDatalineStatement]::Dd
   } elseif ($Processor -eq "RDMSLOAD") {
     [EclDatalineStatement]$global:PreviousStatement = [EclDatalineStatement]::RdmsLoad
   } else {
     [EclDatalineStatement]$global:PreviousStatement = [EclDatalineStatement]::None
   }
} # UnknownProcessorCall


function RdmsLoad {
  <#
    .SYNOPSIS
      RDMSLOAD processor call statement.
    .DESCRIPTION
      Inserts file data into a table. A report named "RdmsLoad_<$File>" is assumed to be present in the repository.
      The report should know the record layout of the supplied file and imports its records into the database.
    .PARAMETER  FullProcessor
      [String]  The processor name as it occurred in the original source. This may have qualifiers preceding "RDMSLOAD".
    .PARAMETER  RawOptions
      [String]  The processor's raw options (whatever is immediately behind the comma attached to the processor).
    .PARAMETER  Operand
      [String]  The processor call statement's first and assumed only operand.
    .PARAMETER  File
      [String]  The file to be loaded.
    .PARAMETER  FileFormat
      [String]  The format of the file to be loaded ("External", "Internal" or "User").
    .PARAMETER  Sorted
      [Boolean] A value indicating whether the lines in the file are already sorted
                in the primary key order of the tables being loaded or not.
    .PARAMETER  LoadFactor
      [Int32]   The loading factor for B-tree pages, both data and index pages (including
                secondary index pages). Its value can be between 50 and 100 inclusive.
    .PARAMETER  Table
      [String]  The name of the table to insert the file's data into in this format: [qualifier.]table-name[:version-name] .
    .PARAMETER  Index
      [String]  If used, loads B-tree independently. If omitted, a load into the table is assumed.
    .PARAMETER  Partitions
      [String]  The partitions to load. If omitted, load into all partitions that constitute the specified index.
    .PARAMETER  Format
      [String]  Additional format information. See 4.2.5 in "Relational Database Fast Load User Guide".
    .PARAMETER  CommitEvery
      [Int32]   The frequency at which to commit the loaded records.
    .PARAMETER  Resume
      [Boolean] A value indicating whether to resume... something, or not.
  #>

  param (
   [String]$FullProcessor,
   [String]$RawOptions,
   [String]$Operand,
   [String]$File,
   [String]$FileFormat,
   [Boolean]$Sorted,
   [Int32]$LoadFactor,
   [String]$Table,
   [String]$Index,
   [String]$Partitions,
   [String]$Format,
   [Int32]$CommitEvery,
   [Boolean]$Resume
  )

  if (Process-Skip "RdmsLoad $FullProcessor") {
    return
  }

  Check-FinishStatement

  [Object]$ObjTask = $global:AmtReport
  Clear-TaskObject -ObjTask $ObjTask
  Initialize-TaskObject $ObjTask

  $File = $File.Trim('.')
  $ReportName = $File

<#
  # note: This is too slow, the input files are humongous.

  # map file id to physical file
  $ObjTask.AddExtractFile($ReportName, $File)

  $ObjTask.SetTVCustom("FullProcessor", $FullProcessor)
  $ObjTask.SetTVCustom("RawOptions"   , $RawOptions   )
  $ObjTask.SetTVCustom("Operand"      , $Operand      )
  $ObjTask.SetTVCustom("File"         , $File         )
  $ObjTask.SetTVCustom("FileFormat"   , $FileFormat   )
  $ObjTask.SetTVCustom("Sorted"       , $Sorted       )
  $ObjTask.SetTVCustom("LoadFactor"   , $LoadFactor   )
  $ObjTask.SetTVCustom("Table"        , $Table        )
  $ObjTask.SetTVCustom("Index"        , $Index        )
  $ObjTask.SetTVCustom("Partitions"   , $Partitions   )
  $ObjTask.SetTVCustom("Format"       , $Format       )
  $ObjTask.SetTVCustom("CommitEvery"  , $CommitEvery  )
  $ObjTask.SetTVCustom("Resume"       , $Resume       )

  $Report = "RdmsLoad_" + $ReportName
  [Int32]$JobId = $global:Com.JobIdByJobName($Report, $global:Const_JobType_Report)
  if ($JobId -gt -1) {
    CloseJobLogForExternalProgram
    $RequestId = $ObjTask.AddJobRequest($Report, $global:Const_JobType_Report)
    ReopenJobLog

    [String[]]$Lines = GetReportOutput $ObjTask
    DisplayReportOutput $Lines $ReportName
  } else {
    Add-WarningMsg "RdmsLoad failed, report $Report does not exist."
    return
  }
#>

  # target table name
  [String]$TableName = ""

  $File = $File.ToUpperInvariant()

  if ($File.Contains("A5600DATA")) {
    $TableName = "A5600"
  } elseif ($File.Contains("A5610DATA")) {
    $TableName = "A5610"
  } elseif ($File.Contains("A5630DATA")) {
    $TableName = "A5630"
  } elseif ($File.Contains("A5710SB")) {
    $TableName = "MI0514D"  # alias for A5710SB
  } else {
    Abort ($File + " is not an expected file name for RdmsLoad.")
  }

  $File = Check-UseName $File
  SpeedRdmsLoad $File $TableName

} # RdmsLoad


function DumpIpfWorkspace {
  <#
    .SYNOPSIS
      Called for any ECL unknown processor call.
    .DESCRIPTION
      This signals the current statement, telling what kind of data lines to expect.
    .PARAMETER Processor
      The processor's name.
    .PARAMETER RawOptions
      The processor's raw options (whatever is immediately behind the comma attached to the processor).
    .PARAMETER Operands
      The processor call statement's operands.
  #>

  param (
  )

  Write-Host "Key                    LineNumber              Line"
  Write-Host "------------------------------------------------------------------------------------------------------"

  foreach ($Key in $global:IpfWorkspace.Lines.Keys) {
    $LineObject = $global:IpfWorkspace.Lines[$Key]
    Write-Host (("{0,21:N10}  " -f [Decimal]$Key) + ("{0,21:N10}   " -f $LineObject.LineNumber) + $LineObject.Line)
  }

  Write-Host ""
  Write-Host ("TopImage     = " + $global:IpfSv_TopImage    )
  Write-Host ("CurrentImage = " + $global:IpfSv_CurrentImage)
  Write-Host ("BottomImage  = " + $global:IpfSv_BottomImage )
  Write-Host ("LocateString = " + $global:IpfSv_LocateString)
  Write-Host ("ChangeString = " + $global:IpfSv_ChangeString)
  Write-Host ("MatchLine    = " + $global:IpfSv_Matchline   )
  Write-Host ("StartColumn  = " + $global:IpfSv_StartColumn )   # one based
  Write-Host ("EndColumn    = " + $global:IpfSv_EndColumn   )   # one based
  Write-Host ("Results      = " + $global:IpfSv_Results     )
} # DumpIpfWorkspace


function Get-AmtCurrentDate {
  <#
    .SYNOPSIS
      Called to get the current date (that is the one we want to work with, not necessarily the real current date).
    .DESCRIPTION
      This function returns the current date. It first looks into the system database to get
      the date defined in the runtime configuration. If the date is 0 it will use the system 
      date of the server after all.
    .PARAMETER Format
      The format can be MM/dd/yy or MM/dd/yyyy.
  #>

   param (
     [string] $Format
   )

   [DateTime]$CurDate = $global:Com.CurrentDateTime

   switch ($Format) {
     "MM/dd/yy"  {
       return $CurDate.ToString("MM/dd/yy")
       break
     }

     "MM/dd/yyyy"  {
       return $CurDate.ToString("MM/dd/yyyy")
       break
     }

     default {
       abort "Unexpected date format: $Format"
     }
   }
} # Get-AmtCurrentDate


function GetReportOutput {
  <#
    .SYNOPSIS
      Retrieves the result messages from an executed report.
    .DESCRIPTION
      Retrieves the result messages from an executed report.
    .PARAMETER ObjTask
      The job object to obtain the messages from.
    OUTPUT
      The report's result messages.
  #>

  param (
    [Object]$ObjTask
  )

  # Get the messages from the report
  # Try to get them a number of times with pauses in between, messages may be on the way (logging is implemented asynchronously)
  #
  [Int32]$Attempts = 0
  [Int32]$First = -1
  [Boolean]$ReportDone = $False
  do {
    # Give AmtBaseReport a couple of seconds to settle down, the report is run asynchronously 
    # and messages may not have been written to the database yet. This appeared to be an issue
    # in case of recovery runs where messages with a previously used request id are added to 
    # the AmtSysMessage table. If we are too quick we only get the messages for the prior run.
	  # Start-Sleep -s 3
    [String]$ReportOutput = $ObjTask.GetMessagesByRequestId($RequestId)
    [String[]]$Lines = $ReportOutput.Split("`r`n", [System.StringSplitOptions]::RemoveEmptyEntries)

    # there may be messages from multiple runs, => find the first line of the last sequence
    for ([Int32]$i = $Lines.Count - 1; $i -ge 0 ; $i--) {
      if ($Lines[$i].StartsWith("Report execution time:")) {
        $ReportDone = $True
      } elseif ($Lines[$i].StartsWith("Started Rev:")) {
        $First = $i
        break
	  }
    }

	$Attempts++
  } while (((-Not $ReportDone) -or ($First -eq -1)) -and ($Attempts -lt 13))

  if ($First -eq -1) {
    Add-WarningMsg "No messages found for RequestId=$RequestId"
    return @()
  }

  # we do not want the "Started Rev:..." either, -> skip it
  $First += 1

  [Int32]$BodyLinesCount = $Lines.Count - 1

  # if it ends with "Done", do not include that
  if ($Lines[$BodyLinesCount] -eq "Done") {
    $BodyLinesCount--
  }

  # if it ends with "Failed", do not include that
  if ($Lines[$BodyLinesCount] -eq "Failed") {
    $BodyLinesCount--
  }

  # if it ends with "Report execution time:", do not include that
  if ($Lines[$BodyLinesCount].StartsWith("Report execution time:")) {
    $BodyLinesCount--
  }

  [String[]]$Body = @()
  if ($BodyLinesCount -gt 0) {
    $Body = $Lines[$First..$BodyLinesCount]
  }

  return $Body
} # GetReportOutput


function DisplayReportOutput {
  <#
    .SYNOPSIS
      Display the result messages from an executed report.
    .DESCRIPTION
      This function provides some feedback in case a report did not finish successfully.
    .PARAMETER Lines
      The lines to be displayed.
    .PARAMETER Report
      The report's name.
  #>

  param (
    [String[]]$Lines=$null,
    [String]$Report=""
  )

  if ($Lines -eq $null) {
    return
  }

  Write-Host -ForegroundColor Cyan "Report Output"
  Write-Host -ForegroundColor Cyan "-------------"
  foreach ($Line in $Lines) {
    Write-JobLog ($Report + ": " + $Line) ([LoggingSeverity]::Debug)
  }

  Write-Host -ForegroundColor Cyan "-------------"	
} # DisplayReportOutput

function Initialize-TaskObject {
  <#
    .SYNOPSIS
      Initializes the bare necessities of a task object before adding a job request.
    .DESCRIPTION
      This function sets task object properties according to the current script state.
    .PARAMETER TaskObject
      The task object to be initialized.
  #>

  param (
    [Parameter(Mandatory=$true)][Object]$TaskObject
  )

  $TaskObject.SetDefaultDontPrint($global:DefaultDontPrint)
  $TaskObject.SetDefaultAppendToPrintFile($true)

  $TaskObject.Wait                    = $true
  $TaskObject.Station                 = $global:Initiator
  $TaskObject.User                    = $global:User
  $TaskObject.StartDate               = Get-TimeDate "YYYYMMDD" (Get-Date)
  $TaskObject.StartTime               = Get-TimeDate "HHMM" (Get-Date)
  $TaskObject.Debug                   = $global:Debug
  $TaskObject.BatchId                 = $global:BatchId
  $TaskObject.RunAs                   = $global:WindowsUser
  $TaskObject.MaximumNumberOfRestarts = 0  # tell Batch Controller not to retry, we will handle retries outselves
  $TaskObject.RecoverCriticalReport   = $false

  $TaskObject.SetTVCustom("JOBNAME", $global:Jobname)
  $TaskObject.SetTVCustom("JOBNUMBER", $global:JobNumber)
} # Initialize-TaskObject


function GetRecoveryPointCount {
  <#
    .SYNOPSIS
      Retrieves the number of recovery points for the given job.
    .DESCRIPTION
      A recovery point will be stored for a job each time it crashes. This function 
      returns the number of available recovery points for the specified job. If 
      $RecoverId is also specified, it returns either 0 or 1, depending on the 
      existence of the specified recovery point.
    .PARAMETER AppId
      The application id.
    .PARAMETER JobName
      The name of the report for which to return the number of recovery points.
    .PARAMETER RecoverId
      The specific process job id (identifying the recovery point) to look for.
    OUTPUT
      The number of available recovery points for the given arguments.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$AppId,
    [Parameter(Mandatory=$true)][String]$JobName,
                                 [Int32]$FindRecoverId=-1
  )

  # Get the number of recovery points for the given parameters.
  #
  # This information is available in table AMTSYSPROCESSJOB, this links to table AMTSYSCRITICALREPORT:
  # AmtSysProcessJob.ProcessJobId -> AmtSysCriticalReport.Id
  # AmtSysProcessJob.AppId        -> AmtSysCriticalReport.AppId

  [Int32[]]	$ProcessJobIds = $global:Com.GetRecoverableProcessJobs($AppId, $JobName)

  if ($FindRecoverId -gt -1) {
    if ($ProcessJobIds.Contains($FindRecoverId)) {
      return 1
	} else {
      return 0
	}
  } else {
    # no recover id was specified but if we found exacly one, this will be the one to use
    if ($ProcessJobIds.Count -eq 1) {
      $global:RecoverId = $ProcessJobIds[0]
    }
  }

  return $ProcessJobIds.Count;
} # GetRecoveryPointCount


function SpeedRdmsLoad {
  <#
    .SYNOPSIS
      RDMSLOAD processor call statement.
    .DESCRIPTION
      Inserts file data into a table. We expect any of four different file names,
      each maps to a specific table.
    .PARAMETER  File
      [String]  The file to be loaded.
    .PARAMETER  TableName
      [String]  The name of the table to load the data into.
  #>

  param (
   [String]$File,
   [String]$TableName
  )


  # get the bulk copy object that is connected to the current application database
  [Asysco.Amt.Libs.Database.IAmtBulkCopy]$BulkCopy = $global:AmtDatabase.GetBulkCopy()

  # for testing/debugging: use a custom connection to your favorite database
  #$CS="Persist Security Info=true;Trusted_Connection=False;User Id=asy;Password=asy;Database=STA-PROD-L3;MultipleActiveResultSets=true;Server=VM-STA\MSSQL2012;Application Name=powershell_ise;Pooling=True;TrustServerCertificate=False;Encrypt=False;Connect Timeout=60"
  #[System.Data.SqlClient.SqlBulkCopy]$BulkCopy = new-Object System.Data.SqlClient.SqlBulkCopy $CS

  try {
    $BulkCopy.DestinationTableName = $TableName
    $BulkCopy.BulkCopyTimeout = 0

    # note: Do not set $BulkCopy.BatchSize, it is likely to decrease performance.
    #       http://stackoverflow.com/questions/28275779/bulkcopy-batch-size-affecting-the-insert

    # the number of records to stuff a DataTable object with before sending it to the database
    $BatchSize = 100000

    # the number of records to read from the text steam in a single Read statement
    $BiteSize = 500

    # start time
    $Start = [DateTime]::Now

    [Asysco.Amt.Scripting.IFileTextStream]$TextStream = $global:AmtFile.OpenTextFile($File, $global:Const_ExclusiveBatch, 0, $true)

    if (-not $TextStream) {
      Abort "SpeedRdmsLoad: Could not open text stream on file $File."
    }

    try {

      $Start = [DateTime]::Now
      [Int64]$RecordCounter = 0

      # create table object that matches the table to be filled
      $DataTable = new-object System.Data.DataTable

      # The order of column definitions must match the order of the fields in the database table,
      # => we will get current column definitions from the database and create data table object
      # columns from them.
      [System.Data.DataTable]$ColumnDefinitions = new-object System.Data.DataTable
      $global:AmtDatabase.GetColumnDefinitions($ColumnDefinitions, $TableName)

      foreach ($Row in $ColumnDefinitions.Rows) {
        [String]$ColumnName = $Row["COLUMN_NAME"]
        [String]$DataType = $Row["DATA_TYPE"]
        [System.Type]$Type = [String]

        if ($DataType.Contains("int")) {
          $Type = [Int32]
        }

        if ($ColumnName -ne "LIONRECNO") {
          $DataTable.Columns.Add($ColumnName, $Type) | Out-Null
        }
      }

      switch ($TableName) {

        "A5600" {

          while (-not ($TextStream.EndOfFile)) {

            # Have ComScript fill up the data table object (this is about 4 times as fast compared
            # to doing it here in script). Fill an array with Substring arguments in the order
            # field values are to be moved from an input line to a data table object row.
            [Int32[][]]$SubstringArguments = @(0) * 14

            foreach ($Column in $DataTable.Columns) {
              switch ($Column.ColumnName) {                      #  start  length
                "F_IREGNR"  { $SubstringArguments[$Column.Ordinal] = (  0,  6) }  # alpha
                "A_DTRANS"  { $SubstringArguments[$Column.Ordinal] = (  6,  9) }  # numeric  (including leading sign character)
                "A_GTID"    { $SubstringArguments[$Column.Ordinal] = ( 15,  7) }  # numeric  (including leading sign character)
                "A_IARENDE" { $SubstringArguments[$Column.Ordinal] = ( 22, 15) }  # alpha
                "A_IFLOPNR" { $SubstringArguments[$Column.Ordinal] = ( 37,  4) }  # numeric  (including leading sign character)
                "A_GDOKID"  { $SubstringArguments[$Column.Ordinal] = ( 41, 14) }  # alpha
                "A_GLDATA"  { $SubstringArguments[$Column.Ordinal] = ( 55, 70) }  # alpha
                "A_IANV"    { $SubstringArguments[$Column.Ordinal] = (125, 10) }  # alpha
                "A_KARTYP"  { $SubstringArguments[$Column.Ordinal] = (135,  6) }  # alpha
                "A_KEXT"    { $SubstringArguments[$Column.Ordinal] = (141, 10) }  # alpha
                "A_KFUNK"   { $SubstringArguments[$Column.Ordinal] = (151,  8) }  # alpha
                "A_KORG"    { $SubstringArguments[$Column.Ordinal] = (159, 10) }  # alpha
                "A_KURSPR"  { $SubstringArguments[$Column.Ordinal] = (169,  8) }  # alpha
                "GLB_DTIME" { $SubstringArguments[$Column.Ordinal] = (177,  8) }  # alpha
                "MAINT"     { $SubstringArguments[$Column.Ordinal] = (185,  1) }  # alpha
              }
            }

            # read $BatchSize records (or whatever is left if we are near the end)
            $ChunkCreationStart = [DateTime]::Now
            [Int64]$ChunkRecordCounter = $global:AmtDatabase.FillDataTable($DataTable, $TextStream, 186, $BatchSize, $BiteSize, $SubstringArguments)
            $RecordCounter += $ChunkRecordCounter

            $ChunkCreationFinish = [DateTime]::Now
            Write-Host ("Creation of DataTable object with $ChunkRecordCounter records: " + ($ChunkCreationFinish - $ChunkCreationStart))

            $WriteToServerStart = [DateTime]::Now
            $BulkCopy.WriteToServer($DataTable) | Out-Null
            $WriteToServerFinish = [DateTime]::Now
            Write-Host ("Writing $ChunkRecordCounter records to server: $($WriteToServerFinish - $WriteToServerStart)")
            Write-Host ("The total number of records added to table $TableName is $RecordCounter.")

            $DataTable.Rows.Clear()
          }

          break
        }

        "A5610" {

          while (-not ($TextStream.EndOfFile)) {

            # Have ComScript fill up the data table object (this is about 4 times as fast compared
            # to doing it here in script). Fill an array with Substring arguments in the order
            # field values are to be moved from an input line to a data table object row.
            [Int32[][]]$SubstringArguments = @(0) * 14

            foreach ($Column in $DataTable.Columns) {
              switch ($Column.ColumnName) {                      #  start  length
                "P_GPNR"    { $SubstringArguments[$Column.Ordinal] = (  0, 11) }  # numeric  (including leading sign character)
                "A_DTRANS"  { $SubstringArguments[$Column.Ordinal] = ( 11,  9) }  # numeric  (including leading sign character)
                "A_GTID"    { $SubstringArguments[$Column.Ordinal] = ( 20,  7) }  # numeric  (including leading sign character)
                "A_IARENDE" { $SubstringArguments[$Column.Ordinal] = ( 27, 15) }  # alpha
                "A_IFLOPNR" { $SubstringArguments[$Column.Ordinal] = ( 42,  4) }  # numeric  (including leading sign character)
                "A_GDOKID"  { $SubstringArguments[$Column.Ordinal] = ( 46, 14) }  # alpha
                "A_GLDATA"  { $SubstringArguments[$Column.Ordinal] = ( 60, 70) }  # alpha
                "A_IANV"    { $SubstringArguments[$Column.Ordinal] = (130, 10) }  # alpha
                "A_KARTYP"  { $SubstringArguments[$Column.Ordinal] = (140,  6) }  # alpha
                "A_KEXT"    { $SubstringArguments[$Column.Ordinal] = (146, 10) }  # alpha
                "A_KFUNK"   { $SubstringArguments[$Column.Ordinal] = (156,  8) }  # alpha
                "A_KORG"    { $SubstringArguments[$Column.Ordinal] = (164, 10) }  # alpha
                "A_KURSPR"  { $SubstringArguments[$Column.Ordinal] = (174,  8) }  # alpha
                "GLB_DTIME" { $SubstringArguments[$Column.Ordinal] = (182,  8) }  # alpha
                "MAINT"     { $SubstringArguments[$Column.Ordinal] = (190,  1) }  # alpha
              }
            }

            # read $BatchSize records (or whatever is left if we are near the end)
            $ChunkCreationStart = [DateTime]::Now
            [Int64]$ChunkRecordCounter = $global:AmtDatabase.FillDataTable($DataTable, $TextStream, 191, $BatchSize, $BiteSize, $SubstringArguments)
            $RecordCounter += $ChunkRecordCounter

            $ChunkCreationFinish = [DateTime]::Now
            Write-Host ("Creation of DataTable object with $ChunkRecordCounter records: " + ($ChunkCreationFinish - $ChunkCreationStart))

            $WriteToServerStart = [DateTime]::Now
            $BulkCopy.WriteToServer($DataTable) | Out-Null
            $WriteToServerFinish = [DateTime]::Now
            Write-Host ("Writing $ChunkRecordCounter records to server: $($WriteToServerFinish - $WriteToServerStart)")
            Write-Host ("The total number of records added to table $TableName is $RecordCounter.")

            $DataTable.Rows.Clear()
          }

          break
        }

        "A5630" {

          while (-not ($TextStream.EndOfFile)) {

            # Have ComScript fill up the data table object (this is about 4 times as fast compared
            # to doing it here in script). Fill an array with Substring arguments in the order
            # field values are to be moved from an input line to a data table object row.
            [Int32[][]]$SubstringArguments = @(0) * 14

            foreach ($Column in $DataTable.Columns) {
              switch ($Column.ColumnName) {                      #  start  length
                "A_GNYCKEL" { $SubstringArguments[$Column.Ordinal] = (  0, 60) }  # alpha
                "A_DTRANS"  { $SubstringArguments[$Column.Ordinal] = ( 60,  9) }  # numeric  (including leading sign character)
                "A_GTID"    { $SubstringArguments[$Column.Ordinal] = ( 69,  7) }  # numeric  (including leading sign character)
                "A_IARENDE" { $SubstringArguments[$Column.Ordinal] = ( 76, 15) }  # alpha
                "A_IFLOPNR" { $SubstringArguments[$Column.Ordinal] = ( 91,  4) }  # numeric  (including leading sign character)
                "A_GDOKID"  { $SubstringArguments[$Column.Ordinal] = ( 95, 14) }  # alpha
                "A_GLDATA"  { $SubstringArguments[$Column.Ordinal] = (109, 70) }  # alpha
                "A_IANV"    { $SubstringArguments[$Column.Ordinal] = (179, 10) }  # alpha
                "A_KARTYP"  { $SubstringArguments[$Column.Ordinal] = (189,  6) }  # alpha
                "A_KEXT"    { $SubstringArguments[$Column.Ordinal] = (195, 10) }  # alpha
                "A_KFUNK"   { $SubstringArguments[$Column.Ordinal] = (205,  8) }  # alpha
                "A_KORG"    { $SubstringArguments[$Column.Ordinal] = (213, 10) }  # alpha
                "A_KURSPR"  { $SubstringArguments[$Column.Ordinal] = (223,  8) }  # alpha
                "GLB_DTIME" { $SubstringArguments[$Column.Ordinal] = (231,  8) }  # alpha
                "MAINT"     { $SubstringArguments[$Column.Ordinal] = (239,  1) }  # alpha
              }
            }

            # read $BatchSize records (or whatever is left if we are near the end)
            $ChunkCreationStart = [DateTime]::Now
            [Int64]$ChunkRecordCounter = $global:AmtDatabase.FillDataTable($DataTable, $TextStream, 240, $BatchSize, $BiteSize, $SubstringArguments)
            $RecordCounter += $ChunkRecordCounter

            $ChunkCreationFinish = [DateTime]::Now
            Write-Host ("Creation of DataTable object with $ChunkRecordCounter records: " + ($ChunkCreationFinish - $ChunkCreationStart))

            $WriteToServerStart = [DateTime]::Now
            $BulkCopy.WriteToServer($DataTable) | Out-Null
            $WriteToServerFinish = [DateTime]::Now
            Write-Host ("Writing $ChunkRecordCounter records to server: $($WriteToServerFinish - $WriteToServerStart)")
            Write-Host ("The total number of records added to table $TableName is $RecordCounter.")

            $DataTable.Rows.Clear()
          }

          break
        }

        "A5710" {

          while (-not ($TextStream.EndOfFile)) {

            # Have ComScript fill up the data table object (this is about 4 times as fast compared
            # to doing it here in script). Fill an array with Substring arguments in the order
            # field values are to be moved from an input line to a data table object row.
            [Int32[][]]$SubstringArguments = @(0) * 14

            foreach ($Column in $DataTable.Columns) {
              switch ($Column.ColumnName) {                      #  start  length
                "P_GPNR"    { $SubstringArguments[$Column.Ordinal] = (  0, 11) }  # numeric  (including leading sign character)
                "A_DTRANS"  { $SubstringArguments[$Column.Ordinal] = ( 11,  9) }  # numeric  (including leading sign character)
                "A_GTID"    { $SubstringArguments[$Column.Ordinal] = ( 20,  7) }  # numeric  (including leading sign character)
                "A_IARENDE" { $SubstringArguments[$Column.Ordinal] = ( 27, 15) }  # alpha
                "A_IFLOPNR" { $SubstringArguments[$Column.Ordinal] = ( 42,  4) }  # numeric  (including leading sign character)
                "A_GDOKID"  { $SubstringArguments[$Column.Ordinal] = ( 46, 14) }  # alpha
                "A_GLDATA"  { $SubstringArguments[$Column.Ordinal] = ( 60, 70) }  # alpha
                "A_IANV"    { $SubstringArguments[$Column.Ordinal] = (130, 10) }  # alpha
                "A_KARTYP"  { $SubstringArguments[$Column.Ordinal] = (140,  6) }  # alpha
                "A_KEXT"    { $SubstringArguments[$Column.Ordinal] = (146, 10) }  # alpha
                "A_KFUNK"   { $SubstringArguments[$Column.Ordinal] = (156,  8) }  # alpha
                "A_KORG"    { $SubstringArguments[$Column.Ordinal] = (164, 10) }  # alpha
                "A_KURSPR"  { $SubstringArguments[$Column.Ordinal] = (174,  8) }  # alpha
                "GLB_DTIME" { $SubstringArguments[$Column.Ordinal] = (182,  8) }  # alpha
                "MAINT"     { $SubstringArguments[$Column.Ordinal] = (190,  1) }  # alpha
              }
            }

            # read $BatchSize records (or whatever is left if we are near the end)
            $ChunkCreationStart = [DateTime]::Now
            [Int64]$ChunkRecordCounter = $global:AmtDatabase.FillDataTable($DataTable, $TextStream, 193, $BatchSize, $BiteSize, $SubstringArguments)
            $RecordCounter += $ChunkRecordCounter

            $ChunkCreationFinish = [DateTime]::Now
            Write-Host ("Creation of DataTable object with $ChunkRecordCounter records: " + ($ChunkCreationFinish - $ChunkCreationStart))

            $WriteToServerStart = [DateTime]::Now
            $BulkCopy.WriteToServer($DataTable) | Out-Null
            $WriteToServerFinish = [DateTime]::Now
            Write-Host ("Writing $ChunkRecordCounter records to server: $($WriteToServerFinish - $WriteToServerStart)")
            Write-Host ("The total number of records added to table $TableName is $RecordCounter.")

            $DataTable.Rows.Clear()
          }

          break
        }
      }

      $Finish = [DateTime]::Now
      Write-Host ""
      Write-Host ("RdmsLoad time: " + ($Finish - $Start))
    } finally {
      $TextStream.Close() | Out-Null
    }
  } finally {
    $BulkCopy.Close()
  }
} # SpeedRdmsLoad


function CompareTypeSafe {
  <#
    .SYNOPSIS
      Compares two values using a comparison operator and report if the expression yields true or not.
    .DESCRIPTION
      This is needed because at conversion time it is impossible to determine the nature of the operands, 
	  they may either be numeric or not. If both are numeric we want to use numeric logic (3 is smaller than 12).
	  If at least one of them is non-numeric we want to do a text compare.
    .PARAMETER $Left
      The left operand.
    .PARAMETER $Operator
      The operator being the PsAstOperatorType as a string.
    .PARAMETER $Right
      The right operand.
	.OUTPUT
	  The resulting boolean value of the comparison.
  #>

  param (
    [String]$Left,
    [Parameter(Mandatory=$true)][String]$Operator,
    [String]$Right
  )

  [Double]$dummy=0
  [Boolean]$LeftIsNumeric = [Double]::TryParse($Left,[ref]$dummy)
  [Boolean]$RightIsNumeric = [Double]::TryParse($Right,[ref]$dummy)

  # note: the type of the left operand will determine the comparison type
  if ($LeftIsNumeric -and $RightIsNumeric) {
     Switch ($Operator) {
      "LessThan"           { return ([Double]$Left -lt $Right)  }
      "LessThanOrEqual"    { return ([Double]$Left -le $Right)  }
      "EqualTo"            { return ([Double]$Left -eq $Right)  }
      "NotEqualTo"         { return ([Double]$Left -ne $Right)  }
      "GreaterThanOrEqual" { return ([Double]$Left -ge $Right)  }
      "GreaterThan"        { return ([Double]$Left -gt $Right)  }
      default { Abort ("$Operator is not a valid comparison operator.") }
    }
  } else {
     Switch ($Operator) {
      "LessThan"           { return ([String]$Left -lt $Right)  }
      "LessThanOrEqual"    { return ([String]$Left -le $Right)  }
      "EqualTo"            { return ([String]$Left -eq $Right)  }
      "NotEqualTo"         { return ([String]$Left -ne $Right)  }
      "GreaterThanOrEqual" { return ([String]$Left -ge $Right)  }
      "GreaterThan"        { return ([String]$Left -gt $Right)  }
      default { Abort ("$Operator is not a valid comparison operator.") }
    }
  }
}  # CompareTypeSafe


function JobStateName {
  <#
    .SYNOPSIS
      Outputs the friendly job state name matching the provided code.
    .DESCRIPTION
      The code is the integer value of ComScript's AmtJobState, the returned name is the enum's name.
    .PARAMETER $JobState
      The value to be translated.
	.OUTPUT
	  The friendly job state name matching the provided code.
  #>

  param (
    [Int32]$JobState
  )

  Switch ($JobState) {

    $global:Const_JobState_Idle                { return "Idle"                }  #  0
    $global:Const_JobState_Queued              { return "Queued"              }	 #  1
    $global:Const_JobState_Running             { return "Running"             }	 #  2
    $global:Const_JobState_Killed              { return "Killed"              }	 #  3
    $global:Const_JobState_Done                { return "Done"                }	 #  4
    $global:Const_JobState_Suspended           { return "Suspended"           }	 #  5
    $global:Const_JobState_Skipped_By_Op       { return "Skipped_By_Op"       }	 #  6
    $global:Const_JobState_Run_Manual          { return "Run_Manual"          }	 #  7
    $global:Const_JobState_Run_Forced          { return "Run_Forced"          }	 #  8
    $global:Const_JobState_Run_Debug           { return "Run_Debug"           }	 #  9
    $global:Const_JobState_Del_Queue           { return "Del_Queue"           }	 # 10
    $global:Const_JobState_Error               { return "Error"               }	 # 11
    $global:Const_JobState_Aborted             { return "Aborted"             }	 # 12
    $global:Const_JobState_WaitForFile         { return "WaitForFile"         }	 # 13
    $global:Const_JobState_WaitForInputRequest { return "WaitForInputRequest" }	 # 14
    $global:Const_JobState_WaitForJob          { return "WaitForJob"          }	 # 15
    $global:Const_JobState_WaitForReport       { return "WaitForReport"       }	 # 16
    $global:Const_JobState_Reserved1           { return "Reserved1"           }	 # 17
    $global:Const_JobState_RecoverCP           { return "RecoverCP"           }	 # 18
    $global:Const_JobState_Undefined           { return "Undefined"           }	 # 19
    $global:Const_JobState_WaitForQueue        { return "WaitForQueue"        }	 # 20
    $global:Const_JobState_WaitForDebugger     { return "WaitForDebugger"     }	 # 21
    $global:Const_JobState_AbortedWithRecover  { return "AbortedWithRecover"  }	 # 22
    $global:Const_JobState_KilledWithRecover   { return "KilledWithRecover"   }	 # 27

    default { return "?" }  # not a known job state
  }

} # JobStateName


function CloseJobLogForExternalProgram() {
  <#
    .SYNOPSIS
      Close the job log to make it available to an external program.
    .DESCRIPTION
      When the script starts an external program it should close the 
      job log so the external program can open it and write to it.
  #>

  #if ($global:UseJobLog) {
  #  Write-JobLog "Closing job log..." $true
  #  Close-JobLog
  #}
}

function ReopenJobLog() {
  <#
    .SYNOPSIS
      Re-open the job log after it was closed to make it available to an external job.
    .DESCRIPTION
      The external job (typically a report) may have written to the job log which is 
      now re-opened to allow the script to wrote to it again.
  #>

  #if ($global:UseJobLog) {
  #  $global:JobLogObj = Open-TextFile $global:JobLogFile $global:Const_ExclusiveBatch $global:Const_FileEnc_Autodetect $true
  #  if ($global:ErrorCode -ne 0) {
  #    Write-Host "Error opening joblog: $($global:ErrorDescription)" 
  #  } else {
  #    Write-JobLog "Job log re-opened." $true
  #  }
  # }
}


function Process-FreedInProgram() {
  <#
    .SYNOPSIS
      Process the files that were freed in the program.
    .PARAMETER ObjTask
      [Object] Task object
  #>

  param (
    [Parameter(Mandatory=$true)][Object]$ObjTask
  )
  
  [Int32]$NrOfFreedFiles = $ObjTask.GetTVCustom("NROFFREEDFILES")
  for ([Int32]$I = 1; $I -le $NrOfFreedFiles; $I++) {
    [String]$Fileinfo = $ObjTask.GetTVCustom("FREEDFILE_$I")

    [String[]]$InfoArr = $FileInfo.Split(",")
    [String]$InternalFilename = $InfoArr[0]
    [String]$Filename = $InfoArr[1]
    [String]$ExternalFilename = $InfoArr[2]
    [String]$AsgFilename = $InfoArr[3]
    for ([Int32]$J = 0; $J -lt $global:FilesList.Count; $J++) {
      if (($global:FilesList[$J].Filename -eq $AsgFilename)) {
        # this file was freed, remove it from the assigned files list
        $global:FileObject = $global:FilesList[$J]
        $global:FilesList.RemoveAt($J);
        for ([Int32]$K = 0; $K -lt $global:UseNamesList.Count; $K++) {
          if ($global:UseNamesList[$K].FileObject -eq $global:FileObject) {
            $global:UseNamesList.RemoveAt($K)
          }
        }
        break;
      }
    }

    <# Not needed anymore, AsgFilename should match
    for ([Int32]$J = 0; $J -lt $global:FilesList.Count; $J++) {
      if ((($global:FilesList[$J].Copyname -eq $Filename) -or
          (($global:FilesList[$J].FileHandle -ne $null) -and ($global:FilesList[$J].FileHandle.FullName -eq $Filename)))) {
        # this file was freed, remove it from the assigned files list
        $global:FilesList.RemoveAt($J);
        break;
      }
    }
    #>
  }
} # Process-FreedInProgram


function Process-AssignedInProgram() {
  <#
    .SYNOPSIS
      Process the files that were assigned in the program.
    .PARAMETER ObjTask
      [Object] Task object
  #>

  param (
    [Parameter(Mandatory=$true)][Object]$ObjTask
  )

  [Int32]$NrOfAssignedFiles = $ObjTask.GetTVCustom("NROFASSIGNEDFILES")
  for ([Int32]$I = 1; $I -le $NrOfAssignedFiles; $I++) {
    [String]$Fileinfo = $ObjTask.GetTVCustom("ASSIGNEDFILE_$I")

    [Boolean]$FileInList = $false
    [String[]]$InfoArr = $FileInfo.Split("|")
    [String]$ExternalFilename = $InfoArr[0]
    [String]$Filename = $InfoArr[1]
    [String]$Options = $InfoArr[2]
    [String]$AsgFilename = $InfoArr[3]

    for ([Int32]$J = 0; $J -lt $global:FilesList.Count; $J++) {
      if ($global:FilesList[$J].WindowsFilename -eq $ExternalFilename) {
        # file was already assigned in this job -> Do nothing
        $FileInList = $true
        $global:FileObject = $global:FilesList[$J]
        break
      }
    }
    if (-not $FileInList) {
      for ([Int32]$J = 0; $J -lt $global:FilesList.Count; $J++) {
        if ($global:FilesList[$J].Filename -eq $AsgFilename) {
          # file was already assigned in this job -> Do nothing
          $FileInList = $true
          $global:FileObject = $global:FilesList[$J]
          break
        }
      }
    }
  
    if (-not $FileInList) {
      # If option A was used when assigning the file, IsCataloged must be set to true.
      [Boolean]$IsCataloged = $false
      if ($Options.Length -gt 0) {
        [String[]]$OptionsArr = $Options.Split(",")
        if ($OptionsArr.Contains("A")) {
          $IsCataloged = $true
        }
      }

      [String]$Cycle = Find-Cycle $ExternalFilename
      if ($Cycle -ne '') {
        # file is a cycle file.
        $global:FileHandle = Fco-AssignFile $Filename $global:Const_ExclusiveBatch $true
        #[String]$Cyclename = $ExternalFilename
        #$ExternalFilename = Strip-Cycle $ExternalFilename ([Ref]$Cyclename)
        [String]$ShortName = Filename-ToShortName $ExternalFilename
        #[String]$BasePath = Get-PathName ([Ref]$ShortName)
        [String]$Copyname = $Filename
        if ($Copyname -eq $ExternalFilename) {
          $Copyname = ""
        }
        $global:FileObject = New-Object PSObject
        $global:FileObject | Add-Member -Name Filename        -Value $AsgFilename       -MemberType NoteProperty
        #$global:FileObject | Add-Member -Name Cyclename      -Value $Cyclename         -MemberType NoteProperty
        $global:FileObject | Add-Member -Name FileHandle      -Value $global:FileHandle -MemberType NoteProperty
        $global:FileObject | Add-Member -Name DeleteOnFree    -Value $false             -MemberType NoteProperty
        $global:FileObject | Add-Member -Name Copyname        -Value $Copyname          -MemberType NoteProperty
        $global:FileObject | Add-Member -Name DeleteOnError   -Value $false             -MemberType NoteProperty
        $global:FileObject | Add-Member -Name ChangeReadOnly  -Value 0                  -MemberType NoteProperty
        $global:FileObject | Add-Member -Name IsAssigned      -Value $true              -MemberType NoteProperty
        $global:FileObject | Add-Member -Name IsCataloged     -Value $IsCataloged       -MemberType NoteProperty
        $global:FileObject | Add-Member -Name CHG_N_name      -Value ""                 -MemberType NoteProperty
        $global:FileObject | Add-Member -Name IsASG_I         -Value $false             -MemberType NoteProperty
        $global:FileObject | Add-Member -Name ShortName       -Value $ShortName         -MemberType NoteProperty
        $global:FileObject | Add-Member -Name WindowsFilename -Value $ExternalFilename  -MemberType NoteProperty
        $global:FileObject | Add-Member -Name AsgOptions      -Value $Options           -MemberType NoteProperty
        $global:FilesList.Add($global:FileObject)
      } else {
        $global:FileHandle = Fco-AssignFile $Filename $global:Const_ExclusiveBatch $true
        [String]$ShortName = Filename-ToShortName $ExternalFilename
        #[String]$BasePath = Get-PathName ([Ref]$ShortName)
        [String]$Copyname = $Filename
        if ($Copyname -eq $ExternalFilename) {
          $Copyname = ""
        }
        $global:FileObject = New-Object PSObject
        $global:FileObject | Add-Member -Name Filename        -Value $AsgFilename       -MemberType NoteProperty
        #$global:FileObject | Add-Member -Name Cyclename      -Value ""                 -MemberType NoteProperty
        $global:FileObject | Add-Member -Name FileHandle      -Value $global:FileHandle -MemberType NoteProperty
        $global:FileObject | Add-Member -Name DeleteOnFree    -Value $false             -MemberType NoteProperty
        $global:FileObject | Add-Member -Name Copyname        -Value $Copyname          -MemberType NoteProperty
        $global:FileObject | Add-Member -Name DeleteOnError   -Value $false             -MemberType NoteProperty
        $global:FileObject | Add-Member -Name ChangeReadOnly  -Value 0                  -MemberType NoteProperty
        $global:FileObject | Add-Member -Name IsAssigned      -Value $true              -MemberType NoteProperty
        $global:FileObject | Add-Member -Name IsCataloged     -Value $IsCataloged       -MemberType NoteProperty
        $global:FileObject | Add-Member -Name CHG_N_name      -Value ""                 -MemberType NoteProperty
        $global:FileObject | Add-Member -Name IsASG_I         -Value $false             -MemberType NoteProperty
        $global:FileObject | Add-Member -Name ShortName       -Value $ShortName         -MemberType NoteProperty
        $global:FileObject | Add-Member -Name WindowsFilename -Value $ExternalFilename  -MemberType NoteProperty
        $global:FileObject | Add-Member -Name AsgOptions      -Value $Options           -MemberType NoteProperty
        $global:FilesList.Add($global:FileObject)
      }
    }
    #Check if file was Used in program
    [Int32]$NrOfUsedFiles = $ObjTask.GetTVCustom("NROFUSEDFILES_$I")
    for ([Int32]$J = 1; $J -le $NrOfUsedFiles; $J++) {
      [String]$UseName = $ObjTask.GetTVCustom("USEDFILE_$I" + "_$J")
      [Boolean]$UseInList = $false
      if ($UseName -eq "") {
        break
      }
      for ([Int32]$K = 0; $K -lt $global:UseNamesList.Count; $K++) {
        if ($global:UseNamesList[$K].Usename -eq $UseName) {
          $UseInList = $true
        }
      }
      if (-not $UseInList) {
        $global:UseNameObject = New-Object PSObject
        $global:UseNameObject | Add-Member -Name Usename         -Value $UseName            -MemberType NoteProperty   # The usename of the file/usename
        $global:UseNameObject | Add-Member -Name Filename        -Value $Filename           -MemberType NoteProperty   # The file/usename
        $global:UseNameObject | Add-Member -Name FileObject      -Value $global:FileObject  -MemberType NoteProperty   # The file object
        $global:UseNameObject | Add-Member -Name IsSentToProgram -Value $false              -MemberType NoteProperty   # Is this USE info sent to program
        $global:UseNamesList.Add($global:UseNameObject)
      }
    }
  }
} #  Process-AssignedInProgram


function Asy-StartJob {
  <#
    .SYNOPSIS
      Add a job request to start a job.
    .DESCRIPTION
      This function calls AddJobRequest which places a job request in the 
      AMTSYSJOBREQUEST table. This request will then be handled by the batchcontroller.
      This function does not wait for the job to end.
    .PARAMETER JobName
      [String] Name of the Job
    .PARAMETER StartTime
      [String] Start time, "HHMM", "HH:MM" or time interval "+HH:MM". If empty, the
      current time is used.
    .PARAMETER StartDate
      [String] Start date, "MM/DD/YY", "MM/DD/YYYY", "YYDDD", "YYYYDDD" or "YYYYMMDD" 
      or date interval "+DD". If empty current date is used.
    .PARAMETER Wait
      [Boolean] If true wait until the job has finished.
    .PARAMETER Params
      [String] The parameters for the script, in an array
  #>
  
  param (
    [Parameter(Mandatory=$true)][String]$JobToRun,
    [String]$StartTime,
    [String]$StartDate,
    [Boolean]$Wait = $false,
    [Object[]]$Params = @() # Array containing parameter objects (could be of any type)
  )

  [Boolean]$UseStartDateTime = $false
  [String]$Statement = ""
  [String]$ParString = ""

  if (($StartTime -eq "") -and ($StartDate -eq "")) {
    $UseStartDateTime = $false
    $Statement = "Asy-StartJob: $JobToRun"
  } else {
    $UseStartDateTime = $true
    $Statement = "Asy-StartJob: Scheduled $JobToRun for $StartDate at $StartTime"
  }

  if (Process-Skip $Statement) {
    return
  }

  Check-FinishStatement

  Write-JobLog $Statement ([LoggingSeverity]::Info)
  $JobToRun = $JobToRun.ToUpperInvariant()

  if ($JobToRun.EndsWith(".ps1", [StringComparison]::OrdinalIgnoreCase)) {
    # If present, remove .ps1 extension
    $JobToRun = $JobToRun.Substring(0, $JobToRun.Length - 4)
  }
  if ($JobToRun.EndsWith(".exe", [StringComparison]::OrdinalIgnoreCase)) {
    # If present, remove .exe extension
    $JobToRun = $JobToRun.Substring(0, $JobToRun.Length - 4)
  }

  if (-not(Check-Date ([ref]$StartDate))) {
    Abort "Asy-StartJob: ERROR: Date: $StartDate is invalid." 
  }

  if (-not(Check-Time ([ref]$StartTime) ([ref]$StartDate))) {
    Abort "Asy-StartJob: ERROR: Time: $StartTime is invalid."
  }

  # Create a String of the parameter array
  if (($Params -ne $null) -and ($Params.Count -gt 0)) {
    foreach ($Par in $Params) {
      # Replace single quotes with double quotes
      $Par = $Par.Replace("'", "`"")
      if ($Par -is [Boolean]) {
        # Keep dollar sign in front of Boolean parameters
        $ParString += "`$$par "
      } elseif ($Par -is [String]) {
        # Surround String parameters with single quotes
        $ParString += "'$Par' "
      } else {
        $ParString += "$Par "
      }
    }
  }

  [String]$Jobname = [System.IO.Path]::GetFileName($JobToRun)  # Don't remove extension for jobs like AGTDTL.XQT
  [Int32]$JobId = $global:Com.JobIdbyJobName($JobName, $global:Const_JobType_Script)
  if ($JobId -eq -1) {
	# it is not a script, it could be a report
    $JobId = $global:Com.JobIdbyJobName($JobName, $global:Const_JobType_CobolProgram)
	if ($JobId -eq -1) {
	  $JobId = $global:Com.JobIdbyJobName($JobName, $global:Const_JobType_Report)
	}
    if ($JobId -eq -1) {
      # it is not a report either, it should be an executable
      $JobId = $global:Com.JobIdbyJobName($JobName, $global:Const_JobType_Executable)
      if ($JobId -eq -1) {
        # it is not an executable, it must be a DOS batch file
        $JobId = $global:Com.JobIdbyJobName($JobName, $global:Const_JobType_Batch)
        if ($JobId -eq -1) {
          # it is none of the above, => give up
          Abort "Asy-StartJob: Job not found: $JobToRun"
		} else {
          # it is a DOS batch file
          $global:AmtScript.BatchId         = $global:BatchId      # started Job might need access to assigned files so run under same batchId
          $global:AmtScript.StartDate       = $StartDate
          $global:AmtScript.StartTime       = $StartTime
          $global:AmtScript.Station         = $global:Initiator
          $global:AmtScript.User            = $global:User
          $global:AmtScript.Wait            = $Wait
          $global:AmtScript.RunAs           = $global:WindowsUser
          $global:AmtScript.ScriptParameter = $ParString

          if ($UseStartDateTime) {
            Add-InformationMsg "Asy-StartJob: Scheduling job: $JobToRun for $StartDate $StartTime"
            Write-JobLog "Asy-StartJob: Scheduling job: $JobToRun for $StartDate $StartTime" ([LoggingSeverity]::Info)
          } else {
            Add-InformationMsg "Asy-StartJob: Starting job: $JobToRun"
            Write-JobLog "Asy-StartJob: Starting job: $JobToRun" ([LoggingSeverity]::Info)
          }

          [Int32]$RequestId = $global:AmtScript.AddJobRequest($JobToRun, $global:Const_JobType_Script)

          if ($RequestId -lt 0) {
            Add-ErrorMsg "Asy-StartJob: ERROR: Could not add job request." 
          }

          if ($global:AmtScript.ErrorCode -ne 0) {
            Add-ErrorMsg "Asy-StartJob: Error starting job $JobToRun : $($global:AmtScript.ErrorDescription)"
          }
		}
      } else {
        # it is an executable
        Xqt "" $JobName
        End-Xqt
      }
	} else {
      # it is a report, => execute it
      Xqt "" $JobName
      End-Xqt
	}
  } else {
    # it is a (PowerShell) script
    $global:AmtScript.BatchId         = $global:BatchId      # started Job might need access to assigned files so run under same batchId
    $global:AmtScript.StartDate       = $StartDate
    $global:AmtScript.StartTime       = $StartTime
    $global:AmtScript.Station         = $global:Initiator
    $global:AmtScript.User            = $global:User
    $global:AmtScript.Wait            = $Wait
    $global:AmtScript.RunAs           = $global:WindowsUser
    $global:AmtScript.ScriptParameter = $ParString

    if ($UseStartDateTime) {
      Add-InformationMsg "Asy-StartJob: Scheduling job: $JobToRun for $StartDate $StartTime"
      Write-JobLog "Asy-StartJob: Scheduling job: $JobToRun for $StartDate $StartTime" ([LoggingSeverity]::Info)
    } else {
      Add-InformationMsg "Asy-StartJob: Starting job: $JobToRun"
      Write-JobLog "Asy-StartJob: Starting job: $JobToRun" ([LoggingSeverity]::Info)
    }

    [Int32]$RequestId = $global:AmtScript.AddJobRequest($JobToRun, $global:Const_JobType_Script)

    if ($RequestId -lt 0) {
      Add-ErrorMsg "Asy-StartJob: ERROR: Could not add job request." 
    }

    if ($global:AmtScript.ErrorCode -ne 0) {
      Add-ErrorMsg "Asy-StartJob: Error starting job $JobToRun : $($global:AmtScript.ErrorDescription)"
    }
  }
} # Asy-StartJob

function Check-ValidPs {
  <#
    .SYNOPSIS
       Check for powershell command in lines
    .DESCRIPTION
       Does an array of lines (e.g. file content) contain powershell?
    .PARAMETER $Lines
       Array of strings with possible powershell
	.OUTPUT
       True when a powershell statement was found
  #>

  param (
    [String[]]$Lines
  )
  
  [String[]]$Statements = ""
  [Boolean]$MultilineComment = $false
  foreach ($Line in $Lines) {
    # Remove any comments, multiline comments are not always parsed correctly.
    if ($MultilineComment) {
      if ($Line.Contains('#>')) {
        $MultilineComment = $false
      }
      continue
    }
    if (($Line.Contains('<#')) -and (-not ($Line.Contains('#>')))) {
      $MultilineComment = $true
      continue
    }
    if ($line.TrimStart().StartsWith('#')) {
      continue
    }
    $Statements += $Line
  }
  $Tokens = $null
  $Errors = $null
  #Parse the statements without any comment lines
  $Ast = [System.Management.Automation.Language.Parser]::ParseInput($Statements, [ref]$Tokens, [ref]$Errors)
  #Check for any Ast statements in the Ast object
  $Nodes = $Ast.FindAll({$args[0] -is [System.Management.Automation.Language.StatementAst]}, $true)
  #Only when statements found, check the tokens for valid powershell
  if (($Nodes -ne $null) -and ($Nodes.Count -gt 0)) {
    foreach ($Token in $Tokens) {
      if ($Token.TokenFlags -eq 'commandname') {
        try {
          if (Get-Command -Name $Token -ErrorAction Stop) {
            return $true   # Found a powershell statement - assume the rest is powershell also
          }  
        } catch {
          return $false # Not powershell
        } 
      } elseif (($Token.TokenFlags -eq 'keyword') -or                                          #like catch
                ($Token.TokenFlags -eq 'Keyword, StatementDoesntSupportAttributes')) {         #like try 
        return $true      # Found a powershell keyword - asume the rest is powershell also
      }
    }
  }

  return $false  # No powershell found
} # Check-ValidPs

function TempPs1Filename {
  <#
    .SYNOPSIS
       Change a filename into a temporary ps1 filename.
    .DESCRIPTION
       For dot sourcing a file needs a ps1 extension
    .PARAMETER [String]$Filename
       Name of the file to change.
	.OUTPUT
       Name of the temporary ps1 file including (temp) path
  #>

  param (
    [String]$Filename
  )

  [String]$Ps1File = $Filename.Replace('/', '\')
  if ($Ps1File.Contains(".")) {
    $Ps1File = [System.IO.Path]::GetFileNameWithoutExtension($Ps1File)
  }
  return (Add-BackSlash $global:TempFolder) + $Ps1File + ".ps1"
} # TempPs1Filename

function DynamicPowershellInFile {
  <#
    .SYNOPSIS
       Check for dynamic powershell (ECL) in a file
    .DESCRIPTION
       Read contents of a file, check for powershell statements.
       When found create a new ps1 file with these statements and return true.
    .PARAMETER [String]$Filename
       Name of the file to check.
	.OUTPUT
       True when file contains powershell
  #>
  
  param (
    [String]$Filename
  )

  [String[]]$Data = Read-FileContent $Filename
  if (Check-ValidPs $Data) {
    $global:TempPs1File = (TempPs1Filename $Filename)
    Write-FileContent $global:TempPs1File ($Data | Out-String)
    return $true 
  } else {
    return $false
  }
} # DynamicPowershellInFile

function Get-TempPs1File {
  <#
    .SYNOPSIS
       Get the name of the temporary ps1 file
    .DESCRIPTION
       For dot sourcing a file needs a ps1 extension
       A global TempPs1File variable should be set at DynamicPowershellInFile check.
  #>

  return $global:TempPs1File
} # Get-TempPs1File

function CleanUp-TempPs1File {
  <#
    .SYNOPSIS
       Delete the temporary ps1 file
    .DESCRIPTION
       After dot sourcing the ps1 file may be deleted
  #>


  Delete-File (Get-TempPs1File $global:TempPs1File)
  $global:TempPs1File = ""

} # CleanUp-TempPs1File

function Copy-FileWithTwist {
  <#
    .SYNOPSIS
      Performs a file copy with a side effect.
    .PARAMETER SourceFileName
      [String] The source file specification.
    .PARAMETER TargetFileName
      [String] The target file specification.
    .PARAMETER Twist
      [String] The twist, a string identifying what extra action to perform.
  #>

  param (
    [String]$SourceFileName,
    [String]$TargetFileName,
    [String]$Twist,
    [Boolean]$Trim = $false
  )

  switch ($Twist) {

    "PrefixSourceWithTransferRoot"  {
      # we only want to do this if SourceFileName starts with a single \
      if ($SourceFileName.StartsWith("\") -and -not $SourceFileName.StartsWith("\\")) {
        [String]$TransferRoot = GetAmtSetting "TransferRoot"
        $SourceFileName = $TransferRoot + $SourceFileName
      } elseif ($SourceFileName.Contains("*")) {
        # it is an OS2200 file reference, => convert it to a Windows path
        $SourceFileName = Get-AssignedFile (Convert-FileReference $SourceFileName)
      }

      $TargetFileName = Get-AssignedFile (Convert-FileReference $TargetFileName)

      if (-not $global:AmtFile.FileExists($TargetFileName) -and -not $TargetFileName.EndsWith($global:Extension)) {
        $TargetFileName += $global:Extension
      }

      break
    }

    "PrefixTargetWithTransferRoot" {
      $SourceFileName = Get-AssignedFile (Convert-FileReference $SourceFileName)

      # we only want to do this if TargetFileName starts with a single \
      if ($TargetFileName.StartsWith("\") -and -not $TargetFileName.StartsWith("\\")) {
        [String]$TransferRoot = GetAmtSetting "TransferRoot"
        $TargetFileName = $TransferRoot + $TargetFileName
      } elseif ($TargetFileName.Contains("*")) {
        # it is an OS2200 file reference, => convert it to a Windows path
        $TargetFileName = Get-AssignedFile (Convert-FileReference $TargetFileName)
      }

      break
	}

    default {
      Abort "$Twist is not a valid twist name."
	}
  }

  # perform the copy (overwriting any existing file)
  [String]$Msg = ""
  $Result = CopyFileToAscii $SourceFileName $TargetFileName $true 2 ([Ref]$Msg) $Trim
  if (-not $Result) {
    Abort $Msg
  }
} # Copy-FileWithTwist


function Delete-FileWithTwist {
  <#
    .SYNOPSIS
      Performs a file delete with a side effect.
    .PARAMETER Path
      [String] The file specification.
    .PARAMETER Twist
      [String] The twist, a string identifying what extra action to perform.
  #>

  param (
    [String]$Path,
    [String]$Twist
  )

  switch ($Twist) {

    "PrefixPathWithTransferRoot"  {
      # we only want to do this if SourceFileName starts with a single \
      if ($Path.StartsWith("\") -and -not $Path.StartsWith("\\")) {
        [String]$TransferRoot = GetAmtSetting "TransferRoot"
        $Path = $TransferRoot + $Path

        if ($Path.EndsWith("*.") -or $Path.EndsWith(".*")) {
          # delete multiple files with mask
          [Int32]$LastBackslash = $Path.LastIndexOf('\')
          if ($LastBackslash -gt -1) {
            $Folder = $Path.Substring(0, $LastBackslash)
            $Pattern = $Path.Substring($LastBackslash + 1)
            [String[]]$Files = [System.IO.Directory]::GetFiles($Folder, $Pattern)
            ForEach ($File in $Files) {
              Delete-File $File
            }

            return
          }
        }
      } elseif ($Path.Contains("*")) {
        # it is an OS2200 file reference, => convert it to a Windows path
        $Path = Get-AssignedFile (Convert-FileReference $Path)
      }


      break
    }

    default {
      Abort "$Twist is not a valid twist name (Delete-FileWithTwist)."
	}
  }

  # perform the delete
  Delete-File $Path
} # Delete-FileWithTwist


function Test-AsyscoUnicode {
  <#
    .SYNOPSIS
      Tells whether the specified file starts with a Byte Order Mark for either UTF-16 (LE) or UTF-32 (LE) or not.
    .PARAMETER The file system path of the file to test.
      [String] $FilePath
    .OUTPUT
      [Boolean] A value indicating whether the specified file starts with a Byte Order Mark for either UTF-16 (LE) or UTF-32 (LE) or not.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$FilePath
  )

  [Asysco.Amt.Scripting.IFileBinaryStream]$FileStream = $global:AmtFile.OpenBinaryFile($FilePath, $global:Const_Exclusive)
  if ($FileStream -eq $null) {
    Abort "Test-AsyscoUnicode: $($global:AmtFile.ErrorDescription)"
  }

  try {
    [Byte[]]$FirstTwoBytes = $FileStream.Read(0, 2)
    if ($FirstTwoBytes.Length -eq 2 -and $FirstTwoBytes[0] -eq (0xFF -as [char]) -and $FirstTwoBytes[1] -eq (0xFE -as [char])) {
      return $true
    } else {
      return $false
    }
  } finally {
    $FileStream.Close() | Out-Null
  }
} # Test-AsyscoUnicode


function CopyFileToAscii {

  <#
    .SYNOPSIS
      Copies a file, converting it to ASCII if the source file appears to be a Unicode text file.
    .PARAMETER $SourceFilePath
      [String] The file system path of the source file.
    .PARAMETER $TargetFilePath
      [String] The file system path of the target file.
    .PARAMETER $Overwrite
      [Boolean] A value indicating whether to overwrite the target file if it exists or not. 
    .PARAMETER $MaxWaitTime
      [String] The maximum number of seconds to wait for a file to become available if it appears to locked.
    .OUTPUT
      [Boolean] A value indicating whether the operation was successful or not.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$SourceFilePath,
    [Parameter(Mandatory=$true)][String]$TargetFilePath,
    [Parameter(Mandatory=$true)][Boolean]$Overwrite,
    [Parameter(Mandatory=$true)][Int32]$MaxWaitTime,
    [Parameter(Mandatory=$true)][Ref][String]$Msg,
    [Parameter(Mandatory=$false)][Boolean]$Trim = $false
  )

  $TempFilePath = [System.IO.Path]::GetTempFileName()
  try {
    # if the file is a Unicode text file created by Asysco, => convert it to ASCII and treat is as the new source file
    if (Test-AsyscoUnicode $SourceFilePath) {

      # convert it to local temporary ASCII file
      [Object]$SourceStream = $global:AmtFile.OpenTextFile($SourceFilePath, $global:Const_Exclusive, $global:Const_FileEnc_Unicode, $true)
      [Object]$TempStream = $global:AmtFile.OpenTextFile($TempFilePath, $global:Const_Exclusive, $global:Const_FileEnc_ASCII, $false)

      while (-not $SourceStream.EndOfFile) {
        [String]$Line = $SourceStream.ReadLine()
        if ($Trim) {
          $Line = $Line.TrimEnd()
        }
        $TempStream.WriteLine($Line, $false) | Out-Null
      }

      $TempStream.Close() | Out-Null
      $SourceStream.Close() | Out-Null
      $SourceFilePath = $TempFilePath
    } elseif ($Trim) {
      [Object]$SourceStream = $global:AmtFile.OpenTextFile($SourceFilePath, $global:Const_Exclusive, $global:Const_FileEnc_ASCII, $true)
      [Object]$TempStream = $global:AmtFile.OpenTextFile($TempFilePath, $global:Const_Exclusive, $global:Const_FileEnc_ASCII, $false)

      while (-not $SourceStream.EndOfFile) {
        [String]$Line = $SourceStream.ReadLine()
        $Line = $Line.TrimEnd()
        $TempStream.WriteLine($Line, $false) | Out-Null
      }

      $TempStream.Close() | Out-Null
      $SourceStream.Close() | Out-Null
      $SourceFilePath = $TempFilePath

    }
    # copy the (possibly converted) source file to its destination
    $global:AmtFile.CopyFile($SourceFilePath, $TargetFilePath, $Overwrite, $MaxWaitTime) | Out-Null
    if ($global:AmtFile.ErrorCode -ne 0) {
      $Msg.Value = $global:AmtFile.ErrorDescription
      return $false
    }
  } finally {
    if (Test-Path $TempFilePath) {
      Remove-Item $TempFilePath
    }
  }

  $Msg.Value = ""

  return $true
} # CopyFileToAscii

function WaitForChildJobs {
  <#
    .SYNOPSIS
      Wait until all jobs and programs started by this job are finished.
    .DESCRIPTION
      This function waits untill all children with the same BatchId are finished
  #>
  [Int32]$LastJobCount = 0
  while ($true) {
    [Int32]$JobCount = 0  

    $JobList =  $global:Com.GetQueuedJobs()
    [Int32[]]$RequestList = @()
    foreach ($job in $JobList) {
      if (($job.BatchId -eq $global:BatchId) -and ($job.RequestId -ne $global:BatchId)) {
        $jobCount++
        $RequestList += $job.RequestId
      }
    }
    $JobList =  $global:Com.GetJobs()
    foreach ($job in $JobList) {
      if (($job.BatchId -eq $global:BatchId) -and ($job.RequestId -ne $global:BatchId)) {
        foreach($Id in $RequestList) {
          if ($Id -eq $job.RequestId) {
            $jobCount--  #already found in requests but now started, don't count twice
            break
          }
        }
        $jobCount++
      }
    }

    if ($jobCount -eq 0) {
      [String]$Msg = "WaitForChildJobs: No child jobs running."
      Add-InformationMsg $Msg
      Write-JobLog $Msg ([LoggingSeverity]::Info)
      break    ## out of loop
    } else {
      if ($JobCount -ne $LastJobCount) {
        [String]$Msg = "WaitForChildJobs: Waiting for completion of $JobCount child jobs."
        Add-InformationMsg $Msg
        Write-JobLog $Msg ([LoggingSeverity]::Info)
        $LastJobCount = $JobCount
      }
      Start-Sleep -Seconds 1
    }
  }
} #WaitForChildJobs
