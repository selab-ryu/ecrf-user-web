<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf/update-crf_jsp"); %>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
	
	String menu = "crf-add";
	
	boolean isUpdate = false;

	CRF crf = null;
	
	_log.info("crf id : " + crfId);
	
	if(crfId > 0) {
		crf = (CRF)renderRequest.getAttribute(ECRFUserCRFAttributes.CRF);
		if(Validator.isNotNull(crf)) {
			isUpdate = true;
			menu = "crf-update";	
		}
	}
	
	List<String> expGroupList = Stream.of(ExperimentalGroup.values()).map(m -> m.getFullString()).collect(Collectors.toList());
	_log.info(expGroupList);
	
	DataType dataType = null;
	
	if(isUpdate) {
		dataTypeId = crf.getDatatypeId();
		
		if(dataTypeId > 0) {
			_log.info("dataType id : " + dataTypeId);
			dataType = DataTypeLocalServiceUtil.getDataType(dataTypeId);
		}
	}
%>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_ADD_CRF %>" var="addCRFURL">
</portlet:actionURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_UPDATE_CRF %>" var="updateCRFURL">
	<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
	<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(dataTypeId) %>" />
</portlet:actionURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_CRF %>" var="deleteCRFURL">
	<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
	<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(dataTypeId) %>" />
</portlet:actionURL>

<portlet:renderURL var="listCRFURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF %>" />
	<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
</portlet:renderURL>

