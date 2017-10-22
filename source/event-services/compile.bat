@echo off

cd C:\lazarus-clean\fpc\3.0.2\bin\x86_64-win64\
mkdir lib
c:fpc services.lpr @extra.cfg
