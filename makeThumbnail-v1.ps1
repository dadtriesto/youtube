# 137 | %{magick convert .\crusader1280x720.jpg 
# -fill "rgba(0,0,0,0.5)" -draw "rectangle 100,0 500,720" 
# -font "..\\fonts\\PS_Steiner\\Steiner.otf" -pointsize 70 -interword-spacing 10 -interline-spacing -10 -kerning 0 -strokewidth 2 -stroke black 
# -fill "rgba(255,255,255,1)" -gravity north -annotate -340+475 "Dad\nTries\nTo" -pointsize 80 -annotate -340+10 "#$_" 
# .\MW5-alt-logo-red.png -gravity center -geometry 363x125-340-35 -composite output.jpg}

# clear;185 | %{.\makeThumbnail.ps1 -outPath "H:\thumbnails\" -seriesName "Ostranauts" -episodeNumber $_ -overlayGeometry x275-335-75  -overlay "h:\ostranauts\Ostranauts_Presskit_July 2023\Presskit files\Logo\Ostranauts_logo.png" -background "h:\ostranauts\Ostranauts_Presskit_July 2023\Presskit files\Key Art\Ostranauts_keyart_1920x1080.png" -title "DAD\nTRIES\nTO" -interlinespacing -20 -fontSize 90 -titleGravity center -titleOffset -335+230 -episodeNumberGravity center -episodeOffset -335-295}
