function newRegistryGrid(name, config) {
    var grid = new EditableGrid(name, {enableSort: false, editmode: "absolute", dateFormat: "US"});
    grid.ctxPath = config.ctxPath;
    grid.imgPath = config.imgPath;
    grid.registryConfig = config;

    if (undefined == EditableGrid.prototype._references_lock) {
        EditableGrid.prototype._references_lock = true;
        EditableGrid.prototype._loadReferences(config.ctxPath + "/data/registry/_references.json"
            ,function loaded(references, reference_urls){
                EditableGrid.prototype._references = references;
                EditableGrid.prototype._reference_urls = reference_urls;
            }
            ,function error(err){
                console.log(["Error loading NRS references.", err]);
            }
        );
    }

    return grid;
}

EditableGrid.prototype.render = function () {
    this.renderGrid(this.registryConfig.renderTo, this.registryConfig.className, this.registryConfig.elementId)
};

EditableGrid.prototype.setActionColumn = function (registryFieldName) {
    var i = this.imgPath;
    var grid = this;

    var actionsRenderer = new CellRenderer({render:function (cell, value) {
        function icon(pic, onclick) {
            var img = document.createElement("img");
            img.src = i + "/" + pic + ".png";
            img.border = "0";
            img.alt = pic;
            img.title = pic;
            var a = document.createElement("a");
            a.appendChild(img);
            a.style = "cursor:pointer";
            a.style.paddingRight = "0.25em";
            a.onclick = onclick;
            a.grid = grid;
            return a;
        }

        cell.appendChild(icon("delete", function () {
            if (confirm('Are you sure you want to delete this registry field?')) {
                grid.remove(cell.rowIndex);
            }
        }));

        cell.appendChild(icon("duplicate", function () {grid.duplicate(cell.rowIndex);}));
        cell.appendChild(icon("insert", function () {grid.insertBelow(cell.rowIndex);}));
        cell.appendChild(icon("up", function () {grid.moveUp(cell.rowIndex);}));
        cell.appendChild(icon("down", function () {grid.moveDown(cell.rowIndex);}));
    }});

    this.setCellRenderer(registryFieldName, actionsRenderer);
};

EditableGrid.prototype.setRegistryTypeCellRenderer = function (registryFieldName) {
    var c = this.ctxPath;
    var grid = this;

    var registryEditRenderer = new CellRenderer({render:function (cell, value) {
        function link(token) {
            var span = document.createElement("span");
            span.innerHTML = token + "&nbsp;";
            var a = document.createElement("a");
            a.href = c + "/admin/" + token;
            a.innerHTML = "[edit]";
            a.style = "cursor:pointer";
            a.style.paddingRight = "0.25em";

            span.appendChild(a);
            return span;
        }
        if ("" != value) cell.appendChild(link(value));
    }});

    this.setCellRenderer(registryFieldName, registryEditRenderer);
};

EditableGrid.prototype.setReferenceTypeCellRenderer = function (registryFieldName) {
    var c = this.ctxPath;
    var grid = this;

    var registryReferenceRenderer = new CellRenderer({render:function (cell, value) {
        function link(token) {
            var span = document.createElement("span");
            span.innerHTML = token;
            if (grid._reference_urls[token]) {
                span.innerHTML += "&nbsp;";
                var a = document.createElement("a");
                a.href = grid._reference_urls[token];
                a.target = "_nrs_reference";
                a.innerHTML = "[link]";
                a.style = "cursor:pointer";
                a.style.paddingRight = "0.25em";

                span.appendChild(a);
            }
            return span;
        }

        if ("" != value) cell.appendChild(link(value));
    }});

    this.setCellRenderer(registryFieldName, registryReferenceRenderer);
};



EditableGrid.prototype.nrsRegistryTypeValues = {
    "Simple Types":{"token":"Token [letters, numbers, hyphen (-), and underscore (_)]", "string":"String", "integer":"Integer", "date":"Date", "url":"URL"},
    "Special Types":{"reference":"NRS Reference Document", "registry":"NRS Registry Id [letters, numbers, hyphen (-), and underscore (_)]"}
};


