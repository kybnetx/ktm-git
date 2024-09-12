// vim: ts=4:sw=4:nu:fdc=1:nospell

Ext.namespace('ktm');

ktm.SBstart = function() {

///////////////////////////////////////////////////////////////////////////////
// Satelliten
///////////////////////////////////////////////////////////////////////////////

	var sb_satflieger_exp = new Ext.grid.RowTableExpander({
		 url: ktm.ASR+'/satpgext_tab'
		,datakey: 'uidx'
		,noData: 'Keine SAT Programme zugeordnet!'
		,clSfx: 'satpg'
	});

	var sb_satflieger_act = new Ext.ux.grid.CellActions({
		align: 'left'
	});

    var sb_satflieger_gr = new ktm.EditorGrid({
		 url: ktm.ASR+'/satext'
		,root: 'sat'
		,record: [
			 { name:'uidx', type:'int' }
			,{ name:'sbpid', type:'int' }
			,{ name:'plnd', type:'string' }
			,{ name:'pfrm', type:'string' }
			,{ name:'kn1', type:'string' }
			,{ name:'kn2', type:'string' }
			,{ name:'spo', type:'float' }
			,{ name:'sei', type:'float' }
			,{ name:'scx', type:'string' }
			,{ name:'sba', type:'string' }
			,{ name:'sbe', type:'string' }
			,{ name:'dummy' }
		]
		 // the folowing fields won't be send to server on record change
		,nosend: [ 'plnd', 'pfrm' ]
		,columns: [
			 sb_satflieger_exp
			,{header:'' ,sortable:false ,dataIndex:'dummy' ,width:25 ,menuDisabled:true ,cellActions:[{iconCls:'actreload' ,qtip:'SAT Programme neu laden'}]}
//[[
			,{header:'ID' ,sortable:false ,dataIndex:'uidx' ,width:25 ,menuDisabled:true}
			,{header:'PV' ,sortable:false ,dataIndex:'sbpid' ,width:25 ,menuDisabled:true}
//]]
			,{header:'Pg' ,sortable:false ,dataIndex:'dummy' ,width:25 ,menuDisabled:true ,cellActions:[{iconCls:'actedit' ,qtip:'SAT Programme verwalten'}]}
			,{id:'KN1' ,header:'Kennung' ,dataIndex:'kn1' ,sortable:true ,editor:new Ext.form.TextField({allowBlank:false})}
			,{header:'Ost °' ,dataIndex:'spo' ,sortable:true ,width:40 ,editor:new Ext.form.TextField({allowBlank:false})}
			,{header:'CoDX' ,dataIndex:'scx' ,sortable:true ,width:35 ,editor:new Ext.form.TextField({allowBlank:false})}
			,{header:'Betreiber' ,dataIndex:'pfrm' ,sortable:true ,width:180 ,cellActions:[{iconCls:'appform' ,qtip:'Betreiber wählen'}]}
		]
		,onStoreLoad: null
		,onStoreChange: function () {
			if(sb_satsbprov_win.rendered) {
				sb_satsbprov_win.hide();
			}
		 }
		,onGridHide: function () {
			if(sb_satsbprov_win.rendered) {
				sb_satsbprov_win.hide();
			}
		 }
		,title: 'Satelliten'
		,iconCls: 'tabico'
		,autoExpandColumn: 'KN1'
		,layout:'fit'
		,autoWidth: true
		,autoScroll: true
//		,width: ktm.app.sbpanWidth
//		,height: ktm.app.sbpanHeight
		,plugins: [ sb_satflieger_exp, sb_satflieger_act ]
		,pagerLimit: 15
	}); //EO sb_satflieger_gr

// === Satelliten Programme =======================================================

	var sb_conn_satcrypt_chc = new Ext.grid.CheckColumn({
			 header: 'Verschlüßelt'
			,dataIndex: 'cry'
			,width: 80
	});

	var sb_satflieger_win = new ktm.ConnectorWin({
		 width: 700
		,height: 550
		,title:'Satellitenprogramme verwalten'
		 // remote grid expander to be updated
		,rmtexpander: sb_satflieger_exp
		// property grid config
		,propcfg: {
			 title: 'Der aktuelle Satellit'
			 // width of columns in property grid
			,col0width: 110
			,col1width: 160
			// primary key of property data
			,keyIdx: 'uidx'
			// definition of data which shows up
			,datarows: [
				 { name: '1. Kennung:' ,idx: 'kn1' }
				,{ name: '2. Position:' ,idx: 'spo' }
				,{ name: '3. SatcoDX:' ,idx: 'scx' }
				,{ name: '4. Betreiber:' ,idx: 'pfrm' }
				,{ name: '5. Land:' ,idx: 'plnd' }
			]
		}
		// chooser grid config
		,choocfg: {
			 url: ktm.ASR+'/pgext_sel'
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
//[[
				 {header:'ID' ,dataIndex:'uidx' ,width:25 ,menuDisabled:true ,sortable:false},
//]]
				 {header:'Programm' ,dataIndex:'nam' ,width:140 ,menuDisabled:true ,sortable:true}
				,{header:'Typ' ,dataIndex:'pgt' ,width:80 ,menuDisabled:true ,sortable:true}
				,{id:'GNR' ,header:'Genre' ,dataIndex:'gnr' ,menuDisabled:true ,sortable:true}
			]
			,autoExpandColumn: 'GNR'
			,title: 'Programmauswahl'
		}
		// connector grid config
		,conncfg: {
			 url: ktm.ASR+'/satpgext'
			,root: 'satpg'
			,height: 230
			,title: 'Die Programme vom Satellit'
			 // index of property data to add on title
			,titleIdx: 'kn1'
			 // connector's property and chooser reference
			,prkeyIdx: 'sbid'
			,chkeyIdx: 'pgid'
			 // tooltip for delete action
			,deltip: 'Programm vom Satelliten entfernen'
			,record: [
				 { name:'uidx', type:'int' }
				,{ name:'pgid', type:'int' }
				,{ name:'sbid', type:'int' }
				,{ name:'nam', type:'string' }
				,{ name:'pgt', type:'string' }
				,{ name:'pol', type:'string' }
				,{ name:'frq', type:'string' }
				,{ name:'cry', type:'bool' }
			]
			,columns: [
//[[
				 {header:'PGID' ,dataIndex:'pgid' ,width:30 ,menuDisabled:true ,sortable:false}
				,{header:'SBID' ,dataIndex:'sbid' ,width:30 ,menuDisabled:true ,sortable:false},
//]]
				 {id:'NAM' ,header:'Programm' ,css:'background-color: #dddddd;' ,dataIndex:'nam' ,width:140 ,menuDisabled:true ,sortable:true}
				,{header:'Typ' ,css:'background-color: #dddddd;' ,dataIndex:'pgt' ,width:80 ,menuDisabled:true ,sortable:true}
				,{header:'Freq' ,dataIndex:'frq' ,width:70 ,menuDisabled:true ,sortable:true ,editor:new Ext.form.TextField({allowBlank: true})}
				,{header:'Pol' ,dataIndex:'pol' ,width:30 ,menuDisabled:true ,sortable:true ,editor:new Ext.form.TextField({allowBlank: true})}
				,sb_conn_satcrypt_chc
			]
			,plugins: sb_conn_satcrypt_chc
			,autoExpandColumn: 'NAM'
			,editor: true
		}
	});

