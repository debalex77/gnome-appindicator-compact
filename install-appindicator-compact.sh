#!/usr/bin/env bash

set -Eeuo pipefail

EXTENSION_UUID="appindicatorsupport@rgcjonas.gmail.com"

SOURCE_DIR="/usr/share/gnome-shell/extensions/${EXTENSION_UUID}"
DESTINATION_BASE="${HOME}/.local/share/gnome-shell/extensions"
DESTINATION_DIR="${DESTINATION_BASE}/${EXTENSION_UUID}"
TARGET_FILE="${DESTINATION_DIR}/indicatorStatusIcon.js"

OLD_VALUE="-natural-hpadding: 10px"
NEW_VALUE="-natural-hpadding: 6px"

echo "Configurare extensie GNOME: ${EXTENSION_UUID}"

# Verificăm dacă extensia de sistem există.
if [[ ! -d "${SOURCE_DIR}" ]]; then
    echo "Eroare: extensia nu există în:"
    echo "  ${SOURCE_DIR}"
    echo
    echo "Verifică extensiile instalate cu:"
    echo "  ls /usr/share/gnome-shell/extensions/"
    exit 1
fi

# Verificăm dacă fișierul ce trebuie modificat există.
if [[ ! -f "${SOURCE_DIR}/indicatorStatusIcon.js" ]]; then
    echo "Eroare: fișierul indicatorStatusIcon.js nu există în extensie."
    exit 1
fi

mkdir -p "${DESTINATION_BASE}"

# Facem backup dacă există deja o copie locală.
if [[ -d "${DESTINATION_DIR}" ]]; then
    BACKUP_DIR="${DESTINATION_DIR}.backup-$(date +%Y%m%d-%H%M%S)"

    echo "Copia existentă va fi salvată în:"
    echo "  ${BACKUP_DIR}"

    mv "${DESTINATION_DIR}" "${BACKUP_DIR}"
fi

echo "Copiez extensia în directorul utilizatorului..."

cp -a "${SOURCE_DIR}" "${DESTINATION_DIR}"

echo "Modific padding-ul: 10px -> 6px"

if grep -Fq -- "${OLD_VALUE}" "${TARGET_FILE}"; then
    sed -i "s/${OLD_VALUE}/${NEW_VALUE}/g" "${TARGET_FILE}"
elif grep -Fq -- "${NEW_VALUE}" "${TARGET_FILE}"; then
    echo "Modificarea este deja prezentă."
else
    echo "Avertisment: textul căutat nu a fost găsit:"
    echo "  ${OLD_VALUE}"
    echo "Este posibil ca structura extensiei să se fi schimbat."
fi

echo "Reîncarc extensia..."

gnome-extensions disable "${EXTENSION_UUID}" 2>/dev/null || true
gnome-extensions enable "${EXTENSION_UUID}"

echo
echo "Configurarea s-a încheiat."
echo
echo "Pe Wayland trebuie să ieșiți din sesiune și să vă autentificați din nou."
echo "Pe X11 poteși încerca: Alt+F2, apoi 'r' -> Enter."
