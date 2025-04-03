<%@page import="java.text.ParseException"%>
<%@page import="com.liferay.portal.kernel.portlet.LiferayPortletURL"%>
<%@page import="com.sx.icecap.service.StructuredDataLocalServiceUtil"%>
<%@page import="ecrf.user.constants.attribute.ECRFUserCRFSubjectInfoAttribute"%>
<%@page import="ecrf.user.model.CRFAutoquery"%>
<%@page import="com.sx.icecap.service.DataTypeStructureLocalServiceUtil"%>
<%@page import="ecrf.user.service.CRFAutoqueryLocalServiceUtil"%>
<%@page import="ecrf.user.crf.util.data.CRFGroupCaculation"%>
<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html.crf-data.dialog.crf_data_selector_jsp"); %>

<%
SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/M/d");
SimpleDateFormat dateFormatWithTime = new SimpleDateFormat("yyyy/M/d HH:mm"); 

long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID);

ArrayList<LinkCRF> linkList = (ArrayList<LinkCRF>)renderRequest.getAttribute(ECRFUserCRFDataAttributes.STRUCTURED_DATA_LIST);

boolean isAudit = ParamUtil.getBoolean(renderRequest, ECRFUserCRFDataAttributes.IS_AUDIT, false);
boolean isDelete = ParamUtil.getBoolean(renderRequest, ECRFUserCRFDataAttributes.IS_DELETE, false);

_log.info("isAudit / isDelete : " + isAudit + " / " + isDelete);

String progressPercentage = "0%";
String eachPercentage = "Group1:0% Group2:0% Group3:0% Group4:0% Group5:0% Group6:0% Group7:0%";

boolean hasForm = (boolean)renderRequest.getAttribute(ECRFUserCRFDataAttributes.HAS_FORM);

boolean updateLock = (boolean)renderRequest.getAttribute(ECRFUserCRFSubjectInfoAttribute.UPDATE_LOCK);

_log.info("update lock : " + updateLock);

