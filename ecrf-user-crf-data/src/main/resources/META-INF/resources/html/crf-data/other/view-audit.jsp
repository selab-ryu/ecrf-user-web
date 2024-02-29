<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html.crf-data.data.view_audit_jsp"); %>

<%
	SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/M/d");

	String menu = "update-crf-data";

	long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID);
	long sdId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID); 

	_log.info("subject id : " + subjectId);
	_log.info("sd id : " + sdId);
	
	Subject subject = null;
	if(subjectId > 0) {
		subject = (Subject)renderRequest.getAttribute(ECRFUserCRFDataAttributes.SUBJECT);
	}
	
	String crfForm = (String)renderRequest.getAttribute(ECRFUserCRFDataAttributes.CRF_FORM);
	String answerForm = (String)renderRequest.getAttribute(ECRFUserCRFDataAttributes.ANSWER_FORM);
	
	CRFGroupCaculation groupApi = new CRFGroupCaculation();
	groupApi.getEachGroupProgress(dataTypeId, JSONFactoryUtil.createJSONObject(answerForm));
	
	_log.info("crfForm : " + crfForm);
	_log.info("answerForm : " + answerForm);
%>

<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_REDIRECT_UPDATE_CRF_QUERY %>" var="redirectUpdateQuery">
</liferay-portlet:actionURL>

<div class="ecrf-user-crf-data ecrf-user">

	<%@ include file="sidebar.jspf" %>
	
	<div class="page-content">
	
		<liferay-ui:header backURL="<%=redirect %>" title='ecrf-user.crf-data.title.audit-trail' />
	
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
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="name"
								label="ecrf-user.subject.name">
								<p><%=Validator.isNull(subject) ? "-" : subject.getName() %></p>
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
								<p><%=Validator.isNull(subject) ? "-" : dateFormat.format(subject.getBirth()) + " (" + Math.abs(124 - subject.getBirth().getYear()) + ")" %></p>
							</aui:field-wrapper>
						</aui:col>
					</aui:row>
				</aui:container>
			</aui:fieldset>
		</aui:fieldset-group>
		
		<aui:fieldset-group markupView="lexicon">
			<aui:fieldset cssClass="search-option radius-shadow-container pad8" style="" collapsed="<%=false %>" collapsible="<%=true %>" label="ecrf-user.crf-data.title.audit-trail">
				<table class="crf-max-width  table crfHistory">
					<tbody id="canvasPanel">
					</tbody>
				</table>
			</aui:fieldset>
		</aui:fieldset-group>
		
		<!-- change input name -->
		<aui:form name="fm" action="${redirectUpdateQuery}">
			<aui:input type="hidden" name="termName"></aui:input>
			<aui:input type="hidden" name="termValue"></aui:input>
			<aui:input type="hidden" name="subjectId" value="<%=subjectId%>"></aui:input>
			<aui:input type="hidden" name="crfId" value="<%=crfId %>"></aui:input>
			<aui:input type="hidden" name ="<%=ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID %>" value="<%=sdId%>"></aui:input>
		</aui:form>
	</div>
</div>

<aui:script>
$(document).ready(function(){
	console.group("view-audit");

	let crfFormArr = JSON.parse('<%=crfForm%>');
	var answerFormArr = JSON.parse('<%=answerForm%>');
	console.log("json parse end");
		
	var mainGroupKeys = new Array();
	var subGroupKeys = new Array();
	var sectionKeys = new Array();
	for(var index = 0; index < crfFormArr.length; index++){
		if(crfFormArr[index].termType === "Group"){
			if(!crfFormArr[index].hasOwnProperty('groupTermId')){
				mainGroupKeys.push(crfFormArr[index]);
			}
			else{
				subGroupKeys.push(crfFormArr[index]);
			}
		}else{
			sectionKeys.push(crfFormArr[index]);
		}
	}
	
	Liferay.Service(
	  '/ec.crf-autoquery/get-query-list-by-s-id',
	  {
	    subjectId: <%=subjectId %>
	  },
	  function(obj) {
	  	var results = new Array();
	  	var queryComfirm = new Array();
	  	for(var i = 0; i < obj. length; i++){
	  		if(obj[i].queryTermId == <%=sdId %>){
	  			results.push(obj[i].queryTermName);
	  			queryComfirm.push(obj[i].queryComfirm);
	  		}
	  	}
		$("#canvasPanel").empty();
		if(mainGroupKeys.length > 0 && subGroupKeys.length < 1){
			createMediumCRFTable(mainGroupKeys, sectionKeys, answerFormArr, results, queryComfirm);
		}else if(mainGroupKeys.length > 0){
			createCRFTable(mainGroupKeys, subGroupKeys, sectionKeys, answerFormArr, results, queryComfirm);
		}else{
			createGroupCol("No Group");
			createSmallCRFTable(sectionKeys,answerFormArr, results, queryComfirm);
		}
	  }
	);
	
	console.groupEnd();
});

