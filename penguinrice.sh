#!/usr/bin/env bash

# penguinRice
# p3nguin-kun's auto rice script
# Author: Khanh Hien Hoang (p3nguin-kun)
# GitHub: p3nguin-kun
# Website: https://p3nguin-kun.github.io

CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
BLD=$(tput bold)
CNC=$(tput sgr0)

backup_folder=~/.RiceBackup
date=$(date +%Y%m%d-%H%M%S)

logo() {

	local text="${1:?}"
	echo -en "                                 
  penguinRice\n\n"
	printf ' %s [%s%s %s%s %s]%s\n\n' "${CRE}" "${CNC}" "${CYE}" "${text}"
}

# Check if this script is run as root
if [ "$(id -u)" = 0 ]; then
	echo "This script MUST NOT be run as root."
	exit 1
fi

# Intro
clear
logo "Welcome!"
printf '%s%sThis script will automatically install fully-featured tiling/floating window manager-based system on any Arch Linux or Arch-based system. \n\nMy dotfiles DO NOT modify any of your system configuration. \nYou will be prompted for your root password to install missing dependencies and/or to switch to fish shell if its not your default. \n\nThis script doesnt have potential power to break your system, it only copies files from my repo to your HOME directory. %s\n\n' "${BLD}" "${CRE}" "${CNC}"

while true; do
	read -rp " Do you want to continue? [y/n]: " yn
	case $yn in
	[Yy]*) break ;;
	[Nn]*) exit ;;
	*) printf "Just write 'y' or 'n'\n\n" ;;
	esac
done
clear

# Install packages
logo "Installing needed packages"

dependencies=(alacritty arandr archlinux-xdg-menu bspwm btop calcurse dunst feh firefox fish gtk-engine-murrine gvfs gvfs-afc gvfs-mtp gvfs-smb i3-wm jq lightdm lightdm-webkit2-greeter lxappearance-gtk3 mpc mpd mpv ncmpcpp neovim networkmanager network-manager-applet obconf openbox pamixer pavucontrol picom pipewire pipewire-pulse plank playerctl polkit-gnome polybar ranger rofi sed sxhkd thunar thunar-archive-plugin thunar-volman ttf-iosevka-nerd ttf-sarasa-gothic udisks2 ueberzug unrar unzip wireplumber xarchiver xbindkeys xdg-user-dirs-gtk xfce4-power-manager xfce4-screenshooter xorg xorg-drivers xss-lock zathura zathura-pdf-mupdf zip)

is_installed() {
	pacman -Qi "$1" &>/dev/null
	return $?
}

printf "%s%sChecking for required packages%s\n" "${BLD}" "${CBL}" "${CNC}"
for paquete in "${dependencies[@]}"; do
	if ! is_installed "$paquete"; then
		sudo pacman -S --noconfirm "$paquete"
		printf "\n"
	else
		printf '%s%s is already installed on your system!%s\n' "${CGR}" "$paquete" "${CNC}"
	fi
done
sleep 1
clear

# Installing yay
logo "Installing yay and AUR packages"
if command -v yay &>/dev/null; then
	echo "Yay is installed in your system"
else
	echo "Installing yay"
	sudo pacman -S --needed --noconfirm base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd ..
fi

echo "Installing AUR packages"
aur=(betterlockscreen dragon-drop lmaofetch qogir-icon-theme ttf-icomoon-feather)

is_installed() {
	pacman -Qi "$1" &>/dev/null
	return $?
}

printf "%s%sChecking for required packages%s\n" "${BLD}" "${CBL}" "${CNC}"
for paquete in "${aur[@]}"; do
	if ! is_installed "$paquete"; then
		yay -S --noconfirm "$paquete"
		printf "\n"
	else
		printf '%s%s is already installed on your system!%s\n' "${CGR}" "$paquete" "${CNC}"
	fi
done
sleep 1
clear

# Preparing folders
logo "Preparing Folders"
if [ ! -e $HOME/.config/user-dirs.dirs ]; then
	xdg-user-dirs-update
	echo "Creating xdg-user-dirs"
else
	echo "user-dirs.dirs already exists"
fi
sleep 1
clear

# Downloading dotfiles
logo "Downloading dotfiles"
[ -d ~/penguinDotfiles ] && rm -rf ~/penguinDotfiles
printf "Cloning rice from https://github.com/p3nguin-kun/penguinDotfiles\n"
cd
git clone --depth=1 https://github.com/p3nguin-kun/penguinDotfiles.git
printf "Cloning rice from https://github.com/p3nguin-kun/penguinFox\n"
cd
git clone --depth=1 https://github.com/p3nguin-kun/penguinFox.git
sleep 1
clear

# Backup dotfiles
logo "Backing-up dotfiles"
printf "Backup files will be stored in %s%s%s/.RiceBackup%s \n\n" "${BLD}" "${CRE}" "$HOME" "${CNC}"
sleep 1

if [ ! -d "$backup_folder" ]; then
	mkdir -p "$backup_folder"
fi

for folder in alacritty bspwm btop calcurse dunst fish gtk-3.0 gtk-4.0 i3 mpd ncmpcpp neofetch nvim openbox picom plank ranger rofi sxhkd wallpapers xfce4 zathura; do
	if [ -d "$HOME/.config/$folder" ]; then
		mv "$HOME/.config/$folder" "$backup_folder/${folder}_$date"
		echo "$folder folder backed up successfully at $backup_folder/${folder}_$date"
	else
		echo "The folder $folder does not exist in $HOME/.config/"
	fi
done

