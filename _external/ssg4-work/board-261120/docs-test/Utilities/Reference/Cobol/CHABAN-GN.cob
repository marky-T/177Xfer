       IDENTIFICATION DIVISION.
      * SSG-4 (MT-043): one CHABAN for every CHABAN and CHAB100 call.
      * Builds records from the run's data images (input CHAIN, the
      * Accept file mapped by the skeleton hand-off). Card length,
      * output length and record counts come from SGSPARM; see
      * _scratch\spike-chaban\spec.md.
       PROGRAM-ID. 'CHABAN-GN'.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. UNIVAC-1100-10.
       OBJECT-COMPUTER. UNIVAC-1100-10.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PARMF ASSIGN TO DISC SGSPARM.
           SELECT FI1 ASSIGN TO DISC CHAIN.
           SELECT FO1 ASSIGN TO DISC CHAOUT.
       DATA DIVISION.
       FILE SECTION.
       FD  PARMF
           LABEL RECORD STANDARD.
       01  PARM-REC.
           03  P-TYPE         PIC XX.
           03  P-REST         PIC X(78).
       01  PARM-FILE-REC.
           03  FILLER         PIC XX.
           03  PF-NAME        PIC X(30).
           03  PF-LEN         PIC 9(5).
           03  FILLER         PIC X(43).
       01  PARM-NB-REC.
           03  FILLER         PIC XX.
           03  PN-REC         PIC 9(5).
           03  PN-PER         PIC 9(5).
           03  FILLER         PIC X(68).
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
       01  WS-REC             PIC X(4200).
       77  WS-IN-LEN          PIC 9(5) COMP VALUE 0.
       77  P-CARD             PIC 9(5) COMP VALUE 80.
       77  P-LEN              PIC 9(5) COMP VALUE 0.
       77  N-REC              PIC 9(5) COMP VALUE 0.
       77  N-PER              PIC 9(5) COMP VALUE 0.
       77  R                  PIC 9(5) COMP VALUE 0.
       77  C                  PIC 9(5) COMP VALUE 0.
       77  KP                 PIC 9(5) COMP VALUE 0.
       77  CP-LEN             PIC 9(5) COMP VALUE 0.
       77  NB-CARDS           PIC 9(10) COMP VALUE 0.
       77  NB-OUT             PIC 9(10) COMP VALUE 0.
       01  DISPLAY-LINE.
           03  DISP-MESSAGE   PIC X(24).
           03  DISP-CT        PIC Z(11)9.
       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT PARMF.
       PARM-LECT.
           READ PARMF AT END GO TO PARM-FIN.
           IF P-TYPE = 'IN'
              MOVE PF-LEN TO P-CARD.
           IF P-TYPE = 'OU'
              MOVE PF-LEN TO P-LEN.
           IF P-TYPE = 'NB'
              MOVE PN-REC TO N-REC
              MOVE PN-PER TO N-PER.
           GO TO PARM-LECT.
       PARM-FIN.
           CLOSE PARMF.
           OPEN INPUT FI1.
           OPEN OUTPUT FO1.
           MOVE 0 TO R.
       REC-LOOP.
           IF R NOT < N-REC GO TO FINW.
           MOVE SPACES TO WS-REC.
           MOVE 1 TO KP.
           MOVE 0 TO C.
       CARD-LOOP.
           IF C NOT < N-PER GO TO REC-WRITE.
           MOVE SPACES TO RECIN.
           READ FI1 INTO RECIN AT END GO TO FINW.
           ADD 1 TO NB-CARDS.
           MOVE WS-IN-LEN TO CP-LEN.
           IF CP-LEN > P-CARD
              MOVE P-CARD TO CP-LEN.
           IF CP-LEN > 0
              MOVE RECIN (1:CP-LEN) TO WS-REC (KP:CP-LEN).
           ADD P-CARD TO KP.
           ADD 1 TO C.
           GO TO CARD-LOOP.
       REC-WRITE.
           WRITE FO1-REC FROM WS-REC.
           ADD 1 TO NB-OUT.
           ADD 1 TO R.
           GO TO REC-LOOP.
       FINW.
           MOVE '    DATA CARDS READ     ' TO DISP-MESSAGE.
           MOVE NB-CARDS TO DISP-CT.
           DISPLAY DISPLAY-LINE UPON PRINTER.
           MOVE '    RECORDS WRITTEN     ' TO DISP-MESSAGE.
           MOVE NB-OUT TO DISP-CT.
           DISPLAY DISPLAY-LINE UPON PRINTER.
           CLOSE FI1.
           CLOSE FO1.
           STOP RUN.
