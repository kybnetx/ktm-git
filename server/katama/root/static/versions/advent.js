/*
 * advent.js
 */

Ext.onReady(function(){

	var col_model = new Ext.grid.ColumnModel([
        {
            id:         'SQUIDX',
            header:     'SQ Index',
            dataIndex:  'sq_uidx'
        },
        {
            id:         'LOCSTR',
            header:     'Strasse',
            dataIndex:  'loc_strasse',
			editor:     new Ext.form.TextField({
				allowBlank: false
			})
        },
        {
            id:         'COKON',
            header:     'Kontaktperson',
            dataIndex:  'co_kontakt',
            editor:     new Ext.form.ComboBox({
                typeAhead:      true,
                triggerAction:  'all',
                transform:      'affpopup',
                lazyRender:     true,
                listClass:      'x-combo-list-small'
            })
        }
    ]);

	var Person = Ext.data.Record.create([
        { name: 'sq_uidx', type: 'int' },
        { name: 'loc_strasse', type: 'string' },
        { name: 'co_kontakt', type: 'string' }
    ]); 

    var store = new Ext.data.JsonStore({
        url: gridurl,
        root: 'sqkids',
        fields: Person
    });

    var grid = new Ext.grid.EditorGridPanel({
        store:              store,
        cm:                 col_model,
        title:              'Edit Signalquellen',
        width:              400,
        height:             300,
        frame:              true,
        autoExpandColumn:   'LOCSTR',
        renderTo:           'datagrid',
        tbar:               [
            {               
                text:           'New',
                handler:        function() {
                    var p = new Person({
                        loc_strasse: 'NEUER STANDORT',
                        co_kontakt: 'NEUER KONTAKT',
                    }); 
                    grid.stopEditing();
                    store.insert( 0, p );
                    grid.startEditing( 0, 1 );
                },
            },
            {
                text:           'Save',
                handler:        function() {
                    grid.stopEditing();
                    var changes = new Array();
                    var dirty = store.getModifiedRecords();
                    for ( var i = 0 ; i < dirty.length ; i++ ) {
                        var fields = dirty[i].getChanges();
                        fields.id = dirty[i].get( 'sq_uidx' );
                        changes.push( fields );
                    }
// This console stuff works only if firebug is enabled, otherwise error!
                    console.log( changes );
                    submitChanges( changes );
                    store.commitChanges();
                },
            },
            {
                text:           'Discard',
                handler:        function() {
                    grid.stopEditing();
                    store.rejectChanges();
                },
            }
        ]
    });

// This request sends x-www-form-urlencoded header, for x-json catalyst View JSON
    function submitChanges( data ) {
        Ext.Ajax.request({
            url:        posturl,
            success:    function() { store.reload() },
            params:     { changes: Ext.util.JSON.encode( data ) },
//            jsonData: data
        });
    }

	Ext.apply(Ext.lib.Ajax.defaultHeaders,{'Content-Type': 'text/x-json'});

	store.load({
		callback: function (records) {
			alert(store.getTotalCount());
		}
	});
});

