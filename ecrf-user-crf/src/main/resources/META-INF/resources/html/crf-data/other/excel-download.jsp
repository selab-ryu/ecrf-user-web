<%@page import="com.liferay.portal.kernel.portlet.LiferayPortletURL"%>
<%@page import="ecrf.user.service.CRFSearchLogLocalServiceUtil"%>
<%@ include file="../../init.jsp" %>

<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.14.3/xlsx.full.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/1.3.8/FileSaver.min.js"></script>

<%! Log _log = LogFactoryUtil.getLog("html.crf-data.other.excel-download.jsp"); %>

<%
	_log.info("Render Excel Download JSP");
	String menu = "crf-data-excel";
	
	_log.info("1. Get data from java");
	String subjectJson = (String)renderRequest.getAttribute("subjectJson");
	String answerJson = (String)renderRequest.getAttribute("answerJson");
	String json = (String)renderRequest.getAttribute("json");
	String options = (String)renderRequest.getAttribute("options");
	
	
	boolean isSearch = false;
	String[] arr_options = null;
	
	arr_options = options.split(",");
	_log.info("1. End");
	
	// Check Total Search
	if(options == "noSearch"){
		isSearch = false;
	}
	else{
		isSearch = true;
		arr_options = options.split(",");
	}

	// Gets the information (name) of the CRF
	Long dtypeId = CRFLocalServiceUtil.getCRF(crfId).getDatatypeId();
	DataType dataType = DataTypeLocalServiceUtil.getDataType(dtypeId);
	String dType = dataType.getDisplayName();
	String[] dName = dType.split(">");
	String[] fin_dName = dName[3].split("<");
	
	boolean hasDownloadExcelPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DOWNLOAD_EXCEL);
	
	LiferayPortletURL baseURL = PortletURLFactoryUtil.create(request, themeDisplay.getPortletDisplay().getId(), themeDisplay.getPlid(), PortletRequest.RENDER_PHASE);
%>

<style>
       pre {
        word-wrap: break-word;
      }
      #Big_Category{
        color:red;
        display:inline;
      }
      #Main_Category{
        display:inline;
        color:blue;
      }
      #Sub_Category{
        display:inline-block;
        color:green;
      }
     
	.marL100 { margin-left: 100px; }
	.marL150 { margin-left: 150px; }
	.padL114 { margin-left: 114px; }
	.padL214 { margin-left: 214px; }
	.padL264 { 
		margin-left: 264px; 
	}
	.padL478 { 
		margin-left: 478px; 
	}
	
	.w100 { width:100px; }
	.w200 { width:200px; }
	.w250 { width:250px; }

	.crfinfo{
		background-image: linear-gradient(90deg, red, orange, yellow, green, blue, navy, purple);
		-webkit-background-clip: text;
		color: transparent;
		
		font-weight: bold;
		font-size: 40px;
	}
	.checkboxx{
		vertical-align: middle;
	}
	
	.overfflow{
		display: inline-block;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
		width: 100px;
		margin-left: 0.5em;
		vertical-align: middle;
	}
	
	.tooltip {
            visibility: hidden;
            background-color: black;
            color: #fff;
            text-align: center;
            border-radius: 5px;
            padding: 5px;
            position: absolute;
            z-index: 1;
            transform: translateX(50%);
            opacity: 0;
            transition: opacity 0.3s;
 	}
 	.overfflow:hover .tooltip {
            visibility: visible;
            opacity: 1;
	}
	#circlered {

		width : 20px;
		height : 20px;
		border-radius: 50%;
		background-color: red;
		display: inline-block;
	}
	#circleblue {

		width : 20px;
		height : 20px;
		border-radius: 50%;
		background-color: blue;
		display: inline-block;
	}
	#circleblack {

		width : 20px;
		height : 20px;
		border-radius: 50%;
		background-color: black;
		display: inline-block;
	}
</style>

