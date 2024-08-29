#!/bin/bash

# Пути к иконкам
ICON_PACMAN="$HOME/.icons/pacman.svg"
ICON_PARU="$HOME/.icons/Paruyay.svg"
ICON_YAY="$HOME/.icons/Paruyay.svg"
ICON_FLATPAK="$HOME/.icons/flatpak.png"
ICON_SUCCESS="$HOME/.icons/success.svg"
ICON_ERROR="$HOME/.icons/error.svg"

# Цвета для вывода текста
COLOR_YELLOW='\033[1;33m'
COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_CYAN='\033[0;36m'
COLOR_RESET='\033[0m'

# Функция обновления
update_system() {
    echo -e "${COLOR_YELLOW}\n=== Обновление pacman ===${COLOR_RESET}"
    if ! sudo pacman -Syu; then
        notify-send "Ошибка" "Ошибка обновления через pacman!" -i "$ICON_ERROR"
        return 1
    fi

    echo -e "${COLOR_GREEN}\n=== Обновление paru ===${COLOR_RESET}"
    if ! paru -Syu; then
        notify-send "Ошибка" "Ошибка обновления через paru!" -i "$ICON_ERROR"
        return 1
    fi

    echo -e "${COLOR_BLUE}\n=== Обновление yay ===${COLOR_RESET}"
    if ! yay -Syu; then
        notify-send "Ошибка" "Ошибка обновления через yay!" -i "$ICON_ERROR"
        return 1
    fi

    echo -e "${COLOR_CYAN}\n=== Обновление flatpak ===${COLOR_RESET}"
    if ! flatpak update; then
        notify-send "Ошибка" "Ошибка обновления через flatpak!" -i "$ICON_ERROR"
        return 1
    fi

    return 0
}

# Основной цикл
while true; do
    nitch

    echo -e "\nДоступные обновления:"

    # Проверка обновлений для pacman
    pacman_updates=$(pacman -Qu)
    echo -e "${COLOR_YELLOW}  ===> pacman 󰮯 :"
    echo "$pacman_updates" | awk '{print "       " $1}'

    # Проверка обновлений для paru
    paru_updates=$(paru -Qu)
    echo -e "${COLOR_GREEN}  ===> paru 󰣇 :"
    echo "$paru_updates" | awk '{print "       " $1}'

    # Проверка обновлений для yay
    yay_updates=$(yay -Qu)
    echo -e "${COLOR_BLUE}  ===> yay 󰣇 :"
    echo "$yay_updates" | awk '{print "       " $1}'

    # Проверка обновлений для flatpak
    flatpak_updates=$(flatpak remote-ls --updates)
    echo -e "${COLOR_CYAN}  ===> flatpak  :"
    echo "$flatpak_updates" | awk '{print "       " $1}'

    echo -e "\nНачало обновления системы..."
    
    if update_system; then
        notify-send "Обновление системы" "Все обновления завершены успешно!" -i "$ICON_SUCCESS"
        echo -e "\nОбновление завершено успешно!"
    else
        notify-send "Обновление системы" "Обновление прервано! Повторите попытку." -i "$ICON_ERROR"
        echo -e "\nОбновление прервано."
        continue
    fi

    nitch

    figlet -f mini "' -->  bye  <-- '
    ' -->  bye  <-- '
    ' -->  maaru ^^  <-- '  "

    sleep 5
    break
done
