    
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
           REC38 
           REC39 
           REC310 
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
