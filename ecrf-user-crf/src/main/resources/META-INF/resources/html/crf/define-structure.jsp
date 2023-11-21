<%@page import="com.sx.icecap.constant.IcecapMVCCommands"%>
<%@page import="com.sx.icecap.constant.IcecapWebPortletKeys"%>
<%@page import="com.sx.constant.StationXWebKeys"%>
<%@page import="ecrf.user.constants.ECRFUserCRFAttributes"%>
<%@ include file="../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf/define-structure_jsp"); %>

<%
	boolean isAdd = true;

	long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFAttributes.CRF_ID, 0);
	CRF crf = null;

	long dataTypeId = 0;	
	DataType dataType = null;
	
	_log.info("crf id : " + crfId);
	
	if(crfId > 0) {
		isAdd = false;
		crf = CRFLocalServiceUtil.getCRF(crfId);
		dataTypeId = crf.getDatatypeId();
	}
	
	_log.info("dataType id : " + dataTypeId);
	
	if(dataTypeId > 0) {
		dataType = DataTypeLocalServiceUtil.getDataType(dataTypeId);
	}
	
	boolean isUpdate = !isAdd;
	
	String pageTitle = "Define Structure";
	
	String queryString = "";
	queryString += ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME + "=" + IcecapMVCCommands.RENDER_DEFINE_DATA_STRUCTURE;
	queryString += "&" + StationXWebKeys.DATATYPE_ID + "=" + dataTypeId;
	
	_log.info(queryString);
%>

<div class="ecrf-user-crf">
	
	<aui:container>
		<aui:row>
			<aui:col>
				<h3 class="marTr">
					<span class="vertical-align-bottom"><liferay-ui:message key="<%= pageTitle %>" /></span>
				</h3>
			</aui:col>
		</aui:row>
	
		<aui:row>
			<aui:col>
				<hr class="header-hr">
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col>
				<liferay-portlet:runtime portletName="<%=IcecapWebPortletKeys.DATATYPE_MANAGEMENT %>" queryString="<%=queryString %>" >
					</liferay-portlet:runtime>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col>
				<hr class="header-hr">
			</aui:col>
		</aui:row>
		
	</aui:container>
</div>