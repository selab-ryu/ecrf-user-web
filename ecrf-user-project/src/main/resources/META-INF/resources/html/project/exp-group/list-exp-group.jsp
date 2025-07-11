<%@page import="com.liferay.portal.kernel.portlet.PortletURLUtil"%>
<%@page import="ecrf.user.project.util.ExpGroupSearchUtil"%>
<%@page import="ecrf.user.constants.type.ExperimentalGroupType"%>
<%@page import="ecrf.user.constants.attribute.ECRFUserExpGroupAttributes"%>
<%@ include file="../../init.jsp" %>

<%!private static Log _log = LogFactoryUtil.getLog("html.project.exp-group.list_exp_group_jsp");%>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

String menu = ECRFUserMenuConstants.LIST_EXP_GROUP;

ArrayList<ExperimentalGroup> expGroupList = new ArrayList<>(); 
expGroupList.addAll(ExperimentalGroupLocalServiceUtil.getExpGroupByGroupId(scopeGroupId));

boolean isSearch = ParamUtil.getBoolean(renderRequest, "isSearch", false);

PortletURL portletURL = null;

boolean hasAddPermission = ProjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ADD_EXP_GROUP);
boolean hasUpdatePermission = ProjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.UPDATE_EXP_GROUP);
boolean hasDeletePermission = ProjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DELETE_EXP_GROUP);

if(isSearch) {	
	ExpGroupSearchUtil searchUtil = new ExpGroupSearchUtil(expGroupList);
	
	portletURL = PortletURLUtil.getCurrent(renderRequest, renderResponse);
	_log.info("portlet url : " + portletURL.toString());
	
	String nameKeyword = ParamUtil.getString(renderRequest, ECRFUserExpGroupAttributes.NAME);
	String abbrKeyword = ParamUtil.getString(renderRequest, ECRFUserExpGroupAttributes.ABBREVIATION);
	int typeKeyword = ParamUtil.getInteger(renderRequest, ECRFUserExpGroupAttributes.TYPE, -1);
	
	ExperimentalGroupType expGroupType = ExperimentalGroupType.valueOf(typeKeyword);
	
	expGroupList = searchUtil.search(nameKeyword, abbrKeyword, expGroupType);
}
%>

<portlet:renderURL var="searchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_EXP_GROUP %>" />
	<portlet:param name="isSearch" value="true" />
</portlet:renderURL>

<portlet:renderURL var="clearSearchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_EXP_GROUP %>" />	
</portlet:renderURL>

<portlet:renderURL var="addExpGroupURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME%>" value="<%=ECRFUserMVCCommand.RENDER_ADD_EXP_GROUP%>"/>
</portlet:renderURL>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.1/font/bootstrap-icons.css">

