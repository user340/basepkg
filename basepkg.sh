#!/usr/bin/env sh
#
# Copyright (c) 2016,2017 Yuuki Enomoto  
# All rights reserved.  
#   
# Redistribution and use in source and binary forms, with or without  
# modification, are permitted provided that the following conditions are met:  
#   
# * Redistributions of source code must retain the above copyright notice, 
#   this list of conditions and the following disclaimer.  
#   
# * Redistributions in binary form must reproduce the above copyright notice,  
#   this list of conditions and the following disclaimer in the documentation  
#   and/or other materials provided with the distribution.  
#   
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE  
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE  
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE  
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR  
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER  
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,  
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  

#
# POSIX Utilities
#
AWK="/usr/bin/awk"
BASENAME="/usr/bin/basename"
CAT="/bin/cat"
CHGRP="/bin/chgrp"
CHMOD="/bin/chmod"
CHOWN="/sbin/chown"
CKSUM="/usr/bin/cksum" 
CP="/bin/cp"
CUT="/usr/bin/cut"
DATE="/bin/date"
ECHO="/bin/echo"
ENV="/usr/bin/env"
EXPR="/bin/expr"
FILE="/usr/bin/file"
FIND="/usr/bin/find"
GREP="/usr/bin/grep"
LS="/bin/ls"
MKDIR="/bin/mkdir"
MV="/bin/mv"
RM="/bin/rm"
RMDIR="/bin/rmdir"
SED="/usr/bin/sed"
SH="/bin/sh"
SORT="/usr/bin/sort"
TEST="/bin/test"
TOUCH="/usr/bin/touch"
TR="/usr/bin/tr"
UNAME="/usr/bin/uname"
UNIQ="/usr/bin/uniq"
XARGS="/usr/bin/xargs"

#
# Non POSIX Utilities
#
DISKLABEL="/sbin/disklabel"
HOSTNAME="/bin/hostname"
INSTALL="/usr/bin/install"
INSTALLBOOT="/usr/sbin/installboot"
MAKEFS="/usr/sbin/makefs"
MKTEMP="/usr/bin/mktemp"
STAT="/usr/bin/stat"
PKG_ADD="/usr/pkg/sbin/pkg_add"
PKG_CREATE="/usr/pkg/sbin/pkg_create"
PKG_DELETE="/usr/pkg/sbin/pkg_delete"
PKG_INFO="/usr/pkg/sbin/pkg_info"

