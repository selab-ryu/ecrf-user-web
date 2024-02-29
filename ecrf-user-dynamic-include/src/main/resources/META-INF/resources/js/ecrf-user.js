function dateMilToFormat(miliSecond) {
	let date = new Date(miliSecond);
	let dateStr = date.getFullYear() + "/";
	dateStr += ( (date.getMonth() + 1) > 9 ? (date.getMonth()+1).toString() : "0" + (date.getMonth()+1) ) + "/"; 
	dateStr += (date.getDate() > 9 ? date.getDate().toString() : "0" + date.getDate().toString() );
	return dateStr;
}

function dateCheck(startDateId, endDateId, namespace) {
	console.group("dateCheck Function");
	var fromDate;
	var toDate;
	
	var isValidDate = false;
	var isStart = false;
	var isEnd = false;
		
	console.log(namespace);
	
	var fromDateObj = document.getElementById(namespace+startDateId);
	if(fromDateObj.value !== "") {
		fromDate = new Date(fromDateObj.value);
		isStart = true;
	} else {
		isValidDate = true;
	}
	
	var toDateObj = document.getElementById(namespace+endDateId);
	if(toDateObj.value !== "") {
		toDate = new Date(toDateObj.value);
		isEnd = true;	
	} else {
		isValidDate = true;
	}
	
	//alert("is start / end : " + isStart + " / " + isEnd )
	console.log("is start / end : " + isStart + " / " + isEnd )
	
	if(isStart && isEnd) {
		isValidDate = (toDate.getTime() > fromDate.getTime());
	} else {
		isValidDate = true;
	}
	console.groupEnd();
	return isValidDate;
}

function dateMilToFormat(miliSecond) {
	let date = new Date(miliSecond);
	let dateStr = date.getFullYear() + "/";
	dateStr += ( (date.getMonth() + 1) > 9 ? (date.getMonth()+1).toString() : "0" + (date.getMonth()+1) ) + "/"; 
	dateStr += (date.getDate() > 9 ? date.getDate().toString() : "0" + date.getDate().toString() );
	return dateStr;
}

function genderToStr(gender) {
	let str = "Male";
	if(gender == 1) {
		str = "Female";
	}
	return str;
}