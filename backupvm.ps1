# export-vm "pag" -Path G:\Backup\vm -asjob

#
# https://ronbokleman.wordpress.com/2014/07/07/export-multiple-windows-server-2012-r2-hyper-v-guests-with-powershell-part-i/
#
# $RootPath: Can be changed to point where you’d like the Virtual Machines exported and can be any valid drive path.
#            
$RootPath   = 'D:\backup\vm\'
$vms        = "Pag","Krk","Rab"
$hrs        = -7
$OutputDate = Get-Date -format "yyyy-MM-dd HH.mm.ss"


function Export-It2
{
	param([string]$exportTo, [string]$vm)
        Log-It -msg "Exporting $vm to $exportTo"
	Export-VM -ComputerName $env:COMPUTERNAME -Name $vm -Path $exportTo
        Log-It -msg "Exported"
}


function Log-It
{
	param([string]$msg)
	$logDtm = Get-Date -format "yyyy-MM-dd HH:mm:ss"
        Write-Host "$logDtm $msg"
}


function Clean-ExportTo-Folder
{
	param([string]$exportTo, [string]$vm)
	
	#Clean up old Export-VM folders older than one month ago to reduce disk space consumption.
        Log-It -msg "Removing...."
	foreach ($i in Get-ChildItem $exportTo)
	{
	    if ($i.CreationTime -lt ($(Get-Date).AddHours($hrs)))
	        {
		    Log-It -msg "Removing $i.Name.ToString()"
	            Remove-Item $i.PSPath -Recurse
		    Log-It -msg "Removed"
	        }
	}
}


# ### main ###
Log-It -msg "Backing up virtual machines - start"
Clean-ExportTo-Folder -exportTo $RootPath
$ExportPath = New-Item ($RootPath + ' ' + $OutputDate) -type directory
Log-It -msg "Directory $ExportPath created"
foreach ($vm in $vms) {
	Export-It2 -exportTo $ExportPath -vm $vm
}
Log-It -msg "Backing up virtual machines - end"

