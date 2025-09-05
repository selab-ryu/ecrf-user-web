<%@ include file="../../init.jsp"%>

<%@ page import="javax.portlet.PortletURL"%>

<style>
/* 팝업 전체 여백 유지 */
#historyPopupWrapper {
	padding: 20px 80px !important;
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
	/* 행간도 조금 줄여보기 */
	line-height: 1;
	/* 텍스트 좌우·상하 중앙 정렬 유지 */
	text-align: center;
	vertical-align: middle;
	border-spacing: 0;
	margin: 0;
}
</style>

<%
	List<DisplayHistory> displayList = (List<DisplayHistory>) request.getAttribute("displayList");
	long teethNum = (Long) request.getAttribute("teethNum");
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	String regionName = (String) request.getAttribute("regionName");
	long patientID = 1001;
	PortletURL iteratorURL = renderResponse.createRenderURL();
	iteratorURL.setParameter("mvcRenderCommandName", "/teeth/historyPopup");
	iteratorURL.setParameter("cmd", "search");
	iteratorURL.setParameter("teethNum", String.valueOf(teethNum));
	iteratorURL.setParameter("regionName", regionName);
	iteratorURL.setParameter("PatientID", String.valueOf(patientID));
	iteratorURL.setWindowState(LiferayWindowState.POP_UP);
%>

<!-- RenderURL -->
<portlet:renderURL var="ViewAuditURL" windowState="pop_up">
	<portlet:param name="mvcRenderCommandName" value="/teeth/viewAuditTrail" />
	<portlet:param name="mode" value="Teeth" />
	<portlet:param name="teethNum" value="<%=String.valueOf(teethNum)%>" />
</portlet:renderURL>

<div id="historyPopupWrapper">
	<aui:row>
		<aui:col>
			<liferay-ui:search-container cssClass="compact-search-container" total="<%=displayList.size()%>" delta="5" deltaConfigurable="true" iteratorURL="<%=iteratorURL%>" emptyResultsMessage="No Treatments Yet.">
				<liferay-ui:search-container-results results="<%=displayList.subList(searchContainer.getStart(), Math.min(searchContainer.getEnd(), displayList.size()))%>" />
				<liferay-ui:search-container-row className="teeth.web.dto.DisplayHistory" modelVar="treatment">
					<liferay-ui:search-container-column-text name="Treatment Date" value="<%=sdf.format(treatment.getDate())%>" />
					<liferay-ui:search-container-column-text name="Age at Tx." value="<%=treatment.getAgeYears() + " 년 " + treatment.getAgeMonths() + " 개월 "%>" />
					<liferay-ui:search-container-column-text name="State"
						value="<%=treatment.getStatus()%>" />
					<liferay-ui:search-container-column-text name="Treatments"
						value="<%=treatment.getTreatmnetString()%>" 
 						cssClass="treatment-column" />
					<liferay-ui:search-container-column-text name="Edit">
						<portlet:renderURL var="HistoryPopUpURL" windowState="pop_up">
							<portlet:param name="mvcRenderCommandName" value="/teeth/editHistoryPopup" />
							<portlet:param name="TreatmentID" value="<%=treatment.getTreatmentID()%>" />
						</portlet:renderURL>
						<aui:button-row>
							<aui:button type="button" cssClass="btn btn-primary" value="Edit" onClick="<%=HistoryPopUpURL%>" />
						</aui:button-row>
					</liferay-ui:search-container-column-text>
				</liferay-ui:search-container-row>
				<liferay-ui:search-iterator />
			</liferay-ui:search-container>
		</aui:col>
	</aui:row>

	<aui:button-row>
		<aui:button type="button" cssClass="btn btn-primary" value="Close" onClick="Liferay.Util.getOpener().location.reload(); " />
		<aui:button type="button" cssClass="btn btn-primary" value="View Audit" onClick="<%=ViewAuditURL%>" />
	</aui:button-row>
</div>

<script src="/o/teeth-web/js/categoryLabelMap.js"></script>

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
