       IDENTIFICATION DIVISION. 
       PROGRAM-ID.  FUSION-LOA.  
       AUTHOR. BOURDEAUD HUY PIERRE.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNIVAC-1100-60. 
       OBJECT-COMPUTER. UNIVAC-1100-60. 
       SPECIAL-NAMES.     PRINTER   IS   LISTE. 
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT  TAPEIN1  ASSIGN  TO 
                    DISC  CLE.  
           SELECT  TAPEIN2  ASSIGN  TO 
                    DISC  UNL.  
           SELECT  TAPEOUT1  ASSIGN  TO   
                    DISC  LOA.
           SELECT  TAPEOUT2  ASSIGN  TO   
                    DISC  SUP.
       DATA DIVISION.   
       FILE SECTION.
       FD  TAPEIN1 
                    LABEL RECORD IS STANDARD
                   BLOCK CONTAINS 10 RECORDS   
                   RECORD CONTAINS 029 CHARACTERS   
                    DATA RECORD  IS REC-IN-1.  
       01  REC-IN-1.   
       FD  TAPEIN2 
                    LABEL RECORD IS STANDARD
                   BLOCK CONTAINS 10 RECORDS   
                   RECORD CONTAINS 296 CHARACTERS   
                    DATA RECORD  IS REC-IN-2.  
       01  REC-IN-2.   
       FD  TAPEOUT1 
                    LABEL RECORD IS STANDARD
                    BLOCK CONTAINS 10 RECORDS  
                    RECORD CONTAINS 296 CHARACTERS  
                    DATA RECORD IS REC-OUT-1.   
       01  REC-OUT-1           PIC X(296).  
       FD  TAPEOUT2 
                    LABEL RECORD IS STANDARD
                    BLOCK CONTAINS 10 RECORDS  
                    RECORD CONTAINS 296 CHARACTERS  
                    DATA RECORD IS REC-OUT-2.   
       01  REC-OUT-2           PIC X(296).  
       WORKING-STORAGE SECTION. 
       77  TAPE-1-CT                PIC 9(10)  COMP VALUE 0.   
       77  TAPE-2-CT                PIC 9(10)  COMP VALUE 0.   
       77  INPUT-CT           PIC 9(10)  COMP  VALUE 0. 
       77  TAPE-1-OUT-CT            PIC 9(10)  COMP  VALUE 0. 
       77  TAPE-2-OUT-CT            PIC 9(10)  COMP  VALUE 0. 
       77  OUTPUT-CT                PIC 9(10)  COMP  VALUE 0.   
       01  COMPARE-1.   
           03 COMPARE-FILE-1-FIELD-1
                 PIC X(10).
       01  COMPARE-2.   
           03  COMPARE-FILE-2-FIELD-1   PIC X(10).   
       01  DISPLAY-LINE   USAGE DISPLAY-1   VALUE SPACES.   
               03  DISP-MESSAGE        PIC X(24).   
               03  DISP-FNAME          PIC X(12).   
               03  DISP-CT             PIC Z(11)9.  
               03  FILLER              PIC X(84).   
       01  SWITCHES.
           03 SWITCHA PIC X.
           03  SWITCHB  PIC  X  VALUE 0.
       PROCEDURE DIVISION.  
       MERGE-2-FILES  SECTION.  
       OPEN-AND-FIRST-READ. 
           OPEN  INPUT  TAPEIN1. READ  TAPEIN1
             AT END  MOVE  HIGH-VALUE TO REC-IN-1. 
           MOVE  CORRESPONDING  REC-IN-1  TO  COMPARE-1.  
           ADD  1  TO  TAPE-1-CT.  
           OPEN  INPUT  TAPEIN2. READ  TAPEIN2
             AT END  MOVE  HIGH-VALUE TO REC-IN-2. 
           MOVE  CORRESPONDING  REC-IN-2  TO  COMPARE-2.  
           ADD  1  TO  TAPE-2-CT.  
           OPEN  OUTPUT  TAPEOUT1.
           OPEN  OUTPUT  TAPEOUT2.
           GO  TO  FUSION.  
       READ-FILE-1. 
           READ  TAPEIN1
                    AT END  MOVE  HIGH-VALUE  TO  REC-IN-1. 
           MOVE  CORRESPONDING  REC-IN-1   TO  COMPARE-1.   
           ADD 1 TO TAPE-1-CT.  
