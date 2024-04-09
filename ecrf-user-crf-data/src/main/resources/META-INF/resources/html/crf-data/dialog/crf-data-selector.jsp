<%@page import="ecrf.user.constants.attribute.ECRFUserCRFSubjectInfoAttribute"%>
<%@page import="ecrf.user.model.CRFAutoquery"%>
<%@page import="com.sx.icecap.service.DataTypeStructureLocalServiceUtil"%>
<%@page import="ecrf.user.service.CRFAutoqueryLocalServiceUtil"%>
<%@page import="ecrf.user.crf.data.util.CRFGroupCaculation"%>
<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html.crf-data.dialog.crf_data_selector_jsp"); %>

<%
SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/M/d");
SimpleDateFormat dateFormatWithTime = new SimpleDateFormat("yyyy/M/d HH:mm"); 

long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID);

ArrayList<StructuredData> sdList = (ArrayList<StructuredData>)renderRequest.getAttribute(ECRFUserCRFDataAttributes.STRUCTURED_DATA_LIST);

boolean isAudit = ParamUtil.getBoolean(renderRequest, ECRFUserCRFDataAttributes.IS_AUDIT, false);
boolean isDelete = ParamUtil.getBoolean(renderRequest, ECRFUserCRFDataAttributes.IS_DELETE, false);

_log.info("isAudit / isDelete : " + isAudit + " / " + isDelete);

String progressPercentage = "0%";
String eachPercentage = "Group1:0% Group2:0% Group3:0% Group4:0% Group5:0% Group6:0% Group7:0%";

boolean hasForm = (boolean)renderRequest.getAttribute(ECRFUserCRFDataAttributes.HAS_FORM);

boolean updateLock = (boolean)renderRequest.getAttribute(ECRFUserCRFSubjectInfoAttribute.UPDATE_LOCK);

