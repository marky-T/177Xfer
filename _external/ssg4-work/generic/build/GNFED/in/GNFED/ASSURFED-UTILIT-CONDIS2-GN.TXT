       IDENTIFICATION DIVISION.
      * SSG-4 (MT-043): one CONDIS2 for every call. Conditions
      * (PG CASE / OTHERWISE), field moves (PG MOVE, date conversions)
      * and constants (PG CONST) come from the SGSPARM file written by
      * the skeleton hand-off; see Generic\CONDIS2\spec.md.
       PROGRAM-ID. 'ASSURFED-UTILIT-CONDIS2-GN'.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. UNIVAC-1100-10.
       OBJECT-COMPUTER. UNIVAC-1100-10.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PARMF ASSIGN TO DISC SGSPARM.
           SELECT FI1 ASSIGN TO DISC FILEIN.
           SELECT FO1 ASSIGN TO DISC FILEOUT.
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
       01  PARM-VAL-REC.
           03  FILLER         PIC XX.
           03  PV-POS         PIC 9(5).
           03  PV-LEN         PIC 9(5).
           03  PV-TXT         PIC X(238).
       01  PARM-MOVE-REC.
           03  FILLER         PIC XX.
           03  PM-IS          PIC 9(5).
           03  PM-IL          PIC 9(5).
           03  PM-OS          PIC 9(5).
           03  PM-OL          PIC 9(5).
           03  PM-CODE        PIC X(4).
           03  FILLER         PIC X(224).
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
       01  WS-IN              PIC X(4000).
       01  WS-OUT             PIC X(4000).
       77  WS-IN-LEN          PIC 9(5) COMP VALUE 0.
       77  CP-LEN             PIC 9(5) COMP VALUE 0.
       77  P-INLEN            PIC 9(5) COMP VALUE 0.
       77  P-OUTLEN           PIC 9(5) COMP VALUE 0.
       77  N-GRP              PIC 9(4) COMP VALUE 0.
       77  N-CASE             PIC 9(4) COMP VALUE 0.
       77  N-OTH              PIC 9(4) COMP VALUE 0.
       77  N-TS               PIC 9(4) COMP VALUE 0.
       77  N-OP               PIC 9(4) COMP VALUE 0.
       77  N-CO               PIC 9(4) COMP VALUE 0.
       77  G                  PIC 9(4) COMP VALUE 0.
       77  I                  PIC 9(4) COMP VALUE 0.
       77  J                  PIC 9(4) COMP VALUE 0.
       77  WS-N2              PIC 99 VALUE 0.
       01  GRP-TAB.
           03  GRP-ENT OCCURS 100.
               05  G-KIND     PIC X.
               05  G-CN       PIC 9(4) COMP.
               05  G-T1       PIC 9(4) COMP.
               05  G-TN       PIC 9(4) COMP.
               05  G-O1       PIC 9(4) COMP.
               05  G-ON       PIC 9(4) COMP.
       01  TS-TAB.
           03  TS-ENT OCCURS 200.
               05  T-POS      PIC 9(5) COMP.
               05  T-LEN      PIC 9(5) COMP.
               05  T-VAL      PIC X(238).
       01  OP-TAB.
           03  OP-ENT OCCURS 600.
               05  O-TYPE     PIC X.
               05  O-IS       PIC 9(5) COMP.
               05  O-IL       PIC 9(5) COMP.
               05  O-OS       PIC 9(5) COMP.
               05  O-OL       PIC 9(5) COMP.
               05  O-CODE     PIC X(4).
               05  O-CX       PIC 9(4) COMP.
       01  CO-TAB.
           03  CO-VAL OCCURS 300 PIC X(238).
       01  NB-CASE-TAB.
           03  NB-CASE OCCURS 100 PIC 9(6).
       01  NB-REC-CASE-0            PIC 9(6).
       01  WS-RECORD-TRANSFORME-22A-200X      PIC X.
       01  WS-RECORD-TRANSFORME-22A-201X      PIC X.
       01  WS-RECORD-TRANSFORME-22A-202X      PIC X.
       01  WS-RECORD-TRANSFORME-22A-203X      PIC X.
       01  WS-RECORD-TRANSFORME-22B-200X      PIC X.
       01  WS-RECORD-TRANSFORME-22B-201X      PIC X.
       01  WS-RECORD-TRANSFORME-22B-202X      PIC X.
       01  WS-RECORD-TRANSFORME-22B-203X      PIC X.
       01  WS-RECORD-TRANSFORME-66A-200X      PIC X.
       01  WS-RECORD-TRANSFORME-66A-201X      PIC X.
       01  WS-RECORD-TRANSFORME-66A-202X      PIC X.
       01  WS-RECORD-TRANSFORME-66A-203X      PIC X.
       01  WS-RECORD-TRANSFORME-66B-200X      PIC X.
       01  WS-RECORD-TRANSFORME-66B-201X      PIC X.
       01  WS-RECORD-TRANSFORME-66B-202X      PIC X.
       01  WS-RECORD-TRANSFORME-66B-203X      PIC X.
       01  NB-REC-TRANSFORME-22A-200X      PIC 9(6).
       01  NB-REC-TRANSFORME-22A-201X      PIC 9(6).
       01  NB-REC-TRANSFORME-22A-202X      PIC 9(6).
       01  NB-REC-TRANSFORME-22A-203X      PIC 9(6).
       01  NB-REC-TRANSFORME-22B-200X      PIC 9(6).
       01  NB-REC-TRANSFORME-22B-201X      PIC 9(6).
       01  NB-REC-TRANSFORME-22B-202X      PIC 9(6).
       01  NB-REC-TRANSFORME-22B-203X      PIC 9(6).
       01  NB-REC-TRANSFORME-66A-200X      PIC 9(6).
       01  NB-REC-TRANSFORME-66A-201X      PIC 9(6).
       01  NB-REC-TRANSFORME-66A-202X      PIC 9(6).
       01  NB-REC-TRANSFORME-66A-203X      PIC 9(6).
       01  NB-REC-TRANSFORME-66B-200X      PIC 9(6).
       01  NB-REC-TRANSFORME-66B-201X      PIC 9(6).
       01  NB-REC-TRANSFORME-66B-202X      PIC 9(6).
       01  NB-REC-TRANSFORME-66B-203X      PIC 9(6).
       01  NB-REC-LU                PIC 9(6).
       01  NB-REC-ECRIT             PIC 9(6).
       01  NB-REC-OTHER             PIC 9(6).
       01  NB-REC-NONECRIT          PIC 9(6).
       01  WS-A6.
           02 WS-A6-YY.
              03 WS-A6-Y1           PIC X(01).
              03 WS-A6-Y2           PIC X(01).
           02 WS-A6-MM              PIC X(02).
           02 WS-A6-JJ              PIC X(02).

       01  WS-A8.
           02 WS-A8-YYY.
              03 WS-A8-SS           PIC X(02).
              03 FILLER             PIC X(01).
           02 WS-A8-Y4              PIC X(01).
           02 WS-A8-MM              PIC X(02).
           02 WS-A8-JJ              PIC X(02).

       01  WS-A8-BIS REDEFINES WS-A8.
           02 ws-a8-yy              pic x(02).
           02 ws-a8-yymmjj          PIC X(06).

       01  WS-A4.
           02 WS-A4-SS              PIC X(02).
           02 WS-A4-AA.
              03 WS-A4-A1           PIC X(01).
              03 WS-A4-A2           PIC X(01).
       01  WS-A2.
              03 WS-A2-A1           PIC X(01).
              03 WS-A2-A2           PIC X(01).
       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT PARMF.
       PARM-LECT.
           READ PARMF AT END GO TO PARM-FIN.
           IF P-TYPE = 'FI'
              MOVE PL-LEN TO P-INLEN.
           IF P-TYPE = 'FO'
              MOVE PL-LEN TO P-OUTLEN.
           IF P-TYPE = 'CA' OR P-TYPE = 'OT' OR P-TYPE = 'NG'
              ADD 1 TO N-GRP
              MOVE P-TYPE (1:1) TO G-KIND (N-GRP)
              MOVE 0 TO G-CN (N-GRP)
              COMPUTE G-T1 (N-GRP) = N-TS + 1
              MOVE N-TS TO G-TN (N-GRP)
              COMPUTE G-O1 (N-GRP) = N-OP + 1
              MOVE N-OP TO G-ON (N-GRP).
           IF P-TYPE = 'CA'
              ADD 1 TO N-CASE
              MOVE N-CASE TO G-CN (N-GRP).
           IF P-TYPE = 'OT'
              ADD 1 TO N-OTH.
           IF P-TYPE = 'TS'
              ADD 1 TO N-TS
              MOVE PV-POS TO T-POS (N-TS)
              MOVE PV-LEN TO T-LEN (N-TS)
              MOVE PV-TXT TO T-VAL (N-TS)
              MOVE N-TS TO G-TN (N-GRP).
           IF P-TYPE = 'MV'
              ADD 1 TO N-OP
              MOVE 'M' TO O-TYPE (N-OP)
              MOVE PM-IS TO O-IS (N-OP)
              MOVE PM-IL TO O-IL (N-OP)
              MOVE PM-OS TO O-OS (N-OP)
              MOVE PM-OL TO O-OL (N-OP)
              MOVE PM-CODE TO O-CODE (N-OP)
              MOVE N-OP TO G-ON (N-GRP).
           IF P-TYPE = 'CO'
              ADD 1 TO N-OP
              ADD 1 TO N-CO
              MOVE 'K' TO O-TYPE (N-OP)
              MOVE PV-POS TO O-OS (N-OP)
              MOVE PV-LEN TO O-OL (N-OP)
              MOVE PV-TXT TO CO-VAL (N-CO)
              MOVE N-CO TO O-CX (N-OP)
              MOVE N-OP TO G-ON (N-GRP).
           GO TO PARM-LECT.
       PARM-FIN.
           CLOSE PARMF.
           OPEN INPUT FI1.
           OPEN OUTPUT FO1.
           MOVE 0 TO NB-REC-LU.
           MOVE 0 TO NB-REC-ECRIT.
           MOVE 0 TO NB-REC-NONECRIT.
           MOVE 0 TO NB-REC-TRANSFORME-22A-200X.
           MOVE 0 TO NB-REC-TRANSFORME-22A-201X.
           MOVE 0 TO NB-REC-TRANSFORME-22A-202X.
           MOVE 0 TO NB-REC-TRANSFORME-22A-203X.
           MOVE 0 TO NB-REC-TRANSFORME-22B-200X.
           MOVE 0 TO NB-REC-TRANSFORME-22B-201X.
           MOVE 0 TO NB-REC-TRANSFORME-22B-202X.
           MOVE 0 TO NB-REC-TRANSFORME-22B-203X.
           MOVE 0 TO NB-REC-TRANSFORME-66A-200X.
           MOVE 0 TO NB-REC-TRANSFORME-66A-201X.
           MOVE 0 TO NB-REC-TRANSFORME-66A-202X.
           MOVE 0 TO NB-REC-TRANSFORME-66A-203X.
           MOVE 0 TO NB-REC-TRANSFORME-66B-200X.
           MOVE 0 TO NB-REC-TRANSFORME-66B-201X.
           MOVE 0 TO NB-REC-TRANSFORME-66B-202X.
           MOVE 0 TO NB-REC-TRANSFORME-66B-203X.
           MOVE 0 TO NB-REC-CASE-0.
           MOVE ZEROES TO NB-CASE-TAB.
           MOVE 0 TO NB-REC-OTHER.
       TRT.
           MOVE SPACES TO RECIN.
           READ FI1 INTO RECIN AT END GO TO FIN-TRT.
           MOVE SPACES TO WS-IN.
           MOVE WS-IN-LEN TO CP-LEN.
           IF CP-LEN > P-INLEN
              MOVE P-INLEN TO CP-LEN.
           IF CP-LEN > 0
              MOVE RECIN (1:CP-LEN) TO WS-IN (1:CP-LEN).
           MOVE SPACES TO WS-OUT.
           MOVE 'N' TO WS-RECORD-TRANSFORME-22A-200X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-22A-201X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-22A-202X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-22A-203X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-22B-200X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-22B-201X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-22B-202X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-22B-203X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-66A-200X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-66A-201X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-66A-202X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-66A-203X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-66B-200X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-66B-201X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-66B-202X.
           MOVE 'N' TO WS-RECORD-TRANSFORME-66B-203X.
           ADD 1 TO NB-REC-LU.
           MOVE 0 TO G.
       GRP-NEXT.
           ADD 1 TO G.
           IF G > N-GRP GO TO GRP-END.
           MOVE G-T1 (G) TO J.
       TST-LOOP.
           IF G-KIND (G) NOT = 'C' GO TO OP-START.
           IF J > G-TN (G) GO TO OP-START.
           IF WS-IN (T-POS (J):T-LEN (J)) NOT = T-VAL (J) (1:T-LEN (J))
              GO TO GRP-NEXT.
           ADD 1 TO J.
           GO TO TST-LOOP.
       OP-START.
           MOVE G-O1 (G) TO I.
       OP-LOOP.
           IF I > G-ON (G) GO TO OP-END.
           IF O-TYPE (I) = 'K'
              MOVE CO-VAL (O-CX (I)) (1:O-OL (I))
                TO WS-OUT (O-OS (I):O-OL (I))
           ELSE
              IF O-CODE (I) = SPACES
                 MOVE WS-IN (O-IS (I):O-IL (I))
                   TO WS-OUT (O-OS (I):O-OL (I))
              ELSE
                 PERFORM DATE-OP THRU DATE-OP-EXIT.
           ADD 1 TO I.
           GO TO OP-LOOP.
       OP-END.
           IF G-KIND (G) = 'N' GO TO GRP-NEXT.
           IF G-KIND (G) = 'C'
              ADD 1 TO NB-CASE (G-CN (G))
           ELSE
              ADD 1 TO NB-REC-OTHER.
           PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT.
           GO TO TRT.
       GRP-END.
      *    no group matched: written only when the call has no CASE and
      *    no OTHERWISE (CASE-NON-PREVU otherwise).
           IF N-CASE = 0 AND N-OTH = 0
              ADD 1 TO NB-REC-CASE-0
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT.
           GO TO TRT.
       DATE-OP.
           IF O-CODE (I) = 'D42'
              MOVE WS-IN (O-IS (I):4) TO WS-A4
              PERFORM TRANSFO-DATE-4-2 THRU TRANSFO-DATE-4-2-EXIT
              MOVE WS-A2 TO WS-OUT (O-OS (I):2).
           IF O-CODE (I) = 'D24'
              MOVE WS-IN (O-IS (I):2) TO WS-A2
              PERFORM TRANSFO-DATE-2-4 THRU TRANSFO-DATE-2-4-EXIT
              MOVE WS-A4 TO WS-OUT (O-OS (I):4).
           IF O-CODE (I) = 'D22A'
              MOVE WS-IN (O-IS (I):2) TO WS-A2
              PERFORM TRANSFO-DATE-22A THRU TRANSFO-DATE-22A-EXIT
              MOVE WS-A2 TO WS-OUT (O-OS (I):2).
           IF O-CODE (I) = 'D22B'
              MOVE WS-IN (O-IS (I):2) TO WS-A2
              PERFORM TRANSFO-DATE-22B THRU TRANSFO-DATE-22B-EXIT
              MOVE WS-A2 TO WS-OUT (O-OS (I):2).
           IF O-CODE (I) = 'D66A'
              MOVE WS-IN (O-IS (I):6) TO WS-A6
              PERFORM TRANSFO-DATE-66A THRU TRANSFO-DATE-66A-EXIT
              MOVE WS-A6 TO WS-OUT (O-OS (I):6).
           IF O-CODE (I) = 'D66B'
              MOVE WS-IN (O-IS (I):6) TO WS-A6
              PERFORM TRANSFO-DATE-66B THRU TRANSFO-DATE-66B-EXIT
              MOVE WS-A6 TO WS-OUT (O-OS (I):6).
           IF O-CODE (I) = 'D68'
              MOVE WS-IN (O-IS (I):6) TO WS-A6
              PERFORM TRANSFO-DATE-68 THRU TRANSFO-DATE-68-EXIT
              MOVE WS-A8 TO WS-OUT (O-OS (I):8).
           IF O-CODE (I) = 'D86'
              MOVE WS-IN (O-IS (I):8) TO WS-A8
              PERFORM TRANSFO-DATE-86 THRU TRANSFO-DATE-86-EXIT
              MOVE WS-A6 TO WS-OUT (O-OS (I):6).
       DATE-OP-EXIT.
           EXIT.
       FIN-TRT.
           DISPLAY 'NB ENREGISTREMENTS LUS    = ' NB-REC-LU
                                UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS ECRITS = ' NB-REC-ECRIT
                                UPON PRINTER.
           SUBTRACT NB-REC-ECRIT FROM NB-REC-LU GIVING NB-REC-NONECRIT.
           IF NB-REC-NONECRIT > 0
              DISPLAY '*******************************' UPON PRINTER
              DISPLAY '*   attention                 *' UPON PRINTER
              DISPLAY '*   certains records ne       *' UPon printer
              DISPLAY '*   respectent aucun case     *' UPON PRInter
              DISPLAY '*   et ne figurent donc pas   *' UPON PRInter
              DISPLAY '*   sur le fichier output     *' UPON PRInter
              DISPLAY '*******************************' UPON PRINTER.
           MOVE 1 TO J.
       DSP-CASE.
           IF J > N-CASE GO TO DSP-END.
           MOVE J TO WS-N2.
           IF J < 10
              DISPLAY 'NB ENREGISTREMENTS CONDITION NO ' WS-N2 (2:1)
                      ' = ' NB-CASE (J) UPON PRINTER
           ELSE
              DISPLAY 'NB ENREGISTREMENTS CONDITION NO ' WS-N2
                      ' = ' NB-CASE (J) UPON PRINTER.
           ADD 1 TO J.
           GO TO DSP-CASE.
       DSP-END.
           DISPLAY 'NB ENREGISTREMENTS OTHER = ' NB-REC-OTHER
                                                UPON PRINTER.
           display ' ' upon printer.
           display ' ' upon printer.
           display ' ' upon printer.
           display ' ' upon printer.

           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22A) 0X --> ;X    = '
                   NB-REC-TRANSFORME-22A-200X UPON PRINTER.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22A) 1X --> _X    = '
                   NB-REC-TRANSFORME-22A-201X UPON PRINTER.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22A) 2X --> |X    = '
                   NB-REC-TRANSFORME-22A-202X UPON PRINTER.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22A) 3X --> ~X    = '
                   NB-REC-TRANSFORME-22A-203X UPON PRINTER.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22B) ;X --> 0X    = '
                   NB-REC-TRANSFORME-22B-200X UPON PRINTER.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22B) _X --> 1X    = '
                   NB-REC-TRANSFORME-22B-201X UPON PRINTER.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22B) |X --> 2X    = '
                   NB-REC-TRANSFORME-22B-202X UPON PRINTER.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22B) ~X --> 3X    = '
                   NB-REC-TRANSFORME-22B-203X UPON PRINTER.

           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66A) 0X --> ;X    = '
                   NB-REC-TRANSFORME-66A-200X UPON PRINTER.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66A) 1X --> _X    = '
                   NB-REC-TRANSFORME-66A-201X UPON PRINTER.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66A) 2X --> |X    = '
                   NB-REC-TRANSFORME-66A-202X UPON PRINTER.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66A) 3X --> ~X    = '
                   NB-REC-TRANSFORME-66A-203X UPON PRINTER.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66B) ;X --> 0X    = '
                   NB-REC-TRANSFORME-66B-200X UPON PRINTER.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66B) _X --> 1X    = '
                   NB-REC-TRANSFORME-66B-201X UPON PRINTER.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66B) |X --> 2X    = '
                   NB-REC-TRANSFORME-66B-202X UPON PRINTER.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66B) ~X --> 3X    = '
                   NB-REC-TRANSFORME-66B-203X UPON PRINTER.

           CLOSE FI1 FO1.
           STOP RUN.
       TRANSFO-DATE-4-2.
      ******************
           MOVE WS-A4-AA TO WS-A2.
           IF ((WS-A4 > '1999') AND (WS-A4 < '2010'))
              MOVE ';' TO WS-A2-A1.
           IF ((WS-A4 > '2009') AND (WS-A4 < '2020'))
              MOVE '_' TO WS-A2-A1.
           IF ((WS-A4 > '2019') AND (WS-A4 < '2030'))
              MOVE '|' TO WS-A2-A1.
           IF ((WS-A4 > '2029') AND (WS-A4 < '2040'))
              MOVE '~' TO WS-A2-A1.

       TRANSFO-DATE-4-2-EXIT.
      ******************
           EXIT.


       TRANSFO-DATE-2-4.
      ******************
           IF WS-A2 = '00'
              MOVE '0000' TO WS-A4
              GO TO TRANSFO-DATE-2-4-EXIT.
           IF WS-A2 = '  '
              MOVE '    ' TO WS-A4
              GO TO TRANSFO-DATE-2-4-EXIT.
           IF WS-A2-A1 = ';'
              MOVE '20' TO WS-A4-SS
              MOVE '0'  TO WS-A4-A1
              MOVE WS-A2-A2  TO WS-A4-A2
              GO TO TRANSFO-DATE-2-4-EXIT.
           IF WS-A2-A1 = '_'
              MOVE '20' TO WS-A4-SS
              MOVE '1'  TO WS-A4-A1
              MOVE WS-A2-A2  TO WS-A4-A2
              GO TO TRANSFO-DATE-2-4-EXIT.
           IF WS-A2-A1 = '|'
              MOVE '20' TO WS-A4-SS
              MOVE '2'  TO WS-A4-A1
              MOVE WS-A2-A2  TO WS-A4-A2
              GO TO TRANSFO-DATE-2-4-EXIT.
           IF WS-A2-A1 = '~'
              MOVE '20' TO WS-A4-SS
              MOVE '3'  TO WS-A4-A1
              MOVE WS-A2-A2  TO WS-A4-A2
              GO TO TRANSFO-DATE-2-4-EXIT.
           MOVE '19'     TO WS-A4-SS.
           MOVE WS-A2    TO WS-A4-AA.
           GO TO TRANSFO-DATE-2-4-EXIT.

       TRANSFO-DATE-2-4-EXIT.
      ******************
           EXIT.

       TRANSFO-DATE-22A.
      ******************
           IF WS-A2-A1 = '0'
              MOVE ';'      TO WS-A2-A1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-22A-200X
              GO TO TRANSFO-DATE-22A-EXIT.
           IF WS-A2-A1 = '1'
              MOVE '_'      TO WS-A2-A1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-22A-201X
              GO TO TRANSFO-DATE-22A-EXIT.
           IF WS-A2-A1 = '2'
              MOVE '|'      TO WS-A2-A1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-22A-202X
              GO TO TRANSFO-DATE-22A-EXIT.
           IF WS-A2-A1 = '3'
              MOVE '~'      TO WS-A2-A1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-22A-203X
              GO TO TRANSFO-DATE-22A-EXIT.

       TRANSFO-DATE-22A-EXIT.
      ******************
           EXIT.

       TRANSFO-DATE-66A.
      ******************
           IF WS-A6 NOT NUMERIC
              GO TO TRANSFO-DATE-66A-EXIT.
           IF ((WS-A6-MM > '15') or (WS-A6-MM = '00'))
              GO TO TRANSFO-DATE-66A-EXIT.
           IF ((WS-A6-JJ > '35') or (WS-A6-JJ = '00'))
              GO TO TRANSFO-DATE-66A-EXIT.
           IF WS-A6-Y1 = '0'
              MOVE ';'      TO WS-A6-Y1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66A-200X
              GO TO TRANSFO-DATE-66A-EXIT.
           IF WS-A6-Y1 = '1'
              MOVE '_'      TO WS-A6-Y1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66A-201X
              GO TO TRANSFO-DATE-66A-EXIT.
           IF WS-A6-Y1 = '2'
              MOVE '|'      TO WS-A6-Y1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66A-202X
              GO TO TRANSFO-DATE-66A-EXIT.
           IF WS-A6-Y1 = '3'
              MOVE '~'      TO WS-A6-Y1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66A-203X
              GO TO TRANSFO-DATE-66A-EXIT.

       TRANSFO-DATE-66A-EXIT.
      ******************
           EXIT.

       TRANSFO-DATE-66B.
      ******************
           IF WS-A6-Y1 = ';'
              MOVE '0'      TO WS-A6-Y1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66B-200X
              GO TO TRANSFO-DATE-66B-EXIT.
           IF WS-A6-Y1 = '_'
              MOVE '1'      TO WS-A6-Y1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66B-201X
              GO TO TRANSFO-DATE-66B-EXIT.
           IF WS-A6-Y1 = '|'
              MOVE '2'      TO WS-A6-Y1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66B-202X
              GO TO TRANSFO-DATE-66B-EXIT.
           IF WS-A6-Y1 = '~'
              MOVE '3'      TO WS-A6-Y1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66B-203X
              GO TO TRANSFO-DATE-66B-EXIT.

       TRANSFO-DATE-66B-EXIT.
      ******************
           EXIT.

       TRANSFO-DATE-68.
      ******************
           MOVE WS-A6 TO WS-A8-YYMMJJ.
           MOVE '19'  to WS-A8-YY.
           IF WS-A6 = '      '
              MOVE '        ' to WS-A8
              GO TO TRANSFO-DATE-68-EXIT.
           IF WS-A6 = '000000'
              MOVE '00000000' to WS-A8
              GO TO TRANSFO-DATE-68-EXIT.
           IF WS-A6-Y1 = ';'
              MOVE '200'    TO WS-A8-YYY
              MOVE WS-A6-Y2 TO WS-A8-Y4
              MOVE WS-A6-MM TO WS-A8-MM
              MOVE WS-A6-JJ TO WS-A8-JJ
              GO TO TRANSFO-DATE-68-EXIT.
           IF WS-A6-Y1 = '_'
              MOVE '201'    TO WS-A8-YYY
              MOVE WS-A6-Y2 TO WS-A8-Y4
              MOVE WS-A6-MM TO WS-A8-MM
              MOVE WS-A6-JJ TO WS-A8-JJ
              GO TO TRANSFO-DATE-68-EXIT.
           IF WS-A6-Y1 = '|'
              MOVE '202'    TO WS-A8-YYY
              MOVE WS-A6-Y2 TO WS-A8-Y4
              MOVE WS-A6-MM TO WS-A8-MM
              MOVE WS-A6-JJ TO WS-A8-JJ
              GO TO TRANSFO-DATE-68-EXIT.
           IF WS-A6-Y1 = '~'
              MOVE '203'    TO WS-A8-YYY
              MOVE WS-A6-Y2 TO WS-A8-Y4
              MOVE WS-A6-MM TO WS-A8-MM
              MOVE WS-A6-JJ TO WS-A8-JJ
              GO TO TRANSFO-DATE-68-EXIT.

       TRANSFO-DATE-68-EXIT.
      ******************
           EXIT.

       TRANSFO-DATE-86.
      ******************
           MOVE WS-A8-YYMMJJ TO WS-A6.
           IF WS-A8 NOT NUMERIC
              GO TO TRANSFO-DATE-86-EXIT.
           IF ((WS-A8-MM > '15') or (WS-A8-MM = '00'))
              GO TO TRANSFO-DATE-86-EXIT.
           IF ((WS-A8-JJ > '35') or (WS-A8-JJ = '00'))
              GO TO TRANSFO-DATE-86-EXIT.
           IF WS-A8-YYY = '200'
              MOVE ';'      TO WS-A6-Y1
              MOVE WS-A8-Y4 TO WS-A6-Y2
              MOVE WS-A8-MM TO WS-A6-MM
              MOVE WS-A8-JJ TO WS-A6-JJ
              GO TO TRANSFO-DATE-86-EXIT.
           IF WS-A8-YYY = '201'
              MOVE '_'      TO WS-A6-Y1
              MOVE WS-A8-Y4 TO WS-A6-Y2
              MOVE WS-A8-MM TO WS-A6-MM
              MOVE WS-A8-JJ TO WS-A6-JJ
              GO TO TRANSFO-DATE-86-EXIT.
           IF WS-A8-YYY = '202'
              MOVE '|'      TO WS-A6-Y1
              MOVE WS-A8-Y4 TO WS-A6-Y2
              MOVE WS-A8-MM TO WS-A6-MM
              MOVE WS-A8-JJ TO WS-A6-JJ
              GO TO TRANSFO-DATE-86-EXIT.
           IF WS-A8-YYY = '203'
              MOVE '~'      TO WS-A6-Y1
              MOVE WS-A8-Y4 TO WS-A6-Y2
              MOVE WS-A8-MM TO WS-A6-MM
              MOVE WS-A8-JJ TO WS-A6-JJ
              GO TO TRANSFO-DATE-86-EXIT.
           IF WS-A8-SS = '19'
              MOVE WS-A8-YYMMJJ   TO WS-A6
              GO TO TRANSFO-DATE-86-EXIT.

       TRANSFO-DATE-86-EXIT.
      ******************
           EXIT.

       TRANSFO-DATE-22B.
      ******************
           IF WS-A2-A1 = ';'
              MOVE '0'      TO WS-A2-A1
              move 'Y' TO WS-RECORD-TRANSFORME-22B-200X
              GO TO TRANSFO-DATE-22B-EXIT.
           IF WS-A2-A1 = '_'
              MOVE '1'      TO WS-A2-A1
              move 'Y' TO WS-RECORD-TRANSFORME-22B-201X
              GO TO TRANSFO-DATE-22B-EXIT.
           IF WS-A2-A1 = '|'
              MOVE '2'      TO WS-A2-A1
              move 'Y' TO WS-RECORD-TRANSFORME-22B-202X
              GO TO TRANSFO-DATE-22B-EXIT.
           IF WS-A2-A1 = '~'
              MOVE '3'      TO WS-A2-A1
              move 'Y' TO WS-RECORD-TRANSFORME-22B-203X
              GO TO TRANSFO-DATE-22B-EXIT.

       TRANSFO-DATE-22B-EXIT.
      ******************
           EXIT.

       WRITE-REC-OUTPUT.
      *******************
           ADD 1 TO NB-REC-ECRIT.
           IF WS-RECORD-TRANSFORME-22A-200X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-22A-200X.
           IF WS-RECORD-TRANSFORME-22A-201X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-22A-201X.
           IF WS-RECORD-TRANSFORME-22A-202X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-22A-202X.
           IF WS-RECORD-TRANSFORME-22A-203X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-22A-203X.
           IF WS-RECORD-TRANSFORME-22B-200X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-22B-200X.
           IF WS-RECORD-TRANSFORME-22B-201X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-22B-201X.
           IF WS-RECORD-TRANSFORME-22B-202X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-22B-202X.
           IF WS-RECORD-TRANSFORME-22B-203X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-22B-203X.
           IF WS-RECORD-TRANSFORME-66A-200X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-66A-200X.
           IF WS-RECORD-TRANSFORME-66A-201X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-66A-201X.
           IF WS-RECORD-TRANSFORME-66A-202X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-66A-202X.
           IF WS-RECORD-TRANSFORME-66A-203X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-66A-203X.
           IF WS-RECORD-TRANSFORME-66B-200X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-66B-200X.
           IF WS-RECORD-TRANSFORME-66B-201X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-66B-201X.
           IF WS-RECORD-TRANSFORME-66B-202X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-66B-202X.
           IF WS-RECORD-TRANSFORME-66B-203X = 'Y'
              ADD 1 TO NB-REC-TRANSFORME-66B-203X.

           WRITE FO1-REC FROM WS-OUT.

       WRITE-REC-OUTPUT-EXIT.
      ************************
           EXIT.
