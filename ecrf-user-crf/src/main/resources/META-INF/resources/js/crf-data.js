Liferay.provide(window, 'openManageResearcherDialog', function(portletId, crfId, crfResearcherInfoArr) {
	var renderURL = Liferay.PortletURL.createRenderURL();
	
	renderURL.setPortletId(portletId);
	renderURL.setPortletMode("edit");
    renderURL.setWindowState("pop_up");
    
    renderURL.setParameter("mvcPath", "/html/crf/dialog/manage-researcher.jsp");
    renderURL.setParameter("crfId", crfId);
    renderURL.setParameter("crfResearcherInfoJsonStr", JSON.stringify(crfResearcherInfoArr));
    
    Liferay.Util.openWindow({
		dialog: {
			width:800,
			height:800,
			modal: true,
			cenered: true
		},
		id: "manageResearcherPopup",
		title: "Manage CRF Researcher",
		uri: renderURL.toString()
	});
}, ['liferay-util-window', 'liferay-portlet-url']);

Liferay.provide(window, 'openManageSubjectDialog', function(portletId, crfId, crfSubjectInfoArr) {
	var renderURL = Liferay.PortletURL.createRenderURL();
	
	renderURL.setPortletId(portletId);
	renderURL.setPortletMode("edit");
    renderURL.setWindowState("pop_up");
    
    renderURL.setParameter("mvcPath", "/html/crf/dialog/manage-subject.jsp");
    renderURL.setParameter("crfId", crfId);
    renderURL.setParameter("crfSubjectInfoJsonStr", JSON.stringify(crfSubjectInfoArr));
    
    Liferay.Util.openWindow({
		dialog: {
			width:800,
			height:800,
			modal: true,
			cenered: true
		},
		id: "manageSubjectPopup",
		title: "Manage CRF Subject",
		uri: renderURL.toString()
	});
}, ['liferay-util-window', 'liferay-portlet-url']);

Liferay.provide(window, 'openManageUpdateLockDialog', function(portletId, crfId, crfSubjectInfoArr) {
	var renderURL = Liferay.PortletURL.createRenderURL();
	
	renderURL.setPortletId(portletId);
	renderURL.setPortletMode("edit");
    renderURL.setWindowState("pop_up");
    
    renderURL.setParameter("mvcPath", "/html/crf/dialog/manage-subject-update-lock.jsp");
    renderURL.setParameter("crfId", crfId);
    renderURL.setParameter("crfSubjectInfoJsonStr", JSON.stringify(crfSubjectInfoArr));
    
    Liferay.Util.openWindow({
		dialog: {
			width:800,
			height:800,
			modal: true,
			cenered: true
		},
		id: "manageUpdateLockPopup",
		title: "Manage Update Lock",
		uri: renderURL.toString()
	});
}, ['liferay-util-window', 'liferay-portlet-url']);

Liferay.provide(window, 'openMultiCRFDialog', function(sId, crfId, type, portletId, baseURL) {
	console.log("function activate");
	
	var renderURL = Liferay.PortletURL.createRenderURL();

	// set default value
	renderURL.setPortletId(portletId);
	renderURL.setPortletMode("edit");
    renderURL.setWindowState("pop_up");
    
    // set url param
	renderURL.setParameter("subjectId", sId);
	renderURL.setParameter("crfId", crfId);
	renderURL.setParameter("baseURL", baseURL);
	
	// set dialog type value by type param 
	if(type === 0) {
		renderURL.setParameter("isAudit", false);
		renderURL.setParameter("isDelete", false);
	} else if (type === 1) {
		renderURL.setParameter("isAudit", true);
		renderURL.setParameter("isDelete", false);
	} else if (type === 2) {
		renderURL.setParameter("isAudit", false);
		renderURL.setParameter("isDelete", true);
	}
	
	// set render command
	renderURL.setParameter("mvcRenderCommandName", "/render/crf-data/crf-data-selector");
			
	Liferay.Util.openWindow({
		dialog: {
			cache: false,
			destroyOnClose: true,
			centered: true,
			constrain2view: true,
			modal: true,
			resizable: false,
			height: 700,
			width: 1000
		},
		id: '_' + portletId + '_multiCRFDialog',	// add _ as prefix/suffix to make portlet namespace
		title: 'CRF Selector',
		uri: renderURL.toString()
	});
	
}, ['liferay-portlet-url']); 