function createCRFTable(mainGroupKeys, subGroupKeys, sectionKeys, answerFormArr, results, queryComfirm){
	for(var i = 0; i < mainGroupKeys.length; i++){
		createGroupCol(mainGroupKeys[i].displayName.en_US);
		var count = 0;
		if(subGroupKeys.length > 0){
			for(var j = 0; j < subGroupKeys.length; j++){
				if(subGroupKeys[j].groupTermId.name === mainGroupKeys[i].termName){
					createSectionCol(subGroupKeys[j], sectionKeys, answerFormArr, results, queryComfirm);
					count++
				}			
			}	
		}
		else{
			createSmallSectionCol(sectionKeys, answerFormArr, results, queryComfirm);
		}
		if(count == 0){
			createSectionCol(mainGroupKeys[i], sectionKeys, answerFormArr, results, queryComfirm);
		}
	}
	createGroupCol("No Group");
	const sectionTr = document.createElement("tr");
	const answerTr = document.createElement("tr");
	for(var k = 0; k < sectionKeys.length; k++){
		if(!sectionKeys[k].hasOwnProperty("groupTermId")){
			const sectionTd = document.createElement("td");
			const sectionNode = document.createTextNode(sectionKeys[k].displayName.en_US);
			sectionTd.appendChild(sectionNode);
			sectionTd.setAttribute("style", "background: #727272; color: white; border: solid 1px #000; text-align: center;");
			let isQuery = false;
			for(var i = 0; i < results.length; i++){
						if(results[i] === sectionKeys[k].termName){
							sectionTd.setAttribute("style", "background: #727272; color: red; border: solid 1px #000; text-align: center;");
							isQuery = true;
							if(queryComfirm[i] == 2){
								sectionTd.setAttribute("style", "background: #727272; color: green; border: solid 1px #000; text-align: center;");						
							}
						}
					}
			const answerTd = document.createElement("td");
			var non_excuted="<liferay-ui:message key='SxcrfForm.history.non-execution'/>";
			let answer = "";
			if(answerFormArr.hasOwnProperty(sectionKeys[k].termName)){
				if(sectionKeys[k].termType==="List"){
					for(var idx = 0; idx < sectionKeys[k].options.length; idx++){
						if(sectionKeys[k].options[idx].value === answerFormArr[sectionKeys[k].termName][0]){
							answer = sectionKeys[k].options[idx].label.en_US;
							break;
						}else{
							answer = non_excuted;
						}
					}
				}else if(sectionKeys[k].termType==="Date"){
					var dateValue = "";
					if(typeof answerFormArr[sectionKeys[k].termName] === 'string'){
						dateValue = parseFloat(answerFormArr[sectionKeys[k].termName]);
					}else{
						dateValue = answerFormArr[sectionKeys[k].termName];
					}
					var date = new Date(dateValue);
					answer = date.toLocaleDateString("ko-KR") + " " + date.toLocaleTimeString("ko-KR");
				}
				else{
					if(Number.isInteger(answerFormArr[sectionKeys[k].termName])){
						answer = answerFormArr[sectionKeys[k].termName];
						if(sectionKeys[k].hasOwnProperty("unit")){
							answer = answer + " " + sectionKeys[k].unit;
						}			
					}else if(typeof answerFormArr[sectionKeys[k].termName] === 'string'){
						answer = answerFormArr[sectionKeys[k].termName];
					}else if(answerFormArr[sectionKeys[k].termName].toString().split(".")[1].length > 1){
						answer = answerFormArr[sectionKeys[k].termName].toFixed(2);
						if(sectionKeys[k].hasOwnProperty("unit")){
							answer = answer + " " + sectionKeys[k].unit;
						}	
					}else{
						answer = answerFormArr[sectionKeys[k].termName].toFixed(1);
						if(sectionKeys[k].hasOwnProperty("unit")){
							answer = answer + " " + sectionKeys[k].unit;
						}	
					}
				}
			}else{
				answer = non_excuted;				
			}
			const answerNode = document.createTextNode(answer);
			answerTd.setAttribute("id", sectionKeys[k].termName);
			answerTd.setAttribute("style", "background: #FFFFFF; color: black; border: solid 1px #000; text-align: center;");
			answerTd.setAttribute("onClick", "openHistoryDialog(id)");
			answerTd.appendChild(answerNode);
			answerTr.appendChild(answerTd);
			sectionTd.setAttribute("onClick", "openQuery(" + sectionKeys[k].termName + "," + answerFormArr[sectionKeys[k].termName] + "," + isQuery +")");
			sectionTr.appendChild(sectionTd);
		}
	}
	$("#canvasPanel").append(sectionTr);
	$("#canvasPanel").append(answerTr);
}