<div class="ecrf-user">
	<%@ include file="../sidebar.jspf" %>
	
	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect%>" title="ecrf-user.project.title.exp-group-list" />
		
		<aui:form action="${searchURL}" name="searchOptionFm" autocomplete="off" cssClass="marBr">
			<aui:container cssClass="radius-shadow-container">
				<aui:row>
					<aui:col md="6">
						<aui:field-wrapper
							name="<%=ECRFUserExpGroupAttributes.NAME %>"
							label="ecrf-user.project.exp-group.name"
							helpMessage="ecrf-user.project.exp-group.name.help"
							cssClass="marBrh"
						>
							<aui:input
								type="text"
								name="<%=ECRFUserExpGroupAttributes.NAME %>"
								cssClass="form-control"
								label=" "
								></aui:input>
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="6">
						<aui:field-wrapper
							name="<%=ECRFUserExpGroupAttributes.ABBREVIATION %>"
							label="ecrf-user.project.exp-group.abbreviation"
							helpMessage="ecrf-user.project.exp-group.abbreviation.help"
							cssClass="marBrh"
						>
							<aui:input
								type="text"
								name="<%=ECRFUserExpGroupAttributes.ABBREVIATION %>"
								cssClass="form-control"
								label=" "
								></aui:input>
						</aui:field-wrapper>
					</aui:col>
				</aui:row>
				<aui:row>
					<aui:col md="12">
						<aui:field-wrapper
							name="<%=ECRFUserExpGroupAttributes.TYPE %>"
							label="ecrf-user.project.exp-group.type"
							helpMessage="ecrf-user.project.exp-group.type.help"
							cssClass="marBrh"
						>
							<aui:fieldset cssClass="radio-one-line radio-align">
								<aui:input 
									type="radio" 
									name="<%=ECRFUserExpGroupAttributes.TYPE %>" 
									cssClass="search-input"
									label="ecrf-user.project.exp-group.type.experimental-group"  
									value="0" />
								<aui:input 
									type="radio" 
									name="<%=ECRFUserExpGroupAttributes.TYPE %>" 
									cssClass="search-input"
									label="ecrf-user.project.exp-group.type.control-group" 
									value="1" />
								<aui:input 
									type="radio" 
									name="<%=ECRFUserExpGroupAttributes.TYPE %>" 
									cssClass="search-input"
									label="ecrf-user.project.exp-group.type.not-assign" 
									value="2" />
							</aui:fieldset>
						</aui:field-wrapper>
					</aui:col>
				</aui:row>
				
				<aui:row>
					<aui:col md="12">
						<aui:button-row cssClass="right marVr">
							<button id="<portlet:namespace/>search" type="submit" class="br20 dh-icon-button submit-btn search-btn white-text w130 h40 marR8 active">
								<img class="search-icon" />
								<span><liferay-ui:message key="ecrf-user.button.search" /></span>
							</button>
							<button id="<portlet:namespace/>clear" type="button" class="br20 dh-icon-button submit-btn clear-btn white-text w130 h40 active" onclick="location.href='<%=clearSearchURL %>'">
								<img class="clear-icon" />
								<span><liferay-ui:message key="ecrf-user.button.clear" /></span>
							</button>
						</aui:button-row>
					</aui:col>
				</aui:row>
			</aui:container>
		</aui:form>
		
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
				name="ecrf-user.list.name"
				value="<%=expGroup.getName()%>"
			/>
			
			<liferay-ui:search-container-column-text 
				name="ecrf-user.list.abbreviation"
				value="<%=expGroup.getAbbreviation()%>"
			/>
			
			<%
				ExperimentalGroupType expGroupEnum = ExperimentalGroupType.valueOf(expGroup.getType());
			%>
			
			<liferay-ui:search-container-column-text 
				name="ecrf-user.list.type"
				value="<%=expGroupEnum.getFullString() %>"
			/>
			
			<liferay-ui:search-container-column-text
				name="ecrf-user.list.create-date"
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
				<%
					String updateBtnClass = "dh-icon-button w130";
					String updateOnClickStr = "location.href='"+ updateExpGroupURL +"'";
					String updateBtnKey = "ecrf-user.button.update";

					if(!hasUpdatePermission) {
						updateBtnClass += " inactive";
						updateOnClickStr = "";
						updateBtnKey = "ecrf-user.button.locked";
					} else {
						updateBtnClass += " update-btn";	
					}
				%>
				
				<button id="updateExpGroup" class="<%=updateBtnClass%>" onclick="<%=updateOnClickStr%>" <%=!hasUpdatePermission ? "disabled" : "" %>>
					<img class="update-icon<%=TagAttrUtil.inactive(!hasUpdatePermission, TagAttrUtil.TYPE_ICON)%>" />
					<span><liferay-ui:message key="<%=updateBtnKey %>" /></span>
				</button>
			</liferay-ui:search-container-column-text>
			
			<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_EXP_GROUP%>" var="deleteExpGroupURL" >
				<portlet:param name="<%=ECRFUserExpGroupAttributes.EXP_GROUP_ID%>" value="<%=String.valueOf(expGroup.getExperimentalGroupId())%>" />
			</portlet:actionURL>
			
			<liferay-ui:search-container-column-text
				name="ecrf-user.list.delete"
				cssClass="min-width-80"
			>
			<%
				String deleteBtnClass = "dh-icon-button w130";
				String deleteBtnKey = "ecrf-user.button.delete";
			
				String title = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-exp-group.title");
				String content = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-exp-group.content");
				String deleteFunctionCall = String.format("deleteConfirm('%s', '%s', '%s' )", title, content, deleteExpGroupURL.toString());
				
				if(!hasDeletePermission) {
					deleteBtnClass += " inactive";
					deleteFunctionCall = "";
					deleteBtnKey = "ecrf-user.button.locked";
				} else {
					deleteBtnClass += " delete-btn";
				}
			%>
				<button id="deleteExpGroup" class="<%=deleteBtnClass%>" onClick="<%=deleteFunctionCall %>" <%=!hasDeletePermission ? "disabled" : "" %>>
					<img class="delete-icon<%=TagAttrUtil.inactive(!hasDeletePermission, TagAttrUtil.TYPE_ICON)%>" />
					<span><liferay-ui:message key="<%=deleteBtnKey %>" /></span>
				</button>
			</liferay-ui:search-container-column-text>
			
			</liferay-ui:search-container-row>
			
			<liferay-ui:search-iterator
				displayStyle="list"
				markupView="lexicon"
				paginate="<%=true %>"
				searchContainer="<%=searchContainer %>"
			/>
			
		</liferay-ui:search-container>
		
		<c:if test="<%=hasAddPermission %>">
		<aui:button-row>
			<button id="<portlet:namespace/>addExp" class="dh-icon-button submit-btn add-btn w110 h36 marR8" onclick="location.href='<%=addExpGroupURL%>'">
				<img class="add-icon" />
				<span><liferay-ui:message key="ecrf-user.button.add" /></span>
			</button>
		</aui:button-row>
		</c:if>
		
	</div>
</div>