// === Satelliten Betreiber ======================================================

	var sb_satsbprov_win = new ktm.ChooserWin({
		 width: 700
		,height: 290
		,title:'Satelliten Betreiber verwalten'
		// property grid config
		,propcfg: {
			 title: 'Der aktuelle Satellit'
			 // width of columns in property grid
			,col0width: 110
			,col1width: 150
			// primary key of property data
			,keyIdx: 'uidx'
			// definition of data which shows up
			,datarows: [
				 { name: '1. Kennung:' ,idx: 'kn1' }
				,{ name: '2. Position:' ,idx: 'spo' }
				,{ name: '3. SatcoDX:' ,idx: 'scx' }
				,{ name: '4. Betreiber:' ,idx: 'pfrm' }
				,{ name: '5. Land:' ,idx: 'plnd' }
			]
		}
		// chooser grid config
		,choocfg: {
			 url: ktm.ASR+'/sbgpext_sel'
			,root: 'sbgpsel'
			 // primary key of chooser data
			,keyIdx: 'uidx'
			 // tooltip for use action
			,addtip: 'Betreiber festlegen'
			 // here the 'propMap' are the receiver fields of the chooser values
			 // stored under data index 'name'
			,record: [
				 { name:'uidx', type:'int', propMap:'sbpid' }
				,{ name:'frm', type:'string', propMap:'pfrm' }
				,{ name:'lnd', type:'string', propMap:'plnd' }
			]
			,columns: [
//[[
				 {header:'ID' ,dataIndex:'uidx' ,width:30 ,menuDisabled:true ,sortable:false},
//]]
				 {id:'FRM' ,header:'Betreiber' ,dataIndex:'frm' ,menuDisabled:true ,sortable:true}
				,{header:'Land' ,dataIndex:'lnd' ,width:150 ,menuDisabled:true ,sortable:true}
			]
			,autoExpandColumn: 'FRM'
			,title: 'Betreiberauswahl'
		}
	});

	sb_satflieger_act.on({
		action: function(grid, record, action, value, dataid, row, col) {
			if( action == 'actreload' ) {
				sb_satflieger_exp.reloadTable(record, row, true);
			}
			else if( action == 'actedit' ) {
				sb_satflieger_gr.getSelectionModel().select(row, col);
				sb_satflieger_win.cwShow(record, row);
			}
			else if( action == 'appform' ) {
				sb_satflieger_gr.getSelectionModel().select(row, col);
				sb_satsbprov_win.chwShow(record, row);
			}
		}
	});

