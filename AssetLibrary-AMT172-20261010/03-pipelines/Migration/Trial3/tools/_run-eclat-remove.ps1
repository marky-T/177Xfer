$src  = "C:\Amt\MainframeSource\Codedrop 2025\SSG Prd\SSG Creating COBOL\ASSURFED_UTILIT_ECLAT(P).TXT"
$dest = "C:\Amt\Migration\EclCobolPipeline\candidates\trial-09-eclat\ECLAT.TXT"

$overrides = @{
    '[key]'            = '1'
    '[key,1,1,1]'      = '1'
    '[key,1,1,2]'      = '10'
    '[key,1,1,3]'      = '1'
    '[filekey,1,1,1]'  = 'ECL-FILEKEY'
    '[filekey,1,1,2]'  = '10'
    '[table,1,1,1]'    = 'ECL-TABLE'
    '[table,1,1,2]'    = '20'
    '[table,1,1,3]'    = 'ARCHIVE-TABLE'
    '[farchive,1,1,1]' = 'ECL-FARCHIVE'
    '[fencours,1,1,1]' = 'ECL-FENCOURS'
}

$condVals = @{ 'key' = 1 }

& "C:\Amt\Migration\EclCobolPipeline\tools\Remove-SsgDirectives.ps1" `
    -InputFile  $src `
    -OutputFile $dest `
    -AnnotateStubs `
    -ParamOverrides  $overrides `
    -ConditionValues $condVals
