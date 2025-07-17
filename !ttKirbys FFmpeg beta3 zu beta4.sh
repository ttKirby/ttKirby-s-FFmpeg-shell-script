#!/bin/bash

# GEPLANT
#
# neuer name für auto audio/metadata/reihenfolge-sonstwas
# farben neu überdenken.
# untertitel hinzufügen ohne transkodieren
# metadata sprache automatisch erkennen und in richtige reihenfolge bringen
# ein paar Vorlagen bereitstellen
# option um tonspuir 1 und 2 zu tauschen (kann eignetlich in vorlagen)
# code optimieren, damit weniger verzweigungen/variablen sind. evtl. mal optisch darstellen (paint oder draw.io)
# noch gedanken wegen "-tune animation" machen
# die wahl einen untertitel im videofile zu wählen
# audiospuren zum bearbeiten angeben. am liebsten im skript, zur not in config datei
# resi verlinken https://github.com/resi23

# UMGESETZT (alles richtig tests steht noch aus!)
#
# neue presets mit unterordner
# nur noch auto audio, bitrate justierbar in configdatei
# confing.ini hinugefügt für die benutzerfreundlichkeit
# audiocodec selbst eintragen verfügbar per config ini
# man kann nun wählen wie viele audiospuren behandelt werden sollen
#
#BUGFIX
# optimierung des codes. weniger verzweigungen, zusammenfassung einiger codeblöcke und redundantes entfernt.
# ist nun wirklcih in der lage gezielt 1, 2 oder mehr angegebene audiospuren zu behandeln (zahl eingeben)
# bei falscher eingabe wird die abfrage noch mal gestellt anstatt das skript zu beenden
#

trap 'echo -e "\nAbbruch durch Benutzer."; exit 1' INT

## Hier deine Werte für das Transcodieren eingeben.

	# Videoqualität
	crf="20"

	# Wie viele Audiokanäle behandelt werden sollen		# nur zur Deko
	# cha_num="2"

	# Audiocodec (z.B. ac3, eac3, dts, flac)
	codec_a="eac3"

	# Audiobitrate - 2 Kanal und 6 Kanal
	bit_2="224"
	bit_6="448"
	
	# Metadata: Sprache (für Audio und Untertitel)		# nur zur Deko
	# lang_1="ger"
	# lang_2="ja"

	# Metadata: Audio									# nur zur Deko
	# title_audio1="Stereo"
	# title_audio2="Surround"

	# Metadata: Untertitel								# nur zur Deko
	# title_forced="Forced"
	# title_full="Full"

## Hauptskript

WORKINGDIR="$(pwd -W)"
echo ""
echo "$WORKINGDIR"
PAUSEFILE=pause.txt
SHUTDOWNFILE=shutdown.txt

## Zielort wählen

ordner="$(pwd)/output"
#ordner="Y:\MKVnew"

eingespartemb=0
counter=0
mkdir -p "$ordner"

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

## Wenn config.ini existiert, lade sie und evaluiere ihren Inhalt
if [[ -f "config.ini" ]]; then
    # Kommentare und leere Zeilen rausfiltern, dann eval
    eval "$(grep -v '^\s*#' config.ini | grep -v '^\s*$')"
	clear
	echo
	echo -e "${YELLOW}Konfigurationsdatei wurde geladen.${NORMAL}"
else
	clear
fi

## Startmenü anzeigen
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

## Audiospuren
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
            cha_num="alle"
        else
            cha_num="$audiochannel"
            echo -e "${YELLOW}$cha_num Audiospur(en) werden verarbeitet.${RESET}"
        fi

        break  # gültige Eingabe, Schleife verlassen
    done
fi

# Vorlagen
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
			ffmpeg_cmd=$(<"$preset_datei")
			echo -e "${YELLOW}FFmpeg-Befehl: ${RESET}$ffmpeg_cmd"

			break  # <-- Hier Schleife verlassen
		elif [[ "$preset" == "0" ]]; then
			echo -e "${RED}Abgebrochen.${RESET}"
			break  # <-- Hier auch Schleife verlassen
		else
			echo -e "${RED}Ungültige Auswahl.${RESET}"
		fi
	done
fi

## Zum Beenden des Skriptes
if [[ "$choice" == "0" || "$preset" == "0" ]]; then
	echo ""
	echo -e "${RED}Beende das Skript...${RESET}"
	sleep 1
	exit 0
fi

## Schleife für alle Videodateien im aktuellen Verzeichnis
for filename in *.mkv *.mp4 *.avi;
do
	ext="${filename##*.}"
	title=$(basename "$filename" ."$ext")
	new_filename="$ordner/${title}.mkv"
	counter=$((counter+1))

	echo -e "${ORANGE}\"$filename\" ${YELLOW}wird ausgelesen.${RESET}"
	echo ""