///////////////////////////////////////////////////////////////////////////////
// Kabel
///////////////////////////////////////////////////////////////////////////////

	var sb_kabelknoten_exp = new Ext.grid.RowTableExpander({
		 url: ktm.ASR+'/kabpgext_tab'
		,datakey: 'uidx'
		,noData: 'Keine Kabel Programme zugeordnet!'
		,clSfx: 'satpg'
	});

	var sb_kabelknoten_act = new Ext.ux.grid.CellActions({
		align: 'left'
	});

	var sb_betreiberkt_chc = new Ext.grid.CheckColumn({
			 header: 'Betreiber KT'
			,dataIndex: 'bkt'
			// if true, the check box is disabled
			,disableIndex: 'nobkt'
			,width: 70
	});

    var sb_kabelknoten_gr = new ktm.EditorGrid({
		 url: ktm.ASR+'/kabext'
		,root: 'kab'
		,record: [
			 { name:'uidx', type:'int' }
			,{ name:'sbpid', type:'int' }
			,{ name:'nobkt', type:'bool' }
			,{ name:'pnam', type:'string' }
			,{ name:'pfrm', type:'string' }
			,{ name:'plnd', type:'string' }
			,{ name:'kn1', type:'string' }
			,{ name:'kn2', type:'string' }
			,{ name:'str', type:'string' }
			,{ name:'hnr', type:'string' }
			,{ name:'hnz', type:'string' }
			,{ name:'plz', type:'string' }
			,{ name:'ort', type:'string' }
			,{ name:'bkt', type:'bool' }
			,{ name:'pgeAct', type:'string' }
			,{ name:'pgeTip', type:'string' }
			,{ name:'dummy' }
		]
		 // the folowing fields won't be send to server on record change
		,nosend: [ 'pnam', 'pfrm', 'plnd', 'nobkt' ]
		,columns: [
			 sb_kabelknoten_exp
			,{header:'' ,sortable:false ,dataIndex:'dummy' ,width:25 ,menuDisabled:true ,cellActions:[{iconCls:'actreload' ,qtip:'ÜP Programme neu laden'}]}
//[[
			,{header:'ID' ,sortable:false ,dataIndex:'uidx' ,width:25 ,menuDisabled:true}
			,{header:'PV' ,sortable:false ,dataIndex:'sbpid' ,width:25 ,menuDisabled:true}
//]]
			,{header:'Pg' ,sortable:false ,dataIndex:'dummy' ,width:25 ,menuDisabled:true ,cellActions:[{iconIndex:'pgeAct' ,qtipIndex:'pgeTip'}]}
			,{header:'Kennung' ,dataIndex:'kn1' ,sortable:true ,width:60 ,editor:new Ext.form.TextField({allowBlank:false})}
			,{header:'PLZ' ,dataIndex:'plz' ,sortable:true ,width:40 ,menuDisabled:true ,editor:new Ext.form.TextField({allowBlank:false})}
			,{header:'Ort' ,dataIndex:'ort' ,sortable:true ,width:105 ,menuDisabled:true ,editor:new Ext.form.TextField({allowBlank:false})}
			,{header:'Strasse' ,dataIndex:'str' ,sortable:true ,width:135 ,menuDisabled:true ,editor:new Ext.form.TextField({allowBlank:false})}
			,{header:'Nr.' ,dataIndex:'hnr' ,sortable:true ,width:30 ,menuDisabled:true ,editor:new Ext.form.TextField({allowBlank:false})}
			,{header:'Zs.' ,dataIndex:'hnz' ,sortable:true ,width:30 ,menuDisabled:true ,editor:new Ext.form.TextField({allowBlank:false})}
			,sb_betreiberkt_chc
			,{header:'Signalgruppe' ,dataIndex:'pnam' ,sortable:true ,width:100 ,menuDisabled:true}
			,{header:'Betreiber Firma' ,dataIndex:'pfrm' ,sortable:true ,width:160 ,cellActions:[{iconCls:'appform' ,qtip:'Betreiber wählen'}]}
			,{header:'Betreiber Land' ,dataIndex:'plnd' ,sortable:true ,width:120 ,menuDisabled:true}
		]
		,onStoreLoad: null
		,onStoreChange: function () {
			if(sb_kabsbprov_win.rendered) {
				sb_kabsbprov_win.hide();
			}
		 }
		,onGridHide: function () {
			if(sb_kabsbprov_win.rendered) {
				sb_kabsbprov_win.hide();
			}
		 }
		,title: 'Kabel ÜP'
		,iconCls: 'tabico'
//		,autoExpandColumn: 'STR'
		,layout:'fit'
		,autoWidth: true
		,autoScroll: true
//		,width: ktm.app.sbpanWidth
//		,height: ktm.app.sbpanHeight
		,plugins: [ sb_kabelknoten_exp, sb_kabelknoten_act, sb_betreiberkt_chc ]
		,pagerLimit: 15
	}); //EO sb_kabelknoten_gr

