// vim: ts=4:sw=4:nu:fdc=4:nospell

/*
 * Ext JS Library 2.0.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */



// === Ext.grid.RowTableExpander ===================================================

Ext.grid.RowTableExpander = function(config){

	// default table identifier
	this.tabId = 'ux-rowtabex';
	// default identifier suffix (for different table layouts)
	this.clSfx = '';
	// default content if there is no data for the table
	this.noData = 'No data!'

    Ext.apply(this, config);

	if(this.clSfx) {
		this.clSfx += '-';
	}
	// table class
	this.tabCls = this.tabId + '-' + this.clSfx + 'tab';
	// table header class
	this.headCls = this.tabId + '-' + this.clSfx + 'head';
	// table content class
	this.rowCls = this.tabId + '-' + this.clSfx + 'row';
	// single column class, used to set column width
	this.colCls = this.tabId + '-' + this.clSfx + 'col';
	// row stripes class, used to alter row background
	this.strCls = this.tabId + '-' + this.clSfx + 'str';

    this.addEvents({
        beforeexpand : true,
        expand: true,
        beforecollapse: true,
        collapse: true
    });

    Ext.grid.RowTableExpander.superclass.constructor.call(this);

	// current class of the row
	// (-expanded, -collapsed, -loading)
    this.state = {};

	// table markup with data
	// (created and ready to show)
    this.bodyContent = {};

	// table data only - no expansion till loaded
	this.tableLoaded = {};

	// protection against mad-multi-clicks
	// (kinda request semaphore)
	this.tableRequested = {};
};

Ext.extend(Ext.grid.RowTableExpander, Ext.util.Observable, {
    header: "",
    width: 20,
    sortable: false,
    fixed: true,
    menuDisabled: true,
    dataIndex: '',
    id: 'expander',

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
		return '<div class="x-grid3-row-expander">&#160;</div>';
    },

	makeTable : function(table, ok, id) {

		if(!ok) {
			this.bodyContent[id] =
				'<p class="'+this.headCls+'">'+this.noData+'</p><br>';
			return;
		}

		var rows = table.length;
		var cols = table[0].length;

		// table def start here
		var tt = '<table id="'+this.tabId+'-'+id+'" class="'+this.tabCls+'">';
		// table header
		tt += '<tr>';
		for(var col = 0; col < cols; col++) {
			tt += '<th class="'+this.headCls+' '+this.colCls+col+'">'+table[0][col]+'</th>';
		}
		tt += '</tr>';
		// table content
		for(var row = 1; row < rows; row++) {
			tt += '<tr>';
			for(var col = 0; col < cols; col++) {
				tt += '<td class="'+this.rowCls+' '+this.strCls+(row%2)+'">'+table[row][col] +'</td>';
			}
			tt += '</tr>';
		}
		tt += '</table><br>';

		this.bodyContent[id] = tt;
	},

	loadTableAndExpand : function(record, rowidx, expand) {
		var reqid = this.tableRequested[record.id];
		if( reqid ) { return reqid; }
		reqid = Ext.Ajax.request({
			 method: 'GET'
			,url: this.url + (this.datakey ? '/'+record.get(this.datakey) : '')
			,headers: { 'Content-Type': 'text/x-json' }
			,scope: this
			,callback: function (opt, ok, r) {
				var tabdata = Ext.util.JSON.decode(r.responseText);
				this.makeTable(tabdata, ok, record.id);
				this.tableLoaded[record.id] = tabdata;
				this.tableRequested[record.id] = false;
				if(expand) {
					this.expandRow(this.grid.view.getRow(rowidx));
				}
			 }
		});
		this.tableRequested[record.id] = reqid;
		return reqid;
	},

    getRowClass : function(record, rowIndex, p, ds){
        p.cols = p.cols-1;
		if(!this.state[record.id]) {
			this.state[record.id] = 'x-grid3-row-collapsed';
		}
		return this.state[record.id];
    },

    getBodyContent : function(record, index) {
        return this.bodyContent[record.id];
    },

	reloadTable : function(record, rowIndex, expand) {
		this.tableLoaded[record.id] = false;
		if(expand) {
			this.expandRow(rowIndex);
			return;
		}
		this.loadTableAndExpand(record, rowIndex, false);
	},

    onMouseDown : function(e, t){
        if(t.className == 'x-grid3-row-expander'){
            e.stopEvent();
            var row = e.getTarget('.x-grid3-row');
            this.toggleRow(row);
        }
    },

    beforeExpand : function(record, body, rowIndex){
        if(this.fireEvent('beforeexpand', this, record, body, rowIndex) !== false){
			if (this.tableLoaded[record.id]) {
				body.innerHTML = this.getBodyContent(record, rowIndex);
				return true;
			}
			this.loadTableAndExpand(record, rowIndex, true);
            row = this.grid.view.getRow(rowIndex);
			Ext.fly(row).replaceClass(this.state[record.id], 'x-grid3-row-loading');
            this.state[record.id] = 'x-grid3-row-loading';
        }
		return false;
    },

    toggleRow : function(row){
        if(typeof row == 'number'){
            row = this.grid.view.getRow(row);
        }
        var record = this.grid.store.getAt(row.rowIndex);
		var cc = this.state[record.id];
		if(cc == 'x-grid3-row-collapsed') {
			this.expandRow(row);
		} else if(cc == 'x-grid3-row-expanded') {
			this.collapseRow(row);
		}
	},

    expandRow : function(row){
        if(typeof row == 'number'){
            row = this.grid.view.getRow(row);
        }
        var record = this.grid.store.getAt(row.rowIndex);
        var body = Ext.DomQuery.selectNode('tr:nth(2) div.x-grid3-row-body', row);
        if(this.beforeExpand(record, body, row.rowIndex)){
            Ext.fly(row).replaceClass(this.state[record.id], 'x-grid3-row-expanded');
            this.state[record.id] = 'x-grid3-row-expanded';
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
            Ext.fly(row).replaceClass(this.state[record.id], 'x-grid3-row-collapsed');
            this.state[record.id] = 'x-grid3-row-collapsed';
            this.fireEvent('collapse', this, record, body, row.rowIndex);
		}
	}
}); // ENDOF Ext.grid.RowTableExpander



