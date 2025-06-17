FROM node:22-bullseye

# Instalar herramientas del sistema
RUN apt-get update && apt-get install -y \
    git \
    vim \
    curl \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario de desarrollo
RUN useradd -m -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Instalar pnpm globalmente
RUN npm install -g pnpm@latest

# Configurar el directorio de trabajo
WORKDIR /workspace

# Cambiar al usuario developer
USER developer

# Configurar git (opcional)
RUN git config --global init.defaultBranch main 