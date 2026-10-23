$ex = 'E:\Repos\SsgTrial\SsgConverter\Examples\Input'
$names = 'ACCSGS$','ADD_GOS$','CASE$','CASECHAR$','COLED$','CONFLC$','CSFSTA$','EDITAB$','EOF$','ERRCNT$','FEATURE_LEVEL$','FLD$','GOSCNT$','IMGLEN$','IOPT$','LBRK$','MOPT$','NEW_BOOLEAN$','NEW_PROCESS$','NOFND$','NOPT$','NSIGN$','NSIGNCHAR$','PCFNAME$','PILO$','PILOCHAR$','PROCESS_LEVEL$','PRTOFF$','RTC$','SFLD$','SGSADDCNT$','SGSCNT$','SKELINE$','SKELINECNT$','SOPT$','SSGSGS$','STARTCHAR$','STMT$','STOPCHAR$','STRINGCHAR$','TCFNAME$','UNS_CONTROL$','UNS_INPUT$','UTC$','WARNINGCNT$','WARNINGFLG$','ZOPT$'
'== reserved variables used in the 20 example inputs (file: count)'
$any = $false
foreach ($n in $names) {
  $hits = Get-ChildItem $ex -File | Select-String -SimpleMatch -Pattern $n -CaseSensitive:$false
  if ($hits) { $any = $true; '{0,-16} {1}' -f $n, (($hits | Group-Object Filename | ForEach-Object { '{0}:{1}' -f $_.Name, $_.Count }) -join ', ') }
}
if (-not $any) { 'none' }
'== uses of m_SystemVariables in the processor'
Select-String -Path 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter\SymstreamProcessor.cs' -Pattern 'm_SystemVariables|IsSystemVariable' | ForEach-Object { '{0}: {1}' -f $_.LineNumber, $_.Line.Trim().Substring(0, [Math]::Min(130, $_.Line.Trim().Length)) }