String baseURL = ParamUtil.getString(renderRequest, "baseURL");
_log.info("base url : " + baseURL);
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
				if(Validator.isNotNull(linkList)){
					for(int i = linkList.size() - 1; i >= 0; i--){
						LinkCRF link = linkList.get(i);
						JSONObject answerForm = JSONFactoryUtil.createJSONObject(DataTypeLocalServiceUtil.getStructuredData(link.getStructuredDataId()));

						String dateStr = "";
           				Date visitDate = null;
						if(Validator.isNotNull(answerForm) && answerForm.has("visit_date")){
							dateStr = answerForm.getString("visit_date");
							
							try {
								visitDate = new Date(Long.valueOf(dateStr));
							} catch(NumberFormatException nfe) {
								SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
								try {
									visitDate = format.parse(dateStr);
								} catch(ParseException pe) {
									pe.printStackTrace();
								}
							}
							
						}
						Date modifiedDate = link.getModifiedDate();
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

								CRFGroupCaculation groupApi = new CRFGroupCaculation();
								int totalLength = groupApi.getTotalLength(dataTypeId);
								JSONObject termPackage = groupApi.getEachGroupProgress(dataTypeId, answerForm);
								
								CRFProgressUtil progressApi = new CRFProgressUtil(renderRequest, dataTypeId, answerForm);
								progressPercentage = String.valueOf(progressApi.getProgressPercentage()) + "%";
								
								boolean hasQuery = false;
								if(CRFAutoqueryLocalServiceUtil.countQueryBySdId(link.getStructuredDataId()) > 0){
									List<CRFAutoquery> queryList = CRFAutoqueryLocalServiceUtil.getQueryBySId(subjectId);
									for(int queryIdx = 0; queryIdx < queryList.size(); queryIdx++){
										CRFAutoquery query = queryList.get(queryIdx);
										if(query.getQueryComfirm() != 2){
											hasQuery = true;
											break;
										}
									}
								}
								
								progressSrc = progressApi.getProgressImg(progressApi.getProgressPercentage(), hasQuery);
								eachPercentage = progressApi.getProgressByGroup();
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
							
							<td>
								<aui:button name="deleteCRF" type="button" value="ecrf-user.crf-data.delete-crf" cssClass="delete-btn small-btn" onClick="<%="deleteEachCRF(" + link.getLinkId() +")"%>"></aui:button>							
							</td>
							
							</c:otherwise>
							</c:choose>
						
						</c:when>
						
						<c:when test="<%=isAudit %>">
						
						<% String auditFunctionCall = String.format("toEachCRF(%d, %d)", link.getStructuredDataId(), 1); %>
						<td>
							<aui:button name="auditCRF" type="button" value="<%=updateLock ? "ecrf-user.button.view-crf-data" : "ecrf-user.button.view-audit" %>" cssClass="ci-btn small-btn" onClick="<%=auditFunctionCall%>"></aui:button>
						</td>
						
						</c:when>
						
						<c:otherwise>
							
							<c:choose>
							<c:when test="<%=updateLock %>">
							
							<% String viewFunctionCall = String.format("toViewCRF(%d)", link.getStructuredDataId()); %>
							<td>
								<aui:button name="viewCRF" type="button" value="ecrf-user.button.view-crf-data" cssClass="ci-btn small-btn" onClick="<%=viewFunctionCall%>"></aui:button>
							</td>
							
							</c:when>
							<c:otherwise>
							
							<% String updateFunctionCall = String.format("toEachCRF(%d, %d)", link.getStructuredDataId(), 0); %>
							<td>
								<aui:button name="updateCRF" type="button" value="ecrf-user.button.update-crf-data" cssClass="ci-btn small-btn" onClick="<%=updateFunctionCall%>"></aui:button>
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
		
		<c:if test="false">
		<aui:row>
			<aui:col cssClass="center">
				<liferay-ui:message key="ecrf-user.validation.no-crf-form" />
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col cssClass="center">
				<span>
				<liferay-ui:message key="ecrf-user.crf-data.db-lock" />
				</span>
			</aui:col>
		</aui:row>
		</c:if>
		
		<c:choose>
		<c:when test="<%=!hasForm %>">
			<aui:row>
				<aui:col cssClass="center">
					<span class="marTr" style="font-weight:600;">
					<liferay-ui:message key="ecrf-user.validation.no-crf-form" />
					</span>
				</aui:col>
			</aui:row>
		</c:when>
		<c:when test="<%=updateLock %>">
			<aui:row>
				<aui:col cssClass="center">
					<span class="marTr" style="font-weight:600;">
					<liferay-ui:message key="ecrf-user.crf-data.db-lock" />
					</span>
				</aui:col>
			</aui:row>	
		</c:when>
		</c:choose>
	
		<!--
		<aui:button name="crfFormNotice" type="button" value="ecrf-user.validation.no-crf-form" cssClass="none-btn full-btn" disabled="true"></aui:button> 
		<aui:button name="dbLockNotice" type="button" value="ecrf-user.crf-data.db-lock" cssClass="none-btn full-btn" disabled="true"></aui:button>
	 	-->
	 	
	</aui:container>
</div>

<script>
function toViewCRF(sdId){
	Liferay.Util.getOpener().moveViewCRFData(<%=subjectId %>, <%=crfId%>, sdId, <%=CRFLocalServiceUtil.getCRF(crfId).getDefaultUILayout()%>, '<portlet:namespace/>multiCRFDialog', '<%=themeDisplay.getPortletDisplay().getId() %>', <%=themeDisplay.getPlid() %>, '<%=baseURL%>');
}

function toEachCRF(sdId, isAudit){
	console.log("<%=baseURL%>");
	Liferay.Util.getOpener().moveUpdateCRFData(<%=subjectId %>, <%=crfId%>, sdId, isAudit, <%=CRFLocalServiceUtil.getCRF(crfId).getDefaultUILayout()%>, '<portlet:namespace/>multiCRFDialog', '<%=themeDisplay.getPortletDisplay().getId() %>', <%=themeDisplay.getPlid() %>, '<%=baseURL%>');	
}

function deleteEachCRF(linkCrfId){
	// cant use general confirm dialog code, need to change ok action function
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
					Liferay.Util.getOpener().deleteCRFData(linkCrfId, <%=crfId%>, '<portlet:namespace/>multiCRFDialog', '<%=themeDisplay.getPortletDisplay().getId() %>', <%=themeDisplay.getPlid() %>, '<%=baseURL%>');				
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