# 🧹 Folder Cleaner (Python)

A set of utilities for automatically cleaning folders if they exceed a specified size limit.

## 📦 Description

The project contains two scripts:

### 🔸 Fast Folder Cleaner (`cleaner_fast.py`)
A simple and fast cleaning method:
- Deletes all contents of the first found subfolder
- Repeats until the folder is below the size limit
- Suitable for temporary data, caches, and logs

### 🔹 Smart Folder Cleaner (`cleaner_smart.py`)
A more careful approach:
- Iterates through all subfolders
- Deletes **old files** first
- Does not touch `.ini` files
- Perfect for logs and important data

## 🛠 Example Usage

```bash
python cleaner_fast.py <path> <limit_in_GB> -v
python cleaner_smart.py <path> <limit_in_GB>
```
## Example

```bash
python cleaner_smart.py D:\Logs 2
```

## IMPORTANT!

+ The scripts will irreversibly delete data
+ Works on Python 3.x
+ Requires access permissions to the specified folder