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

.PARAMETER thumbnail
    The filename of your finalized thumbnail. Can include path
.PARAMETER episodeNumber
    The number of the episode to display on the thumbnail
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
.PARAMETER dooblyDo
    Default: none. If provided, will echo contents of text file passed to it to make editing uploads a little faster. Future update: generate from input schema file.
#> 

[CmdletBinding(DefaultParametersetName = "setDefault")]
Param(
    [string]$thumbnail = "final.png",
    [Parameter(Mandatory=$true)]
    [string]$seriesName,
    [Parameter(Mandatory=$true)]
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
    [Int]$fontSize = 108,
    [string]$fontColor = "white",
    [string]$fontStrokeColor = "black",
    [Int]$fontStrokeWidth = 1,
    [string]$dooblyDo
);

write-output "Making thumbnail"
write-output "Thumbnail: [$thumbnail]"
write-output "Background: [$background]"
write-output "Episode: [$episode]"
if(!$background){
    write-output "No background provided. Please select a background"
}

if(!$background){
    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $null = $FileBrowser.ShowDialog()
    if(!$FileBrowser.FileName){
        exit 0
    }
    
    $background = $FileBrowser.FileName
}


# make the DTT label
write-output "Making title image title.png"
magick convert -background $titleBackgound -fill $fontColor -font $fontName -pointsize $fontSize -stroke $fontStrokeColor -strokewidth $fontStrokeWidth label:$title title.png
# make the episode label
$paddedEpisode = ($episodeNumber).PadLeft($episodeZeroPad,'0')
write-output "Making episode $paddedEpisode image episode.png"
magick convert -background $episodeBackground -fill $fontColor -font $fontName -pointsize $fontSize -stroke $fontStrokeColor -strokewidth $fontStrokeWidth label:$paddedEpisode episode.png
# composite label onto background -> intermediary
write-output "Compositing episode.png and $background to intermediary.png"
magick composite -resize '1x1<' -gravity $episodeNumberGravity -geometry +25+10 episode.png $background intermediary.png
# composite episode onto intermediary -> $thumbnail
write-output "Compositing title.png and intermediary.png to $thumbnail"
$outFileName = "${seriesName}_thumbnail_${episodeNumber}.png"
magick composite -resize '1x1<' -gravity $titleGravity -geometry +25+10 title.png .\intermediary.png $outFileName.Replace(' ','_')

write-output "removing title.png"
Remove-Item title.png
write-output "removing episode.png"
Remove-Item episode.png
write-output "removing intermediary.png"
Remove-Item intermediary.png
write-output "Thumbnail [$thumbnail] created"
write-output "Suggested YouTube Title: ${title}: $subTitle, $paddedEpisode"

if($dooblyDo){
    write-output "Doobly Do"
    Get-Content $dooblyDo | write-output 
}