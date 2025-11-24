#!/bin/bash

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar curl si no está instalado
if ! command -v curl &> /dev/null
then
    echo "Instalando curl..."
    sudo apt install curl -y
fi

# Añadir repositorio NodeSource para Node.js 22.x
echo "Añadiendo repositorio NodeSource para Node.js 22.x..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

# Instalar Node.js y npm
echo "Instalando Node.js y npm..."
sudo apt install -y nodejs

# Verificar instalación de Node.js y npm
echo "Versión de Node.js:"
node -v
echo "Versión de npm:"
npm -v

# Instalar Gemini CLI globalmente
echo "Instalando Gemini CLI..."
sudo npm install -g @google/gemini-cli

# Verificar instalación de Gemini CLI
echo "Versión de Gemini CLI:"
gemini --version

echo "Instalación completada. Para iniciar Gemini CLI escribe: gemini"
