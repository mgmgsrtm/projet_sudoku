<?xml version="1.0" encoding="UTF-8"?>
<!-- transformation XSLT pour générer une représentation SVG, une indication du statut (vide/correcte/gagnante/incorrecte) -->
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/2000/svg">
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <!-- template principal -->
    <xsl:template match="/sudoku">
        <svg width="500" height="550" viewBox="0 0 500 550">
            
            <text x="250" y="30" text-anchor="middle" 
                  font-size="24" font-weight="bold" fill="#334">
                Grille Sudoku
            </text>
            
            <xsl:call-template name="afficher_statut"/>
            
            <!-- dessin de la grille -->
            <g transform="translate(50, 80)">
                <xsl:call-template name="dessiner_grille"/>
                <xsl:call-template name="dessiner_chiffres"/>
            </g>
            
        </svg>
    </xsl:template>
    
    <!-- template pour afficher le statut -->
    <xsl:template name="afficher_statut">
        <xsl:variable name="statut">
            <xsl:call-template name="determiner_statut"/>
        </xsl:variable>
        
        <xsl:variable name="couleur">
            <xsl:choose>
                <xsl:when test="$statut = 'GAGNANTE'">green</xsl:when>
                <xsl:when test="$statut = 'CORRECTE'">blue</xsl:when>
                <xsl:when test="$statut = 'INCORRECTE'">orange</xsl:when>
                <xsl:otherwise>gray</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <text x="250" y="55" text-anchor="middle" 
              font-size="18" font-weight="bold">
            <xsl:attribute name="fill">
                <xsl:value-of select="$couleur"/>
            </xsl:attribute>
            Statut : <xsl:value-of select="$statut"/>
        </text>
    </xsl:template>
    
    <!-- template pour déterminer le statut de la grille -->
    <xsl:template name="determiner_statut">
        <!-- si la grille est vide -->
        <xsl:variable name="nb_cellules_remplies" select="count(row/cell[@v])"/>
        
        <xsl:choose>
            <xsl:when test="$nb_cellules_remplies = 0">
                <xsl:text>VIDE</xsl:text>
            </xsl:when>
            
            <!-- s'il y a des erreurs -->
            <xsl:otherwise>
                <xsl:variable name="a_erreurs">
                    <xsl:call-template name="verifier_erreurs"/>
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="contains($a_erreurs, 'true')">
                        <xsl:text>INCORRECTE</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="$nb_cellules_remplies = 81">
                        <xsl:text>GAGNANTE</xsl:text>
                    </xsl:when>
                    
                    <!-- partiellement remplie sans erreur -->
                    <xsl:otherwise>
                        <xsl:text>CORRECTE</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- pour vérifier les erreurs -->
    <xsl:template name="verifier_erreurs">
        <!-- vérifier les doublons dans chaque ligne -->
        <xsl:for-each select="row">
            <xsl:for-each select="cell[@v]">
                <xsl:variable name="valeur" select="@v"/>
                <xsl:variable name="pos" select="position()"/>
                <!-- si ce n'est pas la première occurrence de cette valeur dans la ligne -->
                <xsl:if test="count(../cell[@v = $valeur and position() &lt; $pos]) &gt; 0">
                    <xsl:text>true</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
        
        <!-- vérifier les doublons dans chaque colonne -->
        <xsl:variable name="grille" select="/sudoku"/>
        <xsl:for-each select="row[1]/cell">
            <xsl:variable name="col" select="position()"/>
            <xsl:for-each select="$grille/row/cell[position() = $col][@v]">
                <xsl:variable name="valeur" select="@v"/>
                <xsl:variable name="ligne" select="count(../preceding-sibling::row) + 1"/>
                <!-- si ce n'est pas la première occurrence de cette valeur dans la colonne -->
                <xsl:if test="count($grille/row[position() &lt; $ligne]/cell[position() = $col][@v = $valeur]) &gt; 0">
                    <xsl:text>true</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <!-- pour dessiner la structure de la grille -->
    <xsl:template name="dessiner_grille">
        <xsl:variable name="taille_cellule" select="40"/>
        
        <xsl:call-template name="dessiner_lignes_horizontales">
            <xsl:with-param name="index" select="0"/>
            <xsl:with-param name="taille" select="$taille_cellule"/>
        </xsl:call-template>
        
        <xsl:call-template name="dessiner_lignes_verticales">
            <xsl:with-param name="index" select="0"/>
            <xsl:with-param name="taille" select="$taille_cellule"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- template récursif pour les lignes horizontales -->
    <xsl:template name="dessiner_lignes_horizontales">
        <xsl:param name="index"/>
        <xsl:param name="taille"/>
        
        <xsl:if test="$index &lt;= 9">
            <xsl:variable name="epaisseur">
                <xsl:choose>
                    <xsl:when test="$index mod 3 = 0">3</xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <line x1="0" x2="{9 * $taille}" 
                  y1="{$index * $taille}" y2="{$index * $taille}"
                  stroke="#334" stroke-width="{$epaisseur}"/>
            
            <xsl:call-template name="dessiner_lignes_horizontales">
                <xsl:with-param name="index" select="$index + 1"/>
                <xsl:with-param name="taille" select="$taille"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- template récursif pour les lignes verticales -->
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
            
            <line x1="{$index * $taille}" x2="{$index * $taille}"
                  y1="0" y2="{9 * $taille}"
                  stroke="#334" stroke-width="{$epaisseur}"/>
            
            <xsl:call-template name="dessiner_lignes_verticales">
                <xsl:with-param name="index" select="$index + 1"/>
                <xsl:with-param name="taille" select="$taille"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- pour dessiner les chiffres -->
    <xsl:template name="dessiner_chiffres">
        <xsl:variable name="taille_cellule" select="40"/>
        
        <xsl:for-each select="row">
            <xsl:variable name="ligne" select="position()"/>
            
            <xsl:for-each select="cell">
                <xsl:variable name="colonne" select="position()"/>
                
                <!-- afficher le chiffre si @v existe -->
                <xsl:if test="@v">
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
                        <xsl:value-of select="@v"/>
                    </text>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
