<%@page import="ecrf.user.service.ProjectLocalServiceUtil"%>
<%@page import="ecrf.user.model.Project"%>
<%@page import="ecrf.user.constants.ECRFUserProjectAttributes"%>
<%@ include file="../init.jsp" %>

<%!
    private static Log _log = LogFactoryUtil.getLog("html.researcher.update_researcher_jsp");
%>

<%
long projectId = ParamUtil.getLong(renderRequest, ECRFUserProjectAttributes.PROJECT_ID, 0);
Project project = null;

if(projectId > 0) {
	project = ProjectLocalServiceUtil.getProject(projectId);
}

%>

<div class="ecrf-user-project">

<!-- Project info -->
<c:choose>
	<c:when test="<%=Validator.isNull(project) %>">
		
	</c:when>
	<c:otherwise>
		
	</c:otherwise>
</c:choose>

<!-- buttons -->
<c:choose>
	<c:when test="<%=Validator.isNull(project) %>">
		
	</c:when>
	<c:otherwise>
		
	</c:otherwise>
</c:choose>

</div>