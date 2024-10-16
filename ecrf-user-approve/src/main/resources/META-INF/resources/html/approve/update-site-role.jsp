<%@page import="ecrf.user.approve.servlet.taglib.clay.RoleVerticalCard"%>
<%@page import="ecrf.user.approve.display.context.UserRolesManagementToolbarDisplayContext"%>
<%@page import="ecrf.user.approve.display.context.UserRolesDisplayContext"%>
<%@page import="com.liferay.portal.kernel.util.HashMapBuilder"%>
<%@page import="com.liferay.portal.kernel.model.role.RoleConstants"%>
<%@page import="com.liferay.portal.kernel.service.RoleLocalServiceUtil"%>
<%@page import="ecrf.user.constants.attribute.ECRFUserResearcherAttributes"%>
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/approve/update-site-role_jsp"); %>

<%
SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

long researcherId = ParamUtil.getLong(renderRequest, ECRFUserResearcherAttributes.RESEARCHER_ID);
Researcher researcher = null;
User researcherUser = null;

if(researcherId > 0) {
	_log.info("researcher id : " + researcherId);
	researcher = ResearcherLocalServiceUtil.fetchResearcher(researcherId);
	researcherUser = UserLocalServiceUtil.fetchUser(researcher.getResearcherUserId());
	_log.info(researcher.getResearcherUserId() + " / " + researcherUser.getFullName());
}

int roleType = RoleConstants.TYPE_SITE;
String roleSubtype = StringPool.BLANK;

List<Role> allSiteRoles = RoleLocalServiceUtil.getRoles(roleType, roleSubtype);

ArrayList<Role> siteRoles = new ArrayList<Role>();

for(int i=0; i<allSiteRoles.size(); i++) {
	Role tempRole = allSiteRoles.get(i);
	_log.info(tempRole.getTitle() + " / " + tempRole.isSystem());
	
	if(!tempRole.isSystem()) {
		siteRoles.add(tempRole);
	}
}

%>

<portlet:renderURL var="viewMembershipURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_MEMBERSHIP %>" />
</portlet:renderURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_UPDATE_USER_SITE_ROLE %>" var="updateUserSiteRoleURL">
	<portlet:param name="<%=ECRFUserAttributes.USER_ID %>" value="<%=String.valueOf(researcher.getResearcherUserId()) %>" />
	<portlet:param name="<%=ECRFUserAttributes.GROUP_ID %>" value="<%=String.valueOf(scopeGroupId) %>" />
</portlet:actionURL>

<div class="ecrf-user-approve ecrf-user">
	
	<div class="pad16">
	
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.approve.title.site-role" />
		
		<%
		UserRolesDisplayContext userRolesDisplayContext = new UserRolesDisplayContext(request, renderRequest, renderResponse);
		userRolesDisplayContext.setCurUser(researcherUser);
		%>
		
		<clay:management-toolbar
			displayContext="<%=new UserRolesManagementToolbarDisplayContext(liferayPortletRequest, liferayPortletResponse, request, userRolesDisplayContext) %>"
		/>
		
		<aui:form name="fm" action="<%=updateUserSiteRoleURL %>">
		
		<aui:container cssClass="radius-shadow-container">
			<aui:row>
				<aui:col md="12">
					<span class="title-span">
						<liferay-ui:message key="ecrf-user.approve.title.update-site-role" />
					</span>
					<hr align="center" class="marV5"></hr>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col md="12">
					<liferay-ui:search-container
						id="userGroupRoleRole"
						searchContainer="<%= userRolesDisplayContext.getRoleSearchSearchContainer() %>"
					>
						<liferay-ui:search-container-row
							className="com.liferay.portal.kernel.model.Role"
							keyProperty="roleId"
							modelVar="role"
						>
				
						<%
						String displayStyle = userRolesDisplayContext.getDisplayStyle();
						
						_log.info(role.getName());
						%>
						
						<c:choose>
							<c:when test='<%= displayStyle.equals("icon") %>'>
						
								<%
								row.setCssClass("entry-card lfr-asset-item");
								%>
						
								<liferay-ui:search-container-column-text>
									<clay:vertical-card
										verticalCard="<%= new RoleVerticalCard(role, renderRequest, searchContainer.getRowChecker()) %>"
									/>
								</liferay-ui:search-container-column-text>
							</c:when>
							<c:when test='<%= displayStyle.equals("descriptive") %>'>
								<liferay-ui:search-container-column-icon
									icon="users"
									toggleRowChecker="<%= true %>"
								/>
						
								<liferay-ui:search-container-column-text
									colspan="<%= 2 %>"
								>
									<h5><%= HtmlUtil.escape(role.getTitle(locale)) %></h5>
						
									<h6 class="text-default">
										<span><%= HtmlUtil.escape(role.getDescription(locale)) %></span>
									</h6>
						
									<h6 class="text-default">
										<%= LanguageUtil.get(request, role.getTypeLabel()) %>
									</h6>
								</liferay-ui:search-container-column-text>
							</c:when>
							<c:when test='<%= displayStyle.equals("list") %>'>
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-small table-cell-minw-200 table-title"
									name="title"
									value="<%= HtmlUtil.escape(role.getTitle(locale)) %>"
								/>
						
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand table-cell-minw-300"
									name="description"
									value="<%= HtmlUtil.escape(role.getDescription(locale)) %>"
								/>
						
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smallest"
									name="type"
									value="<%= LanguageUtil.get(request, role.getTypeLabel()) %>"
								/>
							</c:when>
						</c:choose>
					
						</liferay-ui:search-container-row>
						
					<liferay-ui:search-iterator
						displayStyle="<%= userRolesDisplayContext.getDisplayStyle() %>"
						markupView="lexicon"
					/>
						
					</liferay-ui:search-container>
				</aui:col>
			</aui:row>				
		</aui:container>
				
		<aui:container>
			<aui:row>
				<aui:col>
					<aui:button-row> 
						<aui:button type="submit" value="Update" />
						<aui:button value="Back" onClick="<%=redirect.toString() %>" /> 
					</aui:button-row>
				</aui:col>
			</aui:row>
		</aui:container>
		
		</aui:form>
	</div>
</div>

<aui:script use="liferay-search-container">
	var searchContainer = Liferay.SearchContainer.get('<portlet:namespace />userGroupRoleRole');

	searchContainer.on('rowToggled', function(event) {
		Liferay.Util.getOpener().Liferay.fire(
			'<%= HtmlUtil.escapeJS(userRolesDisplayContext.getEventName()) %>',
			{
				data: event.elements.allSelectedElements.getDOMNodes()
			}
		);
	});
</aui:script>