// === Signalbezug Kabel Programme ===========================================

	var sb_kabelknoten_kan = new ktm.KanalChooser({
		 url: ktm.ASR+'/kfext_sel'
		,root: 'kfcbsel'
		,fields: ['uidx', 'kan']
		,displayField: 'kan'
		,valueField: 'uidx'
		// the idx of data in edited row to be set on select
		,valueIdx: 'kfid'
		// the idx of data type in edited row for request
		,typeIdx: 'pgtid'
	});

	var sb_kabelknoten_win = new ktm.ConnectorWin({
		 width: 700
		,height: 650
		,title:'Kabel-ÜP programme verwalten'
		 // remote grid expander to be updated
		,rmtexpander: sb_kabelknoten_exp
		// property grid config
		,propcfg: {
			 title: 'Der aktuelle Kabel-ÜP'
			 // width of columns in property grid
			,col0width: 110
			,col1width: 150
			// primary key of property data
			,keyIdx: 'uidx'
			// definition of data which shows up
			,datarows: [
				 { name: '1. Kennung:' ,idx: 'kn1' }
				,{ name: '2. PLZ:' ,idx: 'plz' }
				,{ name: '3. Ort:' ,idx: 'ort' }
				,{ name: '4. Strasse:' ,idx: 'str' }
				,{ name: '5. Hausnr:' ,idx: 'hnr' }
				,{ name: '6. Zusatz:' ,idx: 'hnz' }
				,{ name: '7. Betreiber:' ,idx: 'pfrm' }
				,{ name: '8. Betreiber Land:' ,idx: 'plnd' }
				,{ name: '9. Signalgruppe:' ,idx: 'pnam' }
			]
		}
		// chooser grid config
		,choocfg: {
			 url: ktm.ASR+'/pgext_sel'
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
//[[
				 {header:'ID' ,dataIndex:'uidx' ,width:25 ,menuDisabled:true ,sortable:false},
//]]
				 {header:'Programm' ,dataIndex:'nam' ,width:140 ,menuDisabled:true ,sortable:true}
				,{header:'Typ' ,dataIndex:'pgt' ,width:80 ,menuDisabled:true ,sortable:true}
				,{id:'GNR' ,header:'Genre' ,dataIndex:'gnr' ,menuDisabled:true ,sortable:true}
			]
			,autoExpandColumn: 'GNR'
			,title: 'Programmauswahl'
		}
		// connector grid config
		,conncfg: {
			 url: ktm.ASR+'/kabpgext'
			,root: 'kabpg'
			,height: 230
			,title: 'Die Programme von Kabel-ÜP'
			 // index of property data to add on title
			,titleIdx: 'kn1'
			 // connector's property and chooser reference
			,prkeyIdx: 'sbid'
			,chkeyIdx: 'pgid'
			 // tooltip for delete action
			,deltip: 'Programm vom Satelliten entfernen'
			,record: [
				 { name:'uidx', type:'int' }
				,{ name:'pgid', type:'int' }
				,{ name:'sbid', type:'int' }
				,{ name:'kfid', type:'int' }
				,{ name:'pgtid', type:'int' }
				,{ name:'nam', type:'string' }
				,{ name:'pgt', type:'string' }
				,{ name:'kfk', type:'string' }
			]
			,nosend: [ 'kfk' ]
			,columns: [
//[[
				 {header:'PGID' ,dataIndex:'pgid' ,width:30 ,menuDisabled:true ,sortable:false}
				,{header:'SBID' ,dataIndex:'sbid' ,width:30 ,menuDisabled:true ,sortable:false}
				,{header:'KFID' ,dataIndex:'kfid' ,width:30 ,menuDisabled:true ,sortable:false}
				,{header:'PTID' ,dataIndex:'pgtid' ,width:30 ,menuDisabled:true ,sortable:false},
//]]
				 {id:'NAM' ,header:'Programm' ,css:'background-color: #dddddd;' ,dataIndex:'nam' ,width:140 ,menuDisabled:true ,sortable:true}
				,{header:'Typ' ,css:'background-color: #dddddd;' ,dataIndex:'pgt' ,width:80 ,menuDisabled:true ,sortable:true}
				,{header:'Kanal / Freq' ,css:'background-color: #ddffdd;' ,dataIndex:'kfk' ,width:80 ,menuDisabled:true ,sortable:true ,editor:sb_kabelknoten_kan.kcCombo ,renderer:sb_kabelknoten_kan.kcRender}
			]
			,autoExpandColumn: 'NAM'
			,editor: true
		}
	});  //EO sb_kabelknoten_win

	sb_kabelknoten_win.cwConnectGrid.on('beforeedit', sb_kabelknoten_kan.kcBeforeEdit);

// === Kabel Betreiber Chooser window =======================================

	var sb_kabsbprov_win = new ktm.ChooserWin({
		 width: 700
		,height: 390
		,title:'Kabel ÜP Betreiber verwalten'
		// property grid config
		,propcfg: {
			 title: 'Der aktuelle Kabel ÜP'
			 // width of columns in property grid
			,col0width: 110
			,col1width: 150
			// primary key of property data
			,keyIdx: 'uidx'
			// definition of data which shows up
			,datarows: [
				 { name: '1. Kennung:' ,idx: 'kn1' }
				,{ name: '2. PLZ:' ,idx: 'plz' }
				,{ name: '3. Ort:' ,idx: 'ort' }
				,{ name: '4. Strasse:' ,idx: 'str' }
				,{ name: '5. Hausnr:' ,idx: 'hnr' }
				,{ name: '6. Zusatz:' ,idx: 'hnz' }
				,{ name: '7. Betreiber:' ,idx: 'pfrm' }
				,{ name: '8. Betreiber Land:' ,idx: 'plnd' }
				,{ name: '9. Signalgruppe:' ,idx: 'pnam' }
			]
		}
		// chooser grid config
		,choocfg: {
			 url: ktm.ASR+'/sbpext_sel'
			,root: 'sbpsel'
			 // primary key of chooser data
			,keyIdx: 'uidx'
			 // tooltip for use action
			,addtip: 'Kabel ÜP Betreiber festlegen'
			 // here the 'propMap' are the receiver fields of the chooser values
			 // in the related record, which are stored under the 'name' property
			,record: [
				 { name:'uidx', type:'int', propMap:'sbpid' }
				,{ name:'nam', type:'string', propMap:'pnam' }
				,{ name:'frm', type:'string', propMap:'pfrm' }
				,{ name:'lnd', type:'string', propMap:'plnd' }
			]
			,columns: [
//[[
				 {header:'ID' ,dataIndex:'uidx' ,width:30 ,menuDisabled:true ,sortable:false},
//]]
				 {id:'FRM' ,header:'Betreiber' ,dataIndex:'frm' ,menuDisabled:true ,sortable:true}
				,{header:'Land' ,dataIndex:'lnd' ,width:100 ,menuDisabled:true ,sortable:true}
				,{header:'Signalgruppe' ,dataIndex:'nam' ,width:100 ,menuDisabled:true ,sortable:true}
			]
			,autoExpandColumn: 'FRM'
			,title: 'Betreiberauswahl'
		}
	}); //EO sb_kabsbprov_win

