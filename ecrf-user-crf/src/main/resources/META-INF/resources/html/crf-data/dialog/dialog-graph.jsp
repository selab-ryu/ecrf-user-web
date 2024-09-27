<%@ include file="../../init.jsp" %>

<%! private Log _log = LogFactoryUtil.getLog("html/crf-data/dialog/dialog-graph_jsp"); %>

<%
// Received column names and number to put in graph
String type = (String)renderRequest.getAttribute("type");

String[] datas;
int[] values;
List<Double> listDouble = new ArrayList<>();
List<String> listString = new ArrayList<String>();
List<Integer> listInt = new ArrayList<>();
listDouble.add(1.1);
if(type != "empty"){
	datas = (String[])renderRequest.getAttribute("datas");
	values = (int[])renderRequest.getAttribute("values");

	
	_log.info("hi:" + datas);
	if(type.equals("Numeric")){
		listDouble = new ArrayList<>();
		for(String i : datas) {
			listDouble.add(Double.parseDouble(i));
		}
		_log.info("hi:" + listDouble);
	}
	else if(type.equals("List")){
		for(String i : datas) {
			listString.add(i);
		}
		for(Integer i : values) {
			listInt.add(i);
		}
	}
}


BarChartConfig _barChartConfig = new BarChartConfig();
LineChartConfig _lineChartConfig = new LineChartConfig();
DonutChartConfig _donutChartConfig = new DonutChartConfig();

%>

<div class="ecrf-user-crf-data ecrf-user">
	<aui:container cssClass="">
		
		<!-- Radio button that outputs graphs by type -->
		<aui:row cssClass="marVr">
			<aui:col md="12" cssClass="text-right">
				<input type="radio" id = "radio_bar" name = "radio" value = "1" checked = "true">
				<label for= 'radio_bar' style="font-weight: bold;font-size: 1rem;">Bar</label>
				<input type="radio" id = "radio_line" name = "radio" value = "2">
				<label for= 'radio_line' style="font-weight: bold;font-size: 1rem;">Line</label>
				<input type="radio" id = "radio_donut" name = "radio" value = "3">
				<label for= 'radio_donut' style="font-weight: bold;font-size: 1rem;">Donut</label>
			</aui:col>
		</aui:row>
		
		<!-- Graphs of bar, line, and donut, respectively -->
		<aui:row cssClass="marBr">
			<aui:col md="12">
				<chart:bar
					id="bar"
					config="<%=_barChartConfig %>"
				/>
			
				<chart:line
					id="line"
				  	config="<%=_lineChartConfig %>"
			  	/>
			
				<chart:donut
					id="donut"
					config="<%=_donutChartConfig %>"
				/>
			</aui:col>
		</aui:row>
		
		<!-- Graphs containing each analysis item -->
		<div id="input_range" style="display: flex;">
			<h2 style="display: inline-block;margin-left: auto;">Range :</h2>
			<input type = "number" id="value_range" value="10" step="0.01" min = "<%=Collections.min(listDouble)%>" max = "<%=Collections.max(listDouble)%>" style="margin-left: 1em;"></input>
			<button id="btn_1" style="margin-left: 1em;">Submit</button>
		</div>
		<br>
		<aui:row>
			<aui:col md="4">
				<div id="title_table_statistics" class=" sub-title-bottom-border marBr">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf-user.crf-data.title.statistics" />
					</span>
				</div>
				
				<table id="table_statistics" class="table table-bordered table-striped left">
				    <thead>
						<tr>
							<th>Name</th>
							<th>Value</th>
						</tr>
				    </thead>
				    <tbody>
				    	<!-- Add the number of lists received from GraphRendercommand -->
				    	<c:forEach items = "${statistics_name}" var = "name" varStatus = "status">
				    		<tr>
				    			<td>${name}</td>
				    			<td>${statistics_value[status.index]}</td>
				    		</tr>
				    	</c:forEach>
				    </tbody>
				</table>
			</aui:col>
			
			<aui:col md="4">
				<div id="title_table_quartiles" class=" sub-title-bottom-border marBr">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf-user.crf-data.title.quartiles" />
					</span>
				</div>
				
				<table id="table_quartiles" class="table table-bordered table-striped left">
					<thead>
						<tr>
							<th>Name</th>
							<th>Value</th>
						</tr>
				    </thead>
				    <tbody>
				    	<!-- Add the number of lists received from GraphRendercommand -->
				    	<c:forEach items = "${quartiles_name}" var = "name" varStatus = "status">
				    		<tr>
				    			<td>${name}</td>
				    			<td>${quartiles_value[status.index]}</td>
				    		</tr>
				    	</c:forEach>
				    </tbody>
				</table>
			</aui:col>

			<aui:col md="4">
				<div id="title_table_normality" class=" sub-title-bottom-border marBr">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf-user.crf-data.title.normality" />
					</span>
				</div>
				
				<table id="table_normality" class="table table-bordered table-striped left">
					<thead>
						<tr>
							<th>Name</th>
							<th>Value</th>
						</tr>
				    </thead>
				    <tbody>
				    	<!-- Add the number of lists received from GraphRendercommand -->
				    	<c:forEach items = "${normality_name}" var = "name" varStatus = "status">
				    		<tr>
				    			<td>${name}</td>
				    			<td>${normality_value[status.index]}</td>
				    		</tr>
				    	</c:forEach>
				    </tbody>
				</table>
				
			</aui:col>
		</aui:row>
	</aui:container>
</div>

