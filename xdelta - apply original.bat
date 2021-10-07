@echo off
echo %cmdcmdline%|find /i """%~f0""">nul && set isclick=true
pushd %~dp0
xdelta -d -f -s "roms\ssb.rom" original.xdelta roms\original.z64
popd
if ["%isclick%"]==["true"] pause