function createMediumCRFTable(mainGroupKeys, sectionKeys, answerFormArr, results, queryComfirm){
	for(var i = 0; i < mainGroupKeys.length; i++){
		createGroupCol(mainGroupKeys[i].displayName.en_US);
		const sectionTr = document.createElement("tr");
		const answerTr = document.createElement("tr");
		for(var k = 0; k < sectionKeys.length; k++){
			if(sectionKeys[k].hasOwnProperty("groupTermId")){
				if(sectionKeys[k].groupTermId.name === mainGroupKeys[i].termName){
					const sectionTd = document.createElement("td");
					const sectionNode = document.createTextNode(sectionKeys[k].displayName.en_US);
					sectionTd.appendChild(sectionNode);
					sectionTd.setAttribute("style", "background: #727272; color: white; border: solid 1px #000; text-align: center;");
					let isQuery = false;
					for(var i = 0; i < results.length; i++){
						if(results[i] === sectionKeys[k].termName){
							sectionTd.setAttribute("style", "background: #727272; color: red; border: solid 1px #000; text-align: center;");
							isQuery = true;
							if(queryComfirm[i] == 2){
								sectionTd.setAttribute("style", "background: #727272; color: green; border: solid 1px #000; text-align: center;");						
							}
						}
					}
					const answerTd = document.createElement("td");
					var non_excuted="<liferay-ui:message key='SxcrfForm.history.non-execution'/>";
					let answer = "";
					if(answerFormArr.hasOwnProperty(sectionKeys[k].termName)){
						if(sectionKeys[k].termType==="List"){
							for(var idx = 0; idx < sectionKeys[k].options.length; idx++){
								if(sectionKeys[k].options[idx].value === answerFormArr[sectionKeys[k].termName][0]){
									answer = sectionKeys[k].options[idx].label.en_US;
									break;
								}else{
									answer = non_excuted;
								}
							}
						}else if(sectionKeys[k].termType==="Date"){
							var dateValue = "";
							if(typeof answerFormArr[sectionKeys[k].termName] === 'string'){
								dateValue = parseFloat(answerFormArr[sectionKeys[k].termName]);
							}else{
								dateValue = answerFormArr[sectionKeys[k].termName];
							}
							var date = new Date(dateValue);
							answer = date.toLocaleDateString("ko-KR") + " " + date.toLocaleTimeString("ko-KR");
						}
						else{
							if(Number.isInteger(answerFormArr[sectionKeys[k].termName])){
								answer = answerFormArr[sectionKeys[k].termName];
								if(sectionKeys[k].hasOwnProperty("unit")){
									answer = answer + " " + sectionKeys[k].unit;
								}			
							}else if(typeof answerFormArr[sectionKeys[k].termName] === 'string'){
								answer = answerFormArr[sectionKeys[k].termName];
							}else if(answerFormArr[sectionKeys[k].termName].toString().split(".")[1].length > 1){
								answer = answerFormArr[sectionKeys[k].termName].toFixed(2);
								if(sectionKeys[k].hasOwnProperty("unit")){
									answer = answer + " " + sectionKeys[k].unit;
								}	
							}else{
								answer = answerFormArr[sectionKeys[k].termName].toFixed(1);
								if(sectionKeys[k].hasOwnProperty("unit")){
									answer = answer + " " + sectionKeys[k].unit;
								}	
							}
						}
					}else{
						answer = non_excuted;				
					}
					const answerNode = document.createTextNode(answer);
					answerTd.setAttribute("id", sectionKeys[k].termName);
					answerTd.setAttribute("style", " background: #FFFFFF; color: black; border: solid 1px #000; text-align: center;");
					answerTd.setAttribute("onClick", "openHistoryDialog(id)");
					answerTd.appendChild(answerNode);
					answerTr.appendChild(answerTd);
					sectionTd.setAttribute("onClick", "openQuery(" + sectionKeys[k].termName + "," + answerFormArr[sectionKeys[k].termName] + "," + isQuery +")");
					sectionTr.appendChild(sectionTd);
				}
			}
		}
		$("#canvasPanel").append(sectionTr);
		$("#canvasPanel").append(answerTr);
	}
	createGroupCol("No Group");
	const sectionTr = document.createElement("tr");
	const answerTr = document.createElement("tr");
	for(var k = 0; k < sectionKeys.length; k++){
		if(!sectionKeys[k].hasOwnProperty("groupTermId")){
			const sectionTd = document.createElement("td");
			const sectionNode = document.createTextNode(sectionKeys[k].displayName.en_US);
			sectionTd.appendChild(sectionNode);
			sectionTd.setAttribute("style", "background: #727272; color: white; border: solid 1px #000; text-align: center;");
			let isQuery = false;
			for(var i = 0; i < results.length; i++){
						if(results[i] === sectionKeys[k].termName){
							sectionTd.setAttribute("style", "background: #727272; color: red; border: solid 1px #000; text-align: center;");
							isQuery = true;
							if(queryComfirm[i] == 2){
								sectionTd.setAttribute("style", "background: #727272; color: green; border: solid 1px #000; text-align: center;");						
							}
						}
					}
			const answerTd = document.createElement("td");
			var non_excuted="<liferay-ui:message key='SxcrfForm.history.non-execution'/>";
			let answer = "";
			if(answerFormArr.hasOwnProperty(sectionKeys[k].termName)){
				if(sectionKeys[k].termType==="List"){
					for(var idx = 0; idx < sectionKeys[k].options.length; idx++){
						if(sectionKeys[k].options[idx].value === answerFormArr[sectionKeys[k].termName][0]){
							answer = sectionKeys[k].options[idx].label.en_US;
							break;
						}else{
							answer = non_excuted;
						}
					}
				}else if(sectionKeys[k].termType==="Date"){
					var dateValue = "";
					if(typeof answerFormArr[sectionKeys[k].termName] === 'string'){
						dateValue = parseFloat(answerFormArr[sectionKeys[k].termName]);
					}else{
						dateValue = answerFormArr[sectionKeys[k].termName];
					}
					var date = new Date(dateValue);
					answer = date.toLocaleDateString("ko-KR") + " " + date.toLocaleTimeString("ko-KR");
				}
				else{
					if(Number.isInteger(answerFormArr[sectionKeys[k].termName])){
						answer = answerFormArr[sectionKeys[k].termName];
						if(sectionKeys[k].hasOwnProperty("unit")){
							answer = answer + " " + sectionKeys[k].unit;
						}			
					}else if(typeof answerFormArr[sectionKeys[k].termName] === 'string'){
						answer = answerFormArr[sectionKeys[k].termName];
					}else if(answerFormArr[sectionKeys[k].termName].toString().split(".")[1].length > 1){
						answer = answerFormArr[sectionKeys[k].termName].toFixed(2);
						if(sectionKeys[k].hasOwnProperty("unit")){
							answer = answer + " " + sectionKeys[k].unit;
						}	
					}else{
						answer = answerFormArr[sectionKeys[k].termName].toFixed(1);
						if(sectionKeys[k].hasOwnProperty("unit")){
							answer = answer + " " + sectionKeys[k].unit;
						}	
					}
				}
			}else{
				answer = non_excuted;				
			}
			const answerNode = document.createTextNode(answer);
			answerTd.setAttribute("id", sectionKeys[k].termName);
			answerTd.setAttribute("style", " background: #FFFFFF; color: black; border: solid 1px #000; text-align: center;");
			answerTd.setAttribute("onClick", "openHistoryDialog(id)");
			answerTd.appendChild(answerNode);
			answerTr.appendChild(answerTd);
			sectionTd.setAttribute("onClick", "openQuery(" + sectionKeys[k].termName + "," + answerFormArr[sectionKeys[k].termName] + "," + isQuery +")");
			sectionTr.appendChild(sectionTd);
		}
	}
	$("#canvasPanel").append(sectionTr);
	$("#canvasPanel").append(answerTr);
}

