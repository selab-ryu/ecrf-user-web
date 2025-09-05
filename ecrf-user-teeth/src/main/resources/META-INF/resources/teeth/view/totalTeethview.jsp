<%@ include file="../../init.jsp"%>

<%!Log _log = LogFactoryUtil.getLog("/teeth/deciduousTeethview.jsp");%>

<style>
  #imageWrapper {
    position: relative;
    width: auto;
    max-width: none;
    margin: 0 auto;
    aspect-ratio: 1223 / 772;
  }
</style>

<%
	Long patientID = (Long) request.getAttribute("patientID"); //patientId 
	if(patientID == null) { patientID = 1001L; } // patientId는 현재 1001로 임시 설정
	
	List<TreatmentHistory> historyList = (List<TreatmentHistory>) request.getAttribute("HistoryList"); //history list를 받아오기
	
	List<TreatmentHistory>[] RL = new List[86]; //각 teeth에 대한 정보 받아오기
	for(int i = 11; i <= 85; i++)
	{
		RL[i] = (List<TreatmentHistory>) request.getAttribute("teeth" + i);
	}
	
	// RL에 있는 List<TreatmentHistory>를 PortletSession 에 Map 형태로 저장
	java.util.Map<Integer, java.util.List<TreatmentHistory>> rlMap = new java.util.HashMap<>();

	for (int i = 11; i <= 85; i++) {
		if (RL[i] != null) {
			rlMap.put(i, RL[i]);
		}
	}
	portletSession.setAttribute("rlMap", rlMap, PortletSession.PORTLET_SCOPE);
	
	// JS에 약어 및 색 display용 historyList 설정
	// (1) historyList → JSONArray 생성
	SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
	JSONArray historyJson = JSONFactoryUtil.createJSONArray();

	for (TreatmentHistory th : historyList) {
		JSONObject obj = JSONFactoryUtil.createJSONObject();
		obj.put("region", "Teeth" + th.getTeethNum());
		obj.put("treatment", th.getTreatment());
		obj.put("date", fmt.format(th.getTreatmentDate()));
		obj.put("state", th.getState());
		historyJson.put(obj);
	}
	
	LiferayPortletURL baseURL = PortletURLFactoryUtil.create(request, themeDisplay.getPortletDisplay().getId(), themeDisplay.getPlid(), PortletRequest.RENDER_PHASE);
%>


<!-- RenderURL -->
<!-- Add Tooth Popup -->
<portlet:renderURL var="openDialogURL"
	windowState="<%=LiferayWindowState.POP_UP.toString()%>">
	<portlet:param name="mvcRenderCommandName" value="/render/add_tooth_treatment" />
	<portlet:param name="test" value="test" />
</portlet:renderURL>
<!-- View Audit Popup -->
<portlet:renderURL var="ViewAuditURL" windowState="pop_up">
	<portlet:param name="mvcRenderCommandName" value="/teeth/viewAuditTrail" />
	<portlet:param name="mode" value="All" />
</portlet:renderURL>

<portlet:renderURL var="HistoryPopUpURL" windowState="pop_up">
	<portlet:param name="mvcRenderCommandName" value="/teeth/historyPopup" />
	<portlet:param name="PatientID" value="<%=String.valueOf(patientID)%>" />
	<!-- 임시로 만들어놓은 PatientID -->
</portlet:renderURL>

<portlet:renderURL var="ViewPermanentTeethURL">
	<portlet:param name="mvcRenderCommandName" value="/teeth/permanentTeethView"/>
	<portlet:param name="PatientID" value="<%=String.valueOf(patientID)%>" />
</portlet:renderURL>

<portlet:renderURL var="ViewDeciduousTeethURL">
	<portlet:param name="mvcRenderCommandName" value="/teeth/deciduousTeethView"/>
	<portlet:param name="PatientID" value="<%=String.valueOf(patientID)%>" />
</portlet:renderURL>

<%-- Resource URLs --%>
<%-- /teeth/getHistory 리소스 커맨드 호출용 --%>
<portlet:resourceURL var="historyJsonUrl">
	<portlet:param name="mvcResourceCommandName" value="/teeth/getHistory" />
</portlet:resourceURL>
<%-- /teeth/tooltip 리소스 커맨드용 --%>
<portlet:resourceURL id="/teeth/tooltip" var="tooltipURL"/>

