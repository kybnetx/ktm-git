Ext.namespace("Ext.ux");
Ext.namespace("Ext.ux.tree");

Ext.ux.tree.ParentLoader = function(config) {
  this.baseParams = {};
  this.test='testing';
  this.requestMethod = "POST";
  Ext.apply(this, config);
  this.addEvents({
    "beforeload" : true,
    "load" : true,
    "loadexception" : true
  });
  Ext.ux.tree.ParentLoader.superclass.constructor.call(this);
};

Ext.extend(Ext.ux.tree.ParentLoader, Ext.tree.TreeLoader, {

  getChildren: function(parent){
   var items = new Array();
   this.store.each(function(rec) {
     if(rec.get('parent')==parent) items[items.length]=rec;
   });
   return items;
  },
  
  hasChildren: function(id){
    return (this.getChildren(id).length > 0);
  },

  addChildren: function(parent) {
    Ext.each(this.getChildren(parent.attributes.id), function(rec){
      var attr = {};
      if(this.baseAttrs) Ext.applyIf(attr, this.baseAttrs);
      if(this.applyLoader !== false) attr.loader = this;
      Ext.each(this.dataFields, function(item){
        attr[item] = rec.get(item);
      });
      var node =(this.hasChildren(attr.id)?
        new Ext.tree.AsyncTreeNode(attr):
        new Ext.tree.TreeNode(attr));
      parent.appendChild(node);
    },this);
  },

  load : function(node, callback){
    if(!!this.store) {
      this.addChildren(node);
      if(typeof callback == "function") callback();
    }else{
      this.requestData(node, callback);
    }
  },

  requestData : function(node, callback){
    if(this.fireEvent("beforeload", this, node, callback) !== false){
      this.store = new Ext.data.JsonStore({
        url: this.dataUrl,
        root: this.dataRoot,
        fields: this.dataFields
      });
      this.store.on('load', this.handleResponse.createDelegate(this, [node, callback], 1));
      this.store.on('loadexception', this.handleFailure.createDelegate(this, [node, callback], 1));
      this.store.load();
    }else{
      if(typeof callback == "function")callback();
    }
   },
   
   processResponse : function(response, node, callback){
     try {
       this.load.call(this, node, callback);
      }catch(e){
        this.handleFailure(response);
      }
    }, 
   
   handleResponse : function(response, node, callback){
     this.transId = false;
     this.processResponse(response, node, callback); 
     this.fireEvent("load", this, node, response);
   },

   handleFailure : function(response, node, callback){
     this.transId = false;
     this.fireEvent("loadexception", this, node);
     if(typeof callback == "function") callback(this, node, response);
   }

});
