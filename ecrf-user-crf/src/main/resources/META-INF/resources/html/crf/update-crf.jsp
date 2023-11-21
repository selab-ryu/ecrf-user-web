<%@page import="com.sx.constant.StationXWebKeys"%>
<%@page import="ecrf.user.constants.ECRFUserCRFAttributes"%>
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf/update-crf_jsp"); %>

<%
	boolean isAdd = true;

	long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFAttributes.CRF_ID, 0);
	CRF crf = null;

	long dataTypeId = 0;	
	DataType dataType = null;
	
	_log.info("crf id : " + crfId);
	
	if(crfId > 0) {
		isAdd = false;
		crf = CRFLocalServiceUtil.getCRF(crfId);
		dataTypeId = crf.getDatatypeId();
	}
	
	_log.info("dataType id : " + dataTypeId);
	
	if(dataTypeId > 0) {
		dataType = DataTypeLocalServiceUtil.getDataType(dataTypeId);
	}
	
	boolean isUpdate = !isAdd;
	
	String pageTitle = "Add CRF";
%>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_ADD_CRF %>" var="addCRFURL">
</portlet:actionURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_UPDATE_CRF %>" var="updateCRFURL">
</portlet:actionURL>

<portlet:actionURL var="deleteCRFURL">
</portlet:actionURL>

<div class="ecrf-user-crf">
	
	<aui:form id="crfFm" name="crfFm" method="post" action="">
	<aui:container>
	
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
				<h3 class="marTr">
					<span class="vertical-align-bottom"><liferay-ui:message key="<%= pageTitle %>" /></span>
				</h3>
			</aui:col>
		</aui:row>
	
		<aui:row>
			<aui:col>
				<hr class="header-hr">
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col>
				<aui:field-wrapper
					name="crfTitle"
					label="ecrf-user.crf-title"
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
					label="ecrf-user.description"
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
					label="ecrf-user.crf-var-name"
					required="true"
					value="<%= Validator.isNull(dataType)?StringPool.BLANK:dataType.getDataTypeName() %>"
					helpMessage="ecrf-user.crf-var-name-help">
				</aui:input>
			</aui:col>
			<aui:col md="4">
				<aui:input
					name="crfVersion" 
					label="ecrf-user.version"  
					required="true" 
					placeholder="1.0.0"
					value="<%= Validator.isNull(dataType)?StringPool.BLANK:dataType.getDataTypeVersion() %>"
					helpMessage="ecrf-user.crf-version-help">
				</aui:input>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col md="6">
				<aui:input
					type="number"
					name="managerId" 
					label="Manager Researcher ID"
					helpMessage="ecrf-user.crf-manager-id-help">
				</aui:input>
			</aui:col>
			<aui:col md="6">
				
			</aui:col>
		</aui:row>
		
		
		
		<aui:row>
			<aui:col>
				<hr class="header-hr">
			</aui:col>
		</aui:row>
		
		<aui:button-row>
			<aui:button type="submit" value="Save" />
			
			<c:if test="<%=isUpdate %>">
			<aui:button value="Delete" onClick="<%=deleteCRFURL.toString() %>" />
			
			<portlet:actionURL var="defineStructureURL">
				<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_DEFINE_STRUCTURE %>" />
				<portlet:param name="crfId" value="<%=String.valueOf(crfId) %>" />
			</portlet:actionURL>
			
			<aui:button value="Define Structure" onClick="<%=defineStructureURL.toString() %>" />
			</c:if>
			
			<c:if test="<%=true%>">
			
			<aui:button value="Researcher Connect" />
			
			<aui:button value="Patient Connect" />
			</c:if>
			
			<aui:button id="btnCancel" value="Cancel" href="<%= redirect %>"></aui:button>
		</aui:button-row>
		
	</aui:container>
	</aui:form>
</div>

<aui:script>
$(document).ready(function() {
	const isUpdate = <%=isUpdate %>;
	
	let actionURL = isUpdate ? '<%=updateCRFURL.toString() %>' : '<%=addCRFURL.toString() %>';
	
	$('#<portlet:namespace/>crfFm').prop('action', actionURL);
	
});
</aui:script>