## SRT- und ASS-Dateien suchen
	srt_files=( "$title"*.srt )
	ass_files=( "$title"*.ass )
	for srt in "${srt_files[@]:0:2}"; do
		echo "   - $srt"
	done
	for ass in "${ass_files[@]:0:2}"; do
		echo "   - $ass"
	done

	echo ""

## FFMPEG Hauptschleife
	if [ 1 -eq 1 ]; then

		# Werte werden geleert um Fehler zu vermeiden

		# Hier handelt es sich um "Variablen" und ein "Array". Diese sind unter Transcodieren zu finden.
		map_files=""
		map_video=""
		tune_ani=""
		type_sub=""
		metadata_a_0=""
		metadata_a_1=""
		metadata_a_2=""
		metadata_s_0=""
		metadata_s_1=""
		metadata_s_2=""
		# cha_num="" # wird weiter oben schon geleert, nur zur Vervöllständigung vorrübergehend hier hier
		i_files=()

		# Hier handelt es sich um "Arrays" und eine "Variable". Diese sind unter der automatischen Erkennung und Sortierung zu finden.
		map_audio=()
		codec_a=""			# Variable, weil es zu Auto-Audio gehört
		codec_audio=()
		channels_audio=()
		title_audio=()
		bitrate_audio=()

		# Function Execution
		transcode1() {
				echo ""
				map_video="-map 0:v -c:v libx265 -crf $crf"
				if [[ "$choice" == "11" ]]; then
					tune_ani="-tune animation"
				fi
		}

