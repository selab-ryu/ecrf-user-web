<%@ include file="./init.jsp" %>

<portlet:renderURL var="searchURL">
	<portlet:param name="mvcPath" value="/html/researcher/list-researcher.jsp" />
</portlet:renderURL>

<aui:button onClick="${searchURL}" value="Move to Search" />