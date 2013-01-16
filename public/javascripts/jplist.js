/**
 * @license jQuery jPList Plugin ##VERSION## 
 * Copyright 2012 Miriam Zusin. All rights reserved.
 * To use this file you must to buy a licence at http://codecanyon.net/user/no81no/portfolio 
 */
 
(function($){
	'use strict';	
	/**
    * jQuery definition to anchor JsDoc comments.
    * @see <a href="http://jquery.com/" title="" target="_blank">jquery.com</a>
    * @name jQuery
    * @class jQuery Library
    */
	 
	/**
    * jQuery 'fn' definition to anchor JsDoc comments.
    * @see <a href="http://jquery.com/" title="" target="_blank">jquery.com</a>
    * @name fn
    * @class jQuery Library
    * @memberOf jQuery
    */	
	 
	/** 
	* jplist constructor 
	* @param {Object} user_options - jplist user options
	* @param {jQueryObject} $this - jplist container
	* @constructor 
	*/
	var init = function(user_options, $this){
		
		var self = {};
		
		self.options = $.extend(true, {	
		
			//main options
			items_box: '.list'
			,item_path: '.list-item'
			,panel_path: '.panel'
			,no_results: ".jplist-no-results"	
			,redraw_callback: ""
			
			//animate to top
			,animate_to_top: '' //auto - top panel, html, body
			,animate_to_top_duration: 1000
						
			//events
			,ask_event: 'jplist_ask' //event from panel to controller: ask to rebuild item container's html
			,answer_event: 'jplist_answer' //event from controller to panel after html rebuild
			,force_ask_event: 'jplist_force_ask' //event to panel -> panel sends ask event
			,restore_event: 'jplist_restore' //event to panel -> restore panel from event data (statuses array)
			,status_event: 'jplist_status' //event to panel -> get all statuses and merge them with the given status, then send ask event
			
			//cookies
			,cookies: false
			,expiration: -1 //cookies expiration in days (-1 = cookies expire when browser is closed)
			,cookie_name: 'jplist'
			
			//panel controls
			,control_types: {
			
				'drop-down':{
					class_name: 'control_dropdown'
					,options: {}
				}
				
				,'placeholder':{
					class_name: 'control_placeholder'
					,options: {
						//paging
						paging_length: 7
						
						//arrows
						,prev_arrow: '&lt;'
						,next_arrow: '&gt;'
						,first_arrow: '&lt;&lt;'
						,last_arrow: '&gt;&gt;'
					}
				}
				
				,'label':{
					class_name: 'control_label'
					,options: {}
				}
				
				,'textbox':{
					class_name: 'control_textbox' 
					,options: {
						ignore: '[~!@#$%^&*\(\)+=`\'"\/\\_]+' //[^a-zA-Z0-9]+ not letters/numbers
						/* need to escape / . * + ? | ( ) [ ] { } \							*/							
					}
					//,cookies: false
				}
			}
			
		}, user_options);
			
		//init controller		
		self.controller = new $.fn.jplist.controller($this, self.options);		
		
		return jQuery.extend(this, self); 
	};
	
	/**
	* API: sort		
	*/
	init.prototype.sort = function(control_name, path, type, order){
	
		var status
			,data;
		
		data = {
			path: path
			,type: type
			,order: order
		};
				
		status = new jQuery.fn.jplist.status(control_name, 'sort', 'drop-down', data);
		
		//send status event		
		this.controller.panel.jplist_box.trigger(this.controller.options.status_event, [status]);
	};
	
	/**
	* API: items per page		
	*/
	init.prototype.items_per_page = function(control_name, number){
	
		var status
			,data;
		
		data = {
			number: number
		};
				
		status = new jQuery.fn.jplist.status(control_name, 'paging', 'drop-down', data);
		
		//send status event		
		this.controller.panel.jplist_box.trigger(this.controller.options.status_event, [status]);
	};
	
	/**
	* API: filter by path		
	*/
	init.prototype.filter_path = function(control_name, path){
	
		var status
			,data;
		
		data = {
			path: path
			,filter_type: 'path'
		};
				
		status = new jQuery.fn.jplist.status(control_name, 'filter', 'drop-down', data);
		
		//send status event		
		this.controller.panel.jplist_box.trigger(this.controller.options.status_event, [status]);
	};
	
	/**
	* API: filter by text		
	*/
	init.prototype.filter_text = function(control_name, text, path){
	
		var status
			,data;
		
		data = {
			value: text
			,path: path
			,filter_type: 'text'
			,ignore: ''
		};
				
		status = new jQuery.fn.jplist.status(control_name, 'filter', 'textbox', data);
		
		//send status event		
		this.controller.panel.jplist_box.trigger(this.controller.options.status_event, [status]);
	};
	
	/**
	* API: jump to page		
	*/
	init.prototype.jump_page = function(control_name, page){
	
		var status
			,data
			,radix = 10
			,current_page;
		
		//get current page
		current_page = parseInt(page, radix);
		
		if(!isNaN(current_page) &&
		   current_page > 0){
		   
			data = {
				current_page: current_page - 1
			};
					
			status = new jQuery.fn.jplist.status(control_name, 'paging', 'placeholder', data);
			
			//send status event		
			this.controller.panel.jplist_box.trigger(this.controller.options.status_event, [status]);
		}
	};
	
	/** 
	* jPList main contructor
	* @example
	* <pre>
	* $('#demo').jplist({	
	*	items_box: '.list' 
	*	,item_path: '.list-item'
	*	,panel_path: '.panel'
	*	,cookies: true
	* });
	* </pre>
	* @param {Object} user_options - jplist user options
	* @name jplist
    * @class jQuery jPList Plugin
    * @memberOf jQuery.fn	
	*/
	jQuery.fn.jplist = function(user_options){
	
		return this.each(function(){
			var self = new init(user_options, $(this));
			$(this).data('jplist', self);
		});
	};
})(jQuery);