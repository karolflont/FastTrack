####################
##### EVENTLOG #####
####################

function Get-APSUEventLogErrors($ComputerName,[System.Management.Automation.PSCredential] $Credential, $After, $Before){
    ### Get Error events from servers' EventLog
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
    if ($After) {$EventLogAfter = Get-Date $After}
    if ($Before) {$EventLogBefore = Get-Date $Before}
    if ($After){
        if ($Before){
            $FullEventLogList = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-EventLog -LogName System -EntryType Error -After $using:EventLogAfter -Before $using:EventLogBefore}
        }
        else {
            $FullEventLogList = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-EventLog -LogName System -EntryType Error -After $using:EventLogAfter}
        }
    }
    elseif ($Before){
        $FullEventLogList = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-EventLog -LogName System -EntryType Error -Before $using:EventLogBefore}
    }
    else {
       $FullEventLogList = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-EventLog -LogName System -EntryType Error} 
    }
    
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Number of Error type EventLog entries "

    for ($i=0; $i -lt $ComputerName.Count; $i++){
        $ServerEventLogList = $FullEventLogList | Where-Object PSComputerName -eq $ComputerName[$i]
        $message = "`n Summary of Error type EventLog entries for " + $ComputerName[$i]
        Write-Host -BackgroundColor White -ForegroundColor DarkBlue $message
        $ServerEventLogListSummary = $ServerEventLogList | Group-Object Source | Sort-Object Count -Descending | Select-Object Name, Count
        $EventLogSummaryList = @()
   
        for ($j=0; $j -lt $ServerEventLogListSummary.Count; $j++){
            $FirstEvent = ($ServerEventLogList | Where-Object Source -eq $ServerEventLogListSummary.Name[$j] | Sort-Object TimeGenerated)[0]
            $LastEvent = ($ServerEventLogList | Where-Object Source -eq $ServerEventLogListSummary.Name[$j] | Sort-Object TimeGenerated -Descending)[0]
            $OccurenceCount = ($ServerEventLogListSummary | Select-object Count)[$j]

            $EventLogSummary = New-Object -TypeName PSObject
            $EventLogSummary| Add-Member -MemberType NoteProperty -Name Count -Value $OccurenceCount.Count
            $EventLogSummary| Add-Member -MemberType NoteProperty -Name FirstOccurrenceTime -Value $FirstEvent.TimeGenerated
            $EventLogSummary| Add-Member -MemberType NoteProperty -Name LastOccurrenceTime -Value $LastEvent.TimeGenerated
            $EventLogSummary| Add-Member -MemberType NoteProperty -Name PSComputerName -Value $LastEvent.PSComputerName
            $EventLogSummary| Add-Member -MemberType NoteProperty -Name EntryType -Value $LastEvent.EntryType
            $EventLogSummary| Add-Member -MemberType NoteProperty -Name Source -Value $LastEvent.Source
            $EventLogSummary| Add-Member -MemberType NoteProperty -Name EventID -Value $LastEvent.EventID
            $EventLogSummary| Add-Member -MemberType NoteProperty -Name Message -Value $LastEvent.Message

            $EventLogSummaryList += $EventLogSummary
        }
        
        Write-Output $EventLogSummaryList | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
    }
}
