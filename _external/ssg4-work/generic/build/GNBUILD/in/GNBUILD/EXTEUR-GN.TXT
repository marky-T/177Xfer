       IDENTIFICATION DIVISION.
      * SSG-4 (MT-069): one EXTEUR for every call. Record length,
      * currency field, target and amounts come from the SGSPARM
      * file written by the skeleton hand-off (the hand-off reads the
      * phase in EU001, spec A1/A2); behaviour: Generic/EXTEUR/spec.md.
       PROGRAM-ID. 'EXTEUR-GN'.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. UNIVAC-1100-10.
       OBJECT-COMPUTER. UNIVAC-1100-10.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PARMF ASSIGN TO DISC SGSPARM.
           SELECT FI1 ASSIGN TO DISC EXTIN.
           SELECT FO1 ASSIGN TO DISC EXTOUT.
           SELECT FO2 ASSIGN TO DISC EXTANO.
       DATA DIVISION.
       FILE SECTION.
       FD  PARMF
           LABEL RECORD STANDARD.
       01  PARM-REC.
           03  P-TYPE         PIC XX.
           03  P-POS          PIC 9(5).
           03  P-LEN          PIC 9(5).
           03  P-DLEN         PIC 9(5).
           03  P-TARGET       PIC X(3).
           03  P-PHA          PIC X(3).
           03  P-C1           PIC X(3).
           03  P-C2           PIC X(3).
           03  FILLER         PIC X(51).
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
       01  WS-IN              PIC X(4001).
       01  WS-OUT             PIC X(4000).
       77  WS-IN-LEN          PIC 9(5) COMP VALUE 0.
       77  CP-LEN             PIC 9(5) COMP VALUE 0.
       77  P-LONG             PIC 9(5) COMP VALUE 0.
       77  D-POS              PIC 9(5) COMP VALUE 0.
       77  D-LEN              PIC 9(5) COMP VALUE 0.
       77  N-MT               PIC 9(3) COMP VALUE 0.
       77  I                  PIC 9(3) COMP VALUE 0.
       77  K                  PIC 9(3) COMP VALUE 0.
       77  L                  PIC 9(3) COMP VALUE 0.
       77  AP                 PIC 9(3) COMP VALUE 0.
       77  FPOS               PIC 9(5) COMP VALUE 0.
       77  NDIG               PIC 9(3) COMP VALUE 0.
       77  SW-END             PIC 9 VALUE 0.
       77  SW-ERREUR          PIC 9 VALUE 0.
       77  WS-MAJ             PIC 9 VALUE 0.
       77  WS-NEG             PIC 9 VALUE 0.
       77  WS-FORM            PIC X VALUE SPACE.
       77  WS-D               PIC 9 VALUE 0.
       01  WS-TARGET          PIC X(3).
       01  WS-PHA             PIC X(3).
       01  WS-C1              PIC X(3).
       01  WS-C2              PIC X(3).
       01  WS-OWN             PIC X(3).
       01  WS-DEV             PIC X(3).
      * counters as the skeleton (MAJ: no VALUE there, spec A5)
       01  WS-NB-REC-LUS      PIC 9(10) VALUE 0.
       01  WS-NB-REC-MAJ      PIC 9(10) VALUE 0.
       01  WS-NB-REC-ERR      PIC 9(8) VALUE 0.
       01  MT-TAB.
           03  MT-ENT OCCURS 50.
               05  MT-POS     PIC 9(5) COMP.
               05  MT-LEN     PIC 9(5) COMP.
      * an amount field, left-aligned (its own length L)
       01  WS-FLD             PIC X(18).
       01  WS-FC              PIC X.
       01  WS-LC              PIC X.
      * digits right-aligned with leading zeros
       01  WS-NUM             PIC 9(18).
       01  WS-NUM-X REDEFINES WS-NUM PIC X(18).
       01  WS-VAL             PIC S9(18).
       01  WS-RES             PIC S9(18).
       01  WS-LIM             PIC 9(18).
       01  WS-OVP             PIC X(10) VALUE '{ABCDEFGHI'.
       01  WS-OVN             PIC X(10) VALUE '}JKLMNOPQR'.
       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT PARMF.
       PARM-LECT.
           READ PARMF AT END GO TO PARM-FIN.
           IF P-TYPE = 'HD'
              MOVE P-POS TO P-LONG
              MOVE P-LEN TO D-POS
              MOVE P-DLEN TO D-LEN
              MOVE P-TARGET TO WS-TARGET
              MOVE P-PHA TO WS-PHA
              MOVE P-C1 TO WS-C1
              MOVE P-C2 TO WS-C2.
           IF P-TYPE = 'MT'
              ADD 1 TO N-MT
              MOVE P-POS TO MT-POS (N-MT)
              MOVE P-LEN TO MT-LEN (N-MT).
           GO TO PARM-LECT.
       PARM-FIN.
           CLOSE PARMF.
           MOVE WS-C2 TO WS-OWN.
           IF WS-TARGET = 'BEF'
              MOVE WS-C1 TO WS-OWN.
           OPEN OUTPUT FO2 FO1.
           OPEN INPUT FI1.
           DISPLAY 'PHASE ACTUELLE : ' WS-PHA '/' WS-TARGET.
       LECT.
           MOVE SPACES TO RECIN.
           READ FI1 INTO RECIN AT END GO TO FIN.
           ADD 1 TO WS-NB-REC-LUS.
           MOVE SPACES TO WS-IN.
           MOVE WS-IN-LEN TO CP-LEN.
           IF CP-LEN > P-LONG
              MOVE P-LONG TO CP-LEN.
           IF CP-LEN > 0
              MOVE RECIN (1:CP-LEN) TO WS-IN (1:CP-LEN).
           MOVE WS-IN TO WS-OUT.
           MOVE 0 TO WS-MAJ.
           MOVE 0 TO SW-ERREUR.
           MOVE WS-IN (D-POS:D-LEN) TO WS-DEV.
           IF WS-DEV NOT = WS-C1 AND WS-DEV NOT = WS-C2
              GO TO ERR-DEVISE.
           IF WS-DEV = WS-OWN
              GO TO SUITE.
           MOVE 1 TO I.
       MT-LOOP.
           IF I > N-MT GO TO SUITE.
           PERFORM MT-ONE THRU MT-ONE-EXIT.
           ADD 1 TO I.
           GO TO MT-LOOP.
       SUITE.
           ADD WS-MAJ TO WS-NB-REC-MAJ.
           MOVE WS-TARGET TO WS-OUT (D-POS:D-LEN).
           WRITE FO1-REC FROM WS-OUT.
           IF SW-ERREUR = 1
              ADD 1 TO WS-NB-REC-ERR
              WRITE FO2-REC FROM WS-IN.
           GO TO LECT.
       ERR-DEVISE.
           DISPLAY '*---------------------------------*'.
           DISPLAY '*     GRAVE ERREUR DE DEVISE      *'.
           DISPLAY '*        ABORT DU PROGRAMME       *'.
           DISPLAY '*        CONTACTER J-Y NAUW       *'.
           DISPLAY '*       APPELER LES POMPIERS      *'.
           DISPLAY '*---------------------------------*'.
           CALL 'ABORT'.
           STOP RUN.
       FIN.
           DISPLAY 'NB RECORDS LUS     : ' WS-NB-REC-LUS.
           DISPLAY 'NB RECORDS MAJ     : ' WS-NB-REC-MAJ.
           DISPLAY 'NB RECORDS ERREUR  : ' WS-NB-REC-ERR.
           CLOSE FO2 FI1 FO1.
           IF WS-NB-REC-ERR > 0
              DISPLAY '*---------------------------------*'
              DISPLAY '*     GRAVE ERREUR (OVERFLOW)     *'
              DISPLAY '*        ABORT DU PROGRAMME       *'
              DISPLAY '*        CONTACTER J-Y NAUW       *'
              DISPLAY '*       APPELER LES POMPIERS      *'
              DISPLAY '*---------------------------------*'
              CALL 'ABORT'.
           STOP RUN.
      * amount I (skeleton CASE-0): sign form, value, convert, store
       MT-ONE.
           MOVE MT-POS (I) TO FPOS.
           MOVE MT-LEN (I) TO L.
           MOVE SPACES TO WS-FLD.
           MOVE WS-IN (FPOS:L) TO WS-FLD (1:L).
           IF WS-FLD (1:L) = SPACES GO TO MT-ONE-EXIT.
           MOVE WS-FLD (1:1) TO WS-FC.
           MOVE WS-FLD (L:1) TO WS-LC.
           MOVE 0 TO WS-NEG.
      * leading separate sign: digits 2..L, WS-MAJ not set (A7)
           IF WS-FC = '+' OR WS-FC = ',' OR WS-FC = '-'
              MOVE 'L' TO WS-FORM
              COMPUTE NDIG = L - 1
              MOVE ALL '0' TO WS-NUM-X
              COMPUTE AP = 19 - NDIG
              MOVE WS-FLD (2:NDIG) TO WS-NUM-X (AP:NDIG)
              GO TO MT-VALUE.
           COMPUTE NDIG = L - 1.
           MOVE ALL '0' TO WS-NUM-X.
           COMPUTE AP = 19 - NDIG.
           MOVE WS-FLD (1:NDIG) TO WS-NUM-X (AP:NDIG).
           IF WS-NUM NOT NUMERIC GO TO MT-ONE-EXIT.
      * trailing separate sign: digits 1..L-1
           IF WS-LC = '+' OR WS-LC = ',' OR WS-LC = '-'
              MOVE 'T' TO WS-FORM
              GO TO MT-VALUE.
           MOVE L TO NDIG.
           MOVE ALL '0' TO WS-NUM-X.
           COMPUTE AP = 19 - NDIG.
           MOVE WS-FLD (1:NDIG) TO WS-NUM-X (AP:NDIG).
      * unsigned: last byte a digit
           IF WS-LC NOT < '0' AND WS-LC NOT > '9'
              MOVE 'U' TO WS-FORM
              GO TO MT-VALUE.
      * overpunched sign on the last digit (ACOB Table 2-1)
           MOVE 'S' TO WS-FORM.
           MOVE 1 TO K.
       MT-OVP.
           IF K > 10 GO TO MT-OVZ.
           IF WS-LC = WS-OVP (K:1)
              COMPUTE WS-D = K - 1
              MOVE WS-D TO WS-NUM-X (18:1)
              GO TO MT-VALUE.
           IF WS-LC = WS-OVN (K:1)
              MOVE 1 TO WS-NEG
              COMPUTE WS-D = K - 1
              MOVE WS-D TO WS-NUM-X (18:1)
              GO TO MT-VALUE.
           ADD 1 TO K.
           GO TO MT-OVP.
       MT-OVZ.
           IF WS-LC = '!' OR WS-LC = '?'
              MOVE '0' TO WS-NUM-X (18:1)
              IF WS-LC = '?'
                 MOVE 1 TO WS-NEG
                 GO TO MT-VALUE
              ELSE
                 GO TO MT-VALUE.
      * any other last byte: no conversion, counted (skeleton ELSE)
           MOVE 1 TO WS-MAJ.
           GO TO MT-ONE-EXIT.
       MT-VALUE.
           IF WS-NUM NOT NUMERIC GO TO MT-ONE-EXIT.
           IF WS-NUM = 0 GO TO MT-ONE-EXIT.
           IF WS-FORM NOT = 'L'
              MOVE 1 TO WS-MAJ.
           MOVE WS-NUM TO WS-VAL.
           IF WS-NEG = 1
              COMPUTE WS-VAL = 0 - WS-VAL.
           IF WS-TARGET = 'EUR'
              DIVIDE WS-VAL BY 0,403399 GIVING WS-RES ROUNDED
                 ON SIZE ERROR MOVE 1 TO SW-ERREUR
                 GO TO MT-ONE-EXIT.
           IF WS-TARGET = 'BEF'
              MULTIPLY WS-VAL BY 0,403399 GIVING WS-RES ROUNDED
                 ON SIZE ERROR MOVE 1 TO SW-ERREUR
                 GO TO MT-ONE-EXIT.
      * size error of the field itself: keep the input value
           COMPUTE WS-LIM = 10 ** NDIG.
           IF WS-RES NOT < WS-LIM OR WS-RES NOT > 0 - WS-LIM
              MOVE 1 TO SW-ERREUR
              GO TO MT-ONE-EXIT.
           MOVE 0 TO WS-NEG.
           IF WS-RES < 0
              MOVE 1 TO WS-NEG
              COMPUTE WS-RES = 0 - WS-RES.
           MOVE WS-RES TO WS-NUM.
           COMPUTE AP = 19 - NDIG.
           IF WS-FORM = 'S'
              MOVE WS-NUM-X (18:1) TO WS-D
              COMPUTE K = WS-D + 1
              IF WS-NEG = 1
                 MOVE WS-OVN (K:1) TO WS-NUM-X (18:1)
              ELSE
                 MOVE WS-OVP (K:1) TO WS-NUM-X (18:1).
           IF WS-FORM = 'L'
              MOVE WS-NUM-X (AP:NDIG) TO WS-OUT (FPOS + 1:NDIG)
           ELSE
              MOVE WS-NUM-X (AP:NDIG) TO WS-OUT (FPOS:NDIG).
       MT-ONE-EXIT.
           EXIT.