#
# Immutable variables
#
progname=${0##*/}
host="$(${HOSTNAME})"
machine_arch="$(${UNAME} -p)"
opsys="$(${UNAME})"
osversion="$(${UNAME} -r)"
pkgtoolversion="$(${PKG_ADD} -V)"
utcdate="$(${ENV} TZ=UTC LOCALE=C ${DATE} '+%Y-%m-%d %H:%M')"
user="${USER:-root}"
param="usr/include/sys/param.h"
lists="distrib/sets/lists"
comments="distrib/sets/comments"
descrs="distrib/sets/descrs"
deps="distrib/sets/deps"
tmp_deps="/tmp/culldeps"
basedir="share/basepkg/root"

#
# Output error message to STDERR
#
err()
{
  ${ECHO} "[$(${DATE} +'%Y-%m-%dT%H:%M:%S')] $@" >&2
}

#
# Output version of NetBSD source set.
#
osrelease() {
  path=$0
  exec < ${destdir}/${param}

  while
    read define ver_tag rel_num comment_start NetBSD rel_text rest; do
      [ "${define}" = "#define" ] || continue;
      [ "${ver_tag}" = "__NetBSD_Version__" ] || continue
      break
  done
  rel_num=${rel_num%??}
  rel_MMmm=${rel_num%????}
  rel_MM=${rel_MMmm%??}
  rel_mm=${rel_MMmm#${rel_MM}}
  IFS=.
  set -- - $rel_text
  beta=${3#[0-9]}
  beta=${beta#[0-9]}
  shift 3
  IFS=' '
  set -- $rel_MM ${rel_mm#0}$beta $*
  IFS=.
  echo "$*"
}

#
# "dir" option use the following functions.
#

#
# Make category directory and organized files named "FILES".
#
split_category_from_lists()
{
  i=""
  j=""
  for i in ${category}; do
    ${TEST} -d ${workdir}/${i} || ${MKDIR} -p ${workdir}/${i}
    ${TEST} -f ${workdir}/${i}/FILES && ${RM} -f ${workdir}/${i}/FILES
    for j in `${LS} ${src}/${lists} | ${GREP} -v "^[A-Z]"`; do
      ${AWK} '
      ! /^\#/ {
          #
          # Ignore obsolete packages.
          #
          if ($2 == "'"${i}-obsolete"'")
              next
          #
          # Ignore pacakge with obsolete tags.
          #
          if ($3 ~ "obsolete")
              next
          if ($2 ~ "^'"${i}"'") {
              #
              # Remove "./" characters.
              #
              $1 = substr($1, 3);
              if ($1 != "") {
                  gsub(/@MODULEDIR@/, "stand/'"${machine}"'/'"${release}"'/modules");
                  gsub(/@MACHINE@/, "'"${machine}"'");
                  gsub(/@OSRELEASE@/, "'"${release}"'");
                  print
              }
          }
      }' ${src}/${lists}/${j}/mi >> ${workdir}/${i}/FILES
  
      if [ -f ${src}/${lists}/${j}/md.${machine} ]; then
        ${AWK} '
        ! /^\#/ {
            #
            # Ignore obsolete packages.
            #
            if ($2 == "'"${i}-obsolete"'")
                next
            #
            # Ignore pacakge with obsolete tags.
            #
            if ($3 ~ "obsolete")
                next
            if ($2 ~ "^'"${i}"'") {
                #
                # Remove "./" characters.
                #
                $1 = substr($1, 3);
                if ($1 != "") {
                    gsub(/@MODULEDIR@/, "stand/'"${machine}"'/'"${release}"'/modules");
                    gsub(/@MACHINE@/, "'"${machine}"'");
                    gsub(/@OSRELEASE@/, "'"${release}"'");
                    print
                }
            }
        }' ${src}/${lists}/${j}/md.${machine} >> ${workdir}/${i}/FILES
      fi
    done
  done
}

#
# Make directories referring to "FILES".
#
make_directories_of_package()
{
  i=""
  for i in ${category}; do
    ${AWK} '{print $2}' ${workdir}/${i}/FILES | ${SORT} | ${UNIQ} | \
    ${XARGS} -n 1 -I % ${SH} -c "${TEST} -d ${workdir}/${i}/% || ${MKDIR} ${workdir}/${i}/%"
  done
}

#
# "list" option use the following function.
#

#
# List each package's contents and write into "category/package/package.FILE".
#
make_contents_list()
{
  i=""
  for i in ${category}; do
    ${AWK} ' 
    # $1 - file name
    # $2 - package name
    $2 ~ /\./ {
        gsub(/\./, "-", $2)
    }
    {
        if ($2 in lists)
            lists[$2] = $1 " " lists[$2]
        else
            lists[$2] = $1
    }
    END {
        for (pkg in lists)
            print pkg, lists[pkg]
    }' ${workdir}/${i}/FILES > ${workdir}/${i}/CATEGORIZED
  done
  i=""
  j=""
  for i in ${category}; do
    for j in `${LS} ${workdir}/${i} | ${GREP} '^[a-z]'`; do
      ${AWK} '
      /^'"$j"'/ {
          for (i = 2; i <= NF; i++) {
              print $i
          }
      }' ${workdir}/${i}/CATEGORIZED > ${workdir}/${i}/${j}/${j}.FILES
    done
  done
}

#
# "pkg" option use the following functions.
#

#
# Make "+BUILD_INFO" file.
#
make_BUILD_INFO()
{
  ${CAT} > ${workdir}/$1/+BUILD_INFO << _BUILD_INFO_
OPSYS=${opsys}
OS_VERSION=${osversion}
OBJECT_FMT=ELF
MACHINE_ARCH=${machine_arch}
PKGTOOLS_VERSION=${pkgtoolversion}
_BUILD_INFO_
}

#
# Calculate package's dependency.
#
culc_deps()
{
  ${GREP} -E "^$1" ${src}/${deps} > /dev/null 2>&1
  if [ $? -eq 1 ]; then
    err "$1:Unknown package dependency."
    return 1
  fi
  ${AWK} '/^'"$1"'/{print $2}' ${src}/${deps} | while read depend; do
    if [ ! "${depend}" ]; then
      return 1
    fi
    ${ECHO} "@pkgdep ${depend}>=${release}" >> ${tmp_deps}
    if [ "${depend}" = "base-sys-root" ]; then
      return 0
    fi
    culc_deps ${depend}
  done
}

#
# Make "+CONTENTS" file.
#
make_CONTENTS()
{
  TMPFILE=`${MKTEMP} -q`
  if [ $? -ne 0 ]; then
    err "$0: Can't create temp file, exiting..."
    exit 1
  fi
  setname=`${ECHO} $1 | ${CUT} -d '/' -f 1 | ${SED} 's/\./-/g'`
  pkgname=`${ECHO} $1 | ${CUT} -d '/' -f 2 | ${SED} 's/\./-/g'`
  ${ECHO} "@name ${pkgname}-${release}" > ${workdir}/$1/+CONTENTS
  ${ECHO} "@comment Packaged at ${utcdate} UTC by ${user}@${host}" >> ${workdir}/$1/+CONTENTS
  if [ -f ${tmp_deps} ]; then
    ${RM} -f ${tmp_deps}
  fi
  culc_deps ${pkgname}
  if [ -f ${tmp_deps} ]; then
    ${SORT} ${tmp_deps} | ${UNIQ} >> ${workdir}/$1/+CONTENTS
  fi
  ${ECHO} "@cwd ${targetdir}" >> ${workdir}/$1/+CONTENTS
  ${CAT} ${workdir}/$1/${pkgname}.FILES | while read i; do
    if [ `${FILE} ${destdir}/${i} | ${CUT} -d " " -f 2` = "symbolic" ]; then
      continue
    fi
    if [ -d ${destdir}/${i} ]; then
      filename=`${ECHO} ${i} | ${SED} 's%\/%\\\/%g'`
      ${AWK} '$1 ~ /^\.\/'"${filename}"'$/{print $0}' ${destdir}/etc/mtree/set.${setname} | \
      ${SED} 's%^\.\/%%' | \
      ${AWK} '
      {
          print "@exec install -d -o root -g wheel -m "substr($5, 6) " "$1
      }
      ' >> ${TMPFILE}
    elif [ ! -f ${destdir}/${i} ]; then
      continue
    else
      ${ECHO} ${i} >> ${TMPFILE}
    fi
  done
  ${SORT} ${TMPFILE} >> ${workdir}/$1/+CONTENTS
  ${RM} -f ${TMPFILE}
}

#
# Make "+DESC" and "+COMMENT" file.
#
make_DESC_and_COMMENT()
{
  pkgname=`${ECHO} $1 | ${CUT} -d '/' -f 2 | ${SED} 's/\./-/g'`

  ${AWK} '
  /^'"${pkgname}"'/ {
      for (i = 2; i <= NF; i++) {
          if (i == NF)
              printf $i"\n"
          else
              printf $i" "
      }
  }' ${src}/${descrs} > ${workdir}/$1/+DESC

  ${AWK} '
  /^'"${pkgname}"'/ {
      for (i = 2; i <= NF; i++) {
          if (i == NF)
              printf $i"\n"
          else
              printf $i" "
      }
  }' ${src}/${descrs} > ${workdir}/$1/+COMMENT
}

#
# Make "+INSTALL" file.
# Role of "+INSTALL" is defining absolute path of file, 
# permission, owner and group.
#
make_INSTALL()
{
  setname=`${ECHO} $1 | ${CUT} -d '/' -f 1 | ${SED} 's/\./-/g'`
  pkgname=`${ECHO} $1 | ${CUT} -d '/' -f 2 | ${SED} 's/\./-/g'`
  if [ -f ${setname}/${pkgname}/+INSTALL ]; then
    ${MV} ${workdir}/$1/+INSTALL ${workdir}/$1/+INSTALL.old
  fi
  if [ -f ${workdir}/$1/+CONTENTS ]; then
    ${GREP} -v -e "^@" ${workdir}/$1/+CONTENTS | while read file; do
      if [ `${FILE} ${file} | ${CUT} -d " " -f 2` = "symbolic" ]; then
        continue
      fi
      if [ `${ECHO} ${file} | ${CUT} -d "/" -f 1` = "etc" ]; then
        install_type="CONF"
      elif [ `${ECHO} ${file} | ${CUT} -d "/" -f 1` = "boot.cfg" ]; then
        install_type="CONF"
      else
        install_type="FILE"
      fi
      if [ -f /${file} ]; then
        mode_user_group=`${STAT} -f '%p %u %g' ${destdir}/${file} | \
        ${SED} 's/^[0-9]\{3\}//'`
      else
        mode_user_group=""
      fi
      ${ECHO} "# ${install_type}: /${file} ${file} ${mode_user_group}" \
      >> ${workdir}/$1/+INSTALL
    done
    if [ -f ${workdir}/$1/+INSTALL.old ]; then
      ${RM} -f ${workdir}/$1/+INSTALL.old
    fi
  else
    return 1
  fi
  return 0
}

#
# "pkg_create" command wrapper.
# Package moved to ${packages}/All directory.
#
do_pkg_create()
{
  setname=`${ECHO} $1 | ${CUT} -d '/' -f 1 | ${SED} 's/\./-/g'`
  pkgname=`${ECHO} $1 | ${CUT} -d '/' -f 2 | ${SED} 's/\./-/g'`
  if [ -f ${workdir}/$1/+INSTALL ]; then
    install_script="-i ${workdir}/$1/+INSTALL"
  else
    install_script=""
  fi
  ${PKG_CREATE} -v -l -U -B ${workdir}/$1/+BUILD_INFO -c ${workdir}/$1/+COMMENT \
  -d ${workdir}/$1/+DESC -f ${workdir}/$1/+CONTENTS ${install_script} \
  -p ${destdir} -K ${pkgdb} ${pkgname}
  if [ $? != 0 ]; then
    return $?
  fi
  if [ ! -d ${packages}/${release}/${machine} ]; then
    ${MKDIR} -p ${packages}/${release}/${machine}
  fi
  ${MV} ./${pkgname}.tgz \
    ${packages}/${release}/${machine}/${pkgname}-${release}.tgz
}

#
# Execute any functions and make MD5 and SHA512.
#
make_packages()
{
  i=""
  j=""
  for i in ${category}; do
    for j in `${LS} ${workdir}/${i} | ${GREP} -E '^[a-z]+'`; do
      ${ECHO} "Package ${i}/${j} Creating..."
      make_BUILD_INFO ${i}/${j}
      make_CONTENTS ${i}/${j}
      make_DESC_and_COMMENT ${i}/${j}
      make_INSTALL ${i}/${j}
      do_pkg_create ${i}/${j}
    done
  done
  pkgs="$(${FIND} ${packages} -type f \
    \! -name MD5 \! -name *SUM \! -name SHA512 2>/dev/null)"
  ${TEST} -f ${packages}/${release}/${machine}/MD5 && \
    ${RM} -f ${pacakges}/${release}/${machine}/MD5
  ${TEST} -f ${packages}/${release}/${machine}/SHA512 && \
    ${RM} -f ${pacakges}/${release}/${machine}/SHA512
  if [ -n "${pkgs}" ]; then
    ${CKSUM} -a md5 ${pkgs} >> ${packages}/${release}/${machine}/MD5
    ${CKSUM} -a sha512 ${pkgs} >> ${packages}/${release}/${machine}/SHA512
  fi
}

#
# "install" option use the following functions.
#

#
# "pkg_add" command wrapper.
#
do_pkg_add()
{
  pkg_add_options=""
  ${TEST} -d ${targetdir} || ${MKDIR} -p ${targetdir}
  ${TEST} ${force} = "true" && pkg_add_options="-f"
  ${TEST} ${update} = "true" && pkg_add_options="-u ${pkg_add_options}"
  ${TEST} ${replace} = "true" && pkg_add_options="-U ${pkg_add_options}"
  pkg_add_options="-K ${pkgdb} -p ${targetdir} ${pkg_add_options}"
  ${PKG_ADD} ${pkg_add_options} $@ || exit 1
  if [ $touch_system = "true" ]; then
    i=""
    for i in $@; do
      ${SED} -n "/^\# CONF: /{s/^\# CONF: //;p;}" \
      ${pkgdb}/`${BASENAME} ${i} | ${SED} 's/\.tgz$//'`/+INSTALL | ${SORT} -u |
      while read dst source mode user group; do
        case ${dst} in
          "") continue ;;
          [!/]*) dst="/${dst}" ;;
        esac
        case ${source} in
          "") continue ;;
          [!/]*) source="${targetdir}/${source}" ;;
        esac
        if [ -f ${source} -a ! -f ${dst} ]; then
          case ${mode} in
            "") ;;
            *) ${CHMOD} ${mode} ${source} ;;
          esac
          case ${user} in
            "") ;;
            *) ${CHOWN} ${user} ${source} ;;
          esac
          case ${group} in
            "") ;;
            *) ${CHGRP} ${group} ${source} ;;
          esac
          mv ${source} ${dst}
        elif [ -f ${source} -a -f ${dst} ]; then
          ${ECHO} "${dst} is already exist. Ignore..."
        fi
      done
      ${SED} -n "/^\# FILE: /{s/^\# FILE: //;p;}" \
      ${pkgdb}/`${BASENAME} ${i} | ${SED} 's/\.tgz$//'`/+INSTALL | ${SORT} -u |
      while read dst source mode user group; do
        case ${dst} in
          "") continue ;;
          [!/]*) dst="/${dst}" ;;
        esac
        case ${source} in
          "") continue ;;
          [!/]*) source="${targetdir}/${source}" ;;
        esac
        if [ -f ${source} ]; then
          case ${mode} in
            "") ;;
            *) ${CHMOD} ${mode} ${source} ;;
          esac
          case ${user} in
            "") ;;
            *) ${CHOWN} ${user} ${source} ;;
          esac
          case ${group} in
            "") ;;
            *) ${CHGRP} ${group} ${source} ;;
          esac
          ${MV} ${source} ${dst}
        fi
      done
    done
  fi
}

