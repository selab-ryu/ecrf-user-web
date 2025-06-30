<%@ page import="ecrf.user.constants.type.ExperimentalGroupType"%>
<%@ page import="ecrf.user.constants.attribute.ECRFUserExpGroupAttributes"%>
<%@ include file="../../init.jsp" %>

<%!private static Log _log = LogFactoryUtil.getLog("html.project.exp-group.list_exp_group_jsp");%>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

String menu = ECRFUserMenuConstants.ADD_EXP_GROUP;

boolean isUpdate = false;

ExperimentalGroup expGroup = null;

long expGroupId = ParamUtil.getLong(renderRequest, ECRFUserExpGroupAttributes.EXP_GROUP_ID, 0);

if(expGroupId > 0) {
	isUpdate = true;
	menu = ECRFUserMenuConstants.UPDATE_EXP_GROUP;
	
	expGroup = ExperimentalGroupLocalServiceUtil.getExperimentalGroup(expGroupId);
}

boolean hasAddPermission = ProjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ADD_EXP_GROUP);
boolean hasUpdatePermission = ProjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.UPDATE_EXP_GROUP);
boolean hasDeletePermission = ProjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DELETE_EXP_GROUP);

%>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_ADD_EXP_GROUP%>" var="addExpGroupURL" >
	<portlet:param name="<%=Constants.CMD%>" value="<%=Constants.ADD%>"/>
</portlet:actionURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_UPDATE_EXP_GROUP%>" var="updateExpGroupURL" >
	<portlet:param name="<%=ECRFUserExpGroupAttributes.EXP_GROUP_ID%>" value="<%=String.valueOf(expGroupId)%>" />
	<portlet:param name="<%=Constants.CMD%>" value="<%=Constants.UPDATE%>"/>
</portlet:actionURL>

<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_EXP_GROUP%>" var="deleteExpGroupURL" >
	<portlet:param name="<%=ECRFUserExpGroupAttributes.EXP_GROUP_ID%>" value="<%=String.valueOf(expGroupId)%>" />
</portlet:actionURL>

<portlet:renderURL var="listExpGroupURL" >
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME%>" value="<%=ECRFUserMVCCommand.RENDER_LIST_EXP_GROUP%>" />
</portlet:renderURL>

<div class="ecrf-user">

	<%@ include file="../sidebar.jspf" %>
	
	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect%>" title="ecrf-user.project.title.add-exp-group" />
		
		<aui:form name="updateExpGroup" action="<%=isUpdate ? updateExpGroupURL : addExpGroupURL%>" autocomplete="off" method="POST">
			<aui:container cssClass="radius-shadow-container">
				
				<c:if test="<%=isUpdate%>">
					<aui:input type="hidden" name="<%=ECRFUserExpGroupAttributes.EXP_GROUP_ID%>" value="<%=expGroupId%>"></aui:input>
				</c:if>
				
				<aui:row>
					<aui:col md="3">
						<aui:field-wrapper
							name="<%=ECRFUserExpGroupAttributes.NAME%>"
							label="ecrf-user.project.exp-group.name"
							required="true">
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="6">
						<aui:input
							autofocus="true"
							name="<%=ECRFUserExpGroupAttributes.NAME%>"
							label=""
							value="<%=Validator.isNull(expGroup) ? StringPool.BLANK : expGroup.getName()%>"
							>
						</aui:input>
					</aui:col>
				</aui:row>
				<aui:row>
					<aui:col md="3">
						<aui:field-wrapper
							name="<%=ECRFUserExpGroupAttributes.ABBREVIATION%>"
							label="ecrf-user.project.exp-group.abbreviation"
							required="true">
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="6">
						<aui:input
							name="<%=ECRFUserExpGroupAttributes.ABBREVIATION%>"
							label=""
							value="<%=Validator.isNull(expGroup) ? StringPool.BLANK : expGroup.getAbbreviation()%>"
							>
						</aui:input>
					</aui:col>
				</aui:row>
				<aui:row>
					<aui:col md="3">
						<aui:field-wrapper
							name="<%=ECRFUserExpGroupAttributes.DESCRIPTION%>"
							label="ecrf-user.project.exp-group.description"
							required="true">
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="6">
						<aui:input
							name="<%=ECRFUserExpGroupAttributes.DESCRIPTION%>"
							label=""
							value="<%=Validator.isNull(expGroup) ? StringPool.BLANK : expGroup.getDescription()%>"
							>
						</aui:input>
					</aui:col>
				</aui:row>
				<aui:row>
					<aui:col md="3">
						<aui:field-wrapper
							name="<%=ECRFUserExpGroupAttributes.TYPE%>"
							label="ecrf-user.project.exp-group.type"
							required="true">
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="6">
						<aui:select
							name="<%=ECRFUserExpGroupAttributes.TYPE%>"
							label=""
						>
							<%
							ExperimentalGroupType[] expGroups = ExperimentalGroupType.values();
							for(int i=0; i<expGroups.length; i++) {
								ExperimentalGroupType rowExpGroup = expGroups[i];
								boolean isSelected = false;
								if(Validator.isNull(expGroup)) {
									isSelected = true;
								} else {
									if(expGroup.getType() == rowExpGroup.getNum()) isSelected = true;
								}
							%>
								<aui:option selected="<%=isSelected %>" value="<%=rowExpGroup.getNum() %>"><%=rowExpGroup.getFullString() %></aui:option>
							<%
							}
							%>
						</aui:select>
					</aui:col>
				</aui:row>			
			</aui:container>
			
			<aui:button-row>
				<c:if test="<%=!isUpdate %>">
					<c:if test="<%=hasAddPermission %>">
					<button id="<portlet:namespace/>add" type="submit" class="dh-icon-button submit-btn add-btn w110 h36 marR8">
						<img class="add-icon" />
						<span><liferay-ui:message key="ecrf-user.button.add" /></span>
					</button>
					</c:if>
				</c:if>
				
				<c:if test="<%=isUpdate %>">
					<c:if test="<%=hasUpdatePermission %>">
					<button id="<portlet:namespace/>update" type="submit" class="dh-icon-button submit-btn update-btn w110 h36 marR8">
						<img class="update-icon" />
						<span><liferay-ui:message key="ecrf-user.button.update" /></span>
					</button>
					</c:if>
				
					<c:if test="<%=hasDeletePermission %>">
					<%
						String title = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-exp-group.title");
						String content = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-exp-group.content");
						String deleteFunctionCall = String.format("deleteConfirm('%s', '%s', '%s' )", title, content, deleteExpGroupURL.toString());
					%>
					<button id="<portlet:namespace/>delete" type="button" class="dh-icon-button submit-btn delete-btn w110 h36 marR8" onclick="<%=deleteFunctionCall %>">
						<img class="delete-icon" />
						<span><liferay-ui:message key="ecrf-user.button.delete" /></span>
					</button>
					</c:if>
				</c:if>
				<button id="<portlet:namespace/>back" type="button" class="dh-icon-button submit-btn back-btn w110 h36 marR8" onclick="location.href='<%=listExpGroupURL%>'">
					<img class="back-icon" />
					<span><liferay-ui:message key="ecrf-user.button.back" /></span>
				</button>
			</aui:button-row>
		</aui:form>
	</div>
</div>
