<%@ include file="/init.jsp" %>

<div class="ecrf-user">
	<div class="pad1r">
		<liferay-ui:header title="ecrf-user.visualizer.title.graph1" />
		
		
		<aui:container>
			<aui:row>
				<aui:col md="3">
					<liferay-ui:message key="ecrf-user.visualizer.title.data-count" />
				</aui:col>
				<aui:col md="9">
					<span id="<portlet:namespace/>dataCount"></span>
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col md="3">	<!-- 1st trimester -->
				</aui:col>
				<aui:col md="3">
				</aui:col>
				<aui:col md="3">	<!-- 2nd trimester -->
				</aui:col>
				<aui:col md="3">
				</aui:col>
			</aui:row>
			
			<aui:row>
				<aui:col md="3">	<!-- 3rd trimester -->
				</aui:col>
				<aui:col md="3">
				</aui:col>
				<aui:col md="3">	<!-- 4th trimester -->
				</aui:col>
				<aui:col md="3">
				</aui:col>
			</aui:row>
		</aui:container>
	</div>
</div>


<script>

$(document).ready(function() {
	console.log("graph data loading");
	
	let crfId = 41733;
	
	getGraphData(crfId);
	
});

function getGraphData(crfId) {
	$.ajax({
		url: '<portlet:resourceURL id="<%=ECRFVisualizerMVCCommand.RESOURCE_GET_NOE_MOC %>"></portlet:resourceURL>',
		type:'post',
		dataType: 'json',
		data:{
			<portlet:namespace/>crfId: crfId,
		},
		success: function(data){
			// do pre-process data for chart			
			console.log("data :", data);
			
			// set data to chart
			$("#<portlet:namespace/>dataCount").text("120");
			
		},
		error: function(jqXHR, a, b){
			console.log('Fail to render trimester graph');
		}
	});
}

</script>