<xsl:stylesheet xmlns:efn="http://edirom.de/ns/local-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsl xs exist tei efn" version="2.0">
    <xsl:output encoding="UTF-8" indent="yes" exclude-result-prefixes="xsl xs exist tei efn"/>
    <xsl:variable name="textEdition">Text Edition</xsl:variable>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="tei:p tei:seg tei:sp tei:stage"/>
    <xsl:template match="/">
        <!-- Main box for the header and the scrollable content of the text edition -->
        <xsl:variable name="textEditionText" select=".//tei:text/tei:body"/>
        <xsl:variable name="textEditionElems" select="$textEditionText//tei:p | $textEditionText//tei:l | $textEditionText//tei:head | $textEditionText//tei:speaker | $textEditionText//tei:sp | $textEditionText//tei:stage[not(preceding-sibling::*[1][self::tei:speaker]) and not(ancestor::tei:head)] | $textEditionText//tei:milestone"/>
        <xsl:variable name="textEditionFrontElems" select="$textEditionText/../tei:front//tei:titlePart"/>
        <div class="textEditionBox">
            <!-- Scrollable content -->
            <div id="scrollCont" class="scrollCont">
                <table class="librettoEdition {/tei:TEI/@xml:id}" id="librettoEdition">
                    <tbody>
                        <!-- Ausgabe der Titelangaben etc. -->
                        <xsl:for-each select="$textEditionFrontElems">
                            <tr class="text1Column">
                                <td class="technicalColumnLeft"> </td>
                                <td class="text1Column">
                                    <xsl:apply-templates select="."/>

                                </td>
                                <td class="annotationColumn">
                                    <xsl:apply-templates select="efn:getNote(.)"/>
                                </td>
                            </tr>
                        </xsl:for-each>
                        <xsl:for-each select="$textEditionElems">
                            <tr class="text1Column">
                                <td class="technicalColumnLeft">
                                    <xsl:variable name="pos" select="position()"/>
                                    <xsl:variable name="elemBefore" select="$textEditionElems[$pos - 1]"/>
                                    <xsl:choose>
                                        <xsl:when test="($elemBefore/local-name() eq 'milestone') and $elemBefore[@unit = 'act']">
                                            <span class="musicalNumber">
                                                <xsl:apply-templates select="$elemBefore/@xml:id"/> Act <xsl:value-of select="$elemBefore/@n"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:when test="($elemBefore/local-name() eq 'milestone') and $elemBefore[@unit = 'scene']">
                                            <span class="musicalNumber">
                                                <xsl:apply-templates select="$elemBefore/@xml:id"/> Sc. <xsl:value-of select="$elemBefore/@n"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:when test="($elemBefore/local-name() eq 'milestone') and $elemBefore[@unit = 'number']">
                                            <span class="musicalNumber">
                                                <xsl:apply-templates select="$elemBefore/@xml:id"/>
                                                <xsl:value-of select="$elemBefore/@n"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:when test="($elemBefore/local-name() eq 'milestone') and $elemBefore[@unit = 'appendix']">
                                            <span class="musicalNumber">
                                                <xsl:apply-templates select="$elemBefore/@xml:id"/> Appendix
                                                    <xsl:value-of select="$elemBefore/@n"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:when test="($elemBefore/local-name() eq 'milestone') and $elemBefore[@unit = 'scene']">
                                            <span class="musicalNumber">
                                                <xsl:apply-templates select="$elemBefore/@xml:id"/> Sc. <xsl:value-of select="$elemBefore/@n"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:when test="local-name() eq 'p' and tei:lb">
                                            <xsl:for-each select=".//tei:lb">
                                                <span class="verseNumber" style="display:block;line-height:2em;">
                                                    <xsl:value-of select="./@n/number()"/>
                                                </span>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:when test="not(local-name() eq 'milestone') and ./@n">
                                            <span class="verseNumber">
                                                <xsl:value-of select="@n/number()"/>
                                            </span>
                                        </xsl:when>
                                    </xsl:choose>
                                </td>
                                <td class="text1Column">
                                    <xsl:apply-templates select="."/>
                                </td>
                                <td class="annotationColumn">
                                    <xsl:apply-templates select="efn:getNote(.)"/>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="tei:sp" priority="2">
        <span class="speaker">
            <!-- Process the speaker only in this mode -->
            <xsl:apply-templates select="tei:speaker" mode="speaker"/>

            <!-- Check if the next sibling is a stage with type 'delivery' and merge them -->
            <xsl:if test="tei:speaker/following-sibling::*[1][self::tei:stage]">
                <xsl:text> </xsl:text>
                <!-- This inserts a whitespace -->
                <xsl:element name="span">
                    <!-- Add the id from the original stage element -->
                    <xsl:attribute name="class">stage type_stageAfterSpeaker</xsl:attribute>
                    <xsl:attribute name="id" select="tei:speaker/following-sibling::tei:stage[1]/@xml:id"/>
                    <!-- Apply the text content from the stage -->
                    <xsl:value-of select="tei:speaker/following-sibling::tei:stage[1]/text()"/>
                </xsl:element>
            </xsl:if>
        </span>
    </xsl:template>

    <xsl:template match="tei:speaker" mode="speaker">
        <!-- The logic for handling the speaker output -->
        <span class="speaker">
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    <!-- Prevent double processing by limiting the general template for tei:speaker -->
    <xsl:template match="tei:speaker" priority="1"/>
    <xsl:template match="tei:lb" priority="1">
        <xsl:element name="br">
            <xsl:apply-templates select="@xml:id | node()"/>
        </xsl:element>
    </xsl:template>
      <xsl:template match="tei:*" priority="0.1">
        <xsl:element name="span">
            <xsl:call-template name="add.attribute.class"/>
            <xsl:apply-templates select="@* | node()[./local-name() != 'note']"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@target[parent::tei:ref]">
        <xsl:attribute name="onclick" select="concat('loadLink(&#34;', string(.), '&#34;, {width:820})')"/>
    </xsl:template>
    <xsl:template match="tei:choice">
        <xsl:element name="span">
            <xsl:call-template name="add.attribute.class"/>
            <xsl:value-of select="./tei:corr/text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:note">
        <span class="note {substring-before(substring-after(@rend, '/'), '.')}">
            <xsl:apply-templates select="@xml:id | node()"/>
        </span>
    </xsl:template>
    <xsl:template match="exist:match">
        <span class="searchResult">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="@xml:id">
        <xsl:attribute name="id" select="."/>
    </xsl:template>
    <xsl:template match="@*"/>
    <xsl:template match="tei:seg" priority="1.0">
        <xsl:element name="span">
            <xsl:call-template name="add.attribute.class"/>
            <xsl:attribute name="n" select="@n"/>
            <xsl:apply-templates select="@* | node()" xml:space="preserve"/>
        </xsl:element>
    </xsl:template>
    <xsl:template name="add.attribute.class">
        <xsl:variable name="classNames" select="efn:getClassName(@type | @met | @synch | @part | @rend | @source | @reason)"/>
        <xsl:variable name="parentClassNames" select="efn:getParentClassName(ancestor::tei:cit | ancestor::tei:lg | ancestor::tei:quote | ancestor::tei:ref)"/>
        <xsl:variable name="lgPos" select="efn:getLgPos(.)"/>
        <xsl:variable name="PPos" select="efn:getPPos(.)"/>
        <xsl:variable name="ciPos" select="efn:getCastItemPos(.)"/>
        <xsl:attribute name="class" select="                 for $i in (local-name(), $classNames, $parentClassNames, $lgPos, $PPos, $ciPos)[. != '']                 return                     $i" separator=" "/>
    </xsl:template>
    <xsl:function name="efn:getClassName">
        <xsl:param name="attrs"/>
        <xsl:value-of>
            <xsl:for-each select="$attrs">
                <xsl:variable name="name" select="local-name()"/>
                <xsl:for-each select="tokenize(., '\s+')">
                    <xsl:value-of select="concat($name, '_', .)"/>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:value-of>
    </xsl:function>
    <xsl:function name="efn:getParentClassName">
        <xsl:param name="parents"/>
        <xsl:value-of>
            <xsl:for-each select="$parents">
                <xsl:variable name="name" select="local-name()"/>
                <xsl:value-of select="concat($name, ' ')"/>
                <xsl:value-of>
                    <xsl:for-each select="@type | @met | @synch | @part | @rend">
                        <xsl:variable name="aname" select="local-name()"/>
                        <xsl:for-each select="tokenize(., '\s+')">
                            <xsl:value-of select="concat($aname, '_', .)"/>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:value-of>
            </xsl:for-each>
        </xsl:value-of>
    </xsl:function>

    <xsl:function name="efn:getNote">
        <!-- Dieser Parameter hat keine Funktion… -->
        <xsl:param name="preceding"/>
        <!-- entweder . und darin note oder . und note als sibling. -->
        <!--<xsl:variable name="following" select="$preceding/following::*[1]"/>-->
        <xsl:variable name="following" select="$preceding/following-sibling::*[1]"/>
        <xsl:variable name="children" select="$preceding/child::tei:note"/>
        <xsl:choose>
            <xsl:when test="$following/local-name() = 'note'">
                <xsl:sequence select="$following"/>
                <xsl:sequence select="efn:getNote($following)"/>
            </xsl:when>
            <xsl:when test="$children">
                <xsl:for-each select="$children">
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="efn:getLgPos">
        <xsl:param name="elem"/>
        <xsl:if test="local-name($elem) eq 'l' and $elem/ancestor::tei:lg">
            <xsl:choose>
                <xsl:when test="($elem/ancestor::tei:lg//tei:l)[1] eq $elem">
                    <xsl:text>l_first</xsl:text>
                </xsl:when>
                <xsl:when test="($elem/ancestor::tei:lg//tei:l)[last()] eq $elem">
                    <xsl:text>l_last</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    <xsl:function name="efn:getCastItemPos">
        <xsl:param name="elem"/>
        <xsl:if test="local-name($elem) eq 'castItem' and $elem/ancestor::tei:castGroup">
            <xsl:choose>
                <xsl:when test="($elem/ancestor::tei:castList//tei:castGroup)[1] eq $elem">
                    <xsl:text>castItem_first</xsl:text>
                </xsl:when>
                <xsl:when test="($elem/ancestor::tei:castList//tei:castGroup)[last()] eq $elem">
                    <xsl:text>castItem_last</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    <xsl:function name="efn:getPPos">
        <xsl:param name="elem"/>
        <xsl:if test="local-name($elem) = 'p'">
            <xsl:choose>
                <xsl:when test="$elem/preceding-sibling::tei:stage[contains(@rend, 'with-following-p')]">
                    <xsl:text>p_no-margin-top</xsl:text>
                </xsl:when>
                <xsl:when test="local-name(($elem/preceding-sibling::*)[last()]) != 'p'">
                    <xsl:text>p_first</xsl:text>
                </xsl:when>
                <xsl:when test="($elem/ancestor::tei:sp//tei:p)[last()] eq $elem">
                    <xsl:text>p_last</xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
</xsl:stylesheet>