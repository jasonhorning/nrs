<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">

<%
    //root URL path
    String ctxPath = request.getContextPath();
%>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Edit Registry</title>

    <script type="text/javascript">
        var ctxPath = "<%=ctxPath%>";
        var imgPath = ctxPath + "/resources";
        var adminRegistryDefaultUrl = window.location.origin + ctxPath + "/admin/_registries";
        /\/admin\/?([^\/]*)/.exec(window.location.pathname);
        var registryToken = RegExp.$1;

        if ("" == registryToken) {
            console.log("registry token not found on the URL, redirecting to " + adminRegistryDefaultUrl);
            window.location = adminRegistryDefaultUrl;
        }
    </script>

    <!-- include javascript and css files for the EditableGrid library -->
    <script src="<%=ctxPath%>/js-lib/editablegrid-2.0.1/editablegrid-2.0.1.js"></script>
  	<link rel="stylesheet" href="<%=ctxPath%>/js-lib/editablegrid-2.0.1/editablegrid-2.0.1.css" type="text/css" media="screen">

    <!-- include javascript and css files for jQuery, needed for the datepicker and autocomplete extensions -->
    <script src="<%=ctxPath%>/js-lib/editablegrid-2.0.1/extensions/jquery/jquery-1.6.4.min.js" ></script>
    <script src="<%=ctxPath%>/js-lib/editablegrid-2.0.1/extensions/jquery/jquery-ui-1.8.16.custom.min.js" ></script>
    <link rel="stylesheet" href="<%=ctxPath%>/js-lib/editablegrid-2.0.1/extensions/jquery/jquery-ui-1.8.16.custom.css" type="text/css" media="screen">

    <!-- include javascript and css files for the autocomplete extension -->
    <script src="<%=ctxPath%>/js-lib/editablegrid-2.0.1/extensions/autocomplete/autocomplete.js" ></script>
    <link rel="stylesheet" href="<%=ctxPath%>/js-lib/editablegrid-2.0.1/extensions/autocomplete/autocomplete.css" type="text/css" media="screen">

    <!-- include javascript and css files for this app -->
    <link rel="stylesheet" type="text/css" href="<%=ctxPath%>/resources/nrs.css" media="screen"/>
    <script type="text/javascript" src="<%=ctxPath%>/js-lib/registryGrid.js"></script>
    <script type="text/javascript" src="<%=ctxPath%>/js-lib/registryXmlUtils.js"></script>
    <script type="text/javascript" src="<%=ctxPath%>/js-lib/json2.js"></script>
    <script type="text/javascript" src="<%=ctxPath%>/js-lib/XMLWriter-1.0.0.js"></script>
</head>



<body>

<div id="registryDetailsHeaderPanel">
        <span id="titleNRSHome"><a href="<%=ctxPath%>">NRS</a></span>
        /
        <span id="titleAdminHome"><a href="<%=ctxPath%>/admin">Admin</a></span>
        /
        <span id="titleRegistries"><a href="<%=ctxPath%>/admin/_registries">Registries</a></span>
        /
        <span id="titleRegistryTitle"></span>
</div>

