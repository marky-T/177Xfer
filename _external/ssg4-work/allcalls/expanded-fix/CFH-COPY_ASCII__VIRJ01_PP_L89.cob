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
                   DISC  ina. 
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
           RECIN.   
       01     REC11. 
                     06 FILLER PIC  X(20).  
           06  ZONE1  PIC  X(7).   
       01     REC12. 
                     06 FILLER PIC  X(27).  
           06  ZONE2  PIC  X(2).   
       01     REC13. 
                     06 FILLER PIC  X(61).  
           06  ZONE3  PIC  X(6).   
       01     REC14. 
                     06 FILLER PIC  X(132).  
           06  ZONE4  PIC  X(1).   
       01     REC15. 
                     06 FILLER PIC  X(246).  
           06  ZONE5  PIC  X(1).   
       01  RECIN   PIC  X(1000).   
       FD  TAPEOUT  
           LABEL  RECORD STANDARD   
           BLOCK  CONTAINS 10  RECORDS  
           DATA RECORD IS   
           REC21 
           REC22 
           REC23 
           REC24 
           REC25 
           REC31 
           REC32 
           REC33 
           REC34 
           REC35 
           REC36 
           REC37 
           RECOUT.  
       01  RECOUT   PIC   X(256).
       01  REC21.
                     06 FILLER PIC  X(8).  
           06 ZONO1 PIC X(7). 
       01  REC22.
                     06 FILLER PIC  X(16).  
           06 ZONO2 PIC X(2). 
       01  REC23.
                     06 FILLER PIC  X(20).  
           06 ZONO3 PIC X(6). 
       01  REC24.
                     06 FILLER PIC  X(70).  
           06 ZONO4 PIC X(1). 
       01  REC25.
                     06 FILLER PIC  X(27).  
           06 ZONO5 PIC X(1). 
       01  REC31.
           06 FIXDATA1 PIC X(8).  
       01  REC32.
                     06 FILLER PIC  X(15).  
           06 FIXDATA2 PIC X(1).  
       01  REC33.
                     06 FILLER PIC  X(18).  
           06 FIXDATA3 PIC X(1).  
       01  REC34.
                     06 FILLER PIC  X(19).  
           06 FIXDATA4 PIC X(1).  
       01  REC35.
                     06 FILLER PIC  X(26).  
           06 FIXDATA5 PIC X(1).  
       01  REC36.
                     06 FILLER PIC  X(28).  
           06 FIXDATA6 PIC X(42).  
       01  REC37.
                     06 FILLER PIC  X(71).  
           06 FIXDATA7 PIC X(185).  
       WORKING-STORAGE SECTION. 
       77  NB-LUS   PIC   9(10)  COMP  VALUE 0. 
       01  TAB11.
           06  FIXED1  PIC  X(8)  VALUE SPACES.   
       01  TAB12.
           06  FIXED2  PIC  X(1)  VALUE SPACES.   
       01  TAB13.
           06  FIXED3  PIC  X(1)  VALUE SPACES.   
       01  TAB14.
           06  FIXED4  PIC  X(1)  VALUE ZEROES.   
       01  TAB15.
           06  FIXED5  PIC  X(1)  VALUE SPACES.   
       01  TAB16.
           06  FIXED6  PIC  X(42)  VALUE SPACES.   
       01  TAB17.
           06  FIXED7  PIC  X(185)  VALUE SPACES.   
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
           MOVE                  FIXED1 TO FIXDATA1.  
           INSPECT FIXDATA1 REPLACING ALL '<' BY ';'.
           MOVE                  FIXED2 TO FIXDATA2.  
           INSPECT FIXDATA2 REPLACING ALL '<' BY ';'.
           MOVE                  FIXED3 TO FIXDATA3.  
           INSPECT FIXDATA3 REPLACING ALL '<' BY ';'.
           MOVE                  FIXED4 TO FIXDATA4.  
           INSPECT FIXDATA4 REPLACING ALL '<' BY ';'.
           MOVE                  FIXED5 TO FIXDATA5.  
           INSPECT FIXDATA5 REPLACING ALL '<' BY ';'.
           MOVE                  FIXED6 TO FIXDATA6.  
           INSPECT FIXDATA6 REPLACING ALL '<' BY ';'.
           MOVE                  FIXED7 TO FIXDATA7.  
           INSPECT FIXDATA7 REPLACING ALL '<' BY ';'.
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
