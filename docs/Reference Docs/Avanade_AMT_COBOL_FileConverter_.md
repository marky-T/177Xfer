# Avanade_AMT_COBOL_FileConverter_

  AMT COBOL
FILECONVERTER
TRAINING MANUAL
Table of Contents

1    INTRODUCTION                                                   3

     1.1       Why do these f iles require special conversion?     4

     1.2       Recommended directory structure                     5

2    USING THE AMT COBOL FILECONVERTER TO CONVERT A SINGLE FILE     6

     2.1       Record Layouts                                      9

     2.1.1     Header Record Layout                                10

     2.1.2     Footer Record Layout                                11

     2.1.3     Detail Record Layout                                12

     2.1.3.1      The Def ault Layout                              13

     2.1.3.2      Filtered and Conditional Detail Layouts          14

     2.1.4     Filter ing Precedence                               15

     2.1.5     Cross-ref erencing detail layouts                   16

     2.2       Applying an Alternative Character set               18

     2.3       Converting the f ile                                20

     2.4       Viewing the Converted Records                       21

     2.5       Saving the Conversion Settings                      22


3    USING THE AMT COBOL FILECONVERTER TO CONVERT MULTIPLE FILES   25


4    AUTOMATING THE CONVERSION PROCESS                             29


5    RUNNING IN BATCH                                              30


6    RUNNING IN LINUX                                              31




                                                           2



     AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
1   INTRODUCTION

    The AMT COBOL FileConverter is an application designed to convert data f iles which
    have been created on a mainf rame, in EBCDIC f ormat, into ASCII f iles, whilst
    retaining the integrity of the data held within the f ile.


    No specif ic installation steps need to be taken. The latest version of the AMT COBOL
    FileConverter can be deployed wherever you wish – even to a non-AMT directory.




    The application itself is not a licensed product but should only be used during the
    migration project.




                                                          3



    AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
1.1   Why do these files require special conversion?

      It is common f or mainf rame f iles to contain numeric data in a compressed f ormat
      (ref erred to as Computational Data or COMP). If this COMP f ield is also signed, the
      sign is held, whether it be a positive or a negative sign, as an over -punch on the
      least signif icant digit. It is this over-punched sign that is not converted correctly in a
      standard f ile conversion (i.e. using FTP) where a non-binary transf er will
      automatically convert the f ile to ASCII f ormat.


      The Input f ile must be transf erred f rom the mainf rame in EBCDIC characters using
      the binary option f or the f tp, so that all of the hexadecimal characters remain the
      same.


      The AMT COBOL FileConverter is able to correctly convert the f iles using the record
      layout def ined f or the creation of the f ile on the mainf rame.


      However, the complexity increases when the same data area is used by multiple
      record layouts, all of which contain signed COMP f ields in dif f erent positions. In this
      instance, multiple layouts must be declared – one f or each dif f erent record def inition.




                                                            4



      AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
1.2   Recommended directory structure

      To organize the input, output and settings f iles that the f ile converter uses it is
      suggested that a simple f ile directory structure is implemented.


└à      Cobol File Conversion
        └à      Exe
                └à      ConvertCobolFiles.Exe
        └à      Input
                └à      Data_01
                └à      Data_02
        └à      Logs
                └à      Data_01.Log
                └à      Data_02.Log
        └à      Output
                └à      Data_01
                └à      Data_02
        └à      Converter Settings
                └à      Data_01_Settings.ini
                └à      Data_02_Settings.ini




      If several dif f erent sets of f iles are to be used f or input (perhaps f rom dif f erent
      testing phases or dif f erent overnight batches) it may be advisable to hold these f iles
      in separately named staging directories and then copy them into the Input directory
      when the conversion is to take place.




                                                            5



      AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
