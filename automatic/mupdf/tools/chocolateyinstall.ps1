﻿$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Remove old versions
$null = Get-ChildItem $env:ChocolateyPackageFolder -Filter $env:ChocolateyPackageName* | 
            Where-Object { $_.PSIsContainer } | Remove-Item -Force -Recurse

$ZipFile = Get-ChildItem $toolsDir -filter "*.zip" |
               Sort-Object LastWriteTime | 
               Select-Object -ExpandProperty FullName -Last 1

Get-ChocolateyUnzip -FileFullPath $ZipFile -Destination $env:ChocolateyPackageFolder

Remove-Item -force $ZipFile -ea 0