<div id="registryDetailsPanel">
    <table class="registryDetails">
        <%--<tr><td>URL fragment</td><td><input id="registryToken" name="registryToken" type="text" onchange="titleRegistryToken.innerHTML = this.value" value="<%=escapeHtml4(registryToken)%>"></td></tr>--%>
        <tr><td>Title</td><td><input id="registryTitle" name="registryTitle" type="text" onchange="setTitle(this.value)"></td></tr>
        <tr><td>Created</td><td><input id="registryCreated" name="registryCreated" type="text" onfocus="$(this).datepicker().datepicker('show');"></td></tr>
        <tr><td>Last Updated</td><td><input id="registryLastUpdated" name="registryLastUpdated" type="text" onfocus="$(this).datepicker().datepicker('show');"></td></tr>
        <tr>
            <td>Parent Registry</td>
            <td>
                <select id="registryParentRegistry" name="registryParentRegistry"></select>
            </td>
        </tr>
        <tr>
            <td>Management Policy</td>
            <td>
                <select id="registryManagementPolicy" name="registryManagementPolicy"></select>
            </td>
        </tr>
        <tr><td>Description</td><td><textarea id="registryDescription" name="registryDescription" rows="5" cols="50"></textarea></td></tr>
        <tr><td>Notes</td><td><textarea id="registryNotes" name="registryNotes" rows="5" cols="50"></textarea></td></tr>
        <tr id="fieldsEditor">
            <td style="vertical-align: top;">Columns</td>
            <td>
                <div id="registryFieldsGridShowHideDiv">
                    <a id="registryFieldsGridEditA" href="javascript:editRegistryFields()" style="display: inline">[Edit]</a>
                    <a id="registryFieldsGridApplyA" href="javascript:applyRegistryFields()"  style="display: none">[Apply]</a>
                    <a id="registryFieldsGridCancelA" href="javascript:cancelRegistryFields()"  style="display: none">[Cancel]</a>
                </div>
                <div id="registryFieldsEditorDiv" style="display: none">
                    <div id="registryFieldsGridDiv"></div>
                </div>
            </td>
        </tr>
        <tr>
            <td style="vertical-align: top;">Entries</td>
            <td><div id="registryEntriesGridDiv"></div></td>
        </tr>
        <tr>
            <td style="vertical-align: top;"></td>
            <td><div id="save-revert-buttons">
                <input type="button" value="Save Changes" onclick="javascript:saveRegistry(); return false;">
                <input type="button" value="Revert Changes" onclick="javascript:initRegistry(); return false;">
            </div></td>
        </tr>
    </table>
</div>


