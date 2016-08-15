$packageName = 'jmol'
$MajorVersion = '14.6'
$MinorVersion = '14.6.1'
$SubVersion = '2016.08.11'

$installArgs = @{
   packageName = $packageName
   url = "https://sourceforge.net/projects/jmol/files/Jmol/Version%20$majorVersion/Version%20$MinorVersion/Jmol-$($MinorVersion)_$SubVersion-binary.zip/download"
   Checksum = '51683330ae480115f8c17a07166c2264645a6fa1'
   ChecksumType = 'sha1'
   UnzipLocation = $(Split-Path -parent $MyInvocation.MyCommand.Path)
}

Install-ChocolateyZipPackage @installArgs

$JavaExe = 'C:\ProgramData\Oracle\Java\javapath\javaw.exe'
$target = (Get-ChildItem $installArgs.UnzipLocation -filter jmol.jar -Recurse).fullname
$icon = Join-Path $installArgs.UnzipLocation "Jmol_icon13.ico"
$launcher = Join-Path $installArgs.UnzipLocation 'Jmol Launcher.exe'
$SGpath = Join-Path $env:ChocolateyInstall 'tools\shimgen.exe'

& $SGpath -o $launcher -p $JavaExe -c "-jar '$target'" -i $icon --gui

$shortcut = Join-Path ([Environment]::GetFolderPath("Desktop")) 'Jmol.lnk'

Install-ChocolateyShortcut -ShortcutFilePath $shortcut -TargetPath $launcher -IconLocation $icon
