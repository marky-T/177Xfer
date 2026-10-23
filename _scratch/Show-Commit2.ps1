$g = 'E:\Repos\amt-go-net-ref'
$env:GIT_TERMINAL_PROMPT = '0'
'== clone HEAD'
git -C $g log -1 --format='%h %ad %s' --date=short 2>&1
'== shallow?'
git -C $g rev-parse --is-shallow-repository 2>&1
'== is 5fc53fd one of the commits we have (no fetch)'
git -C $g -c fetch.negotiationAlgorithm=noop cat-file -e '5fc53fdb78f80fc6cd2422e2e875a79a1863b96f^{commit}' 2>&1
'exit: ' + $LASTEXITCODE
'== log of the SsgConverter folder in our clone (local objects only)'
git -C $g log --format='%h %ad %an | %s' --date=short -6 -- 'Migration Tools/SsgConverter' 2>&1
