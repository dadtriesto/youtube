# youtube
YouTube-related scripts and whatnot.

# List of Tools
[OBS](https://obsproject.com/) for recording capture.  
[Davinci Resolve](https://www.blackmagicdesign.com/products/davinciresolve/). Used in the dad tries to automate channel tasks video.  
[Paint.net](https://www.getpaint.net/) for general image manipulation.  
[Image Magick](https://imagemagick.org/) for thumbnail generation.  
Music from [Incompetech](https://incompetech.filmmusic.io).  
Orange grate image from [Pixabay]( https://pixabay.com/users/brett_hondow-49958/).  
Bebas Neue font from [google fonts](https://fonts.google.com/specimen/Bebas+Neue).  
Nunito Sans font from [google fonts](https://fonts.google.com/specimen/Nunito+Sans).  
Screen grabs courtesy of `Win+Shift+S`
  
# makeThumbnail.ps1
This powershell script will generate an image that can be used as a youtube thumbnail. Requires [Image Magick](https://imagemagick.org/).

## Simple Usage
At its simplest, you're required to provide 2 things: an episode # and a background image.  
  
`.\makeThumbnail.ps1`  
  
If you do not provide either, you'll be prompted for them. Note: YouTube recommends 1280x720 for a thumbnail size. The generated image will be titled 'thumbnail.png'  
  
Use `get-help .\makeThumbnail.ps1 -detailed` for more information

# Command Line Stuff
Use ffmpeg to extract audio from an mp4 (use OBS for audio-only capture) `ffmpeg -i source.mp4 -vn -c:a copy audio-only.m4a`  
Use ffmpeg to concatenate videos where filenames are contained in a file called 'concatList.txt' with lines like `file 'path/to/file.ext'`
  
`ffmpeg -safe 0 -f concat -i concatList.txt -c copy "concatenatedFile.mp4"`