AMT Installation andConfiguration TrainingAMT Installation andConfiguration Training
AMT 
Installation 
and
Configuration 
Training
AMT 
Installation 
and
Configuration 
Training
Table of contents


1Introduction6
1.1AMT Installation and Configuration6
1.2Attendees6
1.2.1Audience6
1.2.2Prerequisites6
1.2.3Learning objectives7
1.3Daily Time Schedule7
1.4Exercises7
2Installation summary8
3Prerequisites9
3.1System requirements9
3.2Available disk space12
3.3User permissions13
4Installation of AMT14
4.1Unpacking the AMT software14
4.2Creating the Repository Database16
4.3Configuring Lion.ini18
4.4Running Setup.exe20
4.5Installation Version Checking22
5AMT License24
5.1Install latest updates24
6Installation of the AMT Control Center26
6.1Create the System Database26
6.2Setup the Windows environment variable28
6.3Configure Sys.ini30
6.4Reorganize System database32
6.5Adding websites to IIS34
7Basic Control Center settings36
7.1Base setup36
7.2Create default login account40
7.3Installing basic services42
7.3.1AMT File Controller42
7.3.2AMT Batch Controller46
7.3.3AMT Batch controller Job Queues50
7.3.4AMT Print Controller52
7.3.5AMT Print Controller Print Queues55
7.3.6Remote Print Service57
7.3.7AMT Reorganization service57
7.4Basic Runtime configuration58
7.4.1Base paths59
7.4.2Logging61
7.4.3General Logging Level62
7.4.4Runtime behavior64
8Application setup67
8.1.1Database setup67
8.2Configuration setup72
8.3Application setup74
8.4Setup AMT LION Application services77
8.4.1Application Manager78
8.4.3Finalize Application setup83
8.4.4Configure app.ini86
8.4.5Setup IIS for web enabled applications88
8.4.6Security88
8.5Reorganize application database90
9Logging92
9.1Transaction logging setup92
9.1.1Setup database in the AMT Control Center92
9.1.2Create an empty database in SQL Server93
9.1.3Enable transaction logging94
9.1.4Run AMT Reorganize95
9.2General logging97
9.2.1Logging media97
9.2.2Logging severities99
9.2.3Setting the logging level101
9.2.4Logging details102
9.2.5Retention period103
9.3Audit configuration103
10Saving the Control Center configuration104
10.1Configuration Manager104
11Testing the application106
Appendix A: External Link Index107


Exercises
Exercise 1: Install AMT LION15
Exercise 2: Create an empty repository database17
Exercise 3: Configure LION.INI19
Exercise 4: Run Setup.exe23
Exercise 5: Install latest AMT release25
Exercise 6: Configure AMT system database27
Exercise 7: Set AMTSYSTEM variable29
Exercise 8: Configure SYS.INI31
Exercise 9: Reorganize AMT System database33
Exercise 10: Configure IIS35
Exercise 11: Configure Base Setup39
Exercise 12: Configure AMT account41
Exercise 13: Configure AMT FileController45
Exercise 14: Configure AMT BatchController48
Exercise 15: Configure default queue51
Exercise 16: Configure AMT PrintController54
Exercise 17: Configure print queue56
Exercise 18: Configure Base Path60
Exercise 19: Configure Default logging63
Exercise 20: Configure Default Runtime behaviour66
Exercise 21: Configure User database71
Exercise 22: Setup a Configuration73
Exercise 23: Configure Application step #176
Exercise 24: Configure Application Manager80
Exercise 25: Configure Application Server82
Exercise 26: Configure AMT LION properties85
Exercise 27: Configure APP.INI87
Exercise 28: Configure Security89
Exercise 29: Reorganize application database91
Exercise 30: Configure Transaction database96
Exercise 31: Export AMT Control Center configuration105
Exercise 32: Test AMT LION application106

Introduction
AMT Installation and Configuration
This training guides the attendee through the initial installation process for an AMT LION runtime environment. This training is an addition to the steps described in Asysco’s online help resources.
After completing all the exercises, a basic runtime environment is created and the application can be run. 
This training does not cover the generation and deployment process. This is explained in the AMT Generation and Deployment training.
This training explains the basic security settings to make an application run. More extensive information is explained in the AMT Security Administration Training.
This 1-day (4 sessions) training course consists of:
Walk through of training manual
Explanation by the trainer on installation topics
Exercises for the trainees
Attendees
Audience
This training is intended for IT personnel that are responsible for set up and maintenance of the AMT runtime environment.
Prerequisites
Attendees should at least have a basic working knowledge of the following:
An internet browser like Microsoft Internet Explorer
Microsoft Windows environment
Using the File Explorer 
Start programs
Using the Windows Command Prompt
Solid understanding of Internet Information Server
SQL Server or Oracle
AMT training courses
AMT General Introduction (AGI)
AMT Control Center Operations (CCOL)
Learning objectives
After completing this training, the attendees will understand 
Prerequisites for an AMT installation
and be able to
install the AMT software and runtime environment
configure the AMT runtime environment using the AMT Control Center

Daily Time Schedule
Session 1:
Section 3: Prerequisites
Section 4: Installation of AMT
Session 2:
Section 5: Installation of AMT License
Section 6: Installation of AMT Control Center
Session 3:
Section 7: Basic Control Center settings
Session 4:
Section 8: Application setup
Section 8: Logging
Section 10: Save configuration
Section 11: Test application

Exercises
This training comes with a number of small, approximately 10 minute, exercises. These exercises have a logical order and need to be executed in the order they are described in the training manual.  
Every exercise has a heading like
Number
Number of the exercise
Learning objective
Describes the learning objective
Duration
Gives the average duration
Dependency
Describes the dependency on other exercises.
In total, there are 32 exercises.
Installation summary
The main steps to install and configure an AMT LION environment consist of:
Checking for prerequisites (e.g. OS, SQL server or .Net framework version)
Creating a number of empty databases
Defining the folder for installation and setup system parameters
Installing the AMT product
Generating a license request, and install the license
Configuring the basic runtime environment in the AMT Control Center
Setup the application runtime environment
Test the application

The above steps will be explained in this training.

Prerequisites
System requirements
AMT runs on a Windows environment. This can be a client version like Windows 10 or a server version like Windows Server 2016. All supported software can be found in the release notes website, here. 

Figure 31: Supported Software example

Figure 31: Supported Software example, shows an example of the system requirements of an AMT release. Since this information can change with every release, it’s important to check this before installation.

The AMT product is being upgraded to use .NET Core and various additional requirements have been introduced to enable this upgrade.  The following libraries will be required, on top of the latest .Net Framework version:
.Net Core 3.1.xVC_Redist x64.NET Core 3.1.x SDK 
ASP.NET Core Runtime 3.1 Hosting Bundle (download here)

Additional information on the prerequisites relating to .NET Core can be found in the Release Notes website here, and the locations of resources on the web are listed in Appendix A: External Link Index.
In your Visual Studios environment, all packages mentioned below must be installed in the order they appear.
Type “Turn Windows Features On or Off” in your Search bar and activate the following.


Install Visual Studio 2019:


Install Visual Studio 2019 Build Tools:




Install additional software packages:

AMT Add-ons:

Additional utilities:



Available disk space
Next table shows the space that needs to be available:
Component
Available space
AMT Developer Studio including patch files
1 Gb
AMT Tools
500Mb
AMT application
Depends on size of the application. 1 Gb for medium size applications
Table 31: Required disk space
User permissions
The person using the installation files, must have sufficient permissions. It might be that not all tasks are executed by the same person (i.e. the installation of the AMT product suite can be done by a System Administrator while the setup of the database is done by a Database Administrator).
In this training, the student has sufficient permissions to execute all tasks.


All executables need to be ‘Run as administrator’ by right-clicking on the executable and selecting ‘Run as administrator’. 


Figure 32: Run as administrator

Installation of AMT
Unpacking the AMT software
The Asysco AMT software consists of two Windows installation files: AmtSetup58.msi and LionWebDeploymentProjects.msi. 
AmtSetup58.msi contains all the AMT Developer and runtime tools. 
LionWebDeploymentProjects.msi only needs to be installed on AMT developer servers without an installation of Microsoft Visual Studio 2010.
The required .msi files are provided in this training. 



Exercise 1: Install AMT LION

Number
1
Learning objective
How to Install the AMT LION and WebDeployment packages
Duration
20 minutes
Dependency
None


