<%@ include file="../init.jsp" %>

<%! private Log _log = LogFactoryUtil.getLog("html/crf-query/update-query.jsp"); %>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

	boolean isUpdate = false;
	
	// change String to long
	String sdId = (String)renderRequest.getAttribute("sdId");
	String sId = (String)renderRequest.getAttribute("sId");
	String value = (String)renderRequest.getAttribute("value");
	
	String menu = ECRFUserMenuConstants.VALIDATE_QUERY;
	
	Subject subject = null;
	if(sId != null) {
		isUpdate = true;
		subject = (Subject)renderRequest.getAttribute("subject");
	}

	CRFAutoquery query = null;
	if(value != null){
		query = (CRFAutoquery)renderRequest.getAttribute("query");
	}
	
	_log.info("crf id : " + crfId);
	CRF crf = null;
	DataType dataType = null;
	if(crfId > 0) {
		crf = (CRF)renderRequest.getAttribute(ECRFUserCRFAttributes.CRF);	
		
		if(dataTypeId > 0) {
			_log.info("dataType id : " + dataTypeId);
			dataType = DataTypeLocalServiceUtil.getDataType(dataTypeId);
		}
	}
	
	//_log.info("jsp : " + sd + " / " + subject + " / " + query);
%>
<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_COMFIRM_CRF_QUERY%>" var="updateQueryURL">
	<portlet:param name="sId" value="<%=String.valueOf(sId) %>" />
	<portlet:param name="sdId" value="<%=String.valueOf(sdId) %>" />
	<portlet:param name="queryId" value="<%=String.valueOf(query.getAutoQueryId())%>" />
	<portlet:param name="crfId" value="<%=String.valueOf(crfId)%>" />
</liferay-portlet:actionURL>

<portlet:renderURL var="listCRFQueryURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_QUERY%>"/>
	<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
</portlet:renderURL>

<style>

.ecrf-query .sub-title-bottom-border {
	margin-bottom:0rem;
}

</style>

