#-------------------------------------------------------------------------------
# AMT Sort PowerShell Library
#
# This library provides these functions for sorting:
#
# - Sort-Init
# - Sort-AddInputFile
# - Sort-AddOutputFile
# - Sort-SetKey
# - Sort-Execute
# - Sort-SetEbcdicSortSequence
# - Sort-SetRecordSize
# - Sort-AddAccept
# - Sort-AddSelect
#-------------------------------------------------------------------------------
# BEWARE This library is used by multiple other libraries like the JCL and ECL libraries, function calls from one library may not work in another.
[String]$global:SortVersionDate        = "Amt Sort PS library version: 60.31, date: 2026-04-13"

# Wait for INPUT file(s) behaviour, default = NOT waiting for input files
[Boolean]$global:SortWaitForInputFiles = $False

Add-Type -TypeDefinition @"
  public enum AmtFileRecordEnding {
    Default = 0,
    CrLf    = 1,
    Cr      = 2,
    Lf      = 3,
    None    = 4
  }
"@

[Object]$global:AmtSort              = $Null      # AMT Comscript Sort object
[Object]$global:SortInputFiles       = $Null      # The object containing the list of input files.
[String]$global:SortOutputFile       = ""         # The sort operation's output file.
[Object]$global:SortKeyList          = $Null      # The list of sort key objects.
[Object]$global:SortSequence         = $Null      # Used for different sort sequences.
[String]$global:EbcdicSortSeqUnisys  = ""         # EBCDIC sort sequence (Unisys).
[String]$global:EbcdicSortSeqIbm     = ""         # EBCDIC sort sequence (IBM).

[Int32] $global:SortNumRec           = 0          # The sort operation's NumRec statement.
[Object]$global:SortAcceptList       = $Null      # The sort operation's list of Accept statements.

[Object]$global:SortSelectList       = $Null      # The list of sort select objects.

[Object]$global:SortOutrecList       = $Null      # The list of outrec objects.
[Object]$global:SortInrecList        = $Null      # The list of inrec objects.
[Object]$global:SortInrecIfthenList  = $Null      # The list of INREC IFTHEN blocks.
[Object]$global:SortOutrecIfthenList = $Null      # The list of OUTREC IFTHEN blocks (post-sort).
[Object]$global:SortSumFieldList     = $Null      # The list of sum field objects.

[String]$global:ReadBuff             = ""         # Read buffer.
[String]$global:WriteBuff            = ""         # Write buffer.

[Boolean]$global:SortRecSizeSet      = $False     # 
[Boolean]$global:CopyOption          = $False     # 
[Int32]$global:SortRecSize           = 0          # 
[Int32]$global:SortLinkSize          = 0          # 

[String]$global:DupeOption            = ""         # Dupkey option
[Boolean]$global:NoDups               = $False     # No duplicates, if set to true, only unique records will be kept in the output.

[Boolean]$global:HasHadError         = $False     # True if Sort-Init was successful.
[Object]$global:ObjTaskSort          = $Null  	  # Task object used for the sort.

function Sort-Init {
  <#
    .SYNOPSIS
      Creates and Initialise the AmtSort object
    .PARAMETER ObjTask
      [Object] Task object
  #>

  param (
    [Object]$ObjTask,
    [String]$SortName
  )

  if($Null -ne $ObjTask) {
    $global:ObjTaskSort = $ObjTask
  } else {
    $global:ObjTaskSort = Get-TaskObject -ObjTask $ObjTask
    Check-ClearTaskObject -TaskObj $global:ObjTaskSort
  }

  Write-JobLog -Message ''
  Write-JobLog -Message $global:SortVersionDate
  Display -Message "[Sort-Init] Initializing Sort $SortName"

  $global:AmtSort = $global:Com.CreateSort()     # Create Sort object

  if ($global:Com.ErrorCode -ne 0) {
    Sort-SetError -Message "Failed initializing Sort object, reason: $($global:Com.ErrorDescription) (code=$($global:Com.ErrorCode))"
    return
  }

  $global:SortInputFiles = New-Object 'System.Collections.Generic.List[String]'
  $global:SortKeyList = New-Object 'System.Collections.Generic.List[Object]'

  $global:EbcdicSortSeqUnisys = ' ,[,.,<,(,+,!,&,],$,*,),;,^,-,/,|,,,%,_,>,?,`,:,#,@,'',=,",a-r,~,s-z,{,A-I,},J-R,\\,S-Z,0-9'
  
  # Based on EBCDIC 037 codepage
  $global:EbcdicSortSeqIbm    = ' ,â,ä,à,á,ã,å,.,<,(,+,&,é,ê,ë,è,í,î,ï,ì,!,$,*,),;,^,-,/,Â,Ä,À,Á,Ã,Å,|,,,%,_,>,?,É,Ê,Ë,È,Í,Î,Ï,Ì,`,:,#,@,'',=,",a-r,~,s-z,[,],{,A-I,ô,ö,ò,ó,õ},J-R,\\,S-Z,Ô,Ö,Ò,Ó,Õ,0-9,Û,Ü,Ù,Ú'

  $global:AmtSort.Init()
  $global:AmtSort.SetNumericCoding("EBCDIC")
} #Sort-Init

function Sort-Reset {
  <#
    .SYNOPSIS
      Resets sort variables before next sort can be done
  #>
  $global:SortInputFiles.Clear()
  $global:SortOutputFile = ""
  $global:SortKeyList.Clear()
  $global:SortNumRec = 0
  $global:SortAcceptList = $Null
  $global:SortSelectList = $Null

  $global:SortOutrecList      = $Null
  $global:SortSumFieldList    = $Null
  $global:SortInrecIfthenList = $Null
  $global:SortOutrecIfthenList = $Null
  
  $global:ReadBuff  = ""
  $global:WriteBuff = ""

  $global:SortRecSizeSet = $False
  $global:SortRecSize = 0
  $global:SortLinkSize = 0
  $global:CopyOption = $False

  $global:DupeOption = ""
  $global:NoDups = $False

  $global:HasHadError = $False

  $global:AmtSort.Init()
  $global:AmtSort.SetNumericCoding("EBCDIC")
} #Sort-Reset

function Sort-Init-Reset {
  <#
    .SYNOPSIS
      Inits sort when called the first time, 
      resets sort variables when called a second time
  #>
  if ($Null -eq $global:AmtSort) {
    Sort-Init
  } else {
    Sort-Reset
  }
} #Sort-Init-Reset

function Sort-AddInputFile {
  <#
    .SYNOPSIS
      Adds input file for sorting
    .DESCRIPTION
      ECL equivalent: DISKSORT -> FILEIN= or FILESIN=
      WFL equivalent: FILE IN (TITLE = <title>)
    .PARAMETER Filename
      [String] The (fully qualified) input file to add.
  #>

  param (
    [Parameter(Mandatory=$True)][String]$Filename
  )

  if($global:HasHadError) {
    return
  }

  if (-not (Is-FullyQualifiedFile $Filename)) {
    Sort-SetError -Message "Sort-AddInputFile: Input filename not fully qualified."
    return
  }
  
  Write-JobLog -Message "Sort-AddInputFile: $Filename"
  $global:SortInputFiles.Add($Filename)
} #Sort-AddInputFile

function Sort-AddOutputFile {
  <#
    .SYNOPSIS
      Adds output file for sorting
    .DESCRIPTION
      ECL equivalent: DISKSORT -> FILEOUT
      WFL equivalent: FILE OUT (TITLE = <title>)
    .PARAMETER Filename
      [String] The (fully qualified) output file to add.
  #>

  param (
    [Parameter(Mandatory=$True)][String]$Filename
  )

  if($global:HasHadError) {
    return
  }
  
  if (-not (Is-FullyQualifiedFile $Filename)) {
    Sort-SetError -Message "Sort-AddInputFile: Output filename not fully qualified."
    return
  }
  
  Write-JobLog -Message "Sort-AddOutputFile: $Filename"
  $global:SortOutputFile = $Filename
} #Sort-AddOutputFile

#-------------------------------------------------------------------------------
#.SYNOPSIS
# Sets the sort key
#
#.DESCRIPTION
# ECL equivalent DISKSORT -> Key=
# WFL equivalent KEY ()
#-------------------------------------------------------------------------------
function Sort-SetKey {
  <#
    .SYNOPSIS
      Sets the sort key
    .DESCRIPTION
      ECL equivalent: DISKSORT -> KEY=
      WFL equivalent: KEY ()
    .PARAMETER StartPos
      [Int32] Start Position
    .PARAMETER Length
      [Int32] Length
    .PARAMETER SortOrder
      [Int32] Sort order (Ascending or Descending)
  #>

  param (
    [Parameter(Mandatory=$True)][Int32]$StartPos,
    [Parameter(Mandatory=$True)][Int32]$Length,
    [Parameter(Mandatory=$True)][String]$SortOrder,
    [String]$Type
  )

  if($global:HasHadError) {
    return
  }

  Write-JobLog -Message "Set-SortKey: $StartPos, $Length, $SortOrder, $Type"
  $Type = $Type.ToUpper()
  $SortOrder = $SortOrder.ToUpper()
  if (($SortOrder -eq "D") -or ($SortOrder -eq "DESC") -or ($SortOrder -eq "DESCENDING")) {
    $SortOrder = "DSC"
  } elseif (($SortOrder -eq "") -or ($SortOrder -eq "A") -or ($SortOrder -eq "ASC") -or ($SortOrder -eq "ASCENDING")) {
    $SortOrder = "ASC"
  }
  
  if ($Type -eq "") {
    $Type = "A"
  }
  
  if (($SortOrder -ne "ASC") -and ($SortOrder -ne "DSC")) {
    Sort-SetError -Message "Set-SortKey: Sort order must be ASCENDING or DESCENDING."
    return
  }
  
  $SortKeyObj = New-Object -TypeName PSObject -Property @{
    StartPos  = $StartPos  
    NumOfChar = $Length
    Type      = $Type
    SubType   = ""
    AscDsc    = $SortOrder
  }
  $global:SortKeyList.Add($SortKeyObj)
} #Set-SortKey

