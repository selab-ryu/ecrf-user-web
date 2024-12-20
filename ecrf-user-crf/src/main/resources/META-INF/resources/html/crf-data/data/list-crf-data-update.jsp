<%@page import="java.util.Arrays"%>
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
Collections.reverse(subjectList);
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

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.1/font/bootstrap-icons.css">

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
							label="ecrf-user.crf-data.serial-id"
							helpMessage="ecrf-user.crf-data.serial-id.help"
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
							label="ecrf-user.crf-data.subject-name"
							helpMessage="ecrf-user.crf-data.subject.name.help"
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
							label="ecrf-user.crf-data.subject-gender"
							helpMessage="ecrf-user.crf-data.subject-gender.help"
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
							label="ecrf-user.crf-data.subject-birth.start"
							helpMessage="ecrf-user.crf-data.subject-birth.start.help"
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
							label="ecrf-user.crf-data.subject-birth.end"
							helpMessage="ecrf-user.crf-data.subject-birth.end.help"
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
				String progressSrc = renderRequest.getContextPath() + "/img/empty_progress.png";
				if(hasCRF){
					List<LinkCRF> linkList = LinkCRFLocalServiceUtil.getLinkCRFByG_S_C(scopeGroupId, rowSubjectId, crfId);
					if(linkList.size() > 0){
						LinkCRF link = linkList.get(linkList.size() - 1);
						String answer = DataTypeLocalServiceUtil.getStructuredData(link.getStructuredDataId());
						JSONObject answerObj = JSONFactoryUtil.createJSONObject(answer);
						long rowDataTypeId = CRFLocalServiceUtil.getDataTypeId(link.getCrfId());
						
						CRFProgressUtil progressApi = new CRFProgressUtil(renderRequest, rowDataTypeId, answerObj);
						progressPercentage = String.valueOf(progressApi.getProgressPercentage()) + "%";
						
						boolean hasQuery = false;
						if(CRFAutoqueryLocalServiceUtil.countQueryBySdId(link.getStructuredDataId()) > 0){
							List<CRFAutoquery> queryList = CRFAutoqueryLocalServiceUtil.getQueryBySId(rowSubjectId);
							for(int queryIdx = 0; queryIdx < queryList.size(); queryIdx++){
								CRFAutoquery query = queryList.get(queryIdx);
								if(query.getQueryComfirm() != 2){
									hasQuery = true;
									break;
								}
							}
						}
						
						progressSrc = progressApi.getProgressImg(progressApi.getProgressPercentage(), hasQuery);
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
				String name = rowSubject.getName();
				boolean hasViewEncryptPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_ENCRYPT_SUBJECT);
				if(!hasViewEncryptPermission)
					name = ECRFUserUtil.encryptName(name);
						
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
			
			<a class="icon-button icon-button-db-lock" href="<%=changeUpdateLock %>" name="dblock" disabled="<%=updateLock ? true : false %>">
				<img src="<%= updateLock ?  renderRequest.getContextPath() + "/btn_img/DB_Lock_icon_only.png" : renderRequest.getContextPath() + "/btn_img/DB_Unlock_icon_only.png"%>"/>
				<c:if test="<%=updateLock %>">
					<span>DB Locked</span>
				</c:if>
				<c:if test="<%=!updateLock %>">
					<span>DB Lock</span>
				</c:if>			
			</a>
			
			</liferay-ui:search-container-column-text>
			
			<!-- DB Lock -->
			
			<!-- Data Update -->
			<%
				String CRFUpdateBtnClass = "";
				String CRFAddBtnClass = "ci-btn small-btn";
				if(hasCRF){
					CRFUpdateBtnClass = "ci-btn small-btn";
				}else{
					CRFUpdateBtnClass = "none-btn small-btn";
				}
				
				if(updateLock) {
					CRFUpdateBtnClass = "none-btn small-btn";
					CRFAddBtnClass = "none-btn small-btn";
				}
				
				int displayId = CRFLocalServiceUtil.getCRF(crfId).getDefaultUILayout();
				String commandName = ECRFUserMVCCommand.RENDER_VIEW_CRF_DATA;
				if(displayId < 2){
					commandName = ECRFUserMVCCommand.RENDER_CRF_VIEWER;
				}
			%>
			<liferay-ui:search-container-column-text 
				name="ecrf-user.list.crf-data"
				cssClass="min-width-80"
			>
			<portlet:renderURL var="renderAddCRFURL">
				<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=commandName%>" />
				<portlet:param name="fromFlag" value="selector-add" />
				<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
				<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(rowSubjectId) %>" />
				<portlet:param name="structuredDataId" value="0" />			
				<portlet:param name="menu" value="crf-data-list-update" />
				<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
			</portlet:renderURL>
				<a class="<%= updateLock ? "icon-button icon-button-deactivate" : "icon-button icon-button-add"%>" href="<%=renderAddCRFURL %>" name="addCRF" disabled="<%=updateLock ? true : false %>">
          <img src="<%= updateLock ?  renderRequest.getContextPath() + "/btn_img/add_icon_deactivate.png" : renderRequest.getContextPath() + "/btn_img/add_icon.png"%>"/>
					<c:if test="<%=updateLock %>">
						<span>Locked</span>
					</c:if>
					<c:if test="<%=!updateLock %>">
						<span>Add Data</span>
					</c:if>			
				</a>
			</liferay-ui:search-container-column-text>
			
			<liferay-ui:search-container-column-text 
				name="ecrf-user.list.crf-data"
				cssClass="min-width-80"
			>
			
			<%
				String updateFunctionCallStr = String.format("openMultiCRFDialog(%d, %d, %d, '%s', '%s')", rowSubjectId, crfId, 0, themeDisplay.getPortletDisplay().getId(), baseURL.toString());
				List<LinkCRF> links = LinkCRFLocalServiceUtil.getLinkCRFByC_S(crfId, rowSubjectId);
				long singleSdId = 0;
				if(links.size() < 2 && links.size() > 0){
					LinkCRF getLink = links.get(0);
					singleSdId = getLink.getStructuredDataId();
				}
			%>
			<portlet:renderURL var="renderUpdateCRFURL">
				<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=commandName%>" />
				<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
				<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(rowSubjectId) %>" />
				<portlet:param name="sdId" value="<%=String.valueOf(singleSdId) %>" />				
				<portlet:param name="structuredDataId" value="<%=String.valueOf(singleSdId) %>" />				
				<portlet:param name="menu" value="crf-data-list-update" />
				<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
			</portlet:renderURL>
			<c:choose>
				<c:when test="<%=(links.size() < 2 && links.size() > 0) %>">
					<a class="<%= updateLock ? "icon-button icon-button-deactivate" : "icon-button icon-button-update"%>" href="<%=renderUpdateCRFURL %>" name="updateCRF" disabled="<%=updateLock ? true : false %>">
            <img src="<%= updateLock ?  renderRequest.getContextPath() + "/btn_img/update_icon_deactivate.png" : renderRequest.getContextPath() + "/btn_img/update_icon.png"%>"/>
						<c:if test="<%=updateLock %>">
							<span>Locked</span>
						</c:if>
						<c:if test="<%=!updateLock %>">
							<span>Update Data</span>
						</c:if>			
					</a>
				</c:when>
				<c:otherwise>
					<a class="<%= updateLock ? "icon-button icon-button-deactivate" : "icon-button icon-button-update"%>" onclick="<%=updateFunctionCallStr %>" name="updateCRF" disabled="<%=updateLock ? true : false %>">
            <img src="<%= updateLock ?  renderRequest.getContextPath() + "/btn_img/update_icon_deactivate.png" : renderRequest.getContextPath() + "/btn_img/update_icon.png"%>"/>
						<c:if test="<%=updateLock %>">
							<span>Locked</span>
						</c:if>
						<c:if test="<%=!updateLock %>">
							<span>Update Data</span>
						</c:if>			
					</a>				
				</c:otherwise>	
			</c:choose>
		
			
				
			</liferay-ui:search-container-column-text>
			
			<%
				String auditBtnClass = "";
				if(hasCRF){
					auditBtnClass = "history-btn small-btn";
				}else{
					auditBtnClass = "none-btn small-btn";
				}
			
				String auditFunctionCallStr = String.format("openMultiCRFDialog(%d, %d, %d, '%s', '%s')", rowSubjectId, crfId, 1, themeDisplay.getPortletDisplay().getId(), baseURL.toString());
				List<LinkCRF> links = LinkCRFLocalServiceUtil.getLinkCRFByC_S(crfId, rowSubjectId);
				long singleSdId = 0;
				if(links.size() < 2 && links.size() > 0){
					LinkCRF getLink = links.get(0);
					singleSdId = getLink.getStructuredDataId();
				}
				boolean hasViewAuditPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_AUDIT);
				boolean auditDisable = true;
				if(hasViewAuditPermission && hasCRF) auditDisable = false;  
			%>
			
			<!-- Audit trail button -->
			<liferay-ui:search-container-column-text 
				name="ecrf-user.list.audit-trail"
				cssClass="min-width-80"
			>
			<portlet:renderURL var="renderAuditCRFURL">
				<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_CRF_VIEWER%>" />
				<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
				<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(rowSubjectId) %>" />
				<portlet:param name="sdId" value="<%=String.valueOf(singleSdId) %>" />				
				<portlet:param name="structuredDataId" value="<%=String.valueOf(singleSdId) %>" />
				<portlet:param name="isAudit" value="1" />			
				<portlet:param name="menu" value="crf-data-list-update" />
				<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
			</portlet:renderURL>
			<c:choose>
				<c:when test="<%=(links.size() < 2 && links.size() > 0) %>">
					<a class="icon-button icon-button-audit" href="<%=renderAuditCRFURL %>" name="auditCRF" disabled="<%=updateLock ? true : false %>">
						<c:if test="<%=updateLock %>">
							<img src="<%= updateLock ?  renderRequest.getContextPath() + "/btn_img/view_icon.png" : renderRequest.getContextPath() + "/btn_img/view_icon.png"%>"/>						
							<span>View Data</span>
						</c:if>
						<c:if test="<%=!updateLock %>">
							<img src="<%= updateLock ?  renderRequest.getContextPath() + "/btn_img/audit_icon.png" : renderRequest.getContextPath() + "/btn_img/audit_icon.png"%>"/>						
							<span>Audit Trail</span>
						</c:if>				
					</a>	
				</c:when>
				<c:otherwise>
					<a class="icon-button icon-button-audit" onclick="<%=auditFunctionCallStr %>" name="auditCRF" disabled="<%=updateLock ? true : false %>">
						<c:if test="<%=updateLock %>">
							<img src="<%= updateLock ?  renderRequest.getContextPath() + "/btn_img/view_icon.png" : renderRequest.getContextPath() + "/btn_img/view_icon.png"%>"/>						
							<span>View Data</span>
						</c:if>
						<c:if test="<%=!updateLock %>">
							<img src="<%= updateLock ?  renderRequest.getContextPath() + "/btn_img/audit_icon.png" : renderRequest.getContextPath() + "/btn_img/audit_icon.png"%>"/>						
							<span>Audit Trail</span>
						</c:if>			
					</a>	
				</c:otherwise>	
			</c:choose>
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

				long singleLinkId = 0;
				if(links.size() < 2 && links.size() > 0){
					LinkCRF getLink = links.get(0);
					singleLinkId = getLink.getLinkId();
				}
				
				String deleteFunctionCallStr = String.format("openMultiCRFDialog(%d, %d, %d, '%s', '%s')", rowSubjectId, crfId, 2, themeDisplay.getPortletDisplay().getId(), baseURL.toString());
				
				String deleteSingleFunctionCallStr = String.format("deleteSingleCRF(%d, %d, '%s', '%s')", singleLinkId, crfId, themeDisplay.getPortletDisplay().getId(), baseURL.toString());

				boolean deleteDisable = true;
				if(!updateLock && hasCRF) deleteDisable = false;
			%>
			
			<liferay-ui:search-container-column-text 
				name="ecrf-user.list.delete"
				cssClass="min-width-80"
			>
			<c:choose>
				<c:when test="<%=(links.size() < 2 && links.size() > 0) %>">
					<a class="<%= updateLock ? "icon-button icon-button-deactivate" : "icon-button icon-button-delete"%>" onclick="<%=deleteSingleFunctionCallStr %>" name="deleteCRF" disabled="<%=updateLock ? true : false %>">
            <img src="<%= updateLock ?  renderRequest.getContextPath() + "/btn_img/delete_icon_deactivate.png" : renderRequest.getContextPath() + "/btn_img/delete_icon.png"%>"/>
						<c:if test="<%=updateLock %>">
							<span>Locked</span>
						</c:if>
						<c:if test="<%=!updateLock %>">
							<span>Delete</span>
						</c:if>			
					</a>	
				</c:when>
				<c:otherwise>
					<a class="<%= updateLock ? "icon-button icon-button-deactivate" : "icon-button icon-button-delete"%>" onclick="<%=deleteFunctionCallStr %>" name="deleteCRF" disabled="<%=updateLock ? true : false %>">
            <img src="<%= updateLock ?  renderRequest.getContextPath() + "/btn_img/delete_icon_deactivate.png" : renderRequest.getContextPath() + "/btn_img/delete_icon.png"%>"/>
						<c:if test="<%=updateLock %>">
							<span>Locked</span>
						</c:if>
						<c:if test="<%=!updateLock %>">
							<span>Delete</span>
						</c:if>			
					</a>	
				</c:otherwise>	
			</c:choose>
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
				<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
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
function deleteSingleCRF(linkCrfId, crfId, portletId, baseURL){
	$.confirm({
		title: '<liferay-ui:message key="ecrf-user.message.confirm-delete-crf-data.title"/>',
		content: '<p><liferay-ui:message key="ecrf-user.message.confirm-delete-crf-data.content"/></p>',
		type: 'red',
		typeAnimated: true,
		columnClass: 'large',
		buttons:{
			ok: {
				btnClass: 'btn-blue',
				action: function(){

					var actionURL = Liferay.Util.PortletURL.createActionURL(baseURL,
							{
								'p_p_id' : portletId,
								'p_auth': Liferay.authToken,
								'javax.portlet.action' : '/action/crf-data/delete-crf-data',
								'linkCrfId' : linkCrfId,
								'crfId' : crfId
							});
					
					window.location.href = actionURL.toString();
				}
			},
			close: {
	            action: function () {
	            }
	        }
		},
		draggable: true
	});
}
</script>

<aui:script use="aui-base aui-modal">
$('#<portlet:namespace/>search').on('click', function() {
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