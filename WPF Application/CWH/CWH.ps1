#========================================================================
#
# Tool Name	: Custom Wizard Hydration WPF 1.3
# Author 	: Jérôme Bezet-Torres
# Date 		: 02/11/2019
# Website	: http://JM2K69.github.io/
# Twitter	: https://twitter.com/JM2K69
#
#========================================================================

##Initialize######
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework')			| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       			| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.IconPacks.dll')     	| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\ControlzEx.dll')       			| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null
[String]$ScriptDirectory = split-path $myinvocation.mycommand.path
function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("$ScriptDirectory\CWH.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)


$XamlMainWindow.SelectNodes("//*[@Name]") | %{
    try {Set-Variable -Name "$("WPF_"+$_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop}
    catch{throw}
    }
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable *WPF*
}
  #Get-FormVariables



#########################################################################
#                       Functions       								#
#########################################################################

	function Encrypt_Password($Crypter)
	{
		$MDP = [System.Text.Encoding]::UTF8.GetBytes($Crypter)
		
		$value = [System.Convert]::ToBase64String($MDP)
		
		return $value
		
	}
	
	function Decrypt_Password($decrypter)
	{
		$MDP = [System.Convert]::FromBase64String($decrypter)
		
		$value = [System.Text.Encoding]::UTF8.GetString($MDP)
		
		return $value
	}
	function Test-IsEmpty ([string]$Text)
	{
		return [string]::IsNullOrEmpty($Text)
		
	}

#########################################################################
#                       END Functions       							#
#########################################################################
$Global:InfoD = ""
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
$WPF_Computer_Name.Text 				= $tsenv.Value("HydrationOSDComputerName") 
$WPF_Local_Admin_PWD.Password 			= Decrypt_Password($tsenv.Value("AdminPassword"))
$WPF_ADDS_DRM_PWD.Password 				= Decrypt_Password ($tsenv.Value("SafeModeAdminPassword"))
$WPF_DHCP_DNS.Text						= $tsenv.Value("DHCPServerOptionDNSServer")
$WPF_DHCP_Domain_name.Text 				= $tsenv.Value("DHCPServerOptionDNSDomainName")
$WPF_DHCP_EndIP.Text   					= $tsenv.Value("DHCPScopes0EndIP")          
$WPF_DHCP_Name.Text 					= $tsenv.Value("DHCPScopes0Name")                            
$WPF_DHCP_Routeur.Text  				= $tsenv.Value("DHCPServerOptionRouter")
$WPF_DHCP_Scope.Text    				= $tsenv.Value("DHCPScopes0IP")          
$WPF_DHCP_StartIP.Text     				= $tsenv.Value("DHCPScopes0StartIP")                   
$WPF_DNS_Server.Text 					= $tsenv.Value("OSDAdapter0DNSServerList")
$WPF_Domain_DNS_Name.Text 				= $tsenv.Value("NewDomainDNSName")
$WPF_Domain_NetBios_Name.Text 			= $tsenv.Value("DomainNetBiosName")
$WPF_Gateway.Text 						= $tsenv.Value("OSDAdapter0Gateways")
$WPF_IPAddress.Text 					= $tsenv.Value("OSDAdapter0IPAddressList")
$WPF_Platform_Virtualization.Text		= $tsenv.Value("VMPLATFORM")
$WPF_Site_Name.Text 					= $tsenv.Value("SiteName")
$WPF_SubnetMask.Text 					= $tsenv.Value("OSDAdapter0SubnetMask")
$WPF_UserName.Text						= $tsenv.Value("DomainAdmin")
$WPF_VM_Memory.Text						= $tsenv.Value("MEMORY")
$WPF_WinPe_ADK.Text						= $tsenv.Value("OSCURRENTBUILD")
$WPF_WinPe_Language.Text				= $tsenv.Value("UILANGUAGE")
$WPF_Tabcontrol.selecteditem 			= $WPF_Tabcontrol.Items[0]
$WPF_Choose_Network.IsEnabled			= $false
$WPF_Choose_Domain_WKG.IsEnabled 		= $false
$TestBios								= $tsenv.Value("ISUEFI")

switch ($TestBios)
{
    'False' {$WPF_Bios_UEFI.Text="Bios"}
    'True' {$WPF_Bios_UEFI.Text="UEFI"}

}

$TestDomain = Test-IsEmpty $tsenv.Value("JoinWorkgroup")

if ($TestDomain -eq $true) {
	
	$WPF_Domaine_Wkg_txtbox.Text			= $tsenv.Value("JoinDomain")
	$WPF_UserName.Text						= Decrypt_Password ($tsenv.Value("DomainAdmin"))
	$WPF_ADDS_Admin_PWD.Password			= Decrypt_Password ($tsenv.Value("DomainAdminPassword"))
	$WPF_Local_Admin_PWD.Password 			= Decrypt_Password ($tsenv.Value("DomainAdminPassword"))
	$WPF_Domain_DNS_Name.Text  				= $WPF_Domaine_Wkg_txtbox.Text
	$WPF_DHCP.IsEnabled = $false
}
if ($TestDomain -eq $false) {
	
	$WPF_Domaine_Wkg_txtbox.Text			= $tsenv.Value("JoinWorkgroup")
}


###################################################
#        Disable Edit on VM InFo Part             #
###################################################
$WPF_WinPe_Language.IsEnabled 			= $false
$WPF_WinPe_ADK.IsEnabled 				= $false
$WPF_VM_Memory.IsEnabled 				= $false
$WPF_Platform_Virtualization.IsEnabled	= $false
$WPF_Bios_UEFI.IsEnabled				= $false
###################################################
#      			 End Part     				      #
###################################################


if ( ($tsenv.Value("VMTOOLS") -eq "YES") ) {
		$WPF_VMTOOLS.IsChecked = "True"
}
# Check Workgroup Or domain ADDS

if( $($($WPF_Domaine_Wkg_txtbox.Text).split(".").count -ge "2" ))
{
	$Global:InfoD = "ADDS"
	$WPF_Mode_Domain.IsSelected = $true
	$WPF_Domain_Block.Visibility = "Visible"

	#Make Read Only AD DS Section
	$WPF_Domain_DNS_Name.IsEnabled 		= $false
	$WPF_Domain_NetBios_Name.IsEnabled 	= $false
	$WPF_ADDS_DRM_PWD.IsEnabled			= $false
	$WPF_Site_Name.IsEnabled			= $false
	$WPF_OU_SRV.IsEnabled 				= $true
	$WPF_OU_COMP.IsEnabled 				= $true

	$NB = $($WPF_Domain_DNS_Name.Text).split(".").count

	if ($NB -eq "3")
	{
		$WPF_Domain_NetBios_Name.IsEnabled = $false
		$NetBios = $($WPF_Domain_DNS_Name.Text).split(".")[0]
		$WPF_Domain_NetBios_Name.Text = $NetBios.ToUpper()
	}
	if ($NB -eq "2")
	{
		$WPF_Domain_NetBios_Name.IsEnabled = $false
		$NetBios = $($WPF_Domain_DNS_Name.Text).split(".")[0]
		$WPF_Domain_NetBios_Name.Text = $NetBios.ToUpper()
	}


}
if( $($($WPF_Domaine_Wkg_txtbox.Text).split(".").count -eq "1" )) {
		$Global:InfoD = "WRK"
		$WPF_Domain_Block.Visibility = "Collapsed"
		$WPF_UserName.IsEnabled = $false 
		$WPF_ADDS_Admin_PWD.IsEnabled = $false	
		$WPF_Mode_Workgroup.IsSelected = $true
		$WPF_OU_SRV.IsEnabled = $false
		$WPF_OU_COMP.IsEnabled = $false
		$WPF_Override.IsEnabled = $false
	}

$WPF_Apply_ADDS.add_Click({
	if(	$WPF_DHCP.IsEnabled -ne $false	)
	{
		$WPF_Tabcontrol.selecteditem = $WPF_Tabcontrol.Items[4]

		if ($($($WPF_Domain_DNS_Name.Text).split(".").count -eq "2")) 
		{
			
			if ($Global:InfoD -ne "ADDS") {
				$Dom = $($($WPF_Domain_DNS_Name).split(".")[0])
				$Ext = $($($WPF_Domain_DNS_Name).split(".")[1])
				
				if ($WPF_OU_SRV.IsChecked -eq $true) {
					
					$Tsenv.Value("MachineObjectOU") = "OU=Servers,OU=Equipment,dc=$dom,dc=$Ext"

				}
				if ($WPF_OU_COMP.IsChecked -eq $true) {
					
					$Tsenv.Value("MachineObjectOU") = "OU=Computers,OU=Equipment,dc=$dom,dc=$Ext"

				}
			}
		}

		if ($($($WPF_Domain_DNS_Name.Text).split(".").count -eq "3")) 
		{
			
			if ($Global:InfoD -ne "ADDS") {
				$Dom1 = $($($WPF_Domain_DNS_Name).split(".")[0])
				$Dom2 = $($($WPF_Domain_DNS_Name).split(".")[1])
				$Ext = $($($WPF_Domain_DNS_Name).split(".")[2])
				
				if ($WPF_OU_SRV.IsChecked -eq $true) {
					
					$Tsenv.Value("MachineObjectOU") = "OU=Servers,OU=Equipment,dc=$dom1,dc=$dom2,dc=$Ext"

				}
				if ($WPF_OU_COMP.IsChecked -eq $true) {
					
					$Tsenv.Value("MachineObjectOU") = "OU=Computers,OU=Equipment,dc=$dom1,dc=$dom2,dc=$Ext"

				}
			}
		}

	}
	$tsenv.Value("NewDomainDNSName") 		= $WPF_Domain_DNS_Name.Text
	$tsenv.Value("DomainNetBiosName")		= $WPF_Domain_NetBios_Name.Text
	$tsenv.Value("SafeModeAdminPassword")	= Encrypt_Password ($WPF_ADDS_DRM_PWD.Password)
	$tsenv.Value("SiteName")				= $WPF_Site_Name.Text

	$WPF_Apply_ADDS.IsEnabled = $false
})

$WPF_Apply_Computer.add_Click({
	
	$WPF_Tabcontrol.selecteditem = $WPF_Tabcontrol.Items[2]
	$WPF_Apply_Computer.IsEnabled = $false

	if ($Global:InfoD -eq "WRK")
	{
		$tsenv.Value("HydrationOSDComputerName") 	= $WPF_Computer_Name.Text 
		$tsenv.Value("AdminPassword") 				= Encrypt_Password ($WPF_Local_Admin_PWD.Password)
		$tsenv.Value("JoinWorkgroup")				= $WPF_Domaine_Wkg_txtbox.Text
		
	}
	if ($Global:InfoD -eq "ADDS")
	{
		$tsenv.Value("HydrationOSDComputerName") 	= $WPF_Computer_Name.Text 
		$tsenv.Value("AdminPassword") 				= Encrypt_Password ($WPF_Local_Admin_PWD.Password)
		$tsenv.Value("JoinDomain")					= $WPF_Domaine_Wkg_txtbox.Text
		$tsenv.Value("DomainAdmin") 				= $WPF_UserName.Text
		$tsenv.Value("DomainAdminPassword")			= Encrypt_Password ($WPF_ADDS_Admin_PWD.Password)
		
	}

})

$WPF_Apply_DHCP.add_Click({

$tsenv.Value("DHCPServerOptionDNSServer") 		= $WPF_DHCP_DNS.Text					 
$tsenv.Value("DHCPServerOptionDNSDomainName")	= $WPF_DHCP_Domain_name.Text 				 
$tsenv.Value("DHCPScopes0EndIP")				= $WPF_DHCP_EndIP.Text   					           
$tsenv.Value("DHCPScopes0Name")					= $WPF_DHCP_Name.Text	
$tsenv.Value("DHCPServerOptionRouter")			= $WPF_DHCP_Routeur.Text  				
$tsenv.Value("DHCPScopes0IP")					= $WPF_DHCP_Scope.Text    				           
$tsenv.Value("DHCPScopes0StartIP")  			= $WPF_DHCP_StartIP.Text     				                  

$WPF_Apply_DHCP.IsEnabled = $false					
	
})

$WPF_Apply_NetWork.add_Click({
	
	$WPF_Tabcontrol.selecteditem = $WPF_Tabcontrol.Items[3]

	$tsenv.Value("OSDAdapter0IPAddressList")	= $WPF_IPAddress.Text
	$tsenv.Value("OSDAdapter0Gateways")			= $WPF_Gateway.Text
	$tsenv.Value("OSDAdapter0SubnetMask")		= $WPF_SubnetMask.Text
	$tsenv.Value("OSDAdapter0DNSServerList")	= $WPF_DNS_Server.Text
	$WPF_Apply_NetWork.IsEnabled = $false
})

$WPF_Apply_VMInfo.add_Click({
	$WPF_Tabcontrol.selecteditem = $WPF_Tabcontrol.Items[1]
	
	# Check VMware Tools for HydrationKit VM
	if ($WPF_VMTOOLS.IsChecked -eq "True") {
		$tsenv.Value("VMTOOLS") = "YES" 
	}
	$WPF_Apply_VMInfo.IsEnabled = $false	
	

})

$WPF_Domaine_Wkg_txtbox.add_TextChanged({

	if( $Global:InfoD -eq "ADDS")
	{
		$WPF_Domain_DNS_Name.Text = $WPF_Domaine_Wkg_txtbox.Text
		
	}
})
$WPF_Override.add_Click({
	
	$WPF_Domain_NetBios_Name.IsEnabled =$true
	
})

$WPF_Domain_DNS_Name.add_TextChanged({

	$NB = $($WPF_Domain_DNS_Name.Text).split(".").count

	if ($NB -eq "3")
	{
		$WPF_Domain_NetBios_Name.IsEnabled = $true
		$NetBios = $($WPF_Domain_DNS_Name.Text).split(".")[0]
		$WPF_Domain_NetBios_Name.Text = $NetBios.ToUpper()
	}
	if ($NB -eq "2")
	{
		$WPF_Domain_NetBios_Name.IsEnabled = $false
		$NetBios = $($WPF_Domain_DNS_Name.Text).split(".")[0]
		$WPF_Domain_NetBios_Name.Text = $NetBios.ToUpper()
	}
})

$WPF_Domain_DNS_Name.add_TextChanged({

	$WPF_DHCP_Domain_name.IsEnabled = $false
	$WPF_DHCP_Domain_name.Text = $WPF_Domain_DNS_Name.Text
})

$WPF_Modify.add_Click({

	# Enable All Button again
		$WPF_Apply_VMInfo.IsEnabled = $true	
		$WPF_Apply_NetWork.IsEnabled = $true
		$WPF_Apply_DHCP.IsEnabled = $true				
		$WPF_Apply_Computer.IsEnabled = $true
		$WPF_Apply_ADDS.IsEnabled = $true
})

$WPF_Exit.add_Click({
	Exit
})
$Form.ShowDialog() | Out-Null

