
# Table of contents


1	Glossary of terms	4
2	Introduction	5
### 2.1	Migrate from AMT LION to C#/.NET	5
### 2.2	Audience	5
3	Management Summary	6
4	Asysco Migration Technology	7
5	AMT runtime environment	8
6	Application development and deployment	10
### 6.1	Infrastructure	10
#### 6.1.1	Developer workstation	10
#### 6.1.2	Development, Test and Production servers	11
### 6.2	Repository	11
### 6.3	Coding	12
### 6.4	Version control	14
### 6.5	Build & Deploy	15
### 6.6	Debug & Unit Testing	16
7	Application Runtime Environment	17
### 7.1	Online and end-user interface	17
### 7.2	Control Center	18
### 7.3	Batch processing	18
### 7.4	Printing	18
### 7.5	Performance	18
### 7.6	Interfaces	18
8	Migration project	19
### 8.1	Preparations	19
#### 8.1.1	Implement IIS for Application delivery	19
#### 8.1.2	Upgrade to latest AMT release	19
#### 8.1.3	Prepare baseline test	19
#### 8.1.4	Prepare Visual Studio development environment	19
#### 8.1.5	Prepare temporary runtime environment	19
#### 8.1.6	Education	19
### 8.2	Migration process	20
#### 8.2.1	Code migration	20
#### 8.2.2	Code delivery	20
#### 8.2.3	Testing	20
#### 8.2.4	Go live	21
### 8.3	Asysco support	21
#### 8.3.1	AMT Control Center	21
#### 8.3.2	Reorganization	22
9	Asysco support after migration	23
### 9.1	1st year	23
### 9.2	After 1st year	23

# Glossary of terms
# Introduction
## Migrate from AMT LION to C#/.NET
This document is intended to help making the decision to migrate a current AMT LION environment to C#/.NET. The application sources can be converted to C# or VB.NET. The AMT framework will always be delivered in C# sources. All aspects of such a migration will be explained in detail. The document will not categorize a difference as an advantage or disadvantage because this is highly dependent on the current situation and company’s strategy.

