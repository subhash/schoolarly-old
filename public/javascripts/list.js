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
                class_name: 'Reset',
                options: {}
            }            //CheckboxFilter - checkbox filter control 
            ,
            'checkbox-filters': {
                class_name: 'CheckboxFilter',
                options: {}
            }            //CheckboxGroupFilter - group of checkboxes control 
            ,
            'checkbox-group-filter': {
                class_name: 'CheckboxGroupFilter',
                options: {}
            },
            'default-sort': {
                class_name: 'DefaultSort',
                options: {}
            }
        }
    });
}

