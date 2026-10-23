      ***------------------------------------------------------------***
      ***                    -- CONDIS2 --  
      ***              UTILITAIRE - CFH-COPY CONDITIONNEL            ***
      ***------------------------------------------------------------***
      * Type     : UTILITAIRE TRANSFERT DE ZONES CONDITIONNEL          *
      * Analyste : SABLON                          (INITIALES)         *
      * Auteur   : SABLON                                              *
      * Release  : 01                              (99)                *
      * VersIon  : 001                             (999)               *
      *----------------------------------------------------------------*
      * ModIfIcatIons :                                                *
      * QuI ?  Quand ?     QuoI ?                             Projet/Ph*
      * _____  __/__/____  _________________________________  ______/__*
      * _____  __/__/____  _________________________________  ______/__*
      * _____  __/__/____  _________________________________  ______/__*
      * _____  __/__/____  _________________________________  ______/__*
      ***------------------------------------------------------------***
       IDENTIFICATION DIVISION. 
      **************************
       PROGRAM-ID.  CONDIS2.
      *-----------* 
      / 
       ENVIRONMENT DIVISION.
      **********************
       CONFIGURATION SECTION.   
      *======================*  
       SOURCE-COMPUTER.  UNIVAC-1110.   
      *----------------*
       OBJECT-COMPUTER.  UNIVAC-1110.   
      *----------------*
       SPECIAL-NAMES.   
           PRINTER IS PRINER.   
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FILEIN ASSIGN TO DISC FILEIN. 
           SELECT FILEOUT ASSIGN TO DISC FILEOUT.   
       DATA DIVISION.   
      ****************  
       FILE SECTION.
      *------------*
       FD  FILEIN   
           BLOCK CONTAINS 10 RECORDS
               RECORD CONTAINS 408 CHARACTERS
               LABEL RECORD STANDARD
               DATA RECORD IS FSINPUT.  
       01  FSINPUT. 
            02   FILLER    PIC X(408).   
       FD  FILEOUT  
           BLOCK CONTAINS 10 RECORDS   
               RECORD CONTAINS 400 CHARACTERS   
               LABEL RECORD STANDARD
               DATA RECORD IS FSOUTPUT. 
       01  FSOUTPUT.
           02   FILLER     PIC X(400).  
       WORKING-STORAGE SECTION. 
      ************************* 
       01  WS-RECORD-TRANSFORME-22A-200X      PIC X.
       01  WS-RECORD-TRANSFORME-22A-201X      PIC X.
       01  WS-RECORD-TRANSFORME-22A-202X      PIC X.
       01  WS-RECORD-TRANSFORME-22A-203X      PIC X.
       01  WS-RECORD-TRANSFORME-22B-200X      PIC X.
       01  WS-RECORD-TRANSFORME-22B-201X      PIC X.
       01  WS-RECORD-TRANSFORME-22B-202X      PIC X.
       01  WS-RECORD-TRANSFORME-22B-203X      PIC X.
       01  WS-RECORD-TRANSFORME-66A-200X      PIC X.
       01  WS-RECORD-TRANSFORME-66A-201X      PIC X.
       01  WS-RECORD-TRANSFORME-66A-202X      PIC X.
       01  WS-RECORD-TRANSFORME-66A-203X      PIC X.
       01  WS-RECORD-TRANSFORME-66B-200X      PIC X.
       01  WS-RECORD-TRANSFORME-66B-201X      PIC X.
       01  WS-RECORD-TRANSFORME-66B-202X      PIC X.
       01  WS-RECORD-TRANSFORME-66B-203X      PIC X.
       01  NB-REC-TRANSFORME-22A-200X      PIC 9(6).
       01  NB-REC-TRANSFORME-22A-201X      PIC 9(6).
       01  NB-REC-TRANSFORME-22A-202X      PIC 9(6).
       01  NB-REC-TRANSFORME-22A-203X      PIC 9(6).
       01  NB-REC-TRANSFORME-22B-200X      PIC 9(6).
       01  NB-REC-TRANSFORME-22B-201X      PIC 9(6).
       01  NB-REC-TRANSFORME-22B-202X      PIC 9(6).
       01  NB-REC-TRANSFORME-22B-203X      PIC 9(6).
       01  NB-REC-TRANSFORME-66A-200X      PIC 9(6).
       01  NB-REC-TRANSFORME-66A-201X      PIC 9(6).
       01  NB-REC-TRANSFORME-66A-202X      PIC 9(6).
       01  NB-REC-TRANSFORME-66A-203X      PIC 9(6).
       01  NB-REC-TRANSFORME-66B-200X      PIC 9(6).
       01  NB-REC-TRANSFORME-66B-201X      PIC 9(6).
       01  NB-REC-TRANSFORME-66B-202X      PIC 9(6).
       01  NB-REC-TRANSFORME-66B-203X      PIC 9(6).
       01  NB-REC-LU                PIC 9(6).   
       01  NB-REC-ECRIT             PIC 9(6).   
       01  NB-REC-OTHER             PIC 9(6).   
       01  NB-REC-NONECRIT          PIC 9(6).   
       01  WS-A6.   
           02 WS-A6-YY. 
              03 WS-A6-Y1           PIC X(01).  
              03 WS-A6-Y2           PIC X(01).  
           02 WS-A6-MM              PIC X(02).  
           02 WS-A6-JJ              PIC X(02).  
       01  WS-A8.   
           02 WS-A8-YYY.
              03 WS-A8-SS           PIC X(02).  
              03 FILLER             PIC X(01).  
           02 WS-A8-Y4              PIC X(01).  
           02 WS-A8-MM              PIC X(02).  
           02 WS-A8-JJ              PIC X(02).  
       01  WS-A8-BIS REDEFINES WS-A8.   
           02 ws-a8-yy              pic x(02).  
           02 ws-a8-yymmjj          PIC X(06).  
       01  WS-A4.   
           02 WS-A4-SS              PIC X(02).  
           02 WS-A4-AA. 
              03 WS-A4-A1           PIC X(01).  
              03 WS-A4-A2           PIC X(01).  
       01  WS-A2.   
              03 WS-A2-A1           PIC X(01).  
              03 WS-A2-A2           PIC X(01).  
       01  NB-REC-CASE-0            PIC 9(6).   
       01  ENR-INPUT.   
              03  FILLER                PIC X(408).  
       01  ENRIN-MOVE-0-1   REDEFINES ENR-INPUT. 
