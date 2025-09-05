<%@ include file="../../init.jsp" %>

<%
    List<TreatmentHistory> EditHistoryList = (List<TreatmentHistory>) request.getAttribute("EditHistoryList");
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	long userId = themeDisplay.getUserId();
%>

<script src="/o/teeth-web/js/categoryLabelMap.js"></script>

<html>
<head>
    <title>Edit Treatment</title>
    <style>
      .treatment-btn {
          margin: 5px;
          padding: 10px;
          cursor: pointer;
      }
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
      gap: 30px;
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
<h3 style="padding: 15px 10px;">Selected Treatment Information</h3>

<script type="text/javascript">
function applyTreatment(treatmentInfo) {
        // 1) 문자열 → 객체로 변환
        var pairs = treatmentInfo.split(', ');
        var data = {};
        pairs.forEach(function(pair) {
            var idx = pair.indexOf('=');
            if (idx > -1) {
                var key = pair.substring(0, idx);
                var val = pair.substring(idx + 1);
                data[key] = val;
            }
        });

        // 2) 디테일 영역에 출력
        document.getElementById('treatmentID').innerText =
            'Treatment ID: ' + data.treatmentID;
        document.getElementById('teethNum').innerText =
            'Teeth Number: ' + data.teethNum;
        document.getElementById('treatment').innerText =
            'Treatment: ' + data.treatment;
        document.getElementById('state').innerText =
            'State: ' + data.state;
        document.getElementById('treatmentDate').innerText =
            'TreatmentDate: ' + data.treatmentDate;
        //document.getElementById('treatment-details').style.display = 'block';

        // 3) 숨겨진 input 에도 세팅
        document.getElementById('treatmentIdInput').value = data.treatmentID;
        document.getElementById('teethInput').value = data.teethNum;
        // 서버에 yyyy-MM-dd 형태로 전송하기 위해 포맷
        document.getElementById('treatmentDateInput').value =
            new Date(data.treatmentDate).toISOString().split('T')[0];

        // 4) 기존 체크 해제
        //document.querySelectorAll('input[name="status"], input[name="permanent"]')
           //.forEach(function(el) { el.checked = false; });

        // 5) treatment(=status) 체크
        data.treatment.split(',').forEach(function(val) {
            var v = val.trim();
            var el = document.querySelector('input[name="status"][value="' + v + '"]');
            if (el) el.checked = true;
        });
        // 6) state(=permanent) 체크
        data.state.split(',').forEach(function(val) {
            var v = val.trim();
            var el = document.querySelector('input[name="permanent"][value="' + v + '"]');
            if (el) el.checked = true;
        });
    }
</script>
<div id="treatment-buttons" style="padding: 20px 10px;" style="display: none;">
    <% if (EditHistoryList != null) {
        for (TreatmentHistory history : EditHistoryList) {
            String treatmentInfo = "treatmentID=" + history.getTreatmentID() +
                                   ", teethNum=" + history.getTeethNum() +
                                   ", treatment=" + history.getTreatment() +
                                   ", state=" + history.getState() +
                                   ", teeth=" + history.getTeethNum() +
                                   ", treatmentDate=" + history.getTreatmentDate();
            
    %>
		<%
		String safeTreatmentInfo = treatmentInfo.replace("'", "\\'");
		%>
		<script>
		const treat = '<%= safeTreatmentInfo %>';
		applyTreatment(treat);
		</script>
    
    
        <button class="treatment-btn" onclick="applyTreatment('<%= treatmentInfo %>')" style="display: none;">
           Date: <%= sdf.format(history.getTreatmentDate()) %> | <%= history.getTreatment() %>
        </button>
    <% }
    } %>
</div>

<div id="treatment-details" class="treatment-info" style="display: none;">
    
    <p id="treatmentID">Treatment ID: </p>
    <p id="teethNum">Teeth Number: </p>
    <p id="treatment">Treatment: </p>
    <p id="state">State: </p>
    <p id="treatmentDate">TreatmentDate: </p>
</div>

<portlet:actionURL var="editDBURL" name="/edit_tooth_treatment" />

