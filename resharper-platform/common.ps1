$urls = @{
    "Release" = @{
        Version = "https://download-cf.jetbrains.com/resharper/resharper-version.json"
        Updates = "https://download-cf.jetbrains.com/resharper/resharper-updates.json"
        Hash = "https://download.jetbrains.com/resharper/dotUltimate.VERSIONMARKETINGSTRING/JetBrains.dotUltimate.VERSIONMARKETINGSTRING.exe.sha256"

        # https://download.jetbrains.com/resharper/dotUltimate.2018.2/JetBrains.dotUltimate.2018.2.exe.sha256
        # https://download.jetbrains.com/resharper/dotUltimate.2018.2/JetBrains.dotUltimate.2018.2.exe
        # https://download-cf.jetbrains.com/resharper/dotUltimate.2018.2/JetBrains.dotUltimate.2018.2.exe

        Url = "https://download.jetbrains.com/resharper/dotUltimate.VERSIONMARKETINGSTRING/JetBrains.dotUltimate.VERSIONMARKETINGSTRING.exe"
    }
    "Release-EAP" = @{
        Version = "https://download.jetbrains.com/resharper/resharper-version-eap.json"
        Updates = "https://download.jetbrains.com/resharper/resharper-updates-eap.json"

        # https://download.jetbrains.com/resharper/dotUltimate.2020.2.EAP7/JetBrains.dotUltimate.2020.2.EAP7.Checked.exe.sha256
        # https://download.jetbrains.com/resharper/dotUltimate.2020.2.EAP7/JetBrains.dotUltimate.2020.2.EAP7.Checked.exe
        Hash = "https://download.jetbrains.com/resharper/dotUltimate.VERSIONMARKETINGSTRING/JetBrains.dotUltimate.VERSIONMARKETINGSTRING.Checked.exe.sha256"
        Url = "https://download.jetbrains.com/resharper/dotUltimate.VERSIONMARKETINGSTRING/JetBrains.dotUltimate.VERSIONMARKETINGSTRING.Checked.exe"
    }
}

function GetJetbrainsReSharperPlatformLatestRelease($release) {
    # Prefer version from here, rather than from PackageMetadata.Version
    # 222.0.20220727.110528-eap11
    $version = (Invoke-RestMethod -Uri ($urls[$release].Version)) -replace "eap(\d)$", '-eap0$1' # "https://download-cf.jetbrains.com/resharper/resharper-version.json"
    $updates = Invoke-RestMethod -Uri ($urls[$release].Updates) #"https://download-cf.jetbrains.com/resharper/resharper-updates.json"

    $package = $updates.AllPackages.InstallablePackage | Where-Object { $_.PackageMetadata.Id -eq "JetBrains.ReSharper.src" }
    $productInfo =  $package.ProductInfo | ConvertFrom-Json

    # "2022.2 EAP 11"
    $versionMarketingString = $productInfo.VersionMarketingString

    # "2022.2-EAP11"
    $versionMarketingStringSemVer = ($versionMarketingString -replace " EAP ", "-EAP") -replace "EAP(\d)$", 'EAP0$1'

    # "2022.2.EAP11"
    $versionMarketingStringDotted = $versionMarketingString -replace " EAP ", ".EAP"

    #$filename = "JetBrains.dotUltimate.$($versionMarketingStringUpdated).exe"
    $url = $urls[$release].Hash -replace "VERSIONMARKETINGSTRING", $versionMarketingStringDotted
    $data = Invoke-RestMethod -Uri $url
    ($hashcode, $filename) = $data -split "\s\*" #.Split(([string[]] ," *"), [System.StringSplitOptions]::RemoveEmptyEntries)

    $url = $urls[$release].Url -replace "VERSIONMARKETINGSTRING", $versionMarketingStringDotted

    $Latest = @{
        Filename = $filename.Trim()
        Checksum32 = $hashcode
        Version = $version

        # Used in title
        MarketingVersion = $versionMarketingStringSemVer

        # Used in URL
        VersionMarketingStringDotted = $versionMarketingStringDotted
        Url32 = $url
    }
    return $Latest
}

function GetJetbrainsReSharperPlatformLatest {
    $Latest = @{
        Streams = [ordered] @{
            "Release" = (GetJetbrainsReSharperPlatformLatestRelease "Release")

            "Release-Eap" = (GetJetbrainsReSharperPlatformLatestRelease "Release-EAP")
        }
    }

    return $Latest
}

function GetJetbrainsProductLatest {
    $latest = GetJetbrainsReSharperPlatformLatest

    $streams = $latest.Streams
    foreach ($key in $streams.Keys) {
        $streams[$key].PlatformVersion = $streams[$key].Version
        $streams[$key].Version = $streams[$key].MarketingVersion
    }

    return $latest
}