<aui:script require="frontend-taglib-chart$billboard.js@1.5.1/dist/billboard as myChart">

	function makeBarChart(freqData, labelData){
		var rowData = [];
		
		rowData[0] = labelData;
		rowData[1] = freqData;
		
		var bar_chart = myChart.bb.generate({
			bindto: "#bar",
			data: {
				rows: rowData, 
				type: "bar"
			},
			bar: {
				padding: 10
			},
			tooltip: {
				format: {
					title: function(d) {
						return 'Frequency';
					}
				}
			}
		});
		bar_chart.category(0, "Frequency");
	}
	
	function makeLineChart(freqData, labelData){
		var line_chart = myChart.bb.generate({
			bindto: "#line",
			data: {
				x:"x",
				json: {
					"Frequency" : freqData,
					"x" : labelData
				},
				type: "line"
			},
			axis: {
				x: {
					tick: {
						text: {
				        	inner: true
				        },
						fit: false,
						count: 10
					},
	 				type: "category"
				}
			},
			zoom: {
				enabled: true,
				type: "drag"
			},
			point: {
				focus: {
					only: true
				}
			}
		});
	}
	
	function makeDonutChart(freqData, labelData){
		var rowData = [];
		
		rowData[0] = labelData;
		rowData[1] = freqData;
		
		var donut_chart = myChart.bb.generate({
			data: {
				rows: rowData,
				type: "donut",
				onclick: function(d, i) {
					console.log("onclick", d, i);
				},
				onover: function(d, i) {
					console.log("onover", d, i);
				},
				onout: function(d, i) {
					console.log("onout", d, i);
				}
			},
			bindto: "#donut"
		});
	}

	function adjustmentRange(rangeValue){
		if("<%=type%>" == "List"){
			
			var freqs = <%=listInt %>;
			var labels = [];
			<%for(int i = 0; i < listString.size(); i++){ %>
				<%-- console.log(<%=i%>); --%>
				labels[<%=i %>] = "<%=listString.get(i)%>"; 
				<%} %>;
			console.log(labels);
			makeBarChart(freqs, labels);
			makeLineChart(freqs, labels);
			makeDonutChart(freqs, labels);
		}
		else if("<%=type%>" == "Numeric"){
			console.log("<%=type %>");
			var rangeSize = rangeValue;
			var max = <%=Collections.max(listDouble) %>;
			var min = <%=Collections.min(listDouble) %>;
			var rangeCount = 0;
			console.log("rs: " + rangeSize);
			if(rangeSize == "default"){
				rangeCount = 10;
				rangeSize = Math.ceil((max - min) / (rangeCount - 1));
				document.getElementById('value_range').value = rangeSize;
				console.log("hu: " + rangeSize);
			}
			else if(rangeSize > max || Object.is(rangeSize, NaN)){
				alert("Input the right value...");
				return 0;
			}
			else{
				rangeCount = Math.ceil((max - min) / rangeSize) + 1;
			}
	
			var freqs = [];
			var labels = [];
			var listDouble = <%=listDouble %>;
			for(var i = 0; i < rangeCount; i++){
				freqs[i] = 0;
			}
			for(var i = 0; i < listDouble.length; i++){
				var binIndex = parseInt(((listDouble[i] - min) / rangeSize), 10);
				freqs[binIndex]++;
			}
			for(var i = 0 ; i < rangeCount; i++){
				var rangeStart = Number(min + i * rangeSize).toFixed(2);
				console.log("st: " + rangeStart);
				var rangeEnd = Number(parseFloat(rangeStart) + rangeSize).toFixed(2);
				console.log("en: " + rangeEnd);
				labels[i] = rangeStart + "~" + rangeEnd;
			}
			makeBarChart(freqs, labels);
			makeLineChart(freqs, labels);
			makeDonutChart(freqs, labels);
		}
	
	}
	
	$(document).ready(function() {
		adjustmentRange("default");
	});
	var hw = document.getElementById('btn_1');
	hw.addEventListener('click',function(){
		if("<%=type %>" != "empty"){
			adjustmentRange(parseFloat(document.getElementById('value_range').value, 10));
		} else{
			alert("No data available for generating the graph.");
		}
		
	});
</aui:script>

<script>
	// The initial output graph is a Bar-type graph
	document.getElementById("bar").style.display = "block";
    document.getElementById("line").style.display = "none";
    document.getElementById("donut").style.display = "none";
    
	// Outputs the statistical table only when the Term type is Numeric
	if('<%=type%>' == 'Numeric'){
		document.getElementById('table_statistics').style.display = "";
		document.getElementById('title_table_statistics').style.display = "";
		document.getElementById('table_quartiles').style.display = "";
		document.getElementById('title_table_quartiles').style.display = "";
		document.getElementById('table_normality').style.display = "";
		document.getElementById('title_table_normality').style.display = "";
		document.getElementById('input_range').style.display = "";
	}
	else{
		document.getElementById('table_statistics').style.display = "none";
		document.getElementById('title_table_statistics').style.display = "none";
		document.getElementById('table_quartiles').style.display = "none";
		document.getElementById('title_table_quartiles').style.display = "none";
		document.getElementById('table_normality').style.display = "none";
		document.getElementById('title_table_normality').style.display = "none";
		document.getElementById('input_range').style.display = "none";
	}
	
	// Press each radio button to output a graph of each type
	$('input[id$="radio_bar"]').change(function(){
        document.getElementById("bar").style.display = "block";
        document.getElementById("line").style.display = "none";
        document.getElementById("donut").style.display = "none";
	});
	
	$('input[id$="radio_line"]').change(function(){
        document.getElementById("bar").style.display = "none";
        document.getElementById("line").style.display = "block";
        document.getElementById("donut").style.display = "none";
	});
	
	$('input[id$="radio_donut"]').change(function(){
        document.getElementById("bar").style.display = "none";
        document.getElementById("line").style.display = "none";
        document.getElementById("donut").style.display = "block";
        
	});
	
	//document.getElementById('xlsx_name').value
	

</script>

