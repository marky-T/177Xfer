    
    
       IDENTIFICATION DIVISION. 
       PROGRAM-ID. LECTIS.  
       AUTHOR. BOURDEAUD HUY P. 
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNIVAC-1100-60EIS.  
       OBJECT-COMPUTER. UNIVAC-1100-60EIS.  
       SPECIAL-NAMES.   
           DECIMAL-POINT IS COMMA   
               PAGE IS SAUT.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT LECTST  ASSIGN TO DISC LECTST   
               ACCESS MODE IS SEQUENTIAL
                    RECORD KEY IS SYMK  
                    ORGANIZATION INDEXED.   
           SELECT IMP ASSIGN TO PRINTER.
       DATA DIVISION.   
       FILE SECTION.
       FD  LECTST
           LABEL RECORD STANDARD
           BLOCK CONTAINS 1 RECORDS 
           RECORD CONTAINS 100 CHARACTERS 
           DATA RECORD IS ZFIC ZFICH1.  
       01  ZFIC               PIC X(100). 
       01  ZFICH1.  
           02 SYMK   PIC X(10).   
           02 FILLER PIC X(90).   
       FD  IMP  
           LABEL RECORD OMITTED 
           LINAGE IS 63 
           AT TOP 6 
           AT BOTTOM 3  
           DATA RECORD ZPRINT.  
       01  ZPRINT             PIC X(100) USAGE DISPLAY-1.   
       WORKING-STORAGE SECTION. 
       01  WREC.
           02 FILLER  PIC X(100). 
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
       OUVERT.  
           OPEN OUTPUT IMP. 
           WRITE ZPRINT FROM ZP1 BEFORE PAGE.   
           OPEN INPUT LECTST.
       LECTURE. 
           READ LECTST INTO WREC AT END GO TO FIN.   
           ADD 1 TO CTR.
              IF
           CTR 
           > 
           0 
                    NEXT SENTENCE   
                                      ELSE GO TO LECTURE.   
    
       SUITE.   
           MOVE CTR TO FILCO.   
           WRITE ZPRINT FROM TIT BEFORE 1.  
           MOVE WREC TO ZPR.
           PERFORM IMPRES THRU FIIMPRES.
           GO TO LECTURE.   
       FIN. 
           MOVE SPACES TO ZPRINT.   
           WRITE ZPRINT BEFORE SAUT.
           DISPLAY '** FIN DU TRAVAIL **' UPON PRINTER. 
           DISPLAY 'NOMBRE DE RECORDS LUS ** ' CTR UPON PRINTER.
           CLOSE LECTST IMP. 
           STOP RUN.
       IMPRES.  
           WRITE ZPRINT FROM ZP1 BEFORE 1.  
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP2 BEFORE 1.  
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP3 BEFORE 1.  
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP4 BEFORE 1.  
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP5 BEFORE 1.  
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP6 BEFORE 1.  
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP7 BEFORE 1.  
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP8 BEFORE 1.  
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP9 BEFORE 1.  
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP10 BEFORE 1. 
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP11 BEFORE 1. 
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP12 BEFORE 1. 
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP13 BEFORE 1. 
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP14 BEFORE 1. 
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP15 BEFORE 1. 
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP16 BEFORE 1. 
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP17 BEFORE 1. 
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP18 BEFORE 1. 
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
           WRITE ZPRINT FROM ZP19 BEFORE 1. 
           ADD 100 TO CTRLI.
           IF 100 = CTRLI GO TO RAZ.  
           IF 100 < CTRLI GO TO RAZ.  
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
