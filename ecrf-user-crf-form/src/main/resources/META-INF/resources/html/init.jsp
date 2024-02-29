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

<%@ page import="javax.portlet.PortletURL" %>
<%@ page import="javax.portlet.PortletRequest"%>

<%@ page import="com.liferay.portal.kernel.util.ParamUtil" %>
<%@ page import="com.liferay.portal.kernel.util.WebKeys" %>
<%@ page import="com.liferay.portal.kernel.security.permission.ActionKeys" %>
<%@ page import="com.liferay.portal.kernel.dao.search.SearchContainer" %>
<%@ page import="com.liferay.portal.kernel.exception.PortalException" %>
<%@ page import="com.liferay.portal.kernel.exception.SystemException" %>
<%@ page import="com.liferay.portal.kernel.language.LanguageUtil" %>
<%@ page import="com.liferay.portal.kernel.log.Log" %>
<%@ page import="com.liferay.portal.kernel.log.LogFactoryUtil" %>
<%@ page import="com.liferay.portal.kernel.search.Indexer" %>
<%@ page import="com.liferay.portal.kernel.search.IndexerRegistryUtil" %>
<%@ page import="com.liferay.portal.kernel.search.SearchContext" %>
<%@ page import="com.liferay.portal.kernel.search.SearchContextFactory" %>
<%@ page import="com.liferay.portal.kernel.search.Hits" %>
<%@ page import="com.liferay.portal.kernel.search.Document" %>
<%@ page import="com.liferay.portal.kernel.search.Field" %>
<%@ page import="com.liferay.portal.kernel.util.GetterUtil" %>
<%@ page import="com.liferay.portal.kernel.util.Validator" %>
<%@ page import="com.liferay.portal.kernel.util.PortalUtil" %>
<%@ page import="com.liferay.portal.kernel.search.Sort" %>
<%@ page import="com.liferay.portal.kernel.workflow.WorkflowConstants" %>
<%@ page import="com.liferay.portal.kernel.util.ListUtil" %>
<%@ page import="com.liferay.portal.kernel.util.Constants" %>
<%@ page import="com.liferay.portal.kernel.repository.model.FileEntry" %>
<%@ page import="com.liferay.document.library.kernel.service.DLAppLocalServiceUtil" %>
<%@ page import="com.liferay.portal.kernel.service.UserLocalServiceUtil" %>
<%@ page import="com.liferay.portal.kernel.model.User" %>
<%@ page import="com.liferay.portal.kernel.model.Role" %>
<%@ page import="com.liferay.portal.kernel.portlet.LiferayWindowState" %>

<%@ page import="com.liferay.portal.kernel.json.JSONFactoryUtil"%>
<%@ page import="com.liferay.portal.kernel.json.JSONArray"%>
<%@ page import="com.liferay.portal.kernel.json.JSONObject"%>
<%@ page import="com.liferay.portal.kernel.language.LanguageUtil"%>
<%@ page import="com.liferay.portal.kernel.util.PortalUtil"%>

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

<%@ page import="com.liferay.petra.string.StringPool" %>

<%@ page import="ecrf.user.model.CRF"%>
<%@ page import="ecrf.user.model.Subject"%>
<%@ page import="ecrf.user.model.LinkCRF"%>
<%@ page import="ecrf.user.model.CRFHistory"%>
<%@ page import="ecrf.user.constants.*"%>

<%@ page import="ecrf.user.service.CRFLocalServiceUtil"%>
<%@ page import="ecrf.user.service.SubjectLocalService"%>
<%@ page import="ecrf.user.service.LinkCRFLocalService"%>
<%@ page import="ecrf.user.service.CRFHistoryLocalService"%>
<%@ page import="ecrf.user.service.CRFHistoryLocalServiceUtil"%>

<%@ page import="com.sx.constant.StationXWebKeys"%>
<%@ page import="com.sx.icecap.constant.*" %>
<%@ page import="com.sx.icecap.model.DataType"%>

<%@ page import="com.sx.icecap.service.DataTypeLocalServiceUtil"%>

<%@ page import="com.liferay.portal.kernel.portlet.PortletURLFactoryUtil"%>
<%@ page import="com.liferay.portal.kernel.service.LayoutLocalService"%>

<%@page import="ecrf.user.constants.attribute.ECRFUserCRFAttributes"%>

<liferay-theme:defineObjects />
<portlet:defineObjects />

<%
	String currentURL = themeDisplay.getURLCurrent();
	String backURL = ParamUtil.getString(renderRequest, "backURL", "");
	String redirect = ParamUtil.getString(renderRequest, WebKeys.REDIRECT, "");
	
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
%>