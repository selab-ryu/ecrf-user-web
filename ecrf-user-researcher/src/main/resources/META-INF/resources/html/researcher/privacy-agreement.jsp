<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html.researcher.privacy_agreement_jsp"); %>

<%

String menu = ECRFUserMenuConstants.ADD_RESEARCHER;

// setting for admin user add menu / researcher module user add menu 
String divClass = "ecrf-user ecrf-user-researcher"; 
String headerTitle = "ecrf-user.researcher.title.add-researcher";

// for control menu => admin add user at user and organization
boolean isAdminMenu = ParamUtil.getBoolean(renderRequest, "isAdminMenu", false);
_log.info("is admin menu : " + isAdminMenu);

PortletURL viewURL = renderResponse.createRenderURL();
if(Validator.isNull(backURL)) {
	backURL = viewURL.toString();
	_log.info("view url : " + viewURL);
}

// set backURL at admin menu
if(isAdminMenu) {	
	divClass += " mar1r";
	headerTitle = "ecrf-user.researcher.title.add-researcher.admin";
}

//setting for admin user add menu / researcher module user add menu

%>

<portlet:renderURL var="createAccountURL" copyCurrentRenderParameters="true">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LOGIN_CREATE_ACCOUNT %>"/>
	<portlet:param name="from" value="privacy"/>
</portlet:renderURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_ADD_RESEARCHER %>" var="addResearcherURL">
</portlet:actionURL>

<div class="<%=divClass %>">
	
	<liferay-ui:header backURL="<%=backURL %>" title="<%=headerTitle %>" />
	
	<aui:container cssClass="radius-shadow-container">
		<aui:row>
			<aui:col>
				<span>
					<strong>This is Privacy Agreement Page</strong>
				</span>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col>
				
				<aui:button-row>

					<a class="dh-icon-button submit-btn update-btn w110 h36" name="<portlet:namespace/>move" href="<%=createAccountURL%>">
						<img class="view-icon" />
						<span><liferay-ui:message key="ecrf-user.button.view" /></span>
					</a>
				</aui:button-row>
				
			</aui:col>
		</aui:row>
	</aui:container>
</div>
