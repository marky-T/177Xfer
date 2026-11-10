    
    
       IDENTIFICATION DIVISION. 
       PROGRAM-ID. LECTIS.  
       AUTHOR. BOURDEAUD HUY P. 
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNIVAC-1100-60EIS.  
       OBJECT-COMPUTER. UNIVAC-1100-60EIS.  
       SPECIAL-NAMES.   
           DECIMAL-POINT IS COMMA   
               PAGE IS SAUT.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT LECTST  ASSIGN TO DISC LECTST   
               ACCESS MODE IS DYNAMIC   
                    RECORD KEY IS SYMK  
                    ORGANIZATION INDEXED.   
           SELECT IMP ASSIGN TO PRINTER.
           SELECT CARTE ASSIGN TO CARD-READER.  
       DATA DIVISION.   
       FILE SECTION.
       FD  LECTST
           LABEL RECORD STANDARD
           BLOCK CONTAINS 10 RECORDS 
           RECORD CONTAINS 80 CHARACTERS 
           DATA RECORD IS ZFIC ZFICH1.  
       01  ZFIC               PIC X(80). 
       01  ZFICH1.  
           02 SYMK   PIC X(12).   
           02 FILLER PIC X(68).   
       FD  IMP  
           LABEL RECORD OMITTED 
           LINAGE IS 63 
           AT TOP 6 
           AT BOTTOM 3  
           DATA RECORD ZPRINT.  
       01  ZPRINT             PIC X(100) USAGE DISPLAY-1.   
       FD  CARTE
           LABEL RECORD OMITTED 
           DATA RECORD IS ZL1.  
       01  ZL1. 
