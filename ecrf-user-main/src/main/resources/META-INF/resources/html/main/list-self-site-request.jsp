<%@page import="ecrf.user.model.SelfSiteRequest"%>
<%@page import="ecrf.user.service.SelfSiteRequestLocalServiceUtil"%>
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/main/list-self-site-request_jsp"); %>

<%
SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");

ArrayList<SelfSiteRequest> siteRequestList = new ArrayList<>();
siteRequestList.addAll(SelfSiteRequestLocalServiceUtil.getAllSiteRequest());

%>

<portlet:renderURL var="viewSiteURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME%>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_SITE %>" />
</portlet:renderURL>

<div class="ecrf-user" style="margin:1rem">
	
	<liferay-ui:header cssClass="marTr" title="ecrf-user.main.title.list-self-site-request" />
		
	<liferay-ui:search-container
		delta="10"
		total="<%=siteRequestList.size() %>"
		emptyResultsMessage="ecrf-user.empty.no-self-site-request-were-found"
		emptyResultsMessageCssClass="taglib-empty-result-message-header"
		var ="siteRequestSearchContainer"
	>
		
		<liferay-ui:search-container-results
			results="<%=ListUtil.subList(siteRequestList, siteRequestSearchContainer.getStart(), siteRequestSearchContainer.getEnd()) %>"
		/>
		
		<% int siteRequestContainerCount = siteRequestSearchContainer.getStart(); %>
		
		<liferay-ui:search-container-row
			className="ecrf.user.model.SelfSiteRequest"
			keyProperty="selfSiteRequestId"
			modelVar="siteRequest" >
		
			<liferay-ui:search-container-column-text
				name="ecrf-user.list.no"
				value="<%=String.valueOf(++siteRequestContainerCount) %>"
			/>
			
			<liferay-ui:search-container-column-text
				name="ecrf-user.list.main.name"
				value="<%=siteRequest.getLastName() + StringPool.SPACE + siteRequest.getFirstName() %>"
			/>
			
			<liferay-ui:search-container-column-text
				name="ecrf-user.list.main.email"
				value="<%=siteRequest.getEmail() %>"
			/>
			
			<liferay-ui:search-container-column-text
				name="ecrf-user.list.main.project-title"
				value="<%=siteRequest.getProjectTitle() %>"
			/>
			
			<liferay-ui:search-container-column-text
				cssClass="table-cell-expand"
				name="ecrf-user.list.main.project-description"
				value="<%= HtmlUtil.escape(siteRequest.getProjectDescription()) %>"
			/>
			
		</liferay-ui:search-container-row>
		
		<liferay-ui:search-iterator	/>
		
	</liferay-ui:search-container>
	
	<aui:button-row>
		<aui:button type="button" name="back" value="ecrf-user.button.main.back" onClick="<%=viewSiteURL %>" />
	</aui:button-row>
	
</div>