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
		<liferay-ui:header title="ecrf-user.visualizer.title.view-visualizer"/>
		
		<!-- Display each cohort data chart by Tab -->
		<liferay-ui:tabs names="NoE_MoC, EDPS, KATRI" refresh="false" value="${param.tab}">
		
		
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
	
	if(edpsId > 0) {
		getEDPSData(edpsId);
	}
	
	if(katriId > 0) {
		getKATRIData(katriId);
	}
	

});





function getEDPSData(crfId) {
	console.log("edps cohort data loading");
	$.ajax({
		url: '<portlet:resourceURL id="<%=ECRFVisualizerMVCCommand.RESOURCE_GET_EDPS %>"></portlet:resourceURL>',
		type:'post',
		dataType: 'json',
		data:{
			<portlet:namespace/>crfId: crfId,
		},
		success: function(obj){
			
			console.log("crfId : ", crfId);
			console.log("data : ", obj);		
			
			$("#<portlet:namespace/>dataCount").text(100);
			
			console.log("*******EDPS******", obj.data);
			let groupData = obj.group; //추가 한것
			let mergedGroupData = getGroupData(groupData);
			
			//let average = averageData3(obj); 
			//let processedData = reverseTransformData(average);
			setEDPSGridData(mergedGroupData, obj);
			
		},
		error: function(jqXHR, a, b){
			console.log('Fail to render trimester graph');
		}
	});
}

function getKATRIData(crfId) {
	console.log("katri cohort data loading");
	
	$.ajax({
		url: '<portlet:resourceURL id="<%=ECRFVisualizerMVCCommand.RESOURCE_GET_KATRI %>"></portlet:resourceURL>',
		type:'post',
		dataType: 'json',
		data:{
			<portlet:namespace/>crfId: crfId,
		},
		success: function(obj){
			console.log("crfId : ", crfId);
			console.log("data : ", obj.data);		
			
			$("#<portlet:namespace/>dataCount").text(100);
			
			let groupData = obj.group; //추가 한것
			
			console.log("*******KATRI******", obj.data);
			let mergedGroupData = getGroupData(groupData);
			

			setKATRIGridData(mergedGroupData, obj); 
		},
		error: function(jqXHR, a, b){
			console.log('Fail to render trimester graph');
		}
	});
}

function getGraphData(crfId) {
	$.ajax({
		url: '<portlet:resourceURL id="<%=ECRFVisualizerMVCCommand.RESOURCE_GET_NOE_MOC %>"></portlet:resourceURL>',
		type:'post',
		dataType: 'json',
		data:{
			<portlet:namespace/>crfId: crfId,
		},
		success: function(obj){

			console.log("crfId : ", crfId);
			console.log("data : ", obj.data[0]);
			console.log("group : ", obj.group);// 추가 한 것

			// set data to chart
			$("#<portlet:namespace/>dataCount").text(100);
			console.log("*******NoEMoC_getGraphData******", obj.data);
			let groupData = obj.group; //추가 한것
			let mergedGroupData = getGroupData(groupData);
			console.log("*******NoEMoC_mergedGroupData******", mergedGroupData);
			
			
			renderGroupInfo(mergedGroupData);// 추가한것
			
			//let average = averageData2(obj); // 데이터 전처리 함수 추가
			//let average2 = averageData(obj); // 데이터 전처리 함수 추가
			setNoEMoCGridData(mergedGroupData, obj);// 추가한 것
			
			

		},
		error: function(jqXHR, a, b){
			console.log('Fail to render trimester graph');
		}
	});
}

function getGroupData(group) {
    const keys = [];
    const displayList = [];

    group.forEach(item => {
        const g1 = Array.isArray(item) ? item[1] : item.g1;
        const g2 = Array.isArray(item) ? item[2] : item.g2;
        const cohot = Array.isArray(item) ? item[3] : item.cohot;
        const termName = Array.isArray(item) ? item[0] : item.termName;

        const key = g1 + '|' + g2;

        let idx = keys.indexOf(key);

        if (idx === -1) {
            // 새로운 그룹
            keys.push(key);
            displayList.push({
                cohot: cohot,
                g1: g1,
                g2: g2,
                termNames: termName  // 초기값으로 첫 termName 넣기
            });
        } else {
            // 기존 그룹에 termName만 콤마로 이어붙이기 (중복 방지는 필요 시 추가)
            displayList[idx].termNames += ', ' + termName;
        }
    });

    return displayList;
}


