<%@page import="com.liferay.portal.kernel.util.StringUtil"%>
<%@ include file="../init.jsp" %>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.subject.list_subject_update_jsp");
%>

<%
SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

ArrayList<Subject> subjectList = new ArrayList<Subject>();
subjectList.addAll(SubjectLocalServiceUtil.getSubjectByGroupId(scopeGroupId));

String menu="subject-list-update";

boolean isSearch = ParamUtil.getBoolean(renderRequest, "isSearch", false); 

PortletURL portletURL = null;

portletURL = PortletURLUtil.getCurrent(renderRequest, renderResponse);

if(isSearch) {
	_log.info("search");
		
	portletURL = PortletURLUtil.getCurrent(renderRequest, renderResponse);
	_log.info("portlet url : " + portletURL.toString());
	
	String serialIdKeyword = ParamUtil.getString(renderRequest, ECRFUserSubjectAttributes.SERIAL_ID);
	String nameKeyword = ParamUtil.getString(renderRequest, ECRFUserSubjectAttributes.NAME);
	
	int gender = ParamUtil.getInteger(renderRequest, ECRFUserSubjectAttributes.GENDER, -1); 
	
	Date birthStart = null;
	Date birthEnd = null;
	
	String birthStartStr = ParamUtil.getString(renderRequest, ECRFUserSubjectAttributes.BIRTH_START);	
	if(!birthStartStr.isEmpty()) { birthStart = sdf.parse(birthStartStr); }
	
	String birthEndStr = ParamUtil.getString(renderRequest, ECRFUserSubjectAttributes.BIRTH_END);
	if(!birthEndStr.isEmpty()) { birthEnd = sdf.parse(birthEndStr); }
	
	subjectList = SubjectSearchUtil.search(
			subjectList, serialIdKeyword, nameKeyword, gender, 
			birthStart, birthEnd);
}
%>

<portlet:renderURL var="searchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_SUBJECT %>" />
	<portlet:param name="<%=Constants.CMD %>" value="<%=Constants.UPDATE%>" />
	<portlet:param name="isSearch" value="true" />
</portlet:renderURL>

<portlet:renderURL var="clearSearchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_SUBJECT %>" />	
	<portlet:param name="<%=Constants.CMD %>" value="<%=Constants.UPDATE%>" />
</portlet:renderURL>

<portlet:renderURL var="addSubjectRenderURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_ADD_SUBJECT %>" />
	<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
</portlet:renderURL>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.1/font/bootstrap-icons.css">

