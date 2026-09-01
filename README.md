# sway-setup

### 1. Перенесите конфиги вручную
Скопируйте папки из репозитория в `~/.config/`:
- `~/.config -> /sway/, /dunst/, /xdg-desktop-portal/`

### 2. Установка пакетов и зависимостей
Запустите в терминале:

```bash
sudo apt update && sudo apt install -y sway swaylock swayidle brightnessctl kitty fonts-jetbrains-mono bemenu dunst libnotify-bin pipewire wireplumber pipewire-pulse pavucontrol blueman grim slurp jq wl-clipboard wlsunset xdg-desktop-portal xdg-desktop-portal-wlr golang-go && export PATH="$HOME/go/bin:$PATH" && command -v cliphist >/dev/null || go install go.senan.xyz/cliphist@latest && chmod +x ~/.config/sway/scripts/*.sh
```

### 3. Настройка аудио (запускайте уже внутри Sway)
```bash
systemctl --user disable --now pulseaudio.service pulseaudio.socket 2>/dev/null || true && systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service && systemctl --user restart xdg-desktop-portal-wlr.service xdg-desktop-portal.service && sudo usermod -aG video "$USER"
```

### 4. Перезайдите в систему
Выйдите и зайдите обратно, чтобы применилась группа `video`. Затем выберите Sway в меню входа (шестерёнка справа внизу).
