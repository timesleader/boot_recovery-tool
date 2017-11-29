FOR %%a IN ("%1") DO (set file=%%~na%%~xa)
set filename=%file:~0,-4%
java -Xmx512M -jar BootSignature.jar /recovery %file% ./security/verity.pk8 ./security/verity.x509.pem %filename%-sign_recovery.img
pause