function createSmallCRFTable(sectionKeys, answerFormArr, results, queryComfirm){
	createSmallSectionCol(sectionKeys, answerFormArr, results, queryComfirm);
}

function createGroupCol(name){
	const groupTr = document.createElement("tr");
	const groupTd = document.createElement("td");
	const groupNameNode = document.createTextNode(name);
	groupTd.appendChild(groupNameNode);	
	groupTd.setAttribute("style", "background: #424242; color: white; border: solid 1px #424242; border-top: solid 5px #BEBEBE");
	groupTr.appendChild(groupTd);
	
	$("#canvasPanel").append(groupTr);
}

function createSectionCol(group, sectionKeys, answerFormArr, results, queryComfirm){
	const sectionTr = document.createElement("tr");
	const subGroupName = document.createElement("td");
	subGroupName.setAttribute("rowSpan", 2);
	const subGroupNameText = document.createTextNode(group.displayName.en_US);
	subGroupName.appendChild(subGroupNameText);
	subGroupName.setAttribute("style", "background: #727272; color: white; border: solid 1px #000;");
	sectionTr.appendChild(subGroupName);
	const answerTr = document.createElement("tr");
	
	//create section node
	for(var k = 0; k < sectionKeys.length; k++){
		if(sectionKeys[k].hasOwnProperty("groupTermId") && sectionKeys[k].groupTermId.name === group.termName){
			const sectionTd = document.createElement("td");
			const sectionNode = document.createTextNode(sectionKeys[k].displayName.en_US);
			sectionTd.appendChild(sectionNode);
			sectionTd.setAttribute("style", "background: #727272; color: white; border: solid 1px #000; text-align: center;");
			let isQuery = false;
			for(var i = 0; i < results.length; i++){
						if(results[i] === sectionKeys[k].termName){
							sectionTd.setAttribute("style", "background: #727272; color: red; border: solid 1px #000; text-align: center;");
							isQuery = true;
							if(queryComfirm[i] == 2){
								sectionTd.setAttribute("style", "background: #727272; color: green; border: solid 1px #000; text-align: center;");						
							}
						}
					}
			const answerTd = document.createElement("td");
			var non_excuted="<liferay-ui:message key='SxcrfForm.history.non-execution'/>";
			let answer = "";
			if(answerFormArr.hasOwnProperty(sectionKeys[k].termName)){
				if(sectionKeys[k].termType==="List"){
					for(var idx = 0; idx < sectionKeys[k].options.length; idx++){
						if(sectionKeys[k].options[idx].value === answerFormArr[sectionKeys[k].termName][0]){
							answer = sectionKeys[k].options[idx].label.en_US;
							break;
						}else{
							answer = non_excuted;
						}
					}
				}else if(sectionKeys[k].termType==="Date"){
					var dateValue = "";
					if(typeof answerFormArr[sectionKeys[k].termName] === 'string'){
						dateValue = parseFloat(answerFormArr[sectionKeys[k].termName]);
					}else{
						dateValue = answerFormArr[sectionKeys[k].termName];
					}
					var date = new Date(dateValue);
					answer = date.toLocaleDateString("ko-KR") + " " + date.toLocaleTimeString("ko-KR");
				}
				else{
					if(Number.isInteger(answerFormArr[sectionKeys[k].termName])){
						answer = answerFormArr[sectionKeys[k].termName];
						if(sectionKeys[k].hasOwnProperty("unit")){
							answer = answer + " " + sectionKeys[k].unit;
						}			
					}else if(typeof answerFormArr[sectionKeys[k].termName] === 'string'){
						answer = answerFormArr[sectionKeys[k].termName];
					}else if(answerFormArr[sectionKeys[k].termName].toString().split(".")[1].length > 1){
						answer = answerFormArr[sectionKeys[k].termName].toFixed(2);
						if(sectionKeys[k].hasOwnProperty("unit")){
							answer = answer + " " + sectionKeys[k].unit;
						}	
					}else{
						answer = answerFormArr[sectionKeys[k].termName].toFixed(1);
						if(sectionKeys[k].hasOwnProperty("unit")){
							answer = answer + " " + sectionKeys[k].unit;
						}	
					}
				}
			}else{
				answer = non_excuted;				
			}
			const answerNode = document.createTextNode(answer);
			answerTd.setAttribute("id", sectionKeys[k].termName);
			answerTd.setAttribute("style", " background: #FFFFFF; color: black; border: solid 1px #000; text-align: center;");
			answerTd.setAttribute("onClick", "openHistoryDialog(id)");
			answerTd.appendChild(answerNode);
			answerTr.appendChild(answerTd);
			sectionTd.setAttribute("onClick", "openQuery(" + sectionKeys[k].termName + "," + answerFormArr[sectionKeys[k].termName] + "," + isQuery +")");
			sectionTr.appendChild(sectionTd);	
		}
	}
	$("#canvasPanel").append(sectionTr);
	$("#canvasPanel").append(answerTr);
}