function renderGroupInfo(groupArr) {
	const container = $("#groupInfo");
	console.log("groupArr", groupArr);
	container.empty(); // 기존 내용 초기화

	if (!groupArr || groupArr.length === 0) {
		container.append("<p>표시할 그룹 정보가 없습니다.</p>");
		return;
	}

	const list = $("<ul></ul>").css({
		"list-style-type": "disc",
		"padding-left": "20px"
	});

	groupArr.forEach((group, index) => {
		let text = (typeof group === "object") ? JSON.stringify(group) : group;
		list.append("<li>[" + index + "] " + text + "</li>");
	});

	container.append(list);
}


function averageData(data, terms) {
	 const dataArray = data.data;
	 const termNames = terms;

	  let processedData = [];
	  const trimesterSums = {};
	  const trimesterCounts = {}; // 각 term별로 trimester별 카운트 저장

	  dataArray.forEach(item => {
	    const trimester = item.trimester?.[0]; // '1', '2', '3'
	    if (!trimester) return;

	    termNames.forEach(term => {
	      const value = item[term];
	      if (typeof value === 'number') {
	        // 합계 초기화
	        if (!trimesterSums[term]) {
	          trimesterSums[term] = { t1: 0, t2: 0, t3: 0 };
	        }

	        // 카운트 초기화
	        if (!trimesterCounts[term]) {
	          trimesterCounts[term] = { t1: 0, t2: 0, t3: 0 };
	        }

	        if (trimester === '1') {
	          trimesterSums[term].t1 += value;
	          trimesterCounts[term].t1++;
	        } else if (trimester === '2') {
	          trimesterSums[term].t2 += value;
	          trimesterCounts[term].t2++;
	        } else if (trimester === '3') {
	          trimesterSums[term].t3 += value;
	          trimesterCounts[term].t3++;
	        }
	      }
	    });
	  });

	  console.log("=== Count by Term and Trimester ===");
	  console.table(trimesterCounts);
	  
	  const result = Object.entries(trimesterSums).map(([termName, { t1: sum1, t2: sum2, t3: sum3 }], index) => {
	    const { t1: count1 = 0, t2: count2 = 0, t3: count3 = 0 } = trimesterCounts[termName] || {};
	    return {
	      id: index + 1,
	      termName,
	      t1: count1 ? sum1 / count1 : 0,
	      t2: count2 ? sum2 / count2 : 0,
	      t3: count3 ? sum3 / count3 : 0,
	    };
	  });

	  console.log("*******NoEMoC_averageData******", result);
	  return result;
}


function averageData2(data, terms) {
	 
	  const result =averageData(data, terms);
	  processedData = reverseTransformData(result);
	  console.log("*******NoEMoC_TransposedAverageData******", processedData);

	  return processedData;
	}
	
function averageData3(data, terms) {
	  const dataArray = data.data;
	  const termNames = terms

	  let processedData = [];
	  const trimesterSums = {};
	  const trimesterCounts = {};

	  dataArray.forEach(item => {
	    const trimester = item.trimester?.[0]; 
	    const category = (trimester === '1' || trimester === '2' || trimester === '3') ? trimester : 'other';

	    termNames.forEach(term => {
	      const value = item[term];
	      if (typeof value === 'number') {
	        if (!trimesterSums[term]) {
	          trimesterSums[term] = { other: 0 };
	        }
	        if (!trimesterCounts[term]) {
	          trimesterCounts[term] = {other: 0 };
	        }

	        if (category === '1') {
	         
	        } else if (category === '2') {
	          
	        } else if (category === '3') {
	         
	        } else {
	          trimesterSums[term].other += value;
	          trimesterCounts[term].other++;
	        }
	      }
	    });
	  });

	  console.log("=== Count by Term and Trimester ===");
	  console.table(trimesterCounts);

	  const result = Object.entries(trimesterSums).map(([termName, { other }], index) => {
	    const { other: cOther = 0 } = trimesterCounts[termName] || {};
	    return {
	      id: index + 1,
	      termName,
	      other: cOther ? other / cOther : 0,
	    };
	  });

	  console.log("result :", result);
	  return result;
	}


