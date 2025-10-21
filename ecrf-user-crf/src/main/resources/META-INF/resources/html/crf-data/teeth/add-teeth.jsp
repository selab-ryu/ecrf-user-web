<%@page import="teeth.service.TreatmentHistoryLocalServiceUtil"%>
<%@page import="teeth.model.TreatmentHistory"%>
<%@ include file="../../init.jsp" %>

<%! private Log _log = LogFactoryUtil.getLog("add-teeth_jsp");  %>

<%
	String portalURL = themeDisplay.getPortalURL();
	String contextPath = themeDisplay.getPathContext();
	String teethsParam = (String) request.getAttribute("teeths");
		
	String[] teethNumArr = teethsParam.split(",");
	int teethCount = teethNumArr.length;

	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	
	long subjectId = ParamUtil.getLong(request, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
	long linkId = ParamUtil.getLong(request, ECRFUserCRFDataAttributes.LINK_ID, 0);
	
	Date birth = null;
		
	Subject subject = null;
	if(subjectId > 0) {
		subject = (Subject)request.getAttribute(ECRFUserCRFDataAttributes.SUBJECT);	
	}
	
	if(Validator.isNotNull(subject)) {
		birth = subject.getBirth();
		_log.info(subject.getSerialId() + " / " + sdf.format(birth));
	}	
	
	// 1) DB에서 전체 이력 조회
	List<TreatmentHistory> allHistories = new ArrayList<TreatmentHistory>();
	
	if(crfId > 0 && subjectId > 0 && linkId > 0) {
		allHistories = TreatmentHistoryLocalServiceUtil.getTreatmentsByG_C_P_L(scopeGroupId, crfId, subjectId, linkId);
	}

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
	_log.info("allHistoryJson : " + allHistoryJson.toString());
%>

<div class="ecrf-user-crf-data">		<!-- for scss -->
<div class="add-teeth" style="padding:10px;">

	<% Object[] args = {  String.valueOf(teethCount) , teethsParam }; %>
	<div style="padding: 0px 0px; font-size: 20px; font-weight: bold;">
		<liferay-ui:message key="ecrf-user.crf-data.teeth.add-teeth.teeth-num-text" arguments="<%=args%>" />
	</div>
	
	<div class="treatment-row">
 		<!-- 날짜 선택 -->
 		<div class="treatment-box-date option-group">
 			<label for="treatmentDate"><liferay-ui:message key="ecrf-user.crf-data.teeth.add-teeth.date-input-label" /></label><br>
			<input type="date" name="treatmentDate" id="treatmentDate" min="1970-01-01" max="">
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
							<p><strong><liferay-ui:message key="ecrf-user.crf-data.teeth.catrgory.preventive" /></strong></p>
							<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="TFA" data-category="예방"/>
									<liferay-ui:message key="ecrf-user.crf-data.teeth.catrgory.preventive.tfa" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="SC" data-category="예방"/>
									<liferay-ui:message key="ecrf-user.crf-data.teeth.catrgory.preventive.sc" />
								</label>
							</div>
						</div>
					
						<!-- 수복 -->
						<div class="inline-section with-border">
							<p><strong><liferay-ui:message key="ecrf-user.crf-data.teeth.category.restoration" /></strong></p>
							<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="Seal" data-category="수복"/>
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.restoration.seal" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="AF" data-category="수복"/>
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.restoration.af" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="RF" data-category="수복"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.restoration.rf" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="Gl" data-category="수복"/>
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.restoration.gl" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="SS" data-category="수복"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.restoration.ss" /> 
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="Zr" data-category="수복"/>
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.restoration.zr" />
								</label>
							</div>
						</div>
					
					</div>
				
					<!-- 치수 -->
					<div id="radioButtonWrapper" class="treatment-box option-group">
						<div class="inline-section">
							<p><strong><liferay-ui:message key="ecrf-user.crf-data.teeth.category.surgery" /></strong></p>
							<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="Ext" data-category="외과"/>
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.surgery.ext" />
								</label>
								<!-- yes일 경우 서술 공간 필요 -->
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="oral" data-category="외과"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.surgery.oral" />
								</label>
							</div>
						</div>
						<div class="inline-section with-border">
							<p><strong><liferay-ui:message key="ecrf-user.crf-data.teeth.category.pulp" /></strong></p>
							<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="Pulpo" data-category="치수"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.pulp.pulpo" />
									</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="Pulpec" data-category="치수"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.pulp.pulpec" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="Apexo" data-category="치수"/>
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.pulp.apexo" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="Apexi" data-category="치수"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.pulp.apexi" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="RCT" data-category="치수"/>
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.pulp.rct" />
								</label>
							</div>
						</div>
					</div>
				
				
					<!-- 교정 -->
					<div id="radioButtonWrapper" class="treatment-box option-group">
						<div class="inline-section">
							<p><strong><liferay-ui:message key="ecrf-user.crf-data.teeth.category.anesthesia" /></strong></p>
							<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="DOR" data-category="전신마취"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.anesthesia.dor" /> 
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="MOR" data-category="전신마취"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.anesthesia.mor" /> 
								</label>
							</div>
						</div>
						<div class="inline-section with-border">
							<p><strong><liferay-ui:message key="ecrf-user.crf-data.teeth.category.orthodontics" /></strong></p>
							<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="firstStraighten" data-category="교정"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.orthodontics.firstStraighten" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="secondStraighten" data-category="교정"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.orthodontics.secondStraighten" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="partialStraighten" data-category="교정"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.orthodontics.partialStraighten" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="muscleFunction" data-category="교정"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.orthodontics.muscleFunction" />
								</label>
							</div>
						</div>
					</div>
				
					<!-- 공간유지장치 -->
					<div id="radioButtonWrapper" class="treatment-box option-group">
						<div class="inline-section">
							<p><strong><liferay-ui:message key="ecrf-user.crf-data.teeth.category.space-maintainer" /></strong></p>
							<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="BL" data-category="공간유지장치"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.space-maintainer.bl" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="LA" data-category="공간유지장치"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.space-maintainer.la" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="NHA" data-category="공간유지장치"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.space-maintainer.nha" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="RSM" data-category="공간유지장치"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.space-maintainer.rsm" />
								</label>
							</div>
						</div>
						<div class="inline-section with-border">
							<p><strong><liferay-ui:message key="ecrf-user.crf-data.teeth.category.sedation" /></strong></p>
							<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="N2OSedation" data-category="진정"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.sedation.n20" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="LASedation" data-category="진정"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.sedation.las" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="NHASedation" data-category="진정"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.sedation.nha" />
								</label>
								<label>
									<input type="checkbox" class="mar-r-2" name="status" value="RSMSedation" data-category="진정"/> 
									<liferay-ui:message key="ecrf-user.crf-data.teeth.category.sedation.rsm" />
								</label>
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
		<liferay-ui:message key="ecrf-user.crf-data.teeth.add-teeth.treatment-record" arguments="<%=teethsParam%>" />
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
		<liferay-ui:message key="ecrf-user.crf-data.teeth.add-teeth.add-treatemnt-notice" />
	</div>
	
	<div class="treatment-column" style="justify-content: center; margin-top: 20px; margin-bottom: 20px;">
	  	<button id="addDBBtn" type="button" style="padding: 5px 15px; font-size: 15px;">Save</button>
		<button id="cancelBtn" type="button" style="padding: 5px 15px; font-size: 15px; margin-left: 5px;">Cancel</button>
	</div>

</div>
</div>		<!-- for scss -->

<portlet:resourceURL id="<%=ECRFUserMVCCommand.RESOURCE_ADD_TREATMENT%>" var="resourceAddURL"/>

<c:set var="initialTeeths" value="${param.teeths}" />
<script>
	const resourceURL = '<%=resourceAddURL.toString()%>';
	var INITIAL_TEETHS = '${initialTeeths}'; //jstl로 처리 

	console.log(window.INITIAL_TEETHS);

	const allHistoryData = <%= allHistoryJson.toString() %>;
	const teethsParam = '<%= teethsParam.toString() %>';
	console.log("전체 이력:", allHistoryData);
	console.log("선택 치아:", teethsParam);
	console.log("Received teeths:", "<%= teethsParam %>");

	$(document).ready(function() {
		// 전역에 배열로 저장
		const birth = new Date('<%=Validator.isNull(birth) ? "2025-01-01" : sdf.format(birth)%>');
		
		window.teeth = {
			birth : birth,
			subjectId: <%=subjectId%>,
			crfId: <%=crfId%>,
			linkId: <%=linkId%>
		};

		console.log(window.teeth);
	});
</script>

<script src="/o/ecrf.user.crf/js/teeth/treatment.js"></script>