<%@ include file="./init.jsp" %>

<portlet:renderURL var="searchURL">
	<portlet:param name="mvcPath" value="/html/researcher/list-researcher.jsp" />
	<portlet:param name="<%=WebKeys.REDIRECT %>" value="<%=currentURL %>" />
</portlet:renderURL>

<aui:button onClick="${searchURL}" value="Move to Search" />