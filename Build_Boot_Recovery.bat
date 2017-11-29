@echo off
if "%~1" == "" goto error
set path_arg=%~d1%~p1
cd /d %path_arg%
set L=%path_arg%
set tools=%L%tools
FOR %%a IN ("%1") DO (set file=%%~na%%~xa)
set filename=%file:~0,-4%

echo 当前文件为：%file%
echo.

if not exist "%L%%filename%-working" (echo 请先运行Dump.bat!&goto error)

cd "%L%%filename%-working"

if exist "New-%file%" (del /q "New-%file%")

:config
for /f %%a in (.\base) do (set base=0x%%a)
for /f "tokens=*" %%a in (.\cmdline) do set cmdline=%%a
for /f %%a in (.\pagesize) do (set pagesize=%%a)
for /f %%a in (.\ramdisk_offset) do (set ramdisk_offset=0x%%a)
for /f %%a in (.\second_offset) do (set second_offset=0x%%a)
for /f %%a in (.\tags_offset) do (set tags_offset=0x%%a)
for %%1 in ("dt") do ( set dt=%%~z1 ) 

:mkbootfs
"%tools%\mkbootfs.exe" "./ramdisk" | "%tools%\gzip.exe" > "ramdisk-new.gz"

:general_mk
if "%cmdline%" == "" ( set cmdlinecfg= ) else ( set cmdlinecfg=--cmdline "%cmdline%")
if "%ramdisk_offset%" == "0x01000000" ( set ramdisk_offsetcfg= ) else ( set ramdisk_offsetcfg=--ramdisk_offset %ramdisk_offset%)
if "%tags_offset%" == "0x00000100" ( set tags_offsetcfg= ) else ( set tags_offsetcfg=--tags_offset %tags_offset%)
if "%second_offset%" == "0x00f00000" ( set second_offsetcfg= ) else ( set second_offsetcfg=--second_offset %second_offset%)
if "%dt%" == "0" ( set dtcfg= ) else ( set dtcfg=--dt "dt")

echo 合成参数：
echo base           ：%base%
echo cmdline        ：%cmdline%
echo pagesize       ：%pagesize%
echo ramdisk_offset ：%ramdisk_offset%
echo second_offset  ：%second_offset%
echo tags_offset    ：%tags_offset%
echo dt             ：%dt%

"%tools%\mkbootimg.exe" --kernel "zImage" --ramdisk "ramdisk-new.gz" --base %base% %cmdlinecfg% --pagesize %pagesize% %ramdisk_offsetcfg% %tags_offsetcfg% %second_offsetcfg% %dtcfg% -o "../New-%file%"

:done
cd ..
rem rd /s /q "%L%%filename%-working"
echo.
echo.
if exist "New-%file%" (echo Build完成，新文件为 "New-%file%") else goto error
echo.
pause
goto :eof

:error
echo error!
pause
