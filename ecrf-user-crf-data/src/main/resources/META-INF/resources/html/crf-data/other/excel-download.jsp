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
	long searchLogId = ParamUtil.getLong(renderRequest, "searchLogId", 0);
	
	String excelPackage = "";
	if(searchLogId > 0){
		_log.info("search log id : " + searchLogId);
		excelPackage = CRFSearchLogLocalServiceUtil.getCRFSearchLog(searchLogId).getSearchLog();
		_log.info("excel package : " + excelPackage);
	}
	
	List<String> searchSIds = new ArrayList();
	List<String> searchTermName = new ArrayList();
	List<String> searchNum = new ArrayList();
	
	boolean isSearch = false;
	boolean isEmpty = false;
	
	if(excelPackage.length() > 0){
		isSearch = true;
	}
	
	if(isSearch){
		JSONArray jArray_ep = JSONFactoryUtil.createJSONArray(excelPackage);
		
		for(int i = 0; i < jArray_ep.length(); i++){
			String str_ep = jArray_ep.get(i).toString();
			JSONObject jObject_ep = JSONFactoryUtil.createJSONObject(str_ep);
			JSONArray jArray_ep_final = (JSONArray) jObject_ep.get("results");
			searchNum.add(Integer.toString(jArray_ep_final.length()));
		}
		
		String str_ep = jArray_ep.get(jArray_ep.length() - 1).toString();
		JSONObject jObject_ep = JSONFactoryUtil.createJSONObject(str_ep);
		JSONArray jArray_ep_final = (JSONArray) jObject_ep.get("results");
		
		for(int i = 0; i < jArray_ep_final.length(); i++){
			long IdSd = Long.parseLong(jArray_ep_final.get(i).toString());
			long IdLinkCrf = LinkCRFLocalServiceUtil.getLinkCRFBySdId(IdSd).getSubjectId();
			String Idsubject = SubjectLocalServiceUtil.getSubject(IdLinkCrf).getSerialId();
			searchSIds.add(Idsubject);	
		}
		
		for(int i = 0; i < jArray_ep.length(); i++){
			str_ep = jArray_ep.get(i).toString();
			jObject_ep = JSONFactoryUtil.createJSONObject(str_ep);
			String str_ep_final = jObject_ep.get("fieldName").toString();
			searchTermName.add(str_ep_final);
		}
	}
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

</style>

