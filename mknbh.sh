export PATH=${PATH}:/home/alexander/builds/HTCFlasher-20080806/src/:/home/alexander/handhelds/armv6/codesourcery/bin/
export CROSS_COMPILE=arm-none-eabi-
export AS=${CROSS_COMPILE}as
export OBJCOPY=${CROSS_COMPILE}objcopy

rm *.NBH
rm out.nb
rm tinboot tinboot.o
$AS tinboot.S -o tinboot.o
$OBJCOPY tinboot.o -O binary tinboot
./generate
yang -F HDLOADER.NBH -f out.nb -t 0x400 -s 64 -d PB9210000 -c 11111111 -v 1.42.1337 -l WWE
