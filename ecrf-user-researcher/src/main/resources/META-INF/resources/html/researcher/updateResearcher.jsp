<%@page import="selab.ecrf.user.constants.ECRFUserResearcherAttributes"%>
<%@page import="selab.ecrf.user.constants.ECRFUserAttributes"%>
<%@page import="selab.ecrf.user.constants.ECRFUserMVCCommand"%>
<%@ include file="../init.jsp" %>

<%
Logger _logger = LoggerFactory.getLogger(this.getClass().getName());
boolean isUpdate = false;


%>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_ADD_RESEARCHER %>" var="addResearcherURL">
</portlet:actionURL>

<div class="ecrf-user-researcher">
	<aui:container cssClass="radius-shadow-container">
		<!-- subject info title -->
		<aui:row cssClass="marBrh">
			<aui:col md="12">
				<span class="title-span">
					<liferay-ui:message key="ecrf.user.researcher.title.add-resarcher" />
				</span>
			</aui:col>
		</aui:row>
		
		<aui:form name="updateResearhcerFm" action="<%=addResearcherURL %>" method="post" autocomplete="off">
		<aui:input type="hidden" name="<%=Constants.CMD %>" value="<%=Constants.ADD %>"/>
		<aui:row>
		<aui:col md="12">
		<!-- user info -->
		<aui:container>
			<aui:row>
				<aui:col md="12">
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
				<aui:col md="12">
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
		</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="12">
				<aui:button-row>
					<aui:button name="addResearcher" type="submit" value="Add" />
				</aui:button-row>
			</aui:col>
		</aui:row>
		</aui:form>
	</aui:container>
</div>