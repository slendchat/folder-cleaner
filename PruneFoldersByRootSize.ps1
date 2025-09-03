# Script as advanced function
# Mandatory parameters
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory)][string] $Root,
    [Parameter(Mandatory)][int64] $MaxSize
)

function Get-dirSizeBytes {
    param (
        [Parameter(Mandatory)][string]$Path
    )

    $DirSize = (Get-ChildItem -LiteralPath $Path -File -Recurse -ErrorAction Stop | Measure-Object -Sum Length).Sum
    if(-not $DirSize){
        throw "[ERROR] Failed to calculate Root dir size"
    }
    [int64]$DirSize
}

if(-not(Test-Path -LiteralPath $Root)){
    throw "[ERROR] Path is not valid"
}


$RootDirTotalSize = Get-dirSizeBytes -Path $Root
Write-Debug "[DEBUG] Root dir size - $($RootDirTotalSize)"

if ($RootDirTotalSize -lt $MaxSize) {
    Write-Host "[INFO] The root folder smaller the given size" 
    return
}

$SubDirs = Get-ChildItem -LiteralPath $Root -Directory -Force -ErrorAction Stop | Sort-Object LastWriteTimeUtc

foreach ($SubDir in $SubDirs) {
    $SubDirSize = Get-dirSizeBytes -Path $SubDir.FullName
    Write-Debug "[DEBUG] SubDir size - $($SubDirSize)"

    if($PSCmdlet.ShouldProcess($SubDir.FullName,"DELETE")){
        try {
            Remove-Item -LiteralPath $SubDir.FullName -Recurse -Force -ErrorAction Stop
            $RootDirTotalSize -= $SubDirSize   
            Write-Debug "[DEBUG] Folder $($SubDir.FullName) was DELETED"
        }
        catch {
            Write-Warning "[WARNING] Failed to delete folder \n $($_.Exception.Message)"
        }
    } else {
        Write-Debug "[DEBUG] Folder $($SubDir.FullName) could be DELETED"
        $RootDirTotalSize -= $SubDirSize
    }

    Write-Debug "[DEBUG] Root dir size after deleting - $($RootDirTotalSize)"

    if ($RootDirTotalSize -lt $MaxSize) {
        break
    }
}

Write-Host "[INFO] Done"
