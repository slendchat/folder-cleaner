import os
import sys

print("len of args", len(sys.argv))
print("name of script",sys.argv[0])


main_folder = sys.argv[1]
max_sizeGB = int(sys.argv[2])
max_sizeByte = max_sizeGB * 1073741824

print(main_folder)
print(max_sizeByte)
folder_list = []

for path, dirs, files in os.walk(main_folder):
  for folder in dirs:
    folder_path = os.path.join(path, folder)
    folder_list.append(folder_path)


def get_folder_size(folder_path):
  size=0
  for path, dirs, files in os.walk(folder_path):
    for f in files:
      fp = os.path.join(path, f)
      size += os.path.getsize(fp)
  return size

def get_files_date_ascending(folder_path):
  files_list = []
  for path, dirs, files in os.walk(folder_path):
    for f in files:
      fp = os.path.join(path, f)
      if(".ini" in fp):
        continue
      files_list.append(fp)
  files_list.sort(key=os.path.getctime)
  return files_list


for folder in folder_list:
  print(get_folder_size(folder))
  files = get_files_date_ascending(folder)
  while(get_folder_size(folder) > max_sizeGB):
    os.remove(files[0])
    print(files[0], " removed")
    files.remove(files[0])


sys.exit()