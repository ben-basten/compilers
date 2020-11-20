@echo off
echo Flexing...
win_flex --wincompat -o hw9.flex.cpp hw9.l
echo.
echo Bisoning...
win_bison --defines=hw9.tab.h -o hw9.tab.cpp -r all --report-file=hw9.tab.output hw9.y
echo.
echo Compiling...
echo.
cppcompileall hw9.exe