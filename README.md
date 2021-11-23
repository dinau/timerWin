# timerWin
Timer module for wNim
# Environment
- Windows10 (32bit)  
- nim-1.4.8 (32bit)  
- wnim-0.13.1  
- MingW(32bit)/gcc/clang:  
    - gcc version 10.3.0 (Rev5, Built by MSYS2 project)  
    - clang version 12.0.1:  
       - Target: i686-w64-windows-gnu  
       - Thread model: posix  
# Compilation
1. $ nimble install wNim  
1. Compilation
	1. Compile with [tcc](https://bellard.org/tcc/)  
  $ make   
	1. Compile with gcc   
  $ make TC=gcc  
	1. Compile with clang   
  $ make TC=clang  

# Execute timer.exe:  
![alt](timerWin.gif)
