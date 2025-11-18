# Bug Busters - Projekt MITRE ATT&CK T1543

## Opis Projektu

Projekt demonstruje technikę ataku **Create or Modify System Process (T1543)** według MITRE ATT&CK, która należy do taktyk:
- **Persistence (TA0003)** - Utrzymanie dostępu
- **Privilege Escalation (TA0004)** - Eskalacja uprawnień

## Struktura Projektu

```
Bug_Busters/
├── red_team/              # Komponenty atakujące
│   ├── agent/            # Agent Launch Agent
│   ├── installer.sh      # Skrypt instalacyjny
│   └── malicious_agent.sh # Skrypt wykonujący złośliwe działania
├── blue_team/            # Komponenty obronne
│   ├── monitor.sh        # Narzędzie monitorujące
│   ├── defender.sh       # Skrypt usuwający podejrzane agenty
│   └── README.md         # Instrukcje dla użytkowników
└── README.md             # Ten plik
```

## ⚠️ Ostrzeżenie

**Ten projekt jest przeznaczony wyłącznie do celów edukacyjnych i testowych na własnym sprzęcie lub maszynach wirtualnych. Użycie tych narzędzi na systemach innych osób bez zgody jest nielegalne i nieetyczne.**

## Wymagania

- macOS (dla testowania Launch Agents)
- Uprawnienia administratora (dla instalacji agentów)
- Terminal z dostępem do bash/zsh

## Red Team - Komponenty Atakujące

### Agent Launch Agent
Agent uruchamia się automatycznie przy starcie systemu i wykonuje złośliwe działania w tle:
- Zbiera informacje o plikach i folderach użytkownika
- Monitoruje aktywność sieciową
- Wykonuje okresowo zadania obciążające CPU
- Zapisuje logi do ukrytych lokalizacji

### Instalacja (TYLKO NA WŁASNYM SPRZĘCIE)
```bash
cd red_team
sudo ./installer.sh
```

## Blue Team - Komponenty Obronne

### Monitor
Narzędzie monitorujące wykrywa:
- Nowe Launch Agents i Launch Daemons
- Modyfikacje istniejących agentów
- Podejrzane skrypty i pliki logów
- Procesy uruchomione przez agenty

### Uruchomienie monitora
```bash
cd blue_team
./monitor.sh
```

### Usuwanie podejrzanych agentów
```bash
cd blue_team
sudo ./defender.sh
```

## Etyka i Prawo

Wszystkie testy powinny być wykonywane wyłącznie na:
- Własnym sprzęcie
- Maszynach wirtualnych pod pełną kontrolą
- Środowiskach testowych z wyraźną zgodą

**NIE używaj tych narzędzi na systemach innych osób bez pisemnej zgody.**

## Autorzy

Projekt edukacyjny - Bug Busters Team

## Licencja

Projekt edukacyjny - użycie na własną odpowiedzialność.

