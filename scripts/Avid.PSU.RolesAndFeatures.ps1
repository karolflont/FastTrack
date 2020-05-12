function Install-AvFailoverClusteringFeature {
<#
.SYNOPSIS
   TODO
.DESCRIPTION
   TODO
.PARAMETER ComputerIP
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   TODO
#>
param(
    [Parameter(Mandatory = $true)] $ComputerIP,
    [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
)

$ClusterFeature = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools}
$ClusterFeature | Select-Object PSComputerName, ConsentPromptBehaviorAdmin | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}