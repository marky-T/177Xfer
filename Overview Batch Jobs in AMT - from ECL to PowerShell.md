



# Glossary


# Introduction
## PowerShell scripting
This document gives a basic introduction to PowerShell scripting on the Windows environment and then gives a further insight into how it is implemented in AMT following migration from ECL to PowerShell.
This document gives information on a generic level. The scripting environment may have been tailored to the customer specific requirements during migration. These customizations are not included in this document but will be covered in handover training material.
This document consists of the following sections:
- 1.1 Basic introduction to the Windows Scripting Environment
- 1.2 Script components in AMT environment
- 1.3 Developing scripts for an AMT environment
- 1.4 Debugging and Error handling
- 1.5 Scripts in the AMT ControlCenter
- 1.6 Starting scripts without the AMT ControlCenter
This document is based on the technology used by AMT.net version 6R2.
## Conventions used in this document
The following icons will be used in this document to denote various kinds of information

## Attendees
Attendees should at least have a basic working knowledge of the following:
- 3.1 AMT Administration and Operations. This training should be successfully completed.
- 3.2 The Microsoft Windows environment (Windows Vista or later).
- 3.3 Basic knowledge of Windows PowerShell Scripting

This document will reference topics described in greater detail in the online AMT- help system. The relevant sections in these guides will be indicated and the attendee will reference these manuals for guidance as well. To access the AMT- Help system enter the URL:
http://help.myasysco.com/Launchpad
in your web browser.
Please note that the online help system is being updated constantly to reflect the newest versions of the AMT system. For help with your specific installed version please reference the static help files provided for your system.

# Basic concepts
## Windows PowerShell
Windows PowerShell is the standard Windows command-line shell. Windows PowerShell includes a runtime engine, data providers, core commands (known as cmdlets), a scripting language, and an interactive prompt. Windows PowerShell is completely object-oriented and processes cmdlets, script files (.ps1), and executable files.
The PowerShell command prompt can be used to start PowerShell scripts or to enter PowerShell commands.

Figure 3-1 PowerShell command prompt


Since the syntax checking in PowerShell is limited and the scripts are not compiled, errors can occur when the script is tested. When an error occurs, it’s very helpful to run the script in debug mode. There are multiple editors available. For example, the PowerShell Integrated Scripting Environment is included in Windows.


Figure 3-2 Windows PowerShell ISE

PowerGUI® of Quest Software Inc. is another editor that is used a lot.

Figure 3-3 PowerGUI
It’s beyond the scope of this training to go into details of these editors. During the training, the Windows PowerShell Integrated Scripting Environment will be used.

## ECLs converted to PowerShell scripts
The initial PowerShell scripts in the AMT environment are converted from Unisys® ECL (Executive Control Language) scripts. Every ECL is converted on a line-by-line basis. The mainframe specific behaviour of the ECL script is hidden away in the AMT PowerShell ECL Library (AmtPsEclLib). This library contains a collection of generic functions that mimic the mainframe behaviour.
Appendix A shows a side-by-side example of an ECL migration to PowerShell.
## Starting a script
There are multiple ways to start a script
- 6.1 From the Windows Command prompt. This method is also used by external scheduling applications like OpCon®.
- 6.2 From the PowerShell prompt.
- 6.3 From a script editor like Windows PowerShell ISE
- 6.4 From an online or batch program. The program has to add the script to AMT. The request will be handled by the AMT BatchController.
- 6.5 From the AMT ControlCenter. This will also add the script to the job requests.
Notes:
To benefit the most from the AMT framework, the script has to connect to the AMT Application. After the connection is established, all messages will be shown in the AMT ControlCenter.
The connection is made through the COM script library that is included in the AMT installation. Which is described in section 4.4.

When the script is started from the command line or PowerShell prompt, the BOJ (Begin Of Job) and EOJ (End Of Job) are not shown in the AMT ControlCenter.
In this overview, multiple ways of starting a script will be explained.
# AMT Components
To run PowerShell scripts in an AMT environment, several components are required. This section gives an overview.
## AmtPsEclLib.psm1
This library contains a collection of functions that mimic the mainframe behaviour and contain AMT specific functions to keep the actual script code similar to the original ECL code.
All functions are documented according to the PowerShell standards. Because of this, all default PowerShell help functions can be used for the functions in the Library.

Figure 4-1 Example AmtPsEclLib documentation
The AmtPsEclLib is a generic library. When client specific functions are required, additional libraries can be created.

The library is loaded at the very beginning of every script.
Import-Module -Name "..\Library\AmtPsEclLib.psm1" -Force -DisableNameChecking -ErrorAction Stop -ArgumentList $args


Parameters used with the Import-Module cmdlet

