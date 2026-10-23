       IDENTIFICATION DIVISION. 
       PROGRAM-ID.  FUSION-OUT.  
       AUTHOR. BOURDEAUD HUY PIERRE.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNIVAC-1100-60. 
       OBJECT-COMPUTER. UNIVAC-1100-60. 
       SPECIAL-NAMES.     PRINTER   IS   LISTE. 
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT  TAPEIN1  ASSIGN  TO 
                    DISC  MAJ.  
           SELECT  TAPEIN2  ASSIGN  TO 
                    DISC  INP.  
           SELECT  TAPEOUT1  ASSIGN  TO   
                    DISC  OUT.
       DATA DIVISION.   
       FILE SECTION.
       FD  TAPEIN1 
                    LABEL RECORD IS STANDARD
                   BLOCK CONTAINS 10 RECORDS   
                   RECORD CONTAINS 70 CHARACTERS   
           DATA RECORD IS   
                   REC-IN-1-1
           REC-IN-1.   
       01  REC-IN-1.   
           03 COMPARE-FILE-1-FIELD-1  
                   PIC  X(6).
           03  FILLER  PIC  X(1).  
           03 COMPARE-FILE-1-FIELD-2  
                   PIC  X(1).
           03 FILLER   PIC X(62).   
       01  REC-IN-1-1.   
           06  FILLER  PIC X(9). 
           06  ZONE1  PIC  X(61).   
       FD  TAPEIN2 
                    LABEL RECORD IS STANDARD
                   BLOCK CONTAINS 10 RECORDS   
                   RECORD CONTAINS 184 CHARACTERS   
                    DATA RECORD  IS REC-IN-2.  
       01  REC-IN-2.   
           03  COMPARE-FILE-2-FIELD-1   PIC  X(6).   
           03  FILLER                   PIC  X(1). 
           03  COMPARE-FILE-2-FIELD-2   PIC  X(1).   
           03  FILLER                   PIC  X(176). 
       FD  TAPEOUT1 
                    LABEL RECORD IS STANDARD
                    BLOCK CONTAINS 10 RECORDS  
                    RECORD CONTAINS 246 CHARACTERS  
           DATA RECORD IS   
               REC-OUT-11
           REC-OUT-1.   
       01  REC-OUT-1           PIC X(246).  
       01  REC-OUT-11.   
           06  FILLER  PIC X(185). 
           06  ZONO1  PIC  X(61).  
       WORKING-STORAGE SECTION. 
       77  TAPE-1-CT                PIC 9(10)  COMP VALUE 0.   
       77  TAPE-2-CT                PIC 9(10)  COMP VALUE 0.   
       77  INPUT-CT           PIC 9(10)  COMP  VALUE 0. 
       77  TAPE-1-OUT-CT            PIC 9(10)  COMP  VALUE 0. 
       77  TAPE-1-MAJ-CT            PIC 9(10)  COMP  VALUE 0. 
       77  OUTPUT-CT                PIC 9(10)  COMP  VALUE 0.   
       01  COMPARE-1.   
           03 COMPARE-FILE-1-FIELD-1
                 PIC X(6).
           03 COMPARE-FILE-1-FIELD-2
                 PIC X(1).
       01  COMPARE-2.   
           03  COMPARE-FILE-2-FIELD-1   PIC X(6).   
           03  COMPARE-FILE-2-FIELD-2   PIC X(1).   
       01  PREC-COMPARE-1.  
           03 PREC-COMPARE-FILE-1-FIELD-1   
                 PIC X(6).
           03 PREC-COMPARE-FILE-1-FIELD-2   
                 PIC X(1).
       01  PREC-COMPARE-2.  
           03 PREC-COMPARE-FILE-2-FIELD-1 PIC X(6). 
           03 PREC-COMPARE-FILE-2-FIELD-2 PIC X(1). 
       01  DISPLAY-LINE   USAGE DISPLAY-1   VALUE SPACES.   
               03  DISP-MESSAGE        PIC X(24).   
               03  DISP-FNAME          PIC X(16).   
               03  DISP-CT             PIC Z(11)9.  
               03  FILLER              PIC X(28).   
       01  SWITCHES.
           03 SWITCHA PIC X.
           03  SWITCHB  PIC  X  VALUE 0.
       PROCEDURE DIVISION.  
       MERGE-2-FILES  SECTION.  
       OPEN-AND-FIRST-READ. 
           OPEN  INPUT  TAPEIN1.   
           OPEN  INPUT  TAPEIN2.   
           OPEN  OUTPUT  TAPEOUT1.
           PERFORM READ-FILE-1. 
           PERFORM READ-FILE-2. 
       COMPARE-FILES.   
           IF  COMPARE-1 <  COMPARE-2   
               PERFORM DISPLAY-FILE-1   
               PERFORM READ-FILE-1  
               GO TO COMPARE-FILES. 
           IF  COMPARE-1 >  COMPARE-2   
               MOVE REC-IN-2 TO REC-OUT-1   
               PERFORM WRITE-FROM-FILE  
               PERFORM READ-FILE-2  
               GO TO COMPARE-FILES. 
           IF  COMPARE-1 =  COMPARE-2  AND  
               COMPARE-1 =  HIGH-VALUES 
               GO TO PRINT-FILE-TOT.
           MOVE REC-IN-2 TO REC-OUT-1.  
           MOVE ZONE1 TO ZONO1. 
           PERFORM WRITE-FROM-FILE. 
           ADD 1 TO TAPE-1-MAJ-CT.  
           PERFORM READ-FILE-2. 
           IF  COMPARE-2 >  PREC-COMPARE-2  
               PERFORM READ-FILE-1. 
           GO TO COMPARE-FILES. 
       READ-FILE-1. 
           MOVE  COMPARE-1  TO  PREC-COMPARE-1. 
           READ  TAPEIN1
                    AT END  MOVE  HIGH-VALUE  TO  REC-IN-1. 
           MOVE  CORRESPONDING  REC-IN-1   TO  COMPARE-1.   
           ADD 1 TO TAPE-1-CT.  
       READ-FILE-2. 
           MOVE  COMPARE-2  TO  PREC-COMPARE-2. 
           READ  TAPEIN2
                    AT END  MOVE  HIGH-VALUE  TO  REC-IN-2. 
           MOVE  CORRESPONDING  REC-IN-2   TO  COMPARE-2.   
           ADD 1 TO TAPE-2-CT.  
       WRITE-FROM-FILE. 
           WRITE REC-OUT-1. 
           ADD 1 TO TAPE-1-OUT-CT.  
       DISPLAY-FILE-1.  
       PRINT-FILE-TOT.  
           SUBTRACT  1  FROM  TAPE-1-CT.   
           MOVE  '     RECORDS  READ FROM '  TO  DISP-MESSAGE.  
           MOVE  'MAJ'  TO  DISP-FNAME. 
           MOVE  TAPE-1-CT  TO  DISP-CT.   
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           ADD  TAPE-1-CT  TO  INPUT-CT.   
           CLOSE    TAPEIN1.   
           SUBTRACT  1  FROM  TAPE-2-CT.   
           MOVE  '     RECORDS  READ FROM '  TO  DISP-MESSAGE.  
           MOVE  'INP'  TO  DISP-FNAME. 
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
           MOVE  'OUT'  TO  DISP-FNAME.   
           MOVE  TAPE-1-OUT-CT  TO  DISP-CT.  
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           CLOSE    TAPEOUT1. 
           ADD  TAPE-1-OUT-CT  TO  OUTPUT-CT. 
           MOVE  '   TOTAL RECORDS WRITTEN'  TO  DISP-MESSAGE.  
           MOVE  OUTPUT-CT  TO  DISP-CT.
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           MOVE  '    RECORDS OUTPUT MAJ. '  TO  DISP-MESSAGE.  
           MOVE  TAPE-1-MAJ-CT  TO  DISP-CT.
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           STOP RUN.
       ABORT-ROUTINES SECTION.  
       SEQUENCE-ERRORS. 
           STOP RUN.
