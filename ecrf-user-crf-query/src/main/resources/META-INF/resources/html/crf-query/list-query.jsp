<%@page import="ecrf.user.constants.attribute.ECRFUserCRFDataAttributes"%>	
<%@ include file="../init.jsp" %>
<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
		
	String menu = "crf-query-list";
	
	ArrayList<CRFAutoquery> queryList = new ArrayList<CRFAutoquery>();
	queryList.addAll(CRFAutoqueryLocalServiceUtil.getQueryByGroupCRF(scopeGroupId, crfId));
	
	PortletURL portletURL = renderResponse.createRenderURL();
	
	portletURL.setParameter("jspPage", ECRFUserJspPaths.JSP_LIST_QUERY);
%>

<portlet:renderURL var="searchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_QUERY%>"/>
	<portlet:param name="isSearch" value="true"/>
</portlet:renderURL>

<portlet:renderURL var="clearSearchURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_QUERY%>"/>	
</portlet:renderURL>

<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_ALL_CRF_QUERY %>" var="deleteAllQueryURL">
	<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
</liferay-portlet:actionURL>

<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_ALL_CRF_QUERY%>" var="addAllQueryURL">
	<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
</liferay-portlet:actionURL>

<div class="ecrf-user ecrf-user-query SXCRFAutoquery">

	<%@ include file="sidebar.jspf" %>
	
	<div class="page-content">
		
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.crf-query.title.query-list" />
				
		<aui:form action="${searchURL}" name="searchOptionFm" autocomplete="off" cssClass="marBr">
			<aui:container cssClass="radius-shadow-container">
				<aui:row>
					<aui:col md="4">
						<aui:field-wrapper
							name="userId"
							label="SXcrfAutoquery.user.id"
							helpMessage="SXcrfAutoquery.user.id.help"
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
							label="SXcrfAutoquery.user.name"
							helpMessage="SXcrfAutoquery.user.name.help"
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
							label="SXcrfAutoquery.query.comfirm"
							helpMessage="SXcrfAutoquery.query.comfirm"
							cssClass="marBrh"
						>
							<aui:fieldset cssClass="">
								<aui:input type="radio" name="queryComfirm" value="0" cssClass="search-input" label="SXcrfAutoquery.query.comfirm.processing" ></aui:input>
								<aui:input type="radio" name="queryComfirm" value="1" cssClass="search-input" label="SXcrfAutoquery.query.comfirm.accept" ></aui:input>
								<aui:input type="radio" name="queryComfirm" value="2" cssClass="search-input" label="SXcrfAutoquery.query.comfirm.refuse" ></aui:input>
							</aui:fieldset>
						</aui:field-wrapper>
					</aui:col>
				</aui:row>
				<aui:row>
					<aui:col md="12">
						<aui:button-row cssClass="right marVr">
							<aui:button name="search" cssClass="add-btn medium-btn radius-btn"  type="submit" value="SxcrfForm.list.search-btn"></aui:button>
							<aui:button name="clear" cssClass="reset-btn medium-btn radius-btn" type="button" value="SxcrfForm.list.clear-btn" onClick="<%=clearSearchURL %>"></aui:button>
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
				<liferay-ui:search-container-column-text
					name="SXcrfForm.subject.id"
					property="subjectId"
				/>
				<liferay-ui:search-container-column-text
					name="SXcrfForm.subject.crf.id"
					property="queryTermId"
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
					name="SXcrfAutoquery.query.termname"
					value="<%=displayName %>"
				/>
				<liferay-ui:search-container-column-text
					name="SXcrfAutoquery.query.value"
					property="queryValue"
				/>
				<liferay-ui:search-container-column-text
					name="SXcrfAutoquery.query.prevalue"
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
					name="SXcrfAutoquery.query.querytype"
					value="<%=queryTypeStr %>"
				/>
				<liferay-ui:search-container-column-text
					name="SXcrfAutoquery.query.comment"
					property="queryComment"
				/>
				<liferay-ui:search-container-column-text
					name="SXcrfAutoquery.query.createdate"
					value="<%=Validator.isNull(crfAutoquery.getCreateDate()) ? "-" : sdf.format(crfAutoquery.getCreateDate()) %>"				/>
				<liferay-ui:search-container-column-text
					name="SXcrfAutoquery.query.comfirm.date"
					value="<%=Validator.isNull(crfAutoquery.getQueryComfirmDate()) ? "-" : sdf.format(crfAutoquery.getQueryComfirmDate()) %>"
				/>
				<liferay-ui:search-container-column-text
					name="SXcrfAutoquery.user.name"
					property="userName"
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
					name="SXcrfAutoquery.query.comfirm"
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
				<!-- History button -->
				
				<liferay-ui:search-container-column-text
					name="SXcrfAutoquery.query.edit-btn"
					cssClass="min-width-80"
				>
					<aui:button name="updateQuery" type="button" value="SXcrfAutoquery.query.edit-btn" cssClass="edit-btn small-btn" onClick="<%=updateQueryURL%>"></aui:button>
				</liferay-ui:search-container-column-text>
			
			</liferay-ui:search-container-row>
			<liferay-ui:search-iterator
				displayStyle="list"
				markupView="lexicon"
				paginate="<%=true %>"
				searchContainer="<%=searchContainer%>"
			/>
		</liferay-ui:search-container>
		<aui:row>
			<aui:col>
				<aui:button-row cssClass="marL10">
					<aui:button type="button" name="delete" value="delete all query" style="" cssClass="delete-btn medium-btn radius-btn" onClick="<%=deleteAllQueryURL%>"></aui:button>
					<aui:button type="button" name="add" value="add all query" style="" cssClass="add-btn medium-btn radius-btn" onClick="<%=addAllQueryURL%>"></aui:button>
				</aui:button-row>
				
			</aui:col>
		</aui:row>	
	</div>
</div>