FOR %%a IN ("%1") DO (set file=%%~na%%~xa)
set filename=%file:~0,-4%
java -Xmx512M -jar BootSignature.jar /boot %file% ./security/verity.pk8 ./security/verity.x509.pem %filename%-sign_boot.img
pause
