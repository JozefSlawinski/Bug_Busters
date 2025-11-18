#!/bin/bash

# Blue Team - Monitor Launch Agents/Daemons
# Wykrywa podejrzane Launch Agents i Launch Daemons

MONITOR_LOG="monitor.log"
ALERT_LOG="alerts.log"
BASELINE_FILE="baseline_agents.txt"
CHECK_INTERVAL=60  # sekundy

# Kolory dla outputu
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Lokalizacje Launch Agents i Daemons
LAUNCH_AGENTS_USER="$HOME/Library/LaunchAgents"
LAUNCH_AGENTS_SYSTEM="/Library/LaunchAgents"
LAUNCH_DAEMONS_SYSTEM="/Library/LaunchDaemons"
LAUNCH_DAEMONS_SYSTEM_PRIV="/System/Library/LaunchDaemons"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$MONITOR_LOG"
}

alert() {
    echo -e "${RED}[ALERT]${NC} $1" | tee -a "$ALERT_LOG"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ALERT: $1" >> "$ALERT_LOG"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log_message "INFO: $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log_message "WARNING: $1"
}

# Funkcja skanująca wszystkie Launch Agents/Daemons
scan_launch_items() {
    local items=()
    
    # Skanuj Launch Agents użytkownika
    if [ -d "$LAUNCH_AGENTS_USER" ]; then
        while IFS= read -r item; do
            [ -n "$item" ] && items+=("$item")
        done < <(find "$LAUNCH_AGENTS_USER" -name "*.plist" 2>/dev/null)
    fi
    
    # Skanuj systemowe Launch Agents (wymaga sudo)
    if [ -d "$LAUNCH_AGENTS_SYSTEM" ] && [ -r "$LAUNCH_AGENTS_SYSTEM" ]; then
        while IFS= read -r item; do
            [ -n "$item" ] && items+=("$item")
        done < <(find "$LAUNCH_AGENTS_SYSTEM" -name "*.plist" 2>/dev/null)
    fi
    
    # Skanuj systemowe Launch Daemons (wymaga sudo)
    if [ -d "$LAUNCH_DAEMONS_SYSTEM" ] && [ -r "$LAUNCH_DAEMONS_SYSTEM" ]; then
        while IFS= read -r item; do
            [ -n "$item" ] && items+=("$item")
        done < <(find "$LAUNCH_DAEMONS_SYSTEM" -name "*.plist" 2>/dev/null)
    fi
    
    printf '%s\n' "${items[@]}"
}

