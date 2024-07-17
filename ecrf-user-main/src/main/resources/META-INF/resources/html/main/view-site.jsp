<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/main/view-site_jsp"); %>

<%
	SiteDisplayContext siteDisplayContext = new SiteDisplayContext(renderRequest, renderResponse);
	boolean signedIn = themeDisplay.isSignedIn();
	if(!signedIn) _log.info("not logged in");
%>

<style>
.list-group-item-flex .autofit-col {
    justify-content: center;
}
</style>

<liferay-ui:error embed="<%= false %>" key="membershipAlreadyRequested" message="membership-was-already-requested" />

<div class="ecrf-user pad1R">

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
			List<CRF> crfList = CRFLocalServiceUtil.getCRFByGroupId(group.getGroupId());
			List<DataType> dataTypeList = new ArrayList<>(); 
			//_log.info(crfList.size());
			
			for(int i=0; i<crfList.size(); i++ ) {
				CRF crf = crfList.get(i);
				DataType dataType = DataTypeLocalServiceUtil.getDataType(crf.getDatatypeId());
				if(Validator.isNotNull(dataType)) {
					//_log.info("datatype check");
					JSONObject obj = DataTypeLocalServiceUtil.getDataTypeStructureJSONObject(dataType.getDataTypeId());
					//_log.info(obj);
					
					String dataTypePrint = "";
					JSONArray termsArr = null;
					boolean isEmpty = false;
					
					if(Validator.isNull(obj)) {
						isEmpty = true;	// crf form not exist 
					} else {
						termsArr = obj.getJSONArray("terms");
						//_log.info(termsArr);
						
						if(Validator.isNull(termsArr)) isEmpty = true;	// crf form dosent have term
					}
					
					if(isEmpty) {
						dataTypePrint = (i+1) + StringPool.PERIOD + StringPool.SPACE + dataType.getDisplayName() + StringPool.SPACE + "(0)";
					} else {
						dataTypePrint = (i+1) + StringPool.PERIOD + StringPool.SPACE + dataType.getDisplayName() + StringPool.SPACE + "(" + termsArr.length() + ")";	
					}					
			%>

			<div class="text-default">
				<strong><%=dataTypePrint %></strong>
			</div>
			
			<%
				}
			}
			%>
			
			<%
			int usersCount = siteDisplayContext.getGroupUsersCount(group.getGroupId());
			%>
			
				
			<c:if test="false">
			<c:if test="<%= usersCount > 0 %>">
			<div class="text-default">
				<strong><liferay-ui:message arguments="<%= usersCount %>" key='<%= (usersCount > 1) ? "x-users" : "x-user" %>' /></strong>
			</div>
			</c:if>
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
		
		<c:if test="<%=signedIn %>">
		
		<liferay-ui:search-container-column-text>
			<portlet:renderURL var="requestMembershipURL">
				<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_REQUEST_MEMBERSHIP %>" />
				<portlet:param name="<%=ECRFUserMainAttributes.SITE_GROUP_ID %>" value="<%=String.valueOf(group.getGroupId()) %>" />
				<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
			</portlet:renderURL>
			
			<aui:button type="button" value="Join" onClick="<%=requestMembershipURL.toString() %>" />
		</liferay-ui:search-container-column-text>
		
		</c:if>
	</liferay-ui:search-container-row>
	
	<liferay-ui:search-iterator
		displayStyle="descriptive"
		markupView="lexicon"
	/>
	
</liferay-ui:search-container>

</div>