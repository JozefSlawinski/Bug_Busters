# Blue Team - Instrukcje dla Użytkowników

## 🔵 Narzędzia Obronne przeciwko Launch Agents

Ten katalog zawiera narzędzia do wykrywania i usuwania podejrzanych Launch Agents i Launch Daemons w systemie macOS.

## 📋 Zawartość

- **monitor.sh** - Narzędzie monitorujące wykrywające podejrzane Launch Agents
- **defender.sh** - Narzędzie do usuwania podejrzanych agentów i procesów
- **README.md** - Ten plik z instrukcjami

## 🚀 Szybki Start

### 1. Przygotowanie

Upewnij się, że skrypty mają uprawnienia do wykonania:

```bash
chmod +x monitor.sh defender.sh
```

### 2. Uruchomienie Monitora

```bash
./monitor.sh
```

Monitor oferuje następujące opcje:
- **Utwórz baseline** - Tworzy początkową listę wszystkich Launch Agents (zalecane przy pierwszym uruchomieniu)
- **Jednorazowe skanowanie** - Skanuje system i porównuje z baseline
- **Ciągłe monitorowanie** - Monitoruje system w czasie rzeczywistym (co 60 sekund)
- **Sprawdź aktywne procesy** - Sprawdza aktualnie uruchomione procesy Launch Agents

### 3. Uruchomienie Defendera

**⚠️ Wymaga uprawnień administratora:**

```bash
sudo ./defender.sh
```

Defender oferuje następujące opcje:
- **Skanuj i usuń podejrzane agenty** - Automatycznie znajduje i pozwala usunąć podejrzane agenty
- **Usuń konkretnego agenta** - Usuwa agenta o podanej nazwie
- **Zabij podejrzane procesy** - Kończy podejrzane procesy związane z agentami
- **Wyczyść dane i logi** - Usuwa katalogi z danymi i logami agentów
- **Pełne czyszczenie** - Wykonuje wszystkie powyższe operacje

## 🛡️ Jak Zabezpieczyć się przed Launch Agents

### 1. Regularne Monitorowanie

Uruchamiaj monitor regularnie, najlepiej automatycznie:

```bash
# Dodaj do crontab (uruchamianie co godzinę)
0 * * * * /ścieżka/do/monitor.sh --scan >> /ścieżka/do/monitor.log 2>&1
```

### 2. Sprawdzanie Lokalizacji Launch Agents

Regularnie sprawdzaj następujące lokalizacje:

```bash
# Launch Agents użytkownika
ls -la ~/Library/LaunchAgents/

# Systemowe Launch Agents (wymaga sudo)
sudo ls -la /Library/LaunchAgents/

# Systemowe Launch Daemons (wymaga sudo)
sudo ls -la /Library/LaunchDaemons/
```

### 3. Sprawdzanie Aktywnych Agentów

```bash
# Lista wszystkich aktywnych Launch Agents
launchctl list

# Lista tylko niestandardowych (nie Apple)
launchctl list | grep -v "com.apple"
```

### 4. Analiza Podejrzanych Plików

Jeśli znajdziesz podejrzany plik `.plist`, możesz go przeanalizować:

```bash
# Wyświetl zawartość pliku
plutil -p /ścieżka/do/pliku.plist

# Sprawdź szczegóły
plutil -extract Label raw /ścieżka/do/pliku.plist
plutil -extract ProgramArguments raw /ścieżka/do/pliku.plist
```

### 5. Oznaki Podejrzanych Launch Agents

Zwracaj uwagę na:

- ✅ **Podejrzane nazwy** - Nazwy zawierające słowa: "malicious", "backdoor", "bugbusters", losowe ciągi znaków
- ✅ **Niestandardowe lokalizacje** - Pliki poza standardowymi katalogami Launch Agents
- ✅ **Częste uruchamianie** - `StartInterval` mniejszy niż 300 sekund
- ✅ **Trwała obecność** - `RunAtLoad` + `KeepAlive` = true
- ✅ **Podejrzane skrypty** - Skrypty w `/tmp`, `/var/tmp`, lub ukrytych lokalizacjach
- ✅ **Nieznane procesy** - Procesy bash/sh/python uruchomione z podejrzanych lokalizacji

