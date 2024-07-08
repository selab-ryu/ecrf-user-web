<%@ page import="ecrf.user.constants.ECRFUserActionKeys" %>
<%@ page import="ecrf.user.constants.type.ResearcherPosition" %>
<%@ page import="com.liferay.portal.kernel.exception.UserEmailAddressException" %>
<%@ page import="com.liferay.portal.kernel.exception.UserScreenNameException"%>
<%@ page import="com.liferay.portal.kernel.exception.GroupFriendlyURLException"%>
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html.researcher.update_researcher_jsp"); %>

<liferay-ui:success key="researcherWithUserAdded" message="researcher-with-user-added" />

<%

String menu = "researcher-add";

boolean isUpdate = false;

long researcherId = ParamUtil.getLong(renderRequest, ECRFUserResearcherAttributes.RESEARCHER_ID);

Researcher researcher = null;
User researcherUser = null;
if(researcherId > 0) {
	researcher = ResearcherLocalServiceUtil.getResearcher(researcherId);
	researcherUser = UserLocalServiceUtil.getUser(researcher.getResearcherUserId());
	isUpdate = true;
	menu =  "researcher-update";
}

String birthStr = null;
boolean isMale = true;

boolean isPasswordUpdate = false;

if(isUpdate) {
	birthStr = ECRFUserUtil.getDateStr(researcher.getBirth());
	
	// gender value / male : 0, female : 1
	int genderValue = researcher.getGender();
	isMale = (genderValue == 1) ? false : true;	// if null -> male is true (default value)
	
	if( (researcher.getResearcherUserId() == user.getUserId()) ) {
		_log.info("has password update permission");
		isPasswordUpdate = true;
	}
}

// setting for admin user add menu / researcher module user add menu 
String divClass = "ecrf-user ecrf-user-researcher"; 
String headerTitle = "ecrf-user.researcher.title.add-researcher";

// for control menu => admin add user at user and organization
boolean isAdminMenu = ParamUtil.getBoolean(renderRequest, "isAdminMenu", false);
_log.info("is admin menu : " + isAdminMenu);

// set backURL at admin menu
if(isAdminMenu) {
	PortletURL viewURL = renderResponse.createRenderURL();
	
	_log.info("back url : " + backURL);
	if(Validator.isNull(backURL)) {
		backURL = viewURL.toString();
		_log.info("view url : " + viewURL);
	}
	
	divClass += " mar1r";
	headerTitle = "ecrf-user.researcher.title.add-researcher.admin";
} else {
	backURL = redirect;
}

// Custom Update User Render added parameter (for admin menu))
boolean fromLiferay = ParamUtil.getBoolean(renderRequest, "fromLiferay", false);

//setting for admin user add menu / researcher module user add menu

%>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_ADD_RESEARCHER %>" var="addResearcherURL">
</portlet:actionURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_UPDATE_RESEARCHER %>" var="updateResearcherURL">
	<portlet:param name="<%=ECRFUserResearcherAttributes.RESEARCHER_ID %>" value="<%=String.valueOf(researcherId) %>" />
</portlet:actionURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_RESEARCHER %>" var="deleteResearcherURL">
	<portlet:param name="<%=ECRFUserResearcherAttributes.RESEARCHER_ID %>" value="<%=String.valueOf(researcherId) %>" />
</portlet:actionURL>

<portlet:renderURL var="listResearcherURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_RESEARCHER %>" />	
</portlet:renderURL>

<liferay-ui:error exception="<%= UserEmailAddressException.MustNotBeDuplicate.class %>" focusField="emailAddress" message="the-email-address-you-requested-is-already-taken" />
<liferay-ui:error exception="<%= UserEmailAddressException.MustNotBeNull.class %>" focusField="emailAddress" message="please-enter-an-email-address" />
<liferay-ui:error exception="<%= UserEmailAddressException.MustNotBePOP3User.class %>" focusField="emailAddress" message="the-email-address-you-requested-is-reserved" />
<liferay-ui:error exception="<%= UserEmailAddressException.MustNotBeReserved.class %>" focusField="emailAddress" message="the-email-address-you-requested-is-reserved" />
<liferay-ui:error exception="<%= UserEmailAddressException.MustNotUseCompanyMx.class %>" focusField="emailAddress" message="the-email-address-you-requested-is-not-valid-because-its-domain-is-reserved" />