The document describes:
### 1.1 Differences
#### 1.1.1 AMT Runtime and infrastructure
#### 1.1.2 Application development and deployment
#### 1.1.3 Application runtime environment
### 1.2 Transition
#### 1.2.1 Preparations
#### 1.2.2 Migration
#### 1.2.3 Support
- 1.3 Support after migration
## Audience
This document is intended for:
- 2.1 IT managers
- 2.2 IT architects
- 2.3 Senior developers (AMT LION or C#)
The readers should be familiar with the current AMT environment and AMT components. When needed, an AMT General Introduction Training is available.

# Management Summary
Migration from AMT LION to C# can be considered for several reasons. Whether this migration is the best option for a company depends on the (long term) strategy.
This document provides guidance in making the right decision to migrate to C# or to keep using AMT LION.

Some important aspects in the IT strategy are:
- 2.4 Is the application still in development? When a lot of changes are made to the application, productivity of the development team is important.
- 2.5 Does the company want the freedom to choose their own development and administration toolsets?
- 2.6 Does the company want to consolidate the variety of programming languages and use existing C# developers more efficiently?
- 2.7 Is a complete development environment for Visual Studio already available?
- 2.8 Are the current AMT LION developers close to retirement?

To calculate the actual financial benefits of a migration to C#, the TCO for the next 5 years or to the end-of-life date should be defined.

Asysco can conduct a 2-day assessment to investigate the current situation and produce a customized project plan.

# Asysco Migration Technology
The Asysco Migration Technology has two ways to convert a mainframe runtime environment to an AMT runtime environment on Windows.
- 2.9 Migrate to AMT LION
- 2.10 Migrate to C#


Figure 4-1: Unisys LINC to AMT Conversion process
In above figure, the two migration methods are shown. As can be derived from this figure, migration to C# flows through migration to AMT Developer Studio. Conversion to C# is always possible. Even after working for many years in AMT Developer Studio. All functions supported in AMT LION are supported in C#. The differences will be explained in next sections.
# AMT runtime environment
Every AMT runtime environment is based on a distributed .NET architecture also known as AMT GO. The environment can be configured on a single or many servers depending on the required performance, resiliency and redundancy. Next table shows the AMT components that make an AMT environment. In an AMT C#/.NET environment, the runtime generated from the C# sources.

Table 5-1: AMT components
Above table already shows an important difference between the two types of environments. The AMT Application Server (and optionally the AMT Application Manager) is only used in an AMT LION environment. In C#/.NET, the application is solely delivered as a web application using Internet Information Service. This is optional for AMT LION configurations. Either the AMT Application Center can be used or the application can be deployed with ‘no-framework’.
All other components are identical and require no further migration.
Next two images show an example configuration with the differences.

Figure 5-1: AMT LION architecture

Figure 5-2: AMT GO Architecture
# Application development and deployment
The AMT Developer Studio IDE provides a quick and easy way to maintain application sources. This includes:
- 2.11 All sources are safely stored in a central database repository
- 2.12 Intuitive 4GL coding language
- 2.13 Version management including ‘generation sets’, compare and merge.
- 2.14 Quick generation into Development runtime for unit testing
- 2.15 Debugging
- 2.16 Deploy tool

The differences between AMT LION and development of C#/.NET in Microsoft Visual Studio of above aspects will be described in next sections.
## Infrastructure
### Developer workstation
Table 6-1: Developer Workstation differences
### Development, Test and Production servers
With the migration from AMT LION to C#/.NET, the development is moved from the Development server to the developer workstation. A development server is no longer required but since the C# sources have to be stored on a shared location, it’s probably required to have a ‘Build & Deploy’ server. Examples of both server types are shown in next figures.

Figure 6-1: Servers AMT LION


Figure 6-2: AMT C#/.NET servers
## Repository
The migration process to C#/.NET will deliver a set of C# solutions, projects and sources of the current applications. Also, the sources of all AMT framework components will be delivered. Excluding the Reorganization and Control Center client application which are licensed products.
These sources need to be stored in a secure place and backed up regularly.
## Coding
Successful maintenance of a migrated application depends on:
- 5.1 Knowledge of the business rules; It’s well known that this is the hardest to learn. Especially for very large applications and in case sufficient documentation is not available.
- 5.2 Knowledge of the programming language; Depending on the target programming language and previous experience of the developer this is relatively easy to learn. For a LINC developer, the 4GL language AMT LION in AMT Developer Studio is easier to learn than C# or VB.NET in Visual Studio. But for an experienced C# or VB.NET developer it’s probably easier to learn the AMT architecture in C#/.NET.
- 5.3 Knowledge of the runtime environment; The runtime environments of AMT LION and C#/.NET are both based on AMT GO and use the AMT Control Center for operations. But the runtime for development in C#/.NET is deployed on the workstation of the developer and has to be administered by the developer where an AMT LION runtime is deployed on a server and administered by a system administrator.

Table 6-2: Coding
The best results are achieved when AMT LION developers work together with experienced C#/.NET developers.

## Version control
New version control procedures will need to be adopted as part of the migration. AMT Dev Studio offers the possibility of creating multiple generation sets for PROD, DEV, TEST, etc. AMT Dev Studio provides security to control the access to these generation sets. Asysco can provide guidance to the best options, and the following table outlines some considerations for version control in AMT Dev Studio, versus that of the Microsoft Visual Studio.
Table 6-3: Version Control

## Build & Deploy
Release management within AMT Dev Studio can be done through the export and import of sources from separate repositories or can also be achieved through the use of generation sets within an AMT Dev Studio repository. Asysco can provide guidance to the best options for release management in these solutions. The following table outlines some considerations for release management in the AMT Dev Studio solution versus that of the Microsoft Visual Studio solution.

Table 6-4: Build & Deploy

## Debug & Unit Testing
The following table outlines some considerations for debugging and testing in the AMT Dev Studio solution versus that of the Microsoft Visual Studio solution.

Table 6-5: Debug and testing
In most AMT LION implementations, the developers share one development server that is used for debugging and testing.
# Application Runtime Environment
## Online and end-user interface
In a C#/.NET environment, the application can only be provided to the end-user though a browser interface. When, in the current environment AMTScreens (formerly known as LionScreens) is used, there are differences that are listed in next table. When the application is already delivered through a browser, there are no differences.

Table 7-1: Online and UI
## Control Center
Since all online transactions are handled by Internet Information Server (IIS) after migrating to C#/.NET, the Application Servers don’t need to be configured anymore in the Control Center. Also, inhibiting user access cannot be controlled anymore by bringing down the application server(s). Any functionality and procedures currently based on the Application servers needs to be moved to procedures based on IIS. E.g. PowerShell scripts to start/stop application pool(s) in IIS.
All other functionality in the Control Center remains the same.
## Batch processing
Batch processing doesn’t need any migration. All scripts (VB or PowerShell) and AMT reports will continue to run without change. An exception might be scripts that stop/start the online by stopping/starting the Application server. See previous section.
Also, any scheduling tools can remain as they are the AMT LION environment.
## Printing
No changes are needed in the Printer configuration or procedures.
## Performance
No performance increase/degradation is anticipated when migrating from AMT LION to C#/.NET.
## Interfaces
No changes in external interfaces is anticipated.
When more than one AMT LION application is migrated to C#, and an ‘application link’ or ‘switch to’ is used, all applications must be migrated at the same time.
# Migration project
## Preparations
### Implement IIS for Application delivery
When the AMT LION application is not completely delivered through IIS, it’s recommended to do this before the actual migration process. This limits the number of changes in the actual migration process.
### Upgrade to latest AMT release
The conversion of AMT LION code to C#/.NET is always done with the latest release of AMT. Before the actual migration process, the current AMT LION environment has to be upgraded to the latest AMT release. As with all release updates, this must include regular regression testing.
### Prepare baseline test
Although both AMT LION and C#/.NET are based on .NET technology and the runtime is almost the same, there’re also some differences. It’s recommended to include  tests on a selection of objects (online programs and/or reports) that contain these differences to assure that the functionality is converted correctly.
### Prepare Visual Studio development environment
Before the migrated code can be delivered, the new source management, Build & Deploy server and procedures need to be in place.
### Prepare temporary runtime environment
During the migration project, the normal support of the application should not be affected. It’s recommended to have a separate temporary development and runtime environment for release upgrade test and regression testing after the C#/.NET migration.
### Education
Developers
AMT LION developers need to be trained in Visual Studio, C# or VB.NET and should follow the AMT Primary Developer Training for C#/.NET.
System Administrators
Since there are little changes in the AMT runtime environment, it not needed to follow additional training. A short workshop will be sufficient to explain the differences.
End-users
When the application is already delivered through a browser, the end-user doesn’t need additional training. The end-user interface will be exactly the same.
When LionScreens is used, end-users should be familiar with the content of the ‘Application Center User Guide’. This is only needed when the Application Center is used to deliver the application to the end-users. When ‘No-Framework’ is used, it’s not required.
See also section 8.1.1.

## Migration process
### Code migration
Asysco will convert the AMT LION sources into C#/.NET code. The sources of the application(s) need to be provided in an AMT Developer Studio export of the complete application(s).
Although it’s very unlikely, it might be possible that some code constructions in AMT LION result in invalid C#/.NET code. In these cases, the AMT LION code needs to be corrected and the sources have to be converted again.
Only AMT LION code will be converted. Scripts in Visual Basic or PowerShell remain unchanged.
### Code delivery
The application is delivered as a set of Visual Studio Solutions, projects and sources. The source management and the Build & Deploy server have to be ready. See also section 8.1.4.
Next to the migrated application, also the sources of the AMT framework (excluding the Control Center and Reorganization) will be delivered.
The complete environment needs to be built and deployed to the (temporary) test server.

### Testing
This migration project should be tested in the same way as an AMT release update. Because the AMT Developer Studio will not be used anymore, it’s not needed to include this in the test plan.
In addition to the ‘normal’ AMT release update tests, the following tests should be included:
- 16.1 Objects that uses includable code.
- 16.2 Any procedures to enable/disable the application for the end-user
- 16.3 Mass user test to verify the performance of the infrastructure for online. I.e. IIS servers and load balancers.
### Go live
With the correct preparations and testing, the go-live is a small event in the AMT LION to C#/.NET migration and can even be done overnight.
## Asysco support
After go-live, no further release updates will be provided. The delivered AMT framework components come with a warranty of 1 year. It’s recommended not to make any changes to these AMT framework components the first year.
When other components in the environment of AMT C#/.NET are changed, e.g. Windows, .NET or SQL Server update, Asysco can be contacted for support.
The AMT Control Center and AMT Reo are still licensed products. These products can be replaced with other self-written, and/or third-party products if required.
### AMT Control Center

Figure 8-1: AMT Control Center
The Control Center is the user interface to interact with the AMT system database and to start/stop AMT services. This user interface can be replaced by a home-grown application to remove the dependency on Asysco.
### Reorganization
The AMT reorganization can be used to synchronize the structure of the runtime database with the definition in the C#/.NET sources. This guarantees that the database structure matches the code which eliminates any errors because of a mismatch.
The database changes can also be applied with regular SQL tools and scripts.

# Asysco support after migration
## 1st year
The first year after go-live, Asysco will solve any issues that are reported by the customer in the AMT framework components and libraries.
## After 1st year
The delivery includes the licensed products AMT Control Center, AMT Reorganization and AMT Report designer. Asysco will solve any issues in these products.
Issues in non-licensed components can be reported but will be fixed based on time-and-material.








