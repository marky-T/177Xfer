    
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
           SELECT  TAPEIN  ASSIGN  TO  DISC IPBA07C2B.  
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
           RECIN.   
       01     REC11. 
           06 FILLER PIC  X(7).
           06  ZONE1  PIC  X(2).   
       01     REC12. 
           06 FILLER PIC  X(9).
           06  ZONE2  PIC  X(2).   
       01     REC13. 
           06  ZONE3  PIC  X(6).   
       01     REC14. 
           06 FILLER PIC  X(6).
           06  ZONE4  PIC  X(1).   
       01     REC15. 
           06 FILLER PIC  X(11).
           06  ZONE5  PIC  X(8).   
       01  RECIN   PIC  X(80).   
       FD  TAPEOUT  
           LABEL  RECORD OMITTED
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
           RECOUT.  
       01  RECOUT  PIC  X(132).  
       01  REC21.
           06 FILLER PIC  X(2).
           06 ZONO1 PIC X(2). 
       01  REC22.
           06 FILLER PIC  X(9).
           06 ZONO2 PIC X(2). 
       01  REC23.
           06 FILLER PIC  X(15).
           06 ZONO3 PIC X(6). 
       01  REC24.
           06 FILLER PIC  X(22).
           06 ZONO4 PIC X(1). 
       01  REC25.
           06 FILLER PIC  X(24).
           06 ZONO5 PIC X(8). 
       01  REC31.
           06 FIXDATA1 PIC X(22).  
       01  REC32.
