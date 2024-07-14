<%@page import="com.liferay.portal.kernel.json.JSONFactoryUtil"%>
<%@page import="com.liferay.portal.kernel.json.JSON"%>
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/dashboard/view_jsp"); %>

<%

SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");


JSONObject obj = (JSONObject)renderRequest.getAttribute("chartDataObj");

//_log.info(obj);

JSONArray chartDataArr = obj.getJSONArray("chart-data");

String chartDataStr = chartDataArr.toJSONString();

%>

<style>
.ecrf-user-dashboard .panel-title {
	font-size:1.2rem;
}

.ecrf-user-dashboard .radius-shadow-container {
	padding:0px;
}
</style>

<div class="ecrf-user ecrf-user-dashboard">
	
	<div class="mar16px">
		<liferay-ui:header title="ecrf-user.dashboard.title.view-dashboard" />
		
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
							
							<div id="yearChart-<%=crfId%>"></div>
						</aui:col>
						
						<!-- Month Chart -->
						<aui:col md="12" lg="6">
							<div class=" sub-title-bottom-border marBr">
								<span class="sub-title-span">
									<liferay-ui:message key="ecrf-user.crf.title.month-chart" />
								</span>
							</div>
							
							<div id="monthChart-<%=crfId%>"></div>
						</aui:col>
					</aui:row>
					
				</aui:container>
				
				</aui:fieldset>
			</aui:fieldset-group>
			
			<!--
			<script>
			$(document).ready(function() {
				setMonthChart('monthChart<%=i%>', "<%=monthFreqList%>", "<%=monthCategories%>");
			});
			</script>
			-->
		
		<%
			}
		}
		
		%>
		
	</div>
</div>

<!-- get billboard js object from liferay Loaded JS -->
<aui:script require="frontend-taglib-chart$billboard.js@1.5.1/dist/billboard as myChart">
function setYearChart(id, yearFreqData, yearTimeData) {
	console.log("chart id : " + id)
	
	rowData = [];
	rowData[0] = yearTimeData;
	rowData[1] = yearFreqData;
	
	console.log(rowData);
	
	var chart = myChart.bb.generate({
		bindto: id,
		data: {
			rows: rowData, 
			xFormat: "%Y-%m",
			type: "bar"
		},
		bar: {
			padding: 5
		}
	});
}

function setMonthChart(id, freqData, timeData) {
	console.log("chart id : " + id)
	
	var chart = myChart.bb.generate({
		bindto: id,
		data: {
			x:"x",
			json: {
				"Frequency" : freqData,
				"x" : timeData
			},
			xFormat: "%Y-%m",
			type: "line"
		},
		axis: {
			x: {
				tick: {
					format: "%Y-%m",
					fit:true,
					count: 10
				},
 				type: "timeseries"
			}
		},
		zoom: {
			enabled: true,
			type: "drag"
		},
		point: {
			focus: {
				only: true
			}
		}
	});
}

var chartDataArr = [];

const monthChartDiv = document.querySelector('<portlet:namespace/>monthChartRow');

const observer = new ResizeObserver(entries => {
  for (let entry of entries) {
    const {width, height} = entry.contentRect;
    console.log(entry);
  }
});

console.log(observer);

$(document).ready(function() {
	var freqData = [25, 23, 12, 45, 54, 34, 32, 12];
	var timeData = ["2022-12", "2023-4", "2023-5", "2023-6", "2023-8", "2023-10", "2024-1", "2024-3"];
	
	let jsonStr = <%=chartDataStr %>;
		
	try {
		chartDataArr = JSON.parse(JSON.stringify(jsonStr));
		
		console.log(chartDataArr);
					
	} catch(e) {
		console.log("json parse error");
	}
	
	for(let i=0; i < chartDataArr.length; i++) {
		let crfId = chartDataArr[i].id;
		let yearDataArr = chartDataArr[i].data.yearData;
		let monthDataArr = chartDataArr[i].data.monthData;
		
		console.log(crfId);
		console.log(yearDataArr);
		console.log(monthDataArr);
		
		let yearFreqData = [];
		let yearTimeData = [];
		
		for(let j=0; j < yearDataArr.length; j++) {
			yearTimeData[j] = yearDataArr[j].x;
			yearFreqData[j] = yearDataArr[j].y;
		}
		
		setYearChart('#yearChart-'+crfId, yearFreqData, yearTimeData);
		
		let monthFreqData = [];
		let monthTimeData = [];
					
		for(let j=0; j < monthDataArr.length; j++) {
			monthTimeData[j] = monthDataArr[j].x;
			monthFreqData[j] = monthDataArr[j].y;
		}
		
		setMonthChart('#monthChart-'+crfId, monthFreqData, monthTimeData);
	}
});
</aui:script>