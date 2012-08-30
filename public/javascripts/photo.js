// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery.noConflict();
jQuery(document).ready(function(){
    applyPrettyPhoto();
});

function applyPrettyPhoto(){
    jQuery("a[rel^='prettyPhoto']").prettyPhoto({
        theme: 'facebook',
        social_tools: false,
        allow_resize: true,
        default_width: 900,
        overlay_gallery: true
    });
}

