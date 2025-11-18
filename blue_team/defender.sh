#!/bin/bash

# Blue Team - Defender - Usuwanie podejrzanych Launch Agents
# ⚠️ Wymaga uprawnień administratora

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Sprawdź uprawnienia
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Ten skrypt wymaga uprawnień administratora (sudo)${NC}"
    echo "Użyj: sudo $0"
    exit 1
fi

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "defender.log"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log_action "INFO: $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
    log_action "SUCCESS: $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log_action "WARNING: $1"
}

alert() {
    echo -e "${RED}[ALERT]${NC} $1"
    log_action "ALERT: $1"
}

# Funkcja analizująca plist (uproszczona wersja z monitor.sh)
analyze_plist_simple() {
    local plist_file="$1"
    local suspicious=0
    
    # Podejrzane nazwy
    if [[ "$plist_file" == *"bugbusters"* ]] || \
       [[ "$plist_file" == *"malicious"* ]] || \
       [[ "$plist_file" == *"backdoor"* ]]; then
        return 0  # Podejrzany
    fi
    
    # Sprawdź zawartość
    if plutil -extract Label raw "$plist_file" 2>/dev/null | grep -qiE "(bugbusters|malicious|backdoor)"; then
        return 0  # Podejrzany
    fi
    
    return 1  # Niepodejrzany
}

# Funkcja zatrzymywania i usuwania agenta
remove_agent() {
    local plist_file="$1"
    local label=$(basename "$plist_file" .plist)
    
    info "Przetwarzanie: $plist_file"
    
    # Zatrzymaj agenta
    if launchctl list | grep -q "$label"; then
        info "Zatrzymywanie agenta: $label"
        launchctl unload "$plist_file" 2>/dev/null || \
        launchctl bootout system "$plist_file" 2>/dev/null || \
        launchctl bootout gui/$(id -u) "$plist_file" 2>/dev/null || true
        success "Agent zatrzymany: $label"
    fi
    
    # Usuń plik plist
    if [ -f "$plist_file" ]; then
        rm -f "$plist_file"
        success "Usunięto plik: $plist_file"
    fi
    
    # Znajdź i usuń powiązane skrypty
    local program_args=$(plutil -extract ProgramArguments raw "$plist_file" 2>/dev/null || echo "")
    if [ -n "$program_args" ]; then
        echo "$program_args" | grep -oE '/[^"]+\.(sh|py|pl)' | while read -r script_path; do
            if [ -f "$script_path" ] && [[ "$script_path" == *"/Library/Application Support"* ]]; then
                warning "Znaleziono powiązany skrypt: $script_path"
                read -p "Czy usunąć ten skrypt? (tak/nie): " confirm
                if [ "$confirm" == "tak" ]; then
                    rm -rf "$(dirname "$script_path")"
                    success "Usunięto katalog: $(dirname "$script_path")"
                fi
            fi
        done
    fi
}

# Funkcja skanowania i usuwania podejrzanych agentów
scan_and_remove() {
    local locations=(
        "$HOME/Library/LaunchAgents"
        "/Library/LaunchAgents"
        "/Library/LaunchDaemons"
    )
    
    local found_suspicious=0
    
    for location in "${locations[@]}"; do
        if [ ! -d "$location" ]; then
            continue
        fi
        
        info "Skanowanie: $location"
        
        find "$location" -name "*.plist" 2>/dev/null | while read -r plist_file; do
            if analyze_plist_simple "$plist_file"; then
                found_suspicious=1
                alert "Znaleziono podejrzany agent: $plist_file"
                
                # Pokaż szczegóły
                echo ""
                echo "Szczegóły pliku:"
                plutil -p "$plist_file" 2>/dev/null | head -20
                echo ""
                
                read -p "Czy usunąć ten agent? (tak/nie): " confirm
                if [ "$confirm" == "tak" ]; then
                    remove_agent "$plist_file"
                else
                    warning "Pominięto: $plist_file"
                fi
                echo ""
            fi
        done
    done
    
    if [ $found_suspicious -eq 0 ]; then
        success "Nie znaleziono podejrzanych agentów"
    fi
}

