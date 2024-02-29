<%@ include file="../../init.jsp" %>

<%! private Log _log = LogFactoryUtil.getLog("html/crf-data/other/dialog-graph.jsp"); %>

<%

String[] datas = (String[])renderRequest.getAttribute("datas");
int[] valueCounts = (int[])renderRequest.getAttribute("values");

BarChartConfig _barChartConfig = new BarChartConfig();

for(int i = 0; i < datas.length; i++){
	_log.info(datas[i] + " : " + valueCounts[i]);
	_barChartConfig.addColumns(new MultiValueColumn(datas[i], valueCounts[i]));
}
%>

<div class="ecrf-user-crf-data ecrf-user">
	<aui:container cssClass="">
		<chart:bar
		  config="<%= _barChartConfig %>"
		/>
	</aui:container>
</div>