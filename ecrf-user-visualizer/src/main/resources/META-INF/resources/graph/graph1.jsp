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

			<aui:row>
				<aui:col md="12">
					<div id="enrollmentChart3" style="height: 400px"></div>
				</aui:col>
			</aui:row>
			<aui:row>
				<aui:col md="12">
					<div id="theGrid" style="height: 400px"></div>
				</aui:col>
			</aui:row>
		</aui:container>
	</div>
</div>

<script>
//wijmo.setLicenseKey('licenseKey');
wijmo.setLicenseKey('smart-crf.medbiz.or.kr,951833985592528#B0IMJojIyVmdiwSZzxWYmpjIyNHZisnOiwmbBJye0ICRiwiI34zdalVOkVHOrQ7VVd6UoNlcyFVey2meP94Q4x4YMFUQw44YnhmaHFlMG56RL3GWllVSYNnZXFTSzdXe7VncQNXcmVzLm3SUrE5LmZUcKNDZZVnMEhWZwgTTPJENyw6KYhWNP3SazpkZ9gETXNVN4hndzxWZzlFWrckY4hWWyllQOtWOUh7MxRWMUNVYyBTdJ3kQLhTO6okaWpkSPRHTw56NNdGVzFDTzkTW4hWSnF6TaJkZH3SUTpER4FmW48WY6BDNtdFN446QPBlTFZkNwMDapZDcxNzNnRjcnZVQ49WdCh5NhVGVz34S4JkWTdFUOZUM92Ue8tGNuZjTrlVWIFlRXZHZEV6SNVDUUdGSIN7dDJzSMRTOjN7NmNFTEpkZrUmW9NXVpZWVUFEc5IXd4FjcJ9EcxEVd05GNvYVUURkaGdUT9BnY0ZHN7lkW8ADdyoFcqB7RhVlI0IyUiwiIDJ4N9kTNwYjI0ICSiwCO5UTO6EjNxMTM0IicfJye=#Qf35VfikEMyIlI0IyQiwiIu3Waz9WZ4hXRgACdlVGaThXZsZEIv5mapdlI0IiTisHL3JSNJ9UUiojIDJCLi86bpNnblRHeFBCIyV6dllmV4J7bwVmUg2Wbql6ViojIOJyes4nILdDOIJiOiMkIsIibvl6cuVGd8VEIgc7bSlGdsVXTg2Wbql6ViojIOJyes4nI4YkNEJiOiMkIsIibvl6cuVGd8VEIgAVQM3EIg2Wbql6ViojIOJyes4nIzMEMCJiOiMkIsISZy36Qg2Wbql6ViojIOJyes4nIVhzNBJiOiMkIsIibvl6cuVGd8VEIgQnchh6QsFWaj9WYulmRg2Wbql6ViojIOJyebpjIkJHUiwiI4ATMzEDMgITM5ATNyAjMiojI4J7QiwiIwEDOwUjMwIjI0ICc8VkIsIicr9icv9iepJGZl5mLmJ7YtQnch56ciojIz5GRiwiI8qY1ESZ1MaI1YmL146J1QeJ1US90iojIh94QiwiI8ITNykTN5gTOzMDOxUTOiojIklkIs4XXbpjInxmZiwiIyYYNhA');

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

			let chartData3 = processChartData3(data); // 데이터 전처리 함수 추가
	        setGraphData3(chartData3); // 차트 데이터 설정
		
			let gridData = processGridData(data); // 데이터 전처리 함수 추가
	        setGridData(gridData); // 그리드 데이터 설정
		
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

//				console.log(f_data.trimester,':',in_data.data[i].trimester[0])
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