// === Kabel Betreiber Kanal Tabelle Status Window ==========================

	var sb_sbprovkt_win = new ktm.StatusWin({
		 width: 650
		,height: 390
		,title:'Kabel ÜP Programme zeigen'
		// property grid config
		,propcfg: {
			 title: 'Der aktuelle Kabel ÜP'
			 // width of columns in property grid
			,col0width: 110
			,col1width: 150
			// definition of data which shows up
			,datarows: [
				 { name: '1. Kennung:' ,idx: 'kn1' }
				,{ name: '2. PLZ:' ,idx: 'plz' }
				,{ name: '3. Ort:' ,idx: 'ort' }
				,{ name: '4. Strasse:' ,idx: 'str' }
				,{ name: '5. Hausnr:' ,idx: 'hnr' }
				,{ name: '6. Zusatz:' ,idx: 'hnz' }
				,{ name: '7. Betreiber:' ,idx: 'pfrm' }
				,{ name: '8. Betreiber Land:' ,idx: 'plnd' }
				,{ name: '9. Signalgruppe:' ,idx: 'pnam' }
			]
		}
		// status grid config
		,statcfg: {
			 url: ktm.ASR+'/kabpvpgext'
			,root: 'kabpvpg'
			 // search key in related record for status data
			,keyIdx: 'sbpid'
			,record: [
				 { name:'uidx', type:'int' }
				,{ name:'pgid', type:'int' }
				,{ name:'sbpid', type:'int' }
				,{ name:'kfid', type:'int' }
				,{ name:'pgtid', type:'int' }
				,{ name:'nam', type:'string' }
				,{ name:'pgt', type:'string' }
				,{ name:'kfk', type:'string' }
			]
			,columns: [
//[[
				 {header:'PGID' ,dataIndex:'pgid' ,width:30 ,menuDisabled:true ,sortable:false}
				,{header:'PVID' ,dataIndex:'sbpid' ,width:30 ,menuDisabled:true ,sortable:false}
				,{header:'KFID' ,dataIndex:'kfid' ,width:30 ,menuDisabled:true ,sortable:false}
				,{header:'PTID' ,dataIndex:'pgtid' ,width:30 ,menuDisabled:true ,sortable:false},
//]]
				 {id:'NAM' ,header:'Programm' ,dataIndex:'nam' ,menuDisabled:true ,sortable:true}
				,{header:'Typ' ,dataIndex:'pgt' ,width:60 ,menuDisabled:true ,sortable:true}
				,{header:'Kanal / Freq' ,dataIndex:'kfk' ,width:80 ,menuDisabled:true ,sortable:true}
			]
			,autoExpandColumn: 'NAM'
			 // index of property data to add on title
			,titleIdx: 'kn1'
			,title: 'Kabel ÜP Programme von'
		}
	}); //EO sb_sbprovkt_win

	sb_kabelknoten_act.on({
		action: function(grid, record, action, value, dataid, row, col) {
			if( action == 'actreload' ) {
				sb_kabelknoten_exp.reloadTable(record, row, true);
			}
			else if( action == 'actedit' ) {
				sb_kabelknoten_gr.getSelectionModel().select(row, col);
				sb_kabelknoten_win.cwShow(record, row);
			}
			else if( action == 'appform' ) {
				sb_kabelknoten_gr.getSelectionModel().select(row, col);
				sb_kabsbprov_win.chwShow(record, row);
			}
			else if( action == 'actshow' ) {
				sb_kabelknoten_gr.getSelectionModel().select(row, col);
				sb_sbprovkt_win.swShow(record, row);
			}
		}
	}); //EO sb_kabelknoten_act


///////////////////////////////////////////////////////////////////////////////
// Terrestrisch
///////////////////////////////////////////////////////////////////////////////

	var sb_terrturm_exp = new Ext.grid.RowTableExpander({
		 url: ktm.ASR+'/terrpgext_tab'
		,datakey: 'uidx'
		,noData: 'Keine terrestrische Programme zugeordnet!'
		,clSfx: 'satpg'
	});

	var sb_terrturm_act = new Ext.ux.grid.CellActions({
		align: 'left'
	});

    var sb_terrturm_gr = new ktm.EditorGrid({
		 url: ktm.ASR+'/terrext'
		,root: 'terr'
		,record: [
			 { name:'uidx', type:'int' }
			,{ name:'sbpid', type:'int' }
			,{ name:'pnam', type:'string' }
			,{ name:'plnd', type:'string' }
			,{ name:'pfrm', type:'string' }
			,{ name:'kn1', type:'string' }
			,{ name:'kn2', type:'string' }
			,{ name:'dummy' }
		]
		 // the folowing fields won't be send to server on record change
		,nosend: [ 'pnam', 'pfrm', 'plnd' ]
		,columns: [
			 sb_terrturm_exp
			,{header:'' ,sortable:false ,dataIndex:'dummy' ,width:25 ,menuDisabled:true ,cellActions:[{iconCls:'actreload' ,qtip:'Terrestrische Programme neu laden'}]}
//[[
			,{header:'ID' ,sortable:false ,dataIndex:'uidx' ,width:25 ,menuDisabled:true}
			,{header:'PV' ,sortable:false ,dataIndex:'sbpid' ,width:25 ,menuDisabled:true}
//]]
			,{header:'Pg' ,sortable:false ,dataIndex:'dummy' ,width:25 ,menuDisabled:true ,cellActions:[{iconCls:'actedit' ,qtip:'Terrestrische Programme verwalten'}]}
			,{id:'KN1' ,header:'Kennung' ,dataIndex:'kn1' ,sortable:true ,editor:new Ext.form.TextField({allowBlank:false})}
			,{header:'Betreiber Land' ,dataIndex:'plnd' ,sortable:true ,width:120 ,menuDisabled:true}
			,{header:'Betreiber Firma' ,dataIndex:'pfrm' ,sortable:true ,width:160 ,cellActions:[{iconCls:'appform' ,qtip:'Betreiber wählen'}]}
		]
		,onStoreLoad: null
		,onStoreChange: function () {
			if(sb_terrsbprov_win.rendered) {
				sb_terrsbprov_win.hide();
			}
		 }
		,onGridHide: function () {
			if(sb_terrsbprov_win.rendered) {
				sb_terrsbprov_win.hide();
			}
		 }
		,title: 'Terrestrisch'
		,iconCls: 'tabico'
		,autoExpandColumn: 'KN1'
		,layout:'fit'
		,autoWidth: true
		,autoScroll: true
//		,width: ktm.app.sbpanWidth
//		,height: ktm.app.sbpanHeight
		,plugins: [ sb_terrturm_exp, sb_terrturm_act ]
		,pagerLimit: 15
	}); //EO sb_terrturm_gr

