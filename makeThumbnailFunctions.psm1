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
    if ($config.makeThumbnail.outPath -ne $outPath) {
        Write-Output "Updating outPath config"
        $config.makeThumbnail.outPath = $outPath
        Set-NeedsUpdate -update $true
    }
}

Function Add-Series(){
    Param($config, $seriesName)

    $newSeriesConfig = [pscustomobject]@{
        "description"= $description
        "episodeNumber"= $episodeNumber
        "background"= $background
    }

    Add-Member -InputObject $config -Name $seriesName -Value $newSeriesConfig -MemberType NoteProperty
    Set-NeedsUpdate -update $true
}

Function Update-SeriesConfig() {
    Param($config, $series, $episodeNumber, $description, $background)
    $seriesConfig = $config.$series
    if(!$seriesConfig){
        Add-Series -config $config -seriesName $series
    }

    $desc = $seriesConfig.description
    $epn = $seriesConfig.episodeNumber
    $bkg = $seriesConfig.background

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
    Param(
        [string]$number,
        [string]$zeroPad,
        [string]$font,
        [Int]$point,
        [string]$color,
        [string]$strokeColor,
        [Int]$strokeWidth,
        [string]$episodeGravity,
        [string]$titleGravity,
        [string]$title,
        [string]$outPath,
        [string]$seriesName,
        [string]$background
    )

    try {
        $paddedEpisode = ($number).PadLeft($zeroPad, '0')
        $outFileName = "${seriesName}_thumbnail_${paddedEpisode}.png"
        write-host $outFileName
        $output = join-path $outPath $outFileName.Replace(' ', '_')
        magick convert $background -font $font -fill $color -pointsize $point `
            -stroke $strokeColor -strokewidth $strokeWidth `
            -gravity $episodeGravity -annotate +25+10 $paddedEpisode `
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
    Param($number, $zeroPad, $title, $subTitle, $description, $contactBlock)
    $paddedEpisode = ($number).PadLeft($zeroPad, '0')
    $titleCasedTitle = (Get-Culture).TextInfo.ToTitleCase($title.ToLower())
    Write-Output `n"--"
    write-output "${titleCasedTitle}: $subTitle, $paddedEpisode"
    Write-Output "--"`n
    if ($description) {
        Get-Content $description | write-output 
    }
    if ($contactBlock) {
        Get-Content $contactBlock | write-output 
    }
    Write-Output `n`n
}

Function Get-ConfigValue(){
    Param($config, $series, $key)

    # write-host $config.$($series).$($key)
    return $config.$($series).$($key)
}