<div class="ecrf-user ecrf-query">

	<%@ include file="sidebar.jspf" %>
	
	<div class="page-content">

		<div class="crf-header-title">
			<% DataType titleDT = DataTypeLocalServiceUtil.getDataType(dataTypeId); %>
			<liferay-ui:message key="ecrf-user.general.crf-title-x" arguments="<%=titleDT.getDisplayName(themeDisplay.getLocale()) %>" />
		</div>
		
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.crf-query.title.update-query" />
		
		<aui:container cssClass="radius-shadow-container">
			<aui:row>
				<aui:col md="12">
					<aui:form name="updateQueryFm" action="<%=updateQueryURL%>" autocomplete="off">
						<aui:container>	
							
							<aui:row cssClass="">
								<aui:col md="12" cssClass="sub-title-bottom-border">
									<span class="sub-title-span">
										<liferay-ui:message key="ecrf-user.crf-query.title.query-info" />
									</span>
								</aui:col>
							</aui:row>
							
							<aui:row cssClass="padT20">
								<aui:col md="3">
									<aui:field-wrapper
										name="crfTitle"
										label="ecrf-user.crf-query.crf-title"
										helpMessage="ecrf-user.crf-query.crf-title.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3">
									<p><%=Validator.isNull(dataType) ? StringPool.BLANK : dataType.getDisplayName() %></p>
								</aui:col>
								<aui:col md="3">
									<aui:field-wrapper
										name="subjectIdStr"
										label="ecrf-user.crf-query.subject-name-id"
										helpMessage="ecrf-user.crf-query.subject-name-id.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<%
								String subjectName = subject.getName();
								boolean hasViewEncryptPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_ENCRYPT_SUBJECT);
								if(!hasViewEncryptPermission)
									subjectName = ECRFUserUtil.encryptName(subjectName);	
								%>
								<aui:col md="3">
									<p><%=Validator.isNull(subject.getName()) ? StringPool.BLANK : subjectName + "(" + subject.getSerialId() + ")"%></p>
								</aui:col>
							</aui:row>
							
							<aui:row cssClass="top-border padT20">
								<aui:col md="3">
									<aui:field-wrapper
										name="queryTermName"
										label="ecrf-user.crf-query.term-name"
										helpMessage="ecrf-user.crf-query.term-name.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<%
									String displayName = "";
									//long dataTypeId = DataTypeLocalServiceUtil.getAllDataTypes().get(0).getDataTypeId();
									JSONObject crfForm = DataTypeLocalServiceUtil.getDataTypeStructureJSONObject(dataTypeId);
									JSONArray crfFormArr = crfForm.getJSONArray("terms");
									for(int i = 0; i < crfFormArr.length(); i++){
										if(Validator.isNotNull(query)){
											if(crfFormArr.getJSONObject(i).getString("termName").equals(query.getQueryTermName())){
												displayName = crfFormArr.getJSONObject(i).getJSONObject("displayName").getString("en_US");	
											}
										}
									}
								%>
								<aui:col md="3">
									<p><%=displayName%></p>
								</aui:col>
								<aui:col md="3">
									<aui:field-wrapper
										name="queryValue"
										label="ecrf-user.crf-query.term-value"
										helpMessage="ecrf-user.crf-query.term-value.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3">
									<p><%=Validator.isNull(query.getQueryPreviousValue()) ? query.getQueryValue() : query.getQueryPreviousValue()%></p>
								</aui:col>
							</aui:row>
							
							<aui:row cssClass="top-border padT20">
								<aui:col md="3">
									<aui:field-wrapper
										name="queryType"
										label="ecrf-user.crf-query.query-type"
										helpMessage="ecrf-user.crf-query.query-type.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<!-- TODO: change to enum -->
								<%
									String queryTypeStr = "";
									if(Validator.isNotNull(query)){
										if(query.getQueryType() == 0){
											queryTypeStr = "Auto"; 
										}else if(query.getQueryType() == 1){
											queryTypeStr = "Minimum Value Error"; 
										}else if(query.getQueryType() == 2){
											queryTypeStr = "Maximum Value Error"; 
										}else if(query.getQueryType() == 3){
											queryTypeStr = "Out of Range"; 
										}else if(query.getQueryType() == 4){
											queryTypeStr = "Missing Floating Point"; 
										}else if(query.getQueryType() == 5){
											queryTypeStr = "Unmatch Floating Point length"; 
										}
									}
								%>
								<aui:col md="9">
									<p><%=Validator.isNull(query) ? StringPool.BLANK : queryTypeStr%></p>
								</aui:col>
							</aui:row>
							
							<%
								User publisher = null;
								String publisherName = StringPool.DASH;
								try {
									publisher = UserLocalServiceUtil.getUser(query.getUserId());
									publisherName = publisher.getLastName() + StringPool.SPACE + publisher.getFirstName();
								} catch(Exception e) {
									_log.info("cannot find user");
								}
							%>
							
							<aui:row cssClass="top-border padT20">
								<aui:col md="3">
									<aui:field-wrapper
										name="userName"
										label="ecrf-user.crf-query.publisher"
										helpMessage="ecrf-user.crf-query.publisher.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3">
									<p><%=Validator.isNull(query) ? StringPool.BLANK : publisherName %></p>
								</aui:col>
								<aui:col md="3">
									<aui:field-wrapper
										name="createDate"
										label="ecrf-user.crf-query.create-date"
										helpMessage="ecrf-user.crf-query.create-date.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3">
									<p><%=sdf.format(query.getCreateDate()) %></p>
								</aui:col>
							</aui:row>
							
							
							<aui:row cssClass="marTr">
								<aui:col md="12" cssClass="sub-title-bottom-border">
									<span class="sub-title-span">
										<liferay-ui:message key="ecrf-user.crf-query.title.validation-info" />
									</span>
								</aui:col>
							</aui:row>
							
							<aui:row cssClass="padT20">
								<aui:col md="3">
									<aui:field-wrapper
										name="queryChangeValue"
										label="ecrf-user.crf-query.change-value"
										helpMessage="ecrf-user.crf-query.change-value.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3">
									<aui:input
										cssClass="search-input h35"
										name="queryChangeValue"
										label=" "
										placeholder=""
										value="<%= Validator.isNull(query) ? StringPool.BLANK : query.getQueryValue()%>"
									>
									</aui:input>
								</aui:col>
							</aui:row>
							
							<aui:row cssClass="top-border padT20">
								<aui:col md="3">
									<aui:field-wrapper
										name="queryComment"
										label="ecrf-user.crf-query.comment"
										helpMessage="ecrf-user.crf-query.comment.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="9">
									<aui:input
										cssClass="search-input h35"
										name="queryComment"
										label=""
										placeholder=""
										value="<%=Validator.isNull(query) ? StringPool.BLANK : query.getQueryComment() %>"
									>
									</aui:input>
								</aui:col>
							</aui:row>
							
							
							<aui:row cssClass="marTr">
								<aui:col md="12" cssClass="sub-title-bottom-border">
									<span class="sub-title-span">
										<liferay-ui:message key="ecrf-user.crf-query.title.confirm-info" />
									</span>
								</aui:col>
							</aui:row>
							
							<aui:row cssClass="padT20">
							<!-- TODO: change to enum -->
								<% 
									boolean processing = false;
									boolean refuse = false;
									boolean accept = false;
									
									if(query.getQueryComfirm() == 0){
										processing = true;
									}else if(query.getQueryComfirm() == 1){
										refuse = true;
									}else if(query.getQueryComfirm() == 2){
										accept = true;
									}
								%>
								<aui:col md="12" >
									<aui:field-wrapper
										name="queryComfirm"
										label="ecrf-user.crf-query.confirm-status"
										helpMessage="ecrf-user.crf-query.confirm-status.help"
										cssClass="marBrh"
									>
										<aui:fieldset>
											<aui:input type="radio" name="queryComfirm" value="0" cssClass="search-input" label="ecrf-user.crf-query.confirm-status.processing" checked="<%=processing %>"></aui:input>
											<aui:input type="radio" name="queryComfirm" value="1" cssClass="search-input" label="ecrf-user.crf-query.confirm-status.refuse" checked="<%=refuse %>"></aui:input>
											<aui:input type="radio" name="queryComfirm" value="2" cssClass="search-input" label="ecrf-user.crf-query.confirm-status.accept" checked="<%=accept %>"></aui:input>
										</aui:fieldset>
									</aui:field-wrapper>
								</aui:col>
							</aui:row>
							
							<aui:row cssClass="top-border padT20">
							<%
								User confirmUser = null;
								String confirmUserName = StringPool.DASH;
								try {
									confirmUser = user;
									confirmUserName = confirmUser.getLastName() + StringPool.SPACE + confirmUser.getFirstName();
								} catch(Exception e) {
									_log.info("cannot find user");
								}
							%>
							
								<aui:col md="3">
									<aui:field-wrapper
										name="queryComfirmUserName"
										label="ecrf-user.crf-query.confirm-user"
										helpMessage="ecrf-user.crf-query.confirm-user.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3">
									<p><%=Validator.isNull(user) ? StringPool.BLANK : confirmUserName %></p>
								</aui:col>
								<aui:col md="3">
									<aui:field-wrapper
										name="modifiedDate"
										label="ecrf-user.crf-query.confirm-date"
										helpMessage="ecrf-user.crf-query.confirm-date.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3">
									<p><%=sdf.format(new Date()) %></p>
								</aui:col>
							</aui:row>
							
							<%
							boolean hasAddPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ADD_CRF_QUERY);
							boolean hasValidateQueryPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VALIDATE_CRF_QUERY);							 
							%>
							
							<aui:row>
								<aui:col md="12">
									<aui:button-row cssClass="marL10">
										<c:choose>
										<c:when test="<%=isUpdate%>">
											<c:if test="<%=hasValidateQueryPermission%>">
												<button name="<portlet:namespace/>save" type="submit" class="dh-icon-button submit-btn save-btn w110 h36 marR8">
													<img class="save-icon" />
													<span><liferay-ui:message key="ecrf-user.button.save"/></span>
												</button>
											</c:if>
										</c:when>
										<c:otherwise>	
											<c:if test="<%=hasAddPermission%>">
												<button name="<portlet:namespace/>add" type="submit" class="dh-icon-button submit-btn add-btn w110 h36 marR8">
													<img class="add-icon"/>
													<span><liferay-ui:message key="ecrf-user.button.add"/></span>
												</button>					
											</c:if>
										</c:otherwise>
										</c:choose>
										
										<button name="<portlet:namespace/>back" class="dh-icon-button submit-btn back-btn w110 h36 marR8" onclick="location.href='<%=listCRFQueryURL%>'">
											<img class="back-icon" />
											<span><liferay-ui:message key="ecrf-user.button.back"/></span>
										</button>
									</aui:button-row>
								</aui:col>
							</aui:row>	
						</aui:container>
					</aui:form>				
				</aui:col>
			</aui:row>
		</aui:container>
	</div>
</div>