    
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
           06  ZONE2  PIC  X(2).   
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
           REC34 
           REC35 
           REC36 
           REC37 
           RECOUT.  
       01  RECOUT  PIC  X(132).  
       01  REC21.
           06 ZONO1 PIC X(7). 
       01  REC22.
           06 FILLER PIC  X(12).
           06 ZONO2 PIC X(2). 
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
       01  REC34.
           06 FILLER PIC  X(31).
           06 FIXDATA4 PIC X(27).  
       01  REC35.
