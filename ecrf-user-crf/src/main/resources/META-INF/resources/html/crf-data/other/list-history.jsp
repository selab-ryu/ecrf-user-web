<%@page import="ecrf.user.constants.attribute.ECRFUserAttributes"%>
<%@ include file="../../init.jsp" %>

<%! private Log _log = LogFactoryUtil.getLog("html/crf-data/other/list-history.jsp"); %>

<%
SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

String menu="crf-data-history";

ArrayList<CRFHistory> wholeHistoryList = new ArrayList<CRFHistory>();

if(dataTypeId > 0){
	wholeHistoryList.addAll(CRFHistoryLocalServiceUtil.getCRFHistoryByG_C(scopeGroupId, crfId));
}

int historyCount = wholeHistoryList.size();

if(historyCount == 0) {
	_log.info("0 history");
}

boolean modifiedDateStartValid = false;
boolean modifiedDateEndValid = false;

boolean isSearch = ParamUtil.getBoolean(renderRequest, "isSearch", false);

PortletURL portletURL = null;

if(isSearch) {
	// DO SEARCH
	HistorySearch historySearch = new HistorySearch();
	
	portletURL = PortletURLUtil.getCurrent(renderRequest, renderResponse);
	
	String serialIdKeyword = ParamUtil.getString(renderRequest, ECRFUserCRFDataAttributes.SERIAL_ID, StringPool.BLANK); 
	String nameKeyword = ParamUtil.getString(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_NAME, StringPool.BLANK);
	String crfItemNameKeyword = ParamUtil.getString(renderRequest, ECRFUserCRFDataAttributes.DISPLAY_NAME, StringPool.BLANK);
	int actionType = ParamUtil.getInteger(renderRequest, ECRFUserCRFDataAttributes.ACTION_TYPE, 0);
	String modifiedUserName = ParamUtil.getString(renderRequest, ECRFUserAttributes.USER_NAME);
	
	Date modifiedDateStart = null;
	Date modifiedDateEnd = null;
	
	String modifiedDateStartStr = ParamUtil.getString(renderRequest, ECRFUserAttributes.MODIFIED_DATE_START);	
	if(!modifiedDateStartStr.isEmpty()) { modifiedDateStart = sdf.parse(modifiedDateStartStr); }
	
	String modifiedDateEndStr = ParamUtil.getString(renderRequest, ECRFUserAttributes.MODIFIED_DATE_END);
	if(!modifiedDateEndStr.isEmpty()) { modifiedDateEnd = sdf.parse(modifiedDateEndStr); }
	
	wholeHistoryList = historySearch.search(
			wholeHistoryList,
			serialIdKeyword, nameKeyword, crfItemNameKeyword,
			actionType, modifiedUserName,
			modifiedDateStart, modifiedDateEnd
		);
}

%>

<portlet:renderURL var="searchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_DATA_HISTORY %>"/>
	<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
	<portlet:param name="isSearch" value="true" />
</portlet:renderURL>

<portlet:renderURL var="clearSearchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_DATA_HISTORY %>"/>
	<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
</portlet:renderURL>