<div class="ecrf-user-crf-data ecrf-user">

	<%@ include file="sidebar.jspf" %>
	
	<div class="page-content">
	
		<liferay-ui:header backURL="<%=redirect %>" title='ecrf-user.crf-data.title.excel-download' />
		<!-- CRF Info Header -->
		<aui:fieldset-group markupView="lexicon">
			<aui:fieldset cssClass="search-option radius-shadow-container" collapsed="<%=false %>" collapsible="<%=true %>" label="ecrf-user.crf.title.crf-info">
				<aui:container>
					<aui:row cssClass="top-border">
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="title"
								label="ecrf-user.crf.crf-title">
								<p><%=Validator.isNull(dataType)?StringPool.BLANK:dataType.getDisplayName() %></p>
							</aui:field-wrapper>
						</aui:col>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="version"
								label="ecrf-user.crf.version">
								<p><%=Validator.isNull(dataType)?StringPool.BLANK:dataType.getDataTypeVersion() %></p>
							</aui:field-wrapper>
						</aui:col>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="count-subejct"
								label="ecrf-user.crf.crf-subject-count">
								<p><%=CRFSubjectLocalServiceUtil.countCRFSubjectByCRFId(scopeGroupId, crfId) %></p>
							</aui:field-wrapper>
						</aui:col>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="data-subejct"
								label="ecrf-user.crf.crf-data-count">
								<p><%=LinkCRFLocalServiceUtil.countLinkCRFByG_C(scopeGroupId, crfId) %></p>
							</aui:field-wrapper>
						</aui:col>
					</aui:row>
				</aui:container>
			</aui:fieldset>
		</aui:fieldset-group>
		
		<div class="radius-shadow-container" style="width:auto;">
			<!-- Display which Term type for each Text color -->
			<div id="guideText" style="float: right;">
				<div id ="circlered"></div>
				<h2 style="display: inline-block;">&nbsp;Frequency&nbsp;</h2>
				<div id ="circleblue"></div>
				<h2 style="display: inline-block;">&nbsp;Numeric&nbsp;</h2>
				<div id ="circleblack"></div>
				<h2 style="display: inline-block;">&nbsp;Etc(String, Date, ..)&nbsp;</h2>
			</div>
			<!-- All Term selections available in full -->
			<input type = "checkbox" id = "EntireCheck" onClick = "EntireCheck(this.id)"/>
			<label class="w200" for ="EntireCheck">AllCheck</label>
			<hr style="border: solid 1px #787878">
			<!-- Display Term -->
		    <span id="searchText"></span>
		    <!-- Option to choose whether to divide the selected Term by Sheet -->
		    <div>
		    	<span>Sheet Divide : </span>
			    <input type="radio" id="group" name="divideOption" value="group">
			    <label for="group">Divide Group</label>
			    <input type="radio" id="whole" name="divideOption" value="whole" checked = "checked">
			    <label for="whole">No Divide Group</label>
		    </div>
		    
		    <input id="xlsx_name" placeholder="FileName">.xlsx &nbsp</input>
		    <button id="btn_1" <%=hasDownloadExcelPermission ? "" : "disabled"%> >Export xlsx</button>
		</div>
	</div>
</div>

<script>
	// Check or uncheck all sub-inputs, including the input itself.
	function allcheck(id){
		let inputCheck = $("input[id = " + id + "]");
		let inputCheckChild = inputCheck.parent().children('div');
		let isCheck = inputCheck[0].checked;
		
		for(var i = 0; i < inputCheckChild.length; i++){
			inputCheckChild[i].children[0].checked = isCheck;
			
			if(inputCheckChild[i].id == 'Main_Category'){
				for(var j = 0; j < inputCheckChild[i].children.length; j++){
					if(inputCheckChild[i].children[j].id == 'Sub_Category'){
						inputCheckChild[i].children[j].children[0].checked = isCheck;
					}
				}
			}
		}
	}
	
	// Check or uncheck all input.
	function EntireCheck(id){
        let Big_Checkbox = $("input[id = " + id + "]").parent().children('span').find('input');
        for(var i = 0; i < Big_Checkbox.length; i++){
        	Big_Checkbox[i].checked = $("input[id = " + id + "]")[0].checked;
        	allcheck(Big_Checkbox[i].id);
        }
    }

	// Function that also de-checks the parent classification when the child classification is de-checked
	function isAll(id){
		let sameDepthCheckbox = $("input[id = " + id + "]").parent().parent().children('div').children('input');
		let upperDepthCheckbox = $("input[id = " + id + "]").parent().parent().children('input')[0];
		let checkNum = 0;

		// Get the number of checks of people of the same depth.
		for(var i = 0; i < sameDepthCheckbox.length; i++){
			if(sameDepthCheckbox[i].checked){
				checkNum++;
			}
		}

		// Check parent classification if the number checked is equal to the number of classifications; uncheck otherwise
		if(sameDepthCheckbox.length == checkNum){
			upperDepthCheckbox.checked = true;
		}
		else{
			upperDepthCheckbox.checked = false;
		}

		// If the subclassification is examined, the middle classification is also examined.
		if(upperDepthCheckbox.id.includes('B')){
			isAll(upperDepthCheckbox.id);
		}
	}
	
	// Sort to output the Terms at each Level in a predetermined order before outputting them
	function sort_list(obj){
		var list_ordered = [];
        for(var i = 0; i < obj.length; i++){
        	list_ordered[obj[i].order - 1] = obj[i];
        }
        return list_ordered;
	}
	
	// Graph Part
	function renderGraph(elem){
		console.log("Render Graph");
        let inspectionData = JSON.parse(JSON.stringify(<%=json%>)).terms;
		var termLabel = $(elem);
		var termName = termLabel.attr("name");			
		var type = "";
		var displayName = "";
		for(var i = 0; i < inspectionData.length; i++){
			// Currently, there are 2 types to output the Graph
			if(inspectionData[i].termName === termName){
				if(inspectionData[i].termType === "List"){
					type = "List";
					displayName = inspectionData[i].displayName.en_US;
					break;
				}
				else if(inspectionData[i].termType === "Numeric"){
					type = "Numeric";
					displayName = inspectionData[i].displayName.en_US;
					break;
				}
			}
		}
		// TODO : if there is not exist data, then dont call popup function
		var answerData = JSON.parse(JSON.stringify(<%=answerJson%>));
		var answerCount = 0;
		
		if(type != ""){
			for(var i = 0; i < answerData.length; i++){
				if(!(termName in answerData[i])){
					answerCount++;
				}
			}
			if(answerCount == answerData.length){
				type = "empty";
			}
		}
		
		if(type === "List" || type === "Numeric"){
			createGraphPopupRenderURL("<%=themeDisplay.getPortletDisplay().getId() %>"
					, termName, displayName, type, <%=crfId%>
					, "<%=ECRFUserMVCCommand.RENDER_DIALOG_CRF_DATA_GRAPH %>"
					, "<%=baseURL.toString()%>");
		}
		else if(type === "empty"){
			alert("No data available for generating the graph.");	
		}
	}
	
	// Function that puts the Html value to output the Terms for each Depth
	function renderTerm(contentText, termDepth, className, index, termName, classLabel, displayName){
		var termLabel = '';
		var termFunc = '';
		
		if(termDepth == 'Big_Category'){
			termLabel = 'A_' + index;
			termFunc = 'allcheck(this.id);';
		}
		else if(termDepth == 'Main_Category'){
			termLabel = 'B_' + index;
			termFunc = 'allcheck(this.id); isAll(this.id);';
		}
		else if(termDepth == 'Sub_Category'){
			termLabel = 'C_' + index;
			termFunc = 'isAll(this.id);';
		}
		

		contentText += '<div id = "' + termDepth + '" class = "'
					+ className
					+ '">';
		if(termDepth == 'Sub_Category'){
			contentText += '<input type = "checkbox" id = "' 
				+ termLabel
    			+ '" value = "' 
    			+ termName 
    			+ '"name = "Section" onClick = "'
    			+ termFunc
    			+ '"/>';
		}
		else{
			contentText += '<input type = "checkbox" id = "' 
				+ termLabel
    			+ '" value = "' 
    			+ termName 
    			+ '"name = "" onClick = "'
    			+ termFunc
    			+ '"/>';
		}
        			
        contentText += '<label class="'
        			+ classLabel
        			+'" onClick="renderGraph(this);" for ="'
        			+ termLabel
        			+ '" name = "' 
        			+ termName
        			+ '">' 
        			+ displayName
        			+ '<span class = "tooltip">'
        			+ displayName
        			+ '</span></label>';
        			
        return contentText;
	}

