export PATH=${PATH}:/home/alexander/builds/HTCFlasher-20080806/src/:/home/alexander/handhelds/armv6/codesourcery/bin/
export CROSS_COMPILE=arm-none-eabi-
export AS=${CROSS_COMPILE}as
export OBJCOPY=${CROSS_COMPILE}objcopy

#pushd .
#cd /home/alexander/handhelds/htc/lk-msm7200a-htc-wince
#bash photon.sh
#popd
#rm lk.bin
#cp /home/alexander/handhelds/htc/lk-msm7200a-htc-wince/build-msm7227_htc_wince/lk.bin .
rm tinboot tinboot.o out.nb
$AS tinboot.S -o tinboot.o
$OBJCOPY tinboot.o -O binary tinboot
./mkhtcimage
