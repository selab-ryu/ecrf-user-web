<%@page import="com.sx.icecap.constant.IcecapWebPortletKeys"%>
<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf/update-crf-data_jsp"); %>

<%
SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd");
SimpleDateFormat dateFormatWithTime = new SimpleDateFormat("yyyy/MM/dd HH:mm");

long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);

System.out.println("view-crf / subject id: "+subjectId);
System.out.println("dataTypeId : " + dataTypeId);

Subject subject = null;
LinkCRF linkCRF = null;

if(subjectId > 0) {
	subject = (Subject)renderRequest.getAttribute(ECRFUserCRFDataAttributes.SUBJECT);
	linkCRF = (LinkCRF)renderRequest.getAttribute(ECRFUserCRFDataAttributes.LINK_CRF);
}

System.out.println("linkCRF : " + linkCRF);

JSONArray crfForm = (JSONArray)renderRequest.getAttribute(ECRFUserCRFDataAttributes.CRF_FORM);
JSONObject answerForm = null; 
Date visitDate = null;

long sdId = ParamUtil.getLong(renderRequest, "structuredDataId", 0);

if(Validator.isNotNull(linkCRF)){
	sdId = linkCRF.getStructuredDataId();
}

CRFGroupCaculation groupApi = new CRFGroupCaculation();
JSONObject eachGroups = null;

String menu = "view-crf-data";

if(sdId > 0) {			
	answerForm = (JSONObject)renderRequest.getAttribute(ECRFUserCRFDataAttributes.ANSWER_FORM);
	
	String visitDateStr = "";
	if(Validator.isNotNull(answerForm) && answerForm.has("visit_date")){
		visitDate = new Date(Long.valueOf(answerForm.getString("visit_date")));
	}
	
	eachGroups = groupApi.getEachGroupProgress(dataTypeId, answerForm);
}

ArrayList<String> mainGroups = new ArrayList<String>();
ArrayList<String> subGroups = new ArrayList<String>();

for(int i = 0; i < crfForm.length(); i++){
	if(crfForm.getJSONObject(i).getString("termType").equals("Group")){
		String termName = crfForm.getJSONObject(i).getString("termName");
		if(!termName.equals("")){
			if(crfForm.getJSONObject(i).has("groupTermId")){
				subGroups.add(termName);
			}else{
				mainGroups.add(termName);
			}
		}
	}
}
%>

<portlet:renderURL var="listCRFURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_DATA%>"/>
	<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
</portlet:renderURL>

