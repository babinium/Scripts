#!/bin/bash

# Instalar dependencias
sudo apt update
sudo apt install -y zsh git curl tldr

# Instalar Oh My Zsh sin pedir confirmación
export RUNZSH=no
export CHSH=yes
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Instalar plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# Configurar el archivo .zshrc
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="darkblood"/' ~/.zshrc
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# Agregar manualmente el source del syntax-highlighting al final
echo "source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc

# Agregar alias personalizado
echo 'alias update="sudo apt update && sudo apt upgrade -y"' >> ~/.zshrc

# Cambiar shell por defecto a zsh
chsh -s $(which zsh)

echo "✅ Instalación completa. Reiniciá la terminal o cerrá sesión para ver los cambios."
