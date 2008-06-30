function toggleTree(page_id, sender) {
	var e = $('tree_'+page_id);
	e.toggle();
	if ( e.visible() ) {
		sender.className = 'expanded';
 	} else {
		sender.className = 'collapsed';
	}
	new Ajax.Request('/admin/pages/'+page_id+';tree_toggle?state='+e.visible(), { method: 'get' });
}