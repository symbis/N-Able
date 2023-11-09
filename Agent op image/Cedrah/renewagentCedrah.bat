@echo off
net stop "Windows Agent Service"
net stop "Windows Agent Maintenance Service"
"C:\Program Files (x86)\N-able Technologies\Windows Agent\bin\NcentralAssetTool.exe" -d
"C:\Program Files (x86)\BeAnywhere Support Express\GetSupportService_N-Central\uninstall.exe" /S
"C:\Program Files (x86)\SolarWinds MSP\CacheService\unins000.exe"
"C:\Program Files (x86)\SolarWinds MSP\RpcServer\unins000.exe"
"C:\Program Files (x86)\SolarWinds MSP\PME\unins000.exe"
del "C:\ProgramData\N-Able Technologies\Windows Agent\config\ConnectionString_Agent.xml"
Echo Remove old Agent
MsiExec.exe /X{1D35A03E-E581-4838-9EE3-244DBBF51415}
Echo Install new Agent
WindowsAgentSetup.exe /s /v" /qn CUSTOMERID=103 CUSTOMERNAME=Cedrah REGISTRATION_TOKEN=2d08829b-5242-be78-f3a4-013f328da52e SERVERPROTOCOL=HTTPS SERVERADDRESS=login.zorgvoorict.nl SERVERPORT=443 "
Echo Install new Agent completed
Pause

