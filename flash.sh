#!/bin/bash

# . ./.venv/bin/activate  # Uncomment if using a virtual environment

list1=$(ls /dev/tty*)
echo "Press enter to continue after you have plugged in the board while holding the SW1 button to place it into update mode"
read

sleep 6s

list2=$(ls /dev/tty*)
flash_port=$(comm -13 <(echo "$list1" | sort) <(echo "$list2" | sort))

if [ -z "$flash_port" ]; then
    echo "No new device detected. Exiting."
    exit 1
fi

echo "Detected new device on $flash_port"
sleep 4s
#Enter virtual enviroment for building and flashing firmware
. ./.venv/bin/activate
#Build the firmware using docker
docker build -t decoder ./decoder
docker run --rm -v ./decoder/build_out:/out -v ./decoder/:/decoder -v ./secrets:/serets -e DECODER_ID=0xdeadbeef decoder
# Flash the firmware
python3 -m tools.ectf25.utils.flash ./decoder/build_out/max78000.bin $flash_port
# Exit virtual enviroment so that shell is usable again
deactivate
echo "Successfully flashed to board"