#
# "delete" option use the following functions.
#

#
# "pkg_delete" command wrapper.
#
do_pkg_delete()
{
  if [ $touch_system = "true" ]; then
    real_prefix="/"
  else
    real_prefix="${targetdir}"
  fi
  if [ ${force} = "true" ]; then
    pkg_delete_options="-f"
  else
    pkg_delete_options=""
  fi
  pkg_delete_options="-K ${pkgdb} -p ${real_prefix} ${pkg_delete_options}"
  ${PKG_DELETE} ${pkg_delete_options} $@ || exit 1
}

#
# "info" option use the following functions.
#

#
# "pkg_info" command wrapper
#
do_pkg_info()
{
  pkg_info_options="-K ${pkgdb}"
  ${PKG_INFO} ${pkg_info_options} $@ || exit 1
}

#
# "image" option use the following functions.
#

#
# Making bootable base system packaged image named "pkg.img".
# Thank you for src/distrib/common/bootimage/Makefile.bootimage by Izumi Tsutsui.
#
do_make_bootable_image()
{
  #
  # File name and path.
  #
  image_name="boot_basepkg.img"
  fstab="distrib/common/bootimage/fstab.in"
  diskproto="distrib/common/bootimage/diskproto.mbr.in"
  specin="distrib/common/bootimage/spec.in"
  workspec="instfs.spec"
  primary_boot="usr/mdec/bootxx_ffsv1"
  secondary_boot="usr/mdec/boot"
  imgdir="${PWD}/images/${release}/${machine}"

  ${TEST} -d ${imgdir} || ${MKDIR} -p ${imgdir}

  #
  # Command options.
  #
  imgmakefsoptions="-o bsize=16384,fsize=2048,density=8192"
  target_endianness="1234"
  fstype="ffs"

  #
  # Size parameters for image.
  #
  bootdisk="sd0"
  imageMB=2048 # 2048MB
  swapMB=128   # 128MB

  # XXX: swapMB could be zero and expr(1) returns exit status 1 in that case.
  imagesectors=`${EXPR} ${imageMB} \* 1024 \* 1024 / 512`
  swapsectors=`${EXPR} ${swapMB} \* 1024 \* 1024 / 512 || true`

  # Not use MBR.
  labelsectors=0

  #
  # Calculating disk information for disklabel.
  #
  fssectors=`${EXPR} ${imagesectors} - ${swapsectors} - ${labelsectors}`
  fssize=`${EXPR} ${fssectors} \* 512`
  heads=64
  sectors=32
  secpercylinders=`${EXPR} ${heads} \* ${sectors}`
  cylinders=`${EXPR} ${imagesectors} / ${secpercylinders}`
  bsdpartsectors=`${EXPR} ${imagesectors} - ${labelsectors}`
  fsoffset=${labelsectors}
  swapoffset=`${EXPR} ${labelsectors} + ${fssectors}`
  fssize=`${EXPR} ${fssectors} \* 512`

  ${CP} ${kerneldir}/${kernel}/netbsd ${targetdir} \
    || (err "copy kernel failed"; exit 1)

  #
  # Copying secondary boot
  #
  ${INSTALL} -c -m 0644 ${targetdir}/${secondary_boot} ${targetdir} \
    || (err "copy secondary boot failed"; exit 1)

  #
  # Preparing /etc/fstab
  #
  ${SED} 's/@@BOOTDISK@@/'"${bootdisk}"'/' < ${src}/${fstab} > ${imgdir}/fstab \
    || (err "edit ${src}/${fstab} failed"; exit 1)
  ${INSTALL} -c -m 0644 ${imgdir}/fstab ${targetdir}/etc \
    || (err "install fstab failed"; exit 1)

  #
  # Setting rc_configure=YES in /etc/rc.conf
  #
  ${SED} -i 's/rc_configured=NO/rc_configured=YES/' ${targetdir}/etc/rc.conf \
    || (err "edit ${targetdir}/etc/rc.conf failed"; exit 1)

  #
  # Preparing spec files for makefs
  #
  test -f ${imgdir}/${workspec} && ${RM} -f ${imgdir}/${workspec}
  ${CAT} ${targetdir}/etc/mtree/* | ${SED} -e 's/size=[0-9]*//' > ${imgdir}/${workspec}
  ${SH} ${targetdir}/dev/MAKEDEV -s all ipty | \
    ${SED} -e '/^\. type=dir/d' -e 's,^\.,./dev,' >> ${imgdir}/${workspec} \
    || (err "MAKEDEV failed"; exit 1)
  ${CAT} ${src}/${specin} >> ${imgdir}/${workspec}
  ${ECHO} "./${secondary_boot} type=file uname=root gname=wheel mode=0444" \
    >> ${imgdir}/${workspec}

  #
  # Creating rootfs
  #

  # XXX /var/spool/ftp/hidden is unreadable.
  ${CHMOD} +r ${targetdir}/var/spool/ftp/hidden
  ${MAKEFS} -M ${fssize} -m ${fssize} \
    -B ${target_endianness} \
    -t ${fstype} \
    -F ${imgdir}/${workspec} \
    -N ${targetdir}/etc \
    ${imgmakefsoptions} \
    ${imgdir}/${image_name} ${targetdir} \
    || (err "makefs failed"; exit 1)
  ${INSTALLBOOT} -v -m ${machine} ${imgdir}/${image_name} ${targetdir}/${primary_boot} \
    || (err "installboot failed"; exit 1)

  ${SED} \
    -e "s/@@SECTORS@@/${sectors}/" \
    -e "s/@@HEADS@@/${heads}/" \
	  -e "s/@@SECPERCYLINDERS@@/${secpercylinders}/" \
	  -e "s/@@CYLINDERS@@/${cylinders}/" \
	  -e "s/@@IMAGESECTORS@@/${imagesectors}/" \
	  -e "s/@@FSSECTORS@@/${fssectors}/" \
	  -e "s/@@FSOFFSET@@/${fsoffset}/" \
	  -e "s/@@SWAPSECTORS@@/${swapsectors}/" \
	  -e "s/@@SWAPOFFSET@@/${swapoffset}/" \
	  -e "s/@@BSDPARTSECTORS@@/${bsdpartsectors}/" < ${src}/${diskproto} > ${imgdir}/diskproto

	${DISKLABEL} -R -F -M ${machine} -B le ${imgdir}/${image_name} ${imgdir}/diskproto \
    || (err "disklabel failed"; exit 1)
}

