<%@page import="ecrf.user.constants.ECRFUserResearcherAttributes"%>
<%@page import="ecrf.user.constants.ECRFUserWebKeys"%>
<%@page import="ecrf.user.constants.ECRFUserMVCCommand"%>
<%@page import="ecrf.user.constants.ECRFUserConstants"%>
<%@ page import="ecrf.user.model.Researcher"%>
<%@ page import="ecrf.user.service.ResearcherLocalServiceUtil"%>
<%@ include file="../init.jsp" %>

<liferay-ui:success key="researcherWithUserAdded" message="researcher-with-user-added" />

<%
Logger _logger = Logger.getLogger(this.getClass().getName());

List<Researcher> researcherList = ResearcherLocalServiceUtil.getResearcherByGroupId(scopeGroupId);
int totalCount = ResearcherLocalServiceUtil.getResearcherCount(scopeGroupId);

%>

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
	var ="searchContainer" 
>
<liferay-ui:search-container-results
	results="<%=ResearcherLocalServiceUtil.getResearcherByGroupId(scopeGroupId.longValue(), searchContainer.getStart(), searchContainer.getEnd()) %>" />
	
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
			href="<%=rowURL.toString() %>"
			name="ecrf-user.user-name"
			value="<%=researcherUser.getFullName() %>"
		/>
	</liferay-ui:search-container-row>
	
<liferay-ui:search-iterator />
	
</liferay-ui:search-container>

