FOR %%A IN (%*) DO (
	java -jar "%~dp0SSB64ImageFileAppender.jar" "0A05" %%A
	move "%%~dpA0A05-new.bin" "%%~dpA0A05.bin"
)
pause