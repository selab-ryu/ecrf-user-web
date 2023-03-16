<%@page import="ecrf.user.constants.ECRFUserResearcherAttributes"%>
<%@page import="ecrf.user.constants.ECRFUserWebKeys"%>
<%@page import="ecrf.user.constants.ECRFUserMVCCommand"%>
<%@page import="ecrf.user.constants.ECRFUserConstants"%>
<%@page import="ecrf.user.model.Researcher"%>
<%@page import="ecrf.user.service.ResearcherLocalServiceUtil"%>
<%@ include file="../init.jsp" %>

<liferay-ui:success key="researcherWithUserAdded" message="researcher-with-user-added" />

<%
Logger _logger = Logger.getLogger(this.getClass().getName());

SimpleDateFormat sdf = new SimpleDateFormat("YYYY/MM/dd");

List<Researcher> researcherList = ResearcherLocalServiceUtil.getResearcherByGroupId(scopeGroupId);
int totalCount = ResearcherLocalServiceUtil.getResearcherCount(scopeGroupId);

String keywords = ParamUtil.getString(request, "keywords");

%>



<portlet:renderURL var="searchURL">
	<portlet:param name="mvcPath" value="/html/researcher/list-researcher.jsp" />
</portlet:renderURL>

<portlet:renderURL var="viewURL">
	<portlet:param name="mvcPath" value="/html/view.jsp" />
</portlet:renderURL>

<aui:form action="${searchURL}" name="fm">
	<liferay-ui:header backURL="${viewURL}" title="back" />
	
	<div class="row">
		<div class="col-md-8">
			<aui:input inlineLabel="left" label="" name="keywords" placeholder="search-entries" size="256" />
		</div>
		<div class="col-md-4">
			<aui:button type="submit" value="search" />
		</div>
	</div>
</aui:form>

<aui:button-row>
	<portlet:renderURL var="addResearcherURL">
		<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_ADD_RESEARCHER %>" />
		<portlet:param name="<%=ECRFUserWebKeys.REDIRECT %>" value="<%=redirect %>" />
	</portlet:renderURL>
	
	<aui:button onClick="<%=addResearcherURL.toString() %>" value="Add Researcher" />
</aui:button-row>

<liferay-ui:search-container 
	total="<%=totalCount %>"
	delta="10"
	emptyResultsMessage="No Researchers were found"
	emptyResultsMessageCssClass="taglib-empty-result-message-header"
	var ="searchContainer" 
>
<liferay-ui:search-container-results
	results="<%=ResearcherLocalServiceUtil.getResearcherByGroupId(scopeGroupId.longValue(), searchContainer.getStart(), searchContainer.getEnd()) %>" />
	
	<% int count = searchContainer.getStart(); %>
	
	<liferay-ui:search-container-row
		className="ecrf.user.model.Researcher"
		keyProperty="researcherId" 
		modelVar="researcher" 
		escapedModel="<%=true %>">
		
		<%
		long userId = researcher.getResearcherUserId();
		User researcherUser = UserLocalServiceUtil.getUser(userId);
		%>
		
		<portlet:renderURL var="rowURL">
			<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_RESEARCHER %>" />
			<portlet:param name="<%=ECRFUserResearcherAttributes.RESEARCHER_ID %>" value="<%=String.valueOf(researcher.getResearcherId()) %>" />
		</portlet:renderURL>
		
		<liferay-ui:search-container-column-text
			name="ecrf-user.list.no"
			value="<%=String.valueOf(++count) %>"
		/>
		
		<liferay-ui:search-container-column-text
			name="ecrf-user.list.email"
			value="<%=Validator.isNull(researcherUser.getEmailAddress()) ? "-" : researcherUser.getEmailAddress() %>"
		/>
		
		<liferay-ui:search-container-column-text
			href="<%=rowURL.toString() %>"
			name="ecrf-user.list.name"
			value="<%=Validator.isNull(researcherUser.getFullName()) ? "-" : researcherUser.getFullName() %>"
		/>
		
		<liferay-ui:search-container-column-text
			name="ecrf-user.birth"
			value="<%=Validator.isNull(researcher.getBirth()) ? "-" : sdf.format(researcher.getBirth()) %>"
		/>
		
		<liferay-ui:search-container-column-text
			name="ecrf-user.position"
			value="<%=Validator.isNull(researcher.getPosition()) ? "-" : researcher.getPosition() %>"
		/>
		
		<liferay-ui:search-container-column-text
			name="ecrf-user.institution"
			value="<%=Validator.isNull(researcher.getInstitution()) ? "-" : researcher.getInstitution() %>"
		/>
		
	</liferay-ui:search-container-row>
	
<liferay-ui:search-iterator />
	
</liferay-ui:search-container>

