#-ico "/usr/share/icons/Papirus-Dark/symbolic/actions/view-app-grid-symbolic.svg)!/usr/bin/env bash

DOCK_HEIGHT=120
INITIAL_LAUNCH_FLAGS=( -d -i 40 -w 10 -mb 6 -hd 0 -c /home/maaru/.config/rofi/launchers/type-3/launcher_1.sh)
HIDE_SIGNAL="pkill -37 -f nwg-dock-hyprland"
SHOW_SIGNAL="pkill -36 -f nwg-dock-hyprland"

toggle_dock() {
  if [ "$1" = "show" ]; then
    $SHOW_SIGNAL
  else
    $HIDE_SIGNAL
  fi
}

get_active_ws_id() {
  local ws_id=$(echo "$1" | awk 'NR==2')
  local special_ws_id=$(echo "$1" | awk 'NR==3')

  if [ "$special_ws_id" -eq 0 ]; then
    echo "$ws_id"
  else
    echo "$special_ws_id"
  fi
}

show_hide_dock() {
  local monitor_info=$(hyprctl monitors -j | jq -r '.[] | select (.focused == true) | .height, .activeWorkspace.id, .specialWorkspace.id')
  local monitor_height=$(echo "$monitor_info" | awk 'NR==1')
  local ws_id=$(get_active_ws_id "$monitor_info")
  local window_count=$(hyprctl workspaces -j | jq ".[] | select(.id == $ws_id) | .windows")

  if [ "$window_count" -eq 0 ]; then
    toggle_dock "show"
    return
  fi

  # get all windows Y pos and Y size on the active workspace
  local windows_data=$(hyprctl clients -j | jq -c ".[] | select(.workspace.id == $ws_id) | {at: .at[1], size: .size[1]}")
  local should_show=1

  while IFS= read -r window; do
    local pos_y=$(echo "$window" | jq -r '.at')
    local size_y=$(echo "$window" | jq -r '.size')
    local free_space=$((monitor_height - pos_y - size_y))

    if [ "$free_space" -lt "$DOCK_HEIGHT" ]; then
      should_show=0
      break
    fi
  done <<<"$windows_data"

  if [ "$should_show" -eq 1 ]; then
    toggle_dock "show"
  else
    toggle_dock "hide"
  fi
}

initial_dock_launch() {
  nwg-dock-hyprland "${INITIAL_LAUNCH_FLAGS[@]}" >/dev/null 2>&1 &

  # need to wait this much only if using '-d', I don't know why. Needs only 0.1 with '-r'
  sleep 0.6 && show_hide_dock
}

function handle {
  case $1 in
  changefloatingmode* | workspacev2* | closewindow* | openwindow* | activespecial*)
    show_hide_dock
    ;;

  focusedmon*)
    # buggy with "-d" if you hover on the hotspot on one monitor it stops moving between monitors, works perfect with "-r"
    toggle_dock "hide" && show_hide_dock
    ;;
  esac
}

initial_dock_launch

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