## AmtPsSortLib.psm1
This additional library focuses on the single task of sorting files. The sort library needs to be imported alongside the ECL library in a similar fashion.
## AmtSettings.xml
This configuration file holds the settings that are required to run scripts within AMT.
<Amt>
<AmtSettings>
<AppName>TEST_APP</AppName>
<IniFile>D:\Amt\Sys.Ini</IniFile>
<ComScript>C:\DLLs\ComScript.dll</ComScript>
<MainframeOS>2200</MainframeOS>
<MaxWaitTime>5</MaxWaitTime>
<UseJobLog>True</UseJobLog>  <!-- If True the logging will be enabled -->
<LogTimes>True</LogTimes>    <!-- If True the time is added to each JobLog -->
<LogEventError>True</LogEventError>
<LogEventInfo>False</LogEventInfo>
<LogEventWarning>False</LogEventWarning>
</AmtSettings>
</Amt>
These settings are loaded by the AmtPsEclLib in the initialization phase of the script.
$AmtSettings = [xml](Get-Content $AmtSettingsFile)
After loading the XML file, the elements can be inquired in the script.
$global:SysIniFile = $AmtSettings.Amt.AmtSettings.IniFile


## AMT ComScript library
The ComScript library is included in the AMT installation. The script needs this library to connect to the AMT application. Without a successful connection, the AMT related functions in the AmtPsEclLib cannot work. The AmtPsEclLib function “Connect-Application” connects to the application based on the value of $global:AppName. When the connection cannot be established, the script will terminate.
The application name can be set in the AmtSettings file or in the script.
<AppName>TEST_APP</AppName>
The AppName will be read by the ‘Initialize’ function of the AmtPsEclLib
$global:AppName    = $AmtSettings.Amt.AmtSettings.AppName
The path the ComScript library can also be specified in the AmtSettings file.
<ComScript>C:\DLLs\ComScript.dll</ComScript>
# Getting started
## Script skeleton
Every migrated ECL script is based on a structure and contains the next sections
### Include the library.
Import-Module -Name "..\Library\AmtPsEclLib.psm1" -Force -DisableNameChecking -ErrorAction Stop -ArgumentList $args

Import-Module -Name "..\Library\AmtPsSortLib.psm1" -Force -DisableNameChecking -ErrorAction Stop -ArgumentList $args


$AmtSettingsFile = "..\Settings\AmtSettings.xml"
In above example, the path to the AmtPsEclLib, AmtPsSortLib and AmtSettings file are relative to current directory of the script that is started. It’s good practice to have the same directory structure on different environments. Using the relative path makes it easy to deploy the scripts.
The variable $AmtSettingsFile is used in the “initialize” function.
### Functions
To avoid replication of code, functions can be defined. In PowerShell, functions need to be defined before they are called. Although it’s not required to define all the functions in the beginning of the script, it’s good practice and improves readability, to group these before that actual body of the script.
When a function is needed in more than one script, it might be an option to create a separate library that is loaded as described in section 5.1.1.

### Body
The actual body is where the script execution begins. The minimal content consists of:
#Initialize
Set-Jobname "TEST_SCRIPT"
Initialize $AmtSettingsFile

Trap {
HandleTrapAndAbort "Error trapped:" $_
}


<Script commands>

Fin


Trap allows the library to handle runtime exceptions and log them.

The ‘Fin’ function triggers a ‘Cleanup’ method which disposes all the created object instances and closes all the files.

## Error handling
Errors in a script can be logged on multiple places depending how the script is started. The following sections will delve into these logging locations.
### Windows Event log
The AMT PowerShell library has the function ‘Asy-WriteEventLog’ to write errors to the Windows Event file. This function is called in AmtPsEclLib whenever a fatal error occurs.
This functionality can be switched on or off by the setting ‘LogEventError’ in the AmtSettings.xml configuration file.
<LogEventError>True</LogEventError>

Figure 5-1 Windows event property
The ‘Source’ of the error depends on how the script is started. It will contain ‘powershell_ise.exe’ when started from the Windows PowerShell ISE. The name of the AMT BatchController will be shown when started from the AMT ControlCenter.

Figure 5-2 Windows event log items

### AMT BatchController log
The AMT BatchController log will show any errors in a script when the script is connected to an application (See section 4.4) or when the script is started through the ControlCenter.
The AMT BatchController log can be inquired in the AMT ControlCenter
- 12.1 Applications – Server Control - <BatchController> - Messages
- 12.2 Processed – Logging - <BatchController>
The log file can also be inquired by any text editor. The log path is defined in the ControlCenter base path and is also shown in the ‘Name’ field in the ‘Log Entries’.

Figure 5-3 AMT BatchController log
### AMT ControlCenter
When a script is terminated because of an error, the error message will be displayed in the ControlCenter Jobs – Job Management.

