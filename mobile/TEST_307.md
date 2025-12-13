# Test et débogage de l'erreur 307

## 🔍 Pour identifier le problème

Avec le nouvel APK, les logs afficheront maintenant :

### **Lors de l'ajout d'un produit :**
```
🔧 [API] POST Normalisation:
   Endpoint original: /stock
   Segments: [stock]
   Is root route: true
   ✅ Trailing slash ajouté: /stock/
   🔧 URL finale: http://192.168.11.108:8000/api/stock/
🌐 [API] POST http://192.168.11.108:8000/api/stock/
```

### **Si vous voyez encore 307 :**
```
⚠️ [API] Redirection 307 détectée!
   URL demandée: http://192.168.11.108:8000/api/stock
   Location: http://192.168.11.108:8000/api/stock/
```

## 📋 Instructions

1. **Installez le nouvel APK**
2. **Connectez votre téléphone en USB**
3. **Lancez les logs :**
   ```bash
   cd mobile
   flutter logs
   ```
4. **Essayez d'ajouter un produit**
5. **Regardez les logs et copiez :**
   - La ligne `🔧 [API] POST Normalisation:`
   - La ligne `URL normalisée:`
   - La ligne `📥 [API] POST Response:`
   - Toute ligne avec `⚠️` ou `❌`

## 🔧 Solutions possibles

### Si les logs montrent que le trailing slash n'est PAS ajouté :
- La détection de route racine ne fonctionne pas
- Il faut forcer l'ajout pour `/stock` et `/chat`

### Si les logs montrent que le trailing slash EST ajouté mais 307 persiste :
- Le problème vient peut-être d'ailleurs
- Vérifier la configuration du backend
- Vérifier les headers

### Si vous voyez une autre URL dans les logs :
- Il y a peut-être un problème de construction d'URL
- Les logs montreront l'URL exacte utilisée

## 📝 Partagez les logs

Copiez les lignes pertinentes des logs pour que je puisse identifier le problème exact.