<div class="ecrf-user">

	<%@ include file="sidebar.jspf" %>

	<div class="page-content">
		<liferay-ui:header title="Subject List" />
		<!-- search option section -->
		<aui:form action="${searchURL}" name="searchOptionFm" autocomplete="off" cssClass="marBr">
			<aui:container cssClass="radius-shadow-container">
				<aui:row>
					<aui:col md="4">
						<aui:field-wrapper
							name="<%=ECRFUserSubjectAttributes.SERIAL_ID %>"
							label="ecrf-user.subject.serial-id"
							helpMessage="ecrf-user.subject.serial-id.help"
							cssClass="marBrh"
						>
							<aui:input
								type="text"
								name="<%=ECRFUserSubjectAttributes.SERIAL_ID %>"  
								cssClass="form-control"
								label=" "
								></aui:input>
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="4">
						<aui:field-wrapper
							name="<%=ECRFUserSubjectAttributes.NAME %>"
							label="ecrf-user.subject.name"
							helpMessage="ecrf-user.subject.name.help"
							cssClass="marBrh"
						>
							<aui:input
								type="text"
								name="<%=ECRFUserSubjectAttributes.NAME %>" 
								cssClass="form-control" 
								label=" "
								></aui:input>
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="4">
						<aui:field-wrapper
							name="<%=ECRFUserSubjectAttributes.GENDER %>"
							label="ecrf-user.subject.gender"
							helpMessage="ecrf-user.subject.gender.help"
							cssClass="marBrh"
						>
							<aui:fieldset cssClass="radio-one-line radio-align">
								<aui:input 
									type="radio" 
									name="<%=ECRFUserSubjectAttributes.GENDER %>" 
									cssClass="search-input"
									label="ecrf-user.subject.male"  
									value="0" />
								<aui:input 
									type="radio" 
									name="<%=ECRFUserSubjectAttributes.GENDER %>" 
									cssClass="search-input"
									label="ecrf-user.subject.female" 
									value="1" />
							</aui:fieldset>
						</aui:field-wrapper>
					</aui:col>
				</aui:row>
				<aui:row>
					<aui:col md="4">
						<aui:field-wrapper
							name="<%=ECRFUserSubjectAttributes.BIRTH_START %>"
							label="ecrf-user.subject.birth.start"
							helpMessage="ecrf-user.subject.birth.start.help"
							cssClass="marBrh"
						>
							<aui:input 
								name="<%=ECRFUserSubjectAttributes.BIRTH_START %>"
								cssClass="date"
								placeholder="yyyy/mm/dd"
								label="" />
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="4">
						<aui:field-wrapper
							name="<%=ECRFUserSubjectAttributes.BIRTH_END %>"
							label="ecrf-user.subject.birth.end"
							helpMessage="ecrf-user.subject.birth.end.help"
							cssClass="marBrh"
						>
							<aui:input 
								name="<%=ECRFUserSubjectAttributes.BIRTH_END %>"
								cssClass="date"
								placeholder="yyyy/mm/dd"
								label="" />
						</aui:field-wrapper>
					</aui:col>
				</aui:row>								
				<aui:row>
					<aui:col md="12">
						<aui:button-row cssClass="right marVr">
							<button class="icon-button-submit icon-button-submit-search" name="<portlet:namespace/>search">
								<i class="bi bi-search" style="color:white;"></i>
								<span>Search</span>
							</button>
							<a class="icon-button-submit icon-button-submit-clear" href="<%=clearSearchURL %>" name="<portlet:namespace/>clear">
								<i class="bi bi-arrow-clockwise" style="color:white;"></i>							
								<span>Clear</span>
							</a>
						</aui:button-row>
					</aui:col>
				</aui:row>
			</aui:container>
		</aui:form>
		
		<!-- search result section -->
		<liferay-ui:search-container
			iteratorURL="<%=portletURL %>"
			delta="10"
			emptyResultsMessage="subject.no-subjects-were-found"
			emptyResultsMessageCssClass="taglib-empty-result-message-header"
			total="<%=subjectList.size() %>"
			var="searchContainer"
			cssClass="marBr marTrh center-table radius-shadow-container"
			>
		
			<liferay-ui:search-container-results>
			<%
				ArrayList<Subject> sortableSubjects = new ArrayList<Subject>(ListUtil.subList(subjectList, searchContainer.getStart(), searchContainer.getEnd()));
				//sortableSubjects = EmployeeDtlsComparatorUtil.sortEmployeeDtls(sortableSubjects, orderByCol, orderByType);     
			    pageContext.setAttribute("results", sortableSubjects);     
			    pageContext.setAttribute("total", subjectList.size()); 
			%>
			</liferay-ui:search-container-results>
			
			<%
				if(subjectList.size() == 0) {
					searchContainer.setEmptyResultsMessageCssClass("taglib-empty-search-result-message-header");
					searchContainer.setEmptyResultsMessage("subject.no-search-result");
				}
			%>

			<% int count = searchContainer.getStart(); %>
			
			<%
				boolean hasViewPermission = false;			
				boolean hasUpdatePermission = false;
				boolean hasDeletePermission = false;
			%>
			
			<liferay-ui:search-container-row
				className="ecrf.user.model.Subject"
				escapedModel="<%=true %>"
				keyProperty="subjectId"
				modelVar="subject"
			>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.no"
					value="<%=String.valueOf(++count) %>"
				/>
				
				<%
				hasViewPermission = SubjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_SUBJECT);
				%>
				
				<portlet:renderURL var="viewURL">
					<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_SUBJECT%>" />
					<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(subject.getSubjectId()) %>" />
					<portlet:param name="menu" value="subject-list-update" />
					<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
				</portlet:renderURL>
			
				<liferay-ui:search-container-column-text
					href="<%=hasViewPermission ? viewURL.toString() : ""%>"
					name="ecrf-user.list.serial-id"
					value="<%=subject.getSerialId() %>"
				/>
				
				<%
				String subjectName = subject.getName();
				boolean hasViewEncryptPermission = SubjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_ENCRYPT_SUBJECT);
				if(!hasViewEncryptPermission)
					subjectName = ECRFUserUtil.encryptName(subjectName);
				%>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.name"
					value="<%=subjectName %>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.birth"
					value="<%=Validator.isNull(subject.getBirth()) ? "-" : sdf.format(subject.getBirth()) %>"
				/>
				
				<%
					String genderStrKey = "";
					if(Validator.isNull(subject.getGender())) {
						genderStrKey = "-";
					} else {
						if(subject.getGender() == 0) {
							genderStrKey = "ecrf-user.general.male";
						} else {
							genderStrKey = "ecrf-user.general.female";
						}
					}
				%>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.gender"	
				>
					<liferay-ui:message key="<%=genderStrKey %>"></liferay-ui:message>
				</liferay-ui:search-container-column-text>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.create-date"
					value="<%=Validator.isNull(subject.getCreateDate()) ? "-" : sdf.format(subject.getCreateDate()) %>"
				/>
								
				<portlet:renderURL var="updateURL">
					<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_UPDATE_SUBJECT%>" />
					<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(subject.getSubjectId()) %>" />
					<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
				</portlet:renderURL>
				
				<% hasUpdatePermission = SubjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.UPDATE_SUBJECT); %>
								
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.update"
				>	

					<a class="<%= !hasUpdatePermission ? "icon-button icon-button-deactivate" : "icon-button icon-button-update"%>" href="<%=updateURL %>" name="updateSubject" disabled="<%=!hasUpdatePermission ? true : false %>">
						<img src="<%= !hasUpdatePermission ?  renderRequest.getContextPath() + "/btn_img/update_icon_deactivate.png" : renderRequest.getContextPath() + "/btn_img/update_icon.png"%>"/>
						<c:if test="<%=!hasUpdatePermission %>">
							<span>Locked</span>
						</c:if>
						<c:if test="<%=hasUpdatePermission %>">
							<span>Update</span>
						</c:if>			
					</a>

				</liferay-ui:search-container-column-text>
				
				<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_SUBJECT %>" var="deleteSubjectURL">
					<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(subject.getSubjectId()) %>" />
				</liferay-portlet:actionURL>
				
				<% hasDeletePermission = SubjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DELETE_SUBJECT); %>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.delete"
				>

				<%
				String title = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-subject.title");
				String content = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-subject.content");
				String deleteFunctionCall = String.format("deleteConfirm('%s', '%s', '%s', 'large')", title, content, deleteSubjectURL.toString());
				%>
				
					<a class="<%= !hasDeletePermission ? "icon-button icon-button-deactivate" : "icon-button icon-button-delete"%>" onclick="<%=deleteFunctionCall %>" name="deleteSubject" disabled="<%=!hasDeletePermission ? true : false %>">
						<img src="<%= !hasDeletePermission ?  renderRequest.getContextPath() + "/btn_img/delete_icon_deactivate.png" : renderRequest.getContextPath() + "/btn_img/delete_icon.png"%>"/>
						<c:if test="<%=!hasDeletePermission %>">
							<span>Locked</span>
						</c:if>
						<c:if test="<%=hasDeletePermission %>">
							<span>Delete</span>
						</c:if>			
					</a>	
				</liferay-ui:search-container-column-text>
				
			</liferay-ui:search-container-row>

				
			<liferay-ui:search-iterator
				displayStyle="list"
				markupView="lexicon"
				paginate="<%=true %>"
				searchContainer="<%=searchContainer %>"
			/>
		</liferay-ui:search-container>
		
		<c:if test="<%=SubjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ADD_SUBJECT) %>">
			<a class="icon-button icon-button-add" href="<%=addSubjectRenderURL %>" name="addSubject">
				<img src="<%=renderRequest.getContextPath() + "/btn_img/add_icon.png"%>"/>
				<span>Add Subject</span>
			</a>
		</c:if>
		
		<c:if test="<%=SubjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DELETE_ALL_SUBJECT) %>">
			<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_ALL_SUBJECT %>" var="deleteAllSubjectURL">
			</liferay-portlet:actionURL>
			
			<a class="icon-button icon-button-delete" href="<%=deleteAllSubjectURL %>" name="deleteAllSubject">
				<img src="<%=renderRequest.getContextPath() + "/btn_img/delete_icon.png"%>"/>
				<span>Delete All</span>		
			</a>	
		</c:if>
	</div>
</div>

<script>
$(document).ready(function() {
	$("#<portlet:namespace/>birthStart").datetimepicker({
		lang: 'kr',
		changeYear: true,
		changeMonth : true,
		validateOnBlur: false,
		gotoCurrent: true,
		timepicker: false,
		format: 'Y/m/d',
		scrollMonth: false
	});
	$("#<portlet:namespace/>birthStart").mask("0000/00/00");
	
	$("#<portlet:namespace/>birthEnd").datetimepicker({
		lang: 'kr',
		changeYear: true,
		changeMonth : true,
		validateOnBlur: false,
		gotoCurrent: true,
		timepicker: false,
		format: 'Y/m/d',
		scrollMonth: false
	});
	$("#<portlet:namespace/>birthEnd").mask("0000/00/00");
});
</script>