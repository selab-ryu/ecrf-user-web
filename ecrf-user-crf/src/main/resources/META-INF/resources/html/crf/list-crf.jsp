<%@page import="ecrf.user.constants.attribute.ECRFUserSubjectAttributes"%>
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html.crf.list_crf_jsp"); %>

<%
SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

String menu="crf-list";

crfId = 0L;
dataTypeId = 0L;

_log.info("group id : " + scopeGroupId);

ArrayList<CRF> crfList = new ArrayList<CRF>();
crfList.addAll(CRFLocalServiceUtil.getCRFByGroupId(scopeGroupId));

boolean isSearch = ParamUtil.getBoolean(renderRequest, "isSearch", false);

PortletURL portletURL = null;

portletURL = PortletURLUtil.getCurrent(renderRequest, renderResponse);

if(isSearch) {
	SearchUtil searchUtil = new SearchUtil(crfList, locale);
	
	portletURL = PortletURLUtil.getCurrent(renderRequest, renderResponse);
	
	String titleKeyword = ParamUtil.getString(renderRequest, ECRFUserCRFAttributes.CRF_TITLE, StringPool.BLANK);
	int crfStatus = ParamUtil.getInteger(renderRequest, ECRFUserCRFAttributes.CRF_STATUS, -1);
	
	CRFStatus crfStatusKeyword = CRFStatus.valueOf(crfStatus);
	
	Date applyDateStart = null;
	Date applyDateEnd = null;
	
	String applyDateStartStr = ParamUtil.getString(renderRequest, ECRFUserCRFAttributes.APPLY_DATE_START);
	if(Validator.isNotNull(applyDateStartStr)) { applyDateStart = sdf.parse(applyDateStartStr); }
	
	String applyDateEndStr = ParamUtil.getString(renderRequest, ECRFUserCRFAttributes.APPLY_DATE_END);
	if(Validator.isNotNull(applyDateEndStr)) { applyDateEnd = sdf.parse(applyDateEndStr); }
	
	//_log.info(String.valueOf(titleKeyword) + " / " + String.valueOf(crfStatus) + " / " + String.valueOf(applyDateStart) + " / " + String.valueOf(applyDateEnd) );
	
	crfList = searchUtil.search(titleKeyword, crfStatusKeyword, applyDateStart, applyDateEnd);
}
%>

<portlet:renderURL var="searchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF%>"/>
	<portlet:param name="isSearch" value="true" />
</portlet:renderURL>

