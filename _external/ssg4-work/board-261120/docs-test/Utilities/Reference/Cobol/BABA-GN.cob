       IDENTIFICATION DIVISION.
      * SSG-4 (MT-043): one BABA for every call. Key fields, mode,
      * value sets and outputs come from the SGSPARM file written by
      * the skeleton hand-off; see _scratch\spike-baba\spec.md.
       PROGRAM-ID. 'BABA-GN'.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. UNIVAC-1100-10.
       OBJECT-COMPUTER. UNIVAC-1100-10.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PARMF ASSIGN TO DISC SGSPARM.
           SELECT FI1 ASSIGN TO DISC BABIN.
           SELECT FO1 ASSIGN TO DISC BABOUT1.
           SELECT FO2 ASSIGN TO DISC BABOUT2.
       DATA DIVISION.
       FILE SECTION.
       FD  PARMF
           LABEL RECORD STANDARD.
       01  PARM-REC.
           03  P-TYPE         PIC XX.
           03  P-REST         PIC X(398).
       01  PARM-FILE-REC.
           03  FILLER         PIC XX.
           03  PF-NAME        PIC X(30).
           03  PF-LEN         PIC 9(5).
           03  FILLER         PIC X(363).
       01  PARM-MODE-REC.
           03  FILLER         PIC XX.
           03  PD-MODE        PIC X(3).
           03  PD-SEQ         PIC X.
           03  FILLER         PIC X(394).
       01  PARM-KEY-REC.
           03  FILLER         PIC XX.
           03  PK-POS         PIC 9(5).
           03  PK-LEN         PIC 9(5).
           03  FILLER         PIC X(388).
       01  PARM-REQ-REC.
           03  FILLER         PIC XX.
           03  PR-LEN         PIC 9(5).
           03  PR-VAL         PIC X(393).
       FD  FI1
           LABEL RECORD STANDARD
           RECORD VARYING IN SIZE FROM 1 TO 4001
           DEPENDING ON WS-IN-LEN.
       01  FI1-REC PIC X(4001).
       FD  FO1
           LABEL RECORD STANDARD.
       01  FO1-REC PIC X(4000).
       FD  FO2
           LABEL RECORD STANDARD.
       01  FO2-REC PIC X(4000).
       WORKING-STORAGE SECTION.
       01  RECIN              PIC X(4001).
       01  RECOUT             PIC X(4000).
       01  WS-IN              PIC X(4000).
       01  WS-KEY             PIC X(400).
       01  PREV-KEY           PIC X(400).
       77  WS-IN-LEN          PIC 9(5) COMP VALUE 0.
       77  P-INLEN            PIC 9(5) COMP VALUE 0.
       77  P-MODE             PIC X(3) VALUE 'ALL'.
       77  P-SEQ              PIC X VALUE 'N'.
       77  N-OUT              PIC 9(3) COMP VALUE 0.
       77  N-KF               PIC 9(3) COMP VALUE 0.
       77  N-RQ               PIC 9(3) COMP VALUE 0.
       77  I                  PIC 9(3) COMP VALUE 0.
       77  KP                 PIC 9(5) COMP VALUE 0.
       77  KEY-LEN            PIC 9(5) COMP VALUE 0.
       77  CP-LEN             PIC 9(5) COMP VALUE 0.
       77  TARGET             PIC 9 VALUE 1.
       77  DUP                PIC X VALUE 'N'.
       77  NB-LUS             PIC 9(10) COMP VALUE 0.
       77  NB-OUT1            PIC 9(10) COMP VALUE 0.
       77  NB-OUT2            PIC 9(10) COMP VALUE 0.
       77  NB-ELIM            PIC 9(10) COMP VALUE 0.
       77  NB-PREV            PIC 9(10) COMP VALUE 0.
       01  OUT-TAB.
           03  OUT-LEN        PIC 9(5) COMP OCCURS 2.
       01  KF-TAB.
           03  KF-ENT OCCURS 20.
               05  KF-POS     PIC 9(5) COMP.
               05  KF-LEN     PIC 9(5) COMP.
       01  RQ-TAB.
           03  RQ-ENT OCCURS 40.
               05  RQ-LEN     PIC 9(5) COMP.
               05  RQ-VAL     PIC X(393).
       01  DISPLAY-LINE.
           03  DISP-MESSAGE   PIC X(24).
           03  DISP-CT        PIC Z(11)9.
       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT PARMF.
       PARM-LECT.
           READ PARMF AT END GO TO PARM-FIN.
           IF P-TYPE = 'IN'
              MOVE PF-LEN TO P-INLEN.
           IF P-TYPE = 'OU'
              ADD 1 TO N-OUT
              MOVE PF-LEN TO OUT-LEN (N-OUT).
           IF P-TYPE = 'MD'
              MOVE PD-MODE TO P-MODE
              MOVE PD-SEQ TO P-SEQ.
           IF P-TYPE = 'KF'
              ADD 1 TO N-KF
              MOVE PK-POS TO KF-POS (N-KF)
              MOVE PK-LEN TO KF-LEN (N-KF).
           IF P-TYPE = 'RQ'
              ADD 1 TO N-RQ
              MOVE PR-LEN TO RQ-LEN (N-RQ)
              MOVE PR-VAL TO RQ-VAL (N-RQ).
           GO TO PARM-LECT.
       PARM-FIN.
           CLOSE PARMF.
           OPEN INPUT FI1.
           OPEN OUTPUT FO1.
           IF N-OUT > 1
              OPEN OUTPUT FO2.
       LECT.
           MOVE SPACES TO RECIN.
           READ FI1 INTO RECIN AT END GO TO FINW.
           ADD 1 TO NB-LUS.
           IF NB-LUS NOT < 99999999 GO TO FINW.
           MOVE SPACES TO WS-IN.
           MOVE WS-IN-LEN TO CP-LEN.
           IF CP-LEN > P-INLEN
              MOVE P-INLEN TO CP-LEN.
           IF CP-LEN > 0
              MOVE RECIN (1:CP-LEN) TO WS-IN (1:CP-LEN).
           MOVE SPACES TO WS-KEY.
           MOVE 1 TO KP.
           MOVE 1 TO I.
       KEY-LOOP.
           IF I > N-KF GO TO KEY-END.
           MOVE WS-IN (KF-POS (I):KF-LEN (I))
             TO WS-KEY (KP:KF-LEN (I)).
           ADD KF-LEN (I) TO KP.
           ADD 1 TO I.
           GO TO KEY-LOOP.
       KEY-END.
           COMPUTE KEY-LEN = KP - 1.
           MOVE 'N' TO DUP.
           IF P-SEQ = 'N' OR NB-LUS = 1 OR KEY-LEN = 0
              GO TO SEQ-END.
           IF WS-KEY (1:KEY-LEN) < PREV-KEY (1:KEY-LEN)
              GO TO SEQ-ABORT.
           IF P-SEQ = 'M' AND WS-KEY (1:KEY-LEN) = PREV-KEY (1:KEY-LEN)
              MOVE 'Y' TO DUP.
       SEQ-END.
           MOVE WS-KEY TO PREV-KEY.
           MOVE 1 TO TARGET.
           IF P-SEQ = 'M'
              IF DUP = 'Y'
                 MOVE 2 TO TARGET
                 GO TO ROUTE-END
              ELSE
                 GO TO ROUTE-END.
           IF P-MODE = 'ALL' GO TO ROUTE-END.
           MOVE 1 TO I.
       RQ-LOOP.
           IF I > N-RQ GO TO RQ-NONE.
           IF RQ-LEN (I) = KEY-LEN AND KEY-LEN > 0
              IF WS-KEY (1:KEY-LEN) = RQ-VAL (I) (1:KEY-LEN)
                 GO TO RQ-FOUND.
           ADD 1 TO I.
           GO TO RQ-LOOP.
       RQ-FOUND.
           IF P-MODE = 'E'
              MOVE 2 TO TARGET.
           GO TO ROUTE-END.
       RQ-NONE.
           IF P-MODE = 'R'
              MOVE 2 TO TARGET.
       ROUTE-END.
           IF TARGET > N-OUT
              ADD 1 TO NB-ELIM
              GO TO LECT.
           MOVE SPACES TO RECOUT.
           MOVE WS-IN (1:P-INLEN) TO RECOUT (1:OUT-LEN (TARGET)).
           IF TARGET = 1
              WRITE FO1-REC FROM RECOUT
              ADD 1 TO NB-OUT1
           ELSE
              WRITE FO2-REC FROM RECOUT
              ADD 1 TO NB-OUT2.
           GO TO LECT.
       SEQ-ABORT.
           COMPUTE NB-PREV = NB-LUS - 1.
           MOVE ' HAS SEQUENCE ERROR AT  ' TO DISP-MESSAGE.
           MOVE NB-PREV TO DISP-CT.
           DISPLAY DISPLAY-LINE UPON PRINTER.
           MOVE '               AND AT   ' TO DISP-MESSAGE.
           MOVE NB-LUS TO DISP-CT.
           DISPLAY DISPLAY-LINE UPON PRINTER.
           CLOSE FI1.
           CLOSE FO1.
           IF N-OUT > 1
              CLOSE FO2.
           CALL 'ABORT'.
           STOP RUN.
       FINW.
           MOVE '     RECORDS  READ      ' TO DISP-MESSAGE.
           MOVE NB-LUS TO DISP-CT.
           DISPLAY DISPLAY-LINE UPON PRINTER.
           MOVE '    RECORDS WRITTEN 1   ' TO DISP-MESSAGE.
           MOVE NB-OUT1 TO DISP-CT.
           DISPLAY DISPLAY-LINE UPON PRINTER.
           MOVE '    RECORDS WRITTEN 2   ' TO DISP-MESSAGE.
           MOVE NB-OUT2 TO DISP-CT.
           DISPLAY DISPLAY-LINE UPON PRINTER.
           MOVE '    RECORDS ELIMINATED  ' TO DISP-MESSAGE.
           MOVE NB-ELIM TO DISP-CT.
           DISPLAY DISPLAY-LINE UPON PRINTER.
           CLOSE FI1.
           CLOSE FO1.
           IF N-OUT > 1
              CLOSE FO2.
           STOP RUN.
