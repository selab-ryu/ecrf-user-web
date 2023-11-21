<%@ page import="ecrf.user.main.display.context.SiteDisplayContext"%>
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/main/view-site_jsp"); %>

<%
	SiteDisplayContext siteDisplayContext = new SiteDisplayContext(renderRequest, renderResponse);
	boolean signedIn = themeDisplay.isSignedIn();
	if(!signedIn) _log.info("not logged in");
%>

<liferay-ui:error embed="<%= false %>" key="membershipAlreadyRequested" message="membership-was-already-requested" />

<liferay-ui:header title="ecrf-user.main.title.view-my-site" />

<liferay-ui:search-container
	searchContainer="<%=siteDisplayContext.getMyGroupSearchContainer() %>">
	
	<liferay-ui:search-container-row
			className="com.liferay.portal.kernel.model.Group"
			keyProperty="groupId"
			modelVar="group"
			rowIdProperty="friendlyURL"
		>
		
		<%
			String siteImageURL = group.getLogoURL(themeDisplay, false);

			String rowURL = StringPool.BLANK;

			if (group.getPublicLayoutsPageCount() > 0) {
				rowURL = group.getDisplayURL(themeDisplay, false);
			} else if (group.getPrivateLayoutsPageCount() > 0) {
				rowURL = group.getDisplayURL(themeDisplay, true);
			}
		%>
		
		<c:choose>
			<c:when test="<%= Validator.isNotNull(siteImageURL) %>">
				<liferay-ui:search-container-column-image
					src="<%= siteImageURL %>"
				/>
			</c:when>
			<c:otherwise>
				<liferay-ui:search-container-column-icon
					icon="sites"
				/>
			</c:otherwise>
		</c:choose>
		
		<liferay-ui:search-container-column-text
			colspan="<%= 2 %>"
		>
			<div>
				<c:choose>
					<c:when test="<%= Validator.isNotNull(rowURL) %>">
						<a href="<%= rowURL %>" target="_blank">
							<strong><%= HtmlUtil.escape(group.getDescriptiveName(locale)) %></strong>
						</a>
					</c:when>
					<c:otherwise>
						<strong><%= HtmlUtil.escape(group.getDescriptiveName(locale)) %></strong>
					</c:otherwise>
				</c:choose>
			</div>
			
			<c:if test='<%= Validator.isNotNull(group.getDescription(locale)) %>'>
				<div class="text-default">
					<%= HtmlUtil.escape(group.getDescription(locale)) %>
				</div>
			</c:if>
			
			<%
			int usersCount = siteDisplayContext.getGroupUsersCount(group.getGroupId());
			%>
			
			<c:if test="<%= usersCount > 0 %>">
			<div class="text-default">
				<strong><liferay-ui:message arguments="<%= usersCount %>" key='<%= (usersCount > 1) ? "x-users" : "x-user" %>' /></strong>
			</div>
			</c:if>
			
		</liferay-ui:search-container-column-text>
		
	</liferay-ui:search-container-row>
	
	<liferay-ui:search-iterator
		displayStyle="descriptive"
		markupView="lexicon"
	/>
	
</liferay-ui:search-container>

<liferay-ui:header title="ecrf-user.main.title.view-available-site" />

<liferay-ui:search-container
	searchContainer="<%=siteDisplayContext.getAvailableGroupSearchContainer() %>">
	
	<liferay-ui:search-container-row
			className="com.liferay.portal.kernel.model.Group"
			keyProperty="groupId"
			modelVar="group"
			rowIdProperty="friendlyURL"
		>
		
		<%
			String siteImageURL = group.getLogoURL(themeDisplay, false);

			String rowURL = StringPool.BLANK;

			if (group.getPublicLayoutsPageCount() > 0) {
				rowURL = group.getDisplayURL(themeDisplay, false);
			} else if (group.getPrivateLayoutsPageCount() > 0) {
				rowURL = group.getDisplayURL(themeDisplay, true);
			}
		%>
		
		<c:choose>
			<c:when test="<%= Validator.isNotNull(siteImageURL) %>">
				<liferay-ui:search-container-column-image
					src="<%= siteImageURL %>"
				/>
			</c:when>
			<c:otherwise>
				<liferay-ui:search-container-column-icon
					icon="sites"
				/>
			</c:otherwise>
		</c:choose>
		
		<liferay-ui:search-container-column-text
			colspan="<%= 2 %>"
		>
			<div>
			<c:choose>
			<c:when test="<%= Validator.isNotNull(rowURL) %>">
				<a href="<%= rowURL %>" target="_blank">
					<strong><%= HtmlUtil.escape(group.getDescriptiveName(locale)) %></strong>
				</a>
			</c:when>
			<c:otherwise>
				<strong><%= HtmlUtil.escape(group.getDescriptiveName(locale)) %></strong>
			</c:otherwise>
			</c:choose>
			</div>
			
			<c:if test='<%= Validator.isNotNull(group.getDescription(locale)) %>'>
			<div class="text-default">
				<%= HtmlUtil.escape(group.getDescription(locale)) %>
			</div>
			</c:if>
			
			<%
			int usersCount = siteDisplayContext.getGroupUsersCount(group.getGroupId());
			%>
			
			<c:if test="<%= usersCount > 0 %>">
			<div class="text-default">
				<strong><liferay-ui:message arguments="<%= usersCount %>" key='<%= (usersCount > 1) ? "x-users" : "x-user" %>' /></strong>
			</div>
			</c:if>
			
		</liferay-ui:search-container-column-text>
		
		<liferay-ui:search-container-column-text>
			<portlet:renderURL var="requestMembershipURL">
				<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_REQUEST_MEMBERSHIP %>" />
				<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
			</portlet:renderURL>
			
			<aui:button type="button" value="Join" onClick="<%=requestMembershipURL.toString() %>" />
		</liferay-ui:search-container-column-text>
		
	</liferay-ui:search-container-row>
	
	<liferay-ui:search-iterator
		displayStyle="descriptive"
		markupView="lexicon"
	/>
	
</liferay-ui:search-container>