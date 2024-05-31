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

<%@ page import="javax.portlet.PortletURL" %>
<%@ page import="javax.portlet.PortletRequest"%>

<%@ page import="com.liferay.portal.kernel.util.ParamUtil" %>
<%@ page import="com.liferay.portal.kernel.util.WebKeys" %>
<%@ page import="com.liferay.portal.kernel.util.PortalUtil"%>
<%@ page import="com.liferay.portal.kernel.util.ListUtil" %>
<%@ page import="com.liferay.portal.kernel.util.Constants" %>
<%@ page import="com.liferay.portal.kernel.util.GetterUtil" %>
<%@ page import="com.liferay.portal.kernel.util.Validator" %>
<%@ page import="com.liferay.portal.kernel.security.permission.ActionKeys" %>
<%@ page import="com.liferay.portal.kernel.dao.search.SearchContainer" %>
<%@ page import="com.liferay.portal.kernel.exception.PortalException" %>
<%@ page import="com.liferay.portal.kernel.exception.SystemException" %>
<%@ page import="com.liferay.portal.kernel.language.LanguageUtil" %>
<%@ page import="com.liferay.portal.kernel.search.Indexer" %>
<%@ page import="com.liferay.portal.kernel.search.IndexerRegistryUtil" %>
<%@ page import="com.liferay.portal.kernel.search.SearchContext" %>
<%@ page import="com.liferay.portal.kernel.search.SearchContextFactory" %>
<%@ page import="com.liferay.portal.kernel.search.Hits" %>
<%@ page import="com.liferay.portal.kernel.search.Document" %>
<%@ page import="com.liferay.portal.kernel.search.Field" %>
<%@ page import="com.liferay.portal.kernel.search.Sort" %>
<%@ page import="com.liferay.portal.kernel.workflow.WorkflowConstants" %>
<%@ page import="com.liferay.portal.kernel.repository.model.FileEntry" %>
<%@ page import="com.liferay.document.library.kernel.service.DLAppLocalServiceUtil" %>

<%@ page import="com.liferay.portal.kernel.portlet.LiferayWindowState" %>
<%@ page import="com.liferay.portal.kernel.portlet.PortletURLUtil"%>
<%@ page import="com.liferay.portal.kernel.portlet.PortletURLFactoryUtil"%>

<%@ page import="com.liferay.portal.kernel.model.User" %>
<%@ page import="com.liferay.portal.kernel.model.Role" %>

<%@ page import="com.liferay.portal.kernel.service.UserLocalServiceUtil" %>
<%@ page import="com.liferay.portal.kernel.service.LayoutLocalService"%>

<%@ page import="com.liferay.portal.kernel.log.Log" %>
<%@ page import="com.liferay.portal.kernel.log.LogFactoryUtil" %>

<%@ page import="com.liferay.portal.kernel.json.JSONFactoryUtil"%>
<%@ page import="com.liferay.portal.kernel.json.JSONObject"%>
<%@ page import="com.liferay.portal.kernel.json.JSONArray"%>

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
<%@ page import="java.util.stream.Collectors"%>
<%@ page import="java.util.stream.Stream"%>

<%@ page import="com.liferay.petra.string.StringPool" %>

<%@ page import="ecrf.user.constants.ECRFUserWebKeys"%>
<%@ page import="ecrf.user.constants.ECRFUserMVCCommand"%>
<%@ page import="ecrf.user.constants.ECRFUserJspPaths"%>
<%@ page import="ecrf.user.constants.ECRFUserConstants"%>
<%@ page import="ecrf.user.constants.ECRFUserPortletKeys"%>
<%@ page import="ecrf.user.constants.ECRFUserPageFriendlyURL"%>
<%@ page import="ecrf.user.constants.ECRFUserUtil"%>
<%@ page import="ecrf.user.constants.CRFStatus"%>
<%@ page import="ecrf.user.constants.ExperimentalGroupType"%>

<%@ page import="ecrf.user.constants.attribute.ECRFUserProjectAttributes"%>
<%@ page import="ecrf.user.constants.attribute.ECRFUserCRFAttributes"%>
<%@ page import="ecrf.user.constants.attribute.ECRFUserSubjectAttributes"%>
<%@ page import="ecrf.user.constants.attribute.ECRFUserCRFDataAttributes"%>
<%@ page import="ecrf.user.constants.attribute.ECRFUserAttributes"%>

