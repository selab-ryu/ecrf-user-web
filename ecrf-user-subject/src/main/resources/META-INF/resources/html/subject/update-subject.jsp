<%@ include file="../init.jsp" %>

<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.16/jquery.mask.js" integrity="sha512-0XDfGxFliYJPFrideYOoxdgNIvrwGTLnmK20xZbCAvPfLGQMzHUsaqZK8ZoH+luXGRxTrS46+Aq400nCnAT0/w==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.subject.update_subject_jsp");
%>

<%
SimpleDateFormat sdf = new SimpleDateFormat("YYYY/MM/dd");

boolean updatePermission = true;

//check user roles
if(user != null) {
	List<Role> roleList = user.getRoles();
	for(int i=0; i<roleList.size(); i++) {
		Role role = roleList.get(i);
		//_logger.info("user role : " + role.getName());
		if(role.getName().equals("Guest")) updatePermission = false;
	}
}

long subjectId = ParamUtil.getLong(renderRequest, ECRFUserSubjectAttributes.SUBJECT_ID, 0);

boolean isUpdate = false;

Date subjectBirth = null;
Date visitDate = null;

Date consentDate = null;
Date participationDate = null;

int subjectBirthYearVal = 0;
int subjectBirthMonthVal = -1;
int subjectBirthDayVal = 0;

int visitDateYearVal = 0;
int visitDateMonthVal = -1;
int visitDateDayVal = 0;

int consentDateYearVal = 0;
int consentDateMonthVal = -1;
int consentDateDayVal = 0;

int participationStartDateYearVal = 0;
int participationStartDateMonthVal = -1;
int participationStartDateDayVal = 0;

Subject subject = null;
if(subjectId > 0) {
	subject = (Subject)renderRequest.getAttribute(ECRFUserSubjectAttributes.SUBJECT);
	if(Validator.isNotNull(subject)) isUpdate = true;	
}

if(isUpdate) {
	subjectBirth = subject.getBirth();
	if(Validator.isNull(subjectBirth)) {
		subjectBirth = new Date();
	}
}
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


