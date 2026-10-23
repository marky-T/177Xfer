# Shared by Export-SgsCards.ps1 and Invoke-SsgExpansion.ps1.
#
# DELIBERATE CHANGES TO SGS CARDS (not accidents). SSG accepts card forms (manual 78311784-010 s3.1.1)
# that AMT's runtime parser, AddTo-SgsList, reads differently because it only splits on spaces and
# commas (MT-033 item 12). So that AMT sees the cards SSG would have seen, ConvertTo-AmtSgsCard applies
# SSG's own rules before the cards are written. Every change is reported with one of the codes below
# (sgs-warnings.csv, Severity = Changed). Things that cannot be expressed to AMT's parser stay as
# they are and are reported with Severity = Warning. Rules, with manual references:
#   SGS-CONTINUED                  trailing ' ;' or ',;' joins the next image (s3.1.1); done in Export-SgsCards.ps1
#   SGS-LAST-CONTINUED-DROPPED     last card ending ' ;' is ignored by SSG (s3.1.1); done in Export-SgsCards.ps1
#   SGS-PERIOD-CUT                 an unquoted period ends the scan of the card (s3.1.1)
#   SGS-SPACE-AFTER-COMMA-REMOVED  spaces after a comma are ignored (s3.1.1, example 5)
#   SGS-DOUBLE-QUOTE-STRIPPED      ''text'' loses its quote pairs; a plain 'text' keeps its quotes (s3.1.1 methods 1 and 2)
# Docs: Conversion/Pipeline/WorkingExample-CFH-COPY_ASCII/README.md ("Deliberate changes to the cards").

$script:SgsCardCodes = [ordered]@{
  'SGS-CONTINUED'                 = @('Changed', "Card continued with a trailing ' ;' or ',;'. Joined into one line, as SSG does; AddTo-SgsList has no continuation.")
  'SGS-LAST-CONTINUED-DROPPED'    = @('Changed', "Last card ends with ' ;'. Dropped, as SSG ignores it (manual s3.1.1).")
  'SGS-PERIOD-CUT'                = @('Changed', "Unquoted period: card cut there, as SSG ends the scan of the card. The text after it was a comment.")
  'SGS-SPACE-AFTER-COMMA-REMOVED' = @('Changed', "Spaces after a comma removed, as SSG ignores them. AMT would start a new field.")
  'SGS-DOUBLE-QUOTE-STRIPPED'     = @('Changed', "Subfield in pairs of single quotes ('' '') written without them, as SSG drops them.")
  'SGS-QUOTED-SPECIAL'            = @('Warning', "Quoted subfield contains a space or comma. NOT FIXABLE in the card: AMT's parser splits it into several fields or subfields.")
  'SGS-EXTERNAL'                  = @('Warning', "Cards come from a file named on the @SSG or SGS statement, not from the runstream. Not exported.")
}

function Split-SgsCard {
  # Splits a card into text and quoted segments: text | single ('..') | double (''..'')
  param([AllowEmptyString()][String]$Card)
  $segs = New-Object System.Collections.Generic.List[object]
  $text = New-Object System.Text.StringBuilder
  $i = 0; $n = $Card.Length
  while ($i -lt $n) {
    if ($Card[$i] -eq "'") {
      if ($i + 1 -lt $n -and $Card[$i + 1] -eq "'") {
        $end = $Card.IndexOf("''", $i + 2)
        if ($end -ge 0) {
          if ($text.Length) { $segs.Add(@{ Type = 'text'; Value = $text.ToString() }); [void]$text.Clear() }
          $segs.Add(@{ Type = 'double'; Value = $Card.Substring($i + 2, $end - $i - 2) })
          $i = $end + 2; continue
        }
      } else {
        $end = $Card.IndexOf("'", $i + 1)
        if ($end -ge 0) {
          if ($text.Length) { $segs.Add(@{ Type = 'text'; Value = $text.ToString() }); [void]$text.Clear() }
          $segs.Add(@{ Type = 'single'; Value = $Card.Substring($i + 1, $end - $i - 1) })
          $i = $end + 1; continue
        }
      }
    }
    [void]$text.Append($Card[$i]); $i++
  }
  if ($text.Length) { $segs.Add(@{ Type = 'text'; Value = $text.ToString() }) }
  return $segs.ToArray()
}

function ConvertTo-AmtSgsCard {
  param([AllowEmptyString()][String]$Card)

  $changes = New-Object System.Collections.Generic.List[string]
  $unfixable = New-Object System.Collections.Generic.List[string]
  $out = New-Object System.Text.StringBuilder
  $stop = $false

  foreach ($seg in @(Split-SgsCard $Card)) {
    if ($stop) { break }
    switch ($seg.Type) {
      'text' {
        $t = $seg.Value
        $dot = $t.IndexOf('.')
        if ($dot -ge 0) { $t = $t.Substring(0, $dot); $stop = $true; $changes.Add('SGS-PERIOD-CUT') }
        $t2 = [regex]::Replace($t, ',[ \t]+', ',')
        if ($t2 -ne $t) { $changes.Add('SGS-SPACE-AFTER-COMMA-REMOVED') }
        [void]$out.Append($t2)
      }
      'single' {
        if ($seg.Value -match '[\s,]') { $unfixable.Add('SGS-QUOTED-SPECIAL') }
        [void]$out.Append("'" + $seg.Value + "'")
      }
      'double' {
        if ($seg.Value -match '[\s,]') { $unfixable.Add('SGS-QUOTED-SPECIAL'); [void]$out.Append("''" + $seg.Value + "''") }
        else { $changes.Add('SGS-DOUBLE-QUOTE-STRIPPED'); [void]$out.Append($seg.Value) }
      }
    }
  }

  [pscustomobject]@{
    Card      = $out.ToString().TrimEnd()
    Changes   = @($changes | Select-Object -Unique)
    Unfixable = @($unfixable | Select-Object -Unique)
  }
}
