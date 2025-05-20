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
			
			<aui:row>
				<aui:col md="12">
					<div id="enrollmentChart2" style="height: 400px"></div>
				</aui:col>
			</aui:row>
		</aui:container>
	</div>
</div>

<script>
wijmo.setLicenseKey('licenseKey');


$(document).ready(function() {
	console.log("graph data loading");
	
	let crfId = 56603;
	
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

			console.log("crfId : ", crfId);
			console.log("data : ", data.data[0]);

			// set data to chart
			$("#<portlet:namespace/>dataCount").text(100);
			
			// do pre-process data for chart
			let chartData = processChartData(data); // 데이터 전처리 함수 추가
            setGraphData(chartData); // 차트 데이터 설정
		
			let chartData2 = processChartData2(data); // 데이터 전처리 함수 추가
	        setGraphData2(chartData2); // 차트 데이터 설정
		},
		error: function(jqXHR, a, b){
			console.log('Fail to render trimester graph');
		}
	});
}

function processChartData(in_data) {
    // 표시할  termName List 
	const termNames = new Array("BPA","BPF","BPS","TCS","BP3","MP","EP","PP","BP");
	let processedData = [];
//	console.log(termNames)
//	console.log('Length=',termNames.length)
	
	for (i=0; i<in_data.data.length; i++) {
		if( in_data.data[i].name === "NOE_1001") {
			
			if(in_data.data[i].hasOwnProperty("trimester")){
				const f_data = new Object();
				f_data.trimester = 'T-'+in_data.data[i].trimester[0]
				console.log(f_data.trimester,':',in_data.data[i].trimester[0])
	
//				console.log('BPA :',in_data.data[i]["BPA"])
//				console.log('BPF :',in_data.data[i]["BPF"])
//				console.log('BPS :',in_data.data[i]["BPS"])
//				console.log('TCS :',in_data.data[i]["TCS"])
//				console.log('BP3 :',in_data.data[i]["BP3"])
//				console.log('MP :',in_data.data[i]["MP"])
//				console.log('PP :',in_data.data[i]["PP"])
//				console.log('BP :',in_data.data[i]["BP"])

				let noTerms = 0;
				for (i2=0; i2<termNames.length; i2++) {
					termName = termNames[i2]
					if(in_data.data[i].hasOwnProperty(termName)){
					//	console.log(termName,':', in_data.data[i][termName])
						noTerms += 1
						f_data[termName] = in_data.data[i][termName]
					}
				}
				console.log("==================================")
				if ( noTerms > 0 ) {
					//	console.log(f_data)
					processedData.push(f_data)
				}
			}
		}
	}
	
	console.log("processed Data :",processedData)
	
//	processedData = [
//		{trimester:'T-1','BPA':1,'BPF':2,'BPS':3,'TCS':4,'BP3':5,'MP':6,'EP':7,'PP':8,'BP':9},  
//		{trimester:'T-2','BPA':2,'BPF':3,'BPS':4,'TCS':5,'BP3':6,'MP':7,'EP':8,'PP':9,'BP':10},	    
//		{trimester:'T-3','BPA':3,'BPF':4,'BPS':5,'TCS':6,'BP3':7,'MP':8,'EP':9,'PP':10,'BP':11},	    
//	];
	return processedData;
}
function processChartData2(in_data) {
    // 표시할  termName List 
	const termNames = new Array("BPA","BPF","BPS","TCS","BP3","MP","EP","PP","BP");
    
	let processedData = [];
	let originalData  = [];
//	console.log(termNames)
//	console.log('Length=',termNames.length)
	
	for (i=0; i<in_data.data.length; i++) {
		if( in_data.data[i].name === "NOE_1001") {
			
			if(in_data.data[i].hasOwnProperty("trimester")){
				const f_data = new Object();
				f_data.trimester = 'T-'+in_data.data[i].trimester[0]
			//	console.log(f_data.trimester,':',in_data.data[i].trimester[0])
	
				let noTerms = 0;
				for (i2=0; i2<termNames.length; i2++) {
					termName = termNames[i2]
					if(in_data.data[i].hasOwnProperty(termName)){
					//	console.log(termName,':', in_data.data[i][termName])
						noTerms += 1
						f_data[termName] = in_data.data[i][termName]
					}
				}
			//	console.log("==================================")
				if ( noTerms > 0 ) {
					//	console.log(f_data)
					originalData.push(f_data)
				}
			}
		}
	}
	
	console.log("processed Data :",originalData)
	processedData = transFormData(originalData)
	
//	processedData = [
//		{termName:'BPA','T-1':1,'T-2':2,'T-3':3},	    
//		{termName:'BPF','T-1':2,'T-2':3,'T-3':4},	    
//		{termName:'BPS','T-1':3,'T-2':4,'T-3':5},	    
//		{termName:'TCS','T-1':4,'T-2':5,'T-3':6},	    
//		{termName:'MP','T-1':0.5,'T-2':1.0,'T-3':1.5},	    
//		{termName:'EP','T-1':1.0,'T-2':1.5,'T-3':2.0},	    
//		{termName:'PP','T-1':1.5,'T-2':2.0,'T-3':2.5},	    
//		{termName:'BP','T-1':2.0,'T-2':2.5,'T-3':3.0},	    
//	];

	return processedData;
}
function transFormData(in_data) {
	const transformedData = [];
	const termNames = Object.keys(in_data[0]).filter(key => key !== 'trimester')
	
	console.log("termNames : ",termNames);
	
	termNames.forEach(term => {
		const newObject = { termName: term };
		in_data.forEach(item => {
			newObject[item.trimester] = item[term];
		});
		transformedData.push(newObject);
	});
	
	console.log("transformed Data :",transformedData)
	
	return transformedData;
};

function setGraphData(data) {
	 // 1. 환자 등록 현황 차트
   new wijmo.chart.FlexChart('#enrollmentChart', {
       header: '임상시험 시계열 현황',
       legendToggle: true,
       bindingX: 'trimester',
       itemsSource: data,
       series: [
    	   { name: 'BPA',   binding: 'BPA' ,	chartType: 'LineSymbols'},
    	   { name: 'BPF',   binding: 'BPF' ,	chartType: 'LineSymbols'},
    	   { name: 'BPS',   binding: 'BPS' ,	chartType: 'LineSymbols'},
    	   { name: 'TCS',   binding: 'TCS' ,	chartType: 'LineSymbols'},
    	   { name: 'BP3',   binding: 'BP3' ,	chartType: 'LineSymbols'},
    	   { name: 'MP',   binding: 'MP' ,	chartType: 'LineSymbols'},
    	   { name: 'EP',   binding: 'EP' ,	chartType: 'LineSymbols'},
    	   { name: 'PP',   binding: 'PP' , 	chartType: 'LineSymbols'},
    	   { name: 'BP',   binding: 'BP' ,	chartType: 'LineSymbols'},
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
function setGraphData2(data) {
	 // 1. 환자 등록 현황 차트
    new wijmo.chart.FlexChart('#enrollmentChart2', {
        header: '임상시험 시계열 현황',
        legendToggle: true,
        bindingX: 'termName',
        itemsSource: data,
        series: [{
                name: '1stTri',
                binding: 'T-1'
            },{
                name: '2ndTri',
                binding: 'T-2'
            },{
                name: '3rdTri',
                binding: 'T-3'
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