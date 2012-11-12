<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:import href="../../../_support/nrs-registry.xsl" />
    <xsl:param name="base" select="'../../..'"/>
    <xsl:param name="registry-columns" select="document('./registry.xsd')/xs:schema/xs:complexType[@name='recordType']/xs:sequence/xs:element"/>

</xsl:stylesheet>
