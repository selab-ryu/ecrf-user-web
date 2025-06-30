
<%@page import="com.liferay.portal.kernel.util.LocalizationUtil"%>
<%@page import="com.liferay.portal.kernel.util.Localization"%>
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/dashboard/view_jsp"); %>

<%

SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");


JSONObject obj = (JSONObject)renderRequest.getAttribute("chartDataObj");

//_log.info(obj);

JSONArray chartDataArr = obj.getJSONArray("chart-data");

String chartDataStr = chartDataArr.toJSONString();
boolean isNoemoc = false;

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
				<aui:fieldset cssClass="search-option radius-shadow-container panel-content" collapsed="false" collapsible="true" label="<%=datatype.getDisplayName(themeDisplay.getLanguageId()) %>">
										
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
											cssClass=""
											label="ecrf-user.crf.crf-title"
										>
										</aui:field-wrapper>
									</aui:col>
									<aui:col md="3" cssClass="right-border-gray">
										<p class=""><%=datatype.getDisplayName(themeDisplay.getLanguageId()) %></p>
									</aui:col>
									
									<aui:col md="6" cssClass="text-right marBr">
										
										<%
										boolean hasCRFPermission = CRFResearcherLocalServiceUtil.isResearcherInCRF(crf.getCrfId(), user.getUserId());
										if(isAdmin) hasCRFPermission = true;
										if(CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.ALL_UPDATE_CRF)) hasCRFPermission = true;
										
										boolean hasUpdatePermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.UPDATE_CRF);
										boolean hasViewFormPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_CRF_FORM);
										boolean hasViewDataListPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_CRF_DATA_LIST);
										%>
										
										<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_REDIRECT_UPDATE_CRF %>" var="moveCRFInfoURL" >
											<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
											<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(crf.getDatatypeId()) %>" />
											<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
										</portlet:actionURL>
										
										<c:if test="<%=(hasCRFPermission && hasUpdatePermission) %>">
										<a class="dh-icon-button submit-btn crf-info-btn w130 h36 marR8" href="<%=moveCRFInfoURL%>" name="<portlet:namespace/>moveCRFInfo">
											<img class="crf-icon h20" />
											<span><liferay-ui:message key="ecrf-user.button.crf-info" /></span>
										</a>
										</c:if>
										
										<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_REDIRECT_CRF_FORM %>" var="moveCRFFormURL" >
											<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
											<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(crf.getDatatypeId()) %>" />
											<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
										</portlet:actionURL>
										
										<c:if test="<%=(hasCRFPermission && hasViewFormPermission) %>">
										<a class="dh-icon-button submit-btn crf-form-btn w130 h36 marR8" href="<%=moveCRFFormURL%>" name="<portlet:namespace/>moveCRFForm">
											<img class="crf-form-icon h20" />
											<span><liferay-ui:message key="ecrf-user.button.crf-builder" /></span>
										</a>
										</c:if>
									
										<portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_REDIRECT_CRF_DATA_LIST %>" var="moveCRFDataURL" >
											<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
											<portlet:param name="<%=ECRFUserCRFAttributes.DATATYPE_ID %>" value="<%=String.valueOf(crf.getDatatypeId()) %>" />
											<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
										</portlet:actionURL>
										
										<c:if test="<%=(hasCRFPermission && hasViewDataListPermission) %>">
										<a class="dh-icon-button submit-btn crf-data-btn w130 h36 marR8" href="<%=moveCRFDataURL%>" name="<portlet:namespace/>moveCRFData">
											<img class="crf-data-icon h20" />
											<span><liferay-ui:message key="ecrf-user.button.crf-data" /></span>
										</a>
										</c:if>

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
									<aui:col md="3" cssClass="right-border-gray">
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
								
								<%
									boolean isDescriptionVisible = false;
									String datatypeName = datatype.getDataTypeName();
									String description = datatype.getDescription(themeDisplay.getLanguageId());
									
									if( Validator.isNotNull(description) ) {
										isDescriptionVisible = true;
									}
									//_log.info(description);
								%>
								
								<c:if test="<%=isDescriptionVisible %>">
								<!-- Description Title -->
								<aui:row>
									<aui:col>
										<aui:field-wrapper
											label="ecrf-user.crf.description"
										>
											<pre class="description-pre"><c:out value="<%=description%>"/></pre>
										</aui:field-wrapper>
									</aui:col>
								</aui:row>
								</c:if>
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
					
					
					<%
						String dataTypeVarName = datatype.getDataTypeName();
						//if(dataTypeVarName.equals("noe_moc_crf")) isNoemoc = true;
					%>
					
					<c:if test="<%=isNoemoc %>">
					<aui:row>
						<!-- Noe_Moc Trimester Graph -->
						<aui:col md="12" lg="12">
							<div class=" sub-title-bottom-border marBr">
								<span class="sub-title-span">
									<liferay-ui:message key="ecrf-user.crf.title.trimester-chart" />
								</span>
							</div>
							
							<div id="trimesterChart"></div>
						</aui:col>
					</aui:row>
					</c:if>
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

function setTrimesterChart(crfId) {
	$.ajax({
		url: '<portlet:resourceURL id="<%= ECRFUserMVCCommand.RESOURCE_GET_TRIMESTER_DATA %>"></portlet:resourceURL>',
		type:'post',
		dataType: 'json',
		data:{
			<portlet:namespace/>crfId: crfId,
		},
		success: function(data){
			
			// do pre-process data for chart
			
			let chart = myChart.bb.generate({
				bindto: 'trimesterChart',
				data: {
					
				},
				axis: {
				},
				point: {
					focus: {
						only: true
					}
				}
			});
		},
		error: function(jqXHR, a, b){
			console.log('Fail to render trimester graph');
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
	
	let isNoemoc = <%=isNoemoc %>;
	
	if(isNoemoc) {
		console.log('noemoc crf');
	}
});
</aui:script>