#Requires -Version 2

<#  
.SYNOPSIS  
    Uses ffmepg to concatenate 2 video files together.

.DESCRIPTION
    When given a $recording, users ffmpeg to append $endScreen onto it. Files must be the same size.

.EXAMPLE
    Example.ps1
    .\makeThumbnail -episodeNumber 1

.NOTES  
    Author      : Dad Tries To
    Version     : 1.0.0
    Requires    : ffmpeg
    License     : MPL 2.0 (See Repo)

.PARAMETER recording
    The filename of your recording. Can include path
.PARAMETER endScreen
    The end screen to append to $recording
.PARAMETER outputName
    The non-extension name of your file (output.mp4 -> output)
#> 

[CmdletBinding(DefaultParametersetName = "setDefault")]
Param(
    [Parameter(Mandatory=$true)]
    [string]$recording,
    [string]$endScreen = "EndCard.mp4",
    [string]$outputName = "output"
);


Remove-Item concatList.txt
Write-Output "file '$recording'" | out-file concatList.txt -Encoding ascii
Write-Output "file '$endScreen'" | out-file -append concatList.txt -Encoding ascii
ffmpeg -safe 0 -f concat -i concatList.txt -c copy "${outputName}.mp4"
Remove-Item concatList.txt