<div class="ecrf-user">

	<%@include file="sidebar.jspf" %>
	
	<div class="page-content">
		
		<liferay-ui:header backURL="<%=redirect %>" title="<%=isUpdate ? "ecrf-user.crf.title.update-crf" : "ecrf-user.crf.title.add-crf" %>" />
		
		<aui:form name="updateCRFFm" action="<%=isUpdate ? updateCRFURL : addCRFURL %>" method="POST" autocomplete="off">
		<aui:container cssClass="radius-shadow-container">
			<aui:input type="hidden" name="<%=Constants.CMD %>" value="<%=isUpdate ? Constants.UPDATE : Constants.ADD %>" />
			
			<aui:input type="hidden" name="researcherListInput" vlaue ="" />
			<aui:input type="hidden" name="subjectListInput" vlaue ="" />
			
			<c:if test="<%=isUpdate %>">
			<aui:row>
				<aui:col>
					<aui:input type="hidden" name="crfId" value="<%=crfId %>"></aui:input>
					<aui:input type="hidden" name="dataTypeId" value="<%= dataTypeId %>"></aui:input>
					<aui:input type="hidden" name="redirect" value="<%= redirect %>"></aui:input>
				</aui:col>
			</aui:row>
			</c:if>
			 
			<aui:row>
				<aui:col>
					<aui:field-wrapper
						name="crfTitle"
						label="ecrf-user.crf.crf-title"
						required="true"
						helpMessage="ecrf-user.crf-title-help">
						<liferay-ui:input-localized
							xml="<%= Validator.isNull(dataType)?StringPool.BLANK:dataType.getDisplayName() %>" 
							name="crfTitle">
						</liferay-ui:input-localized>
					</aui:field-wrapper>
				</aui:col>
			</aui:row>
			<aui:row>
				<aui:col>
					<aui:field-wrapper
						name="description"
						label="ecrf-user.crf.description"
						helpMessage="datatype-description-help">
						<liferay-ui:input-localized 
							type="textarea" 
							xml="<%= Validator.isNull(dataType)?StringPool.BLANK:dataType.getDescription() %>" 
							name="description">
						</liferay-ui:input-localized>
					</aui:field-wrapper>
				</aui:col>
			</aui:row>
			<aui:row>
				<aui:col md="8">
					<aui:input
						name="crfName"
						label="ecrf-user.crf.crf-var-name"
						required="true"
						value="<%= Validator.isNull(dataType)?StringPool.BLANK:dataType.getDataTypeName() %>"
						helpMessage="ecrf-user.crf-var-name-help">
					</aui:input>
				</aui:col>
				<aui:col md="4">
					<aui:input
						name="crfVersion" 
						label="ecrf-user.crf.version"  
						required="true" 
						placeholder="1.0.0"
						value="<%= Validator.isNull(dataType)?StringPool.BLANK:dataType.getDataTypeVersion() %>"
						helpMessage="ecrf-user.crf-version-help">
					</aui:input>
				</aui:col>
			</aui:row>		
			
			<aui:row>
				<aui:col md="12" cssClass="sub-title-bottom-border marBr">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf-user.crf.title.crf-researcher-list" />
					</span>
				</aui:col>
			</aui:row>
						
			<aui:row>
				<aui:col>
					<table id="researcherList" style="width:100%" class="table table-striped table-bordered">
						<thead>
							<tr>
								<th>Name</th>
								<th>Birth</th>
								<th>Gender</th>
								<th>Position</th>
								<th>Institution</th>
							</tr>
						</thead>
					</table>
				</aui:col>
			</aui:row>
			
			<!-- subject list -->
			
			<aui:row>
				<aui:col md="12" cssClass="sub-title-bottom-border marBr">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf-user.crf.title.crf-subject-list" />
					</span>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col>
					<table id="subjectList" style="width:100%" class="table table-striped table-bordered">
						<thead>
							<tr>
								<th>Name</th>
								<th>Serial ID</th>
								<th>Birth</th>
								<th>Gender</th>
								<th>Exp. Group</th>
								<th>Update Lock</th>
							</tr>
						</thead>
					</table>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col md="12" cssClass="sub-title-bottom-border marBr">
				</aui:col>
			</aui:row>
			
			<c:if test="<%=isUpdate %>">
			<aui:button-row>
				<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_MOVE_CRF_FORM %>" var="manageFormURL">
					<portlet:param name="crfId" value="<%=String.valueOf(crfId) %>" />
					<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(dataTypeId) %>" />
				</portlet:actionURL>
				
				<aui:button type="button" value="ecrf-user.button.manage-crf-form" onClick="<%=manageFormURL %>" />
				
				<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_MOVE_CRF_DATA %>" var="crfDataURL">
					<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
					<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(dataTypeId) %>" />
				</portlet:actionURL>
				
				<aui:button type="button" value="ecrf-user.button.crf-data" onClick="<%=crfDataURL %>" />
				
				<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_MOVE_CRF_QUERY %>" var="crfQueryURL">
					<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
					<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(dataTypeId) %>" />
				</portlet:actionURL>
				
				<aui:button type="button" value="ecrf-user.button.crf-query" onClick="<%=crfQueryURL %>" />
				
				
				<aui:button type="button" value="ecrf-user.button.crf-meta"/>
				
			</aui:button-row>
			</c:if>
			
			
			<aui:button-row>
				<aui:button type="button" name="saveBtn" value="Save" />
				
				<c:if test="<%=isUpdate %>">
				<aui:button value="Delete" onClick="<%=deleteCRFURL %>" />		
				</c:if>
				
				<aui:button type="button" name="cancel" cssClass="" value="ecrf-user.button.cancel" onClick="<%=listCRFURL %>"></aui:button>
			</aui:button-row>
			
		</aui:container>
		</aui:form>		
	</div>
	
</div>

<script>
var resarcherTable;
var subjectTable;

var crfResearcherInfoArr = [];
var crfSubjectInfoArr = [];

var crfId = "<%=String.valueOf(crfId) %>";
var dataTypeId = "<%=String.valueOf(dataTypeId) %>";

function manageResearcherPopup() {
	var renderURL = Liferay.PortletURL.createRenderURL();
	renderURL.setPortletId("<%=themeDisplay.getPortletDisplay().getId() %>");
	renderURL.setPortletMode("edit");
    renderURL.setWindowState("pop_up");
    renderURL.setParameter("<%=ECRFUserWebKeys.MVC_PATH%>", "<%=ECRFUserJspPaths.JSP_DIALOG_MANAGE_CRF_RESEARCHER %>");
    renderURL.setParameter("<%=ECRFUserCRFAttributes.CRF_ID%>", crfId);
    renderURL.setParameter("crfResearcherInfoJsonStr", JSON.stringify(crfResearcherInfoArr));
    
	AUI().use("liferay-util-window", function(A) {
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
		})
	});
}

