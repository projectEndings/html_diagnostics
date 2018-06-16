<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    xmlns:xh="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    version="2.0">
    <xsl:include href="global.xsl"/>
    
    <xsl:output method="xml"/>
    
    <!--A parameter-->
    <xsl:param name="byDoc" select="'true'"/>
     
    <xsl:variable name="externalErrorDocs" select="distinct-values($errorsDoc//ul/li/ul/li/text())"/>
    <xsl:variable name="internalErrorDocs" select="distinct-values($internalErrorsDoc//ul[not(ancestor::ul)]/li/text())"/>
    
    <xsl:variable name="internalOnly" select="hcmc:compareSeq($internalErrorDocs,$externalErrorDocs)"/>
    
    <xsl:key name="doc-to-externalError" match="div/ul/li" use="ul/li/normalize-space(text())"/>
    <xsl:key name="doc-to-internalError" match="div/ul/li" use="normalize-space(text())"/>
    <xsl:variable name="externalErrorCount" select="count($errorsDoc//li)"/>
    <xsl:variable name="internalErrorCount" select="count($internalErrorsDoc//li)"/>
    <xsl:variable name="totalErrorCount" select="$internalErrorCount + $externalErrorCount"/>
    
    
    
    <xsl:template match="/">
        
        <html>
            <head>
                <title>HTML Diagnostics</title>
                <link rel="stylesheet" type="text/css" href="https://cdn.rawgit.com/projectEndings/diagnostics/master/xsl/style.css"/>
            </head>
            <body>
                <div>
                    <h1>HTML Diagnostics for <xsl:value-of select="$projectDirectory"/></h1>
                    <div id="stats">
                        <h2>Statistics</h2>
                        <table>
                            <tbody>
                                <tr>
                                    <td>Total documents analyzed:</td>
                                    <td><xsl:value-of select="count($refDocs)"/></td>
                                </tr>
                                <tr>
                                    <td>Documents in project:</td>
                                    <td><xsl:value-of select="count($systemFilesDoc//li)"/></td>
                                </tr>
                                <tr>
                                    <td>Total external references:</td>
                                    <td><xsl:value-of select="count($refDocs//li)"/></td>
                                </tr>
         
                                <tr>
                                    <td>Total unique external references:</td>
                                    <td><xsl:value-of select="count(distinct-values($refDocs//li))"/></td>
                                </tr>
                                <tr>
                                    <td>Total unique documents referenced:</td>
                                    <td><xsl:value-of select="count(distinct-values(for $n in distinct-values($refDocs//li) return hcmc:getBaseUri($n)))"/></td>
                                </tr>
                                <tr>
                                    <td>Total internal references</td>
                                    <td><xsl:value-of select="count($internalRefsDocs//li)"/></td>
                                </tr>
                                <tr>
                                    <td>Total errors</td>
                                    <td><xsl:value-of select="$totalErrorCount"/></td>
                                </tr>
                                <tr>
                                    <td>Total external errors</td>
                                    <td><xsl:value-of select="$externalErrorCount"/></td>
                                </tr>
                                <tr>
                                    <td>Total internal errors</td>
                                    <td><xsl:value-of select="$internalErrorCount"/></td>
                                </tr>
                                
                            </tbody>
                        </table>
                    </div>
                    <xsl:choose>
                        <xsl:when test="$totalErrorCount gt 0">
                            <xsl:choose>
                                <xsl:when test="$byDoc='true'">
                                    <xsl:for-each-group select="$errorsDoc//div/ul/li" group-by="ul/li">
                                        <xsl:variable name="thisDocName" select="current-grouping-key()"/>
                                        <xsl:variable name="currGroup" select="current-group()"/>
                                        <xsl:variable name="internalErrors" select="$internalErrorsDoc//key('doc-to-internalError',$thisDocName)"/>
                                        <xsl:message>Processing <xsl:value-of select="$thisDocName"/>...</xsl:message> 
                                        <div>
                                            <h3><xsl:value-of select="hcmc:getRelativeUri(current-grouping-key())"/></h3>
                                            <div>
                                                <h4>External Errors</h4>
                                                <ul>
                                                    <xsl:for-each select="$currGroup">
                                                        <li><xsl:value-of select="hcmc:getRelativeUri(text())"/></li>
                                                    </xsl:for-each>
                                                </ul>
                                            </div>
                                            <xsl:if test="not(empty($internalErrors))">
                                                <div>
                                                    <h4>Internal Errors</h4>
                                                    <ul>
                                                        <xsl:for-each select="$internalErrors/ul/li">
                                                            <li><xsl:value-of select="text()"/></li>
                                                        </xsl:for-each>
                                                    </ul>
                                                    
                                                </div>
                                            </xsl:if>
                                        </div>
                                    </xsl:for-each-group>
                                    <!--Now we need to get all the documents that are not in the internal, but not the external-->
                                    <xsl:for-each select="$internalOnly">
                                        <xsl:variable name="thisInternalDoc" select="."/>
                                        <div>
                                            <h3><xsl:value-of select="hcmc:getRelativeUri($thisInternalDoc)"/></h3>
                                            <div>
                                                <h4>Internal Errors</h4>
                                                <ul>
                                                    <xsl:for-each select="$internalErrorsDoc//key('doc-to-internalError',$thisInternalDoc)/ul/li">
                                                        <li><xsl:value-of select="text()"/></li>
                                                    </xsl:for-each>
                                                </ul>
                                            </div>
                                        </div>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <div>
                                        <xsl:apply-templates select="$errorsDoc | $internalErrorsDoc" mode="output"/>
                                    </div>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message>No errors found!</xsl:message>
                            <div>
                                <p>None found!</p>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </body>
        </html>
    </xsl:template>
    
    
    
    <!--Templates-->
    <xsl:template match="ul/text() | li/text()" mode="output">
        <xsl:value-of select="hcmc:getRelativeUri(.)"/>
    </xsl:template>
    
    <xsl:template match="node()" priority="-1" mode="output">
        <xsl:copy>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>