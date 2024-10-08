<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf-data/crf-data-viewer_jsp"); %>

<%
SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/M/d");

long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0); 
long sdId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID, 0);
boolean isAudit = ParamUtil.getBoolean(renderRequest, "isAudit", false);

Subject subject = null;
if(subjectId > 0){
	subject = (Subject)renderRequest.getAttribute(ECRFUserCRFDataAttributes.SUBJECT);
}

String crfForm = (String)renderRequest.getAttribute(ECRFUserCRFDataAttributes.CRF_FORM);

DataType dataType = null;

if(dataTypeId > 0){
	dataType = DataTypeLocalServiceUtil.getDataType(dataTypeId);
}

CRFGroupCaculation groupApi = new CRFGroupCaculation();
JSONObject eachGroups = null;

Date visitDate = null;
boolean isUpdate = false;


String none = ParamUtil.getString(renderRequest, "none");
String menu = "add-crf-data";

String answerForm = null;
if(sdId > 0) {
	menu = "update-crf-data";
	isUpdate = true;	
	answerForm = (String)renderRequest.getAttribute(ECRFUserCRFDataAttributes.ANSWER_FORM);
}

_log.info("is update : " + isUpdate);
_log.info("is audit : " + isAudit);

%>

<portlet:actionURL name="<%= ECRFUserMVCCommand.ACTION_ADD_CRF_VIEWER %>" var="saveActionURL">
	<portlet:param name="subjectId" value="<%=String.valueOf(subjectId)%>"/>
	<portlet:param name="isUpdate" value="<%=String.valueOf(isUpdate)%>"/>
</portlet:actionURL>

<div class="ecrf-user ecrf-user-crf-data">
	<%@ include file="../other/sidebar.jspf" %>	
	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect %>" title='<%=isUpdate ? "Update CRF" : "ADD CRF" %>' />
		
		<aui:fieldset-group markupView="lexicon">
			<aui:fieldset cssClass="search-option radius-shadow-container" collapsed="<%=false %>" collapsible="<%=true %>" label="ecrf-user.subject.title.subject-info">
				<aui:container>
					<aui:row cssClass="top-border">
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="serialId"
								label="ecrf-user.subject.serial-id">
								<p><%=Validator.isNull(subject) ? "-" : String.valueOf(subject.getSerialId()) %></p>
							</aui:field-wrapper>
						</aui:col>
						<%
						String subjectName = subject.getName();
						boolean hasViewEncryptPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_ENCRYPT_SUBJECT);
						if(!hasViewEncryptPermission)
							subjectName = ECRFUserUtil.encryptName(subjectName);	
						%>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="name"
								label="ecrf-user.subject.name">
								<p><%=Validator.isNull(subject.getName()) ? "-" : subjectName %></p>
							</aui:field-wrapper>
						</aui:col>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="gender"
								label="ecrf-user.subject.gender">
								<p><%=Validator.isNull(subject) ? "-" : (subject.getGender() == 0 ? "male" : "female") %></p>
							</aui:field-wrapper>
						</aui:col>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="birth"
								label="ecrf-user.subject.birth-age">
								<p><%=Validator.isNull(subject) ? "-" : dateFormat.format(subject.getBirth()) + " (" + Math.abs(124 - subject.getBirth().getYear()) + ")" %></p>
							</aui:field-wrapper>
						</aui:col>
					</aui:row>
				</aui:container>
			</aui:fieldset>
		</aui:fieldset-group>
		
		<div class="marBr" style="display: none;">
			<aui:button-row>
				<aui:button type="button" id="btnTable" value="Table"></aui:button>
				<aui:button type="button" id="btnVert" value="Vertical"></aui:button>
			</aui:button-row>
		</div>
		
		<div class="col-md-12"  id="<portlet:namespace/>canvasPanel"></div>		
		
		<form action="<%=saveActionURL.toString() %>" name="crfViewerForm" id="crfViewerForm" method="post" enctype="multipart/form-data">
			<input type="hidden" id="<portlet:namespace/>crfId" name="<portlet:namespace/>crfId" value="<%=crfId %>" >
			<input type="hidden" id="<portlet:namespace/>dataTypeId" name="<portlet:namespace/>dataTypeId" value="<%=dataTypeId %>" >			
			<input type="hidden" id="<portlet:namespace/>structuredDataId" name="<portlet:namespace/>structuredDataId" value="<%=sdId%>" >
			<input type="hidden" id="<portlet:namespace/>dataContent" name="<portlet:namespace/>dataContent" >
			<aui:button-row>
				<aui:button type="button" id="btnSave" value="save"></aui:button>
			</aui:button-row>
		</form>
	</div>
