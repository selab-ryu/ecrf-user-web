<%@page import="com.liferay.portal.kernel.portlet.LiferayPortletURL"%>
<%@page import="ecrf.user.constants.type.UILayout"%>
<%@page import="ecrf.user.constants.ECRFUserActionKeys"%>
<%@ include file="../init.jsp" %>

<%!private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf/update-crf_jsp");%>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
	
	String menu = "crf-add";
	
	boolean isUpdate = false;

	CRF crf = null;
	
	_log.info("crf id : " + crfId);
	_log.info("group Id : " + scopeGroupId);
	
	if(crfId > 0) {
		crf = (CRF)renderRequest.getAttribute(ECRFUserCRFAttributes.CRF);
		if(Validator.isNotNull(crf)) {
			isUpdate = true;
			menu = "crf-update";	
		}
	}
	
	List<String> expGroupList = Stream.of(ExperimentalGroupType.values()).map(m -> m.getFullString()).collect(Collectors.toList());
	_log.info(expGroupList);
	
	DataType dataType = null;
	
	if(isUpdate) {
		dataTypeId = crf.getDatatypeId();
		
		if(dataTypeId > 0) {
			_log.info("dataType id : " + dataTypeId);
			dataType = DataTypeLocalServiceUtil.getDataType(dataTypeId);
		}
	}
	
	LiferayPortletURL baseURL = PortletURLFactoryUtil.create(request, themeDisplay.getPortletDisplay().getId(), themeDisplay.getPlid(), PortletRequest.RENDER_PHASE);
	
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
						helpMessage="ecrf-user.crf.crf-title.help">
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
						helpMessage="ecrf-user.crf.description.help">
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
						helpMessage="ecrf-user.crf.crf-var-name.help">
					</aui:input>
				</aui:col>
				<aui:col md="4">
					<aui:input
						name="crfVersion" 
						label="ecrf-user.crf.version"  
						required="true" 
						placeholder="1.0.0"
						value="<%= Validator.isNull(dataType)?StringPool.BLANK:dataType.getDataTypeVersion() %>"
						helpMessage="ecrf-user.crf.version.help">
					</aui:input>
				</aui:col>
			</aui:row>		
			
			<c:if test="<%=CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.UPDATE_CRF_DATA_UI) %>">
			<aui:row>
				<aui:col md="12">
					<aui:field-wrapper
						name="<%=ECRFUserCRFAttributes.DEFAULT_UI_LAYOUT%>"
						label="ecrf-user.crf.default-ui-layout"
						helpMessage="ecrf-user.crf.default-ui-layout.help"
						cssClass="marBrh"
					>
						<aui:fieldset cssClass="radio-one-line radio-align">
							<aui:input 
								type="radio" 
								name="<%=ECRFUserCRFAttributes.DEFAULT_UI_LAYOUT%>" 
								cssClass="search-input"
								label="ecrf-user.crf.default-ui-layout.table" 
								value="0"
								checked="<%=Validator.isNull(crf) ? false : ((UILayout.TABLE.getNum() == crf.getDefaultUILayout()) ? true : false) %>"
								/>
							<aui:input 
								type="radio" 
								name="<%=ECRFUserCRFAttributes.DEFAULT_UI_LAYOUT%>" 
								cssClass="search-input"
								label="ecrf-user.crf.default-ui-layout.vertical" 
								value="1"
								checked="<%=Validator.isNull(crf) ? false : ((UILayout.VERTICAL.getNum() == crf.getDefaultUILayout()) ? true : false) %>"
								/> 
							<aui:input 
								type="radio" 
								name="<%=ECRFUserCRFAttributes.DEFAULT_UI_LAYOUT%>" 
								cssClass="search-input"
								label="ecrf-user.crf.default-ui-layout.station-x" 
								value="2"
								checked="<%=Validator.isNull(crf) ? false : ((UILayout.STATIONX.getNum() == crf.getDefaultUILayout()) ? true : false) %>"
								/>
						</aui:fieldset>
					</aui:field-wrapper>
				</aui:col>
			</aui:row>
			</c:if>
			
			<c:if test="<%=isUpdate %>">
			
			<c:if test="<%=CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_CRF_RESEARCHER) %>">
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
			</c:if>
			
			<c:if test="<%=CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_CRF_SUBJECT) %>">
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
			</c:if>
			
			</c:if>
			
			<aui:row>
				<aui:col md="12" cssClass="sub-title-bottom-border marBr">
				</aui:col>
			</aui:row>
			
			<c:if test="<%=isUpdate %>">
			<aui:button-row>
				<c:if test="<%=CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_CRF_FORM) %>">
				<portlet:renderURL var="moveCRFFormURL">
					<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_MANAGE_FORM %>" />
					<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
					<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(dataTypeId) %>" />
					<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
				</portlet:renderURL>
									
				<aui:button type="button" value="ecrf-user.button.manage-crf-form" onClick="<%=moveCRFFormURL %>" />
				</c:if>
				
				<c:if test="<%=CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_CRF_DATA_LIST) %>">
				<portlet:renderURL var="moveCRFDataURL">
					<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_DATA %>" />
					<portlet:param name="<%=ECRFUserWebKeys.LIST_PATH %>" value="<%=ECRFUserJspPaths.JSP_LIST_CRF_DATA_UPDATE%>" />
					<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
					<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(dataTypeId) %>" />
					<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
				</portlet:renderURL>
				
				<aui:button type="button" value="ecrf-user.button.crf-data" onClick="<%=moveCRFDataURL %>" />
				</c:if>
				
				<c:if test="<%=CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_CRF_QUERY_LIST) %>">
				<portlet:renderURL var="moveCRFQueryURL">
					<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_QUERY %>" />
					<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
					<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(dataTypeId) %>" />
					<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
				</portlet:renderURL>
				
				<aui:button type="button" value="ecrf-user.button.crf-query" onClick="<%=moveCRFQueryURL %>" />
				</c:if>
			</aui:button-row>
			</c:if>
			
			<c:if test="<%=isUpdate %>">
				<aui:button-row>
					<c:if test="<%=isAdmin %>">
					<portlet:renderURL var="moveImportSubjectsURL">
						<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_IMPORT_SUBJECTS %>" />
						<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
						<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(dataTypeId) %>" />
						<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
					</portlet:renderURL>
					
					<aui:button type="button" value="ecrf-user.button.crf-import-subject" onClick="<%=moveImportSubjectsURL %>" />
					</c:if>
					
					<c:if test="<%=isAdmin %>">
					<portlet:renderURL var="moveImportDatasURL">
						<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_IMPORT_DATAS %>" />
						<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
						<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(dataTypeId) %>" />
						<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
					</portlet:renderURL>
					
					<aui:button type="button" value="ecrf-user.button.crf-import-sddata" onClick="<%=moveImportDatasURL %>" />
					</c:if>
				</aui:button-row>
			</c:if>
			
			<aui:button-row>
				<c:choose>
				<c:when test="<%=isUpdate %>">
				
				<c:if test="<%=CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.UPDATE_CRF) %>">
					<aui:button type="button" name="saveBtn" cssClass="add-btn medium-btn radius-btn" value="ecrf-user.button.update"></aui:button>
				</c:if>
		
				<c:if test="<%=CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DELETE_CRF) %>">
					<aui:button type="button" name="delete" cssClass="delete-btn medium-btn radius-btn" value="ecrf-user.button.delete"></aui:button>
				</c:if>
								
				</c:when>
				<c:otherwise>
								
				<c:if test="<%=CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ADD_CRF) %>">
					<aui:button type="button" name="saveBtn" cssClass="add-btn medium-btn radius-btn" value="ecrf-user.button.add"></aui:button>
				</c:if>	
				
				</c:otherwise>
				</c:choose>
				<aui:button type="button" name="cancel" cssClass="cancel-btn medium-btn radius-btn"  value="ecrf-user.button.cancel" onClick="<%=listCRFURL %>"></aui:button>
			</aui:button-row>
			
		</aui:container>
		</aui:form>		
	</div>	