Start the installation of Asysco AMT by double clicking the provided file: AmtSetup58.msi. The installation wizard will guide you through the process.
As you navigate the installation wizard, you will enter the physical path for your AMT installation (provided by the instructor).
The online help manual (link below) can be consulted for examples of how to install both .msi files. 
The WebDeploy2015.msi file can be found in the folder C:\AMT\SETUP, it is important to run this file as Administrator.

An installation example may be reviewed in the AMT online help manual:

Home > AMT Admin > Installation and Configuration > Installation of AMT > Unpacking AMT

Creating the Repository Database
The AMT Developer Studio uses a repository that is stored in a database.  This database needs to be created and available before further installation steps can be completed. 
Creating a new empty database is all that is required; the setup.exe of AMT will create the tables and indexes. 
For database access, Windows authentication or SQL authentication may be used. This is generally dictated by a company’s IT policies.  In our training exercises, we’ll be using SQL authentication.
For this training, an empty SQL Server environment is provided. The default collation is set to ‘Latin1_General_BIN’ which is required for migrated mainframe applications to have the same sorting order in the database and files. 
Further details and information are provided in the AMT online help manual.


Home > AMT Admin > Installation and Configuration > Installation of AMT > Creating the Repository Database



Exercise 2: Create an empty repository database

Number
2
Learning objective
Creating an empty Repository database
Duration
10 minutes
Dependency
Exercise 1


Start SQL Server Management Studio.  Select SQL Server Authentication, and login with the login/password credentials: asy/asy
Create an empty database named: AMT_REPOS  
While creating the new database, look under Options and check the ‘Collation’, this needs to be set to ‘Latin1_General_BIN’.
After the database is created, create a new user in that database named: LionDev, and give it the ‘db_owner’ role.  The credentials will be needed in the next step.


It’s good practice to precede the name of all AMT related databases with ‘AMT’, especially when the SQL Server is used for non-AMT databases as well. 



 
Configuring Lion.ini
This file is used for multiple purposes by the AMT development environment. One of these is the connection information to the Repository database created in the previous step.
The information used to find the Repository database is stored in the file Lion.ini in the Lion directory of the installation.  A default (example) Lion.ini file, named Default_Lion.ini, and an empty file named Lion.ini are provided.  These files can be opened in a simple text editor like Notepad.


Exercise 3: Configure LION.INI

Number
3
Learning objective
How to configure LION.INI
Duration
10 minutes
Dependency
Exercise 2: Create an empty repository database


Open the default_lion.ini file and the lion.ini file, after installation these are found in the ‘LION’ folder.
Copy all text from the default_lion.ini file to the empty lion.ini file.
See the instructions in the online help manual (link below) for examples of values to be used when configuring the Lion.ini.  The SQL Server instance name is usually the computer’s machine name, and can be found in Microsoft SQL Server Management Studio. Use the SQL login account asy (with password asy) that are used as credentials in the previous exercise. 

Home > AMT Admin > Installation and Configuration > Installation of AMT > Configuring lion.ini


Running Setup.exe
This program will finalize the installation of AMT.  It will create the needed database objects in the empty repository database created in section 4.2.
Setup also creates the IIS websites for the AMT Control Center, to do this, the correct information must be supplied.
A walkthrough of the process can be found here in the online help manual:

Home > AMT Admin > Installation and Configuration > Installation of AMT > Finalizing the Installation

Figure 41: Setup dialog

Additional information and settings in Setup.exe include:
The backup folder for installation rollback
Web site root (no changes are required)
Virtual folder: Represents the virtual directory in IIS. The base folder for the AMT Control Center and applications (e.g. when set to ‘AMT’, the ControlCenter will be configured as AMT\ControlCenter).  If no virtual directory is specified, the website will be configured directly under the default website. When more than one runtime environment will be configured on the same server, best practice is to use virtual directories (e.g. AMT_DEV, or AMT_TST, etc.)
Root URL: Must match the virtual folder setting. When the runtime environment is accessed from the server itself, http://localhost/AMT can be used. In other cases, the actual name of the server has to be specified, for example: http://amtdevserver/AMT
 
By checking or unchecking the “Https” checkbox, secure/non-secure versions of the sites are created, and the related web.config files, are updated to reflect the change.
Users can also select an application pool, specify a single application pool for all sites, and have a specific application configured all by checking the appropriate boxes.


It is also possible to change the IIS configuration manually in the Windows IIS Manager later, if needed. 







Installation Version Checking
To verify the versions of all the individual components of an AMT release would be time consuming if carried out for each file.  The ‘Amt Versions’ window provides the product and files versions for each component in a convenient list.  This can be found in the Setup tool under File > Versions.  The list is sorted by folder in a tree list view with the highest DLL version always being shown against the folder node.


Figure 42: AMT versions dialog

Exercise 4: Run Setup.exe

Number
4
Learning objective
Run setup.exe
Duration
15 minutes
Dependency
Exercise 3: Configure LION.INI

Follow the instructions in the online help manual to finalize the installation.  Remember to run setup.exe as Administrator.
Set the IIS mappings as mentioned on the previous page.
Check the IIS settings, using IIS Manager, after setup is completed.
Use SQL Server Management Studio to confirm tables are created in the new AMT_REPOS database when setup is complete.

Example of AMT folder structure after installation:
 
Figure 43: AMT Folder structure

AMT License
The AMT Control Center and AMT Developer Studio are licensed products and need a valid license to operate.  This license is server dependent and cannot be transferred to another server or cloned to another VM. 
The normal process for license installation is documented in the online help system.  For this training a valid runtime license is provided. 
For more information on requesting a new license, watch this video.

Home > AMT Admin > Installation and Configuration > Installation of AMT > Obtaining and Activating the AMT License


Install latest updates
The AMT product is updated regularly. Before installing an update, it’s important to check the release notes to verify your system meets current version requirements for OS, SQL etc. 
A new release may also come with special installation instructions.
These steps can be repeated with any new release; it is not necessary to install all releases.  The latest release contains all previous updates. 
The steps are the same as described in Section 4.4.


Home > AMT Admin > Installation and Configuration > Installation of AMT > Installing Releases and Fixes


Exercise 5: Install latest AMT release 

Number
5
Learning objective
How to install the latest AMT release
Duration
15 minutes
Dependency
Exercise 4: Run Setup.exe


Copy the setup.exe and provided AMT .dat file to the SETUP folder, overwrite existing files if necessary
Install the most current version of AMT
Installation of the AMT Control Center
The AMT Control Center application is installed by the setup process but is not ready for use.  For the Control Center to work, the following next actions are required:
Create an AMT System database
Setup the Windows environment variable
Configure Sys.ini
Reorganize the System database
Add websites to IIS when needed
Start Control Center configuration


Home > AMT Admin > Installation and Configuration > Installation of the Control Center

Create the System Database
All components in an AMT runtime environment communicate with the System database.  This database is used for configuration and operational information (e.g. running jobs, messages, etc).  For the current step in this process only the empty database needs to be created, similar to the new Repository database, in section 4.2.  
Before the AMT runtime can use the new System database, the reorganization step is called to create all needed database objects (e.g. tables, indexes, etc).  
It’s good practice to have a Windows account with system administrator rights that is solely used by AMT (e.g. AMT_Admin). This account can be used to run the processes and access the database.  For this training, the Windows AMT_Admin user account is already configured on the VM.


Exercise 6: Configure AMT system database

Number
6
Learning objective
How to configure the AMT System database
Duration
15 minutes
Dependency
Exercise 5: Install latest AMT release


Start SQL Server Management Studio.  Select SQL Server Authentication, and login with the login/password credentials: asy/asy
Create an empty database named: AMT_SYSTEM  
While creating the new database, look under Options and check the ‘Collation’, this needs to be set to ‘Latin1_General_BIN’
Map the Windows user AMT_Admin as db-owner

Additional information is provided in the online help manual.

Home > AMT Admin > Installation and Configuration > Installation of the Control Center > Creating the System Database



Setup the Windows environment variable
All AMT runtime components communicate with the System database.  The connection information is stored in the ‘Sys.ini’ file.  To be able to find this file, a Windows environment variable ‘AMTSYSTEM’ is needed, containing the path to this ‘Sys.ini’ file. 
In a situation where more than one AMT runtime environment is installed, the ‘AMTSYSTEM’ variable contains all the paths to all the ‘Sys.ini’ files, separated with a semi-colon (e.g. c:\amt_dev; c:\amt_tst, etc). 
The default behavior of all AMT runtime components is that the executing AMT component searches for the ‘Sys.ini’ from the current directory up.  For example, if the BatchController is executing from the folder ‘C:\AMT\AmtTools\BatchController’, it starts searching in the same folder ‘C:\AMT\AmtTools\BatchController’, followed by ‘C:\AMT\AmtTools’, followed by ‘C:\AMT’. 
A detailed example for creating the required Windows environment variable is located in the online help system.


