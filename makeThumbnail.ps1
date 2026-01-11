#Requires -Version 2

<#  
.SYNOPSIS  
    Generates a titled, 0-pad numbered, youtube thumbnail with ImageMagick.

.DESCRIPTION
    When given a background image (dialog for selection if none is provided on the command line), 
    this script will generate a titled, numbered, youtube thumbnail. Use get-help -detailed for more info.

.EXAMPLE
    Example.ps1
    .\makeThumbnail -episodeNumber 1

.NOTES  
    Author      : Dad Tries To
    Version     : 1.0.0
    Requires    : ImageMagick
    License     : MPL 2.0 (See Repo)

.PARAMETER outPath
    The location to save your finalized thumbnail.
.PARAMETER seriesName
    Required. The name of your series. Used in thumbail file name and suggested upload title.
.PARAMETER episodeNumber
    Required. The number of the episode to display on the thumbnail
.PARAMETER episodeNumberGravity
    Default: SouthEast. Tells ImageMagick where to place the episode number. Uses no-space compass bearings (NorthEast, SouthWest, etc).
.PARAMETER episodeBackground
    Default: none. Defines fill color for the episode temp image.
.PARAMETER episodeZeroPad
    Default: 2. Will zero-pad your episode number to n places. For n=2, "1" becomes "01"
.PARAMETER background
    Default: Series path, replacing spaces with underscores, appending _bg.png. Ex., mechwarrior_5_mercenaries_bg.png. The background image for your thumbnail. If none is provided, a dialog will open to allow you to select one.
.PARAMETER overlay
    Default: Series path, replacing spaces with underscores, appending _overlay.png. Ex., mechwarrior_5_mercenaries_overlay.png. An overlay for your thumbnail, typically a game logo. If none is provided, a dialog will open to allow you to select one.
.PARAMETER overlayGravity
    Default: center. The default position of the overlay
.PARAMETER overlayGeometry
    Deafult: none. Can be use to resize and offset the overlay from overlayGravity. Ex., -geometry 363x125-340-35 sizes the image to 363x125 and offsets it -340 in the x and -35 in the y
.PARAMETER title
    Default: DAD TRIES TO. Sets the title to display in the thumbnail.
.PARAMETER titleGravity
    Default: NorthWest. Tells ImageMagick where to place the title. Uses no-space compass bearings (NorthEast, SouthWest, etc).
.PARAMETER titleBackgound
    Default: none. Defines fill color for the title temp image.
.PARAMETER fontName
    Default: Bebas Neue Regular. The font ImageMagick will use for title and episode. Can be an installed ttf font or you can pass the full path to the ttf file. `magick convert -list font` to list installed fonts on your system known by imagemagick.
.PARAMETER fontSize
    Default: 108pt. The font size ImageMagick will use for title and episode.
.PARAMETER fontColor
    Default: white. The font color ImageMagick will use for title and episode.
.PARAMETER fontStrokeColor
    Default: black. The font color ImageMagick will use to outline title and episode text.
.PARAMETER fontStrokeWidth
    Default: 1. The width of the outline ImageMagick will apply to title and episode.
.PARAMETER kerning
	Default: 0. Inter-character spacing. Negative values move characters closer to one another.
.PARAMETER interWordSpacing
	Default: 0. Inter-word spacing. Negative values move words closer to one another.
.PARAMETER interLineSpacing
	Default: 0. Inter-line spacing. Negative values move lines closer to one another.
#> 

