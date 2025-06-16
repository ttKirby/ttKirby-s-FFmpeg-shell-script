# ttKirby's-FFmpeg-Shell-Script

Still in development, but works so far. English script comming soon.

## Overview

- A simple shell script for batch processing video files using FFmpeg.
- The script scans the current folder for `.mkv`, `.mp4`, and `.avi` files and offers a few features for handling subtitle files.
- It uses some variables and arrays, lists all videos in the folder, and asks what should be done with them.
- This script is loosely based on a friend's version. I don't have much experience writing scripts — this is my first larger project — but I hope someone out there will find it useful.

## Features

- Automatically process videos in a folder
- Support for external subtitle files (`.srt` and `.ass`)
- Automatically detects audio streams in video files. Applies presets based on the number and properties of the audio tracks
- Simple templates for common FFmpeg configurations
- Option to remove subtitles
- Many comments and echo outputs in the script to explain what happens where — great for understanding the flow and for customizing your own values

## Usage

- If environment variables are set on Windows, just double-click to run. Otherwise, open via console/terminal
- The script presents a menu of available options

## Functionality

[1] Transcoding  
- Uses predefined settings for video, audio, and subtitles  
- You should adjust them to your needs if necessary!

[2] Transcoding with Auto-Audio  
- Uses predefined settings for video and subtitles. Detects audio channels and bitrates via FFprobe and responds with predefined values  
- e.g. `2 channels = 224k` and `6 channels = 448k`  
- You should adjust these to your needs if necessary!  
- Note: It can handle both `CBR` and `VBR`, but only detects `CBR`. For `VBR`, it uses predefined fallback values.

[3] Apply templates  
- Uses predefined templates for specific use cases

[4] Remove subtitles  
- Simply removes all subtitles. Video and audio are copied without touching metadata.

[5] Exit (CTRL+C)  
- Exits the script. You can also press `CTRL+C` at any time to stop the script.

[6] Shutdown and Pause  
- The script checks for specific files to either shut down the PC or exit the script automatically.
- Pause: If a `pause.txt` file is present in the folder, the script will exit automatically after completing the current task. You can create this file at any time.
- Shutdown: If a `shutdown.txt` file is present, the PC will shut down after the current task is completed. You can create this file at any time.
- For details, see the bottom of the script under the `# SHUTDOWN` and `# PAUSE` sections.

## Customization

- The script must be in the same folder as the videos to be processed.  
- Subtitle files must have the same name as the video file.

[1] Transcoding  
- CRF, bitrate, and metadata settings can be found at the top of the script.  
- The order of subtitle files is defined in the `i_files` variable:  
  `i_files=(-i \"${srt_files[0]}\" -i \"${srt_files[1]}\" -i \"${ass_files[0]}\")`  
- Recommended structure and naming:

```
/MyFolder
  ├── !FFMPEG beta1.sh
  ├── video1.mkv
  ├── video1.FORCED.srt
  ├── video1.FULL.srt
  ├── video1.FULL.ass
```

[2] Transcoding with Auto-Audio  
- Same as [1], except audio bitrate needs to be customized:  
  `auto_bit_2=\"224\"`  
  `auto_bit_6=\"448\"`

[3] Templates  
- Some examples are included — use them as reference  
- The most important options to include video, audio, and subtitles are:

```
-map 0:v            # use video stream
-map 0:a            # use audio
-map 0:s            # use subtitles
-c:v libx265        # transcode to h265
-c:a eac3           # transcode to E-AC3
-b:a 224k           # constant audio bitrate (CBR) at 224k
-ac 2               # 2 channels = stereo, 6 = 5.1
-c:s srt            # transcode subtitles to srt format
```

[4] Remove subtitles  
- Only uses `-map 0:v -map 0:s -c:v copy -c:a copy`, so video and audio are copied without changes.

[5] Exit  
- Self-explanatory. Press 5 and hit Enter — or press `CTRL+C` anytime.

## Requirements, Recommendations & Notes

- FFmpeg must be installed. You may need to set environment variables.
- Git: https://git-scm.com/downloads  
- Recommended editor for Windows: https://notepad-plus-plus.org/downloads/  
- Should theoretically work on Linux and macOS too — practically tested only on Windows!  
- For editing subtitles: https://www.nikse.dk/subtitleedit  
- To inspect video file info: https://mediaarea.net/en/MediaInfo  

- Powerful tool for video processing: https://handbrake.fr/  
- Another handy tool for managing video files: https://mkvtoolnix.download/

## License

MIT – free to use, modify, and share.
