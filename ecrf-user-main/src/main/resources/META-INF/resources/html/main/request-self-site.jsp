<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/main/request-self-site_jsp"); %>

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

<div class="ecrf-user" style="margin:1rem">

<liferay-ui:header backURL="<%=viewSiteURL %>" title="ecrf-user.main.title.request-self-site" />

<aui:form name="fm" action="" method="POST">

<aui:container cssClass="radius-shadow-container">
	<aui:row>
		<aui:col md="12">
			<span class="title-span">
				<liferay-ui:message key="ecrf-user.main.title.request-info" />
			</span>
			<hr align="center" class="marV5"></hr>
		</aui:col>
	</aui:row>

	<aui:row>
		<aui:col md="12">
			<aui:input
				type="text"
				name="email"
				label="ecrf-user.main.email"
				required="true"
				value="<%=Validator.isNull(curUser) ? StringPool.DASH : curUser.getEmailAddress() %>"
			/>
		</aui:col>
	</aui:row>
	
	<aui:row>
		<aui:col md="4">
			<aui:input
				type="text"
				name="lastName"
				label="ecrf-user.main.last-name"
				required="true"
				value="<%=Validator.isNull(curUser) ? StringPool.DASH : curUser.getLastName() %>"
			/>
		</aui:col> 
		<aui:col md="8">
			<aui:input
				type="text"
				name="firstName"
				label="ecrf-user.main.first-name"
				required="true"
				value="<%=Validator.isNull(curUser) ? StringPool.DASH : curUser.getFirstName() %>"
			/>
		</aui:col>
	</aui:row>
	
	<aui:row>
		<aui:col md="12">
			<aui:input
				type="text"
				name="phone"
				label="ecrf-user.main.phone"
			/>
		</aui:col> 
	</aui:row>
	
	<aui:row>
		<aui:col md="12">
			<aui:input
				type=""
				name="title"
				label="ecrf-user.main.project-title"
				required="true"
			/>
		</aui:col> 
	</aui:row>
	
	<aui:row>
		<aui:col md="12">
			<aui:input
				type="textarea"
				name="description"
				label="ecrf-user.main.project-description" 
			/>
		</aui:col> 
	</aui:row>
	
	<aui:row>
		<aui:col>
			<aui:button-row>
				<aui:button type="button" cssClass="btn-primary" name="request" value="ecrf-user.button.main.request" onClick="<%=viewSiteURL %>" />
				<aui:button type="button" name="back" value="ecrf-user.button.main.back" onClick="<%=viewSiteURL %>" />
			</aui:button-row>
		</aui:col>
	</aui:row>
	
</aui:container>
</aui:form>
</div>