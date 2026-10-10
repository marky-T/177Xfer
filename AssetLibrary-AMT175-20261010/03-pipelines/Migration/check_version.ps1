$asm = [System.Reflection.Assembly]::LoadFile('C:\Amt\Working\Apps\AFBUS_2200SSGCOBOL\Source_AMTLion\Development\Programs\Assurfed_Utilit_Cfh_Copy\obj\Debug\Assurfed_Utilit_Cfh_Copy.dll')
($asm.GetReferencedAssemblies() | Where-Object { $_.Name -eq 'Asysco.Amt.Runtime' }).FullName
