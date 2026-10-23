       IDENTIFICATION DIVISION. 
       PROGRAM-ID. EXTRACT-.   
       AUTHOR. BOURDEAUD HUY PIERRE.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNIVAC-1100-60EIS.  
       OBJECT-COMPUTER. UNIVAC-1100-60EIS.  
       SPECIAL-NAMES.     PRINTER   IS   LISTE. 
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       DATA DIVISION.   
       FILE SECTION.
       WORKING-STORAGE SECTION. 
       77  INPUT-CT                 PIC 9(10)  COMP  VALUE 0.   
       77  OUTPUT-CT                PIC 9(10)  COMP  VALUE 0.   
       77  ELIMINATE-CT                 PIC 9(10)  COMP VALUE 0.
       01  REQUIREMENTS-1. 
       01  DISPLAY-LINE                          USAGE  DISPLAY-1.  
               03  DISP-MESSAGE        PIC X(24).   
               03  DISP-FNAME          PIC X(12).   
               03  DISP-CT             PIC Z(11)9.  
               03  FILLER              PIC X(84)  VALUE SPACE.  
       01  CTR PIC 9(18) COMP.  
       PROCEDURE DIVISION.  
       E-F- SECTION.   
       DEBUT.   
       OPEN-AND-FIRST-READ. 
           GO TO  SEPARATION.   
       SEPARATION SECTION.  
       REQUIREMENTS-TEST.   
           GO TO  WRITE-1-FROM-FILE-1.  
       ENDING-ROUTINES SECTION. 
       PRINT-FILE-CTS.  
           MOVE  '   TOTAL RECORDS READ   '  TO  DISP-MESSAGE.  
           MOVE  INPUT-CT  TO  DISP-CT. 
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           MOVE  '   TOTAL RECORDS WRITTEN'  TO  DISP-MESSAGE.  
           MOVE  OUTPUT-CT  TO  DISP-CT.
           DISPLAY  DISPLAY-LINE  UPON  LISTE.  
           MOVE  SPACES  TO  DISPLAY-LINE.  
           STOP RUN.
       ABORT-ROUTINES SECTION.  
       SEQUENCE-ERRORS. 
           STOP RUN.
