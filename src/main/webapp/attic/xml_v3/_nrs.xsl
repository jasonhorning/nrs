<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:nrs="urn:nena:xml:namespace:nrs"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:output method="xml"
                doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

    <xsl:variable name="ALPHA">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
    <xsl:variable name="alpha">abcdefghijklmnopqrstuvwxyz</xsl:variable>

    <xsl:template match="/">
        <html>
            <xsl:apply-templates select="nrs:registry" />
        </html>
    </xsl:template>

    <xsl:template match="/nrs:registry">
        <head>
            <link rel="stylesheet" href="nrs.css" type="text/css"/>
            <title><xsl:value-of select="nrs:details/nrs:title" /></title>
        </head>
        <body>
            <xsl:apply-templates select="nrs:details/nrs:title" />
            <xsl:if
                    test="nrs:details/nrs:created|nrs:details/nrs:last-updated|nrs:details/nrs:parent-registry|nrs:details/nrs:management-policy|nrs:details/nrs:description|nrs:details/nrs:notes|nrs:entries">
                <dl>
                    <xsl:apply-templates select="nrs:details/nrs:created" />
                    <xsl:apply-templates select="nrs:details/nrs:last-updated" />
                    <xsl:apply-templates select="nrs:details/nrs:parent-registry" />
                    <xsl:apply-templates select="nrs:details/nrs:management-policy" />
                    <xsl:apply-templates select="nrs:details/nrs:description" />
                    <xsl:apply-templates select="nrs:details/nrs:notes" />
                </dl>
            </xsl:if>

            <xsl:apply-templates select="nrs:entries" />
        </body>
    </xsl:template>

    <xsl:template match="/nrs:registry/nrs:entries">
        <h2 class="entries">Entries</h2>
        <table class="sortable" id="table-{@id}">
            <thead>
                <xsl:call-template name="nrs:entry_header"/>
            </thead>
            <xsl:choose>
                <xsl:when test="./*">
                    <tbody>
                        <xsl:apply-templates select="./*"/>
                    </tbody>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="nrs:registryempty"/>
                </xsl:otherwise>
            </xsl:choose>
        </table>
    </xsl:template>

    <xsl:template name="nrs:entry_header">
        <xsl:for-each select="$registry-columns">
            <th><xsl:value-of select="@name"/></th>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="/nrs:registry/nrs:entries/*">
        <xsl:variable name="entry" select="."/>
        <tr>
            <xsl:for-each select="$registry-columns">
                <xsl:variable name="elemName" select="@name"/>
                <td><xsl:apply-templates select="$entry/*[name() = $elemName]"/></td>
            </xsl:for-each>
        </tr>
    </xsl:template>

    <xsl:template name="nrs:registryempty">
        <tr>
            <td colspan="{count($registry-columns)}">
                <i>Registry is empty.</i>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="/nrs:registry/nrs:details/nrs:title">
        <h1><xsl:apply-templates select="child::node()" /></h1>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:details/nrs:created">
        <dt>Created</dt><dd><tt><xsl:value-of select="." /></tt></dd>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:details/nrs:last-updated">
        <dt>Last Updated</dt><dd><tt><xsl:value-of select="." /></tt></dd>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:details/nrs:parent-registry">
        <dt>Parent Registry</dt><dd><tt><a href="{text()}.xml"><xsl:value-of select="text()"/></a></tt></dd>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:details/nrs:management-policy">
        <dt>Registration Procedures</dt><dd><tt><xsl:apply-templates/></tt></dd>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:details/nrs:description">
        <dt>Description</dt><dd><tt><xsl:apply-templates/></tt></dd>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:details/nrs:notes">
        <dt>Note</dt><dd><tt><xsl:apply-templates/></tt></dd>
    </xsl:template>

</xsl:stylesheet>
