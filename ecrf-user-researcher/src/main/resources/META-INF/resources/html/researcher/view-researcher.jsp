<%@page import="ecrf.user.service.ResearcherLocalServiceUtil"%>
<%@page import="ecrf.user.constants.ECRFUserResearcherAttributes"%>
<%@page import="ecrf.user.constants.ECRFUserAttributes"%>
<%@page import="ecrf.user.constants.ECRFUserMVCCommand"%>
<%@page import="ecrf.user.model.Researcher" %>
<%@page import="com.liferay.portal.kernel.service.UserLocalServiceUtil" %>
<%@ include file="../init.jsp" %>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.researcher.update_researcher_jsp");
%>

<%
long researcherId = ParamUtil.getLong(renderRequest, ECRFUserResearcherAttributes.RESEARCHER_ID);
long userId = 0;
Researcher researcher = null;
if(researcherId > 0) {
	researcher = ResearcherLocalServiceUtil.getResearcher(researcherId);
	userId = researcher.getResearcherUserId();
}

User researcherUser = null;
if(userId > 0) {
	researcherUser = UserLocalServiceUtil.getUser(userId);
}

%>

<liferay-ui:header backURL="<%=redirect %>" title="ecrf.user.researcher.title.view-resarcher" />

<div class="ecrf-user-researcher">
	<aui:container cssClass="radius-shadow-container">
		<aui:form name="viewResearhcerFm" action="" method="post" autocomplete="off">
		<aui:row>
		<aui:col md="12">
		<!-- user info -->
		<aui:container>
			<aui:row>
				<aui:col md="12" cssClass="sub-title-bottom-border">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf.user.researcher.title.user-info" />
					</span>
				</aui:col>
			</aui:row>
			<aui:row>
				<aui:col md="6">
					<aui:input 
						autofocus="true"
						name="<%=ECRFUserResearcherAttributes.EMAIL %>" 
						value="<%=Validator.isNull(researcherUser) ? "" : researcherUser.getEmailAddress() %>"
						readonly="true" />
					<aui:input 
						name="<%=ECRFUserResearcherAttributes.SCREEN_NAME %>" 
						value="<%=Validator.isNull(researcherUser) ? "" : researcherUser.getScreenName() %>"
						readonly="true" />
				</aui:col>
				<aui:col md="6">
					<aui:input 
						name="<%=ECRFUserResearcherAttributes.FIRST_NAME %>"
						value="<%=Validator.isNull(researcherUser) ? "" : researcherUser.getFirstName() %>"
						readonly="true" />
					<aui:input 
						name="<%=ECRFUserResearcherAttributes.LAST_NAME %>"
						value="<%=Validator.isNull(researcherUser) ? "" : researcherUser.getLastName() %>"
						readonly="true" />
				</aui:col>
			</aui:row>
		</aui:container>
		<!-- resarcher info -->
		<aui:container>
			<aui:row>
				<aui:col md="12" cssClass="sub-title-bottom-border">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf.user.researcher.title.researcher-info" />
					</span>
				</aui:col>
			</aui:row>
			<aui:row>
				<aui:col md="6">
					<aui:input 
						name="<%=ECRFUserResearcherAttributes.INSTITUTION %>"
						value="<%=Validator.isNull(researcher) ? "" : researcher.getInstitution() %>"
						readonly="true" />
					<aui:input 
						name="<%=ECRFUserResearcherAttributes.PHONE %>"
						value="<%=Validator.isNull(researcher) ? "" : researcher.getPhone() %>"
						readonly="true" />
				</aui:col>
				<aui:col md="6">
					<aui:input
						name="<%=ECRFUserResearcherAttributes.POSITION %>"
						value="<%=Validator.isNull(researcher) ? "" : researcher.getPosition() %>"
						readonly="true" />
					<aui:input 
						name="<%=ECRFUserResearcherAttributes.OFFICE_CONTACT %>"
						value="<%=Validator.isNull(researcher) ? "" : researcher.getOfficeContact() %>"
						readonly="true" />
				</aui:col>
			</aui:row>
		</aui:container>
		<aui:button-row>
			<aui:button name="back" type="button" value="Back" onClick="<%=redirect %>"/>
		</aui:button-row>
		</aui:col>
		</aui:row>
		</aui:form>
	</aui:container>
</div>