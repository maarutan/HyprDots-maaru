
#!/bin/bash
# Файл для хранения пути к текущим обоям
CURRENT_WALLPAPER_FILE="/home/maaru/.current_wallpaper"

# Проверяем наличие файла
if [ -f "$CURRENT_WALLPAPER_FILE" ]; then
    CURRENT_WALLPAPER=$(cat "$CURRENT_WALLPAPER_FILE")
    
    # Проверяем и запускаем swww-daemon, если он не запущен
    if ! pgrep -x "swww-daemon" > /dev/null; then
        swww-daemon &
        sleep 1  # Ждём немного, чтобы демон успел запуститься
    fi

    # Устанавливаем обои с помощью swww
    swww img "$CURRENT_WALLPAPER" --transition-type simple --transition-duration 1
fi