</div>

<script>
$(document).ready(function(){
let SX = StationX(  '<portlet:namespace/>', 
		'<%= defaultLocale.toString() %>',
		'<%= locale.toString() %>',
		<%= jsonLocales.toJSONString() %> );
		
console.log(SX);
let profile = {
		dataTypeId: '<%= dataType.getDataTypeId() %>',
		dataTypeName:  '<%= dataType.getDataTypeName() %>',
		dataTypeVersion:  '<%= dataType.getDataTypeVersion() %>',
		dataTypeDisplayName:  '<%= dataType.getDisplayName(locale) %>',
		structuredDataId: '<%= sdId %>'
};
console.log(profile);

let ev = ECRFViewer();
let dataStructure = SX.newDataStructure(<%=crfForm%>, profile, SX.Constants.FOR_EDITOR, $('#<portlet:namespace/>canvasPanel'));

let align = "crf-align-table";
if(<%=CRFLocalServiceUtil.getCRF(crfId).getDefaultUILayout()%> == 0){
	align = "crf-align-table";
}else if(<%=CRFLocalServiceUtil.getCRF(crfId).getDefaultUILayout()%> == 1){
	align = "crf-align-vertical";
}
$('#<portlet:namespace/>btnTable').css("background-color","#5f73ff");

let subjectInfo = new Object();
let subjectGender = <%=subject.getGender()%>;
let subjectBirth = new Date(<%=subject.getBirth().getTime()%>);

subjectInfo["subjectGender"] = subjectGender;
subjectInfo["subjectBirth"] = subjectBirth;

let viewer = new ev.Viewer(dataStructure, align, <%=answerForm%>, subjectInfo, <%=isAudit%>);
console.log($('#<portlet:namespace/>dataContent').val());
dataStructure.renderSmartCRF();

Liferay.on( 'value_changed', function(evt){
	console.log("value_changed", JSON.stringify(evt.dataPacket.result));
	let resultStr = JSON.stringify(evt.dataPacket.result);
	$('#<portlet:namespace/>dataTypeId').val(<%=dataType.getDataTypeId()%>);
	$('#<portlet:namespace/>structuredDataId').val(<%=sdId%>);
	$('#<portlet:namespace/>dataContent').val(resultStr);
	console.log( 'dataContent: ', $('#<portlet:namespace/>dataContent').val());
});

$('#<portlet:namespace/>btnSave').on( 'click', function(event){
	if(!$('#visit_date').val()){
		alert("visit date required");
		document.getElementById('visit_date').focus();
	}else{
		$('#crfViewerForm').submit();
	}
	
});

$('#<portlet:namespace/>btnTable').on( 'click', function(event){
	$('#<portlet:namespace/>btnTable').css("background-color","#5f73ff");
	$('#<portlet:namespace/>btnVert').css("background-color","white");
	align = "crf-align-table";
	viewer = new ev.Viewer(dataStructure, align, <%=answerForm%>);
	dataStructure.renderSmartCRF();
});

$('#<portlet:namespace/>btnVert').on( 'click', function(event){
	$('#<portlet:namespace/>btnTable').css("background-color","white");
	$('#<portlet:namespace/>btnVert').css("background-color","#5f73ff");
	
	align = "crf-align-vertical";
	viewer = new ev.Viewer(dataStructure, align, <%=answerForm%>);
	dataStructure.renderSmartCRF();
});

});

Liferay.provide(window, 'openHistoryDialog', function(termName, displayName) {
	console.log("function activate");
	
	var renderURL = Liferay.PortletURL.createRenderURL();
	
	renderURL.setPortletId('<%=themeDisplay.getPortletDisplay().getId()%>');
	renderURL.setPortletMode("edit");
    renderURL.setWindowState("pop_up");
    
	renderURL.setParameter("groupId", <%=scopeGroupId %>);
	renderURL.setParameter("subjectId", <%=subjectId %>);
	renderURL.setParameter("crfId", <%=crfId %>);
	renderURL.setParameter("structuredDataId", <%=sdId %>);
	renderURL.setParameter("displayName", displayName);
	renderURL.setParameter("termName", termName);
	renderURL.setParameter("mvcRenderCommandName", "/render/crf-data/dialog-audit");
	
	Liferay.Util.openWindow(
			{
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
				title: 'Audit Trail',
				uri: renderURL.toString()
			}
		);
}, ['liferay-util-window', 'liferay-portlet-url']);

</script>