<div class="ecrf-user-crf-data ecrf-user">

	<%@ include file="sidebar.jspf" %>
	
	<div class="page-content">
	
		<liferay-ui:header backURL="<%=redirect %>" title='ecrf-user.crf-data.title.excel-download' />
		
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
            
		function renderGraph(elem){
			console.log("function activate");
	        let graphData = JSON.parse(JSON.stringify(<%=json%>)).terms;
	        //console.log("inspectionData: " + inspectionData);
			var termLabel = $(elem);
			var termName = termLabel.attr("name");
			var renderURL = Liferay.PortletURL.createRenderURL();
			var isList = false;
			for(var i = 0; i < graphData.length; i++){
				if(graphData[i].termName === termName){
					if(graphData[i].termType === "List"){
						isList = true;
					}
				}
			}
			if(isList){
				renderURL.setPortletId("<%=themeDisplay.getPortletDisplay().getId() %>");
				renderURL.setPortletMode("edit");
			    renderURL.setWindowState("pop_up");
				renderURL.setParameter("termName", termName);
				renderURL.setParameter("crfId", <%=crfId%>);
				renderURL.setParameter("mvcRenderCommandName", "<%=ECRFUserMVCCommand.RENDER_DIALOG_CRF_DATA_GRAPH %>");
				
				Liferay.Util.openWindow(
						{
							dialog: {
								cache: false,
								destroyOnClose: true,
								centered: true,
								modal: true,
								resizable: false,
								height: 600,
								width: 1200
							},
							title: 'Graph',
							uri: renderURL.toString()
						}
				);
			}
		}
    </script>

    <script>
        // Emergency Inspection Term Lsit Json to Object array
        var ContentText = "";
        var inspectionData = JSON.parse(JSON.stringify(<%=json%>)).terms;
      
		    //console.log("inspectionData: " + inspectionData);
        // Text in Html
        
        // Survey object data to Each List
        let Big_Category = [];
        let Main_Category = [];
        let Sub_Category = [];
        let Sub_Category_only = [];

        // Move each List
        for(var i = 0; i < inspectionData.length; i++){
            if(inspectionData[i].termType == 'Group'){
                if('groupTermId' in inspectionData[i]){
                    Main_Category.push(inspectionData[i]);
                }
                else{
                    Big_Category.push(inspectionData[i]);
                }
            }
            
            else if(inspectionData[i].termType != 'Group'){
                if('groupTermId' in inspectionData[i]){
                    Sub_Category.push(inspectionData[i]);
                }
                else{
                    Sub_Category_only.push(inspectionData[i]);
                }
            }
        }

        // Index to attach Each Category element id
        let indexA = 0;
        let indexB = 0;
        let indexC = 0;

        // Index to new Line Sub Category
        let Index_Sub_category = 0;

        // Print Each Category
        for(var i = 0; i < Big_Category.length; i++){
            // First, Print Big Category
            ContentText += '<div id = "Big_Category">';
            ContentText += '<input type = "checkbox" id = "A_' + indexA + '" value = "' + Big_Category[i].termName + '" onClick = "allcheck(this.id)"/>';
            ContentText += '<label class="w200" for ="A_' + indexA + '">' + Big_Category[i].displayName.en_US + '</label>';
            indexA++;
            
            //After return Object, present Big Category Name is Key!
            var List_Depth2_Sub_category = Upfnc(Big_Category, Sub_Category)[Big_Category[i].termName];

            // Variables that count how many sections a line has
            Index_Sub_category = 0;

            // Variables for Design
            let Flag_Sub_category = true;

            // Print Sub Category but It hasn't Main Category
            for(var j = 0; j < List_Depth2_Sub_category.length; j++){
				var subCateClass = "";
                // New line if 4 sections are printed per line
                if(Index_Sub_category == 4){
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
                ContentText += '<input type = "checkbox" id = "C_' + indexC + '" value = "' + List_Depth2_Sub_category[j] + '"name = "Section" onClick = "isAll(this.id)"/>'
                ContentText += '<label style="margin-right: 10px;" name="' + Sub_Category.find(e => e.termName === List_Depth2_Sub_category[j]).termName + '" onClick="renderGraph(this);" for ="C_' + indexC + '">' + Sub_Category.find(e => e.termName === List_Depth2_Sub_category[j]).displayName.en_US + '</label>';
                indexC++;
                Index_Sub_category++;
                ContentText += '</div>';
            }
            
            // Variables for Design
            let Flag_Main_category = true;

            //After return Object, present Big Category Name is Key!
            var List_Main_category = Upfnc(Big_Category, Main_Category)[Big_Category[i].termName];

            // Print Main Category
            for(var j = 0; j < List_Main_category.length; j++){
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

                ContentText += '<div id = "Main_Category" class="' + mainCateClass + '">';
                ContentText += '<input type = "checkbox" id = "B_' + indexB + '" value = "' + List_Main_category[j] + '" onClick = "allcheck(this.id); isAll(this.id);"/>'
                ContentText += '<label class="w250" for ="B_' + indexB + '">' + Main_Category.find(e => e.termName === List_Main_category[j]).displayName.en_US + '</label>';
                indexB++;
                
                //Variables that count how many sections a line has
                Index_Sub_category = 0;

                // Variables for Design
                Flag_Sub_category = true;

                List_Sub_category = Upfnc(Main_Category, Sub_Category)[List_Main_category[j]];
                
                // Print Sub Category
                for(var k = 0; k < List_Sub_category.length; k++){
                	var subCateClass = "";
                    // New line if 4 sections are printed per line
                    if(Index_Sub_category == 4){
                        ContentText += '<br>';
                        subCateClass = "padL478";
                        Index_Sub_category = 0;
                    }

                    if(Flag_Sub_category){
                        Flag_Sub_category =false;
                    }

                    ContentText += '<div id = "Sub_Category" class="' + subCateClass + '">';
                    ContentText += '<input type = "checkbox" id = "C_' + indexC + '" value = "' + List_Sub_category[k] + '"name = "Section" onClick = "isAll(this.id); "/>'
                    ContentText += '<label style="margin-right: 10px;" name="'+ Sub_Category.find(e => e.termName === List_Sub_category[k]).termName + '" onClick="renderGraph(this);" for ="C_' + indexC + '">' + Sub_Category.find(e => e.termName === List_Sub_category[k]).displayName.en_US + '</label>';
                    indexC++;
                    Index_Sub_category++;
                    ContentText += '</div>';
                }
                ContentText += '<br>';
                ContentText += '</div>';
            }
            ContentText += '</div>';
            ContentText += '<hr style="border: solid 1px #787878">';
        }

        Index_Sub_category = 0;
        Flag_Sub_category = true;

        // Print Sub Category but It hasn't No group(Big, Main)
        for(var i = 0; i < Sub_Category_only.length; i++){

            if(Flag_Sub_category){
                //ContentText += '&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&nbsp;&nbsp;';
                Flag_Sub_category =false;
            }

            // New line if 4 sections are printed per line
            if(Index_Sub_category == 4){
                //ContentText += '<br>';
                //ContentText += '&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&nbsp;&nbsp;';
                Index_Sub_category = 0;
            }

            ContentText += '<div id = "Sub_Category">';
            ContentText += '<input type = "checkbox" id = "C_' + indexC + '" value = "' + Sub_Category_only[i].termName + '"name = "Section" onClick = "isAll(this.id)"/>'
            ContentText += '<label onClick="renderGraph(this); " name="' + Sub_Category_only[i].termName + '" for ="C_' + indexC + '">' + Sub_Category_only[i].displayName.en_US + '</label>';
            indexC++;
            Index_Sub_category++;
            ContentText += '</div>';
        }
        ContentText += '<br>';

        // xlsx Name Input Window
        ContentText += '<input id = "xlsx_name" placeholder = "FileName">.xlsx &nbsp</input>';

        // xlsx Output Button
        ContentText += '<button id = "btn_1">Export xlsx</button>';
		
        // Insert the UI to be printed so far into the text.
       	$(document).ready(function(){
        	document.getElementById("searchText").innerHTML = ContentText;
        	for(var i = 0; i < inspectionData.length; i++){
        		if(inspectionData[i].termType === "List"){
        			var temp = document.getElementsByName(inspectionData[i].termName);
        			temp[0].setAttribute("style", "color: red!important;");
				}
        	}
        	
        	var hw = document.getElementById('btn_1');
		    hw.addEventListener('click', download_excel);
       	});
	    
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
        // Get answer data and patient information data.
        let answerData = JSON.parse(JSON.stringify(<%=answerJson%>));
        let patientData = JSON.parse(JSON.stringify(<%=subjectJson%>));         
        
        // This function finds the range of cells to merge in Excel.
        function search_range(arr){
        	let range = {};
            let duplicateRange = [];
            
            for(let i = 0; i < arr.length; i++) {
                if(!range[arr[i]]) {
                    range[arr[i]] = [i, i];
                } else {
                    range[arr[i]][1] = i;
                }
            }

            for(let key in range) {
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
			  let result = object[property]
			  return result
		}
        
     // This function imports only the selected term values to Excel and downloads them to a file.
        function download_excel(){
        	
        	var excelData;
        	var Array_TotalSearch = new Array();
        	
        	// Total list variable to enter Excel and list variable to enter each line
        	var Array_Final = [];
        	var Array_row = [];
        	
        	// Check visit date
        	var isCheckedVisit = false;
        	
        	// In the case of total search, only the id that meets the search conditions is added
        	if(<%=isSearch%>){
        		excelData = JSON.parse(JSON.stringify(<%=excelPackage%>));
        		<% for (int i=0; i < searchSIds.size(); i++) { %>
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
            	<% } %>
            	
            	Array_row.push(str_totalExcel);
            	Array_Final.push(Array_row);
        	}

        	// list containing the basic information column of the subject
        	var Array_Info = ["Subject No."/*, "Visit Date"*/, "Hospital Code", "Name", "Birth", "Gender",
        		"Cohort study", "MRI study", "CRF", "Query", "contact_1",
        		"contact_2"];

        	// Gets the information of the term selected on the page
        	var CheckedList = $('input:checkbox[name="Section"]:checked');
        	
        	for(var i = 0; i < CheckedList.length; i++){
        		if(CheckedList[i].value == 'visit_date'){
        			isCheckedVisit = true;
        			break;
        		}
        	}
        	//First Row
        	//-------------------------------------------------------------------------------------------
        	Array_row = [];
        	for(var j = 0; j < Array_Info.length; j++){
        		Array_row.push(Array_Info[j]);
        	}
        	for(var j = 0; j < CheckedList.length; j++){
    			if(CheckedList[j].value == 'visit_date'){
    				Array_row.push("");
    				continue;
    			}
    			else{
    				var Term_Low = {};
            		
            		for(var i = 0; i < inspectionData.length; i++){
            			if(inspectionData[i].termName == CheckedList[j].value){
            				Term_Low = inspectionData[i];
            				break;
            			}
            		}
            		var Term_Middle = {};
            		
            		for(var i = 0; i < inspectionData.length; i++){
            			if(inspectionData[i].termName == Term_Low.groupTermId.name){
            				Term_Middle = inspectionData[i];
            				break;
            			}
            		}

            		var Term_top = {};

            		var First_flag = false;
            		try{
            			for(var i = 0; i < inspectionData.length; i++){
            				if(inspectionData[i].termName == Term_Middle.groupTermId.name){
            					Term_top = inspectionData[i];
            					First_flag = true;
            					break;
            				}
            			}
            		}catch(e){
            			Term_top = Term_Middle;
            		}
            		
            		if(First_flag == false){
            			Term_top = Term_Middle;
            		}
            		
            		Array_row.push(Term_top.displayName.en_US);
    			}
        	}
        	
        	Array_Final.push(Array_row);
        	//-------------------------------------------------------------------------------------------

        	
        	//Second Row
        	//-------------------------------------------------------------------------------------------
        	Array_row = [];

        	for(var j = 0; j < Array_Info.length; j++){
        		Array_row.push("");
        	}
        	for(var j = 0; j < CheckedList.length; j++){
    			if(CheckedList[j].value == 'visit_date'){
    				Array_row.push("");
    				continue;
    			}
    			else{
    				var Term_Low = {};
            		
            		for(var i = 0; i < inspectionData.length; i++){
            			if(inspectionData[i].termName == CheckedList[j].value){
            				Term_Low = inspectionData[i];
            				break;
            			}
            		}

            		var Term_Middle = {};
            		
            		for(var i = 0; i < inspectionData.length; i++){
            			if(inspectionData[i].termName == Term_Low.groupTermId.name){
            				Term_Middle = inspectionData[i];
            				break
            			}
            		}
            		
            		var Term_top = {};

            		var Second_flag = false;
            		
            		try{
            			for(var i = 0; i < inspectionData.length; i++){
            				if(inspectionData[i].termName == Term_Middle.groupTermId.name){
            					Term_top = inspectionData[i];
            					Array_row.push(Term_Middle.displayName.en_US);
            					Second_flag = true;
            					break;
            				}
            			}
            		}catch(e){
            			Term_top = Term_Middle;
            			Array_row.push("");
            		}

    			}
        		
        	}
        	
        	Array_Final.push(Array_row);
        	
        	//-------------------------------------------------------------------------------------------
        	//Third Row
        	//-------------------------------------------------------------------------------------------
        	Array_row = [];

        	for(var j = 0; j < Array_Info.length; j++){
        		Array_row.push("");
        	}

        	for(var j = 0; j < CheckedList.length; j++){
        		var Term_Low = {};
        		
        		if(CheckedList[j].value == 'visit_date'){
    				Array_row.push("visit_date");
    				continue;
    			}
        		else{
        			for(var i = 0; i < inspectionData.length; i++){
            			if(inspectionData[i].termName == CheckedList[j].value){
            				Term_Low = inspectionData[i];
            				break;
            			}
            		}
        			
        			Array_row.push(Term_Low.displayName.en_US);
        		}
        		
        	}
        	
        	Array_Final.push(Array_row);
        	//-------------------------------------------------------------------------------------------
        	/*for(var i = 0 ; i < Array_Final.length; i++){
        		for(var j = 0; j < Array_Final[i].length; j++){
        			console.log("Array_Final: " + Array_Final[i][j]);
        		}
        		
        	}*/
        	// Real Data
			//-------------------------------------------------------------------------------------------
			// Total Search
        	if(<%=isSearch%>){
        		for(var i = 0; i < Array_TotalSearch.length; i++){
            		Array_row = [];
            		var Obj_PatientInfo = {};
            		
            		for(var j = 0; j < patientData.length; j++){
            			if(patientData[j].ID == Array_TotalSearch[i]){
            				Obj_PatientInfo = patientData[j];
            				break;
            			}
            		}
            		
            		Array_row.push(Obj_PatientInfo.ID);
            		
            		//Array_row.push(Obj_PatientInfo.Visit_date);
            		Array_row.push("");
            		Array_row.push(Obj_PatientInfo.Name);
            		Array_row.push(Obj_PatientInfo.Age);
            		Array_row.push(Obj_PatientInfo.Sex);
            		Array_row.push("");
            		Array_row.push("");
            		Array_row.push("");
            		Array_row.push("");
            		Array_row.push("");
            		Array_row.push("");
					
            		for(var j = 0; j < CheckedList.length; j++){
            			var Obj_PatientAnswer = {};
			
            			for(var k = 0; k < answerData.length; k++){
            				if(answerData[k].ID == Array_TotalSearch[i]){
            					Obj_PatientAnswer = answerData[k];
            					break;
            				}
            			}
						
            			var Data_answer ="";
            			Data_answer = getProperty(Obj_PatientAnswer, CheckedList[j].value);

            			// termType == 'Date' -> milliseconds to date
                        if(inspectionData.find(v => v.termName === CheckedList[j].value).termType == 'Date'){
                            console.log("Data_answer: " + Data_answer);
                            var Data_date = new Date(Data_answer);
                            console.log("Data_date: " + Data_date);
                            Data_date.setHours(Data_date.getHours() - 9)
                            
                            if(Data_date.toLocaleString() == 'Invalid Date'){
                            	Data_answer = Data_date.toLocaleString();
                            }
                         }
                         
                         if(typeof(Data_answer) == 'object'){
                            Data_answer = Data_answer.toString();
                         }
                         console.log("Data_answer: " + Data_answer);
                         Array_row.push(Data_answer);
            		}
            	}
        	}
        	else{
        		for(var i = 0; i < answerData.length; i++){
            		Array_row = [];
            		var Obj_PatientInfo = {};
            		
            		for(var j = 0; j < patientData.length; j++){
            			if(patientData[j].ID == answerData[i].ID){
            				Obj_PatientInfo = patientData[j];
            				break;
            			}
            		}
            		
            		Array_row.push(Obj_PatientInfo.ID);
            		//Array_row.push(Obj_PatientInfo.Visit_date);
            		Array_row.push("");
            		Array_row.push(Obj_PatientInfo.Name);
            		Array_row.push(Obj_PatientInfo.Age);
            		Array_row.push(Obj_PatientInfo.Sex);
            		Array_row.push("");
            		Array_row.push("");
            		Array_row.push("");
            		Array_row.push("");
            		Array_row.push("");
            		Array_row.push("");
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
            				Data_answer = Data_answer.toString();
            			}
            			Array_row.push(Data_answer);
            		}
            		Array_Final.push(Array_row);
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
            
         	// It puts coordinates for merging the cell of the initial patient information data.
            let merge = [];
         	
            if(<%=isSearch%>){
            	for(var i = 0; i < 11; i++){
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
            	for(var i = 0; i < 11; i++){
                    let test = { s: {c: i, r: 0}, e: {c: i, r: 2}};
                    merge.push(test);
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
            newWorksheet["!merges"] = merge;
         	// Give a name to the newly created worksheet in the workbook.
            XLSX.utils.book_append_sheet(wb, newWorksheet);
            
            // Create xlsx File
            var wbout = XLSX.write(wb, {bookType:'xlsx',  type: 'binary'});

            // Export xlsx File
            const xlsx_name = document.getElementById('xlsx_name').value + ('.xlsx');
            saveAs(new Blob([s2ab(wbout)],{type:"application/octet-stream"}), xlsx_name);
        }
           
    </script>