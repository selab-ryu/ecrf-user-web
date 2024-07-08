<%@page import="ecrf.user.constants.ECRFUserActionKeys"%>
<%@page import="ecrf.user.constants.type.ResearcherPosition"%>
<%@ page import="com.liferay.portal.kernel.portlet.PortletURLUtil"%>
<%@ page import="ecrf.user.researcher.util.SearchUtil"%>
<%@ page import="ecrf.user.constants.type.Gender"%>
<%@ page import="ecrf.user.constants.attribute.ECRFUserSubjectAttributes"%>
<%@ page import="ecrf.user.constants.attribute.ECRFUserResearcherAttributes"%>
<%@ page import="ecrf.user.constants.ECRFUserWebKeys"%>
<%@ page import="ecrf.user.constants.ECRFUserMVCCommand"%>
<%@ page import="ecrf.user.constants.ECRFUserConstants"%>
<%@ page import="ecrf.user.model.Researcher"%>
<%@ page import="ecrf.user.service.ResearcherLocalServiceUtil"%>

<%@ include file="../init.jsp" %>

<liferay-ui:success key="researcherWithUserAdded" message="researcher-with-user-added" />

<%! private static Log _log = LogFactoryUtil.getLog("html.researcher.list_researcher_jsp"); %>

<%
SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

int totalCount = ResearcherLocalServiceUtil.getResearchersCount();
ArrayList<Researcher> researcherList = new ArrayList<>();
researcherList.addAll(ResearcherLocalServiceUtil.getResearcherBySite(scopeGroupId));

_log.info("all researcher size : "+totalCount);

String menu = "researcher-list";

boolean isSearch = ParamUtil.getBoolean(renderRequest, "isSearch", false); 

PortletURL portletURL = null;

// set search keyword
if(isSearch) {
	_log.info("search");
	
	SearchUtil searchUtil = new SearchUtil(researcherList);
	searchUtil.setRequest(renderRequest);
	
	portletURL = PortletURLUtil.getCurrent(renderRequest, renderResponse);
	_log.info("portlet url : " + portletURL.toString());
		
	String emailKeyword = ParamUtil.getString(renderRequest, ECRFUserResearcherAttributes.EMAIL, StringPool.BLANK);
	String screenNameKeyword = ParamUtil.getString(renderRequest, ECRFUserResearcherAttributes.SCREEN_NAME, StringPool.BLANK);
	String nameKeyword = ParamUtil.getString(renderRequest, ECRFUserResearcherAttributes.NAME, StringPool.BLANK);;
	
	Date birthStart = null;
	Date birthEnd = null;
	
	String birthStartStr = ParamUtil.getString(renderRequest, ECRFUserResearcherAttributes.BIRTH_START);	
	if(!birthStartStr.isEmpty()) { birthStart = sdf.parse(birthStartStr); }
	
	String birthEndStr = ParamUtil.getString(renderRequest, ECRFUserResearcherAttributes.BIRTH_END);
	if(!birthEndStr.isEmpty()) { birthEnd = sdf.parse(birthEndStr); }
	
	int genderNum = ParamUtil.getInteger(renderRequest, ECRFUserResearcherAttributes.GENDER, -1);
	Gender gender = Gender.valueOf(genderNum);
	
	researcherList = searchUtil.search(emailKeyword, screenNameKeyword, nameKeyword, birthStart, birthEnd, gender);	
}
%>

<portlet:renderURL var="searchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_RESEARCHER %>" />
	<portlet:param name="isSearch" value="true" />
</portlet:renderURL>

<portlet:renderURL var="clearSearchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_RESEARCHER %>" />	
</portlet:renderURL>

<portlet:renderURL var="addResearcherURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_ADD_RESEARCHER %>" />
	<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
</portlet:renderURL>

