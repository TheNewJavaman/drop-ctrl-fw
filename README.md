# drop-ctrl-fw

Custom QMK firmware for the [Drop CTRL](https://drop.com/buy/drop-ctrl-mechanical-keyboard) keyboard.

## Effects

- **Per-key reactive white** — keys flash white on press and fade out over 500ms
- **Rolling white underglow** — sinusoidal brightness wave rolling around the base LED strip

## Prerequisites

- ARM toolchain: `sudo apt install binutils-arm-none-eabi gcc-arm-none-eabi libnewlib-arm-none-eabi build-essential`
- Python: [uv](https://docs.astral.sh/uv/)

## Setup

```bash
# Clone QMK 0.26.11 (last version with arm_atsam support)
git clone --depth 1 --branch 0.26.11 https://github.com/qmk/qmk_firmware.git qmk_firmware

# Symlink the keymap into the QMK tree
ln -s "$(pwd)/keymap" qmk_firmware/keyboards/massdrop/ctrl/keymaps/custom

# Python deps
uv venv .venv && uv pip install -r qmk_firmware/requirements.txt && uv pip install qmk

# Build mdloader (flash tool)
git clone --depth 1 https://github.com/Massdrop/mdloader.git && cd mdloader && make && cd ..

# Build the default firmware (used as backup during safe flash)
source .venv/bin/activate
cd qmk_firmware && make massdrop/ctrl:default && cd ..
```

## Build & Flash

```bash
source .venv/bin/activate
cd qmk_firmware && make massdrop/ctrl:custom && cd ..

# Safe flash with 30-second auto-revert
./flash.sh
```

The flash script waits for you to press ENTER to confirm the new firmware works. If you don't confirm within 30 seconds, it automatically reflashes the default firmware.

## Fn Layer

| Key | Function |
|-----|----------|
| Fn+E / Fn+S | Brightness up/down |
| Fn+Q / Fn+W | Effect speed down/up |
| Fn+D / Fn+A | Next/prev effect |
| Fn+Z | Toggle RGB (all / keys-only / underglow-only / off) |
| Fn+B | Bootloader mode (hold 0.5s) |
