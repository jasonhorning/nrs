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
            <link rel="stylesheet" href="{$base}/_support/nrs-registry.css" type="text/css"/>
            <!--
            IE insists on having <script ...></script>, not <script .../> when it
            displays XML converted on the fly using XSLT.
            -->
            <!--
            <script type="text/javascript" src="../_support/jquery.js"></script>
            <script type="text/javascript" src="../_support/sort.js"></script>
            -->
            <title><xsl:value-of select="nrs:title" /></title>
        </head>
        <body>
            <xsl:apply-templates select="nrs:title" />
            <xsl:if
                    test="nrs:created|nrs:updated|nrs:registry|nrs:references|nrs:description|nrs:note|nrs:record">
                <dl>
                    <xsl:apply-templates select="nrs:created" />
                    <xsl:apply-templates select="nrs:updated" />
                    <xsl:apply-templates select="nrs:registry" />
                    <xsl:apply-templates select="nrs:references" />
                    <xsl:apply-templates select="nrs:registration_rule" />
                    <xsl:apply-templates select="nrs:description" />
                    <xsl:apply-templates select="nrs:note" />
                </dl>
            </xsl:if>

            <xsl:apply-templates select="nrs:records" />

            <xsl:apply-templates select="nrs:people"/>
        </body>
    </xsl:template>

    <xsl:template match="/nrs:registry/nrs:records">
            <h2 class="records">Records</h2>
            <table class="sortable" id="table-{@id}">
                <thead>
                    <xsl:call-template name="nrs:record_header"/>
                </thead>
                <xsl:choose>
                    <xsl:when test="nrs:record">
                        <tbody>
                            <xsl:apply-templates select="nrs:record"/>
                        </tbody>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="nrs:registryempty"/>
                    </xsl:otherwise>
                </xsl:choose>
            </table>
    </xsl:template>

    <xsl:template name="nrs:record_header">
		<xsl:for-each select="$registry-columns">
            <th><xsl:value-of select="@name"/></th>
		</xsl:for-each>
    </xsl:template>

    <xsl:template match="nrs:record">
        <xsl:variable name="record" select="."/>
        <tr>
            <xsl:for-each select="$registry-columns">
                <xsl:variable name="elemName" select="@name"/>
                <td><xsl:apply-templates select="$record/*[name() = $elemName]"/></td>
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

    <xsl:template match="nrs:records//nrs:registry">
        <xsl:call-template name="nrs:registryRef"/>
    </xsl:template>



    <xsl:template match="/nrs:registry/nrs:people">
        <xsl:if test="nrs:person">
            <h2 class="people">People</h2>
            <table class="sortable">
                <thead>
                    <tr>
                        <th>Name</th>
                        <xsl:if test="nrs:person/nrs:org">
                            <th>Organization</th>
                        </xsl:if>
                        <th>Contact URI</th>
                        <th>Last Updated</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="nrs:person"/>
                </tbody>
            </table>
        </xsl:if>
    </xsl:template>

    <xsl:template match="/nrs:registry/nrs:people/nrs:person">
        <tr>
            <td><span id="person-{./@id}"><xsl:value-of select="nrs:name"/></span></td>
            <xsl:if test="../nrs:person/nrs:org">
                <td><xsl:value-of select="nrs:org"/></td>
            </xsl:if>
            <td>
                <xsl:for-each select="nrs:uri">
                    <a href="{.}"><xsl:value-of select="."/></a>
                    <xsl:if test="position() != last()"><br/></xsl:if>
                </xsl:for-each>
            </td>
            <td><xsl:value-of select="nrs:updated"/></td>
        </tr>
    </xsl:template>

    <xsl:template match="/nrs:registry/nrs:title">
        <h1><xsl:apply-templates select="child::node()" /></h1>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:created">
        <dt>Created</dt><dd><tt><xsl:value-of select="." /></tt></dd>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:updated">
        <dt>Last Updated</dt><dd><tt><xsl:value-of select="." /></tt></dd>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:registry">
        <dt>Registry</dt><dd><tt><xsl:call-template name="nrs:registryRef"/></tt></dd>
    </xsl:template>

    <xsl:template name="nrs:registryRef">
        <a href="{@ref}/registry.xml">
            <xsl:choose>
                <xsl:when test="child::text()"><xsl:value-of select="."/></xsl:when>
                <xsl:otherwise><xsl:value-of select="@ref"/></xsl:otherwise>
            </xsl:choose>
        </a>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:references">
        <xsl:call-template name="nrs:references"/>
    </xsl:template>

    <xsl:template name="nrs:references">
        <xsl:if test="nrs:xref">
            <dt>References</dt>
            <dd><tt><xsl:apply-templates select="nrs:xref"/></tt></dd>
        </xsl:if>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:registration_rule">
        <dt>Registration Procedures</dt><dd><tt><xsl:apply-templates/></tt></dd>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:description">
        <dt>Description</dt><dd><tt><xsl:apply-templates/></tt></dd>
    </xsl:template>

    <xsl:template match="nrs:registry/nrs:note">
        <dt>Note</dt><dd><tt><xsl:apply-templates/></tt></dd>
    </xsl:template>

    <xsl:template match="nrs:xref">
        <xsl:text>[</xsl:text>
        <xsl:choose>
            <xsl:when test="@type = 'rfc'">
                <a href="http://www.ietf.org/rfc/{@data}.txt"><xsl:text>IETF </xsl:text>
                    <xsl:value-of select="translate(@data,$alpha,$ALPHA)"/>
                </a>
            </xsl:when>

            <xsl:when test="@type = 'nena'">
                <a href="http://www.nena.org/?page={@data}"><xsl:text>NENA </xsl:text><xsl:value-of select="."/></a>
            </xsl:when>

            <xsl:when test="@type = 'uri'">
                <a href="{@data}">
                    <xsl:choose>
                        <xsl:when test="child::text()"><xsl:value-of select="."/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="@data"/></xsl:otherwise>
                    </xsl:choose>
                </a>
            </xsl:when>
            <xsl:when test="@type = 'person'">
                <xsl:variable name="data" select="@data"/>
                <a href="#person-{@data}"><xsl:value-of select="//nrs:person[@id=$data]/nrs:name"/></a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>]</xsl:text><br />
        <xsl:if test="@lastupdated">
            (<xsl:value-of select="@lastupdated"/>)
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
