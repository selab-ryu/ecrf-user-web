<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui" %>
<%@ taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet" %>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme" %>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %>
<%@ taglib uri="http://liferay.com/tld/asset" prefix="liferay-asset" %>
<%@ taglib uri="http://liferay.com/tld/security" prefix="liferay-security" %>
<%@ taglib prefix="liferay-frontend" uri="http://liferay.com/tld/frontend" %>
<%@ taglib prefix="liferay-util" uri="http://liferay.com/tld/util" %>
<%@ taglib prefix="clay" uri="http://liferay.com/tld/clay" %>
<%@ taglib prefix="chart" uri="http://liferay.com/tld/chart" %>

<%@ page import="javax.portlet.PortletURL" %>

<%@ page import="com.liferay.portal.kernel.util.ParamUtil" %>
<%@ page import="com.liferay.portal.kernel.util.WebKeys" %>
<%@ page import="com.liferay.portal.kernel.security.permission.ActionKeys" %>
<%@ page import="com.liferay.portal.kernel.exception.PortalException" %>
<%@ page import="com.liferay.portal.kernel.exception.SystemException" %>
<%@ page import="com.liferay.portal.kernel.language.LanguageUtil" %>
<%@ page import="com.liferay.portal.kernel.search.Field" %>
<%@ page import="com.liferay.portal.kernel.util.GetterUtil" %>
<%@ page import="com.liferay.portal.kernel.util.Validator" %>
<%@ page import="com.liferay.portal.kernel.util.PortalUtil" %>
<%@ page import="com.liferay.portal.kernel.search.Sort" %>
<%@ page import="com.liferay.portal.kernel.workflow.WorkflowConstants" %>
<%@ page import="com.liferay.portal.kernel.util.ListUtil" %>
<%@ page import="com.liferay.portal.kernel.util.Constants" %>
<%@ page import="com.liferay.portal.kernel.service.UserLocalServiceUtil" %>
<%@ page import="com.liferay.portal.kernel.model.User" %>
<%@ page import="com.liferay.portal.kernel.model.Role" %>
<%@ page import="com.liferay.portal.kernel.portlet.LiferayWindowState" %>
<%@ page import="com.liferay.portal.kernel.portlet.PortletURLUtil"%>

<%@ page import="com.liferay.portal.kernel.json.JSONFactoryUtil"%>
<%@ page import="com.liferay.portal.kernel.json.JSONObject"%>
<%@ page import="com.liferay.portal.kernel.json.JSONArray"%>
<%@ page import="com.liferay.portal.kernel.log.Log" %>
<%@ page import="com.liferay.portal.kernel.log.LogFactoryUtil" %>

<%@ page import="com.liferay.petra.string.StringPool" %>

<%@ page import="com.liferay.frontend.taglib.chart.model.point.bar.BarChartConfig" %>
<%@ page import="com.liferay.frontend.taglib.chart.model.point.line.LineChartConfig" %>
<%@ page import="com.liferay.frontend.taglib.chart.model.SingleValueColumn" %>
<%@ page import="com.liferay.frontend.taglib.chart.model.MultiValueColumn" %>

<%@ page import="java.util.Set" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Locale"%>

<%@ page import="ecrf.user.constants.ECRFUserWebKeys"%>
<%@ page import="ecrf.user.constants.ECRFUserMVCCommand"%>
<%@ page import="ecrf.user.constants.ECRFUserJspPaths"%>
<%@ page import="ecrf.user.constants.ECRFUserConstants"%>
<%@ page import="ecrf.user.constants.ECRFUserPortletKeys"%>
<%@ page import="ecrf.user.constants.ECRFUserPageFriendlyURL"%>
<%@ page import="ecrf.user.constants.ECRFUserUtil"%>

<%@ page import="ecrf.user.constants.attribute.ECRFUserCRFAttributes"%>
<%@ page import="ecrf.user.constants.attribute.ECRFUserSubjectAttributes"%>
<%@ page import="ecrf.user.constants.attribute.ECRFUserCRFDataAttributes"%>

<%@ page import="ecrf.user.service.CRFLocalServiceUtil"%>

<%@ page import="ecrf.user.model.Subject" %>
<%@ page import="ecrf.user.service.SubjectLocalServiceUtil" %>

<%@ page import="ecrf.user.model.LinkCRF" %>
<%@ page import="ecrf.user.service.LinkCRFLocalServiceUtil" %>

<%@ page import="ecrf.user.model.CRFHistory" %>
<%@ page import="ecrf.user.service.CRFHistoryLocalServiceUtil"%>

<%@ page import="com.sx.icecap.service.DataTypeLocalServiceUtil"%>
<%@ page import="com.sx.icecap.model.DataType"%>

<%@ page import="com.sx.icecap.model.StructuredData"%>

<%@ page import="ecrf.user.crf.data.util.SearchUtil" %>
<%@ page import="ecrf.user.crf.data.util.HistorySearch"%>

<%@ page import="ecrf.user.model.CRFSubject"%>
<%@ page import="ecrf.user.service.CRFSubjectLocalServiceUtil"%>

<%@ page import="ecrf.user.service.CRFAutoqueryLocalServiceUtil"%>
<%@ page import="ecrf.user.crf.data.util.CRFGroupCaculation"%>

<liferay-theme:defineObjects />

<portlet:defineObjects />

<%! private static Log _init_log = LogFactoryUtil.getLog("html.crf-data.init_jsp"); %>

<%
	String currentURL = themeDisplay.getURLCurrent();
	String backURL = ParamUtil.getString(renderRequest, ECRFUserWebKeys.BACK_URL, "");
	String redirect = ParamUtil.getString(renderRequest, WebKeys.REDIRECT, "");
	
	Locale defaultLocale = PortalUtil.getSiteDefaultLocale(themeDisplay.getScopeGroupId());
	
	Set<Locale> availableLocales = LanguageUtil.getAvailableLocales();
	
	JSONArray jsonLocales = JSONFactoryUtil.createJSONArray();
	availableLocales.forEach( jsonLocales::put );
	
	long crfId = 0L;
	long dataTypeId = 0L;
	
	boolean updatePermission = true;

	//check user roles
	if(user != null) {
		List<Role> roleList = user.getRoles();
		for(int i=0; i<roleList.size(); i++) {
			Role role = roleList.get(i);
			if(role.getName().equals("Guest")) updatePermission = false;
		}
	}
	
	crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFAttributes.CRF_ID, 0);
	dataTypeId = CRFLocalServiceUtil.getDataTypeId(crfId);
		
	_init_log.info("crf id / datatype id : " + crfId + " / " + dataTypeId);
%>

<script charset="utf-8" src="/o/ecrf.user.crf.data/js/crf-data.js" ></script>