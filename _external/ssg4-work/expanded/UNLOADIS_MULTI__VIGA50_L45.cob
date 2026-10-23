       IDENTIFICATION DIVISION. 
       PROGRAM-ID. UNLOADIS.
       AUTHOR.     H A N S E
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.   
       SOURCE-COMPUTER. UNISYS-1100.
       OBJECT-COMPUTER. UNISYS-1100.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT BDE  ASSIGN TO
               DISC OUTVIGA50. 
           SELECT DISQ ASSIGN TO DISC  F006GRS
           RESERVE 20 AREAS 
           ORGANIZATION IS INDEXED  
           ACCESS  MODE IS SEQUENTIAL   
           RECORD KEY IS CLEF   
       DATA DIVISION.   
       FILE SECTION.
       FD  BDE  
           LABEL RECORD STANDARD
             BLOCK CONTAINS 10   RECORDS
           RECORD CONTAINS 200 CHARACTERS
           DATA RECORD IS  ZBDE.
       01  ZBDE    PIC  X(200).  
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
       77  CTR                PIC 9(10) COMP VALUE 0.   
       77  MAXBDE             PIC 9(10) COMP VALUE 99999999.
       01  WREC.
           02 FILLER          PIC X(200). 
       PROCEDURE DIVISION.  
       DEBUT.   
           OPEN  OUTPUT BDE.
           OPEN  INPUT  DISQ.   
           MOVE LOW-VALUES TO CLEF. 
       LECT.
           READ  DISQ  INTO  WREC  AT END GO TO FINB.   
           ADD  1  TO  CTR. 
           WRITE ZBDE FROM WREC.
           MOVE SPACES TO WREC. 
           IF CTR = MAXBDE   GO TO FINB.
           GO TO LECT.  
       FINB.
           DISPLAY 'NB.RECORDS ECRITS : '  CTR  UPON PRINTER.   
           CLOSE  DISQ. 
           CLOSE  BDE.  
           STOP RUN.