<div class="ecrf-user ecrf-user-researcher">

	<%@ include file="sidebar.jspf" %>

	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.researcher.title.researcher-list" />
		
		<!-- search option section -->
		<aui:form action="${searchURL}" name="searchOptionFm" autocomplete="off" cssClass="marBr">
			<aui:container cssClass="radius-shadow-container">
				<aui:row>
					<aui:col md="4">
						<aui:field-wrapper
							name="<%=ECRFUserResearcherAttributes.EMAIL %>"
							label="ecrf-user.researcher.email"
							helpMessage=""
							cssClass="marBrh"
						>
							<aui:input
								type="text"
								name="<%=ECRFUserResearcherAttributes.EMAIL %>"  
								cssClass="form-control"
								label=" "
								></aui:input>
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="4">
						<aui:field-wrapper
							name="<%=ECRFUserResearcherAttributes.SCREEN_NAME %>"
							label="ecrf-user.researcher.screen-name"
							helpMessage=""
							cssClass="marBrh"
						>
							<aui:input
								type="text"
								name="<%=ECRFUserResearcherAttributes.SCREEN_NAME %>" 
								cssClass="form-control" 
								label=" "
								></aui:input>
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="4">
						<aui:field-wrapper
							name="<%=ECRFUserResearcherAttributes.NAME %>"
							label="ecrf-user.researcher.name"
							helpMessage=""
							cssClass="marBrh"
						>
							<aui:input
								type="text"
								name="<%=ECRFUserResearcherAttributes.NAME %>" 
								cssClass="form-control" 
								label=" "
								></aui:input>
						</aui:field-wrapper>
					</aui:col>
				</aui:row>
				<aui:row>
					<aui:col md="4">
						<aui:field-wrapper
							name="<%=ECRFUserResearcherAttributes.BIRTH_START %>"
							label="ecrf-user.researcher.birth.start"
							helpMessage=""
							cssClass="marBrh"
						>
							<aui:input 
								name="<%=ECRFUserResearcherAttributes.BIRTH_START %>"
								cssClass="date"
								label="" />
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="4">
						<aui:field-wrapper
							name="<%=ECRFUserResearcherAttributes.BIRTH_END %>"
							label="ecrf-user.researcher.birth.end"
							helpMessage=""
							cssClass="marBrh"
						>
							<aui:input 
								name="<%=ECRFUserResearcherAttributes.BIRTH_END %>"
								cssClass="date"
								label="" />
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="4">
						<aui:field-wrapper
							name="<%=ECRFUserResearcherAttributes.GENDER %>"
							label="ecrf-user.general.gender"
							helpMessage=""
							cssClass="marBrh"
						>
							<aui:fieldset cssClass="radio-one-line radio-align">
								<aui:input 
									type="radio" 
									name="<%=ECRFUserResearcherAttributes.GENDER %>" 
									cssClass="search-input"
									label="ecrf-user.general.male"  
									value="0" />
								<aui:input 
									type="radio" 
									name="<%=ECRFUserResearcherAttributes.GENDER %>" 
									cssClass="search-input"
									label="ecrf-user.general.female" 
									value="1" />
							</aui:fieldset>
						</aui:field-wrapper>
					</aui:col>
				</aui:row>								
				<aui:row>
					<aui:col md="12">
						<aui:button-row cssClass="right marVr">
							<aui:button name="search" cssClass="add-btn medium-btn radius-btn"  type="submit" value="ecrf-user.button.search"></aui:button>
							<aui:button name="clear" cssClass="reset-btn medium-btn radius-btn" type="button" value="ecrf-user.button.clear" onClick="<%=clearSearchURL %>"></aui:button>
						</aui:button-row>
					</aui:col>
				</aui:row>
			</aui:container>
		</aui:form>
		
		<liferay-ui:search-container 
			delta="10"
			total="<%=researcherList.size() %>"
			emptyResultsMessage="No Researchers were found"
			emptyResultsMessageCssClass="taglib-empty-result-message-header"
			var ="searchContainer" 
		>
		<liferay-ui:search-container-results
			results="<%=ListUtil.subList(researcherList, searchContainer.getStart(), searchContainer.getEnd()) %>"
			 />
			
			<% int count = searchContainer.getStart(); %>
			
			<liferay-ui:search-container-row
				className="ecrf.user.model.Researcher"
				keyProperty="researcherId" 
				modelVar="researcher" 
				escapedModel="<%=true %>">
				
				<%
				long userId = researcher.getResearcherUserId();
				User researcherUser = UserLocalServiceUtil.getUser(userId);
				%>
				
				<portlet:renderURL var="rowURL">
					<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_RESEARCHER %>" />
					<portlet:param name="<%=ECRFUserResearcherAttributes.RESEARCHER_ID %>" value="<%=String.valueOf(researcher.getResearcherId()) %>" />
					<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
					<portlet:param name="menu" value="<%=menu %>" />
				</portlet:renderURL>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.no"
					value="<%=String.valueOf(++count) %>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.email"
					value="<%=Validator.isNull(researcherUser.getEmailAddress()) ? "-" : researcherUser.getEmailAddress() %>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.screen-name"
					value="<%=Validator.isNull(researcherUser.getScreenName()) ? "-" : researcherUser.getScreenName() %>"
				/>
				
				<%
				boolean hasViewPermission = ResearcherPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_RESEARCHER);
				%>
				
				<liferay-ui:search-container-column-text
					href="<%=rowURL.toString() %>"
					name="ecrf-user.list.name"
					value="<%=Validator.isNull(researcher.getName()) ? "-" : researcher.getName() %>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.birth"
					value="<%=Validator.isNull(researcher.getBirth()) ? "-" : sdf.format(researcher.getBirth()) %>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.position"
					value="<%=Validator.isNull(researcher.getPosition()) ? "-" : ResearcherPosition.findByLower(researcher.getPosition()).getFull() %>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.institution"
					value="<%=Validator.isNull(researcher.getInstitution()) ? "-" : researcher.getInstitution() %>"
				/>
				
				<%
				// it make error ?
				boolean hasUpdatePermission = ResearcherPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ADD_RESEARCHER);
				if(user.getUserId() == researcher.getResearcherUserId()) hasUpdatePermission = true;
				%>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.update"
				>
					<portlet:renderURL var="updateResearcherURL">
						<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_UPDATE_RESEARCHER %>" />
						<portlet:param name="<%=ECRFUserResearcherAttributes.RESEARCHER_ID %>" value="<%=String.valueOf(researcher.getResearcherId()) %>" />
						<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />						
					</portlet:renderURL>
					
					<aui:button disabled="<%=hasUpdatePermission ? false : true %>" name="update" type="button" value="ecrf-user.button.update" cssClass="small-btn edit-btn" onClick="<%=updateResearcherURL %>" />
				</liferay-ui:search-container-column-text>
			</liferay-ui:search-container-row>
			
		<liferay-ui:search-iterator />
		
		</liferay-ui:search-container>
	</div>
