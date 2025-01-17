import-module au

function global:au_GetLatest {
   $DownloadURI = 'https://github.com/rcaelers/workrave/releases/latest'
   [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
   $download_page = Invoke-WebRequest -Uri $DownloadURI -UseBasicParsing

   $urlstub = $download_page.rawcontent.split("<>") | 
                Where-Object {$_ -match '\.exe"'} | Select-Object -First 1

   $url = $urlstub -replace '.*?"([^ ]+\.exe).*','$1'

   $version = $url.replace('_','.').split('/') | 
                  Where-Object {$_ -match '^v[0-9.]+$'} |
                  Select-Object -Last 1
   $version = $version.trim('v')
   
   return @{ 
            Version = $version
            URL32   = "https://github.com$url"
   }
}


function global:au_SearchReplace {
   @{
      "tools\VERIFICATION.txt" = @{
            "(^Version\s+:).*"      = "`${1} $($Latest.Version)"
            "(^URL\s+:).*"          = "`${1} $($Latest.URL32)"
            "(^SHA256\s+:).*"     = "`${1} $($Latest.Checksum32)"
      }
   }
}

function global:au_BeforeUpdate() { 
   Write-host "Downloading Workrave v$($Latest.Version) installer"
   Get-RemoteFiles -Purge -NoSuffix
}


update -ChecksumFor none -nocheckchocoversion
