<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf/dialog/manage-researcher_jsp"); %>

<!-- TODO: get researcher list from dialog -->
<!-- TODO: add/update/delete researchers -->

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
	
	String menu = "manage-crf-researcher-add";
	
	boolean isUpdate = false;
	
	_log.info("crf id : " + crfId);
	
	long groupId = ParamUtil.getLong(renderRequest, "groupId");
	
	String crfResearcherInfoJsonStr = ParamUtil.getString(renderRequest, "crfResearcherInfoJsonStr");
	_log.info("json str : " + crfResearcherInfoJsonStr);
	
	if(crfId > 0) {
		isUpdate = true;
		menu = "crf-update";
	}	 
	
	DataType dataType = null;
	
	if(isUpdate) {
		long paramDataTypeId = ParamUtil.getLong(renderRequest, ECRFUserCRFAttributes.DATATYPE_ID, 0);
		
		if(paramDataTypeId != dataTypeId) {
			_log.info("parameter datatype id is difference from crf datatype id");
		} else {
			_log.info("dataType id : " + dataTypeId);					
			if(dataTypeId > 0) {
				dataType = DataTypeLocalServiceUtil.getDataType(dataTypeId);
			}
		}
	}
%>

<div class="ecrf-user">
	
	<div class="">
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
						<liferay-ui:message key="ecrf-user.crf.title.current-researcher-list" />
					</span>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col>
					<table id="currentList" style="width:100%" class="table table-striped table-bordered">
						<thead>
							<tr>
								<th><input type="checkbox" name="select_all"></th>
								<th>Name</th>
								<th>Birth</th>
								<th>Gender</th>
								<th>Position</th>
								<th>Institution</th>
							</tr>
						</thead>
					</table>
				</aui:col>
			</aui:row>
			
			<aui:button-row cssClass="div-center">
				<aui:button name="addBtn" value="ecrf-user.button.add" icon="icon-arrow-up" iconAlign="left" ></aui:button>
				<aui:button name="removeBtn" value="ecrf-user.button.remove" icon="icon-arrow-down" iconAlign="right" ></aui:button>
			</aui:button-row>
			
			<aui:row>
				<aui:col md="12" cssClass="sub-title-bottom-border marBr">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf-user.crf.title.not-included-researcher-list" />
					</span>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col>
					<table id="notIncludedList" style="width:100%" class="table table-striped table-bordered">
						<thead>
							<tr>
								<th><input type="checkbox" name="select_all"></th>
								<th>Name</th>
								<th>Birth</th>
								<th>Gender</th>
								<th>Position</th>
								<th>Institution</th>
							</tr>
						</thead>
					</table>
				</aui:col>
			</aui:row>
			
			<aui:button-row>
				<aui:button type="button" name="saveBtn" value="ecrf-user.button.save" />
				<aui:button type="buutton" name="closeDialog" value="ecrf-user.button.cancel" />
			</aui:button-row>
			
		</aui:container>	
	</div>
	
</div>

<script>
var rowsSelectedCurrent = [];
var rowsSelectedNotIncluded = [];

var currentTable;
var notIncludedTable;

var initCurrentArr = [];

var currentArr = [];
var notIncludedArr = [];

// parameter from update-crf.jsp
var crfResearcherInfoArr = [];

function initTable(type) {
	if(type == 0) {
		console.log(crfResearcherInfoArr);
		
		if(crfResearcherInfoArr.length > 0) {
			currentArr = crfResearcherInfoArr;
			initCurrentArr = crfResearcherInfoArr;
			currentTable.clear();
			currentTable.rows.add(currentArr).draw();
		}
	} else if (type == 1) {
		Liferay.Service(
			{
				"/ec.crf-researcher/get-all-crf-researcher-info" : {
					"groupId" : <%=groupId%>,
					"crfId" : "<%=crfId%>" 
				}
			},
			function(obj) {
				console.log(obj);
				// remove item matched current crf researcher info arr
				
				for(let i=0; i<initCurrentArr.length; i++) {
					let item = initCurrentArr[i];
					const itemToFind = obj.find(function(item) {return item.researcherId == item.researcherId});
					const idx = obj.indexOf(itemToFind);
					if(idx>-1) obj.splice(idx, 1);
				}
				
				notIncludedArr = obj;
				notIncludedTable.clear();
				notIncludedTable.rows.add(notIncludedArr).draw();		
			}
		);
	}
}

