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
.PARAMETER title
    Default: DAD TRIES TO. Sets the title to display in the thumbnail.
.PARAMETER titleGravity
    Default: NorthWest. Tells ImageMagick where to place the title. Uses no-space compass bearings (NorthEast, SouthWest, etc).
.PARAMETER titleBackgound
    Default: none. Defines fill color for the title temp image.
.PARAMETER subTitle
    Used to add a subtitle for suggest YouTube titles. Output format is `$title: $subtitle, $episode`
.PARAMETER fontName
    Default: Bebas Neue Regular. The font ImageMagick will use for title and episode. Can be an installed ttf font or you can pass the full path to the ttf file.
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
.PARAMETER description
    Default: none. If provided, will echo contents of text file passed to it to make editing uploads a little faster. Future update: generate from input schema file.
.PARAMETER contactBlock
    Required. Default: none. If provided, will echo contents of text file passed to it to make editing uploads a little faster. Future update: generate from input schema file.
#> 

#TODO: need to read and use json values

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
    [Int]$episodeZeroPad = 2,

    # override episode numbering and have specified text
    [Parameter(Mandatory = $true, ParameterSetName = "Override")]
    [string]$episodeText,

    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$background,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$title = "DAD TRIES TO",
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$titleGravity = "NorthWest",
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$titleBackgound = "none",
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$subTitleAction = "Play",
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$subTitle = "${subTitleAction} $seriesName",
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
    [string]$description,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$contactBlock,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [string]$configFile = '.\makeThumbnail.json',
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Override")]
    [Boolean]$skipWrite = $false
);
$global:needsUpdate = $false

Import-Module (Resolve-Path('makeThumbnailFunctions.psm1')) -Force

$updateSeries = $false

#read config
$config = Read-ConfigFile -configFile $configFile
$seriesPath = $seriesName.toLower()
Get-ConfigValue -config $config -series $seriesName -key "Description" | Out-Null
if (!$description) {
    $description = '..\..\..\' + $seriesPath + '\Description.txt'
}
if (!$background) {
    $background = '..\..\..\' + $seriesPath + '\' + $seriesPath.replace(' ', '_') + '_bg.png'
}
if (!$contactBlock) {
    $contactBlock = $config.makeThumbnail.contactBlock
}
if (!$episodeNumber) {
    $episodeNumber = [Int]($config.$seriesName.episodeNumber) + 1
}

if (!$fontName) {
    if ($config.$($seriesName).fontName) {
        $fontName = $config.$($seriesName).fontName
    }
    else {
        $fontName = = "Bebas-Neue-Regular"
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

if (!$kerning) {
    if ($config.$($seriesName).kerning) {
        $kerning = $config.$($seriesName).kerning
    }
    else {
        $kerning = 0
    }
}

#create new stuff
Get-Background -background $background | Out-Null
if ($episodeText -eq "") {
    New-Thumbnail -number $episodeNumber -zeroPad $episodeZeroPad -font $fontName -point $fontSize -color $fontColor -strokeColor $fontStrokeColor -strokeWidth $fontStrokeWidth -kerning $kerning -interwordSpacing $interWordSpacing -episodeGravity $episodeNumberGravity -titleGravity $titleGravity -title $title -outPath $outPath -seriesName $seriesName -background $background    
}
else {
    New-Thumbnail -episodeText $episodeText -episodeGravity $episodeNumberGravity -font $fontName -point $fontSize -color $fontColor -strokeColor $fontStrokeColor -strokeWidth $fontStrokeWidth  -kerning $kerning -interwordSpacing $interWordSpacing -titleGravity $titleGravity -title $title -outPath $outPath -seriesName $seriesName -background $background    
}

#update configs
Update-GlobalConfig -config $config -outPath $outPath -contactBlock $contactBlock
Update-SeriesConfig -config $config -series $seriesName -episodeNumber $episodeNumber -description $description -background $background -fontName $fontName -interwordSpacing $interWordSpacing -kerning $kerning -fontSize $fontSize

if ($global:needsUpdate) {
    if (!$skipWrite) {
        Save-ConfigFile -config $config -configFile $configFile
    }
}