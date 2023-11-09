net stop "Windows Agent Service"
net stop "Windows Agent Maintenance Service"

del "C:\Program Files (x86)\N-able Technologies\Windows Agent\config\ApplianceConfig.xml"
del "C:\Program Files (x86)\N-able Technologies\Windows Agent\config\ApplianceConfig.xml.backup"
del "C:\ProgramData\N-Able Technologies\Windows Agent\config\ConnectionString_Agent.xml"

cd "C:\Program Files (x86)\N-able Technologies\Windows Agent\bin\"
ncentralassettool.exe -d

pause