    
       IDENTIFICATION DIVISION. 
       PROGRAM-ID. 'CFH-COPY'.  
       AUTHOR. MICHEL.  
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNIVAC-1106.
       OBJECT-COMPUTER. UNIVAC-1106.
       SPECIAL-NAMES.   
           DECIMAL-POINT IS COMMA.  
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT  TAPEIN  ASSIGN  TO  DISC INP.  
           SELECT   TAPEOUT  ASSIGN  TO  PRINTER.   
       DATA DIVISION.   
       FILE SECTION.
       FD  TAPEIN   
           LABEL  RECORD  STANDARD  
           BLOCK CONTAINS 10  RECORDS
           DATA RECORD IS   
           REC11 
           REC12 
           REC13 
           RECIN.   
       01     REC11. 
           06 FILLER PIC  X(5).
           06  ZONE1  PIC  X(7).   
       01     REC12. 
           06 FILLER PIC  X(12).
           06  ZONE2  PIC  X(5).   
       01     REC13. 
           06 FILLER PIC  X(18).
           06  ZONE3  PIC  X(6).   
       01  RECIN   PIC  X(900).   
       FD  TAPEOUT  
           LABEL  RECORD OMITTED
           DATA RECORD IS   
           REC21 
           REC22 
           REC23 
           REC31 
           REC32 
           REC33 
           RECOUT.  
       01  RECOUT  PIC  X(132).  
       01  REC21.
           06 ZONO1 PIC X(7). 
       01  REC22.
           06 FILLER PIC  X(12).
           06 ZONO2 PIC X(5). 
       01  REC23.
           06 FILLER PIC  X(21).
           06 ZONO3 PIC X(6). 
       01  REC31.
           06 FILLER PIC  X(1).
           06 FIXDATA1 PIC X(6).  
       01  REC32.
           06 FILLER PIC  X(9).
           06 FIXDATA2 PIC X(7).  
       01  REC33.
           06 FILLER PIC  X(19).
           06 FIXDATA3 PIC X(9).  
       WORKING-STORAGE SECTION. 
       77  NB-LUS   PIC  S9(10)  COMP  VALUE 0. 
       77  LNCTR  PIC  S9(2)  VALUE 58. 
       01  TITLE-LINE         USAGE DISP-1. 
           03  FILLER         PIC X(4) VALUE 'H,,,'.
           03  FILLER         PIC X(10)  VALUE '1234567890'.
           03  FILLER         PIC X(10)  VALUE '1234567890'.
           03  FILLER         PIC X(10)  VALUE '1234567890'.
           03  FILLER         PIC X(10)  VALUE '1234567890'.
           03  FILLER         PIC X(10) VALUE '1234567890'. 
           03  FILLER         PIC X(5)  VALUE SPACES.   
           03  FILLER         PIC X(12) VALUE 'INP'.  
           03  FILLER         PIC X(13) VALUE ' TO PRINTER '.   
           03  FILLER         PIC X(10) VALUE '1234567890'. 
           03  FILLER         PIC X(10) VALUE '1234567890'. 
           03  FILLER         PIC X(10) VALUE '1234567890'. 
           03  FILLER         PIC X(10) VALUE '1234567890'. 
           03  FILLER         PIC X(10) VALUE '1234567890'. 
           03  FILLER         PIC X(5)  VALUE '12 . '.  
       01  TAB11.
           06 FIXED1  PIC X(6) VALUE 'POLICE'.
       01  TAB12.
           06 FIXED2  PIC X(7) VALUE 'ANN~TRF'.
       01  TAB13.
           06 FIXED3  PIC X(9) VALUE 'MATRICULE';.
       01   SWITCHES.   
           03  REC-SKIPPED  PIC  S9(6) VALUE ZEROES.
       PROCEDURE DIVISION.  
       DEBUT.   
           OPEN INPUT TAPEIN.   
           OPEN  OUTPUT  TAPEOUT.   
       LECT.
           MOVE SPACES TO RECOUT.   
           IF  LNCTR  > 57  
           MOVE  FIXED1   TO FIXDATA1 
           MOVE  FIXED2   TO FIXDATA2 
           MOVE  FIXED3   TO FIXDATA3 
           WRITE  RECOUT  AFTER  PAGE   
           MOVE SPACES TO  RECOUT   
           MOVE 5 TO LNCTR. 
           READ  TAPEIN  AT  END  GO TO  FINW.  
           MOVE                ZONE1 TO ZONO1.
           MOVE                ZONE2 TO ZONO2.
           MOVE                ZONE3 TO ZONO3.
           ADD 1  TO NB-LUS.
           ADD 1  TO LNCTR. 
           WRITE RECOUT.
           GO TO LECT.  
       FINW.
           DISPLAY  '*CFH-COPY  FIN*'  UPON  PRINTER.   
           DISPLAY  '*NB-ENREG-LUS ='  NB-LUS  UPON  PRINTER.   
           CLOSE  TAPEIN.   
           CLOSE  TAPEOUT.  
           DISPLAY  REC-SKIPPED  UPON  PRINTER. 
           STOP RUN.
