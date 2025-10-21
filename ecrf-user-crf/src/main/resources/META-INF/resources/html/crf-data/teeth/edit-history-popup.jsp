<%@page import="teeth.model.TreatmentHistory"%>
<%@ include file="../../init.jsp" %>

<%
	List<TreatmentHistory> EditHistoryList = (List<TreatmentHistory>) request.getAttribute("EditHistoryList");
	TreatmentHistory treatmentHistory = (TreatmentHistory) request.getAttribute("treatmentHistory");

	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	long userId = themeDisplay.getUserId();

	long subjectId = 0;
	Subject subject = null;
	
	String treatmentInfo = null;

	String stateStr = "";
	String treatmentStr = "";

	if(Validator.isNotNull(treatmentHistory)) {
		subjectId = treatmentHistory.getPatientID();

		if(subjectId > 0) {
			subject = SubjectLocalServiceUtil.getSubject(subjectId);
		}

		treatmentInfo = "treatmentID=" + treatmentHistory.getTreatmentID() +
						", teethNum=" + treatmentHistory.getTeethNum() +
						", treatment=" + treatmentHistory.getTreatment() +
						", state=" + treatmentHistory.getState() +
						", teeth=" + treatmentHistory.getTeethNum() +
						", treatmentDate=" + treatmentHistory.getTreatmentDate();

		treatmentStr = treatmentHistory.getTreatment();
		treatmentStr = treatmentStr.replace(",", ", ");
		stateStr = treatmentHistory.getState();
		stateStr = stateStr.replace(",", ", ");
	}
	
	String subjectName = "";
	boolean hasViewEncryptPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_ENCRYPT_SUBJECT);

	if(Validator.isNotNull(subject)) {
		subjectName = subject.getName();
		
		if(!hasViewEncryptPermission)
			subjectName = ECRFUserUtil.encryptName(subjectName);	
	}
%>

<script src="/o/ecrf.user.crf/js/teeth/categoryLabelMap.js"></script>

<div class="ecrf-user">	<!-- for scss -->
<div class="edit-treatment">
	<aui:container cssClass="info-container">
		<aui:row>
			<aui:col>
				<h3 style="">Selected Treatment Information</h3>
			</aui:col>
		</aui:row>
		<aui:row cssClass="top-border">
			<aui:col md="4" cssClass="marTr">
				<aui:field-wrapper
					name="serialId"
					label="ecrf-user.subject.serial-id">
					<p><%=Validator.isNull(subject) ? "-" : String.valueOf(subject.getSerialId()) %></p>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="4" cssClass="marTr">
				<aui:field-wrapper
					name="name"
					label="ecrf-user.subject.name">
					<p><%=Validator.isNull(subject) ? "-" : subjectName %></p>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="4" cssClass="marTr">
				<aui:field-wrapper
					name="name"
					label="ecrf-user.subject.birth">
					<p><%=Validator.isNull(subject) ? "-" : sdf.format(subject.getBirth()) %></p>
				</aui:field-wrapper>
			</aui:col>
			
		</aui:row>
		<aui:row cssClass="top-border">
			<aui:col md="4" cssClass="marTr">
				<aui:field-wrapper
					name="teethNum"
					label="ecrf-user.crf-data.teeth.treatment-date">
					<p><%=Validator.isNull(treatmentHistory) ? "-" : sdf.format(treatmentHistory.getTreatmentDate()) %></p>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="4" cssClass="marTr">
				<aui:field-wrapper
					name="state"
					label="ecrf-user.crf-data.teeth.state">
					<p><%=Validator.isNull(treatmentHistory) ? "-" : stateStr %></p>
				</aui:field-wrapper>
			</aui:col>
			<aui:col md="4" cssClass="marTr">
				<aui:field-wrapper
					name="treatment"
					label="ecrf-user.crf-data.teeth.treatment">
					<p><%=Validator.isNull(treatmentHistory) ? "-" : treatmentStr %></p>
				</aui:field-wrapper>
			</aui:col>
		</aui:row>
	</aui:container>

	<div id="treatment-details" class="treatment-info" style="display:none">
		<p id="treatmentID">Treatment ID: </p>
		<p id="teethNum">Teeth Number: </p>
		<p id="treatment">Treatment: </p>
		<p id="state">State: </p>
		<p id="treatmentDate">TreatmentDate: </p>
	</div>

	<portlet:actionURL var="editDBURL" name="/edit_tooth_treatment" />

	<!-- ✨ 여기부터 form 추가 ✨ -->
	<aui:form name="editDBForm" action="" method="post">

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
								<p><strong><liferay-ui:message key="ecrf-user.crf-data.teeth.catrgory.preventive" /></strong></p>
								<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="TFA" />
										<liferay-ui:message key="ecrf-user.crf-data.teeth.catrgory.preventive.tfa" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="SC" />
										<liferay-ui:message key="ecrf-user.crf-data.teeth.catrgory.preventive.sc" />
									</label>
								</div>
							</div>
						
							<!-- 수복 -->
							<div class="inline-section with-border">
								<p><strong><liferay-ui:message key="ecrf-user.crf-data.teeth.category.restoration" /></strong></p>
								<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="Seal" />
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.restoration.seal" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="AF" />
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.restoration.af" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="RF" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.restoration.rf" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="Gl" />
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.restoration.gl" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="SS" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.restoration.ss" /> 
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="Zr" />
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
										<input type="checkbox" class="mar-r-2" name="status" value="Ext" />
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.surgery.ext" />
									</label>
									<!-- yes일 경우 서술 공간 필요 -->
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="oral" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.surgery.oral" />
									</label>
								</div>
							</div>
							<div class="inline-section with-border">
								<p><strong><liferay-ui:message key="ecrf-user.crf-data.teeth.category.pulp" /></strong></p>
								<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="Pulpo" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.pulp.pulpo" />
										</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="Pulpec" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.pulp.pulpec" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="Apexo" />
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.pulp.apexo" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="Apexi" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.pulp.apexi" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="RCT" />
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
										<input type="checkbox" class="mar-r-2" name="status" value="DOR" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.anesthesia.dor" /> 
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="MOR" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.anesthesia.mor" /> 
									</label>
								</div>
							</div>
							<div class="inline-section with-border">
								<p><strong><liferay-ui:message key="ecrf-user.crf-data.teeth.category.orthodontics" /></strong></p>
								<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="firstStraighten" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.orthodontics.firstStraighten" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="secondStraighten" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.orthodontics.secondStraighten" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="partialStraighten" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.orthodontics.partialStraighten" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="muscleFunction" /> 
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
										<input type="checkbox" class="mar-r-2" name="status" value="BL" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.space-maintainer.bl" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="LA" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.space-maintainer.la" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="NHA" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.space-maintainer.nha" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="RSM" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.space-maintainer.rsm" />
									</label>
								</div>
							</div>
							<div class="inline-section with-border">
								<p><strong><liferay-ui:message key="ecrf-user.crf-data.teeth.category.sedation" /></strong></p>
								<div style="border-left: 1px solid #ccc; padding-left: 10px; display: flex; gap: 10px;">
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="N2OSedation" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.sedation.n20" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="LASedation" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.sedation.las" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="NHASedation" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.sedation.nha" />
									</label>
									<label>
										<input type="checkbox" class="mar-r-2" name="status" value="RSMSedation" /> 
										<liferay-ui:message key="ecrf-user.crf-data.teeth.category.sedation.rsm" />
									</label>
								</div>
							</div>
						</div>
					</td>
				</tr>
			</table>
		</div>

		<div style="display: flex; justify-content: center; margin-top: 20px; margin-bottom: 20px; gap: 20px;">
			<button type="button" class="btn btn-primary" onclick="submitForm()" value="save">Save</button>
			<button type="button" class="btn btn-secondary" onclick="Delete()" value="delete">Delete</button>
			<button type="button" class="btn btn-secondary" onclick="cancel()" value="back">Back</button>
		</div>
	</aui:form>
