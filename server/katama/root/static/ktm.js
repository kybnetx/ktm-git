// vim: ts=4:sw=4:nu:fdc=1:nospell

Ext.BLANK_IMAGE_URL = '/static/extjs/resources/images/default/s.gif';

Ext.namespace('ktm');

ktm.version = '0.9.beta';

// URI prefix (Application Server Root) for services called by the script
ktm.ASR = '';

// === Create application ======================================================

ktm.app = function() {

    // private

	var _loadstat = 'Stores';

	Ext.MessageBox.show({
		 title: 'Bitte warten'
		,msg: 'Die Applikation wird geladen.'
		,progressText: 'Lade '+_loadstat+'...'
		,progress: true
		,closable: false
		,width: 300
		,wait: true
		,waitConfig: { interval: 1000, increment: 3 } 
	});

	var _sqcurrent = null;
	var _sqchoose = '<p>Bitte eine Signalquelle auswählen!</p>';

	var _qwidth = 580;
	var _qheight = 340;

	var _pgpanWidth = 540;
	var _pgpanHeight = 330;

	var _sqpanWidth = 540;
	var _sqpanHeight = 330;

	var _sbpanWidth = 540;
	var _sbpanHeight = 330;

	var _ktpanWidth = 540;
	var _ktpanHeight = 330;

	//////////////////////////////////////////////////////////
	// The count of async store loaders which must be loaded
	// before we start application

	var _asl = 3;

	var _sqsqtype_st = new Ext.data.JsonStore({
		 url: ktm.ASR+'/cbext/sq_type'
		,root: 'cbd'
		,fields: ['val', 'abb', 'ds1']
	});

//	console.log(_sqsqtype_st);

	var _sqdeland_st = new Ext.data.JsonStore({
		 url: ktm.ASR+'/cbext/delands'
		,root: 'cbd'
		,fields: ['val', 'ds1']
	});

	var _sqdereg_st = new Ext.data.JsonStore({
		 url: ktm.ASR+'/cbext/deregs'
		,root: 'cbd'
		,fields: ['val', 'ds1']
	});
                                                            //
	//////////////////////////////////////////////////////////

	var _KT;
	var _PG;
	var _SB;
	var _SQ;

	function _initviewport() {

		new Ext.Viewport({
			layout: 'border',
			title: 'Kanaltabellen Manager',
			items: [{
				xtype: 'box',
				region: 'north',
				applyTo: 'ktm-header',
				height: 30
			},{
				id: 'ktm-browser',
				region:'west',
				border: false,
				margins: '2 0 5 5',
				width: 100,
				html: '<img id="ktmlogo" src="/static/images/ktmlogo80x80.png" />',
			}, {
				id:'ktm-app',
				region:'center',
				layout:'border',
				margins:'2 5 5 0',
				border:false,
				items: [{
					 id:'ktm-app-north'
					,region:'north'
					,height: _qheight
					,split:true
					,border:true
					,layout:'border'
					,items:[{
						 region: 'west'
						,id:'sq-tabpanel'
						,xtype: 'tabpanel'
						,split: true
						,border: true
						,width: _qwidth
						,resizeTabs:true
						,tabWidth:135
						,layoutOnTabChange: true
						,activeTab: 0
						,deferredRender: false
						,items:[{
							 id: 'sq_sigquell_tp'
							,title: 'Signalquellen'
							,iconCls: 'pgtabs'
							,layout:'fit'
							,autoWidth:true
							,autoScroll:true
							,items: [ _SQ.tab1, _SQ.info ]
						}]
					 }, {
						 region: 'center'
						,id:'sb-tabpanel'
						,xtype: 'tabpanel'
						,split: true
						,border: true
						,resizeTabs:true
						,tabWidth:135
						,layoutOnTabChange: true
						,activeTab: 0
						,deferredRender: false
						,items:[ _SB.tab1, _SB.tab2, _SB.tab3, _SB.tab4a, _SB.tab4b ]
					 }]
				}, {
					 id:'ktm-app-center'
					,region:'center'
					,split:true
					,border:true
					,layout:'border'
					,items:[{
						 region: 'west'
						,id:'kt-tabpanel'
						,xtype: 'tabpanel'
						,split: true
						,border: true
						,width: _qwidth
						,resizeTabs:true
						,tabWidth:135
						,layoutOnTabChange: true
						,activeTab: 0
						,deferredRender: false
						,items:[ _KT.tab1, _KT.tab2 ]
					 }, {
						 region: 'center'
						,id:'pg-tabpanel'
						,xtype: 'tabpanel'
						,split: true
						,border: true
						,resizeTabs:true
						,tabWidth:135
						,layoutOnTabChange: true
						,activeTab: 0
						,deferredRender: false
						,items:[ _PG.tab1, _PG.tab2, _PG.tab3, _PG.tab4 ]
					 }]
				}]
			}],

			renderTo: Ext.getBody()
		});

//		var what = Ext.getCmp('kt-tabpanel');

	} // EO _initviewport

	function _startapp( recs, opts, succ ) {

		if(!succ) {
			Ext.MessageBox.show({
				 title: 'Ladefehler für '+opts.who
				,msg: 'KTM Service nicht verfügbar. Prüfen Sie Ihren KTM Server.'
				,width: 450
				,icon: Ext.MessageBox.ERROR
				,buttons: Ext.MessageBox.OK
			});
			_asl = 999;
			return;
		}

		if(--_asl) { return; }

		// if after 60 seconds loading hadn't finished yet, something must be fucked up...
		var toid = setTimeout(function() {
			Ext.MessageBox.show({
				 title: 'Applikation Fehler: '+_loadstat
				,msg: 'Ein Applikation Fehler ist aufgetreten.'
				,width: 450
				,icon: Ext.MessageBox.ERROR
				,buttons: Ext.MessageBox.OK
			});
		}, 60000);

		_loadstat = 'PG/Programme';
		Ext.MessageBox.updateProgress(0.8, 'Lade '+_loadstat+'...');
		_PG = ktm.PGstart();

		_loadstat = 'SB/Signalbezug';
		Ext.MessageBox.updateProgress(0.8, 'Lade '+_loadstat+'...');
		_SB = ktm.SBstart();

		_loadstat = 'SQ/Signalquellen';
		Ext.MessageBox.updateProgress(0.8, 'Lade '+_loadstat+'...');
		_SQ = ktm.SQstart();

		_loadstat = 'KT/Kanaltabellen';
		Ext.MessageBox.updateProgress(0.8, 'Lade '+_loadstat+'...');
		_KT = ktm.KTstart();

		_initviewport();

		// went through, kill error message
		clearTimeout(toid);

		setTimeout(function() {
            Ext.MessageBox.hide();
        }, 2000);
	}

	// public stuff
	return {


		init: function() {
			_sqsqtype_st.load({ callback: _startapp, who: '_sqsqtype_st' });
			_sqdeland_st.load({ callback: _startapp, who: '_sqdeland_st' });
			_sqdereg_st.load({ callback: _startapp, who: '_sqdereg_st' });
		}

		,getCSQ: function() {
			return _sqcurrent;
		 }

		,setCSQ: function(node) {
			_sqcurrent = node;
		 }

		// tab panels
		,getKT: function() {
			return _KT;
		 }

		// messages
		,sqchoose: _sqchoose

		// some widget dimensions
		,pgpanWidth: _pgpanWidth
		,pgpanHeight: _pgpanHeight
		,sqpanWidth: _sqpanWidth
		,sqpanHeight: _sqpanHeight
		,sbpanWidth: _sbpanWidth
		,sbpanHeight: _sbpanHeight
		,ktpanWidth: _ktpanWidth
		,ktpanHeight: _ktpanHeight

		// pre-loaded stores
		,sqsqtype_st: _sqsqtype_st
		,sqdeland_st: _sqdeland_st
		,sqdereg_st: _sqdereg_st
	};
}(); //EO ktm.app


