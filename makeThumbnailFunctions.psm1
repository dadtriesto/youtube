Function Set-NeedsUpdate() {
    Param($update)
    $global:needsUpdate = $update
}

Function Add-Series() {
    Param($config, $seriesName)

    $newSeriesConfig = [pscustomobject]@{
        "episodeNumber" = $episodeNumber
        "background"    = $background
        "fontName"      = $fontName
        "fontSize"      = $fontSize
        "interWordSpacing" = $interWordSpacing
        "interLineSpacing" = $interLineSpacing
        "kerning"       = $kerning
        "title"         = $title
    }

    Add-Member -InputObject $config -Name $seriesName -Value $newSeriesConfig -MemberType NoteProperty
    Set-NeedsUpdate -update $true
}

Function Update-SeriesConfig() {
    Param($config, $series, $episodeNumber, $background, $fontName, $fontSize, $interWordSpacing, $interLineSpacing, $kerning)
    $seriesConfig = $config.$series
    if (!$seriesConfig) {
        #Add-Series -config $config -seriesName $series
        Write-Error "Series $series does not exist in makeThumbnail.json. Exiting..."
        Exit 1
    }

    $epn = $seriesConfig.episodeNumber
    $bkg = $seriesConfig.background
    $fn = $seriesConfig.fontName
    $fs = $seriesConfig.fontSize
    $iws = $seriesConfig.interWordSpacing
    $ils = $seriesConfig.interLineSpacing
    $krn = $seriesConfig.kerning

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
    if ($ils -ne $interLineSpacing) {
        Write-Output "Updating $series interLineSpacing config"
        $seriesConfig.interLineSpacing = $interLineSpacing
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
        [string]$episodeOffset,
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
        [Int]$interLineSpacing,
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
        [string]$titleOffset,
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
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [string]$overlay,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [string]$overlayGeometry,
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Override")]
        [string]$overlayGravity = "center",
        
        [Parameter(ParameterSetName = "Override")]
        [string]$episodeText
    )
    $episode
    $overlayCommand

    try {
        if ($episodeText -eq "") {
            $episode = ($number).PadLeft($zeroPad, '0')
        }
        else {
            $episode = $episodeText
        }

        $outFileName = "${seriesName}_thumbnail_${episode}.png"
        $output = join-path $outPath $outFileName.Replace(' ', '_')

        if($overlay -ne ""){
            $fontCommand = "-font '$font' -fill '$color' -pointsize '$point' -stroke '$strokeColor' -strokewidth '$strokeWidth' -kerning '$kerning' -interword-spacing '$interWordSpacing' -interline-spacing '$interLineSpacing'"
            #$strip = "magick convert '$background' -resize 1280x720 -size 1280x720 -fill 'rgba(0,0,0,0.5)' -draw 'rectangle 175,0 425,720' $output"
            $strip = "magick convert '$background' -resize 1280x720 -size 1280x720 $output"
            Invoke-Expression $strip
            $logo = "magick composite -geometry '$overlayGeometry' -gravity '$overlayGravity' '$overlay' '$output' $output"
            Invoke-Expression $logo
            $episode = "magick convert '$output' -gravity '$episodeGravity' $fontCommand -annotate $episodeOffset '$episode' '$output'"
            Invoke-Expression $episode
            $title = "magick convert '$output' -gravity '$titleGravity' $fontCommand -annotate $titleOffset '$title' '$output'"
            Invoke-Expression $title
        } else {
            magick convert $background -font $font -fill $color -pointsize $point `
            -stroke $strokeColor -strokewidth $strokeWidth -kerning $kerning `
            -interword-spacing $interWordSpacing -interline-spacing $interLineSpacing `
            -gravity $episodeGravity -annotate +25+10 $episode `
            -gravity $titleGravity -annotate +25+10 $title `
            $output
        }

    }
    catch {
        write-host "Error creating thumbnail"
        write-host $_
        exit 1;
    }

    write-output "Thumbnail [$output] created"
}

Function Get-ConfigValue() {
    Param($config, $series, $key)

    $config.$($series).$($key)
}