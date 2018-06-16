<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs math"
    xmlns:xh="http://www.w3.org/1999/xhtml"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Started on:</xd:b> June 01, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> Joey Takeda</xd:p>
            <xd:p>This stylesheet, included in all of the other stylesheets, contains
            all of the global properties and parameters for the HTML diagnostics process.</xd:p>
        </xd:desc>
        <xd:param name="projectDirectory">The absolute directory of the project</xd:param>
        <xd:param name="suffix">The suffix pattern (by default it is *htm* as passed by ANT)</xd:param>
        <xd:param name="line.separator">The system's line separator</xd:param>
        <xd:param name="outputDir">The output directory where the results and temporary products go</xd:param>
        <xd:param name="exceptionsDoc">The document that lists exceptions</xd:param>
    </xd:doc>
   
   <!--******** PARAMETERS *******-->
    
    <xsl:param name="projectDirectory"/>
    <xsl:param name="suffix"/>
    <xsl:param name="line.separator"/>
    <xsl:param name="outputDir"/>
    <xsl:param name="exceptionsDoc" select="()"/>
    
    <!--******** VARIABLES *******-->
    
    <!-- DIRECTORIES -->
    <xd:doc scope="component">
        <xd:ref type="variable" name="tempDir"/>
        <xd:desc>Temporary directory for indexes.</xd:desc>
    </xd:doc>
    <xsl:variable name="tempDir" select="concat($outputDir,'/temp')"/>
    
    
    <!-- FILE COLLECTIONS-->
    
    <xd:doc scope="component">
        <xd:ref type="variable" name="refDocs"/>
        <xd:desc>The collection of all the reference index documents.</xd:desc>
    </xd:doc>
    <xsl:variable name="refDocs" select="collection(concat($tempDir,'?select=*_refs.xml&amp;recurse=yes'))"/>
    
    <xd:doc scope="component">
        <xd:ref type="variable" name="idDocs"/>
        <xd:desc>The collection of the id index documents.</xd:desc>
    </xd:doc>
    <xsl:variable name="idDocs" select="collection(concat($tempDir,'?select=*_ids.xml&amp;recurse=yes'))"/>
    
    <xd:doc scope="component">
        <xd:ref type="variable" name="internalRefDocs"/>
        <xd:desc>The collection of all of the internal reference index documents.</xd:desc>
    </xd:doc>
    <xsl:variable name="internalRefsDocs" select="collection(concat($tempDir,'?select=*_internalRefs.xml&amp;recurse=yes'))"/>
    
    <!-- FILES -->
    
    <!--System files-->
    <xd:doc scope="component">
        <xd:ref type="variable" name="systemFilesTxt"/>
        <xd:desc>The system_files list produced by ANT, which is then turned to XML.</xd:desc>
    </xd:doc>
    <xsl:variable name="systemFilesTxt" select="unparsed-text(concat($outputDir,'/system_files.txt'))"/>
    
    <xd:doc scope="component">
        <xd:ref type="variable" name="systemFilesPath"/>
        <xd:desc>The filepath for the system files XML.</xd:desc>
    </xd:doc>
    <xsl:variable name="systemFilesPath" select="concat($outputDir,'/system_files.xml')"/>
    
    <xd:doc scope="component">
        <xd:ref type="variable" name="systemFilesDoc"/>
        <xd:desc>The system files document.</xd:desc>
    </xd:doc>
    <xsl:variable name="systemFilesDoc" select="document($systemFilesPath)/xh:ul"/>

    
    <!--Error files-->
    <xd:doc scope="component">
        <xd:ref type="variable" name="errorsPath"/>
        <xd:desc>Path for the site errors document</xd:desc>
    </xd:doc>
    <xsl:variable name="errorsPath" select="concat($outputDir,'/errors.xml')"/>
    
    <xd:doc scope="component">
        <xd:ref type="variable" name="errorsDoc"/>
        <xd:desc>The errors document.</xd:desc>
    </xd:doc>
    <xsl:variable name="errorsDoc" select="document($errorsPath)"/>
    
    <xd:doc scope="component">
        <xd:ref type="variable" name="internalErrorsPath"/>
        <xd:desc>The path to the internal errors document.</xd:desc>
    </xd:doc>
    <xsl:variable name="internalErrorsPath" select="concat($outputDir,'/internalErrors.xml')"/>
    
    <xd:doc scope="component">
        <xd:ref type="variable" name="internalErrorsDoc"/>
        <xd:desc>The internal errors document.</xd:desc>
    </xd:doc>
    <xsl:variable name="internalErrorsDoc" select="document($internalErrorsPath)"/>
    
    <xd:doc scope="component">
        <xd:ref type="variable" name="exceptions"/>
        <xd:desc>A sequence of strings that comprise the exceptions for this project.</xd:desc>
    </xd:doc>
    <xsl:variable name="exceptions" as="xs:string*">
        <xsl:if test="unparsed-text-available($exceptionsDoc) and not(empty($exceptionsDoc))">
            <xsl:for-each select="hcmc:lineTokenize(unparsed-text($exceptionsDoc))[not(matches(.,'(^\s+$)|(^#+)'))]">
                <xsl:variable name="thisLine" select="normalize-space(.)"/>
                <xsl:if test="not($thisLine='')">
                    <xsl:value-of select="normalize-space(resolve-uri(concat($projectDirectory,'/',$thisLine)))"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:variable>
    

   
    
    <!--***** FUNCTIONS *****-->
    
    <xd:doc scope="component">
        <xd:ref name="hcmc:cleanUri" type="function"/>
        <xd:desc>A function to trim off any unnecessary bits of a pointer.</xd:desc>
        <xd:param name="string">An input string that may or may contain selectors and other
        bits.</xd:param>
    </xd:doc>
    <xsl:function name="hcmc:cleanUri" as="xs:string">
        <xsl:param name="string"/>
        <xsl:choose>
            <!--We don't want query selectors-->
            <xsl:when test="contains($string,'?')">
                <xsl:value-of select="substring-before($string,'?')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc>A simple utility function to tokenize a text file based off of lines.</xd:desc>
        <xd:param name="str">A string, usually produced by unparsed-text().</xd:param>
    </xd:doc>
    <xsl:function name="hcmc:lineTokenize" as="xs:string*">
        <xsl:param name="str"/>
        <xsl:sequence select="tokenize($str,$line.separator)"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>Utility function to get the URI before a hash.</xd:desc>
        <xd:param name="uri">A full URI.</xd:param>
    </xd:doc>
    <xsl:function name="hcmc:getBaseUri" as="xs:string">
        <xsl:param name="uri"/>
        <xsl:value-of select="if (contains($uri,'#')) then substring-before($uri,'#') else $uri"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Utility function to get the relative URI of a document. This is mostly
        used for error outputting messages and the results document.</xd:desc>
        <xd:param name="uri">A URI</xd:param>
    </xd:doc>
    <xsl:function name="hcmc:getRelativeUri" as="xs:string">
        <xsl:param name="uri"/>
        <xsl:value-of select="if (matches($uri,$projectDirectory)) then substring-after($uri,concat($projectDirectory,'/')) else $uri"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>A function to get the full path to where a document ought to be
        output. The xslt task in ANT doesn't flatten the results (and shouldn't), so this function
        helps find where the document is in the temporary file system.</xd:desc>
        <xd:param name="uri">A URI.</xd:param>
    </xd:doc>
    <xsl:function name="hcmc:getOutputUriNe" as="xs:string">
        <xsl:param name="uri"/>
        <xsl:variable name="fullUri" select="concat($tempDir,substring-after($uri,$projectDirectory))"/>
        <xsl:variable name="uriExt" select="tokenize($uri,'\.')[last()]"/>
        <xsl:value-of select="substring-before($fullUri,concat('.',$uriExt))"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function compares two sequences and returns all of $seq1
            that is not in $seq2. Thanks to Martin Holmes for the suggestion and pointer
            to this: http://www.xsltfunctions.com/xsl/functx_value-except.html</xd:desc>
        <xd:param name="seq1">A sequence of strings.</xd:param>
        <xd:param name="seq2">Another sequence of strings to be excluded from
        the first sequence.</xd:param>
    </xd:doc>
    <xsl:function name="hcmc:compareSeq" as="xs:string*">
        <xsl:param name="seq1"/>
        <xsl:param name="seq2"/>
        <xsl:sequence select="$seq1[not(.=$seq2)]"/>
    </xsl:function>
    
    
    
    
</xsl:stylesheet>