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
    Default: none. The background image for your thumbnail. If none is provided, a dialog will open to allow you to select one.
.PARAMETER title
    Default: DAD TRIES TO. Sets the title to display in the thumbnail.
.PARAMETER titleGravity
    Default: NorthWest. Tells ImageMagick where to place the title. Uses no-space compass bearings (NorthEast, SouthWest, etc).
.PARAMETER titleBackgound
    Default: none. Defines fill color for the title temp image.
.PARAMETER subTitle
    Used to add a subtitle for suggest YouTube titles. Output format is `$title: $subtitle, $episode`
.PARAMETER fontName
    Default: Bebas Neue Regular. The font ImageMagick will use for title and episode. Must be a an installed ttf font.
.PARAMETER fontSize
    Default: 108pt. The font size ImageMagick will use for title and episode.
.PARAMETER fontColor
    Default: white. The font color ImageMagick will use for title and episode.
.PARAMETER fontStrokeColor
    Default: black. The font color ImageMagick will use to outline title and episode text.
.PARAMETER fontStrokeWidth
    Default: 1. The width of the outline ImageMagick will apply to title and episode.
.PARAMETER description
    Default: none. If provided, will echo contents of text file passed to it to make editing uploads a little faster. Future update: generate from input schema file.
.PARAMETER contactBlock
    Required. Default: none. If provided, will echo contents of text file passed to it to make editing uploads a little faster. Future update: generate from input schema file.
#> 

[CmdletBinding(DefaultParametersetName = "setDefault")]
Param(
    [string]$outPath,
    [Parameter(Mandatory = $true)]
    [string]$seriesName,
    [string]$episodeNumber,
    [string]$episodeNumberGravity = "SouthEast",
    [string]$episodeBackground = "none",
    [Int]$episodeZeroPad = 2,
    [string]$background,
    [string]$title = "DAD TRIES TO",
    [string]$titleGravity = "NorthWest",
    [string]$titleBackgound = "none",
    [string]$subTitleAction = "Play",
    [string]$subTitle = "${subTitleAction} $seriesName",
    [string]$fontName = "Bebas-Neue-Regular",
    [Int]$fontSize = 128,
    [string]$fontColor = "white",
    [string]$fontStrokeColor = "black",
    [Int]$fontStrokeWidth = 1,
    [string]$description,
    [string]$contactBlock,
    [string]$configFile = '.\makeThumbnail.json',
    [Boolean]$skipWrite = $false
);
$global:needsUpdate = $false

Import-Module (Resolve-Path('makeThumbnailFunctions.psm1')) -Force
# Get-Module
#read config
$config = Read-ConfigFile -configFile $configFile
$seriesPath = $seriesName.toLower()
Get-ConfigValue -config $config -series $seriesName -key "Description"
if(!$description){
    $description = '..\..\..\'+$seriesPath+'\Description.txt'
}
if(!$background){
    $background = '..\..\..\'+$seriesPath+'\'+$seriesPath.replace(' ', '_')+'_bg.png'
}
if(!$contactBlock){
    $contactBlock = '..\..\..\dad tries to\social media\contact.txt'
}
if(!$episodeNumber){
    $episodeNumber = [Int]($config.$seriesName.episodeNumber) + 1
}

# if seriesName isn't in config, create an entry?
# if seriesName is in config, check for cli overrides, then set desc/ep/bkg to config file contents

#create new stuff
Get-Background -background $background
New-Thumbnail -number $episodeNumber -zeroPad $episodeZeroPad -font $fontName -point $fontSize -color $fontColor -strokeColor $fontStrokeColor -strokeWidth $fontStrokeWidth -episodeGravity $episodeNumberGravity -titleGravity $titleGravity -title $title -outPath $outPath -seriesName $seriesName -background $background
Write-TitleAndDescription -number $episodeNumber -zeroPad $episodeZeroPad -title $title -subTitle $subTitle -description $description -contactBlock $contactBlock

#update configs
Update-GlobalConfig -config $config -outPath $outPath -contactBlock $contactBlock
Update-SeriesConfig -config $config -series $seriesName -episodeNumber $episodeNumber -description $description -background $background
if($global:needsUpdate){
    if(!$skipWrite){
        Save-ConfigFile -config $config -configFile $configFile
    }
}