## 🔍 Przykłady Wykrywania

### Przykład 1: Wykrycie podejrzanego agenta

```bash
$ ./monitor.sh
# Wybierz opcję 2 (Jednorazowe skanowanie)

[ALERT] Wykryto NOWE Launch Agents/Daemons:
[ALERT]   + /Library/LaunchAgents/com.bugbusters.malicious.plist
[ALERT]     ⚠️  PODEJRZANY!
```

### Przykład 2: Usunięcie agenta

```bash
$ sudo ./defender.sh
# Wybierz opcję 1 (Skanuj i usuń)

[ALERT] Znaleziono podejrzany agent: /Library/LaunchAgents/com.bugbusters.malicious.plist
Czy usunąć ten agent? (tak/nie): tak
[OK] Agent zatrzymany: com.bugbusters.malicious
[OK] Usunięto plik: /Library/LaunchAgents/com.bugbusters.malicious.plist
```

## 📊 Logi i Raporty

Monitor i Defender tworzą pliki logów:

- **monitor.log** - Logi z monitorowania
- **alerts.log** - Tylko alerty i ostrzeżenia
- **defender.log** - Logi z działań defendera
- **baseline_agents.txt** - Lista znanych Launch Agents (baseline)

Regularnie przeglądaj te pliki, aby śledzić zmiany w systemie.

## 🔧 Zaawansowane Użycie

### Automatyczne Monitorowanie w Tle

Możesz uruchomić monitor jako usługę w tle:

```bash
# Uruchom monitor w tle
nohup ./monitor.sh --monitor > monitor_output.log 2>&1 &

# Sprawdź czy działa
ps aux | grep monitor.sh
```

### Integracja z Systemem

Możesz stworzyć własny Launch Agent do monitorowania (ironicznie!):

```bash
# Stwórz plik ~/Library/LaunchAgents/com.yourname.security.monitor.plist
# Skonfiguruj go do uruchamiania monitor.sh co godzinę
```

### Skrypty Pomocnicze

Możesz stworzyć własne skrypty do automatyzacji:

```bash
#!/bin/bash
# daily_check.sh
./monitor.sh --scan
if [ $? -ne 0 ]; then
    echo "Wykryto podejrzane agenty!" | mail -s "Alert Security" admin@example.com
fi
```

## ⚠️ Ostrzeżenia

1. **Używaj z rozwagą** - Defender może usunąć ważne usługi systemowe, jeśli nie jesteś ostrożny
2. **Twórz kopie zapasowe** - Przed usunięciem agenta, rozważ utworzenie kopii zapasowej
3. **Sprawdzaj przed usunięciem** - Zawsze sprawdzaj szczegóły agenta przed jego usunięciem
4. **Uprawnienia administratora** - Niektóre operacje wymagają sudo - używaj ostrożnie

## 📚 Dodatkowe Zasoby

- [Apple Developer - Launch Services](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)
- [MITRE ATT&CK - T1543](https://attack.mitre.org/techniques/T1543/)
- [macOS Security - Launch Agents](https://support.apple.com/guide/security/launch-agents-and-launch-daemons-sec7e0b5b5b/web)

## 🆘 Pomoc

Jeśli masz pytania lub problemy:

1. Sprawdź logi (`monitor.log`, `alerts.log`, `defender.log`)
2. Uruchom monitor z opcją `--scan` aby zobaczyć szczegóły
3. Sprawdź uprawnienia plików i katalogów
4. Upewnij się, że masz najnowszą wersję narzędzi

## 📝 Notatki

- Monitor działa najlepiej gdy najpierw utworzysz baseline
- Defender wymaga interakcji użytkownika przed usunięciem (bezpieczeństwo)
- Wszystkie operacje są logowane dla audytu
- Narzędzia są przeznaczone do użycia na macOS

---

**Pamiętaj:** Najlepszą obroną jest regularne monitorowanie i świadomość tego, co działa w Twoim systemie!

