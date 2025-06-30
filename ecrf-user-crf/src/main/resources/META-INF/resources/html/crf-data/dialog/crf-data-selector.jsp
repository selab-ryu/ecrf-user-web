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

boolean isUpdate = ParamUtil.getBoolean(renderRequest, ECRFUserCRFDataAttributes.IS_UPDATE, false);
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
				<%
					String actionColHeader = "ecrf-user.button.update-crf-data";
					if(isAudit) {
						actionColHeader = "ecrf-user.button.view-audit";
						if(updateLock) actionColHeader = "ecrf-user.button.view-crf-data";
					}
					if(isDelete) actionColHeader = "ecrf-user.button.delete-crf-data";
				%>
				<thead>
					<tr>
						<th>No</th>
						<th>Visit Date</th>
						<th>Modified Date</th>
						<th>Progress</th>
						<th>Query</th>
						<th><liferay-ui:message key="<%=actionColHeader %>" /></th>
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
							_log.info(dateStr);
							try {
								visitDate = new Date(Long.valueOf(dateStr));
							} catch(NumberFormatException nfe) {
								SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
								try {
									visitDate = format.parse(dateStr);
								} catch(ParseException pe) {
									try {
										format = new SimpleDateFormat("yyyy-MM-dd");
										visitDate = format.parse(dateStr);
									} catch(NullPointerException npe) {
										npe.printStackTrace();
									}
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
							<img src="<%=progressSrc%>" width="50%" height="auto"/>
						</td>
						
						<c:if test="<%=isUpdate %>">
							<% String updateFncCall = String.format("toEachCRF(%d, %d)", link.getStructuredDataId(), 0); %>
							<td>
								<button id="updateCRF" type="type" class="dh-icon-button update-btn w130" onclick="<%=updateFncCall %>" >		
									<img class="update-icon" />
									<span><liferay-ui:message key="ecrf-user.button.update-crf-data"/></span>			
								</button>							
							</td>
						</c:if>
												
						<c:if test="<%=isAudit %>">
							<% 
								String auditFncCall = String.format("toEachCRF(%d, %d)", link.getStructuredDataId(), 1);
								String auditBtnKey = "ecrf-user.button.view-audit";
								if(updateLock) auditBtnKey = "ecrf-user.button.view-crf-data";
							%>
							<td>
								<button id="auditCRF" type="button" class="dh-icon-button audit-trail-btn w180" onclick="<%=auditFncCall %>" >		
									<img class="audit-icon" />
									<span><liferay-ui:message key="<%=auditBtnKey %>"/></span>			
								</button>							
							</td>
						</c:if>
						
						<c:if test="<%=isDelete %>">
							<% String deleteFncCall = "deleteEachCRF("+link.getLinkId()+")"; %>	
							<td>
								<button id="deleteCRF" type="button" class="dh-icon-button delete-btn w130" onclick="<%=deleteFncCall %>" >		
									<img class="delete-icon" />
									<span><liferay-ui:message key="ecrf-user.button.delete-crf-data"/></span>			
								</button>							
							</td>
						</c:if>
						
					</tr>
				<%
					}
				}
				%>
				</tbody>
			</table>
			</aui:col>
		</aui:row>
		
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