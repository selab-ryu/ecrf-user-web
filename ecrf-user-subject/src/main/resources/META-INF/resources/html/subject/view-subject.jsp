<%@ include file="../init.jsp" %>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.subject.view_subject_jsp");
%>

<%
SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");


String menu = ParamUtil.getString(renderRequest, "menu", ECRFUserMenuConstants.VIEW_SUBJECT);

long subjectId = ParamUtil.getLong(renderRequest, ECRFUserSubjectAttributes.SUBJECT_ID, 0);

boolean isExist = false;

String subjectBirthStr = null;
String visitDateStr = null;
String consentDateStr = null;
String participationDateStr = null;
boolean isMale = true;

Subject subject = null;
if(subjectId > 0) {
	subject = (Subject)renderRequest.getAttribute(ECRFUserSubjectAttributes.SUBJECT);
	if(Validator.isNotNull(subject)) isExist = true;	
}

if(isExist) {
	subjectBirthStr = ECRFUserUtil.getDateStr(subject.getBirth());
	
	// gender value / male : 0, female : 1
	int genderValue = subject.getGender();
	isMale = (genderValue == 1) ? false : true;	// if null -> male is true (default value)
}

_log.info("jsp variable loading end");
%>

<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_ADD_SUBJECT %>" var="addSubjectURL">
</liferay-portlet:actionURL>

<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_UPDATE_SUBJECT %>" var="updateSubjectURL">
	<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(subjectId) %>" />
</liferay-portlet:actionURL>

<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_SUBJECT %>" var="deleteSubjectURL">
	<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(subjectId) %>" />
</liferay-portlet:actionURL>

<portlet:renderURL var="listSubjectURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_SUBJECT %>" />
	<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
</portlet:renderURL>

<div class="">

	<%@include file="sidebar.jspf" %>
	
	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.subject.title.view-subject" />
	
		<aui:container cssClass="radius-shadow-container">			
			<aui:row>
				<aui:col md="12" cssClass="sub-title-bottom-border marBr">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf-user.subject.title.subject-info" />
					</span>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col md="3">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.NAME %>"
						label="ecrf-user.subject.name"
						required="true"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="6">
					<aui:input 
						autofocus="true" 
						name="<%=ECRFUserSubjectAttributes.NAME %>" 
						label="" 
						value="<%=Validator.isNull(subject) ? StringPool.BLANK : subject.getName() %>"
						disabled="true"
						>
					</aui:input>
				</aui:col>
			</aui:row>
			<aui:row>
				<aui:col md="3">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.SERIAL_ID %>"
						label="ecrf-user.subject.serial-id"
						required="true"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="6">
					<aui:input 
						name="<%=ECRFUserSubjectAttributes.SERIAL_ID %>" 
						label=""  
						value="<%=Validator.isNull(subject) ? StringPool.BLANK : subject.getSerialId() %>"
						disabled="true">
					</aui:input>
				</aui:col>
			</aui:row>
				
			<aui:row>
				<aui:col md="3">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.BIRTH %>"
						label="ecrf-user.subject.birth"
						required="true"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="6">
					<aui:input 
						name="<%=ECRFUserSubjectAttributes.BIRTH %>"
						cssClass="date"
						placeholder="yyyy/mm/dd"
						label=""
						value="<%=Validator.isNull(subjectBirthStr) ? "" : subjectBirthStr %>" 
						disabled="true"
						>
						<aui:validator name="date" />
					</aui:input>
				</aui:col>
			</aui:row>
			<aui:row>
				<aui:col md="3">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.GENDER %>"
						label="ecrf-user.subject.gender"
						required="true"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="6">
					<aui:fieldset cssClass="radio-one-line radio-align">
						<aui:input 
							type="radio" 
							name="<%=ECRFUserSubjectAttributes.GENDER %>" 
							cssClass="search-input"
							label="ecrf-user.subject.male"  
							value="0"
							checked="<%=isMale ? true : false  %>" 
							disabled="true" />
						<aui:input 
							type="radio" 
							name="<%=ECRFUserSubjectAttributes.GENDER %>" 
							cssClass="search-input"
							label="ecrf-user.subject.female" 
							value="1"
							checked="<%=isMale ? false : true %>"
							disabled="true" 
							/>
					</aui:fieldset>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col md="3">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.ADDRESS %>" 
						label="ecrf-user.subject.address"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="6">
					<aui:input
						name="<%=ECRFUserSubjectAttributes.ADDRESS %>" 
						label="" value="<%=Validator.isNull(subject) ? StringPool.BLANK : subject.getAddress() %>"
						disabled="true"/>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col md="3">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.PHONE %>"
						label="ecrf-user.subject.phone1"
						required="true"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="6">
					<aui:input 
						name="<%=ECRFUserSubjectAttributes.PHONE %>" 
						label="" 
						placeholder="000-0000-0000" 
						value="<%=Validator.isNull(subject) ? StringPool.BLANK : subject.getPhone() %>" 
						disabled="true"
						>
						</aui:input>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col md="3">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.PHONE_2 %>"
						label="ecrf-user.subject.phone2"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="6">
					<aui:input 
						name="<%=ECRFUserSubjectAttributes.PHONE_2 %>" 
						label="" 
						placeholder="000-0000-0000" 
						value="<%=Validator.isNull(subject) ? StringPool.BLANK : subject.getPhone2() %>" 
						disabled="true"
						>
						</aui:input>
				</aui:col>
			</aui:row>
					
			<aui:row>
				<aui:col md="3">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.HOSPITAL_CODE %>"
						label="ecrf-user.subject.hospital-code"
						required="true"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="6">
					<aui:input 
						type="number" 
						name="<%=ECRFUserSubjectAttributes.HOSPITAL_CODE %>" 
						label="" 
						value="<%=Validator.isNull(subject) ? StringPool.BLANK : subject.getHospitalCode() %>" 
						disabled="true" />
				</aui:col>
			</aui:row>
						
			<aui:row>
				<aui:col md="12">
					<aui:button-row cssClass="mar0 marL10">
						<aui:button type="button" name="cancel" cssClass="cancel-btn medium-btn radius-btn" value="ecrf-user.button.list" onClick="<%=listSubjectURL %>"></aui:button>
					</aui:button-row>
				</aui:col>
			</aui:row>

		</aui:container>
	</div>

</div>