// === General Editor Grid ====================================================

ktm.EditorGrid = function( config ) {

	// public properties

	this.egRecord = Ext.data.Record.create( config.record );

	this.store = new Ext.data.Store({
		 reader: new Ext.data.JsonReader({
			 root: config.root
			,totalProperty: 'count'
			,fields: this.egRecord
		 })
		,proxy: new Ext.data.HttpProxy({
			 url: config.url
		 })
	});

	var mkNewrec = function() {
		var rec = config.record;
		var i; var f; var t; var newrec = {};
		for(i=0; i<rec.length; i++) {
			f = rec[i].name; t = rec[i].type;
			if (t === 'string') {
				newrec[f] = 'NEU';
			} else if(t === 'date') {
				newrec[f] = '00:00:00';
			} else {
				newrec[f] = '0';
			}
		}
		// the REST controller gets screwed up if we send him uidx for CREATE
		// ( 'cos it distinguishes CREATE and UPDATE only by absence of the primary key uidx )
		newrec.uidx = undefined;
		return newrec;
	};

	// private

	if( config.onStoreLoad ) {
		this.store.on('load', config.onStoreLoad(store, records, options));
	}

	// keeps the row last clicked
	var currentrow = null;

	// toolbar buttons for configurable toolbar
	var tbb_new = {
		 text: 'Neu'
		,iconCls: 'icon-app-add'
		,scope: this
		,handler: function() {
			var newrec = new this.egRecord( mkNewrec() );
			this.stopEditing();
			this.store.insert( 0, newrec );
			this.startEditing( 0, 1 );
		}
	};

	var tbb_save = {
		 text: 'Speichern'
		,iconCls: 'icon-app-save'
		,scope: this
		,handler: function() {
			this.stopEditing();
			var changes = new Array();
			var send = {};
			var pguidcnt = 1;
			var dirty = this.store.getModifiedRecords();
			for (var i=0 ; i < dirty.length ; i++) {
				var fields = dirty[i].getChanges();
				fields.uidx = dirty[i].get('uidx');
				fields.guid = pguidcnt++;
				// peek out the fields we dont want to send
				if(config.nosend) {
					for (var k=0; k < config.nosend.length; k++) {
						fields[config.nosend[k]] = undefined;
					}
				}
				changes.push( fields );
			}
			send[config.root] = changes;
			Ext.Ajax.request({
				 method: 'POST'
		        ,url: this.store.proxy.conn.url+'/m'
				,headers: { 'Content-Type': 'text/x-json' }
				,scope: this
				,success: function() {
					this.store.reload()
					if(config.onDataChanged) {
						config.onDataChanged(this);
					}
				 }
				,jsonData: send
			});
			// required!
			this.store.commitChanges();
			currentrow = null;
			// here we reload the related table
			if(config.onStoreChange) {
				config.onStoreChange('save');
			}
		}
	};

	var tbb_delete = {
		 text: 'Löschen'
		,iconCls: 'icon-app-del'
		,scope: this
		,handler: function() {
			if (!currentrow) return;
			var id = currentrow.get('uidx');
			this.stopEditing();
		    Ext.Ajax.request({
				 method: 'DELETE'
		        ,url: this.store.proxy.conn.url+'/'+id
				,headers:{'Content-Type': 'text/x-json'}
				,scope: this
				,success: function() {
					this.store.reload()
					if(config.onDataChanged) {
						config.onDataChanged(this);
					}
				 }
				,failure: function(r) {
					var resp = Ext.util.JSON.decode(r.responseText).error.split(/,/);
					Ext.MessageBox.show({
						 title: 'Löschen nicht möglich'
						,msg: 'Der Datensatz ist '+resp[1]+'x referenziert'
						,width: 300
						,icon: Ext.MessageBox.ERROR
						,buttons: Ext.MessageBox.OK
					});
				 }
			});
//			this.store.remove( currentrow );
			currentrow = null;
			// here we reload the related table
			if(config.onStoreChange) {
				config.onStoreChange('delete');
			}
		}
	};

	var tbb_cancel = {
		 text: 'Verwerfen'
		,iconCls: 'icon-app-cancel'
		,scope: this
		,handler: function() {
			this.stopEditing();
			this.store.rejectChanges();
		}
	};

	var tbb;

	if(!config.onlyUpdate) {
		tbb = ['->', tbb_new, '-', tbb_save, '-', tbb_delete, '-', tbb_cancel];
	} else {
		tbb = ['->', tbb_save, '-', tbb_cancel];
	}

	if(config.addTB) {
		// add scope to the buttons
		var i=0;
		for(i=0; i<config.addTB.length; i++) {
			config.addTB[i].scope = this;
		}
		tbb = config.addTB.concat(tbb);
	}

	// now for the grid...
	Ext.apply(this, config);

	this.tbar = tbb;

	var pagerconf = {};
	if( config.pagerLimit ) {
		pagerconf.params = { start: 0, limit: config.pagerLimit };
		this.bbar = new Ext.PagingToolbar({
			 store: this.store
			,displayInfo: true
			,pageSize: config.pagerLimit
			,beforePageText: 'Seite '
			,afterPageText: " von {0}"
			,displayMsg: '{0}-{1} von {2}'
			,emptyMsg: "Keine Daten"
		});
	}

	if(config.url !== 'dummy') {
		this.store.load( pagerconf );
	}

	ktm.EditorGrid.superclass.constructor.call(this);

	this.on('hide', function() {
		if(config.onGridHide) { config.onGridHide(); }
	});

	this.on('cellclick', function(grid, rowid, colid, e) {
		currentrow = this.store.getAt(rowid);
//		this.fieldName = this.getColumnModel().getDataIndex(colid);
//		var data = currentrow.get(this.fieldName);
    });
}; //EO ktm.EditorGrid

