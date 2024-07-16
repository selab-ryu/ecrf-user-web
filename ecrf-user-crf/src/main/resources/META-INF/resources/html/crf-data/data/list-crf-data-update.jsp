<%@page import="com.liferay.portal.kernel.portlet.LiferayPortletURL"%>
<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html.crf-data.data.list_crf_data_update_jsp"); %>

<%
SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

ArrayList<CRFSubject> crfSubjectList = new ArrayList<>();
crfSubjectList.addAll(CRFSubjectLocalServiceUtil.getCRFSubjectByCRFId(scopeGroupId, crfId));

long[] subjectIds = ECRFUserUtil.getSubjectIdFromCRFSubject(crfSubjectList);
ArrayList<Subject> subjectList = new ArrayList<Subject>();
subjectList.addAll(SubjectLocalServiceUtil.getSubjectByIds(scopeGroupId, subjectIds));

String menu="crf-data-list";

boolean isSearch = ParamUtil.getBoolean(renderRequest, "isSearch", false);

PortletURL portletURL = null;

portletURL = PortletURLUtil.getCurrent(renderRequest, renderResponse);
_log.info("portletURL : " + portletURL);

boolean isUpdate = false;
CRF crf = null;
DataType dataType = null;

_log.info("crf id : " + crfId);

if(crfId > 0) {
	crf = CRFLocalServiceUtil.getCRF(crfId);
	isUpdate = true;	
}

if(isUpdate) {
	dataTypeId = crf.getDatatypeId();
	
	if(dataTypeId > 0) {
		_log.info("dataType id : " + dataTypeId);
		dataType = DataTypeLocalServiceUtil.getDataType(dataTypeId);
	}
}

if(isSearch) {
	CRFDataSearchUtil searchUtil = new CRFDataSearchUtil();
		
	String serialIdKeyword = ParamUtil.getString(renderRequest, ECRFUserSubjectAttributes.SERIAL_ID, StringPool.BLANK);  
	String nameKeyword = ParamUtil.getString(renderRequest, ECRFUserSubjectAttributes.NAME, StringPool.BLANK);

	int gender = ParamUtil.getInteger(renderRequest, ECRFUserSubjectAttributes.GENDER, -1);
	
	Date birthStart = null;
	Date birthEnd = null;
	
	String birthStartStr = ParamUtil.getString(renderRequest, ECRFUserSubjectAttributes.BIRTH_START);	
	if(!birthStartStr.isEmpty()) { birthStart = sdf.parse(birthStartStr); }
	
	String birthEndStr = ParamUtil.getString(renderRequest, ECRFUserSubjectAttributes.BIRTH_END);
	if(!birthEndStr.isEmpty()) { birthEnd = sdf.parse(birthEndStr); }

	subjectList = searchUtil.search(subjectList, serialIdKeyword, nameKeyword, gender, birthStart, birthEnd);
}

String progressPercentage = "0%";

LiferayPortletURL baseURL = PortletURLFactoryUtil.create(request, themeDisplay.getPortletDisplay().getId(), themeDisplay.getPlid(), PortletRequest.RENDER_PHASE);
_log.info("url : " + baseURL.toString());

%>

<portlet:renderURL var="searchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_DATA%>"/>
	<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
	<portlet:param name="isSearch" value="true" />
</portlet:renderURL>

<portlet:renderURL var="clearSearchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_DATA%>"/>
	<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
</portlet:renderURL>

