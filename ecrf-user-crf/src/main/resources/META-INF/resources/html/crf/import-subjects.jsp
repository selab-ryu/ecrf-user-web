<%@page import="ecrf.user.constants.type.UILayout"%>
<%@page import="ecrf.user.constants.ECRFUserActionKeys"%>
<%@ include file="../init.jsp" %>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.crf.import_subjects_jsp");
%>

<%
	String menu = ECRFUserMenuConstants.UPDATE_CRF;
	
	boolean isUpdate = false;

	CRF crf = null;
	
	
	if(crfId > 0) {
		crf = (CRF)renderRequest.getAttribute(ECRFUserCRFAttributes.CRF);
		if(Validator.isNotNull(crf)) {
			isUpdate = true;
		}
	}
	
	DataType dataType = null;
	
	if(isUpdate) {
		dataTypeId = crf.getDatatypeId();
		
		if(dataTypeId > 0) {
			dataType = DataTypeLocalServiceUtil.getDataType(dataTypeId);
		}
	}
%>

<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_IMPORT_SUBJECTS %>" var="importSubjectJsonURL">
	<portlet:param name="<%= ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>"/>
	<portlet:param name="<%= ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%= String.valueOf(dataTypeId) %>"/>
</liferay-portlet:actionURL>

<div class="ecrf-user">

	<%@include file="sidebar.jspf" %>
	
	<div class="page-content">

		<div class="crf-header-title">
			<% DataType titleDT = DataTypeLocalServiceUtil.getDataType(dataTypeId); %>
			<liferay-ui:message key="ecrf-user.general.crf-title-x" arguments="<%=titleDT.getDisplayName(themeDisplay.getLocale()) %>" />
		</div>
	
		<liferay-ui:header backURL="<%=redirect %>" title="Import Subjects" />
		
		<aui:form action="<%=importSubjectJsonURL %>" name="importJson" autocomplete="off" method="post" enctype="multipart/form-data">
		<aui:container cssClass="marTr radius-shadow-container">
			<aui:row>
				<aui:col>
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf-user.crf.title.select-json-file" />
					</span>
				</aui:col>
				<aui:col>
					<input type="file" id="jsonInput" name="jsonInput" size="75"></input>
					<input type="hidden" id="crfId" value="<%=crfId %>"/>
					<input type="hidden" id="dataTypeId" value="<%=dataTypeId %>"/>
				</aui:col>
			</aui:row>
			
			<aui:button-row cssClass="marTr">
				<button type="submit" id="<portlet:namespace/>import" class="dh-icon-button submit-btn import-subject-btn w200 h36" >
					<img class="import-subject-icon" />
					<span><liferay-ui:message key="ecrf-user.button.crf.import-subject"/></span>
				</button>
			</aui:button-row>
			
			<aui:row>
				<aui:container cssClass="marTr radius-shadow-container">						
					<aui:row>
						<p id="totalLength"></p>
					</aui:row>
					<aui:row>
						<table id="fileReader">
						</table>
					</aui:row>
				</aui:container>
			</aui:row>
		</aui:container>		
		</aui:form>
	</div>
</div>

<script>
$(document).ready(function(){
	console.log($("#jsonInput"));
	$("#jsonInput").on("change", function(event){
        const reader = new FileReader();
        reader.onload = function(e){
        	let content = JSON.parse(reader.result);
        	let table = document.getElementById("fileReader");
        	table.innerHTML = "";
        	
        	$("#totalLength").text("Total subject num : " + content.length);
        	content.forEach(subject =>{
        		const insertRow = table.insertRow();
        		var i = 0;
        		for (let key in subject) {
        		    if (subject.hasOwnProperty(key)) {
        		        let cell = insertRow.insertCell(i);
        		        cell.innerText = key + " : " +  subject[key];
                        cell.style.border = "1px solid black";
                        cell.style.padding = "1rem";
        		        i++;
        		        if(i > 5){
        		        	break;
        		        }
        		    }
        		}      		
        	});
        };
        reader.readAsText(event.target.files[0]);

	});
});
</script>
		