Figure 5-4 AMT Job Management
The error message will only be shown when the script has successfully connected to the application (See section 4.4) or is started through the ControlCenter. The details of the error can be inquired by double clicking on a line or by selecting (single click) and clicking the ‘View’ button.
Any error message will also be shown in the Messages – Alerts.

Figure 5-5 AMT Alert messages
The details of the error message can be inquired by double clicking on a line or by selecting (single click) and clicking the ‘View’ button.
### Job Summary
All (error)messages are logged by the AMT library in a job summary. The filename is constructed by AMT library but can also be specified in the job by the function ‘Set-JobSummaryTitle’
ECL_CALL_REPORT_NORESULT started 09:10:58
Amt PS ECL library version: 0.198, date: 2016-01-13
09:10:59
09:10:59 Amt Sort PS library version: 60.17, date: 2015-12-02
09:10:59 Sort-Init
09:10:59Info:  Script Started: ECL_CALL_REPORT_NORESULT
09:10:59 Starting report: REP_NORESULT
09:11:01 End Report. Time 00:00:02
09:11:01 Get-CompletedOK  : True
09:11:01
09:11:01 End Job. Start: 01/25/2016 09:10:58
09:11:01          End:   01/25/2016 09:11:01
Whether the job summary is created, is defined by the setting of ‘UseJobLog’ in the AMT Settings file. The setting ‘LogTimes’ defines whether the time is included in every log entry.
The file location is defined in the base-path setting in the AMT ControlCenter

Figure 5-6 AMT Basepath configuration
### PowerShell ISE or PowerShell Prompt
The AMT PowerShell library will automatically terminate the script when a fatal error occurs. When the script is started though the PowerShell ISE or from the PowerShell prompt, the window will automatically be closed and the error message cannot be inquired anymore. To prevent this, the ‘Exit’ in the ‘Cleanup’ function can be commented out temporary.

