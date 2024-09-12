<%@ include file="../../init.jsp" %>

<%! Log _log = LogFactoryUtil.getLog("html.crf-data.dialog.dialog_audit_jsp"); %>

<%	
	SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/M/d");

	JSONArray table = (JSONArray)renderRequest.getAttribute("JsonArr");

	_log.info(table.toJSONString());
%>
<div class="ecrf-user-crf-data ecrf-user">
	<aui:container cssClass="">
		<aui:row>
			<aui:col md="12">
			<table class="table crfHistory">
				<thead>
					<tr>
						<th>Term Name</th>
						<th>Previous Value</th>
						<th>Current Value</th>
						<th>Action Type</th>
						<th>Modified Date</th>
						<th>User Name</th>
						<th>User Email</th>
					<tr>
				</thead>
				<tbody>
				<%
					for(int i = 0; i < table.length(); i++){
				%>
					<tr>
						<td><%=table.getJSONObject(i).getString("displayName")%></td>
						<td><%=table.getJSONObject(i).getString("preValue")%></td>
						<td><%=table.getJSONObject(i).getString("curValue")%></td>
						<td><%=table.getJSONObject(i).getString("actionType")%></td>
						<td><%=table.getJSONObject(i).getString("modifiedDate")%></td>
						<td><%=table.getJSONObject(i).getString("userName")%></td>
						<td><%=table.getJSONObject(i).getString("userId")%></td>
					</tr>
				<%
				} 
				%>
				</tbody>
			</table>
			</aui:col>
		</aui:row>
	</aui:container>
</div>