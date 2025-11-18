# Instrukcje Budowania Pakietu .pkg

## ⚠️ Ważne: Wymagania Systemowe

**Ten skrypt MUSI być uruchomiony na macOS!**

Narzędzia `pkgbuild` i `productbuild` są dostępne tylko na macOS jako część Xcode Command Line Tools.

## 🍎 Na macOS

### Metoda 1: Bezpośrednie Uruchomienie

```bash
cd red_team/pkg
chmod +x build.sh scripts/preinstall scripts/postinstall
./build.sh
```

### Metoda 2: Z Wykorzystaniem Bash

Jeśli `./build.sh` nie działa, spróbuj:

```bash
cd red_team/pkg
bash build.sh
```

### Metoda 3: Z Pełną Ścieżką

```bash
bash /ścieżka/do/projektu/red_team/pkg/build.sh
```

## 🪟 Na Windows

### Opcja 1: Maszyna Wirtualna macOS (Zalecane)

1. Zainstaluj maszynę wirtualną z macOS (VMware, VirtualBox, Parallels)
2. Skopiuj projekt do maszyny wirtualnej
3. Uruchom `build.sh` na macOS

### Opcja 2: WSL2 + macOS (Zaawansowane)

WSL2 nie obsługuje macOS natywnie, ale możesz:
1. Użyć maszyny wirtualnej z macOS w WSL2
2. Lub przenieść pliki na fizyczny Mac

### Opcja 3: Przygotowanie Plików na Windows, Budowanie na macOS

Możesz przygotować wszystkie pliki na Windows, a następnie:

1. Skopiuj katalog `red_team/pkg/` na macOS (przez USB, sieć, Git, etc.)
2. Na macOS uruchom:
   ```bash
   cd red_team/pkg
   chmod +x build.sh scripts/preinstall scripts/postinstall
   ./build.sh
   ```

## 🔧 Rozwiązywanie Problemów

### Problem: "command not found: ./build.sh"

**Przyczyna:** Skrypt nie ma uprawnień do wykonania lub jest uruchamiany na niewłaściwym systemie.

**Rozwiązanie:**
```bash
# Sprawdź uprawnienia
ls -la build.sh

# Nadaj uprawnienia
chmod +x build.sh

# Uruchom z bash
bash build.sh
```

### Problem: "pkgbuild: command not found"

**Przyczyna:** Brak Xcode Command Line Tools.

**Rozwiązanie:**
```bash
# Zainstaluj Xcode Command Line Tools
xcode-select --install

# Sprawdź instalację
pkgbuild --version
```

### Problem: "No such file or directory"

**Przyczyna:** Problem z końcami linii (CRLF vs LF) - częsty problem przy kopiowaniu z Windows.

**Rozwiązanie:**
```bash
# Konwertuj końce linii (na macOS)
dos2unix build.sh scripts/preinstall scripts/postinstall

# Lub użyj sed
sed -i '' 's/\r$//' build.sh
sed -i '' 's/\r$//' scripts/preinstall
sed -i '' 's/\r$//' scripts/postinstall
```

### Problem: "Permission denied"

**Przyczyna:** Brak uprawnień do wykonania.

**Rozwiązanie:**
```bash
chmod +x build.sh scripts/preinstall scripts/postinstall
```

## 📋 Checklist Przed Budowaniem

- [ ] Jestem na macOS (nie Windows/Linux)
- [ ] Mam zainstalowane Xcode Command Line Tools
- [ ] Skrypty mają uprawnienia do wykonania (`chmod +x`)
- [ ] Jestem w katalogu `red_team/pkg/`
- [ ] Wszystkie pliki źródłowe są dostępne

## 🚀 Szybkie Sprawdzenie

Uruchom te komendy aby sprawdzić czy wszystko jest gotowe:

```bash
# Sprawdź system
uname -s  # Powinno pokazać "Darwin" (macOS)

# Sprawdź dostępność narzędzi
which pkgbuild      # Powinno pokazać ścieżkę
which productbuild  # Powinno pokazać ścieżkę

# Sprawdź uprawnienia
ls -la build.sh scripts/preinstall scripts/postinstall

# Sprawdź lokalizację
pwd  # Powinno być w red_team/pkg/
```

## 💡 Alternatywa: Użyj Skryptu Instalacyjnego

Jeśli nie możesz zbudować pakietu .pkg, możesz użyć prostszego skryptu instalacyjnego:

```bash
cd red_team
chmod +x installer.sh malicious_agent.sh
sudo ./installer.sh
```

Ten skrypt również działa tylko na macOS, ale jest prostszy i nie wymaga Xcode Command Line Tools (tylko podstawowe narzędzia systemowe).

## 📞 Wsparcie

Jeśli nadal masz problemy:

1. Sprawdź czy jesteś na macOS: `uname -s`
2. Sprawdź logi błędów
3. Upewnij się, że wszystkie pliki są dostępne
4. Sprawdź uprawnienia plików

---

**Pamiętaj:** Pakiet .pkg może być zbudowany TYLKO na macOS!

