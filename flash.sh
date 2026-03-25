#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MDLOADER="$SCRIPT_DIR/mdloader/build/mdloader"
NEW_FW="$SCRIPT_DIR/qmk_firmware/massdrop_ctrl_custom.bin"
BACKUP_FW="$SCRIPT_DIR/qmk_firmware/massdrop_ctrl_default.bin"
TIMEOUT=30

# --- Helpers ---

die() { echo "ERROR: $*" >&2; exit 1; }

wait_for_bootloader() {
    echo "Waiting for keyboard in bootloader mode..."
    while ! ls /dev/ttyACM* &>/dev/null; do
        sleep 0.5
    done
    sleep 1 # let the device settle
    echo "Bootloader detected."
}

flash() {
    local fw="$1"
    local label="$2"
    echo "Flashing $label..."
    "$MDLOADER" --first --download "$fw" --restart
    echo "$label flashed successfully."
}

# --- Preflight checks ---

[[ -x "$MDLOADER" ]]  || die "mdloader not found at $MDLOADER"
[[ -f "$NEW_FW" ]]     || die "Custom firmware not found at $NEW_FW"
[[ -f "$BACKUP_FW" ]]  || die "Backup firmware not found at $BACKUP_FW"

# --- Step 1: Flash new firmware ---

echo "=== Drop CTRL Safe Flash ==="
echo ""
echo "  New firmware:    $NEW_FW"
echo "  Backup firmware: $BACKUP_FW"
echo "  Revert timeout:  ${TIMEOUT}s"
echo ""
echo "Put your keyboard in bootloader mode:"
echo "  - Hold Fn+B for ~0.5 seconds (LEDs turn off), OR"
echo "  - Press the physical reset button on the bottom"
echo ""

wait_for_bootloader
flash "$NEW_FW" "custom firmware"

echo ""
echo "Keyboard is rebooting into the new firmware..."
sleep 2

# --- Step 2: Confirm or revert ---

echo ""
echo ">>> Press ENTER to KEEP the new firmware. <<<"
echo ">>> If you do nothing, it reverts in ${TIMEOUT}s. <<<"
echo ""

for i in $(seq "$TIMEOUT" -1 1); do
    printf "\r  Reverting in %2ds... " "$i"
    if read -r -t 1 2>/dev/null; then
        echo ""
        echo "Confirmed! Keeping new firmware. Done."
        exit 0
    fi
done

# --- Step 3: Revert ---

echo ""
echo ""
echo "No confirmation received — reverting to backup firmware."
echo ""
echo "Put the keyboard back in bootloader mode:"
echo "  - Hold Fn+B for ~0.5 seconds, OR"
echo "  - Press the physical reset button on the bottom"
echo ""

wait_for_bootloader
flash "$BACKUP_FW" "backup firmware"

echo ""
echo "Backup firmware restored. You're back to the default keymap."
