FOR %%A IN (%*) DO (
	java -jar "%~dp0SSB64ImageFileAppender.jar" "153E" %%A
	move "%%~dpA153E-new.bin" "%%~dpA153E.bin"
)
pause