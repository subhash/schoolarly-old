(function($){
	'use strict';		
	
	/** 
	* default sort control
	* @type {Object} 
	* @name control_default_sort
    * @class control_default_sort
    * @memberOf jQuery.fn.jplist
	*/
	jQuery.fn.jplist.control_default_sort = {};
		
	/**
	* get current control status
	* @param {boolean} is_default - if true, get default (initial) control status; else - get current control status
	* @param {jQuery.fn.jplist.panel_control} control
	* @return {jQuery.fn.jplist.status}
	* @memberOf jQuery.fn.jplist.control_default_sort
	*/
	jQuery.fn.jplist.control_default_sort.get_status = function(is_default, control){
		
		var data
			,status;	
						
		data = {
			path: control.jq_control.attr('data-path')
			,type: control.jq_control.attr('data-type')
			,order: control.jq_control.attr('data-order')
		};
		
		status = new jQuery.fn.jplist.status(control.name, control.action, control.type, data);
		
		return status;			
	};	
	
})(jQuery);