Ext.extend(ktm.EditorGrid, Ext.grid.EditorGridPanel);


// === General Grid ===========================================================

ktm.Grid = function( config ) {

	// public properties

	this.egRecord = Ext.data.Record.create( config.record );

	this.store = new Ext.data.Store({
		 reader: new Ext.data.JsonReader({
			 root: config.root
			,totalProperty: 'count'
			,fields: this.egRecord
		 })
		,proxy: new Ext.data.HttpProxy({
			 url: config.url
		 })
	});

	// private

	if( config.onStoreLoad ) {
		this.store.on('load', config.onStoreLoad(store, records, options));
	}

	// keeps the row last clicked
	var currentrow = null;

	// now for the grid...
	Ext.apply(this, config);

	var pagerconf = {};
	if( config.pagerLimit ) {
		pagerconf.params = { start: 0, limit: config.pagerLimit };
		this.bbar = new Ext.PagingToolbar({
			 store: this.store
			,displayInfo: true
			,pageSize: config.pagerLimit
			,beforePageText: 'Seite '
			,afterPageText: " von {0}"
			,displayMsg: '{0}-{1} von {2}'
			,emptyMsg: "Keine Daten"
		});
	}

	if(config.url !== 'dummy') {
		this.store.load( pagerconf );
	}

	ktm.Grid.superclass.constructor.call(this);

	this.on('cellclick', function(grid, rowid, colid, e) {
		currentrow = this.store.getAt(rowid);
    });
}; //EO ktm.Grid

