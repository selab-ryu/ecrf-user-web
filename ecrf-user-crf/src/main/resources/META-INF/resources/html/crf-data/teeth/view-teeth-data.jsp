<%@page import="java.util.TimeZone"%>
<%@ page import="javax.portlet.PortletSession"%>
<%@ page import="teeth.model.TreatmentHistory"%>
<%@ page import="com.liferay.portal.kernel.portlet.LiferayPortletURL"%>
<%@ page import="com.sx.icecap.constant.IcecapWebPortletKeys"%>
<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf/view-teeth-data_jsp"); %>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
	
	DataType dataType = DataTypeLocalServiceUtil.getDataType(dataTypeId);
	
	Subject subject = (Subject)renderRequest.getAttribute(ECRFUserCRFDataAttributes.SUBJECT);
	LinkCRF linkCRF = (LinkCRF)renderRequest.getAttribute(ECRFUserCRFDataAttributes.LINK_CRF);
	
	long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
	long linkId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.LINK_ID, 0);
	
	_log.info("view-teeth-data / subject id: "+subjectId);
	
	boolean isUpdate = false;
	
	if(linkCRF != null){
		isUpdate = true;
	}
	
	String menu = ECRFUserMenuConstants.VIEW_TEETH_DATA;
		
	LiferayPortletURL baseURL = PortletURLFactoryUtil.create(request, themeDisplay.getPortletDisplay().getId(), themeDisplay.getPlid(), PortletRequest.RENDER_PHASE);
	
	String baseURLStr = baseURL.toString();
	String[] result = baseURLStr.split("\\?");
	String rootURL = "";
	if(result.length > 0) {
		rootURL = result[0];
	}
	
	if(Validator.isNull(redirect)) {
		// set redirect for update crf data page when direct by selector dialog
	}
	
	int viewType = ParamUtil.getInteger(request, "viewType", 0);
				
	List<TreatmentHistory> historyList = (List<TreatmentHistory>) request.getAttribute("HistoryList"); //history list를 받아오기
	
	List<TreatmentHistory>[] RL = new List[86]; //각 teeth에 대한 정보 받아오기
	for(int i = 11; i <= 85; i++)
	{
		RL[i] = (List<TreatmentHistory>) request.getAttribute("teeth" + i);
	}
	
	// RL에 있는 List<TreatmentHistory>를 PortletSession 에 Map 형태로 저장
	Map<Integer, List<TreatmentHistory>> rlMap = new HashMap<>();

	for (int i = 11; i <= 85; i++) {
		if (RL[i] != null) {
			rlMap.put(i, RL[i]);
		}
	}
	portletSession.setAttribute("rlMap", rlMap, PortletSession.PORTLET_SCOPE);
	
	SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");

	JSONArray historyJson = JSONFactoryUtil.createJSONArray();

	for (TreatmentHistory th : historyList) {
		JSONObject obj = JSONFactoryUtil.createJSONObject();
		obj.put("region", "Teeth" + th.getTeethNum());
		obj.put("num", th.getTeethNum());
		obj.put("treatment", th.getTreatment());
		obj.put("date", fmt.format(th.getTreatmentDate()));
		obj.put("state", th.getState());
		historyJson.put(obj);
	}
	
	_log.info(historyJson.toJSONString());
%>

<%-- Resource URLs --%>
<%-- /teeth/getHistory 리소스 커맨드 호출용 --%>
<portlet:resourceURL var="historyJsonUrl">
	<portlet:param name="mvcResourceCommandName" value="/teeth/getHistory" />
</portlet:resourceURL>
<%-- /teeth/tooltip 리소스 커맨드용 --%>
<portlet:resourceURL id="/teeth/tooltip" var="tooltipURL"/>

<!-- RenderURL -->
<!-- View Audit Popup -->
<portlet:renderURL var="ViewAuditURL" windowState="pop_up">
	<portlet:param name="mvcRenderCommandName" value="/teeth/viewAuditTrail" />
	<portlet:param name="mode" value="All" />
