<%@page import="com.sx.icecap.constant.IcecapWebPortletKeys"%>
<%@ include file="../../init.jsp" %>

<%! private static Log _log = LogFactoryUtil.getLog("ecrf-user-crf/html/crf/update-crf-data_jsp"); %>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
	
	long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
	
	System.out.println("view-crf / subject id: "+subjectId);
	
	Subject subject = null;
	LinkCRF linkCRF = null;
	
	if(subjectId > 0) {
		dataTypeId = (long)renderRequest.getAttribute("dataTypeId");
		subject = (Subject)renderRequest.getAttribute(SXCRFFormSubjectAttributes.SUBJECT);
		linkCRF = (LinkCRF)renderRequest.getAttribute(SXCRFFormSubjectAttributes.LINK_CRF);
	}
	System.out.println("dataTypeId : " + dataTypeId);
	System.out.println("linkCRF : " + linkCRF);
	
	long sdId = 0;
	
	if(linkCRF != null){
		sdId = linkCRF.getStructuredDataId();
	}
	
	String menu = "add-crf";
	if(sdId > 0){
		menu = "edit-crf";
	}
	System.out.println("sdId : " + sdId);
	
	String sdPortlet = IcecapWebPortletKeys.STRUCTURED_DATA;
%>
<div class="SXCRFForm-web">
	<%@ include file="sidebar.jspf" %>
	<div class="page-content-sub">
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
												<p><%=Validator.isNull(subject) ? "-" : String.valueOf(subject.getSubjectIdStr()) %></p>
											</aui:field-wrapper>
										</aui:col>
										<aui:col md="3" cssClass="marTr">
											<aui:field-wrapper
												name="subjectName"
												label="SXcrfForm.subject.name">
												<p><%=Validator.isNull(subject) ? "-" : subject.getSubjectName() %></p>
											</aui:field-wrapper>
										</aui:col>
										<aui:col md="3" cssClass="marTr">
											<aui:field-wrapper
												name="subjectSex"
												label="SXcrfForm.subject.sex">
												<p><%=Validator.isNull(subject) ? "-" : (subject.getSubjectSex() ? "male" : "female") %></p>
											</aui:field-wrapper>
										</aui:col>
									</aui:row>
									<aui:row cssClass="top-border">
										<aui:col md="3" cssClass="marTr">
											<aui:field-wrapper
												name="subjectBirth"
												label="SXcrfForm.subject.birthage">
												<p><%=Validator.isNull(subject) ? "-" : sdf.format(subject.getSubjectBirth()) + " (" + Math.abs(123 - subject.getSubjectBirth().getYear()) + ")" %></p>
											</aui:field-wrapper>
										</aui:col>
										<aui:col md="3" cssClass="marTr">
											<aui:field-wrapper
												name="visitDate"
												label="SXcrfForm.subject.visit">
												<p><%=Validator.isNull(subject) ? "-" : sdf.format(subject.getVisitDate()) %></p>
											</aui:field-wrapper>
										</aui:col>
										<aui:col md="3" cssClass="marTr">
											<aui:field-wrapper
												name="hasCohortStudy"
												label="SXcrfForm.subject.cohort">
												<p><%=Validator.isNull(subject) ? "-" : (subject.getHasCohortStudy() ? "yes" : "no") %></p>											</aui:field-wrapper>
										</aui:col>
										<aui:col md="3" cssClass="marTr">
											<aui:field-wrapper
												name="hasMRIStudy"
												label="SXcrfForm.subject.mri">
												<p><%=Validator.isNull(subject) ? "-" : (subject.getHasMRIStudy() ? "yes" : "no") %></p>											</aui:field-wrapper>
										</aui:col>
									</aui:row>
								</aui:container>
							</aui:fieldset>
						</aui:fieldset-group>
					</aui:col>
					<aui:col>
						<aui:fieldset-group markupView="lexicon">
							<aui:fieldset cssClass="search-option radius-shadow-container" collapsed="<%=false %>" collapsible="<%=true %>" label="<%= menu.equals("add-crf") ? "SxcrfForm.menu.crf.add" : "SxcrfForm.menu.crf.edit" %>">
								<liferay-portlet:runtime portletName="<%=sdPortlet %>" queryString="<%="subjectId="+ subjectId + "&structuredDataId="+ sdId + "&dataTypeId="+ dataTypeId + "&mvcRenderCommandName=" + IcecapMVCCommands.RENDER_STRUCTURED_DATA_EDIT%>">
								</liferay-portlet:runtime>
							</aui:fieldset>
						</aui:fieldset-group>
					</aui:col>
				</aui:row>
			</aui:container>
		</div>
</div>