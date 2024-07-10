<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/dashboard/view_jsp"); %>

<%

SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");


JSONObject obj = (JSONObject)renderRequest.getAttribute("chartDataObj");

_log.info(obj);

JSONArray chartDataArr = obj.getJSONArray("chart-data");

%>

<style>
.panel-title {
	font-size:1.2rem;
}

.radius-shadow-container {
	padding:0px;
}
</style>

<div class="ecrf-user ecrf-user-dashboard">
	
	<div class="mar16px">
		<liferay-ui:header title="ecrf-user.dashboard.title.view-dashboard" />
		
		<!-- CRF 단위 visit date 기준 연도별 / 월별 데이터 현황 -->
		<%
		ArrayList<BarChartConfig> yearChartConfigList = new ArrayList<>();
		ArrayList<BarChartConfig> monthChartConfigList = new ArrayList<>();
		
		// add Configs for each CRF 
		for(int i=0; i<chartDataArr.length(); i++) {
			yearChartConfigList.add(new BarChartConfig());
			monthChartConfigList.add(new BarChartConfig());
		}
		
		for(int i=0; i<chartDataArr.length(); i++) {
			JSONObject crfObj = chartDataArr.getJSONObject(i);
			
			long crfId = crfObj.getLong("id");
			JSONObject dataObj = crfObj.getJSONObject("data");
			
			CRF crf = null;
			DataType datatype = null;
			
			if(Validator.isNotNull(crfId)) {
				crf = CRFLocalServiceUtil.getCRF(crfId);
				long dataTypeId = crf.getDatatypeId();
				
				if(Validator.isNotNull(dataTypeId))
					datatype = DataTypeLocalServiceUtil.getDataType(dataTypeId);
			}
			
			if(Validator.isNotNull(datatype)) {
				// TODO : refactoring
				
				// set year chart config
				BarChartConfig yearChartConfig = yearChartConfigList.get(i);
				yearChartConfig.getAxisX().setType(AxisX.Type.CATEGORY);
				
				List<String> yearCategories = new ArrayList<>();
				JSONArray yearDataArr = dataObj.getJSONArray("yearData");
				
				List<Integer> yearFreqList = new ArrayList<>();
				// year chart category and values
				for(int j=0; j<yearDataArr.length(); j++) {
					JSONObject yearDataObj = yearDataArr.getJSONObject(j);
					
					String xVal = yearDataObj.getString("x");
					yearCategories.add(xVal);
					
					int yVal = yearDataObj.getInt("y");
					yearFreqList.add(yVal);
				}
				
				yearChartConfig.getAxisX().addCategories(yearCategories);
				
				MultiValueColumn yearCol = new MultiValueColumn("Frequency", yearFreqList);
				yearChartConfig.addColumn(yearCol);
				
				// set month chart config
				BarChartConfig monthChartConfig = monthChartConfigList.get(i);
				monthChartConfig.getAxisX().setType(AxisX.Type.CATEGORY);
					
				List<String> monthCategories = new ArrayList<>();			
				JSONArray monthDataArr = dataObj.getJSONArray("monthData");
				
				List<Integer> monthFreqList = new ArrayList<>();
				// month chart category
				for(int j=0; j<monthDataArr.length(); j++) {
					JSONObject monthDataObj = monthDataArr.getJSONObject(j);
					
					String xVal = monthDataObj.getString("x");
					monthCategories.add(xVal);
					
					int yVal = monthDataObj.getInt("y");
					monthFreqList.add(yVal);
				}
				
				monthChartConfig.getAxisX().addCategories(monthCategories);
				
				MultiValueColumn monthCol = new MultiValueColumn("Frequency", monthFreqList);
				monthChartConfig.addColumn(monthCol);
		%>
			<aui:fieldset-group markupView="lexicon">
				<aui:fieldset cssClass="search-option radius-shadow-container" collapsed="false" collapsible="true" label="<%=datatype.getDisplayName() %>">
										
				<aui:container>
					<!-- CRF Info -->
					<aui:row>
						<aui:col md="12" cssClass="sub-title-bottom-border marBr">
							<span class="sub-title-span">
								<liferay-ui:message key="ecrf-user.crf.title.crf-info" />
							</span>
						</aui:col>
					</aui:row>
					
					<aui:row cssClass="">
						<aui:col>
							<aui:container>
								<aui:row>	
									<aui:col md="3">
										<aui:field-wrapper
											label="ecrf-user.crf.crf-title"
										>
										</aui:field-wrapper>
									</aui:col>
									<aui:col md="9">
										<p><%=datatype.getDisplayName() %></p>
									</aui:col>
								</aui:row>
								
								<%
									int crfSubjectCount = CRFSubjectLocalServiceUtil.countCRFSubjectByCRFId(scopeGroupId, crf.getCrfId());
									int linkCount = LinkCRFLocalServiceUtil.countLinkCRFByG_C(scopeGroupId, crf.getCrfId());
								%>
								<aui:row>
									<aui:col md="3">
										<aui:field-wrapper
											label="ecrf-user.crf.crf-subject-count"
										>
										</aui:field-wrapper>
									</aui:col>
									<aui:col md="3">
										<p><%=String.valueOf(crfSubjectCount) %></p>
									</aui:col>
									
									<aui:col md="3">
										<aui:field-wrapper
											label="ecrf-user.crf.crf-data-count"
										>
										</aui:field-wrapper>
									</aui:col>
									<aui:col md="3">
										<p><%=String.valueOf(linkCount) %></p>
									</aui:col>
								</aui:row>
							</aui:container>
						</aui:col>
					</aui:row>
					
					
					<aui:row>
						<!-- Year Chart -->
						<aui:col md="12" lg="6">
							<div class=" sub-title-bottom-border marBr">
								<span class="sub-title-span">
									<liferay-ui:message key="ecrf-user.crf.title.year-chart" />
								</span>
							</div>
							
							<chart:bar
								config="<%= yearChartConfig %>"
							/>
						</aui:col>
						
						<!-- Month Chart -->
						<aui:col md="12" lg="6">
							<div class=" sub-title-bottom-border marBr">
								<span class="sub-title-span">
									<liferay-ui:message key="ecrf-user.crf.title.month-chart" />
								</span>
							</div>
							<chart:bar
								config="<%= monthChartConfig %>"
							/>
						</aui:col>
					</aui:row>
				</aui:container>
				
				</aui:fieldset>
			</aui:fieldset-group>
		
		<%
			}
		}
		
		%>
		
	</div>
</div>		
	