function setGraphData2(data) {
	 // 1. 환자 등록 현황 차트
    new wijmo.chart.FlexChart('#enrollmentChart2', {
        header: '임상시험 시계열 현황',
        legendToggle: true,
        bindingX: 'termName',
        itemsSource: data,
        series: [{
                name: '1stTrimester',
                binding: 'T-1'
            },{
                name: '2ndTrimester',
                binding: 'T-2'
            },{
                name: '3rdTrimester',
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

function processChartData2(in_data) {
    // 표시할  termName List 
	const termNames = new Array("BPA","BPF","BPS","TCS","BP3","MP","EP","PP","BP");
    
	let processedData = [];
	let originalData  = [];
//	console.log(termNames)
//	console.log('Length=',termNames.length)
	
	for (i=0; i<in_data.data.length; i++) {
		if( !(in_data.data[i].name === "NOE_1001"))
			continue;
			
		if( !(in_data.data[i].hasOwnProperty("trimester")))
			continue;
		
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
		} /* for i2 */
		//	console.log("==================================")
		if ( noTerms > 0 ) {
			//	console.log(f_data)
			originalData.push(f_data)
		}
	} /* for i */
	
	processedData = transFormData(originalData)
	console.log("transformed Data :",processedData)
	
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
	let transformedData = [];
	let termNames = Object.keys(in_data[0]).filter(key => key !== 'trimester')
	
	termNames.forEach(term => {
		const newObject = { termName: term };
		in_data.forEach(item => {
			newObject[item.trimester] = item[term];
		});
		transformedData.push(newObject);
	});
	
	return transformedData;
};

function setGraphData3(data) {
	 // 1. 환자 현황 차트
  new wijmo.chart.FlexPie('#enrollmentChart3', {
      header: '임상 산모학력 현황',
      bindingName: 'education',
      binding: 'count',
      dataLabel: {
  	      	content: (ht) => {
  	          	return `${ht.name} ${core.Globalize.format(ht.value / sum, 'p2')}`;
	   		},
      },
      itemsSource: data,
      palette: ['rgba(42,159,214,1)', 'rgba(119,179,0,1)', 'rgba(153,51,204,1)', 'rgba(255,136,0,1)',
          'rgba(204,0,0,1)', 'rgba(0,204,163,1)', 'rgba(61,109,204,1)', 'rgba(82,82,82,1)', 'rgba(0,0,0,1)']
      
  });
}

function processChartData3(in_data) {
    // 표시할  termName List 
	const edu_label = {"e1":"1-HighSchool","e2":"2-College","e3":"3-University","e4":"4-Graduate"};
    
	let processedData = [];
	let originalData  = [];
//	console.log(termNames)
//	console.log('Length=',termNames.length)

	var  edu_code = ""
	const f_data = new Object();
	
	for (i=0; i<in_data.data.length; i++) {
		
		if(!(in_data.data[i].hasOwnProperty("trimester")))
			continue;
		
		if(in_data.data[i].trimester[0] !== '1')
			continue
			
		if(!(in_data.data[i].hasOwnProperty("education")))
			continue;
		
		edu_code = "e"+in_data.data[i].education[0];
				
		if( !edu_label.hasOwnProperty(edu_code)) 
			continue
				
		if( !f_data.hasOwnProperty(edu_code)){
			f_data[edu_code] = 0;
		}
	
		f_data[edu_code] += 1

	} /* for i */
	
	console.log("==================================")
	console.log("f-data :",f_data)
	
	
	for( let key in f_data ) {
		let edu_record = {};
		edu_record.education = edu_label[key];
		edu_record.count = f_data[key];
		
		processedData.push(edu_record);
	}
	
	console.log("processed Data :",processedData)
	
//	processedData = [
//		{education:'1-High School',count:3},	    
//		{education:'2-College',count:50},	    
//		{education:'3-University',count:150},	    
//		{education:'4-Graduate',count:39},	    
//	];

	return processedData;
}

function setGridData(data) {
	// 1. 환자 현황 차트
	var theGrid = new FlexGrid('#theGrid', {
	   autoGenerateColumns: false,
	   columns: [
		//	{binding: 'id', header: 'No', width: '1*'},
		   {binding: 'termName', header: 'TermName', width: '2*'},
		   {binding: 't1', header: '1st Trimester', width: '*', format: 'n2'},
		   {binding: 't2', header: '2nd Trimester', width: '*', format: 'n2'},
		   {binding: 't3', header: '3rd Trimester', width: '*', format: 'n2'}
	   ],
      itemsSource: data
	});
	 
	// show the current item
	var selItemElement = document.getElementById('selectedItem');
	function updateCurrentInfo() {
		selItemElement.innerHTML = format('TermName: <b>{termName}</b>, 1st Trimester:<b>{t-1:c0}</b> 2nd Trimester:<b>{t-2:c0}</b>  3rd Trimester:<b>{t-3:c0}</b>',
				theGrid.collectionView.currentItem	);
	}
	
	// update current item now and when the grid selection changes
	updateCurrentInfo();
	var sd = new SortDescription('id', true);
	theGrid.collectionView.sortDescription.push(sd);
}

function processGridData(in_data) {
    // 표시할  termName List 
	const tri_label = {"t1":"1st Trimester","t2":"2nd Trimester","t3":"3rd Trimester"};
	const termNames = new Array("BPA","BPF","BPS","TCS","BP3","MP","EP","PP","BP");
    
	let processedData = [];
	let originalData  = [];
//	console.log(termNames)
//	console.log('Length=',termNames.length)

	var  tri_code = ""
	const f_data = new Object();
	
	for (i=0; i<in_data.data.length; i++) {
		if(!(in_data.data[i].name == "NOE_1001"))
			continue;
			
		if( !in_data.data[i].hasOwnProperty("trimester"))
			continue;

		tri_code = "t"+in_data.data[i].trimester[0];
				
		let noTerms = 0;
		for (i2=0; i2<termNames.length; i2++) {
			termName = termNames[i2]
			if(in_data.data[i].hasOwnProperty(termName)){
				//	console.log(termName,':', in_data.data[i][termName])
				noTerms += 1
				f_data[termName] = in_data.data[i][termName]
			}
			//	console.log("==================================")
			if ( noTerms > 0 ) {
				//	console.log(f_data)
				originalData.push(f_data)
			}
		} /* for - i2 */
		
	} /* for - i */
		
	processedData = transFormData(originalData)
	console.log("transformed Data :",processedData)
	console.log("==================================")
	
	originalData = [];
	for( j=0; j<processedData.length; j++ ) {
		let term_record = processedData[j];
		term_record["id"] = j;
		
		originalData.push(term_record);
	}

	console.log("processed Data :",originalData)
	
//	processedData = [
//		{id:1 ,termName:'BPA', t1:0.22, t2:10.00, t3:300.04},	    
//	    {id:2 ,termName:'BPF', t1:0.13, t2:15.50, t3:100.50},
//	];

	return originalData;
}

</script>