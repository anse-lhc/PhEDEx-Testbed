#!/bin/bash

echo "Updating system RPMs first..."
sudo yum update -y

echo "Checking your system has the necessary bits"
slc6_amd64_platformSeeds="glibc coreutils bash tcsh zsh perl tcl tk readline openssl ncurses e2fsprogs krb5-libs freetype fontconfig compat-libstdc++-33 libidn libX11 libXmu libSM libICE libXcursor libXext libXrandr libXft mesa-libGLU mesa-libGL e2fsprogs-libs libXi libXinerama libXft libXrender libXpm compat-readline5 dpkg perl-ExtUtils-Embed"

sudo yum install -y git zsh rlwrap perl-libwww-perl $slc6_amd64_platformSeeds