2   Using the AMT COBOL FileConverter to Convert a Single File
    Launch the application and the f ollowing screen is displayed:




    A number of parameters must be specif ied bef ore the conversion can take place.


    The f ollowing table explains what inf ormation is required.

     Parameter                           Description

     Input file                          The location of the f iles to be converted. Enter the f ull
                                         path or use the button to navigate to the correct
                                         location

     Output file                         The location of the converted f iles. Enter the f ull path
                                         or use the button to navigate to the correct location




                                                          6



    AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
 Record size                         The maximum length of each record. NB each f ile
                                     must be of f ixed length (i.e. spaces must not be
                                     trimmed on FTP f rom the mainf rame).

 Mainframe                           Specif y either Unisys or IBM

 Record Ending                       Choose:
                                     Def ault
                                     CRLF
                                     CR
                                     LF
                                     None

 Overpunch                           Choose:
                                     AMT
                                     COBOL ANSI
                                     Mainf rame (EBCDIC)
                                     Unix
                                     Custom

 Output signed                       Check the box if the converted f ile should contain the
 overpunch                           overpunch character f or signed f ields

 Output trailing                     Check the box if the converted f ile should contain a
 sign                                trailing sign f or signed f ields

 Convert COMP                        Check the box if COMP f ields are to be converted in
 values                              the converted f ile

 Don’t validate                      Check the box if COMP f ields are to not be validated
 COMP values                         during the conversion process

 IBM Rdw                             Indicates that the input f ile contains variable length
                                     records has been copied using the RDW option

 Invalid                             Choose the required option of these are to be
 computational                       converted
 values

 Convert value to                    Invalid values will be converted to zeros
 000000




                                                      7



AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
 Convert value to                    Invalid values will be converted to all 9’s
 999999

 Custom encoding                     Enter required encoding set
                                     e.g. Swedish = RQPONMLKJåäABCDEFGHI

 Header record                       Check the box if the input f ile contains a header
                                     record

 Detail records                      Check the box if the input f ile contains detail records

 Footer record                       Check the box if the input f ile contains a f ooter record

 Conditional detail                  Check the box if the input f ile contains multiple detail
 records                             records.
                                     Enter the number of additional record layouts
                                     contained in the f ile.
                                     Click the Apply button to create additional Detail
                                     sections in the lower panel




                                                      8



AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
2.1   Record Layouts

      Having set the options f or record layouts in the upper panel, the lower panel is used
      to def ine each layout.


      The def inition of each layout f or the f ile should be copied directly f rom the Cobol
      source code and pasted into to the appropriate f rame description area. The button
      “get rec size” is then pressed to establish the record length.


      The f ollowing sections explain how to conf igure the settings f or a f ile with a header,
      f ooter and detail records.




                                                            9



      AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
2.1.1   Header Record Layout

        To specif y a header record, check the “Header record” check box. This automatically
        creates a “Header” tab sheet in the lower panel.


        This tab sheet is used to specif y the header layout in the “Record f rame description”
        area.


        This layout will only be applied to the very f irst record in the f ile.


        The def inition of a header layout can be seen in the screen print below.




                                                              10



        AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
2.1.2   Footer Record Layout

        The f ooter details are specif ied in a similar way to the header record described
        earlier, but this time checking the “Footer record” check box and using the Footer tab
        sheet that is automatically created.


        This record layout will only be applied to the very last record in the f ile.


        The def inition of a f ooter layout can be seen in the screen print below.




                                                              11



        AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
2.1.3   Detail Record Layout

        A common f eature of the Cobol programs using disk f iles f or input is the re -mapping
        of the data area to enable multiple record layouts against the same f ile Id.


        To support the presence of dif f erent record layouts within the Detail record of the
        f ile, multiple Detail tabs can be created.


        This multi-layout approach enables decimal numeric f ields, declared as COMP, to be
        correctly translated, including the over-punched signs.




                                                              12



        AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
2.1.3.1     The Default Layout

          The f irst Detail layout that is created is treated as the def ault layout, and the
          ref ormatting related to this layout will take place if the record read does not conf orm
          to any of the f iltering employed on the subsequent Detail tabs (D01...Dnn).


          For this reason, no Filtering or Content options are available when def ining the
          Record Frame Description f or the Def ault Detail layout.




                                                                13



          AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
2.1.3.2     Filtered and Conditional Detail Layouts

          To f ilter the input f ile using the data contained within the record (e.g. Position 13,
          Length 2, Type = Numeric, where the value is 11) as shown here in Layout D01.




          A f ilter can also be applied on a row count basis. Select the Row Number option in
          the Filter drop down list. Rows that are to use the current layout can be selected by
          their row number in the f ile, (i.e. 17-22, 28-32, 44) as shown here in Layout D02.




          This will def ine which Detail Layout should be applied to those rows.


          A maximum of 99 dif f erent f iltered or conditional detail layouts can be specif ied f or a
          f ile.




                                                                14



          AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
