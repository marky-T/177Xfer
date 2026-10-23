$g = 'E:\Repos\amt-go-net-ref'
'== is the commit in our clone?'
git -C $g cat-file -t 5fc53fdb78f80fc6cd2422e2e875a79a1863b96f 2>&1
'== clone HEAD / shallow'
git -C $g log -1 --format='%h %ad %s' --date=short 2>&1
git -C $g rev-parse --is-shallow-repository 2>&1
'== log of the SsgConverter folder in our clone'
git -C $g log --format='%h %ad %an | %s' --date=short -8 -- 'Migration Tools/SsgConverter' 2>&1
'== the commit (stat)'
git -C $g show --stat --format='%h %ad%n%an%n%s%n%b' --date=short 5fc53fdb78f80fc6cd2422e2e875a79a1863b96f 2>&1 | Select-Object -First 40
