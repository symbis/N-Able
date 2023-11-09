' ******************************************************************************
' Script: TDS-TimeDriftCalc.vbs
' Version: 1.4
' Author: Tony Baker
' Description: This script measures the time difference between local and NTP defined server 
'				and publishes to the
'              WMI Class in the root\NCentral WMI namespace.
' Date: March 1st, 2012
' ******************************************************************************



' Version History

' 1.0 - Initial Release (2012-03-01)
' 1.1 - Adjusted script to take a paramater, otherwise use pool.ntp.org as the server
' 1.2 - Added wscriptout so you get information when running the script from N-Able (29-05-2012 Léon Boers)
' 1.4 - 


' ******************************************************************************
' 			Variables Defined
' ******************************************************************************
' Structure and WMI Related.  Do not ammend
	Option Explicit
	dim HKEY_LOCAL_MACHINE, strComputer, objReg, strTrendKeyPath, InputRegistryKey1, InputRegistryKey2
	dim InputRegistryKey3, InstalledAV, NamespacePresense, objClassCreator, objGetClass, objWMIObject
	dim RegstrValue, ReturneddwValue1, objWMIService, objItem, objNameSpace, ReturneddwValue2
	dim wbemCimtypeString, wbemCimtypeUint32, colNamespaces, objNewNamespace
	dim RawAVVersion, FormattedAVVersion, objNewInstance, strWMINamespace, ParentWMINamespace
	dim ReturnedstrValue1, strValue, FormattedPatternAge, CalculatedPatternAge, CurrentDate
	dim WMINamespace, strWMIClassWithQuotes, strWMIClassNoQuotes, colClasses, objClass 
	dim strTestKeyPath, Registry, arrValueNames, strSymantecESKeyPath, WshShell
	dim ReturnedBinaryArray1(7), bytevalue, i,SymantecAvPatternDate
	dim wbemCimtypeBoolean, ReturneddwValue3, InputRegistryKey4, output, temp, teller, NTPSecAfgerond
		HKEY_LOCAL_MACHINE = &H80000002
		strComputer = "."
		wbemCimtypeString = 8
		wbemCimtypeUint32 = 19
		wbemCimtypeBoolean = 11
		Const wbemFlagReturnImmediately = &h10
		Const wbemFlagForwardOnly = &h20 
		Set objReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
		Set ParentWMINamespace = GetObject("winmgmts:\\" & strComputer & "\root")
		Set WshShell = WScript.CreateObject("WScript.Shell")
    Set output = Wscript.stdout
    teller = 0
    
' Script Specified - Add any additional Scripts necessary for this file here.
	Dim objNTInfo, hostname, splithostname, NTPServer, differentialRaw,  NTPTotalDrift, x, args
	Dim objExecObject, strLine, strLineFirst8
		strWMIClassWithQuotes = chr(34) & "NTPTotalDrift" & chr(34)
		strWMIClassNoQuotes = "NTPTotalDrift"
		strWMINamespace = "NAble"



' ******************************************************************************
' 			Call Functions to perform actions
' ******************************************************************************

	' Calculate Data to Store in WMI
		CalculateClockDrift
 
	'Check to see if an instance of the WMI namespace exists; if it does, 
	'check to see if the WMI class exists. If the class exists, delete it, recreate it, and populate it
		If WMINamespaceExists(ParentWMINamespace) Then
		'      wscript.echo "The Namespace already exists."
			  If WMIClassExists(strComputer,strWMIClassWithQuotes) Then
		'          wscript.echo "The WMI Class exists"
				  WMINamespace.Delete strWMIClassNoQuotes
				  CreateWMIClass
				  PopulateWMIClass
			  Else
		'          wscript.echo "The Namespace exists, but the WMI class does not. Curious." 
				  CreateWMIClass
				  PopulateWMIClass      
			  End If
		  Else
			  'Create the WMI Namespace (if it doesn't already exist), the WMI Class, and populate the class with data.              
		'      wscript.echo "The WMI Namespace and Class does not exist"
			  CreateWMINamespace
			  CreateWMIClass
			  PopulateWMIClass 
		  End If    
                
                