<%@ page import="ecrf.user.model.custom.CRFSubjectInfo"%>

<%@ page import="ecrf.user.model.Researcher"%>
<%@ page import="ecrf.user.model.CRF"%>
<%@ page import="ecrf.user.model.Subject" %>
<%@ page import="ecrf.user.model.LinkCRF" %>
<%@ page import="ecrf.user.model.CRFHistory" %>
<%@ page import="ecrf.user.model.CRFSubject"%>
<%@ page import="ecrf.user.model.CRFAutoquery"%>

<%@ page import="com.sx.icecap.model.DataType"%>
<%@ page import="com.sx.icecap.model.StructuredData"%>

<%@ page import="ecrf.user.service.SubjectLocalService"%>
<%@ page import="ecrf.user.service.LinkCRFLocalService"%>
<%@ page import="ecrf.user.service.CRFHistoryLocalService"%>

<%@ page import="ecrf.user.service.CRFAutoqueryLocalServiceUtil"%>
<%@ page import="ecrf.user.service.CRFHistoryLocalServiceUtil"%>
<%@ page import="ecrf.user.service.LinkCRFLocalServiceUtil" %>
<%@ page import="ecrf.user.service.SubjectLocalServiceUtil" %>
<%@ page import="ecrf.user.service.ResearcherLocalServiceUtil"%>
<%@ page import="ecrf.user.service.CRFLocalServiceUtil"%>
<%@ page import="ecrf.user.service.ProjectLocalServiceUtil"%>
<%@ page import="ecrf.user.service.CRFSubjectLocalServiceUtil"%>
<%@ page import="ecrf.user.service.CRFResearcherLocalServiceUtil"%>

<%@ page import="com.sx.icecap.service.DataTypeLocalServiceUtil"%>
<%@page import="com.sx.icecap.service.StructuredDataLocalServiceUtil"%>

<%@ page import="com.sx.constant.StationXWebKeys"%>
<%@ page import="com.sx.icecap.constant.*" %>

<%@ page import="ecrf.user.crf.util.SearchUtil"%>

<%@ page import="ecrf.user.crf.util.data.CRFDataSearchUtil" %>
<%@ page import="ecrf.user.crf.util.data.HistorySearch"%>
<%@ page import="ecrf.user.crf.util.data.CRFGroupCaculation"%>

<liferay-theme:defineObjects />

<portlet:defineObjects />

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
	boolean isAdmin = false;
	boolean isPI = false;
	
	if(ResearcherLocalServiceUtil.hasPIPermission(user.getUserId())) isPI = true;
	
	//check user roles
	if(user != null) {
		List<Role> roleList = user.getRoles();
		for(int i=0; i<roleList.size(); i++) {
			Role role = roleList.get(i);
			if(role.getName().equals("Guest")) updatePermission = false;
			if(role.getName().equals("Administrator")) isAdmin = true;
		}
	}
	
	crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFAttributes.CRF_ID, 0);
	dataTypeId = CRFLocalServiceUtil.getDataTypeId(crfId);
%>

<script charset="utf-8" src="/o/ecrf.user.crf/js/crf-data.js" ></script>
<script charset="utf-8" src="/o/ecrf.user.crf/js/ecrf-user-crf.js" ></script>

<!-- 
<ol class="breadcrumb">
	<li class="breadcrumb-item">
		<a class="breadcrumb-link" href="#1" title="Home">
			<span class="breadcrumb-text-truncate">Home</span>
		</a>
	</li>
	<li class="breadcrumb-item">
		<a class="breadcrumb-link" href="#1" title="Components">
			<span class="breadcrumb-text-truncate">Components</span>
		</a>
	</li>
	<li class="breadcrumb-item">
		<a class="breadcrumb-link" href="#1" title="Breadcrumbs and Paginations">
			<span class="breadcrumb-text-truncate">Breadcrumbs and Paginations</span>
		</a>
	</li>
	<li class="breadcrumb-item">
		<a class="breadcrumb-link" href="#1" title="Page">
			<span class="breadcrumb-text-truncate">Page</span>
		</a>
	</li>
	<li class="active breadcrumb-item">
		<span class="breadcrumb-text-truncate" title="Active">Active</span>
	</li>
</ol>
	-->