# Funkcja analizująca plist pod kątem podejrzanych właściwości
analyze_plist() {
    local plist_file="$1"
    local suspicious=0
    local reasons=()
    
    # Sprawdź czy plik istnieje i jest czytelny
    if [ ! -r "$plist_file" ]; then
        warning "Nie można odczytać pliku: $plist_file"
        return 1
    fi
    
    # Podejrzane nazwy
    if [[ "$plist_file" == *"bugbusters"* ]] || \
       [[ "$plist_file" == *"malicious"* ]] || \
       [[ "$plist_file" == *"backdoor"* ]] || \
       [[ "$(basename "$plist_file")" =~ ^[0-9a-f]{32} ]]; then
        suspicious=$((suspicious + 1))
        reasons+=("Podejrzana nazwa pliku")
    fi
    
    # Sprawdź zawartość plist
    local label=$(plutil -extract Label raw "$plist_file" 2>/dev/null)
    local program_args=$(plutil -extract ProgramArguments raw "$plist_file" 2>/dev/null)
    local run_at_load=$(plutil -extract RunAtLoad raw "$plist_file" 2>/dev/null)
    local keep_alive=$(plutil -extract KeepAlive raw "$plist_file" 2>/dev/null)
    local start_interval=$(plutil -extract StartInterval raw "$plist_file" 2>/dev/null)
    
    # Podejrzane właściwości
    if [ "$run_at_load" == "true" ] && [ "$keep_alive" == "true" ]; then
        suspicious=$((suspicious + 1))
        reasons+=("RunAtLoad + KeepAlive (trwała obecność)")
    fi
    
    if [ -n "$start_interval" ] && [ "$start_interval" -lt 300 ]; then
        suspicious=$((suspicious + 1))
        reasons+=("Częste uruchamianie (co $start_interval sekund)")
    fi
    
    # Sprawdź ścieżki do skryptów
    if echo "$program_args" | grep -qiE "(bash|sh|python|perl).*\.(sh|py|pl)"; then
        local script_path=$(echo "$program_args" | grep -oE '/[^"]+\.(sh|py|pl)' | head -1)
        if [ -n "$script_path" ]; then
            # Sprawdź czy skrypt jest w podejrzanej lokalizacji
            if [[ "$script_path" == *"/Library/Application Support"* ]] || \
               [[ "$script_path" == *"/Users/Shared"* ]] || \
               [[ "$script_path" == *"/tmp"* ]] || \
               [[ "$script_path" == *"/var/tmp"* ]] || \
               [[ "$script_path" == *"$HOME"* ]]; then
                suspicious=$((suspicious + 1))
                reasons+=("Skrypt w podejrzanej lokalizacji: $script_path")
            fi
            
            # Sprawdź czy skrypt istnieje i ma podejrzane właściwości
            if [ -f "$script_path" ]; then
                if file "$script_path" | grep -qi "script"; then
                    # Sprawdź rozmiar i uprawnienia
                    local file_size=$(stat -f%z "$script_path" 2>/dev/null || echo "0")
                    if [ "$file_size" -gt 0 ] && [ "$file_size" -lt 10000 ]; then
                        # Mały plik - może być złośliwy
                        if strings "$script_path" | grep -qiE "(malicious|backdoor|keylog|steal|exfiltrate)"; then
                            suspicious=$((suspicious + 2))
                            reasons+=("Skrypt zawiera podejrzane słowa kluczowe")
                        fi
                    fi
                fi
            fi
        fi
    fi
    
    # Sprawdź czy plik jest w niestandardowej lokalizacji
    if [[ "$plist_file" != *"/System/Library"* ]] && \
       [[ "$plist_file" != *"/Library/LaunchDaemons"* ]] && \
       [[ "$plist_file" != *"/Library/LaunchAgents"* ]] && \
       [[ "$plist_file" != *"$HOME/Library/LaunchAgents"* ]]; then
        suspicious=$((suspicious + 1))
        reasons+=("Plik w niestandardowej lokalizacji")
    fi
    
    if [ $suspicious -gt 0 ]; then
        echo "SUSPICIOUS|$suspicious|${reasons[*]}"
        return 0
    else
        echo "CLEAN"
        return 1
    fi
}

# Funkcja sprawdzająca aktywne procesy związane z Launch Agents
check_active_processes() {
    info "Sprawdzanie aktywnych procesów Launch Agents..."
    
    # Pobierz listę aktywnych Launch Agents
    local active_agents=$(launchctl list | grep -v "com.apple" | awk '{print $3}' | grep -v "^$")
    
    while IFS= read -r agent_label; do
        [ -z "$agent_label" ] && continue
        
        # Sprawdź czy agent jest podejrzany
        local plist_path=""
        for location in "$LAUNCH_AGENTS_USER" "$LAUNCH_AGENTS_SYSTEM" "$LAUNCH_DAEMONS_SYSTEM"; do
            local potential_plist="$location/${agent_label}.plist"
            if [ -f "$potential_plist" ]; then
                plist_path="$potential_plist"
                break
            fi
        done
        
        if [ -n "$plist_path" ]; then
            local analysis=$(analyze_plist "$plist_path")
            if [[ "$analysis" == "SUSPICIOUS"* ]]; then
                alert "Aktywny podejrzany agent: $agent_label (plik: $plist_path)"
            fi
        else
            warning "Nie znaleziono pliku plist dla aktywnego agenta: $agent_label"
        fi
    done <<< "$active_agents"
}

