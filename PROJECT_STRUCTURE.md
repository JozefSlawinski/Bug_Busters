# Struktura Projektu Bug Busters

## 📁 Przegląd Struktury

```
Bug_Busters/
├── .gitignore                    # Pliki do ignorowania w git
├── README.md                     # Główny opis projektu
├── INSTALLATION.md               # Instrukcje instalacji i użycia
├── PRESENTATION_OUTLINE.md       # Plan prezentacji
├── PROJECT_STRUCTURE.md          # Ten plik
│
├── red_team/                     # 🔴 Komponenty atakujące
│   ├── agent/
│   │   └── com.bugbusters.malicious.plist  # Plik Launch Agent
│   ├── installer.sh              # Skrypt instalacyjny agenta
│   └── malicious_agent.sh        # Skrypt wykonujący złośliwe działania
│
└── blue_team/                    # 🔵 Komponenty obronne
    ├── monitor.sh                # Narzędzie monitorujące
    ├── defender.sh                # Narzędzie do usuwania agentów
    └── README.md                  # Instrukcje dla użytkowników
```

## 📋 Opis Komponentów

### Red Team (Atakujący)

#### `red_team/agent/com.bugbusters.malicious.plist`
- **Typ:** Plik konfiguracyjny Launch Agent (XML/plist)
- **Funkcja:** Definiuje zachowanie agenta systemowego
- **Właściwości:**
  - Uruchamia się przy starcie systemu (`RunAtLoad`)
  - Utrzymuje się przy życiu (`KeepAlive`)
  - Wykonuje się co 300 sekund (`StartInterval`)
  - Uruchamia skrypt `malicious_agent.sh`

#### `red_team/malicious_agent.sh`
- **Typ:** Skrypt bash
- **Funkcja:** Wykonuje złośliwe działania w tle
- **Działania:**
  - Zbiera informacje o plikach użytkownika
  - Monitoruje aktywność sieciową
  - Zbiera informacje o systemie
  - Wykonuje zadania obciążające CPU
  - Zapisuje logi do ukrytych lokalizacji

#### `red_team/installer.sh`
- **Typ:** Skrypt bash (wymaga sudo)
- **Funkcja:** Automatyczna instalacja Launch Agent
- **Operacje:**
  - Tworzy katalogi systemowe
  - Kopiuje pliki agenta
  - Instaluje Launch Agent
  - Uruchamia agenta
  - Obsługuje odinstalowanie (`--uninstall`)

### Blue Team (Obrońcy)

#### `blue_team/monitor.sh`
- **Typ:** Skrypt bash
- **Funkcja:** Wykrywanie podejrzanych Launch Agents/Daemons
- **Funkcjonalności:**
  - Skanowanie lokalizacji Launch Agents/Daemons
  - Analiza plików `.plist` pod kątem podejrzanych właściwości
  - Tworzenie i porównywanie z baseline
  - Wykrywanie nowych/modyfikowanych agentów
  - Monitorowanie aktywnych procesów
  - Ciągłe monitorowanie w czasie rzeczywistym
- **Tryby pracy:**
  - `--baseline` - Utwórz baseline
  - `--scan` - Jednorazowe skanowanie
  - `--monitor` - Ciągłe monitorowanie

#### `blue_team/defender.sh`
- **Typ:** Skrypt bash (wymaga sudo)
- **Funkcja:** Usuwanie podejrzanych agentów i procesów
- **Funkcjonalności:**
  - Automatyczne wykrywanie podejrzanych agentów
  - Zatrzymywanie i usuwanie Launch Agents
  - Zabijanie powiązanych procesów
  - Czyszczenie danych i logów
  - Interaktywne potwierdzanie przed usunięciem
- **Tryby pracy:**
  - `--scan` - Skanuj i usuń
  - `--remove <nazwa>` - Usuń konkretnego agenta
  - `--kill-processes` - Zabij procesy
  - `--cleanup` - Wyczyść dane

#### `blue_team/README.md`
- **Typ:** Dokumentacja Markdown
- **Funkcja:** Instrukcje dla użytkowników końcowych
- **Zawartość:**
  - Szybki start
  - Instrukcje użycia
  - Metody zabezpieczenia
  - Przykłady wykrywania
  - Rozwiązywanie problemów

