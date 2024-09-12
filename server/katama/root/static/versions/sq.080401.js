Ext.onReady(function() {
	Ext.QuickTips.init();

/*
	Ext.state.Manager.setProvider(
		new Ext.state.SessionProvider({state: Ext.appState}));
*/

	var Tree = Ext.tree;
	var Data = Ext.data;

	// create the Data Store
	var store = new Data.Store({

		// load using script tags for cross domain, if the data in on the same domain as
		// this page, an HttpProxy would be better
		proxy: new Data.ScriptTagProxy({
			url: 'http://extjs.com/forum/topics-browse-remote.php'
		})

		// create reader that reads the Topic records
		,reader: new Data.JsonReader({
			root: 'topics'
			,totalProperty: 'totalCount'
			,id: 'threadid'
			,fields: [
				'title', 'forumtitle', 'forumid', 'author'
				,{name: 'replycount', type: 'int'}
				,{name: 'lastpost', mapping: 'lastpost', type: 'date', dateFormat: 'timestamp'}
				,'lastposter', 'excerpt'
			]
		})

		// turn on remote sorting
		,remoteSort: true
	});

	store.setDefaultSort('lastpost', 'desc');

// ================================================================

	var treepan_w = 480;

	var sqinfo = new Ext.Panel({
		 renderTo: 'info-sq'
		,width: treepan_w
		,height: 55
		,html: ktm.app.sqchoose_t
	});

	function sqdbsuccess(r) {
		var response = Ext.util.JSON.decode(r.responseText);
		sqnatt.id = response.uidx;
		var newnode = new Ext.tree.TreeNode(sqnatt);
		sqtext(newnode);
		if(newnode.attributes.ulv == '0') {
			if(currnode == root) {
				root.insertBefore(newnode, root.firstChild);
			} else {
				currnode.parentNode.insertBefore(newnode, currnode.nextSibling);
			}
		} else {
//			currnode.expand();
			currnode.insertBefore(newnode, currnode.firstChild);
		}
		sqtree.getSelectionModel().select(newnode);
		ninfo(newnode);
		currnode = newnode;
		sqtb_disabled(false);
	}

    function sqtsend(cnode) {
		// this is from previous node, clean away
		sqnatt.text='';
		sqnatt.id='';
		// request data for the prime time expanding node
        Ext.Ajax.request({
			 method:'PUT'
            ,url:'/sqkext'
			,headers:{'Content-Type': 'text/x-json'}
            ,success: sqdbsuccess
            ,jsonData: sqnatt
        });
    }

	var sqtloader = new Tree.TreeLoader({
		 dataUrl:'/sqkext'
		,requestMethod:'GET'
//		,uiProviders:{
//			'col': Tree.ColumnNodeUI
//		}
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
		// new node init data attributes:
		stl:'nvl',ssw:'nvl',sws:'nvl',snd:'',stp:'nvl',sdo:'',
		sst:'',shn:'',shz:'',spl:'',sor:'',sld:'nvl', srg:'nvl',
		cfr:'',ckn:'',ctl:'',cfx:'',cem:'',
		cst:'',chn:'',chz:'',cpl:'', cor:'',
		// cursor node id, its parrent node id and the relative position of the new node
		sqcid:'nvl',sqpid:'nvl',ulv:'nvl',
		// new node configuration:
		id:'nvl'
//		,cls:'sq-node'
	};

	function sqtext(node) {
		var id = node.id;
		var na = node.attributes;
		var text = '['
		text = '[NId:'+na.snd+'] '+text;
		text = '['+ktm.app.sqtypes[na.stp][0]+'] '+text;
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

	var sqtree = new Tree.TreePanel({
		 el: 'tree-sq'
		,width: treepan_w
		,height: 270
//		,autoHeight: true
		,rootVisible: true
		,autoScroll: true
		,enableDD: false
        ,animate:true
//		,frame: true
//		,containerScroll: true
//		,title: 'Signalquellen'
		,maskDisabled: true
        ,tbar:[ ]
		,bbar: new Ext.PagingToolbar({
			 pageSize: 25
			,store: store
			,beforePageText: 'Seite '
			,afterPageText: " von {0}"
			,displayInfo: true
			,displayMsg: '{0}-{1} von {2}'
			,emptyMsg: "Keine Daten"
		})
		,loader: sqtloader
	});

    // set the root node
    var root = new Tree.AsyncTreeNode({
         text: 'Signalquellen Gesamtnetz'
        ,draggable: false
        ,id: '0'
		,cls: 'sq-node'
    });
/*
	function toggleDetails(btn, pressed){
		var view = sqtree.getView();
		view.showPreview = pressed;
		view.refresh();
    }
*/
    sqtree.setRootNode(root);

    // render the sqtree
    sqtree.render();
    root.expand();

	// Combobox for TYPE of SIGNALQUELLE
    var sqtyp_cb = new Ext.form.ComboBox({
		 store: new Ext.data.SimpleStore({
			 fields: ['abbr', 'display']
			,data: ktm.app.sqtypes
		 })
		,hideLabel: true
        ,displayField:'display'
		,valueField:'abbr'
		,editable: false
//		,typeAhead: false
        ,mode: 'local'
        ,triggerAction: 'all'
        ,emptyText: 'Wähle aus...'
//		,selectOnFocus: true
        ,width: 110
    });

	sqtyp_cb.on('select', function(cb, rec, idx) {
//		Ext.MessageBox.alert('Status', 'Value: '+rec.data.abbr+' idx: '+idx);
//		console.log(rec);
		sqnatt.stp = idx;
	});

	// Combobox for the LEVEL of Signalquelle
    var sqlev_cb = new Ext.form.ComboBox({
		 store: new Ext.data.SimpleStore({
			 fields: ['abbr', 'display']
			,data: ktm.app.sqlevels
		 })
		,hideLabel: true
        ,displayField:'display'
		,valueField:'abbr'
		,editable: false
//		,typeAhead: true
        ,mode: 'local'
        ,triggerAction: 'all'
        ,emptyText: 'Wähle aus...'
//		,selectOnFocus: true
        ,width: 110
    });

	sqlev_cb.on('select', function(cb, rec, idx) {
		sqnatt.ulv = idx;
//		Ext.MessageBox.alert('Status', 'sqnatt.ulv == '+sqnatt.ulv);
	});

	// LOCATION formpanel
	var tp_sqform = {
		 title: "Hauptdaten"
		,layout:'table'
		,frame: true
		,labelWidth: 65
		,layoutConfig: {
			columns: 4
		}
		// in ext-all.css x-fieldset changed to margin:5px !!!
		// ===================================================
		,items:[{
			 xtype:'fieldset'
			,title:'Einordnen'
			,height: 60
			,items:[ sqlev_cb ]
		},{
			 xtype:'fieldset'
			,title:'Signalquellen Typ'
			,height: 60
			,items:[ sqtyp_cb ]
		},{
			 xtype:'fieldset'
			,title:'Region'
			,height: 60
			,items:[{
			}]
		},{
			 xtype:'fieldset'
			,title:'Land'
			,height: 60
			,items:[{
				width: 150
			}]
		},{
			 xtype:'fieldset'
			,colspan: 2
			,title:'Standort'
			,defaultType:'textfield'
			,autoHeight:true
			,autoWidth:true
			,items:[{
				fieldLabel:'Strasse'
				,validator:function(v) { sqnatt.sst = v; return true; }
				,width: 200
			},{
				fieldLabel:'Hausnr'
				,validator:function(v) { sqnatt.shn = v; return true; }
				,width: 200
			},{
				fieldLabel:'Zusatz'
				,validator:function(v) { sqnatt.shz = v; return true; }
				,width: 200
			},{
				fieldLabel:'PLZ'
				,validator:function(v) { sqnatt.spl = v; return true; }
				,width: 200
			},{
				fieldLabel:'Ort'
				,validator:function(v) { sqnatt.sor = v; return true; }
				,width: 200
			}]
		},{
			 xtype:'fieldset'
			,colspan: 2
			,title:'Merkmale'
			,defaultType:'textfield'
			,autoHeight:true
			,autoWidth:true
			,labelWidth: 115
			,items:[{
				fieldLabel:'Netz ID'
				,validator:function(v) { sqnatt.snd = v; return true; }
				,width: 150
			},{
				fieldLabel:'Wohneinheiten'
				,validator:function(v) { sqnatt.ssw = v; return true; }
				,width: 150
			},{
				fieldLabel:'Soll Wohneinheiten'
				,validator:function(v) { sqnatt.sws = v; return true; }
				,width: 150
			},{
				fieldLabel:'Datenquelle'
				,validator:function(v) { sqnatt.sdo = v; return true; }
				,width: 150
			},{
				fieldLabel:'Reserviert'
				,disabled: true
				,width: 150
			}]
		}]
	};

	// CONTACT OFFICE formpanel
	var tp_coform = {
		 title: "Technikdienst"
		,layout:'table'
		,frame: true
		,labelWidth: 65
//		,defaults: {
//			 border: false
//			,bodyStyle:'padding:5px'
//		}
		,layoutConfig: {
			columns: 2
		}
		,items:[{
			 xtype:'fieldset'
			,title:'Kontakt'
			,defaultType:'textfield'
			,autoHeight:true
			,autoWidth:true
			,items:[{
				fieldLabel:'Firma'
				,validator:function(v) { sqnatt.cfr = v; return true; }
				,width: 200
			},{
				fieldLabel:'Name'
				,validator:function(v) { sqnatt.ckn = v; return true; }
				,width: 200
			},{
				fieldLabel:'Telefon'
				,validator:function(v) { sqnatt.ctl = v; return true; }
				,width: 200
			},{
				fieldLabel:'Fax'
				,validator:function(v) { sqnatt.cfx = v; return true; }
				,width: 200
			},{
				fieldLabel:'Email'
				,validator:function(v) { sqnatt.cem = v; return true; }
				,width: 200
			}]
		},{
			 xtype:'fieldset'
			,title:'Adresse'
			,defaultType:'textfield'
			,autoHeight:true
			,autoWidth:true
			,items:[{
				fieldLabel:'Strasse'
				,validator:function(v) { sqnatt.cst = v; return true; }
				,width: 200
			},{
				fieldLabel:'Hausnr'
				,validator:function(v) { sqnatt.chn = v; return true; }
				,width: 200
			},{
				fieldLabel:'Zusatz'
				,validator:function(v) { sqnatt.chz = v; return true; }
				,width: 200
			},{
				fieldLabel:'PLZ'
				,validator:function(v) { sqnatt.cpl = v; return true; }
				,width: 200
			},{
				fieldLabel:'Ort'
				,validator:function(v) { sqnatt.cor = v; return true; }
				,width: 200
			}]
		}]
	};

//	Ext.form.Field.prototype.msgTarget = 'side';

// --- This holds the current TreeNode pointed with cursor ---------------------------
	var currnode = root;
// -----------------------------------------------------------------------------------

	var sqdataform = new Ext.form.FormPanel({
		 labelWidth: 75
		,border: false
		,frame: true
//		,width: 490
		,items: {
			 xtype: 'tabpanel'
		 	,activeTab: 0
//			,plain: true
			,border: false
			// ensures that we can see other tab too =================
			,deferredRender: false
			,defaults: {
				// hideMode: "offsets" fixes disapearing of the cursor
				 hideMode:"offsets"
				,autoHeight:true
				,bodyStyle:'padding:10px'
			}
			,items: [ tp_sqform, tp_coform ]
		}
		,buttons: [{
			 text:'Einfügen'
			,handler: function() {
//				if( sqlev_cb.getValue()=='' || sqtyp_cb.getValue()=='' ) {
				if( sqnatt.ulv == 'nvl' || sqnatt.stp == 'nvl' ) {
					Ext.MessageBox.alert('Status',
						'Ebene und Signalquellen Typ müssen beide definiert sein.');
					return;
				}
				if ( sqnatt.ulv == '1' ) {
					currnode.expand(false, true, sqtsend);
				} else {
					sqtsend();
				}
			}
		},{
			 text:'Zurücksetzen'
			,handler: function() {
			}
		},{
			 text:'Schließen'
			,handler: function() {
				win_addsq.hide();
			}
		}]
	});


    var win_addsq = new Ext.Window({
         id: 'win_addsq'
        ,width: 670
        ,height: 400
        ,layout:'fit'
        ,border: true
        ,plain: true
        ,closable: false
        ,collapsible: true
        ,title:'Signalquelle einfügen'
		,items: [
			sqdataform
		]
    });

// --- The Definitions of TopToolbar -----------------------------------------

	var sqtb_new = new Ext.Toolbar.Button({
		 text: 'Neu'
//		,iconCls:'add'
		,tooltip: 'Neue Signalquelle'
		,disabled: false
		,handler: function () {
			sqlev_cb.setDisabled(false);
			sqtyp_cb.setDisabled(false);
			win_addsq.show();
		}
	});

	var sqtb_update = new Ext.Toolbar.Button({
		 text: 'Ändern'
//		,iconCls: 'add'
		,tooltip: 'Signalquelle-Daten ändern'
		,disabled: true
		,handler: function () {
			sqlev_cb.setDisabled(true);
			sqtyp_cb.setDisabled(true);
			win_addsq.show();
		}
	});

	var sqtb_edit = new Ext.Toolbar.Button({
		 text: 'Bearbeiten'
//		,iconCls:'add'
		,tooltip: 'Sugnalquelle-Datensatz bearbeiten'
		,disabled: true
		,menu: new Ext.menu.Menu({
			 items: [{
            	 text:'Löschen'
				,handler: function () {
					currnode.remove();
					currnode = root;
					sqtb_disabled(true);
					sqinfo.body.update(ktm.app.sqchoose_t);
				}
			},{
				text:'Kopieren'
			},{ 
				text:'Ausschneiden'
			},{
				text:'Einfügen'
			}]
		})
	});

    sqtree.getTopToolbar().add('->',
		sqtb_new, '-', sqtb_update, '-', sqtb_edit, '-',
		{
			 text:'Maske'
//			,iconCls:'add'
			,tooltip:'Parameter für die Anzeige setzen'
		}
	);

	function sqtb_disabled(d, is_new) {
//		sqtb_new.setDisabled(d);
		sqtb_update.setDisabled(d);
		sqtb_edit.setDisabled(d);
	}

	function ninfo(node) {
		var id = node.id;
		var pid = (node.parentNode ? node.parentNode.id : 'NULL');
		var ns = (node.nextSibling ? node.nextSibling.id : 'NULL');
		var ps = (node.previousSibling ? node.previousSibling.id : 'NULL');
		sqinfo.body.update('<p>ID:['+id+'] --- PID:['+pid+'] --- NextSib:['+ns+'] --- PrevSib:['+ps+']');
	}

	sqtree.on('click', function(node){
		if(node.id != '0') {
			if(currnode.id == '0') {
				sqtb_disabled(false);
			}
		}
		else if(node.id == '0') {
//			sqinfo.body.update(ktm.app.sqchoose_t);
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
});