#-------------------------------------------------------------------------------
#.SYNOPSIS
# Perform the actual sorting
#.PARAMETER RecordLength
#  [Int32] Record length of output file
#-------------------------------------------------------------------------------
function Sort-Execute {
  param (
    [Parameter(Mandatory=$False)][Int32]$RecordLength = -1,
    [String]$SortName
  )

  if($global:HasHadError) {
    return
  }

  Display -Message "[Sort-Execute] Starting Sort $SortName"

  # Create a temporary work folder
  $WorkFolder = (Add-BackSlash $global:AmtPath.ExtractPath) + 'Sort\' + [System.Guid]::NewGuid() + '\'
  $global:AmtFile.CreateFolder($WorkFolder) | Out-Null
  $SortRecordSizes = New-Object 'System.Collections.Generic.List[Int32]'

  try {
    $global:AmtSort.SetUnicode($global:UseUnicode)  
    $PaddedSortInputFiles = New-Object 'System.Collections.Generic.List[String]'
    [Int32]$MaxLength = 0
    $DifferentLength = $False
    
    [Int32]$BiggestSortRecSize = $RecordLength
    [Boolean]$AllEmptyFiles = $True
    [Boolean]$InOutSameFile = $False # True if one of the input files is teh same as the output file.

    for ([Int32]$j = 0; $j -lt $global:SortInputFiles.Count; $j++) {
      [Boolean]$FileExists = $global:AmtFile.FileExists($global:SortInputFiles[$j])
      if (-not $FileExists) {
        if ($global:SortWaitForInputFiles) {
          Wait-ForFile -File $global:SortInputFiles[$j]
        } else {
          Sort-SetError -Message "Sort-Execute: Input file $($global:SortInputFiles[$j]) does not exist."
          return
        }
      }

      [Int32]$SortRecSize = Get-FileRecordSize $global:SortInputFiles[$j]
      $SortRecordSizes.Add($SortRecSize)
      if ($SortRecSize -le 0) {
        # File is empty: No sort possible but script must go on.
        Add-WarningMsg -Message "Sort-Execute: Input file $($global:SortInputFiles[$j]) is empty."
      } else {
        $AllEmptyFiles = $False
        $global:AmtSort.AddFileIn($global:SortInputFiles[$j])
      }

      # We assume that the largest sort size of files is the correct one
      if ($SortRecSize -gt $BiggestSortRecSize) {
        $BiggestSortRecSize = $SortRecSize
      }

      if ($global:SortInputFiles[$j] -eq $global:SortOutputFile) {
        $InOutSameFile = $True
      }
    } # Endloop
    if ($AllEmptyFiles) {
      [Object] $FileObject = $global:AmtFile.CreateTextFile($global:SortOutputFile, 2, $False, $True) # 2 = ExclusiveBatch
      if ($global:AmtFile.ErrorCode -gt 0) {
        Sort-SetError -Message "Sort-Execute: Could not create file ($global:SortOutputFile), reason: $($global:AmtFile.ErrorDescription)"
        return
      } else {
        $FileObject.Close()
        $global:ObjTaskSort.TaskValue = 0
        $global:ObjTaskSort.ProcessOk = $True
        return
      }
    }

    [String]$TempFile
    if ($InOutSameFile) {
      # Output file is the same as one of the input files. Create a temporary output file.
      $TempFile = (Add-BackSlash $global:AmtPath.ExtractPath) + "AMT_SORTOUTPUT\" + $Global:CurrentScript + "_" + (Get-UniqueNumber)
      $global:AmtSort.SetFileOut($TempFile)
    } else {
      $global:AmtSort.SetFileOut($global:SortOutputFile)
    }

    if ($global:AmtSort.ErrorCode -ne 0) {
      Sort-SetError -Message "Sort-Execute: AmtSort.SetFileOut failed, reason: $($global:AmtSort.ErrorDescription)"
      return
    }

    [Int32]$SeqPos = $BiggestSortRecSize + 1
    [Boolean]$YYDateKey = $False
    [String]$TempInputFile = ""
    [Int32]$i = 0

    for ($i = 0; $i -lt $global:SortKeyList.Count; $i++) {
      if ($Null -eq $global:SortSequence) {
        $global:AmtSort.AddKey($global:SortKeyList[$i].StartPos, 
                              $global:SortKeyList[$i].NumOfChar,
                              $global:SortKeyList[$i].Type, 
                              $global:SortKeyList[$i].SubType, 
                              $global:SortKeyList[$i].AscDsc)
      } elseif ($global:SortKeyList[$i].Type -eq "A") {
        # Different sort sequence used
        $global:AmtSort.AddKey($SeqPos,
                              ($global:SortKeyList[$i].NumOfChar * 3), "N", 
                              $global:SortKeyList[$i].SubType, 
                              $global:SortKeyList[$i].AscDsc)
        $SeqPos += ($global:SortKeyList[$i].StartPos * 3)                             
      } elseif ($global:SortKeyList[$i].Type -eq "D") {
        # Date without century
      } elseif ($global:SortKeyList[$i].Type -eq "Y2C" -or $global:SortKeyList[$i].Type -eq "Y2Z") {
        # Century-window year key: add at original record position, century window logic handled by C# engine
        $YYDateKey = $True
        $global:AmtSort.AddKey($global:SortKeyList[$i].StartPos,
                              $global:SortKeyList[$i].NumOfChar,
                              $global:SortKeyList[$i].Type,
                              $global:SortKeyList[$i].SubType,
                              $global:SortKeyList[$i].AscDsc)
      } else {
        $YYDateKey = $True
        $global:AmtSort.AddKey($SeqPos, 8, "N", 
                              $global:SortKeyList[$i].SubType, 
                              $global:SortKeyList[$i].AscDsc)
        $SeqPos += 8
      }
      if ($global:AmtSort.ErrorCode -ne 0) {
        Sort-SetError -Message "Sort-Execute: AmtSort.AddKey failed, reason: $($global:AmtSort.ErrorDescription)" 
        return
      }
    } # for
    if (-not $global:SortRecSizeSet) {
      $global:AmtSort.SetRecSize($SeqPos - 1)
    }
  $global:AmtSort.SortLinkSize = $global:SortLinkSize
  $global:AmtSort.SortNumRec = $global:SortNumRec
  $global:AmtSort.WorkFolder = $WorkFolder
  $global:AmtSort.YYDateKey = $YYDateKey
  $global:AmtSort.CopyOption = $global:CopyOption
  $global:AmtSort.DupeOption = $global:DupeOption
  $global:AmtSort.NoDups = $global:NoDups
  if ($Null -ne $global:SortAcceptList){
      foreach ($Accept in $global:SortAcceptList) {
      $global:AmtSort.AddAcceptKey($Accept.StartPos, $Accept.Length, $Accept.Type, $Accept.Operation, $Accept.Value, $Accept.LogicalOp)	 
    }
  }
  if ($Null -ne $global:SortSelectList) {
    foreach ($SortSelect in $global:SortSelectList) {
      $global:AmtSort.AddSortSelect($SortSelect.StartPos, $SortSelect.Length, $SortSelect.OutputPos)	 
    }
  }
  if ($Null -ne $global:SortInrecList) {
    foreach ($Inrec in $global:SortInrecList) {
      $global:AmtSort.AddInrecField($Inrec.AbsoluteColumnPos, $Inrec.InputColumnPos, $Inrec.InputColumnLength, $Inrec.SeperationField, $Inrec.GenericSeperation)
    }
  }
  if ($Null -ne $global:SortOutrecList) {
    foreach ($Outrec in $global:SortOutrecList) {
      $global:AmtSort.AddOutrecField($Outrec.AbsoluteColumnPos, $Outrec.InputColumnPos, $Outrec.InputColumnLength, $Outrec.SeperationField, $Outrec.GenericSeperation)
    }
  }
  if ($Null -ne $global:SortInrecIfthenList) {
    Sort-AddInrecIfthenBlocks -IfthenBlocks $global:SortInrecIfthenList
  }
  if ($Null -ne $global:SortOutrecIfthenList) {
    Sort-AddOutrecIfthenBlocks -IfthenBlocks $global:SortOutrecIfthenList
  }
  if ($Null -ne $global:SortSumFieldList) {
    foreach ($SortSumField in $global:SortSumFieldList) {
      $global:AmtSort.AddSumField($SortSumField.StartPos, $SortSumField.Length, $SortSumField.Type)
    }
  }

  $global:AmtSort.SortFileFromScript()
    if ($global:AmtSort.ErrorCode -ne 0) {
      Sort-SetError -Message "Sort-Execute: AmtSort.SortFileFromScript failed, reason: $($global:AmtSort.ErrorDescription)"
      return
    }

    if ($InOutSameFile) {
      $global:AmtFile.DeleteFile($global:SortOutputFile, 10) | Out-Null # 10 = MaxWaitTime
      $global:AmtFile.RenameFile($TempFile, $global:SortOutputFile, 10) | Out-Null # 10 = MaxWaitTime
    }

    $global:ObjTaskSort.TaskValue = 0
    $global:ObjTaskSort.ProcessOk = $True
    Display -Message "[Sort-Execute] End Sort $SortName"
  } finally {
  }
} #Sort-Execute


#-------------------------------------------------------------------------------
#.SYNOPSIS
# Set EBCDIC sort sequence (default = Unisys)
#-------------------------------------------------------------------------------
function Sort-SetEbcdicSortSequence {
  Sort-SetEbcdicSortSequenceUnisys
}

#-------------------------------------------------------------------------------
#.SYNOPSIS
# Set EBCDIC sort sequence (Unisys)
#-------------------------------------------------------------------------------
function Sort-SetEbcdicSortSequenceUnisys {
  if($global:HasHadError) {
    return
  }
  Write-Joblog "Sort-SetEbcdicSortSequence: using EBCDIC sort sequence"
  $global:AmtSort.SetSortSequence($global:EbcdicSortSeqUnisys)
}

#-------------------------------------------------------------------------------
#.SYNOPSIS
# Set EBCDIC sort sequence (IBM)
#-------------------------------------------------------------------------------
function Sort-SetEbcdicSortSequenceIbm {
  if($global:HasHadError) {
    return
  }
  Write-Joblog "Sort-SetEbcdicSortSequence: using EBCDIC sort sequence (IBM)"
  $global:AmtSort.SetSortSequence($global:EbcdicSortSeqIbm)
}

