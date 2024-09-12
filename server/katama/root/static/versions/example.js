// vim: ts=4:sw=4:nu:fdc=1:nospell

Ext.onReady(function(){

	Ext.QuickTips.init();

	var xg = Ext.grid;
	
	var dummyData = [
	    ['3m Co', 'Manufacturing', 'Lorem ipsum blah'],
	    ['Alcoa Inc', 'Manufacturing', 'Lorem ipsum blah'],
	    ['Altria Group Inc', 'Manufacturing', 'Lorem ipsum blah'],
	    ['American Express Company', 'Finance', 'Lorem ipsum blah'],
		['American International Group, Inc.', 'Services', 'Lorem ipsum blah']
	];

	// shared reader
	var reader = new Ext.data.ArrayReader({}, [
	   {name: 'company'},
	   {name: 'industry'},
	   {name: 'desc'}
	]);

	// row expander
	var expander = new xg.RowExpander({
		tpl : new Ext.Template(
  			'<br>',
			'<p><b>Company:</b> {company}</p><br>',
			'<p><b>Summary:</b> {desc}</p>',
  			'<br>'
		)
	});

	var actions = new Ext.ux.grid.RowActions({
 		header: 'Actions',
		autoWidth: false,
		actions:[{
			iconCls:'icon-add',
			tooltip:'ADD SOMETHING'
		},{
	 		iconCls:'icon-del',
			tooltip:'DELETE SOMETHING'
		}]
	});

	actions.on({
		action: function(grid, record, action, row, col) {
			Ext.MessageBox.alert('Action', 'To do: '+action+' on row '+row);
		}
	});

	// EXPANDER ONLY ColumnModel
	var colmod_1 = new xg.ColumnModel([
			 expander
			,{id:'company', header: "Company", width: 80, sortable: true, dataIndex: 'company', editor: new Ext.form.TextField({ allowBlank: false }) }
			,{id:'industry', header: "Industry", width: 80, sortable: true, dataIndex: 'industry'}
	]);

	// ACTIONS ONLY ColumnModel
	var colmod_2 = new xg.ColumnModel([
			 {id:'company', header: "Company", width: 80, sortable: true, dataIndex: 'company', editor: new Ext.form.TextField({ allowBlank: false }) }
			,{id:'industry', header: "Industry", width: 80, sortable: true, dataIndex: 'industry'}
			,actions
	]);

	// EXPANDER + ACTIONS ColumnModel
	var colmod_3 = new xg.ColumnModel([
			 expander
			,{id:'company', header: "Company", width: 80, sortable: true, dataIndex: 'company', editor: new Ext.form.TextField({ allowBlank: false }) }
			,{id:'industry', header: "Industry", width: 80, sortable: true, dataIndex: 'industry'}
			,actions
	]);

	// GRID
	var grid_expand = new xg.EditorGridPanel({
		 store: new Ext.data.Store({
			reader: reader,
			data: dummyData
		})

// ------ TESTCASES CHANGE HERE -------------------

// --- EXPANDER ONLY ------------------------------
//		,cm: colmod_1
/*
		,columns: [
			 expander
			,{id:'company', header: "Company", width: 80, sortable: true, dataIndex: 'company', editor: new Ext.form.TextField({ allowBlank: false }) }
			,{id:'industry', header: "Industry", width: 80, sortable: true, dataIndex: 'industry'}
		]
		,plugins: expander
*/


// --- ACTIONS ONLY -------------------------------
//		,cm: colmod_2
/*
		,columns: [
			 {id:'company', header: "Company", width: 80, sortable: true, dataIndex: 'company', editor: new Ext.form.TextField({ allowBlank: false }) }
			,{id:'industry', header: "Industry", width: 80, sortable: true, dataIndex: 'industry'}
			,actions
		]
		,plugins: actions
*/


// --- EXPANDER + ACTIONS -------------------------
//		,cm: colmod_3
		,columns: [
			 expander
			,{id:'company', header: "Company", width: 80, sortable: true, dataIndex: 'company', editor: new Ext.form.TextField({ allowBlank: false }) }
			,{id:'industry', header: "Industry", width: 80, sortable: true, dataIndex: 'industry'}
			,actions
		]
		,plugins: [ actions, expander ]


// ------------------------------------------------

		,viewConfig: {
			forceFit: true
		}

		,width: 600
		,height: 300
		,collapsible: true
		,animCollapse: false
		,title: 'Grid RowExpander and Grid RowActions'
		,renderTo: 'grid-example'
	});

}); // END OF onReady



// ============================================================================

// RowExpander extension from Ext examples
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
		if(!this.enableCaching){
			return this.tpl.apply(record.data);
		}
		var content = this.bodyContent[record.id];
		if(!content){
			content = this.tpl.apply(record.data);
			this.bodyContent[record.id] = content;
		}
		return content;
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
		return '<div class="x-grid3-row-expander">&#160;</div>';
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
}); // END OF RowExpander extension from Ext examples
