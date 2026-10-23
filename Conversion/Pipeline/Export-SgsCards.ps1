<#
.SYNOPSIS
  SSG-4 pipeline step: export the SGS cards of every @SSG call in a set of runstreams.
.DESCRIPTION
  On OS 2200 the cards between "@SSG ..." and the next control statement (normally @EOF) are SSG's
  input (SSG manual 78311784-010 s2.2). The ECL converter drops them (T3-020), so this step writes
  them out in the form AMT's runtime loads: one card per line, read by Add-Sgs -> AddTo-SgsList.

  The cards are NOT copied verbatim. SSG accepts forms that AddTo-SgsList reads differently, so SSG's
  own rules are applied first (continuation joined, text after an unquoted period cut, spaces after a
  comma removed, '' quote pairs dropped). This is deliberate; see SgsCardChecks.ps1 and the README of
  WorkingExample-CFH-COPY_ASCII. Each change is listed in sgs-warnings.csv with Severity = Changed.
  Forms AMT cannot represent (a quoted subfield containing a space or comma) are left as they are and
  listed with Severity = Warning.

  Output (all regenerated on each run, so re-runs are byte-identical):
    <OutDir>\calls\<runstream>__L<line>.sgs   cards of one @SSG call, as written for AMT
    <OutDir>\P$SGS\<run-id>                   the file Invoke-Ssg loads; only written when one
                                              runstream with one @SSG call owns that run-id
                                              (naming otherwise open, T3-020)
    <OutDir>\sgs-calls.csv                    one row per call; CardNotes lists the codes found
    <OutDir>\sgs-warnings.csv                 one row per change or warning: runstream, line, code,
                                              severity, original card, card as written
.PARAMETER RunstreamDir
  Folder of runstream text files (cp1252), e.g. the RunsPrd part of the SSG-4 source pack.
.PARAMETER OutDir
  Output folder. Kept outside the repo by default: the cards are client data.
.EXAMPLE
  pwsh -NoProfile -File Export-SgsCards.ps1
#>
param(
  [String]$RunstreamDir = 'E:\Repos\ssg4-source\01-RunsPrd',
  [String]$OutDir = 'E:\Repos\ssg4-work\sgs-cards',
  [String]$ConvertedDir = (Join-Path $PSScriptRoot '..\..\SsgConverter\Examples\Output')
)

$ErrorActionPreference = 'Stop'
$enc = [System.Text.Encoding]::GetEncoding(1252)
. (Join-Path $PSScriptRoot 'SgsCardChecks.ps1')
$warnRows = New-Object System.Collections.Generic.List[object]

if (-not (Test-Path $RunstreamDir)) { throw "Runstream folder not found: $RunstreamDir" }
foreach ($sub in 'calls', 'P$SGS') {
  $p = Join-Path $OutDir $sub
  if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Recurse -Force }
  New-Item -ItemType Directory -Path $p -Force | Out-Null
}

$ssgRx = [regex]'^@(?:[\w$-]+:)?\s*SSG(?:,(?<opt>\S*))?\s+(?<params>\S.*)?$'
$runRx = [regex]'^@(?:[\w$-]+:)?\s*RUN(?:,\S*)?\s+(?<runid>[^,\s]+)(?:,(?<acct>[^,\s]*))?(?:,(?<proj>[^,\s]*))?'
$fileIdRx = [regex]'^(?<id>SGS|SKEL|OPT|PCF\w*|TCF\w*)(?:,\S*)?(?:\s+(?<spec>\S.*))?$'

$rows = New-Object System.Collections.Generic.List[object]
$files = Get-ChildItem -LiteralPath $RunstreamDir -File | Sort-Object Name

