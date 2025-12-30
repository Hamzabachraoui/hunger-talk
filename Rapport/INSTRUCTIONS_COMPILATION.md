# Instructions pour résoudre le problème des citations [?]

## Problème
Les citations apparaissent comme `[?]` au lieu de `[1]`, `[2]`, etc.

## Solution
Il faut recompiler le document LaTeX avec BibTeX pour générer les références bibliographiques.

## Méthode 1 : Script automatique (Recommandé)

### Windows (PowerShell)
```powershell
cd "G:\EMSI\3eme annee\PFA\Rapport"
.\compile_bib.ps1
```

### Windows (CMD)
```cmd
cd "G:\EMSI\3eme annee\PFA\Rapport"
compile_bib.bat
```

## Méthode 2 : Compilation manuelle

Dans le dossier `Rapport`, exécutez dans l'ordre :

1. **Première compilation LaTeX** (génère le fichier .aux avec les citations)
   ```
   pdflatex main.tex
   ```

2. **Compilation BibTeX** (génère le fichier .bbl avec les références)
   ```
   bibtex main
   ```

3. **Deuxième compilation LaTeX** (intègre les références)
   ```
   pdflatex main.tex
   ```

4. **Troisième compilation LaTeX** (résout toutes les références croisées)
   ```
   pdflatex main.tex
   ```

## Vérification

Après la compilation, ouvrez `main.pdf` et vérifiez que les citations apparaissent comme `[1]`, `[2]`, `[3]`, etc. au lieu de `[?]`.

## Note importante

- Assurez-vous que `bibliography.bib` contient toutes les références citées dans `chapitre1.tex`
- Les fichiers auxiliaires (`.aux`, `.bbl`, `.blg`) sont régénérés à chaque compilation
- Si le problème persiste, supprimez manuellement les fichiers `.aux`, `.bbl`, `.blg` et recommencez

