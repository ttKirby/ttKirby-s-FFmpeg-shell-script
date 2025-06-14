# FFmpeg-shell-script
A relatively narrow shell script which uses FFmpeg to process its media.
It mainly uses variables and arrays which makes it very error-prone.
It searches the current folder for mkv, mp4 and avi files and processes all media in the folder.

The script has a few functions like:
1 .transcoding with and without subtitle files (SRT and ASS, must be in the same directory)
2. the same as 1. only with automatic audio recognition and renaming
3. templates for special configurations
4. remove subtitles