Ext.extend(ktm.Grid, Ext.grid.GridPanel);


// === Connector grid window ==================================================

ktm.ConnectorWin = function( config ) {

	// window scope which is lost in callbacks, so we keep it here
	var cwscope = this;

	var propcfg = config.propcfg
	var choocfg = config.choocfg
	var conncfg = config.conncfg

	// currently selected property row
	var currprop = { record:0, row:0, reqlock:false };

	// remote expander which gets updated on actions here
	var rmtexpander = config.rmtexpander;

	// === Property Grid ==================================

	this.cwPropGrid = new Ext.grid.PropertyGrid({
		 // need cls to disable header in css
		 cls: 'ktm-cw-property-grid'
		,enableColumnResize: false
		,border: true
		,title: propcfg.title
		,region:'west'
		,layout:'fit'
		,split:true
	});

	// We dont want property grid editable
	this.cwPropGrid.on('beforeedit', function(e) { return false; });

	Ext.apply(this.cwPropGrid.colModel.config[0], { width:propcfg.col0width, sortable:false });
	Ext.apply(this.cwPropGrid.colModel.config[1], { width:propcfg.col1width, sortable:false });

	// === Chooser Grid ===================================

	var chooseraction = new Ext.ux.grid.RowActions({
		 header: 'H'
		,autoWidth: true
		,actions:[{
			 iconCls:'actadd'
			,tooltip: choocfg.addtip
		}]
	});

	choocfg.columns.push(chooseraction);

	this.cwChooserGrid = new ktm.Grid({
		 url: choocfg.url
		,root: choocfg.root
		,record: choocfg.record
		,columns: choocfg.columns
		,autoWidth: true
		,autoScroll: true
		,autoExpandColumn: choocfg.autoExpandColumn
		,stripeRows: true
		,border: true
		,plugins: chooseraction
		,title: choocfg.title
		,pagerLimit: 15
		,region:'center'
		,layout:'fit'
	}); //EO this.cwChooserGrid

	// === Connector Grid =================================

	var connectoraction = new Ext.ux.grid.RowActions({
		 header: 'L'
		,autoWidth: true
		,actions:[{
			 iconCls:'actdel'
			,tooltip: conncfg.deltip
		}]
	});

	conncfg.columns.push(connectoraction);

	var cwcgconfig = {
		 columns: conncfg.columns
		,height: conncfg.height
		,autoWidth: true
		,autoScroll: true
		,autoExpandColumn: conncfg.autoExpandColumn
		,stripeRows: true
		,border: true
		,plugins: connectoraction
		,title: conncfg.title
		,region:'south'
		,split:true
	};

	if(conncfg.plugins) {
		cwcgconfig.plugins = [ conncfg.plugins, connectoraction ];
	}

	// editable connector grid with menu
	if(conncfg.editor) {
		Ext.apply(cwcgconfig, {
			 url: 'dummy'
			,root: conncfg.root
			,record: conncfg.record
			,nosend: conncfg.nosend
			,onlyUpdate: true
		});

		if(rmtexpander) {
			cwcgconfig.onDataChanged = function(grid) {
				rmtexpander.collapseRow(currprop.row);
				rmtexpander.reloadTable(currprop.record, currprop.row, false);
			}
		}
		this.cwConnectGrid = new ktm.EditorGrid(cwcgconfig);
	}
	// normal connector grid
	else {
		Ext.apply(cwcgconfig, {
			 store: new Ext.data.JsonStore({
				 url: 'dummy'
				,root: conncfg.root
				,fields: Ext.data.Record.create(conncfg.record)
		 	})
		});
		this.cwConnectGrid = new Ext.grid.GridPanel(cwcgconfig);
	}

	// === Actions of dragons above =======================

	// cwChooserGrid actions
	chooseraction.on({
		action: function(grid, record, action, row, col) {
			// keep mad clickers away from my request until finished
			if( currprop.reqlock ) { return; }
			if( action == 'actadd' ) {
				currprop.reqlock = true;
				// call to connector service to add data
				Ext.Ajax.request({
					 method: 'POST'
					,url: conncfg.url+'/'+currprop.record.get(propcfg.keyIdx)+'/'+record.get(choocfg.keyIdx)
					,headers: { 'Content-Type': 'text/x-json' }
					,scope: cwscope
					,callback: function(options, success, response) {
						if(success) {
							this.cwConnectGrid.getStore().reload();
							if(rmtexpander) {
								rmtexpander.collapseRow(currprop.row);
								rmtexpander.reloadTable(currprop.record, currprop.row, false);
							}
						}
						currprop.reqlock = false;
					}
				});
				// what if Ajax.request never returns? Can it happen?
			}
		}
	});

	// cwConnectGrid actions
	connectoraction.on({
		action: function(grid, record, action, row, col) {
			// keep mad clickers away from my request until finished
			if( currprop.reqlock ) { return; }
			if( action == 'actdel' ) {
				currprop.reqlock = true;
				Ext.Ajax.request({
					 method: 'DELETE'
					,url: conncfg.url+'/'+record.get(conncfg.prkeyIdx)+'/'+record.get(conncfg.chkeyIdx)
					,headers: { 'Content-Type': 'text/x-json' }
					,scope: cwscope
					,callback: function(options, success, response) {
						if(success) {
							this.cwConnectGrid.getStore().load({ scope: cwscope, callback: function(rec, opt, ok) {
								if(!ok) { this.cwConnectGrid.getStore().removeAll(); }
							}});
							if(rmtexpander) {
								rmtexpander.collapseRow(currprop.row);
								rmtexpander.reloadTable(currprop.record, currprop.row, false);
							}
						}
						currprop.reqlock = false;
					}
				});
				// what if Ajax.request never returns? Can it happen?
			}
		}
	});

	// === Load data and show window ======================

	var cgrtitle;
	var showprop;
	var i;

	this.cwShow = function(record, row) {
		if( currprop.reqlock ) { return }
		currprop.row = row;
		currprop.record = record;
		//load connector grid with initial choice
		this.cwConnectGrid.getStore().proxy.conn.url = conncfg.url+'/'+record.get(propcfg.keyIdx);
		this.cwConnectGrid.getStore().load({ scope: this, callback: function(rec, opt, ok) {
			if(!ok) { this.cwConnectGrid.getStore().removeAll(); }
		}});
		//set smart grid title with property info
		cgrtitle = conncfg.title;
		cgrtitle += (conncfg.titleIdx ? ' "' + record.get(conncfg.titleIdx) + '"' : '');
		this.cwConnectGrid.setTitle(cgrtitle);
		//current property data for property store to show
		showprop = {};
		for(i=0; i < propcfg.datarows.length; i++) {
			showprop[ propcfg.datarows[i].name ] = record.get(propcfg.datarows[i].idx);
		}
		this.cwPropGrid.setSource( showprop );
		if(this.hidden || !this.rendered) {
			//chooser load only on window show
			this.cwChooserGrid.getStore().reload();
			this.show();
		}
	}

	// === Actualy window... ==============================

	Ext.apply(this, {
		 title: config.title
		,width: config.width
		,height: config.height
		,border: false
		,plain: true
		,closable: false
		,collapsible: true
		,layout: 'border'
		,items: [ this.cwPropGrid, this.cwChooserGrid, this.cwConnectGrid ]
		,buttons: [{
			 text:'Schließen'
			,handler: function() { this.hide() }
			,scope: this
		}]
	});

	ktm.ConnectorWin.superclass.constructor.call(this);

}; //EO ktm.ConnectorWin

