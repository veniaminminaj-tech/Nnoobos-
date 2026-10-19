@echo off
title NedohackersOS Beta Desktop
py -3 desktop_beta.py
if errorlevel 1 (
  echo.
  echo Could not start. Install Python 3 from https://www.python.org/downloads/ and enable Tcl/Tk.
  pause
)
