       IDENTIFICATION DIVISION.
      * SSG-4 (MT-043): one TAPELD (CFH-COPY to PRINTER with page
      * titles) for every call. Record shapes, field moves and the title
      * come from the SGSPARM file written by the skeleton hand-off; see
      * _scratch\spike-tapeld\spec.md. Statements as the skeleton.
       PROGRAM-ID. 'ASSURFED-UTILIT-TAPELD-GN'.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. UNIVAC-1106.
       OBJECT-COMPUTER. UNIVAC-1106.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT  PARMF  ASSIGN  TO  DISC SGSPARM.
           SELECT  TAPEIN  ASSIGN  TO  DISC TAPLIN.
           SELECT   TAPEOUT  ASSIGN  TO  PRINTER.
       DATA DIVISION.
       FILE SECTION.
       FD  PARMF
           LABEL RECORD STANDARD.
       01  PARM-REC.
           03  P-TYPE         PIC XX.
           03  P-REST         PIC X(248).
       01  PARM-LEN-REC.
           03  FILLER         PIC XX.
           03  PL-LEN         PIC 9(5).
           03  FILLER         PIC X(243).
       01  PARM-MOVE-REC.
           03  FILLER         PIC XX.
           03  PM-IS          PIC 9(5).
           03  PM-IL          PIC 9(5).
           03  PM-OS          PIC 9(5).
           03  PM-OL          PIC 9(5).
           03  FILLER         PIC X(228).
       01  PARM-FIXE-REC.
           03  FILLER         PIC XX.
           03  PX-OS          PIC 9(5).
           03  PX-LEN         PIC 9(5).
           03  PX-TXT         PIC X(238).
       FD  TAPEIN
           LABEL  RECORD  STANDARD
           RECORD VARYING IN SIZE FROM 1 TO 4001
           DEPENDING ON WS-IN-LEN.
       01  RECIN-FD           PIC X(4001).
       FD  TAPEOUT
           LABEL  RECORD OMITTED
           DATA RECORD RECOUT.
       01  RECOUT  PIC  X(132).
       WORKING-STORAGE SECTION.
       77  NB-LUS   PIC  S9(10)  COMP  VALUE 0.
       77  LNCTR  PIC  S9(2)  VALUE 58.
       01   SWITCHES.
           03  REC-SKIPPED  PIC  S9(6) VALUE ZEROES.
       01  RECIN              PIC X(4001).
       01  WS-IN              PIC X(4000).
       77  WS-IN-LEN          PIC 9(5) COMP VALUE 0.
       77  CP-LEN             PIC 9(5) COMP VALUE 0.
       77  P-INLEN            PIC 9(5) COMP VALUE 0.
       77  P-OUTLEN           PIC 9(5) COMP VALUE 0.
       77  P-STITRE           PIC X VALUE 'N'.
       77  N-MV               PIC 9(3) COMP VALUE 0.
       77  N-FX               PIC 9(3) COMP VALUE 0.
       77  I                  PIC 9(3) COMP VALUE 0.
       01  MV-TAB.
           03  MV-ENT OCCURS 60.
               05  MV-IS      PIC 9(5) COMP.
               05  MV-IL      PIC 9(5) COMP.
               05  MV-OS      PIC 9(5) COMP.
               05  MV-OL      PIC 9(5) COMP.
       01  FX-TAB.
           03  FX-ENT OCCURS 40.
               05  FX-OS      PIC 9(5) COMP.
               05  FX-LEN     PIC 9(5) COMP.
               05  FX-TXT     PIC X(238).
       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT PARMF.
       PARM-LECT.
           READ PARMF AT END GO TO PARM-FIN.
           IF P-TYPE = 'IN'
              MOVE PL-LEN TO P-INLEN.
           IF P-TYPE = 'OU'
              MOVE PL-LEN TO P-OUTLEN.
           IF P-TYPE = 'MV'
              ADD 1 TO N-MV
              MOVE PM-IS TO MV-IS (N-MV)
              MOVE PM-IL TO MV-IL (N-MV)
              MOVE PM-OS TO MV-OS (N-MV)
              MOVE PM-OL TO MV-OL (N-MV).
           IF P-TYPE = 'FX'
              ADD 1 TO N-FX
              MOVE PX-OS TO FX-OS (N-FX)
              MOVE PX-LEN TO FX-LEN (N-FX)
              MOVE PX-TXT TO FX-TXT (N-FX).
           IF P-TYPE = 'ST'
              MOVE 'Y' TO P-STITRE.
           GO TO PARM-LECT.
       PARM-FIN.
           CLOSE PARMF.
           OPEN INPUT TAPEIN.
           OPEN  OUTPUT  TAPEOUT.
       LECT.
           MOVE SPACES TO RECOUT.
           IF P-STITRE NOT = 'Y' OR N-FX = 0 GO TO LECT-READ.
           IF LNCTR NOT > 57 GO TO LECT-READ.
           MOVE 1 TO I.
       TITLE-MOVE.
           IF I > N-FX GO TO TITLE-WRITE.
           MOVE FX-TXT (I) (1:FX-LEN (I))
             TO RECOUT (FX-OS (I):FX-LEN (I)).
           ADD 1 TO I.
           GO TO TITLE-MOVE.
       TITLE-WRITE.
           WRITE  RECOUT  AFTER  PAGE
           MOVE SPACES TO  RECOUT
           MOVE 5 TO LNCTR.
       LECT-READ.
           MOVE SPACES TO RECIN.
           READ  TAPEIN  INTO RECIN  AT  END  GO TO  FINW.
           MOVE SPACES TO WS-IN.
           MOVE WS-IN-LEN TO CP-LEN.
           IF CP-LEN > P-INLEN
              MOVE P-INLEN TO CP-LEN.
           IF CP-LEN > 0
              MOVE RECIN (1:CP-LEN) TO WS-IN (1:CP-LEN).
           IF N-MV = 0
              MOVE WS-IN (1:P-INLEN) TO RECOUT.
           MOVE 1 TO I.
       MV-LOOP.
           IF I > N-MV GO TO MV-END.
           MOVE WS-IN (MV-IS (I):MV-IL (I))
             TO RECOUT (MV-OS (I):MV-OL (I)).
           ADD 1 TO I.
           GO TO MV-LOOP.
       MV-END.
           ADD 1  TO NB-LUS.
           ADD 1  TO LNCTR.
           WRITE RECOUT.
           GO TO LECT.
       FINW.
           DISPLAY  '*CFH-COPY  FIN*'  UPON  PRINTER.
           DISPLAY  '*NB-ENREG-LUS ='  NB-LUS  UPON  PRINTER.
           CLOSE  TAPEIN.
           CLOSE  TAPEOUT.
           DISPLAY  REC-SKIPPED  UPON  PRINTER.
           STOP RUN.
