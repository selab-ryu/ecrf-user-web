<%@ include file="../init.jsp" %>
<%@ page contentType="text/html;charset=UTF-8"%>

<%! private static Log _log = LogFactoryUtil.getLog("html.researcher.check_agreement_jsp"); %>

<%

String menu = ECRFUserMenuConstants.LOGIN;

_log.info("view agreement");

String login = ParamUtil.getString(request, "login");
String password = ParamUtil.getString(request, "password");

//_log.info("id / pw : " + login + " / " + password);
%>


<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_AGREEMENT %>" var="agreeURL">
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

<div class="ecrf-user mar1r">
	
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
				<liferay-ui:message key="ecrf-user.policy.text.term-of-use"></liferay-ui:message>
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
				<liferay-ui:message key="ecrf-user.policy.text.privacy"></liferay-ui:message>
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
					<a id="<portlet:namespace/>move" name="<portlet:namespace/>move" class="dh-icon-button submit-btn inactive w110 h36" href="javascript:void(0);">
						<span><liferay-ui:message key="ecrf-user.button.agree" /></span>
					</a>
				</aui:button-row>
			</aui:col>
		</aui:row>
	</aui:container>
	
	<aui:form type="post" name="loginForm" action="<%=agreeURL %>" >
		<aui:input type="hidden" name="login" value="<%=login %>" />
		<aui:input type="hidden" name="password" value="<%=password %>" />
	</aui:form>
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
	
	console.log("agree check result:", result);
	
	if(result) {
		agreeBtn.classList.remove("inactive");
		agreeBtn.classList.add("update-btn");
		agreeBtn.href="javascript:agree();";
	} else {
		agreeBtn.classList.remove("update-btn");
		agreeBtn.classList.add("inactive");
		agreeBtn.onclick="javascript:void(0);";
	}
}

function agree() {
	let form = document.getElementById("<portlet:namespace/>loginForm");
	
	form.submit();
}

</script>