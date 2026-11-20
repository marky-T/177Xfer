$g = 'E:\Repos\SsgTrial\Conversion\Pipeline\Generic\New-GnReleaseDocs.ps1'
'saved (old id text gone): ' + (-not (Select-String -Path $g -Pattern 'MT-063\)|tracker MT-044' -Quiet))
$e = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($g, [ref]$null, [ref]$e)
"parse errors: $($e.Count)"
$ast = [System.Management.Automation.Language.Parser]::ParseFile($g, [ref]$null, [ref]$null)
'params: ' + (($ast.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath }) -join ', ')