<portlet:renderURL var="clearSearchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF%>"/>	
</portlet:renderURL>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.1/font/bootstrap-icons.css">
<div class="ecrf-user">
	
	<%@include file="sidebar.jspf" %>
	
	<div class="page-content">
		
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.crf.title.crf-list" />
		
		<aui:form action="${searchURL}" name="searchOptionFm" autocomplete="off" cssClass="marBr">
			<aui:container cssClass="radius-shadow-container">
				<aui:row>
					<aui:col md="6">
						<aui:field-wrapper
							name="<%=ECRFUserCRFAttributes.CRF_TITLE%>"
							label="ecrf-user.crf.crf-title"
							helpMessage="ecrf-user.crf.crf-title.help"
							cssClass="marBrh"
						>
							<aui:input
								type="text"
								name="<%=ECRFUserCRFAttributes.CRF_TITLE%>"
								cssClass="form-control"
								label=" "
								></aui:input>
						</aui:field-wrapper>
					</aui:col>
					
					<aui:col md="3">
						<aui:field-wrapper
							name="<%=ECRFUserCRFAttributes.APPLY_DATE_START%>"
							label="ecrf-user.crf.apply-date.start"
							helpMessage="ecrf-user.crf.apply-date.start.help"
							cssClass="marBrh"
						>
							<aui:input 
								name="<%=ECRFUserCRFAttributes.APPLY_DATE_START%>"
								cssClass="date"
								placeholder="yyyy/mm/dd"
								label="" />
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="3">
						<aui:field-wrapper
							name="<%=ECRFUserCRFAttributes.APPLY_DATE_END%>"
							label="ecrf-user.crf.apply-date.end"
							helpMessage="ecrf-user.crf.apply-date.end.help"
							cssClass="marBrh"
						>
							<aui:input 
								name="<%=ECRFUserCRFAttributes.APPLY_DATE_END%>"
								cssClass="date"
								placeholder="yyyy/mm/dd"
								label="" />
						</aui:field-wrapper>
					</aui:col>
				</aui:row>
				
				<c:if test="false">
				<aui:row>
					<aui:col md="6">
						<aui:field-wrapper
							name="<%=ECRFUserCRFAttributes.CRF_STATUS%>"
							label="ecrf-user.crf.crf-status"
							helpMessage="ecrf-user.crf.crf-status.help"
							cssClass="marBrh"
						>
							<aui:fieldset cssClass="radio-one-line radio-align">
								<aui:input 
									type="radio" 
									name="<%=ECRFUserCRFAttributes.CRF_STATUS%>" 
									cssClass="search-input"
									label="ecrf-user.crf.crf-status.not-published"  
									value="0" />
								<aui:input 
									type="radio" 
									name="<%=ECRFUserCRFAttributes.CRF_STATUS%>" 
									cssClass="search-input"
									label="ecrf-user.crf.crf-status.in-progress" 
									value="1" />
								<aui:input 
									type="radio" 
									name="<%=ECRFUserCRFAttributes.CRF_STATUS%>" 
									cssClass="search-input"
									label="ecrf-user.crf.crf-status.complete" 
									value="2" />
							</aui:fieldset>
						</aui:field-wrapper>
					</aui:col>
				</aui:row>
				</c:if>
				
				<aui:row>
					<aui:col md="12">
						<aui:button-row cssClass="right marVr">

							<button class="dh-icon-button-submit dh-icon-button-submit-search" id="<portlet:namespace/>search">
								<i class="bi bi-search" style="color:white;"></i>
								<span>Search</span>
							</button>
							<a class="dh-icon-button-submit dh-icon-button-submit-clear" href="<%=clearSearchURL %>" id="<portlet:namespace/>clear">
								<i class="bi bi-arrow-clockwise" style="color:white;"></i>
								<span>Clear</span>
							</a>

						</aui:button-row>
					</aui:col>
				</aui:row>
			</aui:container>
		</aui:form>
		
		<liferay-ui:search-container
			delta="10"
			emptyResultsMessage="ecrf-user.crf.no-crfs-were-found"
			emptyResultsMessageCssClass="taglib-empty-result-message-header"
			total="<%=crfList.size() %>"
			var ="searchContainer" 
			cssClass="marTrh center-table radius-shadow-container"
		>
			<liferay-ui:search-container-results
				results="<%=ListUtil.subList(crfList, searchContainer.getStart(), searchContainer.getEnd()) %>"
			/>
			
			<% int count = searchContainer.getStart(); %>
			
			<liferay-ui:search-container-row
				className="ecrf.user.model.CRF"
				keyProperty="crfId"
				modelVar="crf"
				escapedModel="<%=true%>"
			>
				<%
				long rowDataTypeId = crf.getDatatypeId();
				DataType datatype = DataTypeLocalServiceUtil.getDataType(rowDataTypeId);
				%>
								
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.no"
					value="<%=String.valueOf(++count) %>"
				/>
				
				<portlet:renderURL var="viewURL">
					<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_UPDATE_CRF %>" />
					<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crf.getCrfId()) %>" />
					<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(crf.getDatatypeId()) %>" />
					<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
				</portlet:renderURL>
				
				<liferay-ui:search-container-column-text
					
					name="ecrf-user.list.crf-title"
					value="<%=Validator.isNull(datatype) ? "-" : datatype.getDisplayName(locale) %>"
				/>
								
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.crf-version"
					value="<%=datatype.getDataTypeVersion() %>"
				/>
				
				<%
					int crfStatus = crf.getCrfStatus();
					String statusStr = CRFStatus.valueOf(crfStatus).getFull();
				%>
							    
				<%
					int crfSubjectCount = CRFSubjectLocalServiceUtil.countCRFSubjectByCRFId(scopeGroupId, crf.getCrfId());
				%>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.crf-subject-count"
					value="<%=String.valueOf(crfSubjectCount) %>"
				/>
			
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.crf-apply-date"
					value="<%=sdf.format(crf.getApplyDate()) %>"
				/>
				
				<%
					boolean hasCRFPermission = CRFResearcherLocalServiceUtil.isResearcherInCRF(crf.getCrfId(), user.getUserId());
					if(isAdmin) hasCRFPermission = true;
					if(CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ALL_UPDATE_CRF)) hasCRFPermission = true;
					
					boolean hasUpdatePermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.UPDATE_CRF);
					boolean hasDeletePermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DELETE_CRF);
				%>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.crf-info"
				>
					<portlet:renderURL var="updateCRFURL">
						<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_UPDATE_CRF %>" />
						<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crf.getCrfId()) %>" />
						<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
					</portlet:renderURL>
					
					<a class="<%= !(hasCRFPermission && hasUpdatePermission) ? "dh-icon-button dh-icon-button-deactivate" : "dh-icon-button dh-icon-button-update"%>" href="<%= !(hasCRFPermission && hasUpdatePermission) ? "" : updateCRFURL %>" name="updateCRF" disabled="<%=(hasCRFPermission && hasUpdatePermission) ? false : true %>">
						<img src='<%= !(hasCRFPermission && hasUpdatePermission) ?  renderRequest.getContextPath() + "/btn_img/update_icon.png" : renderRequest.getContextPath() + "/btn_img/update_icon.png"%>'/>
						<c:if test="<%=!(hasCRFPermission && hasUpdatePermission) %>">
							<span>Locked</span>
						</c:if>
						<c:if test="<%=(hasCRFPermission && hasUpdatePermission) %>">
							<span>CRF Info</span>
						</c:if>			
					</a>
 				</liferay-ui:search-container-column-text>
				
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.crf-builder"
				>
					<portlet:renderURL var="updateCRFFormURL">
						<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_MANAGE_FORM %>" />
						<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crf.getCrfId()) %>" />
						<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
					</portlet:renderURL>
					
					<a class="<%= !(hasCRFPermission && hasUpdatePermission) ? "dh-icon-button dh-icon-button-deactivate" : "dh-icon-button dh-icon-button-form"%>" href="<%=!(hasCRFPermission && hasUpdatePermission) ? "" : updateCRFFormURL %>" name="crfForm" disabled="<%=(hasCRFPermission && hasUpdatePermission) ? false : true %>">
						<img src="<%= !(hasCRFPermission && hasUpdatePermission) ?  renderRequest.getContextPath() + "/btn_img/crf_form_icon.png" : renderRequest.getContextPath() + "/btn_img/crf_form_icon.png"%>"/>
						<c:if test="<%=!(hasCRFPermission && hasUpdatePermission) %>">
							<span>Locked</span>
						</c:if>
						<c:if test="<%=(hasCRFPermission && hasUpdatePermission) %>">
							<span>CRF Builder</span>
						</c:if>			
					</a>
 				</liferay-ui:search-container-column-text>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.crf-data"
				>
					<portlet:renderURL var="updateCRFDataURL">
						<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_DATA %>" />
						<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crf.getCrfId()) %>" />
						<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
					</portlet:renderURL>
					
					<a class="<%= !(hasCRFPermission && hasUpdatePermission) ? "dh-icon-button dh-icon-button-deactivate" : "dh-icon-button dh-icon-button-audit"%>" href="<%=!(hasCRFPermission && hasUpdatePermission) ? "" : updateCRFDataURL %>" name="crfData" <%=(hasCRFPermission && hasUpdatePermission) ? "" : "disabled" %> >
						<img src="<%= !(hasCRFPermission && hasUpdatePermission) ?  renderRequest.getContextPath() + "/btn_img/crf_data_icon.png" : renderRequest.getContextPath() + "/btn_img/crf_data_icon.png"%>"/>
						<c:if test="<%=!(hasCRFPermission && hasUpdatePermission) %>">
							<span>Locked</span>
						</c:if>
						<c:if test="<%=(hasCRFPermission && hasUpdatePermission) %>">
							<span>CRF Data</span>
						</c:if>			
					</a>
 				</liferay-ui:search-container-column-text>
 				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.crf-query"
				>
					<portlet:renderURL var="updateCRFQueryURL">
						<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_QUERY %>" />
						<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crf.getCrfId()) %>" />
						<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
					</portlet:renderURL>
					
					<a class="<%= !(hasCRFPermission && hasUpdatePermission) ? "dh-icon-button dh-icon-button-deactivate" : "dh-icon-button dh-icon-button-query"%>" href="<%=!(hasCRFPermission && hasUpdatePermission) ? "" : updateCRFQueryURL %>" name="crfQuery" <%=(hasCRFPermission && hasUpdatePermission) ? "" : "disabled" %> >
						<img src="<%= !(hasCRFPermission && hasUpdatePermission) ?  renderRequest.getContextPath() + "/btn_img/crf_query_icon.png" : renderRequest.getContextPath() + "/btn_img/crf_query_icon.png"%>"/>
						<c:if test="<%=!(hasCRFPermission && hasUpdatePermission) %>">
							<span>Locked</span>
						</c:if>
						<c:if test="<%=(hasCRFPermission && hasUpdatePermission) %>">
							<span>CRF Query</span>
						</c:if>			
					</a>
 				</liferay-ui:search-container-column-text>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.crf-delete"
				>
					<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_CRF %>" var="deleteCRFURL">
						<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crf.getCrfId()) %>" />
					</portlet:actionURL>
					
					<%
						String title = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-crf.title");
						String content = LanguageUtil.get(locale, "ecrf-user.message.confirm-delete-crf.content");
						String deleteFunctionCall = String.format("deleteConfirm('%s', '%s', '%s', 'large')", title, content, deleteCRFURL.toString());
					%>
					
					
					<a class="<%= !(hasCRFPermission && hasUpdatePermission) ? "dh-icon-button dh-icon-button-deactivate" : "dh-icon-button dh-icon-button-delete"%>" onClick="<%=!(hasCRFPermission && hasUpdatePermission) ? "" : deleteFunctionCall %>" name="delete" disabled="<%=(hasCRFPermission && hasUpdatePermission) ? false : true %>">
						<img src="<%= !(hasCRFPermission && hasUpdatePermission) ?  renderRequest.getContextPath() + "/btn_img/delete_icon.png" : renderRequest.getContextPath() + "/btn_img/delete_icon.png"%>"/>
						<c:if test="<%=!(hasCRFPermission && hasUpdatePermission) %>">
							<span>Locked</span>
						</c:if>
						<c:if test="<%=(hasCRFPermission && hasUpdatePermission) %>">
							<span>CRF Delete</span>
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
	</div>
</div>

<script>
$(document).ready(function() {
	$("#<portlet:namespace/>applyDateStart").datetimepicker({
		lang: 'kr',
		changeYear: true,
		changeMonth : true,
		validateOnBlur: false,
		gotoCurrent: true,
		timepicker: false,
		format: 'Y/m/d',
		scrollMonth: false
	});
	$("#<portlet:namespace/>applyDateStart").mask("0000/00/00");
	
	$("#<portlet:namespace/>applyDateEnd").datetimepicker({
		lang: 'kr',
		changeYear: true,
		changeMonth : true,
		validateOnBlur: false,
		gotoCurrent: true,
		timepicker: false,
		format: 'Y/m/d',
		scrollMonth: false
	});
	$("#<portlet:namespace/>applyDateEnd").mask("0000/00/00");	
});
</script>

<aui:script use="aui-base">
A.one('#<portlet:namespace/>search').on('click',function() {
	var isDateValid = dateCheck("applyDateStart", "applyDateEnd", '<portlet:namespace/>');
	
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