<div class="ecrf-user-crf-data ecrf-user">
	<%@ include file="../other/sidebar.jspf" %>
	
	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.crf-data.title.data-history-list" />
	
		<aui:form action="${searchURL}" name="searchOptionFm" autocomplete="off" cssClass="marBr">
			<aui:container cssClass="radius-shadow-container">
				<aui:row>
					<aui:col md="4">
						<aui:field-wrapper
							name="<%=ECRFUserCRFDataAttributes.SERIAL_ID %>"
							label="ecrf-user.subject.serial-id"
							helpMessage="ecrf-user.subject.serial-id.help"
							cssClass="marBrh"
						>
							<aui:input
								type="text"
								name="<%=ECRFUserCRFDataAttributes.SERIAL_ID %>"
								cssClass="form-control"
								label=" "
								></aui:input>
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="4">
						<aui:field-wrapper
							name="<%=ECRFUserCRFDataAttributes.SUBJECT_NAME %>"
							label="ecrf-user.subject.name"
							helpMessage="ecrf-user.subject.name.help"
							cssClass="marBrh"
						>
							<aui:input
								type="text"
								name="<%=ECRFUserCRFDataAttributes.SUBJECT_NAME %>" 
								cssClass="form-control"
								label=" "
								></aui:input>
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="4">
						<aui:field-wrapper
							name="<%=ECRFUserCRFDataAttributes.DISPLAY_NAME %>"
							label="ecrf-user.crf-data.display-name"
							helpMessage="ecrf-user.crf-data.display-name.help"
							cssClass="marBrh"
						>
							<aui:input
								type="text"
								name="<%=ECRFUserCRFDataAttributes.DISPLAY_NAME %>" 
								cssClass="form-control" 
								label=" "
								></aui:input>
						</aui:field-wrapper>
					</aui:col>
				</aui:row>
				
				<aui:row>
					<aui:col md="3">
						<aui:field-wrapper
							name="<%=ECRFUserCRFDataAttributes.ACTION_TYPE %>"
							label="ecrf-user.crf-data.action-type"
							helpMessage="ecrf-user.crf-data.action-type.help"
							cssClass="marBrh"
						>
							<aui:fieldset cssClass="">
								<aui:input
									type="radio" 
									name="<%=ECRFUserCRFDataAttributes.ACTION_TYPE %>" 
									value="0" 
									cssClass="search-input" 
									label="ecrf-user.crf-data.action-type.add" >
								</aui:input>
								<aui:input 
									type="radio" 
									name="<%=ECRFUserCRFDataAttributes.ACTION_TYPE %>" 
									value="1" 
									cssClass="search-input" 
									label="ecrf-user.crf-data.action-type.update" >
								</aui:input>
								<aui:input 
									type="radio" 
									name="<%=ECRFUserCRFDataAttributes.ACTION_TYPE %>" 
									value="2" 
									cssClass="search-input" 
									label="ecrf-user.crf-data.action-type.delete" >
								</aui:input>
							</aui:fieldset>
							
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="3">
						<aui:field-wrapper
							name="<%=ECRFUserAttributes.USER_NAME %>"
							label="ecrf-user.general.update-user-name"
							helpMessage="ecrf-user.general.update-user-name.help"
							cssClass="marBrh"
						>
							<aui:input
								type="text"
								name="<%=ECRFUserAttributes.USER_NAME %>" 
								cssClass="form-control" 
								label=" "
								></aui:input>
						</aui:field-wrapper>
					</aui:col>
					
					<aui:col md="3">
						<aui:field-wrapper
							name="<%=ECRFUserAttributes.MODIFIED_DATE_START %>" 
							label="ecrf-user.general.modified-date.start"
							helpMessage="ecrf-user.general.modified-date.start.help"
							cssClass="marBrh"
						>
							<aui:input 
								name="<%=ECRFUserAttributes.MODIFIED_DATE_START %>"
								cssClass="date"
								placeholder="yyyy/mm/dd"
								label="" />
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="3">
						<aui:field-wrapper
							name="<%=ECRFUserAttributes.MODIFIED_DATE_END %>" 
							label="ecrf-user.general.modified-date.end"
							helpMessage="ecrf-user.general.modified-date.end.help"
							cssClass="marBrh"
						>
							<aui:input 
								name="<%=ECRFUserAttributes.MODIFIED_DATE_END %>"
								cssClass="date"
								placeholder="yyyy/mm/dd"
								label="" />
						</aui:field-wrapper>
					</aui:col>
				</aui:row>
				
				<aui:row>
					<aui:col md="12">
						<aui:button-row cssClass="right marVr">
							<aui:button name="search" cssClass="add-btn medium-btn radius-btn"  type="submit" value="ecrf-user.button.search"></aui:button>
							<aui:button name="clear" cssClass="reset-btn medium-btn radius-btn" type="button" value="ecrf-user.button.clear" onClick="<%=clearSearchURL %>"></aui:button>
						</aui:button-row>
					</aui:col>
				</aui:row>
			</aui:container>
		</aui:form>
		 
		 <!-- search result -->
		<liferay-ui:search-container
			iteratorURL="<%=portletURL %>"
			delta="10"
			emptyResultsMessage="subject.no-subjects-were-found"
			emptyResultsMessageCssClass="taglib-empty-result-message-header"
			total="<%=wholeHistoryList.size() %>"
			var="searchContainer"
			cssClass="marTrh center-table radius-shadow-container"
			>
			
			<liferay-ui:search-container-results
				results="<%=ListUtil.subList(wholeHistoryList, searchContainer.getStart(), searchContainer.getEnd()) %>" /> 
			
			<%
				if(wholeHistoryList.size() == 0) {
					searchContainer.setEmptyResultsMessageCssClass("taglib-empty-search-result-message-header");
					searchContainer.setEmptyResultsMessage("subject.no-search-result");
				}
			%>
	
			<% int count = searchContainer.getStart(); %>
			
			<liferay-ui:search-container-row
				className="ecrf.user.model.CRFHistory"
				escapedModel="<%=true %>"
				keyProperty="historyId"
				modelVar="history"
			>
			
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.no"
					value="<%=String.valueOf(++count) %>"
				/>
					
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.serial-id"
					value="<%=history.getSerialId()%>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.subject-name"
					value="<%=history.getSubjectName()%>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.crf-data.previous-version"
					value="<%=Validator.isNull(history.getPreviousHistoryVersion()) ? "" : history.getPreviousHistoryVersion()%>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.crf-data.current-version"
					value="<%=Validator.isNull(history.getHistoryVersion()) ? "" : history.getHistoryVersion()%>"
				/>				
				
				<%
				/// TODO: change to use language key
				String actionTypeStr = "";
				switch(history.getActionType()){
					case 0:
						actionTypeStr = "add";
						break;
					case 1:
						actionTypeStr = "update";
						break;
					case 2:
						actionTypeStr = "delete";
						break;
					default:
						actionTypeStr = "error";
				}
				%>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.crf-data.action-type"
					value="<%=actionTypeStr%>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.general.update-user-name"
					value="<%=history.getUserName()%>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.modified-date"
					value="<%=Validator.isNull(history.getModifiedDate()) ? "-" : sdf.format(history.getModifiedDate()) %>"
				/>
				
				<portlet:renderURL var="viewHistoryURL">
					<portlet:param name="<%=ECRFUserCRFDataAttributes.HISTORY_ID %>" value="<%=String.valueOf(history.getHistoryId()) %>" />
					<portlet:param name="<%=ECRFUserCRFDataAttributes.SUBJECT_ID %>" value="<%=String.valueOf(history.getSubjectId()) %>" />
					<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(history.getCrfId()) %>" />			
					<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME%>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_CRF_DATA_HISTORY%>" />
					<portlet:param name="<%=WebKeys.REDIRECT%>" value="<%=Validator.isNull(portletURL) ? currentURL : portletURL.toString() %>" />
				</portlet:renderURL>
				
				<%
					boolean hasViewHistoryPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_CRF_HISTORY);
				%>
				
				<liferay-ui:search-container-column-text 
					name="ecrf-user.list.view"
					cssClass="min-width-80"
				>
					<aui:button name="view" type="button" value="ecrf-user.button.view" cssClass="edit-btn small-btn" onClick="<%=viewHistoryURL %>" disabled="<%=hasViewHistoryPermission ? false : true %>"></aui:button>
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

