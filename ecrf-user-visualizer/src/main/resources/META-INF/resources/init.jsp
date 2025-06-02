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
<%@ taglib uri="http://liferay.com/tld/asset" prefix="liferay-asset" %>
<%@ taglib uri="http://liferay.com/tld/comment" prefix="liferay-comment" %>

<%@ page import="javax.portlet.PortletURL" %>

<%@ page import="com.liferay.portal.kernel.util.ParamUtil" %>
<%@ page import="com.liferay.portal.kernel.util.WebKeys" %>
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

<%@ page import="com.liferay.asset.kernel.service.AssetEntryLocalServiceUtil" %>
<%@ page import="com.liferay.asset.kernel.service.AssetTagLocalServiceUtil" %>
<%@ page import="com.liferay.asset.kernel.model.AssetEntry" %>
<%@ page import="com.liferay.asset.kernel.model.AssetTag" %>
<%@ page import="com.liferay.portal.kernel.util.ListUtil" %>
<%@ page import="com.liferay.portal.kernel.comment.Discussion" %>
<%@ page import="com.liferay.portal.kernel.comment.CommentManagerUtil" %>
<%@ page import="com.liferay.portal.kernel.service.ServiceContextFunction" %>

<%@ page import="com.liferay.portal.kernel.log.Log" %>
<%@ page import="com.liferay.portal.kernel.log.LogFactoryUtil" %>

<%@ page import="ecrf.user.constants.ECRFUserWebKeys"%>
<%@ page import="ecrf.user.visualizer.constants.ECRFVisualizerMVCCommand"%>

<%@ page import="ecrf.user.constants.ECRFUserActionKeys"%>
<%@ page import="ecrf.user.constants.ECRFUserWebKeys"%>
<%@ page import="ecrf.user.constants.ECRFUserMVCCommand"%>
<%@ page import="ecrf.user.constants.ECRFUserJspPaths"%>
<%@ page import="ecrf.user.constants.ECRFUserConstants"%>
<%@ page import="ecrf.user.constants.ECRFUserPortletKeys"%>
<%@ page import="ecrf.user.constants.ECRFUserPageFriendlyURL"%>

<%@ page import="ecrf.user.constants.attribute.ECRFUserAttributes"%>
<%@ page import="ecrf.user.constants.attribute.ECRFUserCRFAttributes"%>

<%@ page import="ecrf.user.model.CRF"%>
<%@ page import="ecrf.user.service.CRFLocalServiceUtil"%>
<%@ page import="ecrf.user.service.CRFSubjectLocalServiceUtil"%>
<%@ page import="ecrf.user.service.LinkCRFLocalServiceUtil"%>
<%@ page import="ecrf.user.service.CRFResearcherLocalServiceUtil"%>

<%@ page import="com.sx.icecap.model.DataType"%>
<%@ page import="com.sx.icecap.service.DataTypeLocalServiceUtil"%>

<%@ page import="com.liferay.portal.kernel.json.JSONArray"%>
<%@ page import="com.liferay.portal.kernel.json.JSONObject"%>
<%@ page import="com.liferay.portal.kernel.json.JSONFactoryUtil"%>
<%@ page import="com.liferay.portal.kernel.json.JSON"%>

<liferay-theme:defineObjects />

<portlet:defineObjects />

<!-- Wijmo css/js referenece goes here -->
<link rel="stylesheet" href="https://cdn.mescius.com/wijmo/5.latest/styles/wijmo.min.css" />
<script src="https://cdn.mescius.com/wijmo/5.latest/controls/wijmo.min.js"></script>
<script src="https://cdn.mescius.com/wijmo/5.latest/controls/wijmo.chart.min.js"></script>
<script src="https://cdn.mescius.com/wijmo/5.latest/controls/wijmo.grid.min.js"></script>
<script src="https://cdn.mescius.com/wijmo/5.latest/controls/wijmo.input.min.js"></script>

<script>
wijmo.setLicenseKey('smart-crf.medbiz.or.kr,951833985592528#B0IMJojIyVmdiwSZzxWYmpjIyNHZisnOiwmbBJye0ICRiwiI34zdalVOkVHOrQ7VVd6UoNlcyFVey2meP94Q4x4YMFUQw44YnhmaHFlMG56RL3GWllVSYNnZXFTSzdXe7VncQNXcmVzLm3SUrE5LmZUcKNDZZVnMEhWZwgTTPJENyw6KYhWNP3SazpkZ9gETXNVN4hndzxWZzlFWrckY4hWWyllQOtWOUh7MxRWMUNVYyBTdJ3kQLhTO6okaWpkSPRHTw56NNdGVzFDTzkTW4hWSnF6TaJkZH3SUTpER4FmW48WY6BDNtdFN446QPBlTFZkNwMDapZDcxNzNnRjcnZVQ49WdCh5NhVGVz34S4JkWTdFUOZUM92Ue8tGNuZjTrlVWIFlRXZHZEV6SNVDUUdGSIN7dDJzSMRTOjN7NmNFTEpkZrUmW9NXVpZWVUFEc5IXd4FjcJ9EcxEVd05GNvYVUURkaGdUT9BnY0ZHN7lkW8ADdyoFcqB7RhVlI0IyUiwiIDJ4N9kTNwYjI0ICSiwCO5UTO6EjNxMTM0IicfJye=#Qf35VfikEMyIlI0IyQiwiIu3Waz9WZ4hXRgACdlVGaThXZsZEIv5mapdlI0IiTisHL3JSNJ9UUiojIDJCLi86bpNnblRHeFBCIyV6dllmV4J7bwVmUg2Wbql6ViojIOJyes4nILdDOIJiOiMkIsIibvl6cuVGd8VEIgc7bSlGdsVXTg2Wbql6ViojIOJyes4nI4YkNEJiOiMkIsIibvl6cuVGd8VEIgAVQM3EIg2Wbql6ViojIOJyes4nIzMEMCJiOiMkIsISZy36Qg2Wbql6ViojIOJyes4nIVhzNBJiOiMkIsIibvl6cuVGd8VEIgQnchh6QsFWaj9WYulmRg2Wbql6ViojIOJyebpjIkJHUiwiI4ATMzEDMgITM5ATNyAjMiojI4J7QiwiIwEDOwUjMwIjI0ICc8VkIsIicr9icv9iepJGZl5mLmJ7YtQnch56ciojIz5GRiwiI8qY1ESZ1MaI1YmL146J1QeJ1US90iojIh94QiwiI8ITNykTN5gTOzMDOxUTOiojIklkIs4XXbpjInxmZiwiIyYYNhA');
</script>
<!-- Wijmo css/js referenece goes here -->