<%@page import="ecrf.user.constants.ECRFUserApproveAttibutes"%>
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/approve/approve-membership-request_jsp"); %>

<%
long membershipRequestId = ParamUtil.getLong(renderRequest, ECRFUserApproveAttibutes.MEMBERSHIP_REQUEST_ID);
MembershipRequest membershipRequest = null;
User membershipUser = null;
Researcher researcher = null;

if(membershipRequestId > 0) {
	_log.info("request id : " + membershipRequestId);
	membershipRequest = MembershipRequestLocalServiceUtil.fetchMembershipRequest(membershipRequestId);
	membershipUser = UserLocalServiceUtil.fetchUser(membershipRequest.getUserId());
	researcher = ResearcherLocalServiceUtil.getResearcherByG_RU_First(scopeGroupId, membershipUser.getUserId());
} else {
	_log.error("error : no membership request id");
}

SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

%>

<portlet:renderURL var="viewMembershipURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_MEMBERSHIP %>" />
</portlet:renderURL>

<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.approve.title.membership-request-review" />

<aui:container cssClass="radius-shadow-container">
	<aui:row>
		<aui:col md="12">
			<span class="title-span">
				<liferay-ui:message key="ecrf-user.approve.title.membership-request-info" />
			</span>
			<hr align="center" class="marV5"></hr>
		</aui:col>
	</aui:row>
	<aui:row>
		<aui:col md="12">
			<strong><liferay-ui:message key="ecrf-user.user.full-name"/></strong>
			<p><%=Validator.isNull(membershipUser) ? StringPool.DASH : membershipUser.getFullName() %></p>
		</aui:col> 
	</aui:row>
	<aui:row>
		<aui:col md="12">
			<strong><liferay-ui:message key="ecrf-user.user.email"/></strong>
			<p><%=Validator.isNull(membershipUser) ? StringPool.DASH : membershipUser.getEmailAddress() %></p>
		</aui:col> 
	</aui:row>	
	<aui:row>
		<aui:col md="12">
			<strong><liferay-ui:message key="ecrf-user.general.create-date"/></strong>
			<p><%=Validator.isNull(membershipRequest) ? StringPool.DASH : membershipRequest.getCreateDate() %></p>
		</aui:col> 
	</aui:row>
	<aui:row>
		<aui:col md="12">
			<strong><liferay-ui:message key="ecrf-user.membership-request.comment"/></strong>
			<p><%=Validator.isNull(membershipRequest) ? StringPool.DASH : membershipRequest.getComments() %></p>
		</aui:col> 
	</aui:row>
</aui:container>

<aui:form name="fm" action="" method="POST">
<aui:input type="hidden" name="<%=Constants.CMD %>" />
<aui:container cssClass="radius-shadow-container marTr">
	<aui:row>
		<aui:col md="12">
			<aui:input type="textarea" cssClass="search-input" name="replyComment" label="ecrf-user.membership-request.reply-comment"/>
		</aui:col>
	</aui:row>
</aui:container>
</aui:form>

<aui:container>
	<aui:row>
		<aui:col>
			<aui:button-row>
				<aui:button name="approve" value="Approve" onClick="<%= liferayPortletResponse.getNamespace() + "approveRequest();" %>" />
				<aui:button name="reject" value="Reject" onClick="<%= liferayPortletResponse.getNamespace() + "rejectRequest();" %>" /> 
				<aui:button value="Back" onClick="<%=redirect.toString() %>" /> 
			</aui:button-row>
		</aui:col>
	</aui:row>
</aui:container>

<aui:script>
window.<portlet:namespace />approveRequest = function () {
	var form = document.getElementById('<portlet:namespace />fm');

	if (form) {
		var cmd = form.querySelector('#<portlet:namespace /><%= Constants.CMD %>');

		if (cmd) {
			cmd.setAttribute('value', '<%= Constants.APPROVE %>');
			console.log(cmd.getAttribute('value'));
			submitForm(form);
		}
	}
};

window.<portlet:namespace />rejectRequest = function () {
	var form = document.getElementById('<portlet:namespace />fm');

	if (form) {
		var cmd = form.querySelector('#<portlet:namespace /><%= Constants.CMD %>');

		if (cmd) {
			cmd.setAttribute('value', '<%= Constants.REJECT %>');
			console.log(cmd.getAttribute('value'));
			submitForm(form);
		}
	}
};
</aui:script>