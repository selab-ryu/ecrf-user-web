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


Liferay.provide(window, 'openManageResearcherDialog', function(groupId, portletId, crfId, crfResearcherInfoArr) {
// delete baseURL parameter from function definition
//	var url = Liferay.Util.PortletURL.createRenderURL(baseURL,
//			{
//				'p_p_id' : portletId,
//				'p_auth': Liferay.authToken,
//				
//				
//				'mvcPath' : '/html/crf/dialog/manage-researcher.jsp',
//				'groupId' : groupId,
//				'crfId' : crfId,
//				'crfResearcherInfoJsonStr' : JSON.stringify(crfResearcherInfoArr)
//			}
//		);
//	
//	console.log(url);
//	console.log("render url : " + url.toString());
	
	var renderURL = Liferay.PortletURL.createRenderURL();
	
	renderURL.setPortletId(portletId);
	renderURL.setPortletMode("edit");
    renderURL.setWindowState("pop_up");
    
    renderURL.setParameter("mvcPath", "/html/crf/dialog/manage-researcher.jsp");
    renderURL.setParameter("groupId", groupId);
    renderURL.setParameter("crfId", crfId);
    renderURL.setParameter("crfResearcherInfoJsonStr", JSON.stringify(crfResearcherInfoArr));
    
//    console.log(renderURL);
    
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

Liferay.provide(window, 'openManageSubjectDialog', function(groupId, portletId, crfId, crfSubjectInfoArr, baseURL) {   
	var url = Liferay.Util.PortletURL.createRenderURL(baseURL,
			{
				'p_p_id' : portletId,
				'p_auth': Liferay.authToken,
				'p_p_mode' : 'edit',
				'p_p_state' : 'pop_up',
				'mvcPath' : '/html/crf/dialog/manage-subject.jsp',
				//'mvcRenderCommandName' : '/render/crf/dialog-manage-crf-subject',
				'groupId' : groupId,
				'crfId' : crfId,
				'crfSubjectInfoJsonStr' : JSON.stringify(crfSubjectInfoArr),
				'crfSubjectInfo' : crfSubjectInfoArr
				
			}
	);
	
	console.log(url);
	
	// resource url? / save log by ajax / open dialog when ajax is complete
	var actionURL = Liferay.Util.PortletURL.createActionURL(baseURL,
			{
				'p_p_id' : portletId,
				'javax.portlet.action' : '/action/crf/redirect-crf-subject-dialog',
				'p_auth': Liferay.authToken,
				'groupId' : groupId,
				'crfId' : crfId,
				'crfSubjectInfo' : crfSubjectInfoArr
			});
	
//	console.log(actionURL);
//	console.log(actionURL.toString());
	
    Liferay.Util.openWindow({
		dialog: {
			width:800,
			height:800,
			modal: true,
			cenered: true
		},
		id: "manageSubjectPopup",
		title: "Manage CRF Subject",
		uri: url.toString()
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

Liferay.provide(window, 'moveAddCRFData', function(sId, crfId, displayViewerId, dialogId, portletId, plId, baseURL) {
	var dialog = Liferay.Util.Window.getById(dialogId);
	dialog.destroy();
	
	console.log("subject Id / crf Id : " + sId + " / " + crfId);
	
  var renderCommand = "/render/crf-data/view-crf-data";
  if(displayViewerId == 0 || displayViewerId == 1) renderCommand = "/render/crf-data/crf-viewer";
  
	var url = Liferay.Util.PortletURL.createRenderURL(baseURL,
			{
				'p_p_id' : portletId,
				'p_l_id' : plId,
				'p_auth': Liferay.authToken,
				'mvcRenderCommandName' : renderCommand,
				'fromFlag' : 'selector-add',
				'subjectId' : sId,
				'crfId' : crfId				
			}
		);
	
//	console.log(url);
//	console.log("add render url : " + url.toString());
	
	window.location.href = url.toString();
},['liferay-util-window', 'liferay-portlet-url']);

Liferay.provide(window, 'moveViewCRFData', function(sId, crfId, sdId, displayViewerId, dialogId, portletId, plId, baseURL) {
	var dialog = Liferay.Util.Window.getById(dialogId);
	dialog.destroy();
	
	console.log("subject Id / crf Id : " + sId + " / " + crfId);
	
	var url = Liferay.Util.PortletURL.createRenderURL(baseURL,
			{
				'p_p_id' : portletId,
				'p_l_id' : plId,
				'p_auth': Liferay.authToken,
				'mvcRenderCommandName' : '/render/crf-data/view-crf-data',
				'subjectId' : sId,
				'crfId' : crfId,
				'structuredDataId' : sdId
			}
		);
	
//	console.log(url);
//	console.log("add render url : " + url.toString());
	
	window.location.href = url.toString();	
},['liferay-util-window', 'liferay-portlet-url']);

Liferay.provide(window, 'moveUpdateCRFData', function(sId, crfId, sdId, isAudit, displayViewerId, dialogId, portletId, plId, baseURL) {
	var dialog = Liferay.Util.Window.getById(dialogId);
	dialog.destroy();
	
	console.log("subject Id / crf Id : " + sId + " / " + crfId);
	
	var renderCommand = "/render/crf-data/crf-viewer";
	if(isAudit){
    		renderCommand = "/render/crf-data/view-audit";
	} else{
		if(displayViewerId == 0 || displayViewerId == 1){
        renderCommand = "/render/crf-data/crf-viewer";
		} else{
      renderCommand = "/render/crf-data/view-crf-data";
		}
	}
  
  var url = Liferay.Util.PortletURL.createRenderURL(baseURL,
			{
				'p_p_id' : portletId,
				'p_l_id' : plId,
				'p_auth': Liferay.authToken,
				'mvcRenderCommandName' : renderCommand,
				'subjectId' : sId,
				'crfId' : crfId,
				'structuredDataId' : sdId
			}
		);
	
//	console.log(url);
//	console.log("add render url : " + url.toString());
			
	window.location.href = url.toString();	
},['liferay-util-window', 'liferay-portlet-url']);

Liferay.provide(window, 'deleteCRFData', function(linkCrfId, dialogId, portletId, plId, baseURL) {
	var dialog = Liferay.Util.Window.getById(dialogId);
	dialog.destroy();
	
	var actionURL = Liferay.Util.PortletURL.createActionURL(baseURL,
			{
				'p_p_id' : portletId,
				'javax.portlet.action' : '/action/crf-data/delete-crf-data',
				'linkCrfId' : linkCrfId,
				'p_auth': Liferay.authToken
			});
	
//	console.log(actionURL);
//	console.log(actionURL.toString());
	
	window.location.href = actionURL.toString();
},['liferay-util-window', 'liferay-portlet-url']);

Liferay.provide(window, 'createGraphPopupRenderURL', function(portletId, termName, displayName, termType, crfId, renderCommand, baseURL) {
	var renderURL = Liferay.Util.PortletURL.createRenderURL(baseURL,
			{
				'p_p_id' : portletId,
				'p_auth': Liferay.authToken,
				'p_p_mode' : 'edit',
				'p_p_state' : 'pop_up',
				'mvcRenderCommandName' : renderCommand,
				'termName' : termName,
				'crfId' : crfId
			}
	);
	
	console.log(renderURL.toString());
		
	Liferay.Util.openWindow(
		{
			dialog: {
				cache: false,
				destroyOnClose: true,
				centered: true,
				modal: true,
				resizable: false,
				height: 600,
				width: 1200
			},
			id: "graphPopup",
			title: displayName + "(" + termType + ")",
			uri: renderURL.toString()
		}
	);
	
	const elements = document.getElementsByClassName('modal-title');
	elements[0].style.textAlign = "center";
	
}, ['liferay-util-window', 'liferay-portlet-url']);
