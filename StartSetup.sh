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

echo 'THIS INSTALLER MUST BE PLACED OUTSIDE THE ROOT DIRECTORY!'
echo 'I am not responsivle for any damage caused by this program!'
echo 'Feedback is appreciated!'
echo 'Press ENTER to continue...'
read
clear

declare answ
declare user
declare userRoot

echo 'Do you want to create a user? [y,n] (default: y)'
read answ

answ=$(default_values "$answ" "y" "n")
if [ $answ == "y" ]; then

	echo 'Creating a user'
	echo 'What do you want to name your user?'
	read user
	echo 'Creating user...'
	useradd -m "$user"
	echo 'Enter the password that you want to set for the user'
	passwd "$user"

	echo 'Do you want to make your user a sudoer? [y, n] (default: y)'
	read userRoot
	userRoot=$(default_values "$userRoot" "y" "n")
	if [ $userRoot == "y" ]; then
		echo "$user ALL=(ALL) ALL" >>/etc/sudoers
	fi
	echo "Changing user to $user"
	su "$user" ArchSetup.sh
	cd ~
	pwd
	read
else
	sh Setup1.sh
fi
