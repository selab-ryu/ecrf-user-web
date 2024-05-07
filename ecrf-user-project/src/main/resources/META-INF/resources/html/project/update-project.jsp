<%@page import="com.liferay.portal.kernel.service.RoleLocalServiceUtil"%>
<%@page import="com.liferay.portal.kernel.util.Tuple"%>
<%@page import="com.liferay.portal.kernel.service.UserGroupLocalServiceUtil"%>
<%@page import="com.liferay.portal.kernel.util.CalendarFactoryUtil"%>
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html.researcher.update_researcher_jsp"); %>

<%
_log.info("group id : " + scopeGroupId);

long projectId = ParamUtil.getLong(renderRequest, ECRFUserProjectAttributes.PROJECT_ID, 0);
Project project = null;

long principalResearchId = 0;
long manageResearcherId = 0;

String menu = "project-info";

if(projectId > 0) {
	project = (Project)renderRequest.getAttribute(ECRFUserProjectAttributes.PROJECT);
	principalResearchId = project.getPrincipalResearcherId();
	manageResearcherId = project.getManageResearcherId();
}

List<User> siteUserList = UserLocalServiceUtil.getGroupUsers(scopeGroupId);
Role adminRole = RoleLocalServiceUtil.getRole(themeDisplay.getCompanyId(), "Administrator");
_log.info("site user list size : " + siteUserList.size());

List<Researcher> leadResearcherList = new ArrayList<Researcher>();
List<Researcher> manageResearcherList = new ArrayList<Researcher>();
List<Researcher> wholeResearcherList = new ArrayList<Researcher>();

for(int i=0; i<siteUserList.size(); i++) {
	User siteUser = siteUserList.get(i);
	
	if(siteUser.getRoles().contains(adminRole)) continue;
	
	Researcher researcher = ResearcherLocalServiceUtil.getResearcherByUserId(siteUser.getUserId());
	
	if(researcher.getPosition() == "pi") {
		leadResearcherList.add(researcher);
	} else {
		manageResearcherList.add(researcher);
	}
}

int leadResearcherCount = leadResearcherList.size();
int manageResearcherCount = manageResearcherList.size(); 

_log.info("lead researcher count : " + leadResearcherCount);
_log.info("manage researcher count : " + manageResearcherCount);

Date date = new Date();
Calendar startDateCalendar = CalendarFactoryUtil.getCalendar(date.getTime());
Calendar endDateCalendar = CalendarFactoryUtil.getCalendar(date.getTime());
%>

<portlet:renderURL var="viewProjectURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_PROJECT%>" />
</portlet:renderURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_UPDATE_PROJECT %>" var="updateProjectURL" />

<div class="ecrf-user-project ecrf-user">

	<%@ include file="sidebar.jspf" %>
	
	<div class="page-content">
	
		<liferay-ui:header backURL="<%=redirect %>" title="<%=Validator.isNull(project) ? "ecrf.user.project.title.add-project" : "ecrf.user.project.title.update-project" %>" />

		<!-- check user permission -->
		<c:choose>
		<c:when test="<%=(isAdmin || isPI) %>">
		
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
						name="<%=ECRFUserProjectAttributes.START_DATE %>" 
						label="ecrf.user.project.start-date"
						cssClass="search-input" 
						required="true" />
				</aui:col>
				<aui:col md="6">
					<aui:input 
						name="<%=ECRFUserProjectAttributes.END_DATE %>" 
						label="ecrf.user.project.end-date"
						cssClass="search-input" 
						required="true" />
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
				<aui:col md="12">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf.user.project.title.project-info" />
					</span>
					<hr align="center" class="marV5"></hr>
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