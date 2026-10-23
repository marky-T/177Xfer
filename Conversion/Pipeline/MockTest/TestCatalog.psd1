# Which tests run for the AFBUS_2200COBOL set. Smoke cases need no entry: every generated program gets one from its exported @SSG call.
@{
  # covered by section 1 of Run-AllMockTests.ps1 (reference copy test), so no smoke run
  SmokeExclude = @('CFH-COPY_ASCII')

  # LOADIS-type program then its UNLOADIS partner; expected output = the loaded records in key order
  RoundTrips   = @(
    @{ Load = 'LOADIS_ASCII'; Unload = 'UNLOADIS_ASCII' }
    @{ Load = 'LOADIS_MULTI'; Unload = 'UNLOADIS_MULTI' }
  )
}
