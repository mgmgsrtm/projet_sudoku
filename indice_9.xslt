<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/2000/svg">
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <xsl:variable name="chiffre_cherche" select="9"/>
    
    <xsl:template match="/sudoku">
        <svg width="500" height="550" viewBox="0 0 500 550">
            
            <text x="250" y="30" text-anchor="middle" 
                  font-size="24" font-weight="bold" fill="#334">
                Positions possibles pour le chiffre <xsl:value-of select="$chiffre_cherche"/>
            </text>
            
            <g transform="translate(50, 80)">
                <xsl:call-template name="dessiner_grille"/>
                <xsl:call-template name="dessiner_chiffres"/>
                <xsl:call-template name="marquer_positions_possibles"/>
            </g>
            
            <!-- légende -->
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
    
    <!-- pour dessiner les chiffres existants -->
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
    
    <!-- pour marquer les positions possibles -->
    <xsl:template name="marquer_positions_possibles">
        <xsl:variable name="taille_cellule" select="40"/>
        
        <xsl:for-each select="row">
            <xsl:variable name="ligne" select="position()"/>
            
            <xsl:for-each select="cell">
                <xsl:variable name="colonne" select="position()"/>
                
                <!-- si cette cellule est vide -->
                <xsl:if test="not(@v)">
                    <!-- si le chiffre peut être placé ici -->
                    <xsl:variable name="peut_placer">
                        <xsl:call-template name="verifier_placement">
                            <xsl:with-param name="ligne" select="$ligne"/>
                            <xsl:with-param name="colonne" select="$colonne"/>
                        </xsl:call-template>
                    </xsl:variable>
                    
                    <xsl:if test="$peut_placer = 'true'">
                        <xsl:variable name="x" select="($colonne - 1) * $taille_cellule + $taille_cellule div 2"/>
                        <xsl:variable name="y" select="($ligne - 1) * $taille_cellule + $taille_cellule div 2 + 6"/>
                        
                        <!-- afficher le chiffre -->
                        <text x="{$x}" y="{$y}" 
                              text-anchor="middle" 
                              font-size="20" 
                              font-weight="bold"
                              fill="#ec44ffff">
                            <xsl:value-of select="$chiffre_cherche"/>
                        </text>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <!-- pour vérifier si le chiffre peut être placé -->
    <xsl:template name="verifier_placement">
        <xsl:param name="ligne"/>
        <xsl:param name="colonne"/>
        
        <xsl:variable name="dans_ligne" 
            select="count(/sudoku/row[position() = $ligne]/cell[@v = $chiffre_cherche])"/>
        
        <xsl:variable name="dans_colonne" 
            select="count(/sudoku/row/cell[position() = $colonne][@v = $chiffre_cherche])"/>
        
        <!-- calculer le bloc 3x3 -->
        <xsl:variable name="bloc_ligne" select="ceiling($ligne div 3)"/>
        <xsl:variable name="bloc_colonne" select="ceiling($colonne div 3)"/>
        
        <!-- vérifier le bloc 3x3 -->
        <xsl:variable name="dans_bloc">
            <xsl:value-of select="count(/sudoku/row[position() &gt;= ($bloc_ligne - 1) * 3 + 1 
                                                     and position() &lt;= $bloc_ligne * 3]
                                              /cell[position() &gt;= ($bloc_colonne - 1) * 3 + 1 
                                                    and position() &lt;= $bloc_colonne * 3]
                                              [@v = $chiffre_cherche])"/>
        </xsl:variable>
        
        <!-- le chiffre peut être placé si absent de la ligne, colonne et bloc -->
        <xsl:choose>
            <xsl:when test="$dans_ligne = 0 and $dans_colonne = 0 and $dans_bloc = 0">
                <xsl:text>true</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>false</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