// === Ext.grid.CheckColumn ===================================================

Ext.grid.CheckColumn = function(config){
    Ext.apply(this, config);
    if(!this.id){
        this.id = Ext.id();
    }
    this.renderer = this.renderer.createDelegate(this);
};

Ext.grid.CheckColumn.prototype ={
    init : function(grid){
        this.grid = grid;
        this.grid.on('render', function(){
            var view = this.grid.getView();
            view.mainBody.on('mousedown', this.onMouseDown, this);
        }, this);
    },

    onMouseDown : function(e, t){
        if(t.className && t.className.indexOf('x-grid3-cc-'+this.id) != -1){
            e.stopEvent();
            var index = this.grid.getView().findRowIndex(t);
            var record = this.grid.store.getAt(index);
			// a little hack to be able to disable checkbox and show it disabled
			if(record.get(this.disableIndex)) { return; }
            record.set(this.dataIndex, !record.data[this.dataIndex]);
        }
    },

    renderer : function(v, p, record){
        p.css += ' x-grid3-check-col-td';
		// a little hack to be able to disable checkbox and show it disabled
		if(record.get(this.disableIndex)) {
        	return '<div class="icon-nono x-grid3-cc-'+this.id+'">&#160;</div>';
		}
        return '<div class="x-grid3-check-col'+(v?'-on':'')+' x-grid3-cc-'+this.id+'">&#160;</div>';
    }
}; // ENDOF Ext.grid.CheckColumn



// === Ext.grid.RadioColumn ===================================================

Ext.grid.RadioColumn = function(config){
    Ext.apply(this, config);
    if(!this.id){
        this.id = Ext.id();
    }
    this.renderer = this.renderer.createDelegate(this);
};

Ext.grid.RadioColumn.prototype = {
    init : function(grid){
        this.grid = grid;
        this.grid.on('render', function(){
            var view = this.grid.getView();
            view.mainBody.on('mousedown', this.onMouseDown, this);
        }, this);
    },

    onMouseDown : function(e, t){
        if(t.className && t.className.indexOf('x-grid3-cc-'+this.id) != -1){
            e.stopEvent();
            var index = this.grid.getView().findRowIndex(t);
            var record = this.grid.store.getAt(index);
            record.set(this.dataIndex, this.inputValue);
        }
    },

    renderer : function(v, p, record){
        p.css += ' x-grid3-check-col-td'; 
        return '<div class="x-grid3-check-col'+(v == this.inputValue?'-on':'')+' x-grid3-cc-'+this.id+'"> </div>';
    }
}; // ENDOF Ext.grid.RadioColumn
