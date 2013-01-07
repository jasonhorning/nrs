function registryToNrsXml(reg) {
    var xw = new XMLWriter( 'UTF-8', '1.0' );
    xw.formatting = 'indented'; //add indentation and newlines
    xw.indentChar = ' '; //indent with spaces
    xw.indentation = 4;  //add 2 spaces per level

    xw.writeStylesheet('text/xsl', reg.details.Token + '.xsl');

    xw.writeStartDocument( );
        xw.writeStartElement( 'registry');
            xw.writeAttributeString( 'xmlns', 'urn:nena:xml:namespace:nrs' );
            xw.writeAttributeString( 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance' );
            xw.writeAttributeString( 'xsi:schemaLocation', 'urn:nena:xml:namespace:nrs _nrs.xsd urn:nena:xml:namespace:nrs.' + reg.details.Token + ' ' + reg.details.Token + '.xsd' );

            if (reg.options) {
                xw.writeStartElement( 'options');
                    if (reg.options.isSystemRegistry) {
                        xw.writeElementString('isSystemRegistry', 'true');
                    }
                    xw.writeEndElement();
                xw.writeEndElement();
            }

            xw.writeStartElement( 'details');
                xw.writeElementString('token', reg.details['Token'].encodeXML());
                xw.writeElementString('title', reg.details['Title'].encodeXML());
                xw.writeElementString('created', encodeDate(reg.details['Created']).encodeXML());
                xw.writeElementString('last-updated', encodeDate(reg.details['Last Updated']).encodeXML());
                xw.writeElementString('parent-registry', reg.details['Parent Registry'].encodeXML());
                xw.writeElementString('management-policy', reg.details['Management Policy'].encodeXML());
                xw.writeElementString('description', reg.details['Description'].encodeXML());
                xw.writeElementString('notes', reg.details['Notes'].encodeXML());
            xw.writeEndElement();

            xw.writeStartElement( 'entries');
                for (var e=0; reg.entries && e<reg.entries.length; e++) {
                    xw.writeStartElement( 'entry');
                        xw.writeAttributeString( 'xmlns', 'urn:nena:xml:namespace:nrs.' + reg.details.Token );

                        for (var f=0; reg.fields && f<reg.fields.length; f++) {
                            var name = reg.fields[f].Name;
                            var value = reg.entries[e][reg.fields[f].Name];
                            value = encodeXML(reg.fields[f].Type, value); //reg.fields[f].Type == 'Date' ? encodeDate(value) : value.encodeXML();

                            xw.writeElementString(name, value);
                        }

                    xw.writeEndElement();
                }
            xw.writeEndElement();

        xw.writeEndElement();
    xw.writeEndDocument();

    var strXsd = xw.flush();
    xw.close();
    return strXsd;
}

function encodeXML(nrsType, value) {
    switch (nrsType){
        case "Date": return encodeDate(value);
        default: return ("" + value).encodeXML();
    }
}

function registryToNrsXsd(reg) {
    var xw = new XMLWriter( 'UTF-8', '1.0' );
    xw.formatting = 'indented'; //add indentation and newlines
    xw.indentChar = ' '; //indent with spaces
    xw.indentation = 4;  //add 2 spaces per level

    xw.writeStartDocument( );
        xw.writeStartElement( 'schema', 'xs');
            xw.writeAttributeString( 'xmlns:xs', 'http://www.w3.org/2001/XMLSchema' );
            xw.writeAttributeString( 'xmlns:tns', 'urn:nena:xml:namespace:nrs.' + reg.details.Token );
            xw.writeAttributeString( 'targetNamespace', 'urn:nena:xml:namespace:nrs.' + reg.details.Token );
            xw.writeAttributeString( 'elementFormDefault', 'qualified' );
            xw.writeAttributeString( 'attributeFormDefault', 'unqualified' );

            // Include the registry Description as XSD documentation
            if (reg.details.Description) {
                xw.writeStartElement('annotation', 'xs');
                    xw.writeStartElement('documentation', 'xs');
                        xw.writeString("" + reg.details.Description.encodeXML());
                    xw.writeEndElement();
                xw.writeEndElement();
            }

            xw.writeStartElement( 'element', 'xs');
                xw.writeAttributeString( 'name', 'entry' );
                xw.writeAttributeString( 'type', 'tns:entryType' );
            xw.writeEndElement();

            xw.writeStartElement( 'complexType', 'xs');
                xw.writeAttributeString( 'name', 'entryType' );

                xw.writeStartElement( 'sequence', 'xs');
                for (var i=0; reg.fields && i<reg.fields.length; i++) {
                    xw.writeStartElement( 'element', 'xs');
                        xw.writeAttributeString( 'name', reg.fields[i].Name);
                        xw.writeAttributeString( 'type', schemaTypeFromRegistryFieldType(reg.fields[i].Type));
                        xw.writeAttributeString( 'minOccurs', "1");
                        xw.writeAttributeString( 'maxOccurs', "1");
                    xw.writeEndElement();
                }
                xw.writeEndElement();
            xw.writeEndElement();

        xw.writeEndElement();
    xw.writeEndDocument();

    var strXsd = xw.flush();
    xw.close();
    return strXsd;
}

function registryToNrsXsl(reg) {
    var xw = new XMLWriter( 'UTF-8', '1.0' );
    xw.formatting = 'indented'; //add indentation and newlines
    xw.indentChar = ' '; //indent with spaces
    xw.indentation = 4;  //add 2 spaces per level

    xw.writeStartDocument( );
        xw.writeStartElement( 'stylesheet', 'xsl');
            xw.writeAttributeString( 'xmlns', 'http://www.w3.org/1999/xhtml' );
            xw.writeAttributeString( 'xmlns:xs', 'http://www.w3.org/2001/XMLSchema' );
            xw.writeAttributeString( 'xmlns:xsl', 'http://www.w3.org/1999/XSL/Transform" version="1.0' );

            xw.writeStartElement( 'import', 'xsl');
                xw.writeAttributeString( 'href', '_nrs.xsl' );
            xw.writeEndElement();

            xw.writeStartElement( 'param', 'xsl');
                xw.writeAttributeString( 'name', 'registry-columns' );
                xw.writeAttributeString( 'select', "document('./" + reg.details.Token + ".xsd')/xs:schema/xs:complexType[@name='entryType']/xs:sequence/xs:element" );
            xw.writeEndElement();

        xw.writeEndElement();
    xw.writeEndDocument();

    var strXsd = xw.flush();
    xw.close();
    return strXsd;
}


function schemaTypeFromRegistryFieldType (reistryFieldType) {
    switch (reistryFieldType) {
        //TODO: add xs:date?
        case "token": return "xs:token";
        case "integer": return "xs:integer";
        case "url": return "xs:anyURI";
        default: return "xs:string";
    }
}

/* takes a string in mm/dd/yyyy format and returns yyyy-mm-dd */
function encodeDate (str) {
    var parts=str.split('/');
    return parts[2] + "-" + parts[0] + "-" + parts[1];
}



function _attic_saveRegistryAndXsd() {
    var newReg = createRegistryFromScreen();
    var registryJson = JSON.stringify(newReg, null, "  ");
    var registryXsd = _attic_registryToXsd(newReg);

    var files = {
         filename0:  '/registry/' + newReg.details.Token + ".json"
        ,body0:      registryJson
        ,filename1:  '/registry/' + newReg.details.Token + ".xsd"
        ,body1:      registryXsd
    };

    xhrPost(ctxPath + '/data/multiplefiles',
            files,
            function onSuccess(loaded_registry) {
                var registry = loaded_registry;
                initScreenWithRegistry(registry);
                console.log(["re-loaded registry after save", registry]);
            },
            function onError (err) {
                console.log(["error while saving registry", err])
            }
    );
}

function _attic_registryToXsd(reg) {
    var xw = new XMLWriter( 'UTF-8', '1.0' );
    xw.formatting = 'indented'; //add indentation and newlines
    xw.indentChar = ' '; //indent with spaces
    xw.indentation = 2;  //add 2 spaces per level

    xw.writeStartDocument( );
        xw.writeStartElement( 'schema', 'xs');
            xw.writeAttributeString( 'xmlns:xs', 'http://www.w3.org/2001/XMLSchema' );

            // Include the registry Description as XSD documentation
            if (reg.details.Description) {
                xw.writeStartElement('annotation', 'xs');
                    xw.writeStartElement('documentation', 'xs');
                        xw.writeString("" + reg.details.Description.encodeXML());
                    xw.writeEndElement();
                xw.writeEndElement();
            }

            if (reg.fields.length > 0) {
                // For now we assume the first field in the registry defines the schema enumeration
                var schemaField = reg.fields[0];

                xw.writeStartElement('simpleType', 'xs');
                    xw.writeAttributeString( 'name', (reg.details.Token + schemaField["Name"] + 'Type').encodeXML());

                    xw.writeStartElement('restriction', 'xs');
                        var baseType = schemaTypeFromRegistryFieldType(schemaField["Type"]);
                        xw.writeAttributeString( 'base', baseType );

                        //each registry entry produces an enumeration entry
                        for (var i=0; reg.entries && i<reg.entries.length; i++) {
                            var entry = reg.entries[i];
                            xw.writeStartElement('enumeration', 'xs' );
                                xw.writeAttributeString( 'value', (entry[schemaField["Name"]]).encodeXML() );
                                var refURL = entry["Reference"] ? registryEntriesGrid.resolveReference(entry["Reference"]) : null;
                                if (entry["Description"] || refURL) {
                                    xw.writeStartElement('annotation', 'xs');
                                        if (entry["Description"]) {
                                            xw.writeStartElement('documentation', 'xs');
                                                xw.writeString(entry["Description"].encodeXML());
                                            xw.writeEndElement();
                                        }
                                        if (refURL) {
                                            xw.writeStartElement('documentation', 'xs');
                                                xw.writeAttributeString( 'source', refURL.encodeXML() );
                                            xw.writeEndElement();
                                        }
                                    xw.writeEndElement();
                                }
                            xw.writeEndElement();
                        }

                    xw.writeEndElement();
                xw.writeEndElement();
            }

        xw.writeEndElement();
    xw.writeEndDocument();

    var strXsd = xw.flush();
    xw.close();
    return strXsd;
}
