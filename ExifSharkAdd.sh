#!/bin/bash
# mccshark@me.com

clear
OutputFolder="$HOME/Desktop/"

echo "ExifSharkAdd.sh script"
echo ""
date_formatted=$(date +%m.%d.%y-%H:%M:%S)
echo "Date and Time is: "$date_formatted
echo ""
echo " 1. = ~/Documents"
echo " 2. = /volumes/Lacie/NoDropbox/Photos2017/"
echo -n "Pick a number >"
read character
case $character in
    1 ) echo ""
        TempFolder="$HOME/Documents" ;;
    2 ) TempFolder="/volumes/Lacie/NoDropbox/Photos2017/" ;;
    * ) echo "You did not enter a number"
        echo "between 1 and 2."
        exit 0
esac
echo ""
read -p "Do you want to see a list of folders? (Yy)? " -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]
then
    echo ""
    cd $TempFolder
    ls -l -A -t
    echo ""
else
    echo "you selected no"
fi

IFS= read -r -p "Enter name of subfolder: " newsubfolder
WorkingFolder="$TempFolder/$newsubfolder"
echo ""
echo "The home folder is: "$HOME
echo "The temporary root folder is" $TempFolder
echo "The working folder is: " $WorkingFolder
echo ""
IFS= read -r -p "Enter name of image file ext (jpg,png,gif,m4v): " selectedImageFileExt
echo "You selected: "$selectedImageFileExt
echo ""

read -p "Are you sure you want to run this script (Yy)? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo ""
    echo " -- Ending script --"
    exit 1
