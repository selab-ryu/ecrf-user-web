<%@ page contentType="text/html;charset=UTF-8"%>
<%@ include file="/init.jsp" %>

<div class="ecrf-user">
	<div class="pad1r">
		<liferay-ui:header title="ecrf-user.visualizer.title.graph1" />
		
		<aui:container>
			<aui:row>
				<aui:col md="3">
					<liferay-ui:message key="ecrf-user.visualizer.title.data-count" />
				</aui:col>
				<aui:col md="9">
					<span id="<portlet:namespace/>dataCount"></span>
				</aui:col>
			</aui:row>
			
			<!-- variable option -->
			<aui:row>
				<aui:col md="3">
					
				</aui:col>
				<aui:col md="9">
					
				</aui:col>
			</aui:row>
			
			<!-- graph -->
			<aui:row>
				<aui:col md="12">
					<liferay-ui:message key="ecrf-user.visualizer.title.graph" />
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col md="12">
					<div id="enrollmentChart" style="height: 400px"></div>
				</aui:col>
			</aui:row>
		</aui:container>
	</div>
</div>

<script>
wijmo.setLicenseKey('licenseKey');


$(document).ready(function() {
	console.log("graph data loading");
	
	let crfId = 41733;
	
	getGraphData(crfId);
	
});

function getGraphData(crfId) {
	$.ajax({
		url: '<portlet:resourceURL id="<%=ECRFVisualizerMVCCommand.RESOURCE_GET_NOE_MOC %>"></portlet:resourceURL>',
		type:'post',
		dataType: 'json',
		data:{
			<portlet:namespace/>crfId: crfId,
		},
		success: function(data){
			// do pre-process data for chart			
			console.log("data :", data);
			
			// set data to chart
			$("#<portlet:namespace/>dataCount").text("120");
			
			
			let chartData = null;
			// data pre processing
			
			//setGraphData(chartData);
			
		},
		error: function(jqXHR, a, b){
			console.log('Fail to render trimester graph');
		}
	});
}

function setGraphData(data) {
	 // 1. 환자 등록 현황 차트
    new wijmo.chart.FlexChart('#enrollmentChart', {
        header: '임상시험 시계열 현황',
        legendToggle: true,
        bindingX: 'quater',
        itemsSource: data,
        series: [{
                name: '임상실험1',
                binding: 'value1',
                chartType: 'LineSymbols'
            },{
                name: '임상실험2',
                binding: 'value2',
                chartType: 'LineSymbols'
            },{
                name: '임상실험3',
                binding: 'value3',
                chartType: 'LineSymbols'
            },{
                name: '임상실험4',
                binding: 'value4',
                chartType: 'LineSymbols'
            }
        ],
        axisY: {
            title: '실험 데이터(수치)'
        },
        legend: {
            position: 'Bottom'
        },
        dataLabel: {
            content: '{y}'
        }
    });
}

</script>