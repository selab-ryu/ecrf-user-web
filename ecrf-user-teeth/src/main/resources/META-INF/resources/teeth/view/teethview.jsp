<%@page import="ecrf.user.constants.attribute.ECRFUserTeethAttributes"%>
<%@ include file="../../init.jsp"%>

<%
	Boolean isPermanent = (Boolean) renderRequest.getAttribute("isPermanent");
	Long patientID = (Long) request.getAttribute("patientID");
	if(patientID == null) { patientID = 1001L; }
	
	long subjectId = ParamUtil.getLong(request, ECRFUserTeethAttributes.SUBJECT_ID);
	long linkId = ParamUtil.getLong(request, ECRFUserTeethAttributes.LINK_ID);
%>



<portlet:renderURL var="totalTeethURL">
	<portlet:param name="mvcRenderCommandName" value="/teeth/totalTeethView"/>
	<portlet:param name="PatientID" value="<%=String.valueOf(patientID)%>" />
</portlet:renderURL>

<portlet:renderURL var="deciduousTeethURL">
	<portlet:param name="mvcRenderCommandName" value="/teeth/deciduousTeethView"/>
	<portlet:param name="PatientID" value="<%=String.valueOf(patientID)%>" />
</portlet:renderURL>

<c:choose>
    <c:when test="<% isPermanent= %>">
        <script type="text/javascript">
            window.location.href='<%=totalTeethURL%>';
        </script>
    </c:when>
    <c:otherwise>
        <script type="text/javascript">
            window.location.href='<%=totalTeethURL%>';
        </script>
    </c:otherwise>
</c:choose>