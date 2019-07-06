assembler\bass.exe -o "ssb64asm.z64" main.asm -sym logfile.log
assembler\chksum64.exe "ssb64asm.z64"
assembler\rn64crc.exe -u
pause