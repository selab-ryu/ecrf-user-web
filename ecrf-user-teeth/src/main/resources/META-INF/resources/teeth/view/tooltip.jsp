<%@ include file="../../init.jsp"%>

<%@page import="com.liferay.portal.kernel.language.UTF8Control"%>
<%@page import="java.util.ResourceBundle"%>

<%@ page import="javax.portlet.PortletURL"%>

<%! private Log _log = LogFactoryUtil.getLog("tooltip_jsp]"); %>

<%
	String regionName = (String) request.getAttribute("regionName");
	List<DisplayHistory> displayList = (List<DisplayHistory>) request.getAttribute("displayList");
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		
%>

<div id="historyTooltipWrapper">
	<aui:row>
		<aui:col>
			<liferay-ui:search-container total="<%= displayList.size() %>" emptyResultsMessage="No Treatments Yet." var="searchContainer">
				<liferay-ui:search-container-results results="<%=displayList%>" />
				
				<% int count = searchContainer.getStart(); %>
				
				<liferay-ui:search-container-row
					className="ecrf.user.teeth.dto.DisplayHistory"
					modelVar="treatment">
					<liferay-ui:search-container-column-text name="Treatment Date" value="<%=sdf.format(treatment.getDate())%>" />
					<liferay-ui:search-container-column-text name="Age at Tx." value="<%=treatment.getAgeYears() + " 년 " + treatment.getAgeMonths() + " 개월 "%>" />
					<liferay-ui:search-container-column-text name="State"
						value="<%=treatment.getStatus()%>" />
					<liferay-ui:search-container-column-text name="Treatments" 
						cssClass="treatment-column">
						<%=treatment.getTreatmnetString() %>
					</liferay-ui:search-container-column-text>
				</liferay-ui:search-container-row>
				<liferay-ui:search-iterator paginate="false" />
			</liferay-ui:search-container>
		</aui:col>
	</aui:row>
</div>

<script>

</script>

