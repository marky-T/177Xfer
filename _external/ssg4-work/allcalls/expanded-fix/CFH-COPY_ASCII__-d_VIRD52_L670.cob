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
                   DISC  INP. 
           SELECT TAPEOUT ASSIGN TO 
                   DISC  OUT.
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
           RECIN.   
       01     REC11. 
           06  ZONE1  PIC  X(6).   
       01     REC12. 
                     06 FILLER PIC  X(7).  
           06  ZONE2  PIC  X(1).   
       01     REC13. 
                     06 FILLER PIC  X(761).  
           06  ZONE3  PIC  X(10).   
       01     REC14. 
                     06 FILLER PIC  X(772).  
           06  ZONE4  PIC  X(10).   
       01     REC15. 
                     06 FILLER PIC  X(783).  
           06  ZONE5  PIC  X(10).   
       01     REC16. 
                     06 FILLER PIC  X(794).  
           06  ZONE6  PIC  X(10).   
       01  RECIN   PIC  X(804).   
       FD  TAPEOUT  
           LABEL  RECORD STANDARD   
           BLOCK  CONTAINS 10  RECORDS  
           DATA RECORD IS   
           REC21 
           REC22 
           REC23 
           REC24 
           REC25 
           REC26 
           RECOUT.  
       01  RECOUT   PIC   X(52).
       01  REC21.
           06 ZONO1 PIC X(6). 
       01  REC22.
                     06 FILLER PIC  X(7).  
           06 ZONO2 PIC X(1). 
       01  REC23.
                     06 FILLER PIC  X(9).  
           06 ZONO3 PIC X(10). 
       01  REC24.
                     06 FILLER PIC  X(20).  
           06 ZONO4 PIC X(10). 
       01  REC25.
                     06 FILLER PIC  X(31).  
           06 ZONO5 PIC X(10). 
       01  REC26.
                     06 FILLER PIC  X(42).  
           06 ZONO6 PIC X(10). 
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
           MOVE                ZONE4 TO ZONO4.
           MOVE                ZONE5 TO ZONO5.
           MOVE                ZONE6 TO ZONO6.
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