#-------------------------------------------------------------------------------
#.SYNOPSIS
# Get file record size.
#
#.DESCRIPTION
# This function tries to determine the recordsize in a file. This only works
# for files with fixed records sizes.
#
#.PARAMETER Filename
#
#.OUTPUT 
# [Int32] The record size, value -1 if an error occurred.
#-------------------------------------------------------------------------------
function Get-FileRecordSize {

  param (
    [Parameter(Mandatory=$True)][String]$Filename
  )

  if($global:HasHadError) {
    return
  }

  [Boolean]$FileExists = $global:AmtFile.FileExists($Filename)
  if (-not $FileExists) {
    Add-WarningMsg "Get-FileRecordSize: File $Filename does not exist."
    return -1 # Error
  }
  [Object]$FileHandle = $Null;
  if ($Null -ne $global:FilesList) {
    for ([Int32]$I = 0; $I -lt ($global:FilesList.Count); $I++) {
      if (($global:FilesList[$I].Filename -eq $Filename) -or ($global:FilesList[$I].Copyname -eq $Filename)) {
        $FileHandle = $global:FilesList[$I].FileHandle
        if (($Null -ne $FileHandle) -and ($FileHandle.RecordSize -gt 0)) {
          return $FileHandle.RecordSize
        } elseif (($Null -ne $global:FilesList[$I].RecordSize) -and ($global:FilesList[$I].RecordSize -gt 0)) {
          return $global:FilesList[$I].RecordSize
        }
        break
      }
    }
  }
  # If the record size was explicitly set via RECORD TYPE=F,LENGTH=n, use that value directly.
  # Auto-detection via ReadLine() fails for binary/EBCDIC files (e.g. VSAM datasets migrated as
  # flat files) because packed-decimal data commonly starts with 0x0A bytes, causing ReadLine()
  # to return an empty string even though the file has content.
  if ($global:SortRecSizeSet -and $global:SortRecSize -gt 0) {
    Write-JobLog -Message "Get-FileRecordSize: File: $Filename, Result = $($global:SortRecSize) (from RECORD statement)"
    return $global:SortRecSize
  }

  [Object]$FileTextStream = $global:AmtFile.OpenTextFile($Filename, 4, 0, $True) # 4 = SharedRead
  if ($global:AmtFile.ErrorCode -ne 0) {
    Add-WarningMsg "Get-FileRecordSize: Could not open file $Filename, reason: $($global:AmtFile.ErrorDescription)"
    return -1 # Error
  }
  [Int32] $Result = $FileTextStream.ReadLine().Length
  if ($Result -eq 0) {
    # First line is an empty line, try the next line.
    $Result = $FileTextStream.ReadLine().Length
  }
  $FileTextStream.Close() | Out-Null
  if ($Null -ne $FileHandle) {
    $FileHandle.RecordSize = $Result
  }
  Write-JobLog -Message "Get-FileRecordSize: File: $Filename, Result = $Result" 
  return $Result
} #Get-FileRecordSize


function File-ReadBlock {
  <#
    .SYNOPSIS
      Fast read routine
    .PARAMETER File
      [Object] File
    .PARAMETER Line
      [ref] Line
    .PARAMETER RecLength
      [Int32] RecLength
    .PARAMETER ReadPosInBuf
      [ref] ReadPosInBuf
    .PARAMETER ReadAtEndOfBuf
      [ref] ReadAtEndOfBuf
  #>

  param (
    [Object]$File,
    [ref]$Line,
    [Int32]$RecLength,
    [ref]$ReadPosInBuf,
    [ref]$ReadAtEndOfBuf
  )

  if($global:HasHadError) {
    return
  }
  
  [String]$CrLf = [Environment]::NewLine
  [Boolean]$Result = $True
  [Int32]$ReadBuffLength = 0
  [Int32]$NrChars = [Math]::floor(100000 / ($RecLength + $CrLf.Length)) * ($RecLength + $CrLf.Length)
  
  if ((-not($File.EndOfFile)) -and ($ReadAtEndOfBuf.Value -eq $True)) {
    $global:ReadBuff = $File.Read($NrChars)
    $ReadPosInBuf.Value = 0
    $ReadAtEndOfBuf.Value = $False
    $ReadBuffLength = $global:ReadBuff.Length
    if ($ReadBuffLength -eq 0) {    # When reading blocks of 100 rows and the fiel has exactly 100 rows then we get the length 0 back and
      $ReadAtEndOfBuf.Value = $True # we should stop reading further
    }
  }
  if (($ReadAtEndOfBuf.Value -eq $True) -and ($File.EndOfFile)) {
    $Result = $False
  } else {
    $Line.Value = $global:ReadBuff.Substring($ReadPosInBuf.Value, $RecLength + $CrLf.Length)
    $ReadPosInBuf.Value = $ReadPosInBuf.Value + ($RecLength + $CrLf.Length)

    if ((-not(($ReadPosInBuf.Value + $RecLength + $CrLf.Length) -ge $ReadBuffLength)) -and 
        (-not($global:ReadBuff.Substring($ReadPosInBuf.Value + $RecLength, $CrLf.Length) -eq $CrLf))) {
       Sort-SetError -Message "File-ReadBlock: Record with wrong size in input file."
       return
    }
    
    if (($ReadPosInBuf.Value + $RecLength + $CrLf.Length) -gt ($global:ReadBuff.Length)) {
      $ReadAtEndOfBuf.Value = $True
      $global:ReadBuff = ""
    }
  }
  return $Result
} #File-ReadBlock


function Sort-SetRecordSize {
  <#
    .SYNOPSIS
      Sets the SORT record size.
    .PARAMETER RecSize
      [Int32] Record size
  #>

  param (
    [Parameter(Mandatory=$True)]
    [ValidateRange(0, [Int32]::MaxValue)]
    [Int32]$RecSize
  )

  if($global:HasHadError) {
    return
  }

  $global:SortRecSizeSet = $True
  $global:SortRecSize = $RecSize
  $global:AmtSort.SetRecSize($RecSize)
} # Sort-SetRecSize


function Sort-SetLinkSize {
  <#
    .SYNOPSIS
      Sets the SORT link size.
    .PARAMETER LinkSize
      [Int32] Link size
  #>

  param (
    [Parameter(Mandatory=$True)]
    [ValidateRange(0, [Int32]::MaxValue)]
    [Int32]$LinkSize
  )

  if($global:HasHadError) {
    return
  }

  $global:SortLinkSize = $LinkSize
  # note: May be restored later. ComScript has not been deployed yet 
  #       and it isn't used in ComScript after all anyway.
  #       MMAAT 16-12-2015
  #$global:AmtSort.SetLinkSize($LinkSize)
} # Sort-SetRecSize


function Sort-SetNumRec {
  <#
    .SYNOPSIS
      Specifies the number of records to process, where
      that should be between 1 and 34,359,738,367.
    .PARAMETER RecSize
      [Int64] Number of records to process.
  #>

  param (
    [Parameter(Mandatory=$True)]
    [ValidateRange(1, 34359738367)]
    [Int32]$NumRec
  )

  if($global:HasHadError) {
    return
  }

  $global:SortNumRec = $NumRec
} # Sort-SetNumRec


function Sort-SetCopyOption {

  <#
    .SYNOPSIS
      Sets the SORT copy option (copy only, no sort)
    .PARAMETER CopyOption
      [Boolean] Copy option
  #>

  param (
    [Boolean]$CopyOption = $True
  )

  if($global:HasHadError) {
    return
  }
  
  $global:CopyOption = $CopyOption        

} #Sort-SetCopyOption


function Sort-SetRecordEnding {
  <#
    .SYNOPSIS
      Sets the SORT Record ending.
    .PARAMETER RecordEnding
      [AmtFileRecordEnding] RecordEnding
       Default = 0
       CrLf = 1
       Cr = 2
       Lf = 3,
       None = 4

  #>

  param (
    [Parameter(Mandatory=$True)]
    [AmtFileRecordEnding]$RecordEnding
  )

  if($global:HasHadError) {
    return
  }

  $global:AmtSort.FileRecordEnding = $RecordEnding

} # Sort-SetRecordEnding

function Sort-SetDeleteDuplicateRecords {
  <#
    .SYNOPSIS
      Sets the SORT Delete duplicates option.
    .PARAMETER DeleteDuplicates
      [Boolean] Delete Duplicates
  #>

  param (
    [Boolean]$DeleteDuplicateRecords = $True
  )

  if($global:HasHadError) {
    return
  }

  $global:AmtSort.DeleteDuplicateRecords = $DeleteDuplicateRecords
    
} # Sort-SetDeleteDuplicateRecords

function File-WriteBlock {
  <#
    .SYNOPSIS
      Fast write routine
    .PARAMETER File
      [Object] File
    .PARAMETER Line
      [ref] Line
    .PARAMETER EndWrite
      [Boolean] End write
  #>

  param (
    [Object]$File,
    [ref]$Line,
    [Boolean]$EndWrite
  )

  if($global:HasHadError) {
    return
  }

  if (-not ($EndWrite)) {
    $global:WriteBuff += $Line.Value
  }

  if (($EndWrite) -or ($global:WriteBuff.Length -gt 100000)) {
    [Boolean]$WriteResult = $File.Write($global:WriteBuff, $True)  
    $global:WriteBuff = ""
  }

  if ($EndWrite) {
    $File.Close() | Out-Null
  }
} # File-WriteBlock


