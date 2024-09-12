// vim: ts=4:sw=4:nu:fdc=1:nospell

Ext.namespace('ktm');

ktm.KTstart = function() {

///////////////////////////////////////////////////////////////////////////////
// TV Kanäle / Radio Frequenzen
///////////////////////////////////////////////////////////////////////////////

	var kt_kafre_chc = new Ext.grid.CheckColumn({
			 header: 'Radio FM'
			,dataIndex: 'isr'
			,width: 60
	});

    var kt_kafre_gr = new ktm.EditorGrid({
		 url: ktm.ASR+'/kfext'
		,root: 'kf'
		,record: [
			 { name:'uidx', type:'int' }
			,{ name:'kan', type:'string' }
			,{ name:'fq1', type:'float' }
			,{ name:'fq2', type:'float' }
			,{ name:'mfq', type:'float' }
			,{ name:'btg', type:'float' }
			,{ name:'isr', type:'bool' }
		]
		,columns: [
			 {header:'ID' ,dataIndex:'uidx' ,sortable:false ,width:30 ,menuDisabled:true }
			,{id:'KAN' ,header:'Kennung' ,dataIndex:'kan' ,sortable:true ,editor:new Ext.form.TextField({allowBlank:false})}
			,kt_kafre_chc
			,{header:'Frequenz 1' ,dataIndex:'fq1' ,sortable:true ,width:80 ,editor:new Ext.form.TextField({allowBlank:false})}
			,{header:'Mittelfreq.' ,dataIndex:'mfq' ,sortable:true ,width:80 ,editor:new Ext.form.TextField({allowBlank:true})}
			,{header:'Frequenz 2' ,dataIndex:'fq2' ,sortable:true ,width:80 ,editor:new Ext.form.TextField({allowBlank:true})}
			,{header:'Bildträgerfreq.' ,dataIndex:'btg' ,sortable:true ,width:80 ,editor:new Ext.form.TextField({allowBlank:true})}
		]
		,title: 'Kanal/Frequenz'
		,iconCls: 'tabico'
		,layout:'fit'
		,autoWidth: true
		,autoScroll: true
//		,width: ktm.app.ktpanWidth
//		,height: ktm.app.ktpanHeight
		,plugins: kt_kafre_chc
		,autoExpandColumn: 'KAN'
		,pagerLimit: 25
	}); //EO kt_kafre_gr

///////////////////////////////////////////////////////////////////////////////
// Kanaltabelle
///////////////////////////////////////////////////////////////////////////////

	var sb_kanaltabelle_kan = new ktm.KanalChooser({
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

    var kt_kanaltabelle_gr = new ktm.EditorGrid({
		 url: 'dummy'
		,root: 'kt'
		,record: [
			 { name:'sqid', type:'int' }
			,{ name:'sbid', type:'int' }
			,{ name:'uidx', type:'int' }
			,{ name:'pgid', type:'int' }
			,{ name:'kfid', type:'int' }
			,{ name:'pgfid', type:'int' }
			,{ name:'nam', type:'string' }
			,{ name:'pgt', type:'string' }
			,{ name:'kfk', type:'string' }
		]
		,nosend: [ 'kfk' ]
		,columns: [
//[[
			 {header:'SQID' ,dataIndex:'sqid' ,width:30 ,menuDisabled:true ,sortable:false}
			,{header:'SBID' ,dataIndex:'sbid' ,width:30 ,menuDisabled:true ,sortable:false}
			,{header:'KTID' ,dataIndex:'uidx' ,width:30 ,menuDisabled:true ,sortable:false}
			,{header:'PGID' ,dataIndex:'pgid' ,width:30 ,menuDisabled:true ,sortable:false}
			,{header:'KFID' ,dataIndex:'kfid' ,width:30 ,menuDisabled:true ,sortable:false}
			,{header:'PFID' ,dataIndex:'pgfid' ,width:30 ,menuDisabled:true ,sortable:false},
//]]
			 {id:'NAM' ,header:'Programm' ,css:'background-color: #dddddd;' ,dataIndex:'nam' ,width:140 ,menuDisabled:true ,sortable:true}
			,{header:'Typ' ,css:'background-color: #dddddd;' ,dataIndex:'pgt' ,width:80 ,menuDisabled:true ,sortable:true}
			,{header:'Kanal / Freq' ,css:'background-color: #ddffdd;' ,dataIndex:'kfk' ,width:80 ,menuDisabled:true ,sortable:true ,editor:sb_kanaltabelle_kan.kcCombo ,renderer:sb_kanaltabelle_kan.kcRender}
		]
		,onlyUpdate: true
		,title: 'Kanaltabelle'
		,iconCls: 'tabico'
		,layout:'fit'
		,autoWidth: true
		,autoScroll: true
//		,width: ktm.app.ktpanWidth
//		,height: ktm.app.ktpanHeight
//		,autoExpandColumn: 'NAM'
//		,pagerLimit: 25
		,addTB:[{
			 text: 'Laden'
			,iconCls: 'icon-apptile'
			,handler: function () {
				var node = ktm.app.getCSQ();
				if(!node) { return; }
				kt_kanaltabelle_gr.getStore().proxy.conn.url = ktm.ASR+'/ktext/'+node.attributes.id;
				kt_kanaltabelle_gr.getStore().load({ callback: function(rec, opt, ok) {
					if(!ok) { kt_kanaltabelle_gr.getStore().removeAll(); }
				}});
			}
		}]
	}); //EO kt_kanaltabelle_gr

	kt_kanaltabelle_gr.on('beforeedit', sb_kanaltabelle_kan.kcBeforeEdit);

///////////////////////////////////////////////////////////////////////////////
// TabPanel for all the stuff
///////////////////////////////////////////////////////////////////////////////
/*
	var kt_main_tabs = new Ext.TabPanel({
		 renderTo:'tabpanel-kt'
		,id:'ktm-kt-main'
		,region: 'west'
		,split: true
//		,layout: 'fit'
		,border: true
		,width: ktm.app.ktpanWidth

		,resizeTabs:true
//		,plain: true
//		,minTabWidth: 115
		,tabWidth:135
		,layoutOnTabChange: true
		// ensures that we can see other tabs too
		,deferredRender: false
//		,autoWidth: true
		,autoHeight: true
		,defaults: {
			 autoScroll:false
			 // hideMode: "offsets" fixes disapearing of the cursor
			,hideMode:"offsets"
		}
	});

	kt_main_tabs.add( kt_kanaltabelle_gr );
	kt_main_tabs.add( kt_kafre_gr );

	kt_main_tabs.doLayout();

	kt_main_tabs.activate( kt_kanaltabelle_gr );
*/
	return {
		 tab1: kt_kanaltabelle_gr
		,tab2: kt_kafre_gr
	}

//Ext.ux.Toast.msg('Event: action', 'Failure ROW: <b>{0}</b>, ACTION: <b>{1}</b>', row, action);

};
