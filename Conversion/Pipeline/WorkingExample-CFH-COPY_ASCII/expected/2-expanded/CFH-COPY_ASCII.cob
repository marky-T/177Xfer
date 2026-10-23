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
                   DISC  INB. 
           SELECT TAPEOUT ASSIGN TO 
                   DISC  INC.
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
           RECIN.   
       01     REC11. 
                     06 FILLER PIC  X(5).  
           06  ZONE1  PIC  X(9).   
       01     REC12. 
                     06 FILLER PIC  X(18).  
           06  ZONE2  PIC  X(6).   
       01     REC13. 
                     06 FILLER PIC  X(402).  
           06  ZONE3  PIC  X(2).   
       01     REC14. 
                     06 FILLER PIC  X(56).  
           06  ZONE4  PIC  X(8).   
       01     REC15. 
                     06 FILLER PIC  X(64).  
           06  ZONE5  PIC  X(4).   
       01     REC16. 
                     06 FILLER PIC  X(112).  
           06  ZONE6  PIC  X(24).   
       01     REC17. 
                     06 FILLER PIC  X(160).  
           06  ZONE7  PIC  X(24).   
       01     REC18. 
                     06 FILLER PIC  X(404).  
           06  ZONE8  PIC  X(16).   
       01     REC19. 
                     06 FILLER PIC  X(420).  
           06  ZONE9  PIC  X(24).   
       01     REC110. 
                     06 FILLER PIC  X(264).  
           06  ZONE10  PIC  X(8).   
       01  RECIN   PIC  X(500).   
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
           REC27 
           REC28 
           REC29 
           REC210 
           REC31 
           RECOUT.  
       01  RECOUT   PIC   X(135).
       01  REC21.
                     06 FILLER PIC  X(10).  
           06 ZONO1 PIC X(9). 
       01  REC22.
                     06 FILLER PIC  X(19).  
           06 ZONO2 PIC X(6). 
       01  REC23.
                     06 FILLER PIC  X(25).  
           06 ZONO3 PIC X(2). 
       01  REC24.
                     06 FILLER PIC  X(27).  
           06 ZONO4 PIC X(8). 
       01  REC25.
                     06 FILLER PIC  X(35).  
           06 ZONO5 PIC X(4). 
       01  REC26.
                     06 FILLER PIC  X(39).  
           06 ZONO6 PIC X(24). 
       01  REC27.
                     06 FILLER PIC  X(63).  
           06 ZONO7 PIC X(24). 
       01  REC28.
                     06 FILLER PIC  X(87).  
           06 ZONO8 PIC X(16). 
       01  REC29.
                     06 FILLER PIC  X(103).  
           06 ZONO9 PIC X(24). 
       01  REC210.
                     06 FILLER PIC  X(127).  
           06 ZONO10 PIC X(8). 
       01  REC31.
           06 FIXDATA1 PIC X(10).  
       WORKING-STORAGE SECTION. 
       77  NB-LUS   PIC   9(10)  COMP  VALUE 0. 
       01  TAB11.
           06  FIXED1 PIC X(10)
           VALUE 'TAX-CLASIQ'.
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
           MOVE                ZONE7 TO ZONO7.
           MOVE                ZONE8 TO ZONO8.
           MOVE                ZONE9 TO ZONO9.
           MOVE                ZONE10 TO ZONO10.
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
