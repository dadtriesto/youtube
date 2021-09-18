# youtube
YouTube-Related Scripts And Whatnot.

# makeThumbnail.ps1
Using ImageMagick, this script will generate an image that can be used as a youtube thumbnail.

## Simple Usage
At its simplest, you're required to provide 2 things: an episode # and a background image.  
  
`.\makeThumbnail.ps1`  
  
If you do not provide either, you'll be prompted for them. Note: YouTube recommends 1280x720 for a thumbnail size. The generated image will be titled 'thumbnail.png'  
  
Use `get-help .\makeThumbnail.ps1 -detailed` for more information