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

	var sqinfo = new Ext.Panel({
		 renderTo: 'info-sq'
		,width: 430
		,height: 40
		,html: ktm.app.sqchoose_t
	});

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

lst => $loc->strasse,	lhn => $loc->hausnr,	lhz => $loc->hausnrzus,
lpl => $loc->plz,		lor => $loc->ort,		lld => $loc->land,
lrg => $loc->region,

cfr => $co->firma,		ckn => $co->kontakt,	ctl => $co->telefon,
cfx => $co->fax,		cad => $co->addr,		cpl => $co->plz,
cor => $co->ort
*/

	var sqnodeattr = {
		// new node init data attributes:
		stl:'',ssw:'',sws:'',snd:'',stp:'',sdo:'',
		lst:'TESTNEW',lhn:'',lhz:'',lpl:'',lor:'',lld:'', lrg:'',
		cfr:'',ckn:'',ctl:'',cfx:'',cad:'',cpl:'', cor:'',
		// new node configuration:
		cls:'sq-node', allowDrag: false
	};

	function sqtext(node) {
		var id = node.id;
		var na = node.attributes;
		var text = '['
		text = '[NId:'+na.snd+']'+text;
		text = '['+na.stp+']'+text;
		text = '[ID:'+node.id+']'+text;
		text = text+na.lst+' '+na.lhn;
		if(na.lhz) { text = text+' ('+na.lhz+')'; }
		text = text+', '+na.lpl+' '+na.lor;
		text = text+']';
		node.setText(text);
	}

	sqtloader.on('load', function(treeLoader, node) {
		if(node.id == 0) { node.setText('Signalquellen - Gesamtnetz Infrastruktur'); };
		node.eachChild(sqtext);
	});

	var sqtree = new Tree.TreePanel({
		 el: 'tree-sq'
		,width: 480
		,height: 270
//		,autoHeight: true
		,rootVisible: true
		,autoScroll: true
		,enableDD: false
        ,animate: false
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
//		,loader: sqtloader
	});

    // set the root node - Async only if we use loader!
//    var root = new Tree.AsyncTreeNode({
    var root = new Tree.TreeNode({
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

/*
========= Hier starts Signalquelle Form ===============================================
*/

	// Combobox for TYPE of SIGNALQUELLE
    var sqtyp_cb = new Ext.form.ComboBox({
		 store: new Ext.data.SimpleStore({
			 fields: ['sqabbr', 'squelle', 'sqtip']
			,data: ktm.app.sqtypes
		 })
		,tpl: '<tpl for="."><div ext:qtip="[{sqabbr}]: {sqtip}" class="x-combo-list-item">{squelle}</div></tpl>'
		,hideLabel: true
        ,displayField: 'squelle'
		,editable: false
        ,typeAhead: false
        ,mode: 'local'
        ,triggerAction: 'all'
        ,emptyText: 'Wähle aus...'
        ,selectOnFocus: true
        ,width: 110
    });

	// Combobox for the LEVEL of Signalquelle
    var sqlev_cb = new Ext.form.ComboBox({
		 store: new Ext.data.SimpleStore({
			 fields: ['sqlevabbr', 'sqlevel', 'sqlevtip']
			,data: ktm.app.sqlevels
		 })
		,tpl: '<tpl for="."><div ext:qtip="{sqlevtip}" class="x-combo-list-item">{sqlevel}</div></tpl>'
		,hideLabel: true
        ,displayField: 'sqlevel'
		,editable: false
        ,typeAhead: true
        ,mode: 'local'
        ,triggerAction: 'all'
        ,emptyText: 'Wähle aus...'
        ,selectOnFocus: true
        ,width: 110
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
				,width: 200
			},{
				fieldLabel:'Hausnr'
				,width: 200
			},{
				fieldLabel:'Zusatz'
				,width: 200
			},{
				fieldLabel:'PLZ'
				,width: 200
			},{
				fieldLabel:'Ort'
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
				,width: 150
			},{
				fieldLabel:'Wohneinheiten'
				,width: 150
			},{
				fieldLabel:'Soll Wohneinheiten'
				,width: 150
			},{
				fieldLabel:'Datenquelle'
				,width: 150
			},{
				fieldLabel:'Reserviert'
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
				,width: 200
			},{
				fieldLabel:'Name'
				,width: 200
			},{
				fieldLabel:'Telefon'
				,width: 200
			},{
				fieldLabel:'Fax'
				,width: 200
			},{
				fieldLabel:'Email'
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
				,width: 200
			},{
				fieldLabel:'Hausnr'
				,width: 200
			},{
				fieldLabel:'Zusatz'
				,width: 200
			},{
				fieldLabel:'PLZ'
				,width: 200
			},{
				fieldLabel:'Ort'
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
				var addlev = sqlev_cb.getValue();
				var addtyp = sqtyp_cb.getValue();
				var c;

				if( addlev == ''  || addtyp == '') {
					Ext.MessageBox.alert('Status', 'Ebene und Signalquellen Typ müssen definiert sein.');
					return;
				}

				var newnode = new Ext.tree.TreeNode(sqnodeattr
/*				{
					 allowDrag: false
					,cls: 'sq-node'
				}
*/				);

				for (c in newnode.attributes) {
				}

				newnode.attributes['lst'] = "BLAHHAHAHA";
//				newnode.attributes.lst = "BLAHHAHAHA";
				sqtext(newnode);

				if(addlev == 'Gleiche Ebene') {
					if(currnode == root) {
						root.insertBefore(newnode, root.firstChild);
					} else {
						currnode.parentNode.insertBefore(newnode, currnode.nextSibling);
					}
				} else {
					currnode.expand();
					currnode.insertBefore(newnode, currnode.firstChild);
				}
				sqtree.getSelectionModel().select(newnode);
				ninfo(newnode);
				currnode = newnode;
				sqtb_disabled(false);
//				win_addsq.hide();
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
			win_addsq.show();
		}
	});

	var sqtb_update = new Ext.Toolbar.Button({
		 text: 'Ändern'
//		,iconCls: 'add'
		,tooltip: 'Signalquelle-Daten ändern'
		,disabled: true
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
		if(node.id != 'sqroot') {
			if(currnode.id == 'sqroot') {
				sqtb_disabled(false);
			}
		}
		else if(node.id == 'sqroot') {
//			sqinfo.body.update(ktm.app.sqchoose_t);
			if(currnode.id != 'sqroot') {
				sqtb_disabled(true);
			}
		}
		ninfo(node);
		currnode = node;
    });
});
