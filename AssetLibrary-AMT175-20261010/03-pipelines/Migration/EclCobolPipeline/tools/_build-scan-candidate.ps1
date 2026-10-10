$src  = 'C:\Amt\MainframeSource\Codedrop 2025\SSG Prd\SSG Creating COBOL\ASSURFED_UTILIT_SCAN-VAR_ASCII(P).TXT'
$dest = 'C:\Amt\Migration\EclCobolPipeline\candidates\trial-08-scan\SCAN.TXT'

$po = @{
    '[INPUT,1,1,1]' = 'ECL-FICHIN-1'
    '[INPUT,1,1,2]' = '80'
    '[INPUT,1,1,3]' = '1'
}
$cv = @{
    'ASCII'     = 1
    'INPUT,1,1' = 3
    'BLOCK'     = 0
    'OMITTED'   = 0
    'DESC'      = 0
    'KEY'       = 0
    'INDIC'     = 0
    'IF'        = 0
    'NOCONT'    = 0
    'TITLE'     = 0
    'LIST'      = 0
}

& 'C:\Amt\Migration\EclCobolPipeline\tools\Remove-SsgDirectives.ps1' `
    -InputFile $src -OutputFile $dest `
    -ParamOverrides $po -ConditionValues $cv -AnnotateStubs
