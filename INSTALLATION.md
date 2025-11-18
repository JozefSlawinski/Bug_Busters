# Instrukcja Instalacji i Użycia

## 📋 Wymagania

- macOS (dowolna wersja wspierająca Launch Agents)
- Terminal z dostępem do bash/zsh
- Uprawnienia administratora (dla niektórych operacji)

## 🔴 Red Team - Instalacja Agenta

### ⚠️ OSTRZEŻENIE

**Używaj tylko na własnym sprzęcie lub maszynach wirtualnych!**

### Krok 1: Przygotowanie

```bash
cd red_team
chmod +x installer.sh malicious_agent.sh
```

### Krok 2: Instalacja

```bash
sudo ./installer.sh
```

Instalator:
1. Utworzy katalogi w `/Library/Application Support/BugBusters`
2. Skopiuje skrypt agenta
3. Zainstaluje Launch Agent
4. Uruchomi agenta automatycznie

### Krok 3: Weryfikacja

Sprawdź czy agent działa:

```bash
# Lista aktywnych agentów
launchctl list | grep bugbusters

# Sprawdź logi
sudo tail -f "/Library/Application Support/BugBusters/agent.log"
```

### Odinstalowanie

```bash
sudo ./installer.sh --uninstall
```

Lub ręcznie:

```bash
sudo launchctl unload /Library/LaunchAgents/com.bugbusters.malicious.plist
sudo rm /Library/LaunchAgents/com.bugbusters.malicious.plist
sudo rm -rf "/Library/Application Support/BugBusters"
```

## 🔵 Blue Team - Instalacja Narzędzi Obronnych

### Krok 1: Przygotowanie

```bash
cd blue_team
chmod +x monitor.sh defender.sh
```

### Krok 2: Pierwsze Uruchomienie

```bash
# Utwórz baseline
./monitor.sh
# Wybierz opcję 1
```

### Krok 3: Uruchomienie Monitora

```bash
# Interaktywne menu
./monitor.sh

# Lub bezpośrednio:
./monitor.sh --baseline    # Utwórz baseline
./monitor.sh --scan        # Jednorazowe skanowanie
./monitor.sh --monitor     # Ciągłe monitorowanie
```

### Krok 4: Użycie Defendera

```bash
# Wymaga sudo
sudo ./defender.sh

# Lub bezpośrednio:
sudo ./defender.sh --scan                    # Skanuj i usuń
sudo ./defender.sh --remove com.bugbusters.malicious  # Usuń konkretnego
sudo ./defender.sh --kill-processes          # Zabij procesy
sudo ./defender.sh --cleanup                 # Wyczyść dane
```

## 🔄 Pełny Scenariusz Testowy

### 1. Przygotowanie Środowiska

```bash
# Utwórz maszynę wirtualną macOS (jeśli nie masz fizycznego Mac)
# Lub użyj własnego Mac (tylko do testów!)
```

### 2. Instalacja Agenta (Red Team)

```bash
cd red_team
sudo ./installer.sh
```

### 3. Weryfikacja Działania Agenta

```bash
# Sprawdź czy agent działa
launchctl list | grep bugbusters

# Sprawdź logi
sudo tail -f "/Library/Application Support/BugBusters/agent.log"

# Sprawdź zebrane dane
sudo ls -la "/Library/Application Support/BugBusters/data/"
```

### 4. Wykrycie Agenta (Blue Team)

```bash
cd blue_team

# Utwórz baseline (jeśli jeszcze nie istnieje)
./monitor.sh --baseline

# Skanuj system
./monitor.sh --scan
```

### 5. Usunięcie Agenta (Blue Team)

```bash
sudo ./defender.sh
# Wybierz opcję 1 (Skanuj i usuń)
# Potwierdź usunięcie
```

### 6. Weryfikacja Usunięcia

```bash
# Sprawdź czy agent został usunięty
launchctl list | grep bugbusters

# Sprawdź czy pliki zostały usunięte
ls -la /Library/LaunchAgents/ | grep bugbusters
ls -la "/Library/Application Support/BugBusters"
```

## 📊 Monitorowanie w Produkcji

### Automatyczne Monitorowanie

Możesz skonfigurować automatyczne monitorowanie używając crontab:

```bash
# Edytuj crontab
crontab -e

# Dodaj linię (skanowanie co godzinę)
0 * * * * /ścieżka/do/blue_team/monitor.sh --scan >> /ścieżka/do/blue_team/monitor.log 2>&1
```

### Uruchomienie jako Usługa

Możesz stworzyć Launch Agent do monitorowania (ironicznie!):

```bash
# Stwórz plik ~/Library/LaunchAgents/com.security.monitor.plist
# Skonfiguruj go do uruchamiania monitor.sh
```

## 🐛 Rozwiązywanie Problemów

### Problem: Agent się nie uruchamia

```bash
# Sprawdź logi błędów
sudo cat "/Library/Application Support/BugBusters/agent_error.log"

# Sprawdź uprawnienia
ls -la "/Library/Application Support/BugBusters/malicious_agent.sh"
sudo chmod +x "/Library/Application Support/BugBusters/malicious_agent.sh"

# Sprawdź status Launch Agent
launchctl list | grep bugbusters
launchctl print system/com.bugbusters.malicious
```

### Problem: Monitor nie wykrywa agenta

```bash
# Sprawdź czy baseline istnieje
ls -la blue_team/baseline_agents.txt

# Utwórz nowy baseline
cd blue_team
./monitor.sh --baseline

# Sprawdź uprawnienia do katalogów
ls -la /Library/LaunchAgents/
```

### Problem: Defender nie może usunąć agenta

```bash
# Sprawdź uprawnienia
sudo ls -la /Library/LaunchAgents/com.bugbusters.malicious.plist

# Zatrzymaj agenta ręcznie
sudo launchctl unload /Library/LaunchAgents/com.bugbusters.malicious.plist

# Usuń plik ręcznie
sudo rm /Library/LaunchAgents/com.bugbusters.malicious.plist
```

## 📝 Notatki

- Wszystkie operacje wymagające sudo są niebezpieczne - używaj ostrożnie
- Zawsze sprawdzaj logi po instalacji/usunięciu
- Baseline powinien być tworzony na "czystym" systemie
- Regularnie aktualizuj baseline gdy instalujesz nowe aplikacje

## 🔒 Bezpieczeństwo

1. **Nie udostępniaj** skryptów red team publicznie bez odpowiednich ostrzeżeń
2. **Używaj tylko** na własnym sprzęcie
3. **Usuwaj agenty** po zakończeniu testów
4. **Monitoruj logi** regularnie
5. **Twórz kopie zapasowe** przed modyfikacją systemu

---

**Pamiętaj:** To narzędzia edukacyjne. Używaj odpowiedzialnie!

