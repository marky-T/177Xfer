       IDENTIFICATION DIVISION.
      * SSG-4 (MT-043): one SCAN for every call. Record length, the
      * input name in the end line and the IF R < n limit come from the
      * SGSPARM file written by the skeleton hand-off; see
      * _scratch\spike-scan\spec.md. Print lines as the skeleton.
       PROGRAM-ID. 'ASSURFED-UTILIT-SCAN-GN'.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.  UNIVAC-1100-60EIS.
       OBJECT-COMPUTER.  UNIVAC-1100-60EIS.
       SPECIAL-NAMES.  PRINTER IS LISTE.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT  PARMF  ASSIGN  TO  DISC SGSPARM.
           SELECT  TAPEIN  ASSIGN  TO  DISC SCANIN.
           SELECT  PRT  ASSIGN  TO  PRINTER.
       DATA DIVISION.
       FILE SECTION.
       FD  PARMF
           LABEL RECORD STANDARD.
       01  PARM-REC.
           03  P-TYPE         PIC XX.
           03  P-REST         PIC X(78).
       01  PARM-LEN-REC.
           03  FILLER         PIC XX.
           03  PL-LEN         PIC 9(5).
           03  FILLER         PIC X(73).
       01  PARM-NAME-REC.
           03  FILLER         PIC XX.
           03  PN-TEXT        PIC X(37).
           03  FILLER         PIC X(41).
       01  PARM-MAX-REC.
           03  FILLER         PIC XX.
           03  PX-MAX         PIC 9(10).
           03  FILLER         PIC X(68).
       FD  TAPEIN
           LABEL RECORD IS STANDARD
           RECORD VARYING IN SIZE FROM 1 TO 4001
           DEPENDING ON WS-IN-LEN.
       01  REC-IN             PIC X(4001).
       FD  PRT      LABEL RECORD IS OMITTED  DATA RECORD IS PRT-LINE.
       01  PRT-LINE          PIC X(100)          USAGE  DISPLAY-1.
       WORKING-STORAGE SECTION.
       01  RECIN              PIC X(4001).
       01  REC-AREA           PIC X(4000).
       01  WS-CHUNK           PIC X(100).
       77  WS-IN-LEN          PIC 9(5) COMP VALUE 0.
       77  CP-LEN             PIC 9(5) COMP VALUE 0.
       77  P-LEN              PIC 9(5) COMP VALUE 0.
       77  P-MAX              PIC 9(10) COMP VALUE 0.
       77  N-CHUNK            PIC 9(5) COMP VALUE 0.
       77  K                  PIC 9(5) COMP VALUE 0.
       77  KP                 PIC 9(5) COMP VALUE 0.
       01  SKIP                         PIC  9(10)  COMP VALUE 0.
       01  LINE-CNT            PIC 9(10) COMP    VALUE 66.
       01  REC-IN-CT                    PIC  9(10)  COMP VALUE 0.
       01  REC-FOUND-CT                 PIC 9(10) COMP VALUE 0.
       01  CT-LINE                               USAGE  DISPLAY-1.
           03 FILLER       PIC XX  VALUE '**'.
           03 CT-CT        PIC ZZZZZZ9.
           03 FILLER        PIC XX   VALUE '**'.
           03 FILLER          PIC X(121) VALUE SPACES.
       01  F-LINE  USAGE DISPLAY-1.
           03 FILLER        PIC XX  VALUE '**'.
           03 F-CT        PIC ZZZZZZ9.
           03 FILLER         PIC XX   VALUE '**'.
           03 FILLER          PIC X(08) VALUE '........'.
           03 FILLER          PIC X(10) VALUE '2.........'.
           03 FILLER          PIC X(10) VALUE '3.........'.
           03 FILLER          PIC X(10) VALUE '4.........'.
           03 FILLER          PIC X(10) VALUE '5.........'.
           03 FILLER          PIC X(10) VALUE '6.........'.
           03 FILLER          PIC X(10) VALUE '7.........'.
           03 FILLER          PIC X(10) VALUE '8.........'.
           03 FILLER          PIC X(10) VALUE '9.........'.
           03 FILLER          PIC X(10) VALUE '0.........'.
           03 FILLER          PIC X(10) VALUE '1.........'.
           03 FILLER          PIC X(10) VALUE '2.........'.
           03 FILLER          PIC X(03) VALUE '3..'.
       01  FIVE-CT PIC 9(10) COMP VALUE 6.
       01  M-LINE                                USAGE  DISPLAY-1.
           03  FILLER         PIC X(20)
               VALUE '** END SCAN **      '.
           03  M-NAME         PIC X(37).
           03  M-CT           PIC Z(10)9.
           03  FILLER         PIC X(19)
               VALUE  ' RECORD MATCHING = '.
           03  FN-CT          PIC Z(10)9.
       PROCEDURE DIVISION.
       OPEN-FILES SECTION.
       PARM-READ.
           MOVE SPACES TO M-NAME.
           OPEN INPUT PARMF.
       PARM-LECT.
           READ PARMF AT END GO TO PARM-FIN.
           IF P-TYPE = 'IN'
              MOVE PL-LEN TO P-LEN.
           IF P-TYPE = 'MN'
              MOVE PN-TEXT TO M-NAME.
           IF P-TYPE = 'MX'
              MOVE PX-MAX TO P-MAX.
           GO TO PARM-LECT.
       PARM-FIN.
           CLOSE PARMF.
           COMPUTE N-CHUNK = (P-LEN + 99) / 100.
       FIRST-READ.
           OPEN INPUT  TAPEIN.  OPEN OUTPUT  PRT.
       LR. MOVE SPACES TO RECIN.
           READ  TAPEIN  INTO  RECIN  AT END  GO TO END-OUT.
           MOVE SPACES TO REC-AREA.
           MOVE WS-IN-LEN TO CP-LEN.
           IF CP-LEN > P-LEN
              MOVE P-LEN TO CP-LEN.
           IF CP-LEN > 0
              MOVE RECIN (1:CP-LEN) TO REC-AREA (1:CP-LEN).
           ADD 1 TO REC-IN-CT.
       TEST-FIELDS.
           IF P-MAX > 0 AND REC-IN-CT NOT < P-MAX GO TO LR.
       FOUND-REC.
           ADD  1  TO  REC-FOUND-CT.
           MOVE ZERO  TO  LINE-CNT.
           ADD 1 TO FIVE-CT.
           IF FIVE-CT > 9 MOVE REC-IN-CT TO F-CT
             WRITE PRT-LINE FROM F-LINE AFTER 1 MOVE 1 TO FIVE-CT
            ELSE   MOVE REC-IN-CT TO CT-CT
             WRITE PRT-LINE FROM CT-LINE AFTER 1.
           ADD 1 TO LINE-CNT.
           MOVE  1  TO  SKIP.
           MOVE 1 TO K.
       PRINT-CHUNK.
           IF K > N-CHUNK GO TO PRINT-END.
           COMPUTE KP = (K - 1) * 100 + 1.
           MOVE REC-AREA (KP:100) TO WS-CHUNK.
           WRITE  PRT-LINE  FROM  WS-CHUNK  AFTER ADVANCING SKIP.
           ADD 1 TO LINE-CNT.
           MOVE 1 TO SKIP.
           ADD 1 TO K.
           GO TO PRINT-CHUNK.
       PRINT-END.
           MOVE SPACES  TO REC-AREA.
           MOVE  1  TO  SKIP.     GO  TO  LR.
       END-OUT.
           MOVE  REC-IN-CT  TO  M-CT.
           MOVE REC-FOUND-CT  TO  FN-CT.
           WRITE PRT-LINE  FROM  M-LINE AFTER ADVANCING 10 LINES.
           CLOSE  TAPEIN  PRT.
           STOP RUN.
