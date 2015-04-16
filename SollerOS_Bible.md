## Intro ##
Welcome to a collection of all of the things every SollerOS programmer should know. This page will include information about basic program structure, the various interfaces that programmers can use for their programs, and other things that are needed to use SollerOS to its full potential(albeit a very low potential).

## With Library ##
Since version 140 there is a simple library that may be included at the beginning of a program. This should make it easier to code programs.
### Program Structure ###
Program structure is still the same though the library handles it more easily. A hello world program now looks more like this:
```
%include "include.asm"
mov esi, msg
call print
jmp exit

msg db "Hello World!",0
```

### System Calls ###
Now you may use easy to remember syscalls to do what used to be done using interrupts.
#### print ####
This prints the string in ESI.
  * ESI=Location of zero-terminated string.
#### read ####
This reads input into ESI.
  * ESI=Location of buffer.
  * ECX=length of buffer.
#### showdec ####
This prints a number in decimal.
  * ECX=Number.
#### showhex ####
This prints a number in hexadecimal.
  * ECX=Number.
#### run ####
This runs a command in ESI.
  * ESI=Location of zero-terminated command string.
#### exit ####
This exits with an error code in BL.
  * BL=Error code.

## Without Library ##
### Program Structure ###
Program structure is very important because any failure to adhere to this structure could cause problems when you try to run your program. The basic structure of a hello world program in SollerOS is as follows:
```
[BITS 32]      ;make sure that the program uses 32 bit pointers
[ORG 0x400000] ;this is the place where the program will be loaded
db "EX"        ;this marks the file as an executable
mov esi, msg   ;move the location of the message into esi
mov bx, 7      ;this is the color of the font-7 is white on black
mov al, 0      ;the string ends in 0
mov ah, 1      ;this is the number of the print string function
int 0x30       ;this is the interrupt used to call the function
mov ah, 0      ;choose the quit application function
int 0x30       ;quit the application
   
msg db "Hello World!",0  ;zero terminated string
```
  * First tell the compiler that this is a 32 bit program with its origin at 0x4000000
  * Next tell SollerOS that this is an executable
  * Type your code which should end with the quit application function call
  * Finally, type your data

### Interrupts ###
The 0x30 Interrupt Vector is used to communicate with SollerOS and have it perform basic functions.
#### AH=0 ####
This quits the program.
  * EBX=Exit Code. A non-zero value gives an error.
#### AH=1 ####
This prints strings with the following properties:
  * AL=Terminating character in the string, usually 0
  * BL=Modifier of the string, usually 7
  * ESI=Location of the string to print
#### AH=2 ####
This reads strings from user input with the following properties:
  * AL=Terminating character, usually 10 (which is the Enter key).
  * ESI=Buffer to put the string into.
  * ECX=Length of buffer.
  * **ESI**=Zero-terminated string read from user input.
#### AH=3 ####
This clears the screen.
#### AH=4 ####
This both reads a string from user input and prints it to the screen with the following properties:
  * AL=Terminating character, usually 10.
  * BL=Modifier.
  * ESI=Buffer to put the string into.
  * ECX=Length of buffer.
  * **ESI**=Zero-terminated string read from user input.
#### AH=5 ####
This reads a character from user input with the following properties:
  * AL=Zero if the function should wait for a keypress and nonzero if it should not wait.
  * **AL**=Character read from user input.
#### AH=6 ####
This prints a character to the screen with the following properties:
  * AL=Character to print.
  * BL=Modifier.
#### AH=7 ####
This reads a file from the disk with the following properties:
  * ESI=Location in memory where file should be placed.
  * EDI=Location of zero-terminated string containing the file's filename.
#### AH=8 ####
This will write files but is not implemented.
#### AH=9 ####
This prints a number to the screen.
  * ECX=Number.
  * AL=0 if decimal output is wanted.
  * AL=1 if hexadecimal output is wanted.
#### AH=10 ####
This converts text into a number.
  * ESI=Zero-terminated string containing number.
  * **ECX**=Number.
#### AH=11 ####
This forks the current thread.
  * ESI=Start address of new thread.
  * _For the new thread, all other registers_=Previous values.
  * **EBX**=PID of new thread.
#### AH=12 ####
This gets the current Unix time.
  * **EAX**=Unix time in seconds.
  * **EBX**=Nanoseconds after the second.
  * **ECX**=Microseconds after the second.
#### AH=13 ####
This sets the current Unix time.
  * EAX=Unix time in seconds.
  * EBX=Nanoseconds after the second.
#### AH=14 ####
This runs a command in the place of the current process.
  * ESI=Zero-terminated command string.
  * **EBX**=Error code from process.
#### AH=15 ####
This returns program information for the current process.
  * **EBX**=Owner's UID.
  * **EDX**=PID.
  * **ESI**=Command string.
  * **EDI**=End of command string.
  * **ECX**=Number of arguments.