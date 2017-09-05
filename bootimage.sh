#!/bin/sh

set -u
LANG=C
LC_ALL=C

BOOTDISK="sd0"

IMAGEMB="2048"
SWAPMB="128"

IMAGESECTORS=$(expr ${IMAGEMB} \* 1024 \* 1024 / 512)
SWAPSECTORS=$(expr ${SWAPMB} \* 1024 \* 1024 / 512 || true)

LABELSECTORS="2048"

FSSECTORS=$(expr ${IMAGESECTORS} - ${SWAPSECTORS} - ${LABELSECTORS})
FSSIZE=$(expr ${FSSECTORS} \* 512)

HEADS="64"
SECTORS="32"
CYLINDERS=$(expr ${IMAGESECTORS} / \( ${HEADS} \* ${SECTORS} \))
SECPERCYLINDERS=$(expr ${HEADS} \* ${SECTORS})
MBRHEADS="255"
MBRSECTORS="63"
MBRCYLINDERS=$(expr ${IMAGESECTORS} / \( ${MBRHEADS} \* ${MBRSECTORS} \))
MBRNETBSD="169"

BSDPARTSECTORS=$(expr ${IMAGESECTORS} - ${LABELSECTORS})
FSOFFSET=${LABELSECTORS}
SWAPOFFSET=$(expr ${LABELSECTORS} + ${FSSECTORS})

DISTRIBDIR="/usr/src/distrib"
FSTAB_IN="${DISTRIBDIR}/common/bootimage/fstab.in"
SPEC_IN="${DISTRIBDIR}/common/bootimage/spec.in"

IMGMAKEFSOPTIONS="-o bsize=16384,fsize=2048,density=8192"

# Main Process

# fstab
sed "s/@@BOOTDISK@@/${BOOTDISK}/" < ${FSTAB_IN} > work.fstab
cp work.fstab ./root/etc/fstab

# spec
cat ./root/etc/mtree/* | sed -e 's/ size=[0-9]*//' > work.spec
sh ./root/dev/MAKEDEV -s all | sed -e '/^\. type=dir/d' -e 's,^\.,./dev,' >> work.spec

# makefs
chmod +r ./root/var/spool/ftp/hidden
makefs -M ${FSSIZE} -m ${FSSIZE} \
       -B 1234 \
       -F work.spec -N ./root/etc \
       ${IMGMAKEFSOPTIONS} \
       boot.img ./root
installboot -v -m amd64 boot.img ./root/usr/mdec/bootxx_ffsv1

DISKPROTO_IN="${DISTRIBDIR}/common/bootimage/diskproto.mbr.in"
MBR_DEFAULT_BOOTCODE="mbr"

sed -e "s/@@SECTORS@@/${SECTORS}/"              \
    -e "s/@@HEADS@@/${HEADS}/"                  \
    -e "s/@@SECPERCYLINDERS@@/${SECPERCYLINDERS}/"      \
    -e "s/@@CYLINDERS@@/${CYLINDERS}/"              \
    -e "s/@@IMAGESECTORS@@/${IMAGESECTORS}/"            \
    -e "s/@@FSSECTORS@@/${FSSECTORS}/"              \
    -e "s/@@FSOFFSET@@/${FSOFFSET}/"                \
    -e "s/@@SWAPSECTORS@@/${SWAPSECTORS}/"          \
    -e "s/@@SWAPOFFSET@@/${SWAPOFFSET}/"            \
    -e "s/@@BSDPARTSECTORS@@/${BSDPARTSECTORS}/"        \
    < ${DISKPROTO_IN} > label.tmp

# MBR labels
dd if=/dev/zero of=work.mbr seek=$(expr ${IMAGESECTORS} - 1) count=1
fdisk -f -i -u \
      -b ${MBRCYLINDERS}/${MBRHEADS}/${MBRSECTORS} \
      -0 -a -s ${MBRNETBSD}/${FSOFFSET}/${BSDPARTSECTORS} \
      -F work.mbr

fdisk -f -i -c ./root/usr/mdec//${MBR_DEFAULT_BOOTCODE} -F work.mbr
dd if=work.mbr count=${LABELSECTORS}  | cat - boot.img > work.img
dd if=/dev/zero of=work.swap seek=$(expr ${SWAPSECTORS} - 1) count=1
cat work.swap >> work.img

disklabel -R -F work.img label.tmp
installboot -v -m amd64 work.img ./root/usr/mdec/boot
