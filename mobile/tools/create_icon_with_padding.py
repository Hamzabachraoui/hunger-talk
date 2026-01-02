"""
Script pour créer une icône avec padding pour éviter la coupure
Les icônes adaptatives Android ont une zone sûre de 66% au centre
"""
from PIL import Image
import os

def create_icon_with_padding(input_path, output_path, padding_percent=0.17):
    """
    Crée une icône avec padding pour éviter la coupure
    
    Args:
        input_path: Chemin vers l'image source
        output_path: Chemin vers l'image de sortie
        padding_percent: Pourcentage de padding (0.17 = 17% de chaque côté)
    """
    # Ouvrir l'image source
    img = Image.open(input_path)
    
    # Calculer la nouvelle taille avec padding
    # Si padding = 17%, alors l'image occupera 66% du centre (100% - 2*17%)
    original_width, original_height = img.size
    
    # Calculer la taille de la zone sûre (66% du centre)
    safe_width = int(original_width * (1 - 2 * padding_percent))
    safe_height = int(original_height * (1 - 2 * padding_percent))
    
    # Redimensionner l'image pour qu'elle tienne dans la zone sûre
    img_resized = img.resize((safe_width, safe_height), Image.Resampling.LANCZOS)
    
    # Créer une nouvelle image avec la taille originale et fond transparent
    new_img = Image.new('RGBA', (original_width, original_height), (255, 255, 255, 0))
    
    # Calculer la position pour centrer l'image
    x_offset = (original_width - safe_width) // 2
    y_offset = (original_height - safe_height) // 2
    
    # Coller l'image redimensionnée au centre
    new_img.paste(img_resized, (x_offset, y_offset), img_resized if img_resized.mode == 'RGBA' else None)
    
    # Sauvegarder
    new_img.save(output_path, 'PNG')
    print(f"Icone creee avec padding: {output_path}")
    print(f"   Taille originale: {original_width}x{original_height}")
    print(f"   Zone sure: {safe_width}x{safe_height} (66% du centre)")

if __name__ == '__main__':
    # Chemins
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    assets_dir = os.path.join(project_root, 'assets', 'images')
    
    input_path = os.path.join(assets_dir, 'icon_app.png')
    output_path = os.path.join(assets_dir, 'icon_app_padded.png')
    
    if not os.path.exists(input_path):
        print(f"ERREUR: Fichier source introuvable: {input_path}")
        exit(1)
    
    create_icon_with_padding(input_path, output_path)
    print(f"\nUtilisez maintenant 'icon_app_padded.png' dans pubspec.yaml")

