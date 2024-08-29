#!/usr/bin/env bash

# Пути к иконкам
icon_name="/home/maaru/.icons/brightness.svg"

# Функция для получения текущего уровня яркости в диапазоне от 0 до 100
get_brightness() {
    local current_brightness=$(brightnessctl get)
    local max_brightness=$(brightnessctl max)
    echo $(( 100 * current_brightness / max_brightness ))
}

# Функция для установки яркости в диапазоне от 0 до 100
set_brightness() {
    local brightness_percent=$1
    local max_brightness=$(brightnessctl max)
    local brightness_value=$(( max_brightness * brightness_percent / 100 ))
    brightnessctl set "$brightness_value"
}

# Функция для отправки уведомлений с помощью notify-send.sh
send_notification() {
    DIR=$(dirname "$0")
    brightness=$(get_brightness)
    [ -z "$brightness" ] && brightness=0

    # Отправляем уведомление
    "$DIR/notify-send.sh" -i "$icon_name" -t 2000 -h int:value:"$brightness" --replace=555 "$brightness%"
}

# Основной блок обработки аргументов
case "$1" in
    up)
        current_brightness=$(get_brightness)
        if [ "$current_brightness" -lt 100 ]; then
            new_brightness=$((current_brightness + 5))
            if [ "$new_brightness" -gt 100 ]; then
                new_brightness=100
            fi
            set_brightness "$new_brightness"
            send_notification
        fi
        ;;
    down)
        current_brightness=$(get_brightness)
        if [ "$current_brightness" -gt 0 ]; then
            new_brightness=$((current_brightness - 5))
            if [ "$new_brightness" -lt 0 ]; then
                new_brightness=0
            fi
            set_brightness "$new_brightness"
            send_notification
        fi
        ;;
    *)
        echo "Использование: $0 {up|down}"
        exit 1
        ;;
esac

