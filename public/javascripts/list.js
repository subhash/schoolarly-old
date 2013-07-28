// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery(document).ready(function(){
	jQuery.noConflict();
    applyListFilters();
});

function applyListFilters(){
    jQuery('#sharings').jplist({
        
            items_box: '.list',
            item_path: '.list-item',
            
            redraw_callback: function(){
            	    applyPrettyPhoto();
            },
            
            panel_path: '.panel' //cookies
            ,
            cookies: false,
            expiration: -1 //cookies expiration in days (-1 = cookies expire when browser is closed)
            ,
            cookie_name: 'jplist-div-layout',
            control_types: {
                'reset': {
                    class_name: 'control_reset',
                    options: {}
                },
                'cb_filters': {
                    class_name: 'control_checkbox_filters',
                    options: {}
                },
                'default_sort': {
					class_name: 'control_default_sort',
					options: {}
				}
            }
        });
}