<!-- ✨ 여기부터 form 추가 ✨ -->
<aui:form name="editDBForm" action="<%= editDBURL %>" method="post">

    <input type="hidden" name="treatmentId" id="treatmentIdInput" />
    <input type="hidden" name="mainCategory" id="mainCategoryInput" />
    <input type="hidden" name="status" id="statusInput" />
    <input type="hidden" name="permanent" id="permanentInput" />
    <input type="hidden" name="treatmentDate" id="treatmentDateInput" />
    <input type="hidden" name="teeth" id="teethInput" />
    
    <div class="separator"></div>


	
	<div class="treatment-row" style="padding-left: 10px;">
	 
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
			    <label><input type="radio" name="permanent" value="C1"/> C1</label>
			    <label><input type="radio" name="permanent" value="C2"/> C2</label>
			    <label><input type="radio" name="permanent" value="C3"/> C3</label>
			  </div>
			</td>
		    <td>
		   	  <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 5px;">
			      <label><input type="checkbox" name="permanent" value="W"/> W (White)</label>
			      <label><input type="checkbox" name="permanent" value="Y"/> Y (Yellow)</label>
			      <label><input type="checkbox" name="permanent" value="B"/> B (Brown)</label>
		      </div>
		    </td>
		    <td>
		    	<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 5px;">
			      <label><input type="checkbox" name="permanent" value="E"/> E (Enamel)</label>
			      <label><input type="checkbox" name="permanent" value="D"/> D (Dentin)</label>
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
    
    
  <div class="treatment-row" style="padding-left: 10px;">
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
		    <label><input type="checkbox" class="mar-r-2" name="status" value="TFA"/> 불소도포 </label>
		    <label><input type="checkbox" class="mar-r-2" name="status" value="SC" /> 스케일링 </label>
		    </div>
		  </div>
		
		  <!-- 수복 -->
		  <div class="inline-section with-border">
		    <p><strong>수복</strong></p>
		    <div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
		    <label><input type="checkbox" class="mar-r-2" name="status" value="Seal" /> 실란트 </label>
		    <label><input type="checkbox" class="mar-r-2" name="status" value="AF" /> 아말감 </label>
		    <label><input type="checkbox" class="mar-r-2" name="status" value="RF" /> 레진 </label>
		    <label><input type="checkbox" class="mar-r-2" name="status" value="Gl" /> 글라스아이오노머 </label>
		    <label><input type="checkbox" class="mar-r-2" name="status" value="SS" /> 기성금속관 </label>
		    <label><input type="checkbox" class="mar-r-2" name="status" value="Zr" /> 지르코니아크라운 </label>
		     </div>
		  </div>
	  
	  </div>
	  
 	  <!-- 치수 -->
	  <div id="radioButtonWrapper" class="treatment-box option-group">
	  	<div class="inline-section">
	  	<p><strong>외과</strong></p>
	  	<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
	    <label><input type="checkbox" class="mar-r-2" name="status" value="Ext"/> 발치</label>
	     <!-- yes일 경우 서술 공간 필요 -->
	    <label><input type="checkbox" class="mar-r-2" name="status" value="oral"/> 구강소수술</label>
	    </div>
	    </div>
	    <div class="inline-section with-border">
	    <p><strong>치수</strong></p>
	    <div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
	    <label><input type="checkbox" class="mar-r-2" name="status" value="Pulpo"/> Pulpotomy</label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="Pulpec"/> Pulpectomy</label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="Apexo"/> Apexogenesis</label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="Apexi"/> Apexification</label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="RCT"/> Root canal treatment</label>
	    </div>
	    </div>
	  </div>
	  
	  
	  <!-- 교정 -->
 	 <div id="radioButtonWrapper" class="treatment-box option-group">
	  	<div class="inline-section">
	  	<p><strong>전신마취</strong></p>
	  	<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
	    <label><input type="checkbox" class="mar-r-2" name="status" value="DOR"/> DOR </label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="MOR"/> MOR </label>
	    </div>
	    </div>
	    <div class="inline-section with-border">
	    <p><strong>교정</strong></p>
	    <div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
	    <label><input type="checkbox" class="mar-r-2" name="status" value="firstStraighten"/> 1차교정</label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="secondStraighten"/> 2차교정</label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="partialStraighten"/> 부분교정(장치비+월비)</label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="muscleFunction"/> 근기능장치</label>
	    </div>
	    </div>
	  </div>
	  
	  <!-- 공간유지장치 -->
	  <div id="radioButtonWrapper" class="treatment-box option-group">
	  	<div class="inline-section">
	    <p><strong>공간유지장치</strong></p>
	    <div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
	    <label><input type="checkbox" class="mar-r-2" name="status" value="BL"/> B-L </label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="LA"/> L-A </label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="NHA"/> NHA </label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="RSM"/> RSM </label>
	    </div>
	    </div>
	    <div class="inline-section with-border">
	    <p><strong>진정</strong></p>
	     <div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
	    <label><input type="checkbox" class="mar-r-2" name="status" value="N2OSedation"/> N2O흡인진정 </label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="LASedation"/> 경구진정 </label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="NHASedation"/> 근육진정 </label>
	    <label><input type="checkbox" class="mar-r-2" name="status" value="RSMSedation"/> 정주진정 </label>
	    </div>
	    </div>
	  </div>
	  
	  </td>
	  </tr>
	  </table>
	</div>

	<div style="display: flex; justify-content: center; margin-top: 20px; margin-bottom: 20px;">
	  <button type="button" onclick="submitForm()" style="padding: 10px 20px; font-size: 20px; box-sizing: border-box;">Save</button>
	  <button type="button" onclick="Delete()" style="padding: 10px 20px; font-size: 20px; margin-left: 15px; box-sizing: border-box;">Delete</button>
	  <button type="button" onclick="cancel()" style="padding: 10px 20px; font-size: 20px; margin-left: 15px; box-sizing: border-box;">Back</button>
	</div>
	
	