</div>

<script>
var resarcherTable;
var subjectTable;

var initSubjectInfoArr = [];

var crfResearcherInfoArr = [];
var crfSubjectInfoArr = [];

var crfId = "<%=String.valueOf(crfId) %>";
var dataTypeId = "<%=String.valueOf(dataTypeId) %>";

var isSubjectChanged = false;

$('#<portlet:namespace/>saveBtn').on("click", function(e) {
	let form = $('#<portlet:namespace/>updateCRFFm');
	let researcherListInput = $('#<portlet:namespace/>researcherListInput');
	let subjectListInput = $('#<portlet:namespace/>subjectListInput');
	
	subjectListInput.val(JSON.stringify(crfSubjectInfoArr));
	researcherListInput.val(JSON.stringify(crfResearcherInfoArr));
	
	if(isSubjectChanged) {
		$.confirm({
			title: '<liferay-ui:message key="ecrf-user.message.confirm-delete-crf-subject.title"/>',
			content: '<p><liferay-ui:message key="ecrf-user.message.confirm-delete-crf-subject.content"/></p>',
			type: 'red',
			typeAnimated: true,
			columnClass: 'large',
			buttons:{
				ok: {
					btnClass: 'btn-blue',
					action: function(){
						form.submit();
					}
				},
				close: {
		            action: function () {}
		        }
			},
			draggable: true
		});	
	} else {
		form.submit();
	}	
});

