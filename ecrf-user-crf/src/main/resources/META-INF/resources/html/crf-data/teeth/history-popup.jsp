<%@page import="ecrf.user.crf.util.data.DisplayHistory"%>
<%@ include file="../../init.jsp"%>

<%@ page import="javax.portlet.PortletURL"%>

<style>
/* 팝업 전체 여백 유지 */
#historyPopupWrapper {
	padding: 20px 20px !important;
}

#historyPopupWrapper
	[id$="displayHistoriesSearchContainer"]
	table.table.table-bordered.table-hover.table-striped
	thead.table-columns
	th {
	text-align: center;
}

#historyPopupWrapper
	[id$="displayHistoriesSearchContainer"]
	table.table.table-bordered.table-hover.table-striped
	tbody.table-data
	td.table-cell {
	padding: 0px 0px;
	/* 텍스트 좌우·상하 중앙 정렬 유지 */
	text-align: center;
	vertical-align: middle;
	border-spacing: 0;
	margin: 0;
}

#historyPopupWrapper table {
	font-size: 1.1rem;
	line-height: 1.1rem;
}
</style>

<%
	List<DisplayHistory> displayList = (List<DisplayHistory>) request.getAttribute("displayList");
	long teethNum = (Long) request.getAttribute("teethNum");
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	String regionName = (String) request.getAttribute("regionName");

	long subjectId = ParamUtil.getLong(request, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
	long linkId = ParamUtil.getLong(request, ECRFUserCRFDataAttributes.LINK_ID, 0);

	PortletURL iteratorURL = renderResponse.createRenderURL();
	iteratorURL.setParameter("mvcRenderCommandName", "/teeth/historyPopup");
	iteratorURL.setParameter("cmd", "search");
	iteratorURL.setParameter("teethNum", String.valueOf(teethNum));
	iteratorURL.setParameter("regionName", regionName);
	iteratorURL.setParameter("subjectId", String.valueOf(subjectId));
	iteratorURL.setParameter("crfId", String.valueOf(crfId));
	iteratorURL.setParameter("linkId", String.valueOf(linkId));
	iteratorURL.setWindowState(LiferayWindowState.POP_UP);
%>

<!-- RenderURL -->
<portlet:renderURL var="ViewAuditURL" windowState="pop_up">
	<portlet:param name="mvcRenderCommandName" value="/teeth/viewAuditTrail" />
	<portlet:param name="mode" value="Teeth" />
	<portlet:param name="teethNum" value="<%=String.valueOf(teethNum)%>" />
	<portlet:param name="<%=ECRFUserCRFDataAttributes.SUBJECT_ID%>" value="<%=String.valueOf(subjectId)%>" />
	<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID%>" value="<%=String.valueOf(crfId)%>" />
	<portlet:param name="<%=ECRFUserCRFDataAttributes.LINK_ID%>" value="<%=String.valueOf(linkId)%>" />
</portlet:renderURL>

<div id="historyPopupWrapper">
	<liferay-ui:search-container cssClass="compact-search-container" total="<%=displayList.size()%>" delta="5" deltaConfigurable="true" iteratorURL="<%=iteratorURL%>" emptyResultsMessage="No Treatments Yet.">
		<liferay-ui:search-container-results results="<%=displayList.subList(searchContainer.getStart(), Math.min(searchContainer.getEnd(), displayList.size()))%>" />
		<liferay-ui:search-container-row className="ecrf.user.crf.util.data.DisplayHistory" modelVar="treatment">
			<liferay-ui:search-container-column-text name="Treatment Date" value="<%=sdf.format(treatment.getDate())%>" />
			<liferay-ui:search-container-column-text name="Age at Tx.">
				<% Object[] args = {treatment.getAgeYears(), treatment.getAgeMonths()};%>
				<liferay-ui:message key="ecrf-user.crf-data.teeth.edit-treatment.birth-text" arguments="<%=args %>" />
			</liferay-ui:search-container-column-text>
			<liferay-ui:search-container-column-text name="State"
				value="<%=treatment.getStatus()%>" />
			<liferay-ui:search-container-column-text name="Treatments"
				value="<%=treatment.getTreatmnetString()%>" 
					cssClass="treatment-column" />
			<liferay-ui:search-container-column-text name="Edit">
				<portlet:renderURL var="EditHistoryPopUpURL" windowState="pop_up">
					<portlet:param name="mvcRenderCommandName" value="/teeth/editHistoryPopup" />
					<portlet:param name="treatmentId" value="<%=String.valueOf(treatment.getTreatmentID())%>" />
					<portlet:param name="<%=ECRFUserCRFDataAttributes.CRF_ID%>" value="<%=String.valueOf(crfId)%>" />
				</portlet:renderURL>
				<aui:button-row>
					<aui:button type="button" cssClass="btn btn-primary" value="Edit" onClick="<%=EditHistoryPopUpURL%>" />
				</aui:button-row>
			</liferay-ui:search-container-column-text>
		</liferay-ui:search-container-row>
		<liferay-ui:search-iterator />
	</liferay-ui:search-container>

	<aui:button-row>
		<aui:button type="button" cssClass="btn btn-primary" value="View Audit" onClick="<%=ViewAuditURL%>" />
		<aui:button type="button" cssClass="btn btn-secondary" value="Close" onClick="Liferay.Util.getOpener().location.reload(); " />
	</aui:button-row>
</div>

<script src="/o/ecrf.user.crf/js/teeth/categoryLabelMap.js"></script>

<aui:script>
  // 'State' 컬럼 텍스트 바꾸기
  document.querySelectorAll('td.treatment-column').forEach(td => {
    const value = td.textContent.trim();
    const items = value.split(',');

    
	  const labeledItems = items.map(item => {
	    const label = CategoryUtil.getStatusLabel(item);
	    return label !== "기타" ? label + " - " + item : item;
	  });
    
	td.textContent = labeledItems.join(', ');
    
    
    
  });
</aui:script>
