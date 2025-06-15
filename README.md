# ttKirby's-FFmpeg-Shell-Script

Here's a simple shell script for batch processing video files using FFmpeg.  
The script searches the current folder for `.mkv`, `.mp4`, and `.avi` files and offers a few functions for handling subtitle files.  
It uses some variables and arrays, lists all videos in the folder, and then asks what should be done with them.  
I don’t have much experience writing scripts, but I hope someone might find this useful.

## Features

- Automatically process videos in a folder
- Support for external subtitle files (`.srt` and `.ass`)
- Automatically detects audio streams in video files. Applies predefined settings based on the number and properties of the audio tracks
- Simple templates for specific FFmpeg configurations
- Option to remove subtitles
- Many comments and echoes in the script explaining where and what is happening, for easier understanding and for adding your own values

## Usage

If environment variables are set under Windows, just double-click to run. Otherwise, open via console/terminal.  
The script shows you a menu with a list of options.

## Functionality

[1] Transcode  
- Works with predefined values for video, audio, and subtitles.  
- You should adjust these for your own needs if necessary!

[2] Transcode with Auto-Audio  
- Works with fixed values for video and subtitles. Detects audio channels and bitrates using FFprobe and reacts with predefined values.  
- e.g., 2 channels = 224k and 6 channels = 448k  
- You should adjust these for your own needs if necessary!  
- Note: It can handle both CBR and VBR, but only reads CBR. For VBR, it uses predefined values.

[3] Apply Templates  
- Uses predefined templates for special use cases

[4] Remove Subtitles  
- Simply removes all subtitles; video and audio are copied, metadata remains untouched.

[5] Exit (CTRL+C)  
- Exits the script. You can also press CTRL+C at any time to exit the script.

## Customization

The script must be in the same folder as the videos to be processed.  
Subtitle files must have the same name as the video.

[1] Transcode  
- CRF, bitrate, and metadata are adjusted at the top of the script.  
- The order of subtitles is managed by the variable `i_files`:  
  `"i_files=(-i \"${srt_files[0]}\" -i \"${srt_files[1]}\" -i \"${ass_files[0]}\")"`  
- Recommended structure and naming is:

```
/MyFolder
  ├── !FFMPEG beta1.sh
  ├── video1.mkv
  ├── video1.FORCED.srt
  ├── video1.FULL.srt
  ├── video1.FULL.ass
```

[2] Transcode with Auto-Audio  
- Same as [1], except you must adjust the audio here:

    auto_bit_2="224"  
    auto_bit_6="448"

[3] Templates  
- A few examples are provided, use them as a reference.  
- The most important parts for including video, audio, and optionally text into the video file are:


```
-map 0:v		# nutzt Videospur
-map 0:a		# nutzt Audio
-map 0:s 		# nutzt Untertitel
-c:v libx265	    # Transkodiert zu h265
-c:a eac3		# Transkodiert zu E-AC3
-b:a 224k		# Nimmt eine konstante Audiobitrate (CBR) von 224k
-ac 2			# 2 Kanal steht für Stereo, 6 wäre für 5.1
-c:s srt		# Transcodiert den Untertitel in das srt-Format
```

[4] Remove Subtitles  
- Just uses `-map 0:v -map 0:a -c:v copy -c:a copy`, copying all video and audio streams, nothing more.

[5] Exit  
- Self-explanatory. Press 5 and confirm with Enter. Or press CTRL+C once.

## Requirements, Recommendations and Notes

- FFmpeg must be installed. Environment variables might need to be set.
- Git (https://git-scm.com/downloads)
- For editing under Windows I recommend: https://notepad-plus-plus.org/downloads/
- Theoretically works on Linux and Mac too, but I only tested it on Windows!
- Best to edit subtitles using SubtitleEdit: https://www.nikse.dk/subtitleedit
- You can analyze your video files with MediaInfo: https://mediaarea.net/en/MediaInfo

- Powerful tool for editing videos: https://handbrake.fr/
- Also a very practical tool for handling your videos: https://mkvtoolnix.download/

## License

MIT – free to use, modify and share.