<div class="TeethView">
	<h1>Teeth Image Demo</h1>

	<!-- Add 연산용 내부 div -->
	<div style="display: none;">
		Selected Tooth: <span id="selectedButtonsLabel"></span><br />
		Num of Selected Tooth: <span id="jointNumLabel">0</span>
	</div>

	<!-- 조작 설명용 div -->
	<table class="info-table">
        <tr>
           <td colspan="4"><liferay-ui:message key="info.table.prohibition" /></td>
        </tr>
        <tr>
          <td colspan="2"><liferay-ui:message key="info.table.drag" /></td>
          <td colspan="2"><liferay-ui:message key="info.table.rightclick" /></td>
        </tr>
        <tr>
          <td colspan="2"><span style="color:rgba(0,0,255,1)"><liferay-ui:message key="info.table.blue.name" /></span><liferay-ui:message key="info.table.blue.description" /></td>
          <td><span style="color:rgba(255,165,0,1)"><liferay-ui:message key="info.table.yellow.name" /></span><liferay-ui:message key="info.table.blue.description" /></td>
          <td><span style="color:rgba(0,128,0,1)"><liferay-ui:message key="info.table.green.name" /></span><liferay-ui:message key="info.table.green.description" /></td>
        </tr>
        <tr>
          <td colspan="2"><liferay-ui:message key="info.table.fullaudit" /></td>
          <td colspan="2"><liferay-ui:message key="info.table.change" /></td>
        </tr>
	  	
	</table>

	<!-- teeth image 출력용 div -->
	<div id="imageWrapper">
		<!--  <img id="patientImage" src="<%=request.getContextPath()%>/images/total_teeth.png" alt="Patient Teeth" draggable="false" /> -->

		<!-- tooltip 출력용 div -->
		<div id="tooltipContainer"
			style="position: absolute; display: none; z-index: 9999; background: #fff; border: 1px solid #ccc; padding: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);">
		</div>
	</div>



	<%
		String addBtnOnClickStr = String.format("openDialog('%s', '%s')", themeDisplay.getPortletDisplay().getId(),
				baseURL.toString());
		_log.info(addBtnOnClickStr);
	%>


	<!-- 하단 버튼용 div -->
	<div id="addTWrapper">
		<aui:input type="hidden" name="teeths" value="" />
		<aui:button-row>
			<aui:button id="addBtn" type="button" cssClass="btn btn-primary" name="addBtn" value="<%=LanguageUtil.get(request, "teethview.button.addTreatment") %>" onClick="<%=addBtnOnClickStr%>" />
			<aui:button type="button" cssClass="btn btn-primary" value="<%=LanguageUtil.get(request, "teethview.button.viewFullAudit") %>" onClick="openViewAuditModal()" />
			<aui:button type="button" cssClass="btn btn-secondary" value="<%=LanguageUtil.get(request, "teethview.button.viewPermanentTeeth") %>" onClick="<%= ViewPermanentTeethURL%>" />
			<aui:button type="button" cssClass="btn btn-secondary" value="<%=LanguageUtil.get(request, "teethview.button.viewDeciduousTeeth") %>" onClick="<%= ViewDeciduousTeethURL%>" />
		</aui:button-row>
	</div>

	<!-- 약어 display용 내부 div -->
	<div id="historyContainer" style="display: none;"></div>
</div>

