# FFmpeg-Shell-Skript

Ein einfaches Shell-Skript zur Stapelverarbeitung von Videodateien mit FFmpeg.  
Das Skript durchsucht den aktuellen Ordner nach `.mkv`, `.mp4` und `.avi`-Dateien und bietet grundlegende Funktionen zur Umwandlung und Behandlung von Untertiteln.


## Funktionen

- Videos in einem Ordner automatisch verarbeiten
- Unterstützung für externe Untertiteldateien (`.srt`, `.ass`)
- Erkennt automatisch Audiostreams in Videodateien. Wendet passende Voreinstellungen basierend auf Anzahl und Eigenschaften der Audiotracks an (z. B. Stereo vs. Mehrkanal, einzelne vs. mehrere Spuren)
- Möglichkeit zum Entfernen von Untertiteln
- Einfache Vorlagen für bestimmte FFmpeg-Konfigurationen
- Viele Kommentare und Echos im Skript, die Schritt für Schritt erklären, was wo passiert und wie die einzelnen Funktionen arbeiten.

## Funktionsweise

Das Skript arbeitet mit ein paar Variablen und Arrays, listet alle Videos im Ordner auf und fragt dann, was damit passieren soll.

### Unterstützte Videoformate

- `.mkv`
- `.mp4`
- `.avi`

## Voraussetzungen

- FFmpeg muss installiert und im Terminal/Commandline aufrufbar sein (Umgebungsvariablen müssen eventuell gesetzt werden)
- Git (https://git-scm.com/downloads)

## Verwendung

Das Skript zeigt dir eine Auswahl an Optionen im Terminal.

## Ordnerstruktur

Das Skript muss im gleichen Ordner liegen wie die zu bearbeitenden Videos.  
Untertiteldateien sollten den gleichen Namen wie das Video haben.

```
/MyFolder
  ├── video1.mkv
  ├── video1.FORCED.srt
  ├── video1.FULL.srt
  ├── video1.FULL.ass
  ├── !FFMPEG beta1.sh
```

## Lizenz

MIT – frei verwendbar, veränderbar und teilbar.
