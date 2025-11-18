# Instalator Pakietu .pkg

## 📦 Opis

Ten katalog zawiera narzędzia do budowania profesjonalnego instalatora pakietu `.pkg` dla macOS, który automatycznie poprosi użytkownika o uprawnienia administratora.

## 🏗️ Struktura

```
pkg/
├── build.sh              # Skrypt budujący pakiet
├── Distribution.xml      # Definicja pakietu instalacyjnego
├── welcome.html          # Strona powitalna instalatora
├── conclusion.html       # Strona końcowa instalatora
├── scripts/
│   ├── preinstall        # Skrypt wykonywany przed instalacją
│   └── postinstall       # Skrypt wykonywany po instalacji
├── build/                # Katalog roboczy (tworzony automatycznie)
└── dist/                 # Gotowy pakiet (tworzony automatycznie)
```

## 🚀 Budowanie Pakietu

### ⚠️ WAŻNE: Wymagania Systemowe

**Ten skrypt MUSI być uruchomiony na macOS!**

Narzędzia `pkgbuild` i `productbuild` są dostępne tylko na macOS.

### Wymagania

- **macOS** (dowolna wersja) - **WYMAGANE!**
- Xcode Command Line Tools
  ```bash
  xcode-select --install
  ```

### Krok 1: Przygotowanie

```bash
cd red_team/pkg
chmod +x build.sh scripts/preinstall scripts/postinstall
```

### Krok 2: Budowanie

```bash
# Metoda 1: Bezpośrednie uruchomienie
./build.sh

# Metoda 2: Jeśli powyższe nie działa
bash build.sh
```

**Jeśli jesteś na Windows:** Zobacz `BUILD_INSTRUCTIONS.md` dla alternatywnych metod.

Skrypt:
1. Przygotuje strukturę katalogów
2. Skopiuje pliki do payload
3. Zbuduje komponent pakietu (.pkg)
4. Utworzy finalny instalator z interfejsem graficznym
5. Zapisze pakiet w katalogu `dist/`

### Krok 3: Instalacja

Gotowy pakiet będzie w katalogu `dist/`:

```bash
# Otwórz pakiet w Finder
open dist/Micros0ft_System_Update.pkg

# Lub zainstaluj z terminala
sudo installer -pkg dist/Micros0ft_System_Update.pkg -target /
```

## 📋 Co Zawiera Pakiet

Pakiet instaluje:

1. **Launch Agent** (`com.bugbusters.malicious.plist`)
   - Lokalizacja: `/Library/LaunchAgents/`
   - Uruchamia się automatycznie przy starcie systemu

2. **Skrypt Agenta** (`malicious_agent.sh`)
   - Lokalizacja: `/Users/Shared/Micros0ft/`
   - Wykonuje złośliwe działania w tle

3. **Katalogi Danych**
   - Lokalizacja: `/Users/Shared/Micros0ft/data/`
   - Przechowuje zebrane dane i logi

## 🔧 Skrypty Instalacyjne

### preinstall
- Wykonywany **przed** instalacją plików
- Zatrzymuje istniejącego agenta (jeśli istnieje)
- Usuwa stare pliki

### postinstall
- Wykonywany **po** instalacji plików
- Ustawia uprawnienia
- Ładuje i uruchamia Launch Agent
- Tworzy katalogi na dane

## 🎨 Interfejs Graficzny

Instalator zawiera:

- **Strona powitalna** (`welcome.html`)
  - Opis instalacji
  - Informacje o wymaganych uprawnieniach

- **Strona końcowa** (`conclusion.html`)
  - Potwierdzenie zakończenia instalacji
  - Informacje o następnych krokach

## ⚙️ Konfiguracja

### Zmiana Nazwy Pakietu

Edytuj `build.sh`:
```bash
FINAL_PKG_NAME="Twoja_Nazwa.pkg"
```

### Zmiana Tekstów

