<%@page import="com.liferay.frontend.taglib.servlet.taglib.util.EmptyResultMessageKeys"%>
<%@page import="ecrf.user.constants.ECRFUserActionKeys"%>
<%@ include file="../init.jsp" %>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.project.view_project_jsp");
%>

<%
Project project = null;
long projectId = 0;
int projectCount = ProjectLocalServiceUtil.getProjectCount(scopeGroupId);

String menu = ECRFUserMenuConstants.PROJECT_INFO;

if(projectCount > 0) {
	List<Project> projectList = ProjectLocalServiceUtil.getProjectByGroupId(scopeGroupId);
	project = projectList.get(0);
	projectId = project.getProjectId();
	
	_log.info("project id : " + projectId);
	
	//_log.info("project update : " + ProjectModelPermission.contains(permissionChecker, projectId, ActionKeys.UPDATE));
}

SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

boolean isPrivate = layout.isPrivateLayout();
boolean isPublic = layout.isPublicLayout();

_log.info("public / private : " + isPublic + " / " + isPrivate);

String pageClass = "page-content";
if(!isPrivate) pageClass = "mar16px";

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

<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_PROJECT %>" var="deleteProjectURL" >
	<portlet:param name="<%=ECRFUserProjectAttributes.PROJECT_ID %>" value="<%=String.valueOf(projectId) %>" />
</liferay-portlet:actionURL>

<div class="ecrf-user-project ecrf-user">
	
	<c:if test="<%=isPrivate %>" >
	<%@include file="sidebar.jspf" %>
	</c:if>
	
	<div class="<%=pageClass%>">
	<liferay-ui:header title="ecrf.user.project.title.view-project" />

	<!-- Project info -->
	<aui:container cssClass="radius-shadow-container">
		<aui:row>
			<aui:col md="12">
				<span class="title-span">
					<liferay-ui:message key="ecrf.user.project.title.project-info" />
				</span>
				<hr align="center" class="marV5"></hr>
			</aui:col>
		</aui:row>
	<c:choose>
	<c:when test="<%=Validator.isNull(project) %>">
		<aui:row>
			<aui:col cssClass="padTr">
				<liferay-frontend:empty-result-message
				animationType="<%=EmptyResultMessageKeys.AnimationType.EMPTY %>"
				description='<%= LanguageUtil.get(request, "ecrf-user.empty-no-project-info-were-found") %>'
				elementType='<%= LanguageUtil.get(request, "Project Info") %>'
			/>
			</aui:col>
		</aui:row>
	</c:when>
	<c:otherwise>
		<aui:row>
			<aui:col md="12">
				<strong><liferay-ui:message key="ecrf.user.project.title"/></strong>
				<p><%=Validator.isNull(project.getTitle()) ? StringPool.DASH : project.getTitle() %></p>
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="12">
				<strong><liferay-ui:message key="ecrf.user.project.short-title"/></strong>
				<p><%=Validator.isNull(project.getShortTitle()) ? StringPool.DASH : project.getShortTitle() %></p>
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="12">
				<strong><liferay-ui:message key="ecrf.user.project.purpose"/></strong>
				<p><%=Validator.isNull(project.getPurpose()) ? StringPool.BLANK : project.getPurpose() %></p>
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="6">
				<strong><liferay-ui:message key="ecrf.user.project.start-date"/></strong>
				<p><%=Validator.isNull(project.getStartDate()) ? StringPool.DASH : dateFormat.format(project.getStartDate()) %></p>
			</aui:col>
			<aui:col md="6">
				<strong><liferay-ui:message key="ecrf.user.project.end-date"/></strong>
				<p><%=Validator.isNull(project.getEndDate()) ? StringPool.DASH : dateFormat.format(project.getEndDate()) %></p>
			</aui:col>
		</aui:row>
	</c:otherwise>
	</c:choose>
	</aui:container>
		
	<!-- buttons -->
	<aui:row>
		<aui:col>
			<aui:button-row>
				<c:choose>
				<c:when test="<%=(projectId > 0) %>">
					<c:if test="<%=ProjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ADD_PROJECT) %>">			
						<a href="<%=updateProjectURL %>" class="dh-icon-button submit-btn update-btn w110 h36 marR8" name="<portlet:namespace/>update">
							<img class="update-icon" />
							<span><liferay-ui:message key="ecrf-user.button.update" /></span>
						</a>					
					</c:if>
					<c:if test="<%=ProjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DELETE_PROJECT) %>">
						<%
							String title = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-exp-group.title");
							String content = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-exp-group.content");
							String deleteFunctionCall = String.format("deleteConfirm('%s', '%s', '%s' )", title, content, deleteProjectURL.toString());
						%>
						<a class="dh-icon-button submit-btn delete-btn w110 h36 marR8" onClick="<%=deleteFunctionCall %>" name="btnDelete">
							<img class="delete-icon" />
							<span><liferay-ui:message key="ecrf-user.button.delete" /></span>
						</a>
					</c:if>
			 	</c:when>
			 	<c:otherwise>
			 		<c:if test="<%=ProjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ADD_PROJECT) %>">
						<a href="<%=addProjectURL %>" class="dh-icon-button submit-btn add-btn w110 h36 marR8" name="<portlet:namespace/>add">
							<img class="add-icon" />
							<span><liferay-ui:message key="ecrf-user.button.add" /></span>
						</a>	
			 		</c:if>
			 	</c:otherwise>
			 	</c:choose>		
			</aui:button-row>
		</aui:col>
	</aui:row>
	</div>
</div>