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
		<!--  -->
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
					
		contentText += '<input type = "checkbox" id = "' 
					+ termLabel
        			+ '" value = "' 
        			+ termName 
        			+ '"name = "Section" onClick = "'
        			+ termFunc
        			+ '"/>'
        			
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

    // 
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
			
            if(categorySecond.find(e => e.termType == 'Group') != undefined)
            	isGroup = true;
			
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

	function getProperty(object, property) {
		  var result = object[property]
		  return result
	}

</script>

<script>

	// Make the Excel File And Download
	function makeExcel(){
		console.log("2. Change the received data to json format");
		var inspectionData = JSON.parse(JSON.stringify(<%=json%>)).terms;
		// Total list variable to enter Excel and list variable to enter each line
    	var arrRow = [];
    	var arrFinal = [];
    	
    	// If there is Grid among the checked Terms
    	var isGrid = false;
    	
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
    		
    		var optionFinal = "Choose Term: ";
    		for(var i = 0; i < arrOptions.length; i++){
    			//console.log("options: " + arr_options[i]);
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
    	var arrInfo = ["ID", "Sex", "Age", "Name"];
    	arrRow = [];
    	
    	// Gets the information of the term(Have Value) selected on the page
    	var checkedList = $('input:checkbox[name="Section"]:checked');

    	// Input the basic information column of the subject
    	for(var i = 0; i < arrInfo.length; i++){
    		arrRow.push(arrInfo[i]);
    	}
    	
    	for(var i = 0; i < checkedList.length; i++){
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
    	
    	for(var i = 0; i < checkedList.length; i++){
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
    	
    	for(var i = 0; i < checkedList.length; i++){
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
    	if(isGrid){
    		arrRow = [];
        	
        	for(var i = 0; i < arrInfo.length; i++){
        		arrRow.push("");
        	}
        	
        	for(var i = 0; i < checkedList.length; i++){
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
		console.log(answerData);
		console.log(isGrid);
    	if(isGrid){
    		console.log("9.1 If Grid Term is available, insert data");
			for(var i = 0; i < answerData.length; i++){
				// find grid's max length
				var length_grid_max = 0;
				
				for(var j = 0; j < checkedList.length; j++){
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
            		
            		for(var k = 0; k < checkedList.length; k++){
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
    					/* console.log("Data_answer:" + JSON.stringify(Data_answer)); */
    					if(j == 0){
    						if(inspectionData.find(v => v.termName === checkedList[k].value).termType == 'Date'){
    							var Data_date = new Date(Data_answer);
                				Data_date.setHours(Data_date.getHours() - 9)
                				
                				if(Data_date.toLocaleString() == 'Invalid Date'){
                					Data_answer = "";
                				}
                				else{
                					Data_answer = Data_date.toLocaleString();
                				}
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
    								//console.log("list_order: " + JSON.stringify(Data_answer[(j + 1).toString()]));
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
        								//console.log("list_order: " + list_order[l]);
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
            		console.log("Array_row: " + arrRow);
				}
			}
		}
		else{
			console.log("9.2 If Grid Term is not available, insert data");
			console.log("data: " + answerData.length);
			for(var i = 0; i < answerData.length; i++){
				arrRow = [];
				arrRow.push(patientData[i].ID);
				arrRow.push(patientData[i].Sex);
				arrRow.push(patientData[i].Age);
        		arrRow.push(patientData[i].Name);
        		for(var j = 0; j < checkedList.length; j++){
        			
        			var Obj_PatientAnswer = answerData[i];
        			var Data_answer ="";
        			
        			Data_answer = getProperty(Obj_PatientAnswer, checkedList[j].value);
        			// termType == 'Date' -> milliseconds to date
        			if(inspectionData.find(v => v.termName === checkedList[j].value).termType == 'Date'){
        				var Data_date = new Date(Data_answer);
        				Data_date.setHours(Data_date.getHours() - 9)
        				
        				if(Data_date.toLocaleString() == 'Invalid Date'){
        					Data_answer = "";
        				}
        				else{
        					Data_answer = Data_date.toLocaleString();
        				}
        			}
        			
        			if(typeof(Data_answer) == 'object'){
        				//console.log("ob: " + JSON.stringify(Data_answer));
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
                    return 'Sheet1';
                },
                getExcelData : function(){
                    return arrFinal;
                },
                getWorksheet : function(){
                    return XLSX.utils.aoa_to_sheet(this.getExcelData());
                }
        }
    	
    	// Create xlsx workbook 
        var wb = XLSX.utils.book_new();
        // Create xlsx sheet 
        var newWorksheet = excelHandler.getWorksheet();
        //var newWorksheet1 = excelHandler.getWorksheet();
     	// It puts coordinates for merging the cell of the initial patient information data.
        <%-- let merge = [];
     	
        if(<%=isSearch%>){
        	for(var i = 0; i < 3; i++){
                let test = { s: {c: i, r: 1}, e: {c: i, r: 3}};
                merge.push(test);
            }
        	
        	for(var i = 1; i < 3; i++){
            	var same_range = search_range(arrFinal[i]);

            	for(var j = 0; j < same_range.length; j++){
            		if(i == 2 && j == 0){
            			j = 1;
            		}
            			
            		try{
            			var merge_range = { s: {c: same_range[j][0], r: i}, e: {c: same_range[j][1], r: i}};
                		merge.push(merge_range);
            		}catch{
            			
            		}
            		
            	}
            }
        }
        else{
        	var length_info = 0;
        	if(bool_is_grid){
        		length_info = 4;
        	}else{
        		length_info = 3;
        	}

        	for(var i = 0; i < 4; i++){
                let range_info = { s: {c: i, r: 1}, e: {c: i, r: length_info}};
                merge.push(range_info);
            }

            for(var i = 0; i < 2; i++){
            	var same_range = search_range(arrFinal[i]);

            	for(var j = 0; j < same_range.length; j++){
            		if(i == 1 && j == 0){
            			j = 1;
            		}
            			
            		try{
            			var merge_range = { s: {c: same_range[j][0], r: i}, e: {c: same_range[j][1], r: i}};
                		merge.push(merge_range);
            		}catch{
            			
            		}
            		
            	}
            }
        }
        
     	// If you put all the coordinate information, cell merge.
        newWorksheet["!merges"] = merge; --%>
     	
        newWorksheet.s = {
        	aligment: {
        		wrapText: true
        	}
        }
     	// Give a name to the newly created worksheet in the workbook.
        XLSX.utils.book_append_sheet(wb, newWorksheet);
        //XLSX.utils.book_append_sheet(wb, newWorksheet1);
        
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

    <script>
    
    //var ContentText = "";
    var inspectionData = "";
    
    /*AUI().ready(function() {
    	//setUI();
    	var hw = document.getElementById('btn_1');
	    hw.addEventListener('click', download_excel);
    });
    
 	// Insert the UI to be printed so far into the text.
   	$(document).ready(function(){
    	
   	}); */
    
        
    	/*let $dialog = $('<div>');
    	let $table = $('<table style="width:100%;">').appendTo( $dialog );
    	
		let $pagination = $('<div class="pagination" style="margin-top:30px; width:100%; display:flex; justify-content:center;">').appendTo($dialog);
	    let dialogProperty = {
				autoOpen: true,
				title:'',
				modal: true,
				draggable: true,
				width: 400,
				highr: 200,
				buttons:dlgButtons
		};*/
		
	</script>
		
	<script>
        
        // This function finds the range of cells to merge in Excel.
        /*function search_range(arr){
        	var range = {};
            var duplicateRange = [];
            
            for(var i = 0; i < arr.length; i++) {
                if(!range[arr[i]]) {
                    range[arr[i]] = [i, i];
                } else {
                    range[arr[i]][1] = i;
                }
            }

            for(var key in range) {
                if(range[key][0] !== range[key][1]) {
                    duplicateRange.push(range[key]);
                }
            }
            return duplicateRange;
        }*/
     	
        
     // This function imports only the selected term values to Excel and downloads them to a file.
        function download_excel(){
        	
        	var bool_is_grid = false;
        	
        	// Total list variable to enter Excel and list variable to enter each line
        	var Array_row = [];
        	var arrInfo = [];
        	
        	console.log("3. Put crf information");
        	
        	// CRF information Row
        	//-------------------------------------------------------------------------------------------
        	
        	Array_row.push("<%=fin_dName[0]%>");
        	Array_Final.push(Array_row);
        	
        	//-------------------------------------------------------------------------------------------
        	console.log("3. End");
        	// Total Search Option Row
        	//-------------------------------------------------------------------------------------------
        	var Array_TotalSearch = new Array();
        	Array_row = [];
        	console.log("4. Processes and puts the selected options in the integrated search");
        	// In the case of total search, only the id that meets the search conditions is added
        	if(<%=isSearch%>){
				var arr_options = new Array();
        		
        		<% for (int i=0; i < arr_options.length; i++) { %>
        			arr_options[<%= i %>] = "<%= arr_options[i] %>";
        		<% } %>
        		
        		var final_option = "Choose Term: ";
        		for(var i = 0; i < arr_options.length; i++){
        			//console.log("options: " + arr_options[i]);
        			var extract_termName = null;
        			
        			if(arr_options[i].includes("EXACT")){
        				extract_termName = arr_options[i].split(" EXACT ");
        				final_option += inspectionData.find(v => v.termName === extract_termName[0]).displayName.en_US;
        				
        				var json_options = inspectionData.find(v => v.termName === extract_termName[0]).options;
        				final_option += " => (";
						final_option += json_options.find(v => v.value == extract_termName[1]).label.en_US;
						final_option += ")";
        			}
        			else if(arr_options[i].includes("RANGE")){
        				extract_termName = arr_options[i].split(" RANGE ");
        				final_option += inspectionData.find(v => v.termName === extract_termName[0]).displayName.en_US;
        				final_option += " => (";
						final_option += extract_termName[1];
						final_option += ")";
        			}
        			
        			if((i + 1) != arr_options.length){
        				final_option += " / ";
        			}
        		}
            	
        		Array_row.push(final_option);
            	Array_Final.push(Array_row);
        	}
        	//-------------------------------------------------------------------------------------------
			console.log("4. End");
			console.log("5. Put in the highest Term Name");
        	// Top Category Row
        	//-------------------------------------------------------------------------------------------
        	
        	// list containing the basic information column of the subject
        	var Array_Info = ["ID", "Sex", "Age", "Name"];
        	Array_row = [];
        	
        	// Gets the information of the term selected on the page
        	var CheckedList = $('input:checkbox[name="Section"]:checked');

        	for(var i = 0; i < Array_Info.length; i++){
        		Array_row.push(Array_Info[i]);
        	}
        	
        	for(var i = 0; i < CheckedList.length; i++){
        		var data_input_excel = "";
        		
        		var term_first = inspectionData.find(v => v.termName === CheckedList[i].value);
        		
        		if(inspectionData.find(v => v.termName === term_first.termName).groupTermId == undefined){
        			data_input_excel = "";
        		}else{
        			var term_second = inspectionData.find(v => v.termName === term_first.groupTermId.name);
        			
        			if(inspectionData.find(v => v.termName === term_second.termName).groupTermId == undefined){
        				data_input_excel = term_second.displayName.en_US;
            		}else{
        				var term_third = inspectionData.find(v => v.termName === term_second.groupTermId.name);
        				data_input_excel = term_third.displayName.en_US;
        			}
        		}
        		
        		var length_grid = 1;
        		
				if(term_first.termType == 'Grid'){
        			length_grid = Object.keys(term_first.columnDefs).length;
        			bool_is_grid = true;
        		}
				
				for(var j = 0; j < length_grid; j++){
					Array_row.push(data_input_excel);
				}
        	}
        	Array_Final.push(Array_row);	
        	//-------------------------------------------------------------------------------------------
        	console.log("5. End");
        	console.log("6. Put in the middle Term Name");
        	// Middle Category Row
        	//-------------------------------------------------------------------------------------------
        	Array_row = [];

        	for(var j = 0; j < Array_Info.length; j++){
        		Array_row.push("");
        	}
        	
        	for(var i = 0; i < CheckedList.length; i++){
        		var data_input_excel = "";
        		
        		var term_first = inspectionData.find(v => v.termName === CheckedList[i].value);
        		
        		if(inspectionData.find(v => v.termName === term_first.termName).groupTermId == undefined){
        			data_input_excel = "";
        		}else{
        			var term_second = inspectionData.find(v => v.termName === term_first.groupTermId.name);
        			if(inspectionData.find(v => v.termName === term_second.termName).groupTermId == undefined){
        				data_input_excel = "";
            		}else{
        				var term_third = inspectionData.find(v => v.termName === term_second.groupTermId.name);
        				data_input_excel = term_second.displayName.en_US;
        			}
        		}
        		
        		var length_grid = 1;
        		
				if(term_first.termType == 'Grid'){
        			length_grid = Object.keys(term_first.columnDefs).length;
        		}
				
				for(var j = 0; j < length_grid; j++){
					Array_row.push(data_input_excel);
				}
        	}
        	Array_Final.push(Array_row);
        	//-------------------------------------------------------------------------------------------
        	console.log("6. End");
        	console.log("7. Put in the low Term Name");
        	// Low Category Row
        	//-------------------------------------------------------------------------------------------
        	Array_row = [];

        	for(var j = 0; j < Array_Info.length; j++){
        		Array_row.push("");
        	}
        	
        	for(var i = 0; i < CheckedList.length; i++){
        		var data_input_excel = "";
        		
        		var term_first = inspectionData.find(v => v.termName === CheckedList[i].value);
        		
        		data_input_excel = term_first.displayName.en_US;
        		
        		var length_grid = 1;
        		
				if(term_first.termType == 'Grid'){
        			length_grid = Object.keys(term_first.columnDefs).length;
        		}
				
				for(var j = 0; j < length_grid; j++){
					Array_row.push(data_input_excel);
				}
        	}
        	Array_Final.push(Array_row);
        	//-------------------------------------------------------------------------------------------
        	console.log("7. End");
        	console.log("8. If Grid Term is included, add the name to the term that belongs to that term");
        	//Gird Row
        	//-------------------------------------------------------------------------------------------
        	if(bool_is_grid){
        		Array_row = [];
            	
            	for(var i = 0; i < Array_Info.length; i++){
            		Array_row.push("");
            	}
            	
            	for(var i = 0; i < CheckedList.length; i++){
    				var term_first = inspectionData.find(v => v.termName === CheckedList[i].value);

            		if(term_first.termType == 'Grid'){
            			var length_grid = Object.keys(term_first.columnDefs).length;
            			var array_grid_order = [];
            			
            			for(var j = 0; j < length_grid; j++){
            				var data_key_grid = Object.keys(term_first.columnDefs)[j];
    						var data_order_grid = JSON.stringify(term_first.columnDefs[data_key_grid].order);
    						array_grid_order[data_order_grid - 1] = term_first.columnDefs[data_key_grid];
            			}
            			
            			for(var j = 0; j < length_grid; j++){
    						Array_row.push(array_grid_order[j].displayName.en_US);
    					}
            		}else{
            			Array_row.push("");
            		}
            	}
            	Array_Final.push(Array_row);
        	}
        	console.log("8. End");
        	/* for(var i = 0; i < Array_Final.length; i++){
        		console.log(i + ": " + Array_Final[i]);
        	} */
        	console.log("9. Putting actual data in");
        	// Real Data
			//-------------------------------------------------------------------------------------------
			// Total Search
        	if(<%=isSearch%>){
        		for(var i = 0; i < answerData.length; i++){
    				Array_row = [];
    				Array_row.push(patientData[i].ID);
    				Array_row.push(patientData[i].Sex);
					Array_row.push(patientData[i].Age);
            		Array_row.push(patientData[i].Name);
            		
            		for(var j = 0; j < CheckedList.length; j++){
            			var Obj_PatientAnswer = answerData[i];
            			var Data_answer ="";
            			
            			Data_answer = getProperty(Obj_PatientAnswer, CheckedList[j].value);
            			// termType == 'Date' -> milliseconds to date
            			if(inspectionData.find(v => v.termName === CheckedList[j].value).termType == 'Date'){
            				var Data_date = new Date(Data_answer);
            				Data_date.setHours(Data_date.getHours() - 9)
            				
            				if(Data_date.toLocaleString() == 'Invalid Date'){
            					Data_answer = "";
            				}
            				else{
            					Data_answer = Data_date.toLocaleString();
            				}
            			}
            			
            			if(typeof(Data_answer) == 'object'){
            				//console.log("ob: " + JSON.stringify(Data_answer));
            				Data_answer = Data_answer.toString();
            			}
            			Array_row.push(Data_answer);
            		}
            		Array_Final.push(Array_row);
    			}
        	}
        	else{
        		console.log("9.1 Verify that Grid Term is present");
        		var isGrid = false;
        		for(var j = 0; j < CheckedList.length; j++){
        			if(inspectionData.find(v => v.termName === CheckedList[j].value).termType == 'Grid'){
        				isGrid = true;
        				break;
        			}
        		}
        		console.log("9.1 End");
        		if(isGrid){
        			
        			for(var i = 0; i < answerData.length; i++){
						// find grid's max length
        				var length_grid_max = 0;
        				
        				for(var j = 0; j < CheckedList.length; j++){
        					if(inspectionData.find(v => v.termName === CheckedList[j].value).termType == 'Grid'){
        						if(CheckedList[j].value in answerData[i]){
        							if(length_grid_max < Object.keys(answerData[i][CheckedList[j].value]).length){
            							length_grid_max = Object.keys(answerData[i][CheckedList[j].value]).length;
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
        					Array_row = [];
        					//insert info
        					Array_row.push(Obj_PatientInfo.ID);
        					Array_row.push(Obj_PatientInfo.Sex);
        					Array_row.push(Obj_PatientInfo.Age);
                    		Array_row.push(Obj_PatientInfo.Name);
                    		
                    		for(var k = 0; k < CheckedList.length; k++){
                    			var Data_answer = "";
                    			if(CheckedList[k].value in answerData[i]){
                    				Data_answer = answerData[i][CheckedList[k].value];
                    			}
                    			else{
                    				if(inspectionData.find(v => v.termName === CheckedList[k].value).termType == 'Grid'){
                    					var no_answer = Object.keys(inspectionData.find(v => v.termName === CheckedList[k].value).columnDefs).length;
                        				for(var l = 0; l < no_answer; l++){
                        					Array_row.push("");
                        				}
                    				}
                    				else{
                    					Array_row.push("");
                    				}
                    				continue;
                    			}
            					/* console.log("Data_answer:" + JSON.stringify(Data_answer)); */
            					if(j == 0){
            						if(inspectionData.find(v => v.termName === CheckedList[k].value).termType == 'Date'){
            							var Data_date = new Date(Data_answer);
                        				Data_date.setHours(Data_date.getHours() - 9)
                        				
                        				if(Data_date.toLocaleString() == 'Invalid Date'){
                        					Data_answer = "";
                        				}
                        				else{
                        					Data_answer = Data_date.toLocaleString();
                        				}
            						}
            						else if(inspectionData.find(v => v.termName === CheckedList[k].value).termType == 'Grid'){
            							var gridInfo = inspectionData.find(v => v.termName === CheckedList[k].value).columnDefs;
            							var list_key = Object.keys(gridInfo);
            							var list_order = [];
            							for(var l = 0; l < list_key.length; l++){
            								list_order[gridInfo[list_key[l]].order - 1] = gridInfo[list_key[l]].termName;
            							}
            							for(var l = 0; l < list_order.length; l++){
            								var strIndex = (j + 1).toString();
            								Array_row.push(Data_answer[strIndex][list_order[l]]);
            								//console.log("list_order: " + JSON.stringify(Data_answer[(j + 1).toString()]));
            							}
            							continue;
            							
            						}
            						
            						Array_row.push(Data_answer);
            					}
            					else{
            						if(inspectionData.find(v => v.termName === CheckedList[k].value).termType == 'Grid'){
            							var gridInfo = inspectionData.find(v => v.termName === CheckedList[k].value).columnDefs;
            							var list_key = Object.keys(gridInfo);
            							if(j < Object.keys(Data_answer).length){
            								var list_order = [];
                							for(var l = 0; l < list_key.length; l++){
                								list_order[gridInfo[list_key[l]].order - 1] = gridInfo[list_key[l]].termName;
                							}
                							for(var l = 0; l < list_order.length; l++){
                								var strIndex = (j + 1).toString();
                								Array_row.push(Data_answer[strIndex][list_order[l]]);
                								//console.log("list_order: " + list_order[l]);
                							}
            							}
            							else{
            								for(var l = 0; l < list_key.length; l++){
            									Array_row.push("");
                							}
            							}
            						}
            						else{
            							Array_row.push("");
            						}
            					}
                    		}
                    		Array_Final.push(Array_row);
                    		//console.log("Array_row: " + Array_row);
        				}
        			}
        		}
        		else{
        			console.log("9.2 If Grid Term is not available, insert data");
        			console.log("data: " + answerData.length);
        			for(var i = 0; i < answerData.length; i++){
        				Array_row = [];
        				Array_row.push(patientData[i].ID);
        				Array_row.push(patientData[i].Sex);
    					Array_row.push(patientData[i].Age);
                		Array_row.push(patientData[i].Name);
                		for(var j = 0; j < CheckedList.length; j++){
                			
                			var Obj_PatientAnswer = answerData[i];
                			var Data_answer ="";
                			
                			Data_answer = getProperty(Obj_PatientAnswer, CheckedList[j].value);
                			// termType == 'Date' -> milliseconds to date
                			if(inspectionData.find(v => v.termName === CheckedList[j].value).termType == 'Date'){
                				var Data_date = new Date(Data_answer);
                				Data_date.setHours(Data_date.getHours() - 9)
                				
                				if(Data_date.toLocaleString() == 'Invalid Date'){
                					Data_answer = "";
                				}
                				else{
                					Data_answer = Data_date.toLocaleString();
                				}
                			}
                			
                			if(typeof(Data_answer) == 'object'){
                				//console.log("ob: " + JSON.stringify(Data_answer));
                				Data_answer = Data_answer.toString();
                			}
                			Array_row.push(Data_answer);
                			
                		}
                		var jTime = new Date();
                		Array_Final.push(Array_row);
        			}
        			console.log("9.2 End");
        			
        			/*for(var i = 0; i < answerData.length; i++){
            			//console.log("sKey:" + JSON.stringify(answerData[i]));
                		Array_row = [];
                		var Obj_PatientInfo = {};
                		
                		for(var j = 0; j < patientData.length; j++){
                			if(patientData[j].ID == answerData[i].ID){
                				Obj_PatientInfo = patientData[j];
                				break;
                			}
                		}
                		
                		Array_row.push(Obj_PatientInfo.ID);
    					Array_row.push(Obj_PatientInfo.Age);
    					Array_row.push(Obj_PatientInfo.Sex);
                		Array_row.push(Obj_PatientInfo.Name);
                		console.log("Array_row: " + Array_row);
                		for(var j = 0; j < CheckedList.length; j++){
                			var Obj_PatientAnswer = answerData[i];
                			var Data_answer ="";
                			
                			Data_answer = getProperty(Obj_PatientAnswer, CheckedList[j].value);
                			// termType == 'Date' -> milliseconds to date
                			if(inspectionData.find(v => v.termName === CheckedList[j].value).termType == 'Date'){
                				var Data_date = new Date(Data_answer);
                				Data_date.setHours(Data_date.getHours() - 9)
                				
                				if(Data_date.toLocaleString() == 'Invalid Date'){
                					Data_answer = "";
                				}
                				else{
                					Data_answer = Data_date.toLocaleString();
                				}
                			}
                			
                			if(typeof(Data_answer) == 'object'){
                				//console.log("ob: " + JSON.stringify(Data_answer));
                				Data_answer = Data_answer.toString();
                			}
                			Array_row.push(Data_answer);
                		}
                		Array_Final.push(Array_row);
                	}*/
        		}
        		
        	}
        	
        	// Name each sheet, put the aoa variable in Excel, and put the aoa variable in the sheet
        	var excelHandler = {
                    getSheetName : function(){
                        return 'Sheet1';
                    },
                    getExcelData : function(){
                        return Array_Final;
                    },
                    getWorksheet : function(){
                        return XLSX.utils.aoa_to_sheet(this.getExcelData());
                    }
            }
        	
        	// Create xlsx workbook 
            var wb = XLSX.utils.book_new();
            // Create xlsx sheet 
            var newWorksheet = excelHandler.getWorksheet();
            //var newWorksheet1 = excelHandler.getWorksheet();
         	// It puts coordinates for merging the cell of the initial patient information data.
            <%-- let merge = [];
         	
            if(<%=isSearch%>){
            	for(var i = 0; i < 3; i++){
                    let test = { s: {c: i, r: 1}, e: {c: i, r: 3}};
                    merge.push(test);
                }
            	
            	for(var i = 1; i < 3; i++){
                	var same_range = search_range(Array_Final[i]);

                	for(var j = 0; j < same_range.length; j++){
                		if(i == 2 && j == 0){
                			j = 1;
                		}
                			
                		try{
                			var merge_range = { s: {c: same_range[j][0], r: i}, e: {c: same_range[j][1], r: i}};
                    		merge.push(merge_range);
                		}catch{
                			
                		}
                		
                	}
                }
            }
            else{
            	var length_info = 0;
            	if(bool_is_grid){
            		length_info = 4;
            	}else{
            		length_info = 3;
            	}

            	for(var i = 0; i < 4; i++){
                    let range_info = { s: {c: i, r: 1}, e: {c: i, r: length_info}};
                    merge.push(range_info);
                }

                for(var i = 0; i < 2; i++){
                	var same_range = search_range(Array_Final[i]);

                	for(var j = 0; j < same_range.length; j++){
                		if(i == 1 && j == 0){
                			j = 1;
                		}
                			
                		try{
                			var merge_range = { s: {c: same_range[j][0], r: i}, e: {c: same_range[j][1], r: i}};
                    		merge.push(merge_range);
                		}catch{
                			
                		}
                		
                	}
                }
            }
            
         	// If you put all the coordinate information, cell merge.
            newWorksheet["!merges"] = merge; --%>
         	
            newWorksheet.s = {
            	aligment: {
            		wrapText: true
            	}
            }
         	// Give a name to the newly created worksheet in the workbook.
            XLSX.utils.book_append_sheet(wb, newWorksheet);
            //XLSX.utils.book_append_sheet(wb, newWorksheet1);
            
            // Create xlsx File
            var wbout = XLSX.write(wb, {bookType:'xlsx',  type: 'binary'});

            // Export xlsx File
            const xlsx_name = document.getElementById('xlsx_name').value + ('.xlsx');
            saveAs(new Blob([s2ab(wbout)],{type:"application/octet-stream"}), xlsx_name);
        }
           
    </script>