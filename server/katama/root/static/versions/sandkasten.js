===========================================================================================================
===========================================================================================================
RADIO BUTTONS
===========================================================================================================
            ,items:[{
                 hideLabels:true
                ,layout:'form'
                ,items:[{
                     xtype:'fieldset'
                    ,title:'Ebene'
                    ,height: 75
					,width: 100
                    ,items:[{
						layout: 'form'
						,items: new Ext.form.Radio({
							boxLabel:"gleiche"
							,checked: true
							,hideLabel: true
							,name:"addlevel"
						})
                    },{
						layout: 'form'
						,items: new Ext.form.Radio({
							boxLabel:"darunter"
							,checked: false
							,hideLabel: true
							,name:"addlevel"
						})
                    }]
                }]
			}]
===========================================================================================================
===========================================================================================================
CLONING FROM FORUM/ANIMAL
===========================================================================================================
Ext.override(Ext.Element, {
// Call the passed function on the current Element, and all its descendants
    cascade: function(fn, scope, args) {
        if(fn.apply(scope || this, args || [this]) !== false){
            var cs = this.dom.childNodes;
            for(var i = 0, len = cs.length; i < len; i++) {
            	Ext.get(cs[i]).cascade(fn, scope, args);
            }
        }
    },

    clone: function() {
        var result = this.el.dom.cloneNode(true);
        result.id = Ext.id();
        result = Ext.get(result);
        result.cascade(function(e){e.id = Ext.id();});
    }
});
===========================================================================================================
===========================================================================================================
TREE NODE DATA
===========================================================================================================
var node = new Ext.tree.TreeNode({
  text: 'my node',
  id:'node1',
  data: new Ext.data.SimpleStore({...})
  dataString: 'My Data'
});

if(node.attributes.dataString == 'My Data') {
  // you win.
}
--------- or ---------
var node = new Ext.tree.TreeNode({
  text: 'my node',
  id:'node1'
});

node.attributes.dataString = 'My Data';

if(node.attributes.dataString == 'My Data') {
  // you win.
}
===========================================================================================================
===========================================================================================================
UPDATE PANEL DATA
===========================================================================================================
var tab = Ext.getCmp('###ID from panel for update###');
tab.body.mask('Loading', 'x-mask-loading');
tab.body.load({
  url: '###url to file for load###',
  params: {id: '###node.id###'},
  callback: function(el) {
    el.unmask();
  }
});
===========================================================================================================
===========================================================================================================
XML TREE LOADER FROM ANIMAL
===========================================================================================================
<html>
<head>
<script type="text/javascript" src="../../adapter/ext/ext-base.js"></script>
<script type="text/javascript" src="../../ext-all-debug.js"></script>
<script type="text/javascript" src="../code-display.js"></script>
<script type="text/javascript">
Ext.ux.XmlTreeLoader = Ext.extend(Ext.tree.TreeLoader, {
    /**
     * Load an {@link Ext.tree.TreeNode} xmlNode referred to by the passed TreeNode..
     * This is called automatically when a node is expanded, but may be used to reload
     * a node (or append new children if the {@link #clearOnLoad} option is false.)
     * @param {Ext.tree.TreeNode} node The existing node for which to load child nodes.
     * It must have a reference to its corresponding node in the XML document in a property
     * called xmlNode.
     * @param {Function} callback
     */
    load : function(node, callback){
        if(this.clearOnLoad){
            while(node.firstChild){
                node.removeChild(node.firstChild);
            }
        }
        if(this.doPreload(node)){ // preloaded json children
            if(typeof callback == "function"){
                callback();
            }
        }else {
            this.loadXml(node, callback);
        }
    },

    doPreload : function(node){
        if(node.attributes.children){
            if(node.childNodes.length < 1){ // preloaded?
                var cs = node.attributes.children;
                node.beginUpdate();
                for(var i = 0, len = cs.length; i < len; i++){
                    var cn = node.appendChild(this.createNode(cs[i]));
                    if(this.preloadChildren){
                        this.doPreload(cn);
                    }
                }
                node.endUpdate();
            }
            return true;
        }else {
            return false;
        }
    },

    loadXml : function(node, callback){
        var xNode = node.attributes.xmlNode;

//      If the TreeNode's xmlNode is an Element, or a Document.
//      then we can load from it.
        if (xNode && ((xNode.nodeType == 1) || (xNode.nodeType == 9))) {

//          Load attributes as child nodes
            var childNodes = xNode.attributes, l = xNode.attributes.length;
            for (var i = 0; i < l; i++) {
                var c = xNode.attributes[i];
                node.appendChild(this.createNode({
                    iconCls: 'attribute-name',
                    text: c.name,
                    children: [{
                        iconCls: 'attribute-value',
                        text: c.value,
                        leaf: true
                    }]
                }));
            }

//          Load child elements as child nodes
            childNodes = xNode.childNodes, l = xNode.childNodes.length;
            for (var i = 0; i < l; i++) {
                var c = xNode.childNodes[i];
                if (c.nodeType == 1) {
                    node.appendChild(this.createNode({
                        text: c.tagName,
                        xmlNode: c,
                        leaf: ((c.childNodes.length + c.attributes.length) == 0)
                    }));
                } else if ((c.nodeType == 3) && (c.data.trim().length != 0)) {
                    node.appendChild(this.createNode({
                        text: c.data,
                        leaf: true
                    }));
                }
            }
        }

        callback(this, node);
    },

    /**
    * Override this function for custom TreeNode node implementation
    */
    createNode : function(attr){
        // apply baseAttrs, nice idea Corey!
        if(this.baseAttrs){
            Ext.applyIf(attr, this.baseAttrs);
        }
        if(this.applyLoader !== false){
            attr.loader = this;
        }
        if(typeof attr.uiProvider == 'string'){
           attr.uiProvider = this.uiProviders[attr.uiProvider] || eval(attr.uiProvider);
        }
        return(attr.leaf ?
                        new Ext.tree.TreeNode(attr) :
                        new Ext.tree.AsyncTreeNode(attr));
    }
});
</script>