function manageSubjectPopup() {
	var renderURL = Liferay.PortletURL.createRenderURL();
	renderURL.setPortletId("<%=themeDisplay.getPortletDisplay().getId() %>");
	renderURL.setPortletMode("edit");
    renderURL.setWindowState("pop_up");
    renderURL.setParameter("<%=ECRFUserWebKeys.MVC_PATH%>", "<%=ECRFUserJspPaths.JSP_DIALOG_MANAGE_CRF_SUBJECT %>");
    renderURL.setParameter("<%=ECRFUserCRFAttributes.CRF_ID%>", crfId);
    renderURL.setParameter("crfSubjectInfoJsonStr", JSON.stringify(crfSubjectInfoArr));
    
	AUI().use("liferay-util-window", function(A) {
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
		})
	});
}

function manageExpGroupPopup() {
	var renderURL = Liferay.PortletURL.createRenderURL();
	renderURL.setPortletId("<%=themeDisplay.getPortletDisplay().getId() %>");
	renderURL.setPortletMode("edit");
    renderURL.setWindowState("pop_up");
    renderURL.setParameter("<%=ECRFUserWebKeys.MVC_PATH%>", "<%=ECRFUserJspPaths.JSP_DIALOG_MANAGE_EXP_GROUP %>");
    renderURL.setParameter("<%=ECRFUserCRFAttributes.CRF_ID%>", crfId);
    renderURL.setParameter("crfSubjectInfoJsonStr", JSON.stringify(crfSubjectInfoArr));
    
	AUI().use("liferay-util-window", function(A) {
		Liferay.Util.openWindow({
			dialog: {
				width:800,
				height:800,
				modal: true,
				cenered: true
			},
			id: "manageExpGroupPopup",
			title: "Manage Experimental Group",
			uri: renderURL.toString() 
		})
	});
}

function manageUpdateLockPopup() {
	var renderURL = Liferay.PortletURL.createRenderURL();
	renderURL.setPortletId("<%=themeDisplay.getPortletDisplay().getId() %>");
	renderURL.setPortletMode("edit");
    renderURL.setWindowState("pop_up");
    renderURL.setParameter("<%=ECRFUserWebKeys.MVC_PATH%>", "<%=ECRFUserJspPaths.JSP_DIALOG_MANAGE_UPDATE_LOCK %>");
    renderURL.setParameter("<%=ECRFUserCRFAttributes.CRF_ID%>", crfId);
    renderURL.setParameter("crfSubjectInfoJsonStr", JSON.stringify(crfSubjectInfoArr));
    
	AUI().use("liferay-util-window", function(A) {
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
		})
	});
}

function fetchResearcherArr() {
	Liferay.Service(
		{
			'/ec.crf-researcher/get-crf-researcher-list' : {
				"groupId" : Liferay.ThemeDisplay.getScopeGroupId(),
				"crfId" : <%=crfId%>
			}
		},
		function(obj) {
			console.log(obj);
			
			crfResearcherInfoArr = obj;
			refreshResearcherTable();
		}
	);
}

function fetchSubjectArr() {
	Liferay.Service(
		{
			'/ec.crf-subject/get-crf-subject-list' : {
				"groupId" : Liferay.ThemeDisplay.getScopeGroupId(),
				"crfId" : <%=crfId%>
			}
		},
		function(obj) {
			console.log(obj);
			
			crfSubjectInfoArr = obj;
			refreshSubjectTable();
		}
	);
}

function refreshResearcherTable() {
	console.group(refreshResearcherTable.name);
	console.log("researcher table refresh and print current researcher arr");
	console.log(crfResearcherInfoArr);
	researcherTable.clear();
	researcherTable.rows.add(crfResearcherInfoArr).draw();
	console.groupEnd();
}

function refreshSubjectTable() {
	console.group(refreshSubjectTable.name);
	console.log("subject table refresh and print current subject arr");
	console.log(crfSubjectInfoArr);
	subjectTable.clear();
	subjectTable.rows.add(crfSubjectInfoArr).draw();
	console.groupEnd();
}

