export PATH=${PATH}:/home/alexander/builds/HTCFlasher-20080806/src/:/home/alexander/handhelds/armv6/codesourcery/bin/
export CROSS_COMPILE=arm-none-eabi-
export AS=${CROSS_COMPILE}as
export OBJCOPY=${CROSS_COMPILE}objcopy

pushd .
cd /home/alexander/handhelds/htc/lk-msm7200a-htc-wince
bash build.sh
popd
cp /home/alexander/handhelds/htc/lk-msm7200a-htc-wince/build-msm7200a_htc_wince/lk.bin .
rm *.NBH
rm out.nb
$AS tinboot.S -o tinboot.o
$OBJCOPY tinboot.o -O binary tinboot
./generate
yang -F POOPLOADER.NBH -f out.nb -t 0x400 -s 64 -d KOVS***** -c 11111111 -v 1.0.XDAPOOP -l WWE
