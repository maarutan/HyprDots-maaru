#!/bin/bash

function get_volume {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -n 1 | tr -d '%'
}

function is_mute {
    pactl get-sink-mute @DEFAULT_SINK@ | grep 'yes' > /dev/null
}

function send_notification {
    DIR=$(dirname "$0")
    volume=$(get_volume)
    [ -z "$volume" ] && volume=0

    # Выбор иконки в зависимости от уровня громкости
    if is_mute; then
        icon_name="/usr/share/icons/Faba/48x48/notifications/notification-audio-volume-muted.svg"
    elif [ "$volume" -lt "10" ]; then
        icon_name="/usr/share/icons/Faba/48x48/notifications/notification-audio-volume-low.svg"
    elif [ "$volume" -lt "30" ]; then
        icon_name="/usr/share/icons/Faba/48x48/notifications/notification-audio-volume-low.svg"
    elif [ "$volume" -lt "70" ]; then
        icon_name="/usr/share/icons/Faba/48x48/notifications/notification-audio-volume-medium.svg"
    else
        icon_name="/usr/share/icons/Faba/48x48/notifications/notification-audio-volume-high.svg"
    fi

    # Отправка уведомления
    $DIR/notify-send.sh "$volume%" -i "$icon_name" -t 2000 -h int:value:"$volume" --replace=555
}

function adjust_volume {
    local delta=$1
    local new_volume=$(($(get_volume) + delta))

    # Ограничение уровня громкости от 0% до 100%
    if [ "$new_volume" -gt 100 ]; then
        new_volume=100
    elif [ "$new_volume" -lt 0 ]; then
        new_volume=0
    fi

    pactl set-sink-volume @DEFAULT_SINK@ "${new_volume}%"
}

case $1 in
    up)
        pactl set-sink-mute @DEFAULT_SINK@ 0
        adjust_volume 5
        send_notification
        ;;
    down)
        pactl set-sink-mute @DEFAULT_SINK@ 0
        adjust_volume -5
        send_notification
        ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        if is_mute; then
            DIR=$(dirname "$0")
            $DIR/notify-send.sh -i "/usr/share/icons/Faba/48x48/notifications/notification-audio-volume-muted.svg" --replace=555 -u normal "Mute" -t 2000
        else
            send_notification
        fi
        ;;
    *)
        echo "Usage: $0 {up|down|mute}"
        ;;
esac
