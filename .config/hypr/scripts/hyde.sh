#!/usr/bin/env sh

#// hyde envs

export confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
export hydeConfDir="${confDir}/hyde"
export cacheDir="$HOME/.cache/hyde"
export thmbDir="${cacheDir}/thumbs"
export dcolDir="${cacheDir}/dcols"
export hashMech="sha1sum"

get_hashmap()
{
    unset wallHash
    unset wallList
    unset skipStrays
    unset verboseMap

    for wallSource in "$@"; do
        [ -z "${wallSource}" ] && continue
        [ "${wallSource}" == "--skipstrays" ] && skipStrays=1 && continue
        [ "${wallSource}" == "--verbose" ] && verboseMap=1 && continue

        hashMap=$(find "${wallSource}" -type f \( -iname "*.gif" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec "${hashMech}" {} + | sort -k2)
        if [ -z "${hashMap}" ] ; then
            echo "WARNING: No image found in \"${wallSource}\""
            continue
        fi

        while read -r hash image ; do
            wallHash+=("${hash}")
            wallList+=("${image}")
        done <<< "${hashMap}"
    done

    if [ -z "${#wallList[@]}" ] || [[ "${#wallList[@]}" -eq 0 ]] ; then
        if [[ "${skipStrays}" -eq 1 ]] ; then
            return 1
        else
            echo "ERROR: No image found in any source"
            exit 1
        fi
    fi

    if [[ "${verboseMap}" -eq 1 ]] ; then
        echo "// Hash Map //"
        for indx in "${!wallHash[@]}" ; do
            echo ":: \${wallHash[${indx}]}=\"${wallHash[indx]}\" :: \${wallList[${indx}]}=\"${wallList[indx]}\""
        done
    fi
}

[ -f "${hydeConfDir}/hyde.conf" ] && source "${hydeConfDir}/hyde.conf"

#// hypr vars

if printenv HYPRLAND_INSTANCE_SIGNATURE &> /dev/null; then
    export hypr_border="$(hyprctl -j getoption decoration:rounding | jq '.int')"
    export hypr_width="$(hyprctl -j getoption general:border_size | jq '.int')"
fi

#// extra fns

pkg_installed()
{
    local pkgIn=$1
    if pacman -Qi "${pkgIn}" &> /dev/null ; then
        return 0
    elif pacman -Qi "flatpak" &> /dev/null && flatpak info "${pkgIn}" &> /dev/null ; then
        return 0
    elif command -v "${pkgIn}" &> /dev/null ; then
        return 0
    else
        return 1
    fi
}

get_aurhlpr()
{
    if pkg_installed yay
    then
        aurhlpr="yay"
    elif pkg_installed paru
    then
        aurhlpr="paru"
    fi
}

set_conf()
{
    local varName="${1}"
    local varData="${2}"
    touch "${hydeConfDir}/hyde.conf"

    if [ $(grep -c "^${varName}=" "${hydeConfDir}/hyde.conf") -eq 1 ] ; then
        sed -i "/^${varName}=/c${varName}=\"${varData}\"" "${hydeConfDir}/hyde.conf"
    else
        echo "${varName}=\"${varData}\"" >> "${hydeConfDir}/hyde.conf"
    fi
}

set_hash()
{
    local hashImage="${1}"
    "${hashMech}" "${hashImage}" | awk '{print $1}'
}

