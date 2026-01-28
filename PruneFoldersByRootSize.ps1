# Script as advanced function
# Mandatory parameters
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory)][string] $Root,
    [Parameter(Mandatory)][int64] $MaxSize,
    [string] $LogDirMain = "$Root\LOG",
    [int] $RetentionPeriod = 90
)

function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level = "INFO",

        [string]$LogDir = $LogDirMain
    )

    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $DateStamp = Get-Date -Format "yyyy-MM-dd"
    $LogFile = $LogDir + "\PruneFoldersByRootSize_$DateStamp.log"
    $LogString = "$TimeStamp [$Level] $Message"

    if (!(Test-Path -PathType Container $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir | Out-Null
    }

    $LogString | Out-File -FilePath $LogFile -Append -Encoding utf8

    Write-Verbose $LogString
}

function Get-dirSizeBytes {
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [string]$Path
    )

    try {
        $DirSize = Get-ChildItem -LiteralPath $Path -File -Recurse -ErrorAction SilentlyContinue | Measure-Object -Sum Length
        if ($null -eq $DirSize.Sum) {
            return 0
        } else {
            return $DirSize.Sum
        }
    }
    catch {
        Write-Log -Message "Failed to calculate directory size: $Path. $($_.Exception.Message)" -Level "ERROR"
        throw
    }
}

function Invoke-Log-Retention {
    param (
        [string]$LogDir = $LogDirMain,
        [int]$RetentionPeriod = 90
    )
    if (-not(Test-Path $LogDir)){
        Write-Log -Message "Cannot find log dir to Invoke-Log-Retention" -Level "ERROR"
    }
    $Cutoff = (Get-Date).AddDays(-$RetentionPeriod)
    Get-ChildItem -Path $LogDir -Filter 'PruneFoldersByRootSize_*.log' -File |
    Where-Object {$_.LastWriteTime -lt $Cutoff} |
    Remove-Item -Force -ErrorAction SilentlyContinue
}

############################ SCRIPT STARTS ############################
Write-Log -Message "=== Script Start Executing ==="

Invoke-Log-Retention -RetentionPeriod 90 -LogDir $LogDirMain

if(-not(Test-Path -LiteralPath $Root)){
    Write-Log -Message "Path is not valid: $($Root)" -Level "ERROR"
    throw
}

$RootDirTotalSize = Get-dirSizeBytes -Path $Root
Write-Log -Message "Root dir [$($Root)] size - $([math]::Round(($RootDirTotalSize / 1MB),2)) MB" -Level "DEBUG"

if ($RootDirTotalSize -lt ($MaxSize * 1MB)) {
    Write-Log -Message "The Root dir [$($Root)] smaller the given size" -Level "INFO"
    Write-Log -Message "=== Exiting Script ==="
    return
}

$SubDirs = Get-ChildItem -LiteralPath $Root -Directory -Force -ErrorAction Stop | Sort-Object LastWriteTimeUtc

foreach ($SubDir in $SubDirs) {
    # Skip log dir
    if($SubDir.Name -eq 'LOG') { continue }
    $SubDirSize = Get-dirSizeBytes -Path $SubDir.FullName
    Write-Debug "[DEBUG] SubDir [$($SubDir.Name)] size - $([math]::Round(($SubDirSize / 1MB),2)) MB"

    if($PSCmdlet.ShouldProcess($SubDir.FullName,"DELETE")){
        try {
            Remove-Item -LiteralPath $SubDir.FullName -Recurse -Force -ErrorAction Stop
            $RootDirTotalSize -= $SubDirSize   
            Write-Log -Message "Folder $($SubDir.FullName) was DELETED" -Level "DEBUG"
        }
        catch {
            Write-Log -Message "Failed to delete folder [$($SubDir.Name)] \n $($_.Exception.Message)" -Level "WARN"
        }
    } else {
        Write-Log -Message "Folder $($SubDir.FullName) could be DELETED" -Level "DEBUG"
        $RootDirTotalSize -= $SubDirSize
    }
    
    if ($RootDirTotalSize -lt ($MaxSize * 1MB)) {
        Write-Log -Message "Root dir [$($Root)] size after deleting subfolders - $([math]::Round(($RootDirTotalSize / 1MB),2)) MB" -Level "DEBUG"
        break
    }
}


Write-Log -Message "=== Exiting Script ==="