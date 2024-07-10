<%@page import="ecrf.user.constants.type.UILayout"%>
<%@page import="ecrf.user.constants.ECRFUserActionKeys"%>
<%@ include file="../init.jsp" %>

<%
	String menu = "crf-add";
	
	boolean isUpdate = false;

	CRF crf = null;
	
	
	if(crfId > 0) {
		crf = (CRF)renderRequest.getAttribute(ECRFUserCRFAttributes.CRF);
		if(Validator.isNotNull(crf)) {
			isUpdate = true;
			menu = "crf-update";	
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
		<liferay-ui:header backURL="<%=redirect %>" title="Import Subjects" />
		<div class="marL10">
		<aui:form action="<%=importSubjectJsonURL %>" name="importJson" autocomplete="off" method="post" enctype="multipart/form-data">
			<label>import json</label>		
			<aui:row>
				<input type="file" id="jsonInput" name="jsonInput" size="75"></input>
				<input type="hidden" id="crfId" value="<%=crfId %>"/>
				<input type="hidden" id="dataTypeId" value="<%=dataTypeId %>"/>
			</aui:row>
			<aui:row>
				<aui:col md="12">
				<aui:button-row cssClass="marL10">
						<aui:button type="submit" name="import" value="import" cssClass="add-btn medium-btn radius-btn"></aui:button>
				</aui:button-row>
				</aui:col>
			</aui:row>		
			
			<div class="marTr radius-shadow-container">
				<aui:row>
					<p id="totalLength"></p>
				</aui:row>
				<aui:row>
					<table id="fileReader">
					</table>
				</aui:row>
			</div>			
		</aui:form>
		</div>
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
		