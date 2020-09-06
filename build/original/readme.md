1. Create original.z64 from original.xdelta.
2. In GE Editor, open original.z64 and export all files to this directory. Choose "No" when prompted to use the VPK extension.
3. Make any updates to the files, and track them in incremental.csv.
4. Run `create_original_from_incremental.bat` to create a new original.z64.
5. When you are ready to commit a new original.xdelta to master, update master.csv accordingly. 