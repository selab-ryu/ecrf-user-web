<%@page import="ecrf.user.constants.type.UILayout"%>
<%@page import="ecrf.user.constants.ECRFUserActionKeys"%>
<%@ include file="../init.jsp" %>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
	
	String menu = "crf-add";
	
	boolean isUpdate = false;

	CRF crf = null;
	
	
	if(crfId > 0) {
		crf = (CRF)renderRequest.getAttribute(ECRFUserCRFAttributes.CRF);
		if(Validator.isNotNull(crf)) {
			isUpdate = true;
			menu = "crf-update";	
		}
	}
	
	List<String> expGroupList = Stream.of(ExperimentalGroupType.values()).map(m -> m.getFullString()).collect(Collectors.toList());
	
	DataType dataType = null;
	
	if(isUpdate) {
		dataTypeId = crf.getDatatypeId();
		
		if(dataTypeId > 0) {
			dataType = DataTypeLocalServiceUtil.getDataType(dataTypeId);
		}
	}
%>

<div class="ecrf-user">

	<%@include file="sidebar.jspf" %>
	
	<div class="page-content">
		<liferay-ui:header backURL="<%=redirect %>" title="Import Subjects" />
	</div>
</div>
		