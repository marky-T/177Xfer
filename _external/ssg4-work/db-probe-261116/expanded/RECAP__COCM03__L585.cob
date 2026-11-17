    
       IDENTIFICATION DIVISION. 
       PROGRAM-ID. 'RECAP'. 
       AUTHOR. BOURDEAUD HUY 13/10/82.  
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNIVAC-1106.
       OBJECT-COMPUTER. UNIVAC-1108.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT  TAPEIN  ASSIGN  TO   
                   DISC  INA. 
           SELECT TAPEOUT ASSIGN TO 
                   DISC  OUTA.
       DATA DIVISION.   
       FILE SECTION.
       FD  TAPEIN   
           LABEL  RECORD  STANDARD  
           BLOCK CONTAINS 10  RECORDS
           DATA RECORD IS   
           REC11 
           REC12 
           REC13 
           REC14 
           REC15 
           REC16 
           REC17 
           REC18 
           REC19 
           REC110 
           REC111 
           REC112 
           REC113 
           REC114 
           REC115 
           REC116 
           REC117 
           RECTOT1   
           RECTOT2   
           INDICATIF1
           INDICATIF2
           INDICATIF3
           INDICATIF4
           INDICATIF5
           INDICATIF6
           INDICATIF7
           INDICATIF8
           INDICATIF9
           INDICATIF10
           INDICATIF11
           RECIN.   
       01     REC11. 
                     06 FILLER PIC  X(55).  
           06  ZONE1  PIC  X(1).   
       01     REC12. 
                     06 FILLER PIC  X(82).  
           06  ZONE2  PIC  X(1).   
       01     REC13. 
           06  ZONE3  PIC  X(2).   
       01     REC14. 
                     06 FILLER PIC  X(2).  
           06  ZONE4  PIC  X(5).   
       01     REC15. 
                     06 FILLER PIC  X(64).  
           06  ZONE5  PIC  X(8).   
       01     REC16. 
                     06 FILLER PIC  X(56).  
           06  ZONE6  PIC  X(8).   
       01     REC17. 
                     06 FILLER PIC  X(32).  
           06  ZONE7  PIC  X(3).   
       01     REC18. 
                     06 FILLER PIC  X(25).  
           06  ZONE8  PIC  X(7).   
       01     REC19. 
                     06 FILLER PIC  X(35).  
           06  ZONE9  PIC  X(7).   
       01     REC110. 
                     06 FILLER PIC  X(44).  
           06  ZONE10  PIC  X(3).   
       01     REC111. 
                     06 FILLER PIC  X(83).  
           06  ZONE11  PIC  X(8).   
       01     REC112. 
                     06 FILLER PIC  X(17).  
           06  ZONE12  PIC  X(8).   
       01     REC113. 
                     06 FILLER PIC  X(120).  
           06  ZONE13  PIC  X(10).   
       01     REC114. 
                     06 FILLER PIC  X(130).  
           06  ZONE14  PIC  X(6).   
       01     REC115. 
                     06 FILLER PIC  X(136).  
           06  ZONE15  PIC  X(6).   
       01     REC116. 
                     06 FILLER PIC  X(72).  
           06  ZONE16  PIC  X(1).   
       01     REC117. 
                     06 FILLER PIC  X(143).  
           06  ZONE17  PIC  X(1).   
       01  RECIN   PIC  X(200).   
       01  RECTOT1.  
                     06 FILLER PIC  X(17).  
               06 TOTAL1 PIC S9(8).  
       01  RECTOT2.  
                     06 FILLER PIC  X(120).  
               06 TOTAL2 PIC S9(10).  
       01  INDICATIF1.   
                     06 FILLER PIC  X(55).  
               06 LIND1  PIC  X(1).  
       01  INDICATIF2.   
                     06 FILLER PIC  X(82).  
               06 LIND2  PIC  X(1).  
       01  INDICATIF3.   
               06 LIND3  PIC  X(2).  
       01  INDICATIF4.   
                     06 FILLER PIC  X(2).  
               06 LIND4  PIC  X(5).  
       01  INDICATIF5.   
                     06 FILLER PIC  X(64).  
               06 LIND5  PIC  X(8).  
       01  INDICATIF6.   
                     06 FILLER PIC  X(56).  
               06 LIND6  PIC  X(8).  
       01  INDICATIF7.   
                     06 FILLER PIC  X(32).  
               06 LIND7  PIC  X(3).  
       01  INDICATIF8.   
                     06 FILLER PIC  X(25).  
               06 LIND8  PIC  X(7).  
       01  INDICATIF9.   
                     06 FILLER PIC  X(35).  
               06 LIND9  PIC  X(7).  
       01  INDICATIF10.   
                     06 FILLER PIC  X(44).  
               06 LIND10  PIC  X(3).  
       01  INDICATIF11.   
                     06 FILLER PIC  X(83).  
               06 LIND11  PIC  X(8).  
       FD  TAPEOUT  
           LABEL RECORD STANDARD
           BLOCK  CONTAINS 10  RECORDS  
           DATA RECORD IS   
           REC21 
           REC22 
           REC23 
           REC24 
           REC25 
           REC26 
           REC27 
           REC28 
           REC29 
           REC210 
           REC211 
           REC212 
           REC213 
           REC214 
           REC215 
           REC216 
           REC217 
           RECTOT-O1 
           RECTOT-O2 
           RECOUT.  
       01  RECOUT   PIC   X(200).
       01  REC21.
           06 ZONO1. 
              08  ANNEE-1      PIC X.
              08  FILLER          PIC X(0). 
       01  REC22.
                     06 FILLER PIC  X(1).  
           06 ZONO2. 
              08  ANNEE-2      PIC X.
              08  FILLER          PIC X(0). 
       01  REC23.
                     06 FILLER PIC  X(2).  
           06 ZONO3. 
              08  ANNEE-3      PIC X.
              08  FILLER          PIC X(1). 
       01  REC24.
                     06 FILLER PIC  X(4).  
           06 ZONO4. 
              08  ANNEE-4      PIC X.
              08  FILLER          PIC X(4). 
       01  REC25.
                     06 FILLER PIC  X(9).  
           06 ZONO5. 
              08  ANNEE-5      PIC X.
              08  FILLER          PIC X(7). 
       01  REC26.
                     06 FILLER PIC  X(17).  
           06 ZONO6. 
              08  ANNEE-6      PIC X.
              08  FILLER          PIC X(7). 
       01  REC27.
                     06 FILLER PIC  X(25).  
           06 ZONO7. 
              08  ANNEE-7      PIC X.
              08  FILLER          PIC X(2). 
       01  REC28.
                     06 FILLER PIC  X(28).  
           06 ZONO8. 
              08  ANNEE-8      PIC X.
              08  FILLER          PIC X(6). 
       01  REC29.
                     06 FILLER PIC  X(35).  
           06 ZONO9. 
              08  ANNEE-9      PIC X.
              08  FILLER          PIC X(6). 
       01  REC210.
                     06 FILLER PIC  X(42).  
           06 ZONO10. 
              08  ANNEE-10      PIC X.
              08  FILLER          PIC X(2). 
       01  REC211.
                     06 FILLER PIC  X(45).  
           06 ZONO11. 
              08  ANNEE-11      PIC X.
              08  FILLER          PIC X(7). 
       01  REC212.
                     06 FILLER PIC  X(53).  
           06 ZONO12. 
              08  ANNEE-12      PIC X.
              08  FILLER          PIC X(7). 
       01  REC213.
                     06 FILLER PIC  X(61).  
           06 ZONO13. 
              08  ANNEE-13      PIC X.
              08  FILLER          PIC X(9). 
       01  REC214.
                     06 FILLER PIC  X(71).  
           06 ZONO14. 
              08  ANNEE-14      PIC X.
              08  FILLER          PIC X(5). 
       01  REC215.
                     06 FILLER PIC  X(77).  
           06 ZONO15. 
              08  ANNEE-15      PIC X.
              08  FILLER          PIC X(5). 
       01  REC216.
                     06 FILLER PIC  X(83).  
           06 ZONO16. 
              08  ANNEE-16      PIC X.
              08  FILLER          PIC X(0). 
       01  REC217.
                     06 FILLER PIC  X(84).  
           06 ZONO17. 
              08  ANNEE-17      PIC X.
              08  FILLER          PIC X(0). 
       01  RECTOT-O1.
                     06 FILLER PIC  X(53).  
               06 TOTAL-O1 PIC S9(8).   
       01  RECTOT-O2.
                     06 FILLER PIC  X(61).  
               06 TOTAL-O2 PIC S9(10).   
       WORKING-STORAGE SECTION. 
       77  TEST-SIECLE  PIC X.  
       77  TESTFIN  PIC   9 VALUE 0.
       77  NB-LUS   PIC   9(6)   VALUE 0.   
       77  NB-ECR   PIC   9(6)   VALUE 0.   
       77  ERREUR   PIC   9 VALUE 0.
       77  PREMIER     PIC   9(10) COMP VALUE  0.   
       01  TOTAL.   
           03  MONT1   PIC  S9(18)  VALUE  ZEROES.   
           03 FILLER PIC X. 
           03  MONT2   PIC  S9(18)  VALUE  ZEROES.   
           03 FILLER PIC X. 
       01  W-INDIC. 
           02  IND1    PIC  X(1).
           02  IND2    PIC  X(1).
           02  IND3    PIC  X(2).
           02  IND4    PIC  X(5).
           02  IND5    PIC  X(8).
           02  IND6    PIC  X(8).
           02  IND7    PIC  X(3).
           02  IND8    PIC  X(7).
           02  IND9    PIC  X(7).
           02  IND10    PIC  X(3).
           02  IND11    PIC  X(8).
       01  W-INDIC-OLD. 
           02  IND1     PIC  X(1).   
           02  IND2     PIC  X(1).   
           02  IND3     PIC  X(2).   
           02  IND4     PIC  X(5).   
           02  IND5     PIC  X(8).   
           02  IND6     PIC  X(8).   
           02  IND7     PIC  X(3).   
           02  IND8     PIC  X(7).   
           02  IND9     PIC  X(7).   
           02  IND10     PIC  X(3).   
           02  IND11     PIC  X(8).   
       01  TOTAL-OUT1 PIC S9(8) VALUE ZEROES.   
       01  TOTAL-OUT2 PIC S9(10) VALUE ZEROES.   
       01  TOTAL-LU1 PIC S9(18) VALUE ZEROES.
       01  TOTAL-LU2 PIC S9(18) VALUE ZEROES.
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
       01  RDMS-QUALIFIER                        PIC X(12). 
       01  RDMS-IND                              PIC 9(2).  
       01  RDMS-STATUS                           PIC 9999  VALUE 0. 
       01  RDMS-SAV-STATUS                       PIC 9999  VALUE 0. 
       01  RDMS-ROLLB                            PIC 9     VALUE 0. 
       01  RDMS-COLUMN                           PIC S1(36).
       01  RDMS-SAV-COLUMN                       PIC S1(36).
       01  RDMS-FLAG                             PIC 9     VALUE 0. 
       01  RDMS-FLAG-THREAD                      PIC 9     VALUE 0. 
       01  RDMS-RESULT. 
             05 RDMS-ERROR-LINE OCCURS 4         PIC X(80). 
       01  RDMS-COM.
             05 RLIN            OCCURS 36        PIC X(40). 
       PROCEDURE DIVISION.  
       DEBUT.   
           OPEN INPUT TAPEIN.   
           OPEN  OUTPUT  TAPEOUT.   
           CALL 'RSA$INIT'. 
           ENTER MASM 'ACOB$RDMR' USING 
             'BEGIN THREAD FOR APPLICATION UDSSRC READ;',   
             RDMS-STATUS, RDMS-COLUMN.  
           IF RDMS-STATUS NOT = 0 GO TO RDMS-ERROR-PAR. 
           MOVE 1 TO RDMS-FLAG-THREAD.  
           ENTER MASM 'ACOB$RDMR' USING 
             'USE DEFAULT QUALIFIER AFLINC;',   
             RDMS-STATUS, RDMS-COLUMN.  
           IF RDMS-STATUS NOT = 0 GO TO RDMS-ERROR-PAR. 
           ENTER MASM 'ACOB$RDMR' USING 
             'USE DEFAULT VERSION PRODUCTION ;',
             RDMS-STATUS, RDMS-COLUMN.  
           IF RDMS-STATUS NOT = 0 GO TO RDMS-ERROR-PAR. 
           MOVE 0 TO RDMS-FLAG. 
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
           MOVE SPACES TO RECOUT.   
       LECT.
           MOVE W-INDIC TO W-INDIC-OLD. 
           READ  TAPEIN  AT  END MOVE 1 TO TESTFIN  GO TO  RUPTURE. 
           ADD 1 TO NB-LUS. 
           IF TOTAL1 NUMERIC 
           ADD TOTAL1 TO TOTAL-LU1
           ELSE 
           EXAMINE TOTAL1 REPLACING ALL SPACES BY ZERO   
           ADD TOTAL1 TO TOTAL-LU1.   
           IF TOTAL2 NUMERIC 
           ADD TOTAL2 TO TOTAL-LU2
           ELSE 
           EXAMINE TOTAL2 REPLACING ALL SPACES BY ZERO   
           ADD TOTAL2 TO TOTAL-LU2.   
           MOVE  LIND1  TO  IND1  OF  W-INDIC.
           MOVE  LIND2  TO  IND2  OF  W-INDIC.
           MOVE  LIND3  TO  IND3  OF  W-INDIC.
           MOVE  LIND4  TO  IND4  OF  W-INDIC.
           MOVE  LIND5  TO  IND5  OF  W-INDIC.
           MOVE  LIND6  TO  IND6  OF  W-INDIC.
           MOVE  LIND7  TO  IND7  OF  W-INDIC.
           MOVE  LIND8  TO  IND8  OF  W-INDIC.
           MOVE  LIND9  TO  IND9  OF  W-INDIC.
           MOVE  LIND10  TO  IND10  OF  W-INDIC.
           MOVE  LIND11  TO  IND11  OF  W-INDIC.
           IF PREMIER =  0 MOVE 1 TO PREMIER GO TO EGALITE. 
           IF W-INDIC-OLD GREATER THAN W-INDIC GO TO ERR-SEQ.   
           IF W-INDIC NOT EQUAL TO W-INDIC-OLD GO TO RUPTURE.   
           GO TO EGALITE.   
       RUPTURE. 
           MOVE TOTAL-OUT1 TO TOTAL-O1.   
           MOVE ZEROES TO TOTAL-OUT1.
           MOVE TOTAL-OUT2 TO TOTAL-O2.   
           MOVE ZEROES TO TOTAL-OUT2.
           WRITE RECOUT.
           MOVE SPACES TO RECOUT.   
           ADD 1 TO NB-ECR. 
           IF TESTFIN = 1 GO TO FINW.   
           GO TO EGALITE.   
       ERR-SEQ. 
           DISPLAY '**ANCIEN INDIC** ' W-INDIC-OLD  
           DISPLAY '**NOUVEL INDIC** ' W-INDIC. 
           DISPLAY '**ERREUR DE SEQUENCE** '.   
           CLOSE TAPEIN TAPEOUT.
           ENTER MASM 'ACOB$RDMR' USING 
             'END THREAD ;',
             RDMS-STATUS, RDMS-COLUMN.  
           IF RDMS-STATUS NOT = 0 GO TO RDMS-ERROR-PAR. 
           MOVE 0 TO RDMS-FLAG-THREAD.  
           CALL 'ABORT'.
       EGALITE. 
           MOVE ZONE1 TO ZONO1.   
           MOVE ZONE2 TO ZONO2.   
           MOVE ZONE3 TO ZONO3.   
           MOVE ZONE4 TO ZONO4.   
           MOVE ZONE5 TO ZONO5.   
           MOVE ZONE6 TO ZONO6.   
           MOVE ZONE7 TO ZONO7.   
           MOVE ZONE8 TO ZONO8.   
           MOVE ZONE9 TO ZONO9.   
           MOVE ZONE10 TO ZONO10.   
           MOVE ZONE11 TO ZONO11.   
           MOVE ZONE12 TO ZONO12.   
           MOVE ZONE13 TO ZONO13.   
           MOVE ZONE14 TO ZONO14.   
           MOVE ZONE15 TO ZONO15.   
           MOVE ZONE16 TO ZONO16.   
           MOVE ZONE17 TO ZONO17.   
           ADD TOTAL1 TO TOTAL-OUT1 MONT1. 
           ADD TOTAL2 TO TOTAL-OUT2 MONT2. 
           GO TO LECT.  
       FINW.
           EXAMINE NB-LUS REPLACING LEADING ZEROES BY SPACES.   
           EXAMINE NB-ECR REPLACING LEADING ZEROES BY SPACES.   
           DISPLAY  '*RECAP  FIN*'  UPON  PRINTER.  
           DISPLAY  '*NB-ENREG-LUS ='  NB-LUS  UPON  PRINTER.   
           EXAMINE TOTAL-LU1 REPLACING LEADING ZEROES BY SPACES. 
           MOVE 17     TO MT-ENE-CHI OF EUW002. 
           MOVE 25     TO LG-MAX-MON-SRT OF EUW002. 
           MOVE TOTAL-LU1 TO MT-ENE OF EUW002.   
           MOVE EUW002       TO VL-CHP-TSF  OF WS-CMT-PGM.  
           CALL 'EUU003'     USING WS-CMT-PGM.  
           MOVE VL-CHP-TSF   OF WS-CMT-PGM TO EUW002.   
           DISPLAY MT-SRT    OF EUW002 UPON PRINTER.
           EXAMINE TOTAL-LU2 REPLACING LEADING ZEROES BY SPACES. 
           MOVE 17     TO MT-ENE-CHI OF EUW002. 
           MOVE 25     TO LG-MAX-MON-SRT OF EUW002. 
           MOVE TOTAL-LU2 TO MT-ENE OF EUW002.   
           MOVE EUW002       TO VL-CHP-TSF  OF WS-CMT-PGM.  
           CALL 'EUU003'     USING WS-CMT-PGM.  
           MOVE VL-CHP-TSF   OF WS-CMT-PGM TO EUW002.   
           DISPLAY MT-SRT    OF EUW002 UPON PRINTER.
           DISPLAY  '*NB-ENREG-ECR ='  NB-ECR  UPON  PRINTER.   
           EXAMINE MONT1 REPLACING LEADING ZEROES BY SPACES. 
           MOVE 17     TO MT-ENE-CHI OF EUW002. 
           MOVE 25     TO LG-MAX-MON-SRT OF EUW002. 
           MOVE MONT1 TO MT-ENE OF EUW002.   
           MOVE EUW002       TO VL-CHP-TSF  OF WS-CMT-PGM.  
           CALL 'EUU003'     USING WS-CMT-PGM.  
           MOVE VL-CHP-TSF   OF WS-CMT-PGM TO EUW002.   
           DISPLAY MT-SRT    OF EUW002 UPON PRINTER.
           EXAMINE MONT2 REPLACING LEADING ZEROES BY SPACES. 
           MOVE 17     TO MT-ENE-CHI OF EUW002. 
           MOVE 25     TO LG-MAX-MON-SRT OF EUW002. 
           MOVE MONT2 TO MT-ENE OF EUW002.   
           MOVE EUW002       TO VL-CHP-TSF  OF WS-CMT-PGM.  
           CALL 'EUU003'     USING WS-CMT-PGM.  
           MOVE VL-CHP-TSF   OF WS-CMT-PGM TO EUW002.   
           DISPLAY MT-SRT    OF EUW002 UPON PRINTER.
           CLOSE  TAPEIN.   
           CLOSE  TAPEOUT.  
           ENTER MASM 'ACOB$RDMR' USING 
             'END THREAD ;',
             RDMS-STATUS, RDMS-COLUMN.  
           IF RDMS-STATUS NOT = 0 GO TO RDMS-ERROR-PAR. 
           MOVE 0 TO RDMS-FLAG-THREAD.  
           STOP RUN.
       RAPPEL.  
           DISPLAY 'RELISEZ ATTENTIVEMENT MODE D EMPLOI DE RECAP'   
           UPON PRINTER.
       RDMS-ERROR-PAR.  
           DISPLAY '*** ERROR RDMS ***' UPON PRINTER.   
           DISPLAY 'COLUMN = ' RDMS-COLUMN UPON PRINTER.
           DISPLAY 'STATUS = ' RDMS-STATUS UPON PRINTER.
           PERFORM TRAIT-RDMS.  
           GO TO RDMS-ERROR-EX. 
       TRAIT-RDMS.  
           MOVE ZEROS TO RDMS-FLAG. 
           PERFORM VISU-RDMS-COM VARYING RDMS-IND FROM 1 BY 1   
               UNTIL RDMS-IND > 36. 
           MOVE ZEROS TO RDMS-FLAG. 
           PERFORM TRAIT-RDMS-ERROR 
               UNTIL RDMS-FLAG NOT = ZEROS. 
       TRAIT-RDMS-ERROR.
           ENTER MASM 'ACOB$RDMR' USING 
             'GETERROR INTO $P1, $P2, $P3, $P4 ;',  
             RDMS-STATUS, RDMS-COLUMN,  
             RDMS-ERROR-LINE (1), RDMS-ERROR-LINE (2),  
             RDMS-ERROR-LINE (3), RDMS-ERROR-LINE (4).  
           PERFORM VISU-RDMS-ERROR  
             VARYING RDMS-IND FROM 1 BY 1   
             UNTIL RDMS-IND > 4.
       VISU-RDMS-ERROR. 
           IF RDMS-ERROR-LINE (RDMS-IND) NOT = SPACE
                DISPLAY RDMS-ERROR-LINE (RDMS-IND) UPON PRINTER 
           ELSE MOVE 1 TO RDMS-FLAG.
       VISU-RDMS-COM.   
           IF RLIN (RDMS-IND) NOT = SPACES  
                DISPLAY RLIN (RDMS-IND) UPON PRINTER.   
       RDMS-ERROR-EX.   
