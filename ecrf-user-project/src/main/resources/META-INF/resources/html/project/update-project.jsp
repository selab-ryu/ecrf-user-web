<%@page import="ecrf.user.constants.ECRFUserUtil"%>
<%@page import="com.liferay.portal.kernel.service.RoleLocalServiceUtil"%>
<%@page import="com.liferay.portal.kernel.util.Tuple"%>
<%@page import="com.liferay.portal.kernel.service.UserGroupLocalServiceUtil"%>
<%@page import="com.liferay.portal.kernel.util.CalendarFactoryUtil"%>
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html.project.update_project_jsp"); %>

<%
_log.info("group id : " + scopeGroupId);

long projectId = ParamUtil.getLong(renderRequest, ECRFUserProjectAttributes.PROJECT_ID, 0);
Project project = null;

long principalResearchId = 0;
long manageResearcherId = 0;

String menu = "add-project";

boolean isUpdate = false;

String startDateStr = null;
String endDateStr = null;

if(projectId > 0) {
	project = (Project)renderRequest.getAttribute(ECRFUserProjectAttributes.PROJECT);
	isUpdate = true;
	menu = "update-project";
	
	startDateStr = ECRFUserUtil.getDateStr(project.getStartDate());
	endDateStr = ECRFUserUtil.getDateStr(project.getEndDate());
}

Date date = new Date();
Calendar startDateCalendar = CalendarFactoryUtil.getCalendar(date.getTime());
Calendar endDateCalendar = CalendarFactoryUtil.getCalendar(date.getTime());
%>

<portlet:renderURL var="viewProjectURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_PROJECT%>" />
</portlet:renderURL>

<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_PROJECT %>" var="deleteProjectURL" >
	<portlet:param name="<%=ECRFUserProjectAttributes.PROJECT_ID %>" value="<%=String.valueOf(projectId) %>" />
</liferay-portlet:actionURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_UPDATE_PROJECT %>" var="updateProjectURL" />

