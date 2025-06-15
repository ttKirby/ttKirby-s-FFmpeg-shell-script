# FFmpeg Shell Script

A simple shell script for batch processing video files with FFmpeg.  
The script scans the current folder for `.mkv`, `.mp4`, and `.avi` files and provides basic functions for converting videos and handling subtitles.

## Features

- Automatically process videos in a folder  
- Support for external subtitle files (`.srt`, `.ass`)  
- Automatically detects audio streams in video files and applies suitable presets based on the number and characteristics of audio tracks (e.g., stereo vs. multichannel, single vs. multiple tracks)  
- Option to remove subtitles  
- Simple templates for specific FFmpeg configurations  
- Many comments and echo statements in the script that explain step-by-step what happens where and how the individual functions work.

## How it works

The script uses a few variables and arrays, lists all videos in the folder, and then asks what should be done with them.

### Supported video formats

- `.mkv`  
- `.mp4`  
- `.avi`

## Requirements

- FFmpeg must be installed and callable from the terminal/command line (environment variables may need to be set)  
- Git (https://git-scm.com/downloads)

## Usage

The script shows you a selection of options in the terminal.

## Folder structure

The script must be in the same folder as the videos to be processed.  
Subtitle files should have the same name as the video.

```
/MyFolder
  ├── video1.mkv
  ├── video1.FORCED.srt
  ├── video1.FULL.srt
  ├── video1.FULL.ass
  ├── !FFMPEG beta1.sh
```

## License

MIT – free to use, modify, and share.