Liferay.provide(window, "closePopup", function(dialogId, type, data) {
	var A = AUI();
	var dialog = Liferay.Util.Window.getById(dialogId);
	dialog.destroy();
	console.groupEnd();
	
	console.group("closePopup Function");
	console.log("closePopup called");
	console.log(dialogId);
	console.log(type);
	console.log(data);
	
	if(type == "save") {
		console.log("is it called?");	// check equals
		
		if(dialogId == "manageSubjectPopup" || dialogId == "manageUpdateLockPopup" || dialogId == "manageExpGroupPopup" ) {
			crfSubjectInfoArr = data;
			refreshSubjectTable();
		} else if (dialogId == "manageResearcherPopup") {
			crfResearcherInfoArr = data;
			refreshResearcherTable();	
		}
	}
	
	console.groupEnd();
}, ['liferay-util-window']
);

$('#<portlet:namespace/>saveBtn').on("click", function(e) {
	let form = $('#<portlet:namespace/>updateCRFFm');
	let researcherListInput = $('#<portlet:namespace/>researcherListInput');
	let subjectListInput = $('#<portlet:namespace/>subjectListInput');
	
	subjectListInput.val(JSON.stringify(crfSubjectInfoArr));
	researcherListInput.val(JSON.stringify(crfResearcherInfoArr));
	
	form.submit();
});

AUI().ready(function() {
	tableLoading();	
});

Liferay.Portlet.ready(
function(portletId, node) {
	var date = new Date();
	console.log(date);
	console.log(portletId);		
});

function tableLoading() {
	console.group("table load start");
			
	researcherTable = new DataTable('#researcherList',{
		lengthChange: false,
		searching: false,
		dom: "B<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>" +
		"<'row'<'col-sm-12'tr>>" +
		"<'row marBr'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
		buttons: [
            {
            	text : 'Manage Researhcer',
            	className : 'small-btn marBrh',
            	action : function( e, dt, node, config) {
            		manageResearcherPopup();     
            	}
            }
		],
		data : crfResearcherInfoArr,
		columns: [
	        { data: "name" },
	        {
				data:"birth",
				render: function(data, type, row) {
					let dateStr = dateMilToFormat(data);
					return dateStr;
				}
			}, 
			{
				data:"gender",
				render: function(data, type, row) {
					let genderStr = genderToStr(data);
					return genderStr;
				}
			},
			{ data: "position" },
			{ data: "institution" }
	    ],
	    columnDefs: [ { "defaultContent": "-", "targets": "_all" } ]
	});
	
	subjectTable = $('#subjectList').DataTable({
		dom: "B<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>" +
		"<'row'<'col-sm-12'tr>>" +
		"<'row marBr'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
        buttons: [
            {
            	text : 'Manage Subject',
            	className : 'small-btn marRr marBrh',
            	action : function( e, dt, node, config) {
            		manageSubjectPopup();            		
            	}
            },
            {
            	text : 'Manage Exp. Group',
            	className : 'small-btn marRr marBrh',
            	action : function( e, dt, node, config) {
            		manageExpGroupPopup();            		
            	}
            },
            {
            	text : 'Manage Update Lock',
            	className : 'small-btn marRr marBrh',
            	action : function( e, dt, node, config) {
            		manageUpdateLockPopup();            		
            	}
            },
		],
		data : crfSubjectInfoArr,
		columns: [
			{data:"subjectName"}, 
			{data:"serialId"}, 
			{
				data:"subjectBirth",
				render: function(data, type, row) {
					let dateStr = dateMilToFormat(data);
					return dateStr;
				}
			}, 
			{
				data:"subjectGender",
				render: function(data, type, row) {
					let genderStr = genderToStr(data);
					return genderStr;
				}
			},
			{
				data:"experimentalGroup",
				render: function(data, type, row) {
					// check and return value
					return "Not Assign";
				}
			},
			{
				data:"updateLock",
				render: function(data, type, row) {
					// check and return value
					console.log("updatelock : " + data);
					let lockStr = "N";
					if(data == true) {
						lockStr = "Y";
					}
					
					return lockStr;
				}
			}
		]
	});
	
	fetchSubjectArr();
	
	fetchResearcherArr();
	
	console.groupEnd();
}

</script>
