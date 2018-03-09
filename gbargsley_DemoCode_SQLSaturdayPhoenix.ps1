# Don't run everything, thanks @alexandair!
clear
break









# Load dbatools module
# Update-Module dbatools -force
Import-Module dbatools -force
Import-Module C:\GitHub\dbatools\dbatools.psd1 -Force








# Quick overview of commands
Start-Process https://dbatools.io/commands









# Set connection variables
$SQLServers = "localhost\dev2016", "localhost\prd2016", "localhost\dev2017", "localhost\prd2017"
$singleServer = "localhost\dev2016"
$devServers = "localhost\dev2016", "localhost\dev2017"
$prdServers = "localhost\prd2016", "localhost\prd2017"
$CmsInstance = 'localhost\sql2017'
$ComputerName = 'DESKTOP-EBH9MR8'
$dev2016 = "localhost\dev2016"
$prd2016 = "localhost\prd2016"




# Get connections from Registered Servers (CMS) 
$RegisteredServers = Get-DbaRegisteredServer -SqlInstance $CmsInstance
$RegisteredServers | Select-Object ServerName








# Max Memory Setting
Get-DbaMaxMemory -SqlInstance $devServers
Test-DbaMaxMemory -SqlInstance $SQLServers | Format-Table -AutoSize
Set-DbaMaxMemory -SqlInstance $SQLServers -MaxMB 1024
Test-DbaMaxMemory -SqlInstance $SQLServers | Format-Table -AutoSize





# sp_configure settings
Get-DbaSpConfigure -SqlInstance $singleServer | Out-GridView
$sourceConfig = Get-DbaSpConfigure -SqlInstance $dev2016 
$destConfig = Get-DbaSpConfigure -SqlInstance $prd2016 

Compare-Object -ReferenceObject $sourceConfig -DifferenceObject $destConfig -Property DisplayName, RunningValue -PassThru | Sort-Object DisplayName | Select-Object DisplayName, RunningValue, ServerName







# TempDB Configuration
Test-DbaTempDbConfiguration -SqlInstance $dev2016 | Select-Object SqlInstance, Rule, Recommended, CurrentSetting, IsBestPractice | Format-Table -AutoSize








# Startup Parameters
Get-DbaStartupParameter -SqlInstance $dev2016
Set-DbaStartupParameter -SqlInstance $dev2016 -TraceFlags 3226 -Confirm:$false








# DBA Orphan Files
$SQLServers | Find-DbaOrphanedFile








# You can use the same JSON the website uses to check the status of your own environment
$SQLServers | Get-DbaSqlBuildReference | Format-Table -AutoSize
$SQLServers | Test-DbaSqlBuild -MaxBehind 2CU | Format-Table -AutoSize


Start-Process https://sqlcollaborative.github.io/builds




# SQL Agent Jobs
Get-DbaAgentJob -SqlInstance $dev2016
Get-DbaAgentJob -SqlInstance $dev2016 | Export-DbaScript -Path C:\temp\jobs.sql
Start-Process C:\Temp\jobs.sql








# Support Tools
Install-DbaMaintenanceSolution -SqlInstance $SQLServers -Database DBA -CleanupTime 72 -BackupLocation C:\Temp -InstallJobs -ReplaceExisting 

Install-DbaWhoIsActive -SqlInstance $SQLServers -Database DBA
Invoke-DbaWhoIsActive -SqlInstance $prd2016 -ShowOwnSpid -ShowSystemSpids

Install-DbaFirstResponderKit -SqlInstance $SQLServers -Database DBA




# Check out our logs directory, so Enterprise :D
Invoke-Item (Get-DbaConfig -FullName path.dbatoolslogpath).Value

# Want to see what's in our logs?
Get-DbatoolsLog | Out-GridView

# Need to send us diagnostic information? Use this support package generator
New-DbatoolsSupportPackage