_log.info("update lock : " + updateLock);
%>
<div class="ecrf-user-crf-data ecrf-user">
	<aui:container cssClass="">
		<aui:row>
			<aui:col md="12">
			<table class="table crfHistory">
				<thead>
					<tr>
						<th>No</th>
						<th>Visit Date</th>
						<th>Modified Date</th>
						<th>Progress</th>
						<th>Query</th>
						<th>Edit</th>
					<tr>
				</thead>
				<tbody style="text-align: center;">
				<%
				if(Validator.isNotNull(sdList)){
					for(int i = sdList.size() - 1; i >= 0; i--){
						StructuredData sd = sdList.get(i);						
						JSONObject answerForm = JSONFactoryUtil.createJSONObject(sd.getStructuredData());
						String dateStr = "";
				        Date visitDate = null;
						if(Validator.isNotNull(answerForm) && answerForm.has("visit_date")){
							visitDate = new Date(Long.valueOf(answerForm.getString("visit_date")));
						}
						Date modifiedDate = sd.getModifiedDate();
						
						LinkCRF link = LinkCRFLocalServiceUtil.getLinkCRFByC_S_SD(crfId, subjectId, sd.getStructuredDataId());
				%>
					<tr>
						<td><%=i+1%></td>
						<td><%=dateFormat.format(visitDate) %></td>
						<td><%=dateFormatWithTime.format(modifiedDate) %></td>
						<%
							String progressBarCss = "progressBar";				
							boolean isWord = false;
							String progressSrc = renderRequest.getContextPath() + "/img/empty_progress.png";

							if(Validator.isNotNull(answerForm)){
								int notAnswerCount = 0;
								Iterator<String> keys = answerForm.keys();
								while(keys.hasNext()){
									String key = keys.next();
									if(answerForm.getString(key).equals("-1") || answerForm.getString(key).equals("") || answerForm.getString(key).equals("[]")){
										notAnswerCount++;
									}
								}
								CRFGroupCaculation groupApi = new CRFGroupCaculation();
								int totalLength = groupApi.getTotalLength(dataTypeId);
								JSONObject termPackage = groupApi.getEachGroupProgress(dataTypeId, answerForm);
								if(termPackage.length() > 0){
									eachPercentage = "";
									Iterator<String> groups = termPackage.keys();
									while(groups.hasNext()){
										String group = groups.next();
										eachPercentage = eachPercentage + groupApi.getDisplayName(dataTypeId, group) + ": " + termPackage.getJSONObject(group).getString("percent") + " (" + termPackage.getJSONObject(group).getString("total") +") "; 
									}
								}
								if(totalLength > 0){
									int answers = answerForm.length() - notAnswerCount;
									int percent = Math.round(answers * 100 / totalLength);
									progressPercentage = String.valueOf(percent) + "%";
									if(!isWord){
										progressSrc = renderRequest.getContextPath() + "/img/empty_progress.png";
										if(percent >= 100){
											progressSrc = renderRequest.getContextPath()+"/img/complete_progress.png";
											if(CRFAutoqueryLocalServiceUtil.countQueryBySdId(sd.getStructuredDataId()) > 0){
												List<CRFAutoquery> queryList = CRFAutoqueryLocalServiceUtil.getQueryBySId(subjectId);
												for(int k = 0; k < queryList.size(); k++){
													if(queryList.get(k).getQueryTermId() == sd.getStructuredDataId() && queryList.get(k).getQueryComfirm() < 2){
														progressSrc = renderRequest.getContextPath()+"/img/incomplete_autoqueryerror.png";
													}
												}
											}
										}
										else {
											progressSrc = renderRequest.getContextPath()+"/img/incomplete_progress.png";
											if(CRFAutoqueryLocalServiceUtil.countQueryBySdId(sd.getStructuredDataId()) > 0){
												List<CRFAutoquery> queryList = CRFAutoqueryLocalServiceUtil.getQueryBySId(subjectId);
												for(int k = 0; k < queryList.size(); k++){
													if(queryList.get(k).getQueryTermId() == sd.getStructuredDataId() && queryList.get(k).getQueryComfirm() < 2){
														progressSrc = renderRequest.getContextPath()+"/img/incomplete_autoqueryerror.png";
													}
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
						%>		
						<td>
							<p style="text-align: center; background-image: linear-gradient(to right, #11aaff <%=progressPercentage%>, #aaa 0%); margin-bottom: 0px; padding: 4px;"><%=progressPercentage%><liferay-ui:icon icon="info-sign" message="<%=eachPercentage%>" /></p>
						</td>
						<td>
							<img src="<%= progressSrc%>" width="50%" height="auto"/>
						</td>
						<c:choose>
						<c:when test="<%=isDelete %>">
						
							<c:choose>
							<c:when test="<%=updateLock %>">						
							<td>
								<liferay-ui:message key="ecrf-user.crf-data.db-lock" />
							</td>
							</c:when>
							<c:otherwise>
							<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_DELETE_CRF_DATA %>" var="deleteCRFDataURL">
								<portlet:param name="<%=ECRFUserCRFDataAttributes.LINK_CRF_ID %>" value="<%=String.valueOf(link.getLinkId()) %>" />
							</portlet:actionURL>						
							<td>
								<aui:button name="deleteCRF" type="button" value="ecrf-user.crf-data.delete-crf" cssClass="delete-btn small-btn" onClick="<%="deleteEachCRF(" + link.getLinkId() +")"%>"></aui:button>							
							</td>
							</c:otherwise>
							</c:choose>
						
						</c:when>
						<c:when test="<%=isAudit %>">
						
						<% String auditFunctionCall = String.format("toEachCRF(%d, %d)", sd.getStructuredDataId(), 1); %>
						<td>
							<aui:button name="auditCRF" type="button" value="view Audit Trail" cssClass="ci-btn small-btn" onClick="<%=auditFunctionCall%>"></aui:button>
						</td>
						
						</c:when>
						<c:otherwise>
							
							<c:choose>
							<c:when test="<%=updateLock %>">
							<% String viewFunctionCall = String.format("toViewCRF(%d)", sd.getStructuredDataId()); %>
							<td>
								<aui:button name="viewCRF" type="button" value="View CRF Data" cssClass="ci-btn small-btn" onClick="<%=viewFunctionCall%>"></aui:button>
							</td>
							</c:when>
							<c:otherwise>
							<% String updateFunctionCall = String.format("toEachCRF(%d, %d)", sd.getStructuredDataId(), 0); %>
							<td>
								<aui:button name="updateCRF" type="button" value="Edit CRF Data" cssClass="ci-btn small-btn" onClick="<%=updateFunctionCall%>"></aui:button>
							</td>
							</c:otherwise>
							</c:choose>
							
						</c:otherwise>
						</c:choose>
					</tr>
				<%
					}
				}
				%>
				</tbody>
			</table>
			</aui:col>
		</aui:row>
		<%
		String auditHidden = "";
		String deleteHidden = "";
		if(isAudit){
			auditHidden = "hide";
		}
		else{
			auditHidden = "ci-btn small-btn";
		}
		
		if(isDelete){
			deleteHidden = "delete-btn small-btn";
			auditHidden = "hide";					
		}else{
			deleteHidden = "hide";
		}
		
		if(!hasForm) {
			auditHidden = "hide";
		}
		%>
		
		<c:if test="<%=!hasForm %>">
		<aui:row>
			<aui:col cssClass="center">
				<liferay-ui:message key="ecrf-user.validation.no-crf-form" />
			</aui:col>
		</aui:row>
		</c:if>
		
		<c:choose>
		<c:when test="<%=updateLock %>">
		<aui:row>
			<aui:col cssClass="center">
				<liferay-ui:message key="ecrf-user.crf-data.db-lock" />
			</aui:col>
		</aui:row>
		</c:when>
		<c:otherwise>
			<aui:button name="addCRF" type="button" value="Add New CRF Data" cssClass="<%=auditHidden %>"></aui:button>
		</c:otherwise>
		</c:choose>

	</aui:container>
</div>

<script>
function toViewCRF(sdId){
	Liferay.Util.getOpener().moveViewCRFData(<%=subjectId %>, <%=crfId%>, sdId, '<portlet:namespace/>multiCRFDialog', '<%=themeDisplay.getPortletDisplay().getId() %>', <%=themeDisplay.getPlid() %>);
}

function toEachCRF(sdId, isAudit){
	Liferay.Util.getOpener().moveUpdateCRFData(<%=subjectId %>, <%=crfId%>, sdId, isAudit, '<portlet:namespace/>multiCRFDialog', '<%=themeDisplay.getPortletDisplay().getId() %>', <%=themeDisplay.getPlid() %>);	
}

function deleteEachCRF(linkCrfId){
	Liferay.Util.getOpener().moveDeleteCRFData(linkCrfId, '<portlet:namespace/>multiCRFDialog', '<%=themeDisplay.getPortletDisplay().getId() %>', <%=themeDisplay.getPlid() %>);	
}
</script>

<aui:script use="aui-base">
A.one("#<portlet:namespace/>addCRF").on("click", function(event) {
	Liferay.Util.getOpener().moveAddCRFData(<%=subjectId %>, <%=crfId %>, '<portlet:namespace/>multiCRFDialog', '<%=themeDisplay.getPortletDisplay().getId() %>', <%=themeDisplay.getPlid() %>);	
});
</aui:script>