// converts NRS-Registry column descriptions to EditableGrid "metadata" descriptions for initializing the GUI grid
EditableGrid.prototype.setColumns = function(columns) {
    var metadata = [{ name: "action",  label: " ", datatype:"html", editable:false }];
    var i;
    this.nrsColumns = columns;


    for (i=0; i<columns.length; i++) {
        var metaColumn = {};
        metaColumn.name = columns[i].Name;
        metaColumn.label = columns[i].Name;
        metaColumn.editable = true;

        switch (columns[i].Type) {
            case "token":
                metaColumn.datatype = "string";
                metaColumn.validator = "tokenValidator";
                break;

            case "nrsRegistryType":
                metaColumn.datatype = "string";
                metaColumn.values = EditableGrid.prototype.nrsRegistryTypeValues;
                break;

            case "boolean":
                metaColumn.datatype = "boolean";
                break;

            case "integer":
                metaColumn.datatype = "integer";
                break;

            case "url":
                metaColumn.datatype = "url";
                break;

            case "reference":
                metaColumn.datatype = "string";
                metaColumn.values = this._references;
                break;

            case "registry":
                metaColumn.datatype = "string";
                break;

            case "date":
                metaColumn.datatype = "date";
                break;

            default:
                metaColumn.datatype = "string";
        }
        metadata[metadata.length] = metaColumn;
    }

    this.load({metadata: metadata});

    this.setActionColumn("action");

    //do column actions that must be done after calling this.load({metadata:{...}})]
    for (i=0; i<columns.length; i++) {
        //create autocomplete editors for any NRS column that specifies suggestions
        if (columns[i].suggestions) {
            this.setCellEditor(columns[i].Name, new AutocompleteCellEditor({suggestions: columns[i].suggestions}));
        }

        //setup special cell renderers and validators
        switch (columns[i].Type) {
            case "registry":
                this.setRegistryTypeCellRenderer(columns[i].Name);
                // no break; registry columns need the same validator as tokens
            case "token":
                this.addCellValidator(columns[i].Name, new CellValidator({
                    isValid:function (value) {
                        return ((null == value) || ("" == value)) ? true : (null != value.match(/^[a-zA-Z0-9\-_]+$/));
                    }
                }));
                break;

            case "reference":
                this.setReferenceTypeCellRenderer(columns[i].Name);
                break;
        }
    }

};

EditableGrid.prototype.duplicate = function(rowIndex) {
    // copy values from given row, and munge the first NRS column
    var values = this.getRowValues(rowIndex);
    values[this.nrsColumns[0].Name] = values[this.nrsColumns[0].Name] + '_copy';
    this.insertAfter(rowIndex, this.getMaxRowId() + 1, values);
};

EditableGrid.prototype.moveUp = function(rowIndex) {
    if (0 == rowIndex) return;
    return this.moveDown(rowIndex-1);
};

EditableGrid.prototype.moveDown = function(rowIndex) {
    if (this.getRowCount()-1 == rowIndex) return;
    movingRow = this.getRowValues(rowIndex);
    movingRowId = this.getRowId(rowIndex);
    this.remove(rowIndex);
    this.insertAfter(rowIndex, movingRowId, movingRow, null, false);
};

EditableGrid.prototype.insertBelow = function(rowIndex) {
    var newRowId = this.getMaxRowId() + 1;

    this.insertAfter(rowIndex, newRowId, {}, null, true);
};


EditableGrid.prototype.getMaxRowId = function(rowIndex) {
    var maxRowId = 0;
    for (var r = 0; r < this.getRowCount(); r++) {
        maxRowId = Math.max(maxRowId, parseInt(this.getRowId(r)));
    }
    return maxRowId;
};

EditableGrid.prototype.getColumns = function() {
    return this.nrsColumns;
};

EditableGrid.prototype.setData = function(data) {
    var gridData = [];
    for (var i=0; i<data.length; i++) {
        gridData[i] = {id: i+1, values: data[i]};
    }

    this.load({data: gridData});
};

EditableGrid.prototype.getData = function() {
    var data = [];
    for (var row=0; row<this.getRowCount(); row++){
        var rowValues = this.getRowValues(row);
        data[row] = {};
        for (col=0; col<this.nrsColumns.length; col++) {
            data[row][this.nrsColumns[col].Name] = rowValues[this.nrsColumns[col].Name];
        }
    }
    return data;
};

xhrGet = function(url, onLoaded, onFailure) {
    return _xhrReq("GET", url, "", onLoaded, onFailure);
};

xhrPost = function(url, body, onLoaded, onFailure) {
    return _xhrReq("POST", url, body, onLoaded, onFailure);
};

_xhrReq = function(method, url, body, onLoaded, onFailure) {
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

    xhr.open(method, url, true);
    xhr.send(body);

    return true;
};

EditableGrid.prototype._loadReferences = function (url, onLoaded, onError) {
    xhrGet(url
        ,function loaded(references){
            var refs_outer = {"References":{}};
            var refs = refs_outer["References"];
            var ref_urls = new Object();
            for (var i in references.entries){
                var ref = references.entries[i]["Id"];
                refs[ref] = ref;

                ref_urls[ref] = references.entries[i]["URL"];
            }

            if ("function" == typeof onLoaded) onLoaded(refs_outer, ref_urls);
        }

        ,onError
    );
};
