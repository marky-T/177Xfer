$c = 'E:\Repos\ssg4-work\sgs-cards\calls'
$set = @(
  @{ Case = 'VIRD03_L766';  Dll = 'ASSURFED_UTILIT_FUSBA2_ASCII.dll';   Cards = "$c\ASSURFED_F999RUN-d_VIRD03__L766.sgs" },
  @{ Case = 'CCTA09_L479';  Dll = 'ASSURFED_UTILIT_LECTIS_ASCII.dll';   Cards = "$c\ASSURFED_F999RUN_CCTA09__L479.sgs" },
  @{ Case = 'CLOA49_L141';  Dll = 'ASSURFED_UTILIT_LOADIS_ASCII.dll';   Cards = "$c\ASSURFED_F999RUN_CLOA49__L141.sgs" },
  @{ Case = 'CCTA08_L287';  Dll = 'ASSURFED_UTILIT_RECAP.dll';          Cards = "$c\ASSURFED_F999RUN_CCTA08__L287.sgs" },
  @{ Case = 'CLOA43_L473';  Dll = 'ASSURFED_UTILIT_UNLOADIS_ASCII.dll'; Cards = "$c\ASSURFED_F999RUN_CLOA43__L473.sgs" }
)
foreach ($s in $set) {
  pwsh -NoProfile -File E:\Repos\SsgTrial\Conversion\Pipeline\MockTest\Run-SmokeCase.ps1 -Case $s.Case -Application AFBUS_2200COBOL -Dll $s.Dll -Cards $s.Cards | Format-List | Out-String
}
