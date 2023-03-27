<%@page import="ecrf.user.constants.ECRFUserMVCCommand"%>
<%@ include file="../init.jsp" %>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.researcher.update_researcher_jsp");
%>

<%
long projectId = ParamUtil.getLong(renderRequest, ECRFUserProjectAttributes.PROJECT_ID, 0);
Project project = null;

if(projectId > 0) {
	project = ProjectLocalServiceUtil.getProject(projectId);
}

%>

<portlet:renderURL var="addProjectURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_ADD_PROJECT %>" />
	<portlet:param name="<%=Constants.CMD %>" value="<%=Constants.ADD %>" />
	<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
</portlet:renderURL>

<portlet:renderURL var="updateProjectURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_UPDATE_PROJECT %>" />
	<portlet:param name="<%=ECRFUserProjectAttributes.PROJECT_ID %>" value="<%=String.valueOf(projectId) %>" />
	<portlet:param name="<%=Constants.CMD %>" value="<%=Constants.UPDATE %>" />
	<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
</portlet:renderURL>

<liferay-ui:header title="ecrf.user.project.title.view-project" />

<div class="ecrf-user-project">

<!-- Project info -->
<c:choose>
<c:when test="<%=Validator.isNull(project) %>">
<aui:container cssClass="radius-shadow-container">
	<aui:row>
		<aui:col md="12" cssClass="sub-title-bottom-border">
			<span class="sub-title-span">
				<liferay-ui:message key="ecrf.user.project.title.project-info" />
			</span>
		</aui:col>
	</aui:row>
	<aui:row>
		<aui:col>
			<span>
				<liferay-ui:message key="ecrf.user.project.info.no-project" />
			</span>
		</aui:col>
	</aui:row>
</aui:container>
</c:when>
<c:otherwise>
<aui:form name="fm" autocomplete="off">
<aui:model-context bean="<%=project %>" model="<%= Project.class %>" />
<aui:container cssClass="radius-shadow-container">
	<aui:row>
		<aui:col md="12" cssClass="sub-title-bottom-border">
			<span class="sub-title-span">
				<liferay-ui:message key="ecrf.user.project.title.project-info" />
			</span>
		</aui:col>
	</aui:row>
	<aui:row>
		<aui:col md="12">
			<aui:input
				autoFocus="true"
				name="<%=ECRFUserProjectAttributes.TITLE %>" 
				label="ecrf.user.project.title"
				cssClass="search-input" 
				readOnly="true" />
		</aui:col>
	</aui:row>
	<aui:row>
		<aui:col md="12">
			<aui:input 
				name="<%=ECRFUserProjectAttributes.SHORT_TITLE %>" 
				label="ecrf.user.project.short-title"
				cssClass="search-input" 
				readOnly="true" />
		</aui:col>
	</aui:row>
	<aui:row>
		<aui:col md="12">
			<aui:input 
				name="<%=ECRFUserProjectAttributes.PURPOSE %>"
				cssClass="search-input" 
				label="ecrf.user.project.purpose"
				readOnly="true" />
		</aui:col>
	</aui:row>
	<aui:row>
		<aui:col md="6">
			<aui:input 
				name="startDate" 
				label="ecrf.user.project.start-date"
				cssClass="search-input" 
				readOnly="true" />
		</aui:col>
		<aui:col md="6">
			<aui:input 
				name="endDate" 
				label="ecrf.user.project.end-date"
				cssClass="search-input" 
				readOnly="true" />
		</aui:col>
	</aui:row>
	<aui:row>
		<aui:col md="12" cssClass="sub-title-bottom-border">
			<span class="sub-title-span">
				<liferay-ui:message key="ecrf.user.project.title.project-manager-info" />
			</span>
		</aui:col>
	</aui:row>
	<aui:row>
		<aui:col md="6">
			<aui:input
				type="hidden"
				name="<%=ECRFUserProjectAttributes.PRINCIPAL_RESEARCHER_ID %>"
			/>
			<aui:select
				name="principleResearcher"
				bean="<%=Researcher.class %>"
				listType=""
				showEmptyOption="true"
			>
			</aui:select>
		</aui:col>
		<aui:col md="6">
			
		</aui:col>
	</aui:row>
</aui:container>
</aui:form>
</c:otherwise>
</c:choose>

<!-- buttons -->
<aui:container>
	<aui:row>
		<aui:col>
			<aui:button-row>
				<c:choose>
				<c:when test="<%=Validator.isNull(project) %>">
					<aui:button type="button" value="Add Project Info" onClick="<%=addProjectURL.toString() %>" />	
				</c:when>
				<c:otherwise>
					<aui:button type="button" value="Update Project Info" onClick="<%=updateProjectURL.toString() %>" />
				</c:otherwise>
				</c:choose>
			</aui:button-row>
		</aui:col>
	</aui:row>
</aui:container>

</div>