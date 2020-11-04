@echo off
echo Flexing...
win_flex --wincompat -o hw6.flex.cpp hw6.l
echo.
echo Bisoning...
win_bison --defines=hw6.tab.h -o hw6.tab.cpp -r all --report-file=hw6.tab.output hw6.y
echo.
echo Compiling...
echo.
cppcompileall hw6.exe
