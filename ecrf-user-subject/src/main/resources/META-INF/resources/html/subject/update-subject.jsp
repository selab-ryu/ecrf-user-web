<%@page import="ecrf.user.service.ExperimentalGroupLocalServiceUtil"%>
<%@page import="ecrf.user.model.ExperimentalGroup"%>
<%@ include file="../init.jsp" %>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.subject.update_subject_jsp");
%>

<%
SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

String menu="subject-add";

long subjectId = ParamUtil.getLong(renderRequest, ECRFUserSubjectAttributes.SUBJECT_ID, 0);

boolean isUpdate = false;

String subjectBirthStr = null;
boolean isMale = true;

Subject subject = null;
if(subjectId > 0) {
	subject = (Subject)renderRequest.getAttribute(ECRFUserSubjectAttributes.SUBJECT);
	if(Validator.isNotNull(subject)) {
		isUpdate = true;
		menu="subject-update";
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
				<aui:col md="1">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.BIRTH_YEAR %>"
						label="ecrf-user.subject.birth-age"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="1">
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
				<aui:col md="1">
					<aui:field-wrapper
						name="<%=ECRFUserSubjectAttributes.LUNARBIRTH_YEAR %>"
						label="ecrf-user.subject.lunarbirth-age"
					>
					</aui:field-wrapper>
				</aui:col>
				<aui:col md="1">
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
						required="true"
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
						required="true"
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
						required="true"
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
							<aui:button type="button" name="save" cssClass="add-btn medium-btn radius-btn" value="ecrf-user.button.update"></aui:button>
						</c:if>
						
						<c:if test="<%=SubjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DELETE_SUBJECT) %>">
							<aui:button type="button" name="delete" cssClass="delete-btn medium-btn radius-btn" value="ecrf-user.button.delete" onClick="<%=deleteSubjectURL %>"></aui:button>
						</c:if>
						
						</c:when>
						<c:otherwise>
						
						<c:if test="<%=SubjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ADD_SUBJECT) %>">
							<aui:button type="button" name="save" cssClass="add-btn medium-btn radius-btn" value="ecrf-user.button.add"></aui:button>
						</c:if>
						
						</c:otherwise>
						</c:choose>
								
						<aui:button type="button" name="cancel" cssClass="cancel-btn medium-btn radius-btn" value="ecrf-user.button.cancel" onClick="<%=updateListURL %>"></aui:button>
					</aui:button-row>
				</aui:col>
			</aui:row>
				
		</aui:container>
		</aui:form>
	</div>

</div>

<aui:script use="aui-base">
var rules = {
	<portlet:namespace/>name: {
		required:true
	},
	<portlet:namespace/>serialId: {
		required:true
	},
	<portlet:namespace/>birth: {
		required:true,
		date:true
	},
	<portlet:namespace/>phone: {
		required:true
	},
	<portlet:namespace/>hospitalCode: {
		required:true
	}
};

var fieldStrings = {
	<portlet:namespace/>name: {
		required: '<p style="color:red;"><liferay-ui:message key="ecrf-user.validation.require"/></p>'
	},
	<portlet:namespace/>serialId: {
		required: '<p style="color:red;"><liferay-ui:message key="ecrf-user.validation.require"/></p>'
	},
	<portlet:namespace/>birth: {
		required: '<p style="color:red;"><liferay-ui:message key="ecrf-user.validation.require"/></p>',
		date: '<p><liferay-ui:message key="ecrf-user.validation.date"/></p>'
	},
	<portlet:namespace/>phone: {
		required: '<p style="color:red;"><liferay-ui:message key="ecrf-user.validation.require"/></p>'
	},
	<portlet:namespace/>hospitalCode: {
		required: '<p style="color:red;"><liferay-ui:message key="ecrf-user.validation.require"/></p>'
	}
};

var validator = new A.FormValidator({
	boundingBox: document.<portlet:namespace/>updateSubjectFm,
	fieldStrings: fieldStrings,
	rules: rules
});

A.one("#<portlet:namespace/>save").on("click", function(event) {
	var submitValid = true;
			
	let name = A.one('#<portlet:namespace/>name');
	let serialId = A.one('#<portlet:namespace/>serialId');
	let birth = A.one('#<portlet:namespace/>birth');
	let phone = A.one('#<portlet:namespace/>phone');
	let hospitalCode = A.one('#<portlet:namespace/>hospitalCode');
	
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
	} else if(phone.val().trim().length === 0) {
		submitValid = false;
		validFocus(phone);
	} else if(hospitalCode.val().trim().length === 0) {
		submitValid = false;
		validFocus(hospitalCode);
	}
			
	var form = A.one('#<portlet:namespace/>updateSubjectFm');
	
	if(submitValid) {
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
				console.log();
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