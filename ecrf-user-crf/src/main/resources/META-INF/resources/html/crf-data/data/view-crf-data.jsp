<%@page import="com.liferay.portal.kernel.portlet.LiferayPortletURL"%>
<%@page import="com.sx.icecap.constant.IcecapWebPortletKeys"%>
<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf/update-crf-data_jsp"); %>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
	
	long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
	
	_log.info("view-crf / subject id: "+subjectId);
	String fromFlag = ParamUtil.getString(renderRequest, "fromFlag", "");
	
	Subject subject = null;
	LinkCRF linkCRF = null;
	
	boolean isUpdate = false;
	
	if(subjectId > 0) {
		
		subject = (Subject)renderRequest.getAttribute(ECRFUserCRFDataAttributes.SUBJECT);
		linkCRF = (LinkCRF)renderRequest.getAttribute(ECRFUserCRFDataAttributes.LINK_CRF);
	}
	_log.info("dataTypeId : " + dataTypeId);
	_log.info("linkCRF : " + linkCRF);
	
	String cmd = ParamUtil.getString(renderRequest, "command", "add");
	_log.info("cmd ? " + cmd);
	long sdId = ParamUtil.getLong(renderRequest, "structuredDataId", 0);

	if(linkCRF != null){
		sdId = linkCRF.getStructuredDataId();
		isUpdate = true;
	}
	if(fromFlag.equals("selector-add")){
		sdId = 0;
	}
	String menu = "update-crf-data";
	
	String sdPortlet = IcecapWebPortletKeys.STRUCTURED_DATA;
	
	LiferayPortletURL baseURL = PortletURLFactoryUtil.create(request, themeDisplay.getPortletDisplay().getId(), themeDisplay.getPlid(), PortletRequest.RENDER_PHASE);
	
	_log.info(baseURL.toString());
	
	String baseURLStr = baseURL.toString();
	String[] result = baseURLStr.split("\\?");
	String rootURL = "";
	if(result.length > 0) {
		rootURL = result[0];
	}
	
	String queryString = "subjectId="+ subjectId + "&structuredDataId="+ sdId + "&dataTypeId="+ dataTypeId + "&mvcRenderCommandName=/html/StructuredData/edit-structured-data" + "&baseURL=" + rootURL;
	
	_log.info(queryString);
%>
<div class="ecrf-user-crf-data ecrf-user">
	<%@ include file="../other/sidebar.jspf" %>
	<div class="page-content">
		<aui:fieldset-group markupView="lexicon">
			<aui:fieldset cssClass="search-option radius-shadow-container" collapsed="<%=false %>" collapsible="<%=true %>" label="ecrf-user.subject.title.subject-info">
				<aui:container>
					<aui:row cssClass="top-border">
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="serialId"
								label="ecrf-user.subject.serial-id">
								<p><%=Validator.isNull(subject) ? "-" : String.valueOf(subject.getSerialId()) %></p>
							</aui:field-wrapper>
						</aui:col>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="name"
								label="ecrf-user.subject.name">
								<p><%=Validator.isNull(subject) ? "-" : subject.getName() %></p>
							</aui:field-wrapper>
						</aui:col>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="gender"
								label="ecrf-user.subject.gender">
								<p><%=Validator.isNull(subject) ? "-" : (subject.getGender() == 0 ? "male" : "female") %></p>
							</aui:field-wrapper>
						</aui:col>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="birth"
								label="ecrf-user.subject.birth-age">
								<p><%=Validator.isNull(subject) ? "-" : sdf.format(subject.getBirth()) + " (" + Math.abs(124 - subject.getBirth().getYear()) + ")" %></p>
							</aui:field-wrapper>
						</aui:col>
					</aui:row>
				</aui:container>
			</aui:fieldset>
					
			<aui:fieldset cssClass="search-option radius-shadow-container" collapsed="<%=false %>" collapsible="<%=true %>" label="<%=isUpdate ? "ecrf-user.crf-data.title.update-crf-data" : "ecrf-user.crf-data.title.add-crf-data"%>">
				<liferay-portlet:runtime portletName="<%=sdPortlet %>" queryString="<%=queryString %>">
				</liferay-portlet:runtime>
			</aui:fieldset>
		</aui:fieldset-group>
	</div>
</div>