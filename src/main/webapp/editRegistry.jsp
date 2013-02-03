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

    <script type="text/javascript" src="<%=ctxPath%>/editRegistry.js"></script>
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

</body>
</html>
