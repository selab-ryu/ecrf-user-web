<%@page import="com.sx.icecap.constant.IcecapWebPortletKeys"%>
<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf/update-crf-data_jsp"); %>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
	
	long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
	
	System.out.println("view-crf / subject id: "+subjectId);
	String fromFlag = ParamUtil.getString(renderRequest, "fromFlag", "");
	
	Subject subject = null;
	LinkCRF linkCRF = null;
	
	if(subjectId > 0) {
		
		subject = (Subject)renderRequest.getAttribute(ECRFUserCRFDataAttributes.SUBJECT);
		linkCRF = (LinkCRF)renderRequest.getAttribute(ECRFUserCRFDataAttributes.LINK_CRF);
	}
	System.out.println("dataTypeId : " + dataTypeId);
	System.out.println("linkCRF : " + linkCRF);
	
	String cmd = ParamUtil.getString(renderRequest, "command", "add");
	System.out.println("cmd ? " + cmd);
	long sdId = ParamUtil.getLong(renderRequest, "structuredDataId", 0);

	if(linkCRF != null){
		sdId = linkCRF.getStructuredDataId();
	}
	if(fromFlag.equals("selector-add")){
		sdId = 0;
	}
	String menu = "add-crf";
	
	String sdPortlet = IcecapWebPortletKeys.STRUCTURED_DATA;
%>
<div class="ecrf-user-crf-data ecrf-user">
	<%@ include file="../other/sidebar.jspf" %>
	<div class="page-content">
			<aui:container>	
				<aui:row cssClass="">
					<aui:col>
						<aui:fieldset-group markupView="lexicon">
							<aui:fieldset cssClass="search-option radius-shadow-container" collapsed="<%=false %>" collapsible="<%=true %>" label="SXcrfForm.update.title">
								<aui:container>
									<aui:row cssClass="top-border">
										<aui:col md="3" cssClass="marTr">
											<aui:field-wrapper
												name="hospitalCode"
												label="SXcrfForm.subject.hpcode">
												<p><%=Validator.isNull(subject) ? "-" : String.valueOf(subject.getHospitalCode()) %></p>
											</aui:field-wrapper>
										</aui:col>
										<aui:col md="3" cssClass="marTr">
											<aui:field-wrapper
												name="subjectId"
												label="SXcrfForm.subject.id">
												<p><%=Validator.isNull(subject) ? "-" : String.valueOf(subject.getSerialId()) %></p>
											</aui:field-wrapper>
										</aui:col>
										<aui:col md="3" cssClass="marTr">
											<aui:field-wrapper
												name="subjectName"
												label="SXcrfForm.subject.name">
												<p><%=Validator.isNull(subject) ? "-" : subject.getName() %></p>
											</aui:field-wrapper>
										</aui:col>
										<aui:col md="3" cssClass="marTr">
											<aui:field-wrapper
												name="subjectSex"
												label="SXcrfForm.subject.sex">
												<p><%=Validator.isNull(subject) ? "-" : (subject.getGender() == 0 ? "male" : "female") %></p>
											</aui:field-wrapper>
										</aui:col>
									</aui:row>
									<aui:row cssClass="top-border">
										<aui:col md="3" cssClass="marTr">
											<aui:field-wrapper
												name="subjectBirth"
												label="SXcrfForm.subject.birthage">
												<p><%=Validator.isNull(subject) ? "-" : sdf.format(subject.getBirth()) + " (" + Math.abs(124 - subject.getBirth().getYear()) + ")" %></p>
											</aui:field-wrapper>
										</aui:col>
									</aui:row>
								</aui:container>
							</aui:fieldset>
						</aui:fieldset-group>
					</aui:col>
					<aui:col>
						<aui:fieldset-group markupView="lexicon">
							<aui:fieldset cssClass="search-option radius-shadow-container" collapsed="<%=false %>" collapsible="<%=true %>" label="<%= menu.equals("add-crf") ? "SxcrfForm.menu.crf.add" : "SxcrfForm.menu.crf.edit" %>">
								<liferay-portlet:runtime portletName="<%=sdPortlet %>" queryString="<%="subjectId="+ subjectId + "&structuredDataId="+ sdId + "&dataTypeId="+ dataTypeId + "&mvcRenderCommandName=/html/StructuredData/edit-structured-data"%>">
								</liferay-portlet:runtime>
							</aui:fieldset>
						</aui:fieldset-group>
					</aui:col>
				</aui:row>
			</aui:container>
		</div>
</div>