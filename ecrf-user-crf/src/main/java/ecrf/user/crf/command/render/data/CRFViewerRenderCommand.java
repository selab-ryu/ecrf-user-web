	package ecrf.user.crf.command.render.data;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.sx.icecap.model.DataType;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.model.CRF;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.service.SubjectLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name="+ECRFUserMVCCommand.RENDER_CRF_VIEWER
	    },
	    service = MVCRenderCommand.class
	)
public class CRFViewerRenderCommand implements MVCRenderCommand {
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log.info("Render CRF Update");

		long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long sdId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID, 0);
		boolean isAudit = ParamUtil.getBoolean(renderRequest, "isAudit", false);
		_log.info("s / c / sd / isAudit : " + subjectId + " / " + crfId + " / " + sdId + " / " + isAudit);
		
		Subject subject = null;
		
		CRF crf = null;
		long dataTypeId = 0;
			
		// get subject
		if(subjectId > 0) {
			try {
				subject = _subjectLocalService.getSubject(subjectId);
				renderRequest.setAttribute("subject", subject);
			} catch (Exception subjectEx) {
				throw new PortletException("Cannot find subject : " + subjectId);
			}
		}
		
		// get crf & dataType id
		try {
			crf = _crfLocalService.getCRF(crfId);
			dataTypeId = crf.getDatatypeId();
		} catch (Exception crfEx) {
			throw new PortletException("Cannot find subject : " + crfId);
		}
		
		// TODO : if there is no datatype structure (crf form)
		// get crf form (datatype structure)
		String crfFormStr = "";
		try {
			crfFormStr = _dataTypeLocalService.getDataTypeStructure(dataTypeId);
		} catch (Exception dataTypeEx) {
			dataTypeEx.printStackTrace();
		}
		
		// get crf data (structured data)
		if(sdId > 0) {
			String answerFormStr = _dataTypeLocalService.getStructuredData(sdId);
			renderRequest.setAttribute(ECRFUserCRFDataAttributes.ANSWER_FORM, answerFormStr);
		}
		
		renderRequest.setAttribute("crfId", crfId);
		renderRequest.setAttribute("dataTypeId", dataTypeId);
		renderRequest.setAttribute("isAudit", isAudit);
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.CRF_FORM, crfFormStr);
		return ECRFUserJspPaths.JSP_CRF_VIEWER;
	}
	
	private Log _log = LogFactoryUtil.getLog(UpdateCRFDataRenderCommand.class);
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private LinkCRFLocalService _linkCRFLocalService;

	@Reference
	private DataTypeLocalService _dataTypeLocalService;

}
