# Stanley/Stella

## Verwendung

Installiere das Programm und öffne einen Web-Browser.
Das Webinterface kann man unter `127.0.0.1:4000` erreichen.

## Installation

Lade die `release.tar.gz` Datei aus dem aktuellen Release herunter.

```sh
# Programm entpacken
tar xzf release.tar.gz
cd stanley_stella

# Im Vordergrund starten
./bin/stanley_stella start

# Im Hintergrund starten
./bin/stanley_stella daemon
```

## Entwicklung

### Lokal

```sh
# Interaktive Shell
iex -S mix

# Nur Programm starten
mix run --no-halt
```

Beachte bei der Entwicklung, dass die Dateien aus dem Verzeichnis `web` nur beim Kompilieren aktualisiert werden. Sie werden vom Compiler über `File.read!` eingelesen. Das hat den Vorteil, dass nicht bei jeder Anfrage eine IO-Operation ausgeführt werden muss und beim Erstellen eines Releases die Inhalte der Templates direkt in die Release-Dateien verpackt werden.

### Docker

```sh
# Container erstellen
docker build -t stanley_stella .

# Programm ausführen
docker run -p 4000:4000 --rm stanley_stella
```

## Disclaimer

I am not affiliated with Stanley and Stella SA (“Stanley/Stella”). Use this at your own risk.
