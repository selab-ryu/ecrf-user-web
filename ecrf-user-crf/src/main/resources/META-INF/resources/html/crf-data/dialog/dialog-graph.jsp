<%@ include file="../../init.jsp" %>

<%! private Log _log = LogFactoryUtil.getLog("html/crf-data/dialog/dialog-graph_jsp"); %>

<%
// Received column names and number to put in graph
String[] datas = (String[])renderRequest.getAttribute("datas");
int[] valueCounts = (int[])renderRequest.getAttribute("values");

String type = (String)renderRequest.getAttribute("type");

List<String> lineCategories = new ArrayList<>();
List<Integer> lineDataList = new ArrayList<>();

BarChartConfig _barChartConfig = new BarChartConfig();
LineChartConfig _lineChartConfig = new LineChartConfig();
DonutChartConfig _donutChartConfig = new DonutChartConfig();

for(int i = 0; i < datas.length; i++){
	_barChartConfig.addColumns(new MultiValueColumn(datas[i], valueCounts[i]));
	_donutChartConfig.addColumns(new SingleValueColumn(datas[i], valueCounts[i]));

	lineCategories.add(datas[i]);
	lineDataList.add(valueCounts[i]);
	
	_log.info(datas[i] + " / " + valueCounts[i]);
}

_lineChartConfig.getAxisX().setType(AxisX.Type.CATEGORY);
_lineChartConfig.getAxisX().addCategories(lineCategories);

_lineChartConfig.addColumns(new MultiValueColumn("Freq", lineDataList));

_log.info("hi");
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
		
		<aui:row>
			<aui:col md="4">
				<div class=" sub-title-bottom-border marBr">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf-user.crf-data.title.standard-derivation-statistics" />
					</span>
				</div>
				
				<table id="table_statistics" class="table table-bordered table-striped left">
				    <caption style="text-align: center;">Statistics</caption>
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
				<div class=" sub-title-bottom-border marBr">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf-user.crf.title.year-chart" />
					</span>
				</div>
				
				<table id="table_quartiles" class="table table-bordered table-striped left">
				    <caption style="text-align: center;">Quartiles</caption>
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
				<div class=" sub-title-bottom-border marBr">
					<span class="sub-title-span">
						<liferay-ui:message key="ecrf-user.crf.title.year-chart" />
					</span>
				</div>
				
				<table id="table_normality" class="table table-bordered table-striped left">
					<caption style="text-align: center;">Normality Test</caption>
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

<script>
	// The initial output graph is a Bar-type graph
	document.getElementById("bar").style.display = "block";
    document.getElementById("line").style.display = "none";
    document.getElementById("donut").style.display = "none";
    
	// Outputs the statistical table only when the Term type is Numeric
	if('<%=type%>' == 'Numeric'){
		document.getElementById('table_statistics').style.display = "";
		document.getElementById('table_quartiles').style.display = "";
		document.getElementById('table_normality').style.display = "";
	}
	else{
		document.getElementById('table_statistics').style.display = "none";
		document.getElementById('table_quartiles').style.display = "none";
		document.getElementById('table_normality').style.display = "none";
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


</script>