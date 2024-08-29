#!/bin/bash

# Путь к файлу с процессом док-станции
DOCK_PID_FILE="/tmp/nwg-dock-pid"

# Получаем PID док-станции и записываем его в файл
if pgrep -f nwg-dock-hyprland > "$DOCK_PID_FILE"; then
    DOCK_PID=$(cat "$DOCK_PID_FILE")
else
    echo "Док-станция не запущена. Убедитесь, что она запущена перед выполнением скрипта."
    exit 1
fi

# Проверяем активные окна
while true; do
    # Проверяем наличие окон на рабочем столе
    if [ "$(hyprctl clients -j | jq '.[] | select(.visible == true)')" ]; then
        # Если окна видимы, скрываем док
        kill -SIGUSR1 "$DOCK_PID"
    else
        # Если окон нет, показываем док
        kill -SIGUS
#!/bin/bash

# Путь к файлу с процессом док-станции
DOCK_PID_FILE="/tmp/nwg-dock-pid"

# Получаем PID док-станции и записываем его в файл
if pgrep -f nwg-dock-hyprland > "$DOCK_PID_FILE"; then
    DOCK_PID=$(cat "$DOCK_PID_FILE")
else
    echo "Док-станция не запущена. Убедитесь, что она запущена перед выполнением скрипта."
    exit 1
fi

# Проверяем активные окна
while true; do
    # Проверяем наличие видимых окон
    if [ "$(hyprctl clients -j | jq '.[] | select(.visible == true)')" ]; then
        # Если окна видимы, скрываем док
        kill -SIGUSR1 "$DOCK_PID"
    else
        # Если окон нет, показываем док
        kill -SIGUSR2 "$DOCK_PID"
    fi
    sleep 1
done
