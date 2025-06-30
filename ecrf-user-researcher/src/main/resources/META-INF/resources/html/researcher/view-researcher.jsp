<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html.researcher.view_researcher_jsp"); %>

<%
String menu = ParamUtil.getString(renderRequest, "menu", ECRFUserMenuConstants.LIST_RESEARCHER);

long researcherId = ParamUtil.getLong(renderRequest, ECRFUserResearcherAttributes.RESEARCHER_ID);
long userId = 0;

Researcher researcher = null;
User researcherUser = null;

String birthStr = null;
boolean isMale = true;
String genderStrKey = "";

if(researcherId > 0) {
	researcher = ResearcherLocalServiceUtil.getResearcher(researcherId);
	userId = researcher.getResearcherUserId();
	
	birthStr = ECRFUserUtil.getDateStr(researcher.getBirth());
	
	// gender value / male : 0, female : 1
	int genderValue = researcher.getGender();
	isMale = (genderValue == 1) ? false : true;	// if null -> male is true (default value)
	
	if(Validator.isNull(genderValue)) {
		genderStrKey = "-";
	} else {
		if(genderValue == 0) {
			genderStrKey = "ecrf-user.general.male";
		} else {
			genderStrKey = "ecrf-user.general.female";
		}
	}
	
	if(userId > 0) researcherUser = UserLocalServiceUtil.getUser(userId);
}

backURL = redirect;

%>

<div class="ecrf-user ecrf-user-researcher">

	<%@ include file="sidebar.jspf" %>

	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.researcher.title.view-researcher" />
		
		<aui:container cssClass="radius-shadow-container">	
				
		<!-- user info -->
		<aui:row>
			<aui:col md="12" cssClass="sub-title-bottom-border">
				<span class="sub-title-span">
					<liferay-ui:message key="ecrf-user.researcher.title.user-info" />
				</span>
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.researcher.email"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<p> <%=Validator.isNull(researcher) ? StringPool.DASH : researcher.getEmail() %> </p>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.researcher.screen-name"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<p> <%=Validator.isNull(researcherUser) ? StringPool.DASH : researcherUser.getScreenName() %> </p>
			</aui:col>
		</aui:row>		
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.researcher.first-name"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<p> <%=Validator.isNull(researcherUser) ? StringPool.DASH : researcherUser.getFirstName() %> </p>
			</aui:col>
		</aui:row>		
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.researcher.last-name"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<p> <%=Validator.isNull(researcherUser) ? StringPool.DASH : researcherUser.getLastName() %> </p>
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.researcher.birth"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<p> <%=Validator.isNull(birthStr) ? StringPool.DASH : birthStr %> </p>
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.general.gender"
				>
				</aui:field-wrapper>
			</aui:col>
			
			<aui:col md="6">
				<liferay-ui:message key="<%=genderStrKey %>"></liferay-ui:message>
			</aui:col>
		</aui:row>
		
		
		<!-- resarcher info -->
		<aui:row>
			<aui:col md="12" cssClass="sub-title-bottom-border">
				<span class="sub-title-span">
					<liferay-ui:message key="ecrf-user.researcher.title.researcher-info" />
				</span>
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.researcher.institution"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<p> <%=Validator.isNull(researcher) ? StringPool.BLANK : researcher.getInstitution() %> </p>
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.researcher.phone"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<p> <%=Validator.isNull(researcher) ? StringPool.DASH : researcher.getPhone() %> </p>
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.researcher.office-contact"
					>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<p> <%=Validator.isNull(researcher) ? StringPool.DASH : researcher.getOfficeContact() %> </p>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.researcher.position"
					>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<p> <%=Validator.isNull(researcher.getPosition()) ? StringPool.DASH : ResearcherPosition.findByLower(researcher.getPosition()).getFull() %> </p>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col md="12">
				<aui:button-row>
					<button name="<portlet:namespace/>back" type="button" class="dh-icon-button submit-btn cancel-btn w110 h36" onclick="location.href='<%=backURL %>'">
						<img class="back-icon" />
						<span><liferay-ui:message key="ecrf-user.button.back" /></span>
					</button>
				</aui:button-row>
				
			</aui:col>
		</aui:row>

	</aui:container>
		
	</div>
</div>