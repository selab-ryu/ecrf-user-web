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

<%@ page import="com.liferay.portal.kernel.util.ParamUtil" %>
<%@ page import="com.liferay.portal.kernel.util.WebKeys" %>
<%@ page import="com.liferay.portal.kernel.security.permission.ActionKeys" %>
<%@ page import="com.liferay.portal.kernel.exception.PortalException" %>
<%@ page import="com.liferay.portal.kernel.exception.SystemException" %>
<%@ page import="com.liferay.portal.kernel.language.LanguageUtil" %>
<%@ page import="com.liferay.portal.kernel.util.GetterUtil" %>
<%@ page import="com.liferay.portal.kernel.util.Validator" %>
<%@ page import="com.liferay.portal.kernel.util.PortalUtil" %>
<%@ page import="com.liferay.portal.kernel.workflow.WorkflowConstants" %>
<%@ page import="com.liferay.portal.kernel.util.ListUtil" %>
<%@ page import="com.liferay.portal.kernel.util.Constants" %>
<%@ page import="com.liferay.portal.kernel.service.UserLocalServiceUtil" %>
<%@ page import="com.liferay.portal.kernel.model.User" %>
<%@ page import="com.liferay.portal.kernel.model.Role" %>
<%@ page import="com.liferay.portal.kernel.portlet.LiferayWindowState" %>
<%@ page import="com.liferay.portal.kernel.util.HtmlUtil"%>
<%@ page import="com.liferay.portal.kernel.model.MembershipRequestConstants"%>
<%@ page import="com.liferay.portal.kernel.service.MembershipRequestLocalServiceUtil"%>
<%@ page import="com.liferay.portal.kernel.model.MembershipRequest"%>

<%@ page import="com.liferay.portal.kernel.log.Log" %>
<%@ page import="com.liferay.portal.kernel.log.LogFactoryUtil" %>

<%@ page import="com.liferay.portal.kernel.json.JSONObject"%>
<%@ page import="com.liferay.portal.kernel.json.JSONArray"%>
<%@ page import="com.liferay.portal.kernel.json.JSONFactoryUtil"%>

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

<%@ page import="com.liferay.petra.string.StringPool" %>

<%@ page import="ecrf.user.constants.ECRFUserWebKeys"%>
<%@ page import="ecrf.user.constants.ECRFUserMVCCommand"%>
<%@ page import="ecrf.user.constants.ECRFUserJspPaths"%>
<%@ page import="ecrf.user.constants.ECRFUserConstants"%>
<%@ page import="ecrf.user.constants.ECRFUserPortletKeys"%>
<%@ page import="ecrf.user.constants.ECRFUserPageFriendlyURL"%>

<%@ page import="ecrf.user.constants.attribute.ECRFUserAttributes"%>
<%@ page import="ecrf.user.constants.attribute.ECRFUserMainAttributes"%>

<%@ page import="ecrf.user.model.Researcher"%>
<%@ page import="ecrf.user.model.CRF"%>

<%@ page import="ecrf.user.service.CRFLocalServiceUtil"%>

<%@ page import="com.sx.icecap.model.DataTypeStructure"%>
<%@ page import="com.sx.icecap.service.DataTypeStructureLocalServiceUtil"%>
<%@ page import="com.sx.icecap.model.DataType"%>
<%@ page import="com.sx.icecap.service.DataTypeLocalServiceUtil"%>

<%@ page import="ecrf.user.main.display.context.SiteDisplayContext"%>

<liferay-theme:defineObjects />

<portlet:defineObjects />

<%
	String currentURL = themeDisplay.getURLCurrent();
	String backURL = ParamUtil.getString(renderRequest, ECRFUserWebKeys.BACK_URL, "");
	String redirect = ParamUtil.getString(renderRequest, WebKeys.REDIRECT, "");
%>