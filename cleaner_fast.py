import os
import sys

main_folder = sys.argv[1]
max_sizeGB = int(sys.argv[2])
max_sizeByte = max_sizeGB * 1073741824

if(sys.argv[3]=="-v"):
  print(main_folder)
  print(max_sizeByte)

def get_folders(folder_path):
  folder_list = []
  for path, dirs, files in os.walk(folder_path):
    for folder in dirs:
      folder_path = os.path.join(path, folder)
      folder_list.append(folder_path)
  return folder_list

def get_folder_size(folder_path):
  size=0
  for path, dirs, files in os.walk(folder_path):
    for f in files:
      fp = os.path.join(path, f)
      size += os.path.getsize(fp)
  return size

def get_files(folder_path):
  files_list = get_folders(folder_path)
  for path, dirs, files in os.walk(folder_path):
    for f in files:
      fp = os.path.join(path, f)
      if(".ini" in fp):
        continue
      files_list.append(fp)
  return files_list


def main():
  if(sys.argv[3]=="-v"):
    print(get_folder_size(main_folder))
  while(get_folder_size(main_folder) > max_sizeByte):
    list_folders = get_folders(main_folder)
    if(sys.argv[3]=="-v"):
      print("\nFOLDERS:")
      for folder in list_folders:
        print(folder)
    list_files = get_files(list_folders[0])
    # if(sys.argv[3]=="-v"):
    #   print("\nFILES IN ",list_folders[0])
    #   for file in list_files:
    #     print(file)
    for file in list_files:
      os.remove(file)
      # if(sys.argv[3]=="-v"):
      #   print(file,"\tremoved")
    for folder in list_folders:
      if get_folder_size(folder) == 0:
        os.rmdir(folder)
        if(sys.argv[3]=="-v"):
          print("\n",folder,"\tremoved")


main()
sys.exit()

