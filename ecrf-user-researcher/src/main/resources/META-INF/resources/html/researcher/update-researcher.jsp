<%@page import="ecrf.user.service.ResearcherLocalServiceUtil"%>
<%@page import="ecrf.user.constants.ECRFUserResearcherAttributes"%>
<%@page import="ecrf.user.constants.ECRFUserAttributes"%>
<%@page import="ecrf.user.constants.ECRFUserMVCCommand"%>
<%@page import="ecrf.user.model.Researcher" %>
<%@ include file="../init.jsp" %>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.researcher.update_researcher_jsp");
%>

<liferay-ui:success key="researcherWithUserAdded" message="researcher-with-user-added" />

<%
boolean isUpdate = false;

long researcherId = ParamUtil.getLong(renderRequest, ECRFUserResearcherAttributes.RESEARCHER_ID);

Researcher researcher = null;
if(researcherId > 0) {
	researcher = ResearcherLocalServiceUtil.getResearcher(researcherId);
}

%>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_ADD_RESEARCHER %>" var="addResearcherURL">
</portlet:actionURL>

<liferay-ui:header backURL="<%=redirect %>" title="ecrf.user.researcher.title.add-resarcher" />

<div class="ecrf-user-researcher">
	<aui:container cssClass="radius-shadow-container">
		<aui:form name="updateResearhcerFm" action="<%=addResearcherURL %>" method="post" autocomplete="off">
		<aui:input type="hidden" name="<%=Constants.CMD %>" value="<%=Constants.ADD %>"/>
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
					<aui:input autofocus="true" name="<%=ECRFUserResearcherAttributes.EMAIL %>"/>
					<aui:input name="<%=ECRFUserResearcherAttributes.PASSWORD1 %>" />			
					<aui:input name="<%=ECRFUserResearcherAttributes.PASSWORD2 %>" />
					
				</aui:col>
				<aui:col md="6">
					<aui:input name="<%=ECRFUserResearcherAttributes.SCREEN_NAME %>" />
					<aui:input name="<%=ECRFUserResearcherAttributes.FIRST_NAME %>" />
					<aui:input name="<%=ECRFUserResearcherAttributes.LAST_NAME %>" />
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
					<aui:input name="<%=ECRFUserResearcherAttributes.INSTITUTION %>" />
					<aui:input name="<%=ECRFUserResearcherAttributes.PHONE %>" />
				</aui:col>
				<aui:col md="6">
					<aui:input name="<%=ECRFUserResearcherAttributes.OFFICE_CONTACT %>" />
				</aui:col>
			</aui:row>
		</aui:container>
		<aui:button-row>
			<aui:button name="addResearcher" type="submit" value="Add" />
			<aui:button name="back" type="button" value="Back" onClick="<%=redirect %>"/>
		</aui:button-row>
		</aui:col>
		</aui:row>
		</aui:form>
	</aui:container>
</div>