## Transkodieren
		if [[ "$choice" == "1" ]]; then
			if [ ${#srt_files[@]} -eq 0 ] && [ ${#ass_files[@]} -eq 0 ]; then										# 0 SRT & 0 ASS
				echo -e "${YELLOW}Keine Untertiteldateien gefunden.${RESET}"
				transcode1
				metadata_a_0="-metadata:s:a:0 language=ger -disposition:a:0 default"
				type_sub="-c:s srt"
			elif [ ${#srt_files[@]} -eq 1 ] && [ ${#ass_files[@]} -eq 0 ]; then										# 1 SRT & 0 ASS
				echo -e "${YELLOW}Eine Untertiteldatei (1x SRT) gefunden.${RESET}"
				transcode1
				metadata_a_0="-metadata:s:a:0 language=ger -disposition:a:0 -default"
				metadata_s_0="-metadata:s:s:0 language=ger -metadata:s:s:0 title=Full -disposition:s:0 default"
				map_files="-map 1"
				type_sub="-c:s:0 srt"
				i_files=(-i "${srt_files[0]}")
			elif [ ${#srt_files[@]} -ge 2 ] && [ ${#ass_files[@]} -eq 0 ]; then										# 2 SRT & 0 ASS
				echo -e "${YELLOW}Zwei Untertiteldateien (2x SRT) gefunden.${RESET}"
				transcode1
				metadata_a_0="-metadata:s:a:0 language=ger -disposition:a:0 default"
				metadata_a_1="-metadata:s:a:1 language=ja -disposition:a:1 -default"
				metadata_s_0="-metadata:s:s:0 language=ger -metadata:s:s:0 title=Forced -disposition:s:0 default"
				metadata_s_1="-metadata:s:s:1 language=ger -metadata:s:s:1 title=Full -disposition:s:1 -default"
				map_files="-map 1 -map 2"
				type_sub="-c:s:0 srt -c:s:1 srt"
				i_files=(-i "${srt_files[0]}" -i "${srt_files[1]}")
			elif [ ${#srt_files[@]} -eq 1 ] && [ ${#ass_files[@]} -eq 1 ]; then										# 1 SRT & 1 ASS
				echo -e "${YELLOW}Zwei Untertiteldateien (1x SRT & 1x ASS) gefunden.${RESET}"
				transcode1
				metadata_a_0="-metadata:s:a:0 language=ger -disposition:a:0 default"
				metadata_a_1="-metadata:s:a:1 language=ja -disposition:a:1 -default"
				metadata_s_0="-metadata:s:s:0 language=ger -metadata:s:s:0 title=Full -disposition:s:0 default"
				metadata_s_1="-metadata:s:s:1 language=ger -metadata:s:s:1 title=Full -disposition:s:1 -default"
				map_files="-map 1 -map 2"
				type_sub="-c:s:0 srt -c:s:1 ass"
				i_files=(-i "${srt_files[0]}" -i "${ass_files[0]}")
			elif [ ${#srt_files[@]} -eq 2 ] && [ ${#ass_files[@]} -eq 1 ]; then										# 2 SRT & 1 ASS
				echo -e "${YELLOW}Drei Untertiteldateien (2x SRT & 1x ASS) gefunden.${RESET}"
				transcode1
				metadata_a_0="-metadata:s:a:0 language=ger -disposition:a:0 default"
				metadata_a_1="-metadata:s:a:1 language=ja -disposition:a:1 -default"
				metadata_a_2="-metadata:s:a:2 language=ja -disposition:a:2 -default"
				metadata_s_0="-metadata:s:s:0 language=ger -metadata:s:s:0 title=Forced -disposition:s:0 default"
				metadata_s_1="-metadata:s:s:1 language=ger -metadata:s:s:1 title=Full -disposition:s:1 -default"
				metadata_s_2="-metadata:s:s:2 language=ger -metadata:s:s:2 title=Full -disposition:s:2 -default"
				map_files="-map 1 -map 2 -map 3"
				type_sub="-c:s:0 srt -c:s:1 srt -c:s:2 ass"
				i_files=(-i "${srt_files[0]}" -i "${srt_files[1]}" -i "${ass_files[0]}")
			fi
		fi

## Auto-Reihenfolge

## Metadata und Audiobitrate
		if [[ "$choice" == "1" ]]; then
			audio_count=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$filename" | wc -l)
			if (( audiochannel > 0 )); then
				audio_count=${cha_num}
			fi

			for ((i = 0; i < audio_count; i++)); do
				lang=$(ffprobe -v error -select_streams a:$i -show_entries stream_tags=language -of default=noprint_wrappers=1:nokey=1 "$filename")
				channels=$(ffprobe -v error -select_streams a:$i -show_entries stream=channels -of default=noprint_wrappers=1:nokey=1 "$filename")
				bitrate=$(ffprobe -v error -select_streams a:$i -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$filename")
				if [[ -z "$lang" ]]; then
					lang=unbekannt
				fi
				case "$lang" in
					de|ger) lang="Deutsch" ;;
					en|eng) lang="Englisch" ;;
					ja|jpn) lang="Japanese" ;;
					unbekannt|"") lang="unbekannt" ;;
					*) lang="($lang)" ;; # falls was anderes wie z.B. "pt" => "(pt)"
				esac
				echo -e "${YELLOW}Audiospur $i: Sprache = $lang${RESET}"
				if [[ "$bitrate" == "N/A" || "$bitrate" =~ ^[0-9]+$ ]]; then
					echo -e "${YELLOW}Variable Bitrate (VBR) erkannt.${RESET}"
					echo -e "${YELLOW}Spur $i – Kanäle: $channels, Bitrate: N/A${RESET}"
				else
					echo -e "${YELLOW}Konstante Bitrate (CBR) erkannt.${RESET}"
					bitrate_kbps=$((bitrate / 1000))
					echo -e "${YELLOW}Spur $i – Kanäle: $channels, Bitrate: ${bitrate_kbps}k${RESET}"
				fi

				# Logik der Audiobitrate
				map_audio+=" -map 0:a:$i "
				codec_audio+=("-c:a:$i" "${codec_a}")
				if [[ "$channels" -eq 2 ]]; then
					channels_audio+=("-filter:a:$i" "aformat=channel_layouts=stereo")
					title_audio+=("-metadata:s:a:$i" "title=Stereo")
					if [[ "$bitrate" == "N/A" ]]; then
						echo -e "${YELLOW}Setze Audiobitrate auf ${bit_2}k.${RESET}"
						echo ""
						bitrate_audio+=("-b:a:$i" "${bit_2}k")				# VBR Stereo
					elif [[ "$bitrate_kbps" -le ${bit_2} ]]; then			# CBR Stereo
						echo -e "${YELLOW}Setze Audiobitrate auf ${bitrate_kbps}k.${RESET}"
						echo ""
						bitrate_audio+=("-b:a:$i" "${bitrate_kbps}k")
					else
						echo -e "${YELLOW}Setze Audiobitrate auf ${bit_2}k.${RESET}"
						echo ""
						bitrate_audio+=("-b:a:$i" "${bit_2}k")				# CBR Stereo
					fi
				elif [[ "$channels" -eq 6 ]]; then
					channels_audio+=("-filter:a:$i" "aformat=channel_layouts=5.1")
					title_audio+=("-metadata:s:a:$i" "title=Surround")
					if [[ "$bitrate" == "N/A" ]]; then
						echo -e "${YELLOW}Setze Audiobitrate auf ${bit_6}k.${RESET}"
						echo ""
						bitrate_audio+=("-b:a:$i" "${bit_6}k")				# VBR Surround
					elif [[ "$bitrate_kbps" -le ${bit_6} ]]; then			# CBR Surround
						echo -e "${YELLOW}Setze Audiobitrate auf ${bitrate_kbps}k.${RESET}"
						echo ""
						bitrate_audio+=("-b:a:$i" "${bitrate_kbps}k")
					else
						echo -e "${YELLOW}Setze Audiobitrate auf ${bit_6}k.${RESET}"
						echo ""
						bitrate_audio+=("-b:a:$i" "${bit_6}k")				# CBR Surround
					fi
				else
					echo -e "${RED}Spur $i hat $channels Kanäle – nicht unterstützt.${RESET}"
					exit 1
				fi
			done
		fi

## Untertitel entfernen
		if [[ "$choice" == "2" ]]; then
			echo ""
			echo -e "${YELLOW}Untertitel werden aus ${ORANGE}\"$filename\" ${YELLOW}entfernt.${RESET}"
			echo ""
			map_video="-map 0:v -c:v copy"
			map_audio="-map 0:a -c:a copy"
		fi

## FFmpeg Befehl 
		ffmpeg \
		-ss 00:03:00 \
		-i "$filename" \
		"${i_files[@]}" \
		-t 00:00:30 \
		-metadata title="$title" \
		-metadata:s:v:0 title="" \
		$map_video \
		$tune_ani \
		$map_audio \
		$map_files \
		$type_sub \
		"${title_audio[@]}" \
		"${codec_audio[@]}" \
		"${channels_audio[@]}" \
		"${bitrate_audio[@]}" \
		$metadata_a_0 \
		$metadata_a_1 \
		$metadata_a_2 \
		$metadata_s_0 \
		$metadata_s_1 \
		$metadata_s_2 \
		$ffmpeg_cmd \
		"$new_filename"


## Fehlerprüfung & Pause
		echo ""
		if [ $? -ne 0 ]; then
			echo -e "\n${RED}Fehler bei der Verarbeitung von ${BOLD}\"$filename\"${YELLOW}"
			read -n 1 -s -r -p "Drücke eine beliebige Taste zum Beenden…" key
			echo "${RESET}"
			exit 1
		fi

## EINGESPARTE MEGABYTE
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

## SHUTDOWN
		echo ""
		if test -f "$SHUTDOWNFILE"; then
			echo -e "${YELLOW}$SHUTDOWNFILE gefunden. ${RESET}"
			echo -e "${YELLOW}Computer fährt in fünf Minuten runter.${RESET}"
			shutdown -s -t 300	# Windows
			shutdown -h +5		# Linux + Mac
		fi

## PAUSE
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
#		-ss beginnt bei // -t verarbeitet nur 15 sekunden // muss vor und nach filenames
#		gut zum testen der stapelverarbeitung
#		-ss 00:01:00 \
#		-i "$filename" \
#		"${i_files[@]}" \
#		-t 00:00:15 \
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
#		nvidia hardware acceleration (sehr, sehr viel schneller aber ausgabedatei ist größer)
#		VOR -i PARAMETER SETZEN
#		-hwaccel auto \
#
#		transcodiert zu srt-untertitel
#		-c:s srt \
#
#		convertieren zu x265 mit qualität 20
#		-c:v libx265 \
#		-crf 20 \
#
#		-b:v 2000k \
#		-q:v 2 \
#
#		convertieren zu E-AC3, 224/448 BIT, 2/6 tonspuren
#		-c:a eac3 \
#		-b:a 224k \
#		-ac 2 \
#
#		-c:a eac3 \
#		-b:a 448k \
#		-ac 6 \
#
#		wenn zwei verschiedene tonspuren, erste 2, zweite 6 kanal (klingt verwirrend ist aber anscheinend so.)
#		siehe nächster abschnitt bei -filter
#		-c:a eac3 \
#		-b:a 224k \
#		-ac:1 2 \
#		-c:a:1 eac3 \
#		-b:a:1 448k \
#		-ac:0 6 \
#
#		statt -ac nutzen wenn man mehr als eine adudiospur behandelt
#		-filter:a:0 aformat=channel_layouts=stereo
#		-filter:a:0 aformat=channel_layouts=5.1
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
#		tauscht stream 1 mit 2 oder andersrum
#		-map 0:a:1 -map 0:a:0 \
#		-map 0:s:1 -map 0:s:0 \
#		wählt nicht die hauptdatei, sondern eine zweite datei. wie es oben bei srt- und ass-utnertiteln gemacht wird.
#		-map 1 \
#		-map 2 \
#
#		zum umbenennen der jeweiligen spuren
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
#	BASH BEFEHLE
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