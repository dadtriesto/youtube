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
    #ConvertTo-Json @($config) -depth 32 | Out-File $configFile
}

Function Get-Background() {
    Param($background)
    if (!$background) {
        write-host "Please select a background"
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        $null = $FileBrowser.ShowDialog() # -still- not topmost from vs code terminal...
        if (!$FileBrowser.FileName) {
            exit 0
        }
        
        $background = $FileBrowser.FileName
    }

    write-output $background
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

    write-host "Thumbnail creation command executed successfully."
    [string]$trimmedOutput = $output.ToString().Trim()
    Write-Output $trimmedOutput
}

Function Get-ConfigValue() {
    Param($config, $series, $key)

    $config.$($series).$($key)
}

# From https://stackoverflow.com/a/55384556, which comes from https://github.com/PowerShell/PowerShell/issues/2736
# Formats JSON in a nicer format than the built-in ConvertTo-Json does.
function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
    $indent = 0;
    ($json -Split "`n" | % {
        if ($_ -match '[\}\]]\s*,?\s*$') {
            # This line ends with ] or }, decrement the indentation level
            $indent--
        }
        $line = ('  ' * $indent) + $($_.TrimStart() -replace '":  (["{[])', '": $1' -replace ':  ', ': ')
        if ($_ -match '[\{\[]\s*$') {
            # This line ends with [ or {, increment the indentation level
            $indent++
        }
        $line
    }) -Join "`n"
}

function New-NewThumbnail {
    Param(
        [string]$outPath = "H:\\thumbnails\\",
        [string]$seriesName,
        [string]$episodeBackground = "none",
        [string]$episodeNumber,
        [string]$episodeNumberGravity = "NorthEast",
        [string]$episodeOffset = "+25+10",
        [Int]$episodeZeroPad = 2,
        [string]$episodeText,
        [string]$background,
        [string]$overlay,
        [string]$overlayGravity = "center",
        [string]$overlayGeometry = "+0+0",
        [string]$title = "DAD TRIES TO",
        [string]$titleGravity = "NorthWest",
        [string]$titleOffset = "+25+10",
        [string]$titleBackgound = "none",
        [string]$fontName,
        [Int]$fontSize,
        [string]$fontColor = "white",
        [string]$fontStrokeColor = "black",
        [Int]$fontStrokeWidth = 1,
        [Int]$kerning,
        [Int]$interWordSpacing,
        [Int]$interLineSpacing,
        [string]$configFile = '.\makeThumbnail-v1.json',
        [Boolean]$skipWrite = $false
    );

    $allConfig = Get-Content -raw $configFile | ConvertFrom-Json

    $existingConfig = $allConfig | Where-Object { $_.name -eq $seriesName }
    if ($existingConfig) {
        # Update existingConfig if parameters don't match
        $updatedConfigItemNames = @()
        if ($existingConfig.background -ne $background) {
            $updatedConfigItemNames += "background"
            $existingConfig.background = $background
        }
        if ($existingConfig.fontName -ne $fontName) {
            $updatedConfigItemNames += "fontName"
            $existingConfig.fontName = $fontName
        }
        if ($existingConfig.fontSize -ne $fontSize) {
            $updatedConfigItemNames += "fontSize"
            $existingConfig.fontSize = $fontSize
        }
        if ($existingConfig.interWordSpacing -ne $interWordSpacing) {
            $updatedConfigItemNames += "interWordSpacing"
            $existingConfig.interWordSpacing = $interWordSpacing
        }
        if ($existingConfig.interLineSpacing -ne $interLineSpacing) {
            $updatedConfigItemNames += "interLineSpacing"
            $existingConfig.interLineSpacing = $interLineSpacing
        }
        if ($existingConfig.kerning -ne $kerning) {
            $updatedConfigItemNames += "kerning"
            $existingConfig.kerning = $kerning
        }
        if ($existingConfig.overlay -ne $overlay) {
            $updatedConfigItemNames += "overlay"
            $existingConfig.overlay = $overlay
        }
        if ($existingConfig.overlayGravity -ne $overlayGravity) {
            $updatedConfigItemNames += "overlayGravity"
            $existingConfig.overlayGravity = $overlayGravity
        }
        if ($existingConfig.overlayGeometry -ne $overlayGeometry) {
            $updatedConfigItemNames += "overlayGeometry"
            $existingConfig.overlayGeometry = $overlayGeometry
        }
        if ($existingConfig.title -ne $title) {
            $updatedConfigItemNames += "title"
            $existingConfig.title = $title
        }
        if ($existingConfig.titleGravity -ne $titleGravity) {
            $updatedConfigItemNames += "titleGravity"
            $existingConfig.titleGravity = $titleGravity
        }
        if ($existingConfig.titleOffset -ne $titleOffset) {
            $updatedConfigItemNames += "titleOffset"
            $existingConfig.titleOffset = $titleOffset
        }
        if ($existingConfig.fontColor -ne $fontColor) {
            $updatedConfigItemNames += "fontColor"
            $existingConfig.fontColor = $fontColor
        }
        if ($existingConfig.fontStrokeColor -ne $fontStrokeColor) {
            $updatedConfigItemNames += "fontStrokeColor"
            $existingConfig.fontStrokeColor = $fontStrokeColor
        }
        if ($existingConfig.fontStrokeWidth -ne $fontStrokeWidth) {
            $updatedConfigItemNames += "fontStrokeWidth"
            $existingConfig.fontStrokeWidth = $fontStrokeWidth
        }
        if ($existingConfig.episodeNumber -ne $episodeNumber) {
            $updatedConfigItemNames += "episodeNumber"
            $existingConfig.episodeNumber = $episodeNumber
        }
        if ($existingConfig.episodeNumberGravity -ne $episodeNumberGravity) {
            $updatedConfigItemNames += "episodeNumberGravity"
            $existingConfig.episodeNumberGravity = $episodeNumberGravity
        }
        if ($existingConfig.episodeOffset -ne $episodeOffset) {
            $updatedConfigItemNames += "episodeOffset"
            $existingConfig.episodeOffset = $episodeOffset
        }
        if ($existingConfig.episodeZeroPad -ne $episodeZeroPad) {
            $updatedConfigItemNames += "episodeZeroPad"
            $existingConfig.episodeZeroPad = $episodeZeroPad
        }
        if ($existingConfig.episodeText -ne $episodeText) {
            $updatedConfigItemNames += "episodeText"
            $existingConfig.episodeText = $episodeText
        }
        if($updatedConfigItemNames.Count -eq 0) {
            Write-Host "No changes to series [$seriesName] config. Exiting."
            return
        }
        Write-Host "Updating series [$seriesName] params: " -Join $updatedConfigItemNames -Separator ","
    } else {
        Write-Host "Series [$seriesName] not found in config file [$configFile]. Creating new series."
        Add-Series -config $allConfig -seriesName $seriesName
    }
}