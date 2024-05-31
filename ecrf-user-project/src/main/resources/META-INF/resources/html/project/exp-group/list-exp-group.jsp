<%@page import="ecrf.user.constants.ExperimentalGroupType"%>
<%@page import="ecrf.user.constants.attribute.ECRFUserExpGroupAttributes"%>
<%@ include file="../../init.jsp" %>

<%!private static Log _log = LogFactoryUtil.getLog("html.project.exp-group.list_exp_group_jsp");%>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

String menu="exp-group";

ArrayList<ExperimentalGroup> expGroupList = new ArrayList<>(); 
expGroupList.addAll(ExperimentalGroupLocalServiceUtil.getExpGroupByGroupId(scopeGroupId));

boolean isSearch = ParamUtil.getBoolean(renderRequest, "isSearch", false);

PortletURL portletURL = null;
%>

<portlet:renderURL var="addExpGroupURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME%>" value="<%=ECRFUserMVCCommand.RENDER_ADD_EXP_GROUP%>"/>
</portlet:renderURL>

<div class="ecrf-user">
	<%@ include file="../sidebar.jspf" %>
	
	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect%>" title="ecrf-user.project.title.exp-group-list" />
		
		<aui:form action="${searchURL}" name="searchOptionFm" autocomplete="off" cssClass="marBr">
			<aui:container cssClass="radius-shadow-container">
			</aui:container>
		</aui:form>
		
		<aui:button-row>
			<aui:button name="addExp" value="ecrf-user.button.add" onClick="<%=addExpGroupURL%>" />
		</aui:button-row>
		
		<liferay-ui:search-container
			iteratorURL="<%=portletURL%>"
			delta="10"
			emptyResultsMessage="ecrf-user.empty.no-exp-group-were-found"
			emptyResultsMessageCssClass="taglib-empty-result-message-header"
			total="<%=expGroupList.size()%>"
			var="searchContainer"
			cssClass="marTrh center-table radius-shadow-container"
			>
			
			<liferay-ui:search-container-results
				results="<%=ListUtil.subList(expGroupList, searchContainer.getStart(), searchContainer.getEnd())%>" /> 
			
			<%
				if(expGroupList.size() == 0) {
					searchContainer.setEmptyResultsMessageCssClass("taglib-empty-search-result-message-header");
					searchContainer.setEmptyResultsMessage("ecrf-user.empty.no-search-result");
				}
			%>
			
			<%
				int count = searchContainer.getStart();
			%>
			
			<liferay-ui:search-container-row
				className="ecrf.user.model.ExperimentalGroup"
				escapedModel="<%=true%>"
				keyProperty="experimentalGroupId"
				modelVar="expGroup"
			>
			
			<liferay-ui:search-container-column-text
				name="ecrf-user.list.no"
				value="<%=String.valueOf(++count)%>"
			/>
			
			<liferay-ui:search-container-column-text 
				name="ecrf-user.project.exp-group.name"
				value="<%=expGroup.getName()%>"
			/>
			
			<%
				ExperimentalGroupType expGroupEnum = ExperimentalGroupType.valueOf(expGroup.getType());
			%>
			
			<liferay-ui:search-container-column-text 
				name="ecrf-user.project.exp-group.type"
				value="<%=expGroupEnum.getFullString() %>"
			/>
			
			<liferay-ui:search-container-column-text
				name="ecrf-user.list-create-date"
				value="<%=sdf.format(expGroup.getCreateDate()) %>"
			/>
			
			<portlet:renderURL var="updateExpGroupURL">
				<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_UPDATE_EXP_GROUP%>" />
				<portlet:param name="<%=ECRFUserExpGroupAttributes.EXP_GROUP_ID%>" value="<%=String.valueOf(expGroup.getExperimentalGroupId())%>" />
				<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />			
			</portlet:renderURL>
			
			<liferay-ui:search-container-column-text
				name="ecrf-user.list.update"
				cssClass="min-width-80"
			>
				<aui:button name="updateExpGroup" value="ecrf-user.button.update" cssClass="ci-btn small-btn" onClick="<%=updateExpGroupURL %>" />
			
			</liferay-ui:search-container-column-text>
			
			</liferay-ui:search-container-row>
			
			<liferay-ui:search-iterator
				displayStyle="list"
				markupView="lexicon"
				paginate="<%=true %>"
				searchContainer="<%=searchContainer %>"
			/>
			
		</liferay-ui:search-container>
		
	</div>
</div>