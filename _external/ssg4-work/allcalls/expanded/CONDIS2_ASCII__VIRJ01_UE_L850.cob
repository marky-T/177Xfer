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
               RECORD CONTAINS 132 CHARACTERS
               LABEL RECORD STANDARD
               DATA RECORD IS FSINPUT.  
       01  FSINPUT. 
            02   FILLER    PIC X(132).   
       FD  FILEOUT  
           BLOCK CONTAINS 10 RECORDS   
               RECORD CONTAINS 132 CHARACTERS   
               LABEL RECORD STANDARD
               DATA RECORD IS FSOUTPUT. 
       01  FSOUTPUT.
           02   FILLER     PIC X(132).  
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
       01  NB-REC-CASE-1    PIC 9(6).   
       01  NB-REC-CASE-2    PIC 9(6).   
       01  NB-REC-CASE-3    PIC 9(6).   
       01  NB-REC-CASE-4    PIC 9(6).   
       01  NB-REC-CASE-5    PIC 9(6).   
       01  NB-REC-CASE-6    PIC 9(6).   
       01  NB-REC-CASE-7    PIC 9(6).   
       01  NB-REC-CASE-8    PIC 9(6).   
       01  NB-REC-CASE-9    PIC 9(6).   
       01  NB-REC-CASE-10    PIC 9(6).   
       01  NB-REC-CASE-11    PIC 9(6).   
       01  NB-REC-CASE-12    PIC 9(6).   
       01  NB-REC-CASE-13    PIC 9(6).   
       01  NB-REC-CASE-14    PIC 9(6).   
       01  NB-REC-CASE-15    PIC 9(6).   
       01  NB-REC-CASE-16    PIC 9(6).   
       01  NB-REC-CASE-17    PIC 9(6).   
       01  NB-REC-CASE-18    PIC 9(6).   
       01  NB-REC-CASE-19    PIC 9(6).   
       01  NB-REC-CASE-20    PIC 9(6).   
       01  NB-REC-CASE-21    PIC 9(6).   
       01  NB-REC-CASE-22    PIC 9(6).   
       01  NB-REC-CASE-23    PIC 9(6).   
       01  NB-REC-CASE-24    PIC 9(6).   
       01  NB-REC-CASE-25    PIC 9(6).   
       01  NB-REC-CASE-26    PIC 9(6).   
       01  NB-REC-CASE-27    PIC 9(6).   
       01  NB-REC-CASE-28    PIC 9(6).   
       01  NB-REC-CASE-29    PIC 9(6).   
       01  NB-REC-CASE-30    PIC 9(6).   
       01  NB-REC-CASE-31    PIC 9(6).   
       01  NB-REC-CASE-32    PIC 9(6).   
       01  NB-REC-CASE-33    PIC 9(6).   
       01  NB-REC-CASE-34    PIC 9(6).   
       01  ENR-INPUT.   
              03  FILLER                PIC X(132).  
       01  ENR-CASE-1-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-1-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-1-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-1-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-1-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-1-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-1-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-1-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-1-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-1-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-2-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-2-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-2-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-2-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-2-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-2-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-2-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-2-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-2-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-2-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-3-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-3-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-3-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-3-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-3-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-3-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-3-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-3-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-3-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-3-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-4-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-4-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-4-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-4-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-4-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-4-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-4-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-4-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-4-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-4-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-5-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-5-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-5-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-5-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-5-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-5-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-5-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-5-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-5-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-5-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-6-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-6-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-6-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-6-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-6-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-6-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-6-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-6-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-6-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-6-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-7-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-7-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-7-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-7-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-7-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-7-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-7-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-7-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-7-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-7-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-8-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-8-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-8-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-8-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-8-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-8-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-8-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-8-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-8-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-8-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-9-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-9-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-9-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-9-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-9-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-9-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-9-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-9-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-9-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-9-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-10-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-10-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-10-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-10-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-10-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-10-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-10-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-10-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-10-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-10-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-11-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-11-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-11-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-11-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-11-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-11-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-11-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-11-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-11-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-11-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-12-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-12-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-12-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-12-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-12-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-12-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-12-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-12-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-12-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-12-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-13-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-13-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-13-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-13-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-13-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-13-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-13-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-13-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-13-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-13-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-14-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-14-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-14-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-14-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-14-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-14-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-14-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-14-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-14-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-14-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-15-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-15-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-15-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-15-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-15-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-15-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-15-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-15-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-15-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-15-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-16-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-16-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-16-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-16-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-16-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-16-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-16-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-16-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-16-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-16-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-17-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-17-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-17-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-17-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-17-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-17-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-17-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-17-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-17-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-17-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-18-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-18-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-18-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-18-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-18-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-18-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-18-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-18-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-18-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-18-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-19-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-19-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-19-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-19-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-19-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-19-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-19-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-19-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-19-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-19-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-20-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-20-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-20-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-20-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-20-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-20-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-20-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-20-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-20-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-20-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-21-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-21-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-21-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-21-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-21-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-21-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-21-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-21-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-21-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-21-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-22-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-22-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-22-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-22-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-22-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-22-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-22-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-22-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-22-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-22-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-23-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-23-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-23-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-23-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-23-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-23-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-23-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-23-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-23-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-23-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-24-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-24-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-24-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-24-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-24-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-24-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-24-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-24-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-24-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-24-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-25-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-25-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-25-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-25-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-25-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-25-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-25-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-25-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-25-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-25-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-26-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-26-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-26-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-26-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-26-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-26-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-26-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-26-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-26-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-26-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-27-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-27-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-27-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-27-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-27-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-27-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-27-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-27-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-27-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-27-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-28-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-28-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-28-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-28-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-28-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-28-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-28-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-28-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-28-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-28-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-29-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-29-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-29-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-29-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-29-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-29-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-29-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-29-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-29-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-29-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-30-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-30-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-30-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-30-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-30-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-30-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-30-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-30-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-30-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-30-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-31-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-31-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-31-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-31-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-31-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-31-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-31-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-31-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-31-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-31-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-32-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-32-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-32-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-32-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-32-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-32-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-32-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-32-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-32-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-32-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-33-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-33-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-33-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-33-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-33-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-33-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-33-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-33-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-33-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-33-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-CASE-34-1       REDEFINES ENR-INPUT.   
           03 FILLER                   PIC X(41).
           03 CASE-34-1  PIC X(1).   
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-34-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-34-1  PIC X(29). 
           03 FILLER                   PIC X(103).
       01  ENRIN-MOVE-34-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(30).
           03 MOVEIN-34-2  PIC X(11). 
           03 FILLER                   PIC X(91).
       01  ENRIN-MOVE-34-3   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(42).
           03 MOVEIN-34-3  PIC X(1). 
           03 FILLER                   PIC X(89).
       01  ENRIN-MOVE-34-4   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-34-4  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENRIN-MOVE-35-1   REDEFINES ENR-INPUT. 
           03 MOVEIN-35-1  PIC X(42). 
           03 FILLER                   PIC X(90).
       01  ENRIN-MOVE-35-2   REDEFINES ENR-INPUT. 
           03 FILLER                   PIC X(46).
           03 MOVEIN-35-2  PIC X(11). 
           03 FILLER                   PIC X(75).
       01  ENR-OUTPUT.  
              03  FILLER                PIC X(132). 
       01  ENROUT-MOVE-1-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-1-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-1-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-1-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-1-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-1-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-1-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-1-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-1-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-1-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-1-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-1-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-1-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-1-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-2-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-2-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-2-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-2-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-2-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-2-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-2-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-2-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-2-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-2-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-2-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-2-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-2-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-2-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-3-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-3-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-3-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-3-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-3-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-3-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-3-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-3-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-3-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-3-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-3-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-3-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-3-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-3-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-4-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-4-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-4-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-4-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-4-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-4-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-4-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-4-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-4-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-4-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-4-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-4-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-4-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-4-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-5-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-5-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-5-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-5-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-5-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-5-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-5-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-5-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-5-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-5-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-5-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-5-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-5-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-5-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-6-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-6-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-6-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-6-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-6-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-6-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-6-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-6-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-6-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-6-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-6-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-6-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-6-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-6-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-7-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-7-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-7-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-7-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-7-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-7-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-7-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-7-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-7-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-7-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-7-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-7-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-7-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-7-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-8-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-8-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-8-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-8-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-8-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-8-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-8-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-8-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-8-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-8-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-8-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-8-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-8-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-8-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-9-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-9-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-9-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-9-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-9-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-9-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-9-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-9-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-9-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-9-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-9-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-9-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-9-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-9-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-10-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-10-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-10-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-10-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-10-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-10-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-10-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-10-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-10-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-10-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-10-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-10-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-10-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-10-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-11-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-11-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-11-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-11-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-11-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-11-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-11-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-11-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-11-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-11-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-11-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-11-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-11-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-11-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-12-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-12-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-12-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-12-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-12-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-12-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-12-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-12-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-12-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-12-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-12-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-12-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-12-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-12-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-13-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-13-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-13-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-13-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-13-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-13-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-13-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-13-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-13-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-13-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-13-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-13-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-13-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-13-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-14-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-14-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-14-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-14-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-14-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-14-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-14-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-14-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-14-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-14-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-14-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-14-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-14-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-14-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-15-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-15-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-15-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-15-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-15-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-15-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-15-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-15-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-15-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-15-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-15-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-15-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-15-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-15-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-16-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-16-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-16-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-16-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-16-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-16-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-16-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-16-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-16-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-16-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-16-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-16-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-16-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-16-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-17-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-17-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-17-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-17-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-17-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-17-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-17-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-17-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-17-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-17-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-17-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-17-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-17-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-17-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-18-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-18-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-18-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-18-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-18-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-18-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-18-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-18-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-18-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-18-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-18-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-18-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-18-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-18-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-19-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-19-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-19-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-19-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-19-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-19-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-19-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-19-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-19-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-19-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-19-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-19-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-19-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-19-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-20-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-20-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-20-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-20-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-20-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-20-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-20-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-20-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-20-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-20-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-20-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-20-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-20-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-20-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-21-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-21-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-21-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-21-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-21-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-21-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-21-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-21-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-21-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-21-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-21-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-21-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-21-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-21-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-22-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-22-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-22-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-22-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-22-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-22-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-22-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-22-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-22-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-22-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-22-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-22-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-22-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-22-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-23-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-23-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-23-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-23-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-23-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-23-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-23-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-23-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-23-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-23-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-23-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-23-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-23-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-23-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-24-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-24-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-24-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-24-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-24-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-24-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-24-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-24-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-24-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-24-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-24-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-24-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-24-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-24-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-25-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-25-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-25-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-25-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-25-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-25-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-25-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-25-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-25-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-25-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-25-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-25-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-25-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-25-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-26-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-26-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-26-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-26-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-26-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-26-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-26-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-26-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-26-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-26-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-26-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-26-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-26-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-26-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-27-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-27-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-27-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-27-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-27-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-27-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-27-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-27-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-27-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-27-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-27-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-27-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-27-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-27-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-28-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-28-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-28-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-28-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-28-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-28-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-28-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-28-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-28-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-28-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-28-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-28-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-28-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-28-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-29-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-29-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-29-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-29-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-29-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-29-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-29-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-29-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-29-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-29-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-29-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-29-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-29-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-29-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-30-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-30-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-30-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-30-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-30-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-30-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-30-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-30-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-30-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-30-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-30-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-30-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-30-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-30-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-31-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-31-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-31-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-31-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-31-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-31-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-31-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-31-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-31-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-31-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-31-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-31-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-31-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-31-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-32-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-32-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-32-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-32-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-32-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-32-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-32-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-32-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-32-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-32-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-32-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-32-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-32-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-32-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-33-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-33-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-33-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-33-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-33-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-33-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-33-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-33-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-33-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-33-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-33-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-33-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-33-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-33-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-34-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-34-1  PIC X(29).
           03 FILLER                   PIC X(103).
       01  ENROUT-MOVE-34-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(30).
           03 MOVEOUT-34-2  PIC X(11).
           03 FILLER                   PIC X(91).
       01  ENROUT-MOVE-34-3   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(42).
           03 MOVEOUT-34-3  PIC X(1).
           03 FILLER                   PIC X(89).
       01  ENROUT-MOVE-34-4   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-34-4  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-34-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(29).
           03 CONST-34-1  PIC X(1).  
           03 FILLER                   PIC X(102).
       01  ENROUT-CONST-34-2   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(41).
           03 CONST-34-2  PIC X(1).  
           03 FILLER                   PIC X(90).
       01  ENROUT-CONST-34-3   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-34-3  PIC X(3).  
           03 FILLER                   PIC X(86).
       01  ENROUT-MOVE-35-1   REDEFINES ENR-OUTPUT.   
           03 MOVEOUT-35-1  PIC X(42).
           03 FILLER                   PIC X(90).
       01  ENROUT-MOVE-35-2   REDEFINES ENR-OUTPUT.   
           03 FILLER                   PIC X(46).
           03 MOVEOUT-35-2  PIC X(11).
           03 FILLER                   PIC X(75).
       01  ENROUT-CONST-35-1   REDEFINES ENR-OUTPUT.  
           03 FILLER                   PIC X(43).
           03 CONST-35-1  PIC X(3).  
           03 FILLER                   PIC X(86).
       PROCEDURE DIVISION.  
      ********************  
       DEBUT.   
           OPEN INPUT  FILEIN   
                OUTPUT FILEOUT. 
           MOVE 0 TO NB-REC-LU. 
           MOVE 0 TO NB-REC-ECRIT.  
           MOVE 0 TO NB-REC-NONECRIT.   
           MOVE 0 TO NB-REC-TRANSFORME-22A-200X.
           MOVE 0 TO NB-REC-TRANSFORME-22A-201X.
           MOVE 0 TO NB-REC-TRANSFORME-22A-202X.
           MOVE 0 TO NB-REC-TRANSFORME-22A-203X.
           MOVE 0 TO NB-REC-TRANSFORME-22B-200X.
           MOVE 0 TO NB-REC-TRANSFORME-22B-201X.
           MOVE 0 TO NB-REC-TRANSFORME-22B-202X.
           MOVE 0 TO NB-REC-TRANSFORME-22B-203X.
           MOVE 0 TO NB-REC-TRANSFORME-66A-200X.
           MOVE 0 TO NB-REC-TRANSFORME-66A-201X.
           MOVE 0 TO NB-REC-TRANSFORME-66A-202X.
           MOVE 0 TO NB-REC-TRANSFORME-66A-203X.
           MOVE 0 TO NB-REC-TRANSFORME-66B-200X.
           MOVE 0 TO NB-REC-TRANSFORME-66B-201X.
           MOVE 0 TO NB-REC-TRANSFORME-66B-202X.
           MOVE 0 TO NB-REC-TRANSFORME-66B-203X.
           MOVE 0 TO NB-REC-CASE-1. 
           MOVE 0 TO NB-REC-CASE-2. 
           MOVE 0 TO NB-REC-CASE-3. 
           MOVE 0 TO NB-REC-CASE-4. 
           MOVE 0 TO NB-REC-CASE-5. 
           MOVE 0 TO NB-REC-CASE-6. 
           MOVE 0 TO NB-REC-CASE-7. 
           MOVE 0 TO NB-REC-CASE-8. 
           MOVE 0 TO NB-REC-CASE-9. 
           MOVE 0 TO NB-REC-CASE-10. 
           MOVE 0 TO NB-REC-CASE-11. 
           MOVE 0 TO NB-REC-CASE-12. 
           MOVE 0 TO NB-REC-CASE-13. 
           MOVE 0 TO NB-REC-CASE-14. 
           MOVE 0 TO NB-REC-CASE-15. 
           MOVE 0 TO NB-REC-CASE-16. 
           MOVE 0 TO NB-REC-CASE-17. 
           MOVE 0 TO NB-REC-CASE-18. 
           MOVE 0 TO NB-REC-CASE-19. 
           MOVE 0 TO NB-REC-CASE-20. 
           MOVE 0 TO NB-REC-CASE-21. 
           MOVE 0 TO NB-REC-CASE-22. 
           MOVE 0 TO NB-REC-CASE-23. 
           MOVE 0 TO NB-REC-CASE-24. 
           MOVE 0 TO NB-REC-CASE-25. 
           MOVE 0 TO NB-REC-CASE-26. 
           MOVE 0 TO NB-REC-CASE-27. 
           MOVE 0 TO NB-REC-CASE-28. 
           MOVE 0 TO NB-REC-CASE-29. 
           MOVE 0 TO NB-REC-CASE-30. 
           MOVE 0 TO NB-REC-CASE-31. 
           MOVE 0 TO NB-REC-CASE-32. 
           MOVE 0 TO NB-REC-CASE-33. 
           MOVE 0 TO NB-REC-CASE-34. 
           MOVE 0 TO NB-REC-OTHER.  
       TRT. 
           READ FILEIN INTO ENR-INPUT AT END GO TO FIN-TRT. 
           MOVE SPACES TO ENR-OUTPUT.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-22A-200X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-22A-201X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-22A-202X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-22A-203X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-22B-200X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-22B-201X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-22B-202X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-22B-203X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-66A-200X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-66A-201X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-66A-202X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-66A-203X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-66B-200X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-66B-201X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-66B-202X.   
           MOVE 'N' TO WS-RECORD-TRANSFORME-66B-203X.   
           ADD 1 TO NB-REC-LU.  
       CASE-1.  
           IF CASE-1-1 = '0'
              MOVE MOVEIN-1-1 TO MOVEOUT-1-1  
              MOVE MOVEIN-1-2 TO MOVEOUT-1-2  
              MOVE MOVEIN-1-3 TO MOVEOUT-1-3  
              MOVE MOVEIN-1-4 TO MOVEOUT-1-4  
              MOVE '-' TO CONST-1-1 
              MOVE '0' TO CONST-1-2 
              MOVE 'EUR' TO CONST-1-3 
              ADD 1 TO NB-REC-CASE-1 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-2.  
           IF CASE-2-1 = '1'
              MOVE MOVEIN-2-1 TO MOVEOUT-2-1  
              MOVE MOVEIN-2-2 TO MOVEOUT-2-2  
              MOVE MOVEIN-2-3 TO MOVEOUT-2-3  
              MOVE MOVEIN-2-4 TO MOVEOUT-2-4  
              MOVE '-' TO CONST-2-1 
              MOVE '1' TO CONST-2-2 
              MOVE 'EUR' TO CONST-2-3 
              ADD 1 TO NB-REC-CASE-2 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-3.  
           IF CASE-3-1 = '2'
              MOVE MOVEIN-3-1 TO MOVEOUT-3-1  
              MOVE MOVEIN-3-2 TO MOVEOUT-3-2  
              MOVE MOVEIN-3-3 TO MOVEOUT-3-3  
              MOVE MOVEIN-3-4 TO MOVEOUT-3-4  
              MOVE '-' TO CONST-3-1 
              MOVE '2' TO CONST-3-2 
              MOVE 'EUR' TO CONST-3-3 
              ADD 1 TO NB-REC-CASE-3 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-4.  
           IF CASE-4-1 = '3'
              MOVE MOVEIN-4-1 TO MOVEOUT-4-1  
              MOVE MOVEIN-4-2 TO MOVEOUT-4-2  
              MOVE MOVEIN-4-3 TO MOVEOUT-4-3  
              MOVE MOVEIN-4-4 TO MOVEOUT-4-4  
              MOVE '-' TO CONST-4-1 
              MOVE '3' TO CONST-4-2 
              MOVE 'EUR' TO CONST-4-3 
              ADD 1 TO NB-REC-CASE-4 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-5.  
           IF CASE-5-1 = '4'
              MOVE MOVEIN-5-1 TO MOVEOUT-5-1  
              MOVE MOVEIN-5-2 TO MOVEOUT-5-2  
              MOVE MOVEIN-5-3 TO MOVEOUT-5-3  
              MOVE MOVEIN-5-4 TO MOVEOUT-5-4  
              MOVE '-' TO CONST-5-1 
              MOVE '4' TO CONST-5-2 
              MOVE 'EUR' TO CONST-5-3 
              ADD 1 TO NB-REC-CASE-5 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-6.  
           IF CASE-6-1 = '5'
              MOVE MOVEIN-6-1 TO MOVEOUT-6-1  
              MOVE MOVEIN-6-2 TO MOVEOUT-6-2  
              MOVE MOVEIN-6-3 TO MOVEOUT-6-3  
              MOVE MOVEIN-6-4 TO MOVEOUT-6-4  
              MOVE '-' TO CONST-6-1 
              MOVE '5' TO CONST-6-2 
              MOVE 'EUR' TO CONST-6-3 
              ADD 1 TO NB-REC-CASE-6 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-7.  
           IF CASE-7-1 = '6'
              MOVE MOVEIN-7-1 TO MOVEOUT-7-1  
              MOVE MOVEIN-7-2 TO MOVEOUT-7-2  
              MOVE MOVEIN-7-3 TO MOVEOUT-7-3  
              MOVE MOVEIN-7-4 TO MOVEOUT-7-4  
              MOVE '-' TO CONST-7-1 
              MOVE '6' TO CONST-7-2 
              MOVE 'EUR' TO CONST-7-3 
              ADD 1 TO NB-REC-CASE-7 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-8.  
           IF CASE-8-1 = '7'
              MOVE MOVEIN-8-1 TO MOVEOUT-8-1  
              MOVE MOVEIN-8-2 TO MOVEOUT-8-2  
              MOVE MOVEIN-8-3 TO MOVEOUT-8-3  
              MOVE MOVEIN-8-4 TO MOVEOUT-8-4  
              MOVE '-' TO CONST-8-1 
              MOVE '7' TO CONST-8-2 
              MOVE 'EUR' TO CONST-8-3 
              ADD 1 TO NB-REC-CASE-8 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-9.  
           IF CASE-9-1 = '8'
              MOVE MOVEIN-9-1 TO MOVEOUT-9-1  
              MOVE MOVEIN-9-2 TO MOVEOUT-9-2  
              MOVE MOVEIN-9-3 TO MOVEOUT-9-3  
              MOVE MOVEIN-9-4 TO MOVEOUT-9-4  
              MOVE '-' TO CONST-9-1 
              MOVE '8' TO CONST-9-2 
              MOVE 'EUR' TO CONST-9-3 
              ADD 1 TO NB-REC-CASE-9 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-10.  
           IF CASE-10-1 = '9'
              MOVE MOVEIN-10-1 TO MOVEOUT-10-1  
              MOVE MOVEIN-10-2 TO MOVEOUT-10-2  
              MOVE MOVEIN-10-3 TO MOVEOUT-10-3  
              MOVE MOVEIN-10-4 TO MOVEOUT-10-4  
              MOVE '-' TO CONST-10-1 
              MOVE '9' TO CONST-10-2 
              MOVE 'EUR' TO CONST-10-3 
              ADD 1 TO NB-REC-CASE-10 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-11.  
           IF CASE-11-1 = 'A'
              MOVE MOVEIN-11-1 TO MOVEOUT-11-1  
              MOVE MOVEIN-11-2 TO MOVEOUT-11-2  
              MOVE MOVEIN-11-3 TO MOVEOUT-11-3  
              MOVE MOVEIN-11-4 TO MOVEOUT-11-4  
              MOVE '-' TO CONST-11-1 
              MOVE '1' TO CONST-11-2 
              MOVE 'EUR' TO CONST-11-3 
              ADD 1 TO NB-REC-CASE-11 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-12.  
           IF CASE-12-1 = 'B'
              MOVE MOVEIN-12-1 TO MOVEOUT-12-1  
              MOVE MOVEIN-12-2 TO MOVEOUT-12-2  
              MOVE MOVEIN-12-3 TO MOVEOUT-12-3  
              MOVE MOVEIN-12-4 TO MOVEOUT-12-4  
              MOVE '-' TO CONST-12-1 
              MOVE '2' TO CONST-12-2 
              MOVE 'EUR' TO CONST-12-3 
              ADD 1 TO NB-REC-CASE-12 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-13.  
           IF CASE-13-1 = 'C'
              MOVE MOVEIN-13-1 TO MOVEOUT-13-1  
              MOVE MOVEIN-13-2 TO MOVEOUT-13-2  
              MOVE MOVEIN-13-3 TO MOVEOUT-13-3  
              MOVE MOVEIN-13-4 TO MOVEOUT-13-4  
              MOVE '-' TO CONST-13-1 
              MOVE '3' TO CONST-13-2 
              MOVE 'EUR' TO CONST-13-3 
              ADD 1 TO NB-REC-CASE-13 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-14.  
           IF CASE-14-1 = 'D'
              MOVE MOVEIN-14-1 TO MOVEOUT-14-1  
              MOVE MOVEIN-14-2 TO MOVEOUT-14-2  
              MOVE MOVEIN-14-3 TO MOVEOUT-14-3  
              MOVE MOVEIN-14-4 TO MOVEOUT-14-4  
              MOVE '-' TO CONST-14-1 
              MOVE '4' TO CONST-14-2 
              MOVE 'EUR' TO CONST-14-3 
              ADD 1 TO NB-REC-CASE-14 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-15.  
           IF CASE-15-1 = 'E'
              MOVE MOVEIN-15-1 TO MOVEOUT-15-1  
              MOVE MOVEIN-15-2 TO MOVEOUT-15-2  
              MOVE MOVEIN-15-3 TO MOVEOUT-15-3  
              MOVE MOVEIN-15-4 TO MOVEOUT-15-4  
              MOVE '-' TO CONST-15-1 
              MOVE '5' TO CONST-15-2 
              MOVE 'EUR' TO CONST-15-3 
              ADD 1 TO NB-REC-CASE-15 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-16.  
           IF CASE-16-1 = 'F'
              MOVE MOVEIN-16-1 TO MOVEOUT-16-1  
              MOVE MOVEIN-16-2 TO MOVEOUT-16-2  
              MOVE MOVEIN-16-3 TO MOVEOUT-16-3  
              MOVE MOVEIN-16-4 TO MOVEOUT-16-4  
              MOVE '-' TO CONST-16-1 
              MOVE '6' TO CONST-16-2 
              MOVE 'EUR' TO CONST-16-3 
              ADD 1 TO NB-REC-CASE-16 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-17.  
           IF CASE-17-1 = 'G'
              MOVE MOVEIN-17-1 TO MOVEOUT-17-1  
              MOVE MOVEIN-17-2 TO MOVEOUT-17-2  
              MOVE MOVEIN-17-3 TO MOVEOUT-17-3  
              MOVE MOVEIN-17-4 TO MOVEOUT-17-4  
              MOVE '-' TO CONST-17-1 
              MOVE '7' TO CONST-17-2 
              MOVE 'EUR' TO CONST-17-3 
              ADD 1 TO NB-REC-CASE-17 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-18.  
           IF CASE-18-1 = 'H'
              MOVE MOVEIN-18-1 TO MOVEOUT-18-1  
              MOVE MOVEIN-18-2 TO MOVEOUT-18-2  
              MOVE MOVEIN-18-3 TO MOVEOUT-18-3  
              MOVE MOVEIN-18-4 TO MOVEOUT-18-4  
              MOVE '-' TO CONST-18-1 
              MOVE '8' TO CONST-18-2 
              MOVE 'EUR' TO CONST-18-3 
              ADD 1 TO NB-REC-CASE-18 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-19.  
           IF CASE-19-1 = 'I'
              MOVE MOVEIN-19-1 TO MOVEOUT-19-1  
              MOVE MOVEIN-19-2 TO MOVEOUT-19-2  
              MOVE MOVEIN-19-3 TO MOVEOUT-19-3  
              MOVE MOVEIN-19-4 TO MOVEOUT-19-4  
              MOVE '-' TO CONST-19-1 
              MOVE '9' TO CONST-19-2 
              MOVE 'EUR' TO CONST-19-3 
              ADD 1 TO NB-REC-CASE-19 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-20.  
           IF CASE-20-1 = '?'
              MOVE MOVEIN-20-1 TO MOVEOUT-20-1  
              MOVE MOVEIN-20-2 TO MOVEOUT-20-2  
              MOVE MOVEIN-20-3 TO MOVEOUT-20-3  
              MOVE MOVEIN-20-4 TO MOVEOUT-20-4  
              MOVE '-' TO CONST-20-1 
              MOVE '0' TO CONST-20-2 
              MOVE 'EUR' TO CONST-20-3 
              ADD 1 TO NB-REC-CASE-20 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-21.  
           IF CASE-21-1 = 'é'
              MOVE MOVEIN-21-1 TO MOVEOUT-21-1  
              MOVE MOVEIN-21-2 TO MOVEOUT-21-2  
              MOVE MOVEIN-21-3 TO MOVEOUT-21-3  
              MOVE MOVEIN-21-4 TO MOVEOUT-21-4  
              MOVE '-' TO CONST-21-1 
              MOVE '0' TO CONST-21-2 
              MOVE 'EUR' TO CONST-21-3 
              ADD 1 TO NB-REC-CASE-21 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-22.  
           IF CASE-22-1 = '{'
              MOVE MOVEIN-22-1 TO MOVEOUT-22-1  
              MOVE MOVEIN-22-2 TO MOVEOUT-22-2  
              MOVE MOVEIN-22-3 TO MOVEOUT-22-3  
              MOVE MOVEIN-22-4 TO MOVEOUT-22-4  
              MOVE '-' TO CONST-22-1 
              MOVE '0' TO CONST-22-2 
              MOVE 'EUR' TO CONST-22-3 
              ADD 1 TO NB-REC-CASE-22 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-23.  
           IF CASE-23-1 = 'J'
              MOVE MOVEIN-23-1 TO MOVEOUT-23-1  
              MOVE MOVEIN-23-2 TO MOVEOUT-23-2  
              MOVE MOVEIN-23-3 TO MOVEOUT-23-3  
              MOVE MOVEIN-23-4 TO MOVEOUT-23-4  
              MOVE '+' TO CONST-23-1 
              MOVE '1' TO CONST-23-2 
              MOVE 'EUR' TO CONST-23-3 
              ADD 1 TO NB-REC-CASE-23 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-24.  
           IF CASE-24-1 = 'K'
              MOVE MOVEIN-24-1 TO MOVEOUT-24-1  
              MOVE MOVEIN-24-2 TO MOVEOUT-24-2  
              MOVE MOVEIN-24-3 TO MOVEOUT-24-3  
              MOVE MOVEIN-24-4 TO MOVEOUT-24-4  
              MOVE '+' TO CONST-24-1 
              MOVE '2' TO CONST-24-2 
              MOVE 'EUR' TO CONST-24-3 
              ADD 1 TO NB-REC-CASE-24 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-25.  
           IF CASE-25-1 = 'L'
              MOVE MOVEIN-25-1 TO MOVEOUT-25-1  
              MOVE MOVEIN-25-2 TO MOVEOUT-25-2  
              MOVE MOVEIN-25-3 TO MOVEOUT-25-3  
              MOVE MOVEIN-25-4 TO MOVEOUT-25-4  
              MOVE '+' TO CONST-25-1 
              MOVE '3' TO CONST-25-2 
              MOVE 'EUR' TO CONST-25-3 
              ADD 1 TO NB-REC-CASE-25 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-26.  
           IF CASE-26-1 = 'M'
              MOVE MOVEIN-26-1 TO MOVEOUT-26-1  
              MOVE MOVEIN-26-2 TO MOVEOUT-26-2  
              MOVE MOVEIN-26-3 TO MOVEOUT-26-3  
              MOVE MOVEIN-26-4 TO MOVEOUT-26-4  
              MOVE '+' TO CONST-26-1 
              MOVE '4' TO CONST-26-2 
              MOVE 'EUR' TO CONST-26-3 
              ADD 1 TO NB-REC-CASE-26 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-27.  
           IF CASE-27-1 = 'N'
              MOVE MOVEIN-27-1 TO MOVEOUT-27-1  
              MOVE MOVEIN-27-2 TO MOVEOUT-27-2  
              MOVE MOVEIN-27-3 TO MOVEOUT-27-3  
              MOVE MOVEIN-27-4 TO MOVEOUT-27-4  
              MOVE '+' TO CONST-27-1 
              MOVE '5' TO CONST-27-2 
              MOVE 'EUR' TO CONST-27-3 
              ADD 1 TO NB-REC-CASE-27 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-28.  
           IF CASE-28-1 = 'O'
              MOVE MOVEIN-28-1 TO MOVEOUT-28-1  
              MOVE MOVEIN-28-2 TO MOVEOUT-28-2  
              MOVE MOVEIN-28-3 TO MOVEOUT-28-3  
              MOVE MOVEIN-28-4 TO MOVEOUT-28-4  
              MOVE '+' TO CONST-28-1 
              MOVE '6' TO CONST-28-2 
              MOVE 'EUR' TO CONST-28-3 
              ADD 1 TO NB-REC-CASE-28 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-29.  
           IF CASE-29-1 = 'P'
              MOVE MOVEIN-29-1 TO MOVEOUT-29-1  
              MOVE MOVEIN-29-2 TO MOVEOUT-29-2  
              MOVE MOVEIN-29-3 TO MOVEOUT-29-3  
              MOVE MOVEIN-29-4 TO MOVEOUT-29-4  
              MOVE '+' TO CONST-29-1 
              MOVE '7' TO CONST-29-2 
              MOVE 'EUR' TO CONST-29-3 
              ADD 1 TO NB-REC-CASE-29 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-30.  
           IF CASE-30-1 = 'Q'
              MOVE MOVEIN-30-1 TO MOVEOUT-30-1  
              MOVE MOVEIN-30-2 TO MOVEOUT-30-2  
              MOVE MOVEIN-30-3 TO MOVEOUT-30-3  
              MOVE MOVEIN-30-4 TO MOVEOUT-30-4  
              MOVE '+' TO CONST-30-1 
              MOVE '8' TO CONST-30-2 
              MOVE 'EUR' TO CONST-30-3 
              ADD 1 TO NB-REC-CASE-30 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-31.  
           IF CASE-31-1 = 'R'
              MOVE MOVEIN-31-1 TO MOVEOUT-31-1  
              MOVE MOVEIN-31-2 TO MOVEOUT-31-2  
              MOVE MOVEIN-31-3 TO MOVEOUT-31-3  
              MOVE MOVEIN-31-4 TO MOVEOUT-31-4  
              MOVE '+' TO CONST-31-1 
              MOVE '9' TO CONST-31-2 
              MOVE 'EUR' TO CONST-31-3 
              ADD 1 TO NB-REC-CASE-31 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-32.  
           IF CASE-32-1 = '!'
              MOVE MOVEIN-32-1 TO MOVEOUT-32-1  
              MOVE MOVEIN-32-2 TO MOVEOUT-32-2  
              MOVE MOVEIN-32-3 TO MOVEOUT-32-3  
              MOVE MOVEIN-32-4 TO MOVEOUT-32-4  
              MOVE '+' TO CONST-32-1 
              MOVE '0' TO CONST-32-2 
              MOVE 'EUR' TO CONST-32-3 
              ADD 1 TO NB-REC-CASE-32 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-33.  
           IF CASE-33-1 = 'è'
              MOVE MOVEIN-33-1 TO MOVEOUT-33-1  
              MOVE MOVEIN-33-2 TO MOVEOUT-33-2  
              MOVE MOVEIN-33-3 TO MOVEOUT-33-3  
              MOVE MOVEIN-33-4 TO MOVEOUT-33-4  
              MOVE '+' TO CONST-33-1 
              MOVE '0' TO CONST-33-2 
              MOVE 'EUR' TO CONST-33-3 
              ADD 1 TO NB-REC-CASE-33 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-34.  
           IF CASE-34-1 = '}'
              MOVE MOVEIN-34-1 TO MOVEOUT-34-1  
              MOVE MOVEIN-34-2 TO MOVEOUT-34-2  
              MOVE MOVEIN-34-3 TO MOVEOUT-34-3  
              MOVE MOVEIN-34-4 TO MOVEOUT-34-4  
              MOVE '+' TO CONST-34-1 
              MOVE '0' TO CONST-34-2 
              MOVE 'EUR' TO CONST-34-3 
              ADD 1 TO NB-REC-CASE-34 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       OTHER.   
              MOVE MOVEIN-35-1 TO MOVEOUT-35-1  
              MOVE MOVEIN-35-2 TO MOVEOUT-35-2  
              MOVE 'EUR' TO CONST-35-1 
              ADD 1 TO NB-REC-OTHER 
              PERFORM WRITE-REC-OUTPUT THRU WRITE-REC-OUTPUT-EXIT   
              GO TO TRT.
       CASE-NON-PREVU.  
      *    pas d'ecriture sur le fichier de sortie .....
           GO TO TRT.   
       FIN-TRT. 
           DISPLAY 'NB ENREGISTREMENTS LUS    = ' NB-REC-LU 
                                UPON PRINTER.   
           DISPLAY 'NB ENREGISTREMENTS ECRITS = ' NB-REC-ECRIT  
                                UPON PRINTER.   
           SUBTRACT NB-REC-ECRIT FROM NB-REC-LU GIVING NB-REC-NONECRIT. 
           IF NB-REC-NONECRIT > 0   
              DISPLAY '*******************************' UPON PRINTER
              DISPLAY '*   attention                 *' UPON PRINTER
              DISPLAY '*   certains records ne       *' UPon printer
              DISPLAY '*   respectent aucun case     *' UPON PRInter
              DISPLAY '*   et ne figurent donc pas   *' UPON PRInter
              DISPLAY '*   sur le fichier output     *' UPON PRInter
              DISPLAY '*******************************' UPON PRINTER.   
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 1 = '   
                   NB-REC-CASE-1   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 2 = '   
                   NB-REC-CASE-2   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 3 = '   
                   NB-REC-CASE-3   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 4 = '   
                   NB-REC-CASE-4   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 5 = '   
                   NB-REC-CASE-5   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 6 = '   
                   NB-REC-CASE-6   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 7 = '   
                   NB-REC-CASE-7   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 8 = '   
                   NB-REC-CASE-8   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 9 = '   
                   NB-REC-CASE-9   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 10 = '   
                   NB-REC-CASE-10   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 11 = '   
                   NB-REC-CASE-11   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 12 = '   
                   NB-REC-CASE-12   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 13 = '   
                   NB-REC-CASE-13   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 14 = '   
                   NB-REC-CASE-14   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 15 = '   
                   NB-REC-CASE-15   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 16 = '   
                   NB-REC-CASE-16   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 17 = '   
                   NB-REC-CASE-17   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 18 = '   
                   NB-REC-CASE-18   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 19 = '   
                   NB-REC-CASE-19   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 20 = '   
                   NB-REC-CASE-20   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 21 = '   
                   NB-REC-CASE-21   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 22 = '   
                   NB-REC-CASE-22   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 23 = '   
                   NB-REC-CASE-23   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 24 = '   
                   NB-REC-CASE-24   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 25 = '   
                   NB-REC-CASE-25   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 26 = '   
                   NB-REC-CASE-26   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 27 = '   
                   NB-REC-CASE-27   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 28 = '   
                   NB-REC-CASE-28   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 29 = '   
                   NB-REC-CASE-29   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 30 = '   
                   NB-REC-CASE-30   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 31 = '   
                   NB-REC-CASE-31   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 32 = '   
                   NB-REC-CASE-32   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 33 = '   
                   NB-REC-CASE-33   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS CONDITION NO 34 = '   
                   NB-REC-CASE-34   UPON PRINTER.
           DISPLAY 'NB ENREGISTREMENTS OTHER = ' NB-REC-OTHER   
                                                UPON PRINTER.   
           display ' ' upon printer.
           display ' ' upon printer.
           display ' ' upon printer.
           display ' ' upon printer.
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22A) 0X --> ;X    = '
                   NB-REC-TRANSFORME-22A-200X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22A) 1X --> _X    = '
                   NB-REC-TRANSFORME-22A-201X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22A) 2X --> |X    = '
                   NB-REC-TRANSFORME-22A-202X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22A) 3X --> ~X    = '
                   NB-REC-TRANSFORME-22A-203X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22B) ;X --> 0X    = '
                   NB-REC-TRANSFORME-22B-200X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22B) _X --> 1X    = '
                   NB-REC-TRANSFORME-22B-201X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22B) |X --> 2X    = '
                   NB-REC-TRANSFORME-22B-202X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (22B) ~X --> 3X    = '
                   NB-REC-TRANSFORME-22B-203X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66A) 0X --> ;X    = '
                   NB-REC-TRANSFORME-66A-200X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66A) 1X --> _X    = '
                   NB-REC-TRANSFORME-66A-201X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66A) 2X --> |X    = '
                   NB-REC-TRANSFORME-66A-202X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66A) 3X --> ~X    = '
                   NB-REC-TRANSFORME-66A-203X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66B) ;X --> 0X    = '
                   NB-REC-TRANSFORME-66B-200X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66B) _X --> 1X    = '
                   NB-REC-TRANSFORME-66B-201X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66B) |X --> 2X    = '
                   NB-REC-TRANSFORME-66B-202X UPON PRINTER. 
           DISPLAY 'NB RECORDS AYANT SUBI TRANSFO (66B) ~X --> 3X    = '
                   NB-REC-TRANSFORME-66B-203X UPON PRINTER. 
           CLOSE FILEIN FILEOUT.
           STOP RUN.
       TRANSFO-DATE-4-2.
      ******************
           MOVE WS-A4-AA TO WS-A2.  
           IF ((WS-A4 > '1999') AND (WS-A4 < '2010'))   
              MOVE ';' TO WS-A2-A1. 
           IF ((WS-A4 > '2009') AND (WS-A4 < '2020'))   
              MOVE '_' TO WS-A2-A1. 
           IF ((WS-A4 > '2019') AND (WS-A4 < '2030'))   
              MOVE '|' TO WS-A2-A1. 
           IF ((WS-A4 > '2029') AND (WS-A4 < '2040'))   
              MOVE '~' TO WS-A2-A1. 
       TRANSFO-DATE-4-2-EXIT.   
      ******************
           EXIT.
       TRANSFO-DATE-2-4.
      ******************
           IF WS-A2 = '00'  
              MOVE '0000' TO WS-A4  
              GO TO TRANSFO-DATE-2-4-EXIT.  
           IF WS-A2 = '  '  
              MOVE '    ' TO WS-A4  
              GO TO TRANSFO-DATE-2-4-EXIT.  
           IF WS-A2-A1 = ';'
              MOVE '20' TO WS-A4-SS 
              MOVE '0'  TO WS-A4-A1 
              MOVE WS-A2-A2  TO WS-A4-A2
              GO TO TRANSFO-DATE-2-4-EXIT.  
           IF WS-A2-A1 = '_'
              MOVE '20' TO WS-A4-SS 
              MOVE '1'  TO WS-A4-A1 
              MOVE WS-A2-A2  TO WS-A4-A2
              GO TO TRANSFO-DATE-2-4-EXIT.  
           IF WS-A2-A1 = '|'
              MOVE '20' TO WS-A4-SS 
              MOVE '2'  TO WS-A4-A1 
              MOVE WS-A2-A2  TO WS-A4-A2
              GO TO TRANSFO-DATE-2-4-EXIT.  
           IF WS-A2-A1 = '~'
              MOVE '20' TO WS-A4-SS 
              MOVE '3'  TO WS-A4-A1 
              MOVE WS-A2-A2  TO WS-A4-A2
              GO TO TRANSFO-DATE-2-4-EXIT.  
           MOVE '19'     TO WS-A4-SS.   
           MOVE WS-A2    TO WS-A4-AA.   
           GO TO TRANSFO-DATE-2-4-EXIT. 
       TRANSFO-DATE-2-4-EXIT.   
      ******************
           EXIT.
       TRANSFO-DATE-22A.
      ******************
           IF WS-A2-A1 = '0'
              MOVE ';'      TO WS-A2-A1 
              MOVE 'Y' TO WS-RECORD-TRANSFORME-22A-200X 
              GO TO TRANSFO-DATE-22A-EXIT.  
           IF WS-A2-A1 = '1'
              MOVE '_'      TO WS-A2-A1 
              MOVE 'Y' TO WS-RECORD-TRANSFORME-22A-201X 
              GO TO TRANSFO-DATE-22A-EXIT.  
           IF WS-A2-A1 = '2'
              MOVE '|'      TO WS-A2-A1 
              MOVE 'Y' TO WS-RECORD-TRANSFORME-22A-202X 
              GO TO TRANSFO-DATE-22A-EXIT.  
           IF WS-A2-A1 = '3'
              MOVE '~'      TO WS-A2-A1 
              MOVE 'Y' TO WS-RECORD-TRANSFORME-22A-203X 
              GO TO TRANSFO-DATE-22A-EXIT.  
       TRANSFO-DATE-22A-EXIT.   
      ******************
           EXIT.
       TRANSFO-DATE-66A.
      ******************
           IF WS-A6 NOT NUMERIC 
              GO TO TRANSFO-DATE-66A-EXIT.  
           IF ((WS-A6-MM > '15') or (WS-A6-MM = '00'))  
              GO TO TRANSFO-DATE-66A-EXIT.  
           IF ((WS-A6-JJ > '35') or (WS-A6-JJ = '00'))  
              GO TO TRANSFO-DATE-66A-EXIT.  
           IF WS-A6-Y1 = '0'
              MOVE ';'      TO WS-A6-Y1 
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66A-200X 
              GO TO TRANSFO-DATE-66A-EXIT.  
           IF WS-A6-Y1 = '1'
              MOVE '_'      TO WS-A6-Y1 
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66A-201X 
              GO TO TRANSFO-DATE-66A-EXIT.  
           IF WS-A6-Y1 = '2'
              MOVE '|'      TO WS-A6-Y1 
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66A-202X 
              GO TO TRANSFO-DATE-66A-EXIT.  
           IF WS-A6-Y1 = '3'
              MOVE '~'      TO WS-A6-Y1 
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66A-203X 
              GO TO TRANSFO-DATE-66A-EXIT.  
       TRANSFO-DATE-66A-EXIT.   
      ******************
           EXIT.
       TRANSFO-DATE-66B.
      ******************
           IF WS-A6-Y1 = ';'
              MOVE '0'      TO WS-A6-Y1 
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66B-200X 
              GO TO TRANSFO-DATE-66B-EXIT.  
           IF WS-A6-Y1 = '_'
              MOVE '1'      TO WS-A6-Y1 
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66B-201X 
              GO TO TRANSFO-DATE-66B-EXIT.  
           IF WS-A6-Y1 = '|'
              MOVE '2'      TO WS-A6-Y1 
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66B-202X 
              GO TO TRANSFO-DATE-66B-EXIT.  
           IF WS-A6-Y1 = '~'
              MOVE '3'      TO WS-A6-Y1 
              MOVE 'Y' TO WS-RECORD-TRANSFORME-66B-203X 
              GO TO TRANSFO-DATE-66B-EXIT.  
       TRANSFO-DATE-66B-EXIT.   
      ******************
           EXIT.
       TRANSFO-DATE-68. 
      ******************
           MOVE WS-A6 TO WS-A8-YYMMJJ.  
           MOVE '19'  to WS-A8-YY.  
           IF WS-A6 = '      '  
              MOVE '        ' to WS-A8  
              GO TO TRANSFO-DATE-68-EXIT.   
           IF WS-A6 = '000000'  
              MOVE '00000000' to WS-A8  
              GO TO TRANSFO-DATE-68-EXIT.   
           IF WS-A6-Y1 = ';'
              MOVE '200'    TO WS-A8-YYY
              MOVE WS-A6-Y2 TO WS-A8-Y4 
              MOVE WS-A6-MM TO WS-A8-MM 
              MOVE WS-A6-JJ TO WS-A8-JJ 
              GO TO TRANSFO-DATE-68-EXIT.   
           IF WS-A6-Y1 = '_'
              MOVE '201'    TO WS-A8-YYY
              MOVE WS-A6-Y2 TO WS-A8-Y4 
              MOVE WS-A6-MM TO WS-A8-MM 
              MOVE WS-A6-JJ TO WS-A8-JJ 
              GO TO TRANSFO-DATE-68-EXIT.   
           IF WS-A6-Y1 = '|'
              MOVE '202'    TO WS-A8-YYY
              MOVE WS-A6-Y2 TO WS-A8-Y4 
              MOVE WS-A6-MM TO WS-A8-MM 
              MOVE WS-A6-JJ TO WS-A8-JJ 
              GO TO TRANSFO-DATE-68-EXIT.   
           IF WS-A6-Y1 = '~'
              MOVE '203'    TO WS-A8-YYY
              MOVE WS-A6-Y2 TO WS-A8-Y4 
              MOVE WS-A6-MM TO WS-A8-MM 
              MOVE WS-A6-JJ TO WS-A8-JJ 
              GO TO TRANSFO-DATE-68-EXIT.   
       TRANSFO-DATE-68-EXIT.
      ******************
           EXIT.
       TRANSFO-DATE-86. 
      ******************
           MOVE WS-A8-YYMMJJ TO WS-A6.  
           IF WS-A8 NOT NUMERIC 
              GO TO TRANSFO-DATE-86-EXIT.   
           IF ((WS-A8-MM > '15') or (WS-A8-MM = '00'))  
              GO TO TRANSFO-DATE-86-EXIT.   
           IF ((WS-A8-JJ > '35') or (WS-A8-JJ = '00'))  
              GO TO TRANSFO-DATE-86-EXIT.   
           IF WS-A8-YYY = '200' 
              MOVE ';'      TO WS-A6-Y1 
              MOVE WS-A8-Y4 TO WS-A6-Y2 
              MOVE WS-A8-MM TO WS-A6-MM 
              MOVE WS-A8-JJ TO WS-A6-JJ 
              GO TO TRANSFO-DATE-86-EXIT.   
           IF WS-A8-YYY = '201' 
              MOVE '_'      TO WS-A6-Y1 
              MOVE WS-A8-Y4 TO WS-A6-Y2 
              MOVE WS-A8-MM TO WS-A6-MM 
              MOVE WS-A8-JJ TO WS-A6-JJ 
              GO TO TRANSFO-DATE-86-EXIT.   
           IF WS-A8-YYY = '202' 
              MOVE '|'      TO WS-A6-Y1 
              MOVE WS-A8-Y4 TO WS-A6-Y2 
              MOVE WS-A8-MM TO WS-A6-MM 
              MOVE WS-A8-JJ TO WS-A6-JJ 
              GO TO TRANSFO-DATE-86-EXIT.   
           IF WS-A8-YYY = '203' 
              MOVE '~'      TO WS-A6-Y1 
              MOVE WS-A8-Y4 TO WS-A6-Y2 
              MOVE WS-A8-MM TO WS-A6-MM 
              MOVE WS-A8-JJ TO WS-A6-JJ 
              GO TO TRANSFO-DATE-86-EXIT.   
           IF WS-A8-SS = '19'   
              MOVE WS-A8-YYMMJJ   TO WS-A6  
              GO TO TRANSFO-DATE-86-EXIT.   
       TRANSFO-DATE-86-EXIT.
      ******************
           EXIT.
       TRANSFO-DATE-22B.
      ******************
           IF WS-A2-A1 = ';'
              MOVE '0'      TO WS-A2-A1 
              move 'Y' TO WS-RECORD-TRANSFORME-22B-200X 
              GO TO TRANSFO-DATE-22B-EXIT.  
           IF WS-A2-A1 = '_'
              MOVE '1'      TO WS-A2-A1 
              move 'Y' TO WS-RECORD-TRANSFORME-22B-201X 
              GO TO TRANSFO-DATE-22B-EXIT.  
           IF WS-A2-A1 = '|'
              MOVE '2'      TO WS-A2-A1 
              move 'Y' TO WS-RECORD-TRANSFORME-22B-202X 
              GO TO TRANSFO-DATE-22B-EXIT.  
           IF WS-A2-A1 = '~'
              MOVE '3'      TO WS-A2-A1 
              move 'Y' TO WS-RECORD-TRANSFORME-22B-203X 
              GO TO TRANSFO-DATE-22B-EXIT.  
       TRANSFO-DATE-22B-EXIT.   
      ******************
           EXIT.
       WRITE-REC-OUTPUT.
      *******************   
           ADD 1 TO NB-REC-ECRIT.   
           IF WS-RECORD-TRANSFORME-22A-200X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-22A-200X.  
           IF WS-RECORD-TRANSFORME-22A-201X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-22A-201X.  
           IF WS-RECORD-TRANSFORME-22A-202X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-22A-202X.  
           IF WS-RECORD-TRANSFORME-22A-203X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-22A-203X.  
           IF WS-RECORD-TRANSFORME-22B-200X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-22B-200X.  
           IF WS-RECORD-TRANSFORME-22B-201X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-22B-201X.  
           IF WS-RECORD-TRANSFORME-22B-202X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-22B-202X.  
           IF WS-RECORD-TRANSFORME-22B-203X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-22B-203X.  
           IF WS-RECORD-TRANSFORME-66A-200X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-66A-200X.  
           IF WS-RECORD-TRANSFORME-66A-201X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-66A-201X.  
           IF WS-RECORD-TRANSFORME-66A-202X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-66A-202X.  
           IF WS-RECORD-TRANSFORME-66A-203X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-66A-203X.  
           IF WS-RECORD-TRANSFORME-66B-200X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-66B-200X.  
           IF WS-RECORD-TRANSFORME-66B-201X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-66B-201X.  
           IF WS-RECORD-TRANSFORME-66B-202X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-66B-202X.  
           IF WS-RECORD-TRANSFORME-66B-203X = 'Y'   
              ADD 1 TO NB-REC-TRANSFORME-66B-203X.  
           WRITE FSOUTPUT FROM ENR-OUTPUT.  
       WRITE-REC-OUTPUT-EXIT.   
      ************************  
           EXIT.
