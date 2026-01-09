<?xml version="1.0" encoding="UTF-8"?>
<!-- Transformation XSLT permettant de générer une représentation SVG,
     ainsi qu’une indication de l’état de la grille (vide / correcte / gagnante / incorrecte) -->
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/2000/svg">
    

    <!-- l’attribut method="xml" permet de produire une sortie XML valide -->
    <!-- XSLT ne « dessine » pas directement, mais génère un document XML décrivant le SVG -->
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <!-- template principal -->
    <!-- ce template est exécuté en premier lorsque l’élément racine du document XML est <sudoku> -->
    <xsl:template match="/sudoku">

        <!-- conteneur SVG principal -->
        <!-- définition de la largeur, de la hauteur et du système de coordonnées -->
        <svg width="500" height="550" viewBox="0 0 500 550">
            
            <!-- titre centré en haut du SVG -->
            <text x="250" y="30" text-anchor="middle" 
                  font-size="24" font-weight="bold" fill="#334">
                Grille Sudoku
            </text>
            
            <!-- appel du template chargé d’afficher le statut -->
            <xsl:call-template name="afficher_statut"/>
            
            <!-- groupe principal  de grille déplacé afin de créer des marges -->
            <g transform="translate(50, 80)">
                <xsl:call-template name="dessiner_grille"/>
                <xsl:call-template name="dessiner_chiffres"/>
            </g>
            
        </svg>
    </xsl:template>
    
    <!-- template chargé d’afficher le statut -->
    <!-- Ce template se concentre uniquement sur l’affichage du statut -->
    <!-- la logique de détermination du statut est déléguée à un autre template -->
    <xsl:template name="afficher_statut">

        <xsl:variable name="statut">
            <!-- appel du template determiner_statut -->
            <!-- le resultat (chaîne de caractères) est stocké dans la variable statut -->
            <xsl:call-template name="determiner_statut"/>
        </xsl:variable>
        
        <!-- variable déterminant la couleur associée au statut -->
        <xsl:variable name="couleur">
            <!-- afficher_statutから返される文字列を代入した$statutを判定 -->
            <xsl:choose>
                <xsl:when test="$statut = 'GAGNANTE'">green</xsl:when>
                <xsl:when test="$statut = 'CORRECTE'">blue</xsl:when>
                <xsl:when test="$statut = 'INCORRECTE'">orange</xsl:when>
                <xsl:otherwise>gray</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <text x="250" y="55" text-anchor="middle" 
              font-size="18" font-weight="bold">
            
            <!-- générer dynamiquememnt l’attribut SVG fill -->
            <!-- l’attribut fill définit la couleur de remplissage du texte en SVG -->
            <xsl:attribute name="fill">
                <xsl:value-of select="$couleur"/>
            </xsl:attribute>

            <!-- contenu textuel affiché -->
            Statut : <xsl:value-of select="$statut"/>
        </text>
    </xsl:template>
    

    <!-- template chargé de déterminer le statut global de la grille -->
    <!-- la résultat est retourné sous forme de chaîne de caractères -->
    <xsl:template name="determiner_statut">

        <!-- variable contenant le nombre de cellules avec @v -->
        <xsl:variable name="nb_cellules_remplies" select="count(row/cell[@v])"/>
        
        <xsl:choose>

            <!-- si aucune cellule n’est remplie, la grille est considérée comme vide -->
            <xsl:when test="$nb_cellules_remplies = 0">
                <xsl:text>VIDE</xsl:text>
            </xsl:when>
            
            <!-- s'il y a des erreurs -->
            <!-- dans les autres cas, une vérification des erreurs est effectuée -->
            <!-- "true" : il y a des erreurs -->
            <xsl:otherwise>
                <xsl:variable name="a_erreurs">
                    <!-- le template verifier_erreurs produit "true" lorsqu’une erreur est détectée -->
                    <xsl:call-template name="verifier_erreurs"/>
                </xsl:variable>
                
                <xsl:choose>

                    <!-- s’il existe au moins une violation des règles -->
                    <xsl:when test="contains($a_erreurs, 'true')">
                        <xsl:text>INCORRECTE</xsl:text>
                    </xsl:when>
                    
                    <!-- toutes les cellules sont remplies et aucune erreur n’a été détectée -->
                    <xsl:when test="$nb_cellules_remplies = 81">
                        <xsl:text>GAGNANTE</xsl:text>
                    </xsl:when>
                    
                    <!-- Grille partiellement remplie sans erreur -->
                    <xsl:otherwise>
                        <xsl:text>CORRECTE</xsl:text>
                    </xsl:otherwise>

                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

    <!-- Template chargé de vérifier la présence d’erreurs (doublons) -->
    <xsl:template name="verifier_erreurs">

        <!-- vérification des doublons dans chaque ligne -->
        <xsl:for-each select="row">
            <!-- seules les cellule contenant une valeur sont prises en compte -->
            <xsl:for-each select="cell[@v]">
                <!-- valeur : valeur de la cellule courante -->
                <xsl:variable name="valeur" select="@v"/>
                <!--  pos: position de la cellule dans la ligne (1 à 9) -->
                <xsl:variable name="pos" select="position()"/>
                <!-- vérifier s’il existe déjà, avant cette position dans la ligne une cellule ayant la même valeur que "valeur" -->
                <xsl:if test="count(../cell[@v = $valeur and position() &lt; $pos]) &gt; 0">
                    <xsl:text>true</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
        
        <!-- vérification des doublons dans chaque colonne -->
        <!-- sauvegarde de la grille complète dans une variable -->
        <xsl:variable name="grille" select="/sudoku"/>
        <!-- Le nombre de colonnes est déterminé à partir de la première ligne -->
        <xsl:for-each select="row[1]/cell">
            <!-- col : numéro de la colonne en cours de traitement -->
            <xsl:variable name="col" select="position()"/>
            <!-- parcourir toutes les cellules de cette colonne contenant une valeur -->
            <xsl:for-each select="$grille/row/cell[position() = $col][@v]">
                <!-- valeur de la cellule courante-->
                <xsl:variable name="valeur" select="@v"/>
                <!-- numéro de la ligne courante, calculé comme le nombre de ligne précédant la ligne à laquelle appartient la cellule-->
                <!-- plus 1 (preceding-sibling::row sélectionne les lignes précédentes)-->
                <xsl:variable name="ligne" select="count(../preceding-sibling::row) + 1"/>
                <!-- Recherche d’une occurrence identique dans les lignes situées au-dessus -->
                <!-- position() correspond à l’indice des lignes (1 à 9).
                position() < $ligne sélectionne uniquement les lignes au-dessus.
                position() = $col permet ensuite de ne garder que les cellules
                appartenant à la même colonne. -->
                <xsl:if test="count($grille/row[position() &lt; $ligne]/cell[position() = $col][@v = $valeur]) &gt; 0">
                    <xsl:text>true</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>

    </xsl:template>


    <!-- template chargé de dessiner uniquement la structure de la grille  -->
    <xsl:template name="dessiner_grille">
        <!-- taille d’une cellule en pixels -->
        <xsl:variable name="taille_cellule" select="40"/>
        
        <xsl:call-template name="dessiner_lignes_horizontales">
            <!-- index représentant le numéro de la ligne à dessiner -->
            <xsl:with-param name="index" select="0"/>
            <!-- transmission de la taille des cellules à template -->
            <xsl:with-param name="taille" select="$taille_cellule"/>
        </xsl:call-template>
        
        <xsl:call-template name="dessiner_lignes_verticales">
            <xsl:with-param name="index" select="0"/>
            <xsl:with-param name="taille" select="$taille_cellule"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- template récursif dessinant les lignes horizontales -->
    <!-- 10本の横線を再帰で描画するテンプレート -->
    <xsl:template name="dessiner_lignes_horizontales">
        <xsl:param name="index"/>
        <xsl:param name="taille"/>
        
        <!-- condition d’arrêt de la récursion tant que l’index est inférieur ou égal à 9-->
        <xsl:if test="$index &lt;= 9">
            <!-- l’épaisseur de la ligne -->
            <xsl:variable name="epaisseur">
                <xsl:choose>
                    <xsl:when test="$index mod 3 = 0">3</xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <!-- ligne horizontale (y constant) s’étend sur toute la largeur de la grille (9 × 40 = 360 pixels) -->
            <!-- les expressions XPath entre {} sont évaluées à l’exécution -->
            <line x1="0" x2="{9 * $taille}" 
                  y1="{$index * $taille}" y2="{$index * $taille}"
                  stroke="#334" stroke-width="{$epaisseur}"/>
            
            <!-- appel récursif pour dessiner la ligne suivante -->
            <xsl:call-template name="dessiner_lignes_horizontales">
            <!-- appleler le même traitement pour la ligne suivante -->
                 <!-- L’indice (numéro de la ligne en cours) change -->
                <xsl:with-param name="index" select="$index + 1"/>
                <!-- la valeur de la taille reste constante -->
                <xsl:with-param name="taille" select="$taille"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- template récursif dessinant les lignes verticales -->
    <xsl:template name="dessiner_lignes_verticales">
        <xsl:param name="index"/>
        <xsl:param name="taille"/>
        
        <xsl:if test="$index &lt;= 9">
            <xsl:variable name="epaisseur">
                <xsl:choose>
                    <xsl:when test="$index mod 3 = 0">3</xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <!-- dessin d’une ligne verticale sur toute la hauteur de la grille -->
            <line x1="{$index * $taille}" x2="{$index * $taille}"
                  y1="0" y2="{9 * $taille}"
                  stroke="#334" stroke-width="{$epaisseur}"/>
            
            <!-- appel récursif pour dessiner la ligne suivante -->
            <xsl:call-template name="dessiner_lignes_verticales">
                <xsl:with-param name="index" select="$index + 1"/>
                <xsl:with-param name="taille" select="$taille"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- pour dessiner les chiffres --> 
    <!-- template chargé d’afficher les chiffres présents dans la grille -->
    <xsl:template name="dessiner_chiffres">

        <!-- définition de la taille pour assurer l’alignement -->
        <xsl:variable name="taille_cellule" select="40"/>
        
        <!-- parcourir des lignes de haut en bas -->
        <xsl:for-each select="row">
            <xsl:variable name="ligne" select="position()"/>
            
            <!-- Parcourir des colonnes de gauche à droite -->
            <xsl:for-each select="cell">
                <xsl:variable name="colonne" select="position()"/>
                
                <!-- affichage uniquement si la cellule contient une valeur -->
                <xsl:if test="@v">
                    <!-- calcul de coordonnée d’affichage du chiffre -->
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
                    
                    <text x="{$x}" y="{$y}" 
                          text-anchor="middle" 
                          font-size="20" 
                          font-weight="{$poids}"
                          fill="{$couleur}">
                        <!-- Valeur l’attribut @v sera affiché-->
                        <xsl:value-of select="@v"/>
                    </text>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