for folder in wallpapers; do
	if [ -d "$HOME"/$folder ]; then
		mv "$HOME"/$folder "$backup_folder"/${folder}_$date
		echo "$folder folder backed up successfully at $backup_folder/${folder}_$date"
	else
		echo "The folder $folder does not exist in $HOME/.mozilla/firefox/"
	fi
done

for folder in chrome; do
  if [ -d "$HOME"/.mozilla/firefox/*.default-release/$folder ]; then
    mv "$HOME"/.mozilla/firefox/*.default-release/$folder "$backup_folder"/${folder}_$date
    echo "$folder folder backed up successfully at $backup_folder/${folder}_$date"
  else
    echo "The folder $folder does not exist in $HOME/.mozilla/firefox/"
  fi
done

for file in user.js; do
  if [ -e "$HOME"/.mozilla/firefox/*.default-release/$file ]; then
    mv "$HOME"/.mozilla/firefox/*.default-release/$file "$backup_folder"/${file}_$date
    echo "$file file backed up successfully at $backup_folder/${file}_$date"
  else
    echo "The file $file does not exist in $HOME/.mozilla/firefox/"
  fi
done

printf "%s%sDone!!%s\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 1
clear

# Installing dotfiles
logo "Installing dotfiles.."
printf "Copying files to respective directories..\n"

[ ! -d ~/.config ] && mkdir -p ~/.config
[ ! -d ~/.themes ] && mkdir -p ~/.themes

for archivos in ~/penguinDotfiles/.config/*; do
	cp -R "${archivos}" ~/.config/
	if [ $? -eq 0 ]; then
		printf "%s%s%s folder copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
	else
		printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
		sleep 1
	fi
done

for archivos in ~/penguinDotfiles/themes/*; do
	cp -R "${archivos}" ~/.themes/
	if [ $? -eq 0 ]; then
		printf "%s%s%s folder copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
	else
		printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
		sleep 1
	fi
done

for archivos in ~/penguinDotfiles/lightdm-config/*; do
	sudo cp -R "${archivos}" /etc/lightdm/
	if [ $? -eq 0 ]; then
		printf "%s%s%s folder copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
	else
		printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
		sleep 1
	fi
done

for archivos in ~/penguinDotfiles/wallpapers; do
	cp -R "${archivos}" ~/
	if [ $? -eq 0 ]; then
		printf "%s%s%s folder copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
	else
		printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
		sleep 1
	fi
done

for archivos in ~/penguinFox/*; do
  cp -R "${archivos}" ~/.mozilla/firefox/*.default-release/
  if [ $? -eq 0 ]; then
	printf "%s%s%s folder copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
	sleep 1
  fi
done


printf "%s%sDone!\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 1
clear

# Installing NvChad
[ -d ~/NvChad ] && rm -rf ~/NvChad
logo "Installing NvChad"
rm -rf ~/.local/share/nvim
rm -rf ~/.config/nvim
cd
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
printf "%s%sDone!\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 1
clear

# Configuring dotfiles
logo "Configuring dotfiles"
chmod -R +x ~/.config/bspwm/
chmod -R +x ~/.config/openbox
chmod -R +x ~/.config/i3
chmod -R +x ~/.config/style
chmod +x ~/.config/sxhkd/sxhkdrc
chmod -R +x ~/.config/polybar
chmod -R +x ~/.config/rofi
chmod +x ~/.config/ranger/scope.sh
cp /etc/X11/xinit/xinitrc .xinitrc
echo "exec bspwm" >>.xinitrc
touch ~/.Xresources
printf "Xcursor.theme: Qogir-dark\nXcursor.size: 16" >>~/.Xresources
printf "%s%sDone!\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 1
clear

# Configuring pacman (for what???)
logo "Configuring pacman (for what???)"

grep "^Color" /etc/pacman.conf >/dev/null || sudo sed -i "s/^#Color$/Color/" /etc/pacman.conf
grep "ILoveCandy" /etc/pacman.conf >/dev/null || sudo sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
printf "%s%sDone!\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 1
clear

# Install LightDM theme
[ -d ~/lightdm-minimal ] && rm -rf ~/lightdm-minimal
logo "Installing LightDM theme"
cd
git clone https://github.com/p3nguin-kun/lightdm-minimal
sudo cp -R ~/lightdm-minimal /usr/share/lightdm-webkit/themes/minimal
printf "%s%sDone!\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 1

# Disable currently enabled display manager
if systemctl list-unit-files | grep enabled | grep -E 'gdm|lightdm|lxdm|lxdm-gtk3|sddm|slim|xdm'; then
	echo "Disabling currently enabled display manager"
	sudo systemctl disable $(systemctl list-unit-files | grep enabled | grep -E 'gdm|lightdm|lxdm|lxdm-gtk3|sddm|slim|xdm' | awk -F ' ' '{print $1}')
fi

echo "Enabling LightDM"
sudo systemctl enable lightdm
clear

# Enabling services
logo "Enabling services"

systemctl --user enable mpd.service
systemctl --user start mpd.service
sudo systemctl enable NetworkManager
systemctl --user enable pipewire pipewire-pulse wireplumber
printf "%s%sDone!%s\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 1
clear

# Changing shell to fish and goodbye
logo "Changing default shell to fish"
printf "%s%sIf your shell is not fish will be changed now.\nYour root password is needed to make the change.\n\nAfter that is important for you to reboot.\n %s\n" "${BLD}" "${CYE}" "${CNC}"
if [[ $SHELL != "/usr/bin/fish" ]]; then
	echo "Changing shell to fish, your root pass is needed."
	chsh -s /usr/bin/fish
else
	printf "%s%sYour shell is already fish\nGood bye! installation finished, now reboot%s\n" "${BLD}" "${CGR}" "${CNC}"
fi