Home > AMT Admin > Installation and Configuration > Installation of the Control Center > Setting the Environment Variable

Exercise 7: Set AMTSYSTEM variable

Number
7
Learning objective
Create the AMTSYSTEM environment variable
Duration
5 minutes
Dependency
Exercise 6: Configure AMT system database

Follow the instructions in the online help manual to create the environment variable ‘AMTSYSTEM’.


Home > AMT Admin > Installation and Configuration > Installation of the Control Center > Setting the Environment Variable


Configure Sys.ini
The ‘Sys.ini’ is used by all AMT components to find the connection information to connect to the System database. 
A sample file named ‘Sample_Sys.ini’ is included in the ‘LION’ sub-directory (e.g. c:\amt\lion) and must be copied to the root AMT folder (usually c:\amt) and renamed as ‘Sys.ini’.
Figure 61: Sample_Sys.ini

Once the sample file is copied and renamed, the Sys.ini file can be edited using a simple text-editor like Notepad.  The entries for the username and the password will be encrypted after the first use (i.e. after the reorganization of the System database).




Exercise 8: Configure SYS.INI

Number
8
Learning objective
How to configure the SYS.INI
Duration
10 minutes
Dependency
Exercise 7: Set AMTSYSTEM variable


Copy the ‘Sample_Sys.ini’ file from the LION folder to the root AMT folder and rename it to ‘Sys.ini’
Open the copied ‘Sys.ini’ file with notepad
Use the instructions in the online help manual (link below) to assist in configuring the Sys.ini (include an entry for ‘INTEGRATEDSECURITY’ and make sure its set to ‘True’)
Review the online documentation for all elements that can be included


Home > AMT Admin > Installation and Configuration > Installation of the Control Center > Configuring Sys.ini


Reorganize System database
The Reorganize process uses the Sys.ini file to connect to the database.  This process creates the required objects in the System database and is a good test of your system’s configuration file.   
This step may only be completed once the empty System database is created, the AMTSYSTEM environment variable is set, and the Sys.ini file is created and properly configured.


When Integrated Security is configured as ‘True’ in the Sys.ini, the user that runs the reorganization must have sufficient SQL permissions to perform this action.  This can be achieved by connecting via the Reorganize Service if the user cannot connect themselves.



Exercise 9: Reorganize AMT System database

Number
9
Learning objective
Run the reorganization on the System Database
Duration
10 minutes
Dependency
Exercise 8: Configure SYS.INI
Follow the instructions in the online help manual to run the reorganization on the System Database 

Home > AMT Admin > Installation and Configuration > Installation of the Control Center > Reorganizing the System Database




When Integrated Security is being used, AmtReorganize.exe must be started under the user AMT_Admin. 
Shift – Right-Click on the file and choose “Run as different user” from the menu that appears.


Figure 62: Run AMTReorganize.EXE as different user

 
Adding websites to IIS
The AMT Control Center is a website that uses IIS to run. This is the only website needed to finish the configuration of the runtime environment. 
The AMT Control Center web site is already set up in section 4.4.  A few settings in IIS need to be checked and possibly adjusted. 
IIS Authentication for Virtual Directories ControlCenter and ControlCenterBL
The identity of all application pools needs to be set to AMT_Admin.  Since this training’s Sys.ini is configured to use Integrated Security, the application pools must run under the same user account that accesses the System database 
By default, the website is configured to use Windows authentication (i.e. the Windows credentials of the user that is used to logon to the AMT Control Center). The first user that logs on to the Control Center is granted administrative rights.


Figure 63: Control Center first logon


Exercise 10: Configure IIS

Number
10
Learning objective
How to configure IIS and logon to the AMT Control Center
Duration
20 minutes
Dependency
Error! Reference source not found.
Use IIS manager to create a new application called AMT which points to the AMT root directory
Within the new AMT application, create the ControlCenter and ControlCenterBL websites
Create a new application pool
Check the authentication settings for ControlCenter and ControlCenterBL
Change the application pool identity to AMT_Admin
Use notepad to check the content of the endpoints in the web.config of the AMT Control Center; this file is usually located in a directory like ‘C:\Amt\AmtTools\ControlCenter’.  The endpoints should start with: ‘http://localhost/amt/ControlCenterBL’
Navigate to: http://localhost/amt/controlcenter


Home > AMT Admin > Installation and Configuration > Installation of the Control Center > Adding the necessary Websites to the IIS

Basic Control Center settings
This section explains the basic settings needed for an AMT runtime environment to function. These settings are application independent. 
On first use of the AMT Control Center using Windows Authentication, the Control Center will automatically add a user using the Windows username of the user of the Control Center and then directly advance to the Environment System Settings dialog.  Users of earlier versions, or those using Forms Authentication, will need to enter a username and password.
In either case, once a user has access to the Control Center, User Security should be reviewed in the section ‘Security > Users’ before completing other tasks as many things in the Control Center require the user to be in the Administrative Role.  
Review the online help system for further details.

Home > AMT Admin > Installation and Configuration > Installation of the Control Center > First Use of the Control Center


Base setup
After user login and reviewing of roles, the first setting that needs to be completed, is the ‘Base setup’.  These are the high-level environment settings and impact all further settings.  It’s important that these settings are well thought out.

Figure 71: Control Center Base setup

Environment
This is the name that will appear in the header of the AMT Control Center.  It’s good practice to have different names for development, test and production (e.g. AMT_DEV, AMT_TEST and AMT). 

To reduce the risk of accidently working on the wrong environment, the theme can also be changed. See Home > AMT Admin > Installation and Configuration > Advanced Installation Topics > Customizing the Framework Logo's

System basepath
This is the path as defined in the Sys.ini file.

System logpath
This path will be used by AMT services like FileController, BatchController and the PrintController.  Common practice is to set this to the 'SystemLogging folder in the root path (e.g. ‘C:\AMT\SystemLogging’)
The Windows account used to run the AMT services requires Write permissions to this folder. 

Allowed application kinds
The AMT Control Center is used for different types of runtime environments.  For this training’s installation ‘LION A-Series’ needs to be set. 

Station resolve (can be set to):
Automatic: The station name is derived from the workstation name (e.g. ‘NB600’). When more sessions are opened, a sequence number will be added (e.g. ‘NB600/1’). For auditing purposes, this is the preferred setting. Transactions can be related to a physical station.
User: The station name is the user code of the logged-on user (e.g. ‘MDENOUTER’). 
Predefined: The station name can be set in the AMT Control Center per user.
IpAddress: The IP address of the workstation is used. When a proxy server is used, all connections might use the same IP address. In that case the maximum sessions will be exhausted quickly.
Local server time zone
This is the time zone of the server where the AMT Control Center is running.  Although, in theory, AMT servers in a distributed environment can be installed in different time zones, the servers must all be set to the same time zone.

System time zone
In some situations, the actual server might run in a different time zone as the end-users (e.g. the server is in Amsterdam and the users work from London).
In this example, the System time zone can be set to your local time zone. 
The AMT runtime environment will use the System time zone for scheduling and reporting. 

Max sessions per station
A user can open multiple sessions to the maximum. By default, this is 10, but this should be lowered to the number that is actually used. 

Add unknown users automatically
When set to true, any user that can access the AMT Control Center URL will be added as a user. From a security perspective, this might not be allowed or desired. 
New users get the default role. How this role is configured, is explained in the AMT Control Center Security Administration training.

Schedule calculation starttime 
The start of the time frame the AMT Batch Controllers use for job scheduling. Each day at this time a Batch Controller will look in the job schedules if any job requests should be created within the hours listed in the time frame period. This setting defaults to 18:00 for new environments, preferably this should be set at a time when the system has a low workload.

Schedule Timeframe period (hours) 
The period to use for the BatchControllers’ schedule in hours. This setting defaults to 24 for new environments.
Exercise 11: Configure Base Setup

Number
11
Learning objective
How to configure Base Setup
Duration
5 minutes
Dependency
Exercise 10: Configure IIS


Follow the instructions in the online help manual to configure the base setup with the following content:
Setting Name
Setting Value
Environment
AMT_TRAINING
System basepath
C:\AMT
System logpath
C:\AMT\SystemLogging
Allowed application kinds
LION A-Series
Station resolve
automatic
Local server time zone
leave unchanged
Max sessions per station
10
Add unknown users automatically
Checked
Schedule calculation starttime
18:00
Schedule timeframe period
24