#
# Show usage.
#
usage()
{
  ${CAT} <<_usage_

Usage: ${progname} [--sets sets_dir] [--src src_dir] [--system]
                   [--pkg packages_dir] [--category category]
                   [--prefix prefix] [--pkgdb database_dir]
                   [--force] [--update] [--replace] operation

 Operation:
    pkg                 Create packages.
    install             Install packages to ${targetdir}.
                        If --system option using, install package to /.
    delete              Uninstall packages at ${targetdir}.
                        If --system option using, delete package from /.

 Operation for Debug:
    dir                 Create packages directory.
    list                Create packages list.

 Options:
    --help              Show this message and exit.
    --sets              Set sets to extract tarballs.
                        [Default: /usr/obj/releasedir/${machine}/binary/sets]
    --src               Set src to NetBSD source directory.
                        [Default: /usr/src]
    --obj               Set obj to NetBSD binaries.
                        [Default: ${PWD}]
    --pkg               Set packages root directory; sets a PACKAGES pattern.
                        [Default: ./packages]
    --category          Set category.
                        [Default: "base comp etc games man misc text"]
    --prefix            Set package's prefix.
                        [Default: "/usr/pkg"]
    --system            If install/delete operation with this option,
                        install to/delete from /.
    --pkgdb             Set pkgdb to package's database.
                        [Default: "/var/db/basepkg"]
    --force             Add "-f" option to pkg_add and pkg_delete command.
    --update            Add "-u" option to pkg_add and pkg_delete command.
    --replace           Add "-U" option to pkg_add command.

_usage_
  exit 1
}

