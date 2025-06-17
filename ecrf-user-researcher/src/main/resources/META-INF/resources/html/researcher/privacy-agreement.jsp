<%@ include file="../init.jsp" %>
<%@ page contentType="text/html;charset=UTF-8"%>

<%! private static Log _log = LogFactoryUtil.getLog("html.researcher.privacy_agreement_jsp"); %>

<%

String menu = ECRFUserMenuConstants.ADD_RESEARCHER;

// setting for admin user add menu / researcher module user add menu 
String divClass = "ecrf-user ecrf-user-researcher"; 
String headerTitle = "ecrf-user.researcher.title.add-researcher";

// for control menu => admin add user at user and organization
boolean isAdminMenu = ParamUtil.getBoolean(renderRequest, "isAdminMenu", false);
_log.info("is admin menu : " + isAdminMenu);

%>

<portlet:renderURL var="createAccountURL" copyCurrentRenderParameters="true">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LOGIN_CREATE_ACCOUNT %>"/>
	<portlet:param name="from" value="privacy"/>
	<portlet:param name="agree" value="true"/>
</portlet:renderURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_ADD_RESEARCHER %>" var="addResearcherURL">
</portlet:actionURL>

<style>
	.policy-container h1, .policy-container h2 { color: #2c3e50; }
	.policy-container p, .policy-container li { color: #34495e; }
	.policy-container a { color: #2980b9; text-decoration: none; }
	
	.test-checkbox {
		margin-left:6px;
		margin-right:6px;
	}

</style>

<div class="ecrf-user">
	
	<liferay-ui:header title="ecrf-user.researcher.title.policy" />
	
	<aui:container cssClass="radius-shadow-container">		
		<!-- Term of Use -->
		<aui:row>
			<aui:col>
				<h1 class="marTr">
					<liferay-ui:message key="ecrf-user.general.policy.term-of-use"/>
				</h1>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col>
				<%@ include file="./policy/term-of-use.jspf" %>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col cssClass="marT10">
				<aui:input id="useCheck" name="agreeCheck" type="checkbox" cssClass="test-checkbox" label="ecrf-user.researcher.checkbox.agree-term-of-use" onChange="agreeCheck()" autocomplete="off"/>
			</aui:col>
		</aui:row>
		
		<hr/>
		
		<!-- privacy policy -->
		<aui:row>
			<aui:col>
				<h1 class="marTr">
					<liferay-ui:message key="ecrf-user.general.policy.privacy"/>
				</h1>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col>
				<%@ include file="./policy/privacy.jspf" %>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col cssClass="marT10">
				<aui:input id="privacyCheck" name="agreeCheck" type="checkbox" cssCalss="test-checkbox" label="ecrf-user.researcher.checkbox.agree-privacy-policy" onChange="agreeCheck()" autocomplete="off"/>
			</aui:col>
		</aui:row>
		
		<hr/>
		
		<aui:row>
			<aui:col>
				<aui:button-row>
					<a class="dh-icon-button submit-btn inactive w110 h36" id="<portlet:namespace/>move" name="<portlet:namespace/>move" href="javascript:void(0);">
						<span><liferay-ui:message key="ecrf-user.button.next" /></span>
					</a>
				</aui:button-row>
			</aui:col>
		</aui:row>
	</aui:container>
</div>

<script>
$(document).ready(function() {
	// checkbox autocomplete='off' fixed issue with 
	agreeCheck();
});

function agreeCheck() {
	console.log("agree check");
	let useCheck = document.getElementById("<portlet:namespace/>useCheck");
	let privacyCheck = document.getElementById("<portlet:namespace/>privacyCheck");
	
	let result = false;
	
	if(useCheck && privacyCheck) {
		console.log("agree check value:", useCheck.checked, privacyCheck.checked);
		if(useCheck.checked && privacyCheck.checked) {
			result = true;
		}		
	}
	
	let agreeBtn = document.getElementById("<portlet:namespace/>move");
	let moveURL = "<%=createAccountURL%>";
	
	console.log("agree check result:", result);
	
	if(result) {
		agreeBtn.classList.remove("inactive");
		agreeBtn.classList.add("update-btn");
		agreeBtn.href = moveURL;
	} else {
		agreeBtn.classList.remove("update-btn");
		agreeBtn.classList.add("inactive");
		agreeBtn.href = "javascript:void(0)";
	}
}
</script>