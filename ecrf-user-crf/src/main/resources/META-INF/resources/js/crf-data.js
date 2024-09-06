Liferay.provide(window, 'openMultiCRFDialog', function(sId, crfId, type, portletId, baseURL) {
	console.log("function activate");
		
	var isAudit = false;
	var isDelete = false;
	
	// set dialog type value by type param 
	if(type === 0) {
		isAudit = false;
		isDelete = false;
	} else if (type === 1) {
		isAudit = true;
		isDelete = false;
	} else if (type === 2) {
		isAudit = false;
		isDelete = true;
	}
	
	var url = Liferay.Util.PortletURL.createRenderURL(baseURL,
		{
			'p_p_id' : portletId,
			'p_auth': Liferay.authToken,
			'p_p_mode' : 'edit',
			'p_p_state' : 'pop_up',
			'subjectId' : sId,
			'crfId' : crfId,
			'baseURL' : baseURL,
			'isAudit' : isAudit,
			'isDelete' : isDelete,
			'mvcRenderCommandName' : '/render/crf-data/crf-data-selector'
		}
	);
	
	
	console.log("url : " + url.toString());
	
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
		uri: url.toString()
	});
	
	console.log("after open window");
}, ['liferay-portlet-url']); 


Liferay.provide(window, 'openManageResearcherDialog', function(groupId, portletId, crfId, crfResearcherInfoArr, baseURL) {
	var sessionValue = encodeURIComponent(JSON.stringify(crfResearcherInfoArr));
	
	if(window.sessionStorage) {
        sessionStorage.clear();
        sessionStorage.setItem('researcherArr', sessionValue);
    }
    else {
        alert("세션을 사용할 수 없는 브라우저입니다.");
    }
	
	var url = Liferay.Util.PortletURL.createRenderURL(baseURL,
			{
				'p_p_id' : portletId,
				'p_auth': Liferay.authToken,
				'p_p_mode' : 'edit',
				'p_p_state' : 'pop_up',
				'mvcPath' : '/html/crf/dialog/manage-researcher.jsp',
				'groupId' : groupId,
				'crfId' : crfId
			}
	);
    
    Liferay.Util.openWindow({
		dialog: {
			width:800,
			height:800,
			modal: true,
			cenered: true
		},
		id: "manageResearcherPopup",
		title: "Manage CRF Researcher",
		uri: url.toString()
	});
}, ['liferay-util-window', 'liferay-portlet-url']);

Liferay.provide(window, 'openManageSubjectDialog', function(groupId, portletId, crfId, crfSubjectInfoArr, baseURL) {
	var sessionValue = encodeURIComponent(JSON.stringify(crfSubjectInfoArr));
	
	if(window.sessionStorage) {
        sessionStorage.clear();
        sessionStorage.setItem('subjectArr', sessionValue);
    }
    else {
        alert("세션을 사용할 수 없는 브라우저입니다.");
    }
	
	var url = Liferay.Util.PortletURL.createRenderURL(baseURL,
			{
				'p_p_id' : portletId,
				'p_auth': Liferay.authToken,
				'p_p_mode' : 'edit',
				'p_p_state' : 'pop_up',
				'mvcPath' : '/html/crf/dialog/manage-subject.jsp',
				'groupId' : groupId,
				'crfId' : crfId
			}
	);
	
	console.log(url);
		
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
}, ['liferay-util-window', 'liferay-portlet-url', 'frontend-js-web']);

Liferay.provide(window, 'openManageUpdateLockDialog', function(portletId, crfId, crfSubjectInfoArr, baseURL) {	
	var sessionValue = encodeURIComponent(JSON.stringify(crfSubjectInfoArr));
	
	if(window.sessionStorage) {
        sessionStorage.clear();
        sessionStorage.setItem('subjectArr', sessionValue);
    }
    else {
        alert("세션을 사용할 수 없는 브라우저입니다.");
    }
	
	var url = Liferay.Util.PortletURL.createRenderURL(baseURL,
			{
				'p_p_id' : portletId,
				'p_auth': Liferay.authToken,
				'p_p_mode' : 'edit',
				'p_p_state' : 'pop_up',
				'mvcPath' : '/html/crf/dialog/manage-subject-update-lock.jsp',
				'crfId' : crfId
			}
	);
	    
    Liferay.Util.openWindow({
		dialog: {
			width:800,
			height:800,
			modal: true,
			cenered: true
		},
		id: "manageUpdateLockPopup",
		title: "Manage Update Lock",
		uri: url.toString()
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
    		renderCommand = "/render/crf-data/crf-viewer";
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
				'isAudit' : isAudit,
				'structuredDataId' : sdId
			}
		);
	
//	console.log(url);
//	console.log("add render url : " + url.toString());
			
	window.location.href = url.toString();	
},['liferay-util-window', 'liferay-portlet-url']);

Liferay.provide(window, 'deleteCRFData', function(linkCrfId, crfId, dialogId, portletId, plId, baseURL) {
	var dialog = Liferay.Util.Window.getById(dialogId);
	dialog.destroy();
	
	var actionURL = Liferay.Util.PortletURL.createActionURL(baseURL,
			{
				'p_p_id' : portletId,
				'p_auth': Liferay.authToken,
				'javax.portlet.action' : '/action/crf-data/delete-crf-data',
				'linkCrfId' : linkCrfId,
				'crfId' : crfId
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
