# Simple Printing Compiler

This is a basic compiler that will print integers, floating point numbers, and strings. It converts the text input into crude MIPS code that will print to the console. It also recognizes C-style block or single comments in the code.

### Grammar Details
The grammar is loosely oriented around French. Any keywords in the grammar are not case sensitive (ex. `ecrivez` does the same thing as `eCriVEZ`).
`rien` - equivalent to void in Java
`ecrivez` - "print"

Example method that this compiler supports:

    rien sample () {
        ecrivez ("This is a string!"); // prints a string
        ECRIVEZ (-11); // prints an integer
        eCrIvEz (3.72); // prints a float
    }

### Setup Instructions
There is a `make.bat` file that should compile everything for you. It uses the Visual Studio C++ compiler to compile the C++ code, so Visual Studio Professional or Visual Studio Community must be installed on your PC. 

* Run `make.bat` file in this directory. 
* _Note: if the C++ compilation fails, it's probably an issue with the path that `cppcompileall.exe` uses to run the Visual Studio compiler. I'm sorry. To fix this, `cppcompileall.c` is available in the setup folder. The path varies from system to system and the C code will need to be recompiled._
* Run the hw4.exe file after compilation is successfully completed in the Command Prompt with the command: `hw4.exe > hw4.asm`. The assembly code will be generated in the hw4.asm file. 
* Run hw4.asm in the qtSpim emulator to see the results printed to the console.