function createSmallSectionCol(sectionKeys, answerFormArr, results, queryComfirm){
	//create section node
	const sectionTr = document.createElement("tr");
	const answerTr = document.createElement("tr");
	for(var k = 0; k < sectionKeys.length; k++){
		const sectionTd = document.createElement("td");
		const sectionNode = document.createTextNode(sectionKeys[k].displayName.en_US);
		sectionTd.appendChild(sectionNode);
		sectionTd.setAttribute("style", "background: #727272; color: white; border: solid 1px #000; text-align: center;");
		let isQuery = false;
		for(var i = 0; i < results.length; i++){
						if(results[i] === sectionKeys[k].termName){
							sectionTd.setAttribute("style", "background: #727272; color: red; border: solid 1px #000; text-align: center;");
							isQuery = true;
							if(queryComfirm[i] == 2){
								sectionTd.setAttribute("style", "background: #727272; color: green; border: solid 1px #000; text-align: center;");						
							}
						}
					}
		const answerTd = document.createElement("td");
		var non_excuted="<liferay-ui:message key='SxcrfForm.history.non-execution'/>";
		let answer = "";
		if(answerFormArr.hasOwnProperty(sectionKeys[k].termName)){
				if(sectionKeys[k].termType==="List"){
					for(var idx = 0; idx < sectionKeys[k].options.length; idx++){
						if(sectionKeys[k].options[idx].value === answerFormArr[sectionKeys[k].termName][0]){
							answer = sectionKeys[k].options[idx].label.en_US;
							break;
						}else{
							answer = non_excuted;
						}
					}
				}else if(sectionKeys[k].termType==="Date"){
					var dateValue = "";
					if(typeof answerFormArr[sectionKeys[k].termName] === 'string'){
						dateValue = parseFloat(answerFormArr[sectionKeys[k].termName]);
					}else{
						dateValue = answerFormArr[sectionKeys[k].termName];
					}
					var date = new Date(dateValue);
					answer = date.toLocaleDateString("ko-KR") + " " + date.toLocaleTimeString("ko-KR");
				}
				else{
					if(Number.isInteger(answerFormArr[sectionKeys[k].termName])){
						answer = answerFormArr[sectionKeys[k].termName];
						if(sectionKeys[k].hasOwnProperty("unit")){
							answer = answer + " " + sectionKeys[k].unit;
						}			
					}else if(typeof answerFormArr[sectionKeys[k].termName] === 'string'){
						answer = answerFormArr[sectionKeys[k].termName];
					}else if(answerFormArr[sectionKeys[k].termName].toString().split(".")[1].length > 1){
						answer = answerFormArr[sectionKeys[k].termName].toFixed(2);
						if(sectionKeys[k].hasOwnProperty("unit")){
							answer = answer + " " + sectionKeys[k].unit;
						}	
					}else{
						answer = answerFormArr[sectionKeys[k].termName].toFixed(1);
						if(sectionKeys[k].hasOwnProperty("unit")){
							answer = answer + " " + sectionKeys[k].unit;
						}	
					}
				}
			}else{
				answer = non_excuted;				
			}
		const answerNode = document.createTextNode(answer);
		answerTd.setAttribute("id", sectionKeys[k].termName);
		answerTd.setAttribute("style", " background: #FFFFFF; color: black; border: solid 1px #000; text-align: center;");
		answerTd.setAttribute("onClick", "openHistoryDialog(id)");
		answerTd.appendChild(answerNode);
		answerTr.appendChild(answerTd);
		sectionTd.setAttribute("onClick", "openQuery(" + sectionKeys[k].termName + "," + answerFormArr[sectionKeys[k].termName] + "," + isQuery +")");
		sectionTr.appendChild(sectionTd);		
	}
	$("#canvasPanel").append(sectionTr);
	$("#canvasPanel").append(answerTr);
}

