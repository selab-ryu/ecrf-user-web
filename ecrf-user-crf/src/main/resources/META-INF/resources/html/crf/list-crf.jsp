<%@page import="ecrf.user.constants.ECRFUserAttributes"%>
<%@page import="ecrf.user.constants.ECRFUserConstants"%>
<%@page import="ecrf.user.constants.ECRFUserCRFAttributes"%>
<%@ include file="../init.jsp" %>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.crf.list_crf_jsp");
%>

<%
SimpleDateFormat sdf = new SimpleDateFormat("YYYY/MM/dd");

List<CRF> crfList = CRFLocalServiceUtil.getCRFByGroupId(scopeGroupId);
int crfTotalCount = crfList.size();

%>

<portlet:renderURL var="updateCRFURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_UPDATE_CRF %>" />
	<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
</portlet:renderURL>

<div class="ecrf-user-crf">
	
	<aui:button-row>
		<aui:button name="AddCRF" value="Add CRF" onClick="<%=updateCRFURL %>" />
	</aui:button-row>
	
	<liferay-ui:search-container
		delta="10"
		total="<%=crfTotalCount %>"
		emptyResultsMessage="No CRFs were found"
		emptyResultsMessageCssClass="taglib-empty-result-message-header"
		var ="searchContainer" 
	>
		<liferay-ui:search-container-results
			results="<%=ListUtil.subList(crfList, searchContainer.getStart(), searchContainer.getEnd()) %>"
		/>
		
		<% int count = searchContainer.getStart(); %>
		
		<liferay-ui:search-container-row
			className="ecrf.user.model.CRF"
			keyProperty="crfId"
			modelVar="crf"
			escapedModel="<%=true%>"
		>
			<%
			long dataTypeId = crf.getDatatypeId();
			DataType datatype = DataTypeLocalServiceUtil.getDataType(dataTypeId);
			%>
			
			<portlet:renderURL var="rowURL">
				<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_UPDATE_CRF %>" />
				<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crf.getCrfId()) %>" />
				<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(dataTypeId) %>" />
				<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
			</portlet:renderURL>
			
			<liferay-ui:search-container-column-text
				name="ecrf-user.list.no"
				value="<%=String.valueOf(++count) %>"
			/>
			
			<liferay-ui:search-container-column-text
				href="<%=rowURL.toString() %>"
				name="ecrf-crf.list.crf-title"
				value="<%=Validator.isNull(datatype.getDisplayName(locale)) ? "-" : datatype.getDisplayName(locale) %>"
			/>
			
			<liferay-ui:search-container-column-text
				name="ecrf-crf.list.crf-description"
				value="<%=Validator.isNull(datatype.getDescription(locale)) ? "-" : datatype.getDescription(locale) %>"
			/>
			
			<liferay-ui:search-container-column-text
				name="ecrf-crf.list.crf-create-date"
				value="<%=sdf.format(crf.getCreateDate()) %>"
			/>
			
			
		</liferay-ui:search-container-row>
		
		<liferay-ui:search-iterator 
			markupView="lexicon" />	
		
	</liferay-ui:search-container>
</div>