function averageData4(data, terms) {
	  const dataArray = data.data;
	  
	  const termNames = terms;

	  let processedData = [];
	  const trimesterSums = {};
	  const trimesterCounts = {};

	  dataArray.forEach(item => {
	    const trimester = item.trimester?.[0]; 
	    const category = (trimester === '1' || trimester === '2' || trimester === '3') ? trimester : 'other';

	    termNames.forEach(term => {
	      const value = item[term];
	      if (typeof value === 'number') {
	        if (!trimesterSums[term]) {
	          trimesterSums[term] = { other: 0 };
	        }
	        if (!trimesterCounts[term]) {
	          trimesterCounts[term] = {other: 0 };
	        }

	        if (category === '1') {
	         
	        } else if (category === '2') {
	          
	        } else if (category === '3') {
	         
	        } else {
	          trimesterSums[term].other += value;
	          trimesterCounts[term].other++;
	        }
	      }
	    });
	  });

	  console.log("=== Count by Term and Trimester ===");
	  console.table(trimesterCounts);

	  const result = Object.entries(trimesterSums).map(([termName, { other }], index) => {
	    const { other: cOther = 0 } = trimesterCounts[termName] || {};
	    return {
	      id: index + 1,
	      termName,
	      other: cOther ? other / cOther : 0,
	    };
	  });

	  console.log("result :", result);
	  return result;
	}



