param(
    $user_name,
    $password,
    $auth_type,
    $adou_path,
    $ip, $port,
    $domain_fqdn,
    $ifdeleteadou,
    $deployment_user,
    $deployment_user_password
)

$script:ErrorActionPreference = 'Stop'
$count = 0

for ($count = 0; $count -lt 3; $count++) {
    try {
        $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
        $domainShort = $domain_fqdn.Split(".")[0]
        $cred = New-Object System.Management.Automation.PSCredential -ArgumentList "$domainShort\$user_name", $secpasswd
        
        if ($auth_type -eq "CredSSP") {
            try {
                Enable-WSManCredSSP -Role Client -DelegateComputer $ip -Force
            }
            catch {
                echo "Enable-WSManCredSSP failed"
            }
        }
        
        $session = New-PSSession -ComputerName $ip -Port $port -Authentication $auth_type -Credential $cred
        if ($ifdeleteadou) {
            Invoke-Command -Session $session -ScriptBlock {
                $OUPrefixList = @("OU=Computers,", "OU=Users,", "")
                foreach ($prefix in $OUPrefixList) {
                    $ouname = "$prefix$Using:adou_path"
                    echo "try to get OU: $ouname"
                    Try {
                        $ou = Get-ADOrganizationalUnit -Identity $ouname
                    }
                    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
                        $ou = $null
                    }
                    if ($ou) {
                        Set-ADOrganizationalUnit -Identity $ouname -ProtectedFromAccidentalDeletion $false
                        $ou | Remove-ADOrganizationalUnit -Recursive -Confirm:$False 
                        echo "Deleted adou: $ouname"
                    }
                }
            }
            
        }
        $deploymentSecPasswd = ConvertTo-SecureString $deployment_user_password -AsPlainText -Force
        $lcmCred = New-Object System.Management.Automation.PSCredential -ArgumentList $deployment_user, $deploymentSecPasswd
        Invoke-Command -Session $session -ScriptBlock {
            echo "Install Nuget Provider"
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
            echo "Install AsHciADArtifactsPreCreationTool"
            Install-Module AsHciADArtifactsPreCreationTool -Repository PSGallery -Force -Confirm:$false
            echo "Add KdsRootKey"
            Add-KdsRootKey -EffectiveTime ((Get-Date).addhours(-10))
            echo "New HciAdObjectsPreCreation"
            New-HciAdObjectsPreCreation -AzureStackLCMUserCredential $Using:lcmCred -AsHciOUName $Using:adou_path
        }
        break
    }
    catch {
        echo "Error in retry ${count}:`n$_"
    }
    finally {
        if ($session) {
            Remove-PSSession -Session $session
        }
    }
}

if ($count -ge 3) {
    throw "Failed to provision AD after 3 retries."
}
