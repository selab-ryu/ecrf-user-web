<%@page import="java.util.TimeZone"%>
<%@ include file="../../init.jsp"%>

<%@ page import="teeth.model.TreatmentAudit"%>

<%@ page import="com.liferay.portal.kernel.util.PortalUtil"%>
<%@ page import="javax.portlet.PortletURL"%>
<%@ page import="javax.portlet.WindowState"%>

<style>
#auditPopupWrapper {
	padding: 20px 40px !important;
}

#auditPopupWrapper
   [id$="treatmentAuditsSearchContainer"]
   table.table.table-bordered.table-hover.table-striped
   thead.table-columns
   th {
	text-align: center;
}

#auditPopupWrapper
   [id$="treatmentAuditsSearchContainer"]
   table.table.table-bordered.table-hover.table-striped
   tbody {
	text-align: center;
}

#auditPopupWrapper table {
	font-size: 1.1rem;
	line-height: 1.1rem;
}
</style>

<%
	List<TreatmentAudit> displayList = (List<TreatmentAudit>) request.getAttribute("DisplayList");
	String mode = (String) request.getAttribute("mode");
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	sdf.setTimeZone(TimeZone.getTimeZone("GMT+9"));
	SimpleDateFormat sdd = new SimpleDateFormat("yyyy-MM-dd");
	sdd.setTimeZone(TimeZone.getTimeZone("GMT+9"));
	Object teethAttr = request.getAttribute("teethNum");
	long teethNum = (teethAttr != null) ? (Long) teethAttr : 0L;
	
	long subjectId = ParamUtil.getLong(request, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
	long linkId = ParamUtil.getLong(request, ECRFUserCRFDataAttributes.LINK_ID, 0);

	PortletURL iteratorURL = renderResponse.createRenderURL();
	iteratorURL.setParameter("mvcRenderCommandName", "/teeth/viewAuditTrail");
	iteratorURL.setParameter("mode", mode);
	iteratorURL.setParameter("teethNum", String.valueOf(teethNum));
	iteratorURL.setParameter("subjectId", String.valueOf(subjectId));
	iteratorURL.setParameter("crfId", String.valueOf(crfId));
	iteratorURL.setParameter("linkId", String.valueOf(linkId));
	iteratorURL.setWindowState(LiferayWindowState.POP_UP);
%>

<div id="auditPopupWrapper">
	<aui:row>
		<aui:col>
			<liferay-ui:search-container
				cssClass="compact-search-container" 
				total="<%=displayList.size()%>" 
				delta="5"
				iteratorURL="<%=iteratorURL%>"
				deltaConfigurable="true"
				emptyResultsMessage="No Audit in this teeth Yet."
			>
				<liferay-ui:search-container-results results="<%=displayList.subList(searchContainer.getStart(), Math.min(searchContainer.getEnd(), displayList.size()))%>" />
				<liferay-ui:search-container-row
					className="TreatmentAudit" 
					modelVar="audit"
				>
					<liferay-ui:search-container-column-text name="Teeth Num" value="<%=String.valueOf(audit.getTeethNum())%>" />
					<liferay-ui:search-container-column-text name="Treatment Date" value="<%=sdd.format(audit.getTreatmentDate()) %>"/>
					<liferay-ui:search-container-column-text name="Edit Type" value="<%=audit.getEditType()%>" />
					<liferay-ui:search-container-column-text name="Before Data" value="<%=audit.getBeforeData()%>" />
					<liferay-ui:search-container-column-text name="After Data" value="<%=audit.getAfterData()%>" />
					<liferay-ui:search-container-column-text name="Edited Date" value="<%=sdf.format(audit.getEditedDate())%>" />
					<liferay-ui:search-container-column-user name="Edited User" userId="<%=audit.getEditedUserID()%>" />
				</liferay-ui:search-container-row>
								
				<liferay-ui:search-iterator 
					displayStyle="list"
					markupView="lexicon"
					paginate="<%=true %>"
					searchContainer="<%=searchContainer %>" 
				/>
			</liferay-ui:search-container>
		</aui:col>
	</aui:row>
	
	<aui:button-row>
		<c:if test="<%=mode.equals("Teeth") %>">
			<button type="button" class="btn btn-secondary" value="back" onclick="window.history.back();" >Back</button>
		</c:if>
		
		<button type="button" class="btn btn-secondary" value="close" onclick="Liferay.Util.getWindow().hide();" >Close</button>
	</aui:button-row>
</div>