</div>
</div>	<!-- for scss -->

<portlet:resourceURL id="<%=ECRFUserMVCCommand.RESOURCE_EDIT_TREATMENT%>" var="resourceEditURL">
	<portlet:param name="treatmentId" value="<%=String.valueOf(treatmentHistory.getTreatmentID())%>" />
</portlet:resourceURL>

<portlet:resourceURL id="<%=ECRFUserMVCCommand.RESOURCE_DELETE_TREATMENT%>" var="resourceDeleteURL">
	<portlet:param name="treatmentId" value="<%=String.valueOf(treatmentHistory.getTreatmentID())%>" />
</portlet:resourceURL>

<script type="text/javascript">
	$(document).ready(function() {
		const treat = '<%= treatmentInfo %>';
		if(treat) applyTreatment(treat);
	});

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

	//edit 화면에서 선택한 진료기록을 삭제 요청하는 function
    function Delete() {
    	$.confirm({
			title: '<liferay-ui:message key="ecrf-user.message.confirm-delete-teeth-treatment.title"/>',
			content: '<p><liferay-ui:message key="ecrf-user.message.confirm-delete-teeth-treatment.content"/></p>',
			type: 'red',
			typeAnimated: true,
			columnClass: 'large',
			buttons:{
				ok: {
					btnClass: 'btn-blue',
					action: function(){
						const resourceURL = '<%=resourceDeleteURL.toString()%>';
					  	const base = resourceURL;
					    let urlObj = new URL(base);
				    	
				        $.ajax({
				            type: 'POST',
				            url: urlObj,
				            contentType: 'application/json; charset=UTF-8',
				            success: function(response) {
				            	console.log("response:", response);
				            	window.history.back();
				            },
				            error: function(xhr, status, error) {
				                console.error("AJAX Failed:", error);
				            }
				        });
					}
				},
				close: {
		            action: function () {}
		        }
			},
			draggable: false
		});		
    
	}
    
 	//edit 화면에서 편집한 진료기록을 저장하는 function
    function submitForm() {
        setFormValues();  // 숨겨진 input 값 세팅
		
		const paramData = {
			<portlet:namespace/>state : document.getElementById('permanentInput').value,
			<portlet:namespace/>treatment : document.getElementById('statusInput').value
        };

        console.log('submitForm() 호출 - 전송 데이터:', paramData);

		const resourceURL = '<%=resourceEditURL.toString()%>';
	  	const base = resourceURL;
	    let urlObj = new URL(base);
		
        $.ajax({
            type: 'POST',
            url: urlObj,
            data: paramData,
            success: function(response) {
                window.history.back();
				console.log("서버 응답:", response);
            },
            error: function(xhr, status, error) {
                console.error("AJAX 실패:", error);
            }
        });
    }

    function cancel() {
    	 window.history.back();
    }

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