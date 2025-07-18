<%@page import="ecrf.user.constants.attribute.ECRFUserAttributes"%>
<%@ include file="../../init.jsp" %>

<%! private Log _log = LogFactoryUtil.getLog("html/crf-data/other/view-history.jsp"); %>

<%	
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

	String menu = ECRFUserMenuConstants.LIST_HISTORY;
	
	Date createDate = (Date)renderRequest.getAttribute(ECRFUserAttributes.CREATE_DATE);	
	String[][] termList = (String[][])renderRequest.getAttribute(ECRFUserCRFDataAttributes.TERM_LIST);
	Subject subject = (Subject)renderRequest.getAttribute(ECRFUserCRFDataAttributes.SUBJECT);	
%>

<portlet:renderURL var="listHistoryURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME%>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_DATA_HISTORY%>"/>
	<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
	<portlet:param name="<%=WebKeys.REDIRECT%>" value="<%=currentURL %>" />
</portlet:renderURL>

<div class="ecrf-user-crf-data ecrf-user">

	<%@ include file="sidebar.jspf" %>
	
	<div class="page-content">
		
		<div class="crf-header-title">
			<% DataType titleDT = DataTypeLocalServiceUtil.getDataType(dataTypeId); %>
			<liferay-ui:message key="ecrf-user.general.crf-title-x" arguments="<%=titleDT.getDisplayName(themeDisplay.getLocale()) %>" />
		</div>
		
		<liferay-ui:header backURL="<%=redirect %>" title='ecrf-user.crf-data.title.view-history' />
		
		<aui:container cssClass="radius-shadow-container">
			<aui:row>
				<aui:col>
					<aui:fieldset-group markupView="lexicon">
						<aui:fieldset cssClass="search-option radius-shadow-container" collapsed="<%=false %>" collapsible="<%=true %>" label="ecrf-user.subject.title.subject-info">
							<aui:row cssClass="top-border">
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="serialId"
										label="ecrf-user.subject.serial-id">
										<p><%=Validator.isNull(subject) ? "-" : String.valueOf(subject.getSerialId()) %></p>
									</aui:field-wrapper>
								</aui:col>
								<%
								String subjectName = subject.getName();
								boolean hasViewEncryptPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_ENCRYPT_SUBJECT);
								if(!hasViewEncryptPermission)
									subjectName = ECRFUserUtil.encryptName(subjectName);	
								%>
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="name"
										label="ecrf-user.subject.name">
										<p><%=Validator.isNull(subject.getName()) ? "-" : subjectName %></p>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="gender"
										label="ecrf-user.subject.gender">
										<p><%=Validator.isNull(subject) ? "-" : (subject.getGender() == 0 ? "male" : "female") %></p>
									</aui:field-wrapper>
								</aui:col>
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="birth"
										label="ecrf-user.subject.birth-age">
										<p><%=Validator.isNull(subject) ? "-" : sdf.format(subject.getBirth()) + " (" + Math.abs(124 - subject.getBirth().getYear()) + ")" %></p>
									</aui:field-wrapper>
								</aui:col>
							</aui:row>
							
							<aui:row cssClass="top-border">
								<aui:col md="3" cssClass="marTr">
									<aui:field-wrapper
										name="createDate"
										label="ecrf-user.general.create-date">
										<p><%=Validator.isNull(subject) ? "-" : sdf.format(createDate) %></p>
									</aui:field-wrapper>
								</aui:col>
							</aui:row>
						</aui:fieldset>
					</aui:fieldset-group>
				</aui:col>
				
				<aui:col md="12">
					<table class="table crfHistory">
						<thead>
							<th style="text-align: center;">Term Name</th>
							<th style="text-align: center;">Previous</th>
							<th style="text-align: center;">Current</th>
							<th style="text-align: center;">ActionType</th>							
						<thead>
						<tbody style="text-align: center;">
							<%for(int i = 0; i < termList.length; i++){ 
								if(Validator.isNull(termList[i][0])){
									break;
								}									
							%>
							<tr>
								<td><%=termList[i][0] %></td>
								<td><%=termList[i][1] %></td>
								<td><%=termList[i][2] %></td>
								<td><%=termList[i][3] %></td>
							</tr>
							<%} %>
						</tbody>
					</table>
				</aui:col>
			</aui:row>	
			
			<aui:row>
				<aui:col md="12">
					<aui:button-row cssClass="marL10">
						<button id="<portlet:namespace/>back" type="button" class="dh-icon-button back-btn w130" onclick="location.href='<%=listHistoryURL %>'">
							<img class="back-icon" />					
							<span><liferay-ui:message key="ecrf-user.button.back"/></span>
						</button>
					</aui:button-row>
				</aui:col>
			</aui:row>				
		</aui:container>
	</div>
</div>
		