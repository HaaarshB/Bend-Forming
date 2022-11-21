#Import needed modules
import os
from re import S
import comtypes.client
from comtypes import COMError
from comtypes.client import CreateObject, GetModule, GetActiveObject

# Followed this website: https://stackoverflow.com/questions/56336926/load-autocad-dwg-files-in-python
# Get help on acad by running this:
# acad = GetActiveObject("AutoCAD.Application")
# help(acad)

# TWO INITIAL STEPS FOR THIS TO WORK:
# Install comtypes in Python using with command "python -m pip install comtypes"
# Set "FILEDIA" variable to "0" in AutoCAD so it stops the popups for exporting the file

def main():
    try:
        acad = GetActiveObject("AutoCAD.Application")
        # print("AutoCAD is active")
    except(OSError, COMError): #If AutoCAD isn't running, run it
        acad = CreateObject("AutoCAD.Application",dynamic=True)
        # print("AutoCAD is successfuly opened")

    #2- Get the paths to the lisp file and the dwg file
    filename = "C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\CreateIGES.dwg"
    commandfile1 = open("C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\impgeometry.scr","r")
    command_str1 = commandfile1.read()
    commandfile1.close()

    #3- Open the drawing file
    try:
        doc = acad.ActiveDocument
        doc.SendCommand(command_str1) # executing my AutoCAD command script
    except(OSError, COMError):
        doc = acad.Documents.Open(filename)
        doc.SendCommand(command_str1)

    #2- Get the paths to the lisp file and the dwg file
    # commandfile2 = open("C:\\Users\\harsh\\Desktop\\perfgeometry.scr","r")
    # command_str2 = commandfile2.read()
    # commandfile2.close()

    #3- Open the drawing file
    # try:
    #    doc = acad.ActiveDocument
    #    doc.SendCommand(command_str2) # executing my AutoCAD command script
    # except(OSError, COMError):
    #    doc = acad.Documents.Open(filename)
    #    doc.SendCommand(command_str2)

if __name__ == '__main__':
    main()