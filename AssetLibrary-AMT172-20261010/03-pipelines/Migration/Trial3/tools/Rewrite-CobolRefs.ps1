# Rewrites external ProjectReferences -> deps-DLL References across the Cobol* + VsGenerator projects.
# Keeps local source refs (CobolConverter/CobolAnalyser/CobolConverterSupport/CobolMigrator) and
# repoints the VsGenerator ref to its real 260707 source location.
$ErrorActionPreference = 'Stop'

$vsGenProj = 'C:\Amt\Parallel\AMT175\AmtLion\Lion\VsGenerator\VsGenerator.csproj'

# basename (lowercased, no .csproj) -> deps DLL name (as it exists in _coboldeps)
$dllMap = @{
  'asysco.amt.libs'                = 'Asysco.Amt.Libs'
  'asysco.amt.amtshareddatamodel'  = 'Asysco.Amt.AmtSharedDataModel'
  'convertersupport'               = 'ConverterSupport'
  'asysco.migration.sqlanalyser'   = 'Asysco.Migration.SqlAnalyser'
  'asysco.migration.sqlparser'     = 'Asysco.Migration.SqlParser'
  'asysco.migration.sqlgenerator'  = 'Asysco.Migration.SqlGenerator'
  'dbdefinitionreaders'            = 'DBDefinitionReaders'
  'cobolparser'                    = 'CobolParser'
  'lionrepository'                 = 'LionRepository'
  'xgenconverter'                  = 'XGenConverter'
  'xgenparser'                     = 'XgenParser'
  'cobolconvertersupport'          = 'CobolConverterSupport'
  'cobolanalyser'                  = 'CobolAnalyser'
}
# local source projects to KEEP as ProjectReference (built from 260707 source)
$keep = @('cobolconverter','cobolmigrator')

$targets = @(
  'C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\CobolToAmt\CobolToAmt\CobolAnalyser\CobolAnalyser.csproj'
  'C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\CobolToAmt\CobolToAmt\CobolConverter\CobolConverter.csproj'
  'C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\CobolToAmt\CobolToAmt\CobolMigrator\CobolMigrator.csproj'
  'C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\CobolToAmt\CobolToAmt\CobolConverterConsole\CobolConverterConsole.csproj'
  $vsGenProj
)

foreach ($proj in $targets) {
  if (-not (Test-Path $proj)) { Write-Host "MISSING $proj" -ForegroundColor Red; continue }
  $lines = Get-Content $proj
  $out = foreach ($ln in $lines) {
    if ($ln -match '<ProjectReference\s+Include="([^"]+)"') {
      $inc  = $matches[1]
      $base = [System.IO.Path]::GetFileNameWithoutExtension($inc).ToLower()
      if ($keep -contains $base) {
        $ln                                   # keep local source ref as-is
      } elseif ($base -eq 'vsgenerator') {
        "    <ProjectReference Include=`"$vsGenProj`" />"   # repoint to real 260707 source
      } elseif ($dllMap.ContainsKey($base)) {
        $dll = $dllMap[$base]
        "    <Reference Include=`"$dll`"><HintPath>`$(CobolDeps)$dll.dll</HintPath></Reference>"
      } else {
        Write-Host "  UNMAPPED ref in $([IO.Path]::GetFileName($proj)): $inc" -ForegroundColor Yellow
        $ln
      }
    } else { $ln }
  }
  Set-Content -Path $proj -Value $out -Encoding UTF8
  Write-Host "rewrote $([IO.Path]::GetFileName($proj))" -ForegroundColor Green
}
