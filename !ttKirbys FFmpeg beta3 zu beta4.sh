#!/bin/bash

trap 'echo -e "\nAbbruch durch Benutzer."; exit 1' INT

### Hier deine Werte für das Transcodieren eingeben.

	# Videoqualität
	config_crf="20"

	# Videocodec		(e.g. copy, libx264, libx265, mpeg4, rawvideo)
	config_video_codec="libx265"

	# Audiocodec		(e.g. copy, aac, ac3, eac3, flac)
	config_audio_codec="eac3"

	# Audiobitrate		(2 Kanal und 6 Kanal)
	config_audio_bitrate_stereo="224"
	config_audio_bitrate_surround="448"

### Hauptskript

WORKINGDIR="$(pwd -W)"
echo ""
echo "$WORKINGDIR"
PAUSEFILE=pause.txt
SHUTDOWNFILE=shutdown.txt

### Zielpfad

path="$(pwd)/output"
#path="Y:\MKVnew"

eingespartemb=0
counter=0
mkdir -p "$path"

shopt -s nullglob

## Farben definieren
RED="\e[31m"
ORANGE="\e[33m"
YELLOW="\e[93m"
GREEN="\e[32m"
CYAN="\e[36m"
RESET="\e[0m"
BOLD="\e[1m"		# Fettgedruckt
NORMAL="\e[22m"		# Deaktiviert Fettgedruckt

### Wenn config.ini existiert, lade sie und evaluiere ihren Inhalt
if [[ -f "config.ini" ]]; then
    # Kommentare und leere Zeilen rausfiltern, dann eval
    eval "$(grep -v '^\s*#' config.ini | grep -v '^\s*$')"
	clear
	echo
	echo -e "${YELLOW}Konfigurationsdatei wurde geladen.${NORMAL}"
else
	clear
fi

### Startmenü anzeigen
echo -e "${CYAN}${BOLD}"
echo -e "╔══════════════════════════════════════════════════════════════════════════════╗"
echo -e "║${NORMAL} Wähle Verarbeitungsweg                 ${BOLD}║"
echo -e "║${NORMAL} Für Animationen Zahl doppelt tippen    ${BOLD}║"
echo -e "╠════════════════════════════════════════╣"
echo -e "║${NORMAL}${YELLOW} 1) Transkodieren mit Auto-Audio        ${BOLD}${CYAN}║"
echo -e "║${NORMAL}${YELLOW} 2) Untertitel entfernen                ${BOLD}${CYAN}║"
echo -e "║${NORMAL}${YELLOW} 3) Vorlagen anwenden                   ${BOLD}${CYAN}║"
echo -e "║${NORMAL}${YELLOW} 0)${RED} Beenden  (STRG+C)                   ${BOLD}${CYAN}║"
echo -e "╚════════════════════════════════════════╝${RESET}"
echo ""
while true; do
	echo -e "${YELLOW}"
	read -p "Deine Wahl (0/1/2/3/11): " choice
	echo -e "${RESET}"

    if [[ "$choice" =~ ^(0|1|2|3|11)$ ]]; then
        break	# Gültige Eingabe, Schleife verlassen
    else
        echo -e "${RED}Ungültige Auswahl! Bitte 0, 1, 2, 3 oder 11 wählen.${RESET}"
        sleep 1	# Schleife wiederholt die Abfrage automatisch
    fi
done

