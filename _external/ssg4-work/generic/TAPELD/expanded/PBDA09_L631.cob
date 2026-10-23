    
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
           SELECT  TAPEIN  ASSIGN  TO  DISC IPBA09CMBB.  
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
           06  ZONE1  PIC  X(7).   
       01     REC12. 
           06 FILLER PIC  X(8).
           06  ZONE2  PIC  X(2).   
       01     REC13. 
           06 FILLER PIC  X(13).
           06  ZONE3  PIC  X(2).   
       01  RECIN   PIC  X(80).   
       FD  TAPEOUT  
           LABEL  RECORD OMITTED
           DATA RECORD IS   
           REC21 
           REC22 
           REC23 
           REC31 
           REC32 
           RECOUT.  
       01  RECOUT  PIC  X(132).  
       01  REC21.
           06 ZONO1 PIC X(7). 
       01  REC22.
           06 FILLER PIC  X(9).
           06 ZONO2 PIC X(2). 
       01  REC23.
           06 FILLER PIC  X(17).
           06 ZONO3 PIC X(2). 
       01  REC31.
           06 FIXDATA1 PIC X(24).  
       01  REC32.
           06 FILLER PIC  X(25).
           06 FIXDATA2 PIC X(30).  
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
           03  FILLER         PIC X(12) VALUE 'IPBA09CMBB'.  
           03  FILLER         PIC X(13) VALUE ' TO PRINTER '.   
           03  FILLER         PIC X(10) VALUE '1234567890'. 
           03  FILLER         PIC X(10) VALUE '1234567890'. 
           03  FILLER         PIC X(10) VALUE '1234567890'. 
           03  FILLER         PIC X(10) VALUE '1234567890'. 
           03  FILLER         PIC X(10) VALUE '1234567890'. 
           03  FILLER         PIC X(5)  VALUE '12 . '.  
       01  TAB11.
           06 FIXED1  PIC X(24) VALUE 'POLICE~~CMB-DB~~CMB-INV'.
       01  TAB12.
           06 FIXED2  PIC X(30) VALUE 'CHANGEMENT~COMBINAISON~IND'.
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