<link rel="stylesheet" type="text/css" href="../../resources/css/ext-all.css" />
<style type="text/css">
/* Attribute name node background when collapsed. */
.x-tree-node .x-tree-node-icon.attribute-name {
	background-image: url(images/default/tree/folder.gif)
}

/* Attribute name node background when expanded. */
.x-tree-node-expanded .x-tree-node-icon.attribute-name {
	background-image: url(images/default/tree/folder-open.gif)
}

/* Attribute value node background. */
.x-tree-node-leaf .x-tree-node-icon.attribute-value {
	background-image: url(images/default/form/exclamation.gif)
}
</style>
<script type="text/javascript">
function createTree(response, options) {
	var doc = response.responseXML;
	var root = doc.documentElement || doc;
	new Ext.tree.TreePanel({
		renderTo: document.body,
		loader: new Ext.ux.XmlTreeLoader({
			preloadChildren: true
		}),
		root: new Ext.tree.AsyncTreeNode({
		    text: root.tagName,
		    xmlNode: root
		})
	});
}

Ext.onReady(function() {
    Ext.Ajax.request({
        url: 'plants.xml',
        success: createTree
    });
});
</script>
</head>
<body>
</body>
</html>
===========================================================================================================
===========================================================================================================
===========================================================================================================
/**
* Finds the first child that has the attribute with the specified value.
* Looks recursively down the tree to find the child.
* @param {String} attribute The attribute name
* @param {Mixed} value The value to search for
* @return {Node} The found child or null if none was found
*/
function findChildRecursively(tree,attribute, value) {
    var cs = tree.childNodes;
    for(var i = 0, len = cs.length; i < len; i++) {
        if(cs[i].attributes[attribute] == value){
            return cs[i];
        }
        else {
            // Find it in this tree
            if(found = findChildRecursively(cs[i], attribute, value)) {
                return found;
            }
        }
    }
    return null;
}  
===========================================================================================================
===========================================================================================================
===========================================================================================================

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

===========================================================================================================
===========================================================================================================
===========================================================================================================

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

===========================================================================================================
===========================================================================================================
TreePanel insert node level ulv 0=same level 1=under level
===========================================================================================================

	function cr_sqdbsucc(r) {
		var response = Ext.util.JSON.decode(r.responseText);
		sqnatt.id = response.uidx;
		var newatts = new sqAttr(sqnatt);
		var newnode = new Ext.tree.TreeNode(newatts);
		sqtext(newnode);
////////////////////////////////////////////////////////
		if(newnode.attributes.ulv == '0') {
			if(currnode == root) {
				root.insertBefore(newnode, root.firstChild);
			} else {
				currnode.parentNode.insertBefore(newnode, currnode.nextSibling);
			}
		} else {
			currnode.expand();
  	//DANGEROUS! LOCK CURRENT SOMEHOW!
  		currnode.insertBefore(newnode, currnode.firstChild);
		}
////////////////////////////////////////////////////////
		sqtree.getSelectionModel().select(newnode);
		ninfo(newnode);
		currnode = newnode;
		sqtb_disabled(false);
	}

