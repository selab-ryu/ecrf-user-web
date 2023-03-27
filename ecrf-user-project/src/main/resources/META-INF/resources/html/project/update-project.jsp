<%@page import="ecrf.user.model.Researcher"%>
<%@page import="com.liferay.portal.kernel.util.CalendarFactoryUtil"%>
<%@page import="ecrf.user.project.internal.security.permission.resource.ProjectPermission"%>
<%@page import="ecrf.user.constants.ECRFUserMVCCommand"%>
<%@ include file="../init.jsp" %>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.researcher.update_researcher_jsp");
%>

<%
long projectId = ParamUtil.getLong(renderRequest, ECRFUserProjectAttributes.PROJECT_ID, 0);
Project project = null;

if(projectId > 0) {
	project = (Project)renderRequest.getAttribute(ECRFUserProjectAttributes.PROJECT);
}

Date date = new Date();
Calendar startDateCalendar = CalendarFactoryUtil.getCalendar(date.getTime());
Calendar endDateCalendar = CalendarFactoryUtil.getCalendar(date.getTime());
%>

<portlet:renderURL var="viewProjectURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_PROJECT%>" />
</portlet:renderURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_UPDATE_PROJECT %>" var="updateProjectURL" />

<liferay-ui:header backURL="<%=redirect %>" title="<%=Validator.isNull(project) ? "ecrf.user.project.title.add-project" : "ecrf.user.project.title.update-project" %>" />

<div class="ecrf-user-project">

<!-- check user permission -->
<c:choose>
<c:when test="<%=ProjectPermission.contains(permissionChecker, scopeGroupId, "ADD_PROJECT") %>">

<aui:form name="fm" action="<%=updateProjectURL %>" autocomplete="off" method="POST">
<aui:model-context bean="<%=project %>" model="<%= Project.class %>" />
<aui:input name="<%=Constants.CMD %>" type="hidden" value="<%=Validator.isNull(project) ? Constants.ADD : Constants.UPDATE %>" />
<aui:input name="<%=ECRFUserProjectAttributes.PROJECT_ID %>" type="hidden" value="<%=String.valueOf(projectId) %>" />

<!-- Project info -->
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
				required="true" />
		</aui:col>
	</aui:row>
	<aui:row>
		<aui:col md="12">
			<aui:input 
				name="<%=ECRFUserProjectAttributes.SHORT_TITLE %>" 
				label="ecrf.user.project.short-title"
				cssClass="search-input" 
				required="true" />
		</aui:col>
	</aui:row>
	<aui:row>
		<aui:col md="12">
			<aui:input 
				name="<%=ECRFUserProjectAttributes.PURPOSE %>"
				cssClass="search-input" 
				label="ecrf.user.project.purpose" />
		</aui:col>
	</aui:row>
	<aui:row>
		<aui:col md="6">
			<aui:input 
				name="startDate" 
				label="ecrf.user.project.start-date"
				cssClass="search-input" 
				required="true" />
		</aui:col>
		<aui:col md="6">
			<aui:input 
				name="endDate" 
				label="ecrf.user.project.end-date"
				cssClass="search-input" 
				required="true" />
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
<!-- Project info -->

<!-- buttons -->
<aui:container>
	<aui:row>
		<aui:col>
			<aui:button-row>
				<aui:button type="submit" value="Save" />	
				<aui:button type="button" value="Back" onClick="<%=redirect.toString() %>" />
			</aui:button-row>
		</aui:col>
	</aui:row>
</aui:container>
<!-- buttons -->

</aui:form>

</c:when>
<c:otherwise>

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
				<liferay-ui:message key="ecrf.user.project.info.no-permission" />
			</span>
		</aui:col>
	</aui:row>
	<aui:row>
		<aui:col>
			<aui:button-row>
				<aui:button type="button" value="Back" onClick="<%=viewProjectURL.toString() %>" />
			</aui:button-row>
		</aui:col>
	</aui:row>
</aui:container>

</c:otherwise>
</c:choose>

</div>

<aui:script use="node">
</aui:script>