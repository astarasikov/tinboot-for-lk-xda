export PATH=${PATH}:/home/alexander/builds/HTCFlasher-20080806/src/:/home/alexander/handhelds/armv6/codesourcery/bin/
export CROSS_COMPILE=arm-none-eabi-
export AS=${CROSS_COMPILE}as
export OBJCOPY=${CROSS_COMPILE}objcopy

rm *.NBH
$AS tinboot.S -o tinboot.o
$OBJCOPY tinboot.o -O binary tinboot
cp partition_table output.nb.payload
cat tinboot >> output.nb.payload
wine NBMerge.exe -titan output.nb
yang -F POOPLOADER.NBH -f output.nb -t 0x400 -s 64 -d KOVS***** -c 11111111 -v 1.0.XDAPOOP -l WWE