===========================================================================================================
===========================================================================================================
A little tree on the left and fieldset and grid on the right.
===========================================================================================================
	var pg_bouq_gr = {
//		 title: "Hauptdaten"
		 layout:'table'
//		,frame: true
		,labelWidth: 65
		,layoutConfig: {
			columns: 2
		}
		,items: [{
			 xtype:'treepanel'
			,rowspan: 2
			,width: 180
			,height: 300
			,rootVisible: false
			,autoScroll: true
			,enableDD: false
			,animate: false
        	,tbar:[ ]
			,loader: new Ext.tree.TreeLoader({
				 dataUrl: '/sqkext/0'
				,requestMethod:'GET'
			})
			,root: new Ext.tree.AsyncTreeNode({
				 text: 'Alle Bouquets'
				,draggable: false
			})
		},{
			 xtype:'fieldset'
			,title:'Bouquetdaten'
			,defaultType:'textfield'
			,autoHeight:true
			,autoWidth:true
			,items:[{
				 fieldLabel:'Name'
				,width: 200
			},{
				 fieldLabel:'Betreiber'
				,width: 200
			},{
				 fieldLabel:'Vertrag'
				,width: 200
			}]
		},{
			 xtype:'fieldset'
			,title:'3'
			,colspan: 2
//			,height: 60
//			,items:[ sqland_cb ]
		}]
===========================================================================================================
===========================================================================================================
GRID CLASS FOR BOUQUETS
===========================================================================================================

ktm.pgBqGrid = Ext.extend(Ext.grid.EditorGridPanel, {

	 bqDrec: Ext.data.Record.create([
		 { name:'uidx', type:'int' }
		,{ name:'nam', type:'string' }
		,{ name:'spr', type:'string' }
		,{ name:'dummy' }
	])

	,initComponent: function() {

		this.action = new Ext.ux.grid.RowActions({
			 header: 'Programme'
			,autoWidth: false
			,actions:[{
				 iconCls:'icon-add'
				,tooltip:'Programm einfügen'
			},{
				 iconCls:'icon-del'
				,tooltip:'Programm entfernen'
			}]
		});

		this.action.on({
			 action: function(grid, record, action, row, col) {
				Ext.ux.Toast.msg('Event: action',
					'You have clicked row: <b>{0}</b>, action: <b>{1}</b>', row, action);
			}
			,beforeaction: function() {
				Ext.ux.Toast.msg('Event: beforeaction',
					'You can cancel the action by returning false from this event handler.');
			}
		});

		this.bqStore = new Ext.data.JsonStore({
			 url: '/tvpext'
			,root: 'tvp'
			,fields: this.bqDrec
 		});

		Ext.apply( this, {

			 store: this.bqStore

			,columns: [{
				 id: 'UIDX'
				,header: 'ID'
				,sortable: false
				,dataIndex: 'uidx'
				,width: 30
				,menuDisabled: true
			}, {
				 id: 'NAM'
				,header: 'Name'
				,dataIndex: 'nam'
				,sortable: true
				,editor: new Ext.form.TextField({
					allowBlank: false
				})
			}, {
				 id: 'SPR'
				,header: 'Sprache'
				,dataIndex: 'spr'
				,sortable: true
				,editor: new Ext.form.TextField({
					allowBlank: false
				})
			},
				 this.action
			]

			,plugins: [ this.action ]

			,tbar: [ ]

		}); // <<< Ext.apply( this ...

		ktm.pgBqGrid.superclass.initComponent.apply(this, arguments);

/*
, {
				 text: 'Speichern'
				,handler: function() {
					ktm.pgBqGrid.superclass.stopEditing();
					var mystore = ktm.pgBqGrid.superclass.getStore();
					var changes = new Array();
					var pguidcnt = 1;
					var dirty = mystore.getModifiedRecords();
					for ( var i = 0 ; i < dirty.length ; i++ ) {
						var fields = dirty[i].getChanges();
						fields.uidx = dirty[i].get('uidx');
						fields.guid = pguidcnt++;
						changes.push( fields );
					}
					console.log( changes );
					var send = { 'tvp': changes };
					Ext.Ajax.request({
						 method: 'POST'
						,url: '/tvpext/m'
						,headers: {'Content-Type': 'text/x-json'}
						,success: function() { mystore.reload() }
						,jsonData: send
					});
					mystore.commitChanges();
				}
			}, {
				 text: 'Verwerfen'
				,handler: function() {
					ktm.pgBqGrid.superclass.stopEditing();
					ktm.pgBqGrid.superclass.getStore().rejectChanges();
				}
			}] // <<< tbar
*/

	} // <<< initComponent

	,onRender: function() {

		ktm.pgBqGrid.superclass.onRender.apply(this, arguments);

		this.getTopToolbar().add({
			 text: 'Neu'
			,handler: function() {
				var rec = ktm.pgBqGrid.prototype.bqDrec().prototype;
				var p = new rec({
					 nam:'NEU'
					,spr:'NEU'
				});
				ktm.pgBqGrid.superclass.stopEditing();
				this.getStore().insert( 0, p );
				ktm.pgBqGrid.superclass.startEditing( 0, 1 );
			}
		});

		this.store.load({
			callback: function (records) {
				Ext.ux.Toast.msg('BOUQUETS LOADED', 'blajh');
			}
		});

	} // <<< onRender

}); // <<< pgBqGrid

// register component
Ext.reg('pg_bq_grid', ktm.pgBqGrid);

///////////////////////////////////////////////////////////////////////////////////////////////////

===========================================================================================================
OTHER TRY
===========================================================================================================

ktm.bq_grid = Ext.extend(Ext.grid.GridPanel, {

	initComponent: function() {

		this.action = new Ext.ux.grid.RowActions({
			 header:'Actions'
//			,autoWidth:false
			,actions:[{
				 iconCls:'icon-add'
//				,iconIndex:'action1'
//				,qtipIndex:'qtip1'
				,tooltip:'Programm einfügen'
			},{
				 iconCls:'icon-del'
//				,iconIndex:'action2'
//				,qtipIndex:'qtip2'
				,tooltip:'Programm entfernen'
//				,hideIndex:'hide2'
//				,text:'Open'
			}]
		});

		// dummy action event handler - just outputs some arguments to console
		this.action.on({
			 action:function(grid, record, action, row, col) {
				Ext.ux.Toast.msg('Event: action',
					'You have clicked row: <b>{0}</b>, action: <b>{1}</b>', row, action);
			}
			,beforeaction:function() {
				Ext.ux.Toast.msg('Event: beforeaction',
					'You can cancel the action by returning false from this event handler.');
			}
		});

		// configure the grid
		Ext.apply(this, {
			 store: new Ext.data.Store({
				 reader: new Ext.data.JsonReader({
					 id:'uidx'
//					,totalProperty:'totalCount'
					,root:'tvp'
					,fields:[
						 { name:'uidx', type:'int' }
						,{ name:'nam', type:'string' }
						,{ name:'spr', type:'string' }
						,{ name:'dummy' }
/*
						,{ name:'action1', type:'string'}
						,{ name:'action2', type:'string'}
						,{ name:'qtip1', type:'string'}
						,{ name:'qtip2', type:'string'}
*/
					]
				})
				,proxy: new Ext.data.HttpProxy({
					url:'/tvpext'
				})
				,sortInfo: { field:'nam', direction:'ASC' }
			})

			,columns:[{
				 id: 'UIDX'
				,header: 'ID'
				,dataIndex: 'uidx'
				,width: 30
			}, {
				 id: 'NAM'
				,header: 'Name'
				,sortable: true
				,dataIndex: 'nam'
				,width: 100
			}, {
				 id: 'SPR'
				,header: 'Sprache'
				,sortable: true
				,dataIndex: 'spr'
			}, this.action ]

			,plugins:[ this.action ]

//			,view: new Ext.grid.GridView({
//				 forceFit: true
//			})

		});

/*
		// add paging toolbar
		this.bbar = new Ext.PagingToolbar({
			 store: this.store
			,displayInfo: true
			,pageSize: 10
		});
*/
		// call parent
		ktm.bq_grid.superclass.initComponent.apply(this, arguments);

	} // <<< initComponent

	,onRender: function() {
		// call parent
		ktm.bq_grid.superclass.onRender.apply(this, arguments);

		// start w/o grouping
//		this.store.clearGrouping();

		// load the store
		this.store.load(
/*
		{
			params: { start:0, limit:10 }
		}
*/
		);
	} // <<< onRender

}); // <<< ktm.bq_grid


// register component
Ext.reg('ktm_bq_grid', ktm.bq_grid);

	var pg_bouq_gr = {
		 xtype: 'pg_bq_grid'
		,id: 'pgbqgrid'
		,border: false
		,width: pgw_grids
		,height: pgh_grids-30
		,autoExpandColumn: 'NAM'
		,stripeRows: true
	};

===========================================================================================================
===========================================================================================================
RowGridExpander
===========================================================================================================
	// RowExpander SubGrid
	function bq_grexp(elementId) {
		var grid = new Ext.grid.GridPanel({
			store: new Ext.data.JsonStore({
				 url: '/bqpgext/3'
				,root: 'bqpg'
				,fields: Ext.data.Record.create([
					 { name:'pgid', type:'int' }
					,{ name:'bqid', type:'int' }
					,{ name:'nam', type:'string' }
					,{ name:'pgt', type:'string' }
					,{ name:'gnr', type:'string' }
				])
			 })
			,columns: [
				 {id:'PGID',header:'PGID',sortable:false,dataIndex:'pgid',width:30,menuDisabled:true}
				,{id:'BQID',header:'BQID',sortable:false,dataIndex:'bqid',width:30,menuDisabled:true}
				,{id:'NAM',header:'Name',dataIndex:'nam',width:80,menuDisabled:true}
				,{id:'PGT',header:'Type',dataIndex:'pgt',width:80,menuDisabled:true}
				,{id:'GNR',header:'Genre',dataIndex:'gnr',width:80,menuDisabled:true}
			]
			,viewConfig: {
				forceFit: true
			}
//			,autoWidth: true
//			,autoHeight: true
//			,autoExpandColumn: 'SPR'
			,stripeRows: true
			,border: false
			,width: 400
			,height: 200
			,title: 'expander grid'
//			,renderTo: 'grid-example'
		});
		return grid;
	}

	// === Ext.grid.RowGridExpander ===================================================

Ext.grid.RowGridExpander = function(config){

    Ext.apply(this, config);

    this.addEvents({
        beforeexpand : true,
        expand: true,
        beforecollapse: true,
        collapse: true
    });

    Ext.grid.RowGridExpander.superclass.constructor.call(this);

///////////////////////////////////
	this.subgrids = {};

	this.tpl = new Ext.Template('<div id="ux-rgexpander-{RID}"></div>');
	this.tpl.compile();
///////////////////////////////////

    this.state = {};
    this.bodyContent = {};

	this.on('expand', function(obj, record, body, rowIndex) {
//		var subgrid = this.getSubGrid(record);
//		subgrid.render('ux-rgexpander-'+record.id);
//		subgrid.getEl().swallowEvent(['mouseover','mousedown','click','dblclick']);
	});
};

Ext.extend(Ext.grid.RowGridExpander, Ext.util.Observable, {
    header: "",
    width: 20,
    sortable: false,
    fixed:true,
    menuDisabled:true,
    dataIndex: '',
    id: 'expander',
    lazyRender : true,
    enableCaching: true,

    init : function(grid){

        this.grid = grid;

        var view = grid.getView();
        view.enableRowBody = true;
        view.getRowClass = this.getRowClass.createDelegate(this);

        grid.on('render', function(){
            view.mainBody.on('mousedown', this.onMouseDown, this);
        }, this);
    },

    renderer : function(v, p, record){
        p.cellAttr = 'rowspan="2"';
		return '<div class="x-grid3-row-expander"> </div>';
    },

///////////////////////////////////
	getSubGrid : function(record) {
//		var subgrid = this.subgrids[record.id];
//		if(!subgrid) {
			subgrid = this.subgridinit('ux-rgexpander-'+record.id);
			this.subgrids[record.id] = subgrid;
//		}
		return subgrid
	},
///////////////////////////////////

    getRowClass : function(record, rowIndex, p, ds){
        p.cols = p.cols-1;
        var content = this.bodyContent[record.id];
        if(!content && !this.lazyRender){
            content = this.getBodyContent(record, rowIndex);
        }
        if(content){
            p.body = content;
        }

///////////////////////////////////
		var subgrid = this.getSubGrid(record);
//		subgrid.render('ux-rgexpander-'+record.id);
//		subgrid.getEl().swallowEvent(['mouseover','mousedown','click','dblclick']);
///////////////////////////////////

        return this.state[record.id] ? 'x-grid3-row-expanded' : 'x-grid3-row-collapsed';
    },

    getBodyContent : function(record, index) {
		if(!this.enableCaching && this.tpl){
//			return this.tpl.apply(record.data);
			return this.tpl.apply({'RID':record.id});
        }
        var content = this.bodyContent[record.id];
        if(!content && this.tpl){
//			content = this.tpl.apply(record.data);
			content = this.tpl.apply({'RID':record.id});
            this.bodyContent[record.id] = content;
        }
        return content;
    },

/*
	refreshRow : function(row) {
        if(typeof row == 'number'){
            row = this.grid.view.getRow(row);
        }
        var record = this.grid.store.getAt(row.rowIndex);
		if(this.tpl) {
			var content = this.tpl.apply(record.data);
		}
		this.bodyContent[record.id] = content;
	},
*/

    onMouseDown : function(e, t){
        if(t.className == 'x-grid3-row-expander'){
            e.stopEvent();
            var row = e.getTarget('.x-grid3-row');
            this.toggleRow(row);
        }
    },

    beforeExpand : function(record, body, rowIndex){
        if(this.fireEvent('beforeexpand', this, record, body, rowIndex) !== false){
			if(this.tpl && this.lazyRender){
				body.innerHTML = this.getBodyContent(record, rowIndex);
			}
			return true;
        }else{
            return false;
        }
    },

    toggleRow : function(row){
        if(typeof row == 'number'){
            row = this.grid.view.getRow(row);
        }
        this[Ext.fly(row).hasClass('x-grid3-row-collapsed') ? 'expandRow' : 'collapseRow'](row);
    },

    expandRow : function(row){
        if(typeof row == 'number'){
            row = this.grid.view.getRow(row);
        }
        var record = this.grid.store.getAt(row.rowIndex);
        var body = Ext.DomQuery.selectNode('tr:nth(2) div.x-grid3-row-body', row);
        if(this.beforeExpand(record, body, row.rowIndex)){
            this.state[record.id] = true;
            Ext.fly(row).replaceClass('x-grid3-row-collapsed', 'x-grid3-row-expanded');
            this.fireEvent('expand', this, record, body, row.rowIndex);

			var subgrid = this.getSubGrid(record);
			if(subgrid.rendered) {
				subgrid.show();
			} else {
				subgrid.render('ux-rgexpander-'+record.id);
			}
			subgrid.getEl().swallowEvent(['mouseover','mousedown','click','dblclick']);

        }
    },

    collapseRow : function(row){
        if(typeof row == 'number'){
            row = this.grid.view.getRow(row);
        }
        var record = this.grid.store.getAt(row.rowIndex);
        var body = Ext.fly(row).child('tr:nth(1) div.x-grid3-row-body', true);
        if(this.fireEvent('beforcollapse', this, record, body, row.rowIndex) !== false){

			var subgrid = this.getSubGrid(record);
			subgrid.hide();

            this.state[record.id] = false;
            Ext.fly(row).replaceClass('x-grid3-row-expanded', 'x-grid3-row-collapsed');
            this.fireEvent('collapse', this, record, body, row.rowIndex);

        }
    }
}); // ENDOF Ext.grid.RowGridExpander

===========================================================================================================
===========================================================================================================
Original RowExpander
===========================================================================================================

// === Ext.grid.RowExpander ===================================================

Ext.grid.RowExpander = function(config){

    Ext.apply(this, config);

    this.addEvents({
        beforeexpand : true,
        expand: true,
        beforecollapse: true,
        collapse: true
    });

    Ext.grid.RowExpander.superclass.constructor.call(this);

    if(this.tpl){
        if(typeof this.tpl == 'string'){
            this.tpl = new Ext.Template(this.tpl);
        }
        this.tpl.compile();
    }

    this.state = {};
    this.bodyContent = {};
};

Ext.extend(Ext.grid.RowExpander, Ext.util.Observable, {
    header: "",
    width: 20,
    sortable: false,
    fixed:true,
    menuDisabled:true,
    dataIndex: '',
    id: 'expander',
    lazyRender : true,
    enableCaching: true,

    init : function(grid){

        this.grid = grid;

        var view = grid.getView();
        view.getRowClass = this.getRowClass.createDelegate(this);

        view.enableRowBody = true;

        grid.on('render', function(){
            view.mainBody.on('mousedown', this.onMouseDown, this);
        }, this);
    },

    getBodyContent : function(record, index){
		if(!this.enableCaching && this.tpl){
            return this.tpl.apply(record.data);
        }
        var content = this.bodyContent[record.id];
        if(!content && this.tpl){
            content = this.tpl.apply(record.data);
            this.bodyContent[record.id] = content;
        }
        return content;
    },

    getRowClass : function(record, rowIndex, p, ds){
        p.cols = p.cols-1;
        var content = this.bodyContent[record.id];
        if(!content && !this.lazyRender){
            content = this.getBodyContent(record, rowIndex);
        }
        if(content){
            p.body = content;
        }
        return this.state[record.id] ? 'x-grid3-row-expanded' : 'x-grid3-row-collapsed';
    },

	refreshRow : function(row) {
        if(typeof row == 'number'){
            row = this.grid.view.getRow(row);
        }
        var record = this.grid.store.getAt(row.rowIndex);
		if(this.tpl) {
			var content = this.tpl.apply(record.data);
		}
		this.bodyContent[record.id] = content;
	},

    onMouseDown : function(e, t){
        if(t.className == 'x-grid3-row-expander'){
            e.stopEvent();
            var row = e.getTarget('.x-grid3-row');
            this.toggleRow(row);
        }
    },

    renderer : function(v, p, record){
        p.cellAttr = 'rowspan="2"';
			return '<div class="x-grid3-row-expander"></div>';
//			return '<div class="x-grid3-row-expander">&#160;</div>';
    },

    beforeExpand : function(record, body, rowIndex){
        if(this.fireEvent('beforeexpand', this, record, body, rowIndex) !== false){
				if(this.tpl && this.lazyRender){
					body.innerHTML = this.getBodyContent(record, rowIndex);
				}
			return true;
        }else{
            return false;
        }
    },

    toggleRow : function(row){
        if(typeof row == 'number'){
            row = this.grid.view.getRow(row);
        }
        this[Ext.fly(row).hasClass('x-grid3-row-collapsed') ? 'expandRow' : 'collapseRow'](row);
    },

    expandRow : function(row){
        if(typeof row == 'number'){
            row = this.grid.view.getRow(row);
        }
        var record = this.grid.store.getAt(row.rowIndex);
        var body = Ext.DomQuery.selectNode('tr:nth(2) div.x-grid3-row-body', row);
        if(this.beforeExpand(record, body, row.rowIndex)){
            this.state[record.id] = true;
            Ext.fly(row).replaceClass('x-grid3-row-collapsed', 'x-grid3-row-expanded');
            this.fireEvent('expand', this, record, body, row.rowIndex);
        }
    },

    collapseRow : function(row){
        if(typeof row == 'number'){
            row = this.grid.view.getRow(row);
        }
        var record = this.grid.store.getAt(row.rowIndex);
        var body = Ext.fly(row).child('tr:nth(1) div.x-grid3-row-body', true);
        if(this.fireEvent('beforcollapse', this, record, body, row.rowIndex) !== false){
            this.state[record.id] = false;
            Ext.fly(row).replaceClass('x-grid3-row-expanded', 'x-grid3-row-collapsed');
            this.fireEvent('collapse', this, record, body, row.rowIndex);
        }
    }
}); // ENDOF Ext.grid.RowExpander

===========================================================================================================
===========================================================================================================
AJAX stuff for some funny requests with expander....
===========================================================================================================
//		bq_expander.collapseRow(row);
//		bq_actionurl[action].fnc(response.sel, record, true);
		Ext.Ajax.request({
			 method: 'GET'
			,url: bq_actionurl[action].url+record.get('uidx')
			,headers: { 'Content-Type': 'text/x-json' }
			,success: function (r) {
				var response = Ext.util.JSON.decode(r.responseText);

				console.log(record.get('bqpgs'));
				console.log(record.get('bqpgs').length);
				console.log(record.get('bqpgs')[0].length);


				record.set('bqpgs', response.tpl);
				bq_expander.refreshRow(row);
				bq_expander.expandRow(row);
				bq_actionurl[action].fnc(response.sel, record, true);
			 }
			,failure: function (r) {
				var response = Ext.util.JSON.decode(r.responseText);
				bq_actionurl[action].fnc(response.sel, record, false);
			 }
		});
===========================================================================================================
===========================================================================================================
TOOLBAR MENU - delete, copy, paste, etc
===========================================================================================================

/*
	var sqtb_edit = new Ext.Toolbar.Button({
		 text: 'Bearbeiten'
//		,iconCls:'add'
		,tooltip: 'Sugnalquelle-Datensatz bearbeiten'
		,disabled: true
		,menu: new Ext.menu.Menu({
			 items: [{
            	 text:'Löschen'
				,handler: function () {
					sqtdel(currnode.id);
				}
			},{
				 text:'Kopieren'
				,handler: function () {
					sqcopyattatt(currnode.attributes, sqnatt);
				}
			},{ 
				 text:'Ausschneiden'
				,handler: function () {
					sqcopyattatt(currnode.attributes, sqnatt)
					// CALL SOME DELETE REST HERE!
					//
					currnode.remove();
					currnode = sqroot;
					sqtb_disabled(true);
					sqinfo.body.update(ktm.app.sqchoose);
				}
			},{
				 text:'Einfügen'
				,handler: function () {
					sq_sqdata_win.setTitle('Signalquelle einfügen');
					sqtyp_cb.setDisabled(false);
					sq_sqdata_win.show();
					sqcopyform(sqnatt);
				}
			}]
		})
	});
*/

===========================================================================================================
===========================================================================================================
RECURSION STUFF
===========================================================================================================
	// o: nested json hash to search through
	// id: object identifier to look for
	// returns: json object referenced by id 
	function tpdig(o, id) {
		if(o[id]) { return o; }
		var r; var k;
		for (k in o) {
			if(o[k] != 1) {
				r = tpdig(o[k], id);
				if(r) { return r; }
			}
		}
		return 0;
	}
===========================================================================================================
===========================================================================================================
ARGH!!! DONT NEED THIS RECURSION MONSTER WHICH TOOK ME 2 DAYS TO DEVELOP COS THERE IS SOMETHING MORE EASY
===========================================================================================================
	// keeps hash in form { '0':{ exp:13, cnt:7, '4':{ exp:3, cnt:2, '12':{ exp:1, cnt:1 } }, '7':{ exp:3, cnt:3 } } }
	// id properties are expanded nodes with the bookkeeping about expanded subnodes 
	// exp is the current total count of the expanded nodes for the given id property
	// cnt is the count of the children nodes. if cnt == exp, no sub-nodes are expanded.
	function treepage(rootid) {
		this.cnt = 0;
		this.rid = rootid;
		this.reg = {};

		// o: nested json hash object to search
		// id: property identifier to look after
		// pid: identifier of the parent property
		// cnt: number of nodes to expand for id
		function dig_expand(reg, id, pid, cnt) {
			var par = reg[pid];
			// the parent property found
			if(par) {
				// requested property not registered yet, register
				if(!par[id]) {
					par[id] = { exp:cnt, cnt:cnt };
				}
				// increase exp counters of parent
				par.exp += par[id].exp;
				// increase global expanded counter 
				this.cnt += par[id].exp;
				// return number of newly expanded nodes
				return par[id].exp;
			}
			// parent property not found, dive further into sub-nodes
			var k; var exp;
			for (k in reg) {
				if(k == 'exp') { continue; }
				if(k == 'cnt') { continue; }
				// check subnodes
				exp = dig_expand(reg[k], id, pid, cnt);
				// parent property found, update exp counter & return
				if(exp) {
					reg[k].exp += exp;
					return exp;
				}
			}
			// nothing here
			return 0;
		}

		this.expand = function(pid, id, cnt) {
			// special treatment for the root node without pid
			if( id == this.rid ) {
				// not registered yet
				if(!this.reg[id]) {
					// registar expanded = own children
					this.reg[id] = { exp:cnt, cnt:cnt };
				}
				// increase total of expanded nodes
				this.cnt += this.reg[id].exp;
				return;
			}
			dig_expand(this.reg, pid, id, cnt);
			console.log(this.rog);
		}

		this.collapse = function(pid, id, cnt) {
			// special treatment for the root node without pid
			if( id == this.rid ) {
				// not registered yet is not possible here!
				if(!this.reg[id]) { console.log('REGISTER COLLAPSE ERROR'); }
				// decrease total of expanded nodes
				this.cnt -= this.reg[id].exp;
				return;
			}
//			dig_collapse(this.reg, pid, id, cnt);
		}
	}
===========================================================================================================
===========================================================================================================
===========================================================================================================