function Sort-AddAccept {
  <#
    .SYNOPSIS
      Adds an ACCEPT parameter to the SORT command.
    .PARAMETER Start
      [Int32] Start position
    .PARAMETER Length
      [Int32] Number of characters to be tested.
    .PARAMETER Type
      [String] Kind of data the field contains. Can be ASC, CAS or DEC.
    .PARAMETER Operation
      [String] Test operation. Can be E, G, GE, L, LE or NE.
    .PARAMETER Value
      [String] Contains the test data to be compared.
    .PARAMETER Logical
      [String] Logical operation. Can be AND or OR.
  #>

  param (
    [Int32]$StartPos,
    [Int32]$Length,
    [String]$Type,
    [String]$Operation,
    [String]$Value,
    [String]$LogicalOp = "OR"  # Default logical operator is OR.
  )

  if($global:HasHadError) {
    return
  }

  Write-JobLog -Message "Sort-AddAccept: $StartPos $Length $Type $Operation $Value $LogicalOp"

  if (-not (Is-Numeric $StartPos)) {
    Sort-SetError -Message "Sort-AddAccept: Start character is not numeric."
    return
  }

  if (-not (Is-Numeric $Length)) {
    Sort-SetError -Message "Sort-AddAccept: Length is not numeric."
    return
  }

  $Type = $Type.ToUpperInvariant()
  switch ($Type) {
    "ASC" {  # ASCII: Case insensitive
      $Value = $Value.ToUpperInvariant()
      break
    }
    "CAS" {  # ASCII: Case sensitive
      break
    }
    "DEC" {  # Decimal
      break
    }
    default {
      Sort-SetError -Message "Sort-AddAccept: Type must be ASC, CAS or DEC."
      return
    }
  }

  $Operation = $Operation.ToUpperInvariant()
  switch ($Operation) {
    "E" {  # Equal to
      $Operation = "="
      break
    }
    "G" {  # Greater than
      $Operation = ">"
      break
    }
    "GE" {  # Greater than or equal to
      $Operation = ">="
      break
    }
    "L" {  # Less than
      $Operation = "<"
      break
    }
    "LE" {  # Less than or equal to
      $Operation = "<="
      break
    }
    "NE" {  # Not equal to
      $Operation = "<>"
      break
    }
    default {
      Sort-SetError -Message "Sort-AddAccept: Operation must be E, G, GE, L, LE or NE." 
      return
    }
  }

  $LogicalOp = $LogicalOp.ToUpperInvariant()
  switch ($LogicalOp) {
    "AND" { 
      break
    }
    "OR" { 
      break 
    }
    default { 
      Sort-SetError -Message "Sort-AddAccept: Logical operator must be AND or OR."
      return
    }
  }

  # ECL index is 1-based, but PowerShell 0-based
  if ($StartPos -gt 0) {
    $StartPos -= 1 
  }
  # Create list if this is the first accept
  if ($Null -eq $global:SortAcceptList) {
    $global:SortAcceptList = New-Object 'System.Collections.Generic.List[Object]'
  }

  # Add a new accept object to the accept list
  [Object]$Accept = New-Object -TypeName psObject -Property @{StartPos = $StartPos; Length = $Length; Type = $Type; 
                                                   Operation = $Operation; Value = $Value; LogicalOp = $LogicalOp}
  $global:SortAcceptList.Add($Accept)
} # Sort-AddAccept


function Sort-AcceptLine {
  <#
    .SYNOPSIS
      Runs the ACCEPT parameter checks against the specified $Line.
    .PARAMETER Line
      [String] Line to check.
  #>

  param (
    [String]$Line
  )

  if($global:HasHadError) {
    return
  }

  [Boolean]$Ok  = $False
  [Boolean]$And = $False

  foreach ($Accept in $global:SortAcceptList) {
    if ((($And) -and ($Ok)) -or ((-not $And) -and (-not $Ok))) {
      $Ok = $True

      if ($Accept.Type -eq "DEC") {
        if (-not (Is-Numeric $Line.Substring($Accept.StartPos, $Accept.Length))) {
          $Ok = $False
        }
      }

      if ($Accept.Type -eq "ASC") {
        # Case insensitive
        $Line = $Line.ToUpperInvariant()
      }

      if ($Ok) {
        $Ok = $False

        Switch ($Accept.Operation) {
          "=" {
            if ($Accept.Type -eq "DEC") {
              if (([Int32]$Line.Substring($Accept.StartPos, $Accept.Length)) -eq ([Int32]$Accept.Value)) {
                $Ok = $True
              }
            } else {
              if ($Line.Substring($Accept.StartPos, $Accept.Length) -eq $Accept.Value) {
                $Ok = $True
              }
            }
          }
          ">" {
            if ($Accept.Type -eq "DEC") {
              if (([Int32]$Line.Substring($Accept.StartPos, $Accept.Length)) -gt ([Int32]$Accept.Value)) {
                $Ok = $True
              }
            } else {
              if ($Line.Substring($Accept.StartPos, $Accept.Length) -gt $Accept.Value) {
                $Ok = $True
              }
            }
          }
          ">=" {
            if ($Accept.Type -eq "DEC") {
              if (([Int32]$Line.Substring($Accept.StartPos, $Accept.Length)) -ge ([Int32]$Accept.Value)) {
                $Ok = $True
              }
            } else {
              if ($Line.Substring($Accept.StartPos, $Accept.Length) -ge $Accept.Value) {
                $Ok = $True
              }
            }
          }
          "<" {
            if ($Accept.Type -eq "DEC") {
              if (([Int32]$Line.Substring($Accept.StartPos, $Accept.Length)) -lt ([Int32]$Accept.Value)) {
                $Ok = $True
              }
            } else {
              if ($Line.Substring($Accept.StartPos, $Accept.Length) -lt $Accept.Value) {
                $Ok = $True
              }
            }
          }
          "<=" {
            if ($Accept.Type -eq "DEC") {
              if (([Int32]$Line.Substring($Accept.StartPos, $Accept.Length)) -le ([Int32]$Accept.Value)) {
                $Ok = $True
              }
            } else {
              if ($Line.Substring($Accept.StartPos, $Accept.Length) -le $Accept.Value) {
                $Ok = $True
              }
            }
          }
          "<>" {
            if ($Accept.Type -eq "DEC") {
              if (([Int32]$Line.Substring($Accept.StartPos, $Accept.Length)) -ne ([Int32]$Accept.Value)) {
                $Ok = $True
              }
            } else {
              if ($Line.Substring($Accept.StartPos, $Accept.Length) -ne $Accept.Value) {
                $Ok = $True
              }
            }
          }
          default {
            Sort-SetError -Message "Sort-AcceptLine: Invalid comparison type, please check."
            return
          }
        } # switch
      }
    }

    if ($Accept.LogicalOp -eq "AND") {
      $And = $True
    } elseif ($Accept.LogicalOp -eq "OR") {
      $And = $False
    }
  } # foreach

  return $Ok
} # Sort-AcceptLine


function Sort-AddSelect {
  <#
    .SYNOPSIS
      Adds an SELECT parameter to the SORT command.
    .PARAMETER StartPos
      [Int32] Start position
    .PARAMETER Length
      [Int32] Number of characters to be selected.
    .PARAMETER OutputPos
      [String] Output position of the selection, not mandatory
  #>

  param (
    [Int32]$StartPos,
    [Int32]$Length,
    [Int32]$OutputPos = -1
  )

  if($global:HasHadError) {
    return
  }

  Write-JobLog -Message "Sort-AddAccept: $StartPos $Length $Type $Operation $Value $LogicalOp"

  if (-not (Is-Numeric $StartPos)) {
    Sort-SetError -Message "Sort-AddSelect: Start position is not numeric."
    return
  }

  if (-not (Is-Numeric $Length)) {
    Sort-SetError -Message "Sort-AddSelect: Length is not numeric."
    return
  }

  # ECL index is 1-based, but PowerShell 0-based
  if ($StartPos -gt 0) {
    $StartPos -= 1 
  }
  if ($OutputPos -gt 0) {
    $OutputPos -= 1 
  }

  if ($Null -eq $global:SortSelectList) {
    $global:SortSelectList = @()
  }
  
  # Add a new accept object to the accept list
  [Object]$Select = New-Object -TypeName psObject -Property @{
    StartPos = $StartPos; 
    Length = $Length; 
    OutputPos = $OutputPos
  }
  $global:SortSelectList += $Select

} # Sort-AddSelect


function Sort-AddOmit {
  <#
    .SYNOPSIS
      Adds an OMIT parameter to the SORT command.
    .PARAMETER Start
      [Int32] Start position
    .PARAMETER Length
      [Int32] Number of characters to be tested.
    .PARAMETER Type
      [String] Kind of data the field contains. Can be  CH, AQ, BI, PD
    .PARAMETER Operation
      [String] Test operation. Can be EQ, GT, GE, LT, LE or NE.
    .PARAMETER Value
      [String] Contains the test data to be compared.
    .PARAMETER Logical
      [String] Logical operation. Can be AND or OR.
  #>

  param (
    [Int32]$StartPos,
    [Int32]$Length,
    [String]$Type,
    [String]$Operation,
    [String]$Value,
    [String]$LogicalOp = "OR"  # Default logical operator is OR.
  )

  if($global:HasHadError) {
    return
  }

  Write-JobLog -Message "Sort-AddOmit: $StartPos $Length $Type $Operation $Value $LogicalOp"

  if (-not (Is-Numeric $StartPos)) {
    Sort-SetError -Message "Sort-AddOmit: Start character is not numeric."
    return
  }

  if (-not (Is-Numeric $Length)) {
    Sort-SetError -Message "Sort-AddOmit: Length is not numeric."
    return
  }

  $Type = $Type.ToUpperInvariant()
  switch ($Type) {
    "CH" {  # Alpha Case sensitive
      break
    }
    "BI" {  # Binary
      break
    }
    "PD" {  # Packed decimal
      break
    }
    "AQ" {  # Alpha Case sensitive
      break
    }
    "NU" {
      break # Unsigned Numeric
    }
    default {
      Sort-SetError -Message "Sort-AddOmit: Type must be CH, BI, PD, AQ or NU."
      return
    }
  }

  $Operation = $Operation.ToUpperInvariant()
  switch ($Operation) {
    "EQ" {  # Equal to
      $Operation = "="
      break
    }
    "GT" {  # Greater than
      $Operation = ">"
      break
    }
    "GE" {  # Greater than or equal to
      $Operation = ">="
      break
    }
    "LT" {  # Less than
      $Operation = "<"
      break
    }
    "LE" {  # Less than or equal to
      $Operation = "<="
      break
    }
    "NE" {  # Not equal to
      $Operation = "<>"
      break
    }
    default {
      Sort-SetError -Message "Sort-AddOmit: Operation must be EQ, GT, GE, LT, LE or NE." 
      return
    }
  }

  $LogicalOp = $LogicalOp.ToUpperInvariant()
  switch ($LogicalOp) {
    "AND" { 
      break
    }
    "OR" { 
      break 
    }
    default { 
      Sort-SetError -Message "Sort-AddOmit: Logical operator must be AND or OR." 
      return
    }
  }

  # JCL index is 1-based, but PowerShell 0-based
  if ($StartPos -gt 0) {
    $StartPos -= 1 
  }

  #Add to Sort object
  $global:AmtSort.AddOmitKey($StartPos, $Length, $Type, $Operation, $Value, $LogicalOp)

} # Sort-AddOmit