</script>

<script>
	
	// Display Term
	// Variables with Html values
	var contentText = "";
	var inspectionData = JSON.parse(JSON.stringify(<%=json%>)).terms;
	
	// Term at the highest level (without groupTerm)
	var categoryFirst = [];
    var categoryNoGroup = [];

    // Divide the only Term without a Group Term
    for(var i = 0; i < inspectionData.length; i++){
        if(inspectionData[i].termType == 'Group'){
			if(!('groupTermId' in inspectionData[i]))
				categoryFirst.push(inspectionData[i]);
        }
        
        else if(inspectionData[i].termType != 'Group'){
            if(!('groupTermId' in inspectionData[i])){
            	categoryFirst.push(inspectionData[i]);
            	categoryNoGroup.push(inspectionData[i]);
            }
        }
    }

    // Sort to output the Terms at each Level in a predetermined order before outputting them
    categoryFirst = sort_list(categoryFirst);

 	// Index to attach Each Category element id
    var indexA = 0;
    var indexB = 0;
    var indexC = 0;
    
    // Html value for Horizontal delimiter
    var line_divide = '<hr style="border: solid 1px #787878">';
    
    // Print Term at the highest level (without groupTerm)
    for(var i = 0; i < categoryFirst.length; i++){
    	// In the case of Term that does not belong anywhere, it is treated the same as the top Term, printed out and finished
    	if(categoryNoGroup.includes(categoryFirst[i])){
    		// However, since it is a term that directly receives a value, it is processed as Sub
    		contentText = renderTerm(contentText, 'Sub_Category', ''
    								, indexC, categoryFirst[i].termName, 'w200'
    								, categoryFirst[i].displayName.en_US);
            indexC++;
            contentText += '</div>';
            contentText += line_divide;
    	}
    	// Print Term at the highest level (without groupTerm)
    	else{
    		contentText = renderTerm(contentText, 'Big_Category', ''
    								, indexA, categoryFirst[i].termName, 'w200'
    								, categoryFirst[i].displayName.en_US);
    		indexA++;
            
    		// Term at the middle level (with groupTerm)
            var categorySecond = [];
            
            for(var j = 0; j < inspectionData.length; j++){
            	if('groupTermId' in inspectionData[j]
            			&& inspectionData[j].groupTermId.name == categoryFirst[i].termName){
            		categorySecond.push(inspectionData[j]);
            	}
            }
            
         	// Sort to output the Terms at each Level in a predetermined order before outputting them
            categorySecond = sort_list(categorySecond);
            
         	// Check if any of the middle Term has a lower Term (Group Term)
			var isGroup = false;
			for(var j = 0 ; j < categorySecond.length; j++){
				if(categorySecond[j].termType == 'Group'){
					isGroup = true;
				}
			}
            /*if(categorySecond.find(e => e.termType == 'Group') != undefined)
            	isGroup = true;*/
			
            var Flag_Sub_category = true;
            var Flag_Main_category = true;
            var Index_Sub_category = 0;
            
            // Print Term at the middle level (with groupTerm)
            for(var j = 0; j < categorySecond.length; j++){
            	if(isGroup){
            		var mainCateClass = "";
                    // First Printed Main Category needs this space 
                    if(Flag_Main_category){
                        Flag_Main_category = false;
                    }
                    // other Main Category needs this space
                    else{
                    	mainCateClass = "padL214";
                    }
					// Depth is 2 but there is no sub-Term
                    if(categorySecond[j].termType != 'Group'){
                    	contentText = renderTerm(contentText, "Sub_Category", mainCateClass
                    							, indexC, categorySecond[j].termName, 'w250'
                    							, categorySecond[j].displayName.en_US);
                    	indexC++;
                    	contentText += '</div>';
                    	contentText += '<br>';
                    }
                    else{
                    	contentText = renderTerm(contentText, "Main_Category", mainCateClass
				                    			, indexC, categorySecond[j].termName, 'w250'
				    							, categorySecond[j].displayName.en_US);
                    	indexB++;
                        
                        var categoryThird = [];
                        
                        for(var k = 0; k < inspectionData.length; k++){
                        	if('groupTermId' in inspectionData[k]
                        			&& inspectionData[k].groupTermId.name == categorySecond[j].termName){
                        		categoryThird.push(inspectionData[k]);
                        	}
                        }
                        
                        categoryThird = sort_list(categoryThird);
                        
                        var Index_Sub_category_1 = 0;
                        var Flag_Sub_category_1 = true;
                        for(var k = 0; k < categoryThird.length; k++){
                        	var subCateClass = "";
                            // New line if 4 sections are printed per line
                            if(Index_Sub_category_1 == 5){
                            	contentText += '<br>';
                                subCateClass = "padL478";
                                Index_Sub_category_1 = 0;
                            }

                            if(Flag_Sub_category){
                            	Flag_Sub_category_1 =false;
                            }
                            
                            contentText = renderTerm(contentText, "Sub_Category", subCateClass
                    							, indexC, categoryThird[k].termName, 'overfflow'
                    							, categoryThird[k].displayName.en_US);
                            indexC++;
                            Index_Sub_category_1++;
                            contentText += '</div>';
						}
                        contentText += '<br>';
                        contentText += '</div>';
					}
				}
	            else{
	        		var subCateClass = "";
	                // New line if 4 sections are printed per line
	                if(Index_Sub_category == 5){
	                	contentText += '<br>';
	                    subCateClass = "padL478";
	                    Index_Sub_category = 0;
	                }
	
	                if(Flag_Sub_category){
	                	subCateClass = "padL264";
	                    Flag_Sub_category = false;
	                }
	                contentText = renderTerm(contentText, "Sub_Category", subCateClass
								, indexC, categorySecond[j].termName, 'overfflow'
								, categorySecond[j].displayName.en_US);
	                indexC++;
	                Index_Sub_category++;
	                contentText += '</div>';
	        	}
        	} 
            contentText += '</div>';
            contentText += line_divide;
		}
    }
    document.getElementById("searchText").innerHTML = contentText;
    
    // Paint the element(Term); List => Red / Numeric => Blue
    for(var i = 0; i < inspectionData.length; i++){
		if(inspectionData[i].termType === "List"){
			var eleTerm = document.getElementsByName(inspectionData[i].termName);
			eleTerm[0].setAttribute("style", "color: red!important;");
		}
		else if(inspectionData[i].termType === "Numeric"){
			var eleTerm = document.getElementsByName(inspectionData[i].termName);
			eleTerm[0].setAttribute("style", "color: blue!important;");
		}
	}