<liferay-ui:error exception="<%= GroupFriendlyURLException.class %>" focusField="screenName">
	<% GroupFriendlyURLException gfurle = (GroupFriendlyURLException)errorException; %>
	<c:if test="<%= gfurle.getType() == GroupFriendlyURLException.DUPLICATE %>">
		<liferay-ui:message key="the-screen-name-you-requested-is-associated-with-an-existing-friendly-url" />
	</c:if>
</liferay-ui:error>

<liferay-ui:error exception="<%= UserScreenNameException.MustValidate.class %>" focusField="screenName">
	<% UserScreenNameException.MustValidate usne = (UserScreenNameException.MustValidate)errorException; %>
	<liferay-ui:message key="<%= usne.screenNameValidator.getDescription(locale) %>" />
</liferay-ui:error>

<liferay-ui:error exception="<%= UserScreenNameException.MustNotBeDuplicate.class %>" focusField="screenName" message="the-screen-name-you-requested-is-already-taken" />
<liferay-ui:error exception="<%= UserScreenNameException.MustNotBeNull.class %>" focusField="screenName" message="the-screen-name-cannot-be-blank" />
<liferay-ui:error exception="<%= UserScreenNameException.MustNotBeNumeric.class %>" focusField="screenName" message="the-screen-name-cannot-contain-only-numeric-values" />
<liferay-ui:error exception="<%= UserScreenNameException.MustNotBeReserved.class %>" focusField="screenName" message="the-screen-name-you-requested-is-reserved" />
<liferay-ui:error exception="<%= UserScreenNameException.MustNotBeReservedForAnonymous.class %>" focusField="screenName" message="the-screen-name-you-requested-is-reserved-for-the-anonymous-user" />
<liferay-ui:error exception="<%= UserScreenNameException.MustNotBeUsedByGroup.class %>" focusField="screenName" message="the-screen-name-you-requested-is-already-taken-by-a-site" />
<liferay-ui:error exception="<%= UserScreenNameException.MustProduceValidFriendlyURL.class %>" focusField="screenName" message="the-screen-name-you-requested-must-produce-a-valid-friendly-url" />

