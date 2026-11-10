       IDENTIFICATION DIVISION.
      * SSG-4 generic CONDIS2: one program for every call. The call's
      * item list (conditions, field moves, constants, counters) comes
      * from the SGSPARM file written by the skeleton hand-off, see
      * spec.md "Behaviour" step 3 and "Generic program". The date
      * paragraphs and the report are those of the SSG skeleton.
       PROGRAM-ID. 'ASSURFED-UTILIT-CONDIS2-GN'.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. UNIVAC-1100-10.
       OBJECT-COMPUTER. UNIVAC-1100-10.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PARMF ASSIGN TO DISC SGSPARM.
           SELECT FI1 ASSIGN TO DISC CNDIN.
           SELECT FO1 ASSIGN TO DISC CNDOUT.
       DATA DIVISION.
       FILE SECTION.
       FD  PARMF
           LABEL RECORD STANDARD.
       01  PARM-REC.
           03  P-TYPE         PIC XX.
           03  P-REST         PIC X(248).
       01  PARM-RL-REC.
           03  FILLER         PIC XX.
           03  PRL-IN         PIC 9(5).
           03  PRL-OUT        PIC 9(5).
           03  PRL-NC         PIC 9(5).
           03  FILLER         PIC X(233).
       01  PARM-CD-REC.
           03  FILLER         PIC XX.
           03  PCD-POS        PIC 9(5).
           03  PCD-LEN        PIC 9(5).
           03  PCD-VAL        PIC X(200).
           03  FILLER         PIC X(38).
       01  PARM-MV-REC.
           03  FILLER         PIC XX.
           03  PMV-IP         PIC 9(5).
           03  PMV-IL         PIC 9(5).
           03  PMV-OP         PIC 9(5).
           03  PMV-CODE       PIC X(4).
           03  FILLER         PIC X(229).
       01  PARM-KT-REC.
           03  FILLER         PIC XX.
           03  PKT-OP         PIC 9(5).
           03  PKT-LEN        PIC 9(5).
           03  PKT-VAL        PIC X(200).
           03  FILLER         PIC X(38).
       01  PARM-TL-REC.
           03  FILLER         PIC XX.
           03  PTL-KIND       PIC X.
           03  PTL-K          PIC 9(5).
           03  FILLER         PIC X(242).
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
       01  WS-IN              PIC X(4000).
       01  WS-OUT             PIC X(4000).
       01  WS-CA              PIC X(200).
       77  WS-IN-LEN          PIC 9(5) COMP VALUE 0.
       77  P-INLEN            PIC 9(5) COMP VALUE 0.
       77  P-OUTLEN           PIC 9(5) COMP VALUE 0.
       77  P-NC               PIC 9(5) COMP VALUE 0.
       77  N-IT               PIC 9(5) COMP VALUE 0.
       77  PC                 PIC 9(5) COMP VALUE 0.
       77  W-ACTIVE           PIC 9 VALUE 1.
       77  W-TYPE             PIC X VALUE SPACE.
       77  W-CODE             PIC 9(3) COMP VALUE 0.
       77  CP-LEN             PIC 9(5) COMP VALUE 0.
       77  IX                 PIC 9(5) COMP VALUE 0.
       77  I                  PIC 9(5) COMP VALUE 0.
       01  IT-TAB.
           03  IT-ENT OCCURS 2000.
               05  IT-TYPE    PIC X.
               05  IT-A       PIC 9(5) COMP.
               05  IT-B       PIC 9(5) COMP.
               05  IT-C       PIC 9(5) COMP.
               05  IT-CODE    PIC 9(3) COMP.
               05  IT-VAL     PIC X(200).
       01  CNT-TAB.
           03  CNT            PIC 9(6) OCCURS 202.
       01  D-N1               PIC 9.
       01  D-N2               PIC 99.
       01  D-N3               PIC 999.
       01  D-CNT              PIC 9(6).
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
           02 WS-A8-YY              PIC X(02).
           02 WS-A8-YYMMJJ          PIC X(06).
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
           IF P-TYPE = 'RL'
              MOVE PRL-IN TO P-INLEN
              MOVE PRL-OUT TO P-OUTLEN
              MOVE PRL-NC TO P-NC.
           IF P-TYPE = 'CD'
              ADD 1 TO N-IT
              MOVE 'C' TO IT-TYPE (N-IT)
              MOVE PCD-POS TO IT-A (N-IT)
              MOVE PCD-LEN TO IT-B (N-IT)
              MOVE PCD-VAL TO IT-VAL (N-IT).
           IF P-TYPE = 'MV'
              ADD 1 TO N-IT
              MOVE 'M' TO IT-TYPE (N-IT)
              MOVE PMV-IP TO IT-A (N-IT)
              MOVE PMV-IL TO IT-B (N-IT)
              MOVE PMV-OP TO IT-C (N-IT)
              MOVE 0 TO IT-CODE (N-IT)
              PERFORM CODE-MAP THRU CODE-MAP-EXIT.
           IF P-TYPE = 'KT'
              ADD 1 TO N-IT
              MOVE 'K' TO IT-TYPE (N-IT)
              MOVE PKT-OP TO IT-A (N-IT)
              MOVE PKT-LEN TO IT-B (N-IT)
              MOVE PKT-VAL TO IT-VAL (N-IT).
           IF P-TYPE = 'TL'
              ADD 1 TO N-IT
              MOVE PTL-K TO IT-A (N-IT)
              MOVE 'T' TO IT-TYPE (N-IT)
              IF PTL-KIND = 'O'
                 MOVE 'U' TO IT-TYPE (N-IT).
           GO TO PARM-LECT.
       CODE-MAP.
           IF PMV-CODE = 'D24 '
              MOVE 1 TO IT-CODE (N-IT).
           IF PMV-CODE = 'D42 '
              MOVE 2 TO IT-CODE (N-IT).
           IF PMV-CODE = 'D22A'
              MOVE 3 TO IT-CODE (N-IT).
           IF PMV-CODE = 'D22B'
              MOVE 4 TO IT-CODE (N-IT).
           IF PMV-CODE = 'D66A'
              MOVE 5 TO IT-CODE (N-IT).
           IF PMV-CODE = 'D66B'
              MOVE 6 TO IT-CODE (N-IT).
           IF PMV-CODE = 'D68 '
              MOVE 7 TO IT-CODE (N-IT).
           IF PMV-CODE = 'D86 '
              MOVE 8 TO IT-CODE (N-IT).
       CODE-MAP-EXIT.
           EXIT.
       PARM-FIN.
           CLOSE PARMF.
           OPEN INPUT FI1.
           OPEN OUTPUT FO1.
           MOVE 0 TO NB-REC-LU.
           MOVE 0 TO NB-REC-ECRIT.
           MOVE 0 TO NB-REC-NONECRIT.
           MOVE 0 TO NB-REC-OTHER.
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
           MOVE 1 TO I.
       CNT-INIT.
           IF I > 202 GO TO TRT.
           MOVE 0 TO CNT (I).
           ADD 1 TO I.
           GO TO CNT-INIT.
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
           MOVE 1 TO PC.
           MOVE 1 TO W-ACTIVE.
       RUN-LOOP.
           IF PC > N-IT GO TO CASE-NON-PREVU.
           MOVE IT-TYPE (PC) TO W-TYPE.
           IF W-TYPE = 'C' GO TO IT-C.
           IF W-TYPE = 'M' GO TO IT-M.
           IF W-TYPE = 'K' GO TO IT-K.
           GO TO IT-T.
       IT-NEXT.
           ADD 1 TO PC.
           GO TO RUN-LOOP.
       IT-C.
           IF W-ACTIVE = 0 GO TO IT-NEXT.
           MOVE SPACES TO WS-CA.
           MOVE WS-IN (IT-A (PC):IT-B (PC)) TO WS-CA (1:IT-B (PC)).
           IF WS-CA NOT = IT-VAL (PC)
              MOVE 0 TO W-ACTIVE.
           GO TO IT-NEXT.
       IT-K.
           IF W-ACTIVE = 0 GO TO IT-NEXT.
           MOVE IT-VAL (PC) (1:IT-B (PC))
             TO WS-OUT (IT-A (PC):IT-B (PC)).
           GO TO IT-NEXT.
       IT-M.
           IF W-ACTIVE = 0 GO TO IT-NEXT.
           MOVE IT-CODE (PC) TO W-CODE.
           IF W-CODE = 0
              MOVE WS-IN (IT-A (PC):IT-B (PC))
                TO WS-OUT (IT-C (PC):IT-B (PC))
              GO TO IT-NEXT.
           GO TO
                 DC-1 DC-2 DC-3 DC-4 DC-5 DC-6 DC-7 DC-8
             DEPENDING ON W-CODE.
           GO TO IT-NEXT.
       DC-1.
           MOVE WS-IN (IT-A (PC):2) TO WS-A2.
           PERFORM TRANSFO-DATE-2-4 THRU TRANSFO-DATE-2-4-EXIT.
           MOVE WS-A4 TO WS-OUT (IT-C (PC):4).
           GO TO IT-NEXT.
       DC-2.
           MOVE WS-IN (IT-A (PC):4) TO WS-A4.
           PERFORM TRANSFO-DATE-4-2 THRU TRANSFO-DATE-4-2-EXIT.
           MOVE WS-A2 TO WS-OUT (IT-C (PC):2).
           GO TO IT-NEXT.
       DC-3.
           MOVE WS-IN (IT-A (PC):2) TO WS-A2.
           PERFORM TRANSFO-DATE-22A THRU TRANSFO-DATE-22A-EXIT.
           MOVE WS-A2 TO WS-OUT (IT-C (PC):2).
           GO TO IT-NEXT.
       DC-4.
           MOVE WS-IN (IT-A (PC):2) TO WS-A2.
           PERFORM TRANSFO-DATE-22B THRU TRANSFO-DATE-22B-EXIT.
           MOVE WS-A2 TO WS-OUT (IT-C (PC):2).
           GO TO IT-NEXT.
       DC-5.
           MOVE WS-IN (IT-A (PC):6) TO WS-A6.
           PERFORM TRANSFO-DATE-66A THRU TRANSFO-DATE-66A-EXIT.
           MOVE WS-A6 TO WS-OUT (IT-C (PC):6).
           GO TO IT-NEXT.
       DC-6.
           MOVE WS-IN (IT-A (PC):6) TO WS-A6.
           PERFORM TRANSFO-DATE-66B THRU TRANSFO-DATE-66B-EXIT.
           MOVE WS-A6 TO WS-OUT (IT-C (PC):6).
           GO TO IT-NEXT.
       DC-7.
           MOVE WS-IN (IT-A (PC):6) TO WS-A6.
           PERFORM TRANSFO-DATE-68 THRU TRANSFO-DATE-68-EXIT.
           MOVE WS-A8 TO WS-OUT (IT-C (PC):8).
           GO TO IT-NEXT.
       DC-8.
           MOVE WS-IN (IT-A (PC):8) TO WS-A8.
           PERFORM TRANSFO-DATE-86 THRU TRANSFO-DATE-86-EXIT.
           MOVE WS-A6 TO WS-OUT (IT-C (PC):6).
           GO TO IT-NEXT.
       IT-T.
           IF W-ACTIVE = 0
              MOVE 1 TO W-ACTIVE
              GO TO IT-NEXT.
           IF W-TYPE = 'U'
              ADD 1 TO NB-REC-OTHER
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT
              GO TO TRT.
           MOVE IT-A (PC) TO IX.
           ADD 1 TO IX.
           ADD 1 TO CNT (IX).
           PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT.
           GO TO TRT.
       CASE-NON-PREVU.
           GO TO TRT.
       FIN-TRT.
           DISPLAY 'NB ENREGISTREMENTS LUS    = ' NB-REC-LU
                                UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS ECRITS = ' NB-REC-ECRIT
                                UPON PRINTER.
           SUBTRACT NB-REC-ECRIT FROM NB-REC-LU GIVING NB-REC-NONECRIT.
           IF NB-REC-NONECRIT > 0
              DISPLAY '*******************************' UPON PRINTER
              DISPLAY '*   attention                 *' UPON PRINTER
              DISPLAY '*   certains records ne       *' UPON PRINTER
              DISPLAY '*   respectent aucun case     *' UPON PRINTER
              DISPLAY '*   et ne figurent donc pas   *' UPON PRINTER
              DISPLAY '*   sur le fichier output     *' UPON PRINTER
              DISPLAY '*******************************' UPON PRINTER.
           MOVE 1 TO I.
       CASE-RPT.
           IF I > P-NC GO TO CASE-RPT-FIN.
           MOVE I TO IX.
           ADD 1 TO IX.
           MOVE CNT (IX) TO D-CNT.
           IF I < 10
              MOVE I TO D-N1
              DISPLAY 'NB ENREGISTREMENTS CONDITION NO ' D-N1
                      ' = ' D-CNT UPON PRINTER.
           IF I > 9 AND I < 100
              MOVE I TO D-N2
              DISPLAY 'NB ENREGISTREMENTS CONDITION NO ' D-N2
                      ' = ' D-CNT UPON PRINTER.
           IF I > 99
              MOVE I TO D-N3
              DISPLAY 'NB ENREGISTREMENTS CONDITION NO ' D-N3
                      ' = ' D-CNT UPON PRINTER.
           ADD 1 TO I.
           GO TO CASE-RPT.
       CASE-RPT-FIN.
           DISPLAY 'NB ENREGISTREMENTS OTHER = ' NB-REC-OTHER
                                                UPON PRINTER.
           DISPLAY ' ' UPON PRINTER.
           DISPLAY ' ' UPON PRINTER.
           DISPLAY ' ' UPON PRINTER.
           DISPLAY ' ' UPON PRINTER.
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
           EXIT.
       TRANSFO-DATE-2-4.
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
           EXIT.
       TRANSFO-DATE-22A.
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
           EXIT.
       TRANSFO-DATE-66A.
           IF WS-A6 NOT NUMERIC
              GO TO TRANSFO-DATE-66A-EXIT.
           IF ((WS-A6-MM > '15') OR (WS-A6-MM = '00'))
              GO TO TRANSFO-DATE-66A-EXIT.
           IF ((WS-A6-JJ > '35') OR (WS-A6-JJ = '00'))
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
           EXIT.
       TRANSFO-DATE-66B.
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
           EXIT.
       TRANSFO-DATE-68.
           MOVE WS-A6 TO WS-A8-YYMMJJ.
           MOVE '19'  TO WS-A8-YY.
           IF WS-A6 = '      '
              MOVE '        ' TO WS-A8
              GO TO TRANSFO-DATE-68-EXIT.
           IF WS-A6 = '000000'
              MOVE '00000000' TO WS-A8
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
           EXIT.
       TRANSFO-DATE-86.
           MOVE WS-A8-YYMMJJ TO WS-A6.
           IF WS-A8 NOT NUMERIC
              GO TO TRANSFO-DATE-86-EXIT.
           IF ((WS-A8-MM > '15') OR (WS-A8-MM = '00'))
              GO TO TRANSFO-DATE-86-EXIT.
           IF ((WS-A8-JJ > '35') OR (WS-A8-JJ = '00'))
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
           EXIT.
       TRANSFO-DATE-22B.
           IF WS-A2-A1 = ';'
              MOVE '0'      TO WS-A2-A1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-22B-200X
              GO TO TRANSFO-DATE-22B-EXIT.
           IF WS-A2-A1 = '_'
              MOVE '1'      TO WS-A2-A1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-22B-201X
              GO TO TRANSFO-DATE-22B-EXIT.
           IF WS-A2-A1 = '|'
              MOVE '2'      TO WS-A2-A1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-22B-202X
              GO TO TRANSFO-DATE-22B-EXIT.
           IF WS-A2-A1 = '~'
              MOVE '3'      TO WS-A2-A1
              MOVE 'Y' TO WS-RECORD-TRANSFORME-22B-203X
              GO TO TRANSFO-DATE-22B-EXIT.
       TRANSFO-DATE-22B-EXIT.
           EXIT.
       WRITE-REC-OUTPUT.
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
           MOVE WS-OUT TO RECOUT.
           WRITE FO1-REC FROM RECOUT.
       WRITE-REC-OUTPUT-EXIT.
           EXIT.