Create default login account
Although AMT components can run with a Windows system account, it’s good practice to use a Windows account that is a member of the Administrators group. In this training the user AMT_Admin is used.  This user is already configured on the VM. 
To properly configure this user in AMT, this user must be added as the default login account for services.



Exercise 12: Configure AMT account

Number
12
Learning objective
How to configure an account in AMT
Duration
5 minutes
Dependency
Exercise 11: Configure Base Setup


Follow the instructions in the online help manual to add the AMT_Admin account. The password is ‘@sysco_1234’. The domain needs to be set to the machine name of the server (e.g. AMTADMIN01).

Home > AMT Admin > Installation and Configuration > Basic Runtime Environment Configuration > Creating an AMT Login account


Installing basic services
The basic services of an AMT environment consist of:
Server
Purpose
AMT File Controller
This service handles all file IO, and all AMT components communicate with this service for file actions
AMT Batch Controller
This service handles all jobs
AMT Print Controller
This service processes all print output created by AMT programs
AMT Reorganize Service
This is an optional service that can be used to perform a database reorganization under elevated user privileges
Table 71: AMT services
Naming the service is part of the installation process. The name can be anything you choose, but it’s good practice to start the name with ‘AMT_’ to make these services more recognizable in the Windows Task Manager.
The services can be installed through the AMT Control Center or manually using the Windows Command Prompt.

Home > AMT Admin > Installation and Configuration > Basic Runtime Environment Configuration > Installing the Basic Services

When a service is installed on another server, the AmtTools folder must also be copied to that server. The folder structure should not change.

AMT File Controller
The AMT File Controller handles all file IO for all AMT components.  The files need to be located in a locally accessible path (e.g. ‘C:\AMT\Files’, or a UNC path like ‘\\NB600\Files’). 
When files are located on a different server or SAN, a Windows mapping must be created utilizing a local drive letter. 
The files exist only on the server where the File Controller is installed. 

The configuration of an AMT File Controller consists of:
Setting
Description
Example/recommended setting
Display name
This is the name as will be displayed in the AMT Control Center.
AMT_FileController
Server name
This is the name of the Windows server where the service will be installed.
TRAININGLION1
Service name
The actual name of the service. This name displays in the Windows Task Manager.
Its good practice to keep the Display name and the Service name the same to avoid confusion.
AMT_FileController
Hostname (or IP Address)
The name of the server, or IP Address if known as this is more efficient
TRAININGLION1
Port
Port through which communications will take place, when combined with the Host/IP Address.
9090
Service account type
The service can be installed under a system account or a user account. It’s good practice to install the account under the local administrator account that has been created.
User
Account login
When ‘User’ is selected in the previous setting, the account name needs to be set here.
AMT_Admin
Base path
This is the folder name where the executable of the service is located.
C:\AMT\AmtTools\FileController
Log path
The service creates log files; this is the folder name for those logs. It’s good practice to use the same folder name as used in the Base Setup.
C:\AMT\SystemLogging
Spare controller
A distributed environment can be configured with a spare file controller. This controller takes over when the primary service fails. This only works when the spare controller can access the files on the same shared location.
Unchecked
Reset file security after move
Sets a file’s security to match the destination directory when moved.
Unchecked
Forced Timeout
To manage unused connections, a timeout can be set for inactivity. This timeout is for batch only.
10
Forms Forced Timeout
Open sessions not initiated from a Form, Script or Report close after the specified interval.
1
Batch Running Interval check
An interval the AMT File Controller checks to determine whether a job is still running. This time should be less than the Forced Timeout.
5
Run Inside BatchController

Specifies which AMT Batch Controller the AMT File Controller will run. The user can select one Batch Controller from the list of existing Batch Controllers.

No BatchController selected

Table 72: File controller settings


Exercise 13: Configure AMT FileController

Number
13
Learning objective
How to configure and install an AMT File Controller
Duration
10 minutes
Dependency
Exercise 12: Configure AMT account


Follow the instructions in the online help manual (link below) to configure and install the AMT File Controller.  Use the settings from Table 72.
Use the Windows Services manager to find the new service.
Open the properties
Re-enter the password in the logon tab
The first service that you configure with the AMT_Admin account will automatically elevate the AMT_Admin permissions.

Figure 72: Granted Log On As A Service
Start the File Controller using the Windows Services manager. 


Home > AMT Admin > Control Center > System Configuration > Services > File Services


AMT Batch Controller
At least one Batch Controller is needed to run jobs.  A Batch Controller can be installed on any server in a distributed environment. Database intensive jobs benefit from installing the service on the database server.  File intensive jobs benefit from installing the service on the server where the File Controller is installed.
Configuration options of the Batch Controller are as follows:
Setting
Description
Example/recommended setting
Display name
The name as displayed in the AMT Control Center. Anticipate the possibility that more than one Batch Controller may be installed and add a number at the end.
AMT_BatchController_1
Server name
This is the name of the Windows server where the service will be installed.
TRAININGLION1
Service name
The actual name of the service. This name will be seen in the Windows Task Manager.
It’s good practice to keep the Display name and Service name the same to avoid confusion.
AMT_BatchController_1
Service account type
The service can be installed under a system account or a user account. It’s good practice to install the account under the local administrator account.
User
Account login
When ‘User’ has been selected in previous setting, the account name needs to be set here.
AMT_Admin
Base path
The folder name where the executable of the service is located.
C:\AMT\AmtTools\BatchController
Log path
This service creates log files. This indicates the folder name where they are located. It’s good practice to use the same folder name as used in the Base Setup.
C:\AMT\SystemLogging
Polling interval
The Batch Controller checks the System database for new jobs, on an interval defined here. When the batch consists of many short jobs, the value should be set low.
1000 ms (1 second)
Critical error handling
When a critical error is encountered, (e.g. connection to the database is lost), the action set here will be executed. It’s recommended the set this to ‘Stop BatchController’. Second best option is ‘Halt BatchController’. In that case the Batch Controller can be continued after solving the error. ‘Continue, ignore critical error’ should only be used for test purposes; the result can be unpredictable. 
Halt
Table 73: Batch controller settings

Exercise 14: Configure AMT BatchController

Number
14
Learning objective
How to configure and install an AMT Batch Controller
Duration
10 minutes
Dependency
Exercise 13: Configure AMT FileController


Follow the instructions in the online help manual (link below) for an example of how to configure and install the Batch Controller.  Use the settings in
Setting
Description
Example/recommended setting
Display name
The name as displayed in the AMT Control Center. Anticipate the possibility that more than one Batch Controller may be installed and add a number at the end.
AMT_BatchController_1
Server name
This is the name of the Windows server where the service will be installed.
TRAININGLION1
Service name
The actual name of the service. This name will be seen in the Windows Task Manager.
It’s good practice to keep the Display name and Service name the same to avoid confusion.
AMT_BatchController_1
Service account type
The service can be installed under a system account or a user account. It’s good practice to install the account under the local administrator account.
User
Account login
When ‘User’ has been selected in previous setting, the account name needs to be set here.
AMT_Admin
Base path
The folder name where the executable of the service is located.
C:\AMT\AmtTools\BatchController
Log path
This service creates log files. This indicates the folder name where they are located. It’s good practice to use the same folder name as used in the Base Setup.
C:\AMT\SystemLogging
Polling interval
The Batch Controller checks the System database for new jobs, on an interval defined here. When the batch consists of many short jobs, the value should be set low.
1000 ms (1 second)
Critical error handling
When a critical error is encountered, (e.g. connection to the database is lost), the action set here will be executed. It’s recommended the set this to ‘Stop BatchController’. Second best option is ‘Halt BatchController’. In that case the Batch Controller can be continued after solving the error. ‘Continue, ignore critical error’ should only be used for test purposes; the result can be unpredictable. 
Halt
Table 73 in this document. 
Use the Windows Services manager to re-enter the password for this service (as described previously in step 2 of Exercise 13: Configure AMT FileController).
Do not start the service until directed.


Home > AMT Admin > Control Center > System Configuration > Services > Batch Services



AMT Batch controller Job Queues
The handling of jobs is controlled by job-queues.  A job runs in a queue.  A queue is serviced by a Batch Controller.  A queue can be serviced by a maximum of three Batch Controllers.  A Batch Controller can service many queues as indicated here. 


Figure 73: Serviced queues
When a Batch Controller doesn’t serve any queue, it will stop. 
From a performance perspective, more than one Batch Controller per server will not provide for much improvement. 
Job queues can be configured in the AMT Control Center to run simultaneously, run only inside the Batch Controller, run as a PowerShell script inside the Batch Controller, and more. For more information on job queues, visit the online help manual.
For this training, only one ‘Default’ queue needs to be configured.