</script>

<script>

	//Encoding operation
	function s2ab(s) {
		var buf = new ArrayBuffer(s.length); //convert s to arrayBuffer
		var view = new Uint8Array(buf); //create uint8array as viewer
		
		for (var i=0; i<s.length; i++){
			view[i] = s.charCodeAt(i) & 0xFF; //convert to octet
		}
		
		return buf;
	}

	// Functions that get values from an array
	function getProperty(object, property) {
		  var result = object[property]
		  return result
	}
	
	// Functions that change the Date value for use in Liferay
	function getDateData(Data_answer){
		var Data_date = new Date(Data_answer);
		
		Data_date.setHours(Data_date.getHours() - 9)
		
		if(Data_date.toLocaleString() == 'Invalid Date'){
			Data_answer = "";
		}
		else{
			Data_answer = Data_date.toLocaleString();
		}
		return Data_answer;
	}

</script>

<script>

	// Make the Excel File And Download
	function makeExcel(){
		const xlsxName = document.getElementById('xlsx_name').value;
		console.log(xlsxName);
		if(!xlsxName) {
			alert("excel name is empty");
			return;
		}
		
		console.log("2. Change the received data to json format");
		var inspectionData = JSON.parse(JSON.stringify(<%=json%>)).terms;
		// Total list variable to enter Excel and list variable to enter each line
    	var arrRow = [];
    	var arrFinal = [];
    	
    	// If there is Grid among the checked Terms
    	var isGrid = false;
    	
    	// Gets the information of the term(Have Value) selected on the page
    	var checkedList = $('input:checkbox[name="Section"]:checked');
    	
    	if(checkedList.length <= 0){
    		alert("Please check if there are any Term items checked.");
    		return;
    	}
    	
    	var splitValue = $('input[name=divideOption]:checked').val();
    	
		var isVisit = false;
		
		for(var i = 0; i < checkedList.length; i++){
			if(checkedList[i].value == 'visit_date'){
				isVisit = true;
				break;
			}
		}
		
		var noGroupSheet = [];
		var noGroupDeleteIndex = [];
		if(splitValue == 'group'){
			for(var i = 0; i < checkedList.length; i++){
				var termDest = inspectionData.find(v => v.termName === checkedList[i].value);
	    		
	    		// If groupTermId is not present (Terms that are not in the group)
	    		if(inspectionData.find(v => v.termName === termDest.termName).groupTermId == undefined){
	    			noGroupSheet.push(checkedList[i]);
	    			noGroupDeleteIndex.push(i);
	    		}
			}
		}
		
		for(var i = 0; i < noGroupDeleteIndex.length; i++){
			checkedList.splice(noGroupDeleteIndex[i] - i, 1);
		}
		
		// Create xlsx workbook 
        var wb = XLSX.utils.book_new();

    	while(checkedList.length > 0 || noGroupSheet.length > 0){
    		if(splitValue == 'group' && checkedList.length <= 0){
    			checkedList = noGroupSheet;
    			noGroupSheet = [];
    		}
    		
    		arrRow = [];
        	arrFinal = [];
    		isGrid = false;
    		var sheetName = '';
    		console.log("3. Put crf information");
        	// CRF information Row
        	//-------------------------------------------------------------------------------------------
        	
        	arrRow.push("<%=fin_dName[0]%>");
        	arrFinal.push(arrRow);
        	//-------------------------------------------------------------------------------------------
        	console.log("3. End");
        	// Total Search Option Row
        	//-------------------------------------------------------------------------------------------
        	var Array_TotalSearch = new Array();
        	arrRow = [];
        	console.log("4. Processes and puts the selected options in the integrated search");
        	// In the case of total search, only the id that meets the search conditions is added
        	if(<%=isSearch%>){
    			var arrOptions = new Array();
        		
        		<% for (int i=0; i < arr_options.length; i++) { %>
        			arrOptions[<%= i %>] = "<%= arr_options[i] %>";
        		<% } %>
        		
        		// As I received the DB value as it is, I extracted only the value from the format of that value
        		var optionFinal = "Choose Term: ";
        		for(var i = 0; i < arrOptions.length; i++){
        			var extract_termName = null;
        			
        			if(arrOptions[i].includes("EXACT")){
        				extractTermName = arrOptions[i].split(" EXACT ");
        				optionFinal += inspectionData.find(v => v.termName === extractTermName[0]).displayName.en_US;
        				
        				var optionJson = inspectionData.find(v => v.termName === extractTermName[0]).options;
        				optionFinal += " => (";
        				optionFinal += optionJson.find(v => v.value == extractTermName[1]).label.en_US;
        				optionFinal += ")";
        			}
        			else if(arrOptions[i].includes("RANGE")){
        				extractTermName = arrOptions[i].split(" RANGE ");
        				optionFinal += inspectionData.find(v => v.termName === extractTermName[0]).displayName.en_US;
        				optionFinal += " => (";
        				optionFinal += extractTermName[1];
        				optionFinal += ")";
        			}
        			
        			if((i + 1) != arrOptions.length){
        				optionFinal += " / ";
        			}
        		}
            	
        		arrRow.push(optionFinal);
        		arrFinal.push(arrRow);
        	}
        	//-------------------------------------------------------------------------------------------
    		console.log("4. End");
    		console.log("5. Put in the highest Term Name");
        	// Top Category Row
        	//-------------------------------------------------------------------------------------------

        	// list containing the basic information column of the subject
        	if(isVisit){
        		arrInfo = ["ID", "Sex", "Age", "Name", "Visit_Date"];
        	}
        	else{
        		arrInfo = ["ID", "Sex", "Age", "Name"];
        	}
        	arrRow = [];
        	
        	// Input the basic information column of the subject
        	for(var i = 0; i < arrInfo.length; i++){
        		arrRow.push(arrInfo[i]);
        	}
        	
        	var deleteIndex = checkedList.length + 1;
        	
        	for(var i = 0; i < checkedList.length; i++){
        		if(isVisit && checkedList[i].value == 'visit_date'){
        			continue;
        		}
        		// Variables to add the value of displayName that you want to add in the end
        		var nameFinal = "";
        		
        		var termFirst = inspectionData.find(v => v.termName === checkedList[i].value);
        		
        		// If groupTermId is not present (Terms that are not in the group)
        		if(inspectionData.find(v => v.termName === termFirst.termName).groupTermId == undefined){
        			nameFinal = "";
        		}
        		else{ // If groupTermId is present and depth is 2
        			var termSecond = inspectionData.find(v => v.termName === termFirst.groupTermId.name);
        			
        			if(inspectionData.find(v => v.termName === termSecond.termName).groupTermId == undefined){
        				nameFinal = termSecond.displayName.en_US;
            		}
        			else{ // If groupTermId is present and depth is 3
        				var termThird = inspectionData.find(v => v.termName === termSecond.groupTermId.name);
        				nameFinal = termThird.displayName.en_US;
        			}
        		}
        		if(splitValue == 'group'){
        			if(!sheetName){
            			sheetName = nameFinal;
            		}
            		else if(sheetName != nameFinal){
            			deleteIndex = i + 1;
            			break;
            		}
        			
        		}
        		
        		// If there is Grid among the checked Terms
        		var lenGrid = 1;
        		
    			if(termFirst.termType == 'Grid'){
    				lenGrid = Object.keys(termFirst.columnDefs).length;
    				isGrid = true;
        		}
    			
    			for(var j = 0; j < lenGrid; j++){
    				arrRow.push(nameFinal);
    			}
        	}
        	
        	arrFinal.push(arrRow);	
        	//-------------------------------------------------------------------------------------------
        	console.log("5. End");
        	console.log("6. Put in the middle Term Name");
        	// Middle Category Row
        	//-------------------------------------------------------------------------------------------
        	arrRow = [];

        	// Input the basic information column of the subject (only space not value)
        	for(var j = 0; j < arrInfo.length; j++){
        		arrRow.push("");
        	}
        	
        	for(var i = 0; i < (deleteIndex - 1); i++){
        		if(isVisit && checkedList[i].value == 'visit_date'){
        			continue;
        		}
        		// Variables to add the value of displayName that you want to add in the end
        		var nameFinal = "";
        		
        		var termFirst = inspectionData.find(v => v.termName === checkedList[i].value);
        		
        		// If groupTermId is not present (Terms that are not in the group)
        		if(inspectionData.find(v => v.termName === termFirst.termName).groupTermId == undefined){
        			nameFinal = "";
        		}
        		else{ 
        			var termSecond = inspectionData.find(v => v.termName === termFirst.groupTermId.name);
        			// If groupTermId is present and depth is 2
        			if(inspectionData.find(v => v.termName === termSecond.termName).groupTermId == undefined){
        				nameFinal = "";
            		}
        			else{ // If groupTermId is present and depth is 3
        				var termThird = inspectionData.find(v => v.termName === termSecond.groupTermId.name);
        				nameFinal = termSecond.displayName.en_US;
        			}
        		}
        		
        		// If there is Grid among the checked Terms
        		var lenGrid = 1;
        		
    			if(termFirst.termType == 'Grid'){
    				lenGrid = Object.keys(termFirst.columnDefs).length;
        		}
    			
    			for(var j = 0; j < lenGrid; j++){
    				arrRow.push(nameFinal);
    			}
        	}
        	arrFinal.push(arrRow);
        	//-------------------------------------------------------------------------------------------
        	console.log("6. End");
        	console.log("7. Put in the low Term Name");
        	// Low Category Row
        	//-------------------------------------------------------------------------------------------
        	arrRow = [];

        	for(var j = 0; j < arrInfo.length; j++){
        		arrRow.push("");
        	}
        	
        	for(var i = 0; i < (deleteIndex - 1); i++){
        		if(isVisit && checkedList[i].value == 'visit_date'){
        			continue;
        		}
        		
        		// Variables to add the value of displayName that you want to add in the end
        		var nameFinal = "";
        		
        		var termFirst = inspectionData.find(v => v.termName === checkedList[i].value);
        		
        		nameFinal = termFirst.displayName.en_US;
        		
        		// If there is Grid among the checked Terms
        		var lenGrid = 1;
        		
    			if(termFirst.termType == 'Grid'){
    				lenGrid = Object.keys(termFirst.columnDefs).length;
        		}
    			
    			for(var j = 0; j < lenGrid; j++){
    				arrRow.push(nameFinal);
    			}
        	}
        	arrFinal.push(arrRow);
        	//-------------------------------------------------------------------------------------------
        	console.log("7. End");
        	console.log("8. If Grid Term is included, add the name to the term that belongs to that term");
        	//Gird Row
        	//-------------------------------------------------------------------------------------------
        	// If Grid Term is included, it must be output by dividing it into Grid Term sub-Terms, so a separate Row is added
        	if(isGrid){
        		arrRow = [];
            	
            	for(var i = 0; i < arrInfo.length; i++){
            		arrRow.push("");
            	}
            	
            	for(var i = 0; i < (deleteIndex - 1); i++){
    				var term_first = inspectionData.find(v => v.termName === checkedList[i].value);

            		if(term_first.termType == 'Grid'){
            			var length_grid = Object.keys(term_first.columnDefs).length;
            			var array_grid_order = [];
            			
            			for(var j = 0; j < length_grid; j++){
            				var data_key_grid = Object.keys(term_first.columnDefs)[j];
    						var data_order_grid = JSON.stringify(term_first.columnDefs[data_key_grid].order);
    						array_grid_order[data_order_grid - 1] = term_first.columnDefs[data_key_grid];
            			}
            			
            			for(var j = 0; j < length_grid; j++){
    						arrRow.push(array_grid_order[j].displayName.en_US);
    					}
            		}else{
            			arrRow.push("");
            		}
            	}
            	arrFinal.push(arrRow);
        	}
        	console.log("8. End");
        	
        	console.log("9. Putting actual data in");
        	// Real Data
    		//-------------------------------------------------------------------------------------------
    		// Get answer data and patient information data.
    		var answerData = JSON.parse(JSON.stringify(<%=answerJson%>));
    		var patientData = JSON.parse(JSON.stringify(<%=subjectJson%>));
    		
        	if(isGrid){
        		console.log("9.1 If Grid Term is available, insert data");
    			for(var i = 0; i < answerData.length; i++){
    				// find grid's max length
    				var length_grid_max = 0;
    				
    				for(var j = 0; j < (deleteIndex - 1); j++){
    					if(inspectionData.find(v => v.termName === checkedList[j].value).termType == 'Grid'){
    						if(checkedList[j].value in answerData[i]){
    							
    							if(length_grid_max < Object.keys(answerData[i][checkedList[j].value]).length){
        							length_grid_max = Object.keys(answerData[i][checkedList[j].value]).length;
        						}
    						}
    						else{
    							if(length_grid_max <= 1){
    								length_grid_max = 1;
    							}
    							
    						}
    					}
    				}
    				// insert real data per grid max length
    				for(var j = 0; j < length_grid_max; j++){
    					arrRow = [];
    					//insert info
    					arrRow.push(patientData[i].ID);
    					arrRow.push(patientData[i].Sex);
    					arrRow.push(patientData[i].Age);
                		arrRow.push(patientData[i].Name);
                		// The method of putting data in each type is different, so it is processed as follows
                		for(var k = 0; k < (deleteIndex - 1); k++){
                			var Data_answer = "";
                			if(checkedList[k].value in answerData[i]){
                				Data_answer = answerData[i][checkedList[k].value];
                			}
                			else{
                				if(inspectionData.find(v => v.termName === checkedList[k].value).termType == 'Grid'){
                					var no_answer = Object.keys(inspectionData.find(v => v.termName === checkedList[k].value).columnDefs).length;
                    				for(var l = 0; l < no_answer; l++){
                    					arrRow.push("");
                    				}
                				}
                				else{
                					arrRow.push("");
                				}
                				continue;
                			}
        					if(j == 0){
        						if(inspectionData.find(v => v.termName === checkedList[k].value).termType == 'Date'){
        							Data_answer = getDateData(Data_answer);
        						}
        						else if(inspectionData.find(v => v.termName === checkedList[k].value).termType == 'Grid'){
        							var gridInfo = inspectionData.find(v => v.termName === checkedList[k].value).columnDefs;
        							var list_key = Object.keys(gridInfo);
        							var list_order = [];
        							for(var l = 0; l < list_key.length; l++){
        								list_order[gridInfo[list_key[l]].order - 1] = gridInfo[list_key[l]].termName;
        							}
        							for(var l = 0; l < list_order.length; l++){
        								var strIndex = (j + 1).toString();
        								arrRow.push(Data_answer[strIndex][list_order[l]]);
        							}
        							continue;
        							
        						}
        						
        						arrRow.push(Data_answer);
        					}
        					else{
        						if(inspectionData.find(v => v.termName === checkedList[k].value).termType == 'Grid'){
        							var gridInfo = inspectionData.find(v => v.termName === checkedList[k].value).columnDefs;
        							var list_key = Object.keys(gridInfo);
        							if(j < Object.keys(Data_answer).length){
        								var list_order = [];
            							for(var l = 0; l < list_key.length; l++){
            								list_order[gridInfo[list_key[l]].order - 1] = gridInfo[list_key[l]].termName;
            							}
            							for(var l = 0; l < list_order.length; l++){
            								var strIndex = (j + 1).toString();
            								arrRow.push(Data_answer[strIndex][list_order[l]]);
            							}
        							}
        							else{
        								for(var l = 0; l < list_key.length; l++){
        									arrRow.push("");
            							}
        							}
        						}
        						else{
        							arrRow.push("");
        						}
        					}
                		}
                		arrFinal.push(arrRow);
    				}
    			}
    		}
    		else{
    			console.log("9.2 If Grid Term is not available, insert data");
    			
    			for(var i = 0; i < answerData.length; i++){
    				arrRow = [];
    				arrRow.push(patientData[i].ID);
    				arrRow.push(patientData[i].Sex);
    				arrRow.push(patientData[i].Age);
            		arrRow.push(patientData[i].Name);
            		if(isVisit){
            			arrRow.push(getDateData(answerData[i]["visit_date"]));
            		}
            		for(var j = 0; j < (deleteIndex - 1); j++){
            			var Obj_PatientAnswer = answerData[i];
            			var Data_answer ="";
            			if(checkedList[j].value == 'visit_date' && isVisit){
            				continue;
            			}
            			Data_answer = getProperty(Obj_PatientAnswer, checkedList[j].value);

            			// termType == 'Date' -> milliseconds to date
            			if(inspectionData.find(v => v.termName === checkedList[j].value).termType == 'Date'){
            				Data_answer = getDateData(Data_answer);
            			}
            			
            			if(typeof(Data_answer) == 'object'){
            				Data_answer = Data_answer.toString();
            			}
            			arrRow.push(Data_answer);
            			
            		}
            		var jTime = new Date();
            		arrFinal.push(arrRow);
            		
    			}
    			console.log("9.2 End");
    			
    		}
        	
        	// Name each sheet, put the aoa variable in Excel, and put the aoa variable in the sheet
        	var excelHandler = {
                    getSheetName : function(){
                        return 'qwe';
                    },
                    getExcelData : function(){
                        return arrFinal;
                    },
                    getWorksheet : function(){
                        return XLSX.utils.aoa_to_sheet(this.getExcelData());
                    }
            }
        	
        	
            // Create xlsx sheet 
            var newWorksheet = excelHandler.getWorksheet();
         	// It puts coordinates for merging the cell of the initial patient information data.
            let merge = [];
         	
         	// The criteria for merging Cells are to merge when the same data is in the next col
         	// For example, if there is ['a', 'b', 'b', 'c', 'c', 'c', 'c', 'd', find the coordinate values that show continuous data such as (0, 0), (1, 2), (3, 5), and (6, 6)
         	if(<%=isSearch%>){
         		if(isGrid){
         			console.log("isSearch = yes, isGrid = yes");
         			for(var i = 0; i < arrInfo.length; i++){
                        let test = { s: {c: i, r: 2}, e: {c: i, r: 5}};
                        merge.push(test);
                    }
         			for(var i = 2; i < 5; i++){
         				let mergeResult =[];
         				let start = 0;
         				
         				for(let j = 1; j <= arrFinal[i].length; j++) {
         					if (arrFinal[i][j] !== arrFinal[i][j - 1] || j === arrFinal[i].length) {
         				    	mergeResult.push([start, j - 1]);
	         					start = j;
         					}
         				}
         				
         				if(i == 1){
         					mergeResult.splice(0, arrInfo.length);
         				}
         				else if(i == 2){
         					mergeResult.splice(0, 1);
         				}
         				
             			for(var j = 0; j < mergeResult.length; j++){
             				var merge_range = { s: {c: mergeResult[j][0], r: i}, e: {c: mergeResult[j][1], r: i}};
                    		merge.push(merge_range);
             			}
         			}
         		}
         		else{
         			console.log("isSearch = yes, isGrid = no");
         			for(var i = 0; i < arrInfo.length; i++){
                        let test = { s: {c: i, r: 2}, e: {c: i, r: 4}};
                        merge.push(test);
                    }
         			
         			for(var i = 2; i < 4; i++){
         				let mergeResult =[];
         				let start = 0;
         				
         				for(let j = 1; j <= arrFinal[i].length; j++) {
         					if (arrFinal[i][j] !== arrFinal[i][j - 1] || j === arrFinal[i].length) {
         				    	mergeResult.push([start, j - 1]);
	         					start = j;
         					}
         				}
         				
         				if(i == 2){
         					mergeResult.splice(0, arrInfo.length);
         				}
         				else if(i == 3){
         					mergeResult.splice(0, 1);
         				}
         				
             			for(var j = 0; j < mergeResult.length; j++){
             				var merge_range = { s: {c: mergeResult[j][0], r: i}, e: {c: mergeResult[j][1], r: i}};
                    		merge.push(merge_range);
             			}
         			}
         		}
         	}
         	else{
         		if(isGrid){
         			console.log("isSearch = no, isGrid = yes");
         			for(var i = 0; i < arrInfo.length; i++){
                        let test = { s: {c: i, r: 1}, e: {c: i, r: 4}};
                        merge.push(test);
                    }
         			
         			for(var i = 1; i < 4; i++){
         				let mergeResult =[];
         				let start = 0;
         				
         				for(let j = 1; j <= arrFinal[i].length; j++) {
         					if (arrFinal[i][j] !== arrFinal[i][j - 1] || j === arrFinal[i].length) {
         				    	mergeResult.push([start, j - 1]);
	         					start = j;
         					}
         				}
         				
         				if(i == 1){
         					mergeResult.splice(0, arrInfo.length);
         				}
         				else if(i == 2){
         					mergeResult.splice(0, 1);
         				}
         				
             			for(var j = 0; j < mergeResult.length; j++){
             				var merge_range = { s: {c: mergeResult[j][0], r: i}, e: {c: mergeResult[j][1], r: i}};
                    		merge.push(merge_range);
             			}
         			}
         		}
         		else{
         			console.log("isSearch = no, isGrid = no");
         			for(var i = 0; i < arrInfo.length; i++){
                        let test = { s: {c: i, r: 1}, e: {c: i, r: 3}};
                        merge.push(test);
                    }
         			
         			for(var i = 1; i < 3; i++){
         				let mergeResult =[];
         				let start = 0;
         				
         				for(let j = 1; j <= arrFinal[i].length; j++) {
         					if (arrFinal[i][j] !== arrFinal[i][j - 1] || j === arrFinal[i].length) {
         				    	mergeResult.push([start, j - 1]);
	         					start = j;
         					}
         				}
         				
         				if(i == 1){
         					mergeResult.splice(0, arrInfo.length);
         				}
         				else if(i == 2){
         					mergeResult.splice(0, 1);
         				}
         				
             			for(var j = 0; j < mergeResult.length; j++){
             				var merge_range = { s: {c: mergeResult[j][0], r: i}, e: {c: mergeResult[j][1], r: i}};
                    		merge.push(merge_range);
             			}
         			}
         		}
         	}
            
         	// If you put all the coordinate information, cell merge.
            newWorksheet["!merges"] = merge;
         	
            newWorksheet.s = {
            	aligment: {
            		wrapText: true
            	}
            }
            
            checkedList = checkedList.splice(deleteIndex - 1);
         	// Give a name to the newly created worksheet in the workbook.
            if(splitValue == 'group'){
            	if(checkedList.length > 0 || noGroupSheet.length > 0){
            		XLSX.utils.book_append_sheet(wb, newWorksheet, sheetName);
            	}
            	else{
            		XLSX.utils.book_append_sheet(wb, newWorksheet, 'noGroupSheet');
            	}
            	
            }
            else{
            	XLSX.utils.book_append_sheet(wb, newWorksheet, 'Whole Data');
            }
    	}
    	
    	// Create xlsx File
        var wbout = XLSX.write(wb, {bookType:'xlsx',  type: 'binary'});

        // Export xlsx File
        const xlsx_name = document.getElementById('xlsx_name').value + ('.xlsx');
        saveAs(new Blob([s2ab(wbout)],{type:"application/octet-stream"}), xlsx_name);
	}
	
	

</script>

<script>

	var hw = document.getElementById('btn_1');
	hw.addEventListener('click', makeExcel);
</script>
