@echo off

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

:DoIt
color 0A

:MENU
cls
echo.
echo [93m  ~ INSTALL FM6 FIRMWARE ~[0m  [37mver 20220515[0m
echo.
echo   I = Install FM6 Firmware
echo   R = ReadMe
echo.
echo   X = Exit
echo.
echo.

set /P IN=Enter your choice: 
if /I %IN%==I goto STEP1
if /I %IN%==R goto READ
if /I %IN%==X goto EOF
 
:ERR1
cls
echo.
echo [91mNot a valid choice, try again...[0m
timeout 3
echo.
goto MENU

:STEP1
cls
echo.
echo [93mThese are the files in the current directory:[0m
echo.
dir /a-d /b
echo.
set /P FC= Is this correct [should be 3 [96m(.bat .zip .exe)[0m]? (Y or N): 
if /I %FC%==Y goto STEP2
if /I %FC%==N goto MENU

:ERR2
cls
echo.
echo [91mNot a valid choice, try again...[0m
timeout 3
echo.
goto STEP1

:STEP2
cls
echo.
echo Checking for nrfutil...
echo.
if exist "nrfutil.exe" (
    nrfutil.exe
) else (
    echo [91mnrfutil.exe missing![0m && pause && goto MENU
)
echo.
timeout 1
goto STEP3

:STEP3
cls
echo.
echo [93mChecking for the firmware zip file...[0m
echo.
if exist "fm6_dfu_package_*.zip" (
   for %%X IN (fm6_dfu_package_*.zip) do (set DFU=%%X)
) else (
    echo [91mdfu zip file missing![0m && pause && goto MENU
)
echo.
echo Found:  [96m%DFU%[0m
echo.
echo.
pause
goto STEP4

:STEP4
cls
echo [93mOpening Device Manager...[0m
set devmgr_show_nonpresent_devices=1 
start "" devmgmt.msc
cls
echo.
echo 1) In Device Manager select: [96mView -^> Show hidden devices[0m
echo.
echo 2) Expand:  [96mPorts (COM ^& LPT)[0m
echo.
echo 3) [4mTake note[24m of the listed [96mCOM ports[0m
echo.
echo.
pause
goto STEP5

:STEP5
cls
echo.
echo [93mEnter Mouse Boot Mode...[0m
echo.
echo 1) [4mTurn OFF[24m the mouse
echo.
echo 2) [4mHold down[24m DPI Button and Mouse Wheel
echo.
echo 3) [4mInsert the USB cable[24m into the mouse
echo.
echo 4) [4mRelease[24m the DPI Button and Mouse Wheel
echo.
echo 5) The mouse will be [4mpulsing white[24m
echo.
echo 6) !!! [4mTake note[24m of the newly listed [96mCOM port[0m !!!
echo.
echo.
pause
goto STEP6

:STEP6
cls
echo.
set /P CP= Enter the [96mnew COM Port Number[0m (e.g., 5): 
echo.
echo You entered:  [91m%CP%[0m  (COM[91m%CP%[0m)
echo.
set /P CC= Is this correct? (Y or N): 
if /I %CC%==Y goto STEP7
if /I %CC%==N goto STEP6

:ERR3
cls
echo.
echo [91mNot a valid choice, try again...[0m
timeout 3
echo.
goto STEP6

:STEP7
cls
echo.
echo [93mUpdate firmware...[0m
echo.
echo [37mEXAMPLE:  nrfutil dfu usb-serial -pkg [91mfm6_dfu_package_x.x.x[37m.zip -p COM[91m#[37m -b 115200[0m
echo [96mCOMMAND:  nrfutil dfu usb-serial -pkg [91m%DFU%[96m -p COM[91m%CP%[96m -b 115200[0m
echo.
echo If this looks good and the mouse is in Boot Mode
echo  hit any key to flash the firmware...
echo.
echo.
echo [37mIf not just close this cmd window and start over.[0m
echo.
echo.
echo   [93mNOTE:  Mouse Boot Mode...[0m
echo   1) [4mHold down[24m DPI Button and Mouse Wheel
echo   2) [4mInsert the USB cable[24m into the mouse
echo.
echo.
pause>nul
cls
echo.
echo [93mFlashing firmware please wait...[0m
echo.
nrfutil dfu usb-serial -pkg %DFU% -p COM%CP% -b 115200
echo.
echo [1m[97mAll Done![0m[0m
echo.
echo.
pause
goto MENU

:READ
cls
echo.
echo 1) Create a new folder
echo.
echo   2) Add:  [96mFlashM6.bat[0m (this file)
echo.
echo   3) Add:  [96mnrfutil.exe[0m
echo.
echo   4) Add:  [96mfm6_dfu_package_x.x.xx.zip[0m (current firmware zip)
echo.
echo 5) Connect a second mouse or touchpad
echo.
echo 6) Turn OFF the Finalmouse
echo.
echo 7) Run this file
echo.
echo.
pause
goto MENU

:EOF
cls
exit
