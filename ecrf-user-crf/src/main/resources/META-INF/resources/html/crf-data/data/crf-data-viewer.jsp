<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf-form/crf-data-viewer_jsp"); %>

<%
long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0); 
long sdId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID, 0);

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

%>

<portlet:actionURL name="<%= ECRFUserMVCCommand.ACTION_ADD_CRF_VIEWER %>" var="saveActionURL">
	<portlet:param name="subjectId" value="<%=String.valueOf(subjectId)%>"/>
	<portlet:param name="isUpdate" value="<%=String.valueOf(isUpdate)%>"/>
</portlet:actionURL>

<div class="ecrf-user ecrf-user-crf-data">
	<%@ include file="../other/sidebar.jspf" %>	
	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect %>" title='<%=isUpdate ? "Update CRF" : "ADD CRF" %>' />
		<div class="marBr">
			<aui:button-row>
				<aui:button type="button" id="btnTable" value="Table"></aui:button>
				<aui:button type="button" id="btnVert" value="Vertical"></aui:button>
			</aui:button-row>
		</div>
		<div class="col-md-12"  id="<portlet:namespace/>canvasPanel"></div>
		<form action="<%=saveActionURL.toString() %>" name="<portlet:namespace/>fm" id="<portlet:namespace/>fm" method="post">
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
$('#<portlet:namespace/>btnTable').css("background-color","#5f73ff");
let viewer = new ev.Viewer(dataStructure, align, <%=answerForm%>);
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
		$('#<portlet:namespace/>fm').submit();
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

</script>