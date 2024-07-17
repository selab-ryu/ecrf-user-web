<%@page import="com.liferay.portal.kernel.portlet.LiferayPortletURL"%>
<%@page import="ecrf.user.service.CRFSearchLogLocalServiceUtil"%>
<%@ include file="../../init.jsp" %>

<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.14.3/xlsx.full.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/1.3.8/FileSaver.min.js"></script>

<%! Log _log = LogFactoryUtil.getLog("html.crf-data.other.excel-download.jsp"); %>

<%
	String menu = "crf-data-excel";

	String subjectJson = (String)renderRequest.getAttribute("subjectJson");
	String answerJson = (String)renderRequest.getAttribute("answerJson");
	String json = (String)renderRequest.getAttribute("json");
	String options = (String)renderRequest.getAttribute("options");
	boolean isSearch = false;
	String[] arr_options = null;
	arr_options = options.split(",");
	_log.info(arr_options.length);
	if(options == "noSearch"){
		isSearch = false;
		
		arr_options[0] = "";
		//_log.info(arr_options.length);
	}
	else{
		isSearch = true;
		arr_options = options.split(",");
		_log.info("search");
	}
	
	
	
	List<String> searchSIds = new ArrayList();
	List<String> searchTermName = new ArrayList();
	List<String> searchNum = new ArrayList();
	
	Long dtypeId = CRFLocalServiceUtil.getCRF(crfId).getDatatypeId();
	DataType dataType = DataTypeLocalServiceUtil.getDataType(dtypeId);
	String dType = dataType.getDisplayName();
	String[] dName = dType.split(">");
	String[] fin_dName = dName[3].split("<");
	
	boolean isEmpty = false;
	
	
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
        display:inline;
        color:green;
      }
     
	.marL100 { margin-left: 100px; }
	.marL150 { margin-left: 150px; }
	.padL114 { margin-left: 114px; }
	.padL214 { margin-left: 214px; }
	.padL264 { margin-left: 264px; }
	.padL478 { margin-left: 478px; }
	
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
</style>

<div class="ecrf-user-crf-data ecrf-user">

	<%@ include file="sidebar.jspf" %>
	
	<div class="page-content">
	
		<liferay-ui:header backURL="<%=redirect %>" title='ecrf-user.crf-data.title.excel-download' />
		
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
			<div id="Search_Page"></div>
		    	<span id="searchText"></span>
			</div>
		</div>
	</div>