</portlet:renderURL>

<portlet:renderURL var="HistoryPopUpURL" windowState="pop_up">
	<portlet:param name="mvcRenderCommandName" value="/teeth/historyPopup" />
	<portlet:param name="PatientID" value="<%=String.valueOf(1001)%>" />
</portlet:renderURL>

<portlet:renderURL var="ViewTotalTeethURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_TEETH_DATA%>" />
	<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
	<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(subjectId) %>" />
	<portlet:param name="menu" value="<%=ECRFUserMenuConstants.VIEW_TEETH_DATA %>" />	
	<portlet:param name="viewType" value="0" />	
</portlet:renderURL>

<portlet:renderURL var="ViewPermanentTeethURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_TEETH_DATA%>" />
	<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
	<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(subjectId) %>" />
	<portlet:param name="menu" value="<%=ECRFUserMenuConstants.VIEW_TEETH_DATA %>" />	
	<portlet:param name="viewType" value="1" />	
</portlet:renderURL>

<portlet:renderURL var="ViewDeciduousTeethURL">
	<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFUserMVCCommand.RENDER_VIEW_TEETH_DATA%>" />
	<portlet:param name="<%=ECRFUserCRFAttributes.CRF_ID %>" value="<%=String.valueOf(crfId) %>" />
	<portlet:param name="<%=ECRFUserSubjectAttributes.SUBJECT_ID %>" value="<%=String.valueOf(subjectId) %>" />
	<portlet:param name="menu" value="<%=ECRFUserMenuConstants.VIEW_TEETH_DATA %>" />	
	<portlet:param name="viewType" value="2" />	
</portlet:renderURL>

