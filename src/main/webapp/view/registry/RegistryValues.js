Ext.define('NRS.view.registry.RegistryValues' ,{
    extend: 'Ext.grid.Panel',
    alias: 'widget.registryValues',

    store: 'RegistryValues',
    width: '80%',

    initComponent: function() {
        this.columns = [
             {header: 'Value',  dataIndex: 'Value',  flex: 0}
            ,{header: 'Description', dataIndex: 'Description', flex: 1}
            ,{header: 'References', dataIndex: 'References', flex: 0}
            ,{header: 'Date', dataIndex: 'Date', flex: 0}
        ];

        this.callParent(arguments);
    }
});