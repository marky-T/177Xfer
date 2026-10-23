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
                   DISC  IPBGA02HIDS. 
           SELECT TAPEOUT ASSIGN TO 
                   DISC  IPBGA02HIDT.
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
           RECIN.   
       01     REC11. 
           06  ZONE1  PIC  X(12).   
       01     REC12. 
                     06 FILLER PIC  X(579).  
           06  ZONE2  PIC  X(5).   
       01     REC13. 
                     06 FILLER PIC  X(4).  
           06  ZONE3  PIC  X(1).   
       01     REC14. 
                     06 FILLER PIC  X(18).  
           06  ZONE4  PIC  X(682).   
       01  RECIN   PIC  X(700).   
       FD  TAPEOUT  
           LABEL  RECORD STANDARD   
           BLOCK  CONTAINS 10  RECORDS  
           DATA RECORD IS   
           REC21 
           REC22 
           REC23 
           REC24 
           REC31 
           RECOUT.  
       01  RECOUT   PIC   X(700).
       01  REC21.
           06 ZONO1 PIC X(12). 
       01  REC22.
                     06 FILLER PIC  X(12).  
           06 ZONO2 PIC X(5). 
       01  REC23.
                     06 FILLER PIC  X(17).  
           06 ZONO3 PIC X(1). 
       01  REC24.
                     06 FILLER PIC  X(18).  
           06 ZONO4 PIC X(682). 
       01  REC31.
                     06 FILLER PIC  X(3).  
           06 FIXDATA1 PIC X(2).  
       WORKING-STORAGE SECTION. 
       77  NB-LUS   PIC   9(10)  COMP  VALUE 0. 
       01  TAB11.
           06  FIXED1 PIC X(2)
           VALUE '11'.
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
           MOVE                  FIXED1 TO FIXDATA1.  
           INSPECT FIXDATA1 REPLACING ALL '<' BY ';'.
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
