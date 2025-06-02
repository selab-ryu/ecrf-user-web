<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf/dialog/manage-subject_jsp"); %>

<!-- TODO: get subject list from dialog -->
<!-- TODO: get researcher list from dialog -->
<!-- TODO: add/update/delete subjects and researchers -->

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
	
	String menu = "manage-crf-subject-add";
	
	boolean isUpdate = false;
	
	_log.info("crf id : " + crfId);
	
	long groupId = ParamUtil.getLong(renderRequest, "groupId");
		
	if(crfId > 0) {
		isUpdate = true;
		menu = "crf-update";
	}
	
	DataType dataType = null;
	
	if(isUpdate) {
		_log.info("dataType id : " + dataTypeId);					
		if(dataTypeId > 0) {
			dataType = DataTypeLocalServiceUtil.getDataType(dataTypeId);
		}
	}
	
	boolean hasViewEncryptSubjectPermission = CRFPermission.contains(permissionChecker, groupId, ECRFUserActionKeys.VIEW_ENCRYPT_SUBJECT);
	//_log.info("view enc subject : " + hasViewEncryptSubjectPermission);
%>

<div class="ecrf-user">
	
	<div class="">
		<aui:form name="updateCRFFm" action="" method="POST" autocomplete="off">
		<aui:container cssClass="radius-shadow-container">
			
			<c:if test="<%=isUpdate %>">
			<aui:row>
				<aui:col>
					<aui:input type="hidden" name="crfId" value="<%=crfId %>"></aui:input>
					<aui:input type="hidden" name="dataTypeId" value="<%= dataTypeId %>"></aui:input>
					<aui:input type="hidden" name="redirect" value="<%= redirect %>"></aui:input>
				</aui:col>
			</aui:row>
			</c:if>
			
			<aui:row>
				<aui:col md="12" cssClass="sub-title-bottom-border marBr">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf-user.crf.title.current-subject-list" />
					</span>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col>
					<table id="currentSubjectList" style="width:100%" class="table table-striped table-bordered">
						<thead>
							<tr>
								<th><input type="checkbox" name="subject_select_all"></th>
								<th>Name</th>
								<th>Serial ID</th>
								<th>Birth</th>
								<th>Gender</th>
							</tr>
						</thead>
					</table>
				</aui:col>
			</aui:row>
			
			<aui:button-row cssClass="div-center">
				<div id="<portlet:namespace/>addSubjectBtn" class="dh-icon-button submit-btn up-btn w120 h36" >
					<span><img class="up-icon marR8"/><liferay-ui:message key="ecrf-user.button.add"/></span>
				</div>
				
				<div id="<portlet:namespace/>removeSubjectBtn" class="dh-icon-button submit-btn down-btn w120 h36" >
					<span><liferay-ui:message key="ecrf-user.button.remove"/><img class="down-icon marL8"/></span>
				</div>
			</aui:button-row>
			
			<aui:row>
				<aui:col md="12" cssClass="sub-title-bottom-border marBr">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf-user.crf.title.not-included-subject-list" />
					</span>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col>
					<table id="notIncludedSubjectList" style="width:100%" class="table table-striped table-bordered">
						<thead>
							<tr>
								<th><input type="checkbox" name="subject_select_all"></th>
								<th>Name</th>
								<th>Serial ID</th>
								<th>Birth</th>
								<th>Gender</th>
							</tr>
						</thead>
					</table>
				</aui:col>
			</aui:row>
			
			<aui:button-row>
				<button id="<portlet:namespace/>saveBtn" class="dh-icon-button submit-btn save-btn w120 h36 marR8" >
					<img class="save-icon" />
					<span><liferay-ui:message key="ecrf-user.button.save"/></span>
				</button>
				<button id="<portlet:namespace/>closeDialog" class="dh-icon-button submit-btn cancel-btn w120 h36" >
					<img class="cancel-icon" />
					<span><liferay-ui:message key="ecrf-user.button.cancel"/></span>
				</button>
			</aui:button-row>
			
		</aui:container>
		</aui:form>		
	</div>
	