Exercise 15: Configure default queue

Number
15
Learning objective
How to configure a default queue
Duration
10 minutes
Dependency

Exercise 14: Configure AMT BatchController


Follow the instructions in the online help manual (link below) to configure a default queue that is serviced by the Batch Controller just created.
Start the Batch Controller service.

Home > AMT Admin > Control Center > System Configuration > Batch and Forms > Job Queues

AMT Print Controller
When print output needs to be processed (e.g. sent to a physical printer or output management system), at least one Print Controller is required.  The Print Controller works independently from the Batch Controller.  The Batch Controller starts the job, the job creates the print file and the Print Controller processes the print file as soon as it is released.
The configuration of a Print Controller is as follows:
Setting
Description
Example/recommended setting
Display name
The name as displayed in the AMT Control Center. Anticipate the possibility that more than one Print Controller may be installed and add a number at the end.
AMT_PrintController_1
Server name
This is the name of the Windows server where the service will be installed.
TRAININGLION1
Service name
The actual name of the service. This name will be seen in the Windows Task Manager.
It’s good practice to keep the Display name and Service name the same to avoid confusion.
AMT_PrintController_1
Service account type
The service can be installed under a system account or a user account. It’s good practice to install the account under the local administrator account.
User
Account login
When ‘User’ has been selected in previous setting, the account name needs to be set here.
AMT_Admin
Base path
The folder name where the executable of the service is located.
C:\AMT\AmtTools\PrintController
Log path
This service creates log files. This indicates the folder name where they are located. It’s good practice to use the same folder name as used in the Base Setup.
C:\AMT\SystemLogging
PDF Print program
Only used for graphical prints. Migrated MF applications use character-based reports only.
Adobe
PDF print program path
When another PDF print program is selected, the path to the executable needs to be specified.
Empty
PDF print program parameter
Any parameters that needs to be passed to the PDF program.
Empty
Allow server to change printer settings
When checked the Print Controller is allowed to change printer settings using the Windows printer driver of the selected printer. This is needed for the print options Portrait, Page scaling and Duplex.
Unchecked
Remote
This checkbox needs to be checked when the Print Controller is installed on an extranet (the printers installed on that network are not known in the network where AMT runs). 
Unchecked
Station/Office name
Obsolete

Table 74: Print controller settings


Exercise 16: Configure AMT PrintController

Number
16
Learning objective
How to configure and install an AMT Print Controller
Duration
10 minutes
Dependency

Exercise 14: Configure AMT BatchController


Follow the instructions in the online help manual to configure and install the AMT Print Controller.  Use the settings from Table 74. 
Do not start the service until directed.

Home > AMT Admin > Control Center > System Configuration > Services > Print Services


AMT Print Controller Print Queues
Print requests are handled by queues.  A queue can contain multiple printers.  A Print Controller can service many queues as shown here.

Figure 74: Print queues

The Print Controller reads the print request from the System database and finds the print file.  The print file is sent to the printer using the queue’s settings.
When the Print Controller doesn’t serve any printer, it will stop.


Exercise 17: Configure print queue

Number
17
Learning objective
How to configure and install a print queue and printer
Duration
10 minutes
Dependency
Exercise 16: Configure AMT PrintController


Follow the instructions in the online help manual (link below) to configure a default print queue and a default printer.
Start the Print Controller service.

Home > AMT Admin > Control Center > System Configuration > Printers > PrintQueues
Remote Print Service
In instances where a printer is not directly accessible from the AMT Control Center server (e.g., the printer is on a different network or domain), it is possible to set up a Remote Print Service to access that printer.
The Remote Print Service installation makes use of an ASP.NET Core Web API to provide this remote functionality.
For security reasons, the Print Database Web API is not automatically installed with the rest of the AMT environment, making it necessary to install it manually.
If this Remote Print Service is required in your solution, please consult the online help docs for full step-by-step instructions.

AMT Reorganization service
The reorganization service (Reorganize service) is optional and only needed when Integrated Security is used, or if operators/developers don’t have direct access to the databases with the authority required to perform updates. 
With Integrated Security, the credentials of the user that starts the Reorganize tool are used to access the database; if this user doesn’t have sufficient permissions to perform the updates then the reorganization will fail. 
So, the Reorganize service is installed with a local admin account with privilege on the database server, to ensure that it can communicate with the databases and perform the updates. 
When starting the AMTReorganize tool the connection method should be set to Reorganize Service, which will then give the user the elevated privileges required. 
 
Security is explained in more detail in the AMT Security Administration training.
In this training, the Reorganize service is not used.


Home > AMT Admin > Control Center > System Configuration > Services > Reorganize Services


Basic Runtime configuration

Figure 75: Configuration structure

The configurations in this section are building blocks that can be used in the configuration of applications.  These configurations can be used by different applications, so it’s important to keep the settings application independent.  To facilitate this, there are a few variables that can be used as indicated in next table.
Variable
Value
Example
%SYSROOT%
Root path of the AMT installation
C:\AMT
%APPNAME%
Name of the application as defined in the application setup
CustomerManagement
%APPROOT%
The full path to the application folder
C:\AMT\Apps\CustomerManagement
Table 75: Basepath variables


Home > AMT Admin > Installation and Configuration > Basic Runtime Environment Configuration > Creating a basic runtime Configuration set

Base paths
The Basepaths configuration defines the directory structure that an AMT application can use.  There can be as many Basepaths configurations as needed.
It’s considered a good practice to have one base path named ‘Default’.

In other AMT training documentation, the term ‘Extracts’ is referenced. This is legacy terminology from the Unisys mainframe environment.  It’s just another way of describing input/output files.

When multiple applications are configured and the applications share files, do not put the application name in the extract path.

Figure 76: Basepath example

Setting
Description
Example/recommended setting
Listboxpath
When an application uses static listboxes in forms, these boxes are stored in this location.
Can be left empty if listboxes are not used.
Image path
When an application uses images, the images need to be stored in this location.
Can be left empty if images are not used.
Table 76: Basepath settings

Exercise 18: Configure Base Path

Number
18
Learning objective
How to configure a base path
Duration
10 minutes
Dependency
Exercise 11: Configure Base Setup


Follow the instructions in the online help manual to configure a default base path.  Use the settings from Figure 76: Basepath example.

Home > AMT Admin > Control Center > System Configuration > System Setup > Basepaths


Logging
It’s important to configure the logging according to the archiving policies of the company. When multiple environments (e.g. DEV, TST and PRD) are present, the logging might be configured differently for each. 
The next attributes should be set:
Logging level: This defines the level of detail. The higher the level, the more information stored.
Location: When the information is stored in files, the location can be set in the AMT Control Center. The location of these files can be easily shared with a support team for review.
Retention period: How long the log information is kept. Does this need to be instantly available or can this be available from a backup?
Medium: Information can be stored in a file or database.  
Audit: Security changes can be logged.

General logging settings
Optimal settings can differ per installation and are generally defined by the Services Consultant in cooperation with the System Administrator.
In the testing phase, it’s good practice to enable all logging.  Once in production these settings can be set to their final level.  Since logging can impact performance, it’s advised to set the logging to their production values when running performance tests.

Days to keep logging settings
As disk space must be allocated for log files it’s recommended to remove the oldest logs at a regular interval.  Company policies may dictate that log files are kept for a specific period of time.  If logs files need to be kept longer than the days set in the Control Center, the files should be archived to another location before they are removed by AMT.
Runtime information is also kept in the System database; the number of ‘messages’ can be huge.  Keeping ‘messages’ for a long period can impact the response times of the ‘Alert’ screen in the Control Center.  Since System ‘messages’ are also included in the job summary, batch and Batch Controller logs, it’s not recommended to keep these longer than 30 days (the default setting is 20 days).


Transaction logging setting
All online transactions can be stored in a separate database. These transactions can be replayed in the Control Center Processed > View Transactions.
To configure this option, a new database needs to be created in SQL server, configured in the Control Center System Configuration > Architecture > Databases and reorganized.  
The transaction log is a great help in analyzing online problems and enabling this option is recommended.  The impact on performance is negligible since transactions are written to the database in separate threads. 

General Logging Level
In ‘System Configuration > System Setup’ at tab ‘Runtime Behaviour Configurations’ select a configuration and then open tab ‘General behaviour’.  Here you will find the option ‘Logging level’ which will influence the level of detail in the log files.
Valid entries are from ‘0’ (default) to 9 (maximum) and differ per kind of logging, varying from high level functional calls, to detailed SQL syntax for data retrieval in business logic. 
Due to the increased output which will be produced, the use of the higher levels of logging are usually reserved for issue analysis, and generally only used by the Asysco R&D and Services teams.

