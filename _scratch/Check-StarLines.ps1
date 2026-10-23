$ex = 'E:\Repos\SsgTrial\SsgConverter\Examples\Input'
$dir = 'ABORT','ACCEPT','ADD','BRKPT','CLEAR','COPY','CORRECT','CREATE','CSF','DEFINE','DISPLAY','DIVIDE','DLOC','DO','DUMP','EDIT','EJECT','ELSE','ELSEIF','ENDCORRECT','ENDDEFINE','ENDDO','ENDIF','EXIT','IF','INCREMENT','ITERATE','LIST','LOOP','MERGE','MESSAGE','MULTIPLY','PCONTROL','PROCESS','REMOVE','RESTORE','RETURN','SAVE','SET','SORT','UNLIST','WAIT','END','ELSF'
$rows = foreach ($f in Get-ChildItem $ex -File) {
  $defs = @{}
  $lines = [IO.File]::ReadAllLines($f.FullName)
  foreach ($l in $lines) { if ($l -match '^\*\s*DEFINE\s+(\S+)') { $defs[$Matches[1].ToUpper()] = 1 } }
  $n = 0
  foreach ($l in $lines) {
    $n++
    if ($l.StartsWith('*') -and $l -notmatch '^\*\s*\.') {
      $w = ($l.Substring(1).Trim() -split '[\s,(]')[0].ToUpper()
      if ($w -and ($dir -notcontains $w)) { [pscustomobject]@{ File = $f.Name; Line = $n; Word = $w; IsDefinedInFile = $defs.ContainsKey($w); Text = $l.Trim() } }
    }
  }
}
'== * lines in the 20 inputs whose first word is not a known directive: {0}' -f @($rows).Count
$rows | Group-Object File, Word, IsDefinedInFile | ForEach-Object { $r = $_.Group[0]; '{0,-24} {1,-14} defined-in-file={2,-5} x{3}   e.g. {4}' -f $r.File, $r.Word, $r.IsDefinedInFile, $_.Count, $r.Text.Substring(0, [Math]::Min(60, $r.Text.Length)) }
'== * lines that are comments (*.) in the inputs: ' + ((Get-ChildItem $ex -File | ForEach-Object { [IO.File]::ReadAllLines($_.FullName) | Where-Object { $_ -match '^\*\s*\.' } }).Count)
'== lines with * in column 1 that look like COBOL comments (text after * starts with a space and has COBOL-ish words)'
$c = 0; foreach ($f in Get-ChildItem $ex -File) { foreach ($l in [IO.File]::ReadAllLines($f.FullName)) { if ($l -match '^\*\s{2,}\S' -and $l -notmatch '^\*\s*\.') { $c++ ; if ($c -le 5) { '{0}: {1}' -f $f.Name, $l.Substring(0, [Math]::Min(80, $l.Length)) } } } }; 'count: ' + $c
