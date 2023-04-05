@echo off
@echo on

:: this line gives a prompt and asks you to type something in to assign to it
set /P sm2File="Enter sm2 file name without extension: "
set sm2File=%sm2File%.sm2

:: the cd thing automatically figures out the directory it is in
SET @var=%cd%

:: this is the same as typing what we see below into the console to run the program and give it two inputs
sm2_to_COMSOL_sketchreal %sm2File% %@var%

:: you can comment out the pause if you want, it's just so the window doesn't dissapear
pause