// vim: ts=4:sw=4:nu:fdc=1:nospell

Ext.namespace('ktm');

ktm.PGstart = function() {

///////////////////////////////////////////////////////////////////////////////
// Vertragsdaten
///////////////////////////////////////////////////////////////////////////////

	var pg_vertr_chc = new Ext.grid.CheckColumn({
			 header: 'Zeitpartage'
			,dataIndex: 'iss'
			,width: 75
	});

    var pg_vertr_gr = new ktm.EditorGrid({
		 url: ktm.ASR+'/pgext'
		,root: 'pg'
		,record: [
			 { name:'uidx', type:'int' }
			,{ name:'nam', type:'string' }
			,{ name:'pgt', type:'string' }
			,{ name:'iss', type:'bool' }
			,{ name:'sfr', type:'string' }
			,{ name:'sto', type:'string' }
			,{ name:'vtd', type:'string' }
		]
		,columns: [
			 {header: 'ID' ,sortable: false ,dataIndex: 'uidx' ,width: 30 ,menuDisabled: true }
			,{id: 'NAM' ,css:'background-color: #dddddd;' ,header: 'Programm' ,dataIndex: 'nam' ,sortable:true ,width: 110 }
			,{id: 'PGT' ,css:'background-color: #dddddd;' ,header: 'Typ' ,dataIndex: 'pgt' ,sortable: true ,width: 70 }
			,{id: 'VTD' ,header: 'Vertrag' ,dataIndex: 'vtd' ,sortable:true ,editor: new Ext.form.TextField({ allowBlank: false }) }
			,pg_vertr_chc
			,{id: 'SFR' ,header: 'Von' ,dataIndex: 'sfr' ,sortable: true ,width: 70 ,editor: new Ext.form.TextField({ allowBlank: false }) }
			,{id: 'STO' ,header: 'Bis' ,dataIndex: 'sto' ,sortable: true ,width: 70 ,editor: new Ext.form.TextField({ allowBlank: false }) }
		]
		,onlyUpdate: true
		,title: 'Vertragsdaten'
		,iconCls: 'tabico'
		,autoExpandColumn: 'VTD'
		,layout:'fit'
		,autoWidth: true
		,autoScroll: true
//		,width: ktm.app.pgpanWidth
//		,height: ktm.app.pgpanHeight
		,plugins: pg_vertr_chc
		,pagerLimit: 15
	}); //EO pg_vertr_gr

///////////////////////////////////////////////////////////////////////////////
// TV Programme
///////////////////////////////////////////////////////////////////////////////

    var pg_tvprog_gr = new ktm.EditorGrid({
		 url: ktm.ASR+'/tvpext'
		,root: 'tvp'
		,record: [
			 { name:'uidx', type:'int' }
			,{ name:'nam', type:'string' }
			,{ name:'lnd', type:'string' }
			,{ name:'gnr', type:'string' }
			,{ name:'spr', type:'string' }
		]
		,columns: [
			 { header:'ID' ,sortable:false ,dataIndex:'uidx' ,width:30 ,menuDisabled:true }
			,{id: 'NAM' ,header: 'Name' ,dataIndex: 'nam' ,sortable:true ,width: 110 ,editor: new Ext.form.TextField({ allowBlank: false }) }
			,{id: 'LND' ,header: 'Land' ,dataIndex: 'lnd' ,sortable:true ,width: 150 ,editor: new Ext.form.TextField({ allowBlank: false }) }
			,{id: 'GNR' ,header: 'Genre' ,dataIndex: 'gnr' ,sortable:true ,width: 100 ,editor: new Ext.form.TextField({ allowBlank: false }) }
			,{id: 'SPR' ,header: 'Sprache' ,dataIndex: 'spr' ,sortable:true ,editor: new Ext.form.TextField({ allowBlank: false }) }
		]
		,title: 'TV Programme'
		,iconCls: 'pgtabs'
		,autoExpandColumn: 'SPR'
		,onStoreChange: function(change) { pg_vertr_gr.store.reload(); }
		,layout:'fit'
		,autoWidth: true
		,autoScroll: true
//		,width: ktm.app.pgpanWidth
//		,height: ktm.app.pgpanHeight
		,pagerLimit: 15
	}); //EO pg_tvprog_gr

///////////////////////////////////////////////////////////////////////////////
// Rundfunk
///////////////////////////////////////////////////////////////////////////////

    var pg_rfprog_gr = new ktm.EditorGrid({
		 url: ktm.ASR+'/rpext'
		,root: 'rp'
		,record: [
			 { name:'uidx', type:'int' }
			,{ name:'nam', type:'string' }
			,{ name:'lnd', type:'string' }
			,{ name:'gnr', type:'string' }
			,{ name:'spr', type:'string' }
		]
		,columns: [
			 {header: 'ID' ,sortable: false ,dataIndex: 'uidx' ,width: 30 ,menuDisabled: true }
			,{id: 'NAM' ,header: 'Name' ,dataIndex: 'nam' ,sortable:true ,width: 110 ,editor: new Ext.form.TextField({ allowBlank: false }) }
			,{id: 'LND' ,header: 'Land' ,dataIndex: 'lnd' ,sortable:true ,width: 150 ,editor: new Ext.form.TextField({ allowBlank: false }) }
			,{id: 'GNR' ,header: 'Genre' ,dataIndex: 'gnr' ,sortable:true ,width: 100 ,editor: new Ext.form.TextField({ allowBlank: false }) }
			,{id: 'SPR' ,header: 'Sprache' ,dataIndex: 'spr' ,sortable:true ,editor: new Ext.form.TextField({ allowBlank: false }) }
		]
		,title: 'Rundfunk'
		,iconCls: 'pgtabs'
		,autoExpandColumn: 'SPR'
		,onStoreChange: function(change) { pg_vertr_gr.store.reload(); }
		,layout:'fit'
		,autoWidth: true
		,autoScroll: true
//		,width: ktm.app.pgpanWidth
//		,height: ktm.app.pgpanHeight
		,pagerLimit: 15
	}); //EO pg_rfprog_gr

///////////////////////////////////////////////////////////////////////////////
// Bouquets
///////////////////////////////////////////////////////////////////////////////
	
	var pg_bouq_exp = new Ext.grid.RowTableExpander({
		 url: ktm.ASR+'/bqpgext_tab'
		,datakey: 'uidx'
		,noData: 'Keine Programme zugeordnet!'
		,clSfx: 'bqpg'
	});

	var pg_bouq_act = new Ext.ux.grid.CellActions({
		align: 'left'
	});

	var pg_bouq_gr = new ktm.EditorGrid({
		 url: ktm.ASR+'/bqext'
		,root: 'bq'
		,iconCls: 'pgtabs'
		,title: 'Bouquets'
		,record: [
			 { name:'uidx', type:'int' }
			,{ name:'nam', type:'string' }
			,{ name:'btr', type:'string' }
			,{ name:'lnd', type:'string' }
			,{ name:'dummy' }
		]
		,columns: [
			 pg_bouq_exp
			,{header:'' ,sortable:false ,dataIndex:'dummy' ,width:25 ,menuDisabled:true ,cellActions:[{iconCls:'actreload' ,qtip:'Bouquet Programme neu laden'}]}
			,{header:'ID' ,sortable:false ,dataIndex:'uidx' ,width:30 ,menuDisabled:true}
			,{header:'Pg' ,sortable:false ,dataIndex:'dummy' ,width:25 ,menuDisabled:true ,cellActions:[{iconCls:'actedit' ,qtip:'Bouquet Programme verwalten'}]}
			,{id:'NAM' ,header:'Name' ,dataIndex:'nam' ,width:130 ,sortable:true ,editor: new Ext.form.TextField({allowBlank:false})}
			,{id:'BTR' ,header:'Betreiber' ,dataIndex:'btr' ,width:130 ,sortable:true ,editor: new Ext.form.TextField({allowBlank:false})}
			,{id:'LND' ,header:'Land' ,dataIndex:'lnd' ,width:130 ,sortable:true ,editor: new Ext.form.TextField({allowBlank:false })}
		]
		,layout:'fit'
		,autoWidth: true
		,autoScroll: true
//		,width: ktm.app.pgpanWidth
//		,height: ktm.app.pgpanHeight
//		,autoExpandColumn: 'NAM'
		,onStoreChange: function(change) { pg_vertr_gr.store.reload(); }
		,plugins: [ pg_bouq_act, pg_bouq_exp ]
		,pagerLimit: 15
	}); //EO pg_bouq_gr


// === Bouquetprogramme =======================================================

	var pg_bouq_win = new ktm.ConnectorWin({
		 width: 700
		,height: 550
		,title:'Bouquetprogramme verwalten'
		 // remote grid expander to be updated
		,rmtexpander: pg_bouq_exp
		// property grid config
		,propcfg: {
			 width: 200
			 // title of property grid
			,title: 'Der aktuelle Bouquet'
			 // width of columns in property grid
			,col0width: 100
			,col1width: 150
			// primary key of property data
			,keyIdx: 'uidx'
			// definition of data which shows up
			,datarows: [{
				 name: 'Bouquet:'
				,idx: 'nam'
			}, {
				 name: 'Betreiber:'
				,idx: 'btr'
			}]
		}
		// chooser grid config
		,choocfg: {
			 url: ktm.ASR+'/pgext_bqsel'
			,root: 'pgsel'
			 // primary key of chooser data
			,keyIdx: 'uidx'
			 // tooltip for add action
			,addtip: 'Programm hinzufügen'
			,record: [
				 { name:'uidx', type:'int' }
				,{ name:'nam', type:'string' }
				,{ name:'pgt', type:'string' }
				,{ name:'gnr', type:'string' }
			]
			,columns: [
				 {header:'ID' ,dataIndex:'uidx' ,width:30 ,menuDisabled:true ,sortable:false}
				,{header:'Programm' ,dataIndex:'nam' ,width:140 ,menuDisabled:true ,sortable:true}
				,{header:'Typ' ,dataIndex:'pgt' ,width:80 ,menuDisabled:true ,sortable:true}
				,{id:'GNR' ,header:'Genre' ,dataIndex:'gnr' ,menuDisabled:true ,sortable:true}
			]
			,autoExpandColumn: 'GNR'
			,title: 'Programmauswahl'
		}
		// connector grid config
		,conncfg: {
			 url: ktm.ASR+'/bqpgext'
			,root: 'bqpg'
			,height: 230
			,title: 'Die Programme vom Bouquet'
			 // index of property data to add on title
			,titleIdx: 'nam'
			 // connector's property and chooser reference
			,prkeyIdx: 'bqid'
			,chkeyIdx: 'pgid'
			 // tooltip for delete action
			,deltip: 'Programm aus dem Bouquet entfernen'
			,record: [
				 { name:'pgid', type:'int' }
				,{ name:'bqid', type:'int' }
				,{ name:'nam', type:'string' }
				,{ name:'pgt', type:'string' }
				,{ name:'gnr', type:'string' }
			]
			,columns: [
				 {header:'PGID' ,dataIndex:'pgid' ,width:30 ,menuDisabled:true ,sortable:false}
				,{header:'BQID' ,dataIndex:'bqid' ,width:30 ,menuDisabled:true ,sortable:false}
				,{header:'Programm' ,dataIndex:'nam' ,width:140 ,menuDisabled:true ,sortable:true}
				,{header:'Typ' ,dataIndex:'pgt' ,width:80 ,menuDisabled:true ,sortable:true}
				,{id:'GNR' ,header:'Genre' ,dataIndex:'gnr' ,menuDisabled:true ,sortable:true}
			]
			,autoExpandColumn: 'GNR'
		}
	});

	pg_bouq_act.on({
		action: function(grid, record, action, value, dataid, row, col) {
			if( action == 'actreload' ) {
				pg_bouq_exp.reloadTable(record, row, true);
			}
			else if( action == 'actedit' ) {
				pg_bouq_win.cwShow(record, row);
			}
		}
	});

///////////////////////////////////////////////////////////////////////////////
// TabPanel for all the stuff
///////////////////////////////////////////////////////////////////////////////

/*
	var pg_main_tabs = new Ext.TabPanel({
		 renderTo:'tabpanel-pg'
		,border: true
		,resizeTabs:true
//		,plain: true
//		,minTabWidth: 115
		,tabWidth:135
		,layoutOnTabChange: true
		// ensures that we can see other tabs too
		,deferredRender: false
//		,autoWidth: true
		,width: ktm.app.pgpanWidth
		,autoHeight: true
		,defaults: {
			 autoScroll:false
			 // hideMode: "offsets" fixes disapearing of the cursor
			,hideMode:"offsets"
		}
	});

	pg_main_tabs.add( pg_tvprog_gr );
	pg_main_tabs.add( pg_rfprog_gr );
	pg_main_tabs.add( pg_bouq_gr );
	pg_main_tabs.add( pg_vertr_gr );

	pg_main_tabs.doLayout();

	pg_main_tabs.activate( pg_tvprog_gr );
*/

	return {
		 tab1:pg_tvprog_gr
		,tab2:pg_rfprog_gr
		,tab3:pg_bouq_gr
		,tab4:pg_vertr_gr
	}
};
