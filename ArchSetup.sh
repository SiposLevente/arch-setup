default_values() {
	local valt
	local def
	local masik

	valt=$1
	def=$2
	masik=$3

	if [ "$valt" != "$def" ]; then
		if [ "$valt" != "$masik" ]; then
			valt=$def
		fi
	fi
	echo "$valt"
}

writeProf() {
	sudo sh -c 'echo "#autostart when logged in" >>  /etc/profile'
	sudo sh -c 'echo '"'"'if [[ "$(tty)" == '"'"'"'"'/dev/tty1'"'"'"'"' ]];then'"'"' >>  /etc/profile'
	sudo sh -c 'echo "	exec startx" >>  /etc/profile'
	sudo sh -c 'echo "fi" >>  /etc/profile'
}

cd ~

ertek=`grep -i "multilib" /etc/pacman.conf | wc -l `
if [ $ertek -lt 3 ];then
	echo 'Updating and upgrading repositories...'
	sudo sh -c 'echo "[multilib]" >>  /etc/pacman.conf'
	sudo sh -c 'echo "Include = /etc/pacman.d/mirrorlist" >>  /etc/pacman.conf'
	sudo pacman -Sy
fi

echo 'Select a desktop environment! [1-8] (default:KDE)'
echo '1 - Gnome 3'
echo '2 - Cinnamon'
echo '3 - Mate'
echo '4 - KDE'
echo '5 - XFCE'
echo '6 - LXDE'
echo '7 - LXQT'
echo '8 - i3'
echo '9 - Do not install a desktop enviroment!'
echo 'Please enter a number: '
read deNum

case $deNum in
1)
	echo 'You have selected Gnome 3!'
	sudo pacman -S gdm xorg gnome
	sudo systemctl enable gdm
	;;

2)
	echo 'You have selected Cinnamon!'
	sudo pacman -S xorg gdm mesa xterm xorg-twm xorg-xclock cinnamon nemo-fileroller
	sudo systemctl enable gdm
	;;

3)
	echo 'You have selected Mate!'
	sudo pacman -S xorg mate mate-extra lxdm
	sudo systemctl enable lxdm.service
	;;

5)
	echo 'You have selected XFCE!'
	sudo pacman -S xorg xorg-xinit xfce4 xfce4-goodies xterm xorg-twm xorg-xclock xorg-server pavucontrol
	touch $HOME/.xinitrc
	echo "#! /bin/bash" >>$HOME/.xinitrc
	echo "set b off" >>$HOME/.xinitrc
	echo "xset b off" >>$HOME/.xinitrc
	echo "exec startxfce4" >>$HOME/.xinitrc
	writeProf
	;;

6)
	echo 'You have selected LXDE!'
	sudo pacman -S lxde xorg xorg-xinit openbox
	touch $HOME/.xinitrc
	echo "#! /bin/bash" >>$HOME/.xinitrc
	echo "set b off" >>$HOME/.xinitrc
	echo "xset b off" >>$HOME/.xinitrc
	echo "exec startlxde" >>$HOME/.xinitrc
	writeProf
	;;

7)
	echo 'You have selected LXQT!'
	sudo pacman -S lxqt openbox sddm
	sudo systemctl enable sddm
	;;

8)
	echo 'You have selected i3!'
	sudo pacman -S i3 dmenu xorg xorg-xinit
	touch $HOME/.xinitrc
	echo "#! /bin/bash" >>$HOME/.xinitrc
	echo "set b off" >>$HOME/.xinitrc
	echo "xset b off" >>$HOME/.xinitrc
	echo "exec i3" >>$HOME/.xinitrc
	writeProf
	;;

9)
	echo 'You have selected none!'
	;;

*)
	echo 'You have selected KDE!'
	sudo pacman -S plasma sddm ark dolphin dolphin-plugins
	sudo systemctl enable sddm
	;;
esac

sudo systemctl enable NetworkManager.service

echo 'Desktop Environment has been installed on the machine!'

echo 'Select a terminal emulator! [1-8] (default: other)'
echo '1 - rxvt-unicode'
echo '2 - kitty'
echo '3 - terminator'
echo '4 - konsole'
echo '5 - gnome terminal'
echo '6 - termite'
echo '7 - tilix'
echo '8 - other (no terminal emulator will be installed)'
echo 'Please enter a number: '
read term

case $term in
1)
	sudo pacman -S rxvt-unicode rxvt-unicode-terminfo --noconfirm
	;;

2)
	sudo pacman -S kitty --noconfirm
	;;

