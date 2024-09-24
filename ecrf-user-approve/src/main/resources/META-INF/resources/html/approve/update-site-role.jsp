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
	researcherUser = UserLocalServiceUtil.fetchUser(researcher.getUserId());
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

<div class="ecrf-user-approve ecrf-user">
	
	<div class="pad16">
	
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.approve.title.site-role" />
		
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
						delta="10"
						total="<%=siteRoles.size() %>"
						emptyResultsMessage="No Researchers were found"
						emptyResultsMessageCssClass="taglib-empty-result-message-header"
						var="searchContainer"
					>
						<liferay-ui:search-container-results
							results="<%=ListUtil.subList(siteRoles, searchContainer.getStart(), searchContainer.getEnd()) %>"
						/>
						
						<liferay-ui:search-container-row
							className="com.liferay.portal.kernel.model.Role"
							escapedModel="<%= true %>"
							keyProperty="roleId"
							modelVar="role"
						
						>
							<%
							Map<String, Object> data = HashMapBuilder.<String, Object>put(
								"id", role.getRoleId()
							).build();
							%>
							
							<liferay-ui:search-container-column-text
								colspan="<%= 2 %>"
							>
								<h5>
									<aui:a cssClass="selector-button" data="<%= data %>" href="javascript:;">
										<%= HtmlUtil.escape(role.getTitle(locale)) %>
									</aui:a>
								</h5>
		
								<h6 class="text-default">
									<span><%= HtmlUtil.escape(role.getDescription(locale)) %></span>
								</h6>
		
								<h6 class="text-default">
									<%= LanguageUtil.get(request, role.getTypeLabel()) %>
								</h6>
							</liferay-ui:search-container-column-text>
					
						</liferay-ui:search-container-row>
						
								<liferay-ui:search-iterator
									displayStyle="descriptive"
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
						<aui:button value="Back" onClick="<%=redirect.toString() %>" /> 
					</aui:button-row>
				</aui:col>
			</aui:row>
		</aui:container>
	</div>
</div>

<aui:script>
</aui:script>