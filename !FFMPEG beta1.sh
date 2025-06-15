#!/bin/bash

## Hier deine Werte für das Transcodieren eingeben.

	# Videoqualität
	crf="20"

	# Audiobitrate
	bit_2="224"
	bit_6="448"
	
	# Audiobitrate für Audo-Audio
	auto_bit_2="224"
	auto_bit_6="448"

	# Audiokanäle
	audio_channe0="stereo"
	audio_channe1="5.1"

	# Metadata: Sprache (für Audio und Untertitel)
	# lang_1="ger"
	# lang_2="ja"

	# Metadata: Audio
	# title_audio1="Stereo"
	# title_audio2="Surround"

	# Metadata: Untertitel
	# title_sub1="Forced"
	# title_sub2="Full"


trap 'echo -e "\nAbbruch durch Benutzer."; exit 1' INT

WORKINGDIR="$(pwd -W)"
echo ""
echo "$WORKINGDIR"
PAUSEFILE=pause.txt
SHUTDOWNFILE=shutdown.txt

#Zierlort wählen
ordner="$(pwd)/output"
#ordner="Y:\MKVnew"

eingespartemb=0
counter=0
mkdir -p "$ordner"

shopt -s nullglob

# Farben definieren
RED="\e[31m"
ORANGE="\e[33m"
YELLOW="\e[93m"
GREEN="\e[32m"
CYAN="\e[36m"
RESET="\e[0m"
BOLD="\e[1m"		# Fettgedruckt
NORMAL="\e[22m"		# Deaktiviert Fettgedruckt

# Menü anzeigen
clear
echo -e "${CYAN}${BOLD}"
echo -e "╔════════════════════════════════════════╗"
echo -e "║${NORMAL} Wähle Verarbeitungsweg                 ${BOLD}║"
echo -e "╠════════════════════════════════════════╣"
echo -e "║${NORMAL}${YELLOW} 1) Transkodieren                       ${BOLD}${CYAN}║"
echo -e "║${NORMAL}${YELLOW} 2) Transkodieren mit Auto-Audio        ${BOLD}${CYAN}║"
echo -e "║${NORMAL}${YELLOW} 3) Vorlagen anwenden                   ${BOLD}${CYAN}║"
echo -e "║${NORMAL}${YELLOW} 4) Untertitel entfernen                ${BOLD}${CYAN}║"
echo -e "║${NORMAL}${YELLOW} 5)${RED} Beenden  (STRG+C)                   ${BOLD}${CYAN}║"
echo -e "╚════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${YELLOW}"
read -p "Deine Wahl (1/2/3/4/5): " auswahl
echo -e "${RESET}"

# Eingabevalidierung für die Auswahl
if ! [[ "$auswahl" =~ ^[1-5]$ ]]; then
    echo -e "${RED}Ungültige Auswahl! Bitte 1, 2, 3, 4 oder 5 wählen.${RESET}"
	sleep 1
    exit 1
fi

# Animation
if [[ "$auswahl" == "1" || "$auswahl" == "2" ]]; then
	echo -e "${CYAN}${BOLD}"
	echo -e "╔════════════════════════════════════════╗"
	echo -e "║${NORMAL} Handelt es sich um eine Animation?     ${BOLD}║"
	echo -e "╠════════════════════════════════════════╣"
	echo -e "║${NORMAL}${YELLOW} 1) Ja                                  ${BOLD}${CYAN}║"
	echo -e "║${NORMAL}${YELLOW} 2) Nein                                ${BOLD}${CYAN}║"
	echo -e "╚════════════════════════════════════════╝${RESET}"
	echo -e ""
	echo -e "${YELLOW}"
	read -p "Deine Wahl (1/2): " animation
	echo -e "${RESET}"

	# Eingabevalidierung für die Auswahl
	if ! [[ "$animation" =~ ^[1-2]$ ]]; then
		echo -e "${RED}Ungültige Auswahl! Bitte 1 oder 2 wählen.${RESET}"
		sleep 1
		exit 1
	fi
fi

