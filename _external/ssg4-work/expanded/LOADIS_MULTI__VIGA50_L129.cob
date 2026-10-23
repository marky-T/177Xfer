       IDENTIFICATION DIVISION. 
       PROGRAM-ID. LOADIS.  
       AUTHOR.     H A N S E
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNISYS-1100.
       OBJECT-COMPUTER. UNISYS-1100.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT BDE  ASSIGN TO
               DISC INVIGA50.  
           SELECT DISQ ASSIGN TO DISC  F006GRS   
           RESERVE 20 AREAS 
           ORGANIZATION IS INDEXED  
           ACCESS  MODE IS SEQUENTIAL   
           FILE STATUS  IS FS-DISQ  
           RECORD KEY IS CLEF   
       DATA DIVISION.   
       FILE SECTION.
       FD  BDE  
           LABEL RECORD STANDARD
           BLOCK CONTAINS 10   RECORDS   
           RECORD CONTAINS 200 CHARACTERS 
           DATA RECORD IS  Z1.  
       01  Z1      PIC  X(200).   
       FD  DISQ 
           LABEL RECORD STANDARD
           BLOCK CONTAINS 10 RECORDS
           RECORD  CONTAINS 200 CHARACTERS   
           DATA RECORD IS ZDISQ CLEFA CLEFB CLEFC CLEFD.
       01  ZDISQ   PIC  X(200).  
       01  CLEFA.   
           02 FILLER PIC X(164).  
           02 CLEF   PIC X(26).  
           02 FILLER PIC X(10).  
       01  CLEFB.   
           02 FILLER PIC X(200). 
       01  CLEFC.   
           02 FILLER PIC X(200). 
       01  CLEFD.   
           02 FILLER PIC X(200). 
       WORKING-STORAGE SECTION. 
       77  CTR                PIC  9(10)  COMP  VALUE 0.
       01  FS-DISQ. 
           02 FS1-DISQ        PIC X.
           02 FS2-DISQ        PIC 99 COMP.  
       01  WREC.
           02 FILLER          PIC  X(200).   
       01  WREC1 REDEFINES  WREC.   
           02 FILLER          PIC X(164). 
           02 KEYA            PIC X(26). 
           02 FILLER          PIC X(10). 
       01  WREC2 REDEFINES WREC.
           02 FILLER          PIC X(200).
       01  WREC3 REDEFINES WREC.
           02 FILLER          PIC X(200).
       01  WREC4 REDEFINES WREC.
           02 FILLER          PIC X(200).
       PROCEDURE DIVISION.  
      ********************  
      * 
       DECLARATIVES.
       ROLLBACK1 SECTION.   
           USE AFTER STANDARD ERROR PROCEDURE ON DISQ.  
       FILE1-ERROR. 
           DISPLAY 'FILE STATUS KEY 1 : ' FS1-DISQ UPON PRINTER.
           DISPLAY '            KEY 2 : ' FS2-DISQ UPON PRINTER.
           GO TO ERRDISQ.   
       FILE1-ERROR-END. 
           EXIT.
      * 
       END DECLARATIVES.
       MAIN-PGM SECTION.
       DEBUT.   
           OPEN  INPUT   BDE.   
           OPEN  OUTPUT  DISQ.  
       LECT.
           MOVE SPACES TO Z1.   
           READ  BDE   INTO  WREC  AT END GO TO FINB.   
       CONT.
           MOVE KEYA     TO  CLEF.  
           ADD  1  TO  CTR. 
           WRITE ZDISQ FROM WREC INVALID KEY GO TO  ERRDISQ.
           MOVE SPACES TO WREC ZDISQ.   
           GO TO LECT.  
       FINB.
           DISPLAY 'NB.RECORDS ECRITS'  CTR  UPON PRINTER.  
           CLOSE  DISQ. 
           CLOSE  BDE.  
           STOP RUN.
       ERRDISQ. 
           DISPLAY 'IS.ERROR'  CLEF  UPON  PRINTER. 
           ENTER ASM 'ABORT'.   
