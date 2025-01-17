#! /bin/sh
#**********************************************************************
# Copyright (C) 2021 - The Geeqie Team
#
# Author: Colin Clark
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#**********************************************************************

## @file
## @brief Generate a Geeqie AppImage.
##
## It must be run from the base Geeqie folder.  
## The single parameter is the directory where the AppDir
## will be created.
##

if [ ! -f geeqie.spec.in ] || [ ! -d .git ]
then
	printf '%s\n' "This is not a Geeqie folder"
	exit 1
fi

if ! target_dir=$(realpath "$1");
then
	printf '%s\n' "No target dir specified"
	exit 1
fi

rm -rf "$target_dir"/AppDir
mkdir "$target_dir"/AppDir || { printf '%s\n' "Cannot make $target_dir/AppDir"; exit 1; }

sudo rm -rf doc/html

sudo make maintainer-clean
./autogen.sh --prefix="/usr/"
make -j
make install DESTDIR="$target_dir"/AppDir

VERSION=$(git tag | tail -1)
export VERSION

cd "$target_dir" || { printf '%s\n' "Cannot cd to $target_dir"; exit 1; }

linuxdeploy-x86_64.AppImage \
	--appdir ./AppDir --output appimage \
	--desktop-file ./AppDir/usr/share/applications/geeqie.desktop \
	--icon-file ./AppDir/usr/share/pixmaps/geeqie.png \
	--plugin gtk \
	--executable ./AppDir/usr/bin/geeqie

mv "./Geeqie-$VERSION-x86_64.AppImage" "$(./Geeqie-"$VERSION"-x86_64.AppImage -v | sed 's/git//' | sed 's/-.* /-/' | sed 's/ /-v/' | sed 's/-GTK3//').AppImage"
