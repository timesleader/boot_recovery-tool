@echo off
if "%~1" == "" goto error
set path_arg=%~d1%~p1
cd /d %path_arg%
set L=%path_arg%
set tools=%cd%\tools
FOR %%a IN ("%1") DO (set file=%%~na%%~xa)
set filename=%file:~0,-4%

echo ��ǰ�ļ�Ϊ��%file%
echo.
echo ��� %filename%-working �ļ���
echo.
if exist "%L%%filename%-working" (rd /s /q "%L%%filename%-working")
md "%L%%filename%-working"
echo "%L%%filename%-working"

:begin
echo ���ڷֽ� "%file%"
echo.

"%tools%\unpackbootimg.exe" -i "%file%" -o "%L%%filename%-working"
cd "%L%%filename%-working"

:config
ren %file%-base base 
ren %file%-cmdline cmdline
ren %file%-dt dt 
ren %file%-pagesize pagesize
ren %file%-ramdisk_offset ramdisk_offset
ren %file%-second second
ren %file%-second_offset second_offset
ren %file%-tags_offset tags_offset

:if_mtk
"%tools%\od.exe" -A n --strings -j 2056 -N 6 "../%file%" >if_mtk.txt
for /f %%a in (if_mtk.txt) do (set if_mtk=%%a)
rem del /q if_mtk.txt
echo.

if "%if_mtk%" == "KERNEL" (goto mt65xx_sp) else (goto general)

:mt65xx_sp
echo ��⵽ MTK image

ren "%file%-ramdisk.gz" "src_ramdisk.gz"
ren "%file%-zImage" "src_zImage"

"%tools%\FileSplitter.exe" src_ramdisk.gz 512 >nul
"%tools%\FileSplitter.exe" src_zImage 512 >nul

ren src_zImage_1 zImage
ren src_ramdisk.gz_1 ramdisk.gz

del /q src_ramdisk.gz*
del /q src_zImage*

goto ramdisk

:general
echo ��⵽ Android��׼ image

ren "%file%-ramdisk.gz" "ramdisk.gz"
ren "%file%-zImage" "zImage"

goto ramdisk

:ramdisk
echo ���ڷֽ� ramdisk
echo.

mkdir ramdisk
cd ramdisk
"%tools%/gzip.exe" -dc "../ramdisk.gz" | "%tools%/cpio.exe" -i
if exist "%L%%filename%-working\ramdisk\init" (echo �ֽ�ɹ���) else (echo �ֽ�ʧ��&goto :error)

:dumpdone
echo.
echo ramdiskĿ¼�ֽ���ɣ�
echo.
pause
goto :eof


:error
echo error!
pause

