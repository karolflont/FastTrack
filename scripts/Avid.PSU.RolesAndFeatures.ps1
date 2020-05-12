function Install-AvFailoverClusteringFeature {
<#
.SYNOPSIS
   TODO
.DESCRIPTION
   TODO
.PARAMETER ComputerName
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   TODO
#>
param(
    [Parameter(Mandatory = $true)] $ComputerName,
    [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
)

$ClusterFeature = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools}
$ClusterFeature | Select-Object PSComputerName, ConsentPromptBehaviorAdmin | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}