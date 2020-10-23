@echo off
echo Flexing...
win_flex --wincompat -o hw5.flex.cpp hw5.l
echo.
echo Bisoning...
echo.
win_bison --defines=hw5.tab.h -o hw5.tab.cpp -r all --report-file=hw5.tab.output hw5.y
echo.
echo Compiling...
echo.
cppcompileall hw5.exe
