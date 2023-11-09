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
MsiExec.exe /X{32371AA7-85F3-4A2B-9831-BA762735032A}
Echo Install new Agent
WindowsAgentSetup.exe /s /v" /qn CUSTOMERID=114 CUSTOMERNAME=Adullam REGISTRATION_TOKEN=8f3db49e-7f6f-ba2a-64a4-0be8f2610046 SERVERPROTOCOL=HTTPS SERVERADDRESS=login.zorgvoorict.nl SERVERPORT=443 "
Echo Install new Agent completed
Pause

