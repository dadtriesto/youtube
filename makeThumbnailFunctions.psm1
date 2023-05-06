Function Set-NeedsUpdate() {
    Param($update)
    $global:needsUpdate = $update
}

Function Update-GlobalConfig() {
    Param($config, $outPath, $contactBlock)

    # update contact block if different
    if ($config.makeThumbnail.contactBlock -ne $contactBlock) {
        Write-Output "Updating contactBlock config"
        $config.makeThumbnail.contactBlock = $contactBlock
        Set-NeedsUpdate -update $true
    }

    # update outpath if different
    if ($config.makeThumbnail.outPath -ne $outPath -and ("" -ne $outPath)) {
        Write-Output "Updating outPath config"
        $config.makeThumbnail.outPath = $outPath
        Set-NeedsUpdate -update $true
    }
}

Function Add-Series() {
    Param($config, $seriesName)

    $newSeriesConfig = [pscustomobject]@{
        "description"   = $description
        "episodeNumber" = $episodeNumber
        "background"    = $background
        "fontName"      = $fontName
        "fontSize"      = $fontSize
        "interWordSpacing" = $interWordSpacing
        "kerning"       = $kerning
        "title"         = $title
    }

    Add-Member -InputObject $config -Name $seriesName -Value $newSeriesConfig -MemberType NoteProperty
    Set-NeedsUpdate -update $true
}

Function Update-SeriesConfig() {
    Param($config, $series, $episodeNumber, $description, $background, $fontName, $fontSize, $interWordSpacing, $kerning)
    $seriesConfig = $config.$series
    if (!$seriesConfig) {
        Add-Series -config $config -seriesName $series
        # TODO: update seriesConfig w/ description, episodeNumber, and background
    }

    $desc = $seriesConfig.description
    $epn = $seriesConfig.episodeNumber
    $bkg = $seriesConfig.background
    $fn = $seriesConfig.fontName
    $fs = $seriesConfig.fontSize
    $iws = $seriesConfig.interWordSpacing
    $krn = $seriesConfig.kerning

    if ($desc -ne $description) {
        Write-Output "Updating $series description config"
        $seriesConfig.description = $description
        Set-NeedsUpdate -update $true
    }
    if ($epn -ne $episodeNumber) {
        Write-Output "Updating $series episode number config to $episodeNumber"
        $seriesConfig.episodeNumber = $episodeNumber
        Set-NeedsUpdate -update $true
    }
    if ($bkg -ne $background) {
        Write-Output "Updating $series background config"
        $seriesConfig.background = $background
        Set-NeedsUpdate -update $true
    }
    if ($fn -ne $fontName) {
        Write-Output "Updating $series fontName config"
        $seriesConfig.fontName = $fontName
        Set-NeedsUpdate -update $true
    }
    if ($fs -ne $fontSize) {
        Write-Output "Updating $series fontSize config"
        $seriesConfig.fontSize = $fontSize
        Set-NeedsUpdate -update $true
    }
    if ($iws -ne $interWordSpacing) {
        Write-Output "Updating $series interWordSpacing config"
        $seriesConfig.interWordSpacing = $interWordSpacing
        Set-NeedsUpdate -update $true
    }
    if ($krn -ne $kerning) {
        Write-Output "Updating $series kerning config"
        $seriesConfig.kerning = $kerning
        Set-NeedsUpdate -update $true
    }
}

Function Read-ConfigFile() {
    Param($configFile)
    Get-Content $configFile -raw | ConvertFrom-Json
}

Function Save-ConfigFile() {
    Param($config, $configFile)
    $config | ConvertTo-Json -depth 32 | Out-File $configFile
}

Function Get-Background() {
    Param($background)
    if (!$background) {
        write-output "Please select a background"
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        $null = $FileBrowser.ShowDialog() # -still- not topmost from vs code terminal...
        if (!$FileBrowser.FileName) {
            exit 0
        }
        
        $background = $FileBrowser.FileName
    }

    $background
}

Function New-Thumbnail() {
    [CmdletBinding(DefaultParametersetName = "Default")]
    Param(
        [Parameter(ParameterSetName = "Default")]
        [string]$number,
        [Parameter(ParameterSetName = "Default")]
        [string]$zeroPad,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [string]$episodeGravity,

        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [string]$font,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [Int]$point,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [Int]$kerning,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [Int]$interWordSpacing,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [string]$color,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [string]$strokeColor,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [Int]$strokeWidth,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [string]$titleGravity,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [string]$title,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [string]$outPath,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [string]$seriesName,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [string]$background,
        
        [Parameter(ParameterSetName = "Override")]
        [string]$episodeText
    )
    $episode

    try {
        if ($episodeText -eq "") {
            $episode = ($number).PadLeft($zeroPad, '0')
        }
        else {
            $episode = $episodeText
        }

        $outFileName = "${seriesName}_thumbnail_${episode}.png"
        $output = join-path $outPath $outFileName.Replace(' ', '_')

        magick convert $background -font $font -fill $color -pointsize $point `
            -stroke $strokeColor -strokewidth $strokeWidth -kerning $kerning `
            -interword-spacing $interWordSpacing -gravity $episodeGravity -annotate +25+10 $episode `
            -gravity $titleGravity -annotate +25+10 $title $output

    }
    catch {
        write-host "Error creating thumbnail"
        write-host $_
        exit 1;
    }

    write-output "Thumbnail [$output] created"
}

Function Write-TitleAndDescription() {
    [CmdletBinding(DefaultParametersetName = "Default")]
    Param(
        [Parameter(ParameterSetName = "Default")]
        [string]$number,
        [Parameter(ParameterSetName = "Default")]
        [string]$zeroPad,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        $title,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        $subTitle,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        $description,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        $contactBlock,

        [Parameter(ParameterSetName = "Override")]
        [string]$episodeText
    )

    if ($episodeText -eq "") {
        $paddedEpisode = ($number).PadLeft($zeroPad, '0')
        $titleCasedTitle = (Get-Culture).TextInfo.ToTitleCase($title.ToLower())
        Write-Output `n"--"
        write-output "${titleCasedTitle}: $subTitle, $paddedEpisode"
        Write-Output "--"`n
    }
    else {
        $titleCasedTitle = (Get-Culture).TextInfo.ToTitleCase($title.ToLower())
        Write-Output `n"--"
        write-output "${titleCasedTitle}: $subTitle, $episodeText"
        Write-Output "--"`n
    }

    if ($description) {
        Get-Content $description | write-output 
    }
    if ($contactBlock) {
        Get-Content $contactBlock | write-output 
    }
    Write-Output `n`n
}

Function Get-ConfigValue() {
    Param($config, $series, $key)

    $config.$($series).$($key)
}