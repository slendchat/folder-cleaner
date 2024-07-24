# autodelete_script

To run program type following command
after folder path write max size of folder in GB

.\autoClean.exe C:\path\to\folder 300

# what program does

program gets path to the folder containing folders in which are files
after the program analyses the size of each folder and deletes oldest files from those folders
in order to make them less or equal minimum size

# compile
to compile just use pyinstaller -F autoClean.py
