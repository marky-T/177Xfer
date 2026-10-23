       IDENTIFICATION DIVISION. 
       PROGRAM-ID. 'CFH-COPY'.  
       AUTHOR. BOURDEAUD HUY PIERRE.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNIVAC-1100-10. 
       OBJECT-COMPUTER. UNIVAC-1100-10. 
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT  TAPEIN  ASSIGN  TO   
                   DISC  IVIR002CCH. 
           SELECT TAPEOUT ASSIGN TO 
                   DISC  IVIR002CCHT.
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
           06  ZONE1  PIC  X(12).   
       01     REC12. 
                     06 FILLER PIC  X(844).  
           06  ZONE2  PIC  X(5).   
       01     REC13. 
                     06 FILLER PIC  X(17).  
           06  ZONE3  PIC  X(883).   
       01  RECIN   PIC  X(900).   
       FD  TAPEOUT  
           LABEL  RECORD STANDARD   
           BLOCK  CONTAINS 10  RECORDS  
           DATA RECORD IS   
           REC21 
           REC22 
           REC23 
           RECOUT.  
       01  RECOUT   PIC   X(900).
       01  REC21.
           06 ZONO1 PIC X(12). 
       01  REC22.
                     06 FILLER PIC  X(12).  
           06 ZONO2 PIC X(5). 
       01  REC23.
                     06 FILLER PIC  X(17).  
           06 ZONO3 PIC X(883). 
       WORKING-STORAGE SECTION. 
       77  NB-LUS   PIC   9(10)  COMP  VALUE 0. 
       01   SWITCHES.   
           03  REC-SKIPPED  PIC  S9(6) VALUE ZEROES.
       PROCEDURE DIVISION.  
       DEBUT.   
           OPEN INPUT TAPEIN.   
           OPEN  OUTPUT  TAPEOUT.   
       LECT.
           MOVE SPACES TO RECOUT.   
           READ  TAPEIN  AT  END  GO TO  FINW.  
           MOVE                ZONE1 TO ZONO1.
           MOVE                ZONE2 TO ZONO2.
           MOVE                ZONE3 TO ZONO3.
           ADD 1  TO NB-LUS.
           WRITE RECOUT.
           GO TO LECT.  
       FINW.
           DISPLAY  '*CFH-COPY  FIN*'  UPON  PRINTER.   
           DISPLAY  '*NB-ENREG-LUS ='  NB-LUS  UPON  PRINTER.   
           CLOSE  TAPEIN.   
           CLOSE  TAPEOUT.  
           DISPLAY  REC-SKIPPED  UPON  PRINTER. 
           STOP RUN.
