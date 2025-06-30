<%@ include file="../init.jsp" %>

<%! private Log _log = LogFactoryUtil.getLog("html/crf-query/list-query.jsp"); %>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
		
	String menu = ECRFUserMenuConstants.LIST_QUERY;
		
	ArrayList<CRFAutoquery> queryList = new ArrayList<CRFAutoquery>();
	queryList.addAll(CRFAutoqueryLocalServiceUtil.getQueryByGroupCRF(scopeGroupId, crfId));
	
	PortletURL portletURL = PortletURLUtil.getCurrent(renderRequest, renderResponse);
	
	portletURL.setParameter("jspPage", ECRFUserJspPaths.JSP_LIST_QUERY);
%>

<portlet:renderURL var="searchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_QUERY%>"/>
	<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
	<portlet:param name="isSearch" value="true"/>
</portlet:renderURL>

<portlet:renderURL var="clearSearchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_QUERY%>"/>
	<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />	
</portlet:renderURL>

<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_ALL_CRF_QUERY %>" var="deleteAllQueryURL">
	<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
</liferay-portlet:actionURL>

<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_ALL_CRF_QUERY%>" var="addAllQueryURL">
	<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
</liferay-portlet:actionURL>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.1/font/bootstrap-icons.css">

<div class="ecrf-user ecrf-user-query">

	<%@ include file="sidebar.jspf" %>
	
	<div class="page-content">
		
		<div class="crf-header-title">
			<% DataType titleDT = DataTypeLocalServiceUtil.getDataType(dataTypeId); %>
			<liferay-ui:message key="ecrf-user.general.crf-title-x" arguments="<%=titleDT.getDisplayName(themeDisplay.getLocale()) %>" />
		</div>
		
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.crf-query.title.query-list" />
		
		<aui:form action="${searchURL}" name="searchOptionFm" autocomplete="off" cssClass="marBr">
			<aui:container cssClass="radius-shadow-container">
				<aui:row>
					<aui:col md="4">
						<aui:field-wrapper
							name="userId"
							label="ecrf-user.crf-query.user-id"
							helpMessage="ecrf-user.crf-query.user-id.help"
							cssClass="marBrh"
						>
							<aui:input
								type="text"
								name="userId" 
								cssClass="search-input h35" 
								label=" "
								></aui:input>
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="4">
						<aui:field-wrapper
							name="userName"
							label="ecrf-user.crf-query.user-name"
							helpMessage="ecrf-user.crf-query.user-name.help"
							cssClass="marBrh"
						>
							<aui:input
								type="text"
								name="userId" 
								cssClass="search-input h35" 
								label=" "
								></aui:input>
						</aui:field-wrapper>
					</aui:col>
					<aui:col md="4">
						<aui:field-wrapper
							name="queryComfirm"
							label="ecrf-user.crf-query.confirm-status"
							helpMessage="ecrf-user.crf-query.confirm-status.help"
							cssClass="marBrh"
						>
							<aui:fieldset cssClass="">
								<aui:input type="radio" name="queryComfirm" value="0" cssClass="search-input" label="ecrf-user.crf-query.confirm-status.processing" ></aui:input>
								<aui:input type="radio" name="queryComfirm" value="1" cssClass="search-input" label="ecrf-user.crf-query.confirm-status.accept" ></aui:input>
								<aui:input type="radio" name="queryComfirm" value="2" cssClass="search-input" label="ecrf-user.crf-query.confirm-status.refuse" ></aui:input>
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
							<buton id="<portlet:namespace/>clear" type="button" class="br20 dh-icon-button submit-btn clear-btn white-text w130 h40 active" onclick="location.href='<%=clearSearchURL %>'">
								<img class="clear-icon" />
								<span><liferay-ui:message key="ecrf-user.button.clear" /></span>
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
			total="<%=queryList.size() %>"
			var="searchContainer"
			cssClass="marTrh center-table radius-shadow-container"
			>
	
			<liferay-ui:search-container-results
				results="<%=ListUtil.subList(queryList, searchContainer.getStart(), searchContainer.getEnd()) %>" /> 
			
			<%
				if(queryList.size() == 0) {
					searchContainer.setEmptyResultsMessageCssClass("taglib-empty-search-result-message-header");
					searchContainer.setEmptyResultsMessage("subject.no-search-result");
				}
			%>
	
			<% int count = searchContainer.getStart(); %>
	
			<liferay-ui:search-container-row
				className="ecrf.user.model.CRFAutoquery"
				escapedModel="<%=true %>"
				keyProperty="autoQueryId"
				modelVar="crfAutoquery"
			>
		
				<liferay-ui:search-container-column-text
					name="No"
					value="<%=String.valueOf(++count) %>"
				/>
				
				<%
					Subject rowSubject = SubjectLocalServiceUtil.getSubject(crfAutoquery.getSubjectId());

					String subjectName = rowSubject.getName();
					boolean hasViewEncryptPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_ENCRYPT_SUBJECT);
					if(!hasViewEncryptPermission)
						subjectName = ECRFUserUtil.encryptName(subjectName);	

					String idRowStr = subjectName + "(" + rowSubject.getSerialId() + ")";
				%>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.subject-name-id"
					value="<%=idRowStr %>"
				/>
								
				<%
					String displayName = "";
					//long dataTypeId = DataTypeLocalServiceUtil.getAllDataTypes().get(0).getDataTypeId();
					JSONObject crfForm = DataTypeLocalServiceUtil.getDataTypeStructureJSONObject(dataTypeId);
					JSONArray crfFormArr = crfForm.getJSONArray("terms");
					for(int i = 0; i < crfFormArr.length(); i++){
						if(Validator.isNotNull(crfAutoquery)){
							if(crfFormArr.getJSONObject(i).getString("termName").equals(crfAutoquery.getQueryTermName())){
								displayName = crfFormArr.getJSONObject(i).getJSONObject("displayName").getString("en_US");	
							}
						}
					}
				%>
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.term-name"
					value="<%=displayName %>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.term-value"
					property="queryValue"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.query.pre-value"
					property="queryPreviousValue"
				/>
				
				<%
					String queryTypeStr = "";
					if(Validator.isNotNull(crfAutoquery)){
						if(crfAutoquery.getQueryType() == 0){
							queryTypeStr = "Auto"; 
						}else if(crfAutoquery.getQueryType() == 1){
							queryTypeStr = "Minimum Value Error"; 
						}else if(crfAutoquery.getQueryType() == 2){
							queryTypeStr = "Maximum Value Error"; 
						}else if(crfAutoquery.getQueryType() == 3){
							queryTypeStr = "Out of Range"; 
						}else if(crfAutoquery.getQueryType() == 4){
							queryTypeStr = "Missing Floating Point"; 
						}else if(crfAutoquery.getQueryType() == 5){
							queryTypeStr = "Unmatch Floating Point length"; 
						}
					}
				%>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.query.query-type"
					value="<%=queryTypeStr %>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.comment"
					property="queryComment"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.query.create-date"
					value="<%=Validator.isNull(crfAutoquery.getCreateDate()) ? "-" : sdf.format(crfAutoquery.getCreateDate()) %>"
				/>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.query.validate-date"
					value="<%=Validator.isNull(crfAutoquery.getQueryComfirmDate()) ? "-" : sdf.format(crfAutoquery.getQueryComfirmDate()) %>"
				/>
				
				<%
					User publisher = null;
					String publisherName = StringPool.DASH;
					try {
						publisher = UserLocalServiceUtil.getUser(crfAutoquery.getUserId());
						publisherName = publisher.getLastName() + StringPool.SPACE + publisher.getFirstName();
					} catch(Exception e) {
						_log.info("cannot find user");
					}
				%>
												
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.query.publisher"
					value="<%=publisherName %>"
				/>
				
				<%
					String queryComfirmStr = "";
					if(Validator.isNotNull(crfAutoquery.getQueryComfirm())){
						if(crfAutoquery.getQueryComfirm() == 0){
							queryComfirmStr = "processing";
						}else if(crfAutoquery.getQueryComfirm() == 1){
							queryComfirmStr = "refused";
						}else if(crfAutoquery.getQueryComfirm() == 2){
							queryComfirmStr = "comfirmed";
						}
					}
				%>
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.query.confirm-status"
					value="<%=Validator.isNull(crfAutoquery.getQueryComfirm()) ? "-" : queryComfirmStr%>"
				/>

				<portlet:renderURL var="updateQueryURL">
					<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
					<portlet:param name="sdId" value="<%=String.valueOf(crfAutoquery.getQueryTermId()) %>" />
					<portlet:param name="sId" value="<%=String.valueOf(crfAutoquery.getSubjectId()) %>" />
					<portlet:param name="termName" value="<%=String.valueOf(crfAutoquery.getQueryTermName()) %>" />
					<portlet:param name="value" value="<%=String.valueOf(crfAutoquery.getQueryValue()) %>" />
					<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME%>" value="<%=ECRFUserMVCCommand.RENDER_UPDATE_CRF_QUERY %>"/>
					<portlet:param name="<%=WebKeys.REDIRECT%>" value="<%=Validator.isNull(portletURL) ? currentURL : portletURL.toString() %>" />
				</portlet:renderURL>
				
				<%
					boolean updateLock = CRFSubjectLocalServiceUtil.getUpdateLockByC_S(crfId, crfAutoquery.getSubjectId());
					boolean hasUpdateQueryPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.UPDATE_CRF_QUERY);
					
					boolean isDisabled = updateLock || !hasUpdateQueryPermission;
					
					//_log.info("update lock / permission / disabled : " + updateLock + " / " + hasUpdateQueryPermission + " / " + isDisabled);
					
					String updateBtnClass = "dh-icon-button w130";
					String updateOnClickStr = "location.href='"+updateQueryURL+"'";
					String updateBtnKey = "ecrf-user.button.update";
					
					if(isDisabled) {
						updateBtnClass += " inactive";
						updateOnClickStr = "";
						updateBtnKey = "ecrf-user.button.locked";
					} else {
						updateBtnClass += " update-btn";
					}
				%>
				
				<liferay-ui:search-container-column-text
					name="ecrf-user.list.update"
					cssClass="min-width-80"
				>

				<button id="updateQuery" class="<%=updateBtnClass %>" onclick="<%=updateOnClickStr %>">
					<img class="update-icon<%=TagAttrUtil.inactive(isDisabled, TagAttrUtil.TYPE_ICON) %>" />
					<span><liferay-ui:message key="<%=updateBtnKey %>"/></span>	
				</button>

				
				</liferay-ui:search-container-column-text>
			
			</liferay-ui:search-container-row>
			<liferay-ui:search-iterator
				displayStyle="list"
				markupView="lexicon"
				paginate="<%=true %>"
				searchContainer="<%=searchContainer%>"
			/>
		</liferay-ui:search-container>
		
		<c:if test="<%=isAdmin %>">
		<aui:row>
			<aui:col>
				<aui:button-row cssClass="marL10">
					<aui:button type="button" name="delete" value="ecrf-user.button.delete-all-query" cssClass="delete-btn medium-btn radius-btn" onClick="<%=deleteAllQueryURL%>"></aui:button>
					<aui:button type="button" name="add" value="ecrf-user.button.add-all-query" cssClass="add-btn medium-btn radius-btn" onClick="<%=addAllQueryURL%>"></aui:button>
				</aui:button-row>
				
			</aui:col>
		</aui:row>
		</c:if>
	</div>
</div>