<div class="ecrf-user-crf-data ecrf-user">
	<%@ include file="../other/sidebar.jspf" %>
	<div class="page-content">
		<div class="crf-header-title">
			<% DataType titleDT = DataTypeLocalServiceUtil.getDataType(dataTypeId); %>
			<liferay-ui:message key="ecrf-user.general.crf-title-x" arguments="<%=titleDT.getDisplayName(themeDisplay.getLocale()) %>" />
		</div>
		
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.crf-data.title.view-teeth-data" /> 
		
		<aui:fieldset-group markupView="lexicon">
			<aui:fieldset cssClass="search-option radius-shadow-container" collapsed="<%=false %>" collapsible="<%=true %>" label="ecrf-user.subject.title.subject-info">
				<aui:container>
					<aui:row cssClass="top-border">
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="serialId"
								label="ecrf-user.subject.serial-id">
								<p><%=Validator.isNull(subject) ? "-" : String.valueOf(subject.getSerialId()) %></p>
							</aui:field-wrapper>
						</aui:col>
						<%
						String subjectName = subject.getName();
						boolean hasViewEncryptPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_ENCRYPT_SUBJECT);
						if(!hasViewEncryptPermission)
							subjectName = ECRFUserUtil.encryptName(subjectName);	
						%>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="name"
								label="ecrf-user.subject.name">
								<p><%=Validator.isNull(subject.getName()) ? "-" : subjectName %></p>
							</aui:field-wrapper>
						</aui:col>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="gender"
								label="ecrf-user.subject.gender">
								<p><%=Validator.isNull(subject) ? "-" : (subject.getGender() == 0 ? "male" : "female") %></p>
							</aui:field-wrapper>
						</aui:col>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="birth"
								label="ecrf-user.subject.birth-age">
								<p><%=Validator.isNull(subject) ? "-" : sdf.format(subject.getBirth()) + " (" + Math.abs(124 - subject.getBirth().getYear()) + ")" %></p>
							</aui:field-wrapper>
						</aui:col>
					</aui:row>
				</aui:container>
			</aui:fieldset>
					
			<aui:fieldset cssClass="search-option radius-shadow-container ecrf-user-teeth" collapsed="<%=false %>" collapsible="<%=true %>" label="ecrf-user.crf-data.title.teeth-data-editor">
				
				<!-- Add 연산용 내부 div -->
				<div style="display: none;">
					Selected Tooth: <span id="selectedButtonsLabel"></span><br />
					Num of Selected Tooth: <span id="jointNumLabel">0</span>
					
				</div>

				<!-- -->
				<div style="display: none;">
					<input id="jointNum" type="hiddne" value="0" />
				</div>
				
				<!-- 조작 설명용 div -->
				<aui:container cssClass="info-box">
					<aui:row>
						<aui:col md="12" cssClass="div-border-bottom">
							<liferay-ui:message key="ecrf-user.crf-data.teeth.info.table.prohibition" />
						</aui:col>
					</aui:row>
					<aui:row>
						<aui:col md="6" cssClass="div-border-bottom div-border-right">
							<liferay-ui:message key="ecrf-user.crf-data.teeth.info.table.drag" />
						</aui:col>
						<aui:col md="6" cssClass="div-border-bottom">
							<liferay-ui:message key="ecrf-user.crf-data.teeth.info.table.rightclick" />
						</aui:col>
					</aui:row>
					<aui:row>
						<aui:col md="4" cssClass="div-border-bottom div-border-right">
							<span style="color:rgba(0,0,255,1)"><liferay-ui:message key="ecrf-user.crf-data.teeth.info.table.blue.name" /></span><liferay-ui:message key="ecrf-user.crf-data.teeth.info.table.blue.description" />
						</aui:col>
						<aui:col md="4" cssClass="div-border-bottom div-border-right">
							<span style="color:rgba(255,165,0,1)"><liferay-ui:message key="ecrf-user.crf-data.teeth.info.table.yellow.name" /></span><liferay-ui:message key="ecrf-user.crf-data.teeth.info.table.blue.description" />
						</aui:col>
						<aui:col md="4" cssClass="div-border-bottom">
							<span style="color:rgba(0,128,0,1)"><liferay-ui:message key="ecrf-user.crf-data.teeth.info.table.green.name" /></span><liferay-ui:message key="ecrf-user.crf-data.teeth.info.table.green.description" />
						</aui:col>
					</aui:row>
					<aui:row>
						<aui:col md="6" cssClass="div-border-right">
							<liferay-ui:message key="ecrf-user.crf-data.teeth.info.table.fullaudit" />
						</aui:col>
						<aui:col md="6">
							<liferay-ui:message key="ecrf-user.crf-data.teeth.info.table.change" />
						</aui:col>
					</aui:row>
				</aui:container>
					
				<div id="imageWrapper" class="imageWrapper">
					<!-- tooltip 출력용 div -->
					<div id="tooltipContainer"
						style="position: absolute; display: none; z-index: 9999; background: #fff; border: 1px solid #ccc; padding: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2); max-width: 600px;">
					</div>
				</div>

				<!-- 하단 버튼용 div -->
				<div id="addTWrapper">
					<aui:input type="hidden" name="teeths" value="" />

					<%
						String addBtnOnClickStr = String.format("openDialog('%s', '%s', %d, %d, %d)", themeDisplay.getPortletDisplay().getId(), baseURL.toString(), crfId, subjectId, linkId);
						//_log.info(addBtnOnClickStr);

						String mode = "All";
						switch(viewType) {
							case 0:
								mode = "All";
								break;
							case 1:
								mode = "permanent";
								break;
							case 2:
								mode = "deciduous";
								break;
							default:
								break;
						}
						
						String viewAuditBtnOnClickStr = String.format("onenViewAuditModal('%s', '%s', %d, %d, %d, '%s')", themeDisplay.getPortletDisplay().getId(), baseURL.toString(), crfId, subjectId, linkId, mode);
					%>

					<aui:button-row>
						<aui:button id="addBtn" type="button" cssClass="btn btn-primary" name="addBtn" value="ecrf-user.crf-data.teeth.button.addTreatment" onClick="<%=addBtnOnClickStr %>" />
						<aui:button id="viewAuditBtn" type="button" cssClass="btn btn-primary" value="ecrf-user.crf-data.teeth.button.viewFullAudit" onClick="<%=viewAuditBtnOnClickStr %>" />
						<aui:button id="viewTotalBtn" type="button" cssClass="btn btn-secondary" value="ecrf-user.crf-data.teeth.button.viewAllTeeth" onClick="<%=ViewTotalTeethURL %>" />
						<aui:button id="viewPermBtn" type="button" cssClass="btn btn-secondary" value="ecrf-user.crf-data.teeth.button.viewPermanentTeeth" onClick="<%=ViewPermanentTeethURL %>" />
						<aui:button id="viewDeciBtn" type="button" cssClass="btn btn-secondary" value="ecrf-user.crf-data.teeth.button.viewDeciduousTeeth" onClick="<%=ViewDeciduousTeethURL %>" />
						
					</aui:button-row>
				</div>
			
				<!-- 약어 display용 내부 div -->
				<div id="historyContainer" style="display: none;"></div>
			</aui:fieldset>
		</aui:fieldset-group>
	</div>
