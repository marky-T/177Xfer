      ***------------------------------------------------------------***
      ***                    -- CONDIS2 --  
      ***              UTILITAIRE - CFH-COPY CONDITIONNEL            ***
      ***------------------------------------------------------------***
      * Type     : UTILITAIRE TRANSFERT DE ZONES CONDITIONNEL          *
      * Analyste : SABLON                          (INITIALES)         *
      * Auteur   : SABLON                                              *
      * Release  : 01                              (99)                *
      * VersIon  : 001                             (999)               *
      *----------------------------------------------------------------*
      * ModIfIcatIons :                                                *
      * QuI ?  Quand ?     QuoI ?                             Projet/Ph*
      * _____  __/__/____  _________________________________  ______/__*
      * _____  __/__/____  _________________________________  ______/__*
      * _____  __/__/____  _________________________________  ______/__*
      * _____  __/__/____  _________________________________  ______/__*
      ***------------------------------------------------------------***
       IDENTIFICATION DIVISION. 
      **************************
       PROGRAM-ID.  CONDIS2.
      *-----------* 
      / 
       ENVIRONMENT DIVISION.
      **********************
       CONFIGURATION SECTION.   
      *======================*  
       SOURCE-COMPUTER.  UNIVAC-1110.   
      *----------------*
       OBJECT-COMPUTER.  UNIVAC-1110.   
      *----------------*
       SPECIAL-NAMES.   
           PRINTER IS PRINER.   
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FILEIN ASSIGN TO DISC FILEIN. 
           SELECT FILEOUT ASSIGN TO DISC FILEOUT.   
       DATA DIVISION.   
      ****************  
       FILE SECTION.
      *------------*
       FD  FILEIN   
           BLOCK CONTAINS 10 RECORDS
               RECORD CONTAINS 408 CHARACTERS
               LABEL RECORD STANDARD
               DATA RECORD IS FSINPUT.  
       01  FSINPUT. 
            02   FILLER    PIC X(408).   
       FD  FILEOUT  
           BLOCK CONTAINS 10 RECORDS   
               RECORD CONTAINS 400 CHARACTERS   
               LABEL RECORD STANDARD
               DATA RECORD IS FSOUTPUT. 
       01  FSOUTPUT.
           02   FILLER     PIC X(400).  
       WORKING-STORAGE SECTION. 
      ************************* 
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
       01  NB-REC-CASE-0            PIC 9(6).   
       01  ENR-INPUT.   
              03  FILLER                PIC X(408).  
       01  ENRIN-MOVE-0-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-0-1  PIC X(28). 
           03 FILLER                   PIC X(380).
       01  ENRIN-MOVE-0-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(28).
           03 MOVEIN-0-2    PIC X(04).   
           03 FILLER                   PIC X(376).
       01  ENRIN-MOVE-0-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(32).
           03 MOVEIN-0-3  PIC X(225). 
           03 FILLER                   PIC X(151).
       01  ENRIN-MOVE-0-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(256).
           03 MOVEIN-0-4    PIC X(04).   
           03 FILLER                   PIC X(148).
       01  ENRIN-MOVE-0-5   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(260).
           03 MOVEIN-0-5  PIC X(34). 
           03 FILLER                   PIC X(114).
       01  ENRIN-MOVE-0-6   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(294).
           03 MOVEIN-0-6    PIC X(04).   
           03 FILLER                   PIC X(110).
       01  ENRIN-MOVE-0-7   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(298).
           03 MOVEIN-0-7  PIC X(11). 
           03 FILLER                   PIC X(99).
       01  ENRIN-MOVE-0-8   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(309).
           03 MOVEIN-0-8    PIC X(04).   
           03 FILLER                   PIC X(95).
       01  ENRIN-MOVE-0-9   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(313).
           03 MOVEIN-0-9  PIC X(95). 
       01  ENR-OUTPUT.  
              03  FILLER                PIC X(400). 
       01  ENROUT-MOVE-0-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-0-1  PIC X(28).
           03 FILLER                   PIC X(372).
       01  ENROUT-MOVE-0-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(28).
           03 MOVEOUT-0-2       PIC X(02).   
           03 FILLER                   PIC X(370).
       01  ENROUT-MOVE-0-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-0-3  PIC X(225).
           03 FILLER                   PIC X(145).
       01  ENROUT-MOVE-0-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(254).
           03 MOVEOUT-0-4       PIC X(02).   
           03 FILLER                   PIC X(144).
       01  ENROUT-MOVE-0-5   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(256).
           03 MOVEOUT-0-5  PIC X(34).
           03 FILLER                   PIC X(110).
       01  ENROUT-MOVE-0-6   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(290).
           03 MOVEOUT-0-6       PIC X(02).   
           03 FILLER                   PIC X(108).
       01  ENROUT-MOVE-0-7   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(292).
           03 MOVEOUT-0-7  PIC X(11).
           03 FILLER                   PIC X(97).
       01  ENROUT-MOVE-0-8   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(303).
           03 MOVEOUT-0-8       PIC X(02).   
           03 FILLER                   PIC X(95).
       01  ENROUT-MOVE-0-9   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(305).
           03 MOVEOUT-0-9  PIC X(95).
       PROCEDURE DIVISION.  
      ********************  
       DEBUT.   
           OPEN INPUT  FILEIN   
                OUTPUT FILEOUT. 
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
           MOVE 0 TO NB-REC-OTHER.  
       TRT. 
           READ FILEIN INTO ENR-INPUT AT END GO TO FIN-TRT. 
           MOVE SPACES TO ENR-OUTPUT.   
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
              MOVE MOVEIN-0-1 TO MOVEOUT-0-1  
              MOVE MOVEIN-0-2 TO WS-A4   
              PERFORM TRANSFO-DATE-4-2 THRU TRANSFO-DATE-4-2-EXIT   
              MOVE WS-A2 TO MOVEOUT-0-2  
              MOVE MOVEIN-0-3 TO MOVEOUT-0-3  
              MOVE MOVEIN-0-4 TO WS-A4   
              PERFORM TRANSFO-DATE-4-2 THRU TRANSFO-DATE-4-2-EXIT   
              MOVE WS-A2 TO MOVEOUT-0-4  
              MOVE MOVEIN-0-5 TO MOVEOUT-0-5  
              MOVE MOVEIN-0-6 TO WS-A4   
              PERFORM TRANSFO-DATE-4-2 THRU TRANSFO-DATE-4-2-EXIT   
              MOVE WS-A2 TO MOVEOUT-0-6  
              MOVE MOVEIN-0-7 TO MOVEOUT-0-7  
              MOVE MOVEIN-0-8 TO WS-A4   
              PERFORM TRANSFO-DATE-4-2 THRU TRANSFO-DATE-4-2-EXIT   
              MOVE WS-A2 TO MOVEOUT-0-8  
              MOVE MOVEIN-0-9 TO MOVEOUT-0-9  
              ADD 1 TO NB-REC-CASE-0
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-NON-PREVU.  
      *    pas d'ecriture sur le fichier de sortie .....
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
              DISPLAY '*   certains records ne       *' UPon printer
              DISPLAY '*   respectent aucun case     *' UPON PRInter
              DISPLAY '*   et ne figurent donc pas   *' UPON PRInter
              DISPLAY '*   sur le fichier output     *' UPON PRInter
              DISPLAY '*******************************' UPON PRINTER.   
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
           CLOSE FILEIN FILEOUT.
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
           WRITE FSOUTPUT FROM ENR-OUTPUT.  
       WRITE-REC-OUTPUT-EXIT.   
      ************************  
           EXIT.
