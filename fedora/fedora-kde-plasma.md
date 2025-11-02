# Configuring Fedora 40 (& 41, 42, ...) KDE Plasma

These are the **manual** installation steps I ran.

## Core

```shell
sudo hostnamectl set-hostname hpz440
```

```shell
sudo dnf -y update
reboot
```

### Software package sources

```shell
sudo dnf -y install dnf-plugins-core
```

https://rpmfusion.org/Configuration#Command_Line_Setup_using_rpm

```shell
sudo rpm -Uvh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
# Using non-free for the Nvidia driver
sudo rpm -Uvh http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

#Fedora <= 40 --> sudo dnf config-manager --enable fedora-cisco-openh264
#Fedora >= 41 --> sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
```

```shell
sudo dnf -y install curl wget bat jq
```

```shell
#sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

```shell
sudo dnf -y install snapd
# According to the docs: "Either log out and back in again, or restart your system, to ensure snap’s paths are updated correctly."
reboot
```

### Drivers

#### Nivida

https://rpmfusion.org/Howto/NVIDIA#Current_GeForce.2FQuadro.2FTesla

```shell
sudo dnf update -y
sudo dnf install akmod-nvidia
sudo dnf install xorg-x11-drv-nvidia-cuda #optional for cuda/nvdec/nvenc support

modinfo -F version nvidia # should output the version of the driver sand not `modinfo: ERROR: Module nvidia not found`.
```

#### Printer

_After installing via settings (IPP via DNS-SD)_

```shell
sudo dnf -y install hplip hplip-gui
```

### SSH

_Note: I already had a key, but instructions for generating one can be found [here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)._

```shell
sudo dnf -y install ksshaskpass
echo "export SSH_ASKPASS=\"\$(which ksshaskpass)\"" >> .bashrc
echo "export GIT_ASKPASS=\"\${SSH_ASKPASS}\"" >> .bashrc
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519 </dev/null
ssh-add -l
```

Add to `~/.ssh/config`:

```shell
nano ~/.ssh/config
```

```
Host * 
    AddKeysToAgent yes
```

### Git

_Before 'Oh my zsh'._

```shell
sudo dnf -y install git
```

Verify config (and update if needed -- e.g. `user`):
```shell
git config --global --edit
```

```
git config --global user.name "Ricardo Lindooren" 
git config --global user.email "ricardo@..." 
git config --global user.username "rlindooren"
```

```
git config --global init.defaultBranch main
```

Enable automatic upsteam:
```shell
git config --global push.autoSetupRemote true
```

Enable symlinks:
```shell
git config --global core.symlinks true
```

https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration

### ZSH & Oh my zsh

```shell
sudo dnf -y install zsh
chsh -s $(which zsh)
zsh
```

```shell
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/bhilburn/powerlevel9k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel9k
sudo dnf -y install powerline-fonts

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-you-should-use
#git clone https://github.com/fdellwing/zsh-bat.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-bat

echo "export SSH_ASKPASS=\"\$(which ksshaskpass)\"" >> .zshrc
echo "export GIT_ASKPASS=\"\${SSH_ASKPASS}\"" >> .zshrc

cp ~/.zshrc ~/.zshrc.bak.1
```

I manually updated these settings in `.zshrc`:

```shell
nano ~/.zshrc
```

```
ZSH_THEME="powerlevel9k/powerlevel9k"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-you-should-use
    #zsh-bat
    ssh-agent
)

# ! Above `source $ZSH/oh-my-zsh.sh`
zstyle :omz:plugins:ssh-agent helper ksshaskpass
zstyle :omz:plugins:ssh-agent identities id_ed25519
```

Reload:
```shell
source ~/.zshrc
```

### Docker

```shell
sudo dnf -y remove docker \
                   docker-client \
                   docker-client-latest \
                   docker-common \
                   docker-latest \
                   docker-latest-logrotate \
                   docker-logrotate \
                   docker-selinux \
                   docker-engine-selinux \
                   docker-engine
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
#docker run hello-world
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

## Development

## GPG (PGP)

```shell
sudo dnf -y install gnupg2 pinentry-gnome3

mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
chmod 600 ~/.gnupg/*
sudo chown -R $(whoami) ~/.gnupg
gpgconf --kill gpg-agent
mkdir -p ~/gpg-keys/public
mkdir -p ~/gpg-keys/private
```

```shell
gpg --import *****.asc
```

```shell
git config --global user.signingkey *****
git config --global commit.gpgsign true
git config --global gpg.program gpg
```

```
#gpg --full-generate-key
#gpg --list-secret-keys --keyid-format=long
#gpg --armor --export ***** > ~/gpg-keys/public/*****.asc
#gpg --armor --export-secret-keys ***** > ~/gpg-keys/private/*****.asc
```

### Github CLI

```shell
# DNF5 installation commands -- https://github.com/cli/cli/blob/trunk/docs/install_linux.md
sudo dnf install dnf5-plugins
sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf -y install gh --repo gh-cli
gh auth login
```

### Sublime Text

```shell
sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
sudo dnf -y install sublime-text
```

### Java etc. (via SDKman)

```shell
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java
sdk install kotlin
sdk install maven
```

### IntelliJ IDEA

I used the toolbox: https://www.jetbrains.com/toolbox-app/.

```shell
sudo mkdir -p /opt/jetbrains/toolbox
sudo chown ${USER} /opt/jetbrains/toolbox

# Downloaded version will most likely be different!
tar -zxvf ~/Downloads/jetbrains-toolbox-2.3.2.31487.tar.gz -C /opt/jetbrains/toolbox
/opt/jetbrains/toolbox/jetbrains-toolbox-2.3.2.31487/jetbrains-toolbox
```

```shell
sudo dnf -y install jetbrains-mono-fonts
```

Add toolbox scripts to `$PATH`:

```shell
echo "export PATH=\$PATH:\$HOME/.local/share/JetBrains/Toolbox/scripts" >> ~/.zshrc
```

### VS Code

```shell
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
sudo dnf -y install code
```

### GoLang & Python

```shell
sudo dnf -y install go python3
```

### Other/misc.

#### Markdown to PDF

```shell
sudo dnf -y install pandoc
sudo dnf -y install texlive-scheme-full
#sudo dnf -y install texlive-tex-gyre
```

## Music, multimedia, etc.

```shell
sudo dnf -y install vlc
```

To fix movies only showing a black screen:

```shell
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
```

### To shorten video clips
```shell
sudo dnf install avidemux
```

### E-book

```shell
sudo dnf -y install calibre arianna
```

### Spotify (via Snap)

https://snapcraft.io/install/spotify/fedora

```shell
sudo snap install spotify
```

## Other

```shell
sudo dnf -y install langpacks-nl
```

```shell
sudo dnf install fzf 
```
