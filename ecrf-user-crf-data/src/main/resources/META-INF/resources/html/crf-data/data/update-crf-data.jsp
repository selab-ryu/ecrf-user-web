<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html.crf-data.data.update_crf_data_jsp"); %>

<%
SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/M/d");
SimpleDateFormat dateFormatWithTime = new SimpleDateFormat("yyyy/M/d HH:mm");

long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0); 

Subject subject = null;
if(subjectId > 0){
	subject = (Subject)renderRequest.getAttribute(ECRFUserCRFDataAttributes.SUBJECT);
}

JSONArray crfForm = (JSONArray)renderRequest.getAttribute(ECRFUserCRFDataAttributes.CRF_FORM);
JSONObject answerForm = null; 
Date visitDate = null;

CRFGroupCaculation groupApi = new CRFGroupCaculation();
JSONObject eachGroups = null;

boolean isUpdate = false;

long sdId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID, 0);

String none = ParamUtil.getString(renderRequest, "none");
String menu = "add-crf-data";

if(sdId > 0) {
	menu = "update-crf-data";
	isUpdate = true;
		
	answerForm = (JSONObject)renderRequest.getAttribute(ECRFUserCRFDataAttributes.ANSWER_FORM);
	
	String visitDateStr = "";
	if(Validator.isNotNull(answerForm) && answerForm.has("visit_date")){
		visitDate = new Date(Long.valueOf(answerForm.getString("visit_date")));
	}
	
	eachGroups = groupApi.getEachGroupProgress(dataTypeId, answerForm);
}

_log.info("is update : " + isUpdate);

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

<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_ADD_CRF_DATA%>" var="addCRFDataURL">
	<portlet:param name="<%=Constants.CMD %>" value="<%=Constants.ADD %>" />
</liferay-portlet:actionURL>

<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_UPDATE_CRF_DATA %>" var="updateCRFDataURL">
	<portlet:param name="<%=ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID %>" value="<%=String.valueOf(sdId) %>" />
	<portlet:param name="<%=Constants.CMD %>" value="<%=Constants.UPDATE %>" />
</liferay-portlet:actionURL>

<portlet:renderURL var="listCRFURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_LIST_CRF_DATA%>"/>
	<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
</portlet:renderURL>

