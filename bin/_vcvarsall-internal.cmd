@echo off
call "%VS140COMNTOOLS%..\..\VC\vcvarsall.bat" %* >&2
bash %~dp0_vcvarsall-export.sh
