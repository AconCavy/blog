@echo off

set SCRIPT_PATH=%~dp0
pushd %SCRIPT_PATH%..
set ROOT_PATH=%CD%
popd

call dotnet run --project %ROOT_PATH%/src/Blog -- preview
