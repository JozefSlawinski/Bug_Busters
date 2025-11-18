# Plan Prezentacji - Projekt MITRE ATT&CK T1543

## 🎯 Cel Prezentacji

Przedstawienie techniki ataku **Create or Modify System Process (T1543)** w kontekście systemu macOS, demonstracja działania oraz metod obrony.

## 📋 Struktura Prezentacji

### 1. Wprowadzenie (5 min)

#### 1.1. MITRE ATT&CK Framework
- Czym jest MITRE ATT&CK
- Taktyki: Persistence (TA0003) i Privilege Escalation (TA0004)
- Technika T1543: Create or Modify System Process

#### 1.2. Cel Projektu
- Demonstracja techniki ataku
- Zrozumienie mechanizmów Launch Agents/Daemons w macOS
- Opracowanie narzędzi obronnych

### 2. Teoria - Launch Agents w macOS (10 min)

#### 2.1. Mechanizm launchd
- Czym jest launchd
- Różnica między Launch Agents a Launch Daemons
- Lokalizacje plików:
  - `~/Library/LaunchAgents/` - użytkownik
  - `/Library/LaunchAgents/` - system (wszyscy użytkownicy)
  - `/Library/LaunchDaemons/` - system (root)
  - `/System/Library/LaunchDaemons/` - system (tylko do odczytu)

#### 2.2. Struktura pliku .plist
- Kluczowe właściwości:
  - `Label` - unikalna nazwa
  - `ProgramArguments` - komenda do uruchomienia
  - `RunAtLoad` - uruchom przy starcie
  - `KeepAlive` - utrzymaj przy życiu
  - `StartInterval` - uruchom co X sekund

#### 2.3. Dlaczego to niebezpieczne?
- Automatyczne uruchamianie
- Działanie w tle
- Możliwość eskalacji uprawnień
- Trwałość (persistence)

### 3. Red Team - Implementacja Ataku (15 min)

#### 3.1. Architektura Agenta
- Plik `.plist` - konfiguracja Launch Agent
- Skrypt `malicious_agent.sh` - złośliwy kod
- Instalator `installer.sh` - automatyzacja instalacji

#### 3.2. Funkcjonalności Agenta
- **Zbieranie danych o plikach użytkownika**
  - Skanowanie katalogów użytkownika
  - Zbieranie metadanych plików
  - Zapisywanie do ukrytych lokalizacji

- **Monitorowanie aktywności sieciowej**
  - Aktywne połączenia (netstat)
  - Konfiguracja interfejsów (ifconfig)
  - Tabele routingu

- **Zbieranie informacji o systemie**
  - Informacje o systemie (uname, sw_vers)
  - Lista procesów
  - Zainstalowane aplikacje

- **Obciążanie CPU**
  - Symulacja złośliwej aktywności
  - Okresowe zadania

#### 3.3. Demonstracja Instalacji
```bash
cd red_team
sudo ./installer.sh
```

#### 3.4. Weryfikacja Działania
- Sprawdzenie aktywnych agentów
- Przegląd logów
- Sprawdzenie zebranych danych

### 4. Blue Team - Narzędzia Obronne (15 min)

#### 4.1. Monitor - Wykrywanie

**Funkcjonalności:**
- Skanowanie lokalizacji Launch Agents/Daemons
- Analiza plików `.plist` pod kątem podejrzanych właściwości
- Porównywanie z baseline
- Wykrywanie nowych/modyfikowanych agentów
- Monitorowanie aktywnych procesów

**Wskaźniki podejrzanej aktywności:**
- Podejrzane nazwy (malicious, backdoor, losowe ciągi)
- Niestandardowe lokalizacje
- Częste uruchamianie (StartInterval < 300s)
- RunAtLoad + KeepAlive = true
- Skrypty w podejrzanych lokalizacjach (/tmp, /var/tmp)

**Użycie:**
```bash
./monitor.sh --baseline    # Utwórz baseline
./monitor.sh --scan        # Skanuj system
./monitor.sh --monitor     # Ciągłe monitorowanie
```

#### 4.2. Defender - Usuwanie

**Funkcjonalności:**
- Automatyczne wykrywanie podejrzanych agentów
- Zatrzymywanie i usuwanie agentów
- Zabijanie powiązanych procesów
- Czyszczenie danych i logów
- Interaktywne potwierdzanie (bezpieczeństwo)

