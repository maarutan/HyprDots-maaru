#!/bin/bash

# Директория с обоями
WALLPAPER_DIR="/home/maaru/wallpapers"

# Файл для хранения пути к текущим обоям
CURRENT_WALLPAPER_FILE="/home/maaru/.current_wallpaper"

# Проверяем, что директория с обоями не пуста
if [ ! "$(ls -A "$WALLPAPER_DIR")" ]; then
    echo "Директория с обоями пуста!"
    exit 1
fi

# Проверяем и запускаем swww-daemon, если он не запущен
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1  # Ждём немного, чтобы демон успел запуститься
fi

# Получаем текущее изображение
if [ -f "$CURRENT_WALLPAPER_FILE" ]; then
    CURRENT_WALLPAPER=$(< "$CURRENT_WALLPAPER_FILE")
else
    # Если файл не существует, берем первое изображение из директории
    CURRENT_WALLPAPER="$WALLPAPER_DIR/$(ls "$WALLPAPER_DIR" | head -n 1)"
    echo "$CURRENT_WALLPAPER" > "$CURRENT_WALLPAPER_FILE"
fi

# Получаем список всех обоев
WALLPAPER_LIST=($(ls "$WALLPAPER_DIR"))

# Находим текущий индекс
for i in "${!WALLPAPER_LIST[@]}"; do
    if [ "${WALLPAPER_LIST[$i]}" == "$(basename "$CURRENT_WALLPAPER")" ]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Определяем направление и устанавливаем новый индекс
case $1 in
    right)
        NEW_INDEX=$(( (CURRENT_INDEX + 1) % ${#WALLPAPER_LIST[@]} ))
        ;;
    left)
        NEW_INDEX=$(( (CURRENT_INDEX - 1 + ${#WALLPAPER_LIST[@]}) % ${#WALLPAPER_LIST[@]} ))
        ;;
    *)
        echo "Usage: $0 {right|left}"
        exit 1
        ;;
esac

# Получаем новый путь
NEW_WALLPAPER="$WALLPAPER_DIR/${WALLPAPER_LIST[$NEW_INDEX]}"

# Применяем обои с помощью swww
swww img "$NEW_WALLPAPER" --transition-type fade --transition-duration .8 # Сохраняем новое изображение
echo "$NEW_WALLPAPER" > "$CURRENT_WALLPAPER_FILE"