Edytuj pliki HTML:
- `welcome.html` - strona powitalna
- `conclusion.html` - strona końcowa

### Zmiana Wersji

Edytuj `build.sh`:
```bash
VERSION="1.0"
```

I `Distribution.xml`:
```xml
<pkg-ref id="com.bugbusters.malicious" version="1.0" ...>
```

## 🔐 Podpisywanie Pakietu

Aby podpisać pakiet (opcjonalne, dla produkcji):

1. Uzyskaj certyfikat "Developer ID Installer" z Apple Developer
2. Skrypt automatycznie spróbuje podpisać pakiet
3. Jeśli certyfikat nie jest dostępny, pakiet zostanie utworzony bez podpisu

**Uwaga:** Niepodpisane pakiety mogą wyświetlać ostrzeżenia w macOS.

## 🧪 Testowanie

### Test na Maszynie Wirtualnej

1. Zbuduj pakiet na głównej maszynie
2. Skopiuj pakiet do maszyny wirtualnej
3. Zainstaluj pakiet
4. Zweryfikuj instalację:
   ```bash
   launchctl list | grep bugbusters
   ls -la /Users/Shared/Micros0ft/
   ```

### Weryfikacja Instalacji

```bash
# Sprawdź czy agent jest aktywny
launchctl list | grep bugbusters

# Sprawdź pliki
ls -la /Library/LaunchAgents/com.bugbusters.malicious.plist
ls -la /Users/Shared/Micros0ft/

# Sprawdź logi
tail -f /Users/Shared/Micros0ft/agent.log
```

## 🗑️ Odinstalowanie

Aby odinstalować pakiet:

```bash
# Zatrzymaj agenta
sudo launchctl unload /Library/LaunchAgents/com.bugbusters.malicious.plist

# Usuń pliki
sudo rm /Library/LaunchAgents/com.bugbusters.malicious.plist
sudo rm -rf /Users/Shared/Micros0ft
```

Lub użyj narzędzia blue team:
```bash
cd ../../blue_team
sudo ./defender.sh
```

## ⚠️ Ostrzeżenia

1. **Używaj tylko na własnym sprzęcie** - To narzędzie jest tylko do celów edukacyjnych
2. **Nie podpisuj złośliwych pakietów** - Używanie certyfikatów do podpisywania złośliwego oprogramowania jest nielegalne
3. **Testuj na maszynach wirtualnych** - Zalecane środowisko testowe
4. **Usuwaj po testach** - Zawsze usuwaj zainstalowane komponenty po zakończeniu testów

## 🐛 Rozwiązywanie Problemów

### Problem: "pkgbuild: command not found"

```bash
# Zainstaluj Xcode Command Line Tools
xcode-select --install
```

### Problem: Pakiet nie instaluje się

- Sprawdź uprawnienia użytkownika
- Sprawdź logi instalatora: `sudo installer -pkg pakiet.pkg -target / -verbose`
- Upewnij się, że skrypty mają uprawnienia do wykonania

### Problem: Agent się nie uruchamia

```bash
# Sprawdź logi błędów
cat /Users/Shared/Micros0ft/agent_error.log

# Sprawdź uprawnienia
ls -la /Users/Shared/Micros0ft/malicious_agent.sh

# Sprawdź status Launch Agent
launchctl list | grep bugbusters
launchctl print system/com.bugbusters.malicious
```

## 📚 Dodatkowe Zasoby

- [Apple Developer - Creating Installer Packages](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/SoftwareDistribution/Introduction/Introduction.html)
- [pkgbuild man page](https://developer.apple.com/library/archive/documentation/Darwin/Reference/ManPages/man1/pkgbuild.1.html)
- [productbuild man page](https://developer.apple.com/library/archive/documentation/Darwin/Reference/ManPages/man1/productbuild.1.html)

---

**Pamiętaj:** To narzędzie jest tylko do celów edukacyjnych. Używaj odpowiedzialnie!

