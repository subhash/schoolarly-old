var busyDivName = 'busy_ajax';
var offX = 15;
var offY = 15;
var spinnerUrl = '/images/spinner.gif';


jQuery(document).ajaxStart(function() {
  jQuery('#busy_ajax').show();
}).ajaxStop(function() {
  jQuery('#busy_ajax').hide();
});

function mouseX(evt) {
	if (!evt) evt = window.event;
	if (evt.pageX) 
		return evt.pageX;
	else if (evt.clientX)
		return evt.clientX + (document.documentElement.scrollLeft ?  document.documentElement.scrollLeft : document.body.scrollLeft);
	else 
		return 0;
}

function mouseY(evt) {
	if (!evt) evt = window.event;
 	if (evt.pageY) return evt.pageY;
 	else if (evt.clientY) return evt.clientY + (document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop);
	else return 0;
}

function follow(evt) {
	if (document.getElementById) {
		var obj = document.getElementById(busyDivName).style;
		obj.visibility = 'visible';
		obj.left = (parseInt(mouseX(evt))+offX) + 'px';
		obj.top = (parseInt(mouseY(evt))+offY) + 'px';
	}
}

function busy_off() {
	document.onmousemove = null;
	jQuery(busyDivName).remove();
}

function busy_on() {
	try {
		busydiv = document.createElement('div')
		busydiv.id = busyDivName
		// busydiv.setStyle('display:none;position:absolute;z-index:auto;')
		busydiv.style['display'] = 'none'
		busydiv.style['position'] = 'absolute'
		busydiv.style['z-index'] = 'auto'		
		spinimg = document.createElement('img')
		spinimg.src = spinnerUrl;
		busydiv.appendChild(spinimg)
		setTimeout(function() {
			document.body.appendChild(busydiv);
			document.onmousemove = follow;
		}, 1);
	} catch (e) { alert('error; could not insert busy div:\n\n' + e.toString()); throw e }
}

jQuery(document).ready(function() {
  busy_on();
});