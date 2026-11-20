# Check 1 (261119): run R&D's converted SYS$*RUNS.FILE/SSG skeleton (VIRA05 L55) as AMT's Invoke-Ssg would: StrictMode 2,
# with the call's own cards (FILE FKTPPRJASC / JUMP LAB030). AMT primitives are stubbed (recorded, no side effects); Log-Message is
# NOT stubbed because neither Federale library (Scripts\Libraries, 261112) defines it. Read-only on the Federale repo.
param([String]$Skeleton = 'E:\Repos\Federale_InternalRelease\Scripts\SYS$_RUNS\RUNS_FILE_SSG.ps1')
$ErrorActionPreference = 'Stop'
$results = foreach ($case in @(@{ Name = 'file found'; Csf = '0' }, @{ Name = 'file not found'; Csf = '400010000000' })) {
  $calls = New-Object System.Collections.Generic.List[String]
  $sgs = @{ 'FILE' = '1'; 'FILE,1,1,1' = 'FKTPPRJASC'; 'JUMP,1,1,1' = 'LAB030'; 'CSFSTA$,1,1,1' = $case.Csf }
  function global:GetSgsValue([String]$Name) { $script:calls.Add("GetSgsValue $Name"); $script:sgs[$Name] }
  function global:Asg { $script:calls.Add("Asg $($args -join ' ')") }
  function global:Free { $script:calls.Add("Free $($args -join ' ')") }
  function global:Jump { $script:calls.Add("Jump $($args -join ' ')") }
  function global:CompareTypeSafe($a, [String]$op, $b) { "$a" -eq "$b" }
  $verdict = 'completed'
  try { & { Set-StrictMode -Version 2; . $Skeleton } }
  catch { $verdict = "FAILED at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)" }
  [pscustomobject]@{ Case = $case.Name; Result = $verdict; Calls = ($calls -join ' | ') }
}
$results | Format-List