Liferay.provide(window, 'moveAddCRFData', function(sId, crfId, displayViewerId, dialogId, portletId, plId, baseURL) {
	var dialog = Liferay.Util.Window.getById(dialogId);
	dialog.destroy();
	
	console.log("subject Id / crf Id : " + sId + " / " + crfId);
		
	var renderURL = Liferay.PortletURL.createURL(baseURL);
	
	renderURL.setPortletId(portletId);
	renderURL.setPlid(plId);
	
	renderURL.setParameter("subjectId", sId);
	renderURL.setParameter("crfId", crfId);
	
	renderURL.setParameter("fromFlag", "selector-add");
	
	if(displayViewerId == 0 || displayViewerId == 1){
		renderURL.setParameter("mvcRenderCommandName" , "/render/crf-data/crf-viewer");
	}else{
		renderURL.setParameter("mvcRenderCommandName" , "/render/crf-data/view-crf-data");
	}
	
	window.location.href = renderURL;
},['liferay-util-window']);

Liferay.provide(window, 'moveViewCRFData', function(sId, crfId, sdId, displayViewerId, dialogId, portletId, plId, baseURL) {
	var dialog = Liferay.Util.Window.getById(dialogId);
	dialog.destroy();
	
	console.log("subject Id / crf Id : " + sId + " / " + crfId);
		
	var renderURL = Liferay.PortletURL.createURL(baseURL);
	
	renderURL.setPortletId(portletId);
	renderURL.setPlid(plId);
	
	renderURL.setParameter("subjectId", sId);
	renderURL.setParameter("crfId", crfId);
	renderURL.setParameter("structuredDataId", sdId);
	
	renderURL.setParameter("mvcRenderCommandName" , "/render/crf-data/view-crf-data");
	
	window.location.href = renderURL;	
},['liferay-util-window']);

Liferay.provide(window, 'moveUpdateCRFData', function(sId, crfId, sdId, isAudit, displayViewerId, dialogId, portletId, plId, baseURL) {
	var dialog = Liferay.Util.Window.getById(dialogId);
	dialog.destroy();
	
	console.log("subject Id / crf Id : " + sId + " / " + crfId);
		
	var renderURL = Liferay.PortletURL.createURL(baseURL);
	
	renderURL.setPortletId(portletId);
	renderURL.setPlid(plId);
		
	renderURL.setParameter("subjectId", sId);
	renderURL.setParameter("crfId", crfId);
	renderURL.setParameter("structuredDataId", sdId);
	
	if(isAudit){
		renderURL.setParameter("mvcRenderCommandName" , "/render/crf-data/view-audit");
	}else{
		if(displayViewerId == 0 || displayViewerId == 1){
			renderURL.setParameter("mvcRenderCommandName" , "/render/crf-data/crf-viewer");
		}else{
			renderURL.setParameter("mvcRenderCommandName" , "/render/crf-data/view-crf-data");
		}
	}
		
	window.location.href = renderURL;	
},['liferay-util-window']);

Liferay.provide(window, 'moveDeleteCRFData', function(linkCrfId, dialogId, portletId, plId, baseURL) {
	var dialog = Liferay.Util.Window.getById(dialogId);
	dialog.destroy();
	
	var actionURL = Liferay.PortletURL.createURL(baseURL);
	
	actionURL.setPortletId(portletId);
	actionURL.setPlid(plId);
	
	actionURL.setParameter("linkCrfId", linkCrfId);
	actionURL.setName("/action/crf-data/delete-crf-data");
	
	console.log(actionURL);
	
	window.location.href = actionURL.toString();	
},['liferay-util-window']);