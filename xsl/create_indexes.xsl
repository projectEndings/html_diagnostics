<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xh="http://www.w3.org/1999/xhtml"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Started on:</xd:b> June 01, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> Joey Takeda</xd:p>
            <xd:p>This stylesheet, which is the first to be run in the sequence, creates the indexes
            for each document to check in the project. It includes global.xsl.</xd:p>
        </xd:desc>
        <xd:return>Three XHTML documents: one for external references, one for internal references,
            and one for all of the document's ids.</xd:return>
    </xd:doc>
    
    <!--Include global.xsl that contains all of the parameters-->
    <xsl:include href="global.xsl"/>
    
    <!--We output in XHTML-->
    <xsl:output method="xhtml"/>
    
    <!--All ids in this document-->
    <xsl:variable name="allIds" select="descendant-or-self::*/@id"/>
    
    <xsl:variable name="externalRegex" select="'^((mailto:)|(https?:)|(null)|(#)|(javascript))|(/$)'"/>
    <xsl:variable name="internalRegex" select="'^#.+'"/>
    
    <!--TODO: Expand linking elements...-->
    <!--All references-->
    
    
    <xsl:variable name="potentialLinks" select="//xh:*/(@href | @src | @cite | @targetid)/xs:string(.)" as="xs:string*"/>
    <xsl:variable name="potentialLinkTokens" select="for $n in $potentialLinks return tokenize($n,'\s+')" as="xs:string*"/>
    <xsl:variable name="links" select="for $n in distinct-values($potentialLinkTokens) return if (matches(normalize-space($n),$externalRegex)) then () else normalize-space($n)" as="xs:string*"/>
    
    <!--All internal references-->
    <xsl:variable name="internalRefs" select="for $n in $potentialLinkTokens return if (matches(normalize-space($n),$internalRegex)) then normalize-space($n) else ()" as="xs:string*"/>
    <xsl:variable name="thisDocUri" select="document-uri(.)"/>
    <xsl:variable name="thisOutUri" select="hcmc:getOutputUriNe($thisDocUri)"/>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="/">
        <xsl:result-document href="{$thisOutUri}_refs.xml">
            <ul id="references" data-doc="{$thisDocUri}">
                <xsl:for-each select="$links">
                    <xsl:variable name="uri" select="resolve-uri(hcmc:cleanUri(.),$thisDocUri)"/>
                    <li><xsl:value-of select="$uri"/></li>
                </xsl:for-each>
            </ul>
        </xsl:result-document>
        
        <xsl:result-document href="{$thisOutUri}_ids.xml">
            <ul id="ids" data-doc="{$thisDocUri}">
                <xsl:for-each select="$allIds">
                    <li><xsl:value-of select="."/></li>
                </xsl:for-each>
            </ul>
        </xsl:result-document>
        
        <xsl:result-document href="{$thisOutUri}_internalRefs.xml">
            <ul id="internalRefs" data-doc="{$thisDocUri}">
                <xsl:for-each select="$internalRefs">
                    <li><xsl:value-of select="."/></li>
                </xsl:for-each>
            </ul>
        </xsl:result-document>
        
        

    </xsl:template>
    
   
</xsl:stylesheet>