<div class="ecrf-user-crf-data ecrf-user">

	<%@ include file="../other/sidebar.jspf" %>
	
	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect %>" title='ecrf-user.crf-data.title.view-crf-data' />
	
		<aui:fieldset-group markupView="lexicon">
			<aui:fieldset cssClass="search-option radius-shadow-container" collapsed="<%=false %>" collapsible="<%=true %>" label="SXcrfForm.update.title">
				<aui:container>
					<aui:row cssClass="top-border">
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="hospitalCode"
								label="SXcrfForm.subject.hpcode">
								<p><%=Validator.isNull(subject) ? "-" : String.valueOf(subject.getHospitalCode()) %></p>
							</aui:field-wrapper>
						</aui:col>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="subjectId"
								label="SXcrfForm.subject.id">
								<p><%=Validator.isNull(subject) ? "-" : String.valueOf(subject.getSerialId()) %></p>
							</aui:field-wrapper>
						</aui:col>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="subjectName"
								label="SXcrfForm.subject.name">
								<p><%=Validator.isNull(subject) ? "-" : subject.getName() %></p>
							</aui:field-wrapper>
						</aui:col>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="subjectSex"
								label="SXcrfForm.subject.sex">
								<p><%=Validator.isNull(subject) ? "-" : (subject.getGender() == 0 ? "male" : "female") %></p>
							</aui:field-wrapper>
						</aui:col>
					</aui:row>
					<aui:row cssClass="top-border">
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="subjectBirth"
								label="SXcrfForm.subject.birthage">
								<p><%=Validator.isNull(subject) ? "-" : dateFormat.format(subject.getBirth()) + " (" + Math.abs(124 - subject.getBirth().getYear()) + ")" %></p>
							</aui:field-wrapper>
						</aui:col>
					</aui:row>
				</aui:container>
			</aui:fieldset>
		</aui:fieldset-group>
	
		<aui:form name="viewCRFDataForm" action="" autocomplete="off" method="POST">
			<aui:input type="hidden" name="<%=ECRFUserCRFDataAttributes.SUBJECT_ID %>" value="<%=subjectId %>"></aui:input>
			<aui:input type="hidden" name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=crfId %>"></aui:input>
			
			<aui:field-wrapper
				label="ecrf-user.crf-data.visit-date">
				<p><%=Validator.isNull(visitDate) ? StringPool.DASH : dateFormat.format(visitDate)%></p>
			</aui:field-wrapper>
					
			<table class="table crfHistory crf-max-width">
			<% 
				for(int mainIdx = 0; mainIdx < mainGroups.size(); mainIdx++){
					String groupProgress = "";
					String mainGroupName = "";
					String mainGroupId = "";
					for(int crfIdx = 0; crfIdx < crfForm.length(); crfIdx++){
						if(crfForm.getJSONObject(crfIdx).getString("termName").equals(mainGroups.get(mainIdx))){
							mainGroupName = crfForm.getJSONObject(crfIdx).getJSONObject("displayName").getString("en_US");
							mainGroupId = crfForm.getJSONObject(crfIdx).getString("termName");

							if(menu.equals("is-edit") && eachGroups.has(mainGroups.get(mainIdx)) ){
								groupProgress = groupProgress + " ("+ eachGroups.getJSONObject(mainGroups.get(mainIdx)).getString("total") + " " +  eachGroups.getJSONObject(mainGroups.get(mainIdx)).getString("percent") + ")";
							}
						}
					}
			%>
				<tr>
					<th style="background-color: #AAA; width: 20%;"><%=mainGroupName %><p style="color:#5f73ff; margin-bottom:0px;"><%=groupProgress%></p></th>
				</tr>
				<%
					boolean hasSubGroup = false;
					for(int subIdx = 0; subIdx < subGroups.size(); subIdx++){
						String subGroupName = "";
						String subGroupId = "";
						
						for(int crfIdx = 0; crfIdx < crfForm.length(); crfIdx++){
							if(crfForm.getJSONObject(crfIdx).getString("termName").equals(subGroups.get(subIdx))){
								if(crfForm.getJSONObject(crfIdx).has("groupTermId")){
									if(crfForm.getJSONObject(crfIdx).getJSONObject("groupTermId").getString("name").equals(mainGroupId)){
										hasSubGroup = true;
										subGroupName = crfForm.getJSONObject(crfIdx).getJSONObject("displayName").getString("en_US");
										subGroupId = crfForm.getJSONObject(crfIdx).getString("termName");
				%>
										<tr>
											<th><%=subGroupName%></th>
										</tr>
										<tr>
				<%
										String contentName = "";
										String contentId = "";
				
										for(int i = 0; i < crfForm.length(); i++){
											if(crfForm.getJSONObject(i).has("groupTermId") && crfForm.getJSONObject(i).getJSONObject("groupTermId").getString("name").equals(subGroupId)){
												contentName = crfForm.getJSONObject(i).getJSONObject("displayName").getString("en_US");
												contentId = crfForm.getJSONObject(i).getString("termName");
												%>
													<td><%=contentName %></td>
												<%
											}
										}								
				%>
										</tr>
										<tr>
				<%
										for(int i = 0; i < crfForm.length(); i++){
											if(crfForm.getJSONObject(i).has("groupTermId") && crfForm.getJSONObject(i).getJSONObject("groupTermId").getString("name").equals(subGroupId)){
												contentName = crfForm.getJSONObject(i).getJSONObject("displayName").getString("en_US");
												contentId = crfForm.getJSONObject(i).getString("termName");
												String contentType = crfForm.getJSONObject(i).getString("termType");
												String contentValue = "";
												boolean isDisabled = crfForm.getJSONObject(i).getBoolean("disabled");
												// String | Numeric
												if(contentType.equals("String") || contentType.equals("Numeric")){
													if(Validator.isNotNull(answerForm) && answerForm.has(contentId)){
														contentValue = answerForm.getString(contentId);
														if(Validator.isNull(contentValue)) contentValue=StringPool.DASH;
													}
												%>
													<td><%=contentValue %></td>
												<%
												// List | Boolean
												}else if(contentType.equals("List") || contentType.equals("Boolean")){
													JSONArray options = crfForm.getJSONObject(i).getJSONArray("options");
													String optionType = crfForm.getJSONObject(i).getString("displayStyle");
													if(optionType.equals("select")){
												%>
													<td>
													<aui:select cssClass="search-input h35" disabled="<%=isDisabled %>" label= "" name="<%=contentId %>">
													<%
														for(int optionIdx = 0; optionIdx < options.length(); optionIdx++){
															boolean isSelected = false;
															if(Validator.isNotNull(answerForm) && answerForm.has(contentId)){
																if(answerForm.getInt(contentId) == options.getJSONObject(optionIdx).getInt("value")){
																	isSelected = true;
																}
															}
													%>
														<aui:option label="<%=options.getJSONObject(optionIdx).getJSONObject("label").getString("en_US") %>" value="<%=options.getJSONObject(optionIdx).getInt("value")%>" selected="<%=isSelected %>" />
													<%
														}
													%>
													</aui:select>
													</td>
												<%
													}
												// Date
												} else if(contentType.equals("Date")){
													String dateStr = "";
											        Date contentDate = null;
													if(Validator.isNotNull(answerForm) && answerForm.has(contentId)){
														contentDate = new Date(Long.valueOf(answerForm.getString(contentId)));
													}
													%>
													<td>
													
													<aui:field-wrapper
														label="">
														<p><%=Validator.isNull(contentDate) ? StringPool.DASH : dateFormatWithTime.format(contentDate)%></p>
													</aui:field-wrapper>
													
													</td>
												<%											
												}
											}
										}								
				%>
										</tr>
				<%
									}
									
								}
							}
						}
					}
					if(!hasSubGroup){
					%>
						<tr>
							<th><%=mainGroupName%></th>
						</tr>
						<tr>
						<%
							String contentName = "";
							String contentId = "";
	
							for(int i = 0; i < crfForm.length(); i++){
								if(crfForm.getJSONObject(i).has("groupTermId") && crfForm.getJSONObject(i).getJSONObject("groupTermId").getString("name").equals(mainGroupId)){
									contentName = crfForm.getJSONObject(i).getJSONObject("displayName").getString("en_US");
									contentId = crfForm.getJSONObject(i).getString("termName");
									boolean isDisabled = crfForm.getJSONObject(i).getBoolean("disabled");
									String disableColor = "";
									if(isDisabled){
										disableColor = "background-color: #777777;";
									}
									%>
										<td style="<%=disableColor%>"><%=contentName %></td>
									<%
								}
							}								
						%>
						</tr>
						<tr>
						<%
							for(int i = 0; i < crfForm.length(); i++){
								if(crfForm.getJSONObject(i).has("groupTermId") && crfForm.getJSONObject(i).getJSONObject("groupTermId").getString("name").equals(mainGroupId)){
									contentName = crfForm.getJSONObject(i).getJSONObject("displayName").getString("en_US");
									contentId = crfForm.getJSONObject(i).getString("termName");
									String contentType = crfForm.getJSONObject(i).getString("termType");
									String contentValue = "";
									boolean isDisabled = crfForm.getJSONObject(i).getBoolean("disabled");
									if(contentType.equals("String") || contentType.equals("Numeric")){
										if(Validator.isNotNull(answerForm) && answerForm.has(contentId)){
											contentValue = answerForm.getString(contentId);
											if(Validator.isNull(contentValue)) contentValue=StringPool.DASH;
										}
									%>
										<td><%=contentValue %></td>
									<%
									}else if(contentType.equals("List") || contentType.equals("Boolean")){
										JSONArray options = crfForm.getJSONObject(i).getJSONArray("options");
										String optionType = crfForm.getJSONObject(i).getString("displayStyle");
										if(optionType.equals("select")){
									%>
										<td>
										<aui:select cssClass="search-input h35" disabled="<%=isDisabled %>" label= "" name="<%=contentId %>">
										<%
											for(int optionIdx = 0; optionIdx < options.length(); optionIdx++){
												boolean isSelected = false;
												if(Validator.isNotNull(answerForm) && answerForm.has(contentId)){
													if(answerForm.getInt(contentId) == options.getJSONObject(optionIdx).getInt("value")){
														isSelected = true;
													}
												}
										%>
											<aui:option label="<%=options.getJSONObject(optionIdx).getJSONObject("label").getString("en_US") %>" value="<%=options.getJSONObject(optionIdx).getInt("value")%>" selected="<%=isSelected %>" />
										<%
											}
										%>
										</aui:select>
										</td>
									<%
										}
									}else if(contentType.equals("Date")){
										String dateStr = "";
								        Date contentDate = null;
										if(Validator.isNotNull(answerForm) && answerForm.has(contentId)){
											contentDate = new Date(Long.valueOf(answerForm.getString(contentId)));
										}
										%>
										<td>
										
										<aui:field-wrapper
											label="">
											<p><%=Validator.isNull(contentDate) ? StringPool.DASH : dateFormatWithTime.format(contentDate)%></p>
										</aui:field-wrapper>

										</td>
									<%											
									}
								}
							}								
					%>
					</tr>
					<%
					}
				}
			%>
			
			</table>		
			<aui:row>
				<aui:col md="12">
					<aui:button-row cssClass="marL10">
						<aui:button type="button" name="cancel" value="ecrf-user.button.cancel" cssClass="cancel-btn medium-btn radius-btn" onClick="<%=listCRFURL %>"></aui:button>
					</aui:button-row>
				</aui:col>
			</aui:row>	
		</aui:form>
	</div>
</div>