@echo off
echo Flexing...
win_flex --wincompat -o hw4.flex.cpp hw4.l
echo.
echo Bisoning...
echo.
win_bison --defines=hw4.tab.h -o hw4.tab.cpp -r all --report-file=hw4.tab.output hw4.y
echo.
echo Compiling...
echo.
cppcompileall hw4.exe