Figure 77: General logging level
Exercise 19: Configure Default logging

Number
19
Learning objective
How to configure default logging
Duration
5 minutes
Dependency
Exercise 18: Configure Base Path


Follow the instructions in the online help manual to configure a default logging configuration.


Home > AMT Admin > Control Center > System Configuration > System Setup > Logging Configurations


Runtime behavior
The runtime behavior configuration is a collection of settings for multiple purposes. They are grouped in tab-sheets.  Included here are only the fields that need additional explanation.

General behavior
Setting
Remark
Call .NET assemblies internally
In AMT, external DLLs can be called.  Externally called DLLs are not controlled by AMT and can contain unstable code.  To protect the AMT process from crashing, AMT uses a proxy ‘CallDLL.exe’.  For reports, this can be switched off, and the external DLL called directly.
Logging level
The logging levels are 0 (no logging) – 5 (full logging).  Setting this to the maximum will result in very large log files.
Exception on array out of bounds
This is a setting to mimic the mainframe behavior.  The mainframe doesn’t crash when an element is accessed out of bounds.  When checked, the process will fail when this situation occurs. 
When not checked, reading an element out of bounds will return the last record read (i.e. the read buffer is not updated).
Table 77: General behavior

Form behavior
Setting
Remark
No comments (see online help manual if details are needed)
Table 78: Form behavior


Form appearance
Setting
Remark
Background color
To avoid accidental use of the wrong runtime environment (e.g. Development, Test, Production, etc.), the background color can be set differently for each environment.
Table 79: Form appearance

Web behavior
Only when an application is deployed to the web, are these settings relevant. 
Setting
Remark
Usage of keepalive
This setting only applies to the AMT Application Center and applications running within it.  A web session can time out after a period of inactivity (default 20 minutes).  AMT can keep the session alive by sending a ‘keepalive’ message just before the session times out; this results in a situation where the ASP session never times out.  See Section 8.4.5 regarding IIS configuration.
Table 710: Web behavior

Database behavior
Setting
Remark
Database replication
AMT can take care of the SQL database replication.  Please contact Asysco if this is desired.  In most instances, database replication is performed by the database engine.
Table 711: Database behavior

Maintenance
Setting
Remark
Automatic update
In a development or test environment these settings can be checked.  In a production environment, it’s recommended to have these settings disabled to load new objects in a controlled manner. 
Table 712: Maintenance
Exercise 20: Configure Default Runtime behaviour

Number
20
Learning objective
How to configure default runtime behaviour
Duration
10 minutes
Dependency
Exercise 19: Configure Default logging


Follow the instructions in the online help manual to configure a default runtime behaviour configuration.


Home > AMT Admin > Control Center > System Configuration > System Setup > Runtime behaviour configurations
Application setup
After completing the previous installation steps, the actual application can be configured.  An AMT environment can support multiple applications and this section can be repeated for every application.
The steps that must be executed are as follows:
Database setup
Configuration setup
Application setup


Database setup
Every application requires its own database.  Even when the application itself doesn’t use business tables (i.e. the application is completely file based).  AMT also creates a few system tables to control the application (e.g. AMTSYSSESSIONDATA, etc).
A detailed explanation of all settings are explained in the online help manual. 


Home > AMT Admin > Control Center > System Configuration > Architecture > Databases

General
The table below shows only the settings that need further explanation.
Setting
Remark
Kind of database
Internal
An application can connect to its own database.  This is configured as a ‘User database’ and displayed as ‘Internal’.  When this database needs to be accessed by other applications, an ‘alias’ can be defined.  Other applications do not need the credentials for this connection since the database access layer of the first application is used.  See Figure 81: Database connections.  For multiple applications to access the same database, the applications must all run on the same server.
External
When the applications cannot run on the same server, the connection can be configured as a ‘Remote database’.  This is displayed as ‘External’.  The credentials need to be configured here.  This can also be a non-AMT database.  How this database is accessed in the code, is explained in the AMT LION Advanced Developer Training.
Reorganize keep tables
The Reorganization updates the database structure against the database definition of the application.  When the database structure has been changed manually, these changes will be lost.  To prevent this, this checkbox should be checked when additional tables are added. 
Reorganize keep procedures
Check this box to keep stored procedures that are added to the database manually.
Reorganize keep views
Check this box to keep views that are added to the database manually.
Isolation level
For a migrated Unisys application, it’s important that this is set to ‘Read-Uncommitted’ (this mimics the DMSII behavior).
Table 81: Database General
This diagram shows an environment with multiple applications and multiple databases.



Figure 81: Database connections

Aliases
An Internal (User) database can be made available to other applications by specifying an alias. This alias can then be referred to by other AMT applications. 
Setting
Remark
Application
The name of the application can be used in Table queries in the other application.  For example, Application 2’s code can access ‘Table1’ from Application 1, as follows:
qTable1 : TableQuery (Application_1.Table1) 
Alias
The name of the alias can also be used in Free Join Queries.
For example: 
qQRY : Query
qQRY.database := ‘Alias_1’ 
qQRY.sql := ‘SELECT * FROM TABLE1’
New connection
When checked, a new connection to the database will be opened.  Otherwise, an existing connection from the connection pool will be used.  A new connection performs slightly slower but doesn’t affect the number of connections in the main application.
Table 82: Database Alias



FileGroup/TableSpace
Setting
Remark
These settings relate to Oracle definitions and are not discussed in this training.  Additional information for Oracle or DB2 based installations is available in the AMT Help Manuals.
Table 83: Database Filegroup/TableSpace



Exercise 21: Configure User database

Number
21
Learning objective
How to configure an Internal (User) database
Duration
10 minutes
Dependency
Exercise 20: Configure Default Runtime behaviour


Follow the instructions in the online help manual to configure a user database ‘AMT_CustomerManagement’.
Create an empty database in SQL Server with the name specified in the first step. The db_owner should be set to AMT_Admin.
Test the connection using the ‘Test connection’ button in the AMT Control Center.


Home > AMT Admin > Control Center > System Configuration > Architecture > Databases


Configuration setup
An application needs access to the runtime configurations (Base setup, Basepaths, etc.) created in section 0.  This is done by creating a ‘Configuration’ for the Application referring to them, in System Configuration > Architecture > Configurations (see example Figure 75: Configuration structure).
A Configuration can be used by multiple applications.


Figure 82: Application configuration


Exercise 22: Setup a Configuration

Number
22
Learning objective
How to setup a Configuration
Duration
5 minutes
Dependency
Exercise 21: Configure User database


Follow the guidelines in the online help manual to configure a default configuration using runtime configuration items setup in an earlier exercise.

Home > AMT Admin > Control Center > System Configuration > Architecture > Configurations


Application setup
After all previous steps are complete, an Application can be defined in the AMT Control Center. 
Besides the ‘New Application’ configuration in the Control Center, a generated application is needed; generating an application is part of the AMT LION Primary Developer Training.  For the purposes of this training, an example generated application is provided.
An AMT environment can host multiple applications.  This setup can be repeated for every application that needs to be configured.
The creation of an AMT LION application is done in two steps: 
Create the application using the screen in Figure 83: New application.
Click ‘Apply’, this will create an additional tab-sheet ‘Lion Properties’.


Figure 83: New application

Greater detail on creating application is provided in the online help manual.


Home > AMT Admin > Control Center > System Configuration > Architecture > Applications


Setting
Remark
Name
This name is used in several places. 
Part of folder structure as defined in the Base Paths
Name of the application in AMT Developer
Source and production folders as defined in the Generation Set in AMT Developer
It’s important to keep the name consistent. Names cannot contain spaces, and are not case-sensitive. 
Application kind
Depending on the AMT kind choice configured in the Base Setup, this can be selected from the drop-down list. Available kinds are:
COBOL
LION (this training)
VS

Table 84: Application Name
Properties
In this tab-sheet, the connection to an application’s services are established.  At this point in the setup process there are no application services created.
Before application services, or an application manager, can be created the Application must be configured.  This will be done in section 8.4.

Aliases
When more than one AMT LION application is configured on the same server, it’s possible to communicate between them at the business logic layer.  A form from Application 1 can call the same form from Application 2. It’s also possible to switch from one application to the other.


Exercise 23: Configure Application step #1

Number
23
Learning objective
How to configure an application step 1
Duration
10 minutes
Dependency
Exercise 22: Setup a Configuration