**Użycie:**
```bash
sudo ./defender.sh --scan                    # Skanuj i usuń
sudo ./defender.sh --remove <nazwa>          # Usuń konkretnego
sudo ./defender.sh --kill-processes          # Zabij procesy
sudo ./defender.sh --cleanup                 # Wyczyść dane
```

#### 4.3. Demonstracja Wykrywania i Usuwania
- Uruchomienie monitora
- Wykrycie zainstalowanego agenta
- Analiza podejrzanych właściwości
- Usunięcie agenta przez defendera
- Weryfikacja usunięcia

### 5. Metody Obrony dla Użytkowników (10 min)

#### 5.1. Zapobieganie
- **Świadomość** - wiedza o Launch Agents
- **Ostrożność** - nie instaluj oprogramowania z nieznanych źródeł
- **Uprawnienia** - nie podawaj hasła administratora bez potrzeby
- **Aktualizacje** - regularne aktualizacje systemu

#### 5.2. Wykrywanie
- **Regularne skanowanie** - użyj monitor.sh
- **Sprawdzanie lokalizacji** - ręczne przeglądanie katalogów
- **Monitorowanie procesów** - sprawdzanie aktywnych agentów
- **Analiza logów** - przeglądanie logów systemowych

#### 5.3. Reagowanie
- **Natychmiastowe działanie** - użyj defender.sh
- **Izolacja** - odłączenie od sieci
- **Analiza** - zbadaj co agent robił
- **Raportowanie** - zgłoś incydent (jeśli dotyczy)

#### 5.4. Automatyzacja Obrony
- Crontab - regularne skanowanie
- Launch Agent do monitorowania (ironicznie!)
- Integracja z systemami SIEM
- Alerty email/SMS

### 6. Wnioski i Podsumowanie (5 min)

#### 6.1. Kluczowe Wnioski
- Launch Agents są potężnym mechanizmem trwałości
- Wykrywanie wymaga regularnego monitorowania
- Automatyzacja obrony jest kluczowa
- Świadomość użytkowników jest pierwszym krokiem obrony

#### 6.2. Ograniczenia Projektu
- Testy tylko na własnym sprzęcie
- Uproszczone wskaźniki podejrzanej aktywności
- Brak integracji z zaawansowanymi systemami SIEM
- Ograniczenia do macOS

#### 6.3. Możliwości Rozwoju
- Integracja z systemami SIEM
- Machine Learning do wykrywania anomalii
- Rozszerzenie na inne systemy (Windows, Linux)
- Zaawansowana analiza behawioralna

### 7. Pytania i Dyskusja (5-10 min)

## 🎨 Wskazówki Prezentacyjne

### Slajdy
- Używaj diagramów architektury
- Pokaż przykładowe pliki `.plist`
- Zrzuty ekranu z terminala
- Wykresy pokazujące działanie agenta

### Demonstracja Na Żywo
- **Zalecane:** Pokaz działania na maszynie wirtualnej
- Instalacja agenta
- Wykrycie przez monitor
- Usunięcie przez defender

### Materiały Dodatkowe
- README.md - dokumentacja projektu
- INSTALLATION.md - instrukcje instalacji
- blue_team/README.md - instrukcje dla użytkowników
- Kod źródłowy - dostępny do przeglądu

## 📊 Metryki do Prezentacji

- Liczba linii kodu (red team vs blue team)
- Czas działania agenta przed wykryciem
- Liczba wykrytych wskaźników
- Rozmiar zebranych danych
- Czas reakcji obronnej

## 🔒 Uwagi Etyczne

- Podkreśl, że to tylko do celów edukacyjnych
- Używaj tylko na własnym sprzęcie
- Przestrzegaj prawa i etyki
- Nie używaj na systemach innych osób

## 📚 Materiały Referencyjne

- MITRE ATT&CK: https://attack.mitre.org/techniques/T1543/
- Apple Developer Documentation
- macOS Security Guides
- Przykłady złośliwego oprogramowania (tylko do analizy)

---

**Czas trwania prezentacji:** ~60-70 minut (z pytaniami)

**Format:** Prezentacja + demonstracja na żywo

