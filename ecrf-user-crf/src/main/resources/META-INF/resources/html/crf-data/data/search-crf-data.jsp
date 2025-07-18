<%@page import="com.sx.icecap.constant.IcecapMVCCommands"%>
<%@page import="com.sx.icecap.constant.IcecapWebPortletKeys"%>

<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("html.crf-data.data.search_crf_data_jsp");  %>

<!-- TODO: check searchResult div id -->

<%
SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");

ArrayList<Subject> subjectList = new ArrayList<Subject>();
subjectList.addAll(SubjectLocalServiceUtil.getAllSubject());

DataType dataType = null;
if(dataTypeId > 0) {
	dataType = (DataType)renderRequest.getAttribute("dataType"); 
}

_log.info("searchcrfjsp: " + dataType);

PortletURL portletURL = null;

String menu = ECRFUserMenuConstants.SEARCH_CRF_DATA;

String sdPortlet = IcecapWebPortletKeys.STRUCTURED_DATA;
%>

<liferay-portlet:actionURL name="<%=ECRFUserMVCCommand.ACTION_REDIRECT_EXCEL_DOWNLOAD %>" var="excelDownloadActionURL">
</liferay-portlet:actionURL>

<div class="ecrf-user-crf-data ecrf-user">
	<%@ include file="../other/sidebar.jspf" %>
	
	<div class="page-content">
	
		<div class="crf-header-title">
			<% DataType titleDT = DataTypeLocalServiceUtil.getDataType(dataTypeId); %>
			<liferay-ui:message key="ecrf-user.general.crf-title-x" arguments="<%=titleDT.getDisplayName(themeDisplay.getLocale()) %>" />
		</div>
	
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.crf-data.title.search-crf-data" />
		<aui:container>
			<aui:row cssClass="radius-shadow-container">
				<aui:col>
					<liferay-portlet:runtime portletName="<%=sdPortlet %>" queryString="<%="mvcRenderCommandName="+ IcecapMVCCommands.RENDER_STRUCTURED_DATA_ADVANCED_SEARCH + "&dataTypeId=" + dataTypeId%>">
					</liferay-portlet:runtime>
				</aui:col>
			</aui:row>
			<aui:row>
				<aui:col>
					<aui:button-row cssClass="marL10">
						<aui:form name="fm" action="${excelDownloadActionURL}" method="POST">
							<aui:input type="hidden" name="<%=ECRFUserCRFDataAttributes.CRF_ID %>" value="<%=crfId %>" />
							<aui:input type="hidden" name="excelParam"></aui:input>
							
							<c:if test="<%=CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.DOWNLOAD_EXCEL) %>">
							<button id="excelDownload" type="button" class="dh-icon-button update-btn w220">
								<img class="excel-download-icon" />
								<span><liferay-ui:message key="ecrf-user.button.download-search-result"/></span>
							</button>
							</c:if>
							
						</aui:form>
					</aui:button-row>
				</aui:col>
			</aui:row>
		</aui:container>
	</div>
</div>

<script>
// event handler for search option dialog close
// as-is: when move to other page, search option dialog is not closed
// to-be: when move to other page, search option dialog is closed 

// add urlchange event when url has changed
//pushState / replaceState
(function(history) {
  const pushState = history.pushState;
  const replaceState = history.replaceState;

  history.pushState = function(...args) {
    const result = pushState.apply(this, args);
    window.dispatchEvent(new Event("urlchange"));
    return result;
  };

  history.replaceState = function(...args) {
    const result = replaceState.apply(this, args);
    window.dispatchEvent(new Event("urlchange"));
    return result;
  };
})(window.history);

// add event handler on urlchange, when enter the advanced crf search page
window.addEventListener("urlchange", () => {
  //console.log("Custom urlchange event:", window.location.href);
  
  let curUrl = window.location.href;
  let searchStr = "search-crf-data"
  let searchOption = $('#_com_sx_icecap_web_portlet_sd_StructuredDataPortlet_selectSearchTerm');
  
  // check crf-advanced-search menu
  let isCRFSearch = curUrl.includes(searchStr);
  // check searchOption div is exist
  if(!isCRFSearch && searchOption) {
	  // check dialog has initialized & dialog is opend
	  if(searchOption.hasClass("ui-dialog-content") && searchOption.dialog("isOpen")) {
	  	console.log("search option dialog close");
	  	searchOption.dialog('destroy');
	  }
  }
});
</script>

<aui:script use="liferay-portlet-url">
$("#excelDownload").on("click", function(event) {
		var form = $("#<portlet:namespace/>fm");
		var excelPackage = $('#_com_sx_icecap_web_portlet_sd_StructuredDataPortlet_searchResults').val();
		
		console.log($('#_com_sx_icecap_web_portlet_sd_StructuredDataPortlet_searchResults'));
		console.log(excelPackage);
		var hasContent = true;
		if(excelPackage.length == 0){
			hasContent = false;
		}else{
			var packageJSON = JSON.parse(excelPackage);
			for(var i = 0; i < packageJSON.length; i++){
				console.log(packageJSON[i].results.length);
				if(packageJSON[i].results.length == 0){
					hasContent = false;
					break;
				}else{
					hasContent = true;
				}
			}
		
		}
		
		var excelParam = $('#<portlet:namespace/>excelParam');
		excelParam.val(excelPackage);
		if(hasContent){
			form.submit();
		}else{
			alert("Subject Not Exsist!");
		}
});
</aui:script>