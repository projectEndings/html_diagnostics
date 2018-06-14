<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    version="2.0">
    
    <xsl:include href="global.xsl"/>
    
    
    <xsl:variable name="ids" select="$idDocs//ul"/>
    <xsl:variable name="internalRefs" select="$internalRefsDocs//ul"/>
    <xsl:key name="id-to-doc" match="li" use="concat('#',.)"/>
    
    <xsl:template match="/">
        <xsl:message>Processing <xsl:value-of select="count($internalRefsDocs)"/> files...</xsl:message>
        <xsl:result-document href="{$outputDir}/internalErrors.xml">
            <div>
                <h3>Hash Errors</h3>
                <xsl:for-each select="$internalRefs">
                    <xsl:variable name="thisDocId" select="@data-doc"/>
                    <xsl:message>Processing <xsl:value-of select="$thisDocId"/></xsl:message>
                    <xsl:variable name="errors" as="xs:string*">
                        <xsl:for-each select="li">
                            <xsl:variable name="thisRef" select="."/>
                            <xsl:choose>
                                <xsl:when test="$ids[@data-doc=$thisDocId]//key('id-to-doc',$thisRef)"/>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:if test="not(empty($errors))">
                        <ul data-doc="{$thisDocId}">
                            <li><xsl:value-of select="$thisDocId"/>
                                <ul>
                                    <xsl:for-each select="$errors">
                                        <li><xsl:value-of select="."/></li>
                                    </xsl:for-each>
                                </ul>
                            </li>
                        </ul>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>