assembler\bass.exe -o "ssb64_asm.z64" main.asm
assembler\chksum64.exe "ssb64_asm.z64"
assembler\rn64crc.exe -u
pause