
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/main/request-membership_jsp"); %>

<%
User curUser = themeDisplay.getUser();
Researcher researcher = null;

// get researcher
SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

long siteGroupId = ParamUtil.getLong(renderRequest, ECRFUserMainAttributes.SITE_GROUP_ID, 0);

%>

<portlet:renderURL var="viewSiteURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME%>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_SITE %>" />
</portlet:renderURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_ADD_MEMBERSHIP_REQUEST %>" var="requestMembershipURL">
	<portlet:param name="<%=WebKeys.USER_ID %>" value="<%=String.valueOf(curUser.getUserId()) %>" />
	<portlet:param name="<%=ECRFUserMainAttributes.SITE_GROUP_ID %>" value="<%=String.valueOf(siteGroupId) %>" />
	<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=redirect %>" />
</portlet:actionURL>

<liferay-ui:header backURL="<%=viewSiteURL %>" title="ecrf-user.main.title.request-membership" />

<aui:container cssClass="radius-shadow-container">
	<aui:row>
		<aui:col md="12">
			<span class="title-span">
				<liferay-ui:message key="ecrf-user.main.title.user-info" />
			</span>
			<hr align="center" class="marV5"></hr>
		</aui:col>
	</aui:row>
	<aui:row>
		<aui:col md="12">
			<strong><liferay-ui:message key="ecrf-user.user.full-name"/></strong>
			<p><%=Validator.isNull(curUser) ? StringPool.DASH : curUser.getFullName() %></p>
		</aui:col> 
	</aui:row>
	<aui:row>
		<aui:col md="12">
			<strong><liferay-ui:message key="ecrf-user.user.email"/></strong>
			<p><%=Validator.isNull(curUser) ? StringPool.DASH : curUser.getEmailAddress() %></p>
		</aui:col>
	</aui:row>
</aui:container>

<aui:form name="fm" action="<%=requestMembershipURL %>" method="POST">
<aui:container cssClass="radius-shadow-container marTr">
	<aui:row>
		<aui:col md="12">
			<aui:input 
				type="textarea" 
				cssClass="search-input" 
				name="<%=ECRFUserMainAttributes.REQUEST_COMMENT %>"
				required="true" 
				label="ecrf-user.main.request-comment"/>
		</aui:col>
	</aui:row>
</aui:container>

<aui:container>
	<aui:row>
		<aui:col>
			<aui:button-row>
				<aui:button type="submit" name="request" value="Request" />
				<aui:button value="Back" onClick="<%=viewSiteURL %>" />
			</aui:button-row>
		</aui:col>
	</aui:row>
</aui:container>
</aui:form>