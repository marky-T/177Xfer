       IDENTIFICATION DIVISION.
      * SSG-4 archive work (MT-050): one ARCHIFORMAT for all calls. Key,
      * record length, column count and names come from the SGSPARM
      * file written by the skeleton hand-off; behaviour as in
      * Conversion\Pipeline\Generic\ARCHIFORMAT\spec.md (source:
      * SSG-Source\ARCHIFORMAT.TXT, UCS COBOL). The report and the
      * description are written by the skeleton's ECL steps first.
      * SGSPARM (250): TB<base 6><table 30>
      *                KY<key name 30><key type 1><key length 5>
      *                RZ<rsz 5><columns 5>
      * Unload record (b = k + rsz + 1 + columns) up to 3998.
       PROGRAM-ID. 'ASSURFED-UTILIT-ARCHIFORMAT-GN'.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. UNIVAC-1100-10.
       OBJECT-COMPUTER. UNIVAC-1100-10.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PARMF ASSIGN TO DISC SGSPARM.
           SELECT FIC-REPORT ASSIGN TO DISC ARFREP.
           SELECT FIC-DESCRIPT ASSIGN TO DISC ARFDES.
           SELECT FIC-UNLOAD ASSIGN TO DISC ARFUNL.
           SELECT FIC-FORMAT ASSIGN TO DISC ARFOUT.
       DATA DIVISION.
       FILE SECTION.
       FD  PARMF
           LABEL RECORD STANDARD.
       01  PARM-REC.
           03  P-TYPE         PIC XX.
           03  P-REST         PIC X(248).
       01  PARM-TB-REC.
           03  FILLER         PIC XX.
           03  PT-BASE        PIC X(6).
           03  PT-TABLE       PIC X(30).
           03  FILLER         PIC X(212).
       01  PARM-KY-REC.
           03  FILLER         PIC XX.
           03  PK-NAME        PIC X(30).
           03  PK-TYPE        PIC X.
           03  PK-LEN         PIC 9(5).
           03  FILLER         PIC X(212).
       01  PARM-RZ-REC.
           03  FILLER         PIC XX.
           03  PR-RSZ         PIC 9(5).
           03  PR-COLS        PIC 9(5).
           03  FILLER         PIC X(238).
       FD  FIC-REPORT
           LABEL RECORD STANDARD
           RECORD VARYING IN SIZE FROM 1 TO 4001
           DEPENDING ON WS-REP-LEN.
       01  FIC-REPORT-REC     PIC X(4001).
       FD  FIC-DESCRIPT
           LABEL RECORD STANDARD
           RECORD VARYING IN SIZE FROM 1 TO 4001
           DEPENDING ON WS-DES-LEN.
       01  FIC-DESCRIPT-REC   PIC X(4001).
       FD  FIC-UNLOAD
           LABEL RECORD STANDARD
           RECORD VARYING IN SIZE FROM 1 TO 4001
           DEPENDING ON WS-UNL-LEN.
       01  FIC-UNLOAD-REC     PIC X(4001).
       FD  FIC-FORMAT
           LABEL RECORD STANDARD.
       01  LGN-FOR            PIC X(4000).
       WORKING-STORAGE SECTION.
      * The source's 132-byte record areas. Inputs are read at 4001
      * (T3-040); the areas keep their last record at end of file.
       01  LGN-REP            PIC X(132).
       01  LGN-DES            PIC X(132).
       77  WS-REP-LEN         PIC 9(5) COMP VALUE 0.
       77  WS-DES-LEN         PIC 9(5) COMP VALUE 0.
       01  RECIN              PIC X(4001).
       01  WS-UNL             PIC X(4000).
       77  WS-UNL-LEN         PIC 9(5) COMP VALUE 0.
       77  CP-LEN             PIC 9(5) COMP VALUE 0.
       77  P-K                PIC 9(5) COMP VALUE 0.
       77  P-RSZ              PIC 9(5) COMP VALUE 0.
       77  P-T                PIC 9(5) COMP VALUE 0.
       77  P-B                PIC 9(5) COMP VALUE 0.
       77  P-C                PIC 9(5) COMP VALUE 0.
       77  P-D                PIC 9(5) COMP VALUE 0.
       77  P-E                PIC 9(5) COMP VALUE 0.
      *enregistrement type 0
       01  WS-DON-0.
           03  WS-0-TYP       PIC X VALUE '0'.
           03  WS-0-NM-BASE   PIC X(6).
           03  WS-0-NM-TABLE  PIC X(30).
           03  WS-0-DT-ACH    PIC 9(8).
           03  WS-0-DT-MAJ.
            05 WS-0-DT-MAJ-SS PIC 99.
            05 WS-0-DT-MAJ-AA PIC 99.
            05 WS-0-DT-MAJ-MM PIC 99.
            05 WS-0-DT-MAJ-JJ PIC 99.
      *enregistrement type 1
       01  WS-DON-1.
           03  WS-1-TYP       PIC X VALUE '1'.
           03  WS-1-NM-CLE    PIC X(30).
           03  WS-1-CLE.
            05 WS-1-TYP-CLE   PIC X.
            05 WS-1-LG-CLE    PIC 99.99.
      *enregistrement type 2
       01  WS-DON-2.
           03  WS-2-TYP       PIC X VALUE '2'.
           03  WS-2-NM-CHP    PIC X(30).
           03  WS-2-TYP-CHP   PIC X(7).
           03  WS-2-LG-CHP    PIC X(10).
           03  WS-2-NULL      PIC X(8).
      *enregistrement type 3
       01  WS-DON-3.
           03  WS-3-TYP       PIC X VALUE '3'.
           03  WS-3-NM-IDX    PIC X(30).
           03  WS-3-NM-CHP    PIC X(30).
           03  WS-3-TRI       PIC X(8).
      *enregistrement type 4 (cut at a = b + 1 by the record length)
       01  WS-DON-4.
           03  WS-4-TYP       PIC XX VALUE '4A'.
           03  WS-4-DON       PIC X(3998).
      *enregistrement type 9
       01  WS-DON-9.
           03  WS-9-TYP       PIC X VALUE '9'.
           03  WS-9-NM-BASE   PIC X(6).
           03  WS-9-NM-TABLE  PIC X(30).
           03  WS-9-DT-ACH    PIC 9(8).
           03  WS-9-CPT-ACH   PIC S9(11) SIGN LEADING SEPARATE.
           03  WS-9-CPT-5     PIC X(12) VALUE '+00000000000'.
       01  UNLOADF            PIC 9 VALUE 0.
       01  TABLE-NULL.
           03  TNULL          PIC X OCCURS 70 TIMES.
       77  I                  PIC 99.
       77  I-BUF              PIC 99.
       77  I-TOT              PIC 99.
       77  FL-NULL            PIC 9.
       77  CPT-CHAR           PIC 999.
       77  CPT-ACH            PIC 9(11) VALUE 0.
       77  CPT-LU             PIC 9(11) VALUE 0.
       77  CPT-ACHF           PIC Z(10)9.
       77  CPT-LUF            PIC Z(10)9.
       01  DT-I.
           03  AA-I           PIC 9(4).
           03  MM-I           PIC 99.
           03  JJ-I           PIC 99.
       01  DT-FR.
           03  JJ-FR          PIC 99.
           03  FILLER         PIC X VALUE '/'.
           03  MM-FR          PIC 99.
           03  FILLER         PIC X VALUE '/'.
           03  AA-FR          PIC 9(4).
       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT PARMF.
       PARM-LECT.
           READ PARMF AT END GO TO PARM-FIN.
           IF P-TYPE = 'TB'
              MOVE PT-BASE TO WS-0-NM-BASE WS-9-NM-BASE
              MOVE PT-TABLE TO WS-0-NM-TABLE WS-9-NM-TABLE.
           IF P-TYPE = 'KY'
              MOVE PK-NAME TO WS-1-NM-CLE
              MOVE PK-TYPE TO WS-1-TYP-CLE
              MOVE PK-LEN TO P-K.
           IF P-TYPE = 'RZ'
              MOVE PR-RSZ TO P-RSZ
              MOVE PR-COLS TO P-T.
           GO TO PARM-LECT.
       PARM-FIN.
           CLOSE PARMF.
           COMPUTE P-E = P-K + P-RSZ.
           COMPUTE P-D = P-E + 1.
           COMPUTE P-C = P-E + 2.
           COMPUTE P-B = P-E + 1 + P-T.
           OPEN INPUT FIC-REPORT FIC-DESCRIPT FIC-UNLOAD
                OUTPUT FIC-FORMAT.
           PERFORM 100-TYPE0 THRU 100-EXIT.
           PERFORM 101-TYPE1 THRU 101-EXIT.
           PERFORM 102-TYPE2 THRU 102-EXIT.
           PERFORM 103-TYPE3 THRU 103-EXIT.
           PERFORM 104-TYPE4 THRU 104-EXIT.
           PERFORM 105-TYPE9 THRU 105-EXIT.
           PERFORM 106-TOT THRU 106-EXIT.
           CLOSE FIC-REPORT FIC-DESCRIPT FIC-UNLOAD FIC-FORMAT.
           STOP RUN.
      *------------ ENREGISTREMENT DE TYPE 0 ----------------
       100-TYPE0.
           ACCEPT WS-0-DT-ACH FROM DATE YYYYMMDD.
           PERFORM 200-LEC-REPORT THRU 200-EXIT UNTIL LGN-REP (4:21)
             = 'DD-PROCESS-TIME-STAMP'.
           PERFORM 200-LEC-REPORT THRU 200-EXIT.
           MOVE LGN-REP (7:2) TO WS-0-DT-MAJ-AA.
           IF WS-0-DT-MAJ-AA > 90
              MOVE 19 TO WS-0-DT-MAJ-SS
           ELSE
              MOVE 20 TO WS-0-DT-MAJ-SS.
           MOVE LGN-REP (10:2) TO WS-0-DT-MAJ-MM.
           MOVE LGN-REP (13:2) TO WS-0-DT-MAJ-JJ.
           WRITE LGN-FOR FROM WS-DON-0.
       100-EXIT.
           EXIT.
      *------------ ENREGISTREMENT DE TYPE 1 -----------------
       101-TYPE1.
           MOVE P-K TO WS-1-LG-CLE.
           WRITE LGN-FOR FROM WS-DON-1.
       101-EXIT.
           EXIT.
      *------------ ENREGISTREMENT DE TYPE 2 -----------------
       102-TYPE2.
           PERFORM 200-LEC-REPORT THRU 200-EXIT
             UNTIL LGN-REP (1:7) = 'Columns'.
           PERFORM 200-LEC-REPORT THRU 200-EXIT 2 TIMES.
           MOVE 0 TO CPT-CHAR.
           INSPECT LGN-REP TALLYING CPT-CHAR
                           FOR CHARACTERS
                           BEFORE INITIAL 'Allowed'.
           MOVE CPT-CHAR TO I-BUF.
           PERFORM 200-LEC-REPORT THRU 200-EXIT.
           PERFORM 201-LEC-DESCRIPT THRU 201-EXIT 2 TIMES.
           MOVE 0 TO CPT-CHAR.
           INSPECT LGN-DES TALLYING CPT-CHAR
                           FOR CHARACTERS
                           BEFORE INITIAL 'TION.'.
           ADD 6 TO CPT-CHAR.
           PERFORM 102-COL THRU 102-COL-EXIT P-T TIMES.
       102-EXIT.
           EXIT.
       102-COL.
           MOVE LGN-DES (CPT-CHAR:30) TO WS-2-NM-CHP.
           MOVE LGN-DES (6:7) TO WS-2-TYP-CHP.
           MOVE LGN-DES (13:10) TO WS-2-LG-CHP.
           MOVE LGN-REP TO TABLE-NULL.
           ADD 3 TO I-BUF GIVING I.
           MOVE 0 TO FL-NULL.
           ADD 2 TO I GIVING I-TOT.
           PERFORM 102-NULL THRU 102-NULL-EXIT UNTIL I NOT < I-TOT.
           IF FL-NULL = 1
              MOVE 'NULL' TO WS-2-NULL
           ELSE
              MOVE SPACE TO WS-2-NULL.
           WRITE LGN-FOR FROM WS-DON-2.
           PERFORM 200-LEC-REPORT THRU 200-EXIT.
           PERFORM 201-LEC-DESCRIPT THRU 201-EXIT.
       102-COL-EXIT.
           EXIT.
      *recherche [Y] et ensuite [E] pour NULL
       102-NULL.
           IF TNULL (I) = 'Y'
              ADD 1 TO I
              IF TNULL (I) = 'E'
                 MOVE 1 TO FL-NULL.
           ADD 1 TO I.
       102-NULL-EXIT.
           EXIT.
      *------------ ENREGISTREMENT DE TYPE 3 -----------------
       103-TYPE3.
           PERFORM 200-LEC-REPORT THRU 200-EXIT
             UNTIL LGN-REP (1:13) = 'Primary Key :'.
           MOVE 0 TO CPT-CHAR.
           INSPECT LGN-REP TALLYING CPT-CHAR
                           FOR CHARACTERS
                           BEFORE INITIAL 'PK_'.
           ADD 1 TO CPT-CHAR.
           MOVE LGN-REP (CPT-CHAR:30) TO WS-3-NM-IDX.
           PERFORM 200-LEC-REPORT THRU 200-EXIT 2 TIMES.
           PERFORM 103-COL THRU 103-COL-EXIT
             UNTIL LGN-REP (1:10) = SPACE.
       103-EXIT.
           EXIT.
       103-COL.
           MOVE 0 TO CPT-CHAR.
           INSPECT LGN-REP TALLYING CPT-CHAR
                           FOR CHARACTERS
                           BEFORE INITIAL ','.
           SUBTRACT 4 FROM CPT-CHAR.
           MOVE LGN-REP (5:CPT-CHAR) TO WS-3-NM-CHP.
           ADD 7 TO CPT-CHAR.
           MOVE LGN-REP (CPT-CHAR:3) TO WS-3-TRI.
           WRITE LGN-FOR FROM WS-DON-3.
           PERFORM 200-LEC-REPORT THRU 200-EXIT.
       103-COL-EXIT.
           EXIT.
      *------------ ENREGISTREMENT DE TYPE 4 -----------------
       104-TYPE4.
           PERFORM 104-REC THRU 104-REC-EXIT UNTIL UNLOADF = 1.
       104-EXIT.
           EXIT.
       104-REC.
           PERFORM 202-LEC-UNLOAD THRU 202-EXIT.
           IF UNLOADF NOT = 1
              WRITE LGN-FOR FROM WS-DON-4
              ADD 1 TO CPT-ACH.
       104-REC-EXIT.
           EXIT.
      *------------ ENREGISTREMENT DE TYPE 9 -----------------
       105-TYPE9.
           ACCEPT WS-9-DT-ACH FROM DATE YYYYMMDD.
           MOVE CPT-ACH TO WS-9-CPT-ACH.
           WRITE LGN-FOR FROM WS-DON-9.
       105-EXIT.
           EXIT.
      *----------------- RAPPORT  -----------------
       106-TOT.
           MOVE CPT-ACH TO CPT-ACHF.
           MOVE CPT-LU TO CPT-LUF.
           MOVE WS-0-DT-ACH TO DT-I.
           MOVE AA-I TO AA-FR.
           MOVE MM-I TO MM-FR.
           MOVE JJ-I TO JJ-FR.
           DISPLAY 'ARCHIFORMAT          RAPPORT          '
             DT-FR UPON PRINTER.
           DISPLAY 'Enregistrements lus:' CPT-LUF UPON PRINTER.
           DISPLAY 'Enregistrements 4 écrits:' CPT-ACHF UPON PRINTER.
       106-EXIT.
           EXIT.
      *--------------- LECTURE DU REPORT --------------
       200-LEC-REPORT.
           READ FIC-REPORT
             AT END
               DISPLAY 'fin du report' UPON PRINTER
               GO TO 200-EXIT.
           MOVE SPACES TO LGN-REP.
           MOVE WS-REP-LEN TO CP-LEN.
           IF CP-LEN > 132
              MOVE 132 TO CP-LEN.
           IF CP-LEN > 0
              MOVE FIC-REPORT-REC (1:CP-LEN)
                TO LGN-REP (1:CP-LEN).
       200-EXIT.
           EXIT.
      *--------------- LECTURE DU DESCRIPT ------------
       201-LEC-DESCRIPT.
           READ FIC-DESCRIPT
             AT END
               DISPLAY 'fin de la description' UPON PRINTER
               GO TO 201-EXIT.
           MOVE SPACES TO LGN-DES.
           MOVE WS-DES-LEN TO CP-LEN.
           IF CP-LEN > 132
              MOVE 132 TO CP-LEN.
           IF CP-LEN > 0
              MOVE FIC-DESCRIPT-REC (1:CP-LEN)
                TO LGN-DES (1:CP-LEN).
       201-EXIT.
           EXIT.
      *--------------- LECTURE DE L'UNLOAD --------------
       202-LEC-UNLOAD.
           MOVE SPACES TO RECIN.
           READ FIC-UNLOAD INTO RECIN
             AT END
               MOVE 1 TO UNLOADF
               GO TO 202-EXIT.
           MOVE SPACES TO WS-UNL.
           MOVE WS-UNL-LEN TO CP-LEN.
           IF CP-LEN > P-B
              MOVE P-B TO CP-LEN.
           IF CP-LEN > 0
              MOVE RECIN (1:CP-LEN) TO WS-UNL (1:CP-LEN).
           MOVE WS-UNL (1:P-E) TO WS-4-DON (1:P-E).
           MOVE WS-UNL (P-C:P-T) TO WS-4-DON (P-D:P-T).
           ADD 1 TO CPT-LU.
       202-EXIT.
           EXIT.
