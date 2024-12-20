<%@page import="com.liferay.frontend.taglib.servlet.taglib.util.EmptyResultMessageKeys"%>
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
		
		<% BarChartConfig _barChartConfig = new BarChartConfig(); %>
		
		<!-- add chart css by adding chart:bar tag -->
		<div class="hide">
			<chart:bar config="<%=_barChartConfig %>" />
		</div>
		
		<!-- Display Info DIV if there is no CRF -->
		<c:if test="<%=(chartDataArr.length()<=0)%>">
			<liferay-frontend:empty-result-message
				animationType="<%=EmptyResultMessageKeys.AnimationType.EMPTY %>"
				description='<%= LanguageUtil.get(request, "ecrf-user.empty-no-crf-were-found") %>'
				elementType='<%= LanguageUtil.get(request, "CRF") %>'
			/>
		</c:if>
		
		<!-- For each CRF, Display Graph by visit date (Annualy / Monthly) -->
		<%
		
		for(int i=0; i<chartDataArr.length(); i++) {
			JSONObject crfObj = chartDataArr.getJSONObject(i);
			
			long crfId = crfObj.getLong("id");
			
			CRF crf = null;
			DataType datatype = null;
			
			if(Validator.isNotNull(crfId)) {
				crf = CRFLocalServiceUtil.getCRF(crfId);
				long dataTypeId = crf.getDatatypeId();
				
				if(Validator.isNotNull(dataTypeId))
					datatype = DataTypeLocalServiceUtil.getDataType(dataTypeId);
			}
			
			if(Validator.isNotNull(datatype)) {
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
									int formCount = 0;
																	
									JSONObject formObj = DataTypeLocalServiceUtil.getDataTypeStructureJSONObject(datatype.getDataTypeId());
									if(Validator.isNotNull(formObj)) {
										JSONArray termsArr = formObj.getJSONArray("terms");
										if(Validator.isNotNull(termsArr)) formCount = termsArr.length();	 
									}
								%>
								
								<c:if test="false">
								<aui:row>
									<aui:col md="3">
										<aui:field-wrapper
											label="ecrf-user.crf-form.form-count"
										>
										</aui:field-wrapper>
									</aui:col>
									<aui:col md="9">
										<p><%=String.valueOf(formCount) %></p>
									</aui:col>
								</aui:row>
								</c:if>
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

		<%
			}
		}
		
		%>
		
	</div>
</div>

<!-- get billboard js object from liferay Loaded JS -->
<aui:script require="frontend-taglib-chart$billboard.js@1.5.1/dist/billboard as myChart">
function setYearChart(id, yearFreqData, yearTimeData) {	
	let rowData = [];
	
	rowData[0] = yearTimeData;
	rowData[1] = yearFreqData;
	
	var chart = myChart.bb.generate({
		bindto: id,
		data: {
			rows: rowData, 
			type: "bar"
		},
		bar: {
			padding: 10
		},
		tooltip: {
			format: {
				title: function(d) {
					return 'Frequency';
				}
			}
		}
	});
	
	chart.category(0, "Frequency");
}

function setMonthChart(id, freqData, timeData) {
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
					text: {
			        	inner: true
			        },
					format: "%Y-%m",
					fit: false,
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


$(document).ready(function() {
	let jsonStr = <%=chartDataStr %>;
		
	try {
		chartDataArr = JSON.parse(JSON.stringify(jsonStr));
	} catch(e) {
		console.log("json parse error");
	}
	
	for(let i=0; i < chartDataArr.length; i++) {
		let crfId = chartDataArr[i].id;
		let yearDataArr = chartDataArr[i].data.yearData;
		let monthDataArr = chartDataArr[i].data.monthData;
		
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