</aui:form>

<portlet:resourceURL id="/teeth/editTreatment" var="resourceEditURL"/>

<portlet:resourceURL id="/teeth/deleteTreatment" var="resourceDeleteURL"/>

<script>

	//edit 화면에서 선택한 진료기록을 삭제 요청하는 function
    function Delete() {
		
    	if (!confirm("정말 삭제하시겠습니까?")) {
            return;  // 사용자가 취소하면 함수 종료
        }
		
    	setFormValues();  // 숨겨진 input 값 세팅
    	
    	const inputDate = new Date(document.getElementById('treatmentDateInput').value);

    	// 월, 일, 년을 각각 추출하여 포맷팅
    	const formattedDate = (inputDate.getMonth() + 1) + '/' + inputDate.getDate() + '/' + inputDate.getFullYear();

    	
    	const deleteData = {
    	        userId : themeDisplay.getUserId(),
    			treatmentDate: formattedDate,
                selectedStatus: document.getElementById('statusInput').value,
                selectedTeeth: document.getElementById('teethInput').value,
                selectedTreatmentID: document.getElementById('treatmentIdInput').value        
            };
    	
    	
		const resourceURL = '<%=resourceDeleteURL.toString()%>';
	  	const base = resourceURL;
	    let urlObj = new URL(base);
    	
        $.ajax({
            type: 'POST',
            url: urlObj,
            data: JSON.stringify({ deleteData: [deleteData] }),
            contentType: 'application/json; charset=UTF-8',
            success: function(response) {
            	window.history.back();
                console.log("서버 응답:", response);
            },
            error: function(xhr, status, error) {
                console.error("AJAX 실패:", error);
            }
        });
    
	}
    
 	//edit 화면에서 편집한 진료기록을 저장하는 function
    function submitForm() {
        setFormValues();  // 숨겨진 input 값 세팅

        const requestData = {
        	
            EditUserId: Liferay.ThemeDisplay.getUserId(),
            treatmentID: document.getElementById('treatmentIdInput').value,
            selectedStatus: document.getElementById('statusInput').value,
            selectedTeeth: document.getElementById('teethInput').value,
            selectedPermanent: document.getElementById('permanentInput').value
        };

        console.log('submitForm() 호출 - 전송 데이터:', requestData);

		const resourceURL = '<%=resourceEditURL.toString()%>';
	  	const base = resourceURL;
	    let urlObj = new URL(base);
		
        $.ajax({
            type: 'POST',
            //url: '/o/teeth-web/ajax/edit_treatment_db.jsp',      
            url: urlObj,
            //data: requestData,
            data: JSON.stringify({ requests: [requestData] }),
            contentType: 'application/json; charset=UTF-8',
            success: function(response) {
                console.log("서버 응답:", response);
                window.history.back();
            },
            error: function(xhr, status, error) {
                console.error("AJAX 실패:", error);
            }
        });
    
    }
 	
   //edit 화면에서 선택한 진료기록을 삭제 요청하는 function
    function cancel() {
    	 window.history.back();
    }
	
	//선택한 치식을 화면에 출력하는 function 

	//edit, delete 실행전  변경사항을 적용해주는  function
    function setFormValues() {
        // 1) status 체크박스 선택값 모두 가져와서 배열 → 문자열
        var statusEls = document.querySelectorAll('input[name="status"]:checked');
        var selectedStatus = Array.from(statusEls)
                                  .map(el => el.value)
                                  .join(',');

        // 2) permanent (라디오/체크박스) 선택값 모두 가져와서 배열 → 문자열
        var permEls = document.querySelectorAll('input[name="permanent"]:checked');
        var selectedPermanent = Array.from(permEls)
                                     .map(el => el.value)
                                     .join(',');

        // 3) 숨겨진 input 에 세팅
        document.getElementById('statusInput').value    = selectedStatus;
        document.getElementById('permanentInput').value = selectedPermanent;
    }

</script>

</body>


</html>