Figure 5-7 Windows PowerShell ISE
Exercise 1 (Basic script in AMT)
- 12.3 Create a script using the Windows PowerShell ISE (WP-ISE) that displays the text “Hello World” using the command ‘Add-InformationMsg’. Check and correct the content of the `AmtSettings.xml´ file.
- 12.4 Start the script from the WP-ISE and look at the ‘Messages’ and ‘Jobs’ in the ControlCenter
- 12.5 Now start the script in the ControlCenter. It might be necessary to load the script in the ControlCenter. When the script is loaded and it’s not listed in your jobs, check the security settings in the ControlCenter.
What is the difference?


Exercise 2 (Debugging)
This exercise will use the debug functionality of the Windows PowerShell ISE.
- 12.6 Open the script created in exercise 1.
- 12.7 It’s important to change the working folder to the folder of the script. This can be done in the command box.
PS C:\Windows\system32> cd D:\AMT\Scripts\Demo2

PS D:\AMT\Scripts\Demo2>
- 12.8 Create a breakpoint. Right click on the line and select ‘Toggle Breakpoint’ or use F9.
- 12.9 Start the script with the ‘run’ icon in the menu bar or F5.
### 12.10 The script will pause when a breakpoint is hit. Then the next actions are possible:
#### 12.10.1 F10 – Step over – Will execute the next statement. When the statement is a function call, the session will not step into the code of the function.
#### 12.10.2 F11 – Step into - Will execute the next statement. When the statement is a function call, the session will step into the code of the function.
#### 12.10.3 <Shift>F11 – Step out – When in a function, the execution of the code will continue and return to the line where the function is called.
#### 12.10.4 F5 – Continue debugging until the next breakpoint or end of the script
#### 12.10.5 <Shift>F5 – Stops the debug session. The script will be aborted.

### 12.11 The content of variables can be inquired by:
#### 12.11.1 Hovering the mouse over the variable
#### 12.11.2 Type the name of the variable in the command box
[DBG]: PS C:\Windows\system32>> $STR1
abc
#### 12.11.3 When an object need to be inquired, code completion will help to select the desired attribute.

- 12.12 The content of the variable can be changed in the command box
[DBG]: PS C:\Windows\system32>> $STR1 = "xyz"

[DBG]: PS C:\Windows\system32>> $STR1
xyz
- 12.13 Try the different (debug) functions of the Windows PowerShell ISE.

Exercise 3 (Error handling)
In this exercise, the different locations for the error messages will be investigated by introducing different kind of errors.  The debug function of the PS-IDE can be used to investigate any script errors.
### 12.14 Change the application name in the AmtSettings.xml file to a non-existing value.
#### 12.14.1 Start the script created in exercise 1, in the ControlCenter
#### 12.14.2 Where is the error logged?
#### 12.14.3 Start the script in WP-ISE
#### 12.14.4 Where is the error logged?
### 12.15 Correct the AmtSettings.xml file and insert code with syntax errors after the ‘Initialize’ function.
#### 12.15.1 Start the script in the ControlCenter
#### 12.15.2 Where is the error logged?
#### 12.15.3 Start the script in WP-ISE
#### 12.15.4 Where is the error logged?
# Scripts and reports in AMT
## Introduction
Scripts are usually used to start one or more reports. The parameters that need to be passed to the report are provided to the AMT Job object.
## Starting a report
The AMT PowerShell library provides the function ‘Xqt’ to start a report in AMT. In fact the report is actually not started by the script, but the Job interface inserts a job request in the AMT system database. This request is processed by the AMT BatchController.
‘Xqt’ uses the following syntax: Xqt "<Optional Options>" "<Reportname>"

Example:
Xqt "" "FILLREPORT"
This will start report “FILLREPORT”.
The result can also be inquired in the ControlCenter Jobs – Job Management.

Figure 6-1
Exercise 4 (Start report)
- 14.1 Change the script to start the report ‘ReportNoResult’
- 14.2 Start the script through the ControlCenter
- 14.3 Check the ‘Jobs’ and ‘Messages’ in the ControlCenter


## Pass parameters to a script
Parameters can be passed to a script in the ControlCenter or in the command line. The parameter consists of a string. Multiple parameters are separated by a space.
Alpha numeric parameters need to be enclosed in single quotation marks when these contain spaces.
–Parameter ‘Hello world’
Parameters are defined at the beginning of the scripts and assigned to variables.
Param(
[String]$STR1,
[String]$STR2,
[Int32]$INT1
)
In PowerShell, parameter checking can be included as demonstrated in next example.
Param (
# Application name
[Parameter(Mandatory=$false)]
[String]$Application,

# Job name or filepath
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[String]$Job,

# Array containing parameter objects (could be of any type)
[Parameter(Mandatory=$false)]
[Object[]]$Params = @()
)
The parameters are named and can be preceded with the name of the variable. For previous example this is:
-Application “DEMO2” – Job “TESTJOB” –Params ‘Hello world’, 2015
It’s also possible to pass the parameters without naming them. In that case the parameters will be processed in the order they are defined in the function. Optional parameters have to be specified last in the list.
Elements in an array-type parameter, need to be separated by commas ‘,’.

Exercise 5 (Unnamed parameter passing)
### 15.1 Create a script that accepts two parameters.
#### 15.1.1 One string;
#### 15.1.2 One numeric.
- 15.2 Use the ‘Add-InformationMsg’ function of the AMT library to show the parameters passed.
### 15.3 Use values for the string parameter that contain:
#### 15.3.1 Single string;
#### 15.3.2 String with enclosed space(s);
- 15.4 Start the script from the ControlCenter.

Exercise 6 (Named parameter passing)
- 15.5 Use the script of exercise 5.
- 15.6 Change the parameters to named parameters. Both parameters are mandatory.
- 15.7 Run the same kind of test as executed in previous exercise.
- 15.8 Notice what happens when mandatory parameters are not passed.
- 15.9 Also run the script providing the parameters in different order.
# Start a script in a non-AMT scheduler

## Scheduling tools
There are a number of scheduling tools available that can start a command line. For example there is the Microsoft Task Scheduler which is available in all recent Windows systems. Another example is OpCon®. OpCon® is a product of SMA Solutions (http://smasolutions.it/).
The generic syntax to start a PowerShell script from a command line is;
Powershell.exe –Command <ScriptName>

Figure 7-1 Task Scheduler

# Additional functionality
## Runtime usercode handling
In the initialize function of the AMT library, the initiating usercode is retrieved. This usercode will be passed to the job or report request that is added to the AMT System Database. The AMT BatchController will run the script or report under that usercode by user impersonation. This usercode has to be defined in the AMT ControlCenter Security – Login Accounts.
Normal Windows security applies to this kind of job initiation, i.e. when the usercode has no access to the script, or report executable, the initiation will fail.
The AMT FileController will also use the usercode that is passed. When that usercode has no access to the file or folder, the file doesn’t exist, or cannot be created.
Some scheduling tools use the “run as” to start the command line as a specific user.
When a script is started from the ControlCenter, the default account will be used. This usercode is specified in Security – Login Accounts.

Figure 8-1

## AMT Queues
When the request is added, a queue name can be specified. The name of the queue can also be constructed dynamically, for example based on the application name.
If the queue is not specified, the script or report will run in the default queue.
An AMT BatchController can service one or more queues. A queue can be serviced by maximum three BatchControllers. When a queue is serviced by more than one BatchController, AMT will assign the BatchController dynamically.
When none of the BatchControllers is available to service the queue, the jobs will be queued until the BatchController is started.


# Appendix A (ECL migration example)
