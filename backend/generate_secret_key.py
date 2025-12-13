#!/usr/bin/env python3
"""
Script pour générer une SECRET_KEY sécurisée pour JWT
"""
import secrets

def generate_secret_key():
    """Génère une clé secrète aléatoire de 32 bytes encodée en base64"""
    key = secrets.token_urlsafe(32)
    print("=" * 60)
    print("SECRET_KEY générée :")
    print("=" * 60)
    print(key)
    print("=" * 60)
    print("\nCopie cette valeur dans tes variables d'environnement Railway")
    print("ou dans ton fichier .env")
    print("=" * 60)
    return key

if __name__ == "__main__":
    generate_secret_key()
