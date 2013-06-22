<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:nrs="urn:nena:xml:namespace:nrs"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:ref="urn:nena:xml:namespace:nrs._references"
        version="1.0">

    <xsl:param name="nrs-references" select="document('./_references.xml')/nrs:registry/nrs:entries/*" />

    <xsl:output method="xml"
                doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

    <xsl:template match="/">
        <html>
            <xsl:apply-templates select="nrs:registry" />
        </html>
    </xsl:template>

    <xsl:template match="/nrs:registry">
        <head>
            <link rel="stylesheet" href="resources/nrs-registry.css" type="text/css"/>
            <title><xsl:value-of select="nrs:details/nrs:title" /></title>
        </head>
        <body>
            <xsl:apply-templates select="nrs:details/nrs:title" />
            <xsl:if
                    test="nrs:details/nrs:created|nrs:details/nrs:last-updated|nrs:details/nrs:parent-registry|nrs:details/nrs:management-policy|nrs:details/nrs:description|nrs:details/nrs:notes|nrs:entries">

                    <xsl:apply-templates select="nrs:details/nrs:created" />
                    <xsl:apply-templates select="nrs:details/nrs:last-updated" />
                    <xsl:apply-templates select="nrs:details/nrs:parent-registry" />
                    <xsl:apply-templates select="nrs:details/nrs:management-policy" />
                    <xsl:apply-templates select="nrs:details/nrs:description" />
                    <xsl:apply-templates select="nrs:details/nrs:notes" />
            </xsl:if>

            <xsl:apply-templates select="nrs:entries" />

            <xsl:call-template name="nrs:registryfooter"/>
        </body>
    </xsl:template>

    <xsl:template match="/nrs:registry/nrs:entries">
        <h2 class="entries">Entries</h2>
        <table class="gridstyle" id="table-{@id}">
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
            <xsl:if test='not(@name="Publish" and ancestor::*[@targetNamespace="urn:nena:xml:namespace:nrs._registries"])'>
                <th class="registry-column-{@name}"><xsl:value-of select="@name"/></th>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="/nrs:registry/nrs:entries/*">
        <xsl:variable name="entry" select="."/>
        <xsl:if test='not($entry/*[namespace-uri()="urn:nena:xml:namespace:nrs._registries" and local-name()="Publish" and text()="false"])'>
            <tr>
                <xsl:for-each select="$registry-columns">
                    <xsl:variable name="elemName" select="@name"/>
                    <xsl:if test='not($elemName="Publish" and ancestor::*[@targetNamespace="urn:nena:xml:namespace:nrs._registries"])'>
                        <td class="registry-column-{@name}">
                            <xsl:apply-templates select="$entry/*[name() = $elemName]"/>
                        </td>
                    </xsl:if>
                </xsl:for-each>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template match='*[namespace-uri()="urn:nena:xml:namespace:nrs._registries" and local-name()="Id"]'>
        <a href='{text()}.xml'><xsl:apply-templates/></a>
    </xsl:template>

    <xsl:template match='*[local-name()="Reference"]'>
        <xsl:variable name="reference-id" select="text()"/>
        <a href="{$nrs-references//ref:URL[../ref:Id/text() = $reference-id]}" target="_blank"><xsl:apply-templates/></a>
    </xsl:template>

    <xsl:template name="nrs:registryempty">
        <tr>
            <td colspan="{count($registry-columns)}">
                <i>Registry is empty.</i>
            </td>
        </tr>
    </xsl:template>

    <xsl:template name="nrs:registryfooter">
        <div class="registry-footer" >
            <xsl:if test="/nrs:registry/nrs:details/nrs:token != '_registries'">
                <p><a href="https://www.nena.org/?NRS_SubmitNewValue" target="_blank">Submit</a> an entry for consideration to the <span style="font-style: italic"><xsl:value-of select="/nrs:registry/nrs:details/nrs:title"/></span> registry.</p>
            </xsl:if>
            <p style="float: left;">©2012-13 National Emergency Number Association, all rights reserved.</p>
            <p style="float: right;">Please report errors, omissions, or concerns to the <a href="mailto:nrs-admin@nena.org">NRS Administrator</a></p>
            <div style="clear: both;"/>
        </div>
    </xsl:template>

    <xsl:template match="/nrs:registry/nrs:details/nrs:title">
        <!-- this header layout is derived from the NENA PSAP Registry by DDTI, Inc.  https://psaps.ddti.net/-->
        <div class="header">
            <div style="float:left;">
                <a href="http://www.nena.org" target="_blank">
                    <img src="resources/nena-logo-small.png" alt="National Emergency Number Association"/>
                </a>
            </div>

            <h2>National Emergency Number Association</h2>
            <h1>
                <xsl:choose>
                    <xsl:when test="../nrs:token != '_registries'"><a href="_registries.xml">NENA Registry System</a></xsl:when>
                    <xsl:otherwise>NENA Registry System</xsl:otherwise>
                </xsl:choose>
            </h1>
        </div>

        <h1><xsl:value-of select="text()"/></h1>
        <xsl:if test='not(//nrs:entries/*[namespace-uri()="urn:nena:xml:namespace:nrs._registries"])'>
            <a href="{../nrs:token/text()}.xml?download">download xml</a> | <a href="{../nrs:token/text()}.xsd?download">download schema</a>
        </xsl:if>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:details/nrs:created">
        <h3>Created</h3><p class="registry-detail"><xsl:value-of select="." /></p>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:details/nrs:last-updated">
        <h3>Last Updated</h3><p class="registry-detail"><xsl:value-of select="." /></p>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:details/nrs:parent-registry">
        <xsl:choose>
            <xsl:when test="./text()">
                <h3>Parent Registry</h3><p class="registry-detail"><a href="{text()}.xml"><xsl:value-of select="text()"/></a></p>
            </xsl:when>
            <xsl:otherwise>
                <h3>Parent Registry</h3><p class="registry-detail">None</p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:details/nrs:management-policy">
        <h3>Management Policy</h3><p class="registry-detail"><xsl:apply-templates/></p>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:details/nrs:description">
        <h3>Description</h3><p class="registry-detail"><xsl:apply-templates/></p>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:details/nrs:notes">
        <h3>Note</h3><p class="registry-detail"><xsl:apply-templates/></p>
    </xsl:template>

</xsl:stylesheet>
