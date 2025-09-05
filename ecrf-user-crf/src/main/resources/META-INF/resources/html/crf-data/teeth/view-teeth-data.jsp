<%@page import="com.liferay.portal.kernel.portlet.LiferayPortletURL"%>
<%@page import="com.sx.icecap.constant.IcecapWebPortletKeys"%>
<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf/view-teeth-data_jsp"); %>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
	
	DataType dataType = DataTypeLocalServiceUtil.getDataType(dataTypeId);
	
	Subject subject = (Subject)renderRequest.getAttribute(ECRFUserCRFDataAttributes.SUBJECT);
	LinkCRF linkCRF = (LinkCRF)renderRequest.getAttribute(ECRFUserCRFDataAttributes.LINK_CRF);
	
	long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
	long linkId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.LINK_ID, 0);
		
	_log.info("view-crf / subject id: "+subjectId);
	
	boolean isUpdate = false;
	
	if(linkCRF != null){
		isUpdate = true;
	}
	
	String menu = ECRFUserMenuConstants.VIEW_TEETH_DATA;
	
	String teethPortlet = ECRFUserPortletKeys.TEETH_DATA;
		
	LiferayPortletURL baseURL = PortletURLFactoryUtil.create(request, themeDisplay.getPortletDisplay().getId(), themeDisplay.getPlid(), PortletRequest.RENDER_PHASE);
	_log.info(baseURL.toString());
	
	String baseURLStr = baseURL.toString();
	String[] result = baseURLStr.split("\\?");
	String rootURL = "";
	if(result.length > 0) {
		rootURL = result[0];
	}
	
	if(Validator.isNull(redirect)) {
		// set redirect for update crf data page when direct by selector dialog
	}
	
	String queryString = "subjectId="+ subjectId + "&linkId="+ linkId + "&crfId="+ crfId + "&mvcRenderCommandName=/teeth/teethView";
	// "&mvcRenderCommandName=/html/StructuredData/edit-structured-data"
	// "&baseURL=" + rootURL + 
	
	// WHY TEETH WEB DOESNT DISPLAY?
	
	_log.info(queryString);
%>
<div class="ecrf-user-crf-data ecrf-user">
	<%@ include file="../other/sidebar.jspf" %>
	<div class="page-content">
		<div class="crf-header-title">
			<% DataType titleDT = DataTypeLocalServiceUtil.getDataType(dataTypeId); %>
			<liferay-ui:message key="ecrf-user.general.crf-title-x" arguments="<%=titleDT.getDisplayName(themeDisplay.getLocale()) %>" />
		</div>
		
		<liferay-ui:header backURL="<%=redirect %>" title="ecrf-user.crf-data.title.view-teeth-data" /> 
		
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
						<%
						String subjectName = subject.getName();
						boolean hasViewEncryptPermission = CRFPermission.contains(permissionChecker, scopeGroupId, ECRFUserActionKeys.VIEW_ENCRYPT_SUBJECT);
						if(!hasViewEncryptPermission)
							subjectName = ECRFUserUtil.encryptName(subjectName);	
						%>
						<aui:col md="3" cssClass="marTr">
							<aui:field-wrapper
								name="name"
								label="ecrf-user.subject.name">
								<p><%=Validator.isNull(subject.getName()) ? "-" : subjectName %></p>
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
					
			<aui:fieldset cssClass="search-option radius-shadow-container" collapsed="<%=false %>" collapsible="<%=true %>" label="ecrf-user.crf-data.title.data-editor">
				<liferay-portlet:runtime portletName="<%=teethPortlet %>" queryString="<%=queryString %>">
				</liferay-portlet:runtime>
			</aui:fieldset>
		</aui:fieldset-group>
	</div>
</div>

<aui:script use="aui-base, liferay-form, liferay-menu, liferay-portlet-url">

</aui:script>