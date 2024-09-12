// vim: ts=4:sw=4:nu:fdc=1:nospell

Ext.namespace('ktm');

ktm.SQstart = function() {

/*
	Ext.state.Manager.setProvider(
		new Ext.state.SessionProvider({state: Ext.appState}));
*/

// ================================================================

	var sqinfoHeight = 60;
	var sqinfo = new Ext.Panel({
		 html: ktm.app.sqchoose
		,width: ktm.app.sqpanWidth 
		,height: sqinfoHeight
	});

// ================================================================

// ---- POST ----

	function cr_sqdbsucc(r) {
		var response = Ext.util.JSON.decode(r.responseText);
		sqnatt.id = response.uidx;
		var newatts = new sqAttr(sqnatt);
		var newnode = new Ext.tree.TreeNode(newatts);
		sqtext(newnode);
		// DANGEROUS! LOCK CURRENT SOMEHOW!
		currnode.insertBefore(newnode, currnode.firstChild);
		// this is if we want to select brand new node
//		sqtree.getSelectionModel().select(newnode);
//		ninfo(newnode);
//		currnode = newnode;
		sqtb_disabled(false);
	}

	function u_sqdbsucc(r) {
		var response = Ext.util.JSON.decode(r.responseText);
		//DANGEROUS! LOCK CHANGENODE SOMEHOW!
		sqcopyatts(changenode.attributes);
		sqtext(changenode);
	}

	function sqtpost(nid) {
		sqnatt.text='';
		sqnatt.id = '';
        Ext.Ajax.request({
			 method: 'POST'
			,url:'/sqkext/'+nid
			,headers:{'Content-Type': 'text/x-json'}
			,success: (nid ? u_sqdbsucc : cr_sqdbsucc)
			,jsonData: sqnatt
        });
	}

	function sqtpost_new() {
		sqtpost(0);
	};

// ---- DELETE ----

	function d_sqdbsucc(r) {
		var response = Ext.util.JSON.decode(r.responseText);
		//DANGEROUS! LOCK CURRNODE SOMEHOW!
		currnode.remove();
		currnode = sqroot;
		sqtb_disabled(true);
		sqinfo.body.update(ktm.app.sqchoose);
	}

	function sqtdel(id) {
		sqnatt.text='';
		sqnatt.id = '';
        Ext.Ajax.request({
			 method: 'DELETE'
            ,url:'/sqkext/'+id
			,headers:{'Content-Type': 'text/x-json'}
			,success: d_sqdbsucc
        });
	}

// ---- GET ----

	var sqtloader = new Ext.tree.TreeLoader({
		 dataUrl:'/sqkext/unresty'
		,requestMethod:'GET'
	});

	// don't use 'unresty' anymore, with this "hack" we've got real RESTy url
	// (though Ext still attaches url node parameter which we don't need anymore)
	sqtloader.on('beforeload', function(me, node, cb) {
		me.dataUrl = '/sqkext/'+node.id
		return true;
	});

/*
stl => $sq->tlv,		ssw => $sq->sumwe,		sws => $sq->wesoll,
snd => $sq->netzid,		stp => $sq->sq_type,	sdo => $sq->dataorigin,

sst => $sq->strasse,	shn => $sq->hausnr,		shz => $sq->hausnrzus,
spl => $sq->plz,		sor => $sq->ort,		sld => $sq->land,
srg => $sq->region,

cfr => $co->firma,		ckn => $co->kontakt,	ctl => $co->telefon,
cfx => $co->fax,		cem => $co->email,

cst => $co->strasse		chn => $co->hausnr.		chz => $co->hausnrzus,
cpl => $co->plz,		cor => $co->ort
*/

	// 'nvl' represents numeric non-value, where zero '0' is still value

	var sqnatt = {
		// signalquelle data
		 stl:'nvl'
		,ssw:'0'
		,sws:'0'
		,snd:''
		,stp:'nvl'
		,sdo:''
		,sst:''
		,shn:''
		,shz:''
		,spl:''
		,sor:''
		,sld:'1'
		,srg:'1'
		// contact office data
		,cfr:''
		,ckn:''
		,ctl:''
		,cfx:''
		,cem:''
		,cst:''
		,chn:''
		,chz:''
		,cpl:''
		,cor:''
		// cursor node id
		,sqcid:'nvl'
		//parrent node id
		,sqpid:'nvl'
		// relative position of the new node
		,ulv:'1'
		// new node configuration:
		,id:'nvl'
//		,cls:'sq-node'
	};

	function sqAttr(atts) {
		this.stl = atts.stl;
		this.ssw = atts.ssw;
		this.sws = atts.sws;
		this.snd = atts.snd;
		this.stp = atts.stp;
		this.sdo = atts.sdo;
		this.sst = atts.sst;
		this.shn = atts.shn;
		this.shz = atts.shz;
		this.spl = atts.spl;
		this.sor = atts.sor;
		this.sld = atts.sld;
		this.srg = atts.srg;
		this.cfr = atts.cfr;
		this.ckn = atts.ckn;
		this.ctl = atts.ctl;
		this.cfx = atts.cfx;
		this.cem = atts.cem;
		this.cst = atts.cst;
		this.chn = atts.chn;
		this.chz = atts.chz;
		this.cpl = atts.cpl;
		this.cor = atts.cor;
		this.sqcid = atts.sqcid;
		this.sqpid = atts.sqpid;
		this.ulv = atts.ulv;
		this.id = atts.id;
	};

//	sq_type_st.load();

	function sqtext(node) {
		var id = node.id;
		var na = node.attributes;
		var sqt = ktm.app.sqsqtype_st.data.items[na.stp-1].data.abb
		var text = '['
		text = '[NId:'+na.snd+'] '+text;
		text = '['+sqt+'] '+text;
		text = '[ID:'+node.id+'] '+text;
		text = text+na.sst+' '+na.shn;
		if(na.shz) { text = text+' ('+na.shz+')'; }
		text = text+', '+na.spl+' '+na.sor;
		text = text+']';
		node.setText(text);
	}

	sqtloader.on('load', function(treeLoader, node) {
		if(node.id == 0) { node.setText('Signalquellen - Gesamtnetz Infrastruktur'); };
		node.eachChild(sqtext);
	});

	// Combobox for TYPE of SIGNALQUELLE
    var sqtyp_cb = new Ext.form.ComboBox({
		 store: ktm.app.sqsqtype_st
		,hideLabel: true
        ,displayField:'ds1'
		,valueField:'val'
		,editable: false
//		,typeAhead: false
        ,mode: 'local'
        ,triggerAction: 'all'
        ,emptyText: 'Wähle aus...'
//		,selectOnFocus: true
        ,width: 90
    });

	sqtyp_cb.on('select', function(cb, rec, idx) {
//		Ext.MessageBox.alert('Status', 'Value: '+rec.data.abb+' idx: '+val);
		sqnatt.stp = rec.data.val;
	});

	// Combobox for the BUNDESLAND of Signalquelle
    var sqland_cb = new Ext.form.ComboBox({
		 store: ktm.app.sqdeland_st
		,hideLabel: true
        ,displayField:'ds1'
		,valueField:'val'
		,editable: false
//		,typeAhead: true
        ,mode: 'local'
        ,triggerAction: 'all'
        ,emptyText: 'Wähle aus...'
//		,selectOnFocus: true
        ,width: 200
    });

	sqland_cb.on('select', function(cb, rec, idx) {
		sqnatt.sld = rec.data.val;
	});


	// Combobox for the REGION of Signalquelle
    var sqreg_cb = new Ext.form.ComboBox({
		 store: ktm.app.sqdereg_st
		,hideLabel: true
        ,displayField:'ds1'
		,valueField:'val'
		,editable: false
//		,typeAhead: true
        ,mode: 'local'
        ,triggerAction: 'all'
        ,emptyText: 'Wähle aus...'
//		,selectOnFocus: true
		,width: 120
    });

	sqreg_cb.on('select', function(cb, rec, idx) {
		sqnatt.srg = rec.data.val;
	});

	// LOCATION formpanel
	var sq_sqmain_frm = new Ext.form.FormPanel({
		 title: "Hauptdaten"
		,layout: 'table'
		,border: false
		,labelWidth: 50
		,layoutConfig: {
			columns: 4
		}
		,defaults: {
			cls: 'sq-x-fset'
		}
		,items:[
			 {xtype:'fieldset' ,title:'Signalquellen Typ' ,height: 60 ,items:[sqtyp_cb]}
			,{xtype:'fieldset' ,title:'Region' ,height: 60 ,items:[sqreg_cb]}
			,{xtype:'fieldset' ,title:'Bundesland' ,colspan:2 ,height:60 ,items:[sqland_cb]}
			,{xtype:'fieldset' ,title:'Standort' ,colspan:2 ,defaultType:'textfield' ,autoHeight:true ,autoWidth:true ,items:[
				 {fieldLabel:'Strasse' ,width:200}
				,{fieldLabel:'Hausnr' ,width:200}
				,{fieldLabel:'Zusatz' ,width:200}
				,{fieldLabel:'PLZ' ,width:200}
				,{fieldLabel:'Ort' ,width:200}
			 ]}
			,{xtype:'fieldset' ,colspan:2 ,title:'Merkmale' ,defaultType:'textfield' ,autoHeight:true ,autoWidth:true ,labelWidth:115 ,items:[
				 {fieldLabel:'Netz ID' ,width:150}
				,{fieldLabel:'WE' ,width:150}
				,{fieldLabel:'Soll WE' ,width:150}
				,{fieldLabel:'Datenquelle' ,width:150}
				,{fieldLabel:'Reserviert' ,disabled:true ,width:150}
			 ]}
		]
	});

	function sqcopyform(atts) {
		var standort = sq_sqmain_frm.items.items[3].items.items;
		var merkmale = sq_sqmain_frm.items.items[4].items.items;

		//type
		if (atts.stp == 'nvl') {
			sqtyp_cb.clearValue();
		} else {
			sqtyp_cb.setValue(atts.stp);
		}

		//land
		if (atts.sld == '1') {
			sqland_cb.clearValue();
		} else {
			sqland_cb.setValue(atts.sld);
		}

		//region
		if (atts.srg == '1') {
			sqreg_cb.clearValue();
		} else {
			sqreg_cb.setValue(atts.srg);
		}

		//strasse
		standort[0].setRawValue(atts.sst);
		//hausnr
		standort[1].setRawValue(atts.shn);
		//hausnrzusatz
		standort[2].setRawValue(atts.shz);
		//plz
		standort[3].setRawValue(atts.spl);
		//ort
		standort[4].setRawValue(atts.sor);

		//netz-id
		merkmale[0].setRawValue(atts.snd);
		//wohneinheiten
		merkmale[1].setRawValue(atts.ssw);
		//wohneinheiten soll
		merkmale[2].setRawValue(atts.sws);
		//datenquelle
		merkmale[3].setRawValue(atts.sdo);
	};

	function sqcopyattatt(satts, atts) {
		//type
		atts.stp = satts.stp;
		//land
		atts.sld = satts.sld;
		//region
		atts.srg = satts.srg;

		//strasse
		atts.sst = satts.sst;
		//hausnr
		atts.shn = satts.shn;
		//hausnrzustz
		atts.shz = satts.shz;
		//plz
		atts.spl = satts.spl;
		//ort
		atts.sor = satts.sor;
                 
		//netz-id
		atts.snd = satts.snd;
		//wohneinheiten
		atts.ssw = satts.ssw;
		//wohneinheiten soll
		atts.sws = satts.sws;
		//datenquelle
		atts.sdo = satts.sdo;
	};

	function sqcopyatts(atts) {
		var standort = sq_sqmain_frm.items.items[3].items.items;
		var merkmale = sq_sqmain_frm.items.items[4].items.items;

		var stp = sqtyp_cb.getValue();
		var sld = sqland_cb.getValue();
		var srg = sqreg_cb.getValue();

		//type
		atts.stp = (stp == '' ? 'nvl' : stp);
		//land
		atts.sld = (sld == '' ? '1' : sld);
		//region
		atts.srg = (srg == '' ? '1' : srg);

		//strasse
		atts.sst = standort[0].getValue();
		//hausnr
		atts.shn = standort[1].getValue();
		//hausnrzusatz
		atts.shz = standort[2].getValue();
		//plz
		atts.spl = standort[3].getValue();
		//ort
		atts.sor = standort[4].getValue();
                 
		//netz-id
		atts.snd = merkmale[0].getValue();
		//wohneinheiten
		atts.ssw = merkmale[1].getValue();
		//wohneinheiten soll
		atts.sws = merkmale[2].getValue();
		//datenquelle
		atts.sdo = merkmale[3].getValue();
	};

	function sqzerosqnatt() {
		//land
		sqnatt.sld = '1';
		//region
		sqnatt.srg = '1';

		//strasse
		sqnatt.sst = '';
		//hausnr
		sqnatt.shn = '';
		//hausnrzusatz
		sqnatt.shz = '';
		//plz
		sqnatt.spl = '';
		//ort
		sqnatt.sor = '';

		//netz-id
		sqnatt.snd = '';
		//wohneinheiten
		sqnatt.ssw = '0';
		//wohneinheiten soll
		sqnatt.sws = '0';
		//datenquelle
		sqnatt.sdo = '';
	};

	var sqwinHeight = 320;
	var sqwinWidth = 650;

	var sq_sqwin_tabs = new Ext.TabPanel({
		 layoutOnTabChange: false
		,border: false
		,resizeTabs: true
		// ensures that we can see other tabs too
		,deferredRender: false
//		,autoWidth: true
		,width: sqwinWidth
//		,autoHeight: true
		,height: sqwinHeight
		,defaults: {
			 autoScroll: false
			,labelWidth: 70
			,bodyStyle:'padding:10px; background-color: #ffdfdf;'
			 // hideMode: "offsets" fixes disapearing of the cursor
			,hideMode:"offsets"
		}
	});

	sq_sqwin_tabs.add( sq_sqmain_frm );
	sq_sqwin_tabs.activate( sq_sqmain_frm );

//	sq_sqwin_tabs.doLayout();

	// the window is used for both add and change
    var sq_sqdata_win = new Ext.Window({
         id: 'sq_sqdata_win'
		,width: sqwinWidth
        ,height: sqwinHeight + 70
        ,border: false
        ,plain: false
        ,closable: false
        ,collapsible: true
        ,title:''
		,items: [ sq_sqwin_tabs ]
		,buttons: [{
			 text:'Speichern'
			,handler: function() {
				sqcopyatts(sqnatt);
				//this means it's a new one
				if ( ! sqtyp_cb.disabled ) {
					if( sqnatt.stp == 'nvl' ) {
						Ext.MessageBox.alert('Status',
							'Signalquellen Typ muss definiert sein.');
						return;
					}
					currnode.expand(false, true, sqtpost_new);
				} else {
					sqtpost(changenode.id); 
				}
			}
		},{
			 text:'Zurücksetzen'
			,handler: function() {
				//this bloody sqtyp_cb needs real care...
				sqnatt.stp = (sqtyp_cb.disabled ? sqtyp_cb.getValue() : 'nvl');
				sqzerosqnatt();
				sqcopyform(sqnatt);
			}
		},{
			 text:'Schließen'
			,handler: function() {
				//keep textfield changes
				sqcopyatts(sqnatt);
				sq_sqdata_win.hide();
			}
		}]
    });

// --- The Definitions of TopToolbar -----------------------------------------

	var sqtb_sbezug = new Ext.Toolbar.Button({
		 text: 'Signalbezug'
		,iconCls:'icon-tvadd'
		,tooltip: 'Signalbezug verwalten'
		,disabled: false
		,handler: function () {
		}
	});

	var sqtb_filter = new Ext.Toolbar.Button({
		 text: 'Filter'
		,iconCls:'icon-tvdel'
		,tooltip: 'Filter verwalten'
		,disabled: false
		,handler: function () {
		}
	});

// ------------------------------------------------

	var sqtb_new = new Ext.Toolbar.Button({
		 text: 'Einfügen'
		,iconCls:'icon-app-add'
		,tooltip: 'Neue Signalquelle'
		,disabled: false
		,handler: function () {
			sq_sqdata_win.setTitle('Neue Signalquelle einfügen');
			sqtyp_cb.setDisabled(false);
			sq_sqdata_win.show();
			sqcopyform(sqnatt);
		}
	});

	var sqtb_update = new Ext.Toolbar.Button({
		 text: 'Ändern'
		,iconCls: 'icon-app-edit'
		,tooltip: 'Signalquelle-Daten ändern'
		,disabled: true
		,handler: function () {
			sq_sqdata_win.setTitle('Signalquelle-Datensatz ändern');
			sqtyp_cb.setDisabled(true);
			sq_sqdata_win.show();
			changenode = currnode;
			sqcopyform(changenode.attributes);
//			console.log(currnode);
		}
	});

	var sqtb_delete = new Ext.Toolbar.Button({
		 text: 'Löschen'
		,iconCls: 'icon-app-del'
		,tooltip: 'Signalquelle löschen'
		,disabled: true
		,handler: function () {
			sqtdel(currnode.id);
//			console.log(currnode);
		}
	});

	function sqtb_disabled(d, is_new) {
//		sqtb_new.setDisabled(d);
		sqtb_update.setDisabled(d);
//		sqtb_edit.setDisabled(d);
		sqtb_delete.setDisabled(d);
	}

	function ninfo(node) {
		var id = node.id;
		var pid = (node.parentNode ? node.parentNode.id : 'NULL');
		var ns = (node.nextSibling ? node.nextSibling.id : 'NULL');
		var ps = (node.previousSibling ? node.previousSibling.id : 'NULL');
		sqinfo.body.update('<p>ID:['+id+'] --- PID:['+pid+'] --- NextSib:['+ns+'] --- PrevSib:['+ps+']');
	}

	var sqtree = new Ext.tree.TreePanel({
//		 el: 'tree-sq'
		 loader: sqtloader
		,width: ktm.app.sqpanWidth
		,height: (ktm.app.sqpanHeight - sqinfoHeight - 3)
		,rootVisible: true
		,autoScroll: true
		,enableDD: false
        ,animate: false
		,border: false
//		,frame: true
//		,containerScroll: true
//		,title: 'Signalquellen'
		,maskDisabled: true
        ,tbar:[
			 sqtb_sbezug
			,sqtb_filter
			,'->'
			,sqtb_new, '-'
			,sqtb_update, '-'
			,sqtb_delete, '-'
		, {
			 text:'Maske'
			,iconCls:'icon-app-mask'
			,tooltip:'Parameter für die Anzeige setzen'
		}]
/*
		,bbar: new Ext.PagingToolbar({
			 pageSize: 25
			,store: store
			,beforePageText: 'Seite '
			,afterPageText: " von {0}"
			,displayInfo: true
			,displayMsg: '{0}-{1} von {2}'
			,emptyMsg: "Keine Daten"
		})
*/
	});

    // set the root node
    var sqroot = new Ext.tree.AsyncTreeNode({
		 text: 'Signalquellen Gesamtnetz'
		,draggable: false
		,id: '0'
		,cls: 'sq-node'
	});

// --- This holds the current TreeNode pointed with cursor ---------------------------
	var currnode = sqroot;
	var changenode = null;
// -----------------------------------------------------------------------------------

    sqtree.setRootNode(sqroot);

	sqtree.on('click', function(node){
		if(node.id != '0') {
			if(currnode.id == '0') {
				sqtb_disabled(false);
			}
		}
		else if(node.id == '0') {
//			sqinfo.body.update(ktm.app.sqchoose);
			if(currnode.id != '0') {
				sqtb_disabled(true);
			}
		}
		ninfo(node);
		// for generation of the new nodes
		sqnatt.sqcid = node.id;
		sqnatt.sqpid = (node.parentNode ? node.parentNode.id : 0);
		currnode = node;
    });

// ///////////////////////////////////////////////////////////////////////// //
/* ******* SIGNALQUELLEN END *********************************************** */
// ///////////////////////////////////////////////////////////////////////// //

	var sqtabs = new Ext.TabPanel({
		 renderTo:'tabpanel-sq'
		,layoutOnTabChange: true
		,border: true
		,resizeTabs: true
		,minTabWidth: 115
		,tabWidth: 135
		// ensures that we can see other tabs too
		,deferredRender: false
//		,autoWidth: true
		,width: ktm.app.sqpanWidth
		,autoHeight: true
		,defaults: {
			 autoScroll:false
			,labelWidth: 70
			 // hideMode: "offsets" fixes disapearing of the cursor
			,hideMode:"offsets"
		}
	});

	sqtabs.add({
		 id: 'sq_sigquell_tp'
		,title: 'Signalquellen'
		,iconCls: 'pgtabs'
//		,height: ktm.app.sqpanHeight
		,items: [ sqtree, sqinfo ]
	});

/*
	sqtabs.add({
		 title: 'Technikdienst'
		,iconCls: 'pgtabs'
		,labelWidth: 60
	});

	sqtabs.add({
		 title: 'Signalbezug'
		,iconCls: 'pgtabs'
		,labelWidth: 60
	});
*/

	sqtabs.doLayout();
	sqtabs.activate('sq_sigquell_tp');

	sqroot.expand();

////////////////////////////////////////////////////////////////////////////////

};
