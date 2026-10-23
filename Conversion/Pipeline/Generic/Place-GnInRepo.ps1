<#
.SYNOPSIS
  SSG-4: place the generic programs into a Federale_InternalRelease worktree the way the repository is laid out (no separate drop folder).
.DESCRIPTION
  - BSP_AMT\Development\Utilities\<Program>\  the LionDev-generated C# project of each generic program, made relative like the
    application's own programs (framework ..\..\..\..\AmtFramework, application ..\..\), the generation date/time dropped from base(...)
    (the repository's AmtBaseCobolProgram has the 4-argument constructor only), and the COBOL it was generated from as
    Documentation\<PROGRAM-ID>.cob (Content, as the application's programs carry their documentation).
  - BSP_AMT\Development\Utilities\README.md   what the folder holds and how it is used (written by this script).
  - _All_.sln                                 one entry per project in solution folder "Utilities" (Build-And-Publish.ps1 builds only _All_.sln).
  - Scripts\ASSURFED_UTILIT                   the hand-off skeletons and includes (replace R&D's failed-conversion stubs, MT-046).
  - Scripts\Settings\AmtSettings.xml          the CloneReports entries only (AppName/UseUnicode are left to R&D, MT-046).
  Nothing is committed; the caller (elevated, the repository .git is ACL-restricted) reviews and commits.
#>
param(
  [String]$Worktree = 'E:\Repos\Federale_InternalRelease-wt-ssg4',
  [String]$Environment = 'Repo-BSP',
  [String]$SkeletonEnvironment = 'CC-Federale',
  [Switch]$SkipSolution,
  # Build each placed project (and the framework/application projects it references) in the worktree; log to -BuildLog.
  [Switch]$Build,
  [String]$BuildLog = 'E:\Repos\ssg4-work\place-gn-build.txt',
  # Release name; refreshes the generated parts of Utilities\PROGRAM-SUMMARY.md (Update-GnProgramSummary.ps1).
  [String]$Release
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$sk = Get-GnEnvironment $SkeletonEnvironment
$catalog = Get-Content "$PSScriptRoot\utilities.json" -Raw | ConvertFrom-Json
$app = "$Worktree\$($ge.LionApp)_AMT"
$dev = "$app\Development"
$util = "$dev\Utilities"
if (-not (Test-Path "$dev\_All_.sln")) { throw "no $dev\_All_.sln" }
$folderOf = { param($n) ($n.ToLowerInvariant() -split '_' | ForEach-Object { $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1) }) -join '_' }
$report = @()

$gen = @($catalog.utilities | Where-Object programSource)
New-Item -ItemType Directory -Force $util | Out-Null
foreach ($u in $gen) {
  $fo = & $folderOf $u.program
  $src = "$($ge.LionDevelopment)\Programs\$fo"
  if (-not (Test-Path $src)) { throw "not generated: $src" }
  $dst = "$util\$fo"
  if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
  Copy-Item $src $dst -Recurse -Exclude bin, obj
  Get-ChildItem $dst -Recurse -Directory | Where-Object Name -in 'bin', 'obj' | Remove-Item -Recurse -Force
  Get-ChildItem $dst -Recurse -Include *.csproj.user | Remove-Item -Force
  $pj = "$dst\$fo.csproj"
  $c = [IO.File]::ReadAllText($pj)
  $c = $c.Replace('Y:\Amt.Net\', '..\..\..\..\AmtFramework\Amt.Net\').Replace("$($ge.LionDevelopment)\", '..\..\')
  $c = [regex]::Replace($c, '<HintPath>[^<]*Newtonsoft\.Json\.dll</HintPath>', '<HintPath>..\..\..\Binaries\Application\Newtonsoft.Json.dll</HintPath>')
  $docDir = "$dst\Documentation"; New-Item -ItemType Directory -Force $docDir | Out-Null
  $cob = Split-Path $u.programSource -Leaf
  Copy-Item "$PSScriptRoot\$($u.programSource)" "$docDir\$cob"
  $c = $c.Replace("    <Compile Include=`"LocalDefinitions.cs`" />", "    <Compile Include=`"LocalDefinitions.cs`" />`r`n    <Content Include=`"Documentation\$cob`" />")
  if ($c -match '[A-Z]:\\') { throw "absolute path left in $pj" }
  [IO.File]::WriteAllText($pj, $c)
  $n = 0
  foreach ($cs in Get-ChildItem $dst -Filter *.cs) {
    $t = [IO.File]::ReadAllText($cs.FullName)
    $m = [regex]::Match($t, '(base\("[^"]+",\s*"[^"]*",\s*"[^"]*",\s*"[^"]*"),\s*\d{8},\s*\d{3,4}\)')
    if ($m.Success) { [IO.File]::WriteAllText($cs.FullName, $t.Replace($m.Value, $m.Groups[1].Value + ')')); $n++ }
  }
  $report += "{0,-30} placed; base() calls without generation date/time: {1}; documentation {2}" -f $fo, $n, $cob
}

$skelDir = "$Worktree\Scripts\ASSURFED_UTILIT"
$skels = @($catalog.utilities | ForEach-Object { $_.skeletons } | ForEach-Object { "$($_.skeleton).ps1" })
$incs = @($catalog.utilities | ForEach-Object { "$($_.include).inc" }) + 'GnHandoff.inc' | Select-Object -Unique
$replaced = 0; $added = 0
foreach ($f in $skels + $incs) {
  $from = "$($sk.ScriptRoot)\ASSURFED_UTILIT\$f"
  if (-not (Test-Path $from)) { throw "missing in the deployed set: $from" }
  if (Test-Path "$skelDir\$f") { $replaced++ } else { $added++ }
  Copy-Item $from "$skelDir\$f" -Force
}
$report += "Scripts\ASSURFED_UTILIT: $($skels.Count) skeletons + $($incs.Count) includes ($replaced replaced, $added new)"

# Minimal text edits on the committed (HEAD) versions, CRLF kept: dotnet sln and an XML save rewrite the whole file.
function Get-HeadText([String]$RelPath) {
  $tmp = [IO.Path]::GetTempFileName()
  cmd /c "git -C `"$Worktree`" show HEAD:$RelPath > `"$tmp`""
  if ($LASTEXITCODE) { throw "git show HEAD:$RelPath failed" }
  $t = [IO.File]::ReadAllText($tmp); Remove-Item $tmp; $t
}
function Get-NameGuid([String]$Name) {
  $h = [Security.Cryptography.MD5]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes("SSG4-Utilities:$Name"))
  ([Guid]::new($h)).ToString().ToUpperInvariant()
}

$setRel = 'Scripts/Settings/AmtSettings.xml'
$t = Get-HeadText $setRel
$ind = [regex]::Match($t, '(?m)^([ \t]*)</AmtSettings>').Groups[1].Value
$entries = foreach ($u in $catalog.utilities) { foreach ($name in $u.xqt) { "$ind$ind<OrginalReport Name=`"$($u.program)`" Clone=`"$name`" />" } }
$block = "$ind<CloneReports>`r`n" + (($entries) -join "`r`n") + "`r`n$ind</CloneReports>`r`n"
$i = $t.LastIndexOf('</Amt>'); if ($i -lt 0) { throw 'no </Amt> in the settings file' }
[IO.File]::WriteAllText("$Worktree\Scripts\Settings\AmtSettings.xml", $t.Insert($i, $block))
$report += "Scripts\Settings\AmtSettings.xml: CloneReports $(@($entries).Count) entries inserted before </Amt> (AppName and UseUnicode left as they are)"

if (-not $SkipSolution) {
  $slnRel = "$($ge.LionApp)_AMT/Development/_All_.sln"
  $t = Get-HeadText $slnRel
  $fold = Get-NameGuid 'Utilities'
  $projs = @(Get-ChildItem $util -Directory | Where-Object { Test-Path "$($_.FullName)\$($_.Name).csproj" } | Sort-Object Name)
  $decl = "Project(`"{2150E333-8FDC-42A3-9474-1A3956D46DE8}`") = `"Utilities`", `"Utilities`", `"{$fold}`"`r`nEndProject`r`n"
  $cfg = ''; $nest = ''
  $ci = [regex]::Match($t, '(?m)^([ \t]*)\{[0-9A-Fa-f-]+\}\.Debug\|Any CPU\.ActiveCfg').Groups[1].Value
  foreach ($p in $projs) {
    $g = Get-NameGuid $p.Name
    $decl += "Project(`"{9A19103F-16F7-4668-BE54-9A1E7A4F7556}`") = `"$($p.Name)`", `"Utilities\$($p.Name)\$($p.Name).csproj`", `"{$g}`"`r`nEndProject`r`n"
    foreach ($c in 'Debug', 'Release') { $cfg += "$ci{$g}.$c|Any CPU.ActiveCfg = $c|Any CPU`r`n$ci{$g}.$c|Any CPU.Build.0 = $c|Any CPU`r`n" }
    $nest += "$ci{$g} = {$fold}`r`n"
  }
  $i = [regex]::Match($t, '(?m)^Global\r?$').Index
  $t = $t.Insert($i, $decl)
  $m = [regex]::Match($t, '(?m)^[ \t]*GlobalSection\(ProjectConfigurationPlatforms\) = postSolution\r?\n'); $t = $t.Insert($m.Index + $m.Length, $cfg)
  $m = [regex]::Match($t, '(?m)^[ \t]*GlobalSection\(NestedProjects\) = preSolution\r?\n'); if (-not $m.Success) { throw 'no NestedProjects section' }; $t = $t.Insert($m.Index + $m.Length, $nest)
  [IO.File]::WriteAllText("$dev\_All_.sln", $t)
  $report += "_All_.sln: solution folder Utilities + $($projs.Count) project(s) inserted (fixed GUIDs from the names)"
}
if ($Build) {
  $lines = @()
  foreach ($pj in Get-ChildItem $util -Recurse -Filter *.csproj) {
    $o = & dotnet build $pj.FullName -c Release 2>&1
    $errs = @($o | Where-Object { $_ -match ': error ' } | Select-Object -Unique)
    $lines += "=== $($pj.BaseName): exit $LASTEXITCODE, errors $($errs.Count)"; $lines += $errs | Select-Object -First 5
    $report += "build $($pj.BaseName): exit $LASTEXITCODE, errors $($errs.Count)"
    Get-ChildItem $pj.DirectoryName -Directory | Where-Object Name -in 'bin', 'obj' | Remove-Item -Recurse -Force
  }
  $lines += Get-ChildItem "$app\Binaries\Programs" -Filter 'ASSURFED_UTILIT_*_GN.dll' -ErrorAction SilentlyContinue | ForEach-Object { '{0} {1} B {2:HH:mm:ss}' -f $_.Name, $_.Length, $_.LastWriteTime }
  $lines | Set-Content $BuildLog
}
if ($Release) { $report += & "$PSScriptRoot\Update-GnProgramSummary.ps1" -Release $Release -Summary "$util\PROGRAM-SUMMARY.md" }
$report | Tee-Object 'E:\Repos\ssg4-work\place-gn.txt'