</div>

<script>
var rowsSelectedCurrent = [];
var rowsSelectedNotIncluded = [];

var currentSubjectTable;
var notIncludedSubjectTable;

var initCurrentSubjectArr = [];

var currentSubjectArr = [];
var notIncludedSubjectArr = [];

// parameter from update-crf.jsp
var crfSubjectInfoArr = [];

$(document).ready( function() {
	//console.group();
	
	// set init arr by Session Data	
	var getValue = sessionStorage.getItem('subjectArr');
	var parseVal = JSON.parse(decodeURIComponent(getValue)); 
    //console.log(parseVal);
    crfSubjectInfoArr = parseVal;
    tableLoading();
    
	$('#<portlet:namespace/>closeDialog').on("click", function() {
		Liferay.Util.getOpener().closePopup('manageSubjectPopup', "close", null);
	});	
});

function initTable(type) {
	if(type == 0) {
		//console.log(crfSubjectInfoArr);
				
		if(crfSubjectInfoArr.length > 0) {
			currentSubjectArr = crfSubjectInfoArr;
			initCurrentSubjectArr = crfSubjectInfoArr;
			currentSubjectTable.clear();
			currentSubjectTable.rows.add(currentSubjectArr).draw();
		}
	} else if (type == 1) {
		//console.log("group id : " + Liferay.ThemeDisplay.getScopeGroupId())
		//console.log("group id : " + <%=groupId%>)
		
		Liferay.Service(
			{
				"/ec.crf-subject/get-all-crf-subject-info-list" : {
					"groupId" : <%=groupId%>,
					"crfId" : "<%=crfId%>" 
				}
			},
			function(obj) {
				//console.log(obj.slice());
				// remove item matched current crf subject info arr
				
				for(let i=0; i<initCurrentSubjectArr.length; i++) {
					let subject = initCurrentSubjectArr[i];
					//console.log(subject);
					const itemToFind = obj.find(function(item) {return item.subjectId == subject.subjectId});
					const idx = obj.indexOf(itemToFind);
					if(idx>-1) {
						//console.log("remove idx : " + idx);
						obj.splice(idx, 1);
					}
				}				
				
				notIncludedSubjectArr = obj;
				notIncludedSubjectTable.clear();
				notIncludedSubjectTable.rows.add(notIncludedSubjectArr).draw();		
			}
		);
	}
}

function refreshTable() {
	currentSubjectTable.draw(true);
	chkAllCtrl(currentSubjectTable);
	notIncludedSubjectTable.draw(true);
	chkAllCtrl(notIncludedSubjectTable);
}

function chkAllCtrl(table) {
	var $table = table.table().node();
	var $chkbox_all = $('tbody input[type="checkbox"]', $table);
	var $chkbox_checked = $('tbody input[type="checkbox"]:checked', $table);
	var chkbox_select_all = $('thead input[name="subject_select_all"]', $table).get(0);

	// indeterminate : header checkbox
	
	// check none
	if ($chkbox_checked.length === 0) {
		chkbox_select_all.checked = false; 
		if ('indeterminate' in chkbox_select_all) {
			chkbox_select_all.indeterminate = false; 
		}

	// check all
	} else if ($chkbox_checked.length === $chkbox_all.length) {
		chkbox_select_all.checked = true;
		if ('indeterminate' in chkbox_select_all) {
			chkbox_select_all.indeterminate = false;
		}

	// check some
	} else {
		chkbox_select_all.checked = true;
		if ('indeterminate' in chkbox_select_all) {
			chkbox_select_all.indeterminate = true;
		}
	}
}