Ext.extend(ktm.ConnectorWin, Ext.Window);


// === Field value chooser window =============================================

ktm.ChooserWin = function( config ) {

	var propcfg = config.propcfg
	var choocfg = config.choocfg

	// currently selected property row
	var currprop = { record:0, row:0 };

	// === Property Grid ==================================

	this.chwPropGrid = new Ext.grid.PropertyGrid({
		 // need cls to disable header in css
		 cls: 'ktm-cw-property-grid'
		,enableColumnResize: false
		,border: true
		,title: propcfg.title
		,region:'west'
		,layout:'fit'
		,split:true
	});

	// We dont want property grid editable
	this.chwPropGrid.on('beforeedit', function(e) { return false; });

	Ext.apply(this.chwPropGrid.colModel.config[0], { width:propcfg.col0width, sortable:false });
	Ext.apply(this.chwPropGrid.colModel.config[1], { width:propcfg.col1width, sortable:false });

	// === Chooser Grid ===================================

	var chooseraction = new Ext.ux.grid.RowActions({
		 header: 'U'
		,autoWidth: true
		,actions:[{
			 iconCls:'actuse'
			,tooltip: choocfg.addtip
		}]
	});

	choocfg.columns.push(chooseraction);

	this.chwChooserGrid = new ktm.Grid({
		 url: choocfg.url
		,root: choocfg.root
		,record: choocfg.record
		,columns: choocfg.columns
		,autoWidth: true
		,autoScroll: true
		,autoExpandColumn: choocfg.autoExpandColumn
		,stripeRows: true
		,border: true
		,title: choocfg.title
		,plugins: chooseraction
		,pagerLimit: 15
		,region:'center'
		,layout:'fit'
	}); //EO this.chwChooserGrid

	// === Actions of snake above =======================

	var i;
	var pmap;

	// chwChooserGrid actions
	chooseraction.on({
		action: function(grid, record, action, row, col) {
			if( action == 'actuse' ) {
				for(i=0; i<choocfg.record.length; i++) {
					pmap = choocfg.record[i].propMap;
					if(pmap) {
						currprop.record.set(pmap, record.get(choocfg.record[i].name));
					}
				}
				if(choocfg.onuse) { onuse(grid, record, row); }
			}
		}
	});

	// === Load data and show window ======================

	var sgrtitle;
	var showprop;

	this.chwShow = function(record, row) {
		currprop.row = row;
		currprop.record = record;
		//set smart grid title with property info
		sgrtitle = choocfg.title;
		sgrtitle += (choocfg.titleIdx ? ' "' + record.get(choocfg.titleIdx) + '"' : '');
		this.chwChooserGrid.setTitle(sgrtitle);
		//current property data for property store to show
		showprop = {};
		for(i=0; i < propcfg.datarows.length; i++) {
			showprop[ propcfg.datarows[i].name ] = record.get(propcfg.datarows[i].idx);
		}
		this.chwPropGrid.setSource( showprop );
		if(this.hidden || !this.rendered) {
			//chooser load only on window show
			this.chwChooserGrid.getStore().reload();
			this.show();
		}
	}

	// === Actualy window... ==============================

	Ext.apply(this, {
		 title: config.title
		,width: config.width
		,height: config.height
		,border: false
		,plain: true
		,closable: false
		,collapsible: true
		,layout: 'border'
		,items: [ this.chwPropGrid, this.chwChooserGrid ]
		,buttons: [{
			 text:'Schließen'
			,handler: function() { this.hide() }
			,scope: this
		}]
	});

	ktm.ChooserWin.superclass.constructor.call(this);

}; //EO ktm.ChooserWin

