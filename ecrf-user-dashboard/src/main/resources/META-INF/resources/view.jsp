<%@page import="com.liferay.portal.kernel.model.Group"%>
<%@page import="com.liferay.portal.kernel.model.Layout"%>
<%@ include file="./init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html/dashboard/view_jsp"); %>

<%
Layout curLayout = themeDisplay.getLayout();
boolean isPublic = curLayout.isPublicLayout();
_log.info("is public page : " + isPublic);

Group curGroup = themeDisplay.getScopeGroup();

%>

<c:choose>
<c:when test="<%=isPublic %>">
	<aui:button value="Move to Private Page" href="<%=curGroup.getDisplayURL(themeDisplay, true) %>" />
</c:when>
<c:otherwise>
	<aui:button value="Move to Public Page" href="<%=curGroup.getDisplayURL(themeDisplay, false) %>" />
</c:otherwise>
</c:choose>

