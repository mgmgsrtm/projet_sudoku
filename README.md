## Objectifs du projet

Ce projet fournit une solution pour représenter, valider et analyser des grilles de Sudoku en utilisant les technologies XML, XSD et XSLT.

## Fichiers

- sudoku_schema.xsd               - Schéma XSD de validation
- sudoku_affichage.xslt           - XSLT pour affichage et validation

- grille_vide.xml                 - Grille vide (VIDE)
- grille_correcte.xml             - Grille partiellement remplie (CORRECTE)
- grille_simple.xml               - Grille partiellement remplie, simple (CORRECTE)
- grille_gagnante.xml             - Grille complète et correcte (GAGNANTE)
- grille_erreur_ligne.xml         - Grille avec doublon dans une ligne (INCORRECTE)
- grille_erreur_colonne.xml       - Grille avec doublon dans une colonne (INCORRECTE)
- grille_erreur_bloc.xml          - Grille avec doublon dans un bloc 3x3 (CORRECTE)
- grille_structure_invalide.xml   - Grille invalide (erreur de validation XSD)
- grille_valeur_invalide.xml      - Grille invalide (erreur de validation XSD)

*Fichiers SVG générés :*
- grille_vide.svg
- grille_correcte.svg
- grille_simple.svg
- grille_gagnante.svg
- grille_erreur_ligne.svg
- grille_erreur_colonne.svg
- grille_erreur_bloc.svg

- indice_1.xslt                   - Positions possibles pour le chiffre 1
- indice_2.xslt                   - Positions possibles pour le chiffre 2
- indice_3.xslt                   - Positions possibles pour le chiffre 3
- indice_4.xslt                   - Positions possibles pour le chiffre 4
- indice_5.xslt                   - Positions possibles pour le chiffre 5
- indice_6.xslt                   - Positions possibles pour le chiffre 6
- indice_7.xslt                   - Positions possibles pour le chiffre 7
- indice_8.xslt                   - Positions possibles pour le chiffre 8
- indice_9.xslt                   - Positions possibles pour le chiffre 9

*Fichiers SVG générés :*
- indice_1.svg
- indice_2.svg
- indice_3.svg
- indice_4.svg
- indice_5.svg
- indice_6.svg
- indice_7.svg
- indice_8.svg
- indice_9.svg

## Validation et transformations

```bash
# valider la structure XML contre le schéma XSD
# si valide, affiche : grille_correcte.xml validates
# si invalide, affiche les erreurs de structure
xmllint --noout --schema sudoku_schema.xsd grille_correcte.xml
xmllint --noout --schema sudoku_schema.xsd grille_structure_invalide.xml
xmllint --noout --schema sudoku_schema.xsd grille_valeur_invalide.xml
```
```bash
# générer la visualisation SVG d'une grille
xsltproc -o grille_correcte.svg sudoku_affichage.xslt grille_correcte.xml
```
```bash
# générer les positions possibles pour le chiffre 1
xsltproc -o indice_1.svg indice_1.xslt grille_correcte.xml
```

## Visualisation

Ouvrir les fichiers .svg dans un navigateur web

## Exemples de test

**Test 1 : Structure valide**
```bash
xmllint --noout --schema sudoku_schema.xsd grille_correcte.xml
# Résultat : grille_correcte.xml validates
```
**Test 2 : Nombre de cellules incorrect**
```bash
xmllint --noout --schema sudoku_schema.xsd grille_structure_invalide.xml
# Résultat : Element 'row': Missing child element(s)
```
**Test 3 : Valeur incorrecte**
```bash
xmllint --noout --schema sudoku_schema.xsd grille_valeur_invalide.xml
# Résultat : The value '10' is greater than the maximum value allowed ('9') 
```
**Test 4 : Grille vide**
```bash
xsltproc -o grille_vide.svg sudoku_affichage.xslt grille_vide.xml
# Statut : VIDE
```
**Test 5 : Grille correcte**
```bash
xsltproc -o grille_correcte.svg sudoku_affichage.xslt grille_correcte.xml
# Statut : CORRECTE 
```
**Test 6 : Grille gagnante**
```bash
xsltproc -o grille_gagnante.svg sudoku_affichage.xslt grille_gagnante.xml
# Statut : GAGNANTE
```
**Test 7 : Erreur dans une ligne**
```bash
xmllint --noout --schema sudoku_schema.xsd grille_erreur_ligne.xml
# Résultat : validates (XSD ne voit pas l'erreur)
xsltproc -o grille_erreur_ligne.svg sudoku_affichage.xslt grille_erreur_ligne.xml
# Statut : INCORRECTE (XSLT détecte l'erreur)
```
**Test 8 : Erreur dans une colonne**
```bash
xsltproc -o grille_erreur_colonne.svg sudoku_affichage.xslt grille_erreur_colonne.xml
# Statut : INCORRECTE 
```
**Test 9 : Erreur dans un bloc (vérification non réalisée)**
```bash
xsltproc -o grille_erreur_bloc.svg sudoku_affichage.xslt grille_erreur_bloc.xml
# Statut : CORRECTE　(alors qu’il devrait être INCORRECT)
```
**Test 10 : Positions possibles pour un chiffre**
```bash
xsltproc -o indice_4.svg indice_4.xslt grille_correcte.xml
```
**Test 11 : Tous les indices**
```bash
for i in 1 2 3 4 5 6 7 8 9; do
  xsltproc -o indice_$i.svg indice_$i.xslt grille_correcte.xml
done
```

## Auteurs

Haruka MIURA, Aleksandra BASANGOVA