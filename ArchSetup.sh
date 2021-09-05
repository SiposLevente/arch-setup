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

declare deNum

cd ~
echo 'Updating and upgrading repositories...'
sudo sh -c 'echo "[multilib]" >>  /etc/pacman.conf'
sudo sh -c 'echo "Include = /etc/pacman.d/mirrorlist" >>  /etc/pacman.conf'
sudo pacman -Sy

echo 'Select a desktop environment! [1-8] (default:KDE)'
echo '1 - Gnome 3'
echo '2 - Cinnamon'
echo '3 - Mate'
echo '4 - KDE'
echo '5 - XFCE'
echo '6 - LXDE'
echo '7 - LXQT'
echo '8 - i3'
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

*)
	echo 'You have selected KDE!'
	sudo pacman -S plasma sddm ark
	sudo systemctl enable sddm
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
esac

sudo systemctl enable NetworkManager.service

echo 'Desktop Environment has been installed on the machine!'

declare term
echo 'Select a terminal emulator! [1-8] (default:rxvt)'
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

declare aur
echo 'Do you want to install "paru" AUR manager and additional packages? [y, n] (default: y)'
read aur
aur=$(default_values "$aur" "y" "n")
if [ $aur == "y" ]; then
	git clone https://aur.archlinux.org/paru.git
	cd paru
	sed -n 's/.*depends = //p' .SRCINFO | cut -f1 -d":" | sudo pacman -S -
	makepkg
	sudo pacman -U paru*.zst
	declare nvidia
	echo 'Do you want to install nvidia drivers? [y, n] (default: y)'
	read nvidia
	nvidia=$(default_values "$nvidia" "y" "n")
	if [ $aur == "y" ]; then
		echo 'Do you have an old nvidia card? [y, n] (default: n)'
		read oldDrivers
		oldDrivers=$(default_values "$aur" "n" "y")
		if [ $oldDrivers == "y" ]; then
			paru -Sa nvidia-390xx-dkms
			paru -Sa nvidia-390xx-settings
			paru -Sa nvidia-390xx-utils
			paru -Sa lib32-nvidia-390xx-utils
		else
			sudo pacman -S nvidia nvidia-utils nvidia-settings lib32-nvidia-utils
		fi
		sudo pacman -S bumblebee mesa xf86-video-intel lib32-virtualgl
		sudo gpasswd -a $USER bumblebee
		sudo systemctl enable bumblebeed.service
	fi

	declare packages="gimp libreoffice-fresh virtualbox virtualbox-guest-iso virtualbox-host-modules-arch qbittorrent keepassxc zsh mpv ntfs-3g"
	declare aurPackages="vscodium virtualbox-ext-oracle"
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
fi

declare reb
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
