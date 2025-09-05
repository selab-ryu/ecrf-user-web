<%@ include file="../../init.jsp" %>

<%
    String portalURL = themeDisplay.getPortalURL();
    String contextPath = themeDisplay.getPathContext();
    String teethsParam1 = request.getParameter("teeths");
    String trueParam = (String) request.getAttribute("teeths");
    request.setAttribute("teeths", trueParam);
    String teethsParam = (String) request.getAttribute("teeths");
%>
<%! 
   // JSP 컴파일 시점에 한 번만 초기화되는 logger 인스턴스 
   private Log _log = LogFactoryUtil.getLog("add-teeth_jsp"); 
%>

<%
    // 1) DB에서 전체 이력 조회
    List<TreatmentHistory> allHistories = TreatmentHistoryLocalServiceUtil.getPatientTreatmentList(1001);

    // 2) JSON 배열로 변환
    JSONArray allHistoryJson = JSONFactoryUtil.createJSONArray();
    for (TreatmentHistory th : allHistories) {
        JSONObject obj = JSONFactoryUtil.createJSONObject();
        obj.put("region",    "Teeth" + th.getTeethNum());
        obj.put("date",      new SimpleDateFormat("yyyy-MM-dd").format(th.getTreatmentDate()));
        obj.put("treatment", th.getTreatment());  // 예: "AF,Gugang"
        obj.put("state",     th.getState());      // 예: "C1,Y"
        allHistoryJson.put(obj);
          
    }
    _log.info("allHistoryJson → " + allHistoryJson.toString());
%>

<c:set var="allHistoryData" value="${allHistoryJson.toString()}" />
<script>
  // 전역에 배열로 저장
  const allHistoryData = <%= allHistoryJson.toString() %>;
  const teethsParam = '<%= teethsParam.toString() %>';
  console.log("전체 이력:", allHistoryData);
  console.log("선택 치아:", teethsParam);
</script>

<html>
<head>
  <title>Teeth View</title>
  <style>
    #imageWrapper {
      position: relative;
      max-width: 90%;
      margin: 0 auto;
    }

    #patientImage {
      width: 100%;
      height: auto;
      display: block;
      user-select: none;
    }

    .region {
      position: absolute;
      border: 2px solid black;
      opacity: 0.5;
      cursor: pointer;
      z-index: 10;
    }

    #historyContainer {
      margin-top: 30px;
    }

    #historyContainer h4 {
      margin-bottom: 5px;
    }

    #historyContainer ul {
      margin-top: 0;
      margin-bottom: 15px;
      padding-left: 20px;
    }

    .treatment-row {
      display: flex;
      flex-direction: column;    /* <- 추가 */
      align-items: flex-start;   /* 왼쪽 정렬 */
      gap: 20px;                 /* 박스 사이 간격 */
      margin-top: 10px;
    }
    
    .treatment-column {
      display: flex;
      align-items: stretch;
      justify-content: flex-start;
      gap: 15px;
      margin-top: 20px;
      flex-wrap: wrap;
    
    }
    
	.treatment-box {
	  border: 1px solid #ccc;
	  padding: 6px;
	  min-width: 200px;
	  width: 1050px; /* 고정된 너비 설정 */
	  display: flex;
	  flex-direction: column;
	  justify-content: flex-start; /* 박스가 커지더라도 내용은 위에 고정 */
	  flex-grow: 0;
	  flex-shrink: 0;
	  height: auto;
	}

	.treatment-box-date {
	  border: 1px solid #ccc;
	  padding: 10px;
	  min-width: 200px;
	  width: 1160px; /* 고정된 너비 설정 */
	  display: flex;
	  flex-direction: column;
	  justify-content: flex-start; /* 박스가 커지더라도 내용은 위에 고정 */
	  flex-grow: 0;
	  flex-shrink: 0;
	  height: auto;
	}

    .option-group label {
      display: inline-flex;     /* 가로 안에서 inline 배치 */
      align-items: center;
      margin: 0;                /* gap으로 간격 제어 */
    }

    .option-group {
      display: flex;            /* <- 변경 */
      flex-wrap: wrap;          /* 줄바꿈 허용 */
      flex-direction: row;      /* 가로 정렬 */
      gap: 15px;                /* 옵션들 사이 간격 */
    }

    .separator {
      border-top: 2px solid #ccc;
      margin: 10px 0;
    }
    
  table.custom-table-outer {
  	width: 1160px;
    border-collapse: collapse;
   	text-align: left; 
  }

  .custom-table-outer th,
  .custom-table-outer td {
    border: 1px solid #ccc;
    padding: 10px;
    vertical-align: middle;
    font-size: 15px;
  }
  
  .custom-table-outer th {
  text-align: center;  /* th 요소들만 가운데 정렬 */
	}

  .custom-table-outer label {
  	display: block;  /* 라벨을 블록으로 처리하여 세로로 나열 */
    margin: 0 5px;
  }  
    
    
    
  table.custom-table {
  	width: 1050px;
    border-collapse: collapse;
   	text-align: left; 
  }

  .custom-table th,
  .custom-table td {
    border: 1px solid #ccc;
    padding: 6px;
    vertical-align: middle;
    font-size: 15px;
  }
  
  .custom-table th {
  text-align: center;  /* th 요소들만 가운데 정렬 */
	}

  .custom-table label {
  	display: block;  /* 라벨을 블록으로 처리하여 세로로 나열 */
    margin: 0 5px;
  }
  
	  #radioButtonWrapper {
	  display: inline-flex;
	  flex-direction: row;
	  gap: 20px;
	}
	
	#radioButtonWrapper p {
	  margin: 0;
	  font-weight: bold;
	  vertical-align: middle;  /* 텍스트가 수평 정렬되도록 */
	}
	
	#radioButtonWrapper label {
	  display: inline-flex;
	  align-items: center;
	  margin: 0;
	}
  
	.inline-section {
	  display: flex;                   /* 같은 비율로 균등 분할 */
	  align-items: center;
	  gap: 8px;
	  padding: 6px;
	  box-sizing: border-box;
	}
	
	.inline-section:first-child {
	  flex: 1;
	}
	
	.inline-section:last-child {
	  flex: 2;
	}
	
	.inline-section p {
	  margin-right: 5px;
	  white-space: nowrap;
	}
	
	.with-border {
	  border-left: 1px solid #ccc;
	}
	 
	.mar-r-2 { margin-right:2px;}
  </style>