<div class="<%=divClass %>">

	<c:if test="<%=!fromLiferay %>">
	<%@ include file="sidebar.jspf" %>

	<div class="page-content">
	</c:if>

	<liferay-ui:header backURL="<%=listResearcherURL %>" title="<%=headerTitle %>" />
	
	<aui:form name="updateResearhcerFm" action="<%=isUpdate ? updateResearcherURL : addResearcherURL %>" method="post" autocomplete="off">
	<aui:container cssClass="radius-shadow-container">	
		<aui:input type="hidden" name="<%=Constants.CMD %>" value="<%=isUpdate ? Constants.UPDATE : Constants.ADD %>" />
		
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
					name="<%=ECRFUserResearcherAttributes.EMAIL %>"
					label="ecrf-user.researcher.email"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input 
					autofocus="true" 
					name="<%=ECRFUserResearcherAttributes.EMAIL %>" 
					label="" 
					value="<%=Validator.isNull(researcher) ? StringPool.BLANK : researcher.getEmail() %>"
					disabled="<%=isUpdate ? true : false %>"
				>
				</aui:input>
			</aui:col>
		</aui:row>
		
		<c:if test="<%=!isPasswordUpdate %>">
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					name="<%=ECRFUserResearcherAttributes.PASSWORD1 %>"
					label="ecrf-user.researcher.password"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input 
					type="password"
					autocomplete="off"
					name="<%=ECRFUserResearcherAttributes.PASSWORD1 %>" 
					label=""
					value="<%=Validator.isNull(researcherUser) ? StringPool.BLANK : researcherUser.getPasswordUnencrypted() %>"
					>
				</aui:input>
			</aui:col>
			<aui:col md="3">
				<aui:input
					type="checkbox"
					name="notChange"
					label="ecrf-user.researcher.not-change"
					checked="false"
				/>
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					name="<%=ECRFUserResearcherAttributes.PASSWORD2 %>"
					label="ecrf-user.researcher.password-check"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input 
					type="password"
					autocomplete="off"
					name="<%=ECRFUserResearcherAttributes.PASSWORD2 %>" 
					label="" 
					value="<%=Validator.isNull(researcherUser) ? StringPool.BLANK : researcherUser.getPasswordUnencrypted() %>"
					>
				</aui:input>
			</aui:col>
		</aui:row>
		</c:if>
		
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					name="<%=ECRFUserResearcherAttributes.SCREEN_NAME %>"
					label="ecrf-user.researcher.screen-name"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input
					name="<%=ECRFUserResearcherAttributes.SCREEN_NAME %>"
					label=""
					value="<%=Validator.isNull(researcherUser) ? StringPool.BLANK : researcherUser.getScreenName() %>" 
					>
				</aui:input>	
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					name="<%=ECRFUserResearcherAttributes.LAST_NAME %>"
					label="ecrf-user.researcher.last-name"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input  
					name="<%=ECRFUserResearcherAttributes.LAST_NAME %>" 
					label="" 
					value="<%=Validator.isNull(researcherUser) ? StringPool.BLANK : researcherUser.getLastName() %>"
					>
				</aui:input>
			</aui:col>
		</aui:row>	
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					name="<%=ECRFUserResearcherAttributes.FIRST_NAME %>"
					label="ecrf-user.researcher.first-name"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input  
					name="<%=ECRFUserResearcherAttributes.FIRST_NAME %>" 
					label="" 
					value="<%=Validator.isNull(researcherUser) ? StringPool.BLANK : researcherUser.getFirstName() %>"
					>
				</aui:input>
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					name="<%=ECRFUserResearcherAttributes.BIRTH %>"
					label="ecrf-user.researcher.birth"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input 
					name="<%=ECRFUserResearcherAttributes.BIRTH %>"
					cssClass="date"
					label=""
					value="<%=Validator.isNull(birthStr) ? "" : birthStr %>" 
					>
				</aui:input>
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					name="<%=ECRFUserResearcherAttributes.GENDER %>"
					label="ecrf-user.general.gender"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:fieldset cssClass="radio-one-line radio-align">
					<aui:input 
						type="radio" 
						name="<%=ECRFUserResearcherAttributes.GENDER %>" 
						cssClass="search-input"
						label="ecrf-user.general.male"  
						value="0"
						checked="<%=isMale ? true : false  %>" />
					<aui:input 
						type="radio" 
						name="<%=ECRFUserResearcherAttributes.GENDER %>" 
						cssClass="search-input"
						label="ecrf-user.general.female" 
						value="1"
						checked="<%=isMale ? false : true %>" />
				</aui:fieldset>
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
					name="<%=ECRFUserResearcherAttributes.INSTITUTION %>"
					label="ecrf-user.researcher.institution"
					required="true"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input 
					name="<%=ECRFUserResearcherAttributes.INSTITUTION %>" 
					label="" 
					value="<%=Validator.isNull(researcher) ? StringPool.BLANK : researcher.getInstitution() %>"
					>
				</aui:input>
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					name="<%=ECRFUserResearcherAttributes.PHONE %>"
					label="ecrf-user.researcher.phone"
				>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input 
					name="<%=ECRFUserResearcherAttributes.PHONE %>" 
					label="" 
					value="<%=Validator.isNull(researcher) ? StringPool.BLANK : researcher.getPhone() %>"
					>
				</aui:input>
			</aui:col>
		</aui:row>
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					name="<%=ECRFUserResearcherAttributes.OFFICE_CONTACT %>"
					label="ecrf-user.researcher.office-contact"
					>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:input  
					name="<%=ECRFUserResearcherAttributes.OFFICE_CONTACT %>" 
					label="" 
					value="<%=Validator.isNull(researcher) ? StringPool.BLANK : researcher.getOfficeContact() %>"
					>
				</aui:input>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col md="3">
				<aui:field-wrapper
					name="<%=ECRFUserResearcherAttributes.POSITION %>"
					label="ecrf-user.researcher.position"
					>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="6">
				<aui:select 
					name="<%=ECRFUserResearcherAttributes.POSITION %>"
					label=""
				>
					<%
						ResearcherPosition[] positions = ResearcherPosition.values();
						for(int i=0; i<positions.length; i++) {
							ResearcherPosition position = positions[i];
							
							boolean isSelect = false;
							if(Validator.isNotNull(researcher)) {
								if(researcher.getPosition().equals(position.getLower()))
									isSelect = true;
							}
					%>
				
					<aui:option selected="<%=isSelect %>" value="<%=position.getLower() %>"><%=position.getFull() %></aui:option>
					<%
						}
					%>
				</aui:select>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col md="12">
				<aui:button-row>
				
					<c:choose>
					<c:when test="<%=isUpdate %>">
					
					<c:if test="<%=ResearcherPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.UPDATE_RESEARCHER) %>">
					<aui:button type="submit" name="save" cssClass="add-btn medium-btn radius-btn" value="ecrf-user.button.update" ></aui:button>
					</c:if>
					
					<c:if test="<%=ResearcherPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DELETE_RESEARCHER) %>">
					<aui:button type="button" name="delete" cssClass="delete-btn medium-btn radius-btn" value="ecrf-user.button.delete"  onClick="<%=deleteResearcherURL %>"></aui:button>
					</c:if>
					
					</c:when>
					<c:otherwise>
					
					<c:if test="<%=ResearcherPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ADD_RESEARCHER) %>">
					<aui:button type="submit" name="save" cssClass="add-btn medium-btn radius-btn" value="ecrf-user.button.add" ></aui:button>
					</c:if>
					
					</c:otherwise>
					</c:choose>			
							
					<aui:button type="button" name="cancel" cssClass="cancel-btn medium-btn radius-btn" value="ecrf-user.button.cancel" onClick="<%=listResearcherURL %>"></aui:button>
				</aui:button-row>
			</aui:col>
		</aui:row>

	</aui:container>
	</aui:form>
	
	<c:if test="<%=!fromLiferay %>">
	</div>
	</c:if>
