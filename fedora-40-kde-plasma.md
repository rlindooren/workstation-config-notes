# Configuring Fedora 40 KDE Plasma 6

A reminder for myself, about the **manual** installation steps I ran.

## Core

```shell
hostnamectl set-hostname hpz440
```

```shell
sudo dnf -y update
sudo dnf -y install dnf-plugins-core
```

```shell
sudo dnf -y install curl wget jq
```

```shell
sudo rpm -Uvh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
#sudo rpm -Uvh http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

```shell
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

### Git

_Before oh my zsh_

```shell
sudo dnf -y install git
```

Enable automatic upsteam:
```shell
git config --global push.autoSetupRemote true
```

Verify config (and update if needed):
```shell
git config --global --edit
```

### zsh & Oh my zsh

```shell
sudo dnf -y install zsh
chsh -s $(which zsh)
zsh
cp ~/.zshrc ~/.zshrc.bak.1
```

```shell
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
sudo dnf -y install powerline-fonts

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-you-should-use

sudo dnf -y install bat
git clone https://github.com/fdellwing/zsh-bat.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-bat

cp ~/.zshrc ~/.zshrc.bak.2
```

I manually updated these settings in `.zshrc`:
```config
ZSH_THEME="powerlevel9k/powerlevel9k"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-you-should-use
    zsh-bat
)
```

## Docker

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

### Sublime Text

```shell
sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
sudo dnf -y install sublime-text
```

### IntelliJ IDEA

I used the toolbox: https://www.jetbrains.com/toolbox-app/.

```shell
sudo dnf -y install jetbrains-mono-fonts
```

### VS Code

```shell
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
sudo dnf -y install code
```

### Java etc. (via SDKman)

```shell
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java
sdk install kotlin
skd install maven
```

### GoLang & Python

```shell
sudo dnf -y install go python3
```

### SSH

_Note: after installation of ZSH._

_Note: I already had a key, but instructions for generating one can be found [here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)._

```shell
echo "export GIT_ASKPASS=\"\${SSH_ASKPASS}\"" >> .zshrc
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

## Music, multimedia, etc.

```shell
sudo dnf install vlc
```