<script>
$(document).ready(function() {
	$("#<portlet:namespace/>modifiedDateStart").datetimepicker({
		lang: 'kr',
		changeYear: true,
		changeMonth : true,
		validateOnBlur: false,
		gotoCurrent: true,
		timepicker: false,
		format: 'Y/m/d',
		scrollMonth: false
	});
	$("#<portlet:namespace/>modifiedDateStart").mask("0000/00/00");
	
	$("#<portlet:namespace/>modifiedDateEnd").datetimepicker({
		lang: 'kr',
		changeYear: true,
		changeMonth : true,
		validateOnBlur: false,
		gotoCurrent: true,
		timepicker: false,
		format: 'Y/m/d',
		scrollMonth: false
	});
	$("#<portlet:namespace/>modifiedDateEnd").mask("0000/00/00");
});
</script>

<aui:script use="aui-base">
A.one('#<portlet:namespace/>search').on('click', function() {
	var isModifiedDateValid = dateCheck("modifiedDateStart", "modifiedDateEnd", '<portlet:namespace/>');
	
	alert(isModifiedDateValid);
	
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
	});
	
	if(isModifiedDateValid) {
		var form = $('#<portlet:namespace/>searchOptionFm');
		form.submit();
	} else if(!isModifiedDateValid) {
		dialog.render();
	}
});
</aui:script>