function Sort-AddOmitOpeningBracket() {
  <#
   .SYNOPSIS
     Adds opening bracket to the OMIT keys of the SORT command 
  #>

  if($global:HasHadError) {
    return
  }

  $global:AmtSort.AddOmitOpeningBracket();
} # Sort-AddOmitOpeningBracket

function Sort-AddOmitClosingBracket() {
 <#
  .SYNOPSIS
    Adds closing bracket to the OMIT keys of the SORT command
 #>

  if($global:HasHadError) {
    return
  }

 $global:AmtSort.AddOmitClosingBracket();
} # Sort-AddOmitClosingBracket

function Sort-AddOmitLogicalOperator() {
 <#
  .SYNOPSIS
    Adds OMIT logical operator (AND/OR) to the current OMIT key of the SORT command
   .PARAMETER Logical
     [String] Logical operation. Can be AND or OR.
 #>

 param (
   [String]$LogicalOp
 )

  if($global:HasHadError) {
    return
  }

 $global:AmtSort.AddOmitLogicalOperator($LogicalOp);
} # Sort-AddOmitLogicalOperator


function Sort-AddInclude {
  <#
    .SYNOPSIS
      Adds an INCLUDE parameter to the SORT command.
    .PARAMETER Start
      [Int32] Start position
    .PARAMETER Length
      [Int32] Number of characters to be tested.
    .PARAMETER Type
      [String] Kind of data the field contains. Can be  CH, AQ, BI, PD
    .PARAMETER Operation
      [String] Test operation. Can be EQ, GT, GE, LT, LE or NE.
    .PARAMETER Value
      [String] Contains the test data to be compared.
    .PARAMETER Logical
      [String] Logical operation. Can be AND or OR.
  #>

  param (
    [Int32]$StartPos,
    [Int32]$Length,
    [String]$Type,
    [String]$Operation,
    [String]$Value,
    [String]$LogicalOp = "OR"  # Default logical operator is OR.
  )

  if($global:HasHadError) {
    return
  }

  Write-JobLog -Message "Sort-AddInclude: $StartPos $Length $Type $Operation $Value $LogicalOp"

  if (-not (Is-Numeric $StartPos)) {
    Sort-SetError -Message "Sort-AddInclude: Start character is not numeric."
    return
  }

  if (-not (Is-Numeric $Length)) {
    Sort-SetError -Message "Sort-AddInclude: Length is not numeric."
    return
  }

  $Type = $Type.ToUpperInvariant()
  switch ($Type) {
    "CH" {  # Alpha Case sensitive
      break
    }
    "BI" {  # Binary
      break
    }
    "PD" {  # Packed decimal
      break
    }
    "AQ" {  # Alpha Case sensitive
      break
    }
    default {
      Sort-SetError -Message "Sort-AddInclude: Type must be CH, BI, PD or AQ."
      return
    }
  }

  $Operation = $Operation.ToUpperInvariant()
  switch ($Operation) {
    "EQ" {  # Equal to
      $Operation = "="
      break
    }
    "GT" {  # Greater than
      $Operation = ">"
      break
    }
    "GE" {  # Greater than or equal to
      $Operation = ">="
      break
    }
    "LT" {  # Less than
      $Operation = "<"
      break
    }
    "LE" {  # Less than or equal to
      $Operation = "<="
      break
    }
    "NE" {  # Not equal to
      $Operation = "<>"
      break
    }
    default {
      Sort-SetError -Message "Sort-AddInclude: Operation must be EQ, GT, GE, LT, LE or NE." 
      return
    }
  }

  $LogicalOp = $LogicalOp.ToUpperInvariant()
  switch ($LogicalOp) {
    "AND" { 
      break
    }
    "OR" { 
      break 
    }
    default { 
      Sort-SetError -Message "Sort-AddInclude: Logical operator must be AND or OR." 
      return
    }
  }

  # JCL index is 1-based, but PowerShell 0-based
  if ($StartPos -gt 0) {
    $StartPos -= 1 
  }
  # Add a new include object to sort object
  $global:AmtSort.AddIncludeKey($StartPos, $Length, $Type, $Operation, $Value, $LogicalOp)
} # Sort-AddInclude

function Sort-AddIncludeOpeningBracket() {
   <#
    .SYNOPSIS
      Adds opening bracket to the INCLUDE keys of the SORT command 
   #>

  if($global:HasHadError) {
    return
  }

   $global:AmtSort.AddIncludeOpeningBracket();
} # Sort-AddIncludeOpeningBracket

function Sort-AddIncludeClosingBracket() {
  <#
   .SYNOPSIS
     Adds closing bracket to the INCLUDE keys of the SORT command
  #>

  if($global:HasHadError) {
    return
  }

  $global:AmtSort.AddIncludeClosingBracket();
} # Sort-AddIncludeClosingBracket

function Sort-AddIncludeLogicalOperator() {
  <#
   .SYNOPSIS
     Adds INCLUDE logical operator (AND/OR) to the current INCLUDE key of the SORT command
    .PARAMETER Logical
      [String] Logical operation. Can be AND or OR.
  #>

  param (
    [String]$LogicalOp
  )

  if($global:HasHadError) {
    return
  }

  $global:AmtSort.AddIncludeLogicalOperator($LogicalOp);
} # Sort-AddIncludeLogicalOperator

function Sort-AddRec {
  <#
    .SYNOPSIS
      Adds an OUTREC parameter to the SORT command.
      Adds part of of the input record to the outputfile, like Accept
    .PARAMETER AbsoluteColumnPos
      [Int32] Absolute column position in the output record (starting at 1)
    .PARAMETER InputColumnPos
      [Int32] Column position in the input record (starting at 1)
    .PARAMETER InputColumnLength
      [Int32] Number of characters to be taken from the input record
    .PARAMETER SeparationField
      [String] Separation field to be added after the output field, not mandatory
    .PARAMETER GenericSeperation
      [String] Seperation field is nX, nZ
    .PARAMETER RecType
      [String] Record type, can be OUTREC or INREC. Only Difference is the list they go into.
  #>

  param (
    [Int32]$AbsoluteColumnPos,
    [Int32]$InputColumnPos,
    [Int32]$InputColumnLength,
    [String]$SeperationField,
    [Boolean]$GenericSeperation,
    [String]$RecType
  )

  if($global:HasHadError) {
    return
  }

  Write-JobLog -Message "Sort-AddRec: $AbsoluteColumnPos $InputColumnPos $InputColumnLength $SeperationField $GenericSeperation $RecType"

  if (-not (Is-Numeric $InputColumnPos)) {
    Sort-SetError -Message "Sort-AddRec: Start character is not numeric."
    return
  }

  if (-not (Is-Numeric $InputColumnLength)) {
    Sort-SetError -Message "Sort-AddRec: Length is not numeric."
    return
  }

  # JCL index is 1-based, but PowerShell 0-based
  if ($InputColumnPos -gt 0) {
    $InputColumnPos -= 1 
  }

  if ($AbsoluteColumnPos -gt 0) {
    $AbsoluteColumnPos -= 1 
  }

  # Create list if this is the first outrec
  if ($Null -eq $global:SortOutrecList) {
    $global:SortOutrecList = New-Object 'System.Collections.Generic.List[Object]'
  }
  if ($Null -eq $global:SortInrecList) {
    $global:SortInrecList = New-Object 'System.Collections.Generic.List[Object]'
  }

  # Add a new otrec object to the outrec list
  [Object]$Outrec = New-Object -TypeName psObject -Property @{AbsoluteColumnPos = $AbsoluteColumnPos; 
                                                                InputColumnPos = $InputColumnPos; 
                                                                InputColumnLength = $InputColumnLength; 
                                                                SeperationField = $SeperationField;
                                                                GenericSeperation = $GenericSeperation }
  

  if($recType -eq 'OUTREC') {
    $global:SortOutrecList.Add($Outrec)
  } elseif($recType -eq 'INREC') {
    $global:SortInrecList.Add($Outrec)
  }
} # Sort-AddRec

function Sort-SetDupeOptions {
  <#
    .SYNOPSIS
      Sets the options for duplicate records.
    .PARAMETER DupeType
      [String] Dupe option, can be FIRST, LAST or ALL
    .PARAMETER NoDups
      [Boolean] No duplicates, if set to true, only unique records will be kept in the output.
  #>

  param (
    [String]$DupeType = "", # FirstDup, LastDup
    [Boolean]$NoDups = $False
  )

  if($global:HasHadError) {
    return
  }

  $global:DupeOption = $DupeType
  $global:NoDups = $NoDups
}

function Sort-AddSumField {
  <#
    .SYNOPSIS
      Add a SUM field 
    .DESCRIPTION
      IBM SUM FIELDS = (p,m,f)
    .PARAMETER StartPos
      [Int32] Start Position
    .PARAMETER Length
      [Int32] Length
    .PARAMETER Type
      [String] Type, AmtType
  #>

  param (
    [Parameter(Mandatory=$True)][Int32]$StartPos,
    [Parameter(Mandatory=$True)][Int32]$Length,
    [String]$Type
  )

  if($global:HasHadError) {
    return
  }

  Write-JobLog -Message "Sort-AddSumField: $StartPos, $Length, $Type"
  $Type = $Type.ToUpper()
  if ($Type -eq "") {
    $Type = "O"
  }
  
  if ($Null -eq $global:SortSumFieldList) {
    $global:SortSumFieldList = New-Object 'System.Collections.Generic.List[Object]'
  }
  
  $SumFieldObj = New-Object -TypeName PSObject -Property @{
    StartPos  = $StartPos  
    Length    = $Length
    Type      = $Type
  }
  $global:SortSumFieldList.Add($SumFieldObj)
  
} # Sort-AddSumField

