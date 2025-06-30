<%@page import="com.liferay.portal.kernel.portlet.LiferayPortletURL"%>
<%@page import="com.sx.icecap.constant.IcecapWebPortletKeys"%>
<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf/view-crf-data_jsp"); %>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
	
	DataType dataType = DataTypeLocalServiceUtil.getDataType(dataTypeId);

	long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
	Subject subject = (Subject)renderRequest.getAttribute(ECRFUserCRFDataAttributes.SUBJECT);
	LinkCRF linkCRF = (LinkCRF)renderRequest.getAttribute(ECRFUserCRFDataAttributes.LINK_CRF);
	String fromFlag = ParamUtil.getString(renderRequest, "fromFlag", "");
	String cmd = ParamUtil.getString(renderRequest, "command", "add");
	long sdId = ParamUtil.getLong(renderRequest, "structuredDataId", 0);
	
	String dataStructure = (String)renderRequest.getAttribute(ECRFUserCRFDataAttributes.DATA_STRUCTURE);
	String structuredData = (String)renderRequest.getAttribute(ECRFUserCRFDataAttributes.STRUCTURED_DATA);
	
	_log.info("view-crf / subject id: "+subjectId);
	_log.info("cmd ? " + cmd);
	
	_log.info("dataTypeId : " + dataTypeId);
	_log.info("linkCRF : " + linkCRF);
	//_log.info("dataStructure : " + dataStructure);
	
	_log.info("redirect : " + redirect);
	
	boolean isUpdate = false;
	
	if(linkCRF != null){
		sdId = linkCRF.getStructuredDataId();
		isUpdate = true;
	}
	
	String menu = ECRFUserMenuConstants.UPDATE_CRF_DATA;
	
	String sdPortlet = IcecapWebPortletKeys.STRUCTURED_DATA;
	
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
	
	String queryString = "subjectId="+ subjectId + "&structuredDataId="+ sdId + "&dataTypeId="+ dataTypeId + "&mvcRenderCommandName=/html/StructuredData/edit-structured-data" + "&baseURL=" + rootURL;
	
	_log.info(queryString);
%>
<div class="ecrf-user-crf-data ecrf-user">
	<%@ include file="../other/sidebar.jspf" %>
	<div class="page-content">
		<div class="crf-header-title">
			<% DataType titleDT = DataTypeLocalServiceUtil.getDataType(dataTypeId); %>
			<liferay-ui:message key="ecrf-user.general.crf-title-x" arguments="<%=titleDT.getDisplayName(themeDisplay.getLocale()) %>" />
		</div>
		
		<liferay-ui:header backURL="<%=redirect %>" title="<%=isUpdate ? "ecrf-user.crf-data.title.update-crf-data" : "ecrf-user.crf-data.title.add-crf-data"%>" /> 
		
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
				<liferay-portlet:runtime portletName="<%=sdPortlet %>" queryString="<%=queryString %>">
				</liferay-portlet:runtime>
			</aui:fieldset>
		</aui:fieldset-group>
	</div>
</div>

<aui:script use="aui-base, liferay-form, liferay-menu, liferay-portlet-url">

$(document).ready(function(){
	let sdPortletKey = "_<%=sdPortlet %>_";
	//console.log(sdPortletKey); 
	
	// add back button at button-holder
	
	var btn = $("#"+sdPortletKey+"btnSave");
	btn.attr("class", "dh-icon-button save-btn w80");
	//btn.css("background-color", "#0B5FFF");
	//btn.css("color", "white");
	
	$("#"+sdPortletKey+"btnDelete").hide();
	
	let dataStructure = <%= dataStructure %>;
	let structuredData = <%= Validator.isNotNull(structuredData) %> ? JSON.parse('<%= structuredData %>') : null;
	
	let SX_CRF =  StationX(  sdPortletKey, 
			'<%= defaultLocale.toString() %>',
			'<%= locale.toString() %>',
			<%= jsonLocales.toJSONString() %> );

	//console.log("SX_CRF", SX_CRF);

	let profile = {
			dataTypeId: '<%= dataType.getDataTypeId() %>',
			dataTypeName:  '<%= dataType.getDataTypeName() %>',
			dataTypeVersion:  '<%= dataType.getDataTypeVersion() %>',
			dataTypeDisplayName:  '<%= dataType.getDisplayName(locale) %>',
			structuredDataId: '<%= sdId %>'
	};
	//console.log(profile);
	
	let ev = ECRFViewer(SX_CRF);
	
	//console.log("ECRFViewer: ", ev);
	
	let align = "crf-align-vertical";
	
	let subjectInfo = new Object();
	let subjectGender = <%=subject.getGender()%>;
	let subjectBirth = new Date(<%=subject.getBirth().getTime()%>);
	subjectInfo["subjectGender"] = subjectGender;
	subjectInfo["subjectBirth"] = subjectBirth;
	
	//console.log("data structure : ", dataStructure);
	
	let viewer = new ev.Viewer(dataStructure, align, structuredData, subjectInfo, false, 'station-x');
	
	Liferay.on( SX_CRF.Events.AUTO_CALCULATE, function(evt){
		//console.log("crf : auto calculate", evt);
		
		let payload = evt.dataPacket.payload; 
		
		ev.autoCalUtil.checkAutoCal(evt.dataPacket);
	});
});

</aui:script>