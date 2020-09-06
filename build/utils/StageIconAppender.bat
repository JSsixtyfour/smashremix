FOR %%A IN (%*) DO (
	java -jar "%~dp0SSB64ImageFileAppender.jar" "0A04" %%A
	move "%%~dpA0A04-new.bin" "%%~dpA0A04.bin"
)
pause