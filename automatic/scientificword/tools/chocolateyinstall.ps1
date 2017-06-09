﻿$ErrorActionPreference = 'Stop'

$packageName = 'ScientificWord'
$url         = 'https://s3-us-west-1.amazonaws.com/download.mackichan.com/sw-6.0.26-windows-installer.exe'
$Checksum    = '4b29020ad0e4a6b95108b25728bde167f39a519b4ed441bc4e3f85ba149854bd'

$packageArgs = @{
  packageName   = $packageName
  fileType      = 'EXE'
  url           = $url
  softwareName  = 'Scientific Word*'
  checksum      = $Checksum
  checksumType  = 'sha256'
  silentArgs    = '--mode unattended --unattendedmodeui none'
  validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs

$UserArguments = @{}
# Parse the packageParameters using good old regular expression
if ($env:chocolateyPackageParameters) {
   $match_pattern = "\/(?<option>([a-zA-Z]+)):(?<value>([`"'])?([a-zA-Z0-9- _\\:\.@]+)([`"'])?)|\/(?<option>([a-zA-Z]+))"
   $option_name = 'option'
   $value_name = 'value'

   if ($env:chocolateyPackageParameters -match $match_pattern ){
      $results = $env:chocolateyPackageParameters | Select-String $match_pattern -AllMatches
      $results.matches | % {
      $UserArguments.Add(
         $_.Groups[$option_name].Value.Trim(),
         $_.Groups[$value_name].Value.Trim())
      }
   } else {
      Throw 'Package Parameters were found but were invalid (REGEX Failure).'
   }
} else {
   Write-Debug 'No Package Parameters Passed in.  Collecting 30-day Serial Number.'
   $WebClient = New-Object System.Net.Webclient
   $DownloadURL  = 'https://www.mackichan.com/products/dnloadreq.html'
   $DownloadPage = $webclient.DownloadString($DownloadURL)
   $SN = $DownloadPage -replace '(?smi).*title=.Scientific Word.*?(\d\d\d-E[0-9-]+).*','$1'
   $Desktop = [System.Environment]::GetFolderPath('Desktop')
   $SN | Out-File (Join-Path $Desktop 'Scientific Word Trial Serial Number.txt') -Force
}

if ($UserArguments.ContainsKey('LicenseFile')) {
   Write-Host "You requested copying a license file from '$($UserArguments.LicenseFile)'."
   if (test-path $UserArguments.LicenseFile) {
      $Shortcut = gci (Join-Path $env:ALLUSERSPROFILE 'microsoft\windows\start menu\programs\Scientific Word') -Filter 'sw*.lnk' -Recurse
      $sh = New-Object -ComObject WScript.Shell
      $Destination = Split-Path $sh.CreateShortcut($Shortcut.FullName).TargetPath
      Copy-Item $UserArguments.LicenseFile $Destination -Force
   } else {
      Write-Warning "LicenseFile '$($UserArguments.LicenseFile)' not found!"
   }
}

if ($UserArguments.ContainsKey('SystemVariable')) {
   Write-Host "You requested the 'mackichn_LICENSE' environment variable be set to '$($UserArguments.SystemVariable)'."
   Write-Warning 'No check on the accuracy or existance of the information will be made.'

   $EnVarArgs = @{
      VariableName  = 'mackichn_LICENSE'
      VariableValue = $UserArguments.SystemVariable
      VariableType  = 'Machine'
   }
   Install-ChocolateyEnvironmentVariable @EnVarArgs
}
