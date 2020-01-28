@echo off

 call :isAdmin

 if %errorlevel% == 0 (
    goto :run
 ) else (
    goto :UACPrompt
 )

 exit /b

 :isAdmin
    fsutil dirty query %systemdrive% >nul
 exit /b

 :run
   @echo off
   cd /d %~dp0

   rem ON MINING RIGS SET MININGRIG=TRUE
   SET MININGRIG=FALSE

   if not "%GPU_FORCE_64BIT_PTR%"=="1" (setx GPU_FORCE_64BIT_PTR 1) > nul
   if not "%GPU_MAX_HEAP_SIZE%"=="100" (setx GPU_MAX_HEAP_SIZE 100) > nul
   if not "%GPU_USE_SYNC_OBJECTS%"=="1" (setx GPU_USE_SYNC_OBJECTS 1) > nul
   if not "%GPU_MAX_ALLOC_PERCENT%"=="100" (setx GPU_MAX_ALLOC_PERCENT 100) > nul
   if not "%GPU_SINGLE_ALLOC_PERCENT%"=="100" (setx GPU_SINGLE_ALLOC_PERCENT 100) > nul
   if not "%CUDA_DEVICE_ORDER%"=="PCI_BUS_ID" (setx CUDA_DEVICE_ORDER PCI_BUS_ID) > nul

   set "command=& .\multipoolminer.ps1 -DisableDevFeeMining -WarmupTime 30 -Wallet ltc1qwz4dyed3sx999y55qry0yaxh07ss9ns92v46j9 -WorkerName v1.0CGL -Region us -Currency ltc -DeviceName amd,nvidia,cpu -PoolName nlpool,zpool -Donate 10 -Watchdog -MinerStatusURL https://multipoolminer.io/monitor/miner.php -SwitchingPrevention 1"

   if exist "~*.dll" del "~*.dll" > nul 2>&1

   if /I "%MININGRIG%" EQU "TRUE" goto MINING

   if exist ".\SnakeTail.exe" goto SNAKETAIL

   start /min /belownormal pwsh -noexit -executionpolicy bypass -command "& .\reader.ps1 -log 'MultiPoolMiner_\d\d\d\d-\d\d-\d\d\.txt' -sort '^[^_]*_' -quickstart"
   goto MINING

   :SNAKETAIL
   tasklist /fi "WINDOWTITLE eq SnakeTail - MPM_SnakeTail_LogReader*" /fo TABLE 2>nul | find /I /N "SnakeTail.exe" > nul 2>&1
   if "%ERRORLEVEL%"=="1" start /min .\SnakeTail.exe .\MPM_SnakeTail_LogReader.xml

   :MINING
   start /min /belownormal pwsh -noexit -executionpolicy bypass -windowstyle minimized -command "%command%"
   exit /b

 :UACPrompt
   echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
   echo UAC.ShellExecute "cmd.exe", "/c %~s0 %~1", "", "runas", 1 >> "%temp%\getadmin.vbs"

   "%temp%\getadmin.vbs"
   del "%temp%\getadmin.vbs"
  exit /B`