function Sort-AddInrecIfthenBlocks {
  <#
    .SYNOPSIS
      Parse a list of raw IFTHEN/OVERLAY block hashtables (produced by Read-IfthenBlockList
      in AmtJclLibrary) and pass each block's WHEN conditions and OVERLAY/FINDREP items to the
      C# Sort object via the INREC builder methods (BeginInrecIfthenBlock / EndInrecIfthenBlock).
    .PARAMETER IfthenBlocks
      [System.Collections.ArrayList] Block list returned by Read-IfthenBlockList.
  #>
  param (
    [Parameter(Mandatory=$true)][Object]$IfthenBlocks
  )

  foreach ($Block in $IfthenBlocks) {
    $global:AmtSort.BeginInrecIfthenBlock()
    Sort-AddIfthenBlockItems -Block $Block
    $global:AmtSort.EndInrecIfthenBlock()
  } # foreach Block
} # Sort-AddInrecIfthenBlocks

function Sort-AddOutrecIfthenBlocks {
  <#
    .SYNOPSIS
      Parse a list of raw IFTHEN/OVERLAY/FINDREP block hashtables (produced by
      Read-IfthenBlockList in AmtJclLibrary) and pass each block's WHEN conditions and
      OVERLAY/FINDREP items to the C# Sort object via the OUTREC builder methods
      (BeginOutrecIfthenBlock / EndOutrecIfthenBlock). OUTREC IFTHEN runs post-sort.
    .PARAMETER IfthenBlocks
      [System.Collections.ArrayList] Block list returned by Read-IfthenBlockList.
  #>
  param (
    [Parameter(Mandatory=$true)][Object]$IfthenBlocks
  )

  foreach ($Block in $IfthenBlocks) {
    $global:AmtSort.BeginOutrecIfthenBlock()
    Sort-AddIfthenBlockItems -Block $Block
    $global:AmtSort.EndOutrecIfthenBlock()
  } # foreach Block
} # Sort-AddOutrecIfthenBlocks

function Sort-AddIfthenBlockItems {
  <#
    .SYNOPSIS
      Parse a single IFTHEN/OVERLAY/FINDREP block (produced by Read-IfthenBlockList) and
      register its WHEN conditions and OVERLAY/FINDREP items on the current IFTHEN block of
      the C# Sort object. The current block must already have been started with
      BeginInrecIfthenBlock or BeginOutrecIfthenBlock. The WHEN/OVERLAY builder methods operate
      on the shared current block, so they are used for both INREC and OUTREC.
    .PARAMETER Block
      [Hashtable] One block: @{ KeyWord = 'IFTHEN'|'OVERLAY'|'FINDREP'; RawTokens = [...] }.
  #>
  param (
    [Parameter(Mandatory=$true)][Object]$Block
  )

  [System.Collections.ArrayList]$RawTokens = $Block.RawTokens
  [String]$KeyWord = [String]$Block.KeyWord

  # Bare OVERLAY(...) — implicit WHEN=INIT, RawTokens are the overlay items directly.
  if ($KeyWord -eq 'OVERLAY') {
    $global:AmtSort.AddInrecIfthenWhenInit()
    Sort-AddOverlayItemsFromTokens -OverlayTokens $RawTokens
    return
  }

  # Bare FINDREP(...) — implicit WHEN=INIT, RawTokens are the findrep items directly.
  if ($KeyWord -eq 'FINDREP') {
    $global:AmtSort.AddInrecIfthenWhenInit()
    Sort-AddFindRepItemsFromTokens -FrTokens $RawTokens
    return
  }

  # KeyWord = 'IFTHEN' — RawTokens contain WHEN=... plus OVERLAY/FINDREP actions.
  # --- Locate WHEN keyword ---
  [Int32]$TI = 0
  while ($TI -lt $RawTokens.Count -and $RawTokens[$TI] -ne 'WHEN') { $TI++ }

  if ($TI -ge $RawTokens.Count) {
    # No WHEN found — treat as WHEN=INIT
    $global:AmtSort.AddInrecIfthenWhenInit()
  } else {
    $TI++  # skip WHEN
    if ($TI -lt $RawTokens.Count -and $RawTokens[$TI] -eq '=') { $TI++ }

    # Collect WHEN clause tokens
    $WhenTokens = [System.Collections.ArrayList]@()
    if ($TI -lt $RawTokens.Count -and $RawTokens[$TI] -eq '(') {
      $TI++  # skip opening (
      [Int32]$WD = 1
      while ($TI -lt $RawTokens.Count -and $WD -gt 0) {
        [String]$WT = $RawTokens[$TI]; $TI++
        if     ($WT -eq '(') { $WD++; [void]$WhenTokens.Add($WT) }
        elseif ($WT -eq ')') { $WD--; if ($WD -gt 0) { [void]$WhenTokens.Add($WT) } }
        else                 { [void]$WhenTokens.Add($WT) }
      }
    } else {
      if ($TI -lt $RawTokens.Count) {
        [void]$WhenTokens.Add($RawTokens[$TI]); $TI++
      }
    }

    # Parse WHEN tokens into structured conditions
    if ($WhenTokens.Count -eq 0 -or $WhenTokens[0] -eq 'INIT') {
      $global:AmtSort.AddInrecIfthenWhenInit()
    } elseif ($WhenTokens[0] -eq 'NONE') {
      # WHEN=NONE — block applies to records not selected by a preceding WHEN=(logexp).
      $global:AmtSort.AddInrecIfthenWhenNone()
    } else {
      # Walk the WHEN tokens, emitting grouping parentheses, trailing logical operators and
      # individual comparison conditions. Parentheses and operators preserve the nested
      # boolean structure so the engine can evaluate AND/OR with correct precedence.
      [Int32]$WI = 0
      while ($WI -lt $WhenTokens.Count) {
        [String]$WT = $WhenTokens[$WI]
        if ($WT -eq ',') { $WI++; continue }
        if ($WT -eq '(') { $global:AmtSort.AddInrecIfthenWhenOpenParen();  $WI++; continue }
        if ($WT -eq ')') { $global:AmtSort.AddInrecIfthenWhenCloseParen(); $WI++; continue }
        if ($WT -eq 'AND') { $global:AmtSort.AddInrecIfthenWhenLogicalOp('AND'); $WI++; continue }
        if ($WT -eq 'OR')  { $global:AmtSort.AddInrecIfthenWhenLogicalOp('OR');  $WI++; continue }
        if (-not ($WT -match '^[\d]+$')) { $WI++; continue }

        [Int32]$Pos = [Int32]$WT; $WI++
        if ($WI -lt $WhenTokens.Count -and $WhenTokens[$WI] -eq ',') { $WI++ }
        [Int32]$Len = [Int32]$WhenTokens[$WI]; $WI++
        if ($WI -lt $WhenTokens.Count -and $WhenTokens[$WI] -eq ',') { $WI++ }
        [String]$Fmt = $WhenTokens[$WI]; $WI++
        if ($WI -lt $WhenTokens.Count -and $WhenTokens[$WI] -eq ',') { $WI++ }
        [String]$Op  = $WhenTokens[$WI]; $WI++
        if ($WI -lt $WhenTokens.Count -and $WhenTokens[$WI] -eq ',') { $WI++ }

        [String]$ValToken = $WhenTokens[$WI]; $WI++
        [String]$CompVal  = ''
        if ($ValToken -eq 'C') {
          [String]$Q = $WhenTokens[$WI]; $WI++
          $CompVal = $Q.Substring(1, $Q.Length - 2)
        } elseif ($ValToken -eq 'X') {
          [String]$Q = $WhenTokens[$WI]; $WI++
          [String]$Hex = $Q.Substring(1, $Q.Length - 2)
          [System.Text.StringBuilder]$HSb = New-Object System.Text.StringBuilder
          [Int32]$HI = 0
          while ($HI -lt $Hex.Length - 1) {
            [void]$HSb.Append([Char][Convert]::ToInt32($Hex.Substring($HI, 2), 16))
            $HI += 2
          }
          $CompVal = $HSb.ToString()
        } else {
          $CompVal = $ValToken
        }

        # Trailing logical operator (if any) is emitted by the AND/OR branch above.
        $global:AmtSort.AddInrecIfthenWhenCondition($Pos, $Len, $Fmt, $Op, $CompVal, '')
      }
    }
  }

  # --- OVERLAY actions (scan the raw tokens for all OVERLAY=(...) groups) ---
  # A single IFTHEN may contain more than one OVERLAY clause; process every one.
  [Int32]$OAI = 0
  while ($OAI -lt $RawTokens.Count) {
    if ($RawTokens[$OAI] -ne 'OVERLAY') { $OAI++; continue }
    $OAI++  # skip OVERLAY
    if ($OAI -lt $RawTokens.Count -and $RawTokens[$OAI] -eq '=') { $OAI++ }
    if ($OAI -lt $RawTokens.Count -and $RawTokens[$OAI] -eq '(') { $OAI++ }

    # Collect OVERLAY tokens within balanced parens (depth already opened)
    $OverlayTokens = [System.Collections.ArrayList]@()
    [Int32]$AD = 1
    while ($OAI -lt $RawTokens.Count -and $AD -gt 0) {
      [String]$AT = $RawTokens[$OAI]; $OAI++
      if     ($AT -eq '(') { $AD++; [void]$OverlayTokens.Add($AT) }
      elseif ($AT -eq ')') { $AD--; if ($AD -gt 0) { [void]$OverlayTokens.Add($AT) } }
      else                 { [void]$OverlayTokens.Add($AT) }
    }
    Sort-AddOverlayItemsFromTokens -OverlayTokens $OverlayTokens
  }

  # --- BUILD actions (scan the raw tokens for all BUILD=(...) groups) ---
  # BUILD rebuilds the record from an empty buffer; the item list shares the OVERLAY structure,
  # so the C# block is flagged via SetIfthenBuild() and the items are added the same way.
  [Int32]$BAI = 0
  while ($BAI -lt $RawTokens.Count) {
    if ($RawTokens[$BAI] -ne 'BUILD') { $BAI++; continue }
    $BAI++  # skip BUILD
    if ($BAI -lt $RawTokens.Count -and $RawTokens[$BAI] -eq '=') { $BAI++ }
    if ($BAI -lt $RawTokens.Count -and $RawTokens[$BAI] -eq '(') { $BAI++ }

    # Collect BUILD tokens within balanced parens (depth already opened)
    $BuildTokens = [System.Collections.ArrayList]@()
    [Int32]$BD = 1
    while ($BAI -lt $RawTokens.Count -and $BD -gt 0) {
      [String]$BT = $RawTokens[$BAI]; $BAI++
      if     ($BT -eq '(') { $BD++; [void]$BuildTokens.Add($BT) }
      elseif ($BT -eq ')') { $BD--; if ($BD -gt 0) { [void]$BuildTokens.Add($BT) } }
      else                 { [void]$BuildTokens.Add($BT) }
    }
    $global:AmtSort.SetIfthenBuild()
    Sort-AddOverlayItemsFromTokens -OverlayTokens $BuildTokens
  }

  # --- FINDREP actions (scan the raw tokens for FINDREP=(...) groups) ---
  [Int32]$FI = 0
  while ($FI -lt $RawTokens.Count) {
    if ($RawTokens[$FI] -ne 'FINDREP') { $FI++; continue }
    $FI++  # skip FINDREP
    if ($FI -lt $RawTokens.Count -and $RawTokens[$FI] -eq '=') { $FI++ }
    if ($FI -lt $RawTokens.Count -and $RawTokens[$FI] -eq '(') { $FI++ }

    # Collect FINDREP tokens within balanced parens
    $FrTokens = [System.Collections.ArrayList]@()
    [Int32]$FD = 1
    while ($FI -lt $RawTokens.Count -and $FD -gt 0) {
      [String]$FT = $RawTokens[$FI]; $FI++
      if     ($FT -eq '(') { $FD++; [void]$FrTokens.Add($FT) }
      elseif ($FT -eq ')') { $FD--; if ($FD -gt 0) { [void]$FrTokens.Add($FT) } }
      else                 { [void]$FrTokens.Add($FT) }
    }
    Sort-AddFindRepItemsFromTokens -FrTokens $FrTokens
  }
} # Sort-AddIfthenBlockItems

