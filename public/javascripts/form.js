// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery.noConflict();

jQuery(document).ready(function(){

    jQuery('.fields *').focus(function(){
        jQuery(this).parents('p').addClass('focused');
    }).blur(function(){
        jQuery(this).parents('p').removeClass('focused');
    });
});