// === Terrestrische Programme =======================================================

	var sb_conn_terrcrypt_chc = new Ext.grid.CheckColumn({
			 header: 'Verschlüßelt'
			,dataIndex: 'cry'
			,width: 80
	});

	var sb_terrturm_win = new ktm.ConnectorWin({
		 width: 700
		,height: 600
		,title:'Terrestrische Programme verwalten'
		 // remote grid expander to be updated
		,rmtexpander: sb_terrturm_exp
		// property grid config
		,propcfg: {
			 title: 'Terrestrischer Sender'
			 // width of columns in property grid
			,col0width: 110
			,col1width: 150
			// primary key of property data
			,keyIdx: 'uidx'
			// definition of data which shows up
			,datarows: [
				 { name: '1. Kennung 1:' ,idx: 'kn1' }
				,{ name: '2. Kennung 2:' ,idx: 'kn2' }
				,{ name: '3. Betreiber:' ,idx: 'pfrm' }
				,{ name: '4. Betreiber Land:' ,idx: 'plnd' }
			]
		}
		// chooser grid config
		,choocfg: {
			 url: ktm.ASR+'/pgext_sel'
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
//[[
				 {header:'ID' ,dataIndex:'uidx' ,width:25 ,menuDisabled:true ,sortable:false},
//]]
				 {header:'Programm' ,dataIndex:'nam' ,width:140 ,menuDisabled:true ,sortable:true}
				,{header:'Typ' ,dataIndex:'pgt' ,width:80 ,menuDisabled:true ,sortable:true}
				,{id:'GNR' ,header:'Genre' ,dataIndex:'gnr' ,menuDisabled:true ,sortable:true}
			]
			,autoExpandColumn: 'GNR'
			,title: 'Programmauswahl'
		}
		// connector grid config
		,conncfg: {
			 url: ktm.ASR+'/terrpgext'
			,root: 'terrpg'
			,height: 230
			,title: 'Die Programme vom terrestrischen Sender'
			 // index of property data to add on title
			,titleIdx: 'kn1'
			 // connector's property and chooser reference
			,prkeyIdx: 'sbid'
			,chkeyIdx: 'pgid'
			 // tooltip for delete action
			,deltip: 'Programm vom terrestrischen Sender entfernen'
			,record: [
				 { name:'uidx', type:'int' }
				,{ name:'pgid', type:'int' }
				,{ name:'sbid', type:'int' }
				,{ name:'nam', type:'string' }
				,{ name:'pgt', type:'string' }
				,{ name:'frq', type:'string' }
				,{ name:'cry', type:'bool' }
			]
			,columns: [
//[[
				 {header:'PGID' ,dataIndex:'pgid' ,width:30 ,menuDisabled:true ,sortable:false}
				,{header:'SBID' ,dataIndex:'sbid' ,width:30 ,menuDisabled:true ,sortable:false},
//]]
				 {id:'NAM' ,header:'Programm' ,css:'background-color: #dddddd;' ,dataIndex:'nam' ,width:140 ,menuDisabled:true ,sortable:true}
				,{header:'Typ' ,css:'background-color: #dddddd;' ,dataIndex:'pgt' ,width:80 ,menuDisabled:true ,sortable:true}
				,{header:'Freq' ,dataIndex:'frq' ,width:70 ,menuDisabled:true ,sortable:true ,editor:new Ext.form.TextField({allowBlank: true})}
				,sb_conn_terrcrypt_chc
			]
			,plugins: sb_conn_terrcrypt_chc
			,autoExpandColumn: 'NAM'
			,editor: true
		}
	});

// === Terrestrisch Betreiber ======================================================

	var sb_terrsbprov_win = new ktm.ChooserWin({
		 width: 800
		,height: 350
		,title:'Terrestrische Betreiber verwalten'
		// property grid config
		,propcfg: {
			 title: 'Terrestrischer Sender'
			 // width of columns in property grid
			,col0width: 110
			,col1width: 200
			// primary key of property data
			,keyIdx: 'uidx'
			// definition of data which shows up
			,datarows: [
				 { name: '1. Kennung 1:' ,idx: 'kn1' }
				,{ name: '2. Kennung 2:' ,idx: 'kn2' }
				,{ name: '3. Betreiber:' ,idx: 'pfrm' }
				,{ name: '4. Betreiber Land:' ,idx: 'plnd' }
			]
		}
		// chooser grid config
		,choocfg: {
			 url: ktm.ASR+'/sbgpext_sel'
			,root: 'sbgpsel'
			 // primary key of chooser data
			,keyIdx: 'uidx'
			 // tooltip for use action
			,addtip: 'Betreiber festlegen'
			 // here the 'propMap' are the receiver fields of the chooser values
			 // stored under data index 'name'
			,record: [
				 { name:'uidx', type:'int', propMap:'sbpid' }
				,{ name:'lnd', type:'string', propMap:'plnd' }
				,{ name:'frm', type:'string', propMap:'pfrm' }
			]
			,columns: [
//[[
				 {header:'ID' ,dataIndex:'uidx' ,width:30 ,menuDisabled:true ,sortable:false},
//]]
				 {id:'FRM' ,header:'Firma' ,dataIndex:'frm' ,menuDisabled:true ,sortable:true}
				,{header:'Land' ,dataIndex:'lnd' ,width:150 ,menuDisabled:true ,sortable:true}
			]
			,autoExpandColumn: 'FRM'
			,title: 'Betreiberauswahl'
		}
	});

	sb_terrturm_act.on({
		action: function(grid, record, action, value, dataid, row, col) {
			if( action == 'actreload' ) {
				sb_terrturm_exp.reloadTable(record, row, true);
			}
			else if( action == 'actedit' ) {
				sb_terrturm_gr.getSelectionModel().select(row, col);
				sb_terrturm_win.cwShow(record, row);
			}
			else if( action == 'appform' ) {
				sb_terrturm_gr.getSelectionModel().select(row, col);
				sb_terrsbprov_win.chwShow(record, row);
			}
		}
	});


