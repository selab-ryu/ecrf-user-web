<%@ include file="../init.jsp" %>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.subject.list_subject_jsp");
%>

<%
SimpleDateFormat sdf = new SimpleDateFormat("YYYY/MM/dd");

SubjectLocalService subjectLocalService = (SubjectLocalService)renderRequest.getAttribute(ECRFUserConstants.SUBJECT_LOCAL_SERVICE);

ArrayList<Subject> subjectList = new ArrayList<Subject>();

subjectList.addAll(subjectLocalService.getAllSubject(scopeGroupId));

boolean updatePermission = true;

//check user roles
if(user != null) {
	List<Role> roleList = user.getRoles();
	for(int i=0; i<roleList.size(); i++) {
		Role role = roleList.get(i);
		//_logger.info("user role : " + role.getName());
		if(role.getName().equals("Guest")) updatePermission = false;
	}
}

%>

<portlet:renderURL var="addSubjectURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_ADD_SUBJECT %>" />
	<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
</portlet:renderURL>

<div class="">

	<liferay-ui:header title="Subject List" />

	<div class="">
		<!-- search option section -->
		<aui:form action="" name="searchOptionFm" autocomplete="off">
		</aui:form>
		
		<!-- button section -->
		<aui:button-row>
			<aui:button name="add-subject" value="ecrf-user.subject.button.add-subject" onClick="<%=addSubjectURL.toString() %>" />
		</aui:button-row>
		
		<!-- search result section -->
		<liferay-ui:search-container
			delta="10"
			emptyResultsMessage="subject.no-subjects-were-found"
			emptyResultsMessageCssClass="taglib-empty-result-message-header"
			total="<%=subjectList.size() %>"
			var="searchContainer"
			cssClass="marTrh center-table radius-shadow-container"
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
			
				<portlet:renderURL var="rowURL">
					<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_UPDATE_SUBJECT%>" />
					<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(subject.getSubjectId()) %>" />
					<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
				</portlet:renderURL>
			
				<liferay-ui:search-container-column-text
					href="<%=rowURL.toString() %>"
					name="ecrf-user.list.name"
					value="<%=subject.getName() %>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.serial-id"
					value="<%=subject.getSerialId() %>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.birth"
					value="<%=Validator.isNull(subject.getBirth()) ? "-" : sdf.format(subject.getBirth()) %>"
				/>
												
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.participation-date"
					value="<%=Validator.isNull(subject.getParticipationStartDate()) ? "-" : sdf.format(subject.getParticipationStartDate()) %>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.visit-date"
					value="<%=Validator.isNull(subject.getVisitDate()) ? "-" : sdf.format(subject.getVisitDate()) %>"
				/>
				
				<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_SUBJECT %>" var="deleteSubjectURL">
					<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(subject.getSubjectId()) %>" />
				</liferay-portlet:actionURL>
				
				<liferay-ui:search-container-column-text
					href="<%=deleteSubjectURL.toString() %>"
					name="ecrf-user.list.delete"
					value="Delete"
				/>
			
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