</div>

	<script>
        // Returns a Object of Sub category belonging to a Big category
        function Upfnc(Big_Category, Sub_Category){

            var ResultObject = {};

            // List Sub category with Big category as keys
            for(var i = 0; i < Big_Category.length; i++){
                var Sub_CategoryList = [];
                var Big_CategoryName = Big_Category[i].termName;

                for(var j = 0; j < Sub_Category.length; j++){

                    if(Big_Category[i].termName == Sub_Category[j].groupTermId.name){
                        Sub_CategoryList.push(Sub_Category[j].termName);
                    }
                }
                ResultObject[Big_CategoryName] = Sub_CategoryList;
            }
            return ResultObject;
        }

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
        	/* 
            let thisCheck = $("input[id = " + id + "]")[0].checked;
            let thisTermName = $("input[id = " + id + "]")[0].value;
            let childCheckbox = "";
            let checkValue = true;

            //Depth is 2 or division
            if(thisTermName == 'co_profile' || thisTermName == 'abnormal_react' || id.includes('B')){
                childCheckbox = $("input[id = " + id + "]").parent().children('div[id = Sub_Category]').children('input');
                
            }

            //In case of large categories
            else{
                childCheckbox = $("input[id = " + id + "]").parent().children('div[id = Main_Category]').children('input');
            }

            //Assign a variable value to check all subcategories when checking
            if(thisCheck){
                checkValue = true;
            }
            else{
                checkValue = false;
            }

            for(var i = 0; i < childCheckbox.length; i++){
                childCheckbox[i].checked = checkValue;
                
                //If the depth is 3, check the subclassification of the subclassification.
                allcheck(childCheckbox[i].id);
            } */

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
            
		function renderGraph(elem){
			console.log("function activate");
	        let inspectionData = JSON.parse(JSON.stringify(<%=json%>)).terms;
	        //console.log("inspectionData: " + inspectionData);
			var termLabel = $(elem);
			var termName = termLabel.attr("name");			
			var type = "";
			var displayName = "";
						
			for(var i = 0; i < inspectionData.length; i++){
				if(inspectionData[i].termName === termName){
					if(inspectionData[i].termType === "List"){
						type = "List";
						displayName = inspectionData[i].displayName.en_US;
					}
					else if(inspectionData[i].termType === "Numeric"){
						type = "Numeric";
						displayName = inspectionData[i].displayName.en_US;
					}
				}
			}
			
			// TODO : if there is not exist data, then dont call popup function
			if(type === "List" || type === "Numeric")
				createGraphPopupRenderURL("<%=themeDisplay.getPortletDisplay().getId() %>", termName, displayName, type, <%=crfId%>, "<%=ECRFUserMVCCommand.RENDER_DIALOG_CRF_DATA_GRAPH %>", "<%=baseURL.toString()%>");
		}
		
		function sort_list(obj){
			var list_ordered = [];
	        for(var i = 0; i < obj.length; i++){
	        	list_ordered[obj[i].order - 1] = obj[i];
	        }
	        return list_ordered;
		}
		
		function EntireCheck(id){
            let Big_Checkbox = $("input[id = " + id + "]").parent().children().children('input');
            for(var i = 0; i < Big_Checkbox.length; i++){
            	Big_Checkbox[i].checked = $("input[id = " + id + "]")[0].checked;
            	allcheck(Big_Checkbox[i].id);
            }
            console.log(Big_Checkbox);
        }
    </script>

    <script>
    
    var ContentText = "";
    var inspectionData = "";
    
    AUI().ready(function() {
    	setUI();
    	
		document.getElementById("searchText").innerHTML = ContentText;
    	
    	for(var i = 0; i < inspectionData.length; i++){
    		//console.log(inspectionData[i].termName);
    		if(inspectionData[i].termType === "List"){
    			var temp = document.getElementsByName(inspectionData[i].termName);
    			temp[0].setAttribute("style", "color: red!important;");
			}
    		else if(inspectionData[i].termType === "Numeric"){
    			var temp = document.getElementsByName(inspectionData[i].termName);
    			temp[0].setAttribute("style", "color: blue!important;");
			}
    	}
    	
    	var hw = document.getElementById('btn_1');
	    hw.addEventListener('click', download_excel);
    });
    
 	// Insert the UI to be printed so far into the text.
   	$(document).ready(function(){
    	
   	}); 
    
   	function setUI() { 
        // Emergency Inspection Term Lsit Json to Object array
        inspectionData = JSON.parse(JSON.stringify(<%=json%>)).terms;
		//console.log("inspectionData: " + inspectionData);
        // Text in Html

        ContentText = "";
        ContentText += '<input type = "checkbox" id = "EntireCheck" onClick = "EntireCheck(this.id)"/>';
        ContentText += '<label class="w200" for ="EntireCheck">AllCheck</label>';
        ContentText += '<hr style="border: solid 1px #787878">';
        var category_first = [];
        
       
        var list_no_group = [];

        for(var i = 0; i < inspectionData.length; i++){
            if(inspectionData[i].termType == 'Group'){
            	if(!('groupTermId' in inspectionData[i])){
            		category_first.push(inspectionData[i]);
            	}
            }
            
            else if(inspectionData[i].termType != 'Group'){
                if(!('groupTermId' in inspectionData[i])){
                	category_first.push(inspectionData[i]);
                	list_no_group.push(inspectionData[i]);
                }
            }
        }

        category_first = sort_list(category_first);
        
        //console.log("category_first: " + JSON.stringify(category_first));
        //console.log("category_second: " + JSON.stringify(category_second));
        //console.log("category_third: " + JSON.stringify(category_third));
        //console.log("list_no_group: " + JSON.stringify(list_no_group));
        //console.log("list_no_group: " + category_first.includes(list_no_group));
        
     	// Index to attach Each Category element id
        var indexA = 0;
        var indexB = 0;
        var indexC = 0;
        
        for(var i = 0; i < category_first.length; i++){
        	//console.log("category_first: " + JSON.stringify(category_first[i]));
        	if(list_no_group.includes(category_first[i])){
        		ContentText += '<div id = "Sub_Category">';
                ContentText += '<input type = "checkbox" id = "C_' + indexC + '" value = "' + category_first[i].termName + '"name = "Section" onClick = "isAll(this.id)"/>'
                ContentText += '<label class="w200" for ="C_' + indexC + '" name = "' + category_first[i].termName + '">' + category_first[i].displayName.en_US + '</label>';
                indexC++;
                ContentText += '</div>';
                ContentText += '<hr style="border: solid 1px #787878">';
                //ContentText += '<label style="margin-right: 10px;" name="' + Sub_Category.find(e => e.termName === List_Depth2_Sub_category[j]).termName + '" onClick="renderGraph(this);" for ="C_' + indexC + '">' + Sub_Category.find(e => e.termName === List_Depth2_Sub_category[j]).displayName.en_US + '</label>';
                
        	}
        	else{
        		// First, Print Big Category
                ContentText += '<div id = "Big_Category">';
                ContentText += '<input type = "checkbox" id = "A_' + indexA + '" value = "' + category_first[i].termName + '" onClick = "allcheck(this.id)"/>';
                ContentText += '<label class="w200" for ="A_' + indexA + '">' + category_first[i].displayName.en_US + '</label>';
                indexA++;
                
                var category_second = [];
                
                for(var j = 0; j < inspectionData.length; j++){
                	if('groupTermId' in inspectionData[j]
                			&& inspectionData[j].groupTermId.name == category_first[i].termName){
                		category_second.push(inspectionData[j]);
                	}
                }
                
                category_second = sort_list(category_second);
                
                var isGroup = false;
                
                if(category_second.find(e => e.termType == 'Group') != undefined){
                	isGroup = true;
                }
                //console.log("category_second: " + JSON.stringify(category_second));
                /* console.log("category_second: " + JSON.stringify(category_second));
                console.log(category_second.find(e => e.termType == 'Group')); */
                var Flag_Sub_category = true;
                var Flag_Main_category = true;
                var Index_Sub_category = 0;
                for(var j = 0; j < category_second.length; j++){
                	if(isGroup){
                		var mainCateClass = "";
                        // First Printed Main Category needs this space 
                        if(Flag_Main_category){
                            Flag_Main_category = false;
                        }
                        // other Main Category needs this space
                        else{
                        	mainCateClass = "padL214";
                            //ContentText += "&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&nbsp;";
                        }

                        
                        if(category_second[j].termType != 'Group'){
                        	ContentText += '<div id = "Sub_Category" class="' + mainCateClass + '">';
                            ContentText += '<input type = "checkbox" id = "C_' + indexC + '" value = "' + category_second[j].termName + '" onClick = "isAll(this.id);"/>'
                            ContentText += '<label class="w250" for ="C_' + indexC + '" name = "' + category_second[j].termName + '">' +category_second[j].displayName.en_US + '</label>';
                        	ContentText += '</div>';
                        	ContentText += '<br>';
                        	indexC++;
                        }
                        else{
                        	ContentText += '<div id = "Main_Category" class="' + mainCateClass + '">';
                            ContentText += '<input type = "checkbox" id = "B_' + indexB + '" value = "' + category_second[j].termName + '" onClick = "allcheck(this.id); isAll(this.id);"/>'
                            ContentText += '<label class="w250" for ="B_' + indexB + '">' + category_second[j].displayName.en_US + '</label>';
                            indexB++;
                            
                            var category_third = [];
                            
                            for(var k = 0; k < inspectionData.length; k++){
                            	if('groupTermId' in inspectionData[k]
                            			&& inspectionData[k].groupTermId.name == category_second[j].termName){
                            		category_third.push(inspectionData[k]);
                            	}
                            }
                            
                            category_third = sort_list(category_third);
                            //console.log("category_third: " + JSON.stringify(category_third))
                            var Index_Sub_category_1 = 0;
                            var Flag_Sub_category_1 = true;
                            for(var k = 0; k < category_third.length; k++){
                            	var subCateClass = "";
                                // New line if 4 sections are printed per line
                                if(Index_Sub_category_1 == 2){
                                    ContentText += '<br>';
                                    subCateClass = "padL478";
                                    Index_Sub_category_1 = 0;
                                }

                                if(Flag_Sub_category){
                                	Flag_Sub_category_1 =false;
                                }
                                //console.log("category_third: " + JSON.stringify(category_third[k]))
                                //console.log("category_third: " + JSON.stringify(category_third[k].termName))
                                ContentText += '<div id = "Sub_Category" class="' + subCateClass + '">';
                                ContentText += '<input type = "checkbox" id = "C_' + indexC + '" value = "' + category_third[k].termName + '"name = "Section" onClick = "isAll(this.id); "/>'
                                ContentText += '<label style="margin-right: 10px;" name="'+ category_third[k].termName + '" onClick="renderGraph(this);" for ="C_' + indexC + '">' + category_third[k].displayName.en_US + '</label>';
                                indexC++;
                                Index_Sub_category_1++;
                                ContentText += '</div>';
                            }
                            ContentText += '<br>';
                            ContentText += '</div>';
                        }
                        
                	}
                	else{
                		var subCateClass = "";
                        // New line if 4 sections are printed per line
                        if(Index_Sub_category == 2){
                            ContentText += '<br>';
                            subCateClass = "padL478";
                            //ContentText += '&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&nbsp;';
                            Index_Sub_category = 0;
                        }

                        if(Flag_Sub_category){
                        	subCateClass = "padL264";
                            //ContentText += '&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;';
                            Flag_Sub_category = false;
                        }

                        ContentText += '<div id = "Sub_Category"  class="' + subCateClass + '" >';
                        ContentText += '<input type = "checkbox" id = "C_' + indexC + '" value = "' + category_second[j].termName + '"name = "Section" onClick = "isAll(this.id)"/>'
                        ContentText += '<label style="margin-right: 10px;" name="' + category_second[j].termName + '" onClick="renderGraph(this);" for ="C_' + indexC + '">' + category_second[j].displayName.en_US + '</label>';
                        indexC++;
                        Index_Sub_category++;
                        ContentText += '</div>';
                	}
                } 
                
                ContentText += '</div>';
                ContentText += '<hr style="border: solid 1px #787878">';
        	}
        } 

        // move to html tag
        // xlsx Name Input Window
        ContentText += '<input id="xlsx_name" placeholder="FileName">.xlsx &nbsp</input>';
        // xlsx Output Button
        ContentText += '<button id="btn_1" <%=hasDownloadExcelPermission ? "" : "disabled"%> >Export xlsx</button>';
		
  	}
        
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
        // Get answer data and patient information data.
        var answerData = JSON.parse(JSON.stringify(<%=answerJson%>));
        var patientData = JSON.parse(JSON.stringify(<%=subjectJson%>));         
        
        for(var i = 0; i < patientData.length; i++){
        	console.log("I: " + JSON.stringify(patientData[i]));
        }
        
        // This function finds the range of cells to merge in Excel.
        function search_range(arr){
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
        }
        
     	// Encoding operation
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
        
     // This function imports only the selected term values to Excel and downloads them to a file.
        function download_excel(){
        	
        	var bool_is_grid = false;
        	
        	// Total list variable to enter Excel and list variable to enter each line
        	var Array_row = [];
        	var Array_Final = [];
        	
        	// CRF information Row
        	//-------------------------------------------------------------------------------------------
        	
        	Array_row.push("<%=fin_dName[0]%>");
        	Array_Final.push(Array_row);
        	
        	//-------------------------------------------------------------------------------------------
        	
        	// Total Search Option Row
        	//-------------------------------------------------------------------------------------------
        	var Array_TotalSearch = new Array();
        	Array_row = [];
        	
        	// In the case of total search, only the id that meets the search conditions is added
        	if(<%=isSearch%>){
        		<%-- <% for (int i=0; i < searchSIds.size(); i++) { %>
        		Array_TotalSearch[<%= i %>] = "<%= searchSIds.get(i) %>";
        		<% } %>
        		
        		// Add the termName selected in the total search.
            	var str_totalExcel = "Search Sequence: ";

            	<% for (int i=0; i < searchNum.size(); i++) { %>
            	if(<%= i %> != 0){
            	str_totalExcel += ", ";
            	}
            	str_totalExcel += inspectionData.find(v => v.termName === "<%= searchTermName.get(i) %>").displayName.en_US;
            	str_totalExcel += "(";
            	str_totalExcel += <%= searchNum.get(i) %>;
            	str_totalExcel += ")";
            	<% } %> --%>
            	
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
        	
        	/* for(var i = 0; i < Array_Final.length; i++){
        		console.log(i + ": " + Array_Final[i]);
        	} */
        	// Real Data
			//-------------------------------------------------------------------------------------------
			// Total Search
        	if(<%=isSearch%>){
        		for(var i = 0; i < answerData.length; i++){
    				Array_row = [];
    				Array_row.push(patientData[i].ID);
					Array_row.push(patientData[i].Age);
					Array_row.push(patientData[i].Sex);
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
        		var isGrid = false;
        		for(var j = 0; j < CheckedList.length; j++){
        			if(inspectionData.find(v => v.termName === CheckedList[j].value).termType == 'Grid'){
        				isGrid = true;
        				break;
        			}
        		}
        		
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
        			for(var i = 0; i < answerData.length; i++){
        				Array_row = [];
        				Array_row.push(patientData[i].ID);
    					Array_row.push(patientData[i].Age);
    					Array_row.push(patientData[i].Sex);
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