# Funkcja tworząca baseline
create_baseline() {
    info "Tworzenie baseline Launch Agents..."
    scan_launch_items | sort > "$BASELINE_FILE"
    success "Baseline utworzony: $(wc -l < "$BASELINE_FILE") agentów"
}

# Funkcja porównująca z baseline
compare_with_baseline() {
    if [ ! -f "$BASELINE_FILE" ]; then
        warning "Brak pliku baseline. Uruchom z opcją --baseline"
        return 1
    fi
    
    local current_items=$(scan_launch_items | sort)
    local new_items=$(comm -13 "$BASELINE_FILE" <(echo "$current_items"))
    local removed_items=$(comm -23 "$BASELINE_FILE" <(echo "$current_items"))
    
    if [ -n "$new_items" ]; then
        alert "Wykryto NOWE Launch Agents/Daemons:"
        echo "$new_items" | while read -r item; do
            alert "  + $item"
            analyze_plist "$item" | grep -q "SUSPICIOUS" && \
                alert "    ⚠️  PODEJRZANY!"
        done
    fi
    
    if [ -n "$removed_items" ]; then
        info "Usunięte Launch Agents/Daemons:"
        echo "$removed_items" | while read -r item; do
            info "  - $item"
        done
    fi
    
    # Zaktualizuj baseline
    echo "$current_items" > "$BASELINE_FILE"
}

# Funkcja ciągłego monitorowania
continuous_monitor() {
    info "Rozpoczęcie ciągłego monitorowania (co $CHECK_INTERVAL sekund)..."
    info "Naciśnij Ctrl+C aby zatrzymać"
    
    while true; do
        echo ""
        info "=== Skanowanie $(date '+%Y-%m-%d %H:%M:%S') ==="
        
        compare_with_baseline
        check_active_processes
        
        # Skanuj wszystkie pliki i analizuj
        scan_launch_items | while read -r plist_file; do
            local result=$(analyze_plist "$plist_file")
            if [[ "$result" == "SUSPICIOUS"* ]]; then
                local score=$(echo "$result" | cut -d'|' -f2)
                local reasons=$(echo "$result" | cut -d'|' -f3-)
                if [ "$score" -ge 2 ]; then
                    alert "Podejrzany plik (score: $score): $plist_file"
                    alert "  Powody: $reasons"
                fi
            fi
        done
        
        sleep "$CHECK_INTERVAL"
    done
}

# Menu główne
show_menu() {
    echo ""
    echo "🔵 BLUE TEAM - Monitor Launch Agents/Daemons"
    echo "=============================================="
    echo "1. Utwórz baseline"
    echo "2. Jednorazowe skanowanie"
    echo "3. Ciągłe monitorowanie"
    echo "4. Sprawdź aktywne procesy"
    echo "5. Wyjście"
    echo ""
    read -p "Wybierz opcję (1-5): " choice
    
    case $choice in
        1)
            create_baseline
            ;;
        2)
            if [ ! -f "$BASELINE_FILE" ]; then
                create_baseline
            fi
            compare_with_baseline
            scan_launch_items | while read -r plist_file; do
                analyze_plist "$plist_file" | grep -q "SUSPICIOUS" && \
                    alert "Podejrzany: $plist_file"
            done
            ;;
        3)
            continuous_monitor
            ;;
        4)
            check_active_processes
            ;;
        5)
            exit 0
            ;;
        *)
            echo "Nieprawidłowa opcja"
            ;;
    esac
}

# Obsługa argumentów wiersza poleceń
if [ "$1" == "--baseline" ]; then
    create_baseline
elif [ "$1" == "--scan" ]; then
    if [ ! -f "$BASELINE_FILE" ]; then
        create_baseline
    fi
    compare_with_baseline
elif [ "$1" == "--monitor" ]; then
    if [ ! -f "$BASELINE_FILE" ]; then
        create_baseline
    fi
    continuous_monitor
else
    show_menu
fi

