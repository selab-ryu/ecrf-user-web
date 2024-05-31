package ecrf.user.crf.data.command.render.data;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;
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
import ecrf.user.constants.attribute.ECRFUserApproveAttibutes;
import ecrf.user.constants.attribute.ECRFUserAttributes;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.model.CRF;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.service.SubjectLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA,
	        "mvc.command.name=" + ECRFUserMVCCommand.RENDER_UPDATE_CRF_DATA,
	    },
	    service = MVCRenderCommand.class
	)

public class UpdateCRFDataRenderCommand implements MVCRenderCommand {
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException{
		_log.info("Render CRF Update");
		
		long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long sdId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID, 0);
		
		_log.info("s / c / sd : " + subjectId + " / " + crfId + " / " + sdId);
		
		Subject subject = null;
		
		CRF crf = null;
		long dataTypeId = 0;
		
		JSONArray crfForm = null;	// crf form
		JSONObject answerForm = null;	// crf data
		
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
  
			try {
				JSONObject jsonObject = JSONFactoryUtil.createJSONObject(crfFormStr);
				crfForm = jsonObject.getJSONArray("terms");
				answerForm = JSONFactoryUtil.createJSONObject(answerFormStr);
				
				renderRequest.setAttribute(ECRFUserCRFDataAttributes.CRF_FORM, crfForm);
				renderRequest.setAttribute(ECRFUserCRFDataAttributes.ANSWER_FORM, answerForm);
				renderRequest.setAttribute("none", "¹Ì½ÃÇà");
			} catch (Exception e) {
				e.printStackTrace();
			}
		} else {
			try {
				JSONObject jsonObject = JSONFactoryUtil.createJSONObject(crfFormStr);
				crfForm = jsonObject.getJSONArray("terms");
				
				renderRequest.setAttribute(ECRFUserCRFDataAttributes.CRF_FORM, crfForm);
				renderRequest.setAttribute("none", "¹Ì½ÃÇà");
			} catch (Exception e) {
				e.printStackTrace();
			}			
		}
		
		return ECRFUserJspPaths.JSP_UPDATE_CRF_DATA;
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
