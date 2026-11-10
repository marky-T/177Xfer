       IDENTIFICATION DIVISION.
      * SSG-4 (MT-056): one LECTIS for every call. Record length, key
      * position, mode (sequential list or key lookup), the COND test
      * and the Y2K key positions come from the SGSPARM file written
      * by the skeleton hand-off (LectisParm.ps1); see spec.md. The
      * data file is read sequentially in both modes (claim C3).
      * Print lines and DISPLAY texts as the skeleton.
       PROGRAM-ID. 'ASSURFED-UTILIT-LECTIS-GN'.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. UNIVAC-1100-60EIS.
       OBJECT-COMPUTER. UNIVAC-1100-60EIS.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA
               PAGE IS SAUT.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PARMF ASSIGN TO DISC SGSPARM.
           SELECT LECIN ASSIGN TO DISC LECIN.
           SELECT LECCRD ASSIGN TO DISC LECCRD.
           SELECT IMP ASSIGN TO PRINTER.
       DATA DIVISION.
       FILE SECTION.
       FD  PARMF
           LABEL RECORD STANDARD.
       01  PARM-REC.
           03  P-TYPE         PIC XX.
           03  P-REST         PIC X(248).
       01  PARM-IN-REC.
           03  FILLER         PIC XX.
           03  PI-LEN         PIC 9(5).
           03  FILLER         PIC X(243).
       01  PARM-KY-REC.
           03  FILLER         PIC XX.
           03  PK-OFF         PIC 9(5).
           03  PK-LEN         PIC 9(5).
           03  FILLER         PIC X(238).
       01  PARM-MD-REC.
           03  FILLER         PIC XX.
           03  PM-KEYS        PIC 9.
           03  PM-NOLIST      PIC 9.
           03  PM-Y2K         PIC 9.
           03  FILLER         PIC X(245).
       01  PARM-CD-REC.
           03  FILLER         PIC XX.
           03  PC-OP          PIC X.
           03  PC-REL         PIC XX.
           03  PC-LITLEN      PIC 9(3).
           03  PC-LIT         PIC X(100).
           03  PC-LITG        REDEFINES PC-LIT.
               05  PC-LITN    PIC 9(9).
               05  FILLER     PIC X(91).
           03  FILLER         PIC X(142).
       01  PARM-YD-REC.
           03  FILLER         PIC XX.
           03  PY-ND          PIC 99.
           03  PY-Z5          PIC 999.
           03  PY-POS         PIC 999 OCCURS 40 TIMES.
           03  FILLER         PIC X(123).
       FD  LECIN
           LABEL RECORD STANDARD
           RECORD VARYING IN SIZE FROM 1 TO 4001
           DEPENDING ON WS-IN-LEN.
       01  LECIN-REC          PIC X(4001).
       FD  LECCRD
           LABEL RECORD STANDARD
           RECORD VARYING IN SIZE FROM 1 TO 4001
           DEPENDING ON WS-CRD-LEN.
       01  LECCRD-REC         PIC X(4001).
       FD  IMP
           LABEL RECORD OMITTED
           LINAGE IS 63
           AT TOP 6
           AT BOTTOM 3
           DATA RECORD ZPRINT.
       01  ZPRINT             PIC X(100) USAGE DISPLAY-1.
       WORKING-STORAGE SECTION.
       77  WS-IN-LEN          PIC 9(5) COMP VALUE 0.
       77  WS-CRD-LEN         PIC 9(5) COMP VALUE 0.
       77  P-LEN              PIC 9(5) COMP VALUE 0.
       77  P-OFF              PIC 9(5) COMP VALUE 0.
       77  P-KLEN             PIC 9(5) COMP VALUE 0.
       77  P-KEYS             PIC 9 VALUE 0.
       77  P-NOLIST           PIC 9 VALUE 0.
       77  P-Y2K              PIC 9 VALUE 0.
       77  P-OP               PIC X VALUE SPACE.
       77  P-REL              PIC XX VALUE SPACES.
       77  P-LITLEN           PIC 9(5) COMP VALUE 0.
       77  P-LITN             PIC 9(9) COMP VALUE 0.
       77  P-LIT              PIC X(100) VALUE SPACES.
       77  P-ND               PIC 9(5) COMP VALUE 0.
       77  P-Z5               PIC 9(5) COMP VALUE 0.
       01  YP-TAB.
           03  YP             PIC 9(5) COMP OCCURS 40 TIMES.
       77  DA                 PIC 9(5) COMP VALUE 0.
       77  CP-LEN             PIC 9(5) COMP VALUE 0.
       77  CC-LEN             PIC 9(5) COMP VALUE 0.
       77  ZL-LEN             PIC 9(5) COMP VALUE 0.
       77  KP                 PIC 9(5) COMP VALUE 0.
       77  COND-OK            PIC 9 VALUE 0.
       01  RECIN              PIC X(4001).
       01  CRDREC             PIC X(4001).
       01  ZL1                PIC X(4001).
       01  SYMK-W             PIC X(4001).
       01  W-A                PIC X(4001).
       01  W-B                PIC X(4001).
       01  WREC               PIC X(4001).
       77  INDEXI             PIC 9(5) COMP VALUE 0.
       77  INDEXO             PIC 9(5) COMP VALUE 0.
       77  SW-AVANT           PIC 9(5) COMP VALUE 0.
       77  DCNT               PIC S9(5) COMP VALUE 0.
       77  W3                 PIC 9(5) COMP VALUE 0.
       77  WS-MARK            PIC X VALUE SPACE.
       01  TAB-INPUT.
           03  TAB-I          PIC X OCCURS 4200 TIMES.
       01  TAB-OUTPUT.
           03  TAB-O          PIC X OCCURS 4200 TIMES.
       01  TIT.
           03  FILLER      PIC X(5) VALUE '***  '.
           03  FILLER        PIC X(14) VALUE 'RECORD NUMERO '.
           03  FILCO     PIC Z.ZZZ.ZZZ.
           03  FILLER      PIC X(5) VALUE '  ***'.
       01  ZPR  USAGE DISPLAY-1  VALUE ALL SPACES.
           03  ZP1            PIC X(100) USAGE DISPLAY-1.
           03  ZP2            PIC X(100) USAGE DISPLAY-1.
           03  ZP3            PIC X(100) USAGE DISPLAY-1.
           03  ZP4            PIC X(100) USAGE DISPLAY-1.
           03  ZP5            PIC X(100) USAGE DISPLAY-1.
           03  ZP6            PIC X(100) USAGE DISPLAY-1.
           03  ZP7            PIC X(100) USAGE DISPLAY-1.
           03  ZP8            PIC X(100) USAGE DISPLAY-1.
           03  ZP9            PIC X(100) USAGE DISPLAY-1.
           03  ZP10           PIC X(100) USAGE DISPLAY-1.
           03  ZP11           PIC X(100) USAGE DISPLAY-1.
           03  ZP12           PIC X(100) USAGE DISPLAY-1.
           03  ZP13           PIC X(100) USAGE DISPLAY-1.
           03  ZP14           PIC X(100) USAGE DISPLAY-1.
           03  ZP15           PIC X(100) USAGE DISPLAY-1.
           03  ZP16           PIC X(100) USAGE DISPLAY-1.
           03  ZP17           PIC X(100) USAGE DISPLAY-1.
           03  ZP18           PIC X(100) USAGE DISPLAY-1.
           03  ZP19           PIC X(100) USAGE DISPLAY-1.
           03  ZP20           PIC X(100) USAGE DISPLAY-1.
       01  CTRLI PIC 9(4) VALUE ZEROES.
       01  CTR                PIC S9(7) VALUE 0.
       01  SWI                PIC S9 VALUE 0.
       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT PARMF.
       PARM-LECT.
           READ PARMF AT END GO TO PARM-FIN.
           IF P-TYPE = 'IN'
              MOVE PI-LEN TO P-LEN.
           IF P-TYPE = 'KY'
              MOVE PK-OFF TO P-OFF
              MOVE PK-LEN TO P-KLEN.
           IF P-TYPE = 'MD'
              MOVE PM-KEYS TO P-KEYS
              MOVE PM-NOLIST TO P-NOLIST
              MOVE PM-Y2K TO P-Y2K.
           IF P-TYPE = 'CD'
              MOVE PC-OP TO P-OP
              MOVE PC-REL TO P-REL
              MOVE PC-LITLEN TO P-LITLEN
              MOVE PC-LIT TO P-LIT.
           IF P-TYPE = 'CD' AND PC-OP = 'C'
              MOVE PC-LITN TO P-LITN.
           IF P-TYPE = 'YD'
              PERFORM YD-COPY THRU YD-COPY-EXIT.
           GO TO PARM-LECT.
       PARM-FIN.
           CLOSE PARMF.
       OUVERT.
           OPEN OUTPUT IMP.
           WRITE ZPRINT FROM ZP1 BEFORE PAGE.
           IF P-KEYS = 1 GO TO KEY-OPEN.
           OPEN INPUT LECIN.
       LECTURE.
           MOVE SPACES TO RECIN.
           READ LECIN INTO RECIN AT END GO TO FIN.
           PERFORM LOAD-WREC THRU LOAD-WREC-EXIT.
           ADD 1 TO CTR.
           IF P-NOLIST = 1 GO TO LECTURE.
           PERFORM COND-TEST THRU COND-TEST-EXIT.
           IF COND-OK = 0 GO TO LECTURE.
       SUITE.
           MOVE CTR TO FILCO.
           WRITE ZPRINT FROM TIT BEFORE 1.
           MOVE WREC TO ZPR.
           PERFORM IMPRES THRU FIIMPRES.
           GO TO LECTURE.
       KEY-OPEN.
           OPEN INPUT LECCRD.
           MOVE P-KLEN TO ZL-LEN.
           IF P-Y2K = 1 MOVE P-Z5 TO ZL-LEN.
       KEY-LOOP.
           MOVE SPACES TO CRDREC.
           READ LECCRD INTO CRDREC AT END GO TO FIN.
           MOVE SPACES TO ZL1.
           MOVE WS-CRD-LEN TO CC-LEN.
           IF CC-LEN > ZL-LEN
              MOVE ZL-LEN TO CC-LEN.
           IF CC-LEN > 0
              MOVE CRDREC (1:CC-LEN) TO ZL1 (1:CC-LEN).
           MOVE SPACES TO SYMK-W.
           IF P-Y2K = 0 GO TO KEY-PLAIN.
           PERFORM FORMAT-CLE THRU FORMAT-CLE-EXIT.
           MOVE TAB-OUTPUT (1:P-KLEN) TO SYMK-W (1:P-KLEN).
           GO TO KEY-FIND.
       KEY-PLAIN.
           MOVE ZL1 (1:P-KLEN) TO SYMK-W (1:P-KLEN).
       KEY-FIND.
           PERFORM SEARCH-KEY THRU SK-EXIT.
           IF SWI = 1 ADD 1 TO CTR.
           IF SWI NOT = 1 MOVE WREC TO ZPR
              PERFORM IMPRES THRU FIIMPRES.
           MOVE 0 TO SWI.
           GO TO KEY-LOOP.
       FIN.
           MOVE SPACES TO ZPRINT.
           WRITE ZPRINT BEFORE SAUT.
           DISPLAY '** FIN DU TRAVAIL **' UPON PRINTER.
           IF P-KEYS = 0
              DISPLAY 'NOMBRE DE RECORDS LUS ** ' CTR UPON PRINTER.
           IF P-KEYS = 1
              DISPLAY 'NOMBRE D INVALID KEY **' CTR UPON PRINTER.
           CLOSE IMP.
           IF P-KEYS = 0 CLOSE LECIN.
           IF P-KEYS = 1 CLOSE LECCRD.
           STOP RUN.
       YD-COPY.
           MOVE PY-ND TO P-ND.
           MOVE PY-Z5 TO P-Z5.
           MOVE 1 TO DA.
       YD-COPY-LOOP.
           IF DA > P-ND GO TO YD-COPY-EXIT.
           MOVE PY-POS (DA) TO YP (DA).
           ADD 1 TO DA.
           GO TO YD-COPY-LOOP.
       YD-COPY-EXIT.
           EXIT.
       LOAD-WREC.
           MOVE SPACES TO WREC.
           MOVE WS-IN-LEN TO CP-LEN.
           IF CP-LEN > P-LEN
              MOVE P-LEN TO CP-LEN.
           IF CP-LEN > 0
              MOVE RECIN (1:CP-LEN) TO WREC (1:CP-LEN).
       LOAD-WREC-EXIT.
           EXIT.
       COND-TEST.
           MOVE 0 TO COND-OK.
           IF P-OP = 'K' GO TO COND-KEY.
           IF P-REL = 'EQ' AND CTR = P-LITN MOVE 1 TO COND-OK.
           IF P-REL = 'NE' AND CTR NOT = P-LITN MOVE 1 TO COND-OK.
           IF P-REL = 'GT' AND CTR > P-LITN MOVE 1 TO COND-OK.
           IF P-REL = 'LT' AND CTR < P-LITN MOVE 1 TO COND-OK.
           IF P-REL = 'GE' AND CTR NOT < P-LITN MOVE 1 TO COND-OK.
           IF P-REL = 'LE' AND CTR NOT > P-LITN MOVE 1 TO COND-OK.
           GO TO COND-TEST-EXIT.
       COND-KEY.
           MOVE SPACES TO W-A.
           MOVE SPACES TO W-B.
           COMPUTE KP = P-OFF + 1.
           MOVE WREC (KP:P-KLEN) TO W-A (1:P-KLEN).
           MOVE P-LIT (1:P-LITLEN) TO W-B (1:P-LITLEN).
           IF P-REL = 'EQ' AND W-A = W-B MOVE 1 TO COND-OK.
           IF P-REL = 'NE' AND W-A NOT = W-B MOVE 1 TO COND-OK.
           IF P-REL = 'GT' AND W-A > W-B MOVE 1 TO COND-OK.
           IF P-REL = 'LT' AND W-A < W-B MOVE 1 TO COND-OK.
           IF P-REL = 'GE' AND W-A NOT < W-B MOVE 1 TO COND-OK.
           IF P-REL = 'LE' AND W-A NOT > W-B MOVE 1 TO COND-OK.
       COND-TEST-EXIT.
           EXIT.
       SEARCH-KEY.
           MOVE 1 TO SWI.
           COMPUTE KP = P-OFF + 1.
           OPEN INPUT LECIN.
       SK-LOOP.
           MOVE SPACES TO RECIN.
           READ LECIN INTO RECIN AT END GO TO SK-CLOSE.
           PERFORM LOAD-WREC THRU LOAD-WREC-EXIT.
           IF WREC (KP:P-KLEN) = SYMK-W (1:P-KLEN)
              MOVE 0 TO SWI
              GO TO SK-CLOSE.
           GO TO SK-LOOP.
       SK-CLOSE.
           CLOSE LECIN.
       SK-EXIT.
           EXIT.
       IMPRES.
           WRITE ZPRINT FROM ZP1 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP2 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP3 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP4 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP5 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP6 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP7 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP8 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP9 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP10 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP11 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP12 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP13 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP14 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP15 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP16 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP17 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP18 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP19 BEFORE 1.
           ADD 100 TO CTRLI.
           IF P-LEN = CTRLI GO TO RAZ.
           IF P-LEN < CTRLI GO TO RAZ.
           WRITE ZPRINT FROM ZP20 BEFORE 1.
       RAZ.
           MOVE  SPACES TO ZP1 ZP2 ZP3 ZP4 ZP5 ZP6 ZP7 ZP8 ZP9.
           MOVE  SPACES TO ZP10 ZP11 ZP12 ZP13 ZP14 ZP15 ZP16 ZP17.
           MOVE  SPACES TO ZP18 ZP19 ZP20.
           MOVE ZEROES TO CTRLI.
           MOVE ALL '*' TO ZPRINT.
           WRITE ZPRINT BEFORE 1.
       FIIMPRES.
           EXIT.
       FORMAT-CLE.
           MOVE SPACES TO TAB-INPUT.
           MOVE SPACES TO TAB-OUTPUT.
           MOVE ZL1 (1:P-Z5) TO TAB-INPUT (1:P-Z5).
           MOVE 1 TO INDEXI.
           MOVE 1 TO INDEXO.
           COMPUTE SW-AVANT = YP (1) - 1.
           PERFORM MOVE-CHAR THRU MOVE-CHAR-EXIT SW-AVANT TIMES.
           MOVE 1 TO DA.
       DATE-LOOP.
           IF DA > P-ND GO TO FORMAT-CLE-EXIT.
           IF TAB-I (INDEXI) NOT = '2'
              ADD 2 TO INDEXI
              PERFORM MOVE-CHAR THRU MOVE-CHAR-EXIT 2 TIMES
              GO TO DATE-TAIL.
           ADD 1 TO INDEXI.
           IF TAB-I (INDEXI) NOT = '0' GO TO DATE-TAIL.
           IF TAB-I (INDEXI + 1) = '0' MOVE ';' TO WS-MARK
              GO TO DATE-PUT.
           IF TAB-I (INDEXI + 1) = '1' MOVE '_' TO WS-MARK
              GO TO DATE-PUT.
           IF TAB-I (INDEXI + 1) = '2' MOVE '|' TO WS-MARK
              GO TO DATE-PUT.
           IF TAB-I (INDEXI + 1) = '3' MOVE '~' TO WS-MARK
              GO TO DATE-PUT.
           GO TO DATE-TAIL.
       DATE-PUT.
           MOVE WS-MARK TO TAB-O (INDEXO).
           ADD 2 TO INDEXI.
           ADD 1 TO INDEXO.
           PERFORM MOVE-CHAR THRU MOVE-CHAR-EXIT.
       DATE-TAIL.
           MOVE YP (DA) TO W3.
           IF DA = P-ND
              COMPUTE DCNT = P-KLEN - W3 + 2
           ELSE
              COMPUTE DCNT = YP (DA + 1) - W3 - 4.
           IF DCNT > 0
              PERFORM MOVE-CHAR THRU MOVE-CHAR-EXIT DCNT TIMES.
           ADD 1 TO DA.
           GO TO DATE-LOOP.
       FORMAT-CLE-EXIT.
           EXIT.
       MOVE-CHAR.
           MOVE TAB-I (INDEXI) TO TAB-O (INDEXO).
           ADD 1 TO INDEXI.
           ADD 1 TO INDEXO.
       MOVE-CHAR-EXIT.
           EXIT.
