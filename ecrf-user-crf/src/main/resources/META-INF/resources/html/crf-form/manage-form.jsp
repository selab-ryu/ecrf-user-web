<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf-form/manage-form_jsp"); %>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
	
	_log.info("crf id : " + crfId);	
	_log.info("dataType id : " + dataTypeId);
		
	String menu = "crf-form-manage";
		
	String queryString = "";
	queryString += ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME + "=" + IcecapMVCCommands.RENDER_DEFINE_DATA_STRUCTURE;
	queryString += "&" + StationXWebKeys.DATATYPE_ID + "=" + dataTypeId;
	
	_log.info("query string : " + queryString);
	
	// randomized instance id
	String instanceId = ECRFUserUtil.randomizedString(10, "aA1");
	_log.info(instanceId);
%>

<div class="ecrf-user ecrf-user-crf">
	<%@ include file="sidebar.jspf" %>
	
	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.crf-form.title.manage-form" />
		<aui:container cssClass="radius-shadow-container hide-embedded-portlet-header">
			<!-- for check change of crf form -->
			<aui:row>
				<aui:col>
				</aui:col>
			</aui:row>
			<aui:row>
				<aui:col>
					<!-- Event related issue occured -->
					<!-- instance id -->
					<!-- Event called by previous dataStructure object -->
					<liferay-portlet:runtime portletName="<%=IcecapWebPortletKeys.DATATYPE_MANAGEMENT %>" instanceId="<%=instanceId %>" queryString="<%=queryString %>" >
					</liferay-portlet:runtime>
				</aui:col>
			</aui:row>
		</aui:container>
	</div>
</div>

<script>
$(document).ready(function() {
	let dtPortletName = "<%=IcecapWebPortletKeys.DATATYPE_MANAGEMENT %>";
	let dtPortletNamespace = "_" + dtPortletName + "_";
	//console.log(dtPortletNamespace);
	$('#' + dtPortletNamespace + 'naviCol').css('display', 'none');
});
</script>