#
# In options, 
#     --src=/usr/src
#           ^^^^^^^^^
#            take it
#
get_optarg()
{
  ${EXPR} "x$1" : "x[^=]*=\\(.*\\)"
}

#
# Main
#

#
# parse long-options
#
while [ $# -gt 0 ]; do
  case $1 in
    -h|--help)
      usage; exit ;;
    --sets=*)
      sets=`get_optarg "$1"` ;;
    --sets)
      ${TEST} -z $2 && err "What is $1 parameter?" ; exit 1
      sets=$2
      shift ;;
    --src=*)
      src=`get_optarg "$1"` ;;
    --src)
      ${TEST} -z $2 && err "What is $1 parameter?" ; exit 1
      src=$2
      shift ;;
    --obj)
      ${TEST} -z $2 && err "What is $1 parameter?" ; exit 1
      obj=$2
      shift ;;
    --obj=*)
      obj=`get_optarg "$1"` ;;
    --pkg=*)
      packages=`get_optarg "$1"` ;;
    --pkg)
      ${TEST} -z $2 && err "What is $1 parameter?" ; exit 1
      packages=$2
      shift ;;
    --category=*)
      category=`get_optarg "$1"` ;;
    --category)
      ${TEST} -z $2 && err "What is $1 parameter?" ; exit 1
      category="$2"
      shift ;;
    --prefix=*)
      prefix=`get_optarg "$1"` ;;
    --prefix)
      ${TEST} -z $2 && err "What is $1 parameter?" ; exit 1
      prefix="$2"
      shift ;;
    --system)
      touch_system="true"
      pkgdb="/var/db/basepkg" ;;
    --pkgdb=*)
      pkgdb=`get_optarg "$1"` ;;
    --pkgdb)
      ${TEST} -z $2 && err "What is $1 parameter?" ; exit 1
      pkgdb="$2"
      shift ;;
    --machine=*)
      machine=`get_optarg "$1"` ;;
    --machine)
      ${TEST} -z $2 && err "What is $1 parameter?" ; exit 1
      machine="$2"
      shift ;;
    --force)
      force="true" ;;
    --update)
      update="true" ;;
    --replace)
      replace="true" ;;
    -|--)
      break ;;
    *)
      break ;;
  esac
  shift