<!-- JS 사용 전 historyList 설정 script -->
<script>
	const NAMESPACE = '<portlet:namespace />';
	var $teethInput = $('#' + NAMESPACE + 'teeths');
	const tooltipResourceURL = '<%=tooltipURL.toString()%>';
	console.log('$teethInput length =', $teethInput.length);

	// (2) JSP 에서 만든 JSON 을 JS 에 파싱
	const initialHistoryArray = <%=historyJson.toString()%>;

	// (3) regionName 별로 묶어서 Map 생성, 날짜 순 정렬 후 최신 1개만 남김
	const historyMap = {};
	initialHistoryArray.forEach(item => {
		const reg = item.region;
		historyMap[reg] = historyMap[reg] || [];
		historyMap[reg].push(item);
	});
	
    // (4) “YYYY-MM-DD” 날짜만 기준으로 최신 날짜 항목 하나만 남기기
    Object.keys(historyMap).forEach(reg => {
      const items = historyMap[reg];
      if (!items.length) {
        historyMap[reg] = [];
        return;
      }

      // 4-1) 날짜별 그룹핑
      const byDate = items.reduce((acc, item) => {
        const day = item.date.slice(0, 10);  // “2025-06-25T…” → “2025-06-25”
        acc[day] = acc[day] || [];
        acc[day].push(item);
        return acc;
      }, {});

      // 4-2) 날짜 문자열 정렬로 최신 날짜 키 꺼내기
      const allDates  = Object.keys(byDate).sort();
      const latestDay = allDates[allDates.length - 1];

      // 4-3) 그 날짜의 항목들 중 우선순위에 따라 첫 번째 유효 항목 선택
      const latestItems = byDate[latestDay];
      const selected = 
        latestItems.find(i => i.treatment && i.treatment.trim() !== '') ||
        latestItems.find(i => i.state     && i.state.trim()     !== '') ||
        latestItems[0];

      // 4-4) historyMap[reg]에는 선택된 하나만 남기기
      historyMap[reg] = [ selected ];
    });
</script>

<!-- JS파일을 불러옴 -->
<script src="<%=request.getContextPath()%>/js/total_teeth.js"></script>

<script>	
	Liferay.provide(window, "openDialog", function(namespace, baseURL) {
		const teethElem = $("#_"+namespace+"_teeths");
		const teethVal = teethElem.val();
		const teethValNum = teethVal.replace("Teeth", ""); 
		var selectedTeeth = document.getElementById('selectedButtonsLabel').textContent; 
		console.log("teeth val : ", teethVal);
		
		var url = Liferay.Util.PortletURL.createRenderURL(baseURL, {
			"p_p_id": namespace,
         	"p_auth": Liferay.authToken,
         	"p_p_state": "pop_up",
         	"teeths" : selectedTeeth,
         	"test": "test",
         	"mvcRenderCommandName": "/render/add_tooth_treatment"
         });
		console.log(url);
		Liferay.Util.openWindow({
			dialog: {
				destroyOnClose: true,
				centered: true,
				modal:true,
				resizable: true,
				height:950,
				width:1200
			},
			id: "addTreatmentDialog",
			title: "Add Treatement",
			uri: url.toString()
		});
	}, ['liferay-portlet-url'] );
	
	Liferay.provide(window, "closeDialog", function(dialogId) {
	var dialog = Liferay.Util.Window.getById(dialogId);
	dialog.destroy();
	}, ['aui-base'] );

</script>

<!-- script랑 aui:script랑 합치면 안될거 같아서 분리시킨 대로 그대로 사용 -->
<aui:script>
	//Open Record Popup
	window.openHistoryModal = function(regionName) {
		var baseURL = '<%= HistoryPopUpURL.toString() %>';
		var DisplayRegionName = regionName.replace(/(\D+)(\d+)/, '$1 $2');
		// regionName 파라미터만 붙여 URL 완성
		var historyURL = Liferay.Util.PortletURL.createRenderURL(baseURL, { regionName: regionName });

		// 모달 팝업 실행
		Liferay.Util.openWindow({
			dialog: {
				centered: true,
				width: 1200,
				height: 600,
				resizable: false
			},
			title: 'Treatment Record: ' + DisplayRegionName,
			uri: historyURL
		});
		
		setTimeout(() => {	// hide tooltip if visible
			document.getElementById('tooltipContainer').style.display = 'none';	
		}, 300);
	};

	//imageWrapper 내 모든 region에 우클릭 리스너 부착
  	// DOM이 준비되면 콜백 실행
	$(function() {
	// imageWrapper 전체에 contextmenu 이벤트를 위임
		$('#imageWrapper').on('contextmenu', '.region', function(e) {
			e.preventDefault();
			// this는 우클릭된 .region 요소
			openHistoryModal($(this).data('name'));
		});
	});

	//Open Audit Popup
	window.openViewAuditModal = function () {
		console.log("openViewAuditModal");
        Liferay.Util.openWindow({
			dialog: {
				centered: true,
				width: 1200,
				height: 600,
				resizable: false
			},
			title: "View Full Audit",
			uri: '<%=ViewAuditURL%>'
		});
	};
</aui:script>