<%@page import="ecrf.user.constants.type.UILayout"%>
<%@page import="java.util.Arrays"%>
<%@page import="com.liferay.portal.kernel.portlet.LiferayPortletURL"%>
<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html.crf-data.data.list_teeth_data_jsp"); %>

<%
SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

ArrayList<CRFSubject> crfSubjectList = new ArrayList<>();
crfSubjectList.addAll(CRFSubjectLocalServiceUtil.getCRFSubjectByCRFId(scopeGroupId, crfId));

long[] subjectIds = ECRFUserUtil.getSubjectIdFromCRFSubject(crfSubjectList);

ArrayList<Subject> subjectList = new ArrayList<Subject>();
subjectList.addAll(SubjectLocalServiceUtil.getSubjectByIds(scopeGroupId, subjectIds));
Collections.reverse(subjectList);
String menu = ECRFUserMenuConstants.LIST_TEETH_DATA;

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
		
		<div class="crf-header-title">
			<% DataType titleDT = DataTypeLocalServiceUtil.getDataType(dataTypeId); %>
			<liferay-ui:message key="ecrf-user.general.crf-title-x" arguments="<%=titleDT.getDisplayName(themeDisplay.getLocale()) %>" />
		</div>
	
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.crf-data.title.list-teeth-data" />
		
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
							<button id="<portlet:namespace/>search" type="button" class="br20 dh-icon-button submit-btn search-btn white-text w130 h40 marR8 active">
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
					
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.serial-id"
				>
					<p ><%=String.valueOf(rowSubject.getSerialId()) %></p>
				</liferay-ui:search-container-column-text>
				
				<portlet:renderURL var="viewURL">
					<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_CRF_DATA%>" />
					<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
					<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(rowSubjectId) %>" />
					<portlet:param name="menu" value="<%=ECRFUserMenuConstants.VIEW_CRF_DATA %>" />	
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
				
				<%	// Permission and Update Lock Check
					boolean hasAddPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ADD_CRF_DATA);	
					boolean hasUpdatePermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.UPDATE_CRF_DATA);
					boolean hasViewAuditPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_AUDIT);
					boolean hasViewDataPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_CRF_DATA);
					boolean hasDeletePermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DELETE_CRF_DATA);
					
					boolean updateLock = CRFSubjectLocalServiceUtil.getUpdateLockByC_S(crfId, rowSubjectId);
					//_log.info(rowSubject.getSerialId() + " update lock : " + updateLock);
				%>
				
				<!-- Data Update -->
				<%
					// change render command name by ui layout
					int uiLayoutId = CRFLocalServiceUtil.getCRF(crfId).getDefaultUILayout();
					String commandName = ECRFUserMVCCommand.RENDER_VIEW_TEETH_DATA;
										
					// check data count & get link id when only one data exist
					List<LinkCRF> links = LinkCRFLocalServiceUtil.getLinkCRFByC_S(crfId, rowSubjectId);
					
					long singleSdId = 0;
					long singleLinkId = 0;
					if(crfDataCount == 1){
						LinkCRF getLink = links.get(0);
						singleLinkId = getLink.getLinkId();
						singleSdId = getLink.getStructuredDataId();
					}
				%>
				
				<portlet:renderURL var="renderUpdateCRFURL">
					<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=commandName%>" />
					<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
					<portlet:param name="<%=ECRFUserCRFDataAttributes.SUBJECT_ID %>" value="<%=String.valueOf(rowSubjectId) %>" />
					<portlet:param name="<%=ECRFUserCRFDataAttributes.LINK_ID %>" value="<%=String.valueOf(singleLinkId) %>" />					
					<portlet:param name="menu" value="<%=ECRFUserMenuConstants.VIEW_TEETH_DATA %>" />
					<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
				</portlet:renderURL>
				
				<%
					String updateFunctionCallStr = String.format("openMultiCRFDialog(%d, %d, %d, '%s', '%s')", rowSubjectId, crfId, 0, themeDisplay.getPortletDisplay().getId(), baseURL.toString());
					
					String CRFUpdateBtnClass = "dh-icon-button w110";
					String updateDataBtnKey = "ecrf-user.button.update";
					String updateOnClickStr = "";
					
					boolean isUpdateDisabled = false;
					
					// check data is exist
					if(!hasCRF) {
						isUpdateDisabled = true;
					} else {
						// check data count, change onclick code
						if(singleSdId > 0) {	// only one data
							updateOnClickStr = "location.href='" + renderUpdateCRFURL + "'";
						} else if(crfDataCount > 1) {	// multiple data
							updateOnClickStr = updateFunctionCallStr;
						}	
					}
					
					// check update lock -> change button span label key, set disabled
					if(updateLock) {
						isUpdateDisabled = true;
					}
					
					if(!hasUpdatePermission) {
						isUpdateDisabled = true;
					}
					
					// change button class and onclick code
					if(isUpdateDisabled) {
						CRFUpdateBtnClass += " inactive";
						updateDataBtnKey = "ecrf-user.button.locked";
						updateOnClickStr = "";
					} else {
						CRFUpdateBtnClass += " update-btn";
					}
				%>
				
				<liferay-ui:search-container-column-text 
					name="ecrf-user.list.update"
					cssClass="min-width-80"
				>
					<button id="<portlet:namespace/>updateCRF" type="button" class="<%=CRFUpdateBtnClass%>" onclick="<%=updateOnClickStr %>" <%=isUpdateDisabled ? "disabled" : "" %> >		
						<img class="update-icon<%=TagAttrUtil.inactive(isUpdateDisabled, TagAttrUtil.TYPE_ICON) %>" />
						<span><liferay-ui:message key="<%=updateDataBtnKey %>"/></span>			
					</button>
				</liferay-ui:search-container-column-text>
				<!-- Data Update -->
							
			</liferay-ui:search-container-row>
			
			<liferay-ui:search-iterator
				displayStyle="list"
				markupView="lexicon"
				paginate="<%=true %>"
				searchContainer="<%=searchContainer2 %>"
			/>
		</liferay-ui:search-container>
		
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
	}
});
</aui:script>