[CmdletBinding(DefaultParametersetName = "Default")]
Param(
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$outPath = "H:\\thumbnails\\",
    [Parameter(Mandatory = $true, ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$seriesName,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$episodeBackground = "none",

    # default episode numbering scheme
    [Parameter(ParameterSetName = "Default")]
    [string]$episodeNumber,
    [Parameter(ParameterSetName = "Default")]
    [string]$episodeNumberGravity = "NorthEast",
    [Parameter(ParameterSetName = "Default")]
    [string]$episodeOffset = "+25+10",
    [Parameter(ParameterSetName = "Default")]
    [Int]$episodeZeroPad = 2,

    # override episode numbering and have specified text
    [Parameter(Mandatory = $true, ParameterSetName = "Override")]
    [string]$episodeText,

    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$background,

    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$overlay,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$overlayGravity = "center",
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$overlayGeometry = "+0+0",

    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$title = "DAD TRIES TO",
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$titleGravity = "NorthWest",
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$titleOffset = "+25+10",
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$titleBackgound = "none",
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$fontName,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [Int]$fontSize,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$fontColor = "white",
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$fontStrokeColor = "black",
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [Int]$fontStrokeWidth = 1,
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
    [string]$configFile = '.\makeThumbnail.json',
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [Boolean]$skipWrite = $false,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [switch]$openViewer = $false
);
$global:needsUpdate = $false

Import-Module (Resolve-Path('makeThumbnailFunctions.psm1')) -Force

#read config
$config = Read-ConfigFile -configFile $configFile
$seriesPath = $seriesName.toLower()
if (!$($config.($seriesPath))) {
    Add-Series -config $config -seriesName $seriesPath
    Save-ConfigFile -config $config -configFile $configFile
}

Get-ConfigValue -config $config -series $seriesName -key "Description" | Out-Null
if (!$background) {
    $background = '..\..\..\' + $seriesPath + '\' + $seriesPath.replace(' ', '_') + '_bg.png'
}
if (!$episodeNumber) {
    $episodeNumber = [Int]($config.$seriesName.episodeNumber) + 1
}

if (!$fontName) {
    if ($config.$($seriesName).fontName) {
        $fontName = $config.$($seriesName).fontName
    }
    else {
        $fontName = "Bebas-Neue-Regular"
    }
}


if (!$fontSize) {
    if ($config.$($seriesName).fontSize) {
        $fontSize = $config.$($seriesName).fontSize
    }
    else {
        $fontSize = 200
    }
}

if (!$interWordSpacing) {
    if ($config.$($seriesName).interWordSpacing) {
        $interWordSpacing = $config.$($seriesName).interWordSpacing
    }
    else {
        $interWordSpacing = 0
    }
}

if (!$interLineSpacing) {
    if ($config.$($seriesName).interLineSpacing) {
        $interLineSpacing = $config.$($seriesName).interLineSpacing
    }
    else {
        $interLineSpacing = 0
    }
}

if (!$kerning) {
    if ($config.$($seriesName).kerning) {
        $kerning = $config.$($seriesName).kerning
    }
    else {
        $kerning = 0
    }
}

if (!$episodeOffset) {
    if ($config.$($seriesName).episodeOffset) {
        $episodeOffset = $config.$($seriesName).episodeOffset
    }
    else {
        $episodeOffset = "+25+10"
    }
}

if (!$titleOffset) {
    if ($config.$($seriesName).titleOffset) {
        $titleOffset = $config.$($seriesName).titleOffset
    }
    else {
        $titleOffset = "+25+10"
    }
}

#create new stuff
Get-Background -background $background | Out-Null
[string]$thumbnailPath = $null
if ($episodeText -eq "") {
    $thumbnailPath = New-Thumbnail -number $episodeNumber -zeroPad $episodeZeroPad `
        -font $fontName -point $fontSize -color $fontColor -strokeColor $fontStrokeColor -strokeWidth $fontStrokeWidth -kerning $kerning -interwordSpacing $interWordSpacing -interlineSpacing $interLineSpacing `
        -episodeGravity $episodeNumberGravity -episodeOffset $episodeOffset -titleGravity $titleGravity -titleOffset $titleOffset -title $title `
        -outPath $outPath -seriesName $seriesName -background $background `
        -overlay $overlay -overlaygeometry $overlayGeometry -overlaygravity $overlayGravity
}
else {
    $thumbnailPath = New-Thumbnail -episodeText $episodeText -episodeGravity $episodeNumberGravity `
        -font $fontName -point $fontSize -color $fontColor -strokeColor $fontStrokeColor -strokeWidth $fontStrokeWidth  -kerning $kerning -interwordSpacing $interWordSpacing -interlineSpacing $interLineSpacing `
        -titleGravity $titleGravity -title $title `
        -outPath $outPath -seriesName $seriesName -background $background `
        -overlay $overlay -overlaygeometry $overlayGeometry -overlaygravity $overlayGravity
}

#update config
Update-SeriesConfig -config $config -series $seriesName -episodeNumber $episodeNumber -background $background `
    -fontName $fontName -interwordSpacing $interWordSpacing -interlineSpacing $interLineSpacing -kerning $kerning -fontSize $fontSize

if ($global:needsUpdate) {
    if (!$skipWrite) {
        Save-ConfigFile -config $config -configFile $configFile
    }
}

if ($openViewer) {
    [string]$trimmedOutput = $thumbnailPath.ToString().Trim()
    write-host "Opening thumbnail [$trimmedOutput] in default viewer..."
    if (Test-Path $trimmedOutput) {
        Invoke-Item $trimmedOutput
    }
}