done

#
# Initialization
#
set -u
umask 0022
export LC_ALL=C LANG=C

${TEST} $# -eq 0 && usage

#
# Mutable variables
#
src=${src:="/usr/src"}
obj=${obj:="/usr/obj"}
machine="$(${UNAME} -m)"
destdir="${obj}/destdir.${machine}"
packages=${packages:="${PWD}/packages"}
sets=${sets:="/usr/obj/releasedir/${machine}/binary/sets"}
category=${category:="base comp etc games man misc text"}
prefix=${prefix:="/usr/pkg"}
targetdir="${prefix}/${basedir}"
pkgdb=${pkgdb:="${targetdir}/var/db/basepkg"}
touch_system=${touch_system:="false"}
force=${force:="false"}
update=${update:="false"}
replace=${replace:="false"}
release="`osrelease`"
moduledir="stand/${machine}/${release}/modules"
workdir="${PWD}/work/${release}/${machine}"
kerneldir="${obj}/sys/arch/${machine}/compile"
kernel="GENERIC"

#
# operation
#
case $1 in
  dir) 
    split_category_from_lists
    make_directories_of_package ;;
  list)
    make_contents_list ;;
  #
  # Mainly, use "pkg" option.
  #
  pkg)
    split_category_from_lists
    make_directories_of_package
    make_contents_list
    make_packages ;;
  install)
    shift
    do_pkg_add $@ ;;
  delete)
    shift
    do_pkg_delete $@ ;;
  info)
    shift
    do_pkg_info $@ ;;
  image)
    do_make_bootable_image ;;
  *)
    usage ;;
esac

exit 0