function reverseTransformData(transformedData) {
	if (!Array.isArray(transformedData) || transformedData.length === 0) {
		return null;
	}

	const result = [];
	const trimesterKeys = Object.keys(transformedData[0]).filter(key => key !== 'termName');

	trimesterKeys.forEach(trimester => {
		if (trimester === 'id') return; // 'id' 항목은 무시

		const row = { trimester };

		transformedData.forEach(item => {
			row[item.termName] = item[trimester];
		});

		result.push(row);
	});

	return result;
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

function setNoEMoCGridData(data, obj) {
	const view = new wijmo.collections.CollectionView(data, {
		pageSize: 10
	});

	const theGrid = new wijmo.grid.FlexGrid('#theNoEMoCGrid', {
		autoGenerateColumns: false,
		columns: [
			{ binding: 'cohot', header: 'cohot', width: '1*' },
			{ binding: 'g2', header: '대분류', width: '*' },
			{ binding: 'g1', header: '소분류', width: '*' },
			{ binding: 'termNames', header: 'TermNames', width: '2*' },
			{ // 선택 버튼 컬럼 추가
				header: 'Action',
				width: '*',
				// binding 없이 Action 열만 출력
			}
		],
		itemsSource: view
	});

	theGrid.formatItem.addHandler(function (s, e) {
		if (e.panel === s.cells) {
			const col = s.columns[e.col];
			if (col.header === 'Action') {
				const item = s.rows[e.row].dataItem;

				e.cell.innerHTML = '<button class="btn btn-primary btn-sm">선택</button>';
				const button = e.cell.querySelector('button');
				button.addEventListener('click', function () {
					  // 컨테이너 아이디 목록
	                const ids = [
	                    'enrollmentChart4',  // 꺾은선 그래프 컨테이너
	                    'enrollmentChart5',  // 막대 그래프 컨테이너
	                    'theGrid2',          // 그리드 컨테이너
	                    'pager2'             // 페이저(네비게이터) 컨테이너
	                ];

	                ids.forEach(id => {
	        			
	        			
	                    const el = document.getElementById(id);
	                    if (el) {
	                        // 1) 이 요소 내부의 Wijmo 컨트롤 전부 dispose
	                        wijmo.Control.disposeAll(el);
	                        // 2) DOM 을 깨끗이 비우기
	                        el.innerHTML = '';
	                    }
	                });
	
	                $('#enrollmentChart4, #enrollmentChart5, #theGrid2, #pager2').show();

					//alert("선택된 항목: " + item.termNames);
				    const terms = item.termNames; // "BPA, BPF, BPS"
				    const termNameSelected = item.termNames.split(',').map(term => term.trim());
				    console.log("*******NoEMoC_selectedTermName******", terms);
					let average = averageData2(obj, termNameSelected); // 데이터 전처리 함수 추가
					let average2 = averageData(obj, termNameSelected); // 데이터 전처리 함수 추가
				    
				    // data는 서버에서 받아온 혹은 미리 준비된 차트 데이터 배열
				    //const chartData = getChartDataForTerms(terms); // 실제 데이터를 만드는 함수 필요
				    setGraphData4(average, terms);
					setGraphData5(average2, terms); // 차트 데이터 설정
					setGridData2(average2, terms); // 그리드 데이터 설정	  
				});
			}
		}
	});
	
	
	new wijmo.input.CollectionViewNavigator('#NoEMoCPager', {
		byPage: true,
		headerFormat: 'Page {currentPage:n0} / {pageCount:n0}',
		cv: view
	});
}

function setEDPSGridData(data, obj) {
	const view = new wijmo.collections.CollectionView(data, {
		pageSize: 10
	});

	const theGrid = new wijmo.grid.FlexGrid('#theEDPSGrid', {
		autoGenerateColumns: false,
		columns: [
			{ binding: 'cohot', header: 'cohot', width: '1*' },
			{ binding: 'g2', header: '대분류', width: '*' },
			{ binding: 'g1', header: '소분류', width: '*' },
			{ binding: 'termNames', header: 'TermNames', width: '2*' },
			{ // 선택 버튼 컬럼 추가
				header: 'Action',
				width: '*',
				// binding 없이 Action 열만 출력
			}
		],
		itemsSource: view
	});

	theGrid.formatItem.addHandler(function (s, e) {
		if (e.panel === s.cells) {
			const col = s.columns[e.col];
			if (col.header === 'Action') {
				const item = s.rows[e.row].dataItem;

				e.cell.innerHTML = '<button class="btn btn-primary btn-sm">선택</button>';
				const button = e.cell.querySelector('button');
				button.addEventListener('click', function () {
					
				     // 컨테이너 아이디 목록
	                const ids = [
	                    'enrollmentChart6',  // 꺾은선 그래프 컨테이너
	                    'enrollmentChart7',  // 막대 그래프 컨테이너
	                    'theGrid3',          // 그리드 컨테이너
	                    'pager3'             // 페이저(네비게이터) 컨테이너
	                ];

	                ids.forEach(id => {
	                    const el = document.getElementById(id);
	                    if (el) {
	                        // 1) 이 요소 내부의 Wijmo 컨트롤 전부 dispose
	                        wijmo.Control.disposeAll(el);
	                        // 2) DOM 을 깨끗이 비우기
	                        el.innerHTML = '';
	                    }
	                });
	
	                $('#enrollmentChart6, #enrollmentChart7, #theGrid3, #pager3').show();
	                
					//alert("선택된 항목: " + item.termNames);
				    const terms = item.termNames; // "BPA, BPF, BPS"
				    const termNameSelected = item.termNames.split(',').map(term => term.trim());
				    
					let average = averageData3(obj, termNameSelected); 
					let processedData = reverseTransformData(average);
					
					setGraphData6(processedData, terms); 
					setGraphData7(average, terms);
					setGridData3(average, terms); // 그리드 데이터 설정	   
				});
			}
		}
	});
	
	
	new wijmo.input.CollectionViewNavigator('#EDPSPager', {
		byPage: true,
		headerFormat: 'Page {currentPage:n0} / {pageCount:n0}',
		cv: view
	});
}



function setKATRIGridData(data, obj) {
	const view = new wijmo.collections.CollectionView(data, {
		pageSize: 10
	});


	const theGrid = new wijmo.grid.FlexGrid('#theKATRIGrid', {
		autoGenerateColumns: false,
		columns: [
			{ binding: 'cohot', header: 'cohot', width: '1*' },
			{ binding: 'g2', header: '대분류', width: '*' },
			{ binding: 'g1', header: '소분류', width: '*' },
			{ binding: 'termNames', header: 'TermNames', width: '2*' },
			{ // 선택 버튼 컬럼 추가
				header: 'Action',
				width: '*',
				// binding 없이 Action 열만 출력
			}
		],
		itemsSource: view
	});

	theGrid.formatItem.addHandler(function (s, e) {
		if (e.panel === s.cells) {
			const col = s.columns[e.col];
			if (col.header === 'Action') {
				const item = s.rows[e.row].dataItem;

				e.cell.innerHTML = '<button class="btn btn-primary btn-sm">선택</button>';
				const button = e.cell.querySelector('button');
				button.addEventListener('click', function () {
					
					  // 컨테이너 아이디 목록
	                const ids = [
	                    'enrollmentChart8',  // 꺾은선 그래프 컨테이너
	                    'enrollmentChart9',  // 막대 그래프 컨테이너
	                    'theGrid4',          // 그리드 컨테이너
	                    'pager4'             // 페이저(네비게이터) 컨테이너
	                ];

	                ids.forEach(id => {
	                    const el = document.getElementById(id);
	                    if (el) {
	                        // 1) 이 요소 내부의 Wijmo 컨트롤 전부 dispose
	                        wijmo.Control.disposeAll(el);
	                        // 2) DOM 을 깨끗이 비우기
	                        el.innerHTML = '';
	                    }
	                });
	
	                $('#enrollmentChart8, #enrollmentChart9, #theGrid4, #pager4').show();
	                
					//alert("선택된 항목: " + item.termNames);
				    //const terms = item.termNames; // "BPA, BPF, BPS"
					//setGraphData6(transposedAverage, terms); 
					//setGraphData7(average, terms);
					//setGridData3(average, terms); // 그리드 데이터 설정	  
					
					
					const terms = item.termNames;
					const termNameSelected = item.termNames.split(',').map(term => term.trim());
					let average = averageData4(obj, termNameSelected); 
					let processedData = reverseTransformData(average);
					
					setGraphData8(processedData, terms); 
					
					
					setGraphData9(average, terms);
					setGridData4(average, terms); // 그리드 데이터 설정	  
				});
			}
		}
	});
	
	
	new wijmo.input.CollectionViewNavigator('#KATRIPager', {
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


function setGraphData4(data, termNamesStr) {

	
	const terms = termNamesStr.split(',').map(t => t.trim()).filter(t => t);// 추가한 것
    const seriesArray = terms.map(term => ({
        name: term,
        binding: term,
        chartType: 'LineSymbols'
    }));	
	
	
	
	 // 1. 환자 등록 현황 차트
new wijmo.chart.FlexChart('#enrollmentChart4', {
    header: '임상시험(평균) 시계열 현황',
    legendToggle: true,
    bindingX: 'trimester',
    itemsSource: data,
    series: seriesArray,
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


function setGraphData5(data, termNamesStr) {
	
	const terms = termNamesStr
	   .split(',')
	   .map(t => t.trim())
	   .filter(t => t);
	
	//const filteredData = data.filter(item => terms.includes(item.termName));
	
	const dataMap = new Map();
	data.forEach(item => {
	    dataMap.set(item.termName, item);
	});
	
	const filledData = terms.map((term, index) => {
	    if (dataMap.has(term)) {
	        return dataMap.get(term); // 있으면 그대로
	    } else {
	        return {
	            id: index + 1,
	            termName: term,
	            other: null // 없으면 기본값으로 항목 구성
	        };
	    }
	});
	
	
	 // 1. 환자 등록 현황 차트
  	new wijmo.chart.FlexChart('#enrollmentChart5', {
      header: '임상시험(평균) 시계열 현황',
      legendToggle: true,
      bindingX: 'termName',
      itemsSource: filledData,
      series: [{
              name: '1stTrimester',
              binding: 't1'
          },{
              name: '2ndTrimester',
              binding: 't2'
          },{
              name: '3rdTrimester',
              binding: 't3'
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

function transFormData2(in_data) {
	console.log("indata :", in_data);
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


function setGridData2(data, termNamesStr) {
	
	const terms = termNamesStr
    .split(',')
    .map(t => t.trim())
    .filter(t => t);
	
	//const filteredData = data.filter(item => terms.includes(item.termName));
	
	const dataMap = new Map();
	data.forEach(item => {
	    dataMap.set(item.termName, item);
	});
	
	const filledData = terms.map((term, index) => {
	    if (dataMap.has(term)) {
	        return dataMap.get(term); // 있으면 그대로
	    } else {
	        return {
	            id: index + 1,
	            termName: term,
	            other: null // 없으면 기본값으로 항목 구성
	        };
	    }
	});
	
	// Collection View로 페이징 데이터 소스 생성
	var view = new wijmo.collections.CollectionView(filledData,{
		pageSize: 10	// 한 페이지에 10건
	});
	
	var theGrid = new wijmo.grid.FlexGrid('#theGrid2', {
	   autoGenerateColumns: false,
	   columns: [
			{binding: 'id', header: 'No', width: '1*'},
		   	{binding: 'termName', header: 'TermName', width: '2*'},
		   	{binding: 't1', header: 't1', width: '*', format: 'n2'},
		   	{binding: 't2', header: 't2', width: '*', format: 'n2'},
		   	{binding: 't3', header: 't3', width: '*', format: 'n2'},
	   ],
      itemsSource: view
	});
	 
	// 페이지 네비게이터 생성
	var navigator = new wijmo.input.CollectionViewNavigator('#pager2',{
		byPage: true,
		headerFormat: 'Page {currentPage:n0} / {pageCount:n0}',
		cv: view
	});
	
}

function setGraphData6(data, termNamesStr) {
const terms = termNamesStr.split(',').map(t => t.trim()).filter(t => t);// 추가한 것
const seriesArray = terms.map(term => ({
    name: term,
    binding: term,
    chartType: 'LineSymbols'
}));		


	
	 // 1. 환자 등록 현황 차트
new wijmo.chart.FlexChart('#enrollmentChart6', {
   header: 'EDPS 항목별 평균값(꺾은선그래프)',
   legendToggle: true,
   bindingX: 'trimester',
   itemsSource: data,
   series: seriesArray,
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

function setGraphData7(data, termNamesStr) {
	
	
const terms = termNamesStr
   .split(',')
   .map(t => t.trim())
   .filter(t => t);

//const filteredData = data.filter(item => terms.includes(item.termName));

const dataMap = new Map();
data.forEach(item => {
    dataMap.set(item.termName, item);
});

const filledData = terms.map((term, index) => {
    if (dataMap.has(term)) {
        return dataMap.get(term); // 있으면 그대로
    } else {
        return {
            id: index + 1,
            termName: term,
            other: null // 없으면 기본값으로 항목 구성
        };
    }
});
	 // 1. 환자 등록 현황 차트
new wijmo.chart.FlexChart('#enrollmentChart7', {
    header: 'EDPS 항목별 평균값(막대그래프)',
    legendToggle: true,
    bindingX: 'termName',
    itemsSource: filledData,
    series: [
   	 {
            name: 'other',
            binding: 'other'
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


function setGridData3(data, termNamesStr) {
	
	
	const terms = termNamesStr
	   .split(',')
	   .map(t => t.trim())
	   .filter(t => t);

	//const filteredData = data.filter(item => terms.includes(item.termName));

	const dataMap = new Map();
	data.forEach(item => {
	    dataMap.set(item.termName, item);
	});

	const filledData = terms.map((term, index) => {
	    if (dataMap.has(term)) {
	        return dataMap.get(term); // 있으면 그대로
	    } else {
	        return {
	            id: index + 1,
	            termName: term,
	            other: null // 없으면 기본값으로 항목 구성
	        };
	    }
	});
	
	// Collection View로 페이징 데이터 소스 생성
	var view = new wijmo.collections.CollectionView(filledData,{
		pageSize: 10	// 한 페이지에 10건
	});
	
	var theGrid = new wijmo.grid.FlexGrid('#theGrid3', {
	   autoGenerateColumns: false,
	   columns: [
			{binding: 'id', header: 'No', width: '1*'},
		   	{binding: 'termName', header: 'TermName', width: '2*'},
		   	{binding: 'other', header: 'other', width: '*', format: 'n2'},
	   ],
     itemsSource: view
	});
	 
	// 페이지 네비게이터 생성
	var navigator = new wijmo.input.CollectionViewNavigator('#pager3',{
		byPage: true,
		headerFormat: 'Page {currentPage:n0} / {pageCount:n0}',
		cv: view
	});
	
}


function setGraphData8(data, termNamesStr) {
	
	const terms = termNamesStr.split(',').map(t => t.trim()).filter(t => t);// 추가한 것
    const seriesArray = terms.map(term => ({
        name: term,
        binding: term,
        chartType: 'LineSymbols'
    }));	
	 // 1. 환자 등록 현황 차트
new wijmo.chart.FlexChart('#enrollmentChart8', {
  header: 'KATRI 항목별 평균값(꺾은선그래프)',
  legendToggle: true,
  bindingX: 'trimester',
  itemsSource: data,
  series: seriesArray,
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

function setGraphData9(data, termNamesStr) {
	
	const terms = termNamesStr
	   .split(',')
	   .map(t => t.trim())
	   .filter(t => t);

	//const filteredData = data.filter(item => terms.includes(item.termName));

	const dataMap = new Map();
	data.forEach(item => {
	    dataMap.set(item.termName, item);
	});

	const filledData = terms.map((term, index) => {
	    if (dataMap.has(term)) {
	        return dataMap.get(term); // 있으면 그대로
	    } else {
	        return {
	            id: index + 1,
	            termName: term,
	            other: null // 없으면 기본값으로 항목 구성
	        };
	    }
	});
	 // 1. 환자 등록 현황 차트
	new wijmo.chart.FlexChart('#enrollmentChart9', {
   header: 'KATRI 항목별 평균값(막대그래프)',
   legendToggle: true,
   bindingX: 'termName',
   itemsSource: filledData,
   series: [
  	 {
           name: 'other',
           binding: 'other'
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


function setGridData4(data, termNamesStr) {
	
	const terms = termNamesStr
	   .split(',')
	   .map(t => t.trim())
	   .filter(t => t);

	//const filteredData = data.filter(item => terms.includes(item.termName));

	const dataMap = new Map();
	data.forEach(item => {
	    dataMap.set(item.termName, item);
	});

	const filledData = terms.map((term, index) => {
	    if (dataMap.has(term)) {
	        return dataMap.get(term); // 있으면 그대로
	    } else {
	        return {
	            id: index + 1,
	            termName: term,
	            other: null // 없으면 기본값으로 항목 구성
	        };
	    }
	});
	
	// Collection View로 페이징 데이터 소스 생성
	var view = new wijmo.collections.CollectionView(filledData,{
		pageSize: 10	// 한 페이지에 10건
	});
	
	var theGrid = new wijmo.grid.FlexGrid('#theGrid4', {
	   autoGenerateColumns: false,
	   columns: [
			{binding: 'id', header: 'No', width: '1*'},
		   	{binding: 'termName', header: 'TermName', width: '2*'},
		   	{binding: 'other', header: 'other', width: '*', format: 'n2'},
	   ],
    itemsSource: view
	});
	 
	// 페이지 네비게이터 생성
	var navigator = new wijmo.input.CollectionViewNavigator('#pager4',{
		byPage: true,
		headerFormat: 'Page {currentPage:n0} / {pageCount:n0}',
		cv: view
	});
	
}


</script>