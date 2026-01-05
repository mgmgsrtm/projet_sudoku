<?xml version="1.0" encoding="UTF-8"?>
<!-- transformation XSLT pour générer une représentation SVG, une indication du statut (vide/correcte/gagnante/incorrecte) -->
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/2000/svg">
    <!-- ↑SVG を解釈できる環境（ブラウザなど）で開いているからSVGが描画される-->
    

    <!-- method="xmlによって、 XSLT の出力をXML として正しく書き出すための指定-->
    <!-- SVG が図形として描画されるのは、出力された XML が SVG 名前空間を持つ <svg> 要素 -->
    <!-- XSLT は SVG を「描画」しているのではなく、SVG を表す XML を「生成」しています -->
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <!-- template principal -->
    <!-- 入力 XML のルート要素が <sudoku> のときこのテンプレートが 最初に実行される Sudoku XML 1 つに対してSVG 1 枚を生成する設計 -->
    <xsl:template match="/sudoku">

        <!-- 出力全体が SVG.幅・高さ・表示座標系を定義 ここから先はすべて図形や文字として描画される -->
        <svg width="500" height="550" viewBox="0 0 500 550">
            
            <!-- 中央揃え -->
            <text x="250" y="30" text-anchor="middle" 
                  font-size="24" font-weight="bold" fill="#334">
                Grille Sudoku
            </text>
            
            <!-- 状態表示を担当するテンプレートを呼ぶ -->
            <xsl:call-template name="afficher_statut"/>
            
            <!-- dessin de la grille -->
            <g transform="translate(50, 80)">
                <xsl:call-template name="dessiner_grille"/>
                <xsl:call-template name="dessiner_chiffres"/>
            </g>
            
        </svg>
    </xsl:template>
    
    <!-- template pour afficher le statut -->
    <!-- afficher_statutは数独グリッドの「状態」を取得し、それを色付きテキストとして SVG に表示するテンプレート -->
    <!-- 判定はここではしない表示に専念している -->
    <xsl:template name="afficher_statut">

        <xsl:variable name="statut">
            <!-- 別テンプレート determiner_statut を呼び出しその戻り値（文字列）を statut に保存 -->
            <xsl:call-template name="determiner_statut"/>
        </xsl:variable>
        
        <!-- 色を決める couleur 変数 -->
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
            
            <!--　SVG の fill 属性を生成 -->
            <!-- fill は SVG において「塗りの色」を指定する属性 -->
            <xsl:attribute name="fill">
                <xsl:value-of select="$couleur"/>
            </xsl:attribute>

            <!-- 表示されるテキスト内容 -->
            Statut : <xsl:value-of select="$statut"/>
        </text>
    </xsl:template>
    


    <!-- template pour déterminer le statut de la grille -->
    <!-- 数独グリッド全体の状態を判定し、その結果を文字列として返すテンプレート -->
    <xsl:template name="determiner_statut">
        <!-- si la grille est vide -->

        <!-- nb_cellules_remplies変数に値が入っているマスの数を設定-->
        <xsl:variable name="nb_cellules_remplies" select="count(row/cell[@v])"/>
        
        <xsl:choose>

            <!-- 1 つも数字が入っていない　後の判定（エラー・勝利）をする意味がない -->
            <xsl:when test="$nb_cellules_remplies = 0">
                <xsl:text>VIDE</xsl:text>
            </xsl:when>
            
            <!-- s'il y a des erreurs -->
            <!-- 別テンプレートverifier_erreursで行・列の重複をチェック -->
            <!-- "true" が含まれていればエラーあり -->
            <xsl:otherwise>
                <xsl:variable name="a_erreurs">
                    <!-- 別に定義されたverifier_erreurs はエラーが見つかるたびに "true" を出力 -->
                    <xsl:call-template name="verifier_erreurs"/>
                </xsl:variable>
                
                <xsl:choose>

                    <!-- 一つでもルール違反があれば INCORRECTE -->
                    <xsl:when test="contains($a_erreurs, 'true')">
                        <xsl:text>INCORRECTE</xsl:text>
                    </xsl:when>
                    
                    <!-- すべてのマスが埋まっている＆かつ、ここまで来ているということはエラーがない -->
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
    <!-- 数独の盤面にルール違反（重複）があるかを調べるテンプレート -->
    <xsl:template name="verifier_erreurs">

        <!-- 行の中の重複　vérifier les doublons dans chaque ligne -->
        <xsl:for-each select="row">
            <!-- 比較対象は数値があるセルだけ -->
            <xsl:for-each select="cell[@v]">
                <!-- valeur：今見ている数字 -->
                <xsl:variable name="valeur" select="@v"/>
                <!-- pos: 行内での位置（1〜9） -->
                <xsl:variable name="pos" select="position()"/>
                <!-- si ce n'est pas la première occurrence de cette valeur dans la ligne -->
                <!-- 変数"valeur"を同じ値を持つセルをかぞえて、０より大きいか -->
                <xsl:if test="count(../cell[@v = $valeur and position() &lt; $pos]) &gt; 0">
                    <xsl:text>true</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
        
        <!-- 列ごとの重複チェック -->
        <!-- vérifier les doublons dans chaque colonne -->
        <!-- グリッド全体を変数に保存 -->
        <xsl:variable name="grille" select="/sudoku"/>
        <!-- 列番号を決める。1 行目のセル数 = 列数分だけ繰り返すつまり９回-->
        <xsl:for-each select="row[1]/cell">
            <!-- 今チェックしている列番号をcolという変数として保存 -->
            <!-- position() は、現在処理しているノードがそのノード集合（node-set）の中で何番目かを表す XPath 関数 -->
            <xsl:variable name="col" select="position()"/>
            <!-- 全行の、col 列目 で値が入っているセルを対象にする-->
            <xsl:for-each select="$grille/row/cell[position() = $col][@v]">
                <!-- valeur：今見ているcellの数字 -->
                <xsl:variable name="valeur" select="@v"/>
                <!-- 自分の行番号＝今見ているcellが属しているrow が、上から何行目か ＝じぶんより前に現れた〇〇の数＋１-->
                <!-- preceding-sibling::row　同じ親を持つ兄弟要素（row）のうち、自分より前にある row 要素 -->
                <xsl:variable name="ligne" select="count(../preceding-sibling::row) + 1"/>
                <!-- si ce n'est pas la première occurrence de cette valeur dans la colonne -->
                <!-- 同じ列の中で、今のセルより上に、同じ値があるか？ -->
                <!-- $grille は /sudoku（盤面全体）,/row[...] は「行（row）を選ぶ -->
                <!-- position() は「row の並び順（1〜9）」、「< $ligne」 は「自分の行より上だけ」 つまり自分より上の行全体だけを対象にする-->
                <!-- position() = $col　次に、その上側の各行全部から 自分と同じ列番号$colの cell だけを取る　つまり「同じ１列のセル」だけに絞る-->
                <!-- さらに、@v = $valeur　→ 値が自分の数字と同じセルだけが対象 -->
                <!-- 条件に合うセルが1個でもあれば　true -->
                <xsl:if test="count($grille/row[position() &lt; $ligne]/cell[position() = $col][@v = $valeur]) &gt; 0">
                    <xsl:text>true</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>

    </xsl:template>


    <!-- 数独の 9×9 グリッドの「枠線」だけを描画するテンプレートdessiner_grille -->
    <!-- pour dessiner la structure de la grille -->
    <xsl:template name="dessiner_grille">
        <!-- 1 マスの幅・高さ（ピクセル -->
        <xsl:variable name="taille_cellule" select="40"/>
        
        <xsl:call-template name="dessiner_lignes_horizontales">
            <!-- 10本中、今何本目の線を描いているかを表す変数index -->
            <xsl:with-param name="index" select="0"/>
            <!-- 作業計算に使う1マス分の長さ　再帰テンプレートに情報を渡す -->
            <xsl:with-param name="taille" select="$taille_cellule"/>
        </xsl:call-template>
        
        <xsl:call-template name="dessiner_lignes_verticales">
            <xsl:with-param name="index" select="0"/>
            <xsl:with-param name="taille" select="$taille_cellule"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- template récursif pour les lignes horizontales -->
    <!-- 10本の横線を再帰で描画するテンプレート -->
    <xsl:template name="dessiner_lignes_horizontales">
        <!-- パラメーター -->
        <xsl:param name="index"/>
        <xsl:param name="taille"/>
        
        <!-- 再帰の終了条件 index が 9 以下のときだけ処理する -->
        <xsl:if test="$index &lt;= 9">
            <!-- 線の太さをeppaisseurとして決めるロジック -->
            <xsl:variable name="epaisseur">
                <xsl:choose>
                    <xsl:when test="$index mod 3 = 0">3</xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <!-- 横一直線の線を描くための座標の設定 index によって y 座標を計算,水平で（ｙが同じ）横いっぱいは9*40=360px-->
            <!-- {} の中は XPath 式 実行時に計算される -->
            <line x1="0" x2="{9 * $taille}" 
                  y1="{$index * $taille}" y2="{$index * $taille}"
                  stroke="#334" stroke-width="{$epaisseur}"/>
                  <!-- strokeはsvgにおける「線の色」を指定する属性 -->
                  <!-- strokeはsvgにおける「線の太さ」を指定する属性 -->
            
            <!-- 再帰呼び出し -->
            <xsl:call-template name="dessiner_lignes_horizontales">
                <!-- 同じ処理を次の線に対して繰り返す　引数　dessiner_lignes_horizontales(index + 1, taille) -->
                <!-- 状態（何本目か）が変わる -->
                <xsl:with-param name="index" select="$index + 1"/>
                <!-- 設定値（定数） -->
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
            
            <!-- <line> 要素（SVG） -->
             <!-- 横一直線の線を描くための座標の設定 index によって x 座標を計算,線は垂直で（xが同じ）縦いっぱいは9*40=360px-->
            <line x1="{$index * $taille}" x2="{$index * $taille}"
                  y1="0" y2="{9 * $taille}"
                  stroke="#334" stroke-width="{$epaisseur}"/>
            
            <!-- 同じ処理を次の線に対して繰り返す　引数　dessiner_lignes_verticale(index + 1, taille) -->
            <xsl:call-template name="dessiner_lignes_verticales">
                <xsl:with-param name="index" select="$index + 1"/>
                <xsl:with-param name="taille" select="$taille"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- pour dessiner les chiffres -->
    <!-- 数字を描画する　値があるセルだけ表示するテンプレート -->
    <xsl:template name="dessiner_chiffres">

        <!-- 線と数字の位置が一致するように設定-->
        <xsl:variable name="taille_cellule" select="40"/>
        
        <!-- 走査 -->
        <xsl:for-each select="row">
            <xsl:variable name="ligne" select="position()"/>
            
            <xsl:for-each select="cell">
                <xsl:variable name="colonne" select="position()"/>
                
                <!-- afficher le chiffre si @v existe -->
                <xsl:if test="@v">
                    <!-- ローカル変数の設定 -->
                    <!-- 座標計算 ｘ座標 セル左端を計算して、+ taille/2でセル中央-->
                    <xsl:variable name="x" select="($colonne - 1) * $taille_cellule + $taille_cellule div 2"/>
                    <!-- 座標計算 y座標 セル上部を計算して、+ taille/2でセル中央. taille/2はセルの幾何学的中心　「+ 6」はフォントサイズ 20px に対する経験的補正値-->
                    <xsl:variable name="y" select="($ligne - 1) * $taille_cellule + $taille_cellule div 2 + 6"/>
                    
                    <!-- 固定セルと入力セルの見分け -->

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
                        <!-- 属性 v の値を取り出して、テキストとして出力。最終的に SVG に表示される「数字そのもの」 -->
                        <xsl:value-of select="@v"/>
                    </text>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
