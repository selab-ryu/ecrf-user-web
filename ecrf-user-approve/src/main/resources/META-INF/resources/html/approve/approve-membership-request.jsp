
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/approve/approve-membership-request_jsp"); %>

<%
long membershipRequestId = ParamUtil.getLong(renderRequest, ECRFUserApproveAttibutes.MEMBERSHIP_REQUEST_ID);
MembershipRequest membershipRequest = null;
User membershipUser = null;

if(membershipRequestId > 0) {
	_log.info("request id : " + membershipRequestId);
	MembershipRequestLocalService mrLocalService = (MembershipRequestLocalService)renderRequest.getAttribute(ECRFUserConstants.MEMBERSHIP_REQUEST_LOCAL_SERVICE);
	UserLocalService userLocalService = (UserLocalService)renderRequest.getAttribute(ECRFUserConstants.USER_LOCAL_SERVICE);
	
	membershipRequest = mrLocalService.fetchMembershipRequest(membershipRequestId);
	membershipUser = userLocalService.fetchUser(membershipRequest.getUserId());
	
} else {
	_log.error("error : no membership request id");
}

SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

%>

<portlet:renderURL var="viewMembershipURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_MEMBERSHIP %>" />
</portlet:renderURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_REVIEW_MEMBERSHIP_REQUEST %>" var="reviewMembershipRequestURL">
	<portlet:param name="<%=ECRFUserApproveAttibutes.MEMBERSHIP_REQUEST_ID %>" value="<%=String.valueOf(membershipRequestId) %>" />
</portlet:actionURL>

<div class="ecrf-user-approve ecrf-user">

	<div class="pad16">
	
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
					<p><%=Validator.isNull(membershipRequest) ? StringPool.DASH : dateFormat.format(membershipRequest.getCreateDate()) %></p>
				</aui:col> 
			</aui:row>
			<aui:row>
				<aui:col md="12">
					<strong><liferay-ui:message key="ecrf-user.membership-request.comment"/></strong>
					<p><%=Validator.isNull(membershipRequest) ? StringPool.DASH : membershipRequest.getComments() %></p>
				</aui:col> 
			</aui:row>
		</aui:container>
		
		<aui:form name="fm" action="<%=reviewMembershipRequestURL %>" method="POST">
		<aui:input type="hidden" name="<%=Constants.CMD %>" />
		<aui:container cssClass="radius-shadow-container marTr">
			<aui:row>
				<aui:col md="12">
					<aui:input 
						type="textarea" 
						cssClass="search-input" 
						name="replyComment"
						required="true" 
						label="ecrf-user.membership-request.reply-comment"/>
				</aui:col>
			</aui:row>
		</aui:container>
		</aui:form>
		
		<aui:container>
			<aui:row>
				<aui:col>
					<aui:button-row>
						<a class="icon-button-submit icon-button-submit-add" onClick="<%= liferayPortletResponse.getNamespace() + "approveRequest();" %>" name="<portlet:namespace/>approve">
							<img src="<%= renderRequest.getContextPath() + "/btn_img/approve_icon.png"%>"/>					
							<span>Approve</span>
						</a>
						<a class="icon-button-submit icon-button-submit-delete" onClick="<%= liferayPortletResponse.getNamespace() + "rejectRequest();" %>" name="<portlet:namespace/>reject">
							<img src="<%= renderRequest.getContextPath() + "/btn_img/reject_icon.png"%>"/>					
							<span>Reject</span>
						</a>
						<a class="icon-button-submit icon-button-submit-cancel" href="<%=redirect %>" name="<portlet:namespace/>cancel">
							<img src="<%= renderRequest.getContextPath() + "/btn_img/back_icon.png"%>"/>					
							<span style="color:black;">Back</span>
						</a>
					</aui:button-row>
				</aui:col>
			</aui:row>
		</aui:container>

	</div>
</div>

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