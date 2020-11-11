@echo off
echo Flexing...
win_flex --wincompat -o hw7.flex.cpp hw7.l
echo.
echo Bisoning...
win_bison --defines=hw7.tab.h -o hw7.tab.cpp -r all --report-file=hw7.tab.output hw7.y
echo.
echo Compiling...
echo.
cppcompileall hw7.exe