<div class="mar1r">
	<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.subject.title.add-subject" />

	<aui:form name="updateSubjectFm" action="<%=isUpdate ? updateSubjectURL : addSubjectURL %>" method="POST" autocomplete="off">
	<aui:container cssClass="radius-shadow-container">
		<aui:input type="hidden" name="<%=Constants.CMD %>" value="<%=Constants.ADD %>" />
		
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
					label="ecrf-user.subject.name"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input autofocus="true" name="<%=ECRFUserSubjectAttributes.NAME %>" label="" />
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.subject.serial-id"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input name="<%=ECRFUserSubjectAttributes.SERIAL_ID %>" label="" />
			</aui:col>
		</aui:row>
			
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.subject.birth"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
			
			<aui:input name="<%=ECRFUserSubjectAttributes.BIRTH %>" class="form-control date" type="text" placeholder="yyyy/mm/dd" value="<%=subjectBirth %>" label="">
				<aui:validator name="required" />
				<aui:validator name="date" />
			</aui:input>
			
			<!--  
				<liferay-ui:input-date
					cssClass="form-control marBr-date"
					name="<%=ECRFUserSubjectAttributes.BIRTH %>"
					showDisableCheckbox="false"
					yearParam="<%=ECRFUserSubjectAttributes.BIRTH_YEAR %>"
					yearValue="<%=subjectBirthYearVal %>"
					monthParam="<%=ECRFUserSubjectAttributes.BIRTH_MONTH %>"
					monthValue="<%=subjectBirthMonthVal %>"
					dayParam="<%=ECRFUserSubjectAttributes.BIRTH_DAY %>"
					dayValue="<%=subjectBirthDayVal %>"
				/>
			-->
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.subject.gender"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:fieldset cssClass="radio-one-line">
					<aui:input type="radio" name="<%=ECRFUserSubjectAttributes.GENDER %>" cssClass="search-input" value="0" label="ecrf-user.subject.male" />
					<aui:input type="radio" name="<%=ECRFUserSubjectAttributes.GENDER %>" cssClass="search-input" value="1" label="ecrf-user.subject.female" />
				</aui:fieldset>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.subject.address"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input name="<%=ECRFUserSubjectAttributes.ADDRESS %>" label="" />
			</aui:col>
		</aui:row>
				
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.subject.phone1"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input name="<%=ECRFUserSubjectAttributes.PHONE %>" label="" placeholder="000-0000-0000" />
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.subject.phone2"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input name="<%=ECRFUserSubjectAttributes.PHONE_2 %>" label="" />
			</aui:col>
		</aui:row>
				
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.subject.hospital-code"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input type="number" name="<%=ECRFUserSubjectAttributes.HOSPITAL_CODE %>" label="" />
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.subject.visit-date"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input name="<%=ECRFUserSubjectAttributes.VISIT_DATE%>" class="form-control date" type="text" placeholder="yyyy/mm/dd" label="">
					<aui:validator name="required" />
					<aui:validator name="date" />
				</aui:input>
			
			<!-- 
				<liferay-ui:input-date
					cssClass="form-control marBr-date"
					name="<%=ECRFUserSubjectAttributes.VISIT_DATE%>"
					showDisableCheckbox="false"
					yearParam="<%=ECRFUserSubjectAttributes.VISIT_DATE_YEAR %>"
					yearValue="<%=visitDateYearVal %>"
					monthParam="<%=ECRFUserSubjectAttributes.VISIT_DATE_MONTH %>"
					monthValue="<%=visitDateMonthVal %>"
					dayParam="<%=ECRFUserSubjectAttributes.VISIT_DATE_DAY %>"
					dayValue="<%=visitDateDayVal %>"
				/>
		 	-->
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.subject.consent-date"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<liferay-ui:input-date
					cssClass="form-control marBr-date"
					name="<%=ECRFUserSubjectAttributes.CONSENT_DATE%>"
					showDisableCheckbox="false"
					yearParam="<%=ECRFUserSubjectAttributes.CONSENT_DATE_YEAR %>"
					yearValue="<%=consentDateYearVal %>"
					monthParam="<%=ECRFUserSubjectAttributes.CONSENT_DATE_MONTH %>"
					monthValue="<%=consentDateMonthVal %>"
					dayParam="<%=ECRFUserSubjectAttributes.CONSENT_DATE_DAY %>"
					dayValue="<%=consentDateDayVal %>"
				/>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.subject.participation-date"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<liferay-ui:input-date
					cssClass="form-control marBr-date"
					name="<%=ECRFUserSubjectAttributes.PARTICIPATION_START_DATE%>"
					showDisableCheckbox="false"
					yearParam="<%=ECRFUserSubjectAttributes.PARTICIPATION_START_DATE_YEAR %>"
					yearValue="<%=participationStartDateYearVal %>"
					monthParam="<%=ECRFUserSubjectAttributes.PARTICIPATION_START_DATE_MONTH %>"
					monthValue="<%=participationStartDateMonthVal %>"
					dayParam="<%=ECRFUserSubjectAttributes.PARTICIPATION_START_DATE_DAY %>"
					dayValue="<%=participationStartDateDayVal %>"
				/>
			</aui:col>
		</aui:row>
				
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					label="ecrf-user.subject.experimental-group"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input name="<%=ECRFUserSubjectAttributes.EXPERIMENTAL_GROUP %>" label="" />
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col md="12">
				<aui:button-row cssClass="mar0 marL10">
					<aui:button type="submit" name="save" cssClass="" value="ecrf-user.button.save"></aui:button>
					<aui:button type="button" name="delete" cssClass="<%=isUpdate ? StringPool.BLANK : "hide" %>" value="ecrf-user.button.delete" onClick="<%=deleteSubjectURL %>"></aui:button>
					<aui:button type="button" name="cancel" cssClass="" value="ecrf-user.button.cancel" onClick="<%=listSubjectURL %>"></aui:button>
				</aui:button-row>
			</aui:col>
		</aui:row>
			
	</aui:container>
	</aui:form>
</div>

<script>
	$(function() {
		
	});
	
	$(document).ready(function() {
		console.log("test");
		$("#<portlet:namespace/>phone").mask("000-0000-0000", {placeholder: "000-0000-0000"});
		$("#<portlet:namespace/>phone2").mask("000-0000-0000", {placeholder: "000-0000-0000"});
		
		$("#<portlet:namespace/>birth").datepicker({
			dateFormat: 'yy/mm/dd',
			changeYear: true,
			gotoCurrent: true
		});
		$("#<portlet:namespace/>birth").mask("0000/00/00");
		
		$("#<portlet:namespace/>visitDate").datepicker({
			dateFormat: 'yy/mm/dd',
			changeYear: true
		});
		$("#<portlet:namespace/>visitDate").mask("0000/00/00");
	});
</script>