package ecrf.user.crf.command.render.data.other;

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
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.constants.attribute.ECRFUserSubjectAttributes;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.service.SubjectLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name=" + ECRFUserMVCCommand.RENDER_VIEW_AUDIT,
	    },
	    service = MVCRenderCommand.class
	)

public class ViewAuditTrailRenderCommand implements MVCRenderCommand {
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException{
		_log.info("Render AuditTrail");
		
		long subjectId = ParamUtil.getLong(renderRequest, ECRFUserSubjectAttributes.SUBJECT_ID, 0);
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long sdId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID, 0);
		
		Subject subject = null;
		String crfForm = "";
		String answerForm = "";
		
		long dataTypeId = 0;
				
		if(subjectId > 0 && sdId > 0 && crfId > 0) {
			try {
				dataTypeId = _crfLocalService.getDataTypeId(crfId);
				
				subject = _subjectLocalService.getSubject(subjectId);
				String crfFormStr = _dataTypeLocalService.getDataTypeStructure(dataTypeId);
				JSONObject jsonObject = JSONFactoryUtil.createJSONObject(crfFormStr);
				crfForm = jsonObject.getString("terms");
				answerForm = _dataTypeLocalService.getStructuredData(sdId);
			} catch (Exception e) {
				throw new PortletException("Cannot find subject : " + subjectId);
			}
		}
		
		_log.info(sdId);
		
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.SUBJECT, subject);
		
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.CRF_FORM, crfForm);
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.ANSWER_FORM, answerForm);
		
		return ECRFUserJspPaths.JSP_CRF_DATA_VIEW_AUDIT;
	}
	
	private Log _log = LogFactoryUtil.getLog(ViewAuditTrailRenderCommand.class);
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private LinkCRFLocalService _linkCRFLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
	
	@Reference
	private CRFLocalService _crfLocalService;
}
