<%@page import="com.liferay.portal.kernel.util.StringUtil"%>
<%@ include file="../init.jsp" %>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.subject.list_subject_update_jsp");
%>

<%
SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

ArrayList<Subject> subjectList = new ArrayList<Subject>();
subjectList.addAll(SubjectLocalServiceUtil.getSubjectByGroupId(scopeGroupId));

String menu = ECRFUserMenuConstants.LIST_SUBJECT;

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
							<button id="<portlet:namespace/>search" type="button" class="br20 dh-icon-button submit-btn search-btn white-text w130 h40 marR8 active">
								<img class="search-icon" />
								<span><liferay-ui:message key="ecrf-user.button.search" /></span>
							</button>
							<button id="<portlet:namespace/>move" name="<portlet:namespace/>move" type="button" class="br20 dh-icon-button submit-btn clear-btn white-text w130 h40 active" onclick="location.href='<%=clearSearchURL %>'">
								<img class="clear-icon" />
								<span><liferay-ui:message key="ecrf-user.button.clear" /></span>
							</button>
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
					<%
					String updateBtnClass = "dh-icon-button w130";
					String updateOnClickStr = "location.href='"+updateURL+"'";
					String updateBtnKey = "ecrf-user.button.update";
					
					if(!hasUpdatePermission) {
						updateBtnClass += " inactive";
						updateOnClickStr = "";
						updateBtnKey = "ecrf-user.button.locked";
					} else {
						updateBtnClass += " update-btn";
					}
					%>
					
					<button name="<portlet:namespace/>updateSubject" type="button" class="<%=updateBtnClass%>" onclick="<%=updateOnClickStr %>" <%=!hasUpdatePermission ? "disabled" : "" %>>
						<img class="update-icon<%=TagAttrUtil.inactive(!hasUpdatePermission, TagAttrUtil.TYPE_ICON) %>" />
						<span><liferay-ui:message key="<%=updateBtnKey %>" /></span>
					</button>

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
								
				String deleteBtnClass = "dh-icon-button w130";
				String deleteBtnKey = "ecrf-user.button.delete";
				
				if(!hasDeletePermission) {
					deleteBtnClass += " inactive";
					deleteFunctionCall = "";
					deleteBtnKey = "ecrf-user.button.locked";
				} else {
					deleteBtnClass += " delete-btn";
					
				}
				%>
				
					<button name="<portlet:namespace/>deleteSubject" type="button" class="<%=deleteBtnClass%>" onclick="<%=deleteFunctionCall %>" <%=!hasDeletePermission ? "disabled" : "" %>>
						<img class="delete-icon<%=TagAttrUtil.inactive(!hasDeletePermission, TagAttrUtil.TYPE_ICON) %>" />
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
		
		<c:if test="<%=SubjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ADD_SUBJECT) %>">
			<button name="<portlet:namespace/>addSubject" type="button" class="dh-icon-button submit-btn add-btn w150 h36 marR8" onclick="location.href='<%=addSubjectRenderURL %>'">
				<img class="add-icon" />
				<span><liferay-ui:message key="ecrf-user.subject.button.add-subject" /></span>
			</button>
		</c:if>
		
		<c:if test="<%=SubjectPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DELETE_ALL_SUBJECT) %>">
			<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_ALL_SUBJECT %>" var="deleteAllSubjectURL">
			</liferay-portlet:actionURL>
			
			<button name="<portlet:namespace/>deleteAllSubject" type="button" class="dh-icon-button submit-btn delete-btn w130 h36" onclick="location.href='<%=deleteAllSubjectURL %>'">
				<img class="delete-icon" />
				<span><liferay-ui:message key="ecrf-user.subject.button.delete-all" /></span>		
			</button>	
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

<aui:script use="aui-base">
A.one('#<portlet:namespace/>search').on('click', function() {
	var isDateValid = dateCheck("birthStart", "birthEnd", '<portlet:namespace/>');
	
	console.log("date valid : " + isDateValid);
	
	if(isDateValid) {
		var form = $('#<portlet:namespace/>searchOptionFm');
		form.submit();
	} else if(!isDateValid) {
		var dialog = new A.Modal({
			headerContent: '<h3><liferay-ui:message key="Date validation"/></h3>',
			bodyContent: '<span style="color:red;"><liferay-ui:message key="Start Date is greater than End Date"/></span>',
			centered: true,
			modal: true,
			height: 200,
			width: 400,
			render: '#body-div',
			zIndex: 1100,
			close: true
		}).render();
	}
});
</aui:script>