</head>
<body>

<aui:script>
  console.log("Received teeths:", "<%= teethsParam %>");
</aui:script>

<div style="padding:10px;">

	<div style="padding: 0px 0px; font-size: 20px; font-weight: bold;">
	   치식 번호: <span id="jointNumLabel"></span> 개 [ <span id="selectedButtonsLabel"></span> ] 
	</div>
	
	
	<div id="imageWrapper">
	  <img id="patientImage" src="/o/teeth-web/images/teeth.png" alt="Patient Teeth" draggable="false" />
	</div>
	
	<div class="treatment-row">
	  <!-- 날짜 선택 -->
	  <div class="treatment-box-date option-group">
	    <label for="treatmentDate"><strong>Date 입력</strong></label><br>
	    <input type="date" name="treatmentDate" id="treatmentDate" min="2025-01-01" max="">
	    <span id="ageDiff" style="margin-left: 15px; font-size: 1rem; color: #555;"></span>
	  </div>
	  
	


	
	
	</div>
	
	<div class="separator"></div>
    
    
    <div class="treatment-row">
	 
	<table class="custom-table-outer">
	<tr>
	<td style="width: 120px; text-align: center;">
	State
	</td>
	<td>
		<table class="custom-table">
		
		  <tr>
		   <th rowspan="2" style="background-color: #d4edda;">
			 C (Dental <span style="color: red;">c</span>aries)
			</th>
		    <th colspan="2" style="background-color: #d1ecf1;">
		        DD (<span style="color: red;">D</span>evelopmental <span style="color: red;">D</span>efects of enamel)
		    </th>

		  </tr>
		  <tr>
		  <th style="background-color: #d1ecf1;">
		    M (hypo<span style="color: red;">M</span>ineralization)
		    </th>
		    <th style="background-color: #d1ecf1;">
		    P (hypo<span style="color: red;">P</span>lasia)
		    </th>
		  </tr>
		  <tr>
			<td>
			  <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 5px;">
			    <label><input type="radio" name="permanentC" value="C1"/> C1</label>
			    <label><input type="radio" name="permanentC" value="C2"/> C2</label>
			    <label><input type="radio" name="permanentC" value="C3"/> C3</label>
			  </div>
			</td>
		    <td>
		   	  <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 5px;">
			      <label><input type="checkbox" name="permanentDD" value="W"/> W (White)</label>
			      <label><input type="checkbox" name="permanentDD" value="Y"/> Y (Yellow)</label>
			      <label><input type="checkbox" name="permanentDD" value="B"/> B (Brown)</label>
		      </div>
		    </td>
		    <td>
		    	<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 5px;">
			      <label><input type="checkbox" name="permanentDD" value="E"/> E (Enamel)</label>
			      <label><input type="checkbox" name="permanentDD" value="D"/> D (Dentin)</label>
		    	</div>
		    </td>
		    </td>
		  </tr>
		</table>
	 </td>
     </tr>
    </table>
    </div>
    
    <div class="separator"></div>
	
	
	<div class="treatment-row" >
	  <!-- 대분류 -->
	  <table class="custom-table-outer">
	  <tr>
	  <td style="width: 120px; text-align: center;" >
	  treatment
	  </td>
	  <!-- 수복 -->
	  <td>
	  <div id="radioButtonWrapper" class="treatment-box option-group" >
		  <div class="inline-section">
		    <p><strong>예방</strong></p>
		    <div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
		    <label><input type="checkbox" class="mar-r-2" name="status" value="TFA" data-category="예방"/> 불소도포 </label>
		    <label><input type="checkbox" class="mar-r-2" name="status" value="SC" data-category="예방"/> 스케일링 </label>
		    </div>
		  </div>
		
		  <!-- 수복 -->
		  <div class="inline-section with-border">
		    <p><strong>수복</strong></p>
		    <div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
		    <label><input type="checkbox" class="mar-r-2" name="status" value="Seal" data-category="수복"/> 실란트 </label>
		    <label><input type="checkbox" class="mar-r-2" name="status" value="AF" data-category="수복"/> 아말감 </label>
		    <label><input type="checkbox" class="mar-r-2" name="status" value="RF" data-category="수복"/> 레진 </label>
		    <label><input type="checkbox" class="mar-r-2" name="status" value="Gl" data-category="수복"/> 글라스아이오노머 </label>
		    <label><input type="checkbox" class="mar-r-2" name="status" value="SS" data-category="수복"/> 기성금속관 </label>
		    <label><input type="checkbox" class="mar-r-2" name="status" value="Zr" data-category="수복"/> 지르코니아크라운 </label>
		     </div>
		  </div>
	  
	  </div>
	  
	  <!-- 치수 -->
	  <div id="radioButtonWrapper" class="treatment-box option-group">
	  	<div class="inline-section">
	  	<p><strong>외과</strong></p>
	  	<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
	    <label><input type="checkbox" class="mar-r-2" name="status" value="Ext" data-category="외과"/> 발치</label>
	     <!-- yes일 경우 서술 공간 필요 -->
	    <label><input type="checkbox" class="mar-r-2" name="status" value="oral" data-category="외과"/> 구강소수술</label>
	    </div>
	    </div>
	    <div class="inline-section with-border">
	    <p><strong>치수</strong></p>
	    <div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
	    <label><input type="checkbox" class="mar-r-2" name="status" value="Pulpo" data-category="치수"/> Pulpotomy</label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="Pulpec" data-category="치수"/> Pulpectomy</label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="Apexo" data-category="치수"/> Apexogenesis</label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="Apexi" data-category="치수"/> Apexification</label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="RCT" data-category="치수"/> Root canal treatment</label>
	    </div>
	    </div>
	  </div>
	  
	  
	  <!-- 교정 -->
	  <div id="radioButtonWrapper" class="treatment-box option-group">
	  	<div class="inline-section">
	  	<p><strong>전신마취</strong></p>
	  	<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
	    <label><input type="checkbox" class="mar-r-2" name="status" value="DOR" data-category="전신마취"/> DOR </label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="MOR" data-category="전신마취"/> MOR </label>
	    </div>
	    </div>
	    <div class="inline-section with-border">
	    <p><strong>교정</strong></p>
	    <div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
	    <label><input type="checkbox" class="mar-r-2" name="status" value="firstStraighten" data-category="교정"/> 1차교정</label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="secondStraighten" data-category="교정"/> 2차교정</label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="partialStraighten" data-category="교정"/> 부분교정(장치비+월비)</label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="muscleFunction" data-category="교정"/> 근기능장치</label>
	    </div>
	    </div>
	  </div>
	  
	  <!-- 공간유지장치 -->
	  <div id="radioButtonWrapper" class="treatment-box option-group">
	  	<div class="inline-section">
	    <p><strong>공간유지장치</strong></p>
	    <div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
	    <label><input type="checkbox" class="mar-r-2" name="status" value="BL" data-category="공간유지장치"/> B-L </label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="LA" data-category="공간유지장치"/> L-A </label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="NHA" data-category="공간유지장치"/> NHA </label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="RSM" data-category="공간유지장치"/> RSM </label>
	    </div>
	    </div>
	    <div class="inline-section with-border">
	    <p><strong>진정</strong></p>
	     <div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
	    <label><input type="checkbox" class="mar-r-2" name="status" value="N2OSedation" data-category="진정"/> N2O흡인진정 </label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="LASedation" data-category="진정"/> 경구진정 </label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="NHASedation" data-category="진정"/> 근육진정 </label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="RSMSedation" data-category="진정"/> 정주진정 </label>
	    </div>
	    </div>
	  </div>
	  
	  </td>
	  </tr>
	  </table>
	</div>
	
    <div  class="treatment-column" >
	    <button id="addTreatmentBtn" type="button" style="padding: 5px 15px; font-size:15px;" disabled>
	      Add Record
	    </button>
	    <button id="clearSelectionsBtn" type="button" style="padding: 5px 15px; font-size:15px; margin-left: 10px;">
		 Clear
  		 </button>
  		 <button id="deleteAllBtn" type="button" style="padding: 5px 15px; font-size:15px; margin-left: 10px;">
		 Delete all
  		 </button>
	</div>
	
	
	
	<div class="separator"></div>
	
	
	
	<div style="padding: 0px 20px; font-size: 20px; font-weight: bold;">
	   진료 기록  [ Teeth: <span id="selectedButtonsLabel2"></span> ] 
	</div>
	
	<input type="hidden" id="namespace" value="<portlet:namespace/>"/>
	
	<div id="historyContainer"></div>
	
	<table id="treatmentTable" style="width:90%; border-collapse: collapse; margin: 0 auto;">
	  <thead>
	    <tr>
   	      <th style="border:1px solid #ccc; padding:8px;">Date</th>  
	      <th style="border:1px solid #ccc; padding:8px;">Teeth</th> 
	      <th style="border:1px solid #ccc; padding:8px;">State</th>
	      <th style="border:1px solid #ccc; padding:8px;">Treatment</th>
	      <th style="border:1px solid #ccc; padding:8px;">Action</th>
	    </tr>
	  </thead>
	  <tbody>
	    <!-- JS가 여기에 <tr>를 추가 -->
	  </tbody>
	</table>
	
	<div style="margin-top: 20px;" id="historyContainer"></div>
	
	<div style="text-align: center; font-size: 16px;">
	   하단의 Save 버튼을 누르면 추가했던 데이터들이 데이터 베이스에 저장됩니다.<br/><br/>
	  cancel 버튼을 누르면 현재 작업을 취소하고 팝업을 닫습니다.
	</div>
	
	 
	
	
	
	
	<div class="treatment-column" style="justify-content: center; margin-top: 20px; margin-bottom: 20px;">
	  <button id="addDBBtn" type="button" style="padding: 5px 15px; font-size: 15px;">Save</button>
	  <button id="cancelBtn" type="button" style="padding: 5px 15px; font-size: 15px; margin-left: 5px;">Back</button>
	</div>

</div>

<portlet:resourceURL id="/teeth/addTreatment" var="resourceAddURL"/>

<script>
const resourceURL = '<%=resourceAddURL.toString()%>';
</script>

<script src="/o/teeth-web/js/treatment.js"></script>

<c:set var="initialTeeths" value="${param.teeths}" />
<script>
  var INITIAL_TEETHS = '${initialTeeths}'; //jstl로 처리 
</script>

</body>
</html>
