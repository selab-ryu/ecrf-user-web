let ECRFViewer = function(){
	class Viewer{
		constructor(DataStructure, align, structuredData){
			var result = new Object();
			renderUtil.align = align;
			console.log("sd data", structuredData);
			renderUtil.structuredData = structuredData;
			result = structuredData;
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
            };
            
            Liferay.on('value_changed', function(event){
            	if(event.dataPacket.term){
            		let eventTerm = event.dataPacket.term;
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
                }else{
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
			let $inputLabel = this.buildTermInput(term);
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
							Liferay.fire( 'value_changed', eventData );					
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
			}
			if(term.disabled){
				$inputTag.attr("style", "color: black");
			}	
        	return $inputTag;
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