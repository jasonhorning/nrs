    var registry = null;

    var registryFieldsGrid = newRegistryGrid("RegistryFieldsGrid", {
        ctxPath: ctxPath,
        imgPath: imgPath,
        renderTo: "registryFieldsGridDiv",
        elementId: "registryFieldsGrid",
        className: "registrygrid"
    });

    registryFieldsGrid.setColumns([
        {"Name":"Name", "Type":"token", "suggestions":['Value', 'Description', 'Reference', 'Date']},
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