Follow the instructions in the online help manual to configure an application named ‘Customer_Management’. 
Use the database and configuration items, created in previous steps.
Set the applicable application kind to: AMT LION


Home > AMT Admin > Control Center > System Configuration > Architecture > Applications


Setup AMT LION Application services
For every application, at least one AMT Application Server is needed.  This is sufficient for development and testing.  In production, or production-like environments, this can be scaled up to a distributed configuration to include multiple Application Servers and an Application Manager.  For the Application Manager, a spare manager can be configured as well to improve resiliency. 


Figure 84: Example distributed application server setup
The above figure shows an example configuration.  The AMT Application Manager will distribute the online load over the available Application Servers 1 to 5.  If one of the Application Servers goes down, the spare Application Server takes over for the failing one.  If the Application Manager fails, or Server 1 goes down, the spare Application Manager on Server 2 takes over. 
For this training, we’ll create a configuration with one Manager and two Servers.

Application Manager

Figure 85: Application Manager setup

Setting
Remark
Port
AMT Application Managers and Servers use TCP ports to communicate.  These port numbers are free to choose but it’s good practice to use structured numbering (e.g. an Application Manager on port 6000, Application Servers starting at 6001 and so on). 
Since TCP ports are used by non-AMT programs as well, the System Administrator or a Network Administrator should determine a range of ports that can be used. 
The Windows command ‘netstat -abno’ can be used to get a list of active ports.
Active servers
Indicates the minimal number of AMT Application Servers that must be active.  When the number drops below this figure, the Manager will start a spare Application Server, if available.
Balance kind
Number of users
The Manager spreads the load based on the number of users. When users log off, and the difference between servers exceeds a threshold (set in ‘Minimum difference in user per server’), user sessions will be moved to balance the number of users.
This is the preferred setting when the servers are solely used for online AMT and no other non-AMT processes are running on these servers.
CPU load
The load is spread based on the CPU load of the physical machine that the Application Servers are running on.  When the difference between servers exceeds a threshold (set in ‘Minimum difference from average’), sessions will be moved to balance the number of users.
This is the most dynamic setting and should be used when the server is used for batch programs or other non-AMT processes. 
Round Robin
This is a static way of load-balancing. Users will be assigned to the next Application Server in sequence. Users will remain on the assigned Application Server.
This setting could result in one server utilized a lot while another is idling.  This setting should only be used when the Application Manager and Application Servers are all running on the same physical server. 
Table 85: Application Manager properties

Exercise 24: Configure Application Manager

Number
24
Learning objective
How to configure an application manager
Duration
10 minutes
Dependency

Exercise 23: Configure Application step #1


Follow the instructions in the online help manual to configure an Application Manager for the application ‘Customer_Management’.  Select ‘Round Robin’ for load balancing.


Home > AMT Admin > Control Center > System Configuration > Services > LION Managers


AMT Application server
An Application server is the server that links an end-user’s workstation to the application.  The workstation can be a station connected through Amt Screens or a web client using the NoFramework option (this option is described in a future training and more information can be found in the online help manual). 

Figure 86: Application Server setup

Setting
Remark
Startup Parameters
There are no startup parameters required.
Table 86: Application server properties


Exercise 25: Configure Application Server

Number
25
Learning objective
How to configure an AMT Application Server
Duration
10 minutes
Dependency

Exercise 24: Configure Application Manager


Use the instructions in the online help manual to configure two Application Servers for the application ‘Customer_Management’. 


Home > AMT Admin > Control Center > System Configuration > Services > LION Servers


Finalize Application setup
The steps started in section 8.3, can now be finalized in the tab-sheet ‘Lion Properties’. 
Servers
Setting
Remark
User application manager
When one AMT Application Manager is configured, this checkbox should be selected.  The rest of the servers should be left empty.
Use spare
When a spare AMT Application Manager is configured, this box should be checked.  If the main Application Manager fails, the connections will be routed through the spare.
Lion application server
When no AMT Application Manager is configured, or in cases where you want to connect to a specific Application Server, the Application Server must be selected from the drop-down list.
Spare application server
When a spare AMT Application Server is configured, the name can be selected from the drop-down list.  If the first Application Server fails, connections will be routed through the spare.
Default System Threads
Depending on the capacity of the Windows Server, the number of threads should be set.  The higher the processor power, the more threads that can be configured.  The optimal setting is best determined in performance tests. 
Max Form Worker Threads
The maximum number of allowed Online (Form) Worker Threads. Default is 12.
Min Form Worker Threads
The minimum number of active Online (Form) Worker Threads. Default is 3. Must be less than or equal to the Max Form Worker Threads.
Table 87: Application setup Servers

Help command
Setting
Remark
No comments
Table 88: Application setup Help command

RtQuery
These settings only apply when AMT Screens is used. 
Setting
Remark
Records to fetch for Table
The number of records should be set to a relatively low value to prevent long response times and large data transfer.
Records to fetch for Query
The number of records should be set to a relatively low value to prevent long response times and large data transfer. The settings as set in the runtime behaviour will limit the response time. 
Table 89: RtQuery properties



Figure 87: Example of RtQuery screen



Exercise 26: Configure AMT LION properties

Number
26
Learning objective
How to configure AMT LION properties of an application
Duration
10 minutes
Dependency
Exercise 25: Configure Application Server


Using the online help manual as an example, finalize the Application setup for application ‘Customer_Management’. Use the Application Manager to connect.


Home > AMT Admin > Control Center > System Configuration > Architecture > Applications


Configure app.ini
When AMT Screens is used, the information in the file ‘app.ini’ is used to connect to the correct Application Manager or Application Server. The ‘app.ini’ is located in the same folder as AmtScreens.exe and App.exe. 
On the server (for training this is your local machine) of the AMT installation open the Windows Explorer and navigate to the Binaries\ClientGUI directory of the generated application.  In that directory open the file ‘app.ini’ file with a text editor. 


Exercise 27: Configure APP.INI

Number
27
Learning objective
How to configure app.ini
Duration
10 minutes
Dependency
Exercise 26: Configure AMT LION properties


Follow the instructions in the online help manual to configure ‘app.ini’


Home > AMT Admin > Installation and Configuration > Using LionScreens > Configuring App.ini


Setup IIS for web enabled applications
When the application is web enabled, it also needs to be configured in Windows Internet Information Server.  Only the application’s Virtual Directory needs to be configured and must point to the AMT Client folder. 


Home > AMT Admin > Installation and Configuration > Using the Application Center Web Client > Adding the Application Website to the IIS

The web address (URL) must correspond with the URL set in the Application setup.  (See Figure 83: New application)


Security
Various user security options can be configured:

User Role
The user role should be granted access to the application in Security > Roles > Application Roles. 

Forms
Forms must be activated for them to be available to users in the Application, this can be found in Security > Forms. 

Terminal ID
Every user should have at least one terminal ID.  This ID will be used by the Transaction Server to manage the users’ sessions. 

Exercise 28: Configure Security

Number
28
Learning objective
How to setup security
Duration
10 minutes
Dependency
Exercise 27: Configure APP.INI


Follow the instructions in the online help manual set the security.


Home > AMT Admin > Control Center > Security > Users > Users

Reorganize application database
After the application and database are created and configured, the application’s database can be reorganized. 
This Reorganization will create necessary system tables and create the application table structure as is defined in the AMT Developer.  The file <Application name>.Database.dll in the folder %SysRoot%\Apps\<Application name>\binaries\Application is used for reorganization. 


Exercise 29: Reorganize application database

Number
29
Learning objective
Reorganize application database
Duration
10 minutes
Dependency

Exercise 23: Configure Application step #1


Follow the instructions in the online help manual to reorganize the application database of ‘Customer_Management’. Since Integrated Security is used, launch AMTReorganize.exe with the account AMT_Admin.


Home > AMT Admin > Maintenance > Reorganization > Standalone Program

Logging
Transaction logging setup
As mentioned in section 7.4.2, online transactions can be captured in a transaction database. This database can be used for multiple applications. This transaction logging is a great help in analysing online problems and can also be used as evidence that certain end-users entered specific data. 
Enabling the transaction log doesn’t impact on the online performance since these transactions are handled in a separate thread to the database. The retention period of the transactions can be configured in the runtime behaviour.
The steps to enable transaction logging are as follows:
Setup the database configuration in the AMT Control Center
Create an empty database in SQL Server
Enable transaction logging in the Runtime Behaviour section of System Setup
Run the AMT Reorganize application
The AMT Application Servers need to be restarted after the configuration is changed.