<script type="text/javascript">
    var registry = null;

    var registryFieldsGrid = newRegistryGrid("RegistryFieldsGrid", {
        ctxPath: ctxPath,
        imgPath: imgPath,
        renderTo: "registryFieldsGridDiv",
        elementId: "registryFieldsGrid",
        className: "registrygrid"
    });

    registryFieldsGrid.setColumns([
        {"Name":"Name", "Type":"token", "suggestions":['Value', 'Description', 'References', 'Date']},
        {"Name":"Type", "Type":"nrsRegistryType"}
    ]);

    var registryEntriesGrid = newRegistryGrid("RegistryEntriesGrid", {
        ctxPath: ctxPath,
        imgPath: imgPath,
        renderTo: "registryEntriesGridDiv",
        elementId: "registryEntriesGrid",
        className: "registrygrid"
    });

    function editRegistryFields() {
        registryFieldsGridEditA.style.display = 'none';
        registryFieldsGridApplyA.style.display = 'inline';
        registryFieldsGridCancelA.style.display = 'inline';
        registryFieldsEditorDiv.style.display = 'block';
    }

    function applyRegistryFields() {
        registryFieldsGridEditA.style.display = 'inline';
        registryFieldsGridApplyA.style.display = 'none';
        registryFieldsGridCancelA.style.display = 'none';
        registryFieldsEditorDiv.style.display = 'none';
        remungRegistryEntriesGrid();
    }

    function cancelRegistryFields() {
        registryFieldsGridEditA.style.display = 'inline';
        registryFieldsGridApplyA.style.display = 'none';
        registryFieldsGridCancelA.style.display = 'none';
        registryFieldsEditorDiv.style.display = 'none';
        unmungRegistryFieldsGrid();
    }

    function setTitle (str) {
        function escapeHtml(str) {
            var div = document.createElement('div');
            div.appendChild(document.createTextNode(str));
            return div.innerHTML;
        }

        titleRegistryTitle.innerHTML = escapeHtml(str);
    }


    window.onload = function() {
        document.title = "Edit Registry [" + registryToken + "]";
        initParentRegistrySelector();
        initManagementPolicySelector();
        initRegistry();
        initHotKeys();
    };

    function initRegistry() {
        loadRegistry(registryToken
                ,function onSuccess(loaded_registry){
                    registry = loaded_registry;
                    initScreenWithRegistry(registry);
                    console.log(["loaded registry", registry]);
                }

                ,function onFaliure(err){
                    loadRegistry("_newRegistry"
                        ,function onSuccess(loaded_registry){
                            registry = loaded_registry;
                            initScreenWithRegistry(registry);
                            console.log(["loaded registry", registry]);
                        }
                    );
                }
        );
    }

    function initScreenWithRegistry (registry) {
        titleRegistryTitle.innerHTML = registry.details["Title"];
        registryTitle.value = registry.details["Title"];
        registryCreated.value = registry.details["Created"];
        registryLastUpdated.value = registry.details["Last Updated"];

        selectByValueOrFirst(registryParentRegistry, registry.details["Parent Registry"]);
        selectByValueOrFirst(registryManagementPolicy, registry.details["Management Policy"]);

        registryDescription.value = registry.details["Description"];
        registryNotes.value = registry.details["Notes"];

        registryFieldsGrid.setData(registry.fields);
        registryFieldsGrid.render();

        registryEntriesGrid.setColumns(registry.fields);
        registryEntriesGrid.setData(registry.entries);
        registryEntriesGrid.render();

        if (registry.options && registry.options.isSystemRegistry) {
            fieldsEditor.style.display = 'none';
        }
    }


    function initHotKeys() {
        document.addEventListener("keydown", function (e) {
            if (e.keyCode == 83 && (navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)) {
                e.preventDefault();
                saveRegistry();
            }
        }, false);
    }

    function _attic_saveRegistry() {
        var newReg = createRegistryFromScreen();
        var strNewReg = JSON.stringify(newReg, null, "  ");

        xhrPut(ctxPath + '/data/registry/' + newReg.details.Token + ".json", strNewReg,
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

    function createRegistryFromScreen () {
        var newReg = new Object();
        var oldReg = registry;

        newReg.options = registry.options;
        newReg.details = new Object();
        newReg.details.Token = registryToken;
        newReg.details.Title = registryTitle.value;
        newReg.details.Created = registryCreated.value;
        newReg.details["Last Updated"] = registryLastUpdated.value;
        newReg.details["Parent Registry"] = registryParentRegistry.value;
//        newReg.details["Reference"] = registryReference.value;
        newReg.details["Management Policy"] = registryManagementPolicy.value;
        newReg.details["Description"] = registryDescription.value;
        newReg.details["Notes"] = registryNotes.value;
        newReg.fields = registryFieldsGrid.getData();
        newReg.entries = registryEntriesGrid.getData();

        return newReg;
    }

    function initParentRegistrySelector() {
        loadRegistryValuesArray(ctxPath + '/data/registry/_registries.json', "Id",
                function onSuccess(registry_ids) {
                    var options = ["(None)"].concat(registry_ids);
                    var values = [""].concat(registry_ids);
                    initSelector(registryParentRegistry, options, values);
                }
                , function onFailure(err) {
                    console.log(["loadRegistryIdArray failed", err]);
                    var options = ["(None)", "(Error loading registry list)"];
                    var values = ["", ""];
                    initSelector(registryParentRegistry, options, values);
                }
        );
    }

    function initManagementPolicySelector() {
        loadRegistryValuesArray(ctxPath + '/data/registry/_policies.json', "Value",
                function onSuccess(policies) {
                    var options = ["(None)"].concat(policies);
                    var values = [""].concat(policies);
                    initSelector(registryManagementPolicy, options, values);
                }
                , function onFailure(err) {
                    console.log(["loadRegistryIdArray failed", err]);
                    var options = ["(None)", "(Error loading policy list)"];
                    var values = ["", ""];
                    initSelector(registryManagementPolicy, options, values);
                }
        );
    }

    function loadRegistryValuesArray(url, fieldName, onSuccess, onFailure) {
        return xhrGet(url,
                function (registry) {
                    if ("object" != typeof registry) {
                        if ("function" == typeof onFailure) onFailure();
                        return false;
                    }

                    var parent_registries = new Array();
                    for (var i=0; i<registry.entries.length; i++){
                        var regid = registry.entries[i][fieldName];
                        if ("_" == regid.substring(0,1)) continue;
                        parent_registries.push(regid);
                    }

                    if ("function" == typeof onSuccess) onSuccess(parent_registries);
                },

                onFailure
        )
    }


    function initSelector(selector, options, values) {
        selector.options.length = 0;
        for (var i=0; i<options.length; i++) {
            var opt = document.createElement("option");
            opt.text = options[i];
            opt.value = values[i];
            selector.add(opt, null);
        }
    }

    function isBlank(str) {
        return (!str || /^\s*$/.test(str));
    }

    function selectByValueOrFirst(selector, value) {
        if (! isBlank(value)) {
            selector.value = value;
        } else {
            selector.selectedIndex = 0;
        }
    }


    function loadRegistry(registryToken, onSuccess, onFailure) {
        return xhrGet(ctxPath + '/data/registry/' + registryToken + '.json',
                function (registry) {
                    if ("object" != typeof registry) {
                        if ("function" == typeof onFailure) onFailure();
                        return false;
                    }

                    if ("function" == typeof onSuccess) onSuccess(registry);
                },

                onFailure
        )
    }


    function remungRegistryEntriesGrid(){
        var registryEntriesGridColumns = registryFieldsGrid.getData();
        var registryEntriesData = registryEntriesGrid.getData();

        registryEntriesGrid.setColumns(registryEntriesGridColumns);
        registryEntriesGrid.setData(registryEntriesData);
        registryEntriesGrid.render();
    }

    function unmungRegistryFieldsGrid(){
        var registryFieldsGridData = registryEntriesGrid.getColumns();

        registryFieldsGrid.setData(registryFieldsGridData);
        registryFieldsGrid.render();
    }

    function saveRegistry() {
        var newReg = createRegistryFromScreen();
        var registryJson = JSON.stringify(newReg, null, "  ");
        var registryNrsXml = registryToNrsXml(newReg);
        var registryNrsXsd = registryToNrsXsd(newReg);
        var registryNrsXsl = registryToNrsXsl(newReg);

        var files = {
             filename0:  '/registry/' + newReg.details.Token + ".json"
            ,body0:      registryJson
            ,filename1:  '/registry/' + newReg.details.Token + ".xml"
            ,body1:      registryNrsXml
            ,filename2:  '/registry/' + newReg.details.Token + ".xsd"
            ,body2:      registryNrsXsd
            ,filename3:  '/registry/' + newReg.details.Token + ".xsl"
            ,body3:      registryNrsXsl
        };

        console.log(["saveRegistry", files]);

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


function xhrPost (url, params, onLoaded, onFailure) {
    if (typeof onLoaded != "function") return false;

    // we use a trick to avoid getting an old version from the browser's cache
    var orig_url = url;
    var sep = url.indexOf('?') >= 0 ? '&' : '?';
    url += sep + Math.floor(Math.random() * 100000);

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (this.readyState == 4) {
            var jsonData;
            if ((200 != this.status) || (!this.responseText)) {
                if ("function" == typeof onFailure) onFailure(this);
                return false;
            }
            if (typeof this.responseText == "string") jsonData = eval("(" + this.responseText + ")");
            if ("function" == typeof onLoaded) onLoaded (jsonData);
        }
    };

    var body = "";
    for (var paramName in params) {
        body += paramName + "=" + encodeURIComponent(params[paramName]) + "&";
    }

    console.log(["xhrPost", url, params, body]);

    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhr.send(body);

    return true;
};

if (!String.prototype.encodeXML) {
  String.prototype.encodeXML = function () {
    return this.replace(/&/g, '&amp;')
               .replace(/</g, '&lt;')
               .replace(/>/g, '&gt;')
               .replace(/'/g, '&apos;')
               .replace(/"/g, '&quot;');
  };
}

</script>


</body>
</html>
