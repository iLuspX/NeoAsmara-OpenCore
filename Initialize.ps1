#Requires -Version 5.1
[CmdletBinding()]
param([switch]$VerifyOnly,[string]$DatabasePackage)
$ErrorActionPreference='Stop'
$arguments=@('--root',$PSScriptRoot)
if($VerifyOnly){$arguments+='--verify'}
if($DatabasePackage){$arguments+=@('--database-package',[IO.Path]::GetFullPath($DatabasePackage))}
& (Join-Path $PSScriptRoot 'Bin/Initialize.exe') @arguments
if($LASTEXITCODE){throw ('Native initialization failed: '+$LASTEXITCODE)}
