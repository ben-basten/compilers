@echo off
echo Flexing...
win_flex --wincompat -o hw8.flex.cpp hw8.l
echo.
echo Bisoning...
win_bison --defines=hw8.tab.h -o hw8.tab.cpp -r all --report-file=hw8.tab.output hw8.y
echo.
echo Compiling...
echo.
cppcompileall hw8.exe