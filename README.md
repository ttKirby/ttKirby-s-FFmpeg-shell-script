# ttKirby's-FFmpeg-Shell-Script

A simple shell script for batch processing video files with FFmpeg.  
The script scans the current folder for `.mkv`, `.mp4`, and `.avi` files and offers a few features for handling subtitle files.  
It works with some variables and arrays, lists all videos in the folder, and then asks what should be done with them.  
I don't have much experience writing scripts, but I hope someone finds this useful.

## Features

- Automatically process videos in a folder
- Support for external subtitle files (`.srt` and `.ass`)
- Automatically detects audio streams in video files. Applies preset values based on the number and characteristics of audio tracks (e.g. stereo vs. multichannel, single vs. multiple tracks)
- Simple templates for specific FFmpeg configurations
- Option to remove subtitles
- Lots of comments and echo statements in the script that explain what's happening, to help you understand and potentially customize things

## Usage

If environment variables are set under Windows, simply double-click to run.  
The script will show you a selection menu in the terminal with different options.

## Functionality

[1] Transcoding  
- Works with predefined values for video, audio, and subtitles.  
- You should customize these settings to your own needs!

[2] Transcoding with Auto-Audio  
- Uses predefined values for video and subtitles. Detects audio channels and bitrate via FFprobe and reacts with predefined settings.  
- e.g. 2 channels = 224k and 6 channels = 448k  
- You should customize these settings to your own needs!

[3] Apply Templates  
- Uses predefined templates for specific use cases

[4] Remove Subtitles  
- Simply removes all subtitles; video and audio are copied, metadata remains untouched.

[5] Exit (CTRL+C)  
- Exits the script. You can also press CTRL+C at any time to quit the script.

## Customization

The script must be in the same folder as the video files you want to process.  
Subtitle files must have the same name as the video.

[1] Transcoding  
- CRF, bitrate, and metadata settings are defined at the top of the script.  
- The subtitle order is defined in the `i_files` variable:  
  `i_files=(-i "${srt_files[0]}" -i "${srt_files[1]}" -i "${ass_files[0]}")`  
- Recommended folder and naming structure:

```
/MyFolder
  ├── !FFMPEG beta1.sh
  ├── video1.mkv
  ├── video1.FORCED.srt
  ├── video1.FULL.srt
  ├── video1.FULL.ass
```

[2] Transcoding with Auto-Audio  
- Same as [1], but here you can adjust the audio bitrate:

	`auto_bit_2="224"`  
	`auto_bit_6="448"`

[3]  
- ...

## Requirements, Recommendations, and Notes

- FFmpeg must be installed. Environment variables may need to be set.
- Git: https://git-scm.com/downloads
- For editing under Windows, I recommend: https://notepad-plus-plus.org/downloads/
- Should theoretically also work on Linux and macOS, but I’ve only tested it on Windows!

## License

MIT – free to use, modify, and share.