### Dokumentacja

#### `README.md`
- Główny opis projektu
- Struktura projektu
- Ostrzeżenia etyczne
- Wymagania

#### `INSTALLATION.md`
- Szczegółowe instrukcje instalacji
- Scenariusze testowe
- Rozwiązywanie problemów
- Uwagi bezpieczeństwa

#### `PRESENTATION_OUTLINE.md`
- Plan prezentacji projektu
- Struktura slajdów
- Wskazówki prezentacyjne
- Materiały referencyjne

## 🔄 Przepływ Działania

### Scenariusz Ataku (Red Team)

1. **Przygotowanie**
   ```bash
   cd red_team
   chmod +x installer.sh malicious_agent.sh
   ```

2. **Instalacja**
   ```bash
   sudo ./installer.sh
   ```

3. **Działanie Agenta**
   - Agent uruchamia się automatycznie
   - Wykonuje złośliwe działania co 300 sekund
   - Zapisuje dane do `/Library/Application Support/BugBusters/`

### Scenariusz Obrony (Blue Team)

1. **Przygotowanie**
   ```bash
   cd blue_team
   chmod +x monitor.sh defender.sh
   ```

2. **Utworzenie Baseline**
   ```bash
   ./monitor.sh --baseline
   ```

3. **Wykrycie**
   ```bash
   ./monitor.sh --scan
   ```

4. **Usunięcie**
   ```bash
   sudo ./defender.sh --scan
   ```

## 📊 Lokalizacje Plików Systemowych

### Po Instalacji Agenta

```
/Library/LaunchAgents/
└── com.bugbusters.malicious.plist

/Library/Application Support/BugBusters/
├── malicious_agent.sh
├── agent.log
├── agent_error.log
└── data/
    ├── user_*_files_*.txt
    ├── network_*.txt
    └── system_*.txt
```

### Pliki Monitora/Defendera

```
blue_team/
├── monitor.log          # Logi monitorowania
├── alerts.log           # Tylko alerty
├── baseline_agents.txt  # Lista znanych agentów
└── defender.log         # Logi defendera
```

## 🔐 Uprawnienia

### Red Team
- `installer.sh` - wymaga sudo (root)
- `malicious_agent.sh` - wykonuje się jako root (jeśli zainstalowany systemowo)

### Blue Team
- `monitor.sh` - działa jako użytkownik (czytanie)
- `defender.sh` - wymaga sudo (zapis/usuwanie)

## ⚠️ Uwagi Bezpieczeństwa

1. **Nie commituj:**
   - Logów (`.log`)
   - Baseline (`baseline_agents.txt`)
   - Zebranych danych (`data/`)

2. **Używaj tylko na:**
   - Własnym sprzęcie
   - Maszynach wirtualnych
   - Środowiskach testowych

3. **Po testach:**
   - Usuń wszystkie agenty
   - Wyczyść dane
   - Zweryfikuj usunięcie

## 🧪 Testowanie

### Minimalne Wymagania
- macOS (dowolna wersja)
- Terminal z bash/zsh
- Uprawnienia administratora

### Zalecane Środowisko
- Maszyna wirtualna macOS
- Snapshot przed instalacją
- Możliwość przywrócenia

## 📝 Notatki dla Deweloperów

### Rozszerzanie Funkcjonalności

**Red Team:**
- Dodaj nowe funkcje zbierania danych
- Zmień częstotliwość wykonania
- Dodaj szyfrowanie danych

**Blue Team:**
- Dodaj więcej wskaźników podejrzanej aktywności
- Integracja z systemami SIEM
- Machine Learning do wykrywania anomalii
- Rozszerzenie na Windows/Linux

### Debugowanie

```bash
# Sprawdź logi agenta
sudo tail -f "/Library/Application Support/BugBusters/agent.log"

# Sprawdź logi monitora
tail -f blue_team/monitor.log

# Sprawdź status Launch Agent
launchctl list | grep bugbusters
launchctl print system/com.bugbusters.malicious
```

---

**Ostatnia aktualizacja:** Projekt kompletny i gotowy do użycia

