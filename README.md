# ttKirbys-FFmpeg-Shell-Script

Hier ein einfaches Shell-Skript zur Stapelverarbeitung von Videodateien mit FFmpeg.
Das Skript durchsucht den aktuellen Ordner nach `.mkv`, `.mp4` und `.avi`-Dateien und bietet ein paar Funktionen zum Behandeln von Untertitel-Dateien.
Es arbeitet mit ein paar Variablen und Arrays, listet alle Videos im Ordner auf und fragt dann, was damit passieren soll.
Ich habe nicht viel erfahrung im schreiben von Skripten, aber ich hoffe hier findet sich der ein oder andere der einen Nutzen darin findet.

## Funktionen

- Videos in einem Ordner automatisch verarbeiten
- Unterstützung für externe Untertiteldateien (`.srt` und `.ass`)
- Erkennt automatisch Audiostreams in Videodateien. Wendet passende Voreinstellungen basierend auf Anzahl und Eigenschaften der Audiotracks an (z. B. Stereo vs. Mehrkanal, einzelne vs. mehrere Spuren)
- Einfache Vorlagen für bestimmte FFmpeg-Konfigurationen
- Möglichkeit zum Entfernen von Untertiteln
- Viele Kommentare und Echos im Skript, die erklären wo was passiert, zum besseren nachzuvollziehen und gegebenfalls zur Ergänzung eigener Werte.

## Verwendung

Wenn umgebungsvariablen unter Windows gesetzt wurden, einfach doppepklick zum ausführen. 
Das Skript zeigt dir in einem Menu eine Auswahl an Optionen im Terminal an.

## Funktionsweise

[1] Transkodieren
- Artbeitet mit festgelegten Werten für Video, Audio und Untertitel.
- Diese solltest du auch bei Bedarf für dich selbst anpassen!

[2] Transkodieren mit Auto-Audio
- Arbeitet mit festgelegten Werten für Video und Untertitel. Erkennt Audiokkanäle und -bitrate durch FFprobe und reagiert mit vordefinierten Werten.
- z.B. 2 Kanal = 224k und 6 Kanal = 448k
- Diese solltest du auch bei Bedarf für dich selbst anpassen!

[3] Vorlagen anwenden
- Verwendet Vordefinierte Vorlagen für Spezielle Anwendungsfälle

[4] Untertitel entfernen
- Entfern stumpf alle Untertitel, Video und Audio wird kopiert und Metadaten werden nicht angefasst.

[5] Beenden  (STRG+C)
- Beendet das Skript. Man kann auch jederzeit und überall STRG+C drücken um das Skript zu beendet.


## Anpassung 

Das Skript muss im gleichen Ordner liegen wie die zu bearbeitenden Videos.  
Untertiteldateien müssen den gleichen Namen wie das Video inne haben.

[1] Transcodieren
- CRF, Bitrate und Metadaten werden im Skript ganz oben angepasst.
- Die Reihenfolge der Untertitel ist in der Variable i_files geregelt: ""i_files=(-i "${srt_files[0]}" -i "${srt_files[1]}" -i "${ass_files[0]}")""
- Empfohlene Struktur und Benennung ist:

```
/MyFolder
  ├── !FFMPEG beta1.sh
  ├── video1.mkv
  ├── video1.FORCED.srt
  ├── video1.FULL.srt
  ├── video1.FULL.ass
```

[2] Transcodieren mit Audo-Audio
- Das gleiche wie bei [1] nur, das man Audio hier anpassen kann:
	auto_bit_2="224k"
	auto_bit_6="448k"
[3] 
- ...

## Voraussetzungen, Empfehlungen und Anmerkungen

- FFmpeg muss installiert sein. Umgebungsvariablen müssen eventuell gesetzt werden.
- Git (https://git-scm.com/downloads)
- Zur Bearbeitung unter Windows empfehle ich: https://notepad-plus-plus.org/downloads/
- Funktioniert theoretisch auch unter Linux und Mac, praktisch habe ich es nur unter Windows getestet!

## Lizenz

MIT – frei verwendbar, veränderbar und teilbar.