</div>

<!-- JS 사용 전 historyList 설정 script -->
<script>
$(document).ready(function() {
	const imageWrapper = document.getElementById('imageWrapper');
	
	// common global attribute
	window.teeth = {
		jointNum: 0,
		timeoutId: null,
		isDragging: false,
		dragStartX: 0,
		dragStartY: 0,
		selectionBox: null,
		currentScale: 1,
		initialWidth: imageWrapper.getBoundingClientRect().width,
		statePriority: ['C3','C2','C1','W','Y','B','E','D'],
		treatmentPriority: ['Ext','Pulpec','Pulpo','Apexo','Apexi','RCT','ZR','SS','RF','AF','GI','Seal'],
		NAMESPACE: '<portlet:namespace />',
		portletId: '<%=themeDisplay.getPortletDisplay().getId()%>',
		baseURL: "<%=baseURL.toString() %>",
		subjectId: <%=subjectId%>,
		crfId: <%=crfId%>,
		linkId: <%=linkId%>
	}

	console.log(window.teeth);

	// common code
	
	let $teethInput = $('#' + window.teeth.NAMESPACE + 'teeths');
	let tooltipResourceURL = '<%=tooltipURL.toString()%>';
	//console.log('$teethInput length =', $teethInput.length);

	// (2) JSP 에서 만든 JSON 을 JS 에 파싱
	let initialHistoryArray = <%=historyJson.toString()%>;
	//console.log(initialHistoryArray);

	window.teeth.initHistory = initialHistoryArray;

	// (3) regionName 별로 묶어서 Map 생성, 날짜 순 정렬 후 최신 1개만 남김
	let historyMap = {};
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
			latestItems.find(i => i.state && i.state.trim() !== '') ||
			latestItems[0];

		// 4-4) historyMap[reg]에는 선택된 하나만 남기기
		historyMap[reg] = [ selected ];
	});
 	// common code
	
	// type : (0: total, 1: permanent, 2: deciduous)
	let viewType = 1;
	viewType = <%=viewType%>;
	
	let regionWidth = 67;  // 원본 코드에서 x2-x1 이 155px 로 일정
	let rowDefs = [];	// row별 속성 정의 (row: 1~4 영구치, 5~8 유치)
	
	let natW = 1223;
	let natH = 772;
  
	// set layout variable by viewType
	switch(viewType) {
		case 0:	// total
			natW = 1223;
			natH = 772;

			imageWrapper.style.setProperty('aspect-ratio', '1223/772');

			rowDefs = [
				{ row: 1, xStart: 590, direction: -1, y1:  90,  y2: 148 },  
				{ row: 2, xStart: 626, direction:  1, y1:  90,  y2: 148 }, 
				{ row: 3, xStart: 626, direction:  1, y1: 620,  y2: 678 },  
				{ row: 4, xStart: 590, direction: -1, y1: 620,  y2: 678 },  
				{ row: 5, xStart: 590, direction: -1, y1: 266,  y2: 324 },  
				{ row: 6, xStart: 626, direction:  1, y1: 266,  y2: 324 },  
				{ row: 7, xStart: 626, direction:  1, y1: 442,  y2: 500 },  
				{ row: 8, xStart: 590, direction: -1, y1: 442,  y2: 500 }, 
			];
			break;
		case 1:	// permanent
			natW = 2806;
			natH = 963;
			
			regionWidth = 155;

			imageWrapper.style.setProperty('aspect-ratio', '2806/963');
			
			rowDefs = [
				{ row: 1, xStart: 1357, direction: -1, y1:  205,  y2:  338 },  
				{ row: 2, xStart: 1443, direction:  1, y1:  205,  y2:  338 }, 
				{ row: 3, xStart: 1443, direction:  1, y1:  618,  y2:  753 },  
				{ row: 4, xStart: 1357, direction: -1, y1:  618,  y2:  753 },   
			];
			break;
		case 2:	// deciduous
			natW = 2806;
			natH = 834;
			
			regionWidth = 155;

			imageWrapper.style.setProperty('aspect-ratio', '2806/963');
			
			rowDefs = [
				{ row: 5, xStart: 1358, direction: -1, y1:  150,  y2:  283 },  
				{ row: 6, xStart: 1440, direction:  1, y1:  150,  y2:  283 },  
				{ row: 7, xStart: 1440, direction:  1, y1:  557,  y2:  690 },  
				{ row: 8, xStart: 1358, direction: -1, y1:  557,  y2:  690 },  
			];
			break;
		default:
			break;
	}
  
	window.teeth.natW = natW;
	window.teeth.natH = natH;

	const regions = rowDefs.flatMap(def => {
		const count = def.row <= 4 ? 8 : 5;  // 영구치는 8개, 유치는 5개
		return Array.from({ length: count }, (_, idx) => {

			// raw 계산
			const rawX1 = def.xStart + (idx * regionWidth * def.direction);
			const rawX2 = rawX1 + regionWidth * def.direction;
			// 항상 x1 < x2 로 정렬
			const x1 = Math.min(rawX1, rawX2);
			const x2 = Math.max(rawX1, rawX2);
			
			// backtick not worked...., so change code
			const teethNum = def.row * 10 + (idx + 1);
			const teethName = 'Teeth' + teethNum;
			
			return {
				name: teethName,
				num: teethNum,
				x1, y1: def.y1,
				x2, y2: def.y2,
				isClicked: false,
				history:   []
			};
		});
	});


	// JSP 에서 전달된 historyMap 을 전역으로 사용
	regions.forEach(r => {
		if (typeof historyMap === 'object' && historyMap) {
			r.history = historyMap[r.name] || [];
		}
	});

	window.teeth.regions = regions;

	// --- 이벤트 리스너 등록 ---
	regions.forEach(region => {
		const div = document.createElement('div');
		div.classList.add('region');
		div.dataset.name = region.name; 
		div.addEventListener('click', e => handleRegionClick(e, region));
		div.addEventListener('mouseenter', e => handleRegionMouseEnter(e, region, tooltipResourceURL));
		div.addEventListener('mousemove', e => handleRegionMouseMove(e));
		div.addEventListener('mouseleave', () => handleRegionMouseLeave());
		imageWrapper.appendChild(div);
	});

	imageWrapper.addEventListener('mousedown', handleWrapperMouseDown);
	window.addEventListener('mousemove', handleWindowMouseMove);
	window.addEventListener('mouseup', handleWindowMouseUp);
	
	imageWrapper.addEventListener('wheel', imageWrapperWheel);
	
	imageWrapper.addEventListener('load', drawRegions);
	window.addEventListener('resize', drawRegions);
	
	//imageWrapper 전체에 contextmenu 이벤트를 위임
	$('#imageWrapper').on('contextmenu', '.region', function(e) {
		e.preventDefault();
		// this는 우클릭된 .region 요소
		// TODO: subject id update
		const commonData = window.teeth;
		openHistoryModal(window.teeth.portletId, window.teeth.baseURL, $(this).data('name'), commonData.crfId, commonData.subjectId, commonData.linkId);
	});

	drawRegions();
});
</script>

