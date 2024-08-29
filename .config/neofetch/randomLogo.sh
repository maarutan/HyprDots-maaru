#!/bin/bash

# Путь к директории с логотипами
LOGO_DIR="$HOME/.config/neofetch/pngs"

# Путь к файлу кэша
CACHE_FILE="$HOME/.config/neofetch/logo_cache.txt"

# Массив логотипов
LOGOS=(
    "$LOGO_DIR/loli.png"
    "$LOGO_DIR/aisaka.png"
    "$LOGO_DIR/olbedo.png"
    "$LOGO_DIR/pochita.png"
    "$LOGO_DIR/ryuzaki.png"
)

# Выбрать случайный логотип
RANDOM_LOGO="${LOGOS[$RANDOM % ${#LOGOS[@]}]}"

# Записать путь к выбранному логотипу в файл кэша
echo "$RANDOM_LOGO" > "$CACHE_FILE"

echo "Updated logo cache to: $RANDOM_LOGO"

