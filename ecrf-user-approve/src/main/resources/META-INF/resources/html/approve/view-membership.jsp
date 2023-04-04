<%@page import="ecrf.user.constants.ECRFUserApproveAttibutes"%>
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/approve/view-membership_jsp"); %>

<%
List<User> siteUsers = UserLocalServiceUtil.getGroupUsers(scopeGroupId);

int siteUserCount = siteUsers.size();

if(siteUsers.size() <= 0) {
	_log.info("0 group user");
} else {
	for(int i=0; i<siteUserCount; i++) {
		User siteUser = siteUsers.get(i); 
		_log.info("Site Member / " + "name : " + siteUser.getFullName() + " / " + "email : " + siteUser.getEmailAddress());
	}	
}

List<MembershipRequest> membershipRequestList = new ArrayList<>();
int membershipRequestCount = MembershipRequestLocalServiceUtil.searchCount(scopeGroupId, MembershipRequestConstants.STATUS_PENDING);

if(membershipRequestCount <= 0) {
	_log.info("0 pending membership request");	
} else {
	membershipRequestList = MembershipRequestLocalServiceUtil.search(scopeGroupId, MembershipRequestConstants.STATUS_PENDING, 0, membershipRequestCount);
	for(int i=0; i<membershipRequestList.size(); i++) {
		MembershipRequest membershipRequest = membershipRequestList.get(i);
		User membershipRequestUser = UserLocalServiceUtil.fetchUserById(membershipRequest.getUserId()); 
		_log.info("Pending Membership Requets / " + "name : " + membershipRequestUser.getFullName() + " / " + "comment : " + membershipRequest.getComments());
	}
}

%>

<aui:button cssClass="hide" name="call" value="Call" />

<liferay-ui:header title="ecrf-user.approve.title.view-membership" />

<liferay-ui:search-container
	delta="10"
	total="<%=siteUserCount %>"
	emptyResultsMessage="No Researchers were found"
	emptyResultsMessageCssClass="taglib-empty-result-message-header"
	var ="membershipUserSearchContainer"
>

<liferay-ui:search-container-results
	results="<%=ListUtil.subList(siteUsers, membershipUserSearchContainer.getStart(), membershipUserSearchContainer.getEnd()) %>"
/>

<% int membershipUserCount = membershipUserSearchContainer.getStart(); %>

	<liferay-ui:search-container-row
		className="com.liferay.portal.kernel.model.User"
		escapedModel="<%= true %>"
		keyProperty="userId"
		modelVar="siteUser" >
		
		<liferay-ui:search-container-column-text
			name="ecrf-user.list.no"
			value="<%=String.valueOf(++membershipUserCount) %>"
		/>
		
		<liferay-ui:search-container-column-text
			name="ecrf-user.list.name"
			value="<%=siteUser.getFullName() %>"
		/>
		
		<liferay-ui:search-container-column-text
			name="ecrf-user.list.email"
			value="<%=siteUser.getEmailAddress() %>"
		/>
		
		<%
		List<Researcher> researcherList = ResearcherLocalServiceUtil.getResearcherByG_RU(scopeGroupId, siteUser.getUserId());
		int researcherCount = ResearcherLocalServiceUtil.getResearcherCountByG_RU(scopeGroupId, siteUser.getUserId());
		Researcher researcher = null;
		if(researcherCount > 0) {
			researcher = researcherList.get(0);
		}
		%>
		
		<liferay-ui:search-container-column-text
			name="ecrf-user.list.position"
			value="<%=Validator.isNull(researcher) ? StringPool.DASH : researcher.getPosition() %>"
		/>
		
		<liferay-ui:search-container-column-text
			name="ecrf-user.list.institution"
			value="<%=Validator.isNull(researcher) ? StringPool.DASH : researcher.getInstitution() %>"
		/>
		
	</liferay-ui:search-container-row>

<liferay-ui:search-iterator	/>
</liferay-ui:search-container>

<c:choose>
<c:when test="<%=ApprovePermission.contains(permissionChecker, scopeGroupId, "APPROVE_MEMBERSHIP") %>">	

<liferay-ui:header cssClass="marTr" title="ecrf-user.approve.title.view-membership-request" />

<liferay-ui:search-container
	delta="10"
	total="<%=membershipRequestCount %>"
	emptyResultsMessage="No Researchers were found"
	emptyResultsMessageCssClass="taglib-empty-result-message-header"
	var ="membershipRequestSearchContainer"
>

<liferay-ui:search-container-results
	results="<%=ListUtil.subList(membershipRequestList, membershipRequestSearchContainer.getStart(), membershipRequestSearchContainer.getEnd()) %>"
/>

<% int membershipRequestContainerCount = membershipRequestSearchContainer.getStart(); %>

	<liferay-ui:search-container-row
		className="com.liferay.portal.kernel.model.MembershipRequest"
		modelVar="membershipRequest" >
	
	<%
	User membershipRequestUser = UserLocalServiceUtil.fetchUserById(membershipRequest.getUserId());
	%>
		<liferay-ui:search-container-column-text
			name="ecrf-user.list.no"
			value="<%=String.valueOf(++membershipRequestContainerCount) %>"
		/>
		
		<liferay-ui:search-container-column-text
			name="ecrf-user.list.name"
			value="<%=membershipRequestUser.getFullName() %>"
		/>
		
		<liferay-ui:search-container-column-text
			name="ecrf-user.list.email"
			value="<%=membershipRequestUser.getEmailAddress() %>"
		/>
		
		<liferay-ui:search-container-column-text
			cssClass="table-cell-expand"
			name="user-comments"
			value="<%= HtmlUtil.escape(membershipRequest.getComments()) %>"
		/>
		
		<liferay-ui:search-container-column-date
			name="create-date"
			value="<%=membershipRequest.getCreateDate() %>"
		/>
		
		<portlet:renderURL var="approveURL">
			<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_APPROVE_MEMBERSHIP %>" />
			<portlet:param name="<%=ECRFUserApproveAttibutes.MEMBERSHIP_REQUEST_ID %>" value="<%=String.valueOf(membershipRequest.getMembershipRequestId()) %>" />
			<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
		</portlet:renderURL>
		
		<liferay-ui:search-container-column-text
			name="ecrf-user.list.review">
			<aui:button type="button" value="Review" onClick="<%=approveURL.toString() %>" />
		</liferay-ui:search-container-column-text>
		
	</liferay-ui:search-container-row>

<liferay-ui:search-iterator	/>

</liferay-ui:search-container>

</c:when>
</c:choose>

<aui:script use="aui-base node">
	var A = AUI();
	A.one('#<portlet:namespace/>call').on('click', function(event) {
		console.log(window.navigator.userAgent);
		
		//window.location.replace("https://apps.apple.com/us/app/instagram/id389801252");
	});
</aui:script>