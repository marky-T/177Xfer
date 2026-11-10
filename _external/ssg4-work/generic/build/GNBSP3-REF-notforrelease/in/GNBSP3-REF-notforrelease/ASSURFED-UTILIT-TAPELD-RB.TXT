    
       IDENTIFICATION DIVISION. 
       PROGRAM-ID. 'ASSURFED-UTILIT-TAPELD-RB'.  
       AUTHOR. MICHEL.  
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNIVAC-1106.
       OBJECT-COMPUTER. UNIVAC-1106.
       SPECIAL-NAMES.   
           DECIMAL-POINT IS COMMA.  
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT  TAPEIN  ASSIGN  TO  DISC IN1.  
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
           REC14 
           REC15 
           REC16 
           REC17 
           RECIN.   
       01     REC11. 
           06  ZONE1  PIC  X(6).   
       01     REC12. 
           06 FILLER PIC  X(9).
           06  ZONE2  PIC  X(1).   
       01     REC13. 
           06 FILLER PIC  X(13).
           06  ZONE3  PIC  X(5).   
       01     REC14. 
           06 FILLER PIC  X(21).
           06  ZONE4  PIC  X(13).   
       01     REC15. 
           06 FILLER PIC  X(37).
           06  ZONE5  PIC  X(13).   
       01     REC16. 
           06 FILLER PIC  X(54).
           06  ZONE6  PIC  X(8).   
       01     REC17. 
           06 FILLER PIC  X(66).
           06  ZONE7  PIC  X(8).   
       01  RECIN   PIC  X(114).   
       FD  TAPEOUT  
           LABEL  RECORD OMITTED
           DATA RECORD IS   
           REC21 
           REC22 
           REC23 
           REC24 
           REC25 
           REC26 
           REC27 
           REC31 
           REC32 
           REC33 
           REC34 
           REC35 
           REC36 
           REC37 
           RECOUT.  
       01  RECOUT  PIC  X(132).  
       01  REC21.
           06 ZONO1 PIC X(6). 
       01  REC22.
           06 FILLER PIC  X(9).
           06 ZONO2 PIC X(1). 
       01  REC23.
           06 FILLER PIC  X(17).
           06 ZONO3 PIC X(5). 
       01  REC24.
           06 FILLER PIC  X(22).
           06 ZONO4 PIC X(13). 
       01  REC25.
           06 FILLER PIC  X(37).
           06 ZONO5 PIC X(13). 
       01  REC26.
           06 FILLER PIC  X(54).
           06 ZONO6 PIC X(8). 
       01  REC27.
           06 FILLER PIC  X(66).
           06 ZONO7 PIC X(8). 
       01  REC31.
           06 FIXDATA1 PIC X(6).  
       01  REC32.
           06 FILLER PIC  X(8).
           06 FIXDATA2 PIC X(4).  
       01  REC33.
           06 FILLER PIC  X(16).
           06 FIXDATA3 PIC X(7).  
       01  REC34.
           06 FILLER PIC  X(30).
           06 FIXDATA4 PIC X(2).  
       01  REC35.
           06 FILLER PIC  X(45).
           06 FIXDATA5 PIC X(2).  
       01  REC36.
           06 FILLER PIC  X(52).
           06 FIXDATA6 PIC X(11).  
       01  REC37.
           06 FILLER PIC  X(65).
           06 FIXDATA7 PIC X(11).  
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
           03  FILLER         PIC X(12) VALUE 'IN1'.  
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
           06 FIXED2  PIC X(4) VALUE 'SUF.'.
       01  TAB13.
           06 FIXED3  PIC X(7) VALUE 'AN. TRF'.
       01  TAB14.
           06 FIXED4  PIC X(2) VALUE 'CD'.
       01  TAB15.
           06 FIXED5  PIC X(2) VALUE 'CV'.
       01  TAB16.
           06 FIXED6  PIC X(11) VALUE 'Dern. paiem'.
       01  TAB17.
           06 FIXED7  PIC X(11) VALUE 'Date calcul'.
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
           MOVE  FIXED4   TO FIXDATA4 
           MOVE  FIXED5   TO FIXDATA5 
           MOVE  FIXED6   TO FIXDATA6 
           MOVE  FIXED7   TO FIXDATA7 
           WRITE  RECOUT  AFTER  PAGE   
           MOVE SPACES TO  RECOUT   
           MOVE 5 TO LNCTR. 
           READ  TAPEIN  AT  END  GO TO  FINW.  
           MOVE                ZONE1 TO ZONO1.
           MOVE                ZONE2 TO ZONO2.
           MOVE                ZONE3 TO ZONO3.
           MOVE                ZONE4 TO ZONO4.
           MOVE                ZONE5 TO ZONO5.
           MOVE                ZONE6 TO ZONO6.
           MOVE                ZONE7 TO ZONO7.
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