Ext.extend(ktm.ChooserWin, Ext.Window);


// === Simple data status show only window ====================================

ktm.StatusWin = function( config ) {

	var propcfg = config.propcfg
	var statcfg = config.statcfg

	// currently selected property row
	var currprop = { record:0, row:0 };

	// === Property Grid ==================================

	this.swPropGrid = new Ext.grid.PropertyGrid({
		 // need cls to disable header in css
		 cls: 'ktm-cw-property-grid'
		,enableColumnResize: false
		,border: true
		,title: propcfg.title
		,region:'west'
		,layout:'fit'
		,split:true
	});

	// We dont want property grid editable
	this.swPropGrid.on('beforeedit', function(e) { return false; });

	Ext.apply(this.swPropGrid.colModel.config[0], { width:propcfg.col0width, sortable:false });
	Ext.apply(this.swPropGrid.colModel.config[1], { width:propcfg.col1width, sortable:false });

	// === Status Grid ===================================

	this.swStatusGrid = new ktm.Grid({
/*
	Here was the source of an interesting bug: if we should set url to the
	real url, the ktm.Grid would start to load the store (because url != dummy)
	and in the next step within swShow initiate store load again. thus, the first
	load breaks and callback gets called with ok = false, deleting the loaded store.
//		 url: statcfg.url
*/
		 url: 'dummy'
		,root: statcfg.root
		,record: statcfg.record
		,columns: statcfg.columns
		,autoWidth: true
		,autoScroll: true
		,autoExpandColumn: statcfg.autoExpandColumn
		,stripeRows: true
		,border: true
		,title: statcfg.title
//		,pagerLimit: 15
		,region:'center'
		,layout:'fit'
	}); //EO this.swStatusGrid

	// === Load data and show window ======================

	var sgrtitle;
	var showprop;

	this.swShow = function(record, row) {
		currprop.row = row;
		currprop.record = record;
		//load status grid with initial choice
		this.swStatusGrid.getStore().proxy.conn.url = statcfg.url+'/'+record.get(statcfg.keyIdx);

//		console.log(this.swStatusGrid.getStore().proxy.conn.url);

		this.swStatusGrid.getStore().load({ scope: this, callback: function(rec, opt, ok) {
//			console.log(ok);
			if(!ok) { this.swStatusGrid.getStore().removeAll(); }
		}});
		//set smart grid title with property info
		sgrtitle = statcfg.title;
		sgrtitle += (statcfg.titleIdx ? ' "' + record.get(statcfg.titleIdx) + '"' : '');
		this.swStatusGrid.setTitle(sgrtitle);
		//current property data for property store to show
		showprop = {};
		for(i=0; i < propcfg.datarows.length; i++) {
			showprop[ propcfg.datarows[i].name ] = record.get(propcfg.datarows[i].idx);
		}
		this.swPropGrid.setSource( showprop );
		if(this.hidden || !this.rendered) {
			//statser load only on window show
			this.swStatusGrid.getStore().reload();
			this.show();
		}
	}

	// === Actualy window... ==============================

	Ext.apply(this, {
		 title: config.title
		,width: config.width
		,height: config.height
		,border: false
		,plain: true
		,closable: false
		,collapsible: true
		,layout: 'border'
		,items: [ this.swPropGrid, this.swStatusGrid ]
		,buttons: [{
			 text:'Schließen'
			,handler: function() { this.hide() }
			,scope: this
		}]
	});

	ktm.StatusWin.superclass.constructor.call(this);

}; //EO ktm.StatusWin

