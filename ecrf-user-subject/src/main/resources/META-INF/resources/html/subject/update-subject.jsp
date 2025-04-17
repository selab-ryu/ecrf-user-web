<%@page import="ecrf.user.service.ExperimentalGroupLocalServiceUtil"%>
<%@page import="ecrf.user.model.ExperimentalGroup"%>
<%@ include file="../init.jsp" %>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.subject.update_subject_jsp");
%>

<%
SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

String menu = ECRFUserMenuConstants.ADD_SUBJECT;

long subjectId = ParamUtil.getLong(renderRequest, ECRFUserSubjectAttributes.SUBJECT_ID, 0);

boolean isUpdate = false;

String subjectBirthStr = null;
boolean isMale = true;

Subject subject = null;
if(subjectId > 0) {
	subject = (Subject)renderRequest.getAttribute(ECRFUserSubjectAttributes.SUBJECT);
	if(Validator.isNotNull(subject)) {
		isUpdate = true;
		menu = ECRFUserMenuConstants.UPDATE_SUBJECT;
	}
}

int birthAge = 0;
int lunarBirthAge = 0;
if(isUpdate) {
	subjectBirthStr = ECRFUserUtil.getDateStr(subject.getBirth());
	
	Date now = new Date();
	birthAge = now.getYear() - subject.getBirth().getYear();
	if(Validator.isNotNull(subject.getLunarBirth())){
		lunarBirthAge = now.getYear() - (Integer.parseInt(subject.getLunarBirth().split("/")[0]) - 1900);
	}
	if(now.getMonth() - subject.getBirth().getMonth() < 0){
		birthAge =  birthAge + 1;
	}else if(now.getMonth() - subject.getBirth().getMonth() == 0){
		if(now.getDate() - subject.getBirth().getDate() < 0){
			birthAge =  birthAge + 1;
		}		
	}
	System.out.println(birthAge);
	// gender value / male : 0, female : 1
	int genderValue = subject.getGender();
	isMale = (genderValue == 1) ? false : true;	// if null -> male is true (default value)
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
	<portlet:param name="<%=Constants.CMD %>" value="<%=Constants.UPDATE %>"/>
</portlet:renderURL>

<portlet:renderURL var="updateListURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_SUBJECT %>" />
	<portlet:param name="<%=Constants.CMD %>" value="<%=Constants.UPDATE%>" />
	<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
</portlet:renderURL>

<div class="ecrf-user">

	<%@include file="sidebar.jspf" %>
	
	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect %>" title="<%=isUpdate ? "ecrf-user.subject.title.update-subject" : "ecrf-user.subject.title.add-subject" %>" />
	
		<aui:form name="updateSubjectFm" action="<%=isUpdate ? updateSubjectURL : addSubjectURL %>" method="POST" autocomplete="off">
		<aui:container cssClass="radius-shadow-container">
			<aui:input type="hidden" name="<%=Constants.CMD %>" value="<%=isUpdate ? Constants.UPDATE : Constants.ADD %>" />
			
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
						>
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
				<aui:col md="3">
					<aui:input 
						name="<%=ECRFUserSubjectAttributes.BIRTH %>"
						cssClass="date"
						placeholder="yyyy/mm/dd"
						label=""
						value="<%=Validator.isNull(subjectBirthStr) ? "" : subjectBirthStr %>" 
						>
					</aui:input>
				</aui:col>
				<aui:col md="3">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.BIRTH_YEAR %>"
						label="ecrf-user.subject.birth-age"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="3">
					<p id="birthAge"><%=birthAge%></p>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col md="3">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.LUNARBIRTH %>"
						label="ecrf-user.subject.lunarbirth"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="3">
					<aui:input 
						name="<%=ECRFUserSubjectAttributes.LUNARBIRTH %>" 
						label="" 
						placeholder="yyyy/mm/dd"						
						value="<%=Validator.isNull(subject) ? StringPool.BLANK : subject.getLunarBirth() %>" 
						>
						</aui:input>
				</aui:col>
				<aui:col md="3">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.LUNARBIRTH_YEAR %>"
						label="ecrf-user.subject.lunarbirth-age"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="3">
					<p id="lunarBirthAge"><%=Validator.isNotNull(subject) ? lunarBirthAge : "" %></p>
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
							checked="<%=isMale ? true : false  %>" />
						<aui:input 
							type="radio" 
							name="<%=ECRFUserSubjectAttributes.GENDER %>" 
							cssClass="search-input"
							label="ecrf-user.subject.female" 
							value="1"
							checked="<%=isMale ? false : true %>" />
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
						label="" value="<%=Validator.isNull(subject) ? StringPool.BLANK : subject.getAddress() %>"/>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col md="3">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.PHONE %>"
						label="ecrf-user.subject.phone1"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="6">
					<aui:input 
						name="<%=ECRFUserSubjectAttributes.PHONE %>" 
						label=""  
						value="<%=Validator.isNull(subject) ? StringPool.BLANK : subject.getPhone() %>" 
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
						value="<%=Validator.isNull(subject) ? StringPool.BLANK : subject.getPhone2() %>" 
						>
						</aui:input>
				</aui:col>
			</aui:row>
					
			<aui:row>
				<aui:col md="3">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.HOSPITAL_CODE %>"
						label="ecrf-user.subject.hospital-code"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="6">
					<aui:input 
						type="number" 
						name="<%=ECRFUserSubjectAttributes.HOSPITAL_CODE %>" 
						label="" 
						value="<%=Validator.isNull(subject) ? StringPool.BLANK : subject.getHospitalCode() %>" />
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col md="3">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.EXPERIMENTAL_GROUP_ID %>"
						label="ecrf-user.subject.experimental-group"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="6">
				
					<aui:select
						name="<%=ECRFUserSubjectAttributes.EXPERIMENTAL_GROUP_ID %>" 
						label=""
					>
						<aui:option selected="true" value="0"></aui:option>
					
					<%
						ArrayList<ExperimentalGroup> expGroupList = new ArrayList<>();
						expGroupList.addAll(ExperimentalGroupLocalServiceUtil.getExpGroupByGroupId(scopeGroupId));
						
						for(int i=0; i<expGroupList.size(); i++) {
							ExperimentalGroup expGroup = expGroupList.get(i);
							boolean isSelect = false;
							if(Validator.isNotNull(subject)) {
								if(subject.getExpGroupId() == expGroup.getExperimentalGroupId()) isSelect = true;
							}
					%>
					
						<aui:option selected="<%=isSelect %>" value="<%=expGroup.getExperimentalGroupId() %>"><%=expGroup.getName() %></aui:option>
					<%
						}
					%>
					</aui:select>
				</aui:col>
			</aui:row>
				
			
			
			<aui:row>
				<aui:col md="12">
					<aui:button-row cssClass="mar0 marL10">
						<c:choose>
						<c:when test="<%=isUpdate %>">
						
						<c:if test="<%=SubjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.UPDATE_SUBJECT) %>">
							<button type="button" class="dh-icon-button submit-btn update-btn w110 h36 marR8" id="<portlet:namespace/>save">
								<img class="save-icon" />
								<span><liferay-ui:message key="ecrf-user.button.save" /></span>
							</button>
						</c:if>
						
						<c:if test="<%=SubjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DELETE_SUBJECT) %>">
							<%
								String title = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-exp-group.title");
								String content = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-exp-group.content");
								String deleteFunctionCall = String.format("deleteConfirm('%s', '%s', '%s' )", title, content, deleteSubjectURL.toString());
							%>
							<a class="dh-icon-button submit-btn delete-btn w110 h36 marR8" onClick="<%=deleteFunctionCall %>" id="<portlet:namespace/>delete">
								<img class="delete-icon" />
								<span><liferay-ui:message key="ecrf-user.button.delete" /></span>
							</a>
						</c:if>
						
						</c:when>
						<c:otherwise>
						
						<c:if test="<%=SubjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ADD_SUBJECT) %>">
							<button type="button" class="dh-icon-button submit-btn update-btn w110 h36 marR8" id="<portlet:namespace/>save">
								<img class="add-icon" />
								<span><liferay-ui:message key="ecrf-user.button.add" /></span>
							</button>
						</c:if>
						
						</c:otherwise>
						</c:choose>
								
						<a class="dh-icon-button submit-btn cancel-btn w110 h36 marR8" href="<%=updateListURL %>" id="<portlet:namespace/>cancel">
							<img class="cancel-icon" />					
							<span><liferay-ui:message key="ecrf-user.button.cancel" /></span>
						</a>
					</aui:button-row>
				</aui:col>
			</aui:row>
				
		</aui:container>
		</aui:form>
	</div>

</div>

<aui:script use="aui-base aui-form-validator">

var validator = null;

var DEFAULTS_FORM_VALIDATOR = A.config.FormValidator;

var ValidCheck = true;

function isValidDateString(dateStr) {
	const regex = /^\d{4}\/\d{2}\/\d{2}$/;
	if (!regex.test(dateStr)) return false;
	
	const date = new Date(dateStr);
	//console.log("str: ", dateStr, " date: ", date);
	
	return !isNaN(date.getTime());
}

A.mix(
	DEFAULTS_FORM_VALIDATOR.RULES,
	{
		birthRange: function(val, fieldNode, ruleValue) {
			var result = false;
			
			// check empty value
			if(val.trim().length !== 0) {
				//console.log(val, fieldNode, ruleValue);
				
				// check date format
				var isDate = isValidDateString(val);
				//console.log(val, isDate);
				
				if(isDate) {
					var date = new Date(val);
					// check birth range (1900 ~ now)
					const minDate = new Date('1900-01-01');
  					const maxDate = new Date(); // current date
  											
					result = date >= minDate && date <= maxDate;
				}
			}
						
			ValidCheck = result;
			
			return result;
		},
	},
	true
);

A.mix(
	DEFAULTS_FORM_VALIDATOR.RULES,
	{
		serialId: function(val, fieldNode, ruleValue) {
			var result = false;
			
			// check duplicate
			$.ajax({
				url: '<portlet:resourceURL id="<%= ECRFUserMVCCommand.RESOURCE_CHECK_SERIAL_ID %>"></portlet:resourceURL>',
				type:'post',
				dataType: 'json',
			 	async: false,
				data:{
					<portlet:namespace/>groupId: '<%=scopeGroupId %>',
					<portlet:namespace/>serialId: val,
				},
				success: function(obj){
					//console.log(obj);
					let isDuplicated = obj.duplicate;
					if(isDuplicated === false) {
						result = true;
					}
					
				},
				error: function(jqXHR, a, b){
					console.log('Fail to check serial id duplication : <%=ECRFUserPortletKeys.SUBJECT %>'  );
				}
			});
			
			if(!result) validFocus(fieldNode);
			ValidCheck = result;
			
			return result;
		},
	},
	true
);

var rules = {
	<portlet:namespace/>name: {
		required:true
	},
	<portlet:namespace/>serialId: {
		required:true,
		serialId:true
	},
	<portlet:namespace/>birth: {
		required:true,
		birthRange:true
	},
	<portlet:namespace/>lunarBirth: {
		birthRange:true
	}
};

var fieldStrings = {
	<portlet:namespace/>name: {
		required: '<p style="color:red;"><liferay-ui:message key="ecrf-user.validation.require"/></p>'
	},
	<portlet:namespace/>serialId: {
		required: '<p style="color:red;"><liferay-ui:message key="ecrf-user.validation.require"/></p>',
		serialId: '<p style="color:red;"><liferay-ui:message key="ecrf-user.validation.serial-id"/></p>'
	},
	<portlet:namespace/>birth: {
		required: '<p style="color:red;"><liferay-ui:message key="ecrf-user.validation.require"/></p>',
		birthRange: '<p><liferay-ui:message key="ecrf-user.validation.date"/></p>'
	},
	<portlet:namespace/>lunarBirth: {
		birthRange: '<p><liferay-ui:message key="ecrf-user.validation.date"/></p>'
	}
};

validator = new A.FormValidator({
	boundingBox: document.<portlet:namespace/>updateSubjectFm,
	fieldStrings: fieldStrings,
	rules: rules
});


A.one("#<portlet:namespace/>save").on("click", function(event) {
	
	var submitValid = true;
			
	let name = A.one('#<portlet:namespace/>name');
	let serialId = A.one('#<portlet:namespace/>serialId');
	let birth = A.one('#<portlet:namespace/>birth');
	
	// check value
	if(name.val().trim().length === 0) {
		submitValid = false;
		validFocus(name);
	} else if(serialId.val().trim().length === 0) {
		submitValid = false;
		validFocus(serialId);
	} else if(birth.val().trim().length === 0) {
		submitValid = false;
		validFocus(birth);
	}
			
	var form = A.one('#<portlet:namespace/>updateSubjectFm');
	
	if(ValidCheck && submitValid) {
		form.submit(); 
	}
});

function validFocus(elem) {
	elem.focus();
	elem.blur();
	elem.focus();
}
</aui:script>

<script>
$(document).ready(function() {
	$("#<portlet:namespace/>phone").mask("000-0000-0000", {placeholder: "000-0000-0000"});
	$("#<portlet:namespace/>phone2").mask("000-0000-0000", {placeholder: "000-0000-0000"});
	let now = new Date();
	let options = {
			lang: 'kr',
			changeYear: true,
			changeMonth : true,
			scrollInput:false,
			validateOnBlur: false,
			format: 'Y/m/d',
			timepicker: false,
			onChangeDateTime: function(dateText, inst){
				let dateValue = $("#<portlet:namespace/>birth").datetimepicker("getValue");			
				console.log(dateValue);
				
				let age = now.getFullYear() - dateValue.getFullYear()
				if(now.getTime() - dateValue.getTime() < 0){
					alert("Birth must be in the past than present");
				}else{
					if(now.getMonth() - dateValue.getMonth() < 0){
						age =  age + 1;
						$("#birthAge")[0].innerText = age;
					}else if(now.getMonth() - dateValue.getMonth() == 0){
						if(now.getDate() - dateValue.getDate() < 0){
							age =  age + 1;
							$("#birthAge")[0].innerText = age;
						}
						else{
							$("#birthAge")[0].innerText = age;
						}
					}else {
						$("#birthAge")[0].innerText = age;
					}
				}
			}
	}
	$("#<portlet:namespace/>birth").datetimepicker(options);
	$("#<portlet:namespace/>birth").mask("0000/00/00");
	
	$("#<portlet:namespace/>lunarBirth").mask("0000/00/00");
	$("#<portlet:namespace/>lunarBirth").on("change", function(event){
		let value = $("#<portlet:namespace/>lunarBirth").val();
		let lunarYear = value.split("/")[0];
		let lunarMonth = value.split("/")[1];
		let lunarDate = value.split("/")[2];
		let age = now.getFullYear() - lunarYear;
		if(lunarMonth < 0 || lunarMonth > 12 || lunarDate < 0 || lunarDate > 30){
			alert("invalid date");
			$("#<portlet:namespace/>lunarBirth").val("");	
			$("#lunarBirthAge")[0].innerText = "";	
		}else{
			if(age < 0){
				alert("Birth must be in the past than present");
			}else{
				$("#lunarBirthAge")[0].innerText = age;	
			}		
		}
	});
});

function getLunarDate(date){
	console.log("getLunarDate", date);
}
</script>