</div>

<aui:script>
//define rules for fields
var rules = {
	<portlet:namespace/>email: {
		email: true,
		required: true
	},
	<portlet:namespace/>password1: {
		required: true
	},
	<portlet:namespace/>password2: {
		equalTo: '#<portlet:namespace/>password1',
  		required: true
	},
	<portlet:namespace/>screenName: {
		customRuleForScreenName: true,
		required: true
	},
	<portlet:namespace/>firstName: {
		required: true,
		customRuleForName: true
	},
	<portlet:namespace/>lastName: {
		required: true,
		customRuleForName: true
	},
	<portlet:namespace/>birth: {
		required:true,
		customRuleForDate: true
	},
	<portlet:namespace/>institution: {
  		required: true
	},
	<portlet:namespace/>position: {
  		required: true
	}
};

// overrding default error messages for fields
var fieldStrings = {
	<portlet:namespace/>email: {
		required: '<p><liferay-ui:message key="ecrf-user.validation.require"/></p>',
		email: '<p><liferay-ui:message key="ecrf-user.validation.email"/></p>'
	},
	<portlet:namespace/>password1: {
  		required: '<p><liferay-ui:message key="ecrf-user.validation.require"/></p>'
	},
	<portlet:namespace/>password2: {
		equalTo: '<p><liferay-ui:message key="ecrf-user.validation.equal-to"/></p>',
  		required: '<p><liferay-ui:message key="ecrf-user.validation.require"/></p>'
	},
	<portlet:namespace/>firstName: {
		required: '<p><liferay-ui:message key="ecrf-user.validation.require"/></p>' 
	},
	<portlet:namespace/>lastName: {
		required: '<p><liferay-ui:message key="ecrf-user.validation.require"/></p>'
	},
	<portlet:namespace/>birth: {
		required: '<p><liferay-ui:message key="ecrf-user.validation.require"/></p>',
		customRuleForDate: '<p style=""><liferay-ui:message key="ecrf-user.validation.date"/></p>'
	},
	<portlet:namespace/>institution: {
  		required: '<p><liferay-ui:message key="ecrf-user.validation.require"/></p>'
	},
	<portlet:namespace/>position: {
  		required: '<p><liferay-ui:message key="ecrf-user.validation.require"/></p>'
	},
};

function validFocus(elem) {
	elem.focus();
	elem.blur();
	elem.focus();
}

var validator;