Setup database in the AMT Control Center
The next figure shows an example configuration for a transaction database.

Figure 91: Transaction database
Create an empty database in SQL Server
As with the other databases for AMT, only an empty database needs to be created in SQL Server. The Reorganization process creates the tables and indexes.


Figure 92: Creating an empty transaction database


Enable transaction logging
The use of the Transaction database needs to be enabled in the logging runtime behavior, System Configuration > System Setup > Logging configurations.
Transactions will be captured for all applications using this logging runtime configuration. 


Figure 93: Transaction logging configuration

Setting
Remark
Enable transaction logging
Only when transaction logging is enabled can the transaction database be reorganized. 
Transaction database
This is pre-filled when only one database is present. 
Days to keep transaction logging
This needs to be set to an acceptable value that is defined by the number of transactions per day and the available space. 
Enable library transaction logging
When external libraries are called by forms, these transactions can be logged separately. 
Table 91: Transaction logging configuration

Run AMT Reorganize
After the previous three steps are completed, the transactional database can be reorganized. When Integrated Security is configured, the Reorganization must be started with the correct user (e.g. AMT_Admin). 


Figure 94: Reorganize transaction database


Exercise 30: Configure Transaction database

Number
30
Learning objective
Configure Transaction database
Duration
20 minutes
Dependency
Exercise 19: Configure Default logging


Configure a Transaction database in the AMT Control Center
Create an empty database in SQL Server. The user AMT_Admin should be the db_owner
Enable transaction logging in the logging configuration
Reorganize the Transaction database


General logging
All AMT components can generate log information. The depth of information and the storage medium are configurable in the AMT Control Center. 
When AMT is installed, a default setting is already established. This can be modified to meet your company’s logging requirements.

Home > AMT Admin > Control Center > System Configuration > Logging

Logging media
The logging media settings defines where the information will be stored based on related severity.  It’s good practice to differentiate between normal day-to-day logging and error conditions.  Writing everything to all media can impact the overall performance and consume a lot of space. 
The main log media choices are ‘System Database’ and ‘Log File’ (only one of these should be activated).  

Home > AMT Admin > Control Center > System Configuration > Logging > Logging Media Severity


Figure 95: Configure logging
All available media options are as follows:
Medium
Remark
System Database
Information will be stored in the System database table AMTSYSLOGMESSAGE.  Information can be viewed in the AMT Control Center, Processed > Logging > Database log.
The advantage of logging to the System database is having all the logging in one single table for all AMT components. This table can be queried using normal SQL statements.
Depending on the number of messages generated, this table can grow quickly.  Entries are automatically removed as the retention period is reached. 
Log file
Information is stored in separate files in the location that is configured in the AMT Control Center at: System Setup > Base path > Services.
Files can be viewed at: Processed > Logging > Logfiles.
The advantage of having the logging in files, is that the files can be viewed with a simple text editor.  Care should be taken when opening the active log file since some editors lock the file which will prevent AMT writing to it; this can cause an exception when the file is locked too long. 
Log files can easily be shared with the support team to investigate problems.
Log files are automatically deleted when the retention period is reached. 
Trace file
A trace file is intended for storing detailed information when investigating a problem. Trace files can be (very) big. Tracing impacts an application’s performance.
Event log
Logging can be written to the Windows Event log. This can be useful when the Windows Event log is monitored by 3rd party monitoring tools. 
Output Debug String
In an AMT LION environment, this is not likely to be needed. Programs can be analyzed in debug mode with the AMT Debugger. 
Email
Information can be forwarded to an email address. This email address must be specified in the ‘Logging details’.
Table 92: Log media
Logging severities
Severity defines what information is logged. Severities range from high to low, and are defined as follows:
Severity Level 
Description 
Emergency 
An absolutely critical problem which stops the functioning of the AMT runtime environment (e.g. System database is offline); immediate action is required. 
Critical
A critical problem which stops or may stop the functioning of the AMT runtime environment.  Immediate action is required.
BugReport 
A crash occurred and an extensive bug report is created. 
Error 
An error occurred and an error message is recorded. This message can also be created programmatically in a script or program.
Warning 
A possible error or problem occurred and a warning message is created.  This message can also be created programmatically in a script or program.
Notice 
A short informational message is created. 
Information 
A more verbose informational message is created. This message can also be created programmatically in a script or program.
Debug 
Full debug information is recorded. 
Table 93: Log severities

Setting the logging level
For every component type in AMT, the logging can be set in the tab-sheet ‘Logging severity programs’.  Examples of severity level settings in the AMT Control Center can be found in the link to the online help manual.

Figure 96: Setting logging level

Home > AMT Admin > Control Center > System Configuration > Logging > Logging Severity Program

In this tab-sheet, the minimum level is selected. All messages with the selected level or higher, will be logged to the medium selected in the tab-sheet ‘Logging media severity’. 
Severity Level 
Description 
Batch business logic
Information generated in the batch programs of the application.
Batch controller
Information generated by the AMT Batch Controller (e.g. starting a job). It also captures the information when a job crashes.
Controller host

Com module

Communication server

Comscript module

Controlcenter businesslogic
Information generated by the Business Logic of the AMT Control Center. Normally, very little messaging is generated.
Framework
Information generated by the AMT framework.
Application manager

Online businesslogic
Information generated by the forms of an application.
Print controller

Reorganize

Speedloader
Obsolete.
File controller

Application server

Call Dll

Other

Table 94: Setting logging level

Logging details
When the logging medium is set to ‘email’ this setting is required. 

Home > AMT Admin > Control Center > System Configuration > Logging > Logging details

The trainer will demonstrate General Logging.


Retention period
The retention period for logging is set in the System Setup > Logging configurations.

Figure 97: Retention period for logging
When the retention period is reached, the AMT Batch Controller will remove old log files or log entries in the AMT System database. This information is permanently deleted. When this information needs to be preserved for a longer period, these files or information from the System database must be copied to another location. 

Home > AMT Admin > Control Center > System Configuration > System Setup > Logging Configurations
When transaction logging is used, the retention is set in the ‘Transaction logging settings’.


Audit configuration
Audit configuration offers a different kind of logging. It logs changes made in the security configuration of the AMT Control Center.  This information can be used by security personnel to audit these kind of changes. 
This is explained in more detail in the AMT Security Administration training.
Saving the Control Center configuration
Configuration Manager
To import or export AMT configuration parameters the AMT Configuration Manager is used.
All the settings of an AMT environment, which are retained in the System database, can be exported and imported via an XML file.
The AMT Configuration Manager program (AmtConfigurationManager.exe) is located in the AmtTools\ConfigurationManager folder of the AMT environment.
More information about the configuration manager can be found in the online help files.
Figure 101: Configuration Manager

Exercise 31: Export AMT Control Center configuration

Number
31
Learning objective
Export the AMT Control Center configuration
Duration
10 minutes
Dependency
Exercise 11: Configure Base Setup


Export the AMT Control Center configuration
Examine the content of the downloaded file
Further information is available in the online help manual (link below)

Home > AMT Admin > Control Center > System Configuration > Import / Export

Testing the application
After completing all the steps in previous sections, the application is now ready for testing. 

Exercise 32: Test AMT LION application

Number
32
Learning objective
Start application
Duration
10 minutes
Dependency
Exercise 30: Configure Transaction database


Start up all servers using the AMT Control Center
Navigate to the application’s folder (e.g. C:\AMT\Apps\CustomerManagement\Binaries\ClientGUI), find and launch the file App.exe. The AMT Lion Screens application will launch and the application’s menu screen should appear
Run the report ‘Fill_CM’.  This report will populate the application database with test data
Test the application by navigating through it
 


Appendix A: External Link Index
This appendix contains a list of some of the hyperlinks used through this training.  Links to external websites, not controlled by Asysco, are provided as a resource and accurate at the time of this training’s publication.
Website Name 
Location
Asysco Online Help Manual for AMT LION
https://help.myasysco.com/AMT%20Helpfiles%20for%20LION/
AMT Supported Software
http://releasenotes.asysco.com/supported-software/
AMT Release Notes
http://releasenotes.asysco.com/
Asysco Learning Center – License Installation Video
https://www.youtube.com/watch?v=n5FEq2Y2g6k&feature=youtu.be
Microsoft .NET Core 3.1x
https://dotnet.microsoft.com/download/dotnet-core/thank-you/runtime-3.1.3-windows-x64-installer
Microsoft .NET Core 3.1x SDK
https://dotnet.microsoft.com/download/dotnet-core/3.1
Microsoft VC_Redist x64
https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads


