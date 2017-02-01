$ErrorActionPreference = 'Stop'  # stop on all errors

$PackageName = 'chrlauncher.portable'
$version     = '2.2'
$url         = 'https://github.com//henrypp/chrlauncher/releases/download/v.2.2/chrlauncher-2.2-bin.zip'
$checkSum    = '6bace2078bab9aaeac064836f1af399aa6e35ef8d1724e791cb3da3d2dda3aa1'

$PackageDir = Split-path (Split-path $MyInvocation.MyCommand.Definition)

$InstallArgs = @{
   PackageName   = $PackageName
   Url           = $Url 
   UnzipLocation = (Join-path $PackageDir ($PackageName.split('.')[0] + $version))
   checkSum      = $checkSum
   checkSumType  = 'sha256'
}
Install-ChocolateyZipPackage @InstallArgs

$BitLevel = Get-ProcessorBits
$target   = Join-Path $InstallArgs.UnzipLocation "$BitLevel\chrlauncher.exe"
$shortcut = Join-Path ([System.Environment]::GetFolderPath('Desktop')) 'Chromium Launcher.lnk'

Install-ChocolateyShortcut -ShortcutFilePath $shortcut -TargetPath $target


# The following is only for when the "default" package parameter is used.
$UserArguments = @{}
if ($env:chocolateyPackageParameters) {
   $match_pattern = "\/(?<option>([a-zA-Z]+)):(?<value>([`"'])?([a-zA-Z0-9- _\\:\.]+)([`"'])?)|\/(?<option>([a-zA-Z]+))"
   $option_name = 'option'
   $value_name = 'value'

   if ($env:chocolateyPackageParameters -match $match_pattern ){
      $results = $env:chocolateyPackageParameters | Select-String $match_pattern -AllMatches
      $results.matches | ForEach-Object {$UserArguments.Add(
                           $_.Groups[$option_name].Value.Trim(),
                           $_.Groups[$value_name].Value.Trim())
                        }
   } else { Throw 'Package Parameters were found but were invalid (REGEX Failure)' }
} else { Write-Debug 'No Package Parameters Passed in' }

if ($UserArguments.ContainsKey('Default')) {
   Write-Host 'You want chrlauncher as your default browser.'
   $Bat = Join-Path $InstallArgs.unzipLocation "$BitLevel\SetDefaultBrowser.bat"
   $NoPauseBat = Join-Path (Split-Path $Bat) 'NoPauseSetDefaultBrowser.bat'
   (Get-Content $Bat) -ne 'pause' | Out-File $NoPauseBat -Encoding ascii -Force
   & $NoPauseBat
}
