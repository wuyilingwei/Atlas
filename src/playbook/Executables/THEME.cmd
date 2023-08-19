@echo off

:: copy themes
copy "Themes\Atlas Dark.theme" "%windir%\Resources\Themes\aero.theme"
for /f "tokens=6 delims=[.] " %%a in ('ver') do (
    if %%a LSS 22621 (
		copy "Themes\Atlas Light.theme" "%windir%\Resources\Themes\Light.theme" > nul
    ) else (
		copy "Themes\Atlas Light.theme" "%windir%\Resources\Themes\spotlight.theme" > nul
		set win11=true
	)
)

for /f "usebackq tokens=2 delims=\" %%a in (`reg query "HKEY_USERS" ^| findstr /r /x /c:"HKEY_USERS\\S-.*" /c:"HKEY_USERS\\AME_UserHive_[^_]*"`) do (
	if "%%a" == "AME_UserHive_Default" (
		call :ALLUSERS "%%a" "%SystemDrive%\Users\Default\AppData\Roaming"
	) else (
		for /f "usebackq tokens=2* delims= " %%b in (`reg query "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "AppData" ^| findstr /r /x /c:".*AppData[ ]*REG_SZ[ ].*"`) do (
			call :ALLUSERS "%%a" "%%c"
		)
	)
)

:: clear lockscreen cache
for /d %%a in ("%ProgramData%\Microsoft\Windows\SystemData\*") do (
	for /d %%c in ("%%a\ReadOnly\LockScreen_*") do (
		rd /s /q "%%c" > nul
	)
)

taskkill /F /IM sihost.exe > nul
exit /b

:ALLUSERS
if defined win11 (
	reg add "HKU\%~1\Software\Microsoft\Windows\CurrentVersion\Themes" /v "ThemeMRU" /t REG_SZ /d "C:\Windows\Resources\Themes\aero.theme;C:\Windows\resources\Themes\spotlight.theme;" /f > nul
)

reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SystemProtectedUserData\%~1\AnyoneRead\Colors" /v "AccentColor" /t REG_DWORD /d "4290728257" /f > nul
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SystemProtectedUserData\%~1\AnyoneRead\Colors" /v "StartColor" /t REG_DWORD /d "4291969335" /f > nul

del /q /f "%~2\Microsoft\Windows\Themes\TranscodedWallpaper" > nul
rmdir /q /s "%~2\Microsoft\Windows\Themes\CachedFiles" > nul

if not "%~1"=="AME_UserHive_Default" (
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\%~1" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "0" /f > nul
)