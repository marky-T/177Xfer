       IDENTIFICATION DIVISION.
      * SSG-4 (MT-069): one RECAP for every call. Field, amount, key
      * and NEURO lists come from the SGSPARM file written by the
      * skeleton hand-off; behaviour: Generic/RECAP/spec.md. The RDMS
      * session of the skeleton is not kept (spec A2); EUU003 is
      * called as in the skeleton (spec A3).
       PROGRAM-ID. 'RECAP-GN'.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. UNIVAC-1100-10.
       OBJECT-COMPUTER. UNIVAC-1100-10.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PARMF ASSIGN TO DISC SGSPARM.
           SELECT FI1 ASSIGN TO DISC RECAPIN.
           SELECT FO1 ASSIGN TO DISC RECAPOUT.
       DATA DIVISION.
       FILE SECTION.
       FD  PARMF
           LABEL RECORD STANDARD.
       01  PARM-REC.
           03  P-TYPE         PIC XX.
           03  P-POS          PIC 9(5).
           03  P-LEN          PIC 9(5).
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
       01  WS-IN              PIC X(4001).
       01  RECOUT             PIC X(4000).
       01  WS-KEY             PIC X(4001).
       01  PREV-KEY           PIC X(4001).
       77  WS-IN-LEN          PIC 9(5) COMP VALUE 0.
       77  P-INLEN            PIC 9(5) COMP VALUE 0.
       77  P-OUTLEN           PIC 9(5) COMP VALUE 0.
       77  CP-LEN             PIC 9(5) COMP VALUE 0.
       77  KP                 PIC 9(5) COMP VALUE 0.
       77  KEY-LEN            PIC 9(5) COMP VALUE 0.
       77  N-FI               PIC 9(3) COMP VALUE 0.
       77  N-FO               PIC 9(3) COMP VALUE 0.
       77  N-TI               PIC 9(3) COMP VALUE 0.
       77  N-TO               PIC 9(3) COMP VALUE 0.
       77  N-IN               PIC 9(3) COMP VALUE 0.
       77  I                  PIC 9(3) COMP VALUE 0.
       77  AP                 PIC 9(3) COMP VALUE 0.
       77  TESTFIN            PIC 9 VALUE 0.
       77  PREMIER            PIC 9 VALUE 0.
       77  NB-LUS             PIC 9(10) COMP VALUE 0.
       77  NB-ECR             PIC 9(10) COMP VALUE 0.
       01  FI-TAB.
           03  FI-ENT OCCURS 50.
               05  FI-POS     PIC 9(5) COMP.
               05  FI-LEN     PIC 9(5) COMP.
       01  FO-TAB.
           03  FO-ENT OCCURS 50.
               05  FO-POS     PIC 9(5) COMP.
               05  FO-LEN     PIC 9(5) COMP.
       01  TI-TAB.
           03  TI-ENT OCCURS 30.
               05  TI-POS     PIC 9(5) COMP.
               05  TI-LEN     PIC 9(5) COMP.
       01  TO-TAB.
           03  TO-ENT OCCURS 30.
               05  TO-POS     PIC 9(5) COMP.
               05  TO-LEN     PIC 9(5) COMP.
       01  IN-TAB.
           03  IN-ENT OCCURS 30.
               05  IN-POS     PIC 9(5) COMP.
               05  IN-LEN     PIC 9(5) COMP.
       01  NE-TAB.
           03  NE-FLAG        PIC X OCCURS 30.
       01  AMOUNTS.
           03  REC-AMT        PIC S9(18) OCCURS 30.
           03  TOT-GRP        PIC S9(18) OCCURS 30.
           03  TOTAL-LU       PIC S9(18) OCCURS 30.
           03  MONT           PIC S9(18) OCCURS 30.
      * an amount, right-aligned in 18 digits (skeleton TOTAL<i>)
       01  WS-AMT             PIC S9(18).
       01  WS-AMT-X REDEFINES WS-AMT PIC X(18).
      * a sum written into the output (skeleton TOTAL-O<i>)
       01  WS-SUM             PIC S9(18).
       01  WS-SUM-X REDEFINES WS-SUM PIC X(18).
      * a grand total before DISPLAY (skeleton TOTAL-LU<i>, MONT<i>)
       01  WS-T18             PIC S9(18).
       01  WS-T18-X REDEFINES WS-T18 PIC X(18).
       01  WS-CNT             PIC 9(6).
       01  WS-CNT-X REDEFINES WS-CNT PIC X(6).
      * EUW002 and WS-CMT-PGM: as in SSG-Source/RECAP.TXT 187-256
       01  EUW002.
           03  WS-PTR-ENE.
               05  WS-PTR-ENE-MON-ENE.
                   07  MT-ENE              PIC S9(17).
                   07  MT-ENE-SGN          PIC X(01).
                   07  MT-ENE-CHI          PIC 9(02).
               05  WS-PTR-ENE-MON-SRT.
                   07  LG-MAX-MON-SRT      PIC 9(03).
                   07  CD-FMT-MON-SRT      PIC X(01).
                   07  WS-PTR-FAC-MON-SRT.
                       09  FL-IMP-APO      PIC X(01).
                       09  FL-IMP-EUR      PIC X(01).
                       09  FL-IMP-BEF      PIC X(01).
                       09  FL-PLT-SGN      PIC X(01).
                       09  FL-TRD-SGN      PIC X(01).
                       09  FL-SGN-FIX      PIC X(01).
                       09  FL-SGN-VUE      PIC X(01).
                       09  FL-CAD-PRC      PIC X(01).
                       09  FL-CAD-CNV      PIC X(01).
                       09  FL-IMP-PNT      PIC X(01).
                       09  FL-000          PIC X(01).
                       09  CD-DET-MON      PIC X(01).
                       09  FILLER          PIC X(19).
           03  WS-PTR-SRT.
               05  WS-MON-SRT-001.
                   07  MT-SRT              PIC X(100).
               05  WS-MON-SRT-002.
                   07  MT-SRT-PRC          PIC X(50).
                   07  MT-SRT-CNV          PIC X(50).
                   07  TL-PTH-GCH          PIC X(01).
                   07  TL-PTH-DRT          PIC X(01).
               05  LG-MON-SRT              PIC 9(02).
               05  LB-DVI-PRC              PIC X(03).
               05  LB-DVI-CNV              PIC X(03).
           03  WS-PTR-ENE-SRT.
               05  FILLER                  PIC X(10).
           03  WS-IFN-EUR.
               05  FILLER                  PIC X(10).
       01  WS-CMT-PGM.
           03  NM-PGM-APL               PIC X(08).
           03  NM-NOM-ENV               PIC X(08).
           03  NM-NOM-COP               PIC X(08).
           03  NM-NOM-DEM               PIC X(08).
           03  VL-CDE-RET               PIC S9(04).
           03  VL-MOT-CDE               PIC S9(04).
           03  LB-MSG-RET               PIC X(30).
           03  CD-DBG-PRG               PIC X(1).
           03  FILLER                   PIC X(7).
           03  VL-CHP-TSF               PIC X(3922).
       PROCEDURE DIVISION.
       DEBUT.
           MOVE ALL 'N' TO NE-TAB.
           OPEN INPUT PARMF.
       PARM-LECT.
           READ PARMF AT END GO TO PARM-FIN.
           IF P-TYPE = 'HD'
              MOVE P-POS TO P-INLEN
              MOVE P-LEN TO P-OUTLEN.
           IF P-TYPE = 'FI'
              ADD 1 TO N-FI
              MOVE P-POS TO FI-POS (N-FI)
              MOVE P-LEN TO FI-LEN (N-FI).
           IF P-TYPE = 'FO'
              ADD 1 TO N-FO
              MOVE P-POS TO FO-POS (N-FO)
              MOVE P-LEN TO FO-LEN (N-FO).
           IF P-TYPE = 'TI'
              ADD 1 TO N-TI
              MOVE P-POS TO TI-POS (N-TI)
              MOVE P-LEN TO TI-LEN (N-TI).
           IF P-TYPE = 'TO'
              ADD 1 TO N-TO
              MOVE P-POS TO TO-POS (N-TO)
              MOVE P-LEN TO TO-LEN (N-TO).
           IF P-TYPE = 'IN'
              ADD 1 TO N-IN
              MOVE P-POS TO IN-POS (N-IN)
              MOVE P-LEN TO IN-LEN (N-IN).
           IF P-TYPE = 'NE'
              MOVE 'Y' TO NE-FLAG (P-POS).
           GO TO PARM-LECT.
       PARM-FIN.
           CLOSE PARMF.
           MOVE ZEROES TO AMOUNTS.
           MOVE 'RECAP'     TO NM-PGM-APL   OF WS-CMT-PGM.
           MOVE 'BATCH'     TO NM-NOM-ENV   OF WS-CMT-PGM.
           MOVE 'Y'         TO CD-DBG-PRG   OF WS-CMT-PGM.
           MOVE 'EUW002'    TO NM-NOM-COP   OF WS-CMT-PGM.
           MOVE 'SERVICE1'  TO NM-NOM-DEM   OF WS-CMT-PGM.
           MOVE SPACES      TO WS-PTR-ENE   OF EUW002.
           MOVE 'R'         TO FL-PLT-SGN   OF EUW002.
           MOVE '2'         TO FL-TRD-SGN   OF EUW002.
           MOVE 'Y'         TO MT-ENE-SGN   OF EUW002.
           MOVE '1'         TO CD-FMT-MON-SRT  OF EUW002.
           MOVE 'Y'         TO FL-IMP-PNT      OF EUW002.
           MOVE 'N'         TO FL-000          OF EUW002.
           OPEN INPUT FI1.
           OPEN OUTPUT FO1.
           MOVE SPACES TO RECOUT.
       LECT.
           MOVE SPACES TO RECIN.
           READ FI1 INTO RECIN AT END
              MOVE 1 TO TESTFIN
              GO TO RUPTURE.
           ADD 1 TO NB-LUS.
           MOVE SPACES TO WS-IN.
           MOVE WS-IN-LEN TO CP-LEN.
           IF CP-LEN > P-INLEN
              MOVE P-INLEN TO CP-LEN.
           IF CP-LEN > 0
              MOVE RECIN (1:CP-LEN) TO WS-IN (1:CP-LEN).
      * amounts: not numeric -> spaces become 0 in the record (spec A6)
           MOVE 1 TO I.
       AMT-LOOP.
           IF I > N-TI GO TO AMT-END.
           PERFORM AMT-LOAD.
           IF WS-AMT NOT NUMERIC
              INSPECT WS-IN (TI-POS (I):TI-LEN (I))
                REPLACING ALL SPACE BY '0'
              PERFORM AMT-LOAD.
           MOVE WS-AMT TO REC-AMT (I).
           ADD WS-AMT TO TOTAL-LU (I).
           ADD 1 TO I.
           GO TO AMT-LOOP.
       AMT-END.
      * key = the INDIC parts in card order
           MOVE SPACES TO WS-KEY.
           MOVE 1 TO KP.
           MOVE 1 TO I.
       KEY-LOOP.
           IF I > N-IN GO TO KEY-END.
           MOVE WS-IN (IN-POS (I):IN-LEN (I))
             TO WS-KEY (KP:IN-LEN (I)).
           ADD IN-LEN (I) TO KP.
           ADD 1 TO I.
           GO TO KEY-LOOP.
       KEY-END.
           COMPUTE KEY-LEN = KP - 1.
           IF PREMIER = 0
              MOVE 1 TO PREMIER
              GO TO EGALITE.
           IF PREV-KEY (1:KEY-LEN) > WS-KEY (1:KEY-LEN)
              GO TO ERR-SEQ.
           IF PREV-KEY (1:KEY-LEN) NOT = WS-KEY (1:KEY-LEN)
              GO TO RUPTURE.
           GO TO EGALITE.
       RUPTURE.
           MOVE 1 TO I.
       RUP-LOOP.
           IF I > N-TO GO TO RUP-WRITE.
           MOVE TOT-GRP (I) TO WS-SUM.
           COMPUTE AP = 19 - TO-LEN (I).
           MOVE WS-SUM-X (AP:TO-LEN (I))
             TO RECOUT (TO-POS (I):TO-LEN (I)).
           MOVE ZEROES TO TOT-GRP (I).
           ADD 1 TO I.
           GO TO RUP-LOOP.
       RUP-WRITE.
           WRITE FO1-REC FROM RECOUT.
           MOVE SPACES TO RECOUT.
           ADD 1 TO NB-ECR.
           IF TESTFIN = 1 GO TO FINW.
       EGALITE.
           MOVE 1 TO I.
       EGA-LOOP.
           IF I > N-FI GO TO EGA-TOT.
           MOVE WS-IN (FI-POS (I):FI-LEN (I))
             TO RECOUT (FO-POS (I):FO-LEN (I)).
           ADD 1 TO I.
           GO TO EGA-LOOP.
       EGA-TOT.
           MOVE 1 TO I.
       EGA-TLOOP.
           IF I > N-TO GO TO EGA-END.
           ADD REC-AMT (I) TO TOT-GRP (I) MONT (I).
           ADD 1 TO I.
           GO TO EGA-TLOOP.
       EGA-END.
           MOVE WS-KEY TO PREV-KEY.
           GO TO LECT.
       ERR-SEQ.
           DISPLAY '**ANCIEN INDIC** ' PREV-KEY (1:KEY-LEN).
           DISPLAY '**NOUVEL INDIC** ' WS-KEY (1:KEY-LEN).
           DISPLAY '**ERREUR DE SEQUENCE** '.
           CLOSE FI1.
           CLOSE FO1.
           CALL 'ABORT'.
           STOP RUN.
       FINW.
           DISPLAY  '*RECAP  FIN*'  UPON  PRINTER.
           MOVE NB-LUS TO WS-CNT.
           INSPECT WS-CNT-X REPLACING LEADING '0' BY SPACE.
           DISPLAY  '*NB-ENREG-LUS ='  WS-CNT-X  UPON  PRINTER.
           MOVE 1 TO I.
       FIN-LU.
           IF I > N-TI GO TO FIN-ECR.
           MOVE TOTAL-LU (I) TO WS-T18.
           PERFORM FIN-TOTAL.
           ADD 1 TO I.
           GO TO FIN-LU.
       FIN-ECR.
           MOVE NB-ECR TO WS-CNT.
           INSPECT WS-CNT-X REPLACING LEADING '0' BY SPACE.
           DISPLAY  '*NB-ENREG-ECR ='  WS-CNT-X  UPON  PRINTER.
           MOVE 1 TO I.
       FIN-MONT.
           IF I > N-TO GO TO FIN-END.
           MOVE MONT (I) TO WS-T18.
           PERFORM FIN-TOTAL.
           ADD 1 TO I.
           GO TO FIN-MONT.
       FIN-END.
           CLOSE  FI1.
           CLOSE  FO1.
           STOP RUN.
      * one grand-total line: raw when listed on NEURO, else EUU003
       FIN-TOTAL.
           INSPECT WS-T18-X REPLACING LEADING '0' BY SPACE.
           IF NE-FLAG (I) = 'Y'
              DISPLAY WS-T18-X UPON PRINTER
           ELSE
              MOVE 17     TO MT-ENE-CHI OF EUW002
              MOVE 25     TO LG-MAX-MON-SRT OF EUW002
              MOVE WS-T18 TO MT-ENE OF EUW002
              MOVE EUW002       TO VL-CHP-TSF  OF WS-CMT-PGM
              CALL 'EUU003'     USING WS-CMT-PGM
              MOVE VL-CHP-TSF   OF WS-CMT-PGM TO EUW002
              DISPLAY MT-SRT    OF EUW002 UPON PRINTER.
      * amount I of WS-IN, right-aligned with leading zeros in WS-AMT
       AMT-LOAD.
           MOVE ALL '0' TO WS-AMT-X.
           COMPUTE AP = 19 - TI-LEN (I).
           MOVE WS-IN (TI-POS (I):TI-LEN (I))
             TO WS-AMT-X (AP:TI-LEN (I)).
