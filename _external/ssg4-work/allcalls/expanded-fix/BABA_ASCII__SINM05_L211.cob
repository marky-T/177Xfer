       IDENTIFICATION DIVISION. 
       PROGRAM-ID. EXTRACT-IRESMENS.   
       AUTHOR. BOURDEAUD HUY PIERRE.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNIVAC-1100-60EIS.  
       OBJECT-COMPUTER. UNIVAC-1100-60EIS.  
       SPECIAL-NAMES.     PRINTER   IS   LISTE. 
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT  TAPEIN1  ASSIGN  TO 
                    DISC  IRESMENS.  
           SELECT  TAPEOUT1  ASSIGN  TO   
                    DISC  OUT.
       DATA DIVISION.   
       FILE SECTION.
       FD  TAPEIN1 
                    LABEL RECORD IS STANDARD
                   BLOCK CONTAINS 10 RECORDS   
                   RECORD CONTAINS 300 CHARACTERS   
                    DATA RECORD  IS REC-IN-1.  
       01  REC-IN-1.   
           03  FILLER                   PIC  X(218). 
           03  COMPARE-FILE-1-FIELD-2   PIC  X(12).   
           03  FILLER                   PIC  X(70). 
       FD  TAPEOUT1 
                    LABEL RECORD IS STANDARD
                    BLOCK CONTAINS 10 RECORDS  
                    RECORD CONTAINS 300 CHARACTERS  
                    DATA RECORD IS REC-OUT-1.   
       01  REC-OUT-1           PIC X(300).  
       WORKING-STORAGE SECTION. 
       77  TAPE-1-CT                PIC 9(10)  COMP VALUE 0.   
       77  INPUT-CT                 PIC 9(10)  COMP  VALUE 0.   
       77  TAPE-1-OUT-CT            PIC 9(10)  COMP  VALUE 0. 
       77  OUTPUT-CT                PIC 9(10)  COMP  VALUE 0.   
       77  ELIMINATE-CT                 PIC 9(10)  COMP VALUE 0.
       01  REQUIREMENTS-1. 
           03  REQ-ALT-1-FLD-2          PIC X(12)   
               VALUE  '000000000000'.   
       01  REQUIREMENTS-2. 
           03  REQ-ALT-2-FLD-2          PIC X(12)   
               VALUE  '00000000000!'.   
       01  REQUIREMENTS-3. 
           03  REQ-ALT-3-FLD-2          PIC X(12)   
               VALUE  '00000000000}'.   
       01  REQUIREMENTS-4. 
           03  REQ-ALT-4-FLD-2          PIC X(12)   
               VALUE  '00000000000-'.   
       01  REQUIREMENTS-5. 
           03  REQ-ALT-5-FLD-2          PIC X(12)   
               VALUE  '00000000000]'.   
       01  REQUIREMENTS-6. 
           03  REQ-ALT-6-FLD-2          PIC X(12)   
               VALUE  '00000000000['.   
       01  REQUIREMENTS-7. 
           03  REQ-ALT-7-FLD-2          PIC X(12)   
               VALUE  '00000000000{'.   
       01  REQUIREMENTS-8. 
           03  REQ-ALT-8-FLD-2          PIC X(12)   
               VALUE  '00000000000+'.   
       01  REQUIREMENTS-9. 
           03  REQ-ALT-9-FLD-2          PIC X(12)   
               VALUE  '00000000000)'.   
       01  REQUIREMENTS-10. 
           03  REQ-ALT-10-FLD-2          PIC X(12)   
               VALUE  '00000000000('.   
       01  REQUIREMENTS-11. 
           03  REQ-ALT-11-FLD-2          PIC X(12)   
               VALUE  '00000000000%'.   
       01  REQUIREMENTS-12. 
           03  REQ-ALT-12-FLD-2          PIC X(12)   
               VALUE  '00000000000&'.   
       01  REQUIREMENTS-13. 
           03  REQ-ALT-13-FLD-2          PIC X(12)   
               VALUE  '00000000000?'.   
       01  REQUIREMENTS-14. 
           03  REQ-ALT-14-FLD-2          PIC X(12)   
               VALUE  '00000000000:'.   
       01  REQUIREMENTS-15. 
           03  REQ-ALT-15-FLD-2          PIC X(12)   
               VALUE  '00000000000*'.   
       01  REQUIREMENTS-16. 
           03  REQ-ALT-16-FLD-2          PIC X(12)   
               VALUE  '00000000000''.   
       01  REQUIREMENTS-17. 
           03  REQ-ALT-17-FLD-2          PIC X(12)   
               VALUE  '00000000000"'.   
       01  REQUIREMENTS-18. 
           03  REQ-ALT-18-FLD-2          PIC X(12)   
               VALUE  '00000000000$'.   
       01  REQUIREMENTS-19. 
           03  REQ-ALT-19-FLD-2          PIC X(12)   
               VALUE  '00000000000='.   
       01  COMPARE-1.   
           03  COMPARE-FILE-1-FIELD-2   PIC X(12).   
       01  DISPLAY-LINE                          USAGE  DISPLAY-1.  
               03  DISP-MESSAGE        PIC X(24).   
               03  DISP-FNAME          PIC X(12).   
               03  DISP-CT             PIC Z(11)9.  
               03  FILLER              PIC X(84)  VALUE SPACE.  
       01  CTR PIC 9(18) COMP.  
       PROCEDURE DIVISION.  
       E-F-IRESMENS SECTION.   
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
           MOVE  CORRESPONDING  REC-IN-1   TO  COMPARE-1.   
           ADD 1 TO TAPE-1-CT.  
           GO  TO  REQUIREMENTS-TEST.   
       WRITE-1-FROM-FILE-1.   
           WRITE  REC-OUT-1  FROM  REC-IN-1.  
           ADD  1  TO  TAPE-1-OUT-CT. 
           GO  TO  READ-FILE-1. 
       SEPARATION SECTION.  
       REQUIREMENTS-TEST.   
           INSPECT REQUIREMENTS-1 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-1 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-2 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-2 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-3 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-3 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-4 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-4 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-5 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-5 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-6 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-6 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-7 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-7 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-8 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-8 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-9 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-9 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-10 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-10 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-11 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-11 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-12 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-12 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-13 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-13 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-14 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-14 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-15 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-15 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-16 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-16 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-17 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-17 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-18 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-18 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
           INSPECT REQUIREMENTS-19 
                   REPLACING ALL '<' BY ';' 
           IF COMPARE-1 NOT = REQUIREMENTS-19 NEXT SENTENCE ELSE   
                              GO TO ALFRED. 
       TOTOK.   
           GO TO WRITE-1-FROM-FILE-1.   
       ALFRED.  
            ADD 1 TO ELIMINATE-CT.  
           GO TO READ-FILE-1.   
       ENDING-ROUTINES SECTION. 
       PRINT-FILE-CTS.  
           MOVE  '     RECORDS  READ FROM '  TO  DISP-MESSAGE.  
           MOVE  'IRESMENS'  TO  DISP-FNAME. 
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
           STOP RUN.
       ABORT-ROUTINES SECTION.  
       SEQUENCE-ERRORS. 
           STOP RUN.