function tableLoading() {
	var hasViewEncryptSubjectPermission = <%=hasViewEncryptSubjectPermission%>;
	
	currentSubjectTable = $('#currentSubjectList').DataTable({
		dom: "<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>" +
		"<'row'<'col-sm-12'tr>>" +
		"<'row marBr'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
		data : currentSubjectArr,
		columns: [
			{data:""}, 
			{
				data:"subjectName",
				render: function(data, type, row) {
					if(!hasViewEncryptSubjectPermission)
						return encryptName(data);
					else {
						return data;
					}
				}
			},  
			{data:"serialId"}, 
			{
				data:"subjectBirth",
				render: function(data, type, row) {
					let dateStr = dateMilToFormat(data);
					return dateStr;
				}	
			}, 
			{
				data:"subjectGender",
				render: function(data, type, row) {
					let genderStr = genderToStr(data);
					return genderStr;
				}
			} 
		],
		columnDefs: [
	        {
	        	targets: 0,
	        	searchable: false,
	            orderable: false,
	            width: "1%",
	            className: 'dt-body-center',
	            render: function(data, type, full, meta) {
	            	return '<input type="checkbox" name="subject_select">';
	            }
	        }
	    ],
	    order: [[1, 'asc']],
	    rowCallback: function(row, data, dataIndex) {
	    	let rowId = data.serialId;
	    	
	    	//console.log("row selected current : " + rowsSelectedCurrent);
			if ($.inArray(rowId, rowsSelectedCurrent) !== -1) {
				$(row).find('input[type="checkbox"]').prop('checked', true);
				$(row).addClass('selected');
			}
	    }
	});
	
 	notIncludedSubjectTable = $('#notIncludedSubjectList').DataTable({
		dom: "<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>" +
		"<'row'<'col-sm-12'tr>>" +
		"<'row marBr'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
		data : notIncludedSubjectArr,
		columns: [
			{data:""}, 
			{
				data:"subjectName",
				render: function(data, type, row) {
					if(!hasViewEncryptSubjectPermission)
						return encryptName(data);
					else {
						return data;
					}
				}
			},  
			{data:"serialId"}, 
			{
				data:"subjectBirth",
				render: function(data, type, row) {
					let dateStr = dateMilToFormat(data);
					return dateStr;
				}	
			}, 
			{
				data:"subjectGender",
				render: function(data, type, row) {
					let genderStr = genderToStr(data);
					return genderStr;
				}
			} 
		],
		columnDefs: [
	        {
	        	targets: 0,
	        	searchable: false,
	            orderable: false,
	            width: "1%",
	            className: 'dt-body-center',
	            render: function(data, type, full, meta) {
	            	return '<input type="checkbox" name="subject_select">';
	            }
	        }
	    ],
	    order: [[1, 'asc']],
	    rowCallback: function(row, data, dataIndex) {
	    	let rowId = data.serialId;
	    	
	    	//console.log("row selected not included : " + rowsSelectedNotIncluded);
			if ($.inArray(rowId, rowsSelectedNotIncluded) !== -1) {
				$(row).find('input[type="checkbox"]').prop('checked', true);
				$(row).addClass('selected');
			}
	    }
	});
	
 	initTable(0); // current subject
 	initTable(1); // not included subject
 	
 	setCheckboxEvent();
	setMiddleButtonEvent();
	setSaveButtonEvent();
}

function setSaveButtonEvent() {
	$('#<portlet:namespace/>saveBtn').on("click", function(e) { 
		// if current subject arr is shrinked, alert ablut crf data remove
		
		// update crf-subject link by current subject arr
		// loop get subject from current subject arr
			// make json data that send with api request
			// crfId & subjectId
	
		//console.log("save button clicked");
		
		// check subject list changed
		// check subject is removed from upper list
		
		
		Liferay.Util.getOpener().closePopup('manageSubjectPopup', "save", currentSubjectArr);
				
	});
}

