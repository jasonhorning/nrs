Ext.define('NRS.view.registry.RegistryDetails' ,{
     extend: 'Ext.panel.Panel'

    ,alias: 'widget.registryDetails'

    ,tpl: new Ext.XTemplate(
          '<div id="registrydetails">'
        + '<h1>[{Token}] {Title}</h1>'
        + '<table class="pretty">'
        + '<tr><td>Created</td>                <td>{[values["Created"]]}</td></tr>'
        + '<tr><td>Last Updated</td>           <td>{[values["Last Updated"]]}</td></tr>'
        + '<tr><td>Registry</td>               <td>[<a href="/registry/{[values["Registry"]]}">{[values["Registry"]]}</a>]</td></tr>'
        + '<tpl><tr><td>References</td>        <td><tpl for="References">[<a href="{url}">{name}</a>] </tpl></td></tr>'
        + '<tr><td>Registration Procedure</td> <td>{[values["Registration Procedure"]]}</td></tr>'
        + '<tr><td>Description</td>            <td>{[values["Description"]]}</td></tr>'
        + '<tr><td>Note</td>                   <td>{[values["Note"]]}</td></tr>'
        + '</table>'
        + '</div>'
        )


//    ,initComponent: function() {
//        console.log ("NRS.view.registry.RegistryDetails.initComponent()");
//        console.log (this.tpl);
//        this.callParent(arguments);
//    }
});