# Dockerfile pour builder l'application Flutter - Hunger-Talk
# Ce Dockerfile permet de builder l'APK Android dans un conteneur Docker

FROM ubuntu:22.04

# Variables d'environnement
ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_VERSION=3.24.0
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

# Installer les dépendances système nécessaires
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Installer Flutter SDK
RUN cd /opt && \
    wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
    tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
    rm flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Accepter les licences Android
RUN flutter doctor --android-licenses || true

# Configurer Flutter
RUN flutter config --no-analytics && \
    flutter precache

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers du projet
COPY . .

# Installer les dépendances Flutter
RUN flutter pub get

# Builder l'APK (sera exécuté via docker-compose avec les bonnes commandes)
# Pour builder : docker-compose run --rm mobile flutter build apk --release