///////////////////////////////////////////////////////////////////////////////
// Betreiber
///////////////////////////////////////////////////////////////////////////////

// Kabel Betreiber
///////////////////////////////////////////////////////////////////////////////

	var sb_kabprov_exp = new Ext.grid.RowTableExpander({
		 url: ktm.ASR+'/kabpvpgext_tab'
		,datakey: 'uidx'
		,noData: 'Keine Kabelprogramme zugeordnet!'
		,clSfx: 'satpg'
	});

	var sb_kabprov_act = new Ext.ux.grid.CellActions({
		align: 'left'
	});

    var sb_kabprov_gr = new ktm.EditorGrid({
		 url: ktm.ASR+'/sbkpext'
		,root: 'sbkp'
		,record: [
			 { name:'uidx', type:'int' }
			,{ name:'nam', type:'string' }
			,{ name:'frm', type:'string' }
			,{ name:'ver', type:'string' }
			,{ name:'kt1', type:'string' }
			,{ name:'kt2', type:'string' }
			,{ name:'lnd', type:'string' }
			,{ name:'eml', type:'string' }
			,{ name:'www', type:'string' }
			,{ name:'dummy' }
		]
		,columns: [
			 sb_kabprov_exp
			,{header:'' ,sortable:false ,dataIndex:'dummy' ,width:25 ,menuDisabled:true ,cellActions:[{iconCls:'actreload' ,qtip:'Betreiber Programme neu laden'}]}
//[[
			,{header:'ID' ,sortable:false ,dataIndex:'uidx' ,width:30 ,menuDisabled:true}
//]]
			,{header:'Pg' ,sortable:false ,dataIndex:'dummy' ,width:25 ,menuDisabled:true ,cellActions:[{iconCls:'actedit' ,qtip:'Betreiber Programme verwalten'}]}
			,{id:'FRM' ,header:'Betreiber' ,dataIndex:'frm' ,sortable:true ,editor:new Ext.form.TextField({allowBlank:false})}
			,{header:'Signalgruppe' ,dataIndex:'nam' ,sortable:true ,width:100 ,editor:new Ext.form.TextField({allowBlank:false})}
			,{header:'Link' ,dataIndex:'www' ,sortable:true ,width:180 ,editor:new Ext.form.TextField({allowBlank:false})}
		]
		,onStoreLoad: null
		,title: 'Betreiber KT'
		,iconCls: 'tabico'
		,autoExpandColumn: 'FRM'
		,layout:'fit'
		,autoWidth: true
		,autoScroll: true
//		,height: ktm.app.sbpanHeight - 27
		,plugins: [ sb_kabprov_exp, sb_kabprov_act ]
		,pagerLimit: 15
	}); //EO sb_kabprov_gr

// === SB Provider Kabel Programme ===========================================

	var sb_kabprov_kan = new ktm.KanalChooser({
		 url: ktm.ASR+'/kfext_sel'
		,root: 'kfcbsel'
		,fields: ['uidx', 'kan']
		,displayField: 'kan'
		,valueField: 'uidx'
		,valueIdx: 'kfid'
		,typeIdx: 'pgtid'
	});

	var sb_kabprov_win = new ktm.ConnectorWin({
		 width: 700
		,height: 550
		,title:'Kabel-Betreiber Programme verwalten'
		 // remote grid expander to be updated
		,rmtexpander: sb_kabprov_exp
		// property grid config
		,propcfg: {
			 title: 'Der aktuelle Kabel-Betreiber'
			 // width of columns in property grid
			,col0width: 110
			,col1width: 150
			// primary key of property data
			,keyIdx: 'uidx'
			// definition of data which shows up
			,datarows: [
				 { name: '1. Betreiber:' ,idx: 'frm' }
				,{ name: '2. Signalgruppe:' ,idx: 'nam' }
				,{ name: '3. Link:' ,idx: 'www' }
			]
		}
		// chooser grid config
		,choocfg: {
			 url: ktm.ASR+'/pgext_sel'
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
//[[
				 {header:'ID' ,dataIndex:'uidx' ,width:25 ,menuDisabled:true ,sortable:false},
//]]
				 {header:'Programm' ,dataIndex:'nam' ,width:140 ,menuDisabled:true ,sortable:true}
				,{header:'Typ' ,dataIndex:'pgt' ,width:80 ,menuDisabled:true ,sortable:true}
				,{id:'GNR' ,header:'Genre' ,dataIndex:'gnr' ,menuDisabled:true ,sortable:true}
			]
			,autoExpandColumn: 'GNR'
			,title: 'Programmauswahl'
		}
		// connector grid config
		,conncfg: {
			 url: ktm.ASR+'/kabpvpgext'
			,root: 'kabpvpg'
			,height: 230
			,title: 'Die Programme von Kabel-Betreiber'
			 // index of property data to add on title
			,titleIdx: 'nam'
			 // connector's property and chooser reference
			,prkeyIdx: 'sbpid'
			,chkeyIdx: 'pgid'
			 // tooltip for delete action
			,deltip: 'Programm vom Kabel-Betreiber entfernen'
			,record: [
				 { name:'uidx', type:'int' }
				,{ name:'pgid', type:'int' }
				,{ name:'sbpid', type:'int' }
				,{ name:'kfid', type:'int' }
				,{ name:'pgtid', type:'int' }
				,{ name:'nam', type:'string' }
				,{ name:'pgt', type:'string' }
				,{ name:'kfk', type:'string' }
			]
			,nosend: [ 'kfk' ]
			,columns: [
//[[
				 {header:'PGID' ,dataIndex:'pgid' ,width:30 ,menuDisabled:true ,sortable:false}
				,{header:'PVID' ,dataIndex:'sbpid' ,width:30 ,menuDisabled:true ,sortable:false}
				,{header:'KFID' ,dataIndex:'kfid' ,width:30 ,menuDisabled:true ,sortable:false}
				,{header:'PTID' ,dataIndex:'pgtid' ,width:30 ,menuDisabled:true ,sortable:false},
//]]
				 {id:'NAM' ,header:'Programm' ,css:'background-color: #dddddd;' ,dataIndex:'nam' ,width:140 ,menuDisabled:true ,sortable:true}
				,{header:'Typ' ,css:'background-color: #dddddd;' ,dataIndex:'pgt' ,width:80 ,menuDisabled:true ,sortable:true}
				,{header:'Kanal / Freq' ,css:'background-color: #ffffdd;' ,dataIndex:'kfk' ,width:80 ,menuDisabled:true ,sortable:true ,editor:sb_kabprov_kan.kcCombo ,renderer:sb_kabprov_kan.kcRender}
			]
			,autoExpandColumn: 'NAM'
			,editor: true
		}
	});  //EO sb_kabprov_win

	sb_kabprov_win.cwConnectGrid.on('beforeedit', sb_kabprov_kan.kcBeforeEdit);

	sb_kabprov_act.on({
		action: function(grid, record, action, value, dataid, row, col) {
			if( action == 'actreload' ) {
				sb_kabprov_exp.reloadTable(record, row, true);
			}
			else if( action == 'actedit' ) {
				sb_kabprov_win.cwShow(record, row);
				sb_kabprov_gr.getSelectionModel().select(row, col);
			}
		}
	});

