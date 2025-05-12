
<%@ include file="/init.jsp" %>

<div class="ecrf-user">
	<div class="pad1r">
		<liferay-ui:header title="ecrf-user.visualizer.title.view-visualizer" />
		
		<aui:container>
			<aui:row>
				<aui:col>
					<div>
						<liferay-ui:message key="ecrf-user.visualizer.description" />
					</div>
				</aui:col>
			</aui:row>
			
			<aui:button-row>
				<portlet:renderURL var="viewGraphURL">
					<portlet:param name="<%=ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME %>" value="<%=ECRFVisualizerMVCCommand.RENDER_VIEW_GRAPH_1 %>" />
				</portlet:renderURL>
			
				<aui:button name="graph1" onClick="<%=viewGraphURL %>" value="Graph1">
				</aui:button>
			</aui:button-row>
		
		</aui:container>
	</div>
</div>