<!-- Wijmo css/js referenece goes here -->
<link rel="stylesheet" href="https://cdn.mescius.com/wijmo/5.latest/styles/wijmo.min.css" />
<script src="https://cdn.mescius.com/wijmo/5.latest/controls/wijmo.min.js"></script>
<script src="https://cdn.mescius.com/wijmo/5.latest/controls/wijmo.chart.min.js"></script>
<script src="https://cdn.mescius.com/wijmo/5.latest/controls/wijmo.grid.min.js"></script>
<script src="https://cdn.mescius.com/wijmo/5.latest/controls/wijmo.input.min.js"></script>

<script>
wijmo.setLicenseKey('smart-crf.medbiz.or.kr,811749161251782#B0LLcNHbhZmOiI7ckJye0ICbuFkI1pjIEJCLi4TPnxkW7V7YjdHcjJ6LHJDSk94U9o7b9gUVtZEZ4l5KzcWQpBTOKFWcopVcap7dwkkNEhEbutmSwpWTQRTc9AVR93EaUdUYTdlY6tkQWVjdSxESF5meClVYRlVOIRHZUhFVTZzQ9VXcKhDOvh7b9RjYNRUSLZTOrUTWFdGMXZ4aiZTavRGOLl5bz2WeTdXM4dUZQJVMjpVbpVleslVTIBDcCJEdMh4S9NUd05UOWxUS5hUcvkXUJNFNOFnYExmbDZmeRhWbXZFTvl7MnFHUaZWWVFDZBxmcrRkTVx6KwBTeK3EOyhmWB3EdydmbXJmN7lkRL3GNT9kbht4LlhUdT9ERwcUZNdlZXVEN0d4UldUZvZnQrclbMRlM6UFNWRWZzcjNQ5kdC9kN6NWdz9WciZlSnBXNv3CcDNUc7UjV5MTSvBzSycTYyFzSaF6ck9mcxsEdFp6K4kEZiojITJCLiMjMFBTOygjI0ICSiwyM7MTMyEDM4kTM0IicfJye=#Qf35VfikEMyIlI0IyQiwiIu3Waz9WZ4hXRgACdlVGaThXZsZEIv5mapdlI0IiTisHL3JSNJ9UUiojIDJCLi86bpNnblRHeFBCIyV6dllmV4J7bwVmUg2Wbql6ViojIOJyes4nILdDOIJiOiMkIsIibvl6cuVGd8VEIgc7bSlGdsVXTg2Wbql6ViojIOJyes4nI4YkNEJiOiMkIsIibvl6cuVGd8VEIgAVQM3EIg2Wbql6ViojIOJyes4nIzMEMCJiOiMkIsISZy36Qg2Wbql6ViojIOJyes4nIVhzNBJiOiMkIsIibvl6cuVGd8VEIgQnchh6QsFWaj9WYulmRg2Wbql6ViojIOJyebpjIkJHUiwiI6ATNyIDMgUDM9ATNyAjMiojI4J7QiwiIytmLy3mL0lmYkVWbuYmcj5CdyFWbzJiOiMXbEJCLigritTIltzohsjZusTbnsD9lsTJlrLiOiEmTDJCLiIDO7ETNyEjNxkDN7ETM8IiOiQWSiwSfdtlOicGbmJCLiEjd5IDMyIiOiI3ZxJ');
</script>
<!-- Wijmo css/js referenece goes here -->

<script src="/o/ecrf.user.crf/js/teeth/total_teeth.js"></script>