
#!/usr/bin/env sh

icon="/home/maaru/.icons/language.svg"

# Определяем директорию скрипта
scrDir=$(dirname "$(realpath "$0")")

# Смена раскладки клавиатуры
hyprctl devices -j | jq -r '.keyboards[].name' | while read -r keyName; do
    hyprctl switchxkblayout "$keyName" next
done

# Получение текущей активной раскладки
layMain=$(hyprctl -j devices | jq -r '.keyboards[] | select(.main == true) | .active_keymap')

# Отправка уведомления
notify-send -a "t1" -r 91190 -t 800 -i "$icon" "$layMain"
