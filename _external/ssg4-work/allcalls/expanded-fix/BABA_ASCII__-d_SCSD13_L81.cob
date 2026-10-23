       IDENTIFICATION DIVISION. 
       PROGRAM-ID. EXTRACT-INA.   
       AUTHOR. BOURDEAUD HUY PIERRE.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNIVAC-1100-60EIS.  
       OBJECT-COMPUTER. UNIVAC-1100-60EIS.  
       SPECIAL-NAMES.     PRINTER   IS   LISTE. 
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT  TAPEIN1  ASSIGN  TO 
                    DISC  INA.  
           SELECT  TAPEOUT1  ASSIGN  TO   
                    DISC  OUTA.
           SELECT  TAPEOUT2  ASSIGN  TO   
                    DISC  OUTB.
       DATA DIVISION.   
       FILE SECTION.
       FD  TAPEIN1 
                    LABEL RECORD IS STANDARD
                   BLOCK CONTAINS 10 RECORDS   
                   RECORD CONTAINS 358 CHARACTERS   
                    DATA RECORD  IS REC-IN-1.  
       01  REC-IN-1.   
           03  FILLER                   PIC  X(3). 
           03  COMPARE-FILE-1-FIELD-2   PIC  X(5).   
           03  FILLER                   PIC  X(350). 
       FD  TAPEOUT1 
                    LABEL RECORD IS STANDARD
                    BLOCK CONTAINS 10 RECORDS  
                    RECORD CONTAINS 300 CHARACTERS  
                    DATA RECORD IS REC-OUT-1.   
       01  REC-OUT-1           PIC X(300).  
       FD  TAPEOUT2 
                    LABEL RECORD IS STANDARD
                    BLOCK CONTAINS 10 RECORDS  
                    RECORD CONTAINS 358 CHARACTERS  
                    DATA RECORD IS REC-OUT-2.   
       01  REC-OUT-2           PIC X(358).  
       WORKING-STORAGE SECTION. 
       77  TAPE-1-CT                PIC 9(10)  COMP VALUE 0.   
       77  INPUT-CT                 PIC 9(10)  COMP  VALUE 0.   
       77  TAPE-1-OUT-CT            PIC 9(10)  COMP  VALUE 0. 
       77  TAPE-2-OUT-CT            PIC 9(10)  COMP  VALUE 0. 
       77  OUTPUT-CT                PIC 9(10)  COMP  VALUE 0.   
       77  ELIMINATE-CT                 PIC 9(10)  COMP VALUE 0.
       01  REQUIREMENTS-1. 
           03  REQ-ALT-1-FLD-2          PIC X(5)   
               VALUE  '00124'.   
       01  COMPARE-1.   
           03  COMPARE-FILE-1-FIELD-2   PIC X(5).   
       01  DISPLAY-LINE                          USAGE  DISPLAY-1.  
               03  DISP-MESSAGE        PIC X(24).   
               03  DISP-FNAME          PIC X(12).   
               03  DISP-CT             PIC Z(11)9.  
               03  FILLER              PIC X(84)  VALUE SPACE.  
       01  CTR PIC 9(18) COMP.  
       PROCEDURE DIVISION.  
       E-F-INA SECTION.   
       DEBUT.   
            OPEN OUTPUT TAPEOUT1. 
            OPEN OUTPUT TAPEOUT2. 
       OPEN-AND-FIRST-READ. 
           OPEN  INPUT  TAPEIN1. READ  TAPEIN1
             AT END  MOVE  HIGH-VALUE TO REC-IN-1  
             GO TO ENDING-ROUTINES. 
           ADD 1 TO CTR.
           MOVE  CORRESPONDING  REC-IN-1  TO  COMPARE-1.  
           ADD  1  TO  TAPE-1-CT.  
           GO TO  SEPARATION.   
       READ-FILE-1. 
           READ  TAPEIN1
           AT END GO TO ENDING-ROUTINES.
           ADD 1 TO CTR.
           IF   
           CTR 
           < 
           99999999 
           GO TO ECLATEMENT 
           ELSE GO TO ENDING-ROUTINES.  
       ECLATEMENT.  
           MOVE  CORRESPONDING  REC-IN-1   TO  COMPARE-1.   
           ADD 1 TO TAPE-1-CT.  
           GO  TO  REQUIREMENTS-TEST.   
       WRITE-1-FROM-FILE-1.   
           WRITE  REC-OUT-1  FROM  REC-IN-1.  
           ADD  1  TO  TAPE-1-OUT-CT. 
           GO  TO  READ-FILE-1. 
       WRITE-2-FROM-FILE-1.   
           WRITE  REC-OUT-2  FROM  REC-IN-1.  
           ADD  1  TO  TAPE-2-OUT-CT. 
           GO  TO  READ-FILE-1. 
       SEPARATION SECTION.  
       REQUIREMENTS-TEST.   
           INSPECT REQUIREMENTS-1 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-1 NEXT SENTENCE ELSE   
                              GO TO TOTOK.  
           GO TO ALFRED.
       TOTOK.   
           GO TO WRITE-1-FROM-FILE-1.   
       ALFRED.  
            GO TO WRITE-2-FROM-FILE-1.  
       ENDING-ROUTINES SECTION. 
       PRINT-FILE-CTS.  
           MOVE  '     RECORDS  READ FROM '  TO  DISP-MESSAGE.  
           MOVE  'INA'  TO  DISP-FNAME. 
           MOVE  TAPE-1-CT  TO  DISP-CT.   
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           ADD  TAPE-1-CT  TO  INPUT-CT.   
           CLOSE    TAPEIN1.   
           MOVE  '   TOTAL RECORDS READ   '  TO  DISP-MESSAGE.  
           MOVE  INPUT-CT  TO  DISP-CT. 
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           MOVE  '    RECORDS WRITTEN TO  '  TO  DISP-MESSAGE.  
           MOVE  'OUTA'  TO  DISP-FNAME.   
           MOVE  TAPE-1-OUT-CT  TO  DISP-CT.  
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           CLOSE    TAPEOUT1. 
           ADD  TAPE-1-OUT-CT  TO  OUTPUT-CT. 
           MOVE  '    RECORDS WRITTEN TO  '  TO  DISP-MESSAGE.  
           MOVE  'OUTB'  TO  DISP-FNAME.   
           MOVE  TAPE-2-OUT-CT  TO  DISP-CT.  
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           CLOSE    TAPEOUT2. 
           ADD  TAPE-2-OUT-CT  TO  OUTPUT-CT. 
           MOVE  '   TOTAL RECORDS WRITTEN'  TO  DISP-MESSAGE.  
           MOVE  OUTPUT-CT  TO  DISP-CT.
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           STOP RUN.
       ABORT-ROUTINES SECTION.  
       SEQUENCE-ERRORS. 
           STOP RUN.
