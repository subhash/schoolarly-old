/*
 * version: 2.0.3
 * package: OrangeBox
 * author: David Paul Hamilton - http://orangebox.davidpaulhamilton.net
 * copyright: Copyright (c) 2011 David Hamilton / DavidPaulHamilton.net All rights reserved.
 * license: GNU/GPL license: http://www.gnu.org/copyleft/gpl.html
 */
if (typeof(oB) !== 'undefined') { $.error( 'OrangeBox: Variable "oB", used by OrangeBox, is already defined');  }
else {
    var oB;
        (function($) {
        oB = {
            progress: '',
            playing: '',
            slideshowTimer: '',
            slideshow: '',
            docHeight: '',
            docWidth: '',
            controlTimer: '',
            settings: {
                autoplay : false,
                fadeControls: false,
                fadeCaption: true,
                keyboardNavigation: true,
                orangeControls: false,
                showClose: true,
                showDots: false,
                showNav: true,
                addThis: true,
                notFound: 'Not Found',
                overlayOpacity: 0.95,
                contentBorderWidth: 4,
                contentMinWidth: 200,
                contentMinHeight: 100,
                iframeWidth: 0.75,
                iframeHeight: 0.75,
                inlineWidth: 0.5,
                inlineHeight: 0,
                maxImageWidth: 0.75,
                maxImageHeight: 0.75,
                maxVideoWidth: 640,
                maxVideoHeight: 390,
                fadeTime: 200,
                slideshowTimer: 3000
            },
            methods: {
                init : function( options ) {
                    if (!$('#ob_window').length) {
                        if ( options ) { $.extend( oB.settings, options ); }
                            if ( oB.settings.addThis ) { $.getScript('http://s7.addthis.com/js/250/addthis_widget.js#pubid=ra-4dd42f2b5b9fc332'); }
                            return this.each(function() {
                            $(this).click(function(e) {
                                e.preventDefault();
                                oB.methods.create(this);
                            });
                        });             
                    }
                    return false;
                },
                create : function( obj, options ) {
                    if ( options ) { $.extend( oB.settings, options ); }
                    if (!obj) { obj = this; }
                    var dotnav = $('<ul id="ob_dots"></ul>');
                    var mainObject;
                    var rel = $(obj).attr('rel');
                    var gallery;
                    oB.galleryArray=new Array();
                    oB.slideshow = true;
                    oB.docHeight = $(document).height();
                    oB.docWidth = $(document).width();
                    if(!jQuery().orangeControls) { oB.settings.orangeControls = false; }
                //Check for unique elements
                    function uniqueCheck(z, h) {
                        var i;
                        for (i=0; i < oB.galleryArray.length; i++) {
                            var x = oB.galleryArray[i].data('ob_data').ob_href;
                            if (h && x === z.attr('id')) { return false; }
                            else if(x === z.attr('href')){ return false; }
                        }
                        return true;
                    }
                    
                //Gallery
                    if (rel && rel.indexOf("[")) { gallery = rel.substring(rel.indexOf("[") + 1, rel.indexOf("]")); }
                    if (gallery) { 
                        var a = 0;
                        var objectMatch = 'a[rel*=\'lightbox[' + gallery + ']\']';                      
                        $(objectMatch).each(function(){
                            var x = uniqueCheck($(this), false);
                            oB.methods.setupData($(this), false, a);
                            var z = $(this).data('ob_data').ob_contentType;
                            if (x && z !== false) { 
                                oB.galleryArray[a] = $(this);
                                if(oB.settings.showDots) { dotnav.append('<li id="ob_dot' + a + '"></li>'); }
                                if(z !== "image") { oB.slideshow = false; }
                                a++;
                            }
                        });
                        if ($('#ob_gallery').length > 0) {
                            $('#ob_gallery li.' + gallery).each(function() {
                                var x = uniqueCheck($(this), true);
                                oB.methods.setupData($(this), true, a);
                                var z = $(this).data('ob_data').ob_contentType;
                                if (x && z !== false) { 
                                    oB.galleryArray[a] = $(this);
                                    if(oB.settings.showDots) { dotnav.append('<li id="ob_dot' + a + '"></li>'); }
                                    if(z !== "image") { oB.slideshow = false; }
                                    a++;
                                }   
                            });
                        }
                    }                            
                    
                //Set Main Object
                    if ($(obj).attr('href') === "ob_hidden_set") {
                        mainObject = oB.galleryArray[0];
                        oB.methods.setupData(mainObject, true, 0);
                    }
                    else {
                        mainObject = $(obj);
                        oB.methods.setupData(mainObject, false, false);
                    }
                    if(!mainObject.data('ob_data').ob_contentType) { mainObject = oB.galleryArray[0]; }
                    
                //Check for Content Type
                    if(mainObject.data('ob_data').ob_contentType) {
                        
                    //Set Vars
                        var overlay = $('<div id="ob_overlay"></div>');
                        var container = $('<div id="ob_container"></div>');
                        var floater = $('<div id="ob_float"></div>');
                        var window = $('<div id="ob_window"></div>').click(function(e) { e.stopPropagation(); });
                        var close = $('<div title="close" class="ob_controls ob_cs" id="ob_close"></div>').click(function() {
                            oB.methods.destroy(oB.settings);
                        });
                        var title = $('<div id="ob_title"></div>');
                        var navRight = $('<a class="ob_nav ob_controls ob_cs" id="ob_right"><span class="ob_cs" id="ob_right-ico"></span></a>');
                        var navLeft = $('<a class="ob_nav ob_controls ob_cs" id="ob_left"><span class="ob_cs" id="ob_left-ico"></span></a>');
                        var content = $('<div id="ob_content"></div>').css({
                            "border-width": oB.settings.contentBorderWidth,
                            "min-height": oB.settings.contentMinHeight,
                            "min-width": oB.settings.contentMinWidth
                        });
                        oB.playing = oB.settings.autoplay;
                        oB.progress = null;
                        
                    //Set overlay CSS
                        overlay.css({
                            "opacity" : oB.settings.overlayOpacity,
                            "min-height": $(document).height(),
                            "min-width": $(document).width()
                            });
                        
                    //if IE 6                   
                        if (typeof document.body.style.maxHeight === "undefined") { 
                            $("body","html").css({height: "100%", width: "100%"});
                        }
                        
                    //Click to Hide Modal
                        $("body").append(overlay.click(function() { oB.methods.destroy(oB.settings); }));
                        $("body").append(container.click(function() { oB.methods.destroy(oB.settings); }));
                        if(oB.settings.showClose) { window.append(close); }
                        window.append(content).append(title);
                        $("#ob_container").append(floater).append(window);
                        
                    //Show Overlay
                        overlay.show(oB.settings.fadeTime);
                        
                    //Listens for Escape
                        function handleEscape(e) {
                            if (oB.progress === null) {
                                if (e.keyCode === 27) {
                                    oB.methods.destroy(oB.settings);
                                }
                                else if (e.keyCode === 37) {
                                    oB.methods.slideshowPause();
                                    oB.methods.navigate(-1);
                                }
                                else if (e.keyCode === 39) {
                                    oB.methods.slideshowPause();
                                    oB.methods.navigate(1);
                                }
                            }
                        }
                        if(oB.settings.keyboardNavigation) {
                            $(document).keydown(handleEscape);
                        }
                        
                    //Initiate Navigation
                        if(oB.galleryArray.length > 0) {
                            
                        //Initiate OrangeControls
                            if(oB.settings.orangeControls && oB.galleryArray.length > 1) {
                                $(document).orangeControls();
                                $(document).bind('oc_right',function(){
                                    if(oB.progress === null){
                                        oB.methods.slideshowPause();
                                        oB.methods.navigate(1);
                                    }
                                });
                                $(document).bind('oc_left',function(){
                                    if(oB.progress === null){
                                        oB.methods.slideshowPause();
                                        oB.methods.navigate(-1);
                                    }
                                });
                                $(document).bind('oc_pause',function(){
                                    $(document).orangeControls('update', {'play':true});
                                    oB.methods.slideshowPause();
                                });
                                $(document).bind('oc_play', function(){
                                    $(document).orangeControls('update', {'play':false});
                                    oB.methods.slideshowPlay();
                                });
                            }
                            
                        //Initiate Nav Arrows
                            if(oB.settings.showNav && oB.galleryArray.length > 1) {
                                window.append(navRight).append(navLeft);
                                navLeft.click( function (e) {
                                    if(oB.progress === null) {
                                        oB.methods.slideshowPause();
                                        e.stopPropagation();
                                        oB.methods.navigate(-1);
                                    }
                                });
                                navRight.click(function (e) {
                                    if(oB.progress === null) {
                                        oB.methods.slideshowPause();
                                        e.stopPropagation();
                                        oB.methods.navigate(1);
                                    }
                                });
                            }
                            
                        //Initiate Nav Dots
                            if(oB.settings.showDots && oB.galleryArray.length > 1) {
                                window.append(dotnav);
                                dotnav.find("li").click(function() {
                                    if(!$(this).hasClass('current') && oB.progress === null) {
                                        oB.methods.slideshowPause();
                                        var x = $(this).attr('id').substr(6);
                                        dotnav.find("li").removeClass('current');
                                        $(this).addClass('current');
                                        oB.methods.navigate("", x);
                                    }
                                });
                            }
                        }
                        
                    //Fire in the Hole
                        oB.methods.showContent(mainObject, true);
                    }
                },
                setupData : function( o, v, x ) {
                    var z;
                    var c = false;
                    var w = 0;
                    var h = 0;
                    var i;
                    var t = "";
                    if(typeof o.attr('title') !== "undefined") {t = o.attr('title');}
                    if(v) { z = o.attr('id'); }
                    else { z = o.attr('href'); }
                    if(z) {
                        if (z.match(/(width\=)|(height\=)/)) {
                            var heightIndex = z.indexOf("height=") + 7;
                            var widthIndex = z.indexOf("width=") + 6;
                            var heightString = z.substr(heightIndex);
                            var widthString = z.substr(widthIndex);
                            if(heightString.indexOf("&") > 0) { heightString = heightString.substr(0,heightString.indexOf("&")); }
                            if(widthString.indexOf("&") > 0) { widthString = widthString.substr(0,widthString.indexOf("&")); }
                            w = widthString;
                            h = heightString;
                        }
                        if (z.match(/\?iframe/)) { c = "iframe"; }
                        else if (z.match(/\.(?:jpg|jpeg|bmp|png|gif)$/)) { c = "image"; }
                        else if (z.match(/\.(?:mov|mp4|m4v)(\?.{6,}\&.{6,})?$/)) { c = "quicktime"; }
                        else if (z.match(/\.swf(\?.{6,}\&.{6,})?$/)) { c = "flash"; }
                        else if (z.match(/^http:\/\/\w{0,3}\.?youtube\.\w{2,3}\/watch\?v=[\w\-]{11}/)) { c = "youtube"; }
                        else if (z.match(/^http:\/\/\w{0,3}\.?vimeo\.com\/\d{1,10}/)) { c = "vimeo"; }
                        else if (z.match(/^#\w{1,}/)) { c = "inline"; }
                        else if (!z.match(/ob_hidden_set/)){ $.error( 'OrangeBox: Unsupported Media'); }
                        if (x === false) {
                            for (i=0; i < oB.galleryArray.length; i++) {
                                if (oB.galleryArray[i].data('ob_data').ob_href === z) {
                                    x = i;
                                }
                            }
                        }
                    }
                    o.data('ob_data', {
                        ob_height: h,
                        ob_width: w,
                        ob_index: x,
                        ob_contentType: c,
                        ob_href: z,
                        ob_title: t,
                        ob_linkText: o.attr('data-ob_linkText'),
                        ob_link: o.attr('data-ob_link'),
                        ob_caption: o.attr('data-ob_caption'),
                        ob_linkTarget: o.attr('data-ob_linkTarget'),
                        ob_share: o.attr('data-ob_share'),
                        ob_shareLink: o.attr('data-ob_shareLink')
                    });
                },
                destroy : function( options, x ) {
                    $(document).trigger('oB_closing');
                    if ( options ) { $.extend( oB.settings, options ); }
                    oB.methods.showLoad("stop");
                    clearTimeout(oB.controlTimer);
                    clearTimeout(oB.slideshowTimer);
                    clearTimeout(oB.scrollTimer);
                    if(oB.settings.orangeControls) { $(document).orangeControls('destroy', oB.settings.fadeTime); }
                    $(document).unbind("keydown").unbind("mousemove");
                    $('#ob_overlay').fadeOut(oB.settings.fadeTime, function() { $(this).remove().empty(); });
                    $('#ob_container').fadeOut(oB.settings.fadeTime, function() {
                        $(this).remove().empty();
                        $(document).trigger('oB_closed');
                        if(x && jQuery.isFunction(x)) { x(); }
                    });
                },
                showContent : function ( obj, initial ) {
                    var href = obj.data('ob_data').ob_href;
                    var title = obj.data('ob_data').ob_title;
                    var contentType = obj.data('ob_data').ob_contentType;
                    var content;
                    var currentIndex = obj.data('ob_data').ob_index;
                    var ob_caption = $('<div id="ob_caption"></div>').css({
                            "opacity" : 0.95
                        });
                    if(oB.settings.fadeCaption) {
                        ob_caption.hide();
                        $('#ob_content').hover(function(){
                            $('#ob_caption').stop().fadeTo(oB.settings.fadeTime, 0.95);
                        },function(){
                            $('#ob_caption').stop().fadeOut(oB.settings.fadeTime);
                        });
                    }
                    var isError = false;
                    $('#ob_overlay').css({ "height": oB.docHeight });
                    $('#ob_content').removeClass().addClass('content'+currentIndex);
                    
                //Start Preloader
                    oB.methods.showLoad();
                        
                //Set Modal Properties
                    function setModalProperties() {
                        var oH = content.outerHeight();
                        var oW = content.outerWidth();
                        var wH = oH + (oB.settings.contentBorderWidth*2);
                        var wW = oW + (oB.settings.contentBorderWidth*2);
                        var p = $(window).scrollTop();
                        var target = "";
                        var rel = "";
                        if(p === 0) { p = $(document).scrollTop(); }
                        if(p === 0) { p = window.pageYOffset; }
                        if(obj.data('ob_data').ob_linkText) {
                            if(obj.data('ob_data').ob_link){
                                if(obj.data('ob_data').ob_linkTarget === "_self") { target = 'target="_self"'; }
                                else { target = 'target="_blank"'; }
                                title = title+' <a href="'+obj.data('ob_data').ob_link+'" '+target+' '+rel+' >'+obj.data('ob_data').ob_linkText+'</a>';
                            }
                            else { title = title+' '+obj.data('ob_data').ob_linkText; }
                        }
                        $('#ob_title').append('<h3>' + title + '</h3>');
                        if(obj.data('ob_data').ob_caption) {
                            ob_caption.append('<p>'+obj.data('ob_data').ob_caption+'</p>');
                            $('#ob_content').append(ob_caption);
                        }
                    //Check for Mins
                        if(wH < oB.settings.contentMinHeight) { wH = oB.settings.contentMinHeight + (oB.settings.contentBorderWidth*2); }
                        if(wW < oB.settings.contentMinWidth) { wW = oB.settings.contentMinWidth + (oB.settings.contentBorderWidth*2); }
                        $("#ob_container").css({ "margin-top" : p });
                        $("#ob_window").css({ "height": wH, "width": wW });
                        $('#ob_float').css({ "margin-bottom": -($("#ob_window").outerHeight(true)) / 2 });
                        if (isError){ $('#ob_content').css({ "height": oH, "width": oW, "min-height": 0 }); }
                        else { $('#ob_content').css({ "height": wH - (oB.settings.contentBorderWidth*2), "width": wW - (oB.settings.contentBorderWidth*2), "min-height": oB.settings.contentMinHeight });
                        }
                    }
                    
                //Update Navigation
                    function setControls() {
                        if(oB.settings.showDots) {
                            $('#ob_dots').find('li').each(function(){
                                var i = 'ob_dot' + obj.data('ob_data').ob_index;
                                if($(this).attr('id') === i) { $(this).addClass('current'); }
                                else { $(this).removeClass('current'); }
                            });
                        }
                        clearTimeout(oB.controlTimer);
                        if(oB.settings.orangeControls) {
                            var oc_settings = { 'play' : true, 'play_active' : false, 'left_active' : false, 'right_active' : false };
                            if(oB.playing && oB.galleryArray[currentIndex + 1] && oB.galleryArray.length > 1) { oc_settings.play = false; }
                            if(oB.galleryArray[currentIndex + 1] && oB.galleryArray.length > 1) { oc_settings.right_active = true; }
                            if(oB.galleryArray[currentIndex - 1] && oB.galleryArray.length > 1) { oc_settings.left_active = true; }
                            if(oB.slideshow) { oc_settings.play_active = true; }
                            $(document).orangeControls('update', oc_settings);
                        }
                        function showControls() {
                            if(oB.galleryArray.length > 1) {
                                if(oB.settings.orangeControls) {
                                    $(document).orangeControls('toggle', {'time' : oB.settings.fadeTime, 'fade' : "in"});
                                }
                                if(oB.galleryArray[currentIndex + 1]) { 
                                    $('#ob_right').fadeIn(oB.settings.fadeTime);
                                    $('#ob_right-ico').fadeIn(oB.settings.fadeTime);
                                }
                                else { $('#ob_right').hide(); }
                                if(oB.galleryArray[currentIndex - 1]) { 
                                    $('#ob_left').fadeIn(oB.settings.fadeTime); 
                                    $('#ob_left-ico').fadeIn(oB.settings.fadeTime);
                                }
                                else { $('#ob_left').hide(); }
                            }
                            $('#ob_close').fadeIn(oB.settings.fadeTime);
                        }
                        if(oB.settings.fadeControls) {
                            if(!oB.galleryArray[currentIndex + 1] || !oB.galleryArray[currentIndex - 1] || initial) {
                                showControls();
                                oB.controlTimer = setTimeout(function() {
                                    $('.ob_controls').fadeOut(oB.settings.fadeTime);
                                    if(oB.settings.orangeControls) {
                                        $(document).orangeControls('toggle', {'time' : oB.settings.fadeTime, 'fade' : "out"});
                                    }
                                }, 1200);
                            }
                            $(document).mousemove(function(event) {
                                clearTimeout(oB.controlTimer);
                                oB.controlTimer = setTimeout(function() {
                                    showControls();
                                    if (!$(event.target).hasClass('ob_cs') && !$(event.target).hasClass('oc_class')) {
                                        oB.controlTimer = setTimeout(function() {
                                            $('.ob_controls').fadeOut(oB.settings.fadeTime);
                                            if(oB.settings.orangeControls) {
                                                $(document).orangeControls('toggle', {'time' : oB.settings.fadeTime, 'fade' : "out"});
                                            }
                                        }, 1200);
                                    }
                                },20);
                            });
                        }
                        else {
                            showControls();
                        }
                    }
                    
                //Build the Window
                    function buildit() {
                        oB.methods.showLoad("stop");
                        $('#ob_content').append(content);
                            if ( oB.settings.addThis && contentType !== "iframe" && contentType !== "inline" && obj.data('ob_data').ob_share !== "false") {
                                $('#ob_share').empty().remove();
                                var addThis = $('<a id="ob_share" class="addthis_button_compact"></a>');
                                var shareClass = "ob_share-"+title;
                                var link = href;
                                if ( obj.data('ob_data').ob_shareLink ) { link = obj.data('ob_data').ob_shareLink; }
                                addThis.addClass(shareClass);
                                $('#ob_window').append(addThis);
                                $('#ob_title').css('margin-right', 24);
                                addthis.button('.'+shareClass, { services_compact: 'twitter,facebook,digg,delicious,more', ui_offset_left: -244, ui_offset_top: 4 }, { url: link, title: title });
                                $('#ob_share').html('').append('<span class="at300bs at15nc at15t_compact"></span>');
                                if ( title === "" ) { title = "share" }
                            }
                        $('#ob_window').fadeIn(oB.settings.fadeTime, function(){
                            if(initial){ $(document).trigger('oB_init'); }
                            $('#ob_overlay').css({ "height": $(document).height() });
                        });
                        setModalProperties();
                        setControls();
                        oB.progress = null;
                    }
                    
                //Error Content
                    function throwError() {
                        content = $('<div id="ob_error">' + oB.settings.notFound + '</div>');
                        oB.methods.showLoad("stop");
                        $('#ob_content').empty().append(content);
                        $('#ob_window').fadeIn(oB.settings.fadeTime, function(){
                            $('#ob_overlay').css({ "height": $(document).height() });    
                        });
                        $('#ob_title').hide();
                        $('#ob_right').hide();
                        $('#ob_left').hide();
                        $('#ob_dots').hide();
                        $(document).unbind('mousemove');
                        isError = true;
                        setModalProperties();
                    }
                    
                //Set Width or Height Value
                    function setValue(i, x) {
                        var w = oB.docWidth;
                        var h = oB.docHeight;
                        if(oB.docWidth > $(window).width()) { w = $(window).width(); }
                        if(oB.docHeight > $(window).height()) { h = $(window).height(); }
                        if(i > 1) { return i; }
                        else if(i > 0) {
                            if(x === "width") { return w * i; }
                            else if(x === "height") { return h * i; }
                        }
                        return false;
                    }
                    
                //iFrame Content
                    function showiFrame() { 
                        var newhref = href.replace(/\?iframe$/, '');
                        content = $('<iframe id="ob_iframe" frameborder="0" hspace="0" scrolling="auto" src="' + newhref + '"></iframe>').css({
                                "height": setValue(oB.settings.iframeHeight, "height"),
                                "width": setValue(oB.settings.iframeWidth, "width")
                            });
                        buildit();
                    }
                    
                //Inline Content
                    function showInline() {
                        if($(href).length && $(href).html() !== ""){
                            content = $('<div id="ob_inline">' + $(href).html() + '</div>').css({
                                    "height": setValue(oB.settings.inlineHeight, "height"),
                                    "width": setValue(oB.settings.inlineWidth, "width")
                                });
                            buildit();
                        }
                        else { throwError(); }
                    }
                            
                //Video Content
                    function showVideo() {
                        console.log("video");
                        var i;
                        var mH = setValue(oB.settings.maxVideoHeight, "height");
                        var mW = setValue(oB.settings.maxVideoWidth, "width");
                        var a = 'height="100%" width="100%" type="text/html" frameborder="0" hspace="0" scrolling="auto"';
                        var h;
                        var w;
                        var iI;
                        if (obj.data('ob_data').ob_height && obj.data('ob_data').ob_width) {
                            h = obj.data('ob_data').ob_height;
                            w = obj.data('ob_data').ob_width;
                            if(h > mH){
                                w = w * mH / h;
                                h = mH;
                            }
                            if(w > mW){
                                h = h * mW / w;
                                w = mW;
                            }
                        }
                        else {
                            w = mW; 
                            h = mH; 
                        }
                        
                    //If YouTube
                        if (contentType === "youtube") { 
                            iI = href.indexOf("?v=") + 3;
                            if (href.indexOf("&") > iI) { i = href.substring(iI, href.indexOf("&")); }
                            else { i = href.substring(iI); }
                            content = $('<iframe id="ob_video" '+a+' src="http://www.youtube.com/embed/'+i+'?fs=1&hl=en_US&rel=0&autoplay=1&autohide=1&wmode=transparent&enablejsapi=1"></iframe>');
                        }
                        
                    //If Vimeo  
                        else if (contentType === "vimeo") { 
                            iI = href.indexOf("vimeo.com/") + 10;
                            if (href.indexOf("?") > iI) { i = href.substring(iI, href.indexOf("?")); }
                            else { i = href.substring(iI); }
                            content = $('<iframe id="ob_video" '+a+' src="http://player.vimeo.com/video/'+i+'?title=0&byline=0&portrait=0&autoplay=1&wmode=transparent"></iframe>');
                        }
                        
                    //If Quicktime
                        else if (contentType === "quicktime") { 
                            content = $('<div id="ob_video"><object classid="clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B" codebase="http://www.apple.com/qtactivex/qtplugin.cab" height="' + h + '" width="' + w + '"><param name="src" value="' + href + '"><param name="wmode" value="transparent" /><param name="type" value="video/quicktime"><param name="autoplay" value="true"><embed src="' + href + '" height="' + h + '" width="' + w + '" autoplay="true" type="video/quicktime" pluginspage="http://www.apple.com/quicktime/download/" scale="aspect"></embed></object></div>');
                        }
                        
                    //If Flash
                        else if (contentType === "flash") {
                            content = $('<div id="ob_video"><embed flashVars="playerVars=autoPlay=yes" src="' + href + '" wmode="transparent" pluginspage="http://www.macromedia.com/go/getflashplayer" allowFullScreen="true" allowScriptAccess="always" width="' + w + '" height="' + h + '" type="application/x-shockwave-flash"></embed></div>');
                        }
                        content.css({ "width": w, "height": h });
                        buildit();
                    }
                    
                //Image Content
                    function showImage() {                                          
                        var img = new Image();
                        content = $(img);
                        content.load(function () {
                            var mH = 0;
                            var mW = 0;
                            var w = img.width;
                            var h = img.height;
                            if(oB.slideshow && oB.playing) {
                                oB.slideshowTimer = setTimeout(function(){
                                    oB.methods.navigate(1);
                                },oB.settings.slideshowTimer);
                            }
                            mH = setValue(oB.settings.maxImageHeight, "height");
                            mW = setValue(oB.settings.maxImageWidth, "width");
                            if(h > mH){
                                w = w * mH / h;
                                h = mH ;
                            }
                            if(w > mW){
                                h = h * mW / w;
                                w = mW ;
                            }
                            if(h < oB.settings.contentMinHeight){
                                content.css({
                                    "margin-top": (oB.settings.contentMinHeight / 2) - (h / 2)
                                });
                            }
                            if(w < oB.settings.contentMinWidth){
                                content.css({
                                    "margin-left": (oB.settings.contentMinWidth / 2) - (w / 2)
                                });
                            }
                            content.css({
                                "height": parseInt(h, 10),
                                "width": parseInt(w, 10)
                            });
                            buildit();
                        })
                        .error(function () {
                            throwError();
                        })
                        .attr({ src: href, id: 'ob_image' });
                    }
                    
                    console.log('contentType - '+contentType);
                    switch (contentType) {
                        case "iframe":
                            showiFrame();
                            break;
                        case "image":
                            showImage();
                            break;
                        case "inline":
                            showInline();
                            break;
                        case "quicktime":
                        case "youtube":
                        case "vimeo":
                        case "flash":
                            showVideo();
                            break;
                        default:
                            $.error( 'OrangeBox: Unsupported Media');
                    }
                },
                navigate : function( d, i, options ) {
                    if ( options ) { $.extend( oB.settings, options ); }
                    if(!i) {
                        var c =  parseInt($('#ob_content').attr('class').substr(7), 10);
                        if(d === 1) { i = c + 1; }
                        else if(d === -1) { i = c - 1; }
                    }
                    if(oB.galleryArray[i]) {
                        oB.progress = true;
                        $(document).trigger('oB_navigate', [i]);
                        $('#ob_window').fadeOut(oB.settings.fadeTime, function () {
                            $('#ob_title').empty();
                            $('#ob_content').empty();
                            oB.methods.showContent(oB.galleryArray[i], false );
                        });
                    }
                    else { oB.progress = null; }
                    if(!oB.galleryArray[i + 1]) { oB.methods.slideshowPause(); }
                },
                slideshowPlay  : function() {
                    $(document).trigger('oB_play');
                    var c =  parseInt($('#ob_content').attr('class').substr(7), 10);
                    oB.playing = true;
                    if(oB.galleryArray[c + 1]){ oB.methods.navigate(1); }
                    else { oB.methods.navigate(0, 0); }
                },
                slideshowPause  : function() {
                    if(oB.playing) {
                        $(document).trigger('oB_pause');
                        oB.playing = false;
                        clearTimeout(oB.slideshowTimer);
                    }
                },
                showLoad  : function( x ) {
                    var loadTimer;
                    var ob_load = $('<div id="ob_load"></div>').hide();
                    if(x === "stop") {
                        clearTimeout(loadTimer);
                        $('#ob_load').remove();
                    }
                    else {
                        clearTimeout(loadTimer);
                        $("body").append(ob_load);
                        loadTimer=setTimeout(function() { $('#ob_load').fadeIn(); }, 600);
                    }
                }
            }
        };
        
        $.fn.orangeBox = function( method ) {   
        console.log('orange'); 
        console.log(method);
            if ( method === "showContent2" || method === "setupData" ) {
                $.error( 'OrangeBox: ' +  method + ' cannot be called externally' );
                return false;
            }
            else if ( oB.methods[method] ) {
                return oB.methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
            }
            else if ( typeof method === 'object' || ! method ) {
                return oB.methods.init.apply( this, arguments );
            }
            else {
                $.error( 'OrangeBox: Method ' +  method + ' does not exist in OrangeBox' );
                return false;
            }    
        
        };
    })(jQuery); 
}
jQuery(document).ready(function($) {
    if (typeof orangebox_vars !== "undefined") { $('a[rel*=lightbox]').orangeBox(orangebox_vars); }
    else { $('a[rel*=lightbox]').orangeBox(); }
});