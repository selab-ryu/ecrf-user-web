<%@page import="com.sx.icecap.service.DataTypeLocalServiceUtil"%>
<%@page import="com.sx.icecap.service.DataTypeLocalService"%>
<%@page import="com.sx.icecap.model.DataType"%>
<%@ page contentType="text/html;charset=UTF-8"%>

<%@ page import="ecrf.user.model.CRF"%>
<%@ include file="/init.jsp" %>

<%! private Log _log = LogFactoryUtil.getLog("/view_jsp"); %>

<%
	// set crf id by crf variable name
	// noe_moc crf var : noe_moc_crf
	// epds crf var : edps_2018_crf
	// katri crf var : katri_2023_crf
	
	String noemocName = "noe_moc_crf";
	String edpsName = "edps_2018_crf";
	String katriName = "katri_2023_crf";
	
	CRF nmCRF = CRFLocalServiceUtil.getCRFByName(noemocName);
	CRF edpsCRF = CRFLocalServiceUtil.getCRFByName(edpsName);
	CRF katriCRF = CRFLocalServiceUtil.getCRFByName(katriName);
	
	long nmCRFId = 0;
	long edpsCRFId = 0;
	long katriCRFId = 0;
	
	if(Validator.isNotNull(nmCRF)) nmCRFId = nmCRF.getCrfId();
	if(Validator.isNotNull(edpsCRF)) edpsCRFId = edpsCRF.getCrfId();
	if(Validator.isNotNull(katriCRF)) katriCRFId = katriCRF.getCrfId();
%>

<div class="ecrf-user">
	<div class="pad1r">
		<liferay-ui:header title="ecrf-user.visualizer.title.view-visualizer" />
		
		<!-- Display each cohort data chart by Tab -->
		<liferay-ui:tabs names="NoE_MoC, EDPS, KATRI" refresh="false" value="NoE_MoC">
			<liferay-ui:section>
				<%@ include file="/section/noe_moc.jspf"  %>
			</liferay-ui:section>
			
			<liferay-ui:section>
				<%@ include file="/section/edps.jspf"  %>
			</liferay-ui:section>
			
			<liferay-ui:section>
				<%@ include file="/section/katri.jspf"  %>
			</liferay-ui:section>
			
		</liferay-ui:tabs>
	</div>
</div>

<script>
$(document).ready(function() {
	console.log("graph data loading");
		
	let nmId = <%=nmCRFId%>;
	let edpsId = <%=edpsCRFId%>;
	let katriId = <%=katriCRFId%>;
	
	console.log(nmId, edpsId, katriId);
	
	// NoE_MoC Data Graph
	if(nmId > 0) {
		getGraphData(nmId);	
	}
	
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
	const termNames = new Array("BPA","BPF","BPS","TCS","BP3","MP","EP","PP","BP");
	var series_obj = [];

	for(i=0; i<termNames.length; i++ ) {
		termName = termNames[i];
	    var one_series = new Object();
	    one_series['name'] = termName;
	    one_series['binding'] = termName;
	    one_series['chartType'] = 'LineSymbols';
	    series_obj.push(one_series);
	};
	 
  new wijmo.chart.FlexChart('#enrollmentChart', {
      header: '임상시험 시계열 현황',
      legendToggle: true,
      bindingX: 'trimester',
      itemsSource: data,
      series: series_obj,
/*      series: [
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
*/
      axisY: {
          title: 'Unrine Data(Value)'
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
	
	console.log("LINE processed Data :",processedData)
	
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
	console.log("BAR transformed Data :",processedData)
	
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
	};
	
	console.log("PIE processed Data :",processedData)
	
//	processedData = [
//		{education:'1-High School',count:3},	    
//		{education:'2-College',count:50},	    
//		{education:'3-University',count:150},	    
//		{education:'4-Graduate',count:39},	    
//	];

	return processedData;
}

function setGridData(data) {
	// Collection View로 페이징 데이터 소스 생성
	var view = new wijmo.collections.CollectionView(data,{
		pageSize: 10	// 한 페이지에 10건
	});
	
	var theGrid = new wijmo.grid.FlexGrid('#theGrid', {
	   autoGenerateColumns: false,
	   columns: [
			{binding: 'id', header: 'No', width: '1*'},
		   	{binding: 'termName', header: 'TermName', width: '2*'},
		   	{binding: 't1', header: '1st Trimester', width: '*', format: 'n2'},
		   	{binding: 't2', header: '2nd Trimester', width: '*', format: 'n2'},
		   	{binding: 't3', header: '3rd Trimester', width: '*', format: 'n2'}
	   ],
      itemsSource: view
	});
	 
	// 페이지 네비게이터 생성
	var navigator = new wijmo.input.CollectionViewNavigator('#pager',{
		byPage: true,
		headerFormat: 'Page {currentPage:n0} / {pageCount:n0}',
		cv: view
	});
	
}

function processGridData(in_data) {
    // 표시할  termName List 
	const tri_label = {"t1":"1st Trimester","t2":"2nd Trimester","t3":"3rd Trimester"};
	const termNames = new Array("BPA","BPF","BPS","TCS","BP3","MP","EP","PP","BP");
    
	let originalData  = [];
	let transformedData = [];
	let processedData = [];
//	console.log(termNames)
//	console.log('Length=',termNames.length)

	var  tri_code = ""
//	const f_data = new Object();
	
	for (i=0; i<in_data.data.length; i++) {
		if(!(in_data.data[i].name == "NOE_1001"))
			continue;
			
		if( !in_data.data[i].hasOwnProperty("trimester"))
			continue;
		
		const f_data = new Object();
		tri_code = "t"+in_data.data[i].trimester[0];
		f_data.trimester = tri_code;
				
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
		
	transformedData = transFormData(originalData)
	console.log("GRID transformed Data :",transformedData)
	console.log("==================================")
	

	processedData = [];
	for( j=0; j<transformedData.length; j++ ) {
		let term_record = transformedData[j];
		term_record["id"] = j;
		
		processedData.push(term_record);
	}

	console.log("GRID processed Data :",processedData)

//	processedData = [
//		{id:1 ,termName:'BPA', t1:0.22, t2:10.00, t3:300.04},	    
//	    {id:2 ,termName:'BPF', t1:0.13, t2:15.50, t3:100.50},
//	];

	return processedData;
}

</script>