// Allgemein Betreiber
///////////////////////////////////////////////////////////////////////////////

    var sb_genprov_gr = new ktm.EditorGrid({
		 url: ktm.ASR+'/sbgpext'
		,root: 'sbgp'
		,record: [
			 { name:'uidx', type:'int' }
			,{ name:'nam', type:'string' }
			,{ name:'frm', type:'string' }
			,{ name:'ver', type:'string' }
			,{ name:'kt1', type:'string' }
			,{ name:'kt2', type:'string' }
			,{ name:'lnd', type:'string' }
			,{ name:'eml', type:'string' }
			,{ name:'www', type:'string' }
		]
		,columns: [
//[[
			 {header:'ID' ,sortable:false ,dataIndex:'uidx' ,width:30 ,menuDisabled:true},
//]]
			 {id:'FRM' ,header:'Betreiber' ,dataIndex:'frm' ,sortable:true ,editor:new Ext.form.TextField({allowBlank:false})}
			,{header:'Land' ,dataIndex:'lnd' ,sortable:true ,width:120 ,editor:new Ext.form.TextField({allowBlank:false})}
			,{header:'Link' ,dataIndex:'www' ,sortable:true ,width:180 ,editor:new Ext.form.TextField({allowBlank:false})}
		]
		,onStoreLoad: null
		,title: 'Betreiber'
		,iconCls: 'tabico'
		,autoExpandColumn: 'FRM'
		,layout:'fit'
		,autoWidth: true
		,autoScroll: true
//		,height: ktm.app.sbpanHeight - 27
		,pagerLimit: 15
	}); //EO sb_genprov_gr

///////////////////////////////////////////////////////////////////////////////
// TabPanel for all the stuff
///////////////////////////////////////////////////////////////////////////////
/*
	var sb_main_tabs = new Ext.TabPanel({
		 renderTo:'tabpanel-sb'
		,border: true
		,resizeTabs:true
		,tabWidth:135
		,layoutOnTabChange: true
		// ensures that we can see other tabs too
		,deferredRender: false
		,width: ktm.app.sbpanWidth
		,autoHeight: true
		,defaults: {
			 autoScroll:false
			 // hideMode: "offsets" fixes disapearing of the cursor
			,hideMode:"offsets"
		}
	});
	var sb_provider_tabs = new Ext.TabPanel({
		 title: "Betreiber"
		,border: false
		,resizeTabs:true
		,tabWidth:100
		,layoutOnTabChange: true
		// ensures that we can see other tabs too
		,deferredRender: false
		,autoWidth: true
		,height: ktm.app.sbpanHeight
		,defaults: {
			 autoScroll:false
			 // hideMode: "offsets" fixes disapearing of the cursor
			,hideMode:"offsets"
		}
	});

	sb_provider_tabs.add( sb_kabprov_gr );
	sb_provider_tabs.add( sb_genprov_gr );

	sb_provider_tabs.activate( sb_kabprov_gr );

	sb_main_tabs.add( sb_satflieger_gr );
	sb_main_tabs.add( sb_kabelknoten_gr );
	sb_main_tabs.add( sb_terrturm_gr );
	sb_main_tabs.add( sb_provider_tabs );

	sb_main_tabs.doLayout();

	sb_main_tabs.activate( sb_satflieger_gr );
*/
	return {
		 tab1:sb_satflieger_gr
		,tab2:sb_kabelknoten_gr
		,tab3:sb_terrturm_gr
		,tab4a:sb_kabprov_gr
		,tab4b:sb_genprov_gr
	}

//Ext.ux.Toast.msg('Event: action', 'Failure ROW: <b>{0}</b>, ACTION: <b>{1}</b>', row, action);

};