function refreshTable() {
	currentTable.draw(true);
	chkAllCtrl(currentTable);
	notIncludedTable.draw(true);
	chkAllCtrl(notIncludedTable);
}

function chkAllCtrl(table) {
	var $table = table.table().node();
	var $chkbox_all = $('tbody input[type="checkbox"]', $table);
	var $chkbox_checked = $('tbody input[type="checkbox"]:checked', $table);
	var chkbox_select_all = $('thead input[name="select_all"]', $table).get(0);

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

$(document).ready( function() {
	console.group("manage researcher popup");
		
	// parameter from jsp is object, not string
	let jsonStr = <%=crfResearcherInfoJsonStr%>;
	try {
		// set info arr by parent's arr
		crfResearcherInfoArr = JSON.parse(JSON.stringify(jsonStr));
	} catch(e) {
		console.log("json is empty")
	}
	
	tableLoading();
	
	$('#<portlet:namespace/>closeDialog').on("click", function() {
		Liferay.Util.getOpener().closePopup('manageResearcherPopup', "close", null);
	});	
});

function tableLoading() {
	console.group("table loading");
	
	currentTable = $('#currentList').DataTable({
		dom: "<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>" +
		"<'row'<'col-sm-12'tr>>" +
		"<'row marBr'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
		data : currentArr,
		columns: [
			{data:""}, 
			{data:"name"},  
			{
				data:"birth",
				render: function(data, type, row) {
					let dateStr = dateMilToFormat(data);
					return dateStr;
				}
			},
			{
				data:"gender",
				render: function(data, type, row) {
					let genderStr = genderToStr(data);
					return genderStr;
				}
			},
			{data:"position"},
			{data:"institution"}
		],
		columnDefs: [
	        {
	        	targets: 0,
	        	searchable: false,
	            orderable: false,
	            width: "1%",
	            className: 'dt-body-center',
	            render: function(data, type, full, meta) {
	            	return '<input type="checkbox" name="row_select">';
	            }
	        }
	    ],
	    order: [[1, 'asc']],
	    rowCallback: function(row, data, dataIndex) {
	    	let rowId = data.researcherId;
	    	
	    	//console.log("row selected current : " + rowsSelectedCurrent);
			if ($.inArray(rowId, rowsSelectedCurrent) !== -1) {
				$(row).find('input[type="checkbox"]').prop('checked', true);
				$(row).addClass('selected');
			}
	    }
	});
	
 	notIncludedTable = $('#notIncludedList').DataTable({
		dom: "<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>" +
		"<'row'<'col-sm-12'tr>>" +
		"<'row marBr'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
		data : notIncludedArr,
		columns: [
			{data:""}, 
			{data:"name"},  
			{
				data:"birth",
				render: function(data, type, row) {
					let dateStr = dateMilToFormat(data);
					return dateStr;
				}	
			},
			{
				data:"gender",
				render: function(data, type, row) {
					let genderStr = genderToStr(data);
					return genderStr;
				}
			},
			{data:"position"},
			{data:"institution"}
		],
		columnDefs: [
	        {
	        	targets: 0,
	        	searchable: false,
	            orderable: false,
	            width: "1%",
	            className: 'dt-body-center',
	            render: function(data, type, full, meta) {
	            	return '<input type="checkbox" name="row_select">';
	            }
	        }
	    ],
	    order: [[1, 'asc']],
	    rowCallback: function(row, data, dataIndex) {
	    	let rowId = data.researcherId;
	    	
	    	//console.log("row selected not included : " + rowsSelectedNotIncluded);
			if ($.inArray(rowId, rowsSelectedNotIncluded) !== -1) {
				$(row).find('input[type="checkbox"]').prop('checked', true);
				$(row).addClass('selected');
			}
	    }
	});
	
 	initTable(0); // current researcher
 	initTable(1); // not included researcher
 	
 	setCheckboxEvent();
	setMiddleButtonEvent();
	setSaveButtonEvent();
	
	console.groupEnd();
}

function setSaveButtonEvent() {
	$('#<portlet:namespace/>saveBtn').on("click", function(e) { 
		// TODO: if current researcher arr is shrinked, alert about crf data remove
		// send current crf-researcher arr to parent page (using parent function)
			// send with popup id
			
		Liferay.Util.getOpener().closePopup("manageResearcherPopup", "save", currentArr);
				
	});
}

function setMiddleButtonEvent() {
	$('#<portlet:namespace/>addBtn').on("click", function(e) {
		// not include to current
		// loop get select rows from not includedrow selected arr of not included
			// get row from not included table that serialId matched
			// add to current table row, remove from not included table row
			// add to current arr, remove from not included arr
		// initialize row selected arr of not inlcuded
		// refresh table (current, not included)
		console.group();
		
		for(var i=0; i<rowsSelectedNotIncluded.length; i++) {
			var researcherId = rowsSelectedNotIncluded[i];
			//console.log(researcherId);
			
			let matchedRow = notIncludedTable.row((idx, data) => data.researcherId === researcherId);
			let rowData = matchedRow.data(); 
			//console.log(rowData);
			
			currentTable.row.add(rowData);
			matchedRow.remove();
				
			currentArr.push(rowData)
			let removeIdx = notIncludedArr.indexOf(rowData);
			//console.log(removeIdx);
			notIncludedArr.splice(removeIdx, 1);
		}
		
		console.groupEnd();
		
		rowsSelectedNotIncluded = [];
		
		refreshTable();
	});
	
	$('#<portlet:namespace/>removeBtn').on("click", function(e) {
		// alert that if remove researcher from crf, crf data will be removed (only alert)
		
		// current to not included
		// loop get select rows from row selected arr of current
			// get row from current table that serialId matched
			// add to not included table row, remove from current table row
			// add to not included arr, remove from current arr
		// initialize row selected arr of current
		// refresh table (current, not included)
		console.group();
		
		for(var i=0; i<rowsSelectedCurrent.length; i++) {
			var researcherId = rowsSelectedCurrent[i];
			//console.log(researcherId);
			
			let matchedRow = currentTable.row((idx, data) => data.researcherId === researcherId);
			let rowData = matchedRow.data(); 
			console.log(rowData);
			
			notIncludedTable.row.add(rowData);
			matchedRow.remove();
			
			notIncludedArr.push(rowData)
			let removeIdx = currentArr.indexOf(rowData);
			console.log(removeIdx);
			currentArr.splice(removeIdx, 1);
		}
		
		console.groupEnd();
		
		rowsSelectedCurrent = [];
		
		refreshTable();
	});
}

function setCheckboxEvent() {
	$('#notIncludedList tbody, #currentList tbody').on('change', 'input[name="row_select"]',
		function(e) {	
			let $elem = $(this);
			
			let $table = $elem.closest('table');
			
			let selectedTable = notIncludedTable;
			let selectedRowArr = rowsSelectedNotIncluded;
			
			// set data by selected row's table
			if($table.attr('id') == 'currentList') {
				selectedTable = currentTable;
				selectedRowArr = rowsSelectedCurrent;
			}
			
			let $row = $elem.closest('tr');
			let data = selectedTable.row($row).data();
			let rowId = data.researcherId;
			
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
	
	$('thead input[name="select_all"]').on('click', 
		function(e) {
			let $elem = $(this);
			let $table = $elem.closest('table');	
			
			let targetTable = null;
			
			if ($table.attr('id') == 'notIncludedList') {
				targetTable = notIncludedTable;
			} else if ($table.attr('id') == 'currentList') {
				targetTable = currentTable;
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

<aui:script>

</aui:script>