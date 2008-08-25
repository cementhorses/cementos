function createContentSortables() {
	//Sortable.SERIALIZE_RULE = /^[^-]*[-](.*)$/;
	var slides_div = (arguments[0]) ? arguments[0]:false;
	if (slides_div) {
		createSortable(slides_div, 'draghandle', false, $A($(slides_div).getElementsByClassName('slide')));
		updateSortable(slides_div);
	}
	//we have to call this here because scriptaculous has a 'feature' that allows you
	//to send any child of an existing sortable to destroy the parent element's sortable
	createSortable('mixed_content', 'content_draghandle', false, $A($('mixed_content').getElementsByClassName('content')));
}

function createSortable(id, draghandle, only, elements) {
	config = {
		constraint: 'vertical',
		handle: draghandle,
		onChange: 	function() { updateSortable(id); }
	}
	if (elements) {
		config.elements = elements;
	} else {
		config.tag = 'div';
	}	
	if (draghandle) {
		config['draghandle'] = draghandle;
	}
	if (only) {
		config['only'] = only;
	}
	Sortable.create(id, config);
}

function destroySortable(id) {
	Sortable.destroy(id);
}

function updateSortable(id) {
	$contents = $(id).immediateDescendants();
	for (var i = 0; i < $contents.length; i++) {
		$arrPos = $contents[i].getElementsByClassName('sortable_position');
		if ($arrPos.length > 0) {
			$arrPos[0].value = i;
		}
	}
	
	return(true);
}


function textileInsert(text, parent_id) {
	text = "\n" + text; // so that each code snippet starts on its own line
	if (window.opener.focusedTextile != null) {
		insertAtCursor(window.opener.focusedTextile, text);
	} else {
		e = window.opener.document.getElementById(parent_id);
		if (e != null) {
			insertAtCursor(e, text);
		}
	}
}

var focusedTextile = null;
function textileHasFocus(textile) {
	focusedTextile = textile;
}

function insertAtCursor(myField, myValue) { 
	if (window.opener.document.selection) { 
		myField.focus(); 
		sel = window.opener.document.selection.createRange(); 
		sel.text = myValue;
		window.focus();
	} 
	else if (myField.selectionStart || myField.selectionStart == '0') { 
		var startPos = myField.selectionStart; 
		var endPos = myField.selectionEnd; 
		myField.value = myField.value.substring(0, startPos) + myValue + myField.value.substring(endPos, myField.value.length); 
	} else { 
		myField.value += myValue;
	} 
}

function fadeAndDestroy(id) {
	Effect.Fade(id, {afterFinish: function() { $(id).remove(); } });
}