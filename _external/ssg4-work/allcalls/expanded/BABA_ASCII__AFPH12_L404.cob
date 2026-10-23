       IDENTIFICATION DIVISION. 
       PROGRAM-ID. EXTRACT-INASC.   
       AUTHOR. BOURDEAUD HUY PIERRE.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNIVAC-1100-60EIS.  
       OBJECT-COMPUTER. UNIVAC-1100-60EIS.  
       SPECIAL-NAMES.     PRINTER   IS   LISTE. 
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT  TAPEIN1  ASSIGN  TO 
                    DISC  INASC.  
           SELECT  TAPEOUT1  ASSIGN  TO   
                    DISC  OUTASC.
       DATA DIVISION.   
       FILE SECTION.
       FD  TAPEIN1 
                    LABEL RECORD IS STANDARD
                   BLOCK CONTAINS 10 RECORDS   
                   RECORD CONTAINS 80 CHARACTERS   
                    DATA RECORD  IS REC-IN-1.  
       01  REC-IN-1.   
           03  COMPARE-FILE-1-FIELD-2   PIC  X(15).   
           03  FILLER                   PIC  X(65). 
       FD  TAPEOUT1 
                    LABEL RECORD IS STANDARD
                    BLOCK CONTAINS 10 RECORDS  
                    RECORD CONTAINS 80 CHARACTERS  
                    DATA RECORD IS REC-OUT-1.   
       01  REC-OUT-1           PIC X(80).  
       WORKING-STORAGE SECTION. 
       77  TAPE-1-CT                PIC 9(10)  COMP VALUE 0.   
       77  INPUT-CT                 PIC 9(10)  COMP  VALUE 0.   
       77  TAPE-1-OUT-CT            PIC 9(10)  COMP  VALUE 0. 
       77  OUTPUT-CT                PIC 9(10)  COMP  VALUE 0.   
       77  ELIMINATE-CT                 PIC 9(10)  COMP VALUE 0.
       01  REQUIREMENTS-1. 
           03  REQ-ALT-1-FLD-2  PIC X(15).  
       01  COMPARE-1.   
           03  COMPARE-FILE-1-FIELD-2   PIC X(15).   
       01  FILE-1-SEQ-ERROR-CT     PIC 9(5)  COMP  VALUE 0.
       01  SEQ-COMPARE-1.  
           03  COMPARE-FILE-1-FIELD-2    PIC X(15). 
       01  ABORT-IND  PIC 9(5) COMP.
       01  SEQ-ERR-LINE       USAGE  DISPLAY-1. 
           03  SEQ-FNAME                PIC X(12).  
           03  FILLER                   PIC X(36)   
               VALUE  ' HAS SEQUENCE ERROR BETWEEN RECORD '.
           03  SEQ-REC-1                PIC Z(11)9. 
           03  FILLER                   PIC X(12)   
               VALUE  ' AND RECORD '.   
           03  SEQ-REC-2                PIC Z(11)9. 
       01  SEQ-ERR-L2.  
                                                 USAGE   DISPLAY-1  
           03  FILLER                   PIC X(9)
               VALUE  'INDICATIF'.  
           03  SEQ-REC-L2               PIC Z(11)9. 
           03  FILLER PIC X(6)  
               VALUE '  :-  '.  
           03  COMPARE-L2               PIC X(105). 
       01  DISPLAY-LINE                          USAGE  DISPLAY-1.  
               03  DISP-MESSAGE        PIC X(24).   
               03  DISP-FNAME          PIC X(12).   
               03  DISP-CT             PIC Z(11)9.  
               03  FILLER              PIC X(84)  VALUE SPACE.  
       01  TESTA.   
           03  SWITCHA  PIC X.  
       01  CTR PIC 9(18) COMP.  
       PROCEDURE DIVISION.  
       E-F-INASC SECTION.   
       DEBUT.   
            OPEN OUTPUT TAPEOUT1. 
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
           MOVE CORRESPONDING  REC-IN-1  TO  SEQ-COMPARE-1. 
           IF    SEQ-COMPARE-1  <   COMPARE-1   
                 GO  TO  ABORT-ROUTINES.
           MOVE '0' TO SWITCHA. 
           IF SEQ-COMPARE-1 = COMPARE-1 
           MOVE '1' TO SWITCHA. 
       MOVE-REC-1.  
           MOVE  CORRESPONDING  REC-IN-1   TO  COMPARE-1.   
           ADD 1 TO TAPE-1-CT.  
           GO  TO  REQUIREMENTS-TEST.   
       WRITE-1-FROM-FILE-1.   
           WRITE  REC-OUT-1  FROM  REC-IN-1.  
           ADD  1  TO  TAPE-1-OUT-CT. 
           GO  TO  READ-FILE-1. 
       SEPARATION SECTION.  
       REQUIREMENTS-TEST.   
           IF SWITCHA NOT = '1' 
           GO TO WRITE-1-FROM-FILE-1.   
           GO TO READ-FILE-1.   
           GO TO  WRITE-1-FROM-FILE-1.  
       ENDING-ROUTINES SECTION. 
       PRINT-FILE-CTS.  
           MOVE  '     RECORDS  READ FROM '  TO  DISP-MESSAGE.  
           MOVE  'INASC'  TO  DISP-FNAME. 
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
           MOVE  'OUTASC'  TO  DISP-FNAME.   
           MOVE  TAPE-1-OUT-CT  TO  DISP-CT.  
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           CLOSE    TAPEOUT1. 
           ADD  TAPE-1-OUT-CT  TO  OUTPUT-CT. 
           MOVE  '   TOTAL RECORDS WRITTEN'  TO  DISP-MESSAGE.  
           MOVE  OUTPUT-CT  TO  DISP-CT.
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           STOP RUN.
       ABORT-ROUTINES SECTION.  
       SEQUENCE-ERRORS. 
           GO  TO   
                    FILE-1-SEQ-ERROR                                   1
              DEPENDING  ON  ABORT-IND  
       FILE-1-SEQ-ERROR.  
           MOVE  'INASC'  TO  SEQ-FNAME. 
           SUBTRACT  1  FROM  TAPE-1-CT  GIVING  SEQ-REC-1,   
                              SEQ-REC-L2.   
           MOVE  TAPE-1-CT  TO  SEQ-REC-2.
           MOVE  SEQ-ERR-LINE  TO  DISPLAY-LINE.
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  COMPARE-1   TO   COMPARE-L2. 
           MOVE  SEQ-ERR-L2        TO   DISPLAY-LINE.   
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  TAPE-1-CT   TO   SEQ-REC-L2. 
           MOVE  SEQ-COMPARE-1   TO   COMPARE-L2. 
           MOVE  SEQ-ERR-L2         TO   DISPLAY-LINE.  
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           CALL  'ABORT'.   
           STOP RUN.