### Audiospuren
if [[ "$choice" == "1" || "$choice" == "11" ]]; then
    echo -e "${CYAN}${BOLD}"
    echo -e "╔════════════════════════════════════════╗"
    echo -e "║${NORMAL} Wie viele Audiospuren?                 ${BOLD}║"
    echo -e "║${NORMAL} Gib eine Zahl ein (0 = alle Spuren)    ${BOLD}║"
    echo -e "╚════════════════════════════════════════╝${RESET}"
    echo -e ""

    while true; do
        echo -e "${YELLOW}"
        read -p "Deine Eingabe (Zahl): " audiochannel
        echo -e "${RESET}"

        # Nur ganze Zahlen erlauben
        if ! [[ "$audiochannel" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Ungültige Eingabe! Bitte eine ganze Zahl eingeben.${RESET}"
            sleep 1
            continue  # Eingabe erneut abfragen
        fi
		
        # 0 = alle Spuren, sonst wird cha_num gesetzt
		cha_num=""
        if [[ "$audiochannel" -eq 0 ]]; then
            echo -e "${YELLOW}Alle Audiospuren werden verarbeitet.${RESET}"
            cha_num="0"
        else
            cha_num="$audiochannel"
            echo -e "${YELLOW}$cha_num Audiospur(en) werden verarbeitet.${RESET}"
        fi

        break  # gültige Eingabe, Schleife verlassen
    done
fi

### Vorlagen
if [[ "$choice" == "3" ]]; then
    echo -e "${CYAN}${BOLD}"
    echo -e "╔════════════════════════════════════════╗"
    echo -e "║${NORMAL} Welches Preset möchtest du verwenden?  ${BOLD}║"
    echo -e "╠════════════════════════════════════════╣"

    # Presets sammeln
    preset_files=()
    index=1
    for file in presets/*.txt; do
        filename=$(basename "$file" .txt)
        preset_files+=("$file")
        printf "║${NORMAL}${YELLOW} %02d) %-34s ${BOLD}${CYAN}║\n" "$index" "$filename"
        index=$((index + 1))
    done

    echo -e "║${NORMAL}${YELLOW}  0)${RED} Beenden  (STRG+C)                  ${BOLD}${CYAN}║"
    echo -e "╚════════════════════════════════════════╝${RESET}"
    echo -e ""
	while true; do
		echo -e "${YELLOW}"
		read -p "Deine Wahl (Nummer): " preset
		echo -e "${RESET}"

		# Auswahl prüfen
		if [[ "$preset" =~ ^[0-9]+$ ]] && (( preset > 0 && preset <= ${#preset_files[@]} )); then
			preset_datei="${preset_files[$((preset - 1))]}"
			echo -e "${CYAN}Du hast gewählt: ${BOLD}$(basename "$preset_datei")${RESET}"
			echo ""
			# FFmpeg-Befehl aus Datei laden
			ff_preset=$(<"$preset_datei")
			echo -e "${YELLOW}FFmpeg-Befehl: ${RESET}$ff_preset"

			break  # <-- Hier Schleife verlassen
		elif [[ "$preset" == "0" ]]; then
			echo -e "${RED}Abgebrochen.${RESET}"
			break  # <-- Hier auch Schleife verlassen
		else
			echo -e "${RED}Ungültige Auswahl.${RESET}"
		fi
	done
fi

### Zum Beenden des Skriptes
if [[ "$choice" == "0" || "$preset" == "0" ]]; then
	echo ""
	echo -e "${RED}Beende das Skript...${RESET}"
	sleep 1
	exit 0
fi

### Hauptschleife für alle Videodateien im aktuellen Verzeichnis
for filename in *.mkv *.mp4 *.avi;
do
	ext="${filename##*.}"
	title=$(basename "$filename" ."$ext")
	new_filename="$path/${title}.mkv"
	counter=$((counter+1))

	echo -e "${ORANGE}\"$filename\" ${YELLOW}wird ausgelesen.${RESET}"
	echo ""

### SRT- und ASS-Dateien suchen
	srt_files=( "$title"*.srt )
	ass_files=( "$title"*.ass )
	for srt in "${srt_files[@]:0:2}"; do
		echo "   - $srt"
	done
	for ass in "${ass_files[@]:0:2}"; do
		echo "   - $ass"
	done

	echo ""

### FFmpeg Hauptschleife
### Initialisierung & Typdefinition:
	##  Hier werden die Werte der persönlichen Konfiguration geleert um gravierende Fehler zu vermeiden.
		config_crf=""
		config_audio_codec=""
		config_audio_bitrate_stereo=""
		config_audio_bitrate_surround=""

	## Transkodierung
		# Hier werden Variablen und ein Array eindeutig deklariert, damit sie korrekt verarbeitet werden können.
		declare ff_map_files=""
		declare ff_map_video=""
		declare ff_tune_animation=""
		declare ff_map_subtitle_type=""
		declare ff_audio_metadata_0=""
		declare ff_audio_metadata_1=""
		declare ff_audio_metadata_2=""
		declare ff_subtitle_metadata_0=""
		declare ff_subtitle_metadata_1=""
		declare ff_subtitle_metadata_2=""
		declare -a ff_map_input_subtitle=()

		# Hier werden Werte geleert um krittische Fehler zu vermeiden
		ff_map_files=""
		ff_map_video=""
		ff_tune_animation=""
		ff_map_subtitle_type=""
		ff_audio_metadata_0=""
		ff_audio_metadata_1=""
		ff_audio_metadata_2=""
		ff_subtitle_metadata_0=""
		ff_subtitle_metadata_1=""
		ff_subtitle_metadata_2=""
		ff_map_input_subtitle=()

	## Automatische Zuordnung
		# Hier werden assoziatives Arrays und Arrays eindeutig deklariert, damit sie korrekt verarbeitet werden können.
		declare -A track_language
		declare -A language_to_index
		declare -A default_language
		declare -a sorted_indices

		declare -a ff_map_audio
		declare -a ff_audio_codec
		declare -a ff_audio_channel
		declare -a ff_audio_metadata_title
		declare -a ff_audio_bitrate

		# Hier haben wir einen String und einen Integer zur vervollständigung.
		declare lang_a channels_a bitrate_a
		declare -i bitrate_a_kbps

		# Hier werden Werte geleert um krittische Fehler zu vermeiden
		ff_map_audio=()
		ff_audio_codec=()
		ff_audio_channel=()
		ff_audio_metadata_title=()
		ff_audio_bitrate=()
		sorted_indices=()

	## Function Execution
		prepare_ff_video_01() {
				echo ""
				ff_map_video="-map 0:v -c:v $config_video_codec -crf $config_crf"
				if [[ "$choice" == "11" ]]; then
					ff_tune_animation="-tune animation"
				fi
		}

### Transkodieren
	if [[ "$choice" == "1" || "$choice" == "11" ]]; then
		if [ ${#srt_files[@]} -eq 0 ] && [ ${#ass_files[@]} -eq 0 ]; then										# 0 SRT & 0 ASS
			echo -e "${YELLOW}Keine Untertiteldateien gefunden.${RESET}"
			prepare_ff_video_01
			ff_audio_metadata_0="-metadata:s:a:0 language=ger -disposition:a:0 default"
			ff_map_subtitle_type="-c:s srt"
		elif [ ${#srt_files[@]} -eq 1 ] && [ ${#ass_files[@]} -eq 0 ]; then										# 1 SRT & 0 ASS
			echo -e "${YELLOW}Eine Untertiteldatei (1x SRT) gefunden.${RESET}"
			prepare_ff_video_01
			ff_audio_metadata_0="-metadata:s:a:0 language=ger -disposition:a:0 -default"
			ff_subtitle_metadata_0="-metadata:s:s:0 language=ger -metadata:s:s:0 title=Full -disposition:s:0 default"
			ff_map_files="-map 1"
			ff_map_subtitle_type="-c:s:0 srt"
			ff_map_input_subtitle=(-i "${srt_files[0]}")
		elif [ ${#srt_files[@]} -ge 2 ] && [ ${#ass_files[@]} -eq 0 ]; then										# 2 SRT & 0 ASS
			echo -e "${YELLOW}Zwei Untertiteldateien (2x SRT) gefunden.${RESET}"
			prepare_ff_video_01
			ff_audio_metadata_0="-metadata:s:a:0 language=ger -disposition:a:0 default"
			ff_audio_metadata_1="-metadata:s:a:1 language=ja -disposition:a:1 -default"
			ff_subtitle_metadata_0="-metadata:s:s:0 language=ger -metadata:s:s:0 title=Forced -disposition:s:0 default"
			ff_subtitle_metadata_1="-metadata:s:s:1 language=ger -metadata:s:s:1 title=Full -disposition:s:1 -default"
			ff_map_files="-map 1 -map 2"
			ff_map_subtitle_type="-c:s:0 srt -c:s:1 srt"
			ff_map_input_subtitle=(-i "${srt_files[0]}" -i "${srt_files[1]}")
		elif [ ${#srt_files[@]} -eq 1 ] && [ ${#ass_files[@]} -eq 1 ]; then										# 1 SRT & 1 ASS
			echo -e "${YELLOW}Zwei Untertiteldateien (1x SRT & 1x ASS) gefunden.${RESET}"
			prepare_ff_video_01
			ff_audio_metadata_0="-metadata:s:a:0 language=ger -disposition:a:0 default"
			ff_audio_metadata_1="-metadata:s:a:1 language=ja -disposition:a:1 -default"
			ff_subtitle_metadata_0="-metadata:s:s:0 language=ger -metadata:s:s:0 title=Full -disposition:s:0 default"
			ff_subtitle_metadata_1="-metadata:s:s:1 language=ger -metadata:s:s:1 title=Full -disposition:s:1 -default"
			ff_map_files="-map 1 -map 2"
			ff_map_subtitle_type="-c:s:0 srt -c:s:1 ass"
			ff_map_input_subtitle=(-i "${srt_files[0]}" -i "${ass_files[0]}")
		elif [ ${#srt_files[@]} -eq 2 ] && [ ${#ass_files[@]} -eq 1 ]; then										# 2 SRT & 1 ASS
			echo -e "${YELLOW}Drei Untertiteldateien (2x SRT & 1x ASS) gefunden.${RESET}"
			prepare_ff_video_01
			ff_audio_metadata_0="-metadata:s:a:0 language=ger -disposition:a:0 default"
			ff_audio_metadata_1="-metadata:s:a:1 language=ja -disposition:a:1 -default"
			ff_audio_metadata_2="-metadata:s:a:2 language=ja -disposition:a:2 -default"
			ff_subtitle_metadata_0="-metadata:s:s:0 language=ger -metadata:s:s:0 title=Forced -disposition:s:0 default"
			ff_subtitle_metadata_1="-metadata:s:s:1 language=ger -metadata:s:s:1 title=Full -disposition:s:1 -default"
			ff_subtitle_metadata_2="-metadata:s:s:2 language=ger -metadata:s:s:2 title=Full -disposition:s:2 -default"
			ff_map_files="-map 1 -map 2 -map 3"
			ff_map_subtitle_type="-c:s:0 srt -c:s:1 srt -c:s:2 ass"
			ff_map_input_subtitle=(-i "${srt_files[0]}" -i "${srt_files[1]}" -i "${ass_files[0]}")
		fi
	fi

### Auto-Reihenfolge

	if [[ "$choice" == "1" || "$choice" == "11" ]]; then
		audio_count=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$filename" | wc -l)
		if (( audiochannel > 0 )); then
			audio_count=${cha_num}
		fi

		for ((i = 0; i < audio_count; i++)); do
			lang_a=$(ffprobe -v error -select_streams a:$i -show_entries stream_tags=language -of default=noprint_wrappers=1:nokey=1 "$filename")
			channels_a=$(ffprobe -v error -select_streams a:$i -show_entries stream=channels -of default=noprint_wrappers=1:nokey=1 "$filename")
			bitrate_a=$(ffprobe -v error -select_streams a:$i -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$filename")
			if [[ -z "$lang_a" ]]; then
				lang_a=unbekannt
			fi
			case "$lang_a" in
				de|ger) lang_a="Deutsch" ;;
				ja|jpn) lang_a="Japanisch" ;;
				en|eng) lang_a="Englisch" ;;
				unbekannt|"") lang_a="unbekannt" ;;
				*) lang_a="($lang_a)" ;; # falls was anderes wie z.B. "pt" => "(pt)"
			esac
			echo -e "${YELLOW}Audiospur $i: Sprache = $lang_a${RESET}"
			if [[ "$bitrate_a" == "N/A" || "$bitrate_a" =~ ^[0-9]+$ ]]; then
				echo -e "${YELLOW}Variable Bitrate (VBR) erkannt.${RESET}"
				echo -e "${YELLOW}Spur $i – Kanäle: $channels_a, Bitrate: N/A${RESET}"
			else
				echo -e "${YELLOW}Konstante Bitrate (CBR) erkannt.${RESET}"
				bitrate_a_kbps=$((bitrate_a / 1000))
				echo -e "${YELLOW}Spur $i – Kanäle: $channels_a, Bitrate: ${bitrate_a_kbps}k${RESET}"
			fi

			# Logik der Spracherkennung

			# Logik der Audiobitraten- und Audiokanalerkennung
			ff_map_audio+=" -map 0:a:$i "
			ff_audio_codec+=("-c:a:$i" "${config_audio_codec}")
			if [[ "$channels_a" -eq 2 ]]; then
				ff_audio_channel+=("-filter:a:$i" "aformat=channel_layouts=stereo")
				ff_audio_metadata_title+=("-metadata:s:a:$i" "title=Stereo")
				if [[ "$bitrate_a" == "N/A" ]]; then
					echo -e "${YELLOW}Setze Audiobitrate auf ${config_audio_bitrate_stereo}k.${RESET}"
					echo ""
					ff_audio_bitrate+=("-b:a:$i" "${config_audio_bitrate_stereo}k")				# VBR Stereo
				elif [[ "$bitrate_a_kbps" -le ${config_audio_bitrate_stereo} ]]; then			# CBR Stereo
					echo -e "${YELLOW}Setze Audiobitrate auf ${bitrate_a_kbps}k.${RESET}"
					echo ""
					ff_audio_bitrate+=("-b:a:$i" "${bitrate_a_kbps}k")
				else
					echo -e "${YELLOW}Setze Audiobitrate auf ${config_audio_bitrate_stereo}k.${RESET}"
					echo ""
					ff_audio_bitrate+=("-b:a:$i" "${config_audio_bitrate_stereo}k")				# CBR Stereo
				fi
			elif [[ "$channels_a" -eq 6 ]]; then
				ff_audio_channel+=("-filter:a:$i" "aformat=channel_layouts=5.1")
				ff_audio_metadata_title+=("-metadata:s:a:$i" "title=Surround")
				if [[ "$bitrate_a" == "N/A" ]]; then
					echo -e "${YELLOW}Setze Audiobitrate auf ${config_audio_bitrate_surround}k.${RESET}"
					echo ""
					ff_audio_bitrate+=("-b:a:$i" "${config_audio_bitrate_surround}k")				# VBR Surround
				elif [[ "$bitrate_a_kbps" -le ${config_audio_bitrate_surround} ]]; then			# CBR Surround
					echo -e "${YELLOW}Setze Audiobitrate auf ${bitrate_a_kbps}k.${RESET}"
					echo ""
					ff_audio_bitrate+=("-b:a:$i" "${bitrate_a_kbps}k")
				else
					echo -e "${YELLOW}Setze Audiobitrate auf ${config_audio_bitrate_surround}k.${RESET}"
					echo ""
					ff_audio_bitrate+=("-b:a:$i" "${config_audio_bitrate_surround}k")				# CBR Surround
				fi
			else
				echo -e "${RED}Spur $i hat $channels_a Kanäle – nicht unterstützt.${RESET}"
				exit 1
			fi
		done
	fi

### Untertitel entfernen
	if [[ "$choice" == "2" ]]; then
		echo ""
		echo -e "${YELLOW}Untertitel werden aus ${ORANGE}\"$filename\" ${YELLOW}entfernt.${RESET}"
		echo ""
		ff_map_video="-map 0:v -c:v copy"
		ff_map_audio="-map 0:a -c:a copy"
	fi

### FFmpeg Befehl 
	ffmpeg \
	-ss 00:03:00 \
	-i "$filename" \
	"${ff_map_input_subtitle[@]}" \
	-t 00:00:15 \
	-metadata title="$title" \
	-metadata:s:v:0 title="" \
	$ff_map_video \
	$ff_tune_animation \
	$ff_map_audio \
	"${ff_audio_codec[@]}" \
	"${ff_audio_bitrate[@]}" \
	"${ff_audio_channel[@]}" \
	"${ff_audio_metadata_title[@]}" \
	$ff_map_subtitle_type \
	$ff_map_files \
	$ff_audio_metadata_0 \
	$ff_audio_metadata_1 \
	$ff_audio_metadata_2 \
	$ff_subtitle_metadata_0 \
	$ff_subtitle_metadata_1 \
	$ff_subtitle_metadata_2 \
	$ff_preset \
	"$new_filename"


### Fehlerprüfung & Pause
	echo ""
	if [ $? -ne 0 ]; then
		echo -e "\n${RED}Fehler bei der Verarbeitung von ${BOLD}\"$filename\"${YELLOW}"
		read -n 1 -s -r -p "Drücke eine beliebige Taste zum Beenden…" key
		echo "${RESET}"
		exit 1
	fi

### EINGESPARTE MEGABYTE
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

### SHUTDOWN
	echo ""
	if test -f "$SHUTDOWNFILE"; then
		echo -e "${YELLOW}$SHUTDOWNFILE gefunden. ${RESET}"
		echo -e "${YELLOW}Computer fährt in fünf Minuten runter.${RESET}"
		shutdown -s -t 300	# Windows
		shutdown -h +5		# Linux + Mac
	fi

### PAUSE
	echo ""
	if test -f "$PAUSEFILE"; then
		echo -e "${YELLOW}$PAUSEFILE gefunden.${RESET}"
		echo -e "${YELLOW}Fenster schließt in Kürze automatisch${RESET}"
		sleep 3
		exit 1
	fi
done
read -p "Drücke Enter zum Beenden..."