<div class="ecrf-user-crf-data ecrf-user">

	<%@ include file="../other/sidebar.jspf" %>
	
	<div class="page-content">
		
		<liferay-ui:header backURL="<%=redirect %>" title='<%=isUpdate ? "ecrf-user.crf-data.title.update-crf-data" : "ecrf-user.crf-data.title.add-crf-data" %>' />
				
		<aui:fieldset-group markupView="lexicon">
			<aui:fieldset cssClass="search-option radius-shadow-container" collapsed="<%=false %>" collapsible="<%=true %>" label="ecrf-user.subject.title.subject-info">
				<aui:container>
					<aui:row cssClass="top-border">
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="serialId"
								label="ecrf-user.subject.serial-id">
								<p><%=Validator.isNull(subject) ? "-" : String.valueOf(subject.getSerialId()) %></p>
							</aui:field-wrapper>
						</aui:col>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="name"
								label="ecrf-user.subject.name">
								<p><%=Validator.isNull(subject) ? "-" : subject.getName() %></p>
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
								<p><%=Validator.isNull(subject) ? "-" : dateFormat.format(subject.getBirth()) + " (" + Math.abs(124 - subject.getBirth().getYear()) + ")" %></p>
							</aui:field-wrapper>
						</aui:col>
					</aui:row>
				</aui:container>
			</aui:fieldset>
		</aui:fieldset-group>
		
		<aui:form name="updateCRFDataForm" action="<%=isUpdate ? updateCRFDataURL : addCRFDataURL %>" autocomplete="off" method="POST" enctype="multipart/form-data">
			<aui:input type="hidden" name="<%=ECRFUserCRFDataAttributes.SUBJECT_ID %>" value="<%=subjectId %>"></aui:input>
			<aui:input type="hidden" name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=crfId %>"></aui:input>
					
			<aui:input 
			   type="text"
			   name="visitDate"
			   style="width:min-content;"
			   placeholder="yyyy/MM/dd"
			   required="true"
			   label="ecrf-user.crf-data.visit-date"
			   value="<%=Validator.isNull(visitDate) ? "" : dateFormat.format(visitDate)%>" 
			   >
			   <aui:validator name="date" />
			</aui:input>
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
							//_log.info("null test");
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
											if(contentType.equals("String") || contentType.equals("Numeric")){
												if(Validator.isNotNull(answerForm) && answerForm.has(contentId)){
													contentValue = answerForm.getString(contentId);
												}
											%>
												<td><aui:input cssClass="crf-max-width search-input h35" disabled="<%=isDisabled %>" label= "" name="<%=contentId %>" value="<%=contentValue%>"></aui:input></td>
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
												<aui:input 
												   type="text"
												   name="<%=contentId%>"
												   class="form-control date"
												   disabled="<%=isDisabled %>"
												   placeholder="yyyy/MM/dd HH:mm"
												   label=""
												   value="<%=Validator.isNull(contentDate) ? "" : dateFormatWithTime.format(contentDate)%>" 
												   >
												   <aui:validator name="date" />
												</aui:input>
												</td>
												<script>
												  $(document).ready(function() {
												      $("#<portlet:namespace/><%=contentId%>").datetimepicker({
												         lang: 'kr',
												         changeYear: true,
												         changeMonth : true,
												         validateOnBlur: false,
												         gotoCurrent: true,
												         timepicker: true,
												         scrollMonth: false,
												         format: 'Y/m/d H:i'
												         
												      });
												   });
												</script>
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
										}
									%>
										<td><aui:input cssClass="crf-max-width search-input h35" disabled="<%=isDisabled %>" label= "" name="<%=contentId %>" value="<%=contentValue%>"></aui:input></td>
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
										<aui:input 
										   type="text"
										   name="<%=contentId%>"
										   class="form-control date"
										   placeholder="yyyy/MM/dd HH:mm"
										   disabled="<%=isDisabled %>"
										   label=""
										   value="<%=Validator.isNull(contentDate) ? "" : dateFormatWithTime.format(contentDate)%>" 
										   >
										   <aui:validator name="date" />
										</aui:input>
										</td>
										<script>
										  $(document).ready(function() {
										      $("#<portlet:namespace/><%=contentId%>").datetimepicker({
										         lang: 'kr',
										         changeYear: true,
										         changeMonth : true,
										         validateOnBlur: false,
										         gotoCurrent: true,
										         timepicker: true,
										         scrollMonth: false,
										         format: 'Y/m/d H:i'
										         
										      });
										   });
										</script>
									<%											
									}
								}
							}								
					%>
					</tr>
					<%
					}
				%>
			<%
				}
			%>
			
			</table>		
			<aui:row>
				<aui:col md="12">
					<aui:button-row cssClass="marL10">
						<aui:button type="button" name="saveCRF" value='<%=isUpdate ? "ecrf-user.button.update" : "ecrf-user.button.add" %>' cssClass="add-btn medium-btn radius-btn"></aui:button>
						<aui:button type="button" name="cancel" value="ecrf-user.button.cancel" cssClass="cancel-btn medium-btn radius-btn" onClick="<%=listCRFURL %>"></aui:button>
					</aui:button-row>
				</aui:col>
			</aui:row>	
		</aui:form>
	</div>
</div>

<aui:script use="aui-base">
$("#<portlet:namespace/>visitDate").datetimepicker({
	lang: 'kr',
	changeYear: true,
	changeMonth : true,
	validateOnBlur: false,
	gotoCurrent: true,
	timepicker: false,
	scrollMonth: false,
	format: 'Y/m/d'
});
A.one("#<portlet:namespace/>saveCRF").on("click", function(event) {
	var form = A.one('#<portlet:namespace/>updateCRFDataForm');
	
	var rules = {
		<portlet:namespace />visitDate: {
			required: true
		}
	};
	var fieldStrings = {
		<portlet:namespace />visitDate: {
			required: '<p style="color:red;"><liferay-ui:message key="ecrf-user.validation.require"/></p>'
		}
	};
		
	var validator = new A.FormValidator({
		boundingBox: document.<portlet:namespace/>updateCRFDataForm,
		fieldStrings: fieldStrings,
		rules: rules
	});
	
	var submitValid = true;
	
	var visitDate = A.one('#<portlet:namespace/>visitDate');
	
	if(visitDate.val().trim().length === 0) {
		submitValid = false;
		validFocus(visitDate);
	} 
		
	if(submitValid) {
		form.submit();
	}
	

});

function validFocus(elem) {
	elem.focus();
	elem.blur();
	elem.focus();
}
</aui:script>