let ECRFViewer = function(StationX){

	//console.log(StationX);

	let SX = {
		StationX: StationX,
		SDE_Namespace: ""
	};

	class Viewer{
		/*
		 * Here for launch viewer 
		 * 
		 */

		constructor(DataStructure, align, structuredData, subjectInfo, isAudit, forWhat) {
			var result = new Object();
			
			if(SX.StationX) {
				console.log("log SX", SX);
			} else {.0.
				console.log("SX is Empty or Null");
			}

			autoCalUtil.initCalculatevalue(DataStructure, subjectInfo);
			console.log("sd data", structuredData);
			DataStructure.terms = renderUtil.flattenTerms(DataStructure.terms);

			if(structuredData){
				renderUtil.structuredData = structuredData;
				result = structuredData;
			}

			let isProcessing = false;

			if(forWhat !== 'station-x') {
				renderUtil.align = align;
				renderUtil.isAudit = isAudit;

				if(isAudit){
					renderUtil.align = "crf-align-table";
				}

				$(document).ready(function(){
					let dataPacket = new EventDataPacket();
					dataPacket.result = result;
					const eventData = {
						dataPacket: dataPacket
					};
	
					console.log('crf value changed', eventData);
					Liferay.fire( 'value_changed', eventData );	
				});
					
				DataStructure.renderSmartCRF = function(){
					//console.log("is for render smartCRF");
					if( $.isEmptyObject( this.terms ) ){
						return;
					}
					this.$canvas.empty();
					this.$canvas.html(renderUtil.renderCanvas(this.terms));
					
					this.terms.forEach(term=>{
						if( term.termType === 'List' || term.termType === 'boolean' ){
							//console.log("List/Boolean Term slave term check : ", term, term.termName, term.hasSlaves());
							if( term.hasSlaves() ){
								renderUtil.activateTerms(term);
							}
						}
						if(autoCalUtil.checkExcerciseFlag(term.termName)){
							$("#" + term.termName + "_outerDiv").hide();
						}
					});
				};
				/*
				 * value_changed event work on js first, jsp after
				 */
				Liferay.on('value_changed', function(event){
					let packet = event.dataPacket;
	
					if(packet.term){
						let eventTerm = packet.term;
						console.log(eventTerm);
						console.log(eventTerm.value);
						if(eventTerm.termType === "List"){
							renderUtil.activateTerms(eventTerm);
						}
						result[eventTerm.termName.toString()] = eventTerm.value;
						event.dataPacket.result = result;
						if(isProcessing) return;
						isProcessing = true;
						autoCalUtil.checkAutoCal(eventTerm);
					}
					isProcessing = false;
				});
			}
		}
	};
	
	/*
	 * autoCalUtil for exercise crf, er crf
	 */
	let autoCalUtil = {
		initCalculatevalue: function(DataStructure, subjectInfo){
			this.crf = DataStructure;
			
			this.subjectInfo = subjectInfo;
			this.gender = subjectInfo["subjectGender"];
			this.age = autoCalUtil.calcAge(subjectInfo["subjectBirth"], new Date());
			
			//for er crf cogas score
			this.cogasScore = 0;
			if(this.age >= 50){
				this.cogasScore++;
			}
			
			//for exercise crf risk, metabolic measurement
			this.riskCount = 0;
			this.metabolicCount = 0;
			
		},
		
		/**
		 * calculate age at targetDate (in korean way)
		 * @param {Date} birthDate
		 * @param {Date} targetDate
		 * @returns {int} age
		 */
		calcAge: function (birthDate, targetDate) {
			let birthYear = birthDate.getFullYear();
			let birthMonth = birthDate.getMonth();
			let birthDay = birthDate.getDate();
			
			let targetYear = targetDate.getFullYear();
			let targetMonth = targetDate.getMonth();
			let targetDay = targetDate.getDate();
			
			let age = targetYear - birthYear;
			
			if (targetMonth < birthMonth) {
			  age--;
			}
			
			else if (targetMonth === birthMonth && targetDay < birthDay) {
			  age--;
			}
			
			return age;
		},

		/**
		 * Calculate smoke period day by year, month, day
		 * get value from each year, month, day input
		 * divide total day by option
		 * @param {String} targetNamespace 
		 * @param {String} yearId 
		 * @param {String} monthId 
		 * @param {String} dayId 
		 * @param {String} option 
		 * @returns fixed(4) float smoke period
		 */
		calcSmokePeriod: function(targetNamespace, yearId, monthId, dayId, option) {
			const DAYS_IN_YEAR = 365.0;
			const DAYS_IN_MONTH = 30.0;

			const yearVal = parseFloat($('#' + targetNamespace + yearId).val()) || 0.0;
			const monthVal = parseFloat($('#' + targetNamespace + monthId).val()) || 0.0;
			const dayVal = parseFloat($('#' + targetNamespace + dayId).val()) || 0.0;

			const totalDays = (yearVal * DAYS_IN_YEAR) + (monthVal * DAYS_IN_MONTH) + dayVal;

			let result = totalDays;
			if(option === 'year')  result = totalDays / DAYS_IN_YEAR;
			if(option === 'month') result = totalDays / DAYS_IN_MONTH;
			return result.toFixed(4);
		},

		calcSmokeAmountYear: function(targetNamespace, amountId, yearId) {
			const amount = parseFloat($('#'+targetNamespace+amountId).val()) || 0.0;
			const year = parseFloat($('#'+targetNamespace+yearId).val()) || 0.0;

			const amountYear = amount * year;
			
			console.log("smoke amount year :", amountYear);
			return amountYear.toFixed(4);
		},
		
		/**
		 * Calculate bmi by height, weight
		 * get fixed param and return fixed float
		 * @param {String} targetNamespace 
		 * @param {String} weightId 
		 * @param {String} heightId 
		 * @param {number} fixed 
		 * @returns fixed(x) float bmi
		 */
		calcBMI: function(targetNamespace, weightId, heightId, fixed=1) {
			const weight = parseFloat($('#'+targetNamespace+weightId).val()) || 0.0;
			const height = parseFloat($('#'+targetNamespace+heightId).val()) || 0.0;

			let bmi = 0.0;
			if(weight > 0 && height > 0) {
				height = height / 100.0;	// cm to m
				bmi = weight / (height * height);
			}

			return bmi.toFixed(fixed);
		},

		/**
		 * Calculate fev1_fvc by fev1, fvc measurement
		 * get fixed param and return fixed float
		 * @param {String} targetNamespace 
		 * @param {String} fev1Id 
		 * @param {String} fvcId 
		 * @param {number} fixed
		 * @returns fixed(x) float fev1_fvc
		 */
		calcFEV1_FVC: function(targetNamespace, fev1Id, fvcId, fixed) {
			const fev1 = parseFloat($('#'+targetNamespace+fev1Id).val()) || 0.0;
			const fvc = parseFloat($('#'+targetNamespace+fvcId).val()) || 0.0;

			const fev1_fvc = 0.0;
			if(fev1 > 0 && fvc > 0) {
				fev1_fvc = fev1Val / fvcVal * 100.0;	// percent
			}

			return fev1_fvc.toFixed(fixed);
		},

		calcTNMStage: function(targetNamespace, tId, nId, mId, edition=8) {
			let tVal = $('#'+targetNamespace+tId).val() || 0;
			let nVal = $('#'+targetNamespace+nId).val() || 0; 
			let mVal = $('#'+targetNamespace+mId).val() || 0;

			// $().val() is string, need to change to number
			if(tVal > 0) tVal = parseInt(tVal, 10);
			if(nVal > 0) nVal = parseInt(nVal, 10);
			if(mVal > 0) mVal = parseInt(mVal, 10);

			let stage = "";
			
			if(edition === 8) {
				stage = this.tnmStage8(tVal, nVal, mVal);
			}

			if (edition === 9) {
				stage = this.tnmStage9(tVal, nVal, mVal);
			}

			return stage;
		},

		tnmStage8: function(_t, _n, _m) {
			// Stage Matrix (1-based index)
			// [TX(1), T0(2), Tis(3), T1mi(4), T1(5), T1a(6), T1b(7), T1c(8), T2(9), T2a(10), T2b(11), T3(12), T4(13)]
			// [NX(1), N0(2), N1(3), N2(4), N3(5)]
			const stageMatrixTN = [
				['', '', '',  '', ''],  // TX (1)
				['', '',  '', ''],  // T0 (2)

				['', '',  '', ''],  // Tis (3)
				['', '', '',  '', ''],  // T1mi (4)

				['', 'IA1', 'IIB',  'IIIA', 'IIIB'],  // T1 (5)
				['', 'IA1', 'IIB',  'IIIA', 'IIIB'],  // T1a (6)
				['', 'IA2', 'IIB',  'IIIA', 'IIIB'],  // T1b (7)
				['', 'IA3', 'IIB',  'IIIA', 'IIIB'],  // T1c (8)

				['', 'IB',  'IIB',  'IIIA', 'IIIB'],  // T2 (9)
				['', 'IB',  'IIB',  'IIIA', 'IIIB'],  // T2a (10)
				['', 'IIA', 'IIB',  'IIIA', 'IIIB'],  // T2b (11)

				['', 'IIB', 'IIIA', 'IIIB', 'IIIC'],  // T3  (12)
				
				['', 'IIIA','IIIA', 'IIIB', 'IIIC']   // T4  (13)
			];

			let stageCal = '';
			
			// check T, N value
			if(_t && _n) {
				// value validation check
				if(_t < 1 || _t > 13 || _n < 1 || _n > 5 ) {
					return '';
				}
				stageCal = stageMatrixTN[_t-1][_n-1];
			}

			// check M value
			// has high priority
			if(_m) {
				//console.log("post / m value : ", _m, typeof _m);
				switch(_m) {
					case 1:	// M0
						break;
					case 2:	// M1
					case 3:	// M1a
					case 4:	// M1b
						stageCal = 'IVA';
						break;
					case 5:	// M1c
						stageCal = 'IVB';
						break;
				}
			}

			//console.log("T / N / M", _t, _n, _m);
			//console.log("stage : ", stageCal);

			return stageCal;
		},

		tnmStage9: function(_t, _n, _m) {
			// Stage Matrix (1-based index)
			// [TX(1), T0(2), Tis(3), T1mi(4), T1a(5), T1b(6), T1c(7), T2a(8), T2b(9), T3(10), T4(11)]
			// [NX(1), N0(2), N1(3), N2a(4), N2b(5), N3(6)]
			const stageMatrixTN = [
				['', '', '',  '', '', ''],  // TX (1)
				['', '',  '', '', '', ''],  // T0 (2)

				['', '',  '', '', '' , ''],  // Tis (3)
				['', '', '',  '', '', ''],  // T1mi (4)

				['', 'IA1', 'IIA', 'IIB', 'IIIA', 'IIIB'],  // T1a (5)
				['', 'IA2', 'IIA', 'IIB', 'IIIA', 'IIIB'],  // T1b (6)
				['', 'IA3', 'IIA', 'IIB', 'IIIA', 'IIIB'],  // T1c (7)

				['', 'IB',  'IIB',  'IIIA', 'IIIB', 'IIIB'],  // T2a (8)
				['', 'IIA', 'IIB',  'IIIA', 'IIIB', 'IIIB'],  // T2b (9)

				['', 'IIB', 'IIIA', 'IIIB', 'IIIC', 'IIIC'],  // T3  (10)
				
				['', 'IIIA','IIIA', 'IIIB', 'IIIC', 'IIIC']   // T4  (11)
			];

			let stageCal = "";

			// check T, N value
			if(_t && _n) {
				// value validation check
				if(_t < 1 || _t > 11 || _n < 1 || _n > 6 ) {
					return '';
				}
				stageCal = stageMatrixTN[_t-1][_n-1];
			}
			
			// check M value
			// has high priority
			if(_m) {
				//console.log("post / m value : ", _m, typeof _m);
				switch(_m) {
					case 1:	// M0
						break;
					case 2:	// M1a
					case 3:	// M1b
						stageCal = 'IVA';
						break;
					case 4:	// M1c1
					case 5:	// M1c2
						stageCal = 'IVB';
						break;
				}
			}

			//console.log("T / N / M", _t, _n, _m);
			//console.log("stage : ", stageCal);

			return stageCal;
		},

		calcCCI: function(targetNamespace) {
			// weight by input id (disease name)
			const itemWeight = {
				adv_pd_com_age_at_diagnosis: {1:0, 2:1, 3:2, 4:3, 5:4},
				pd_com_dm: {1:0, 2:1, 3:2},
				adv_pd_com_liver_disease: {1:0, 2:1, 3:3},
				adv_pd_com_solid_tumor: {1:0, 2:2, 3:6},
				adv_pd_com_chronic_kidey_ds: {1:0, 2:2},
				pd_com_mi: {1:0, 2:1},
				pd_com_congestive_heart_failure: {1:0, 2:1},
				pd_com_peripheral_vascular_ds: {1:0, 2:1},
				pd_com_cerebral_vascular_ds: {1:0, 2:1},
				pd_com_hemiplegia: {1:0, 2:2},
				pd_com_copd: {1:0, 2:1},
				pd_com_connective_tissue_ds: {1:0, 2:1},
				pd_com_leukemia: {1:0, 2:2},
				pd_com_malignant_lymphoma: {1:0, 2:2},
				pd_com_peptic_ulcer_ds: {1:0, 2:1},
				pd_com_aids: {1:0, 2:6},
				pd_com_dementia: {1:0, 2:1}
			};

			let score = 0;

			// aggregate weight by loop (disease item)
			for(const key in itemWeight) {
				let keyName = targetNamespace+key;
				let elem = $("input[name='"+keyName+"']:checked");
				let value = null;
				value = parseInt(elem.val(), 10);	// parse to int for null check validation
				//console.log("key / value / value type : ", key, value, typeof value);

				if(value) {	// elem value is not null
					let weight = itemWeight[key][value];	// search by string(value)

					if(weight) {	// item weight is exist
						//console.log("key / value / weight : ", key, value, weight)
						score += weight;
					} else {
						//console.log("weight is not defined / ", weight, itemWeight[key]);
					}
				}
			}
			
			return score;
		},

		/*
		 * Auto calculation part .. for find case each crf id
		 */
		checkAutoCal : function(packet){
			//console.log(packet);
			let term = packet.payload.after;
			let namespace = packet.sourcePortlet;
			let dataTypeName = packet.payload.dataTypeName;

			if(this.crf){
				//console.log("crf : ", this.crf);

				if(term.termName === "testBool") {
					let testNumId = "#"+namespace+"testNum";
					console.log(testNumId);

					$(testNumId).val(1234).trigger('change');
				}

				switch(dataTypeName){
					case "lung_cancer":
					case "lung_cancer_opt":
						//console.log("lung cancer crf auto calculate");
						this.cal_CNU_TS_Lung_Caner(term, namespace);
						break;
					case "er_crf":
						this.calYM_ER_CRF(term);
						break; 
					case "excercise_crf":
						this.calYM_EX_CRF(term);						
					break;						
				}
			}
		},

		/**
		 * auto calculdate for Chungbuk University Hospital - Thoracic Surgery
		 * Lung Cancer CRF
		 * @param {object} term 
		 * @param {string} namespace 
		 */
		cal_CNU_TS_Lung_Caner: function(term, namespace) {
			//console.log(term);
			switch(term.termName) {
				case "gi_ad_addmission_date":	// subject age at admission date
					let birth = this.subjectInfo["subjectBirth"];
					let target = new Date(Number(term.value));
					let age = this.calcAge(birth, target);
					this.updateTerm(namespace, 'gi_ad_age', age);
					break;
				// smoke amount year
				case "gi_ad_sh_smoke_amount":
				case "gi_ad_sh_smoke_total":
					let smokeAmountYear1 = this.calcSmokeAmountYear(namespace, "gi_ad_sh_smoke_amount", "gi_ad_sh_smoke_total");
					if(smokeAmountYear1>0) this.updateTerm(namespace, "gi_ad_sh_smoke_amount_year", smokeAmountYear1);
					else this.updateTerm(namespace, "gi_ad_sh_smoke_amount_year");
					break;
				// smoke period
				case "gi_ad_sh_smoke_year":
				case "gi_ad_sh_smoke_month":
				case "gi_ad_sh_smoke_day":
					let smokeTotalYear = this.calcSmokePeriod(namespace, "gi_ad_sh_smoke_year", "gi_ad_sh_smoke_month", "gi_ad_sh_smoke_day", "year");
					if(smokeTotalYear > 0)	this.updateTerm(namespace, "gi_ad_sh_smoke_total", smokeTotalYear);
					else this.updateTerm(namespace, "gi_ad_sh_smoke_total");					
					break;
				// none smoke period
				case "gi_ad_sh_quit_time_year":
				case "gi_ad_sh_quit_time_month":
				case "gi_ad_sh_quit_time_day":
					let quitSmokeTotalYear = this.calcSmokePeriod(namespace, "gi_ad_sh_quit_time_year", "gi_ad_sh_quit_time_month", "gi_ad_sh_quit_time_day", "year");
					if(quitSmokeTotalYear > 0)	this.updateTerm(namespace, "gi_ad_sh_quit_time_total", quitSmokeTotalYear);
					else this.updateTerm(namespace, "gi_ad_sh_quit_time_total");
					break;
				// bmi
				case "adv_pd_cp_height":
				case "adv_pd_cp_weight":
					let bmi = this.calcBMI(namespace, "adv_pd_cp_weight", "adv_pd_cp_height");
					if(bmi > 0) this.updateTerm(namespace, "adv_pd_cp_bmi", bmi);
					else this.updateTerm(namespace, "adv_pd_cp_bmi");
					break;
				// fvc_fev1
				case "adv_pd_pft_fvc":
				case "adv_pd_pft_fev1":
					let fev1_fvc = this.calcFEV1_FVC(namespace, "adv_pd_pft_fev1", "adv_pd_pft_fvc", 2);
					if(fev1_fvc > 0) this.updateTerm(namespace, "pd_pft_fev1_fvc", fev1_fvc);
					else this.updateTerm(namespace, "pd_pft_fev1_fvc");
					break;
				// CCI
				case "comorbidity_adv":
				case "adv_pd_com_age_at_diagnosis":
				case "pd_com_dm":
				case "adv_pd_com_liver_disease":
				case "adv_pd_com_solid_tumor":
				case "adv_pd_com_chronic_kidey_ds":
				case "pd_com_mi":
				case "pd_com_congestive_heart_failure":
				case "pd_com_peripheral_vascular_ds":
				case "pd_com_cerebral_vascular_ds":
				case "pd_com_hemiplegia":
				case "pd_com_copd":
				case "pd_com_connective_tissue_ds":
				case "pd_com_leukemia":
				case "pd_com_malignant_lymphoma":
				case "pd_com_peptic_ulcer_ds":
				case "pd_com_aids":
				case "pd_com_dementia":
					const cciName = namespace + 'comorbidity_adv';
					const cciAdv = $("input[name='"+cciName+"']:checked");
					const cciAdvVal = (cciAdv.val() === 'true');
					//console.log("cci adv : ", cciAdv, cciAdvVal);
					if(cciAdvVal) {	
						let score = this.calcCCI(namespace);
						//console.log("score : ", score);

						if(score > 0) this.updateTerm(namespace, "pd_com_cci", score);
						else this.updateTerm(namespace, "pd_com_cci");
					}
					break;
				
				// Nodule#1 TNM8
				case "pd_cs_noldule1_ajcc_8th_t":
				case "pd_cs_noldule1_ajcc_8th_n":
				case "pd_cs_noldule1_ajcc_8th_m":
					console.log("nodule1 8th tnm");
					let nodule1TNM8stage = this.calcTNMStage(namespace, "pd_cs_noldule1_ajcc_8th_t", "pd_cs_noldule1_ajcc_8th_n", "pd_cs_noldule1_ajcc_8th_m", 8);
					if(nodule1TNM8stage) this.updateTerm(namespace, "pd_cs_noldule1_ajcc_8th_clinical_stage", nodule1TNM8stage);
					else this.updateTerm(namespace, "pd_cs_noldule1_ajcc_8th_clinical_stage");
					break;
				// Nodule#2 TNM8
				case "pd_cs_noldule2_ajcc_8th_t":
				case "pd_cs_noldule2_ajcc_8th_n":
				case "pd_cs_noldule2_ajcc_8th_m":
					let nodule2TNM8stage = this.calcTNMStage(namespace, "pd_cs_noldule2_ajcc_8th_t", "pd_cs_noldule2_ajcc_8th_n", "pd_cs_noldule2_ajcc_8th_m", 8);
					if(nodule2TNM8stage) this.updateTerm(namespace, "pd_cs_noldule2_ajcc_8th_clinical_stage", nodule2TNM8stage);
					else this.updateTerm(namespace, "pd_cs_noldule2_ajcc_8th_clinical_stage");
					break;
				// Nodule#3 TNM8
				case "pd_cs_noldule3_ajcc_8th_t":
				case "pd_cs_noldule3_ajcc_8th_n":
				case "pd_cs_noldule3_ajcc_8th_m":
					let nodule3TNM8stage = this.calcTNMStage(namespace, "pd_cs_noldule3_ajcc_8th_t", "pd_cs_noldule3_ajcc_8th_n", "pd_cs_noldule3_ajcc_8th_m", 8);
					if(nodule3TNM8stage) this.updateTerm(namespace, "pd_cs_noldule3_ajcc_8th_clinical_stage", nodule3TNM8stage);
					else this.updateTerm(namespace, "pd_cs_noldule3_ajcc_8th_clinical_stage");
					break;
				// Nodule#4 TNM8
				case "pd_cs_noldule4_ajcc_8th_t":
				case "pd_cs_noldule4_ajcc_8th_n":
				case "pd_cs_noldule4_ajcc_8th_m":
					let nodule4TNM8stage = this.calcTNMStage(namespace, "pd_cs_noldule4_ajcc_8th_t", "pd_cs_noldule4_ajcc_8th_n", "pd_cs_noldule4_ajcc_8th_m", 8);
					if(nodule4TNM8stage) this.updateTerm(namespace, "pd_cs_noldule4_ajcc_8th_clinical_stage", nodule4TNM8stage);
					else this.updateTerm(namespace, "pd_cs_noldule4_ajcc_8th_clinical_stage");
					break;
				// Nodule#5 TNM8
				case "pd_cs_noldule5_ajcc_8th_t":
				case "pd_cs_noldule5_ajcc_8th_n":
				case "pd_cs_noldule5_ajcc_8th_m":
					let nodule5TNM8stage = this.calcTNMStage(namespace, "pd_cs_noldule5_ajcc_8th_t", "pd_cs_noldule5_ajcc_8th_n", "pd_cs_noldule5_ajcc_8th_m", 8);
					if(nodule5TNM8stage) this.updateTerm(namespace, "pd_cs_noldule5_ajcc_8th_clinical_stage", nodule5TNM8stage);
					else this.updateTerm(namespace, "pd_cs_noldule5_ajcc_8th_clinical_stage");
					break;
				
				// Nodule#1 TNM9
				case "pd_cs_noldule1_ajcc_9th_t":
				case "pd_cs_noldule1_ajcc_9th_n":
				case "pd_cs_noldule1_ajcc_9th_m":
					let nodule1TNM9stage = this.calcTNMStage(namespace, "pd_cs_noldule1_ajcc_9th_t", "pd_cs_noldule1_ajcc_9th_n", "pd_cs_noldule1_ajcc_9th_m", 9);
					if(nodule1TNM9stage) this.updateTerm(namespace, "pd_cs_noldule1_ajcc_9th_clinical_stage", nodule1TNM9stage);
					else this.updateTerm(namespace, "pd_cs_noldule1_ajcc_9th_clinical_stage");
					break;
				// Nodule#2 TNM9
				case "pd_cs_noldule2_ajcc_9th_t":
				case "pd_cs_noldule2_ajcc_9th_n":
				case "pd_cs_noldule2_ajcc_9th_m":
					let nodule2TNM9stage = this.calcTNMStage(namespace, "pd_cs_noldule2_ajcc_9th_t", "pd_cs_noldule2_ajcc_9th_n", "pd_cs_noldule2_ajcc_9th_m", 9);
					if(nodule2TNM9stage) this.updateTerm(namespace, "pd_cs_noldule2_ajcc_9th_clinical_stage", nodule2TNM9stage);
					else this.updateTerm(namespace, "pd_cs_noldule2_ajcc_9th_clinical_stage");
					break;
				// Nodule#3 TNM9
				case "pd_cs_noldule3_ajcc_9th_t":
				case "pd_cs_noldule3_ajcc_9th_n":
				case "pd_cs_noldule3_ajcc_9th_m":
					let nodule3TNM9stage = this.calcTNMStage(namespace, "pd_cs_noldule3_ajcc_9th_t", "pd_cs_noldule3_ajcc_9th_n", "pd_cs_noldule3_ajcc_9th_m", 9);
					if(nodule3TNM9stage) this.updateTerm(namespace, "pd_cs_noldule3_ajcc_9th_clinical_stage", nodule3TNM9stage);
					else this.updateTerm(namespace, "pd_cs_noldule3_ajcc_9th_clinical_stage");
					break;
				// Nodule#4 TNM9
				case "pd_cs_noldule4_ajcc_9th_t":
				case "pd_cs_noldule4_ajcc_9th_n":
				case "pd_cs_noldule4_ajcc_9th_m":
					let nodule4TNM9stage = this.calcTNMStage(namespace, "pd_cs_noldule4_ajcc_9th_t", "pd_cs_noldule4_ajcc_9th_n", "pd_cs_noldule4_ajcc_9th_m", 9);
					if(nodule4TNM9stage) this.updateTerm(namespace, "pd_cs_noldule4_ajcc_9th_clinical_stage", nodule4TNM9stage);
					else this.updateTerm(namespace, "pd_cs_noldule4_ajcc_9th_clinical_stage");
					break;
				// Nodule#5 TNM9
				case "pd_cs_noldule5_ajcc_9th_t":
				case "pd_cs_noldule5_ajcc_9th_n":
				case "pd_cs_noldule5_ajcc_9th_m":
					let nodule5TNM9stage = this.calcTNMStage(namespace, "pd_cs_noldule5_ajcc_9th_t", "pd_cs_noldule5_ajcc_9th_n", "pd_cs_noldule5_ajcc_9th_m", 9);
					if(nodule5TNM9stage) this.updateTerm(namespace, "pd_cs_noldule5_ajcc_9th_clinical_stage", nodule5TNM9stage);
					else this.updateTerm(namespace, "pd_cs_noldule5_ajcc_9th_clinical_stage");
					break;

				// Previous Tx. TNM8
				case "adv_pd_prev_tx_yc_t":
				case "adv_pd_prev_tx_yc_n":
				case "adv_pd_prev_tx_yc_m":
					let preTxTNMstage = this.calcTNMStage(namespace, "adv_pd_prev_tx_yc_t", "adv_pd_prev_tx_yc_n", "adv_pd_prev_tx_yc_m", 8);
					if(preTxTNMstage) this.updateTerm(namespace, "adv_pd_prev_tx_stage", preTxTNMstage);
					else this.updateTerm(namespace, "adv_pd_prev_tx_stage");
					break;
				
				// Tumor#1 TNM8
				case "path_tumor1_ajcc_8th_pathologic_tnm_t":
				case "path_tumor1_ajcc_8th_pathologic_tnm_n":
				case "path_tumor1_ajcc_8th_pathologic_tnm_m":
					let tumor1TNM8stage = this.calcTNMStage(namespace, "path_tumor1_ajcc_8th_pathologic_tnm_t", "path_tumor1_ajcc_8th_pathologic_tnm_n", "path_tumor1_ajcc_8th_pathologic_tnm_m", 8);
					if(tumor1TNM8stage) this.updateTerm(namespace, "path_tumor1_ajcc_8th_pathologic_stage", tumor1TNM8stage);
					else this.updateTerm(namespace, "path_tumor1_ajcc_8th_pathologic_stage");
					break;
				// Tumor#2 TNM8
				case "path_tumor2_ajcc_8th_pathologic_tnm_t":
				case "path_tumor2_ajcc_8th_pathologic_tnm_n":
				case "path_tumor2_ajcc_8th_pathologic_tnm_m":
					let tumor2TNM8stage = this.calcTNMStage(namespace, "path_tumor2_ajcc_8th_pathologic_tnm_t", "path_tumor2_ajcc_8th_pathologic_tnm_n", "path_tumor2_ajcc_8th_pathologic_tnm_m", 8);
					if(tumor2TNM8stage) this.updateTerm(namespace, "path_tumor2_ajcc_8th_pathologic_stage", tumor2TNM8stage);
					else this.updateTerm(namespace, "path_tumor2_ajcc_8th_pathologic_stage");
					break;
				// Tumor#3 TNM8
				case "path_tumor3_ajcc_8th_pathologic_tnm_t":
				case "path_tumor3_ajcc_8th_pathologic_tnm_n":
				case "path_tumor3_ajcc_8th_pathologic_tnm_m":
					let tumor3TNM8stage = this.calcTNMStage(namespace, "path_tumor3_ajcc_8th_pathologic_tnm_t", "path_tumor3_ajcc_8th_pathologic_tnm_n", "path_tumor3_ajcc_8th_pathologic_tnm_m", 8);
					if(tumor3TNM8stage) this.updateTerm(namespace, "path_tumor3_ajcc_8th_pathologic_stage", tumor3TNM8stage);
					else this.updateTerm(namespace, "path_tumor3_ajcc_8th_pathologic_stage");
					break;
				// Tumor#4 TNM8
				case "path_tumor4_ajcc_8th_pathologic_tnm_t":
				case "path_tumor4_ajcc_8th_pathologic_tnm_n":
				case "path_tumor4_ajcc_8th_pathologic_tnm_m":
					let tumor4TNM8stage = this.calcTNMStage(namespace, "path_tumor4_ajcc_8th_pathologic_tnm_t", "path_tumor4_ajcc_8th_pathologic_tnm_n", "path_tumor4_ajcc_8th_pathologic_tnm_m", 8);
					if(tumor4TNM8stage) this.updateTerm(namespace, "path_tumor4_ajcc_8th_pathologic_stage", tumor4TNM8stage);
					else this.updateTerm(namespace, "path_tumor4_ajcc_8th_pathologic_stage");
					break;
				// Tumor#5 TNM8
				case "path_tumor5_ajcc_8th_pathologic_tnm_t":
				case "path_tumor5_ajcc_8th_pathologic_tnm_n":
				case "path_tumor5_ajcc_8th_pathologic_tnm_m":
					let tumor5TNM8stage = this.calcTNMStage(namespace, "path_tumor5_ajcc_8th_pathologic_tnm_t", "path_tumor5_ajcc_8th_pathologic_tnm_n", "path_tumor5_ajcc_8th_pathologic_tnm_m", 8);
					if(tumor5TNM8stage) this.updateTerm(namespace, "path_tumor5_ajcc_8th_pathologic_stage", tumor5TNM8stage);
					else this.updateTerm(namespace, "path_tumor5_ajcc_8th_pathologic_stage");
					break;

				// Tumor#1 TNM9
				case "path_tumor1_ajcc_9th_pathologic_tnm_t":
				case "path_tumor1_ajcc_9th_pathologic_tnm_n":
				case "path_tumor1_ajcc_9th_pathologic_tnm_m":
					let tumor1TNM9stage = this.calcTNMStage(namespace, "path_tumor1_ajcc_9th_pathologic_tnm_t", "path_tumor1_ajcc_9th_pathologic_tnm_n", "path_tumor1_ajcc_9th_pathologic_tnm_m", 9);
					if(tumor1TNM9stage) this.updateTerm(namespace, "path_tumor1_ajcc_9th_pathologic_stage", tumor1TNM9stage);
					else this.updateTerm(namespace, "path_tumor1_ajcc_9th_pathologic_stage");
					break;
				// Tumor#2 TNM9
				case "path_tumor2_ajcc_9th_pathologic_tnm_t":
				case "path_tumor2_ajcc_9th_pathologic_tnm_n":
				case "path_tumor2_ajcc_9th_pathologic_tnm_m":
					let tumor2TNM9stage = this.calcTNMStage(namespace, "path_tumor2_ajcc_9th_pathologic_tnm_t", "path_tumor2_ajcc_9th_pathologic_tnm_n", "path_tumor2_ajcc_9th_pathologic_tnm_m", 9);
					if(tumor2TNM9stage) this.updateTerm(namespace, "path_tumor2_ajcc_9th_pathologic_stage", tumor2TNM9stage);
					else this.updateTerm(namespace, "path_tumor2_ajcc_9th_pathologic_stage");
					break;
				// Tumor#3 TNM9
				case "path_tumor3_ajcc_9th_pathologic_tnm_t":
				case "path_tumor3_ajcc_9th_pathologic_tnm_n":
				case "path_tumor3_ajcc_9th_pathologic_tnm_m":
					let tumor3TNM9stage = this.calcTNMStage(namespace, "path_tumor3_ajcc_9th_pathologic_tnm_t", "path_tumor3_ajcc_9th_pathologic_tnm_n", "path_tumor3_ajcc_9th_pathologic_tnm_m", 9);
					if(tumor3TNM9stage) this.updateTerm(namespace, "path_tumor3_ajcc_9th_pathologic_stage", tumor3TNM9stage);
					else this.updateTerm(namespace, "path_tumor3_ajcc_9th_pathologic_stage");
					break;
				// Tumor#4 TNM9
				case "path_tumor4_ajcc_9th_pathologic_tnm_t":
				case "path_tumor4_ajcc_9th_pathologic_tnm_n":
				case "path_tumor4_ajcc_9th_pathologic_tnm_m":
					let tumor4TNM9stage = this.calcTNMStage(namespace, "path_tumor4_ajcc_9th_pathologic_tnm_t", "path_tumor4_ajcc_9th_pathologic_tnm_n", "path_tumor4_ajcc_9th_pathologic_tnm_m", 9);
					if(tumor4TNM9stage) this.updateTerm(namespace, "path_tumor4_ajcc_9th_pathologic_stage", tumor4TNM9stage);
					else this.updateTerm(namespace, "path_tumor4_ajcc_9th_pathologic_stage");
					break;
				// Tumor#5 TNM9
				case "path_tumor5_ajcc_9th_pathologic_tnm_t":
				case "path_tumor5_ajcc_9th_pathologic_tnm_n":
				case "path_tumor5_ajcc_9th_pathologic_tnm_m":
					let tumor5TNM9stage = this.calcTNMStage(namespace, "path_tumor5_ajcc_9th_pathologic_tnm_t", "path_tumor5_ajcc_9th_pathologic_tnm_n", "path_tumor5_ajcc_9th_pathologic_tnm_m", 9);
					if(tumor5TNM9stage) this.updateTerm(namespace, "path_tumor5_ajcc_9th_pathologic_stage", tumor5TNM9stage);
					else this.updateTerm(namespace, "path_tumor5_ajcc_9th_pathologic_stage");
					break;
			}
		},

		// need to refactoring
		calYM_ER_CRF : function(term) {
			//console.log("ER CRF Auto Calculation Running");
			//console.log(term.termName);
			//console.log(term.value);
			if(term.termName === "conciousness") {
				this.crf.terms.forEach(compareTerm=>{
					if(compareTerm.termName === "gcs"){
						//console.log("find", compareTerm.value);
						let selectedValue = term.value[0];
						var beforeValue = compareTerm.termName + "_before_value";
						switch(selectedValue) {
						case '0':
							compareTerm.value = 15;
							if(this[beforeValue]){
								if(this[beforeValue] < 12){
									this.cogasScore--;
									this[beforeValue] = compareTerm.value;
								}else{
									this[beforeValue] = compareTerm.value;
								}
							}else{
								this[beforeValue] = compareTerm.value;
								
							}									
							break;
						case '1':
							compareTerm.value = 12;
							if(this[beforeValue]){
								if(this[beforeValue] < 12){
									this.cogasScore--;
									this[beforeValue] = compareTerm.value;
								}else{
									this[beforeValue] = compareTerm.value;
								}
							}else{
								this[beforeValue] = compareTerm.value;
								
							}			
							break;
						case '2':
							compareTerm.value = 10;
							if(this[beforeValue]){
								if(this[beforeValue] > 12){
									this.cogasScore++;
									this[beforeValue] = compareTerm.value;
								}else{
									this[beforeValue] = compareTerm.value;
								}
							}else{
								this.cogasScore++;
								this[beforeValue] = compareTerm.value;
							}			
							break;
						case '3':
							compareTerm.value = 8;
							if(this[beforeValue]){
								if(this[beforeValue] > 12){
									this.cogasScore++;
									this[beforeValue] = compareTerm.value;
								}else{
									this[beforeValue] = compareTerm.value;
								}
							}else{
								this.cogasScore++;
								this[beforeValue] = compareTerm.value;
							}		
							break;
						case '4':
							compareTerm.value = 5;
							if(this[beforeValue]){
								if(this[beforeValue] > 12){
									this.cogasScore++;
									this[beforeValue] = compareTerm.value;
								}else{
									this[beforeValue] = compareTerm.value;
								}
							}else{
								this.cogasScore++;
								this[beforeValue] = compareTerm.value;
							}		
							break;
						case '5':
							compareTerm.value = 3;
							if(this[beforeValue]){
								if(this[beforeValue] > 12){
									this.cogasScore++;
									this[beforeValue] = compareTerm.value;
								}else{
									this[beforeValue] = compareTerm.value;
								}
							}else{
								this.cogasScore++;
								this[beforeValue] = compareTerm.value;
							}		
							break;
						default:
							compareTerm.value = -1;
							if(this[beforeValue]){
								if(this[beforeValue] < 12){
									this.cogasScore--;
									this[beforeValue] = compareTerm.value;
								}else{
									this[beforeValue] = compareTerm.value;
								}
							}else{
								this[beforeValue] = compareTerm.value;
								
							}		
							break;
						}
						$("#" + compareTerm.termName).val(compareTerm.value).trigger('change');
					}
				});
			}
			
			if(term.termName === "shock") {
				if(this[beforeValue]){
					if(term.value[0] === '1' && this[beforeValue] !== '1'){
						this.cogasScore++;
						this[beforeValue] = term.value[0];
					}else{
						this.cogasScore--;
						this[beforeValue] = term.value[0];
					}
				}else{
					if(term.value[0] === '1'){
						this.cogasScore++;
						this[beforeValue] = term.value[0];
					}
				}
				
			}
	
			if(term.termName === "hbotTrial") {
				if(this[beforeValue]){
					if(term.value[0] === '0' && this[beforeValue] !== '0'){
						this.cogasScore++;
						this[beforeValue] = term.value[0];
					}else{
						this.cogasScore--;
						this[beforeValue] = term.value[0];
					}
				}else{
					if(term.value[0] === '0'){
						this.cogasScore++;
						this[beforeValue] = term.value[0];
					}
				}
				
			}
			
			if(term.termName === "ck_0") {
				if(this[beforeValue]){
					if(term.value[0] >= 320 && this[beforeValue] < 320){
						this.cogasScore++;
						this[beforeValue] = term.value[0];
					}else{
						this.cogasScore--;
						this[beforeValue] = term.value[0];
					}
				}else{
					if(term.value[0] >= 320){
						cogasScore++;
						this[beforeValue] = term.value[0];
					}
				}
				
			}
			
			if(this.cogasScore > 0){
				//console.log(this.cogasScore);
				$("#cogas_score").val(this.cogasScore).trigger('change');
			}
			
			if(term.termName === "out_hp_date"){
				this.crf.terms.forEach(compareTerm=>{
					if(compareTerm.termName === "visit_date"){
						let visitDate = new Date(compareTerm.value);
						let outDate = new Date(term.value)
						const diffDate = outDate.getTime() - visitDate.getTime();
						let totalDate = Math.abs(diffDate / (1000 * 60 * 60 * 24));
						$("#total_hp_date").val(totalDate).trigger('change');
					}
				});
			}
					
			if(term.termName === "alt_0"){
				this.crf.terms.forEach(compareTerm=>{
					if(compareTerm.termName === "alp_0"){
						var divValue = term.value / compareTerm.value;
						$("#alt_alp_0").val(divValue).trigger('change');
					}
				});
			}
			
			if(term.termName === "alp_0"){
				this.crf.terms.forEach(compareTerm=>{
					if(compareTerm.termName === "alt_0"){
						var divValue = term.value / compareTerm.value;
						$("#alt_alp_0").val(divValue).trigger('change');
					}
				});
			}
	
			if(term.termName === "alt_1"){
				this.crf.terms.forEach(compareTerm=>{
					if(compareTerm.termName === "alp_1"){
						var divValue = term.value / compareTerm.value;
						$("#alt_alp_1").val(divValue).trigger('change');
					}
				});
			}
			
			if(term.termName === "alp_1"){
				this.crf.terms.forEach(compareTerm=>{
					if(compareTerm.termName === "alt_1"){
						var divValue = term.value / compareTerm.value;
						$("#alt_alp_1").val(divValue).trigger('change');
					}
				});
			}
			
			if(term.termName === "alt_2"){
				this.crf.terms.forEach(compareTerm=>{
					if(compareTerm.termName === "alp_2"){
						var divValue = term.value / compareTerm.value;
						$("#alt_alp_2").val(divValue).trigger('change');
					}
				});
			}
			
			if(term.termName === "alp_2"){
				this.crf.terms.forEach(compareTerm=>{
					if(compareTerm.termName === "alt_2"){
						var divValue = term.value / compareTerm.value;
						$("#alt_alp_2").val(divValue).trigger('change');
					}
				});
			}
			
			if(term.termName === "first_hbot_time"){
				let hbotTime = new Date(term.value);
				this.crf.terms.forEach(compareTerm=>{
					if(compareTerm.termName === "detect_time"){
						let detectTime = new Date(compareTerm.value);
						var hour = (hbotTime.getTime() - detectTime.getTime()) / 3600000;
						$("#detect_to_1st_hbot").val(hour).trigger('change');
					}
					else if(compareTerm.termName === "hp_arrived"){
						let arrivedTime = new Date(compareTerm.value);
						var hour = (hbotTime.getTime() - arrivedTime.getTime()) / 3600000;
						$("#detect_to_1st_hbot").val(hour).trigger('change');
					}
				});
			}
			
			if(term.termName === "second_hbot_time"){
				let hbotTime = new Date(term.value);
				this.crf.terms.forEach(compareTerm=>{
					if(compareTerm.termName === "hp_arrived"){
						let arrivedTime = new Date(compareTerm.value);
						var divValue = term.value / compareTerm.value;
						$("#arrive_to_2nd_hbot").val(hour).trigger('change');
					}
				});
			}
			
			if(term.termName === "hp_hbot_num"){
				this.crf.terms.forEach(compareTerm=>{
					if(compareTerm.termName === "out_hbot_num"){
						var total = term.value + compareTerm.value;
						$("#total_hbot").val(total).trigger('change');
					}
				});
			}						
	
			if(term.termName === "lymphocyte_0"){
				this.crf.terms.forEach(compareTerm=>{
					if(compareTerm.termName === "neutropil_0"){
						var divValue = term.value / compareTerm.value;
						$("#nrl_0").val(hour).trigger('change');
					}
					else if(compareTerm.termName === "monocyte_0"){
						var divValue = term.value / compareTerm.value;
						$("#mlr_0").val(hour).trigger('change');
					}
					else if(compareTerm.termName === "plt_0"){
						var divValue = term.value / compareTerm.value;
						$("#plr_0").val(hour).trigger('change');
					}
				});
			}
			
		},
		
		// need to refactoring
		calYM_EX_CRF: function(term) {
			//console.log("Exercise CRF Auto Calculation Running");
			var beforeValue = term.termName + "_before_value";
	
			switch(term.termName){
				case "running_selection":
					if(this.gender == 0 && term.value[0] === '3'){
						$("#treadmill_9min_outerDiv").show();
					}
					break;
				case "drug_diabetes":
					if(term.value[0] === '1'){
						this.crf.terms.forEach(compareTerm=>{
							if(compareTerm.termName === "diabetes"){
								compareTerm.value = "1";
								$("#" + compareTerm.termName).val(compareTerm.value).trigger('change');
							}else if(compareTerm.termName === "is_high_risk"){
								compareTerm.value = "0";
								$("#" + compareTerm.termName).val(compareTerm.value).trigger('change');
							}
						});
					}else{
						let highriskContentArr = new Array();
						this.crf.terms.forEach(compareTerm=>{
							if(compareTerm.termName === "diabetes"){
								compareTerm.value = "0";
								$("#" + compareTerm.termName).val(compareTerm.value).trigger('change');							
							}
							if(compareTerm.termName === "drug_thyroid" || compareTerm.termName === "drug_cv" || compareTerm.termName === "drug_a_c" || compareTerm.termName === "drug_lung" || compareTerm.termName === "drug_respiratory" || compareTerm.termName === "drug_liver"){
								//console.log("comparing term",compareTerm.value);
								highriskContentArr.push(compareTerm.value);												
							}
							
						});
						for(const index in highriskContentArr){
							//console.log("highriskContentArr", highriskContentArr);
							//console.log("highriskContentArr", highriskContentArr[index][0]);
							if(highriskContentArr[index][0] !== "0"){
								$("#is_high_risk").val("0").trigger('change');
								break;
							}else{
								$("#is_high_risk").val("1").trigger('change');
							}
						}
					}
					break;
				case "waist_measurement":
					if(this.gender == 0) {
						if(this[beforeValue]){
							if(this[beforeValue] < 90 && term.value >= 90) {
								if(this.metabolicCount < 5){
									this.metabolicCount++;
									this[beforeValue] = term.value;
								}
							}else if(this[beforeValue] > 90 && term.value < 90){
								if(this.metabolicCount > 0){
									this.metabolicCount--;
									this[beforeValue] = term.value;
								}
							}else{
								this[beforeValue] = term.value;
							}
						}else{
							//console.log("dont have beforeValue");
							if(term.value >= 85) {
								if(this.metabolicCount < 5){
									this.metabolicCount++;
									this[beforeValue] = term.value;
								}
							}else{
								this[beforeValue] = term.value;
							}										
						}
					}else{
						if(this[beforeValue]){
							if(this[beforeValue] < 85 && term.value >= 85) {
								if(this.metabolicCount < 5){
									this.metabolicCount++;
									this[beforeValue] = term.value;
								}
							}else if(this[beforeValue] > 85 && term.value < 85){
								if(this.metabolicCount > 0){
									this.metabolicCount--;
									this[beforeValue] = term.value;
								}
							}else{
								this[beforeValue] = term.value;
							}
						}else{
							//console.log("dont have beforeValue");
							if(term.value >= 85) {
								if(this.metabolicCount < 5){
									this.metabolicCount++;
									this[beforeValue] = term.value;
								}
							}else{
								this[beforeValue] = term.value;
							}										
						}
					}
					break;
	
				case "myocardial_infarction":
					if(this[beforeValue]){
						if(term.value[0] === '1' && term.value[0] !== this[beforeValue]) {
							if(this.riskCount < 10){
								this.riskCount++;
								this[beforeValue] = term.value[0];
							}
						}else{
							if(this.riskCount > 0){
								this.riskCount--;
								this[beforeValue] = term.value[0];
							}
						}
					}else{
						if(term.value[0] === '1') {
							if(this.riskCount < 10){
								this.riskCount++;
								this[beforeValue] = term.value[0];
							}
						}else{
							this[beforeValue] = term.value[0];
						}
					}
					break;
				case "smoke":
					if(this[beforeValue]){
						if((term.value[0] === '2' || term.value[0] === '3' || term.value[0] === '4' || term.value[0] === '5' || term.value[0] === '6') && (this[beforeValue] === '-1' || this[beforeValue] === '1')) {
							if(this.riskCount < 10){
								this.riskCount++;
								this[beforeValue] = term.value[0];
							}
						}else if((term.value[0] === '2' || term.value[0] === '3' || term.value[0] === '4' || term.value[0] === '5' || term.value[0] === '6') && (this[beforeValue] === '2' || this[beforeValue] === '3' || this[beforeValue] === '4' || this[beforeValue] === '5' || this[beforeValue] === '6')){
							this[beforeValue] = term.value[0];
						}else{
							if(this.riskCount > 0){
								this.riskCount--;
								this[beforeValue] = term.value[0];
							}
						}
					}else{
						if(term.value[0] === '2' || term.value[0] === '3' || term.value[0] === '4' || term.value[0] === '5' || term.value[0] === '6') {
							if(this.riskCount < 10){
								this.riskCount++;
								this[beforeValue] = term.value[0];
							}
						}else{
							this[beforeValue] = term.value[0];
						}
					}
					break;
				case "sedentary_life":
					if(this[beforeValue]){
						if(term.value[0] === '1' && term.value[0] !== this[beforeValue]) {
							if(this.riskCount < 10){
								this.riskCount++;
								this[beforeValue] = term.value[0];
							}
						}else{
							if(this.riskCount > 0){
								this.riskCount--;
								this[beforeValue] = term.value[0];
							}
						}
					}else{
						if(term.value[0] === '1') {
							if(this.riskCount < 10){
								this.riskCount++;
								this[beforeValue] = term.value[0];
							}
						}else{
							this[beforeValue] = term.value[0];
						}
					}
					break;
				case "middle_stomach":
					if(this.gender == 0) {
						if(this[beforeValue]){
							if(this[beforeValue] < 90 && term.value >= 90) {
								if(this.riskCount < 10){
									this.riskCount++;
									this[beforeValue] = term.value;
								}
							}else if(this[beforeValue] >= 90 && term.value < 90){
								if(this.riskCount > 0){
									this.riskCount--;
									this[beforeValue] = term.value;
								}
							}else{
								this[beforeValue] = term.value;
							}
						}else{
							//console.log("dont have beforeValue");
							if(term.value >= 90) {
								if(this.riskCount < 10){
									this.riskCount++;
									this[beforeValue] = term.value;
								}
							}else{
								this[beforeValue] = term.value;
							}										
						}
					}else{
						if(this[beforeValue]){
							if(this[beforeValue] < 80 && term.value >= 80) {
								if(this.riskCount < 10){
									this.riskCount++;
									this[beforeValue] = term.value;
								}
							}else if(this[beforeValue] >= 80 && term.value < 80){
								if(this.riskCount > 0){
									this.riskCount--;
									this[beforeValue] = term.value;
								}
							}else{
								this[beforeValue] = term.value;
							}
						}else{
							//console.log("dont have beforeValue");
							if(term.value >= 80) {
								if(this.riskCount < 10){
									this.riskCount++;
									this[beforeValue] = term.value;
								}
							}else{
								this[beforeValue] = term.value;
							}										
						}
					}
					break;
				case "survey_sbp":
					if(this[beforeValue]){
						if(this[beforeValue] < 140 && term.value >= 140) {
							if(this.riskCount < 10){
								this.riskCount++;
								if(this[beforeValue] < 130){
									if(this.metabolicCount < 5){
										this.metabolicCount++;
									}
								}
								this[beforeValue] = term.value;
							}
							
						}else if(this[beforeValue] >= 130 && term.value < 140){
							if(this.riskCount > 0){
								this.riskCount--;
								this[beforeValue] = term.value;
							}
							if(term.value < 130){
								if(this.metabolicCount > 0){
									this.metabolicCount--;
									this[beforeValue] = term.value;
								}
							}
						}else{
							this[beforeValue] = term.value;
						}
					}else{
						//console.log("dont have beforeValue");
						if(term.value >= 140) {
							if(this.riskCount < 10){
								this.riskCount++;
								this[beforeValue] = term.value;
							}
							if(this.metabolicCount < 5){
								this.metabolicCount++;
								this[beforeValue] = term.value;
							}
						}else if(term.value >= 130){
							if(this.metabolicCount < 5){
								this.metabolicCount++;
								this[beforeValue] = term.value;
							}
						}else{
							this[beforeValue] = term.value;
						}										
					}
					break;
				case "survey_dbp":
					if(this[beforeValue]){
						if(this[beforeValue] < 90 && term.value >= 90) {
							if(this.riskCount < 10){
								this.riskCount++;
								this[beforeValue] = term.value;
							}
						}else if(this[beforeValue] >= 90 && term.value < 90){
							if(this.riskCount > 0){
								this.riskCount--;
								this[beforeValue] = term.value;
							}
						}else{
							this[beforeValue] = term.value;
						}
					}else{
						//console.log("dont have beforeValue");
						if(term.value >= 90) {
							if(this.riskCount < 10){
								this.riskCount++;
								this[beforeValue] = term.value;
							}
						}else{
							this[beforeValue] = term.value;
						}										
					}
					break;
				case "tc":
					if(this[beforeValue]){
						if(this[beforeValue] < 200 && term.value >= 200) {
							if(this.riskCount < 10){
								this.riskCount++;
								this[beforeValue] = term.value;
							}
						}else if(this[beforeValue] >= 200 && term.value < 200){
							if(this.riskCount > 0){
								this.riskCount--;
								this[beforeValue] = term.value;
							}
						}else{
							this[beforeValue] = term.value;
						}
					}else{
						//console.log("dont have beforeValue");
						if(term.value >= 200) {
							if(this.riskCount < 10){
								this.riskCount++;
								this[beforeValue] = term.value;
							}
						}else{
							this[beforeValue] = term.value;
						}										
					}
					break;
				case "survey_glu_fasting":
					if(this[beforeValue]){
						if(this[beforeValue] < 100 && term.value >= 100) {
							if(this.riskCount < 10){
								this.riskCount++;
								this.metabolicCount++;
								this[beforeValue] = term.value;
							}
						}else if(this[beforeValue] >= 100 && term.value < 100){
							if(this.riskCount > 0){
								this.riskCount--;
								this.metabolicCount--;
								this[beforeValue] = term.value;
							}
						}else{
							this[beforeValue] = term.value;
						}
					}else{
						//console.log("dont have beforeValue");
						if(term.value >= 100) {
							if(this.riskCount < 10){
								this.riskCount++;
								this.metabolicCount++;
								this[beforeValue] = term.value;
							}
						}else{
							this[beforeValue] = term.value;
						}										
					}
					break;
				case "survey_glu_postprandial":
					if(this[beforeValue]){
						if(this[beforeValue] < 140 && term.value >= 140) {
							if(this.riskCount < 10){
								this.riskCount++;
								this.metabolicCount++;
								this[beforeValue] = term.value;
							}
						}else if(this[beforeValue] >= 140 && term.value < 140){
							if(this.riskCount > 0){
								this.riskCount--;
								this.metabolicCount--;
								this[beforeValue] = term.value;
							}
						}else{
							this[beforeValue] = term.value;
						}
					}else{
						//console.log("dont have beforeValue");
						if(term.value >= 140) {
							if(this.riskCount < 10){
								this.riskCount++;
								this.metabolicCount++;
								this[beforeValue] = term.value;
							}
						}else{
							this[beforeValue] = term.value;
						}										
					}
					break;
				case "hdl":
					if(this.gender == 0) {
						if(this[beforeValue]){
							if(this[beforeValue] > 40 && term.value <= 40) {
								if(this.metabolicCount < 5){
									this.metabolicCount++;
									this[beforeValue] = term.value;
								}
							}else if(this[beforeValue] < 40 && term.value > 40){
								if(this.metabolicCount > 0){
									this.metabolicCount--;
									this[beforeValue] = term.value;
								}
							}else{
								this[beforeValue] = term.value;
							}
						}else{
							//console.log("dont have beforeValue");
							if(term.value < 40) {
								if(this.metabolicCount < 5){
									this.metabolicCount++;
									this[beforeValue] = term.value;
								}
							}else{
								this[beforeValue] = term.value;
							}										
						}
					}else{
						if(this[beforeValue]){
							if(this[beforeValue] > 50 && term.value <= 50) {
								if(this.metabolicCount < 5){
									this.metabolicCount++;
									this[beforeValue] = term.value;
								}
							}else if(this[beforeValue] <= 50 && term.value < 50){
								if(this.metabolicCount > 0){
									this.metabolicCount--;
									this[beforeValue] = term.value;
								}
							}else{
								this[beforeValue] = term.value;
							}
						}else{
							//console.log("dont have beforeValue");
							if(term.value < 50) {
								if(this.metabolicCount < 5){
									this.metabolicCount++;
									this[beforeValue] = term.value;
								}
							}else{
								this[beforeValue] = term.value;
							}										
						}
					}
					break;
				case "drug_thyroid":
				case "drug_cv":
				case "drug_a_c":
				case "drug_lung":
				case "drug_respiratory":
				case "drug_liver":
				case "drug_kidney_ureter":
					if(term.value[0] === '1'){
						this.crf.terms.forEach(compareTerm=>{
							if(compareTerm.termName === "is_high_risk"){
								compareTerm.value = "0";
								$("#" + compareTerm.termName).val(compareTerm.value).trigger('change');
							}
						});
					}else{
						let highriskContentArr = new Array();
						this.crf.terms.forEach(compareTerm=>{
							if(compareTerm.termName === "drug_thyroid" || compareTerm.termName === "drug_cv" || compareTerm.termName === "drug_a_c" || compareTerm.termName === "drug_lung" || compareTerm.termName === "drug_respiratory" || compareTerm.termName === "drug_liver" || compareTerm.termName === "diabetes"){
								//console.log("comparing term", compareTerm.value);
								highriskContentArr.push(compareTerm.value);												
							}
							
						});
						for(const index in highriskContentArr){
							//console.log("highriskContentArr", highriskContentArr);
							//console.log("highriskContentArr", highriskContentArr[index][0]);
							if(highriskContentArr[index][0] !== "0"){
								$("#is_high_risk").val("0").trigger('change');
								break;
							}else{
								$("#is_high_risk").val("1").trigger('change');
							}
						}
					}
					break;
				case "fitness_hand_grip":
					if(this.gender == 0){
						if(term.value < 27){
							$("#is_sarcopenia_ewgsop2").val("1").trigger('change');
							$("#is_sarcopenia_awgs2").val("1").trigger('change');
						}else if(term.value < 28){
							$("#is_sarcopenia_awgs2").val("1").trigger('change');
						}
					}else{
						if(term.value < 16){
							$("#is_sarcopenia_ewgsop2").val("1").trigger('change');
							$("#is_sarcopenia_awgs2").val("1").trigger('change');
						}else if(term.value < 18){
							$("#is_sarcopenia_awgs2").val("1").trigger('change');
						}
					}
					
				case "walking_6m":
					if(term.value < 0.8){
						$("#is_low_physical_performance_awgs2").val("1").trigger('change');
						$("#is_low_physical_performance_ewgsop2").val("1").trigger('change');
					}else if(term.value < 1.0){
						$("#is_low_physical_performance_awgs2").val("1").trigger('change');
					}
					break;
				case "inbody_height":
					$("#sarcopenia_height").val(term.value).trigger('change');
					break;
				case "inbody_weight":
					$("#sarcopenia_weight").val(term.value).trigger('change');
					break;
				case "alm":
					let alm_val = term.value;
					let height = 0;
					let weight = 0;
					this.crf.terms.forEach(compareTerm=>{
						if(compareTerm.termName === "inbody_height"){
							if(compareTerm.value){
								height = compareTerm.value;
							}
						}else if (compareTerm.termName === "inbody_weight"){
							if(compareTerm.value){
								weight = compareTerm.value;
							}
						}
					});
					let bmi = weight / (height*height);
					let alm_height = alm_val / (height*height);
					let alm_bmi = alm_val / bmi;
					//TODO: exception control
					$("#alm_ht_div").val(alm_height).trigger('change');
					$("#alm_bmi_div").val(alm_bmi).trigger('change');
					if(this.gender == 0){
						if(alm_height < 7.0){
							$("#is_alm_ht_div_awgs").val("1").trigger('change');
							$("#is_alm_ht_div_ewgsop2").val("1").trigger('change');
						}else if(alm < 20){
							$("#is_alm_ht_div_ewgsop2").val("1").trigger('change');
						}
						if(alm_bmi < 0.789){
							$("#is_low_alm_bmi_div").val("1").trigger('change');
						}
					}else{
						if(alm_height < 5.5){
							$("#is_alm_ht_div_awgs").val("1").trigger('change');
							$("#is_alm_ht_div_ewgsop2").val("1").trigger('change');
						}else if(alm < 15){
							$("#is_alm_ht_div_ewgsop2").val("1").trigger('change');
						}
						if(alm_bmi < 0.512){
							$("#is_low_alm_bmi_div").val("1").trigger('change');
						}
					}
					break;
				case "bone_density_num":
					//console.log(term.value, typeof term.value);
					if(term.value >= -1){
						$("#is_osteoporosis").val("0").trigger('change');
					}else if(term.value <= -2.5){
						$("#is_osteoporosis").val("2").trigger('change');
					}else{
						$("#is_osteoporosis").val("1").trigger('change');
					}
					break;
				case "depression_grade":
					var isElderly = false;
					if(this.age >= 65) isElderly = true;
					if(isElderly){
						if(term.value <= 14){
							$("#bdi_depress_grade").val("0").trigger('change');
						}else if(term.value <= 18){
							$("#bdi_depress_grade").val("1").trigger('change');
						}else if(term.value <= 21){
							$("#bdi_depress_grade").val("2").trigger('change');
						}else{
							$("#bdi_depress_grade").val("3").trigger('change');
						}
					}else{
						if(term.value <= 9){
							$("#bdi_depress_grade").val("0").trigger('change');
						}else if(term.value <= 15){
							$("#bdi_depress_grade").val("1").trigger('change');
						}else if(term.value <= 23){
							$("#bdi_depress_grade").val("2").trigger('change');
						}else{
							$("#bdi_depress_grade").val("3").trigger('change');
						}
					}
					break;
			}
		
			//console.log("metabolic : " , this.metabolicCount, "risk : ", this.riskCount);		
			if(this.metabolicCount >= 3){
				//console.log("metaBolic ON");
				$("#is_high_risk_metabolic").val("0").trigger('change');
			}else{
				$("#is_high_risk_metabolic").val("1").trigger('change');
			}
			
			if(this.riskCount == 1){
				//console.log("lowRisk ON");
				$("#is_low_risk").val("0").trigger('change');
			}else if(this.riskCount > 1){
				$("#is_low_risk").val("0").trigger('change');
				$("#is_mid_risk").val("0").trigger('change');
				//console.log("lowRisk ON");
				//console.log("midRisk ON");
			}else{
				$("#is_low_risk").val("1").trigger('change');
				$("#is_mid_risk").val("1").trigger('change');
			}
		},

		/*
		 * check age & gender for hide term or change value of exercise crf
		 */ 
		checkExcerciseFlag : function(termName){
			switch(termName){
				case "diabetes":
				case "is_low_risk":
				case "is_mid_risk":
					if(this.age > 65){
						$("#is_mid_risk").val("0").trigger('change');
					}
				case "is_high_risk":
				case "is_high_risk_metabolic":
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
					break;
				case "treadmill_9min":
					if(this.gender == 1){
						$("#treadmill_9min_outerDiv").hide();
					}
				case "long_term_round_run_15m":
					if(this.age > 10 && this.age < 13){
						return false;
					}else{
						return true;
					}
					break;
				case "running_selection":
				case "dexterity_adult_selection":
					if(this.age > 12 && this.age < 65){
						return false;
					}else{
						return true;
					}
					break;
				case "jump_or_sit_up_selection":	
				case "time_of_flight":
				case "eye_hand_coordination_sec":
				case "eye_hand_coordination_repeat":
				case "illinois_agility":
					if(this.age > 12 && this.age < 19){
						return false;
					}else{
						return true;
					}
					break;
				case "third_by_third_button_press":	
				case "shuttle_run_5m":
					if(this.age < 11){
						return false;
					}else{
						return true;
					}
					break;
				case "wall_pass":
				case "repeat_side_jump":
					if(this.age>10 && this.age < 13){
						return false;
					}else{
						return true;
					}
					break;
				case "standing_long_jump":
					if(this.age >19 && this.age < 13){
						return false;
					}else{
						return true;
					}
					break;
				case "lower_limb_function":
				case "walking_6min":
				case "walking_2min":
				case "equilibrium_property":
				case "coordination_elderly":
					if(this.age>64){
						return false;
					}else{
						return true;
					}
					break;
				case "cardio_pulmonary_function":
					if(this.age > 10 && this.age < 65){
						return false;
					}else{
						return true;
					}
					break;
				case "dexterity":
					if(this.age < 65){
						return false;
					}else{
						return true;
					}
					break;
				case "bdi_depress_grade":
					if(this.age < 65){
						return false;
					}else{
						return true;
					}
					break;
				case "kgds_depress_grade":
					if(this.age >= 65){
						return false;
					}else{
						return true;
					}
					break;
				case "KGDS_GROUP":
					if(this.age >= 65){
						return false;
					}else{
						return true;
					}
					break;
				case "SF6D_GROUP":
					if(this.age < 65){
						return false;
					}else{
						return true;
					}
					break;
				case "BDI_GROUP":
					if(this.age < 65){
						return false;
					}else{
						return true;
					}
					break;
				case "menopause":
					if(this.gender == 0){
						
						return true;
					}
					return false;
					break;
				default:
					return false;
					break;
			}
			
		},

		/**
		 * 
		 * @param {string} termId 
		 * @param {*} value //TODO: need to consider term type
		 * @param {string} namespace 
		 */
		updateTerm: function(namespace, termId, value="") {
			let targetTerm = $('#'+namespace+termId);
			if(targetTerm) {	// null check
				targetTerm.val(value).trigger('change');
			}
		}

	}
	
	

	/*
	 * 
	 * for render Smart CRF UI on canvas
	 * 
	 */

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
        flattenTerms : function (terms) {
            terms.sort((a, b) => a.order - b.order);
            return terms;
        },
        buildGroupTerm : function(terms, term){
        	let displayName = term.displayName.localizedMap.en_US;
        	let $GroupOuterDiv = $('<div>');
        	$GroupOuterDiv.prop({
        		id:term.termName + "_outerDiv"
        	});
        	let $accordionTab = $('<div class="card-horizontal main-content-card" style="min-height:0px;">');
        	if(this.isAudit){
        		$accordionTab = $('<div class="card-horizontal main-content-card pad1R">');
        	}
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
			if(!this.isAudit){
				$accordionTab.accordion({
	                collapsible: true,
					highStyle: 'content',
					disabled: false,
					active: false,
					activate: function(event, ui){
						ui.newPanel.css('height', 'auto');
					}
	            });
			}
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
				//console.log("is Grid", term);
				
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
					//console.log("add btn clicked");
					//console.log(term.termName);
					let gridTable = document.getElementById(term.termName);
					term.rowIndex = gridTable.childNodes[1].childNodes.length + 1;
					//console.log(term.rowIndex);
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
						//console.log(dataPacket);
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
				if(this.isAudit){
					$inputLabel.append(this.buildTermAuditValue(term));
				}else{
					$inputLabel.append(this.buildTermInput(term));
				}
			}
			$section.append($inputLabel);
			
			return $container;
        },
        buildTermAuditValue : function(term){
			let $inputTag = $('<p class="field form-control">');
			$inputTag.prop({
				id: term.termName,
				name: term.termName
			});
			
			var termValue = "non-execution";
			if(term.termType === "List"){
				term.options.forEach(option => {
					if(term.value == option.value){
						termValue = option.label.localizedMap.en_US;
					}
				});
			}else if(term.termType === "Date"){
				var temp = new Date(term.value);
				//console.log("Date", temp);
				if(term.value) termValue = temp.getFullYear() + "/" + temp.getMonth() + "/" + temp.getDay();
			}else if(term.termType === "File"){
				
			}
			else{
				if(term.value) termValue = term.value;
			}
			let $outerDiv = $('<div>'); 
			$inputTag.append(termValue);
			if(termValue !== "non-execution"){
				$inputTag.attr('onclick', 'openHistoryDialog("'+ term.termName + '", "' + term.displayName.localizedMap.en_US + '")');
			}
			$outerDiv.append($inputTag);
        	return $outerDiv;
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
							//console.log( 'get value: ', term.value);
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
					if(term.placeHolder){
						//console.log("has placeHolder", term.placeHolder.localizedMap.en_US);
						let $nonExecutionTag = $('<option>');
						$nonExecutionTag.prop({
							disabled: true,
							selected: true,
							hidden: true
						});
						$nonExecutionTag.text(term.placeHolder.localizedMap.en_US);
						$inputTag.append($nonExecutionTag);
					}
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
							//console.log( 'get value: ', term.value);
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
						let check = false;
						if(term.value){
							if(term.value[0] === option.value && term.value !== "-1"){								
								check = true;
							}
						}
						$radioTag.prop({
							class :"field marLr",
							id: term.termName + "_" + index,
							name: term.termName,
							disabled: term.disabled,
							value: option.value,
							checked: check
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

						//console.log( 'get value: ', term.value);
						let dataPacket = new EventDataPacket();
						dataPacket.term = term;
						const eventData = {
							dataPacket: dataPacket
						};
						
						Liferay.fire( 'value_changed', eventData );		
					});
				}else {	// for Checkbox
					//console.log(term);
					let controlName = term.termName;
					
					$inputTag = $('<fieldset style="width:fit-content;max-width:100%;border: 1px solid #aaa; box-shadow: 2px 2px #ccc;">').prop({
						'id': controlName,
						'name': controlName
					});

					// create checkbox for each option
					term.options.forEach((option, index)=> {
						let controlId = controlName+'_'+(index+1);
						let value = option.value;
						let labelText = option.label.localizedMap.en_US;	// TODO: need to change depend on language
						let selected = term.hasValue() ? term.value.includes(option.value) : false;

						let $checkbox = $( '<div class="checkbox" style="display:inline-block;margin-left:10px;margin-right:20px;">' );
						let $label = $( '<label style="font-size:0.8rem;font-weight:400;">' ).prop( 'for', controlId ).appendTo( $checkbox );
						let $input = $( '<input type="checkbox" style="display:inline-block;margin-right:10px;background-color:white;">').appendTo( $label );
						$input.prop({
							class: "field",
							id: controlId,
							name: controlName,
							value: value,
							checked: selected,
							disabled: term.disabled
						});

						$label.append( labelText );

						$inputTag.append($checkbox);
					});
					
					let stationX = SX.StationX;
					//console.log(stationX);

					// event handling when checkbox changed
					$inputTag.change(function(event) {
						event.stopPropagation();

						let checkedValues = new Array();

						$.each( $(this).find('input[type="checkbox"]:checked'), function() {
							checkedValues.push($(this).val() );
						});

						//console.log("list checkbox changed ", checkedValues);
						
						term.value = checkedValues;

						let dataPacket = new EventDataPacket();
						dataPacket.term = term;
						dataPacket.attribute = 'value';
						dataPacket.value = checkedValues;
						dataPacket.$source = $(this);
						const eventData = {
							dataPacket: dataPacket
						};
						
						//console.log(eventData);

						Liferay.fire( 'value_changed', eventData );
					});
				}
				break;
			case "Boolean":
				if(term.displayStyle === "select"){
					$inputTag = $( '<select class="form-control">' );
					if(term.placeHolder){
						//console.log("has placeHolder", term.placeHolder.localizedMap.en_US);
						let $nonExecutionTag = $('<option>');
						$nonExecutionTag.prop({
							disabled: true,
							selected: true,
							hidden: true
						});
						$nonExecutionTag.text(term.placeHolder.localizedMap.en_US);
						$inputTag.append($nonExecutionTag);
					}
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
					
					let booleanEventFuncs = {
						change: function( event ){
							event.stopPropagation();
	
							term.value = $('#'+term.termName).val();
							//console.log( 'get value: ', term.value);
							let dataPacket = new EventDataPacket();
							dataPacket.term = term;
							const eventData = {
								dataPacket: dataPacket
							};
							
							Liferay.fire( 'value_changed', eventData );					
						}
					};
				Object.keys( booleanEventFuncs ).forEach( event => {
					$inputTag.on( event, booleanEventFuncs[event] );
				});
				}else if(term.displayStyle === "radio"){
					$inputTag = $('<label>');
					let index = 1;
					term.options.forEach((option)=>{
						let $radioTag = $( '<input type="radio">' );
						let check = false;
						if(term.value != null){
							if(term.value === option.value && term.value !== "-1"){	
								check = true;
							}
						}
						$radioTag.prop({
							class :"field marLr",
							id: term.termName + "_" + index,
							name: term.termName,
							disabled: term.disabled,
							value: option.value,
							checked: check
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

						//console.log( 'get value: ', term.value);
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
				//console.log("has termvalue?", term.value);
				
				if(term.value){
					for(const key in term.value){
						$fileProfile = $('<td>');
						//console.log("has termvalue 1?", key);
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
			            //console.log("dataTransfer =>", dataTransfer.files);
			            //console.log("input FIles =>", $(this)[0].files);
				 	}
					
					//console.log( 'get value: ', $(this)[0].files);
					
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
					
					//console.log(term.value);
					if(term.value.constructor.length > 0){
						fileTermValue = term.value;
					}
					let toObj = new Object();
				
					for(var i = 0; i < dataTransfer.files.length; i++){
						let data = dataTransfer.files[i];
						//console.log(data);
						toObj["size"] = data.size;
						toObj["parentFolderId"] = 0;
						toObj["name"] = data.name;
						toObj["type"] = data.type;
						toObj["fileId"] = 0;
					}
					
					fileTermValue[toObj["name"]] = toObj;
					//console.log(fileTermValue);
					
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
							//console.log( 'get value: ', termValue);
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
							//console.log(gridTermFormat);
							let dataPacket = new EventDataPacket();
							dataPacket.term = gridTerm;
							//console.log(dataPacket);
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
						//console.log(gridTermFormat);
						
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
							//console.log( 'get value: ', termValue);
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
							//console.log(gridTermFormat);
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
			
			if(this.isAudit){
				let $inputTag = $('<p class="field form-control">');
				$inputTag.prop({
					id: term.termName,
					name: term.termName
				});
				
				var termValue = "non-execution";
				if(term.termType === "List"){
					term.options.forEach(option => {
						if(cellValue == option.value){
							termValue = option.label.localizedMap.en_US;
						}
					});
				}else if(term.termType === "Date"){
					
				}else if(term.termType === "File"){
					
				}
				else{
					if(term.value) termValue = cellValue;
				}
				let $outerDiv = $('<div>'); 
				$inputTag.append(termValue);
				if(termValue !== "non-execution"){
					$inputTag.attr('onclick', 'openHistoryDialog("'+ term.termName + '", "' + term.displayName.localizedMap.en_US + '")');
				}
				$outerDiv.append($inputTag);
	        	return $outerDiv;
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
				//console.log(option)
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
        	//console.log("isSlaveTerm query", $("#"+termName+"_outerDiv"));
        	if( activeFlag ){
        		$("#"+termName+"_outerDiv").show();
			}
			else{
				$("#"+termName+"_outerDiv").hide();
	        	//console.log("hided", $("#"+termName));
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
		constructor( sourcePortlet, targetPortlet ){
			this.sourcePortlet = sourcePortlet;
			this.targetPortlet = targetPortlet;
		}

		isTargetPortlet(ns){
			return this.targetPortlet === ns;
		}

		parse( jsonObj ){
			Object.keys(jsonObj).forEach( key => {
				this[key] = jsonObj[key];
			});
		}

		toJSON(){
			let json = new Object();

			for(let key in this){
				json[key] = this[key];
			};

			return json;
		}
	}

    return {
        Viewer : Viewer,
        renderUtil : renderUtil,
        autoCalUtil : autoCalUtil
    }
};