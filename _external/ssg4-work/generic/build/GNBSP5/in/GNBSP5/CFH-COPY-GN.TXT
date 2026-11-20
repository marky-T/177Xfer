       IDENTIFICATION DIVISION.
      * SSG-4 spike (MT-043): one CFH-COPY for every call. Record shapes,
      * field moves and constants come from the SGSPARM file written by
      * the skeleton hand-off; see _scratch\spike-cfh\spec.md.
       PROGRAM-ID. 'CFH-COPY-GN'.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. UNIVAC-1100-10.
       OBJECT-COMPUTER. UNIVAC-1100-10.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PARMF ASSIGN TO DISC SGSPARM.
           SELECT FI1 ASSIGN TO DISC CFHIN.
           SELECT FO1 ASSIGN TO DISC CFHOUT.
       DATA DIVISION.
       FILE SECTION.
       FD  PARMF
           LABEL RECORD STANDARD.
       01  PARM-REC.
           03  P-TYPE         PIC XX.
           03  P-REST         PIC X(248).
       01  PARM-FILE-REC.
           03  FILLER         PIC XX.
           03  PF-NAME        PIC X(30).
           03  PF-LEN         PIC 9(5).
           03  FILLER         PIC X(213).
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
       01  PARM-SKIP-REC.
           03  FILLER         PIC XX.
           03  PS-N           PIC 9(5).
           03  FILLER         PIC X(243).
       FD  FI1
           LABEL RECORD STANDARD
           RECORD VARYING IN SIZE FROM 1 TO 4001
           DEPENDING ON WS-IN-LEN.
       01  FI1-REC PIC X(4001).
       FD  FO1
           LABEL RECORD STANDARD.
       01  FO1-REC PIC X(4000).
       WORKING-STORAGE SECTION.
       01  RECIN              PIC X(4001).
       01  RECOUT             PIC X(4000).
       01  IN-NAMES-V.
           03 FILLER PIC X(30) VALUE 'CFHIN'.
       01  IN-NAMES REDEFINES IN-NAMES-V.
           03 IN-NM PIC X(30) OCCURS 1.
       01  OUT-NAMES-V.
           03 FILLER PIC X(30) VALUE 'CFHOUT'.
       01  OUT-NAMES REDEFINES OUT-NAMES-V.
           03 OUT-NM PIC X(30) OCCURS 1.
       77  IX-IN              PIC 9(3) COMP VALUE 0.
       77  IX-OUT             PIC 9(3) COMP VALUE 0.
       77  NB-LUS             PIC 9(10) COMP VALUE 0.
       01  SWITCHES.
           03  REC-SKIPPED    PIC S9(6) VALUE ZEROES.
       77  WS-INNAME          PIC X(30) VALUE SPACES.
       77  WS-OUTNAME         PIC X(30) VALUE SPACES.
       77  WS-IN-LEN          PIC 9(5) COMP VALUE 0.
       77  WS-OUT-LEN         PIC 9(5) COMP VALUE 0.
       77  P-INLEN            PIC 9(5) COMP VALUE 0.
       77  P-OUTLEN           PIC 9(5) COMP VALUE 0.
       77  P-SKIP             PIC 9(5) COMP VALUE 0.
       77  N-MV               PIC 9(3) COMP VALUE 0.
       77  N-FX               PIC 9(3) COMP VALUE 0.
       77  I                  PIC 9(3) COMP VALUE 0.
       77  CP-LEN             PIC 9(5) COMP VALUE 0.
       01  MV-TAB.
           03  MV-ENT OCCURS 30.
               05  MV-IS      PIC 9(5) COMP.
               05  MV-IL      PIC 9(5) COMP.
               05  MV-OS      PIC 9(5) COMP.
               05  MV-OL      PIC 9(5) COMP.
       01  FX-TAB.
           03  FX-ENT OCCURS 20.
               05  FX-OS      PIC 9(5) COMP.
               05  FX-LEN     PIC 9(5) COMP.
               05  FX-TXT     PIC X(238).
       01  WS-IN              PIC X(4000).
       01  WS-OUT             PIC X(4000).
       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT PARMF.
       PARM-LECT.
           READ PARMF AT END GO TO PARM-FIN.
           IF P-TYPE = 'IN'
              MOVE PF-NAME TO WS-INNAME
              MOVE PF-LEN TO P-INLEN.
           IF P-TYPE = 'OU'
              MOVE PF-NAME TO WS-OUTNAME
              MOVE PF-LEN TO P-OUTLEN.
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
           IF P-TYPE = 'SK'
              MOVE PS-N TO P-SKIP.
           GO TO PARM-LECT.
       PARM-FIN.
           CLOSE PARMF.
           MOVE 1 TO IX-IN.
           MOVE 1 TO IX-OUT.
       FIND-IN.
           IF IX-IN > 1 GO TO FINW.
           IF IN-NM (IX-IN) = WS-INNAME GO TO FIND-OUT.
           ADD 1 TO IX-IN.
           GO TO FIND-IN.
       FIND-OUT.
           IF IX-OUT > 1 GO TO FINW.
           IF OUT-NM (IX-OUT) = WS-OUTNAME GO TO OPEN-FILES.
           ADD 1 TO IX-OUT.
           GO TO FIND-OUT.
       OPEN-FILES.
           GO TO
                 OI-1
             DEPENDING ON IX-IN.
       OI-1.
           OPEN INPUT FI1.
           GO TO OI-END.
       OI-END.
           GO TO
                 OO-1
             DEPENDING ON IX-OUT.
       OO-1.
           OPEN OUTPUT FO1.
           GO TO OO-END.
       OO-END.
       LECT.
           MOVE SPACES TO WS-OUT.
           MOVE SPACES TO RECIN.
           GO TO
                 RD-1
             DEPENDING ON IX-IN.
       RD-1.
           READ FI1 INTO RECIN AT END GO TO FINW.
           GO TO RD-END.
       RD-END.
           MOVE SPACES TO WS-IN.
           MOVE WS-IN-LEN TO CP-LEN.
           IF CP-LEN > P-INLEN
              MOVE P-INLEN TO CP-LEN.
           IF CP-LEN > 0
              MOVE RECIN (1:CP-LEN) TO WS-IN (1:CP-LEN).
           IF N-MV = 0
              MOVE WS-IN (1:P-INLEN) TO WS-OUT (1:P-OUTLEN).
           MOVE 1 TO I.
       MV-LOOP.
           IF I > N-MV GO TO FX-START.
           MOVE WS-IN (MV-IS (I):MV-IL (I))
             TO WS-OUT (MV-OS (I):MV-OL (I)).
           ADD 1 TO I.
           GO TO MV-LOOP.
       FX-START.
           MOVE 1 TO I.
       FX-LOOP.
           IF I > N-FX GO TO REC-END.
           MOVE FX-TXT (I) (1:FX-LEN (I))
             TO WS-OUT (FX-OS (I):FX-LEN (I)).
           INSPECT WS-OUT (FX-OS (I):FX-LEN (I))
             REPLACING ALL '<' BY ';'.
           ADD 1 TO I.
           GO TO FX-LOOP.
       REC-END.
           ADD 1 TO NB-LUS.
           IF NB-LUS < P-SKIP
              ADD 1 TO REC-SKIPPED
              GO TO LECT.
           MOVE P-OUTLEN TO WS-OUT-LEN.
           MOVE WS-OUT TO RECOUT.
           GO TO
                 WR-1
             DEPENDING ON IX-OUT.
       WR-1.
           WRITE FO1-REC FROM RECOUT.
           GO TO WR-END.
       WR-END.
           GO TO LECT.
       FINW.
           DISPLAY  '*CFH-COPY  FIN*'  UPON  PRINTER.
           DISPLAY  '*NB-ENREG-LUS ='  NB-LUS  UPON  PRINTER.
           IF IX-IN > 1 GO TO CI-END.
           GO TO
                 CI-1
             DEPENDING ON IX-IN.
       CI-1.
           CLOSE FI1.
           GO TO CI-END.
       CI-END.
           IF IX-OUT > 1 GO TO CO-END.
           GO TO
                 CO-1
             DEPENDING ON IX-OUT.
       CO-1.
           CLOSE FO1.
           GO TO CO-END.
       CO-END.
           DISPLAY  REC-SKIPPED  UPON  PRINTER.
           STOP RUN.