fi
cd $WorkingFolder
echo ""
echo " 1. = Subject (overwrite)"
echo " 2. = Caption (if blank)"
echo " 3. = Caption with spaces (overwrite)"
echo " 4. = Add new keyword (no duplicates)"
echo " 5. = -sep: split a tag value into separate items"
echo ""
echo "-- Replace / delete / overwrite --"
echo " 6. = IPTC:Caption-Abstract (replace with space)"
echo " 7. = Image Description (replace)"
echo " 8. = Copyright (replace)"
echo " 9. = Caption (replace)"
echo ""
echo "-- IF BLANK --"
echo "20. = Dates individually (add, if blank)"
echo ""
echo "-- DELETE TAG --"
echo "21. = Keyword (delete)"
echo "31. = IPTC-Caption-Abstract eq imgur.com (delete)"
echo ""
echo " -- SET Image Dimensions, Megapixels, Filesize etc - Add Keywords --"
echo "41. = HD aka 1920x1080 and 1080x1920"
echo "42. = My Camera Dimensions aka Nikon, Canon, Kodak, iPhone (ImageWidth and ImageHeight)"
echo "48. = iPhone6 Dimensions"
echo "35. = large monitor (>1920 width)"
echo ""
echo " -- MY CAMERAS --"
echo "58. = KODAK DIGITAL SCIENCE DC260 (V01.00)"
echo ""
echo "-- Weed out SmallPix, SmallDim, add Wide, SuperLandscape --"
echo "51. = IF Megapixels < 0.7MB, SmallPix"
echo "52. = IF < 600k < 700k, SmallDim"
echo "53. = Run both option above (51 & 52)"
echo "54. = SuperLandscape"
echo "73. = Wide (landscape)"
echo "70. = SQUARE, PORTRAIT OR LANDSCAPE"
echo ""
echo "-- Bundle / collection of Tags --"
echo "74. = Collection of Tags with prompts."
echo "79. = Search for all common photo dimensions and set keyword tags"
echo ""
echo " -- Web sites --"
echo "80. = mccshark.com WordPress Media tags"
echo ""
echo "-- Rename Files"
echo "85. = Rename files with keywords or by caption"
echo ""
echo "-- Movies --"
echo "90. = Home Movie Dimensions e.g., 640x480..1920x1080"
echo "91. = Set Home Movie Tags"
echo ""
echo "-- Music --"
echo "95. = Music Name and ID"
echo "96. = Music tags to CSV"
echo ""
echo "Remember SPACES WILL SCREW UP FILENAMES !!!"
echo ""
echo -n "Pick a number >"
read character
clear
echo "Option: "$character
echo "The working folder is: " $WorkingFolder
echo ""
case $character in
     1) echo " create new subject name for JPGs (replace)"
        read -p "Enter name of new subject (replace): " newsubjectname
        echo "The new subject name is: $newsubjectname"
        exiftool -m -r -fast -ext $selectedImageFileExt -Subject=$newsubjectname -overwrite_original $WorkingFolder ;;
     2) read -p "Enter name of new caption (if blank): " NewCaption
        echo "The new caption name is: $NewCaption"
        exiftool -m -r -ext $selectedImageFileExt -if '(not $Caption)' -Caption=$NewCaption -overwrite_original $WorkingFolder ;;
     3) echo ""
        IFS= read -r -p "Enter new Caption: " NewCaption
        echo "The new caption will be: $NewCaption"
        exiftool -m -r -fast -ext $selectedImageFileExt -Caption="$NewCaption" -overwrite_original -overwrite_original $WorkingFolder ;;
     4) echo "Add a new Keyword section"
        IFS= read -r -p "Please enter a new Keyword: " newkeyword
        echo "You entered: $newkeyword"
        exiftool -m -r -fast -ext $selectedImageFileExt -keywords-="$newkeyword" -keywords+="$newkeyword" -overwrite_original $WorkingFolder ;;
     5) echo "-sep: split a tag value into separate items if it was originally stored incorrectly as a single string"
        # This feature may also be used to split a tag value into separate items if it was originally stored incorrectly as a single string:
        exiftool -ext $selectedImageFileExt -sep ", " -tagsfromfile @ -keywords -overwrite_original $WorkingFolder ;;
     6) echo ""
        IFS= read -r -p "Enter new IPTC:Caption-Abstract: " input
        echo "the new IPTC:Caption-Abstract will be: $input"
        exiftool -m -r -fast -ext $selectedImageFileExt -IPTC:Caption-Abstract="$input" -overwrite_original $WorkingFolder ;;
     7) echo "add a new Image Description"
        IFS= read -r -p "Enter new Image Description: " inputID
        echo "$input"
        exiftool -m -r -fast -ext $selectedImageFileExt -ImageDescription="$inputID" -overwrite_original $WorkingFolder ;;
     8) echo "add a new Copyright"
        IFS= read -r -p "Enter new Copyright: " input
        echo "$input"
        exiftool -m -r -copyright="$input" -overwrite_original $WorkingFolder ;;
     9) read -p "What caption would you like to add (replace old): " NewCaption
        echo "New caption is $NewCaption"
        exiftool -m -r -ext $selectedImageFileExt '-Caption=$NewCaption' -overwrite_original $WorkingFolder ;;
    13) exiftool -m -r -fast -ext jpg -if '$IPTC:Caption-Abstract and $Caption' -IPTC:Caption-Abstract=$Caption -overwrite_original $WorkingFolder ;;
    20) echo "add today's date if CreateDate, DateCreated and DateTimeOriginal is blank"
        exiftool -if -r '(not $CreateDate)' -xmp:CreateDate=now -overwrite_original $WorkingFolder
        exiftool -if -r '(not $DateCreated)' -DateCreated=now -overwrite_original $WorkingFolder
        exiftool -if -r '(not $DateTimeOriginal)' -DateTimeOriginal=now -overwrite_original $WorkingFolder;;
    21) echo "delete a keyword"
        IFS= read -r -p "What Keyword do you want to delete? " deletekeyword
        echo "You entered: $deletekeyword"
        exiftool -m -r -fast -ext jpg -keywords-="$deletekeyword" -overwrite_original $WorkingFolder ;;
    31) echo "delete imprix.com in Caption-Abstract"
        exiftool -m -r -Caption-Abstract-="imprix.com" -overwrite_original $WorkingFolder ;;
    41) echo "searching for HD (1280x1920) dimensions..."
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq "1920x1080"' -keywords-="1920x1080" -keywords+="1920x1080" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq "1080x1920"' -keywords-="1080x1920" -keywords+="1080x1920" -overwrite_original $WorkingFolder
        echo "complete." ;;
    42) echo "MY CAMERA Dimensions"
        echo "The current folder is: "$WorkingFolder
        echo ""
        echo "-- Portrait Camera Size Dimensions --"
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq 768x512' -Keywords+="768x512" -Keywords+="768x512" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq 1024x1536' -Keywords+="1024x1536" -Keywords+="1024x1536" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq 2448x3264' -Keywords+="2448x3264" -Keywords+="2448x3264" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq 3024x4032' -Keywords+="3024x4032" -Keywords+="3024x4032" -overwrite_original $WorkingFolder
        echo "-- Landscape Camera Size Dimensions --"
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq 1600x1200' -Keywords+="1600x1200" -Keywords+="1600x1200" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq 1536x1024' -Keywords-="1536x1024" -Keywords+="1536x1024" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq 2048x1536' -Keywords+="2048x1536" -Keywords+="2048x1536" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq 2272x1704' -Keywords+="2272x1704" -Keywords+="2272x1704" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq 2304x1728' -Keywords+="2304x1728" -Keywords+="2304x1728" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq 3264x2448' -Keywords+="3264x2448" -Keywords+="3264x2448" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq 3872x2592' -Keywords+="3872x2592" -Keywords+="3872x2592" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq 4000x3000' -Keywords+="4000x3000" -Keywords+="4000x3000" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext jpg -if '$ImageSize eq 6016x4000' -Keywords+="6016x4000" -Keywords+="6016x4000" -overwrite_original $WorkingFolder
        ;;
    50) exiftool -m -r -if 'not $datetimeoriginal' -datetimeoriginal=$ModifyDate $WorkingFolder ;;
    51) echo "Add tag SmallPix if < .7 Megapixels"
        echo ""
        exiftool -m -r -if '($FileType eq "JPEG") and ($Megapixels<0.7)' -Keywords-="SmallPix" -Keywords+="SmallPix" -overwrite_original $WorkingFolder ;;
    52) echo "Search for dimensions less than 501, 601 and tag SmallDim"
        exiftool -m -r -if '($FileType eq "JPEG") and ($ImageWidth<501) and ($ImageHeight < 601)'-Keywords-="SmallDim" -Keywords+="SmallDim" -overwrite_original $WorkingFolder
        echo "complete"  ;;
    53) echo "less than 0.7mp and imagewide less than 501"
        exiftool -m -r -if '($FileType eq "JPEG") and ($Megapixels<0.7)' -Keywords-="SmallPix" -Keywords+="SmallPix" -overwrite_original $WorkingFolder
        exiftool -m -r -if '($FileType eq "JPEG") and ($ImageWidth<501) and ($ImageHeight < 601)'-Keywords-="SmallDim" -Keywords+="SmallDim" -overwrite_original $WorkingFolder ;;
    54) echo "check new images for width of 2560 or greater"
        exiftool -m -r -ext jpg -if '($ImageWidth > 2559) and ($ImageWidth > $ImageHeight)' -Keywords-="SuperLandscape" -Keywords+="SuperLandscape" -overwrite_original $WorkingFolder ;;
    73) echo "check if landsacape keyword, evaluate if 2560 or greater width"
        exiftool -if '($keywords =~ /landscape/i) and ($ImageWidth > 2559)' -Keywords-="wide" -Keywords+="wide" $WorkingFolder ;;
    57) echo "update all dates to today if not datetimeoriginal"
        exiftool -alldates=now -if 'not datetimeoriginal' -overwrite_original $WorkingFolder ;;
    58) echo "My Cameras Tags (e.g., Canon, Nikon, Kodak etc.)"
        exiftool -m -r -if '$Make eq "Canon PowerShot G2"' -Keywords-="Canon" -Keywords+="Canon" -overwrite_original $WorkingFolder ;;
    70) echo "Set orientation like tag: portrait, landscape (for Picasa and Photo apps)"
        echo "Looking for Landscape..."
        exiftool -m -r -fast -ext jpg -if '$ImageWidth > $ImageHeight' -Keywords+="landscape" -overwrite_original $WorkingFolder
        echo "Looking for portrait..."
        exiftool -m -r -fast -ext jpg -if '$ImageWidth < $ImageHeight' -Keywords+="portrait" -overwrite_original $WorkingFolder ;;
    74) echo "Bundle: Set permissions, Caption-Abstract, check date, rename..."
        echo ""
        echo "running script..."
        echo ""
        cd $WorkingFolder
        echo "current working folder is: " $WorkingFolder
        echo "The current image file extention is: " $ImageFileExt
        echo "set permissions to 700"
        chmod 700 $WorkingFolder
        echo "square, portrait, landscape"
        exiftool -m -r -ext $ImageFileExt -fast -if '($ImageWidth eq $ImageHeight)' -Keywords+="square" -overwrite_original $WorkingFolder
        exiftool -m -r -ext $ImageFileExt -fast -if '($ImageWidth > $ImageHeight)' -Keywords+="landscape" -overwrite_original $WorkingFolder
        exiftool -m -r -ext $ImageFileExt -fast -if '($ImageWidth < $ImageHeight)' -Keywords+="portrait" -overwrite_original $WorkingFolder
        echo "HD portrait"
        exiftool -m -r -ext $ImageFileExt -fast -if $ImageSize eq "1080x1920" -keywords-="1080x1920" -keywords+="1080x1920" -overwrite_original $WorkingFolder
        exiftool -m -r -ext $ImageFileExt -fast -if $ImageSize eq "1280x1920" -keywords-="1280x1920" -keywords+="1280x1920" -overwrite_original $WorkingFolder
        echo "HD landscape"
        exiftool -m -r -ext $ImageFileExt -fast -if $ImageSize eq "1920x1080" -keywords-="1920x1080" -keywords+="1920x1080" -overwrite_original $WorkingFolder
        exiftool -m -r -ext $ImageFileExt -fast -if $ImageSize eq "1920x1200" -keywords-="1920x1200" -keywords+="1920x1200" -overwrite_original $WorkingFolder
        echo "Wide, check if landsacape and wide (wider than 2650)..."
        exiftool -m -r -ext $ImageFileExt -fast -if '($keywords =~ /landscape/i) and ($ImageWidth > 2559)' -Keywords-="wide" -Keywords+="wide" -overwrite_original $WorkingFolder
        echo "set datetimeoriginal if blank"
        exiftool -m -r -ext $ImageFileExt -fast -if not $DateTimeOriginal -DateTimeOriginal=now -overwrite_original $WorkingFolder
        echo ""

        read -p "Do you want to add new image tags using the folder name (Yy)? " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            echo "Setting IPTC:Caption-Abstract, Caption, and Description using the folder name"
            exiftool -m -r -ext jpg -fast -if '(not $Caption)' -Caption=$newsubfolder -overwrite_original $WorkingFolder
            exiftool -m -r -ext jpg -fast -if '(not $IPTC:Caption-Abstract)' -IPTC:Caption-Abstract=$newsubfolder -overwrite_original $WorkingFolder
            exiftool -m -r -ext jpg -fast -if '(not $Description)' -Description=$newsubfolder -overwrite_original $WorkingFolder
          else
          echo ""
          echo "You selcted no."
          echo ""
        fi

        echo ""
        read -p "Do you want to add a new IPTC:Caption-Abstract with spaces (Yy)? " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
          echo ""
          IFS= read -r -p "Enter new IPTC:Caption-Abstract: " input
            echo ""
            # echo "$input"
            exiftool -m -r -ext jpg -IPTC:Caption-Abstract="$input" -overwrite_original $WorkingFolder
        else
          echo ""
          echo "You selcted no."
          echo ""
        fi

        echo ""
        read -p "Do you want to select an Image Description? (Yy)? " -n 1 -r
        if [[ $REPLY =~ [Yy]$ ]]
        then
          echo ""
          IFS= read -r -p "Enter name of the new Image Description: " addImageDescription
            echo ""
            exiftool -m -r -ImageDescription="$addImageDescription" -overwrite_original $WorkingFolder
        else
          echo ""
          echo "you select no."
          echo ""
          #  exit 0
        fi

        echo ""
        read -p "Do you want to add a keywords (Yy)? " -n 1 -r
        if [[ $REPLY =~ [Yy]$ ]]
        then
            echo ""
            read -p "What keyword would you like to add: " newkeyword
              echo "New Keyword is $newkeyword"
              exiftool -m -r -ext jpg -keywords-=$newkeyword -keywords+=$newkeyword -overwrite_original $WorkingFolder
        else
           echo ""
           echo "you select no."
           echo ""
          #  exit 1
        fi

        read -p "Do you want to see the exif data (Yy)? " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            echo ""
            echo "Creating CSV..."
            exiftool -m -r -csv -g -FileName -ImageSize -XResolution -XMP:Subject -Title -XPTitle -Caption -Caption-Abstract -ImageDescription -IPTC:Caption-Abstract -Keywords -Headline -Description -Copyright -Rights -About -Creator -Credit -Keywords -overwrite_original $WorkingFolder > $OutputFolder"CheckNewPhotoTagProcess.csv"
            echo "look on desktop for file: CheckNewPhotoTagProcess.csv"
            echo ""
            # exit 0
        else
            echo ""
            echo "you selected no"
        fi

        read -p "Do you want to add a rename jpg files by folder name Caption (Yy)? " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
          echo "Renaming files by Caption..."
          exiftool -m -r -fast -ext jpg '-filename<${Caption}'_'${ImageSize} ${Megapixels}'mp' ${XResolution}'dpi' ${datetimeoriginal}' -d "%Y-%m-%d %H.%M.%S%%-c.%%e" '.'${FileTypeExtension} -overwrite_original $WorkingFolder
        else
          echo ""
          echo "You selcted no."
          echo ""
        fi

        read -p "Do you want to add a rename jpg files by Keywords (Yy)? " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
          echo "Renaming files by keywords..."
          exiftool -m -r -fast -ext jpg '-filename<${Keywords}'_'${ImageSize} ${datetimeoriginal}' -d "%Y-%m-%d %H.%M.%S%%-c.%%e" -overwrite_original $WorkingFolder
        else
          echo ""
          echo "You selcted no."
          echo ""
        fi

        echo "Script complete for: "$newsubfolder
        echo "exiting." ;;
    79) echo "Check for common ImageSizes..."
        echo ""
        read -p "Do you want to check for all image dimension (Yy)? " -n 1 -r
        if [[ $REPLY =~ [Yy]$ ]]
        then
            echo ""
            echo "check for additonal landscape and portrait dimensions and adding keywords if match"
            echo ""
            echo "checking for LANDSCAPE dimensions..."
            echo ""
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "1080x720")' -keywords-="1080x720" -keywords+="1080x720" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "1280x800")' -keywords-="1280x800" -keywords+="1280x800" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "1366x768")' -keywords-="1366x768" -keywords+="1366x768" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "1920x1080")' -keywords-="1920x1080" -keywords+="1920x1080" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "1920x1200")' -keywords-="1920x1200" -keywords+="1920x1200" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "2560x1440")' -keywords-="2560x1440" -keywords+="2560x1440" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "2560x1600")' -keywords-="2560x1600" -keywords+="2560x1600" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "3264x2448")' -Keywords+="3264x2448" -Keywords+="3264x2448" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "3744X5616")' -keywords-="3744X5616" -keywords+="3744X5616" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "3840x2160")' -keywords-="3840x2160" -keywords+="3840x2160" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "5616x3744")' -keywords-="5616x3744" -keywords+="5616x3744" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "6016x4000")' -Keywords+="6016x4000" -Keywords+="6016x4000" -overwrite_original $WorkingFolder
            echo ""
            echo "Checking for PORTRAIT dimensions..."
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "500x750")' -keywords-="500x750" -keywords+="500x750" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "800x1200")' -keywords-="800x1200" -keywords+="800x1200" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "1000x1500")' -keywords-="1000x1500" -keywords+="1000x1500" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "1067x1600")' -keywords-="1067x1600" -keywords+="1067x1600" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "1080x1920")' -keywords-="1080x1920" -keywords+="1080x1920" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "1280x1920")' -keywords-="1280x1920" -keywords+="1280x1920" -overwrite_original $WorkingFolder
            exiftool -m -r -fast -if '($FileType eq "JPEG") and ($ImageSize eq "2448x3264")' -Keywords-="2448x3264" -Keywords+="2448x3264" -overwrite_original $WorkingFolder
            echo "Finished checking for photo dimensions."
          else
              echo ""
              echo "you selected no, exiting."
          fi
          ;;
    80) echo "mccshark.com wordpress media tags"
        cd $WorkingFolder
        echo "set permissions to 700"
        # sudo chmod 700 $WorkingFolder
        chmod 700 $WorkingFolder
        echo "image dimension checking"
        exiftool -m -r -fast -ext $ImageFileExt -if $ImageWidth eq $ImageHeight -Keywords+="square" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext $ImageFileExt -if $ImageSize eq "128x128" -keywords-="128x128" -keywords+="128x128" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext $ImageFileExt -if $ImageSize eq "256x256" -keywords-="256x256" -keywords+="256x256" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext $ImageFileExt -if $ImageSize eq "512x512" -keywords-="512x512" -keywords+="512x512" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -ext $ImageFileExt -if $ImageSize eq "1920x1200" -keywords-="1920x1200" -keywords+="1920x1200" -overwrite_original $WorkingFolder

        read -p "Are you sure you want to wipe all existing tags? " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
          echo "wiping (deleting) all existing tags..."
          exiftool -all="" -overwrite_original $WorkingFolder
        else
          echo ""
          echo "You selcted no, exiting branch."
          echo ""
        fi

        read -p "Do you want to add a copyright info (Yy)? " -n 1 -r
        echo ""
        if [[ $REPLY =~ [Yy]$ ]]
        then
          newcopyright="mccshark LLC"
          similartags="mccshark.com LLC"
          exiftool -m -r -if '$FileType eq "JPEG"' -Copyright="$newcopyright" -Rights="$similartags" -Creator="$similartags" -Credit="$similartags" -About="$similartags" -overwrite_original $WorkingFolder
          exiftool -m -r -if '$FileType eq "JPEG"' -Title="$similartags" -caption="$similartags" -IPTC:Caption-Abstract="$similartags" -Description="Private & Public Cloud services" -overwrite_original $WorkingFolder
        else
           echo ""
           echo "you select no."
           echo ""
          #  exit 1
        fi
    ;;
    85) echo "Rename Files"
        read -p "Do you want to add a rename jpg, png or gif files by folder name Caption (Yy)? " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
          echo "Renaming files by Caption..."
          exiftool -m -r -fast -ext $selectedImageFileExt '-filename<${Caption}'_'${ImageSize} ${Megapixels}'mp' ${XResolution}'dpi' ${datetimeoriginal}' -d "%Y-%m-%d %H.%M.%S%%-c.%%e" '.'${FileTypeExtension} -overwrite_original $WorkingFolder
          exit 0
        else
          echo ""
          echo "You selcted no."
          echo ""
        fi

        read -p "Do you want to add a rename jpg files by Keywords (Yy)? " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
          echo "Renaming files by keywords..."
          exiftool -m -r -fast -ext jpg '-filename<${Keywords}'_'${ImageSize} ${datetimeoriginal}' -d "%Y-%m-%d %H.%M.%S%%-c.%%e" -overwrite_original $WorkingFolder
          exit 0
        else
          echo ""
          echo "You selcted no."
          echo ""
        fi
        ;;
    90) echo "Set Video Dimensions Tag e.g., 1920x1080"
        echo "NOTE: -ext mov is not set"
        exiftool -m -r -fast -if '$ImageSize eq "320x240"' -Keywords-="320x240" -Keywords+="320x240" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -if '$ImageSize eq "480x360"' -Keywords+="480x360" -Keywords+="480x360" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -if '$ImageSize eq "640x480"' -Keywords+="640x480" -Keywords+="640x480" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -if '$ImageSize eq "720x480"' -Keywords+="720x480" -Keywords+="720x480" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -if '$ImageSize eq "1280x720"' -Keywords+="1280x720" -Keywords+="1280x720" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -if '$ImageSize eq "1440x1088"' -Keywords+="1440x1088" -Keywords+="1440x1088" -overwrite_original $WorkingFolder
        exiftool -m -r -fast -if '$ImageSize eq "1920x1080"' -Keywords+="1920x1080" -Keywords+="1920x1080" -overwrite_original $WorkingFolder ;;
    91) echo "Set Home Movie Tags"
        read -p "Are you sure you want to add tags to your movie files in folder $LacieFolder (Yy)? " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]
        then
            echo ""
            echo " -- Ending script --"
            exit 1
        fi

        cd $WorkingFolder
        echo "The working folder is: " $WorkingFolder
        echo "current working folder is: " $WorkingFolder
        echo "set permissions to 700"
        echo ""
        chmod 700 $WorkingFolder
        echo "execuiting linux ls -a -l command..."
        echo ""
        ls -a -l

        for i in *m4v *mov; do

            # Get the extension of the previous file
            extension=${i##*.}

            # Extract metadata from the file
            model=$( exiftool -f -s3 -"Model" "${i}" )
            make=$( exiftool -f -s3 -"Make" "${i}" )
            # datetime=$( exiftool -f -s3 -"DateTimeOriginal" "${i}" )
            echo "the model is: " $model
            echo "the make is: " $make
        done

        exiftool -m -r -fast -caption="mccshark's Home Movies" -title="mccshark's Home Movies" -collectionName="Home Movies" -genre="Home Movies" -keywords="Home Movies" -overwrite_original $WorkingFolder
        ;;
    96) echo "Output Music tags"
        echo "The LaCie Folder is: "$LacieFolder
        echo "The working folder is: "$WorkingFolder
        echo ""
        exiftool -m -r -csv -g -FilePermissions -Filename -FileSize -FileType -FileTypeExtension -Title -Artist -Artistname -collectionname -Band -Album -Year -Track -AudioBitrate -PictureType -PictureMIMEType -overwrite_original $WorkingFolder > $OutputFolder"/MusicTags.csv"
        exiftool -m -r -csv -g -FilePermissions -Filename -QuickTime:AppleStoreCountry -QuickTime:AudioSampleRate -QuickTime:ContentCreateDate -QuickTime:GenreID -QuickTime:Title -QuickTime:Album -QuickTime:TrackDuration -QuickTime:CoverArt -QuickTime:PlayListID -QuickTime:TrackNumber -QuickTime:UserID -QuickTime:UserName $WorkingFolder > $OutputFolder"/QuickTimeMusicTags.csv" ;;
    * ) echo "You did not enter a number"
        echo "between 1 and 99." ;;
esac
exit 0