AUI().use(
'aui-form-validator', 
function(A) {
	var DEFAULTS_FORM_VALIDATOR = A.config.FormValidator;
	
	// add custom rule
	A.mix(
		DEFAULTS_FORM_VALIDATOR.RULES,
	    {
	    	customRuleForScreenName : function (val, fieldNode, ruleValue) {
	        	var result = false;
	       		// alphanum, "_", no space, no email, not start with num
	       		const pattern = /^[a-zA-Z_]+\w*$/;
	        	const reg_result = pattern.test(val); 
	        	if(reg_result) {
	        		return true;
	        	}
	            return result;
	        },
	        customRuleForName : function (val, fieldNode, ruleValue) {
	        	var result = false;
	        	// alphanum, korean(UTF-8)
	        	const pattern = /^[\uac00-\ud7a3a-zA-Z0-9]+$/;
	        	const reg_result = pattern.test(val);
	        	if(reg_result) {
	        		return true;
	        	}
	        	return result;
	        },
	        customRuleForDate : function (val, fieldNode, ruleValue) {
	        	var result = false;
	       		const pattern = /^(19|20)\d{2}\/(0[1-9]|1[1,2])\/(0[1-9]|[12][0-9]|3[01])$/;
	        	const reg_result = pattern.test(val); 
	        	if(reg_result) {
	        		return true;
	        	}
	            return result;
	        }
		},
		true
	);
		
	// add custom validate message
	A.mix(
		DEFAULTS_FORM_VALIDATOR.STRINGS,
	    {
	    	customRuleForScreenName : '<p><liferay-ui:message key="ecrf-user.validation.screen-name"/></p>',
	    	customRuleForName : '<p><liferay-ui:message key="ecrf-user.validation.name"/></p>',
	    	customRuleForDate : '<p><liferay-ui:message key="ecrf-user.validation.date"/></p>'
		},
	    true
	);
		
	console.log(DEFAULTS_FORM_VALIDATOR);
	
	validator = new A.FormValidator(
		{
			boundingBox: '#<portlet:namespace/>updateResearhcerFm',
			fieldStrings: fieldStrings,
			rules: rules,
			showAllMessages: true
		}
	);
});

AUI().ready(function() {
	const notChangeCheckbox = document.getElementById('<portlet:namespace/>notChange');
	notChangeCheckbox.addEventListener("click", (event) => {
		let password1 = $('#<portlet:namespace/>password1');
		let password2 = $('#<portlet:namespace/>password2');
					
		if(event.currentTarget.checked) {
			// set disabled
			password1.prop("disabled", "true");
			password2.prop("disabled", "true");
			
			// remove value from input
			password1.val("");
			password2.val("");
			
			// remove has-error class
			password1.parent().removeClass("has-error");
			password2.parent().removeClass("has-error");
			
			// remove help-block div
			password1.parent().find("div.help-block").remove();
			password2.parent().find("div.help-block").remove();
			
			validator.get('rules')['<portlet:namespace/>password1']= {};
			validator.get('rules')['<portlet:namespace/>password2']= {};
		} else {
			password1.removeAttr("disabled");
			password2.removeAttr("disabled");
			
			validator.get('rules')['<portlet:namespace/>password1']= {required:true};
			validator.get('rules')['<portlet:namespace/>password2']= {equalTo: '#<portlet:namespace/>password1', required:true};
		}
	});
});

</aui:script>

<aui:script use="liferay-form">
Liferay.once('<portlet:namespace/>formReady', () => {
	var form = Liferay.Form.get('<portlet:namespace/>updateResearcherFm');
	
	form.set("onSubmit", (event) => {
		event.preventdefault();
		
		console.log("on form submit");		
	});
});
</aui:script>

<script>
$(document).ready(function() {
	var options = {
		onKeyPress: function(phone, e, field, options) {
		    var masks = ['000-0000-0000', '000-000-0000'];
		    var mask = (phone.length>9) ? masks[0] : masks[1];
		    field.mask(mask, options);
		}
	};
	$("#<portlet:namespace/>officeContact").mask("000-000-0000", options);
	$("#<portlet:namespace/>phone").mask("000-000-0000", options);
	
	$("#<portlet:namespace/>birth").datetimepicker({
		lang: 'kr',
		changeYear: true,
		changeMonth : true,
		validateOnBlur: false,
		gotoCurrent: true,
		timepicker: false,
		format: 'Y/m/d',
		scrollMonth: false
	});
	$("#<portlet:namespace/>birth").mask("0000/00/00", {placehodler:"yyyy/mm/dd"});
});
</script>