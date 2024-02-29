<%@ include file="../init.jsp" %>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

	boolean isUpdate = false;

	String sdId = (String)renderRequest.getAttribute("sdId");
	String sId = (String)renderRequest.getAttribute("sId");
	String value = (String)renderRequest.getAttribute("value");
	
	String menu = "query-add";

	Subject subject = null;
	if(sId != null) {
		isUpdate = true;
		subject = (Subject)renderRequest.getAttribute("subject");
		
		menu = "update-query";
	}
	StructuredData sd = null;
	if(sdId != null) {
		sd = (StructuredData)renderRequest.getAttribute("sd");
	}
	CRFAutoquery query = null;
	if(value != null){
		query = (CRFAutoquery)renderRequest.getAttribute("query");
	}
	
	System.out.println("jsp : " + sd + " / " + subject + " / " + query);

%>
<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_COMFIRM_CRF_QUERY%>" var="updateQueryURL">
	<portlet:param name="sId" value="<%=String.valueOf(sId) %>" />
	<portlet:param name="sdId" value="<%=String.valueOf(sdId) %>" />
	<portlet:param name="queryId" value="<%=String.valueOf(query.getAutoQueryId())%>" />
</liferay-portlet:actionURL>

<div class="ecrf-user ecrf-user-query SXCRFAutoquery">

	<%@ include file="sidebar.jspf" %>
	
	<div class="page-content">
		
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.crf-query.title.update-query" />
		
		<aui:container cssClass="radius-shadow-container">
			<aui:row>
				<aui:col md="12">
					<aui:form name="updateQueryFm" action="<%=updateQueryURL%>" autocomplete="off">
						<aui:container cssClass="">	
							<aui:row cssClass="marBrh">
								<aui:col md="12">
									<span class="sub-title-span">
										<liferay-ui:message key="SXcrfAutoquery.query.context" />
									</span>
								</aui:col>
							</aui:row>
							<aui:row cssClass="top-border">
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="queryType"
										label="SXcrfAutoquery.query.querytype"
										helpMessage="SxcrfForm.subject.id.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
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
								<aui:col md="9" cssClass="marTr">
									<aui:input
										cssClass="search-input h35"
										name="queryType"
										label=" "
										placeholder=""
										value="<%= Validator.isNull(query) ? StringPool.BLANK : queryTypeStr%>"
									>
									</aui:input>
								</aui:col>
							</aui:row>
							<aui:row cssClass="top-border">
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="queryTermName"
										label="SXcrfAutoquery.query.termname"
										helpMessage="SxcrfForm.subject.id.help"
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
								<aui:col md="3" cssClass="marTr">
									<aui:input
										cssClass="search-input h35"
										name="queryTermName"
										label=" "
										placeholder=""
										value="<%=displayName%>"
									>
									</aui:input>
								</aui:col>
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="queryValue"
										label="SXcrfAutoquery.query.value"
										helpMessage="SxcrfForm.subject.id.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3" cssClass="marTr">
									<aui:input
										cssClass="search-input h35"
										name="queryValue"
										label=" "
										placeholder=""
										value="<%= Validator.isNull(query.getQueryPreviousValue()) ? query.getQueryValue() : query.getQueryPreviousValue()%>"
									>
									</aui:input>
								</aui:col>
							</aui:row>
							<aui:row cssClass="top-border">
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="subjectIdStr"
										label="SXcrfForm.subject.id"
										helpMessage="SxcrfForm.subject.id.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3" cssClass="marTr">
									<aui:input
										cssClass="search-input h35"
										name="subjectIdStr"
										label=" "
										placeholder=""
										value="<%= Validator.isNull(subject) ? StringPool.BLANK : subject.getSubjectIdStr()%>"
									>
									</aui:input>
								</aui:col>
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="structuredDataId"
										label="SXcrfForm.subject.crf.id"
										helpMessage="SxcrfForm.subject.id.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3" cssClass="marTr">
									<aui:input
										cssClass="search-input h35"
										name="structuredDataId"
										label=" "
										placeholder=""
										value="<%= Validator.isNull(sd) ? StringPool.BLANK : sd.getStructuredDataId()%>"
									>
									</aui:input>
								</aui:col>
							</aui:row>
							<aui:row cssClass="top-border">
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="userName"
										label="SXcrfAutoquery.user.name"
										helpMessage="SxcrfForm.subject.id.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3" cssClass="marTr">
									<aui:input
										cssClass="search-input h35"
										name="userName"
										label=" "
										placeholder=""
										value="<%= Validator.isNull(query) ? StringPool.BLANK : query.getUserName()%>"
									>
									</aui:input>
								</aui:col>
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="createDate"
										label="SXcrfAutoquery.query.comfirm.date"
										helpMessage="SxcrfForm.subject.id.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<%
									int createDateYearVal = 0;
									int createDateMonVal = -1;
									int createDateDayVal = 0;
									if(Validator.isNotNull(query)){
										Calendar cal = Calendar.getInstance();
										Date createDate = query.getCreateDate();
										if(Validator.isNotNull(createDate)){
											cal.setTime(createDate);
											createDateYearVal = cal.get(Calendar.YEAR);
											createDateMonVal = cal.get(Calendar.MONTH);
											createDateDayVal = cal.get(Calendar.DATE);
										}
									}
								%>
								<aui:col md="3" cssClass="marTr">
									<liferay-ui:input-date
										cssClass="search-input h35"
										name="createDate"
										nullable="true"
										showDisableCheckbox="false"
										yearParam="createYear"
										yearValue="<%=createDateYearVal %>"
										monthParam="createMonth"
										monthValue="<%=createDateMonVal %>"
										dayParam="createDay"
										dayValue="<%=createDateDayVal %>"
									/>
								</aui:col>
							</aui:row>
							<aui:row cssClass="marBrh">
								<aui:col md="12">
									<span class="sub-title-span">
										<liferay-ui:message key="SXcrfAutoquery.query.comfirm.context" />
									</span>
								</aui:col>
							</aui:row>
							<aui:row cssClass="top-border">
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="queryChangeValue"
										label="SXcrfAutoquery.query.changevalue"
										helpMessage="SxcrfForm.subject.id.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3" cssClass="marTr">
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
							<aui:row cssClass="top-border">
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="queryComment"
										label="SXcrfAutoquery.query.comment"
										helpMessage="SxcrfForm.subject.id.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="9" cssClass="marTr">
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
							<aui:row cssClass="marBrh">
								<aui:col md="12">
									<span class="sub-title-span">
										<liferay-ui:message key="SXcrfAutoquery.query.comfirm" />
									</span>
								</aui:col>
							</aui:row>
							<aui:row cssClass="top-border">
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="queryComfirm"
										label="SXcrfAutoquery.query.comfirm"
										helpMessage="SxcrfForm.subject.id.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
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
								<aui:col md="9" cssClass="marTrh">
									<aui:fieldset cssClass="">
										<aui:input type="radio" name="queryComfirm" value="0" cssClass="search-input" label="SXcrfAutoquery.query.comfirm.processing" checked="<%=processing %>"></aui:input>
										<aui:input type="radio" name="queryComfirm" value="1" cssClass="search-input" label="SXcrfAutoquery.query.comfirm.refuse" checked="<%=refuse %>"></aui:input>
										<aui:input type="radio" name="queryComfirm" value="2" cssClass="search-input" label="SXcrfAutoquery.query.comfirm.accept" checked="<%=accept %>"></aui:input>
									</aui:fieldset>
								</aui:col>
							</aui:row>
							<aui:row cssClass="top-border">
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="queryComfirmUserName"
										label="SXcrfAutoquery.query.comfirm.user"
										helpMessage="SxcrfForm.subject.id.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3" cssClass="marTr">
									<aui:input
										cssClass="search-input h35"
										name="queryComfirmUserName"
										label=" "
										placeholder=""
										value="<%= Validator.isNull(query) ? StringPool.BLANK : query.getQueryComfirmUserName()%>"
									>
									</aui:input>
								</aui:col>
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="modifiedDate"
										label="SXcrfAutoquery.query.comfirm.date"
										helpMessage="SxcrfForm.subject.id.help"
										cssClass=""
									>
									</aui:field-wrapper>
								</aui:col>
								<%
									int modifiedDateYearVal = 0;
									int modifiedDateMonVal = -1;
									int modifiedDateDayVal = 0;
									if(Validator.isNotNull(query) && query.getQueryComfirm() != 0){
										Calendar cal = Calendar.getInstance();
										Date modifiedDate = query.getModifiedDate();
										if(Validator.isNotNull(modifiedDate)){
											cal.setTime(modifiedDate);
											modifiedDateYearVal = cal.get(Calendar.YEAR);
											modifiedDateMonVal = cal.get(Calendar.MONTH);
											modifiedDateDayVal = cal.get(Calendar.DATE);
										}
									}
								%>
								<aui:col md="3" cssClass="marTr">
									<liferay-ui:input-date
										cssClass="search-input h35"
										name="modifiedDate"
										nullable="true"
										showDisableCheckbox="false"
										yearParam="modifiedYear"
										yearValue="<%=modifiedDateYearVal %>"
										monthParam="modifiedMonth"
										monthValue="<%=modifiedDateMonVal %>"
										dayParam="modifiedDay"
										dayValue="<%=modifiedDateDayVal %>"
									/>
								</aui:col>
							</aui:row>
							<aui:row>
								<aui:col md="12">
									<aui:button-row cssClass="marL10">
										<aui:button type="button" name="save" value="<%=isUpdate ? "SxcrfForm.update.save-btn" : "SxcrfForm.update.add-btn" %>" cssClass="add-btn medium-btn radius-btn"></aui:button>
										<aui:button type="button" name="cancel" value="<%=isUpdate ? "SxcrfForm.update.list-btn" : "SxcrfForm.update.cancel-btn" %>" cssClass="cancel-btn medium-btn radius-btn" onClick="location.href = 'query'"></aui:button>
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

<aui:script use="aui-base">
A.one("#<portlet:namespace/>save").on("click", function(event) {	
	var form = A.one('#<portlet:namespace/>updateQueryFm');
	form.submit();
});
</aui:script>