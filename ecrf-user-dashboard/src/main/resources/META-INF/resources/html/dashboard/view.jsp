<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/dashboard/view.jsp"); %>

<%

Layout curLayout = themeDisplay.getLayout();
boolean isPublic = curLayout.isPublicLayout();
_log.info("is public page : " + isPublic);

Group curGroup = themeDisplay.getScopeGroup();

List<User> siteUsers = UserLocalServiceUtil.getGroupUsers(scopeGroupId);

boolean isSiteMember = false;

if(updatePermission && Validator.isNotNull(user)) {
	for(int i=0; i<siteUsers.size(); i++) {
		User tempSiteUser = siteUsers.get(i);
		if(tempSiteUser.getUserId() == user.getUserId()) isSiteMember = true;
	}
}

%>

<div class="ecrf-user ecrf-user-dashboard">
	
<div class="mar16px">
		<liferay-ui:header title="ecrf-user.dashboard.title.view-dashboard" />
		
		<!-- 
		<c:if test="<%=isSiteMember %>">
		<aui:button value="Move to Private Page" href="<%=curGroup.getDisplayURL(themeDisplay, true) %>" />
		</c:if>
		 -->
	</div>
</div>		
	