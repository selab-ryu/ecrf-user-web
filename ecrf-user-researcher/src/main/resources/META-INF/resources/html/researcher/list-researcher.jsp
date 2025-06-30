<%@ include file="../init.jsp" %>

<liferay-ui:success key="researcherWithUserAdded" message="researcher-with-user-added" />

<%! private static Log _log = LogFactoryUtil.getLog("html.researcher.list_researcher_jsp"); %>

<%
SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

int totalCount = ResearcherLocalServiceUtil.getResearchersCount();
ArrayList<Researcher> researcherList = new ArrayList<>();
researcherList.addAll(ResearcherLocalServiceUtil.getResearcherBySite(scopeGroupId));

_log.info("all researcher size : "+totalCount);

String menu = ECRFUserMenuConstants.LIST_RESEARCHER;

boolean isSearch = ParamUtil.getBoolean(renderRequest, "isSearch", false); 

PortletURL portletURL = null;

portletURL = PortletURLUtil.getCurrent(renderRequest, renderResponse);

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
							helpMessage="ecrf-user.researcher.email.help"
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
							helpMessage="ecrf-user.researcher.screen-name.help"
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
							helpMessage="ecrf-user.researcher.name.help"
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
							helpMessage="ecrf-user.researcher.birth.start.help"
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
							helpMessage="ecrf-user.researcher.birth.end.help"
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
							helpMessage="ecrf-user.general.gender.help"
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
							<button id="<portlet:namespace/>search" type="button" class="br20 dh-icon-button submit-btn search-btn white-text w130 h40 marR8 active">
								<img class="search-icon" />
								<span><liferay-ui:message key="ecrf-user.button.search" /></span>
							</button>
							<button id="<portlet:namespace/>clear" type="button" class="br20 dh-icon-button submit-btn clear-btn white-text w130 h40 active" onclick=".location.href='<%=clearSearchURL%>'">
								<img class="clear-icon" />							
								<span><liferay-ui:message key="ecrf-user.button.clear" /></span>
							</button>
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
				
				<% boolean hasViewPermission = ResearcherPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_RESEARCHER); %>
				
				<liferay-ui:search-container-column-text
					href="<%=hasViewPermission ? rowURL : "javascript:void(0);" %>"
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

				<liferay-ui:search-container-column-text
					name="ecrf-user.list.name"
					value="<%=Validator.isNull(researcher.getName()) ? "-" : researcher.getName() %>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.birth"
					value="<%=Validator.isNull(researcher.getBirth()) ? "-" : sdf.format(researcher.getBirth()) %>"
				/>
				
				<c:if test="false">
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.position"
					value="<%=Validator.isNull(researcher.getPosition()) ? "-" : ResearcherPosition.findByLower(researcher.getPosition()).getFull() %>"
				/>
				</c:if>
				
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
					
					<%
					String updateBtnClass = "dh-icon-button w130";
					String updateOnClickStr = "location.href='"+updateResearcherURL+"'";
					String updateBtnKey = "ecrf-user.button.update-data";
					
					if(!hasUpdatePermission) {
						updateBtnClass += " inactive";
						updateOnClickStr = "";
						updateBtnKey = "ecrf-user.button.locked";
					} else {
						updateBtnClass += " update-btn";
					}
					%>
					
					<button name="<portlet:namespace/>updateCRF" type="button" class="<%=updateBtnClass%>" onclick="<%=updateOnClickStr%>" <%=!hasUpdatePermission ? "disabled" : "" %>>
						<img class="update-icon<%=TagAttrUtil.inactive(!hasUpdatePermission, TagAttrUtil.TYPE_ICON) %>" />
						<span><liferay-ui:message key="<%=updateBtnKey %>" /></span>
					</button>
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