3)
	sudo pacman -S terminator --noconfirm
	;;

4)
	sudo pacman -S konsole --noconfirm
	;;

5)
	sudo pacman -S gnome-terminal --noconfirm
	;;

6)
	sudo pacman -S termite --noconfirm
	;;

7)
	sudo pacman -S tilix --noconfirm
	;;

*)
	echo 'Terminal emulator wont be installed by the installer!'
	;;

esac

echo 'Do you want to install "paru" AUR manager and additional packages? [y, n] (default: y)'
read aur
aur=$(default_values "$aur" "y" "n")
if [ $aur == "y" ]; then
	git clone https://aur.archlinux.org/paru.git
	cd paru
	sed -n 's/.*depends = //p' .SRCINFO | cut -f1 -d":" | sudo pacman -S -
	makepkg
	sudo pacman -U paru*.zst
fi


echo 'Do you want to install ucode for your cpu? [y, n] (default: y)'
read ucode
ucode=$(default_values "$ucode" "y" "n")
if [ $ucode == "y" ]; then
	echo 'Do you have intel or amd cpu? [intel, amd] (default: intel)'
	read cpu
	cpu=$(default_values "$cpu" "intel" "amd")
	if [ $cpu == "intel" ]; then
		sudo pacman -S intel-ucode
	else
		sudo pacman -S amd-ucode lm_sensors
	fi
fi


echo 'Do you want to install gpu drivers? [y, n] (default: y)'
read gpu
gpu=$(default_values "$gpu" "y" "n")
if [ $gpu == "y" ]; then

	echo 'Do you have integrated intel graphics? [y, n] (default: n)'
	read integrated
	integrated=$(default_values "$integrated" "n" "y")
	if [ $integrated == "y" ]; then
		sudo pacman -S mesa lib32-mesa xf86-video-intel vulkan-intel
	fi

	echo 'Do you want to install nvidia gpu drivers? [y, n] (default: n)'
	read nvidia
	nvidia=$(default_values "$nvidia" "n" "y")
	if [ $nvidia == "y" ]; then
		echo 'Do you have an old nvidia card? [y, n] (default: n)'
		read oldDrivers
		oldDrivers=$(default_values "$oldDrivers" "n" "y")
		if [ $oldDrivers == "y" ]; then
			paru -Sa nvidia-390xx-dkms
			paru -Sa nvidia-390xx-settings
			paru -Sa nvidia-390xx-utils
			paru -Sa lib32-nvidia-390xx-utils
		else
			sudo pacman -S nvidia nvidia-utils nvidia-settings lib32-nvidia-utils
		fi

		echo 'Do you have want to install bumblebee (for nvidia optimus)? [y, n] (default: n)'
		read bee
		bee=$(default_values "$bee" "n" "y")
		if [ $bee == "y" ]; then
			sudo pacman -S bumblebee mesa xf86-video-intel lib32-virtualgl
			sudo gpasswd -a $USER bumblebee
			sudo systemctl enable bumblebeed.service
		fi
	fi

	echo 'Do you want to install amd gpu drivers? [y, n] (default: n)'
	read amd
	amd=$(default_values "$amd" "n" "y")
	if [ $amd == "y" ]; then
		sudo pacman -S mesa lib32-mesa xf86-video-ati xf86-video-amdgpu mesa-vdpau lib32-mesa-vdpau
	fi
fi

declare packages="gimp libreoffice-fresh virtualbox virtualbox-guest-iso virtualbox-host-modules-arch qbittorrent keepassxc zsh mpv ntfs-3g firefox"
declare aurPackages="vscodium virtualbox-ext-oracle cpupower-gui"
declare packageInstall
echo "These packages will be installed from main repositories: $packages"
if [ $aur == "y" ]; then
	echo "These packages will be installed from aur: $aurPackages"
fi
echo 'Do you want to install additional packages? [y, n] (default: y)'
read packageInstall
packageInstall=$(default_values "$packageInstall" "y" "n")
if [ $packageInstall == "y" ]; then
	sudo pacman -S $packages
	if [ $aur == "y" ]; then
		paru -Sa $aurPackages
	fi
fi

echo 'The setup has finished!'
echo 'Do you want to reboot? [y, n] (default: n)'
read reb
reb=$(default_values "$reb" "n" "y")
if [ $reb == "y" ]; then
	sudo reboot
else
	echo 'If there were any problems during setup, please contact me!'
	echo 'Exiting setup...'i
	echo 'Press ENTER to continue...'
	read
	clear
	su $USER
fi
