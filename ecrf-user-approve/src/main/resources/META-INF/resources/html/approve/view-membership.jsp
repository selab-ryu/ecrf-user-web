<%@page import="ecrf.user.approve.servlet.taglib.util.MembershipUserActionDropdownItemsProvider"%>
<%@page import="java.util.StringJoiner"%>
<%@page import="com.liferay.petra.string.StringUtil"%>
<%@page import="ecrf.user.constants.attribute.ECRFUserResearcherAttributes"%>
<%@page import="com.liferay.portal.kernel.model.UserGroupRole"%>
<%@page import="com.liferay.portal.kernel.service.UserGroupRoleLocalServiceUtil"%>
<%@page import="ecrf.user.model.CRFResearcher"%>
<%@page import="ecrf.user.service.CRFResearcherLocalServiceUtil"%>
<%@page import="ecrf.user.constants.ECRFUserActionKeys"%>
<%@page import="ecrf.user.constants.type.ResearcherPosition"%>
<%@page import="com.liferay.portal.kernel.service.RoleLocalServiceUtil"%>
<%@page import="ecrf.user.constants.attribute.ECRFUserApproveAttibutes"%>
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/approve/view-membership_jsp"); %>

<%
List<User> siteUsers = UserLocalServiceUtil.getGroupUsers(scopeGroupId);
Role adminRole = RoleLocalServiceUtil.getRole(themeDisplay.getCompanyId(), "Administrator");
int removeIndex = -1;

// admin dosent have researcher entity
// find admin user from site users
for(int i=0; i<siteUsers.size(); i++) {
	User tempSiteUser = siteUsers.get(i);
	if(tempSiteUser.getRoles().contains(adminRole)) removeIndex = i;
}

// remove admin user from site user
if(removeIndex >= 0) {
	siteUsers.remove(removeIndex);
}

int siteUserCount = siteUsers.size();

if(siteUsers.size() <= 0) {
	_log.info("0 group user");
} else {
	for(int i=0; i<siteUserCount; i++) {
		User siteUser = siteUsers.get(i); 
		
		String roleStr = "";
		ArrayList<Role> roleList = new ArrayList<>();
		roleList.addAll(siteUser.getRoles());
		for(int j=0; j<roleList.size(); j++) {
			Role role = roleList.get(j);
			roleStr += role.getName();
			if(j != roleList.size()) roleStr += " | ";
		}
		
		_log.info("Site Member / " + "name : " + siteUser.getFullName() + " / " + "email : " + siteUser.getEmailAddress() + " / " + roleStr);
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

<div class="ecrf-user-approve ecrf-user">
	
	<div class="pad16">
	
		<liferay-ui:header title="ecrf-user.approve.title.view-membership" />
		
		<aui:button cssClass="hide" name="call" value="Call" />
		
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
					value="<%=String.valueOf(++membershipUserCount) %>"
					cssClass="descriptive-index-col descriptive-col-center"
				/>
				
				<liferay-ui:search-container-column-text
					cssClass="descriptive-col-center"
				>
					<liferay-ui:user-portrait
						userId="<%=siteUser.getUserId() %>"
					/>
				</liferay-ui:search-container-column-text>
				
				<%
				Researcher researcher = ResearcherLocalServiceUtil.getResearcherByUserId(siteUser.getUserId());
				
				// get researhcer role
				List<UserGroupRole> userGroupRoleList = UserGroupRoleLocalServiceUtil.getUserGroupRoles(siteUser.getUserId(), scopeGroupId);
				
				String roleStr = "";
				
				if(userGroupRoleList != null) {
					for(int i=0; i<userGroupRoleList.size(); i++) {
						UserGroupRole userGroupRole = userGroupRoleList.get(i); 
						Role role = RoleLocalServiceUtil.getRole(userGroupRole.getRoleId());
		
						roleStr += role.getName();	
						if(i<userGroupRoleList.size()-1) roleStr += StringPool.COMMA_AND_SPACE; 						
					}
				} 				
				%>
				
				<liferay-ui:search-container-column-text
					colspan="<%= 2 %>"
				>
					<h5>
						<%=HtmlUtil.escape(researcher.getName() + "(" + siteUser.getEmailAddress() + ")") %>
					</h5>
					
					<h6>
						<span><%=Validator.isNull(roleStr) ? StringPool.DASH : roleStr %></span>
					</h6>
					
					<h6>
						<span><%=Validator.isNull(researcher) ? StringPool.DASH : researcher.getInstitution() %></span>
					</h6>
				</liferay-ui:search-container-column-text>
				
				<%
				MembershipUserActionDropdownItemsProvider membershipUserActionDropdownItemProvider = new MembershipUserActionDropdownItemsProvider(siteUser, renderRequest, renderResponse);
				%>
				
				<liferay-ui:search-container-column-text>
					
					<portlet:renderURL var="updateSiteRoleURL">
						<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_UPDATE_SITE_ROLE %>" />
						<portlet:param name="<%=ECRFUserResearcherAttributes.RESEARCHER_ID %>" value="<%=String.valueOf(researcher.getResearcherId()) %>" />
						<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
					</portlet:renderURL>
				
					<aui:button name="siteRole" type="button" value="ecrf-user.button.update-site-role" cssClass="small-btn none-btn" onClick="<%=updateSiteRoleURL %>" ></aui:button>
					
					<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_MEMBERSHIP %>" var="deleteMembershipURL">
						<portlet:param name="<%=ECRFUserAttributes.USER_ID %>" value="<%=String.valueOf(researcher.getResearcherUserId()) %>" />
						<portlet:param name="<%=ECRFUserAttributes.GROUP_ID %>" value="<%=String.valueOf(scopeGroupId) %>" />
					</portlet:actionURL>
					
					<%
						String title = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-membership.title");
						String content = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-membership.content");
						String deleteFunctionCall = String.format("deleteConfirm('%s', '%s', '%s')", title, content, deleteMembershipURL.toString());
					%>
					
					<aui:button  
						name="deleteMembership" 
						type="button" 
						value="ecrf-user.button.delete-membership" 
						cssClass="small-btn delete-btn" 
						onClick="<%=deleteFunctionCall %>">
					</aui:button>
				</liferay-ui:search-container-column-text>
								 
			</liferay-ui:search-container-row>
		
			<liferay-ui:search-iterator
				displayStyle="descriptive"
				markupView="lexicon"
			/>
		</liferay-ui:search-container>
		
		<c:choose>
		<c:when test="<%=ApprovePermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ASSIGN_MEMBERS) %>">	
		
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
					value="<%=membershipRequestUser.getLastName() + StringPool.SPACE + membershipRequestUser.getFirstName() %>"
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
					<a class="icon-button-submit icon-button-submit-review" href="<%=approveURL %>" name="<portlet:namespace/>review">
						<img src="<%= renderRequest.getContextPath() + "/btn_img/review_icon.png"%>"/>					
						<span>Review</span>
					</a>
				</liferay-ui:search-container-column-text>
				
			</liferay-ui:search-container-row>
		
		<liferay-ui:search-iterator	/>
		
		</liferay-ui:search-container>
		
		</c:when>
		</c:choose>

	</div>
</div>
<aui:script use="aui-base node">
	var A = AUI();
	A.one('#<portlet:namespace/>call').on('click', function(event) {
		console.log(window.navigator.userAgent);
		
		//window.location.replace("https://apps.apple.com/us/app/instagram/id389801252");
	});
</aui:script>

<script>

</script>