function Resolve-SortDateSymbol {
  <#
    .SYNOPSIS
      Resolve a DFSORT run-date symbol (DATE1..DATE6 with optional Y suffix, optional
      +/-day arithmetic, plus LASTDAYM) to a constant literal string for the current run.
    .DESCRIPTION
      The base date is taken from $global:RunDate (format MM/dd/yy or MM/dd/yyyy as set by
      the job via SetRunDate) when available, otherwise the current system date is used.
      Supported symbols (IBM DFSORT OUTFIL/INREC OVERLAY):
        DATE1  YYYYMMDD               (8 bytes; arithmetic DATE1+d/DATE1-d uses days)
        DATE2  YYYYMM                 (6 bytes; arithmetic DATE2+m/DATE2-m uses months)
        DATE3  YYYYddd                (7 bytes, Julian; arithmetic in days)
        DATE4  YYYY-MM-DD-HH.MM.SS    (19 bytes, timestamp)
        DATE5  YYYY-MM-DD-HH.MM.SS.nnnnnn  (26 bytes, timestamp with microseconds)
        LASTDAYM  last day of the current month (YYYYMMDD)
      For DATE2, +n/-n adjusts by n months. For DATE1/DATE3, by n days.
    .PARAMETER Symbol
      [String] The date symbol token, e.g. 'DATE2', 'DATE1Y', 'DATE2-1', 'LASTDAYM'.
    .PARAMETER Modifiers
      [Object] Optional list of modifier tokens (Y4T, Y2T, TOJUL, TOGREG).
    .OUTPUTS
      [String] The resolved literal, or '' when the symbol is not a run-date symbol.
  #>
  param (
    [Parameter(Mandatory=$true)][String]$Symbol,
    [Object]$Modifiers = $null
  )

  # --- Determine the base run date --------------------------------------------
  [String]$RunDateVal = ''
  $RdVar = Get-Variable -Name 'RunDate' -Scope Global -ErrorAction SilentlyContinue
  if ($null -ne $RdVar -and $null -ne $RdVar.Value) { $RunDateVal = [String]$RdVar.Value }

  [DateTime]$BaseDate = [DateTime]::Now
  if (-not [String]::IsNullOrWhiteSpace($RunDateVal)) {
    [DateTime]$Parsed = [DateTime]::MinValue
    [String[]]$Fmts = @('MM/dd/yy','MM/dd/yyyy','MMddyy','MMddyyyy','yyyy-MM-dd','yyyyMMdd')
    if ([DateTime]::TryParseExact($RunDateVal.Trim(), $Fmts,
          [System.Globalization.CultureInfo]::InvariantCulture,
          [System.Globalization.DateTimeStyles]::None, [ref]$Parsed)) {
      $BaseDate = $Parsed
    }
  }

  # --- LASTDAYM ---------------------------------------------------------------
  if ($Symbol -eq 'LASTDAYM') {
    [DateTime]$Last = [DateTime]::new($BaseDate.Year, $BaseDate.Month, 1).AddMonths(1).AddDays(-1)
    return $Last.ToString('yyyyMMdd')
  }

  # --- Parse DATEn[Y][+/-offset] (IBM DFSORT: DATE1=YYYYMMDD, DATE2=YYYYMM, DATE3=YYYYddd) ---
  if ($Symbol -notmatch '^DATE([1-5])(Y)?([+-]\d+)?$') { return '' }
  [Int32]$Kind   = [Int32]$Matches[1]
  [Int32]$Offset = 0
  if ($Matches[3]) { $Offset = [Int32]$Matches[3] }

  # DATE2 arithmetic is in months; DATE1 and DATE3 are in days.
  if ($Offset -ne 0) {
    if ($Kind -eq 2) {
      $BaseDate = $BaseDate.AddMonths($Offset)
    } else {
      $BaseDate = $BaseDate.AddDays($Offset)
    }
  }

  [String]$DDD = $BaseDate.DayOfYear.ToString('000')

  switch ($Kind) {
    1 { return $BaseDate.ToString('yyyyMMdd') }                               # DATE1 = YYYYMMDD
    2 { return $BaseDate.ToString('yyyyMM') }                                 # DATE2 = YYYYMM
    3 { return ($BaseDate.ToString('yyyy') + $DDD) }                          # DATE3 = YYYYddd (Julian)
    4 { return $BaseDate.ToString('yyyy-MM-dd-HH.mm.ss') }                    # DATE4 = timestamp
    5 { return ($BaseDate.ToString('yyyy-MM-dd-HH.mm.ss') + '.000000') }      # DATE5 = with microseconds
  }
  return ''
} # Resolve-SortDateSymbol

function Resolve-OverlayField {
  <#
    .SYNOPSIS
      Read a literal string of Len characters starting at Pos from a virtual-record hashtable
      (keyed by 1-based column position) built up by Sort-AddOverlayItemsFromTokens.
      Returns '' if any character position in the range is not yet known.
  #>
  param (
    [Parameter(Mandatory=$true)][hashtable]$VirtualRecord,
    [Parameter(Mandatory=$true)][Int32]$Pos,
    [Parameter(Mandatory=$true)][Int32]$Len
  )
  [System.Text.StringBuilder]$sb = New-Object System.Text.StringBuilder
  for ([Int32]$i = 0; $i -lt $Len; $i++) {
    if (-not $VirtualRecord.ContainsKey($Pos + $i)) { return '' }
    [void]$sb.Append([Char]$VirtualRecord[$Pos + $i])
  }
  return $sb.ToString()
} # Resolve-OverlayField

function Resolve-SortLastDayOfMonth {
  <#
    .SYNOPSIS
      Compute the last day of the month for a date given as an 8-char YYYYMMDD string.
      Returns the last day of that month also formatted as YYYYMMDD.
      Returns '' when the input cannot be parsed.
  #>
  param (
    [Parameter(Mandatory=$true)][String]$DateStr
  )
  if ($DateStr.Length -lt 6) { return '' }
  [Int32]$Year  = 0
  [Int32]$Month = 0
  if (-not [Int32]::TryParse($DateStr.Substring(0, 4), [ref]$Year))  { return '' }
  if (-not [Int32]::TryParse($DateStr.Substring(4, 2), [ref]$Month)) { return '' }
  if ($Year -lt 1 -or $Year -gt 9999 -or $Month -lt 1 -or $Month -gt 12) { return '' }
  [Int32]$LastDay = [DateTime]::DaysInMonth($Year, $Month)
  return ('{0:D4}{1:D2}{2:D2}' -f $Year, $Month, $LastDay)
} # Resolve-SortLastDayOfMonth

