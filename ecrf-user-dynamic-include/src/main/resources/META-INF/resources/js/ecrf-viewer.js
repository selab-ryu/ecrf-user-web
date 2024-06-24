let ECRFViewer = function(){
	class Viewer{

		constructor(DataStructure, align, structuredData){
			var result = new Object();
			renderUtil.align = align;
			console.log("sd data", structuredData);
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
							//renderUtil.activateSlaveTerms( term );
						}
					}
				});
            };
            
            Liferay.on('value_changed', function(event){
            	if(event.dataPacket.term){
            		let eventTerm = event.dataPacket.term;
            		console.log(eventTerm.value);
            		result[eventTerm.termName.toString()] = eventTerm.value;
            		event.dataPacket.result = result;
            	}
            });
        }
	};
	
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
			return $accordionTab;
        },
        
        buildSubGroupTerm : function(terms, term){
        	let displayName = term.displayName.localizedMap.en_US;
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
			
			return $accordionTab;
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
					term.options.forEach((option)=>{
						let $radioTag = $( '<input type="radio">' );
						$radioTag.prop({
							class :"field",
							id: term.termName,
							name: term.termName,
							disabled: term.disabled,
							value: option.value
						});
						let $nameTag = $('<span>').text(option.label.localizedMap.en_US); 
						$inputTag.append($radioTag);
						$inputTag.append($nameTag);
					});
					$inputTag.prop({
						for: term.termName
					});
				}
				break;
			case "File":
				$inputTag = $('<input type="file" class="lfr-input-text form-control" size="80" multiple>');
				$inputTag.prop({
					id: term.termName,
					name: term.termName,
					disabled: !!this.disabled ? true : false
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
        renderUtil : renderUtil
    }
};