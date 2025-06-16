# ttKirby's-FFmpeg-Shell-Script

It is still under construction but works so far. English Script comming soon.

## Introduction

- Here is a simple shell script for batch processing video files with FFmpeg.
- The script searches the current folder for `.mkv`, `.mp4` and `.avi` files and offers a few functions to handle subtitle files.
- It works with a few variables and arrays, lists all videos in the folder and then asks what to do with them.
- This script is remotely based on a friend's. I don't have much experience in writing scripts, this is my first one with a larger scope, but I hope there are some people here who will find it useful.

## Functions

- Automatically process videos in a folder
- Support for external subtitle files (`.srt` and `.ass`)
- Automatically detects audio streams in video files. Applies appropriate presets based on number and properties of audio tracks
- Simple templates for specific FFmpeg configurations
- Possibility to remove subtitles
- Many comments and echoes in the script that explain where what happens, for better understanding and, if necessary, to add your own values

## Usage

- If environment variables have been set under Windows, simply double-click to execute. Otherwise open via console/terminal
- The script shows you a selection of options in a menu.

## Functionality

[1] Transcoding
- Works with fixed values for video, audio and subtitles.
- You should also adjust these for yourself if necessary!

[2] Transcoding with Auto-Audio
- Works with fixed values for video and subtitles. Recognizes audio channels and bit rates by FFprobe and reacts with predefined values.
- e.g. `2 channel = 224k` and `6 channel = 448k`.
- You should also adjust these for yourself if necessary!
- Note: It can handle `CBR` and `VBR`, but only reads out `CBR`. For `VBR` it takes predefined values.

[3] Apply templates
- Uses predefined templates for special use cases

[4] Remove subtitles
- Removes all subtitles, video and audio is copied and metadata is not touched.

[5] Exit (CTRL+C)
- Exits the script. You can also press `CTRL+C` anytime and anywhere to end the script.

[6] Shutdown and pause
- The script checks whether certain files are present in order to automatically shut down the PC or terminate the script.
- Pause: If there is a `pause.txt` in the folder, the script terminates itself after the current processing has been completed. Can be easily created in the folder at any time.
- Shutdown: If there is a `shutdown.txt` in the folder, it shuts down the PC after the current processing has been completed. Can be easily created in the folder at any time.
- For a more detailed procedure, see the whole script below under the headings `# SHUTDOWN` and `# PAUSE`.

## Customization 

- The script must be in the same folder as the videos to be edited.  
- Subtitle files must have the same name as the video.

[1] Transcode
- CRF, bit rate and metadata are adjusted at the top of the script.
- The order of the subtitles is defined in the variable i_files: 
 `""i_files=(-i "${srt_files[0]}" -i "${srt_files[1]}" -i "${ass_files[0]}")""`
- Recommended structure and naming is:

```
/MyFolder
 ├── !FFMPEG beta1.sh
 ├── video1.mkv
 ├── video1.FORCED.srt
 ├── video1.FULL.srt
 ├── video1.FULL.ass
```

[2] Transcodieren mit Audo-Audio
- Das gleiche wie bei [1] nur, das man Audio hier anpassen muss:
- `auto_bit_2="224"`
- `auto_bit_6="448"`

[3] Vorlagen
- Ein paar Beispiele sind vorgegeben, orientiere dich daran.
- Das wichtigste um Bild, Ton und gegebenfalls Text in die Videodatei zu bekommen sind:

```
-map 0:v		# uses video track
-map 0:a		# uses audio
-map 0:s 		# uses subtitles
-c:v libx265		# Transcoded to h265
-c:a eac3		# Transcodes to E-AC3
-b:a 224k		# Takes a constant audio bitrate (CBR) of 224k
-ac 2			# 2 channel stands for stereo, 6 would be for 5.1
-c:s srt		# Transcodes the subtitle to srt format
```

[4] Remove subtitles
- Only uses `-map 0:v -map 0:s -c:v copy -c:a copy` and thus copies all video and audio tracks, nothing more.

[5] Exit
- Self-explanatory. Press 5 and confirm with Enter. Or press `STRG+C` once.

## Requirements, recommendations and notes

- FFmpeg must be installed. Environment variables may need to be set.
- Git (https://git-scm.com/downloads)
- For editing under Windows I recommend: https://notepad-plus-plus.org/downloads/
- Theoretically also works under Linux and Mac, in practice I have only tested it under Windows!
- Subtitles are best edited with SubtitleEdit: https://www.nikse.dk/subtitleedit
- You can read out your video files with MediaInfo: https://mediaarea.net/en/MediaInfo

- Powerful tool for editing video files: https://handbrake.fr/
- Also a very practical tool to manage your videos: https://mkvtoolnix.download/

## License

MIT - freely usable, modifiable and shareable.