function Sort-AddOverlayItemsFromTokens {
  <#
    .SYNOPSIS
      Parse OVERLAY item tokens (the content between the OVERLAY(...) parentheses) and register
      each item on the current IFTHEN block via AddInrecIfthenOverlayItem.
    .PARAMETER OverlayTokens
      [System.Collections.ArrayList] Tokens of the OVERLAY item list (without outer parens).
  #>
  param (
    [Parameter(Mandatory=$true)][Object]$OverlayTokens
  )

  [Int32]$OI     = 0
  [Int32]$CurPos = 1
  [hashtable]$VirtualRecord = @{}  # Tracks literal bytes written so far (key = 1-based column).
  while ($OI -lt $OverlayTokens.Count) {
    [String]$OT = $OverlayTokens[$OI]
    if ($OT -eq ',' -or $OT -eq ')') { $OI++; continue }

    # Determine explicit output position
    [Int32]$OutPos        = $CurPos
    [Boolean]$HasExplicit = $false
    if ($OT -match '^[\d]+$' -and
        $OI + 1 -lt $OverlayTokens.Count -and $OverlayTokens[$OI + 1] -eq ':') {
      $OutPos      = [Int32]$OT
      $HasExplicit = $true
      $OI          = $OI + 2   # consume pos and ':'
    }

    [String]$ValTok = $OverlayTokens[$OI]; $OI++
    [String]$Value  = ''
    [Int32]$InPos   = -1
    [Int32]$InLen   = 0

    if ($ValTok -eq 'C') {
      [String]$Q = $OverlayTokens[$OI]; $OI++
      $Value = $Q.Substring(1, $Q.Length - 2)
    } elseif ($ValTok -eq 'X') {
      if ($OI -lt $OverlayTokens.Count -and $OverlayTokens[$OI] -match "^'") {
        # X'hex' form — one or more hex-encoded bytes, optionally followed by a repeat length.
        [String]$Q        = $OverlayTokens[$OI]; $OI++
        [String]$Hex      = $Q.Substring(1, $Q.Length - 2)
        [System.Text.StringBuilder]$XSb = New-Object System.Text.StringBuilder
        [Int32]$XI = 0
        while ($XI -lt $Hex.Length - 1) {
          [void]$XSb.Append([Char][Convert]::ToInt32($Hex.Substring($XI, 2), 16))
          $XI += 2
        }
        [String]$SingleByte = $XSb.ToString()
        $Value = $SingleByte
        if ($OI -lt $OverlayTokens.Count -and $OverlayTokens[$OI] -eq ',') { $OI++ }
        if ($OI -lt $OverlayTokens.Count -and $OverlayTokens[$OI] -match '^[\d]+$' -and
            -not ($OI + 1 -lt $OverlayTokens.Count -and $OverlayTokens[$OI + 1] -eq ':')) {
          [Int32]$XLen = [Int32]$OverlayTokens[$OI]; $OI++
          [System.Text.StringBuilder]$XPad = New-Object System.Text.StringBuilder
          while ($XPad.Length -lt $XLen) { [void]$XPad.Append($SingleByte) }
          $Value = $XPad.ToString().Substring(0, $XLen)
          if ($OI -lt $OverlayTokens.Count -and $OverlayTokens[$OI] -eq ',') { $OI++ }
        }
      } else {
        # Bare X — a single blank byte.
        $Value = ' '
        if ($OI -lt $OverlayTokens.Count -and $OverlayTokens[$OI] -eq ',') { $OI++ }
      }
    } elseif ($ValTok -eq 'Z') {
      # Bare Z — a single binary-zero byte.
      $Value = [String][Char]0
      if ($OI -lt $OverlayTokens.Count -and $OverlayTokens[$OI] -eq ',') { $OI++ }
    } elseif ($ValTok -match '^[\d]+[XZxz]$') {
      [Int32]$Count = [Int32]($ValTok -replace '[XZxz]', '')
      $Value = ' ' * $Count
      if ($OI -lt $OverlayTokens.Count -and $OverlayTokens[$OI] -eq ',') { $OI++ }
    } elseif ($ValTok -match '^DATE[1-5]' -or $ValTok -eq 'LASTDAYM') {
      # DFSORT run-date symbol — resolve to a constant literal for this run.
      # Collect trailing modifier tokens (Y4T/Y2T/TOJUL/TOGREG) belonging to this item.
      [System.Collections.ArrayList]$Mods = [System.Collections.ArrayList]@()
      while ($OI + 1 -lt $OverlayTokens.Count -and $OverlayTokens[$OI] -eq ',' -and
             $OverlayTokens[$OI + 1] -match '^(Y4T|Y2T|TOJUL|TOGREG)$') {
        $OI++                                       # consume comma
        [void]$Mods.Add($OverlayTokens[$OI]); $OI++ # consume modifier
      }
      $Value = Resolve-SortDateSymbol -Symbol $ValTok -Modifiers $Mods
    } elseif ($ValTok -match '^[\d]+$') {
      if ($OI -lt $OverlayTokens.Count -and
          ($OverlayTokens[$OI] -eq 'X' -or $OverlayTokens[$OI] -eq 'Z')) {
        [Int32]$Count = [Int32]$ValTok; $OI++
        $Value = ' ' * $Count
        if ($OI -lt $OverlayTokens.Count -and $OverlayTokens[$OI] -eq ',') { $OI++ }
      } else {
        $InPos = [Int32]$ValTok
        if ($OI -lt $OverlayTokens.Count -and $OverlayTokens[$OI] -eq ',') { $OI++ }
        $InLen = [Int32]$OverlayTokens[$OI]; $OI++
        if ($OI -lt $OverlayTokens.Count -and $OverlayTokens[$OI] -eq ',') { $OI++ }
        # Optional InFmt — consume and save.
        [String]$InFmt = ''
        if ($OI -lt $OverlayTokens.Count -and
            $OverlayTokens[$OI] -match '^[A-Za-z]' -and
            $OverlayTokens[$OI] -ne 'C' -and $OverlayTokens[$OI] -ne 'X' -and
            -not ($OI + 1 -lt $OverlayTokens.Count -and $OverlayTokens[$OI + 1] -eq ':')) {
          $InFmt = $OverlayTokens[$OI]; $OI++
          if ($OI -lt $OverlayTokens.Count -and $OverlayTokens[$OI] -eq ',') { $OI++ }
        }
        # Consume date arithmetic modifiers; support LASTDAYM + TOGREG=Yxx.
        [Boolean]$HasLastDayM = $false
        [String]$ToGregFmt    = ''
        while ($OI -lt $OverlayTokens.Count) {
          [String]$Tok = $OverlayTokens[$OI]
          if ($Tok -eq ',') { $OI++; continue }
          if ($Tok -eq ')' -or ($Tok -match '^[\d]+$') -or $Tok -eq 'C' -or $Tok -eq 'X') { break }
          if ($Tok -eq 'LASTDAYM') { $HasLastDayM = $true }
          $OI++
          if ($OI -lt $OverlayTokens.Count -and $OverlayTokens[$OI] -eq '=') {
            $OI++  # skip '='
            if ($OI -lt $OverlayTokens.Count) {
              if ($Tok -eq 'TOGREG') { $ToGregFmt = $OverlayTokens[$OI] }
              $OI++  # skip value
            }
          }
          if ($OI -lt $OverlayTokens.Count -and $OverlayTokens[$OI] -eq ',') { $OI++ }
        }
        # When LASTDAYM is requested, resolve last-day-of-month from prior overlay literals.
        if ($HasLastDayM -and $InPos -gt 0) {
          [String]$FieldLit = Resolve-OverlayField -VirtualRecord $VirtualRecord -Pos $InPos -Len $InLen
          if (-not [String]::IsNullOrEmpty($FieldLit)) {
            $Value = Resolve-SortLastDayOfMonth -DateStr $FieldLit
          }
        }
      }
    }

    if ($Value.Length -eq 0 -and $InPos -le 0) {
      if ($HasExplicit) { $CurPos = $OutPos }
      continue
    }

    if ($Value.Length -gt 0) {
      # Literal item
      $global:AmtSort.AddInrecIfthenOverlayItem($OutPos, -1, 0, $Value)
      # Record written bytes in the virtual overlay buffer for subsequent LASTDAYM lookups.
      for ([Int32]$RI = 0; $RI -lt $Value.Length; $RI++) {
        $VirtualRecord[$OutPos + $RI] = $Value[$RI]
      }
      $CurPos = $OutPos + $Value.Length
    } else {
      # Field-copy item
      $global:AmtSort.AddInrecIfthenOverlayItem($OutPos, $InPos, $InLen, '')
      $CurPos = $OutPos + $InLen
    }
  }
} # Sort-AddOverlayItemsFromTokens

function Sort-AddFindRepItemsFromTokens {
  <#
    .SYNOPSIS
      Parse FINDREP item tokens (the content between the FINDREP(...) parentheses) and register
      one find/replace item on the current IFTHEN block via AddIfthenFindRepItem.
      Supports IN=, OUT=, STARTPOS= and ENDPOS= with C'..'/X'..' or bare literals.
    .PARAMETER FrTokens
      [System.Collections.ArrayList] Tokens of the FINDREP item list (without outer parens).
  #>
  param (
    [Parameter(Mandatory=$true)][Object]$FrTokens
  )

  [String]$InVal    = ''
  [Boolean]$HasIn   = $false
  [String]$OutVal   = ''
  [Int32]$StartPos  = 0
  [Int32]$EndPos    = 0
  [Int32]$KI        = 0
  while ($KI -lt $FrTokens.Count) {
    [String]$KT = $FrTokens[$KI]
    if ($KT -eq ',' -or $KT -eq '(' -or $KT -eq ')') { $KI++; continue }

    if ($KT -eq 'IN' -or $KT -eq 'OUT') {
      [String]$Key = $KT; $KI++
      if ($KI -lt $FrTokens.Count -and $FrTokens[$KI] -eq '=') { $KI++ }
      [String]$Lit = ''
      if ($KI -lt $FrTokens.Count -and $FrTokens[$KI] -eq 'C') {
        $KI++
        [String]$Q = $FrTokens[$KI]; $KI++
        $Lit = $Q.Substring(1, $Q.Length - 2)
      } elseif ($KI -lt $FrTokens.Count -and $FrTokens[$KI] -eq 'X') {
        $KI++
        [String]$Q = $FrTokens[$KI]; $KI++
        [String]$Hex = $Q.Substring(1, $Q.Length - 2)
        [System.Text.StringBuilder]$FSb = New-Object System.Text.StringBuilder
        [Int32]$FHI = 0
        while ($FHI -lt $Hex.Length - 1) {
          [void]$FSb.Append([Char][Convert]::ToInt32($Hex.Substring($FHI, 2), 16))
          $FHI += 2
        }
        $Lit = $FSb.ToString()
      } elseif ($KI -lt $FrTokens.Count) {
        $Lit = $FrTokens[$KI]; $KI++
      }
      if ($Key -eq 'IN') { $InVal = $Lit; $HasIn = $true } else { $OutVal = $Lit }
      continue
    }

    if ($KT -eq 'STARTPOS') {
      $KI++
      if ($KI -lt $FrTokens.Count -and $FrTokens[$KI] -eq '=') { $KI++ }
      if ($KI -lt $FrTokens.Count) { $StartPos = [Int32]$FrTokens[$KI]; $KI++ }
      continue
    }

    if ($KT -eq 'ENDPOS') {
      $KI++
      if ($KI -lt $FrTokens.Count -and $FrTokens[$KI] -eq '=') { $KI++ }
      if ($KI -lt $FrTokens.Count) { $EndPos = [Int32]$FrTokens[$KI]; $KI++ }
      continue
    }

    $KI++
  }

  if ($HasIn) {
    $global:AmtSort.AddIfthenFindRepItem($InVal, $OutVal, $StartPos, $EndPos)
  }
} # Sort-AddFindRepItemsFromTokens



function Sort-SetError() {
  <#
    .SYNOPSIS
      Sets the error status, and sends an error message to the Control Center.
    .PARAMETER Message
      [String] Message
  #>
  param (
    [String]$Message
  )
  if (-not [String]::IsNullOrEmpty($Message)) {
    Add-ErrorMsg -Message $Message
  }
  $global:HasHadError = $True
  if ($Null -ne $global:ObjTaskSort) {
    $global:ObjTaskSort.TaskValue = 1
    $global:ObjTaskSort.ProcessOk = $False
  }
} # Sort-SetError
