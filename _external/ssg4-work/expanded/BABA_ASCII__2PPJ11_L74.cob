       IDENTIFICATION DIVISION. 
       PROGRAM-ID. EXTRACT-I001MSG054.   
       AUTHOR. BOURDEAUD HUY PIERRE.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNIVAC-1100-60EIS.  
       OBJECT-COMPUTER. UNIVAC-1100-60EIS.  
       SPECIAL-NAMES.     PRINTER   IS   LISTE. 
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT  TAPEIN1  ASSIGN  TO 
                    DISC  I001MSG054.  
           SELECT  TAPEOUT1  ASSIGN  TO   
                    DISC  I006MSG054.
       DATA DIVISION.   
       FILE SECTION.
       FD  TAPEIN1 
                    LABEL RECORD IS STANDARD
                   BLOCK CONTAINS 10 RECORDS   
                   RECORD CONTAINS 366 CHARACTERS   
                    DATA RECORD  IS REC-IN-1.  
       01  REC-IN-1.   
       FD  TAPEOUT1 
                    LABEL RECORD IS STANDARD
                    BLOCK CONTAINS 10 RECORDS  
                    RECORD CONTAINS 366 CHARACTERS  
                    DATA RECORD IS REC-OUT-1.   
       01  REC-OUT-1           PIC X(366).  
       WORKING-STORAGE SECTION. 
       77  TAPE-1-CT                PIC 9(10)  COMP VALUE 0.   
       77  INPUT-CT                 PIC 9(10)  COMP  VALUE 0.   
       77  TAPE-1-OUT-CT            PIC 9(10)  COMP  VALUE 0. 
       77  OUTPUT-CT                PIC 9(10)  COMP  VALUE 0.   
       77  ELIMINATE-CT                 PIC 9(10)  COMP VALUE 0.
       01  REQUIREMENTS-1. 
