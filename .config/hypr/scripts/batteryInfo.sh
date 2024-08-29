#!/bin/bash

# Иконки для уведомлений
ICON_BATTERY_LOW="$HOME/.icons/battery_low.svg"
ICON_BATTERY_CRITICAL="$HOME/.icons/battery_critical.svg"
ICON_BATTERY_NORMAL="$HOME/.icons/battery_normal.svg"

# Цвета для вывода в терминале
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[1;33m'
COLOR_GREEN='\033[0;32m'
COLOR_RESET='\033[0m'

# Получаем информацию о батарее
battery_info=$(acpi -b)

# Извлекаем процент заряда
battery_percent=$(echo "$battery_info" | grep -oP '\d+(?=%)')

# Извлекаем статус батареи
battery_status=$(echo "$battery_info" | grep -oP 'Charging|Discharging')

# Уведомления в зависимости от уровня заряда
if [[ "$battery_status" == "Charging" ]]; then
    if (( battery_percent <= 20 )); then
        dunstify -i "$ICON_BATTERY_LOW" -u critical "Батарея" "Батарея заряжается. Заряд: ${battery_percent}%!"
    elif (( battery_percent <= 50 )); then
        dunstify -i "$ICON_BATTERY_NORMAL" -u normal "Батарея" "Батарея заряжается. Заряд: ${battery_percent}%."
    else
        dunstify -i "$ICON_BATTERY_NORMAL" -u low "Батарея" "Батарея заряжается. Заряд: ${battery_percent}%."
    fi
else
    if (( battery_percent <= 10 )); then
        dunstify -i "$ICON_BATTERY_CRITICAL" -u critical "Батарея" "Батарея разряжена! Заряд: ${battery_percent}%!"
    elif (( battery_percent <= 20 )); then
        dunstify -i "$ICON_BATTERY_LOW" -u critical "Батарея" "Батарея почти разряжена. Заряд: ${battery_percent}%!"
    else
        dunstify -i "$ICON_BATTERY_NORMAL" -u low "Батарея" "Батарея. Заряд: ${battery_percent}%."
    fi
fi

