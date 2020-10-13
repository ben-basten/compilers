# Basic Lexical Analyzer

This is a lexical analyzer that will continually recognize integers, floating point numbers, variables, strings, and C-style comments. It reads from standard input and writes to standard output.

### Setup Instructions
* Create a new Visual Studio project and add the `HW2.l` file to the source files
* Right click the solution, then click `Build Dependencies > Build Customizations > Find Existing...`
* Choose the `Setup > win_flex_bison-build > custom_build_rules > win_flex_bison_custom_build.targets` file and hit OK
*  Make sure that new build target is selected in the checklist and hit OK
* Go to `Build > Rebuild Solution` then run the program with the Local Windows Debugger
* _If there is an error running the analyzer, click the "Show All Files" button in the Solution Explorer and make sure to include the `HW2.flex.cpp` file in the solution. Run with Local Windows Debugger again._
* Once the console appears, try the various types of inputs and watch the analyzer do its work! See `sample-input.in` for some examples of various positive and negative outcome inputs. This can also be configured to take in inputs from the command line.