foreach ($file in $files) {
  $lines = [System.IO.File]::ReadAllLines($file.FullName, $enc)
  $runId = $null; $runAcct = ''; $runProj = ''
  $calls = New-Object System.Collections.Generic.List[object]

  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i].TrimEnd()
    if (-not $runId) {
      $m = $runRx.Match($line)
      if ($m.Success) { $runId = $m.Groups['runid'].Value; $runAcct = $m.Groups['acct'].Value; $runProj = $m.Groups['proj'].Value }
    }
    $m = $ssgRx.Match($line)
    if (-not $m.Success) { continue }

    $params = $m.Groups['params'].Value -split ','
    $skeleton = $params[0].Trim()
    $section = $null
    $external = if ($params.Count -gt 1 -and $params[1].Trim()) { $params[1].Trim() } else { $null }
    $inlineSkel = $false
    $cards = New-Object System.Collections.Generic.List[string]
    $continued = 0; $pending = $null
    $j = $i + 1
    while ($j -lt $lines.Count -and -not $lines[$j].StartsWith('@')) {
      $img = $lines[$j].TrimEnd()
      $fid = $fileIdRx.Match($img.TrimStart())
      if ($pending -eq $null -and $fid.Success) {
        $section = $fid.Groups['id'].Value.ToUpperInvariant()
        if ($section -eq 'SKEL') { $inlineSkel = $true }
        if ($section -eq 'SGS' -and $fid.Groups['spec'].Success) { $external = $fid.Groups['spec'].Value.Trim() }
      } elseif ($section -eq 'SGS' -and ($img.Trim() -ne '' -or $pending -ne $null)) {
        # SSG s3.1.1: a trailing ' ;' or ',;' continues the SGS; text after it is ignored, and leading
        # spaces on the next image are ignored. AddTo-SgsList cannot do this, so join here.
        $part = if ($pending -ne $null) { $img.TrimStart() } else { $img.Trim() }
        $cm = [regex]::Match($part, '^(?<keep>.*?(?:\s|,));')
        if ($cm.Success) {
          $pending = "$pending$($cm.Groups['keep'].Value)"; $continued++
        } else {
          $cards.Add("$pending$part".Trim()); $pending = $null
        }
      }
      $j++
    }
    # SSG ignores a last card that ends with ' ;' (s3.1.1)
    $lastDropped = $false; $droppedText = ''
    if ($pending -ne $null) { if ($pending -match '\s$') { $lastDropped = $true; $droppedText = $pending.Trim() } else { $cards.Add($pending.Trim()) } }
    if (-not $skeleton -and $inlineSkel) { $skeleton = '(inline SKEL)' }
    $calls.Add([pscustomobject]@{ Line = $i + 1; Options = $m.Groups['opt'].Value; Skeleton = $skeleton; Cards = $cards; Continued = $continued; LastDropped = $lastDropped; DroppedText = $droppedText; External = $external; EndLine = $j + 1 })
    $i = $j - 1
  }
  if ($calls.Count -eq 0) { continue }

  if (-not $runId) { $runId = $file.BaseName }
  $stem = $file.BaseName -replace '\(P\)$', ''
  foreach ($c in $calls) {
    $callNotes = New-Object System.Collections.Generic.List[string]
    $note = {
      param($code, $original, $written)
      $callNotes.Add($code)
      $warnRows.Add([pscustomobject]@{ Runstream = $file.Name; Line = $c.Line; Code = $code; Severity = $script:SgsCardCodes[$code][0]; Card = $original; Written = $written })
    }
    if ($c.Continued)   { & $note 'SGS-CONTINUED' "$($c.Continued) continuation(s) joined" '' }
    if ($c.LastDropped) { & $note 'SGS-LAST-CONTINUED-DROPPED' $c.DroppedText '' }
    if ($c.External)    { & $note 'SGS-EXTERNAL' $c.External '' }

    # Apply SSG's rules so AMT's AddTo-SgsList sees the cards SSG would have seen.
    $written = New-Object System.Collections.Generic.List[string]
    foreach ($card in $c.Cards) {
      $r = ConvertTo-AmtSgsCard $card
      foreach ($code in @($r.Changes) + @($r.Unfixable)) { & $note $code $card $r.Card }
      if ($r.Card -ne '') { $written.Add($r.Card) }
    }

    $callFile = Join-Path $OutDir ("calls\{0}__L{1}.sgs" -f $stem, $c.Line)
    [System.IO.File]::WriteAllText($callFile, (($written -join "`r`n") + "`r`n"), $enc)

    # *UTILIT.CFH-COPY/ASCII -> template UTILIT_CFH-COPY_ASCII, program key CFH-COPY_ASCII
    $key = ''
    if ($c.Skeleton -match '\.') {
      $elt = ($c.Skeleton -replace '^.*\*', '') -replace '^[^.]*\.', ''
      $name, $version = $elt -split '/', 2
      $key = if ($version) { "$($name)_$version" } else { $name }
    }

    $rows.Add([pscustomobject]@{
      Runstream       = $file.Name
      RunId           = $runId
      RunAccount      = $runAcct
      RunProject      = $runProj
      Line            = $c.Line
      Options         = $c.Options
      Skeleton        = $c.Skeleton
      ProgramKey      = $key
      Converted       = [bool]($key -and (Test-Path (Join-Path $ConvertedDir "$key.ps1")))
      CallsInRun      = $calls.Count
      Cards           = $written.Count
      Labels          = (($written | ForEach-Object { ($_ -split '\s+')[0] }) | Select-Object -Unique) -join ' '
      ExternalSgs     = $c.External
      CardNotes       = ($callNotes | Select-Object -Unique) -join ' '
      CardFile        = "calls\$(Split-Path $callFile -Leaf)"
      PsgsFile        = ''
    })
  }
}

# P$SGS\<run-id> is what Invoke-Ssg loads; only unambiguous when one runstream with one call owns the run-id.
$byRun = $rows | Group-Object RunId
foreach ($g in $byRun) {
  $owners = @($g.Group | Select-Object -ExpandProperty Runstream -Unique)
  if ($owners.Count -eq 1 -and $g.Count -eq 1) {
    $row = $g.Group[0]
    Copy-Item -LiteralPath (Join-Path $OutDir $row.CardFile) -Destination (Join-Path $OutDir "P`$SGS\$($g.Name)")
    $row.PsgsFile = "P`$SGS\$($g.Name)"
  }
}

$csv = Join-Path $OutDir 'sgs-calls.csv'
$rows | Export-Csv -LiteralPath $csv -NoTypeInformation -Encoding utf8
$warnCsv = Join-Path $OutDir 'sgs-warnings.csv'
$warnRows | Export-Csv -LiteralPath $warnCsv -NoTypeInformation -Encoding utf8

"Runstreams scanned : $($files.Count)"
"Runstreams with SSG: $(@($rows | Select-Object -ExpandProperty Runstream -Unique).Count)"
"@SSG calls         : $($rows.Count)  (on our converted programs: $(@($rows | Where-Object Converted).Count))"
"Calls with an unambiguous P`$SGS file: $(@($rows | Where-Object PsgsFile).Count)  (the rest share a run-id or a runstream, T3-020)"
"Cards changed to follow SSG: $(@($warnRows | Where-Object Severity -eq 'Changed').Count) rows; cards AMT cannot represent (Warning): $(@($warnRows | Where-Object Severity -eq 'Warning').Count) rows"
foreach ($g in ($warnRows | Group-Object Code | Sort-Object Name)) {
  "  {0,-30} {1,4}  [{2}]" -f $g.Name, $g.Count, $script:SgsCardCodes[$g.Name][0]
}
"Index: $csv"
"Changes and warnings: $warnCsv"