<div class="ecrf-user-project ecrf-user">

	<%@ include file="sidebar.jspf" %>
	
	<div class="page-content">
	
		<liferay-ui:header backURL="<%=redirect %>" title="<%=Validator.isNull(project) ? "ecrf.user.project.title.add-project" : "ecrf.user.project.title.update-project" %>" />
		
		<aui:form name="fm" action="<%=updateProjectURL %>" autocomplete="off" method="POST">
		
		<aui:input name="<%=Constants.CMD %>" type="hidden" value="<%=Validator.isNull(project) ? Constants.ADD : Constants.UPDATE %>" />
		<aui:input name="<%=ECRFUserProjectAttributes.PROJECT_ID %>" type="hidden" value="<%=String.valueOf(projectId) %>" />
		
		<!-- Project info -->
		<aui:container cssClass="radius-shadow-container">
			<aui:row>
				<aui:col md="12">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf.user.project.title.project-info" />
					</span>
					<hr align="center" class="marV5"></hr>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col md="12">
					<aui:input
						autoFocus="true"
						name="<%=ECRFUserProjectAttributes.TITLE %>" 
						label="ecrf.user.project.title"
						cssClass="search-input" 
						required="true" 
						value="<%=Validator.isNull(project) ? StringPool.BLANK : project.getTitle() %>"
						/>
				</aui:col>
			</aui:row>
			<aui:row>
				<aui:col md="12">
					<aui:input 
						name="<%=ECRFUserProjectAttributes.SHORT_TITLE %>" 
						label="ecrf.user.project.short-title"
						cssClass="search-input" 
						required="true"
						value="<%=Validator.isNull(project) ? StringPool.BLANK : project.getShortTitle() %>" 
						/>
				</aui:col>
			</aui:row>
			<aui:row>
				<aui:col md="12">
					<aui:input 
						name="<%=ECRFUserProjectAttributes.PURPOSE %>"
						cssClass="search-input" 
						label="ecrf.user.project.purpose"
						value="<%=Validator.isNull(project) ? StringPool.BLANK : project.getPurpose() %>"
						 />
				</aui:col>
			</aui:row>
			<aui:row>
				<aui:col md="6">
					<aui:input 
						name="<%=ECRFUserProjectAttributes.START_DATE %>" 
						label="ecrf.user.project.start-date"
						cssClass="search-input" 
						required="true"
						value="<%=Validator.isNull(startDateStr) ? "" : startDateStr %>"
						 />
				</aui:col>
				<aui:col md="6">
					<aui:input 
						name="<%=ECRFUserProjectAttributes.END_DATE %>" 
						label="ecrf.user.project.end-date"
						cssClass="search-input" 
						required="true"
						value="<%=Validator.isNull(endDateStr) ? "" : endDateStr %>" 
						/>
				</aui:col>
			</aui:row>
	 	</aui:container>
		<!-- Project info -->
		
		<!-- buttons -->
		<aui:container>
			<aui:row>
				<aui:col>
					<aui:button-row>
						<c:choose>
							<c:when test="<%=(projectId > 0) %>">
								<c:if test="<%=ProjectModelPermission.contains(permissionChecker, projectId, ActionKeys.UPDATE) %>">			
									<button type="submit" class="icon-button-submit icon-button-submit-update" name="<portlet:namespace/>update">
										<img src="<%= renderRequest.getContextPath() + "/btn_img/update_icon.png"%>"/>
										<span>Update</span>
									</button>
												
								</c:if>
								<c:if test="<%=ProjectModelPermission.contains(permissionChecker, projectId, ActionKeys.DELETE) %>">
									<%
										String title = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-exp-group.title");
										String content = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-exp-group.content");
										String deleteFunctionCall = String.format("deleteConfirm('%s', '%s', '%s' )", title, content, deleteProjectURL.toString());
									%>
									<a class="icon-button-submit icon-button-submit-delete" onClick="<%=deleteFunctionCall %>" name="btnDelete">
										<img src="<%=renderRequest.getContextPath() + "/btn_img/delete_icon.png"%>"/>
										<span>Delete</span>
									</a>
								</c:if>
						 	</c:when>
						 	<c:otherwise>
						 		<c:if test="<%=ProjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ADD_PROJECT) %>">
	 								<button type="submit" class="icon-button-submit icon-button-submit-add" name="<portlet:namespace/>add">
										<img src="<%= renderRequest.getContextPath() + "/btn_img/add_icon.png"%>"/>
										<span>Add</span>
									</button>	
						 		</c:if>
						 	</c:otherwise>
					 	</c:choose>		
					 	
						<a class="icon-button-submit icon-button-submit-cancel" href="<%=viewProjectURL %>" name="<portlet:namespace/>cancel">
							<img src="<%= renderRequest.getContextPath() + "/btn_img/cancel_icon.png"%>"/>					
							<span style="color:black;">Cancel</span>
						</a>
					</aui:button-row>
				</aui:col>
			</aui:row>
		</aui:container>
		<!-- buttons -->
		
		</aui:form>
		
	</div>
</div>

<script>
$(document).ready(function() {
	$("#<portlet:namespace/>startDate").datetimepicker({
		lang: 'kr',
		changeYear: true,
		changeMonth : true,
		validateOnBlur: false,
		gotoCurrent: true,
		timepicker: false,
		format: 'Y/m/d',
		scrollMonth: false
	});
	$("#<portlet:namespace/>startDate").mask("0000/00/00", {placehodler:"yyyy/mm/dd"});
	
	$("#<portlet:namespace/>endDate").datetimepicker({
		lang: 'kr',
		changeYear: true,
		changeMonth : true,
		validateOnBlur: false,
		gotoCurrent: true,
		timepicker: false,
		format: 'Y/m/d',
		scrollMonth: false
	});
	$("#<portlet:namespace/>endDate").mask("0000/00/00", {placehodler:"yyyy/mm/dd"});

});
</script>