</div>

<script>
$(document).ready(function() {
	$("#<portlet:namespace/>birthStart").datetimepicker({
		lang: 'kr',
		changeYear: true,
		changeMonth : true,
		validateOnBlur: false,
		gotoCurrent: true,
		timepicker: false,
		format: 'Y/m/d',
		scrollMonth: false
	});
	$("#<portlet:namespace/>birthStart").mask("0000/00/00");
	
	$("#<portlet:namespace/>birthEnd").datetimepicker({
		lang: 'kr',
		changeYear: true,
		changeMonth : true,
		validateOnBlur: false,
		gotoCurrent: true,
		timepicker: false,
		format: 'Y/m/d',
		scrollMonth: false
	});
	$("#<portlet:namespace/>birthEnd").mask("0000/00/00");	
});
</script>

<aui:script use="aui-base">
A.one('#<portlet:namespace/>search').on('click', function() {
	var isDateValid = dateCheck("birthStart", "birthEnd", '<portlet:namespace/>');
	
	console.log("date valid : " + isDateValid);
	
	if(isDateValid) {
		var form = $('#<portlet:namespace/>searchOptionFm');
		form.submit();
	} else if(!isDateValid) {
		var dialog = new A.Modal({
			headerContent: '<h3><liferay-ui:message key="Date validation"/></h3>',
			bodyContent: '<span style="color:red;"><liferay-ui:message key="Start Date is greater than End Date"/></span>',
			centered: true,
			modal: true,
			height: 200,
			width: 400,
			render: '#body-div',
			zIndex: 1100,
			close: true
		}).render();
	}
});
</aui:script>