       IDENTIFICATION DIVISION.
      * SSG-4 archive work (MT-050): one ARCHISEPARE for every call. Key
      * lengths, key offset, record length and names come from the
      * SGSPARM file written by the skeleton hand-off; behaviour as in
      * Conversion\Pipeline\Generic\ARCHISEPARE\spec.md (source:
      * SSG-Source\ARCHISEPARE, UCS COBOL).
      * SGSPARM (250): KY<k1 5><offset 5><k2 5><rsz 5>
      *                TN<base 6><table 30>  FN<archi 30><narchi 30>
      * Keys up to 18 digits, rsz up to 3968 (32 + rsz <= 4000).
       PROGRAM-ID. 'ARCHISEPARE-GN'.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. UNIVAC-1100-10.
       OBJECT-COMPUTER. UNIVAC-1100-10.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PARMF ASSIGN TO DISC SGSPARM.
           SELECT FKEY ASSIGN TO DISC ARCKEY.
           SELECT FUNL ASSIGN TO DISC ARCUNL.
           SELECT FARC ASSIGN TO DISC ARCOUT.
           SELECT FNAR ASSIGN TO DISC ARCNOUT.
       DATA DIVISION.
       FILE SECTION.
       FD  PARMF
           LABEL RECORD STANDARD.
       01  PARM-REC.
           03  P-TYPE         PIC XX.
           03  P-REST         PIC X(248).
       01  PARM-KY-REC.
           03  FILLER         PIC XX.
           03  PK-K1          PIC 9(5).
           03  PK-OFF         PIC 9(5).
           03  PK-K2          PIC 9(5).
           03  PK-RSZ         PIC 9(5).
           03  FILLER         PIC X(228).
       01  PARM-TN-REC.
           03  FILLER         PIC XX.
           03  PT-BASE        PIC X(6).
           03  PT-TABLE       PIC X(30).
           03  FILLER         PIC X(212).
       01  PARM-FN-REC.
           03  FILLER         PIC XX.
           03  PN-ARCHI       PIC X(30).
           03  PN-NARCHI      PIC X(30).
           03  FILLER         PIC X(188).
       FD  FKEY
           LABEL RECORD STANDARD
           RECORD VARYING IN SIZE FROM 1 TO 4001
           DEPENDING ON WS-KEY-LEN.
       01  FKEY-REC PIC X(4001).
       FD  FUNL
           LABEL RECORD STANDARD
           RECORD VARYING IN SIZE FROM 1 TO 4001
           DEPENDING ON WS-UNL-LEN.
       01  FUNL-REC PIC X(4001).
       FD  FARC
           LABEL RECORD STANDARD.
       01  FARC-REC PIC X(4000).
       FD  FNAR
           LABEL RECORD STANDARD.
       01  FNAR-REC PIC X(4000).
       WORKING-STORAGE SECTION.
       01  RECIN              PIC X(4001).
       01  WS-KEYREC          PIC X(4000).
       01  WS-UNL             PIC X(4000).
       01  WS-OUT             PIC X(4000).
       01  KEY-C-X            PIC X(18).
       01  KEY-C-N REDEFINES KEY-C-X PIC 9(18).
       01  KEY-U-X            PIC X(18).
       01  KEY-U-N REDEFINES KEY-U-X PIC 9(18).
       77  WS-KEY-LEN         PIC 9(5) COMP VALUE 0.
       77  WS-UNL-LEN         PIC 9(5) COMP VALUE 0.
       77  P-K1               PIC 9(5) COMP VALUE 0.
       77  P-OFF              PIC 9(5) COMP VALUE 0.
       77  P-K2               PIC 9(5) COMP VALUE 0.
       77  P-RSZ              PIC 9(5) COMP VALUE 0.
       77  P-KST              PIC 9(5) COMP VALUE 0.
       77  P-KSU              PIC 9(5) COMP VALUE 0.
       77  P-KSC              PIC 9(5) COMP VALUE 0.
       77  P-DON              PIC 9(5) COMP VALUE 0.
       77  CP-LEN             PIC 9(5) COMP VALUE 0.
       77  P-BASE             PIC X(6) VALUE SPACES.
       77  P-TABLE            PIC X(30) VALUE SPACES.
       77  P-ARCHI            PIC X(30) VALUE SPACES.
       77  P-NARCHI           PIC X(30) VALUE SPACES.
       77  LECRCHF            PIC 9 VALUE 0.
       77  LECUNLOADF         PIC 9 VALUE 0.
       77  CPTLU              PIC 9(7) VALUE 0.
       77  CPTARCHI           PIC 9(7) VALUE 0.
       77  CPTNARCHI          PIC 9(7) VALUE 0.
       77  CPTLUF             PIC Z(6)9.
       77  CPTARCHIF          PIC Z(6)9.
       77  CPTNARCHIF         PIC Z(6)9.
       01  LIGNE-TYPE9.
           03  CD-DON9        PIC X VALUE '9'.
           03  NM-BAS9        PIC X(6).
           03  NM-TAB9        PIC X(30).
           03  DT-ACH9        PIC X(8).
           03  CPTACH1        PIC S9(11) SIGN LEADING SEPARATE.
           03  CPTACH2        PIC S9(11) SIGN LEADING SEPARATE.
       01  DATE-I.
           03  ANNEE-I        PIC 9(4).
           03  MOIS-I         PIC 99.
           03  JOUR-I         PIC 99.
       01  DATE-FR.
           03  JOUR-FR        PIC 99.
           03  FILLER         PIC X VALUE '/'.
           03  MOIS-FR        PIC 99.
           03  FILLER         PIC X VALUE '/'.
           03  ANNEE-FR       PIC 9(4).
       01  WS-MSG             PIC X(80).
       77  WS-PTR             PIC 9(3) COMP VALUE 0.
       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT PARMF.
       PARM-LECT.
           READ PARMF AT END GO TO PARM-FIN.
           IF P-TYPE = 'KY'
              MOVE PK-K1 TO P-K1
              MOVE PK-OFF TO P-OFF
              MOVE PK-K2 TO P-K2
              MOVE PK-RSZ TO P-RSZ.
           IF P-TYPE = 'TN'
              MOVE PT-BASE TO P-BASE
              MOVE PT-TABLE TO P-TABLE.
           IF P-TYPE = 'FN'
              MOVE PN-ARCHI TO P-ARCHI
              MOVE PN-NARCHI TO P-NARCHI.
           GO TO PARM-LECT.
       PARM-FIN.
           CLOSE PARMF.
           COMPUTE P-KST = P-OFF + 1.
           COMPUTE P-KSU = 19 - P-K2.
           COMPUTE P-KSC = 19 - P-K1.
           COMPUTE P-DON = 3 + P-K2.
           OPEN INPUT FKEY FUNL.
           OPEN OUTPUT FARC FNAR.
           PERFORM LEC-KEY THRU LEC-KEY-EXIT.
           PERFORM LEC-UNL THRU LEC-UNL-EXIT.
      * 102-SEPARE: sorted key match, as in the source.
       SEPARE.
           IF LECUNLOADF = 1 GO TO TYPE9.
           IF LECRCHF = 1 GO TO NARCHI.
           IF KEY-C-N = KEY-U-N GO TO ARCHI.
           IF KEY-C-N > KEY-U-N GO TO NARCHI.
           PERFORM LEC-KEY THRU LEC-KEY-EXIT.
           GO TO SEPARE.
       ARCHI.
           MOVE SPACES TO WS-OUT.
           MOVE '4A' TO WS-OUT (1:2).
           MOVE KEY-U-X (P-KSU:P-K2) TO WS-OUT (3:P-K2).
           MOVE WS-UNL (1:P-RSZ) TO WS-OUT (P-DON:P-RSZ).
           WRITE FARC-REC FROM WS-OUT.
           ADD 1 TO CPTARCHI.
           PERFORM LEC-UNL THRU LEC-UNL-EXIT.
           IF KEY-U-N NOT = KEY-C-N
              PERFORM LEC-KEY THRU LEC-KEY-EXIT.
           GO TO SEPARE.
       NARCHI.
           MOVE SPACES TO WS-OUT.
           MOVE WS-UNL (1:P-RSZ) TO WS-OUT (1:P-RSZ).
           WRITE FNAR-REC FROM WS-OUT.
           ADD 1 TO CPTNARCHI.
           PERFORM LEC-UNL THRU LEC-UNL-EXIT.
           GO TO SEPARE.
      * Type-9 trailer: 69 bytes, cut at the record length (32 + rsz)
      * by the runtime, as WRITE FROM cuts it in the source.
       TYPE9.
           MOVE P-BASE TO NM-BAS9.
           MOVE P-TABLE TO NM-TAB9.
           ACCEPT DATE-I FROM DATE YYYYMMDD.
           MOVE DATE-I TO DT-ACH9.
           MOVE CPTARCHI TO CPTACH1 CPTACH2.
           MOVE SPACES TO WS-OUT.
           MOVE LIGNE-TYPE9 TO WS-OUT (1:69).
           WRITE FARC-REC FROM WS-OUT.
           MOVE ANNEE-I TO ANNEE-FR.
           MOVE MOIS-I TO MOIS-FR.
           MOVE JOUR-I TO JOUR-FR.
           MOVE CPTLU TO CPTLUF.
           MOVE CPTARCHI TO CPTARCHIF.
           MOVE CPTNARCHI TO CPTNARCHIF.
           DISPLAY 'Archisepare              Rapport             '
             DATE-FR UPON PRINTER.
           DISPLAY ' ' UPON PRINTER.
           DISPLAY 'Enregistrement lu : ' CPTLUF UPON PRINTER.
           MOVE SPACES TO WS-MSG.
           MOVE 1 TO WS-PTR.
           STRING 'Enregistrement ecrit dans ' DELIMITED BY SIZE
                  P-ARCHI DELIMITED BY SPACE
                  ' : ' DELIMITED BY SIZE
             INTO WS-MSG WITH POINTER WS-PTR.
           SUBTRACT 1 FROM WS-PTR.
           DISPLAY WS-MSG (1:WS-PTR) CPTARCHIF UPON PRINTER.
           MOVE SPACES TO WS-MSG.
           MOVE 1 TO WS-PTR.
           STRING 'Enregistrement ecrit dans ' DELIMITED BY SIZE
                  P-NARCHI DELIMITED BY SPACE
                  ' : ' DELIMITED BY SIZE
             INTO WS-MSG WITH POINTER WS-PTR.
           SUBTRACT 1 FROM WS-PTR.
           DISPLAY WS-MSG (1:WS-PTR) CPTNARCHIF UPON PRINTER.
           CLOSE FKEY FUNL FARC FNAR.
           STOP RUN.
      * 100-LEC-CHERCHEUSE: the key as a number (PIC 9 compare).
       LEC-KEY.
           MOVE SPACES TO RECIN.
           READ FKEY INTO RECIN AT END
              MOVE 1 TO LECRCHF
              GO TO LEC-KEY-EXIT.
           MOVE SPACES TO WS-KEYREC.
           MOVE WS-KEY-LEN TO CP-LEN.
           IF CP-LEN > P-K1
              MOVE P-K1 TO CP-LEN.
           IF CP-LEN > 0
              MOVE RECIN (1:CP-LEN) TO WS-KEYREC (1:CP-LEN).
           MOVE ALL '0' TO KEY-C-X.
           MOVE WS-KEYREC (1:P-K1) TO KEY-C-X (P-KSC:P-K1).
       LEC-KEY-EXIT.
           EXIT.
      * 101-LEC-UNLOAD: the record padded to rsz, and its key.
       LEC-UNL.
           MOVE SPACES TO RECIN.
           READ FUNL INTO RECIN AT END
              MOVE 1 TO LECUNLOADF
              GO TO LEC-UNL-EXIT.
           ADD 1 TO CPTLU.
           MOVE SPACES TO WS-UNL.
           MOVE WS-UNL-LEN TO CP-LEN.
           IF CP-LEN > P-RSZ
              MOVE P-RSZ TO CP-LEN.
           IF CP-LEN > 0
              MOVE RECIN (1:CP-LEN) TO WS-UNL (1:CP-LEN).
           MOVE ALL '0' TO KEY-U-X.
           MOVE WS-UNL (P-KST:P-K2) TO KEY-U-X (P-KSU:P-K2).
       LEC-UNL-EXIT.
           EXIT.
