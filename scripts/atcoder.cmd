@echo off

set SCRIPT_PATH=%~dp0
pushd %SCRIPT_PATH%..
set ROOT_PATH=%CD%
popd

set /p CONTEST_NAME=What is the name of the contest?:
set /p CONTEST_DATE=When did you join the contest? (yyyymmdd):

set CONTEST_YEAR=%CONTEST_DATE:~0,4%
set CONTEST_MONTH=%CONTEST_DATE:~4,2%
set CONTEST_DAY=%CONTEST_DATE:~6,2%

set DRAFT_PATH=%ROOT_PATH%\input\drafts\template_yyyymmdd_abc000.md
set POST_PATH=%ROOT_PATH%\input\posts\%CONTEST_DATE%_%CONTEST_NAME%.md

set CONTEST_NUMBER=%CONTEST_NAME:~-3%
set CONTEST_FULL_NAME=%CONTEST_NAME%

echo %CONTEST_NAME% | findstr /i "abc[0-9][0-9][0-9]" >nul
if errorlevel 0 (
  set CONTEST_FULL_NAME=AtCoder Beginner Contest %CONTEST_NUMBER%
)

echo %CONTEST_NAME% | findstr /i "arc[0-9][0-9][0-9]" >nul
if errorlevel 0 (
  set CONTEST_FULL_NAME=AtCoder Regular Contest %CONTEST_NUMBER%
)

echo %CONTEST_NAME% | findstr /i "agc[0-9][0-9][0-9]" >nul
if errorlevel 0 (
  set CONTEST_FULL_NAME=AtCoder Grand Contest %CONTEST_NUMBER%
)

echo %CONTEST_NAME% | findstr /i "a.c[0-9][0-9][0-9]" >nul
if errorlevel 1 (
  set /p CONTEST_FULL_NAME=What is the full name of the contest?:
)


setlocal ENABLEDELAYEDEXPANSION

for /f "tokens=* delims=0123456789 eol=" %%X in ('findstr /n "^" %DRAFT_PATH%') do (
  set line=%%X
  set line=!line:AtCoder Beginner Contest 000=%CONTEST_FULL_NAME%!
  set line=!line:abc000=%CONTEST_NAME%!
  set line=!line:ABC000=%CONTEST_NAME%!
  set line=!line:yyyy=%CONTEST_YEAR%!
  set line=!line:mm=%CONTEST_MONTH%!
  set line=!line:dd=%CONTEST_DAY%!
  set line=!line:~1!
  (echo.!line!) >> %POST_PATH%
)
 
endlocal