# Funkcja usuwania konkretnego agenta
remove_specific_agent() {
    local agent_name="$1"
    
    if [ -z "$agent_name" ]; then
        echo "Podaj nazwę agenta (np. com.bugbusters.malicious)"
        exit 1
    fi
    
    local plist_files=(
        "$HOME/Library/LaunchAgents/${agent_name}.plist"
        "/Library/LaunchAgents/${agent_name}.plist"
        "/Library/LaunchDaemons/${agent_name}.plist"
    )
    
    local found=0
    for plist_file in "${plist_files[@]}"; do
        if [ -f "$plist_file" ]; then
            found=1
            alert "Znaleziono agenta: $plist_file"
            remove_agent "$plist_file"
        fi
    done
    
    if [ $found -eq 0 ]; then
        warning "Nie znaleziono agenta: $agent_name"
    fi
}

# Funkcja zabijania procesów związanych z agentami
kill_agent_processes() {
    info "Szukanie procesów związanych z podejrzanymi agentami..."
    
    # Znajdź wszystkie procesy bash/sh/python uruchomione z podejrzanych lokalizacji
    ps aux | grep -E "(bash|sh|python|perl).*/(Library/Application Support|/tmp|/var/tmp)" | \
        grep -v grep | while read -r line; do
        local pid=$(echo "$line" | awk '{print $2}')
        local cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')
        
        alert "Znaleziono podejrzany proces:"
        echo "  PID: $pid"
        echo "  CMD: $cmd"
        echo ""
        
        read -p "Czy zabić ten proces? (tak/nie): " confirm
        if [ "$confirm" == "tak" ]; then
            kill -9 "$pid" 2>/dev/null && success "Zabito proces: $pid" || warning "Nie udało się zabić procesu: $pid"
        fi
    done
}

# Funkcja czyszczenia logów i danych
cleanup_agent_data() {
    local data_dirs=(
        "/Library/Application Support/BugBusters"
        "$HOME/Library/Application Support/BugBusters"
    )
    
    for data_dir in "${data_dirs[@]}"; do
        if [ -d "$data_dir" ]; then
            alert "Znaleziono katalog z danymi: $data_dir"
            ls -la "$data_dir"
            echo ""
            
            read -p "Czy usunąć ten katalog i jego zawartość? (tak/nie): " confirm
            if [ "$confirm" == "tak" ]; then
                rm -rf "$data_dir"
                success "Usunięto katalog: $data_dir"
            fi
        fi
    done
}

# Menu główne
show_menu() {
    echo ""
    echo "🔵 BLUE TEAM - Defender - Usuwanie podejrzanych agentów"
    echo "========================================================"
    echo "1. Skanuj i usuń podejrzane agenty"
    echo "2. Usuń konkretnego agenta (podaj nazwę)"
    echo "3. Zabij podejrzane procesy"
    echo "4. Wyczyść dane i logi agentów"
    echo "5. Pełne czyszczenie (wszystko powyżej)"
    echo "6. Wyjście"
    echo ""
    read -p "Wybierz opcję (1-6): " choice
    
    case $choice in
        1)
            scan_and_remove
            ;;
        2)
            read -p "Podaj nazwę agenta (np. com.bugbusters.malicious): " agent_name
            remove_specific_agent "$agent_name"
            ;;
        3)
            kill_agent_processes
            ;;
        4)
            cleanup_agent_data
            ;;
        5)
            scan_and_remove
            kill_agent_processes
            cleanup_agent_data
            success "Pełne czyszczenie zakończone"
            ;;
        6)
            exit 0
            ;;
        *)
            echo "Nieprawidłowa opcja"
            ;;
    esac
}

# Obsługa argumentów wiersza poleceń
if [ "$1" == "--remove" ] && [ -n "$2" ]; then
    remove_specific_agent "$2"
elif [ "$1" == "--scan" ]; then
    scan_and_remove
elif [ "$1" == "--kill-processes" ]; then
    kill_agent_processes
elif [ "$1" == "--cleanup" ]; then
    cleanup_agent_data
else
    show_menu
fi

