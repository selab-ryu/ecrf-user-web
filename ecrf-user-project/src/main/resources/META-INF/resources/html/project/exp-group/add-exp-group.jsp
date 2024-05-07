<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html.project.exp-group.list_exp_group_jsp"); %>

<%
SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

String menu="exp-group";

%>

<div class="ecrf-user">

	<%@ include file="../sidebar.jspf" %>
	
	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.project.title.add-exp-group" />
		
		<aui:form action="${searchURL}" name="updateExpGroup" autocomplete="off" cssClass="marBr">
		
		</aui:form>
		
	</div>
</div>