Ext.extend(ktm.StatusWin, Ext.Window);


// === Kanal (radio or other) chooser =========================================

ktm.KanalChooser = function(config) {

	this.kcStore = new Ext.data.JsonStore({
		 url: config.url
		,root: config.root
		,fields: config.fields
	});

	this.kcCombo = new Ext.form.ComboBox({
		 store: this.kcStore
		,hideLabel: true
		,hideTrigger: true
		,displayField: config.displayField
		,valueField: config.valueField
		,editable: true
		,typeAhead: false
//		,triggerAction: 'all'
//		,emptyText: 'Kanal...'
		,forceSelection: true
		,minChars: 2
		,lazyRender: true
//		,selectOnFocus: true
	});

	this.kcRender = function(val, md, rec) {
		// initial field data, just forward
		if (!rec.dirty) { return val; }
		// that valueField goes somewhere else
		rec.set(config.valueIdx ,val);
		// and here we want displayField
		var idx = this.kcStore.find(config.valueField, val);
		var cbr = this.kcStore.getAt(idx);
		return cbr.get(config.displayField);
	}.createDelegate(this);

	this.kcBeforeEdit = function(e) {
		var rec = e.record;
		// no, we don't want last query because if not changed no server request
		// (different field might require different resultset for the same query)
		this.kcStore.removeAll();
		// fine little undocumented prop to reload cb even if query didn't changed
		this.kcCombo.lastQuery = undefined;
		// setup for new query
		this.kcStore.baseParams = (rec.get(config.typeIdx) == 2 ? {radio:1} : {radio:0});
	}.createDelegate(this);

}; // EO ktm.KanalChooser


// ============================================================================
// === Apps entry point =======================================================
// ============================================================================

Ext.onReady(function() {

	Ext.QuickTips.init();

	ktm.app.init();

});
