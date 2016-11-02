# Directory and Files
ARCH?=		amd64
BSDSRCDIR?=	/usr/src
OBJ_DIR?=	/usr/obj
VERSION=	`${BSDSRCDIR}/sys/conf/osrelease.sh`
TOOL_DIR?=	/usr/tools
WORK_DIR?=	${.CURDIR}/work
MDEC?=		${OBJ_DIR}/destdir.${ARCH}/usr/mdec
BIOSBOOT?=	bootxx_ffsv2
IMG_DIR?=	image.${ARCH}

# About Bootable Image
IMAGE=				netbsd-desktop.img
IMAGEMB?=			4096 # 4096 MB
SWAPMB?=			256 # 256 MB
IMAGESECTORS!=		expr ${IMAGEMB} \* 1024 \* 1024 / 512
SWAPSECTORS!=		expr ${SWAPMB} \* 1024 \* 1024 / 512 || true
HEADS=				64
SECTORS=			32
SECPERCYLINDERS!= 	expr ${HEADS} \* ${SECTORS}
CYLINDERS!= 		expr ${IMAGESECTORS} / \( ${HEADS} \* ${SECTORS} \)
LABELSECTORS?=		2048
FSSECTORS!=			expr ${IMAGESECTORS} - ${SWAPSECTORS} - ${LABELSECTORS}
FSSIZE!=			expr ${FSSECTORS} \* 512
FSOFFSET=			${LABELSECTORS}
SWAPOFFSET!=		expr ${LABELSECTORS} + ${FSSECTORS}
BSDPARTSECTORS!=	expr ${IMAGESECTORS} - ${LABELSECTORS}

# Base System Binaries.
BASE_BIN=	  base
BASE_BIN+=	comp
BASE_BIN+=	etc
BASE_BIN+=	game
BASE_BIN+=	kern-GENERIC
BASE_BIN+=	man
BASE_BIN+=	misc
BASE_BIN+=	modules
BASE_BIN+=	tests
BASE_BIN+=	text

install_base:
	@ if [ ! -d ${WORK_DIR} ]; then \
		mkdir ${WORK_DIR}; \
	fi
	@ for BASE in ${BASE_BIN}; do \
		echo "Installing $$BASE"; \
		pkg_add -m ${ARCH} -P ${WORK_DIR} $$BASE; \
	done
	@ echo "Base System Binary Installed."

create_bootable_image:
	${TOOL_DIR}/bin/nbsed "s/@@BOOTDISK@@/sd0/" < \
	${BSDSRCDIR}/distrib/common/bootimage/fstab.in > work.fstab
	cp work.fstab ${.CURDIR}/work/etc/fstab
	
	${TOOL_DIR}/bin/nbmakefs -M ${FSSIZE} -m ${FSSIZE} -B 1234 -t ffs \
	-N ${WORK_DIR}/etc -o bsize=16384,fsize=2048,density=8192 ${IMAGE} work
	
	${TOOL_DIR}/bin/nbinstallboot -v -m ${ARCH} ${IMAGE} ${MDEC}/${BIOSBOOT}
	
	${TOOL_DIR}/bin/nbsed \
	-e "s/@@SECTORS@@/${SECTORS}/" \
	-e "s/@@HEADS@@/${HEADS}/" \
	-e "s/@@SECPERCYLINDERS@@/${SECPERCYLINDERS}/" \
	-e "s/@@CYLINDERS@@/${CYLINDERS}/" \
	-e "s/@@IMAGESECTORS@@/${IMAGESECTORS}/" \
	-e "s/@@FSSECTORS@@/${FSSECTORS}/" \
	-e "s/@@FSOFFSET@@/${FSOFFSET}/" \
	-e "s/@@SWAPSECTORS@@/${SWAPSECTORS}/" \
	-e "s/@@SWAPOFFSET@@/${SWAPOFFSET}/" \
	-e "s/@@BSDPARTSECTORS@@/${BSDPARTSECTORS}/" \
	< ${BSDSRCDIR}/distrib/common/bootimage/diskproto.mbr.in > work.diskproto

	${TOOL_DIR}/bin/nbdisklabel -R -F -M amd64 -B le ${IMAGE} work.diskproto

	test -d ${IMG_DIR} || mkdir -p ${IMG_DIR}
	mv ${IMAGE} ${IMG_DIR}/${IMAGE}
	gzip -9 ${IMG_DIR}/${IMAGE}

image: install_base create_bootable_image

write:
	gzcat ${IMG_DIR}/${IMAGE}.gz | dd of=/dev/sd0d bs=64k

clean:
	rm -f work.diskproto
	rm -f work.fstab
	rm -fr work/*
	rm -fr ${IMG_DIR}/*
