<#
.SYNOPSIS
  Completes the isolated mock-system runner folder so AMT's runtime can open a SQL Server connection.
.DESCRIPTION
  The runner folder is a copy of the generated program binaries with no deps.json, so the real
  Microsoft.Data.SqlClient implementation (runtimes\win\lib) and the native SNI DLL must sit beside the exe
  (same cause as T3-013: the root-level SqlClient assembly is the platform-neutral stub). Copies only what is
  missing from the Lion tools' AmtAid folder, then swaps in the real SqlClient and SNI. Never touches AmtTools of Federale.
#>
param(
  [String]$Run = 'E:\AMT_Work\MockSystem\Run',
  [String]$AmtAid = 'E:\Amt\AMTTools\AmtAid',
  [String]$Wrapper = 'E:\Amt\AMTTools\SqlServerWrapper'
)
$ErrorActionPreference = 'Stop'
if ($Run -notlike 'E:\AMT_Work\MockSystem\*') { throw 'Run folder must be under E:\AMT_Work\MockSystem.' }
Copy-Item (Join-Path $Wrapper 'Asysco.Amt.AmtSqlServerWrapper.dll') $Run -Force
robocopy $AmtAid $Run *.dll /XC /XN /XO /NFL /NDL /NJH /NJS /NP | Out-Null   # only files not already present
Copy-Item (Join-Path $AmtAid 'runtimes\win\lib\net9.0\Microsoft.Data.SqlClient.dll') $Run -Force
Copy-Item (Join-Path $AmtAid 'runtimes\win-x64\native\Microsoft.Data.SqlClient.SNI.dll') $Run -Force
'{0} files in {1}' -f (Get-ChildItem $Run -File).Count, $Run