# Vorlagen
if [[ "$auswahl" == "3" ]]; then
	echo -e "${CYAN}${BOLD}"
	echo -e "╔════════════════════════════════════════╗"
	echo -e """║${NORMAL} Welches Preset möchtest du verwenden?  ${BOLD}║"
	echo -e "╠════════════════════════════════════════╣"
	echo -e "║${NORMAL}${YELLOW} 1) Test1                      ${BOLD}${CYAN}║"
	echo -e "║${NORMAL}${YELLOW} 2) Test2     ${BOLD}${CYAN}║"
	echo -e "║${NORMAL}${YELLOW} 3) /                  ${BOLD}${CYAN}║"
	echo -e "║${NORMAL}${YELLOW} 4) /              ${BOLD}${CYAN}║"
	echo -e "║${NORMAL}${YELLOW} 5) /              ${BOLD}${CYAN}║"
	echo -e "║${NORMAL}${YELLOW} 6) /              ${BOLD}${CYAN}║"
	echo -e "║${NORMAL}${YELLOW} 7)${RED} Beenden  (STRG+C)                   ${BOLD}${CYAN}║"
	echo -e "╚════════════════════════════════════════╝${RESET}"
	echo -e ""
echo -e "${YELLOW}"
read -p "Deine Wahl (1/2/3/4/5/6/7): " preset
echo -e "${RESET}"

	# Eingabevalidierung für die Auswahl
	if ! [[ "$preset" =~ ^[1-2]$ ]]; then
		echo -e "${RED}Ugültige Auswahl! Bitte 1 oder 2 wählen.${RESET}"
		sleep 1
		exit 1
	fi
fi

if [[ "$auswahl" == "5" || "$preset" == "7" ]]; then
	echo ""
	echo -e "${RED}Beende das Skript...${RESET}"
	sleep 1
	exit 0
fi

# Schleife für alle Videodateien im aktuellen Verzeichnis
for filename in *.mkv *.mp4 *.avi;
do
	ext="${filename##*.}"
	title=$(basename "$filename" ."$ext")
	new_filename="$ordner/${title}.mkv"
	counter=$((counter+1))

	echo ""
	echo -e "${ORANGE}\"$filename\" ${YELLOW}wird ausgelesen.${RESET}"
	echo ""

	# SRT- und ASS-Dateien suchen
	srt_files=( "$title"*.srt )
	ass_files=( "$title"*.ass )
	for srt in "${srt_files[@]:0:2}"; do
		echo "   - $srt"
	done
	for ass in "${ass_files[@]:0:2}"; do
		echo "   - $ass"
	done

	echo ""
# FFMPEG
	if [ 1 -eq 1 ]; then

		# Leeren/Zurücksetzen/Initialisieren der Werte um Fehler zu vermeiden
		i_files=""
		map_files=""
		map_video=""
		tune_ani=""
		map_sub=""
		type_sub=""
		metadata_a_0=""
		metadata_a_1=""
		metadata_a_2=""
		metadata_s_0=""
		metadata_s_1=""
		metadata_s_2=""

		i_files=()
		map_audio=()
		codec_audio=()
		channels_audio=()
		title_audio=()
		bitrate_audio=()

		## Function Execution Variablen

	# lang_1="ger"
	# lang_2="ja"
	# title_audio1="Stereo"
	# title_audio2="Surround"
	# title_sub1="Forced"
	# title_sub2="Full"

	# ${bit_2}k

		transcode1() {
				echo ""
				map_video="-map 0:v -c:v libx265 -crf $crf"
				if [[ "$animation" == "1" ]]; then
					tune_ani="-tune animation"
				fi
				if [[ "$auswahl" == "1" ]]; then
					map_audio=("-map 0:a:0 -c:a:0 eac3 -b:a:0 ${bit_2}k -filter:a:0 aformat=channel_layouts=$audio_channe0
								-map 0:a:1 -c:a:1 eac3 -b:a:1 ${bit_6}k -filter:a:1 aformat=channel_layouts=$audio_channe1")
				fi
		}

		# metadata_a_1() {
		# }
		
		# metadata_a_2() {
		# }

		# metadata_a_3() {
		# }

		# metadata_a_4() {
		# }


		# metadata_s_1() {
		# }
		
		# metadata_s_2() {
		# }

		# metadata_s_3() {
		# }

		# metadata_s_4() {
		# }


		# [1] Transkodieren
		if [[ "$auswahl" == "1" || "$auswahl" == "2" ]]; then
			if [ ${#srt_files[@]} -eq 0 ] && [ ${#ass_files[@]} -eq 0 ]; then										# 0 SRT & 0 ASS
				echo -e "${YELLOW}Keine Untertiteldateien gefunden.${RESET}"
				transcode1
				type_sub="-c:s srt"
			elif [ ${#srt_files[@]} -eq 1 ] && [ ${#ass_files[@]} -eq 0 ]; then										# 1 SRT & 0 ASS
				echo -e "${YELLOW}Eine Untertiteldateien (1x SRT) gefunden.${RESET}"
				transcode1
				metadata_a_0="-metadata:s:a:0 language=ger -metadata:s:a:0 title=Stereo -disposition:a:0 default"
				metadata_s_0="-metadata:s:s:0 language=ger -metadata:s:s:0 title=Full -disposition:s:0 default"
				map_files="-map 1"
				type_sub="-c:s:0 srt"
				i_files=(-i "${srt_files[0]}")
			elif [ ${#srt_files[@]} -ge 2 ] && [ ${#ass_files[@]} -eq 0 ]; then										# 2 SRT & 0 ASS
				echo -e "${YELLOW}Zwei Untertiteldateien (2x SRT) gefunden.${RESET}"
				transcode1
				metadata_a_0="-metadata:s:a:0 language=ger -metadata:s:a:0 title=Stereo -disposition:a:0 default"
				metadata_a_1="-metadata:s:a:1 language=ja -metadata:s:a:1 title=Stereo -disposition:a:1 -default"
				metadata_s_0="-metadata:s:s:0 language=ger -metadata:s:s:0 title=Full -disposition:s:0 default"
				metadata_s_1="-metadata:s:s:1 language=ger -metadata:s:s:1 title=Full -disposition:s:1 -default"
				map_files="-map 1 -map 2"
				type_sub="-c:s:0 srt -c:s:1 srt"
				i_files=(-i "${srt_files[0]}" -i "${srt_files[1]}")
			elif [ ${#srt_files[@]} -eq 1 ] && [ ${#ass_files[@]} -eq 1 ]; then										# 1 SRT & 0 ASS
				echo -e "${YELLOW}Zwei Untertiteldateien (1x SRT & 1x ASS) gefunden.${RESET}"
				transcode1
				metadata_a_0="-metadata:s:a:0 language=ger -metadata:s:a:0 title=Stereo -disposition:a:0 default"
				metadata_a_1="-metadata:s:a:1 language=ja -metadata:s:a:1 title=Stereo -disposition:a:1 -default"
				metadata_s_0="-metadata:s:s:0 language=ger -metadata:s:s:0 title=Full -disposition:s:0 default"
				metadata_s_1="-metadata:s:s:1 language=ger -metadata:s:s:1 title=Full -disposition:s:1 -default"
				map_files="-map 1 -map 2"
				type_sub="-c:s:0 srt -c:s:1 ass"
				i_files=(-i "${srt_files[0]}" -i "${ass_files[0]}")
			elif [ ${#srt_files[@]} -eq 2 ] && [ ${#ass_files[@]} -eq 1 ]; then										# 2 SRT & 1 ASS
				echo -e "${YELLOW}Drei Untertiteldateien (2x SRT & 1x ASS) gefunden.${RESET}"
				transcode1
				metadata_a_0="-metadata:s:a:0 language=ger -metadata:s:a:0 title=Stereo -disposition:a:0 default"
				metadata_a_1="-metadata:s:a:1 language=ja -metadata:s:a:1 title=Stereo -disposition:a:1 -default"
				metadata_a_2="-metadata:s:a:2 language=ja -metadata:s:a:2 title=Stereo -disposition:a:2 -default"
				metadata_s_0="-metadata:s:s:0 language=ger -metadata:s:s:0 title=Forced -disposition:s:0 default"
				metadata_s_1="-metadata:s:s:1 language=ger -metadata:s:s:1 title=Full -disposition:s:1 -default"
				metadata_s_2="-metadata:s:s:2 language=ger -metadata:s:s:2 title=Full -disposition:s:2 -default"
				map_files="-map 1 -map 2 -map 3"
				type_sub="-c:s:0 srt -c:s:1 srt -c:s:2 ass"
				i_files=(-i "${srt_files[0]}" -i "${srt_files[1]}" -i "${ass_files[0]}")
			fi
		fi

		# [2] Auto-Bitrate
		if [[ "$auswahl" == "2" ]]; then
			audio_count=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$filename" | wc -l)
			for ((i = 0; i < audio_count; i++)); do
				channels=$(ffprobe -v error -select_streams a:$i -show_entries stream=channels -of default=noprint_wrappers=1:nokey=1 "$filename")
				bitrate=$(ffprobe -v error -select_streams a:$i -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$filename")
				if [[ "$bitrate" == "N/A" ]]; then
					echo -e "${YELLOW}Variable Bitrate (VBR) erkannt.${RESET}"
					echo -e "${YELLOW}Spur $i – Kanäle: $channels, Bitrate: N/A"
				else
					echo -e "${YELLOW}Konstante Bitrate (CBR) erkannt.${RESET}"
					bitrate_kbps=$((bitrate / 1000))
					echo -e "${YELLOW}Spur $i – Kanäle: $channels, Bitrate: ${bitrate_kbps}k${RESET}"
				fi

				map_audio+=" -map 0:a:$i "

				if [[ "$channels" -eq 2 ]]; then
					map_audio+=("-map 0:a:$i")
					codec_audio+=("-c:a:$i" "eac3")
#					channels_audio+=("-ac:$i" "2")
					channels_audio+=("-filter:a:$i" "aformat=channel_layouts=stereo")
					title_audio+=("-metadata:s:a:$i" "title=Stereo")
					if [[ "$bitrate" == "N/A" ]]; then
						echo -e "${YELLOW}Setze Audiobitrate auf ${auto_bit_2}k.${RESET}"
						echo ""
						bitrate_audio+=("-b:a:$i" "${auto_bit_2}k")				# VBR Stereo
					elif [[ "$bitrate_kbps" -le ${auto_bit_2} ]]; then			# CBR Stereo
						echo -e "${YELLOW}Setze Audiobitrate auf ${bitrate_kbps}k.${RESET}"
						echo ""
						bitrate_audio+=("-b:a:$i" "${bitrate_kbps}k")
					else
						echo -e "${YELLOW}Setze Audiobitrate auf ${auto_bit_2}k.${RESET}"
						echo ""
						bitrate_audio+=("-b:a:$i" "${auto_bit_2}k")				# CBR Stereo
					fi
				elif [[ "$channels" -eq 6 ]]; then
					codec_audio+=("-c:a:$i" "eac3")
#					channels_audio+=("-ac:$i" "6")
					channels_audio+=("-filter:a:$i" "aformat=channel_layouts=5.1")
					title_audio+=("-metadata:s:a:$i" "title=Surround")
					if [[ "$bitrate" == "N/A" ]]; then
						echo -e "${YELLOW}Setze Audiobitrate auf ${auto_bit_6}k.${RESET}"
						echo ""
						bitrate_audio+=("-b:a:$i" "${auto_bit_6}k")				# VBR Surround
					elif [[ "$bitrate_kbps" -le ${auto_bit_6} ]]; then			# CBR Surround
						echo -e "${YELLOW}Setze Audiobitrate auf ${bitrate_kbps}k.${RESET}"
						echo ""
						bitrate_audio+=("-b:a:$i" "${bitrate_kbps}k")
					else
						echo -e "${YELLOW}Setze Audiobitrate auf ${auto_bit_6}k.${RESET}"
						echo ""
						bitrate_audio+=("-b:a:$i" "${auto_bit_6}k")				# CBR Surround
					fi
				else
					echo -e "${RED}Spur $i hat $channels Kanäle – nicht unterstützt.${RESET}"
					exit 1
				fi
			done
		fi

		# [3] Vorlagen
		if [[ "$preset" == "1" ]]; then
			echo "test1 funzt"
		elif [[ "$preset" == "2" ]]; then
			echo "test2 funzt"
		fi

		# [4] Untertitel entfernen
		if [[ "$auswahl" == "4" ]]; then
			echo ""
			echo -e "${YELLOW}Untertitel werden aus ${ORANGE}\"$filename\" ${YELLOW}entfernt.${RESET}"
			echo ""
			map_video="-map 0:v -c:v copy"
			map_audio="-map 0:a -c:a copy"
		fi

		ffmpeg 	-threads 16 \
		-i "$filename" \
		"${i_files[@]}" \
		-metadata title="$title" \
		$map_video \
		$map_audio \
		$tune_ani \
		$map_files \
		$map_sub \
		$type_sub \
		"${title_audio[@]}" \
		"${codec_audio[@]}" \
		"${channels_audio[@]}" \
		"${bitrate_audio[@]}" \
		-metadata:s:v:0 title="" \
		$metadata_a_0 \
		$metadata_a_1 \
		$metadata_a_2 \
		$metadata_s_0 \
		$metadata_s_1 \
		$metadata_s_2 \
		"$new_filename"

		# Fehlerprüfung & Pause
		echo ""
		if [ $? -ne 0 ]; then
			echo -e "\n${RED}Fehler bei der Verarbeitung von ${BOLD}\"$filename\"${YELLOW}"
			read -n 1 -s -r -p "Drücke eine beliebige Taste zum Beenden…" key
			echo "${RESET}"
			exit 1
		fi

		# EINGESPARTE MEGABYTE
		echo ""
		if [ -f "$new_filename" ]; then
			old_filesize=$(($(stat -c%s "$filename") / 1024 / 1024))
			new_filesize=$(($(stat -c%s "$new_filename") / 1024 / 1024))
			dif=$((old_filesize - new_filesize))
			eingespartemb=$((eingespartemb + dif))
			echo -e "${YELLOW}$counter. ${ORANGE}\"$title\" wurde von ${ORANGE}$old_filesize MB${YELLOW} auf ${ORANGE}$new_filesize MB${YELLOW} verkleinert (Ersparnis:${YELLOW} $dif MB${YELLOW})${RESET}"
		else
			echo -e "${RED}Fehler beim Erstellen von ${ORANGE}\"$new_filename\"${RED} – übersprungen.${RESET}"
		fi

		# SHUTDOWN
		echo "\n\n"
		if test -f "$SHUTDOWNFILE"; then
			echo -e "${YELLOW}$SHUTDOWNFILE gefunden. ${RESET}"
			echo -e "${YELLOW}Computer fährt in fünf Minuten runter.${RESET}"
			shutdown -s -t 300	# Windows
			shutdown -h +5		# Linux + Mac
		fi

		# PAUSE
		echo ""
		if test -f "$PAUSEFILE"; then
			echo -e "${YELLOW}$PAUSEFILE gefunden.${RESET}"
			echo -e "${YELLOW}Fenster schließt in Kürze automatisch${RESET}"
			sleep 3
			exit 1
		fi
	fi
done
read -p "Drücke Enter zum Beenden..."

#HILFE 1
# 		FFMPEG BEFEHLE!!!
#
#		-ss beginnt bei // -t verarbeitet nur 15 sekunden
#		-ss 00:01:00 \
#		-i "$filename" \
#		-t 00:00:15 \
#
#
#		nutzt alle 16 kerne
#		-threads 16 \
#
#		skaliert auf 720p	
#		-vf scale=-1:720 \
#
#		für animationen
#		-tune animation \
#
#		nvidia hardware acceleration
#		-hwaccel auto \
#		VOR -i PARAMETER SETZEN
#
#		irgendwas mit untertitel-dateityp, vergessen was genau
#		-c:s srt \
#
#		convertieren zu x265 mit qualität 20 und videobitrate
#		-c:v libx265 \
#		-crf 20 \
#
#		-b:v 2000k \
#		-q:v 2 \
#
#		convertieren zu AC3, 224/448 BIT, 2/6 tonspuren
#		-c:a eac3 \
#		-b:a 224k \
#		-ac 2 \
#
#		-c:a eac3 \
#		-b:a 448k \
#		-ac 6 \
#
#		wenn zwei verschiedene tonspuren, erste 2, zweite 6 kanal (klingt verwirrend ist aber anscheinend so. sollte man noch mal genau prüfen!!!)
#		-c:a eac3 \
#		-b:a 224k \
#		-ac:1 2 \
#		-c:a:1 eac3 \
#		-b:a:1 448k \
#		-ac:0 6 \
#
#		standard (default) an
#		-disposition:v:0 default \
#		-disposition:a:0 default \
#		-disposition:s:0 default \
#		standard (default) aus
#		-disposition:v:1 -default \
#		-disposition:a:1 -default \	
#		-disposition:s:1 -default \	
#
#		alle videospuren
#		map 0:v
#		nur erste videospur
#		map 0:v:0
#		nur zweite videospur
#		map 0:v:1
#
#		kopiert ohne neu zu codieren
#		-c:v copy
#		-c:a copy
#		-c:s copy
#
#		standardspur
#		default
#		-default
#
#		tauscht stream 1 mit 2
#		-map 0:a:1 -map 0:a:0 \
#		-map 0:s:1 -map 0:s:0 \
#		wähl datei 2 und 3, nicht 1 z.B. videodatei
#		-map 1 \
#		-map 2 \
#
#		für umbenennen der jeweiligen spuren
#		-metadata:s:v:0 title="" \
#
#		-metadata:s:a:0 "language=ger" \
#		-metadata:s:a:0 title="Stereo" \
#		-metadata:s:a:1 "language=ja" \
#		-metadata:s:a:1 title="Surround" \
#
#		-disposition:a:0 default \
#		-disposition:a:1 -default \
#		-metadata:s:s:0 "language=ger" \
#		-metadata:s:s:0 title="Forced" \
#		-metadata:s:s:1 title="Full" \

#HILFE 2
#		SCRIPT BEFEHLE
#
#	-lt	less than (<)
#	-le	less or equal (≤)
#	-eq	equal (=)
#	-ne	not equal (≠)
#	-gt	greater than (>)
#	-ge	greater or equal (≥)
#
#	sleep 3		wartet 3 sekunden bis es weiter geht
#	exit 1		schließt in 1 sekunde das fenster