<div class="ecrf-user-crf-data ecrf-user">
	<%@ include file="../other/sidebar.jspf" %>
	
	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.crf-data.title.crf-data-list" />
		
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
					<aui:col md="3">
						<aui:field-wrapper
							name="<%=ECRFUserSubjectAttributes.BIRTH_START %>"
							label="ecrf-user.subject.birth.start"
							helpMessage="ecrf-user.subject.birth-start.help"
							cssClass="marBrh"
						>
							<aui:input 
								name="<%=ECRFUserSubjectAttributes.BIRTH_START %>"
								cssClass="date"
								placeholder="yyyy/mm/dd"
								label="" />
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="3">
						<aui:field-wrapper
							name="<%=ECRFUserSubjectAttributes.BIRTH_END %>"
							label="ecrf-user.subject.birth.end"
							helpMessage="ecrf-user.subject.birth-end.help"
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
							<aui:button name="search" cssClass="add-btn medium-btn radius-btn"  type="button" value="ecrf-user.button.search"></aui:button>
							<aui:button name="clear" cssClass="reset-btn medium-btn radius-btn" type="button" value="ecrf-user.button.clear" onClick="<%=clearSearchURL %>"></aui:button>
						</aui:button-row>
					</aui:col>
				</aui:row>
			</aui:container>
		</aui:form>
		
		<liferay-ui:search-container
			iteratorURL="<%=portletURL %>"
			delta="10"
			emptyResultsMessage="subject.no-subjects-were-found"
			emptyResultsMessageCssClass="taglib-empty-result-message-header"
			total="<%=subjectList.size() %>"
			var="searchContainer2"
			cssClass="marTrh center-table radius-shadow-container"
			>
			
			<liferay-ui:search-container-results
				results="<%=ListUtil.subList(subjectList, searchContainer2.getStart(), searchContainer2.getEnd()) %>" /> 
			
			<%
				if(subjectList.size() == 0) {
					searchContainer2.setEmptyResultsMessageCssClass("taglib-empty-search-result-message-header");
					searchContainer2.setEmptyResultsMessage("subject.no-search-result");
				}
			%>
			
			<% int count = searchContainer2.getStart(); %>
			
			<liferay-ui:search-container-row
				className="ecrf.user.model.Subject"
				escapedModel="<%=true %>"
				keyProperty="subjectId"
				modelVar="rowSubject"
			>
			
			<liferay-ui:search-container-column-text
				name="ecrf-user.list.no"
				value="<%=String.valueOf(++count) %>"
			/>
			
			<% 
				long rowSubjectId = rowSubject.getSubjectId();
				//_log.info("subject id : " + rowSubjectId); 
			%>

			<%
				boolean hasCRF = false;
				int crfDataCount = LinkCRFLocalServiceUtil.countLinkCRFByG_S_C(scopeGroupId, rowSubjectId, crfId);
				if(crfDataCount > 0) hasCRF = true;
			%>
			
			<%
				String progressBarCss = "progressBar";
				boolean isWord = false;
				
				String progressSrc = renderRequest.getContextPath() + "/img/empty_progress.png";
				
				if(hasCRF){
					List<LinkCRF> linkList = LinkCRFLocalServiceUtil.getLinkCRFByG_S_C(scopeGroupId, rowSubjectId, crfId);
					if(linkList.size() > 0){
						LinkCRF link = linkList.get(linkList.size() - 1);
						String answer = DataTypeLocalServiceUtil.getStructuredData(link.getStructuredDataId());
						JSONObject answerObj = JSONFactoryUtil.createJSONObject(answer);
						
						if(Validator.isNotNull(answerObj)){
							int notAnswerCount = 0;
							Iterator<String> keys = answerObj.keys();
							while(keys.hasNext()){
								String key = keys.next();
								if(answerObj.getString(key).equals("-1") || answerObj.getString(key).equals("") || answerObj.getString(key).equals("[]")){
									notAnswerCount++;
								}
							}
							CRFGroupCaculation groupApi = new CRFGroupCaculation();
							long rowDataTypeId = CRFLocalServiceUtil.getDataTypeId(link.getCrfId());
							int totalLength = groupApi.getTotalLength(rowDataTypeId);
							if(totalLength > 0){
								int answers = answerObj.length() - notAnswerCount;
								int percent = Math.round(answers * 100 / totalLength);
								progressPercentage = String.valueOf(percent) + "%";
								if(!isWord){
									progressSrc = renderRequest.getContextPath() + "/img/empty_progress.png";
									if(percent >= 100){
										progressSrc = renderRequest.getContextPath()+"/img/complete_progress.png";
										if(CRFAutoqueryLocalServiceUtil.countQueryBySdId(link.getStructuredDataId()) > 0){
											int hasQuery = 0;
											List<CRFAutoquery> queryList = CRFAutoqueryLocalServiceUtil.getQueryBySId(rowSubjectId);
											for(int i = 0; i < queryList.size(); i++){
												CRFAutoquery query = queryList.get(i);
												if(query.getQueryComfirm() != 2){
													hasQuery = 1;
													break;
												}
											}
											if(hasQuery == 1){
												progressSrc = renderRequest.getContextPath()+"/img/complete_autoqueryerror.png";
											}
										}
									}
									else {
										progressSrc = renderRequest.getContextPath()+"/img/incomplete_progress.png";
										if(CRFAutoqueryLocalServiceUtil.countQueryBySdId(link.getStructuredDataId()) > 0){
											int hasQuery = 0;
											List<CRFAutoquery> queryList = CRFAutoqueryLocalServiceUtil.getQueryBySId(rowSubjectId);
											for(int i = 0; i < queryList.size(); i++){
												CRFAutoquery query = queryList.get(i);
												if(query.getQueryComfirm() != 2){
													hasQuery = 1;
													break;
												}
											}
											if(hasQuery == 1){
												progressSrc = renderRequest.getContextPath()+"/img/incomplete_autoqueryerror.png";
											}
										}
									}
								}else{
									progressSrc = renderRequest.getContextPath() + "/img/empty_progress_word.png";
									if(percent >= 100){
										progressSrc = renderRequest.getContextPath()+"/img/complete_progress_word.png";
									}
									else {
										progressSrc = renderRequest.getContextPath()+"/img/incomplete_progress_word.png";
									}
								}								
							}
						}
					}
				}
				
			%>
			
			

			<liferay-ui:search-container-column-text
				name="ecrf-user.list.serial-id"
			>
				<p style="text-align: center; background-image: linear-gradient(to right, #11aaff <%=progressPercentage%>, #aaa 0%); margin-bottom: 0px; padding: 4px;"><%=String.valueOf(rowSubject.getSerialId()) %><liferay-ui:icon icon="info-sign" message="<%=progressPercentage%>" /></p>
			</liferay-ui:search-container-column-text>
			
			<portlet:renderURL var="viewURL">
				<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_CRF_DATA%>" />
				<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
				<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(rowSubjectId) %>" />
				<portlet:param name="menu" value="crf-data-list-update" />
				<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
			</portlet:renderURL>
			<% 
				String name = ECRFUserUtil.anonymousName(rowSubject.getName());
				if(crfDataCount > 1){
					name = name + " [" + crfDataCount  + "]";
				}
			%>
			<liferay-ui:search-container-column-text
				cssClass="min-width-80"
				name="ecrf-user.subject.name"
				value="<%=Validator.isNull(rowSubject.getName()) ? "-" : name%>"
			/>
			
			<%
				String genderStrKey = "";
				if(Validator.isNull(rowSubject.getGender())) {
					genderStrKey = "-";
				} else {
					if(rowSubject.getGender() == 0) {
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
				name="ecrf-user.list.birth"
				value="<%=Validator.isNull(rowSubject.getBirth()) ? "-" : sdf.format(rowSubject.getBirth()) %>"
			/>
			
			<liferay-ui:search-container-column-text
				name="ecrf-user.list.progress"
			>
				<img src="<%= progressSrc%>" width="50%" height="auto" style="min-width:60px;"/>			
			</liferay-ui:search-container-column-text>	
			<%
				boolean updateLock = CRFSubjectLocalServiceUtil.getUpdateLockByC_S(crfId, rowSubjectId);
				//_log.info(rowSubject.getSerialId() + " update lock : " + updateLock);
				
				String lockBtnKey = "";
				String lockClass = "";
				
				if(updateLock) {
					lockBtnKey = "ecrf-user.button.db-unlock";
					lockClass = "small-btn none-btn";
				} else {
					lockBtnKey = "ecrf-user.button.db-lock";
					lockClass = "small-btn emr-btn";
				}
			%>
			
			<!-- DB Lock -->
			<liferay-ui:search-container-column-text
				name="ecrf-user.list.db-lock"
				cssClass="min-width-80"
			>
			
			<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_CHANGE_UPDATE_LOCK %>" var="changeUpdateLock">
				<portlet:param name="<%=ECRFUserWebKeys.LIST_PATH %>" value="<%=ECRFUserJspPaths.JSP_LIST_CRF_DATA_UPDATE %>" />
				<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
				<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(rowSubjectId) %>" />
			</portlet:actionURL>
			
			<aui:button name="dbLock" type="button" value="<%=lockBtnKey%>" cssClass="<%=lockClass %>" onClick="<%=changeUpdateLock %>" ></aui:button>
			</liferay-ui:search-container-column-text>
			
			<!-- DB Lock -->
						
			<!-- Data Update -->
			<%
				String CRFUpdateBtnClass = "";
				if(hasCRF){
					CRFUpdateBtnClass = "ci-btn small-btn";
				}else{
					CRFUpdateBtnClass = "none-btn small-btn";
				}
				
				if(updateLock) {
					CRFUpdateBtnClass = "none-btn small-btn";
				}
			%>
			
			<liferay-ui:search-container-column-text 
				name="ecrf-user.list.crf-data"
				cssClass="min-width-80"
			>
			
			<%
				String updateFunctionCallStr = String.format("openMultiCRFDialog(%d, %d, %d, '%s', '%s')", rowSubjectId, crfId, 0, themeDisplay.getPortletDisplay().getId(), baseURL.toString());
			%>
			
				<aui:button name="updateCRF" type="button" value="<%=hasCRF ? "ecrf-user.button.update" : "ecrf-user.button.add" %>" cssClass="<%=CRFUpdateBtnClass %>" onClick="<%=updateFunctionCallStr%>" disabled="<%=updateLock ? true : false %>"></aui:button>
				
			</liferay-ui:search-container-column-text>
			
			<%
				String auditBtnClass = "";
				if(hasCRF){
					auditBtnClass = "history-btn small-btn";
				}else{
					auditBtnClass = "none-btn small-btn";
				}
			
				String auditFunctionCallStr = String.format("openMultiCRFDialog(%d, %d, %d, '%s', '%s')", rowSubjectId, crfId, 1, themeDisplay.getPortletDisplay().getId(), baseURL.toString());
				
				boolean hasViewAuditPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_AUDIT);
				boolean auditDisable = true;
				if(hasViewAuditPermission && hasCRF) auditDisable = false;  
			%>
			
			<!-- Audit trail button -->
			<liferay-ui:search-container-column-text 
				name="ecrf-user.list.audit-trail"
				cssClass="min-width-80"
			>
				<aui:button name="auditCRF" type="button" value="<%=updateLock ? "ecrf-user.button.view" : "ecrf-user.button.audit-trail" %>" cssClass="<%=auditBtnClass %>" onClick="<%=auditFunctionCallStr%>" disabled="<%=auditDisable ? true : false %>"></aui:button>
			</liferay-ui:search-container-column-text>
			
						
			<%
				String CRFDeleteBtnClass = "";
			
				if(hasCRF){
					CRFDeleteBtnClass = "delete-btn small-btn";
				}else{
					CRFDeleteBtnClass = "none-btn small-btn";
				}
				
				if(updateLock) {
					CRFDeleteBtnClass = "none-btn small-btn";
				}
				
				String deleteFunctionCallStr = String.format("openMultiCRFDialog(%d, %d, %d, '%s', '%s')", rowSubjectId, crfId, 2, themeDisplay.getPortletDisplay().getId(), baseURL.toString());
				
				boolean deleteDisable = true;
				if(!updateLock && hasCRF) deleteDisable = false;
			%>
			
			<liferay-ui:search-container-column-text 
				name="ecrf-user.list.delete"
				cssClass="min-width-80"
			>
				<aui:button name="delete" type="button" value="ecrf-user.button.delete" cssClass="<%=CRFDeleteBtnClass %>" onClick="<%=deleteFunctionCallStr%>" disabled="<%=deleteDisable ? true : false %>"></aui:button>
			</liferay-ui:search-container-column-text>
			
			</liferay-ui:search-container-row>
			
			<liferay-ui:search-iterator
				displayStyle="list"
				markupView="lexicon"
				paginate="<%=true %>"
				searchContainer="<%=searchContainer2 %>"
			/>
		</liferay-ui:search-container>
		
		<c:if test="<%=isAdmin %>">
			<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_ALL_CRF_DATA %>" var="deleteAllCRFDataURL">
			</liferay-portlet:actionURL>
			
			<aui:button type="button" name="deleteAll" value="Delete All CRF Data" cssClass="delete-btn medium-btn radius-btn marTr" onClick="<%=deleteAllCRFDataURL %>"></aui:button>
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

Liferay.provide(window, "openValidPopup", function() {
	var A = AUI();
	
	var dialog = new A.Modal({
		headerContent: '<h3><liferay-ui:message key="Date validation"/></h3>',
		bodyContent: '<span style="color:red;"><liferay-ui:message key="Start Date is greater than End Date"/></span>',
		centered: true,
		modal: true,
		height: 200,
		width: 400,
		zIndex: 1100,
		close: true
	}).render();
	
}, ['aui-modal']
);

</script>

<aui:script use="aui-base aui-modal">
A.one('#<portlet:namespace/>search').on('click', function() {
	var isBirthDateValid = dateCheck("birthStart", "birthEnd", '<portlet:namespace/>');
	
	if(isBirthDateValid) {
		var form = $('#<portlet:namespace/>searchOptionFm');
		form.submit();
	} else if(!isBirthDateValid) {
	
		openValidPopup();
		/*
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
		*/
	}
});
</aui:script>