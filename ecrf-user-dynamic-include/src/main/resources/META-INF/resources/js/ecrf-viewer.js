let ECRFViewer = function(){
	class Viewer{

		constructor(DataStructure, align, structuredData, subjectBirth){
			var result = new Object();
			renderUtil.align = align;
			autoCalUtil.crf = DataStructure;
			console.log("sd data", structuredData);
			autoCalUtil.age = autoCalUtil.calculateAge(subjectBirth);
			if(structuredData){
				renderUtil.structuredData = structuredData;
				result = structuredData;
			}
			$(document).ready(function(){
				let dataPacket = new EventDataPacket();
				dataPacket.result = result;
				const eventData = {
					dataPacket: dataPacket
				};
				Liferay.fire( 'value_changed', eventData );	
			});
				
            DataStructure.renderSmartCRF = function(){
                console.log("is for render smartCRF");
                if( $.isEmptyObject( this.terms ) ){
                    return;
                }
                this.$canvas.empty();
                this.$canvas.html(renderUtil.renderCanvas(this.terms));
                
                this.terms.forEach(term=>{
					if( term.termType === 'List' || term.termType === 'boolean' ){
						if( term.hasSlaves() ){
							renderUtil.activateTerms(term);
						}
					}
					if(autoCalUtil.checkExcerciseFlag(term.termName)){
						$("#" + term.termName + "_outerDiv").hide();
					}
				});
            };
            
            Liferay.on('value_changed', function(event){
            	if(event.dataPacket.term){
            		let eventTerm = event.dataPacket.term;
            		console.log(eventTerm.value);
            		if(eventTerm.termType === "List"){
            			renderUtil.activateTerms(eventTerm);
            		}
            		result[eventTerm.termName.toString()] = eventTerm.value;
            		let autoTerm = autoCalUtil.checkAutoCal(eventTerm);
            		event.dataPacket.result = result;
            	}
            });
        }
	};
	
	let autoCalUtil = {
		calculateAge: function (birthDate) {
			var birthYear = birthDate.getFullYear();
			var birthMonth = birthDate.getMonth();
			var birthDay = birthDate.getDate();
			
			var currentDate = new Date();
			var currentYear = currentDate.getFullYear();
			var currentMonth = currentDate.getMonth();
			var currentDay = currentDate.getDate();
			
			var age = currentYear - birthYear;
			
			if (currentMonth < birthMonth) {
			  age--;
			}
			
			else if (currentMonth === birthMonth && currentDay < birthDay) {
			  age--;
			}
			
			return age;
		},
		
		checkExcerciseFlag : function(termName){
			switch(termName){
			case "diabetes":
			case "is_low_risk":
			case "is_mid_risk":
			case "is_high_risk":
				return true;
				break;
			case "par_q_under65":
				if(this.age < 65){
					return false;
				}else {
					return true;
				}
				break;
			case "par_q_over65":
				if(this.age > 65){
					return false;
				}else {
					return true;
				}
			default:
				return false;
				break;
			}
			
		},
		
		checkAutoCal : function(term){
			if(this.crf){				
				switch(this.crf.dataTypeName){
					case "er_crf":
						console.log("ER CRF Auto Calculation Running");
						console.log(term.termName);
						console.log(term.value);
						if(term.termName === "conciousness") {
							this.crf.terms.forEach(compareTerm=>{
								if(compareTerm.termName === "gcs"){
									console.log("find", compareTerm.value);
									let selectedValue = term.value[0];
									switch(selectedValue) {
									case '0':
										compareTerm.value = 15;
										console.log(compareTerm.value);
										break;
									case '1':
										compareTerm.value = 12;
										break;
									case '2':
										compareTerm.value = 10;
										break;
									case '3':
										compareTerm.value = 8;
										break;
									case '4':
										compareTerm.value = 5;
										break;
									case '5':
										compareTerm.value = 3;
										break;
									default:
										compareTerm.value = "";
										break;
									}
									$("#" + compareTerm.termName).val(compareTerm.value).trigger('change');
								}
							});
						}

						break; 
					case "excercise_crf":
						console.log("Exercise CRF Auto Calculation Running");
						if(term.termName === "drug_diabetes") {
							console.log(term.value[0]);
							if(term.value[0] === '1'){
								this.crf.terms.forEach(compareTerm=>{
									if(compareTerm.termName === "diabetes"){
										compareTerm.value = "1";
										console.log($("#" + compareTerm.termName));
										$("#" + compareTerm.termName).val(compareTerm.value).trigger('change');
									}
								});
							}else{
								this.crf.terms.forEach(compareTerm=>{
									if(compareTerm.termName === "diabetes"){
										compareTerm.value = "0";
										$("#" + compareTerm.termName).val(compareTerm.value).trigger('change');							
									}
								});
							}
						}
						break;
				}
				 
			}
		}
	}
	
    let renderUtil = {
        renderCanvas : function(terms){
        	let $loader = $('<div>');
        	terms.forEach( term => {
                if(term.termType === "Group"){
                	if(term.groupTermId.name === ""){
                		$loader.append(this.buildGroupTerm(terms, term));
                	}
                }
                else{
                	if(term.groupTermId.name === ""){
                		$loader.append(this.buildGeneralTerm(term, this.align));
                	}
                }
            });
        	
        	return $loader;
        },

        buildGroupTerm : function(terms, term){
        	let displayName = term.displayName.localizedMap.en_US;
        	let $GroupOuterDiv = $('<div>');
        	$GroupOuterDiv.prop({
        		id:term.termName + "_outerDiv"
        	});
        	let $accordionTab = $('<div class="card-horizontal main-content-card" style="min-height:0px;">');
			let $groupBody = $('<div id="'+ term.termName +'">');
			let $groupName = $('<h3>').text(displayName);
			$accordionTab.append($groupName);
			let hasSubGroup = false;
			
			terms.forEach( subTerm => {
                if(subTerm.termType === "Group"){
                	if(subTerm.groupTermId.name !== ""){
                		if(subTerm.groupTermId.name === term.termName){
                			$groupBody.append(this.buildSubGroupTerm(terms, subTerm));
                			hasSubGroup = true;
                		}
                	}
                }else{
                	if(subTerm.groupTermId.name !== ""){
                		if(subTerm.groupTermId.name === term.termName){
                			$groupBody.append(this.buildGeneralTerm(subTerm, this.align));
                			hasSubGroup = true;
                		}
                	}
                }
            });
			
			if(!hasSubGroup){
    			$groupBody.append(this.buildSubGroupTerm(terms, term));
			}
			
			$accordionTab.append($groupBody);
			$accordionTab.accordion({
                collapsible: true,
				highStyle: 'content',
				disabled: false,
				active: false,
				activate: function(event, ui){
					ui.newPanel.css('height', 'auto');
				}
            });
			$GroupOuterDiv.append($accordionTab);
			return $GroupOuterDiv;
        },
        
        buildSubGroupTerm : function(terms, term){
        	let displayName = term.displayName.localizedMap.en_US;
        	let $GroupOuterDiv = $('<div>');
        	$GroupOuterDiv.prop({
        		id:term.termName + "_outerDiv"
        	});
        	let $accordionTab = $('<div class="card-horizontal main-content-card pad1R">');
			let $groupBody = $('<div id="'+ term.termName +'">');
			let $groupName = $('<h3>').text(displayName);
			
			terms.forEach( includeTerm => {
                if(includeTerm.termType !== "Group"){
            		if(includeTerm.groupTermId.name === term.termName){
            			$groupBody.append(this.buildGeneralTerm(includeTerm, this.align));
            		}
                }
            });
			
			$accordionTab.append($groupName);
			$accordionTab.append($groupBody);
			$GroupOuterDiv.append($accordionTab);
			return $GroupOuterDiv;
        },
        
        buildGeneralTerm : function(term, align_control){
			if(this.structuredData){
				if(this.structuredData.hasOwnProperty(term.termName)){
					term.value = this.structuredData[term.termName];
				}
			}
			if(term.termType === "Grid"){
				align_control = "crf-align-vertical";
			}
            let label = term.displayName.localizedMap.en_US;
        	let $container = $('<div class = "radius-shadow-container marBr ' + align_control + '">');
        	$container.prop({
        		id:term.termName + "_outerDiv"
        	});
			if(term.disabled){
				$container.attr("style", "background-color: #dcdcdc!important");
			}	
			let $section = $('<div class="string-term">');
			let $label = $('<div class="label-controller">');
			$label.append($('<p>' + label + '</p>'));
			$section.append($label);
			$container.append($section);
			let $inputLabel = $('<div>');
			if(term.termType === "Grid"){
				console.log("is Grid", term);
				
				let $gridTable = $('<table class="crf-grid-table">');
				$gridTable.prop({
					id: term.termName
				});
				$gridTable.data('rowIndex', 1);

				let $gridHead = $('<thead></thead>');
				let $headRow = $('<tr></tr>');
				let $gridBody = $('<tbody>');
				
				term.rowIndex = 1;
				if(term.value){
					let totalIndex = Object.keys(term.value).length;
					term.rowIndex = totalIndex;
				}
				let keys = Object.keys(term.columnDefs);
				keys.forEach((key) =>{
					let includeTerm = term.columnDefs[key];
					$headRow.append($('<th>' + includeTerm.displayName.localizedMap.en_US +'</th>'));
					$gridHead.append($headRow);

				});
				for(var i = 1; i < term.rowIndex + 1; i++){
					let $bodyRow = $('<tr></tr>');
					keys.forEach((key) =>{
						let $dataColumn = $('<td>'); 
						$dataColumn.append(this.buildGridIncludeTerm(term.columnDefs[key], term, i));
						$bodyRow.append($dataColumn);
						$gridBody.append($bodyRow);
					});
				}
				$gridTable.append($gridHead);
				$gridTable.append($gridBody);
				$inputLabel.append($gridTable);
				
				let $btnArea = $('<div>');
				let $addBtn = $('<button>');
				let $deleteBtn = $('<button>');
				$addBtn.prop({
					class: "btn btn-default marTr",
					id: term.termName +"_addBtn",
					name: term.termName +"_addBtn",
				});
				$addBtn.append("add");
				
				$addBtn.on("click", function(event){
					console.log("add btn clicked");
					console.log(term.termName);
					let gridTable = document.getElementById(term.termName);
					term.rowIndex = gridTable.childNodes[1].childNodes.length + 1;
					console.log(term.rowIndex);
					var newRow = gridTable.insertRow();
					let keys = Object.keys(term.columnDefs);
					keys.forEach((key) =>{
						var newCell = newRow.insertCell(); 
						$(newCell).append(renderUtil.buildGridIncludeTerm(term.columnDefs[key], term, term.rowIndex));
					});

				});
				
				
				$deleteBtn.prop({
					class: "btn btn-default marTr marLr",
					id: term.termName +"_deleteBtn",
					name: term.termName +"_deleteBtn",
				});
				$deleteBtn.append("delete");
				
				$deleteBtn.on("click", function(event){
					let gridTable = document.getElementById(term.termName);
					gridTable.deleteRow(term.rowIndex);

					if(term.value){
						let tempIndex = term.rowIndex.toString();
						delete term.value[tempIndex];
						let dataPacket = new EventDataPacket();
						dataPacket.term = term;
						console.log(dataPacket);
						const eventData = {
							dataPacket: dataPacket
						};
						
						Liferay.fire( 'value_changed', eventData );		
					}
					term.rowIndex = term.rowIndex - 1;
				});
				
				$btnArea.append($addBtn);
				$btnArea.append($deleteBtn);
				$inputLabel.append($btnArea);
			}else{
				$inputLabel.append(this.buildTermInput(term));
			}
			$section.append($inputLabel);
			
			return $container;
        },
        
        buildTermInput : function(term){
			let $inputTag = $('<input class="field form-control" type="text">');
			switch(term.termType){
			case "String":
			case "Numeric":
				$inputTag.prop({
					id: term.termName,
					name: term.termName,
					disabled: term.disabled,
					value: term.value
				});
				
				let eventFuncs = {
						change: function( event ){
							event.stopPropagation();

							term.value = $('#'+term.termName).val();
							console.log( 'get value: ', term.value);
							let dataPacket = new EventDataPacket();
							dataPacket.term = term;
							const eventData = {
								dataPacket: dataPacket
							};
							
							Liferay.fire( 'value_changed', eventData );					
						}
					};
				Object.keys( eventFuncs ).forEach( event => {
					$inputTag.on( event, eventFuncs[event] );
				});
				break;
			case "Date":
				$inputTag = $('<input class="form-control date" type="text" placeholder="yyyy/MM/dd HH:mm">');
				$inputTag.prop({
					id: term.termName,
					name: term.termName,
					disabled: term.mandatory,
					required: true,
					value: term.value
				});
				let dateEventFuncs = {
					change: function(event){
						if((typeof $inputTag.val() === 'string') && $inputTag.val() === ''){
							term.value = undefined;
	
							let dataPacket = new EventDataPacket();
							dataPacket.term = term;
							const eventData = {
								dataPacket: dataPacket
							};
							//Liferay.fire( 'value_changed', eventData );					
						}
					}
				};
				Object.keys( dateEventFuncs ).forEach( event => {
					$inputTag.on( event, dateEventFuncs[event] );
				});

				let options = {
					lang: 'kr',
					changeYear: true,
					changeMonth : true,
					yearStart: term.startYear ? term.startYear : new Date().getFullYear(),
					yearEnd: term.endYear ? term.endYear : new Date().getFullYear(),
					scrollInput:false,
					value: term.enableTime ? renderUtil.toDateTimeString(term.value) : renderUtil.toDateString(term.value),
					validateOnBlur: false,
					id:term.termName,
					onChangeDateTime: function(dateText, inst){
						term.value = $inputTag.datetimepicker("getValue").getTime();
	
						if( term.enableTime ){
							$inputTag.val(renderUtil.toDateTimeString(term.value));
						}
						else{
							$inputTag.val(renderUtil.toDateString(term.value));
						}
	
						$inputTag.datetimepicker('setDate', $inputTag.datetimepicker("getValue"));
	
						let dataPacket = new EventDataPacket();
						dataPacket.term = term;
						const eventData = {
							dataPacket: dataPacket
						};
						Liferay.fire( 'value_changed', eventData );		
					}
				};

				if( term.enableTime ){
					options.timepicker = true;
					options.format = 'Y. m. d. H:i';
					options.value = this.toDateTimeString(),
					$inputTag.datetimepicker(options);
					$inputTag.val(this.toDateTimeString(term.value));
				}
				else{
					options.timepicker = false;
					options.format = 'Y. m. d.';
					options.value = this.toDateString(),
					$inputTag.datetimepicker(options);
					$inputTag.val(this.toDateString(term.value));
				}
				break;
			case "List":
				if(term.displayStyle === "select"){
					$inputTag = $( '<select class="form-control">' );
					term.options.forEach((option)=>{
						let $optionTag = $('<option>').text(option.label.localizedMap.en_US);
						$optionTag.val(option.value);
						$inputTag.append($optionTag);
					});
					$inputTag.prop({
						id: term.termName,
						name: term.termName,
						disabled: term.disabled,
						value: term.value
					});
					
					let listEventFuncs = {
						change: function( event ){
							event.stopPropagation();
	
							term.value = $('#'+term.termName).val();
							console.log( 'get value: ', term.value);
							let dataPacket = new EventDataPacket();
							dataPacket.term = term;
							const eventData = {
								dataPacket: dataPacket
							};
							
							Liferay.fire( 'value_changed', eventData );					
						}
					};
				Object.keys( listEventFuncs ).forEach( event => {
					$inputTag.on( event, listEventFuncs[event] );
				});
				}else if(term.displayStyle === "radio"){
					$inputTag = $('<label>');
					let index = 1;
					term.options.forEach((option)=>{
						let $radioTag = $( '<input type="radio">' );
						$radioTag.prop({
							class :"field",
							id: term.termName + "_" + index,
							name: term.termName,
							disabled: term.disabled,
							value: option.value
						});
						let $nameTag = $('<span>').text(option.label.localizedMap.en_US); 
						$inputTag.append($radioTag);
						$inputTag.append($nameTag);
						index++;
					});
					$inputTag.prop({
						for: term.termName
					});
					$inputTag.change(function(event){
						event.stopPropagation();

						let $checkedRadio = $(this).find('input[type="radio"]:checked').first();
						let changedVal = $checkedRadio.val();

						term.value = changedVal;

						console.log( 'get value: ', term.value);
						let dataPacket = new EventDataPacket();
						dataPacket.term = term;
						const eventData = {
							dataPacket: dataPacket
						};
						
						Liferay.fire( 'value_changed', eventData );		
					});
				}
				break;
			case "File":
				$inputTag = $('<div>');
				
				let $fileTag = $('<input type="file" class="lfr-input-text form-control" size="80" multiple>');
				$fileTag.prop({
					id: term.termName,
					name: term.termName,
					disabled: !!this.disabled ? true : false
				});
				
				const dataTransfer = new DataTransfer();
				//TODO: make table to config file items below
				
				let $fileProfileTag = $('<tr>');
				console.log("has termvalue?", term.value);
				
				if(term.value){
					for(const key in term.value){
						$fileProfile = $('<td>');
						console.log("has termvalue 1?", key);
						$fileProfile.append(key);
						$fileProfileTag.append($fileProfile);
					}
				}
				$inputTag.append($fileTag);
				$inputTag.append($fileProfileTag);
				$fileTag.change(function(event){
					event.stopPropagation();
					let files = $(this)[0].files;
				 	if(files != null && files.length>0){
			            for(var i=0; i<files.length; i++){
			                dataTransfer.items.add(files[i])
			            }
			            $(this)[0].files = dataTransfer.files;
			            console.log("dataTransfer =>", dataTransfer.files);
			            console.log("input FIles =>", $(this)[0].files);
				 	}
					
					console.log( 'get value: ', $(this)[0].files);
					
					let $form = $('#crfViewerForm');

					if($('#' + term.termName + "_fileCarrior").length > 0){
						let $fileCarriorInput = $('#' + term.termName + "_fileCarrior");
						$fileCarriorInput[0].files = $(this)[0].files;
					}else{
						let $fileCarriorInput = $('<input type="file" style="display: none;" multiple/>');
						$fileCarriorInput.prop({
							id: term.termName +"_fileCarrior",
							name: term.termName +"_fileCarrior"
						});
						$fileCarriorInput[0].files = $(this)[0].files;
						$form.append($fileCarriorInput);
					}
					
					let fileTermValue = new Object();
					
					console.log(term.value);
					if(term.value.constructor.length > 0){
						fileTermValue = term.value;
					}
					let toObj = new Object();
				
					for(var i = 0; i < dataTransfer.files.length; i++){
						let data = dataTransfer.files[i];
						console.log(data);
						toObj["size"] = data.size;
						toObj["parentFolderId"] = 0;
						toObj["name"] = data.name;
						toObj["type"] = data.type;
						toObj["fileId"] = 0;
					}
					
					fileTermValue[toObj["name"]] = toObj;
					console.log(fileTermValue);
					
					term.value = fileTermValue;
					
					let dataPacket = new EventDataPacket();
					dataPacket.term = term;
					const eventData = {
						dataPacket: dataPacket
					};
					
					Liferay.fire( 'value_changed', eventData );		
				});

			}
			if(term.disabled){
				$inputTag.attr("style", "color: black");
			}	
        	return $inputTag;
        },
        buildGridIncludeTerm : function(term, gridTerm, rowIndex){
        	let cellValue = undefined;
        	if(gridTerm.value){
        		if(gridTerm.value.hasOwnProperty(rowIndex.toString())){
        			cellValue = gridTerm.value[rowIndex.toString()][term.termName];
        		}
        	}
        	
        	let $gridInputTag = $('<input class="field form-control" type="text">');
			switch(term.termType){
			case "String":
			case "Numeric":
				$gridInputTag.prop({
					id: term.termName + "_" + rowIndex,
					name: term.termName,
					disabled: term.disabled,
					value: cellValue
				});
				
				let eventFuncs = {
						change: function( event ){
							event.stopPropagation();

							let termValue = $('#' + term.termName + "_" + rowIndex).val();
							console.log( 'get value: ', termValue);
							let gridTermFormat = new Object();
							let rowDataFormat = new Object();
							if(gridTerm.value){
								gridTermFormat = gridTerm.value;
								if(!gridTermFormat[rowIndex.toString()]){
									gridTermFormat[rowIndex.toString()] = new Object();
								}
								rowDataFormat = gridTermFormat[rowIndex.toString()];
							}
							
							rowDataFormat[term.termName] = termValue;
							gridTermFormat[rowIndex.toString()] = rowDataFormat;
							gridTerm.value = JSON.stringify(gridTermFormat);
							console.log(gridTermFormat);
							let dataPacket = new EventDataPacket();
							dataPacket.term = gridTerm;
							console.log(dataPacket);
							const eventData = {
								dataPacket: dataPacket
							};
							
							Liferay.fire( 'value_changed', eventData );					
						}
					};
				Object.keys( eventFuncs ).forEach( event => {
					$gridInputTag.on( event, eventFuncs[event] );
				});
				break;
			case "Date":
				$gridInputTag = $('<input class="form-control date" type="text" placeholder="yyyy/MM/dd HH:mm">');
				$gridInputTag.prop({
					id: term.termName,
					name: term.termName,
					disabled: term.mandatory
				});
				let dateEventFuncs = {
					change: function(event){
						if((typeof $gridInputTag.val() === 'string') && $gridInputTag.val() === ''){
							term.value = undefined;				
						}
					}
				};
				Object.keys( dateEventFuncs ).forEach( event => {
					$gridInputTag.on( event, dateEventFuncs[event] );
				});

				let options = {
					lang: 'kr',
					changeYear: true,
					changeMonth : true,
					yearStart: term.startYear ? term.startYear : new Date().getFullYear(),
					yearEnd: term.endYear ? term.endYear : new Date().getFullYear(),
					scrollInput:false,
					value: term.enableTime ? renderUtil.toDateTimeString(cellValue) : renderUtil.toDateString(cellValue),
					validateOnBlur: false,
					id:term.termName,
					onChangeDateTime: function(dateText, inst){
						let termValue = $gridInputTag.datetimepicker("getValue").getTime();
	
						if( term.enableTime ){
							$gridInputTag.val(renderUtil.toDateTimeString(termValue));
						}
						else{
							$gridInputTag.val(renderUtil.toDateString(termValue));
						}
	
						$gridInputTag.datetimepicker('setDate', $gridInputTag.datetimepicker("getValue"));
						
						let gridTermFormat = new Object();
						let rowDataFormat = new Object();
						if(gridTerm.value){
							gridTermFormat = gridTerm.value;
							if(!gridTermFormat[rowIndex.toString()]){
								gridTermFormat[rowIndex.toString()] = new Object();
							}
							rowDataFormat = gridTermFormat[rowIndex.toString()];
						}
						
						rowDataFormat[term.termName] = termValue;
						gridTermFormat[rowIndex.toString()] = rowDataFormat;
						gridTerm.value = JSON.stringify(gridTermFormat);
						console.log(gridTermFormat);
						
						let dataPacket = new EventDataPacket();
						dataPacket.term = gridTerm;
						const eventData = {
							dataPacket: dataPacket
						};
						Liferay.fire( 'value_changed', eventData );		
					}
				};

				if( term.enableTime ){
					options.timepicker = true;
					options.format = 'Y. m. d. H:i';
					options.value = this.toDateTimeString(),
					$gridInputTag.datetimepicker(options);
					$gridInputTag.val(this.toDateTimeString(cellValue));
				}
				else{
					options.timepicker = false;
					options.format = 'Y. m. d.';
					options.value = this.toDateString(),
					$gridInputTag.datetimepicker(options);
					$gridInputTag.val(this.toDateString(cellValue));
				}
				break;
			case "List":
				if(term.displayStyle === "select"){
					$gridInputTag = $( '<select class="form-control">' );
					term.options.forEach((option)=>{
						let $optionTag = $('<option>').text(option.label.localizedMap.en_US);
						$optionTag.val(option.value);
						$gridInputTag.append($optionTag);
					});
					$gridInputTag.prop({
						id: term.termName + "_" + rowIndex,
						name: term.termName,
						disabled: term.disabled,
						value: cellValue
					});
					
					let listEventFuncs = {
						change: function( event ){
							event.stopPropagation();
	
							let termValue = $('#'+term.termName + "_" + rowIndex).val();
							console.log( 'get value: ', termValue);
							let gridTermFormat = new Object();
							let rowDataFormat = new Object();
							var listArr = new Array();
							if(gridTerm.value){
								gridTermFormat = gridTerm.value;
								if(!gridTermFormat[rowIndex.toString()]){
									gridTermFormat[rowIndex.toString()] = new Object();
								}
								rowDataFormat = gridTermFormat[rowIndex.toString()];
							}
							listArr.push(termValue.toString());
							rowDataFormat[term.termName] = listArr;
							gridTermFormat[rowIndex.toString()] = rowDataFormat;
							gridTerm.value = JSON.stringify(gridTermFormat);
							console.log(gridTermFormat);
							let dataPacket = new EventDataPacket();
							dataPacket.term = gridTerm;
							const eventData = {
								dataPacket: dataPacket
							};
							
							Liferay.fire( 'value_changed', eventData );					
						}
					};
				Object.keys( listEventFuncs ).forEach( event => {
					$gridInputTag.on( event, listEventFuncs[event] );
				});
				}else if(term.displayStyle === "radio"){
					$gridInputTag = $('<label>');
					term.options.forEach((option)=>{
						let $radioTag = $( '<input type="radio">' );
						$radioTag.prop({
							class :"field",
							id: term.termName + "_" + rowIndex,
							name: term.termName,
							disabled: term.disabled,
							value: option.value
						});
						let $nameTag = $('<span>').text(option.label.localizedMap.en_US); 
						$gridInputTag.append($radioTag);
						$gridInputTag.append($nameTag);
					});
					$gridInputTag.prop({
						for: term.termName
					});
				}
				break;
			}
        	return $gridInputTag;
        },
        activateTerms : function(term){
        	let options = term.options;

			let values;
			if( Array.isArray(term.value) ){
				values = term.value;
			}
			else{
				values = [term.value];
			}
			
			options.forEach( option => {
				if( values.includes( option.value ) ){
					if( option.slaveTerms ){
						let slaveTermNames = option.slaveTerms;
						slaveTermNames.forEach( termName => this.showAndHide( termName, true ) );
					}
				}
				else{ // all slave term are deactivated.
					if( option.slaveTerms ){
						let slaveTermNames = option.slaveTerms;
						slaveTermNames.forEach( termName => this.showAndHide( termName, false ) );
					}
				}
			});
        },
        showAndHide: function(termName, activeFlag){
        	console.log("isSlaveTerm query", $("#"+termName+"_outerDiv"));
        	if( activeFlag ){
        		$("#"+termName+"_outerDiv").show();
			}
			else{
				$("#"+termName+"_outerDiv").hide();
	        	console.log("hided", $("#"+termName));
				//term.value = undefined;
			}
        },
		toDateTimeString : function(value){
			if(Number(value) !== value){
				return '';
			}
			let date = new Date( Number( value ) );
			let year = date.getFullYear();
			let month = (date.getMonth()+1);
			let day = date.getDate();
			let hour = date.getHours().toLocaleString(undefined, {minimumIntegerDigits:2});
			let minuite = date.getMinutes().toLocaleString(undefined, {minimumIntegerDigits:2});
			let dateAry = [year, String(month).padStart(2, '0'), String(day).padStart(2, '0')];
			let timeAry = [String(hour).padStart(2, '0'), String(minuite).padStart(2, '0')];
			return dateAry.join('/') + ' ' + timeAry.join(':');
		},
		toDateString : function(value){
			if(Number(value) !== value){
				return '';
			}
			
			let date = new Date( Number( value ) );
			let dateAry = [date.getFullYear(), String(date.getMonth()+1).padStart(2, '0'), String(date.getDate()).padStart(2, '0')];

			return dateAry.join('/');
		}
    };
    
    class EventDataPacket{
		parse( jsonObj ){
			Object.keys(jsonObj).forEach( key => {
				this[key] = jsonObj[key];
			});
		}

		toJSON(){
			let json = new Object();

			Object.keys(this).forEach(key=>{
				json[key] = this[key];
			});

			return json;
		}
	}

    return {
        Viewer : Viewer,
        renderUtil : renderUtil,
        autoCalUtil : autoCalUtil
    }
};