# Read-GnSgsImages on raw runstream SGS text vs the exported card files (continuations and embedded semicolons).
$ErrorActionPreference = 'Stop'
. "$(Split-Path (Split-Path $PSScriptRoot))\GnHandoff.ps1"
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
$tmp = Join-Path $env:TEMP 'gn-images.sgs'
function Show($lines) { [IO.File]::WriteAllLines($tmp, [String[]]$lines, $latin1); foreach ($i in (Read-GnSgsImages $tmp)) { "  [$i]" } }
'PAIJ01_UL raw (continued with '' ;''):'
Show @("PG CASE 74,2,''  '' 81,5,''     '' 1,4,''0000'' ", 'PG MOVE 3,2,1 5,29,3 34,4,32,D42 38,61,34 99,4,95,D42 103,2,97 ;', '        105,4,99,D42 109,100,101', 'PG OTHERWISE')
'PBDA04_L339 raw (embedded '';'' after a quote = data, next line is its own image):'
Show @("FIXE       2,6,'POLICE' 10,7,'ANN TRF' 20,9,'MATRICULE';", "32,29,'MULTIPLES COUCHE HIST ENCOURS'")
'PBDA04_L199 raw (continued, comment after the semicolon ignored):'
Show @("FIXE       2,6,'POLICE' 10,7,'BRANCHE' 20,9,'MATRICULE' ;   ignored", "           32,27,'MULTIPLES COUCHE HIST 31/12'", 'STITRE YES')
'comma continuation and a continued last line (dropped):'
Show @('FIELDIN 6,7,;', '13 19,6', 'LAST ;')
'split:'
(Split-GnSgsImage "FIXE 2,6,'POLICE' 10,7,'ANN TRF' 20,9,'MATRICULE'; 1,4,''0 0'' 5,2,SPACES") | ForEach-Object { '  ' + (($_ | ForEach-Object { "<$_>" }) -join ' ') }