2.1.4   Filtering Precedence

        It is possible that, f or a specif ic data row, more than one f iltering rule could be
        applicable. If that is the case, then it is important that the precedence rules of the
        conversion f iltering is understood so that the data row is updated correctly during the
        conversion.


        In order to ensure that the correct layout mask is applied to the data row, it is
        necessary to remember that the Detail Layout masks will be assessed in the
        f ollowing order:


        1) Record layouts def ined as Header or Footer f or the f irst and last record in the f ile.


        2) Data Row and Data Content f ilters, applied in order D01 to D99


        3) Def ault Data layout A new layout is only required when the over -punched sign of
        a signed computational numeric f ield occurs in a dif f erent character position to the
        layouts already def ined.




                                                              15



        AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
2.1.5   Cross-ref erencing detail layouts

        To simplif y the task of comparing the various Detail layouts, the character start
        position of each data item in the Record Frame Description can be displayed.


        To display the character positions f or each data item within each of the Detail layouts
        press the “Show Pos” button in the button bar on the lef t-hand side.


        The start character position of each active data item is placed in the right-hand
        margin, and at the end of the layout def inition the f ull record size will be shown. This
        also enables the record size of each layout to be compared to ensure equality
        throughout each of the Detail layouts




        If the maximum record size of all the layouts def ined f or this f ile is required, then
        you can press the “Get RecSize” button in the button bar on the lef t-hand side. This
        will update the Record size value shown in the f ield next to the button.




                                                              16



        AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
                                                      17



AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
2.2   Applying an Alternative Character set

      The application uses a standard EBCDIC to ASCII conversion table, but it is
      occasionally necessary to apply an alternative character set to the f iles that are being
      converted when they contain characters which are not f ound on the standard US
      keyboard.


      The standard table can be viewed using the EBCDIC – ASCII Conversion Table tab in
      the lower panel.




      An alternate character set can be used by selecting the Load button and navigating
      to the required conversion table. A Swedish character set could be used which will
      ensure that characters such as ä, å, ë and ö are shown and converted correctly when
      f ound in the text.




                                                            18



      AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
                                                      19



AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
2.3   Converting the file

      Once a layout has been specif ied that covers each dif f erent permutation of signed
      computational f ields, then the f ile can be converted f rom its original EBCDIC f ormat
      into the required Ascii f ormat.


      Ensure that the input and output f ile names are correctly entered in their appropriate
      f ields (don’t have the same name f or both f iles !) and then press the “Convert”
      button in the button bar.


      Note: It is important to note that the conversion process will not ask if you wish to
      overwrite a f ile if it already exists. Theref ore, if an inappropriate f ile name is put in
      the Output File name f ield then it will be lost!!




      The f ile will be processed one record at a time. Status messages and any errors f rom
      conversion will be displayed in the Log panel.


      Interrogate any messages that are displayed to determine whether the f iltering is
      being applied incorrectly, or whether a new f ilter is required. The row number of the
      record in error is displayed in the message.




                                                            20



      AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
2.4   Viewing the Converted Records

      Following conversion of the f ile f rom EBCDIC to ASCII it is important to verif y that
      each record (or a good cross-section of them !) has been correctly converted.


      Open the converted f ile using a text editor such as NotePad++. Review the records
      and ensure that they are f ormatted correctly.


      If the data cannot be displayed correctly through it’s intended layout then the
      f iltering rules or layout def initions will need to be amended, and the f ile re -
      converted.




                                                            21



      AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
2.5   Saving the Conversion Settings

      Once you have successf ully converted the f ile to ASCII f ormat, the job is complete
      and the f ile is ready f or use with AMT.


      In order to reuse these conversion settings, press the “Save Settings” button on the
      main f orm.


      A good tip is to use a consistent f ile name f ormat – f or instance, append the phrase
      ”_Settings.ini” to the f ile name, and then the automatic batch creation process (see
      below) will have no trouble constructing a batch f ile.




      If an alternate EBCDIC to ASCII translation table has been used (see image below),
      this should be saved to the settings f ile by using the Save button on the “EBCDIC –
      ASCII Conversion Table” tab.


      Note – the translation settings cannot be saved in the conversion settings f ile.




                                                            22



      AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
If you need to load the settings f rom a previous conversion, then simply start the
program and load the settings f ile previously saved, by clicking the “Load Settings”
button and selecting the appropriate f ile.




                                                      23



AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
                                                      24



AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
3   Using the AMT COBOL FileConverter to Convert Multiple Files
    Launch the application and click the ‘Multiple File converter’ tab:




    A number of parameters must be specif ied bef ore the conversion can take place.


    The f ollowing table explains what inf ormation is required.

     Parameter                           Description

     Input file                          The location of the f iles to be converted. Enter the f ull
                                         path or use the button to navigate to the correct
                                         location




                                                          25



    AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
         Output file                        The location of the converted f iles. Enter the f ull path
                                            or use the button to navigate to the correct location

         File Control Table                 Point to the f ile contral table xml f ile

         Mainframe                          Specif y either Unisys or IBM

         Line Separator                     Choose:
                                            CRLF
                                            CR
                                            LF

         Convert for AMT                    Select if f ile is f or an AMT JAVA application
         Java

         Logging verbose                    Quiet
         level
                                            Minimal

                                            Normal

                                            Detailed

                                            Diagnostic




See below f or a sample settings f ile and f ile control table f ile.




                                                             26



       AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
Note: For f iles converted this way used in an AMT Java runtime, the f ollowing setting must
be added to the application yaml f ile:
storeCompInASCII: true
A restart of the application is required after making this change.




       Settingsfile.xml example:

       <MULTIPLEFILECONVERTERSETTINGS>
        <INPUTFOLDER>C:\Temp\Binary</INPUTFOLDER>
        <OUTPUTFOLDER>C:\Temp\Convert</OUTPUTFOLDER>
        <FILECONTROLTABLE>C:\Temp\FileControlTable.xml</FILECONTROLTABLE>
        <THREADS>2</THREADS>
        <LOGGING>C:\Temp\fc.log</LOGGING>
        <LINESEPARATOR>CrLf</LINESEPARATOR>
        <MAINFRAME>IBM</MAINFRAME>
       </MULTIPLEFILECONVERTERSETTINGS>


       Within the settings file, you may specify a FileControlTable xml file that can include multiple files
       to be converted. See below for examples.




                                                             27



       AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
FileControlTable.xml example:



<FileControlTable>
  <File PhysicalName="FILE_A" OutputType="LineSequential"
RecordLength="390"/>
  <File PhysicalName="FILE_B" OutputType="Sequential"
RecordLength="259"/>
  <File PhysicalName="FILE_C" OutputType="Sqlite" RecordLength="150"
KeyPosition="0" KeyLength="30"/>
  <File PhysicalName="VSAM\FILE_VSAM1" OutputType="Sqlite"
RecordLength="431" KeyPosition="5" KeyLength="23"/>
  <!-- LogicalName, Description, MinRecordLength, Concurrency,
AddRequests, BrowseRequests, DeleteRequests, ReadRequests and
UpdateRequests are optional. Can be used to load VSAM info into system
database-->
  <File PhysicalName="VSAM\FILE_VSAM2" LogicalName="FILE_VSAM"
Description="My Vsam File" OutputType="Sqlite" RecordLength="431"
KeyPosition="0" KeyLength="30" MinRecordLength="19" Concurrency="0"
AddRequests="true" BrowseRequests="true" DeleteRequests="true"
ReadRequests="true" UpdateRequests="true" />
</FileControlTable>




                                                      28



AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
4   Automating the Conversion Process
    Once you have the settings f iles prepared, and have tested every f ile, you can
    automate the conversion of the suite of f iles f or GO-LIVE.




                                                          29



    AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
5       Running in Batch


The AMT COBOL f ile converter can be run in batch mode either f rom a Windows command
prompt or in a batch f ile. The converter should be started with the f ollowing parameter(s):

/INI:
/LOG:
/AUTO
/TRANS:
/NOGUI:
e.g.
FlatFileConvertor.exe /INI:D:\SPV\Convert_COBOL_Files\Settings\CN38.ini
/LOG:D:\SPV\Convert_COBOL_Files\Log\Run1.log /AUTO /NOGUI
/TRANS:D:\SPV\Convert_COBOL_Files\Settings\ebcdic_278_SPV.bin




        The converter will open, load the settings and process the required f ile bef ore closing
        again.


        NOTE:


    •   The “/TRANS” option is optional
    •   The “/NOGUI” option is optional
    •   Starting without the “/AUTO” will load the ini f ile and translation table but will not
        start the data conversion; it will merely show the GUI with the parameters and f ile
        pref illed.
        Starting without the “/AUTO” will load the ini f ile and translation table but will not
        start the data conversion; it will merely show the GUI with the parameters and f ile
        pref illed.




                                                              30



        AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
6   Running in Linux

    The AMT COBOL f ile converter can be run in batch mode f rom a Linux machine using
    the below command:

    dotnet FlatFileConverterConsole.dll xml:/path/to/settingsfile.xml log:/path/to/log/destination




                                                          31



    AMT COBOL FileConverter | © Avanade 2025| 05-Aug-24