function setMiddleButtonEvent() {
	$('#<portlet:namespace/>addSubjectBtn').on("click", function(e) {
		// not include to current
		// loop get select rows from not includedrow selected arr of not included
			// get row from not included table that serialId matched
			// add to current table row, remove from not included table row
			// add to current arr, remove from not included arr
		// initialize row selected arr of not inlcuded
		// refresh table (current, not included)
		//console.group();	
		
		for(var i=0; i<rowsSelectedNotIncluded.length; i++) {
			var serialId = rowsSelectedNotIncluded[i];
			//console.log(serialId);
			
			let matchedRow = notIncludedSubjectTable.row((idx, data) => data.serialId === serialId);
			let rowData = matchedRow.data(); 
			//console.log(rowData);
			
			currentSubjectTable.row.add(rowData);
			matchedRow.remove();
				
			currentSubjectArr.push(rowData)
			let removeIdx = notIncludedSubjectArr.indexOf(rowData);
			//console.log(removeIdx);
			notIncludedSubjectArr.splice(removeIdx, 1);
		}
		
		//console.groupEnd();
		
		rowsSelectedNotIncluded = [];
		
		refreshTable();
	});
	
	$('#<portlet:namespace/>removeSubjectBtn').on("click", function(e) {
		// alert that if remove subject from crf, crf data will be removed (only alert)
		
		// current to not included
		// loop get select rows from row selected arr of current
			// get row from current table that serialId matched
			// add to not included table row, remove from current table row
			// add to not included arr, remove from current arr
		// initialize row selected arr of current
		// refresh table (current, not included)
		//console.group();
		
		for(var i=0; i<rowsSelectedCurrent.length; i++) {
			var serialId = rowsSelectedCurrent[i];
			//console.log(serialId);
			
			let matchedRow = currentSubjectTable.row((idx, data) => data.serialId === serialId);
			let rowData = matchedRow.data(); 
			//console.log(rowData);
			
			notIncludedSubjectTable.row.add(rowData);
			matchedRow.remove();
			
			notIncludedSubjectArr.push(rowData)
			let removeIdx = currentSubjectArr.indexOf(rowData);
			//console.log(removeIdx);
			currentSubjectArr.splice(removeIdx, 1);
		}
		
		//console.groupEnd();
		
		rowsSelectedCurrent = [];
		
		refreshTable();
	});
}

function setCheckboxEvent() {
	$('#notIncludedSubjectList tbody, #currentSubjectList tbody').on('change', 'input[name="subject_select"]',
		function(e) {	
			let $elem = $(this);
			
			let $table = $elem.closest('table');
			
			let selectedTable = notIncludedSubjectTable;
			let selectedRowArr = rowsSelectedNotIncluded;
			
			// set data by selected row's table
			if($table.attr('id') == 'currentSubjectList') {
				selectedTable = currentSubjectTable;
				selectedRowArr = rowsSelectedCurrent;
			}
			
			let $row = $elem.closest('tr');
			let data = selectedTable.row($row).data();
			let rowId = data.serialId;
			
			let index = $.inArray(rowId, selectedRowArr); 
			
			if (this.checked && index === -1) {
				selectedRowArr.push(rowId);		
			} else if (!this.checked && index !== -1) {
				selectedRowArr.splice(index, 1);
			}
			
			if (this.checked) {
				$row.addClass('selected');
			} else {
				$row.removeClass('selected');
			}
			
			// uncomment after add checkbox(all) 
			chkAllCtrl(selectedTable); 
			
			e.stopPropagation();
		}
	);
	
	$('thead input[name="subject_select_all"]').on('click', 
		function(e) {
			let $elem = $(this);
			let $table = $elem.closest('table');	
			
			let targetTable = null;
			
			if ($table.attr('id') == 'notIncludedSubjectList') {
				targetTable = notIncludedSubjectTable;
			} else if ($table.attr('id') == 'currentSubjectList') {
				targetTable = currentSubjectTable;
			} else {
				return;
			}
		
			if (this.checked) {
				$('tbody input[type="checkbox"]:not(:checked)', targetTable.table().container()).trigger('click');						
			} else {
				$('tbody input[type="checkbox"]:checked', targetTable.table().container()).trigger('click');
				$("tbody input[type='checkbox']", targetTable.table().container()).closest('tr').removeClass('selected');
			}
			e.stopPropagation();
			
			targetTable.on(
				'draw', 
				function() {
					chkAllCtrl(targetTable);
				}
			)
		}
	);
}
</script>