$('#<portlet:namespace/>delete').click( function(event){
	var title = '<liferay-ui:message key="ecrf-user.message.confirm-delete-crf.title"/>';
	var content = '<liferay-ui:message key="ecrf-user.message.confirm-delete-crf.content"/>';
	deleteConfirm(title, content, '<%=deleteCRFURL.toString() %>', 'large');
});

AUI().ready(function() {
	var isUpdate = <%=isUpdate%>;
	if(isUpdate)
		tableLoading();
});

Liferay.Portlet.ready(
function(portletId, node) {
	var date = new Date();
	//console.log(date);
	//console.log(portletId);		
});

function fetchResearcherArr() {
	Liferay.Service(
		{
			'/ec.crf-researcher/get-crf-researcher-list' : {
				"groupId" : Liferay.ThemeDisplay.getScopeGroupId(),
				"crfId" : <%=crfId%>
			}
		},
		function(obj) {
			//console.log(obj);	
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
			//console.log(obj);
			initSubjectInfoArr = obj;
			crfSubjectInfoArr = obj;
			refreshSubjectTable();
		}
	);
}

function refreshResearcherTable() {
	//console.group(refreshResearcherTable.name);
	//console.log("researcher table refresh and print current researcher arr");
	//console.log(crfResearcherInfoArr);
	researcherTable.clear();
	researcherTable.rows.add(crfResearcherInfoArr).draw();
	//console.groupEnd();
}

function refreshSubjectTable() {
	//console.group(refreshSubjectTable.name);
	//console.log("subject table refresh and print current subject arr");
	//console.log(crfSubjectInfoArr);
	subjectTable.clear();
	subjectTable.rows.add(crfSubjectInfoArr).draw();
	//console.groupEnd();
}

Liferay.provide(window, "closePopup", function(dialogId, type, data) {
	//var A = AUI();
	var dialog = Liferay.Util.Window.getById(dialogId);
	dialog.destroy();
	//console.groupEnd();
	
	//console.group("closePopup Function");
	//console.log(dialogId);
	console.log(type);
	console.log(data);
	
	if(type == "save") {
		//console.log("is it called?", dialogId);	// check equals
		
		if(dialogId == "manageSubjectPopup" || dialogId == "manageUpdateLockPopup" ) {
			crfSubjectInfoArr = data;
			refreshSubjectTable();
		} else if (dialogId == "manageResearcherPopup") {
			crfResearcherInfoArr = data;
			refreshResearcherTable();
		}
		
		if(dialogId == "manageSubjectPopup") {
			isSubjectChanged = compareCRFSubjectList();
			console.log(isSubjectChanged);
		} else {
			console.log("check");
		}
		
	}
	
	//console.groupEnd();
}, ['liferay-util-window'] );