function openHistoryDialog(id){
	console.log("function activate");
	let crfFormArr = JSON.parse('<%=crfForm%>');
	var displayName = "";
	for(var i = 0; i < crfFormArr.length; i++){
		if(crfFormArr[i].termName === id){
			displayName = crfFormArr[i].displayName.en_US;
		}
	}
	var termName = id;
	var renderURL = Liferay.PortletURL.createRenderURL();
	renderURL.setPortletId("<%=themeDisplay.getPortletDisplay().getId() %>");
	renderURL.setPortletMode("edit");
    renderURL.setWindowState("pop_up"); 
	renderURL.setParameter("subjectId", <%=subjectId %>);
	renderURL.setParameter("crfId", <%=crfId %>);
	renderURL.setParameter("<%=ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID %>", <%=sdId %>);
	renderURL.setParameter("displayName", displayName);
	renderURL.setParameter("termName", termName);
	renderURL.setParameter("mvcRenderCommandName", "<%=ECRFUserMVCCommand.RENDER_DIALOG_AUDIT %>");
	Liferay.Util.openWindow(
			{
				dialog: {
					cache: false,
					destroyOnClose: true,
					centered: true,
					constrain2view: true,
					modal: true,
					resizable: false,
					height: 700,
					width: 1000
				},
				title: 'Audit Trail',
				uri: renderURL.toString()
			}
		);
}

function openQuery(termName, value, isQuery){
	var form = document.getElementById('<portlet:namespace/>fm');
	var termNameId = termName.id;
	console.log(<%=subjectId %>, <%=sdId %>, termNameId, value, isQuery);
	if(isQuery){
		var termNameInput = form.querySelector("#<portlet:namespace/>termName");
		var termValueInput = form.querySelector("#<portlet:namespace/>termValue");
		termNameInput.setAttribute("value", termNameId);
		termValueInput.setAttribute("value", value);
		
		form.submit();
	}
}

</aui:script>