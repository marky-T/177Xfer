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
                   RECORD CONTAINS 100 CHARACTERS   
                    DATA RECORD  IS REC-IN-1.  
       01  REC-IN-1.   
           03 COMPARE-FILE-1-FIELD-1  
                   PIC  X(7).
           03 COMPARE-FILE-1-FIELD-2  
                   PIC  X(6).
           03 COMPARE-FILE-1-FIELD-3  
                   PIC  X(3).
           03 FILLER   PIC X(84).   
       FD  TAPEIN2 
                    LABEL RECORD IS STANDARD
                   BLOCK CONTAINS 10 RECORDS   
                   RECORD CONTAINS 164 CHARACTERS   
                    DATA RECORD  IS REC-IN-2.  
       01  REC-IN-2.   
           03  FILLER                   PIC  X(1). 
           03  COMPARE-FILE-2-FIELD-1   PIC  X(7).   
           03  FILLER                   PIC  X(1). 
           03  COMPARE-FILE-2-FIELD-2   PIC  X(6).   
           03  FILLER                   PIC  X(1). 
           03  COMPARE-FILE-2-FIELD-3   PIC  X(3).   
           03  FILLER                   PIC  X(145). 
       FD  TAPEOUT1 
                    LABEL RECORD IS STANDARD
                    BLOCK CONTAINS 10 RECORDS  
                    RECORD CONTAINS 164 CHARACTERS  
                    DATA RECORD IS REC-OUT-1.   
       01  REC-OUT-1           PIC X(164).  
       FD  TAPEOUT2 
                    LABEL RECORD IS STANDARD
                    BLOCK CONTAINS 10 RECORDS  
                    RECORD CONTAINS 164 CHARACTERS  
                    DATA RECORD IS REC-OUT-2.   
       01  REC-OUT-2           PIC X(164).  
       WORKING-STORAGE SECTION. 
       77  TAPE-1-CT                PIC 9(10)  COMP VALUE 0.   
       77  TAPE-2-CT                PIC 9(10)  COMP VALUE 0.   
       77  INPUT-CT           PIC 9(10)  COMP  VALUE 0. 
       77  TAPE-1-OUT-CT            PIC 9(10)  COMP  VALUE 0. 
       77  TAPE-2-OUT-CT            PIC 9(10)  COMP  VALUE 0. 
       77  OUTPUT-CT                PIC 9(10)  COMP  VALUE 0.   
       01  COMPARE-1.   
           03 COMPARE-FILE-1-FIELD-1
                 PIC X(7).
           03 COMPARE-FILE-1-FIELD-2
                 PIC X(6).
           03 COMPARE-FILE-1-FIELD-3
                 PIC X(3).
       01  COMPARE-2.   
           03  COMPARE-FILE-2-FIELD-1   PIC X(7).   
           03  COMPARE-FILE-2-FIELD-2   PIC X(6).   
           03  COMPARE-FILE-2-FIELD-3   PIC X(3).   
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
           MOVE ' ' TO SWITCHA. 
           GO TO  TEST-FILES-1-AND-2.   
       WRITE-FROM-FILE-1.   
           IF  SWITCHA = '-'
           AND  
           SWITCHB  =  '1'  MOVE '0'  TO SWITCHB
           GO TO READ-FILE-1.   
           IF  SWITCHA  =  '-'  
           GO TO READ-FILE-1.   
           IF  SWITCHA  =  '+'  GO TO NORMAL1.  
           IF SWITCHA = '=' 
           WRITE  REC-OUT-2  FROM  REC-IN-2.
           ADD 1  TO TAPE-1-OUT-CT. 
           GO TO READ-FILE-2.   
           MOVE  REC-IN-2  TO REC-OUT-1.
       FIELD1.  
           WRITE REC-OUT-1. 
           GO TO OVER1. 
       NORMAL1. 
           WRITE  REC-OUT-1  FROM  REC-IN-1.
       OVER1.   
           ADD  1  TO  TAPE-2-OUT-CT.  
           GO TO  READ-FILE-1.  
       READ-FILE-2. 
           READ  TAPEIN2
                    AT END  MOVE  HIGH-VALUE  TO  REC-IN-2. 
           MOVE  CORRESPONDING  REC-IN-2   TO  COMPARE-2.   
           ADD 1 TO TAPE-2-CT.  
           MOVE ' ' TO SWITCHA. 
           GO TO  TEST-FILES-1-AND-2.   
       WRITE-FROM-FILE-2.   
           IF  SWITCHA = '-'
           AND  
           SWITCHB  =  '1'  MOVE '0'  TO SWITCHB
           GO TO READ-FILE-2.   
           IF  SWITCHA  =  '-'  
           GO TO READ-FILE-2.   
           IF  SWITCHA  =  '+'  GO TO NORMAL2.  
           IF SWITCHA = '=' 
           WRITE  REC-OUT-2  FROM  REC-IN-2.
           ADD 1  TO TAPE-2-OUT-CT. 
           GO TO READ-FILE-2.   
           MOVE  REC-IN-2  TO REC-OUT-1.
       FIELD2.  
           WRITE REC-OUT-1. 
           GO TO OVER2. 
       NORMAL2. 
           WRITE  REC-OUT-1  FROM  REC-IN-2.
       OVER2.   
           ADD  1  TO  TAPE-2-OUT-CT.  
           GO TO  READ-FILE-2.  
       FUSION SECTION.  
       TEST-FILES-1-AND-2.
           IF  COMPARE-1   <   COMPARE-2  
           MOVE  '-'   TO SWITCHA   
                    GO  TO  WRITE-FROM-FILE-1.   
           IF  COMPARE-1   >   COMPARE-2  
           MOVE  '+'   TO SWITCHA   
                    GO  TO  WRITE-FROM-FILE-2.   
           IF  COMPARE-1   =   COMPARE-2  
           AND COMPARE-1   =   HIGH-VALUE
                    GO  TO  ENDING-ROUTINES.
              MOVE '='  TO SWITCHA. 
           MOVE  '1'  TO SWITCHB.   
           GO  TO  WRITE-FROM-FILE-1.
       ENDING-ROUTINES SECTION. 
       PRINT-FILE-CTS.  
           SUBTRACT  1  FROM  TAPE-1-CT.   
           MOVE  '     RECORDS  READ FROM '  TO  DISP-MESSAGE.  
           MOVE  'CLE'  TO  DISP-FNAME. 
           MOVE  TAPE-1-CT  TO  DISP-CT.   
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           ADD  TAPE-1-CT  TO  INPUT-CT.   
           CLOSE    TAPEIN1.   
           SUBTRACT  1  FROM  TAPE-2-CT.   
           MOVE  '     RECORDS  READ FROM '  TO  DISP-MESSAGE.  
           MOVE  'UNL'  TO  DISP-FNAME. 
           MOVE  TAPE-2-CT  TO  DISP-CT.   
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           ADD  TAPE-2-CT  TO  INPUT-CT.   
           CLOSE    TAPEIN2.   
           MOVE  '   TOTAL RECORDS READ   '  TO  DISP-MESSAGE.  
           MOVE  INPUT-CT  TO  DISP-CT. 
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           MOVE  '    RECORDS WRITTEN TO  '  TO  DISP-MESSAGE.  
           MOVE  'LOA'  TO  DISP-FNAME.   
           MOVE  TAPE-1-OUT-CT  TO  DISP-CT.  
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           CLOSE    TAPEOUT1. 
           ADD  TAPE-1-OUT-CT  TO  OUTPUT-CT. 
           MOVE  '    RECORDS WRITTEN TO  '  TO  DISP-MESSAGE.  
           MOVE  'SUP'  TO  DISP-FNAME.   
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