function compareCRFSubjectList() {
	// init crf subject list is contained current crf subject list => true
	// dont matter add other subject, only check existing subjects are removed
		
	console.log(initSubjectInfoArr, crfSubjectInfoArr)
	
	if(crfSubjectInfoArr.length < initSubjectInfoArr.length) return true;
	else {
		for(var i=0; i<initSubjectInfoArr.length; i++) {
			var check = crfSubjectInfoArr.some((item) => crfSubjectEqualityCheck(item, initSubjectInfoArr[i]));
			if(!check) return true;
		}
	}
	
	return false;
}

function crfSubjectEqualityCheck(obj1, obj2) {
	// if remove and add subject => crfSubjectId is changed
	// only check subject id
	
	if(obj1['subjectId'] !== obj2['subjectId']) {
		return false;
	}
	return true;
}

function shallowEqualityCheck(obj1, obj2) {
	const keys1 = Object.keys(obj1);
	const keys2 = Object.keys(obj2);
	if (keys1.length !== keys2.length) {
		return false;
	}
	for (const key of keys1) {
		if (obj1[key] !== obj2[key]) {
			return false;
		}
	}
	return true;
}


function tableLoading() {
	console.group("table load start");
	
	var hasUpdateCRFResearcherPermission = <%=CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.UPDATE_CRF_RESEARCHER) %>;
	var resarcherDomFirstLine = "<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>";
	if(hasUpdateCRFResearcherPermission) resarcherDomFirstLine = "B<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>";
	
	researcherTable = new DataTable('#researcherList',{
		lengthChange: false,
		searching: false,
		dom: resarcherDomFirstLine +
		"<'row'<'col-sm-12'tr>>" +
		"<'row marBr'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
		buttons: [
            {
            	text : 'Manage Researhcer',
            	className : 'small-btn marBrh',
            	action : function( e, dt, node, config) {
            		openManageResearcherDialog(<%=scopeGroupId%>, "<%=themeDisplay.getPortletDisplay().getId()%>", <%=crfId%>, crfResearcherInfoArr, "<%=baseURL.toString()%>");
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
	
	var hasUpdateCRFSubjectPermission = <%=CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.UPDATE_CRF_SUBJECT) %>;
	var hasViewEncryptSubjectPermission = <%=CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_ENCRYPT_SUBJECT) %>;
	var subjectDomFirstLine = "<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>";
	if(hasUpdateCRFSubjectPermission) subjectDomFirstLine = "B<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>";
	
	subjectTable = $('#subjectList').DataTable({
		dom: subjectDomFirstLine +
		"<'row'<'col-sm-12'tr>>" +
		"<'row marBr'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
        buttons: [
            {
            	text : 'Manage Subject',
            	className : 'small-btn marRr marBrh',
            	action : function( e, dt, node, config) {
            		openManageSubjectDialog(<%=scopeGroupId%>, "<%=themeDisplay.getPortletDisplay().getId()%>", <%=crfId%>, crfSubjectInfoArr, "<%=baseURL.toString()%>");            		
            	}
            },
            {
            	text : 'Manage Update Lock',
            	className : 'small-btn marRr marBrh',
            	action : function( e, dt, node, config) {
            		openManageUpdateLockDialog(<%=scopeGroupId%>, "<%=themeDisplay.getPortletDisplay().getId()%>", <%=crfId%>, crfSubjectInfoArr, "<%=baseURL.toString()%>");
            	}
            },
		],
		data : crfSubjectInfoArr,
		columns: [
			{
				data:"subjectName",
				render: function(data, type, row) {
					if(!hasViewEncryptSubjectPermission)
						return encryptName(data);
					else {
						return data;
					}
				}
			}, 
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
