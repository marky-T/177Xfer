       IDENTIFICATION DIVISION. 
       PROGRAM-ID. 'TABAN'. 
       AUTHOR. BOURDEAUD HUY PIERRE.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER.     UNIVAC-1100-60EIS.  
       OBJECT-COMPUTER.     UNIVAC-1100-60EIS.  
       SPECIAL-NAMES.   
           DECIMAL-POINT IS COMMA.  
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT   IMP   ASSIGN  TO  PRINTER.  
           SELECT  TAPE1  ASSIGN  TO
               DISC B008S604CP.  
       DATA DIVISION.   
       FILE SECTION.
       FD  IMP   LABEL RECORD  OMITTED  
                    LINAGE IS 63
                    LINES AT TOP 6  
                    LINES AT BOTTOM 3   
                 DATA  RECORD  IS  LIGNE.   
       01  LIGNE   PIC  X(132) DISP-1.  
       FD  TAPE1  LABEL RECORD  STANDARD
                  BLOCK  CONTAINS  10  RECORDS   
             DATA RECORD IS RECE1  REC1.
       01  RECE1  PIC  X(160).
       01  REC1. 
               06 FILLER  PIC  X(32).   
              06 LMONT1  PIC  S9(12).  
              06 RMONT1 REDEFINES LMONT1. 
                   07 TMONT1 PIC 9 OCCURS 12 TIMES INDEXED 
                       BY KMONT1.
       01  REC2. 
               06 FILLER  PIC  X(44).   
              06 LMONT2  PIC  S9(12).  
              06 RMONT2 REDEFINES LMONT2. 
                   07 TMONT2 PIC 9 OCCURS 12 TIMES INDEXED 
                       BY KMONT2.
       01  REC3. 
               06 FILLER  PIC  X(56).   
              06 LMONT3  PIC  S9(12).  
              06 RMONT3 REDEFINES LMONT3. 
                   07 TMONT3 PIC 9 OCCURS 12 TIMES INDEXED 
                       BY KMONT3.
       01  REC4. 
               06 FILLER  PIC  X(68).   
              06 LMONT4  PIC  S9(12).  
              06 RMONT4 REDEFINES LMONT4. 
                   07 TMONT4 PIC 9 OCCURS 12 TIMES INDEXED 
                       BY KMONT4.
       01  REC5. 
               06 FILLER  PIC  X(104).   
              06 LMONT5  PIC  S9(12).  
              06 RMONT5 REDEFINES LMONT5. 
                   07 TMONT5 PIC 9 OCCURS 12 TIMES INDEXED 
                       BY KMONT5.
       01  CCART  PIC 9.
       WORKING-STORAGE SECTION. 
       77  NB-LUS   PIC   9(10) COMP VALUE  0.  
       77  FIRS     PIC   9(10) COMP VALUE  0.  
       01  ZONE-WORK.   
           02 LMONT1 PIC SH9(18).
           02 FILLER PIC X. 
           02 LMONT2 PIC SH9(18).
           02 FILLER PIC X. 
           02 LMONT3 PIC SH9(18).
           02 FILLER PIC X. 
           02 LMONT4 PIC SH9(18).
           02 FILLER PIC X. 
           02 LMONT5 PIC SH9(18).
           02 FILLER PIC X. 
       01  SUB-TOTAL.   
           03  MONT1    PIC  SH9(18)  VALUE 0.   
           03 FILLER PIC X. 
           03  MONT2    PIC  SH9(18)  VALUE 0.   
           03 FILLER PIC X. 
           03  MONT3    PIC  SH9(18)  VALUE 0.   
           03 FILLER PIC X. 
           03  MONT4    PIC  SH9(18)  VALUE 0.   
           03 FILLER PIC X. 
           03  MONT5    PIC  SH9(18)  VALUE 0.   
           03 FILLER PIC X. 
       01  TOTAL.   
           03  MONT1   PIC  SH9(18)  VALUE  0.   
           03 FILLER PIC X. 
           03  MONT2   PIC  SH9(18)  VALUE  0.   
           03 FILLER PIC X. 
           03  MONT3   PIC  SH9(18)  VALUE  0.   
           03 FILLER PIC X. 
           03  MONT4   PIC  SH9(18)  VALUE  0.   
           03 FILLER PIC X. 
           03  MONT5   PIC  SH9(18)  VALUE  0.   
           03 FILLER PIC X. 
       01  W-ZERO.  
           03  MONT1  PIC  SH9(18)  VALUE 0. 
           03 FILLER PIC X. 
           03  MONT2  PIC  SH9(18)  VALUE 0. 
           03 FILLER PIC X. 
           03  MONT3  PIC  SH9(18)  VALUE 0. 
           03 FILLER PIC X. 
           03  MONT4  PIC  SH9(18)  VALUE 0. 
           03 FILLER PIC X. 
           03  MONT5  PIC  SH9(18)  VALUE 0. 
           03 FILLER PIC X. 
       01  TIT-TOTAL.   
           02  FILLER  PIC  X(16)  VALUE  '***TABAN FIN ***'.   
           02  FILLER  PIC  X(15)  VALUE  ' NB.ENREG.LUS= '.
           02  P-LUS   PIC  Z(8)9.  
       01  LIGNES-SUB.  
           02  LIG-SUB1. 
             03 FA1   PIC X(12)  VALUE '*SOUS-TOTAL*'.   
               03 FILLER  PIC  X(3)  VALUE  SPACES. 
               03 MONT1  PIC  X(25). 
               03 FILLER  PIC  X(3)  VALUE  SPACES. 
               03 MONT2  PIC  X(25). 
               03 FILLER  PIC  X(3)  VALUE  SPACES. 
               03 MONT3  PIC  X(25). 
               03 FILLER  PIC  X(3)  VALUE  SPACES. 
               03 MONT4  PIC  X(25). 
           02  LIG-SUB5. 
             03 FA5   PIC X(12)  VALUE '*SOUS-TOTAL*'.   
               03 FILLER  PIC  X(3)  VALUE  SPACES. 
               03 MONT5  PIC  X(25). 
               03 FILLER  PIC  X(3)  VALUE  SPACES. 
               03 MONT6  PIC  X(25). 
               03 FILLER  PIC  X(3)  VALUE  SPACES. 
               03 MONT7  PIC  X(25). 
               03 FILLER  PIC  X(3)  VALUE  SPACES. 
               03 MONT8  PIC  X(25). 
       01  ADETAIL. 
           03 DMONT1  PIC SH9(18)  VALUE 0.  
           03 FILLER PIC X. 
           03 DMONT2  PIC SH9(18)  VALUE 0.  
           03 FILLER PIC X. 
           03 DMONT3  PIC SH9(18)  VALUE 0.  
           03 FILLER PIC X. 
           03 DMONT4  PIC SH9(18)  VALUE 0.  
           03 FILLER PIC X. 
           03 DMONT5  PIC SH9(18)  VALUE 0.  
           03 FILLER PIC X. 
       01  CDTOAF.  
           03  CDTOAF-PRM-ENE.  
               05  CDTOAF-DT-ENE.   
                   07  CDTOAF-AA-ENE.   
                       09  CDTOAF-A1-ENE       PIC X(01).   
                       09  CDTOAF-A2-ENE       PIC X(01).   
                   07  CDTOAF-MM-ENE           PIC X(02).   
                   07  CDTOAF-JJ-ENE           PIC X(02).   
           03  CDTOAF-PRM-SRT.  
               05  CDTOAF-DT-SRT-9             PIC 9(08).   
               05  CDTOAF-DT-SRT REDEFINES CDTOAF-DT-SRT-9. 
                   07  CDTOAF-SSAA-SRT         PIC X(04).   
                   07  CDTOAF-SSAA-SRT-RDF REDEFINES CDTOAF-SSAA-SRT.   
                      09  CDTOAF-SS-SRT        PIC X(02).   
                      09  CDTOAF-AA-SRT.
                          11  CDTOAF-A1-SRT    PIC X(01).   
                          11  CDTOAF-A2-SRT    PIC X(01).   
                   07  CDTOAF-MM-SRT           PIC X(02).   
                   07  CDTOAF-JJ-SRT           PIC X(02).   
               05  CDTOAF-DTE-SRT REDEFINES CDTOAF-DT-SRT-9.
                   07  CDTOAF-SSS-SRT          PIC X(02).   
                   07  CDTOAF-DT6-SRT          PIC X(06).   
               05  CDTOAF-DTE2-SRT REDEFINES CDTOAF-DT-SRT-9.   
                   07  CDTOAF-SS2-SRT          PIC X(02).   
                   07  CDTOAF-AAMM-SRT         PIC X(04).   
                   07  CDTOAF-JJ2-SRT          PIC X(02).   
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
       01  ZONE-25                               PIC Z(18). 
       PROCEDURE DIVISION.  
       DEBUT.   OPEN INPUT TAPE1.   
           MOVE  SPACES  TO  LIGNES-SUB.
           MOVE  '*SOUS-TOTAL*'  TO  FA1.
           MOVE  '*SOUS-TOTAL*'  TO  FA5.
           OPEN OUTPUT  IMP.
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
           MOVE 'TABAN'     TO NM-PGM-APL   OF WS-CMT-PGM.  
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
       LECT.  READ TAPE1  AT END GO TO FINBDE.  
           IF LMONT1  OF REC1 NUMERIC GO TO EXIT1. 
           IF LMONT1 OF REC1 = SPACES 
           MOVE ZEROES TO LMONT1 OF REC1 GO TO EXIT1.  
           PERFORM PMONT1 VARYING KMONT1 FROM 1 BY 1 UNTIL
               KMONT1 = (12 + 1).  
       EXIT1.
           IF LMONT2  OF REC2 NUMERIC GO TO EXIT2. 
           IF LMONT2 OF REC2 = SPACES 
           MOVE ZEROES TO LMONT2 OF REC2 GO TO EXIT2.  
           PERFORM PMONT2 VARYING KMONT2 FROM 1 BY 1 UNTIL
               KMONT2 = (12 + 1).  
       EXIT2.
           IF LMONT3  OF REC3 NUMERIC GO TO EXIT3. 
           IF LMONT3 OF REC3 = SPACES 
           MOVE ZEROES TO LMONT3 OF REC3 GO TO EXIT3.  
           PERFORM PMONT3 VARYING KMONT3 FROM 1 BY 1 UNTIL
               KMONT3 = (12 + 1).  
       EXIT3.
           IF LMONT4  OF REC4 NUMERIC GO TO EXIT4. 
           IF LMONT4 OF REC4 = SPACES 
           MOVE ZEROES TO LMONT4 OF REC4 GO TO EXIT4.  
           PERFORM PMONT4 VARYING KMONT4 FROM 1 BY 1 UNTIL
               KMONT4 = (12 + 1).  
       EXIT4.
           IF LMONT5  OF REC5 NUMERIC GO TO EXIT5. 
           IF LMONT5 OF REC5 = SPACES 
           MOVE ZEROES TO LMONT5 OF REC5 GO TO EXIT5.  
           PERFORM PMONT5 VARYING KMONT5 FROM 1 BY 1 UNTIL
               KMONT5 = (12 + 1).  
       EXIT5.
           MOVE CORRESPONDING REC1 TO ZONE-WORK. 
           MOVE CORRESPONDING REC2 TO ZONE-WORK. 
           MOVE CORRESPONDING REC3 TO ZONE-WORK. 
           MOVE CORRESPONDING REC4 TO ZONE-WORK. 
           MOVE CORRESPONDING REC5 TO ZONE-WORK. 
           ADD  1  TO  NB-LUS.  
           IF  FIRS  =  0  MOVE  1  TO  FIRS  GO TO CONT1.  
       LECT2.   
           ADD   LMONT1 OF ZONE-WORK TO  MONT1  OF  SUB-TOTAL.
           ADD   LMONT2 OF ZONE-WORK TO  MONT2  OF  SUB-TOTAL.
           ADD   LMONT3 OF ZONE-WORK TO  MONT3  OF  SUB-TOTAL.
           ADD   LMONT4 OF ZONE-WORK TO  MONT4  OF  SUB-TOTAL.
           ADD   LMONT5 OF ZONE-WORK TO  MONT5  OF  SUB-TOTAL.
           GO TO LECT.  
       CONT1.   
           MOVE  0  TO MONT1   OF SUB-TOTAL. 
           MOVE  0  TO MONT2   OF SUB-TOTAL. 
           MOVE  0  TO MONT3   OF SUB-TOTAL. 
           MOVE  0  TO MONT4   OF SUB-TOTAL. 
           MOVE  0  TO MONT5   OF SUB-TOTAL. 
           GO TO LECT2. 
       FINBDE.  
           ADD  CORRESPONDING  SUB-TOTAL  TO  TOTAL.
           PERFORM  IMP-TOTAL.  
           MOVE  NB-LUS  TO   P-LUS.
           WRITE  LIGNE  FROM  TIT-TOTAL  AFTER  3. 
       FF. CLOSE  TAPE1.
           CLOSE  IMP.  
           ENTER MASM 'ACOB$RDMR' USING 
             'END THREAD ;',
             RDMS-STATUS, RDMS-COLUMN.  
           IF RDMS-STATUS NOT = 0 GO TO RDMS-ERROR-PAR. 
           MOVE 0 TO RDMS-FLAG-THREAD.  
           STOP RUN.
       IMP-TOTAL.   
           MOVE '*****TOTAL GENERAL *****'  TO  LIGNE.  
            WRITE  LIGNE  AFTER PAGE.   
           MOVE 17     TO MT-ENE-CHI OF EUW002. 
           MOVE 25     TO LG-MAX-MON-SRT OF EUW002. 
           MOVE MONT1     OF TOTAL TO MT-ENE OF EUW002.  
           MOVE EUW002       TO VL-CHP-TSF  OF WS-CMT-PGM.  
           CALL 'EUU003'     USING WS-CMT-PGM.  
           MOVE VL-CHP-TSF   OF WS-CMT-PGM TO EUW002.   
           MOVE MT-SRT       OF EUW002 TO MONT1 OF LIGNES-SUB.   
           MOVE MONT2     OF TOTAL TO MT-ENE OF EUW002.  
           MOVE EUW002       TO VL-CHP-TSF  OF WS-CMT-PGM.  
           CALL 'EUU003'     USING WS-CMT-PGM.  
           MOVE VL-CHP-TSF   OF WS-CMT-PGM TO EUW002.   
           MOVE MT-SRT       OF EUW002 TO MONT2 OF LIGNES-SUB.   
           MOVE MONT3     OF TOTAL TO MT-ENE OF EUW002.  
           MOVE EUW002       TO VL-CHP-TSF  OF WS-CMT-PGM.  
           CALL 'EUU003'     USING WS-CMT-PGM.  
           MOVE VL-CHP-TSF   OF WS-CMT-PGM TO EUW002.   
           MOVE MT-SRT       OF EUW002 TO MONT3 OF LIGNES-SUB.   
           MOVE MONT4     OF TOTAL TO MT-ENE OF EUW002.  
           MOVE EUW002       TO VL-CHP-TSF  OF WS-CMT-PGM.  
           CALL 'EUU003'     USING WS-CMT-PGM.  
           MOVE VL-CHP-TSF   OF WS-CMT-PGM TO EUW002.   
           MOVE MT-SRT       OF EUW002 TO MONT4 OF LIGNES-SUB.   
           MOVE SPACES TO FA1. 
           WRITE  LIGNE  FROM  LIG-SUB1  AFTER 1.  
           MOVE MONT5     OF TOTAL TO MT-ENE OF EUW002.  
           MOVE EUW002       TO VL-CHP-TSF  OF WS-CMT-PGM.  
           CALL 'EUU003'     USING WS-CMT-PGM.  
           MOVE VL-CHP-TSF   OF WS-CMT-PGM TO EUW002.   
           MOVE MT-SRT       OF EUW002 TO MONT5 OF LIGNES-SUB.   
           MOVE SPACES TO FA5. 
           WRITE  LIGNE  FROM  LIG-SUB5  AFTER 1.  
       PMONT1.   
           IF TMONT1 (KMONT1) = SPACES MOVE ZEROES TO 
               TMONT1 (KMONT1).   
       PMONT2.   
           IF TMONT2 (KMONT2) = SPACES MOVE ZEROES TO 
               TMONT2 (KMONT2).   
       PMONT3.   
           IF TMONT3 (KMONT3) = SPACES MOVE ZEROES TO 
               TMONT3 (KMONT3).   
       PMONT4.   
           IF TMONT4 (KMONT4) = SPACES MOVE ZEROES TO 
               TMONT4 (KMONT4).   
       PMONT5.   
           IF TMONT5 (KMONT5) = SPACES MOVE ZEROES TO 
               TMONT5 (KMONT5).   
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
