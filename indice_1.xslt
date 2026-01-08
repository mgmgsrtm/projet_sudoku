<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/2000/svg">
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <!-- définition du chiffre à analyser -->
    <xsl:variable name="chiffre_cherche" select="1"/>
    
    <!-- traite l’élément racine <sudoku> du document XML -->
    <xsl:template match="/sudoku">
        <!-- conteneur SVG principal -->
        <svg width="500" height="550" viewBox="0 0 500 550">
            
            <!-- titre affiché en haut  -->
            <text x="250" y="30" text-anchor="middle" 
                  font-size="24" font-weight="bold" fill="#334">
                Positions possibles pour le chiffre <xsl:value-of select="$chiffre_cherche"/>
            </text>
            
            <!-- groupe principal déplacé pour créer des marges (origine déplacée à (50, 80)) -->
            <!-- l’affichage de la grille est réparti entre trois templates distincts. -->
            <g transform="translate(50, 80)">
                <!-- dessiner_grille, template qui dessine uniquement la structure de la grille -->
                <xsl:call-template name="dessiner_grille"/>
                <!-- dessiner_chiffres template affiche les chiffres déjà présents dans la grille -->
                <xsl:call-template name="dessiner_chiffres"/>
                <!-- marquer_positions_possibles, template chargé de marquer visuellement les cases dans lesquelles le chiffre $chiffre_cherche peut être placé -->
                <xsl:call-template name="marquer_positions_possibles"/>
            </g>
            
            <!-- légende explique la signification des couleurs utilisées -->
            <g transform="translate(50, 480)">
                <rect x="0" y="0" width="20" height="20" fill="#000"/>
                <text x="25" y="15" font-size="14">Chiffres fixes (donnés initialement)</text>
                
                <rect x="0" y="25" width="20" height="20" fill="#0066cc"/>
                <text x="25" y="40" font-size="14">Chiffres joués</text>
                
                <rect x="250" y="0" width="20" height="20" fill="#ec44ffff"/>
                <text x="275" y="15" font-size="14">Positions possibles pour <xsl:value-of select="$chiffre_cherche"/></text>
            </g>
            
        </svg>
    </xsl:template>
    
    <!-- pour dessiner la structure de la grille -->
    <xsl:template name="dessiner_grille">

        <!-- définition de la taille d’une cellule -->
        <xsl:variable name="taille_cellule" select="40"/>
        
        <!-- appel du template récursif pour dessiner les lignes horizontales de la grille -->
        <xsl:call-template name="dessiner_lignes_horizontales">
            <!-- en commençant à l’index 0 et en utilisant la taille des cellules -->
            <!-- xsl:with-param permet de transmettre des paramètres lors de l’appel d’un template -->
            <xsl:with-param name="index" select="0"/>
            <xsl:with-param name="taille" select="$taille_cellule"/>
        </xsl:call-template>
        
        <!-- appel du template récursif pour dessiner les lignes verticales de la grille -->
        <xsl:call-template name="dessiner_lignes_verticales">
            <xsl:with-param name="index" select="0"/>
            <xsl:with-param name="taille" select="$taille_cellule"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- template récursif pour les lignes horizontales -->
    <xsl:template name="dessiner_lignes_horizontales">
        <!-- les valeurs sont reçues depuis le template appelant -->
        <xsl:param name="index"/>
        <xsl:param name="taille"/>
        
        <!-- condition d’arrêt de la récursivité -->
        <xsl:if test="$index &lt;= 9">

            <!-- lignes plus épaisses pour les indices 0, 3, 6 et 9 (séparation des blocs 3×3) -->
            <xsl:variable name="epaisseur">
                <xsl:choose>
                    <xsl:when test="$index mod 3 = 0">3</xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <!-- dessin d’une ligne horizontale sur toute la largeur de la grille -->
            <!-- la coordonnée y est calculée comme index × taille, elle varie à chaque appel en fonction de l’index -->
            <line x1="0" x2="{9 * $taille}" 
                  y1="{$index * $taille}" y2="{$index * $taille}"
                  stroke="#334" stroke-width="{$epaisseur}"/>
            
            <!-- appel récursif du template pour dessiner la ligne suivante -->
            <xsl:call-template name="dessiner_lignes_horizontales">
                <!-- l’index est incrémenté de 1 , taille des cellules est transmise sans modification -->
                <xsl:with-param name="index" select="$index + 1"/>
                <xsl:with-param name="taille" select="$taille"/>
            </xsl:call-template>

        </xsl:if>
    </xsl:template>
    
    <!-- template récursif pour les lignes verticales -->
    <xsl:template name="dessiner_lignes_verticales">
         <!-- les valeurs sont reçues depuis le template appelant -->
        <xsl:param name="index"/>
        <xsl:param name="taille"/>
        
        <!-- condition d’arrêt de la récursivité -->
        <xsl:if test="$index &lt;= 9">
            <xsl:variable name="epaisseur">
                <xsl:choose>
                    <xsl:when test="$index mod 3 = 0">3</xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <!-- dessin d’une ligne verticales sur toute la hauteur de la grille -->
            <line x1="{$index * $taille}" x2="{$index * $taille}"
                  y1="0" y2="{9 * $taille}"
                  stroke="#334" stroke-width="{$epaisseur}"/>
            <!-- appel récursif du template pour dessiner la ligne suivante -->
            <xsl:call-template name="dessiner_lignes_verticales">
                <xsl:with-param name="index" select="$index + 1"/>
                <xsl:with-param name="taille" select="$taille"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- template chargé d’afficher les chiffres déjà présents dans la grille du Sudoku -->
    <xsl:template name="dessiner_chiffres">
        <!-- définition de la taille d’une cellule qui assure l’alignement entre les lignes de la grille et les chiffres -->
        <xsl:variable name="taille_cellule" select="40"/>
        
        <!-- traitement des 9 lignes de haut en bas -->
        <xsl:for-each select="row">

            <!-- position() correspond au numéro de la ligne courante (de 1 à 9) -->
            <xsl:variable name="ligne" select="position()"/>
            
            <!-- traitement des colonnes de gauche à droite -->
            <xsl:for-each select="cell">
                <xsl:variable name="colonne" select="position()"/>
                
                <!-- afficher le chiffre si @v existe -->
                <xsl:if test="@v">

                    <!-- centrage du texte dans la cellule(bord gauche de la cellule + la moitié de sa largeur) -->
                    <xsl:variable name="x" select="($colonne - 1) * $taille_cellule + $taille_cellule div 2"/>
                    <xsl:variable name="y" select="($ligne - 1) * $taille_cellule + $taille_cellule div 2 + 6"/>
                    
                    <!-- couleur différente pour les cellules fixes -->
                    <xsl:variable name="couleur">
                        <xsl:choose>
                            <xsl:when test="@fixed = 'true'">#000</xsl:when>
                            <xsl:otherwise>#0066cc</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <!-- poids de police différent pour les cellules fixes -->
                    <xsl:variable name="poids">
                        <xsl:choose>
                            <xsl:when test="@fixed = 'true'">bold</xsl:when>
                            <xsl:otherwise>normal</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <!-- Affichage de la valeur @v à la position calculée pour chaque cellule -->
                    <text x="{$x}" y="{$y}" 
                        text-anchor="middle" 
                        font-size="20" 
                        font-weight="{$poids}"
                        fill="{$couleur}">
                        <xsl:value-of select="@v"/>
                    </text>

                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <!-- template chargé de rechercher les cases où $chiffre_cherche peut être placé, et d'afficher ce chiffre comme candidat dans la grille SVG -->
    <xsl:template name="marquer_positions_possibles">

        <!-- définition de la taille des cellules. identique à celle utilisé pour le dessin de la grille et des chiffres existants -->
        <xsl:variable name="taille_cellule" select="40"/>
        
        <!-- parcours des lignes de la grille -->
        <xsl:for-each select="row">
            <xsl:variable name="ligne" select="position()"/>
            
            <!-- parcours des cellules de chaque ligne -->
            <xsl:for-each select="cell">
                <xsl:variable name="colonne" select="position()"/>
                
                <!-- si cette cellule est vide -->
                <xsl:if test="not(@v)">
                    <!-- si le chiffre peut être placé ici -->
                    <!-- variable peut_placer stocke le résultat du test-->
                    <!-- indique si le chiffre peut être placé dans la cellule courante(valeur "true" ou "false") -->
                    <!-- encapsulation dans <xsl:variable> permet de récupérer le résultat produit sous forme de chaîne de caractères-->
                    <xsl:variable name="peut_placer">
                         <!-- appel du template verifier_placement  -->
                        <xsl:call-template name="verifier_placement">
                            <!-- transmission des paramètres nécessaires au template verifier_placement -->
                            <xsl:with-param name="ligne" select="$ligne"/>
                            <xsl:with-param name="colonne" select="$colonne"/>
                        </xsl:call-template>
                    </xsl:variable>
                    
                    <xsl:if test="$peut_placer = 'true'">
                        
                        <!-- la position d’affichage du chiffre candidat dans la cellule -->
                        <xsl:variable name="x" select="($colonne - 1) * $taille_cellule + $taille_cellule div 2"/>
                        <xsl:variable name="y" select="($ligne - 1) * $taille_cellule + $taille_cellule div 2 + 6"/>
                        
                        <!-- Le chiffre n’est affiché que si le résultat de verifier_placement est "true" -->
                        <text x="{$x}" y="{$y}" 
                              text-anchor="middle" 
                              font-size="20" 
                              font-weight="bold"
                              fill="#ec44ffff">
                              <!-- Le chiffre affiché correspond au $chiffre_cherche -->
                              <xsl:value-of select="$chiffre_cherche"/>
                        </text>
                    </xsl:if>

                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <!-- pour vérifier si le chiffre peut être placé -->
    <xsl:template name="verifier_placement">
        <!-- paramètres permettant d’identifier la cellule à vérifier -->
        <xsl:param name="ligne"/>
        <xsl:param name="colonne"/>
        
        <!-- comptage des cellules de la ligne spécifiée ($ligne) dont la valeur est égale à $chiffre_cherche -->
        <xsl:variable name="dans_ligne" 
            select="count(/sudoku/row[position() = $ligne]/cell[@v = $chiffre_cherche])"/>
        
        <!-- comptage des occurrences du même chiffre que $chiffre_cherche dans la colonne spécifiée ($colonne) -->
        <xsl:variable name="dans_colonne" 
            select="count(/sudoku/row/cell[position() = $colonne][@v = $chiffre_cherche])"/>
        
        <!-- calcul du bloc 3×3 auquel appartient la cellule -->
        <!-- fonction ceiling(x) permet d’arrondir un nombre décimal à l’entier supérieur -->
        <!-- ligne = 1,2,3 → bloc_ligne = 1 -->
        <!-- ligne = 4,5,6 → bloc_ligne = 2 -->
        <!-- ligne = 7,8,9 → bloc_ligne = 3 -->
        <xsl:variable name="bloc_ligne" select="ceiling($ligne div 3)"/>
        <xsl:variable name="bloc_colonne" select="ceiling($colonne div 3)"/>
        
        <!-- vérifier le bloc 3x3 -->
        <xsl:variable name="dans_bloc">
            <!-- sélection des trois lignes correspondant au bloc 3×3 concerné -->
            <!-- comptage des cellules du bloc 3×3 contenant la valeur $chiffre_cherche -->
            <!-- L’opérateur and permet de définir une borne inf et une borne sup pour sélectionner un bloc -->
            <xsl:value-of select="count(/sudoku/row[position() &gt;= ($bloc_ligne - 1) * 3 + 1 
                                                     and position() &lt;= $bloc_ligne * 3]
                                              /cell[position() &gt;= ($bloc_colonne - 1) * 3 + 1 
                                                    and position() &lt;= $bloc_colonne * 3]
                                              [@v = $chiffre_cherche])"/>
        </xsl:variable>
        
        <!-- variable "peut_placer" de template marquer_positions_possibles retourne true(le chiffre peut être placé) si absent de la ligne, colonne et bloc -->
        <xsl:choose>
            <!-- Le chiffre peut être placé uniquement s’il est absent de la ligne, de la colonne et du bloc -->
            <xsl:when test="$dans_ligne = 0 and $dans_colonne = 0 and $dans_bloc = 0">
                <xsl:text>true</xsl:text>
            </xsl:when>
            <!-- si au moins une occurrence le résultat est false -->
            <xsl:otherwise>
                <xsl:text>false</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
