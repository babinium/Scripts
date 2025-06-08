#!/data/data/com.termux/files/usr/bin/bash

echo "🧩 Instalando dependencias básicas..."
pkg update && pkg upgrade -y
pkg install -y proot-distro git curl wget nano zsh

echo "📦 Instalando Debian dentro de Termux..."
proot-distro install debian

echo "⚙️ Configurando Termux para iniciar Debian automáticamente..."
echo -e '\n# Iniciar Debian automáticamente\nproot-distro login debian' >> ~/.bashrc

echo "📥 Preparando script interno para Debian..."
cat > ~/.setup-debian-zsh.sh << 'EOF'
#!/bin/bash

echo "🧰 Actualizando Debian..."
apt update && apt upgrade -y
apt install -y zsh git curl wget locales

echo "🌍 Configurando locale..."
sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8

echo "🌟 Instalando Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "🔌 Instalando plugins: autosuggestions y syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "🎨 Configurando tema y plugins..."
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="darkblood"/' ~/.zshrc
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

echo "⚙️ Agregando arranque automático de zsh en Debian..."
echo -e '\n# Lanzar zsh automáticamente\nif [ -n "$PS1" ] && [ -x "$(command -v zsh)" ]; then\n  exec zsh\nfi' >> ~/.bashrc

echo "✅ Debian con Zsh, Oh My Zsh y plugins configurado correctamente."
EOF

echo "🚀 Ejecutando setup interno dentro de Debian..."
proot-distro login debian -- bash ~/../home/.setup-debian-zsh.sh

echo "🧹 Eliminando script temporal..."
rm ~/.setup-debian-zsh.sh

echo "✅ Sistema completamente configurado. Abrí Termux y ya estarás en Debian con Zsh y todo listo."