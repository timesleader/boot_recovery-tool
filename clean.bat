@echo off
del /q *.img

for /f %%a in ('"dir /ad /b *-working"') do (rd /s /q %%a)