' *****************************  
' Function: CalculateClockDrift
' 		Returns "NTPTotalDrift" for use in writing to WMI
'		Adapted from http://www.visualbasicscript.com/How-to-count-files-in-directory-m445.aspx
' *****************************
Sub CalculateClockDrift
output.writeline  "running 1.4"
	'' Detrmine which remote system to acquire time from.
  
	if WScript.Arguments.Count = 0 then
		NTPServer = "pool.ntp.org"
	else
		set args = WScript.Arguments
		NTPServer = args.Item(0)
	end if
	
	
	
	
	
	
	'' Runs w32tm /stripchart /computer:
	Set objExecObject = WshShell.Exec("w32tm /stripchart /dataonly /samples:1 /computer:" & NTPServer)
  
	'Do Until objExecObject.StdOut.AtEndOfStream
		' First line will report failure if network server could not be reached.  Set -1 if this happens
		strLine = objExecObject.StdOut.ReadLine()
		strLineFirst8 = mid(strLine,1,8)
		
		if strLineFirst8 = "Tracking" Then
			' We know the NTP server was reached and data was returned.  Continue collecting accurate value
			'dump 2 more lines. they contain useless data.
			objExecObject.StdOut.ReadLine()
			objExecObject.StdOut.ReadLine()
      
			strLine = objExecObject.StdOut.ReadLine()
			differentialRaw = split(strLine)
						
			if instr(differentialRaw(1),"rror:") > 0 then	
				NTPTotalDrift = -1
        NTPSecAfgerond = 0
        output.WriteLine "Error finding time difference. falling back to -1 sec"
			Else 
				'Removes lead character, multiplies by 1000
        'Removed multiplie by 1000, doesnt seem to be needed on window 2008 R2
				NTPTotalDrift = mid(differentialRaw(1),2,6)
        temp =  split(NTPTotalDrift,".")
        for each x in temp
            if teller = 0 then
              NTPSecAfgerond = (x * 1)
              teller = teller + 1
            end if 
        next   
			End If
			
				
		Else
			' The server could not be reached. Set resulting value to -1
			NTPTotalDrift = -1
			NTPSecAfgerond = 0
		End If
		output.writeline "afgerond tijds verschil:" & NTPSecAfgerond
		output.WriteLine "Total Drift (sec): " & NTPTotalDrift
    output.writeline "Compared with: " & NTPServer
		                        
	
End Sub


' *****************************  
' Sub: PopulateWMIClass
'    This sub needs to be updated with the name of the WMI instance to write as well as the value to write to it.
' *****************************
Sub PopulateWMIClass    
    'Create an instance of the WMI class using SpawnInstance_
    Set WMINamespace = GetObject("winmgmts:\\" & strComputer & "\root\" & strWMINamespace)
    Set objGetClass = WMINamespace.Get(strWMIClassNoQuotes)
    Set objNewInstance = objGetClass.SpawnInstance_
    objNewInstance.NTPTotalDrift = NTPTotalDrift
    objNewInstance.Displayname = NTPServer
    objNewInstance.NTPTotalAfgerond = NTPSecAfgerond
    objNewInstance.Put_()
End Sub
  
  
 



' *****************************  
' Sub: CreateWMINamespace
' *****************************
Sub CreateWMINamespace
    Set objItem = ParentWMINamespace.Get("__Namespace")
    Set objNewNamespace = objItem.SpawnInstance_    
    objNewNamespace.Name = strWMINamespace
    objNewNamespace.Put_
End Sub



' *****************************  
' Sub: CreateWMIClass
' *****************************
Sub CreateWMIClass
    Set objWMIService = GetObject("Winmgmts:root\" & strWMINamespace)
    Set objClassCreator = objWMIService.Get() 'Load the Namespace           
    'Define the Properties of the WMI Class
    objClassCreator.Path_.Class = "" & strWMIClassNoQuotes
    
    objClassCreator.Properties_.add "Displayname", wbemCimtypeString
    objClassCreator.Properties_.add "NTPTotalDrift", wbemCimtypeString
    objClassCreator.Properties_.add "NTPTotalAfgerond", wbemCimtypeUint32
                
                
    ' Make the 'Displayname' property a 'key' (or index) property
    objClassCreator.Properties_("Displayname").Qualifiers_.add "key", true
                
    ' Write the new class to the 'root\NAble' namespace in the repository
    objClassCreator.Put_

End Sub
    
    
' *****************************  
' Function: WMINamespaceExists
' Thanks to http://www.cruto.com/resources/vbscript/vbscript-examples/misc/wmi/List-All-WMI-Namespaces.asp for this code 
' *****************************
Function WMINamespaceExists(ParentWMINamespace)
                WMINamespaceExists = vbFalse
                Set colNamespaces = ParentWMINamespace.InstancesOf("__Namespace")
                For Each objNamespace In colNamespaces
                      If instr(objNamespace.Path_.Path,strWMINamespace) Then
                            WMINamespaceExists = vbTrue
                      End if
                Next
                Set colNamespaces = Nothing
End Function


  


' *****************************  
' Function: WMIClassExists
' Thanks to http://gallery.technet.microsoft.com/ScriptCenter/en-us/a1b23364-34cb-4b2c-9629-0770c1d22ff0 for this code 
' *****************************
Function WMIClassExists(strComputer, strWMIClassWithQuotes)
                WMIClassExists = vbFalse
                Set WMINamespace = GetObject("winmgmts:\\" & strComputer & "\root\" & strWMINamespace)
                Set colClasses = WMINamespace.SubclassesOf()
                For Each objClass In colClasses
                      If instr(objClass.Path_.Path,strWMIClassNoQuotes) Then
                            WMIClassExists = vbTrue
                      End if
                Next
                Set colClasses = Nothing
End Function  
  
     

    




' *****************************  
' Function: RegKeyExists
' Returns a value (true / false)
' Thanks to http://www.tek-tips.com/faqs.cfm?fid=5864 for this code
'************************************


Function RegKeyExists (RegistryKey)

    'If there isn't the key when we read it, it will return an error, so we need to resume
    On Error Resume Next

    'Try reading the key
    WshShell.RegRead(RegistryKey)

    'Catch the error
    Select Case Err
      'Error Code 0 = 'success'
      
      Case 0:
        RegKeyExists = true
      'Any other error code is a failure code
      
      Case Else:
        RegKeyExists = false
    End Select

    'Turn error reporting back on
    On Error Goto 0

End Function