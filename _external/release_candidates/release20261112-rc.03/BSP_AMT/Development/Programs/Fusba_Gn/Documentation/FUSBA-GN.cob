       IDENTIFICATION DIVISION.
      * SSG-4 (MT-043): one FUSBA for every FUSBA and FUSBA2 call.
      * Files, key fields, mode and field moves come from the SGSPARM
      * file written by the skeleton hand-off; see
      * _scratch\spike-fusba\spec.md. File 1 = update file, file 2 =
      * master. Modes: C split, D delete, U update, M update with
      * several masters per key (FUSBA2).
       PROGRAM-ID. 'FUSBA-GN'.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. UNIVAC-1100-10.
       OBJECT-COMPUTER. UNIVAC-1100-10.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PARMF ASSIGN TO DISC SGSPARM.
           SELECT FI1 ASSIGN TO DISC FUSIN1.
           SELECT FI2 ASSIGN TO DISC FUSIN2.
           SELECT FO1 ASSIGN TO DISC FUSOUT1.
           SELECT FO2 ASSIGN TO DISC FUSOUT2.
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
       01  PARM-MODE-REC.
           03  FILLER         PIC XX.
           03  PD-MODE        PIC X.
           03  FILLER         PIC X(77).
       01  PARM-KEY-REC.
           03  FILLER         PIC XX.
           03  PK-POS         PIC 9(5).
           03  PK-LEN         PIC 9(5).
           03  FILLER         PIC X(68).
       01  PARM-MOVE-REC.
           03  FILLER         PIC XX.
           03  PM-IPOS        PIC 9(5).
           03  PM-ILEN        PIC 9(5).
           03  PM-OPOS        PIC 9(5).
           03  PM-OLEN        PIC 9(5).
           03  FILLER         PIC X(58).
       FD  FI1
           LABEL RECORD STANDARD
           RECORD VARYING IN SIZE FROM 1 TO 4001
           DEPENDING ON WS-LEN1.
       01  FI1-REC PIC X(4001).
       FD  FI2
           LABEL RECORD STANDARD
           RECORD VARYING IN SIZE FROM 1 TO 4001
           DEPENDING ON WS-LEN2.
       01  FI2-REC PIC X(4001).
       FD  FO1
           LABEL RECORD STANDARD.
       01  FO1-REC PIC X(4000).
       FD  FO2
           LABEL RECORD STANDARD.
       01  FO2-REC PIC X(4000).
       WORKING-STORAGE SECTION.
       01  RECIN              PIC X(4001).
       01  REC1               PIC X(4000).
       01  REC2               PIC X(4000).
       01  RECOUT             PIC X(4000).
       01  KEY1               PIC X(400).
       01  KEY2               PIC X(400).
       01  PREV-KEY2          PIC X(400).
       77  WS-LEN1            PIC 9(5) COMP VALUE 0.
       77  WS-LEN2            PIC 9(5) COMP VALUE 0.
       77  P-LEN1             PIC 9(5) COMP VALUE 0.
       77  P-LEN2             PIC 9(5) COMP VALUE 0.
       77  N-IN               PIC 9(3) COMP VALUE 0.
       77  N-OUT              PIC 9(3) COMP VALUE 0.
       77  P-MODE             PIC X VALUE 'C'.
       77  N-K1               PIC 9(3) COMP VALUE 0.
       77  N-K2               PIC 9(3) COMP VALUE 0.
       77  N-FM               PIC 9(3) COMP VALUE 0.
       77  I                  PIC 9(3) COMP VALUE 0.
       77  KP                 PIC 9(5) COMP VALUE 0.
       77  KL                 PIC 9(5) COMP VALUE 0.
       77  KL2                PIC 9(5) COMP VALUE 0.
       77  CP-LEN             PIC 9(5) COMP VALUE 0.
       77  TARGET             PIC 9 VALUE 1.
       77  EOF1               PIC X VALUE 'N'.
       77  EOF2               PIC X VALUE 'N'.
       77  NB-LUS1            PIC 9(10) COMP VALUE 0.
       77  NB-LUS2            PIC 9(10) COMP VALUE 0.
       77  NB-OUT1            PIC 9(10) COMP VALUE 0.
       77  NB-OUT2            PIC 9(10) COMP VALUE 0.
       77  NB-MAJ             PIC 9(10) COMP VALUE 0.
       77  NB-DEL             PIC 9(10) COMP VALUE 0.
       01  OUT-TAB.
           03  OUT-LEN        PIC 9(5) COMP OCCURS 2.
       01  K1-TAB.
           03  K1-ENT OCCURS 20.
               05  K1-POS     PIC 9(5) COMP.
               05  K1-LEN     PIC 9(5) COMP.
       01  K2-TAB.
           03  K2-ENT OCCURS 20.
               05  K2-POS     PIC 9(5) COMP.
               05  K2-LEN     PIC 9(5) COMP.
       01  FM-TAB.
           03  FM-ENT OCCURS 20.
               05  FM-IPOS    PIC 9(5) COMP.
               05  FM-ILEN    PIC 9(5) COMP.
               05  FM-OPOS    PIC 9(5) COMP.
               05  FM-OLEN    PIC 9(5) COMP.
       01  DISPLAY-LINE.
           03  DISP-MESSAGE   PIC X(24).
           03  DISP-CT        PIC Z(11)9.
       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT PARMF.
       PARM-LECT.
           READ PARMF AT END GO TO PARM-FIN.
           IF P-TYPE = 'IN'
              ADD 1 TO N-IN
              IF N-IN = 1
                 MOVE PF-LEN TO P-LEN1
              ELSE
                 MOVE PF-LEN TO P-LEN2.
           IF P-TYPE = 'OU'
              ADD 1 TO N-OUT
              MOVE PF-LEN TO OUT-LEN (N-OUT).
           IF P-TYPE = 'MD'
              MOVE PD-MODE TO P-MODE.
           IF P-TYPE = 'K1'
              ADD 1 TO N-K1
              MOVE PK-POS TO K1-POS (N-K1)
              MOVE PK-LEN TO K1-LEN (N-K1)
              ADD PK-LEN TO KL.
           IF P-TYPE = 'K2'
              ADD 1 TO N-K2
              MOVE PK-POS TO K2-POS (N-K2)
              MOVE PK-LEN TO K2-LEN (N-K2)
              ADD PK-LEN TO KL2.
           IF P-TYPE = 'FM'
              ADD 1 TO N-FM
              MOVE PM-IPOS TO FM-IPOS (N-FM)
              MOVE PM-ILEN TO FM-ILEN (N-FM)
              MOVE PM-OPOS TO FM-OPOS (N-FM)
              MOVE PM-OLEN TO FM-OLEN (N-FM).
           GO TO PARM-LECT.
       PARM-FIN.
           CLOSE PARMF.
      * Keys of different lengths: the shorter one is space-padded.
           IF KL2 > KL
              MOVE KL2 TO KL.
           OPEN INPUT FI1.
           OPEN INPUT FI2.
           OPEN OUTPUT FO1.
           IF N-OUT > 1
              OPEN OUTPUT FO2.
           PERFORM READ-1 THRU READ-1-END.
           PERFORM READ-2 THRU READ-2-END.
       FUSION.
           IF EOF1 = 'Y' AND EOF2 = 'Y'
              GO TO FINW.
           IF KEY1 (1:KL) < KEY2 (1:KL)
              PERFORM READ-1 THRU READ-1-END
              GO TO FUSION.
           IF KEY1 (1:KL) > KEY2 (1:KL)
              MOVE 1 TO TARGET
              PERFORM WRITE-MASTER
              PERFORM READ-2 THRU READ-2-END
              GO TO FUSION.
           IF P-MODE = 'C'
              MOVE 2 TO TARGET
              PERFORM WRITE-MASTER
              PERFORM READ-2 THRU READ-2-END
              GO TO FUSION.
           IF P-MODE = 'D'
              ADD 1 TO NB-DEL
              PERFORM READ-2 THRU READ-2-END
              GO TO FUSION.
           PERFORM WRITE-UPDATED THRU WRITE-UPDATED-END.
           IF P-MODE = 'U'
              PERFORM READ-1 THRU READ-1-END
              PERFORM READ-2 THRU READ-2-END
              GO TO FUSION.
      * M (FUSBA2): the same update record serves every master with
      * this key; read file 1 when the master key moves on.
           MOVE KEY2 TO PREV-KEY2.
           PERFORM READ-2 THRU READ-2-END.
           IF KEY2 (1:KL) > PREV-KEY2 (1:KL)
              PERFORM READ-1 THRU READ-1-END.
           GO TO FUSION.
       READ-1.
           MOVE SPACES TO RECIN.
           READ FI1 INTO RECIN AT END MOVE 'Y' TO EOF1.
           IF EOF1 = 'Y'
              MOVE HIGH-VALUES TO KEY1
              GO TO READ-1-END.
           ADD 1 TO NB-LUS1.
           MOVE SPACES TO REC1.
           MOVE WS-LEN1 TO CP-LEN.
           IF CP-LEN > P-LEN1
              MOVE P-LEN1 TO CP-LEN.
           IF CP-LEN > 0
              MOVE RECIN (1:CP-LEN) TO REC1 (1:CP-LEN).
           MOVE SPACES TO KEY1.
           MOVE 1 TO KP.
           MOVE 1 TO I.
       KEY1-LOOP.
           IF I > N-K1 GO TO READ-1-END.
           MOVE REC1 (K1-POS (I):K1-LEN (I))
             TO KEY1 (KP:K1-LEN (I)).
           ADD K1-LEN (I) TO KP.
           ADD 1 TO I.
           GO TO KEY1-LOOP.
       READ-1-END.
           EXIT.
       READ-2.
           MOVE SPACES TO RECIN.
           READ FI2 INTO RECIN AT END MOVE 'Y' TO EOF2.
           IF EOF2 = 'Y'
              MOVE HIGH-VALUES TO KEY2
              GO TO READ-2-END.
           ADD 1 TO NB-LUS2.
           MOVE SPACES TO REC2.
           MOVE WS-LEN2 TO CP-LEN.
           IF CP-LEN > P-LEN2
              MOVE P-LEN2 TO CP-LEN.
           IF CP-LEN > 0
              MOVE RECIN (1:CP-LEN) TO REC2 (1:CP-LEN).
           MOVE SPACES TO KEY2.
           MOVE 1 TO KP.
           MOVE 1 TO I.
       KEY2-LOOP.
           IF I > N-K2 GO TO READ-2-END.
           MOVE REC2 (K2-POS (I):K2-LEN (I))
             TO KEY2 (KP:K2-LEN (I)).
           ADD K2-LEN (I) TO KP.
           ADD 1 TO I.
           GO TO KEY2-LOOP.
       READ-2-END.
           EXIT.
       WRITE-MASTER.
           MOVE SPACES TO RECOUT.
           MOVE REC2 (1:P-LEN2) TO RECOUT (1:OUT-LEN (TARGET)).
           IF TARGET = 1
              WRITE FO1-REC FROM RECOUT
              ADD 1 TO NB-OUT1
           ELSE
              WRITE FO2-REC FROM RECOUT
              ADD 1 TO NB-OUT2.
       WRITE-UPDATED.
           MOVE SPACES TO RECOUT.
           MOVE REC2 (1:P-LEN2) TO RECOUT (1:OUT-LEN (1)).
           MOVE 1 TO I.
       MOVE-LOOP.
           IF I > N-FM GO TO MOVE-END.
           MOVE REC1 (FM-IPOS (I):FM-ILEN (I))
             TO RECOUT (FM-OPOS (I):FM-OLEN (I)).
           ADD 1 TO I.
           GO TO MOVE-LOOP.
       MOVE-END.
           WRITE FO1-REC FROM RECOUT.
           ADD 1 TO NB-OUT1.
           ADD 1 TO NB-MAJ.
       WRITE-UPDATED-END.
           EXIT.
       FINW.
           MOVE '   RECORDS READ FILE 1  ' TO DISP-MESSAGE.
           MOVE NB-LUS1 TO DISP-CT.
           DISPLAY DISPLAY-LINE UPON PRINTER.
           MOVE '   RECORDS READ FILE 2  ' TO DISP-MESSAGE.
           MOVE NB-LUS2 TO DISP-CT.
           DISPLAY DISPLAY-LINE UPON PRINTER.
           MOVE '    RECORDS WRITTEN 1   ' TO DISP-MESSAGE.
           MOVE NB-OUT1 TO DISP-CT.
           DISPLAY DISPLAY-LINE UPON PRINTER.
           MOVE '    RECORDS WRITTEN 2   ' TO DISP-MESSAGE.
           MOVE NB-OUT2 TO DISP-CT.
           DISPLAY DISPLAY-LINE UPON PRINTER.
           MOVE '    RECORDS UPDATED     ' TO DISP-MESSAGE.
           MOVE NB-MAJ TO DISP-CT.
           DISPLAY DISPLAY-LINE UPON PRINTER.
           MOVE '    RECORDS DELETED     ' TO DISP-MESSAGE.
           MOVE NB-DEL TO DISP-CT.
           DISPLAY DISPLAY-LINE UPON PRINTER.
           CLOSE FI1.
           CLOSE FI2.
           CLOSE FO1.
           IF N-OUT > 1
              CLOSE FO2.
           STOP RUN.
