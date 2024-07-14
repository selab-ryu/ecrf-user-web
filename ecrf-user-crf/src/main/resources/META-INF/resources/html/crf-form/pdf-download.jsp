<%@ include file="../init.jsp" %>
<%! Log _log = LogFactoryUtil.getLog("html.crf_form.pdf_download.jsp"); %>
<%
	String menu = "crf-pdf";

    String json = DataTypeLocalServiceUtil.getDataTypeStructure(dataTypeId);
    
    //_log.info(json);
    
    boolean hasDownloadPermisson = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DOWNLOAD_PDF);
%>

<div class="ecrf-user-crf-data ecrf-user">

	<%@ include file="sidebar.jspf" %>
	
	<div class="page-content">
	
		<liferay-ui:header backURL="<%=redirect %>" title='ecrf-user.crf-form.title.pdf-download' />
		<aui:container cssClass="radius-shadow-container">
			<div id ="pdfCanvas">
			</div>
					
			<aui:button type="button" class="add-btn medium-btn radius-btn" id="savePdfBtn" value="ecrf-user.button.download" disabled="<%=hasDownloadPermisson ? false : true %>"></aui:button>
        </aui:container>
	</div>
</div>

<script>
    $(document).ready(function(){
    	// change json parsing code
        let crfForm = JSON.parse(JSON.stringify(<%=json%>));
        let crfFormArr = crfForm.terms;
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
        
        $("#pdfCanvas").empty();
        //Front page
        createPDFFrontPage();
        //main page
        if(mainGroupKeys.length > 0 && subGroupKeys.length < 1){
            createPDF_hierarachy_1(mainGroupKeys, sectionKeys);
        }else if(mainGroupKeys.length > 0){
            createPDF_hierarachy_2(mainGroupKeys, subGroupKeys, sectionKeys);
        }else{
            createGroupHeader("No Group");
            createPDF_hierarachy_0(sectionKeys);
        }
    });
    
	function createPDFFrontPage(){
		
	}
    function createPDF_hierarachy_0(sectionKeys){
    	const sectionDiv = document.createElement("div");
        for(var idx = 0; idx < sectionKeys.length; idx++){
            const sectionP = document.createElement("p");
            const sectionNode = document.createTextNode((idx+1) + "." + sectionKeys[idx].displayName.en_US);
            sectionP.appendChild(sectionNode);
            sectionP.setAttribute("style","display: inline-block");
            sectionDiv.appendChild(sectionP);
            var type = sectionKeys[idx].termType;
            const inputTag = createInputTag(type, sectionKeys[idx].termName, sectionKeys[idx].options);
            sectionDiv.appendChild(inputTag);
    		const addLine = document.createElement("br");
			sectionDiv.appendChild(addLine);
        }
        const divider = document.createElement("hr");
        $("#pdfCanvas").append(sectionDiv);
        $("#pdfCanvas").append(divider);
    }

    function createInputTag(type, id, options){
    	if(type === "List" || type === "Boolean"){
    		const checkbox = document.createElement("div");
            for(var idx = 0; idx < options.length; idx++){
            	const sectionInput = document.createElement("input");
                sectionInput.setAttribute("type", "checkbox");
                sectionInput.setAttribute("id", id);
                sectionInput.setAttribute("value", options[idx].value);
                const checkLabel = document.createElement("label");
                checkLabel.setAttribute("for", id);
                const inputNode = document.createTextNode(options[idx].label.en_US);
                checkLabel.appendChild(inputNode);
                checkbox.appendChild(sectionInput);
                checkbox.appendChild(checkLabel);
            }
            return checkbox;
    	}else{
    		const sectionInput = document.createElement("input");
            sectionInput.setAttribute("type", "text");
            sectionInput.setAttribute("id", id);
            sectionInput.setAttribute("style", "margin-left: 10px");
            return sectionInput;

    	}
    }
    function createPDF_hierarachy_1(mainGroupKeys, sectionKeys){
    	for(var mainIdx = 0; mainIdx < mainGroupKeys.length; mainIdx++){
    		createGroupHeader(mainGroupKeys[mainIdx].displayName.en_US);
    		const sectionDiv = document.createElement("div");
        	var groupNo = 1;
            for(var sectionIdx = 0; sectionIdx < sectionKeys.length; sectionIdx++){
            	if(sectionKeys[sectionIdx].hasOwnProperty("groupTermId")){
            		if(mainGroupKeys[mainIdx].termName === sectionKeys[sectionIdx].groupTermId.name){
		                const sectionP = document.createElement("p");
		                const sectionNode = document.createTextNode(groupNo + "." + sectionKeys[sectionIdx].displayName.en_US);
		                sectionP.appendChild(sectionNode);
		                sectionP.setAttribute("style","display: inline-block");
		                sectionDiv.appendChild(sectionP);
		                var type = sectionKeys[sectionIdx].termType;
		                const inputTag = createInputTag(type, sectionKeys[sectionIdx].termName, sectionKeys[sectionIdx].options);
		                sectionDiv.appendChild(inputTag);
		        		const addLine = document.createElement("br");
		    			sectionDiv.appendChild(addLine);
		    			groupNo++;
	    			}
            	}
            }
            const divider = document.createElement("hr");
            $("#pdfCanvas").append(sectionDiv);
            $("#pdfCanvas").append(divider);
    	}
        createGroupHeader("No Group");
        const sectionDiv = document.createElement("div");
    	var noGroupNo = 1;
        for(var noGroupIdx = 0; noGroupIdx < sectionKeys.length; noGroupIdx++){
        	if(!sectionKeys[noGroupIdx].hasOwnProperty("groupTermId")){
	            const sectionP = document.createElement("p");
	            const sectionNode = document.createTextNode(noGroupNo + "." + sectionKeys[noGroupIdx].displayName.en_US);
	            sectionP.appendChild(sectionNode);
	            sectionP.setAttribute("style","display: inline-block");
	            sectionDiv.appendChild(sectionP);
	            var type = sectionKeys[noGroupIdx].termType;
	            const inputTag = createInputTag(type, sectionKeys[noGroupIdx].termName, sectionKeys[noGroupIdx].options);
	            sectionDiv.appendChild(inputTag);
	    		const addLine = document.createElement("br");
				sectionDiv.appendChild(addLine);
				noGroupNo++;
        	}
        }
        const divider = document.createElement("hr");
        $("#pdfCanvas").append(sectionDiv);
        $("#pdfCanvas").append(divider);

    }

    function createPDF_hierarachy_2(mainGroupKeys, subGroupKeys, sectionKeys){
    	for(var mainIdx = 0; mainIdx < mainGroupKeys.length; mainIdx++){
    		createGroupHeader(mainGroupKeys[mainIdx].displayName.en_US);
        	var subGroupCount = 0;
    		for(var subIdx = 0; subIdx < subGroupKeys.length; subIdx++){
    			if(subGroupKeys[subIdx].hasOwnProperty("groupTermId")){
    				if(subGroupKeys[subIdx].groupTermId.name === mainGroupKeys[mainIdx].termName){
    					createSubGroupHeader(subGroupKeys[subIdx].displayName.en_US);
    		            const sectionDiv = document.createElement("div");
    					var groupNo = 1;
    	    			for(var sectionIdx = 0; sectionIdx < sectionKeys.length; sectionIdx++){
    	    				if(sectionKeys[sectionIdx].hasOwnProperty("groupTermId")){
    	                		if(sectionKeys[sectionIdx].groupTermId.name === subGroupKeys[subIdx].termName){
    	    		                const sectionP = document.createElement("p");
    	    		                const sectionNode = document.createTextNode(groupNo + "." + sectionKeys[sectionIdx].displayName.en_US);
    	    		                sectionP.appendChild(sectionNode);
    	    		                sectionP.setAttribute("style","display: inline-block");
    	    		                sectionDiv.appendChild(sectionP);
    	    		                var type = sectionKeys[sectionIdx].termType;
    	    		                const inputTag = createInputTag(type, sectionKeys[sectionIdx].termName, sectionKeys[sectionIdx].options);
    	    		                sectionDiv.appendChild(inputTag);
    	    		        		const addLine = document.createElement("br");
    	    		    			sectionDiv.appendChild(addLine);
    	    		    			groupNo++;
    	    	    			}
    	                	}
    	    			}
    	        		$("#pdfCanvas").append(sectionDiv);
    	        		const divider = document.createElement("hr");
    	                $("#pdfCanvas").append(divider);
    	    			subGroupCount++;
    	    		}
    			}
    		}
    	    if(subGroupCount == 0){
				createSubGroupHeader(mainGroupKeys[mainIdx].displayName.en_US);
				var groupNo = 1;
	            const sectionDiv = document.createElement("div");
				for(var sectionIdx = 0; sectionIdx < sectionKeys.length; sectionIdx++){
	   				if(sectionKeys[sectionIdx].hasOwnProperty("groupTermId")){
	               		if(sectionKeys[sectionIdx].groupTermId.name === mainGroupKeys[mainIdx].termName){
	   		                const sectionP = document.createElement("p");
	   		                const sectionNode = document.createTextNode(groupNo + "." + sectionKeys[sectionIdx].displayName.en_US);
	   		                sectionP.appendChild(sectionNode);
	   		                sectionP.setAttribute("style","display: inline-block");
	   		                sectionDiv.appendChild(sectionP);
	   		                var type = sectionKeys[sectionIdx].termType;
	   		                const inputTag = createInputTag(type, sectionKeys[sectionIdx].termName, sectionKeys[sectionIdx].options);
	   		                sectionDiv.appendChild(inputTag);
	   		        		const addLine = document.createElement("br");
	   		    			sectionDiv.appendChild(addLine);
	   		    			groupNo++;
	   	    			}
	               	}
	   			}
				$("#pdfCanvas").append(sectionDiv);
        		const divider = document.createElement("hr");
                $("#pdfCanvas").append(divider);
    	    }
    	}
    	createGroupHeader("No Group");
        const sectionDiv = document.createElement("div");
    	var noGroupNo = 1;
        for(var noGroupIdx = 0; noGroupIdx < sectionKeys.length; noGroupIdx++){
        	if(!sectionKeys[noGroupIdx].hasOwnProperty("groupTermId")){
	            const sectionP = document.createElement("p");
	            const sectionNode = document.createTextNode(noGroupNo + "." + sectionKeys[noGroupIdx].displayName.en_US);
	            sectionP.appendChild(sectionNode);
	            sectionP.setAttribute("style","display: inline-block");
	            sectionDiv.appendChild(sectionP);
	            var type = sectionKeys[noGroupIdx].termType;
	            const inputTag = createInputTag(type, sectionKeys[noGroupIdx].termName, sectionKeys[noGroupIdx].options);
	            sectionDiv.appendChild(inputTag);
	    		const addLine = document.createElement("br");
				sectionDiv.appendChild(addLine);
				noGroupNo++;
        	}
        }
		$("#pdfCanvas").append(sectionDiv);
        const divider = document.createElement("hr");
        $("#pdfCanvas").append(divider);
    }
    
    function createGroupHeader(groupName){
    	const groupH = document.createElement("h3");
        const groupNode = document.createTextNode(groupName);
    	groupH.appendChild(groupNode);
        $("#pdfCanvas").append(groupH);
    }
    
    function createSubGroupHeader(groupName){
    	const groupH = document.createElement("h4");
        const groupNode = document.createTextNode(groupName);
    	groupH.appendChild(groupNode);
        $("#pdfCanvas").append(groupH);
    }
</script>

<script>

$('#savePdfBtn').click(function() {
    const{jsPDF} = window.jspdf;

    html2canvas($('#pdfCanvas')[0]).then(function (canvas) { 
		var filename = 'OTA-REPORT_' + Date.now() + '.pdf';
		let margin = 10; 
		var doc = new jsPDF('p', 'mm', 'a4'); 
		var imgData = canvas.toDataURL('image/png');
		var imgWidth = 210 - (10 * 2);
		var pageHeight = imgWidth * 1.414;
		var imgHeight = canvas.height * imgWidth / canvas.width;
		var heightLeft = imgHeight;
		var position = margin;
		doc.addImage(imgData, 'PNG', margin, position, imgWidth, imgHeight); 
		heightLeft -= pageHeight;
	          let test = 20;
		while (heightLeft >= 0) {
			position = heightLeft - imgHeight - test;
			doc.addPage();
			doc.addImage(imgData, 'PNG', margin, position, imgWidth, imgHeight);
            position = heightLeft - imgHeight - test;
            heightLeft -= pageHeight;
	              
		}
		doc.save(filename); 
	});
});

</script>
