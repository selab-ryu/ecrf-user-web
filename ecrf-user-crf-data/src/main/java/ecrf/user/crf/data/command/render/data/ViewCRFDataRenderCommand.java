package ecrf.user.crf.data.command.render.data;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
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
import ecrf.user.model.LinkCRF;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.service.SubjectLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA,
	        "mvc.command.name=" + ECRFUserMVCCommand.RENDER_VIEW_CRF_DATA
	    },
	    service = MVCRenderCommand.class
	)


public class ViewCRFDataRenderCommand implements MVCRenderCommand {
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		System.out.println("Render CRF View");
		
		ThemeDisplay themeDisplay = (ThemeDisplay)renderRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long sdId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID, 0);
		
		String fromFlag = ParamUtil.getString(renderRequest, "fromFlag", "");

		_log.info("s / c / sd : " + subjectId + " / " + crfId + " / " + sdId);
		
		Subject subject = null;
		LinkCRF linkCRF = null;
		
		CRF crf = null;
		long dataTypeId = 0;
		
		JSONArray crfForm = null;	// crf form
		JSONObject answerForm = null;	// crf data
		
		String crfFormStr = "";
		
		try {
			if(subjectId > 0) {
				subject = _subjectLocalService.getSubject(subjectId);
				
				int crfDataCount = _linkCRFLocalService.countLinkCRFByG_S_C(themeDisplay.getScopeGroupId(), subjectId, crfId);
				
				if(crfDataCount > 0) {
					try {
						_log.info("group / subject / crf / sd : " + themeDisplay.getScopeGroupId() + " / " + subjectId + " / " + crfId + " / " + sdId);
						linkCRF = _linkCRFLocalService.getLinkCRFByG_S_C_SD(themeDisplay.getScopeGroupId(), subjectId, crfId, sdId);
					} catch (Exception e) {
						throw new PortletException("Cannot find link");
					}
				}
			}	
						
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		// get crf & dataType id
		try {
			crf = _crfLocalService.getCRF(crfId);
			dataTypeId = crf.getDatatypeId();
		} catch (Exception crfEx) {
			throw new PortletException("Cannot find subject : " + crfId);
		}
		
		// get crf form (datatype structure)
		try {
			crfFormStr = _dataTypeLocalService.getDataTypeStructure(dataTypeId);
		} catch (Exception dataTypeEx) {
			dataTypeEx.printStackTrace();
		}
		
		// get crf data (structured data)
		if(sdId > 0) {
			StructuredData sd = _dataTypeLocalService.getStructuredData(sdId);
			String answerFormStr = sd.getStructuredData();
			
			try {
				JSONObject jsonObject = JSONFactoryUtil.createJSONObject(crfFormStr);
				crfForm = jsonObject.getJSONArray("terms");
				answerForm = JSONFactoryUtil.createJSONObject(answerFormStr);
				
				renderRequest.setAttribute(ECRFUserCRFDataAttributes.ANSWER_FORM, answerForm);
			} catch (Exception e) {
				e.printStackTrace();
			}
		} else {
			try {
				JSONObject jsonObject = JSONFactoryUtil.createJSONObject(crfFormStr);
				crfForm = jsonObject.getJSONArray("terms");
			} catch (Exception e) {
				e.printStackTrace();
			}			
		}
		
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.SUBJECT, subject);
		renderRequest.setAttribute("SubjectLocalService", _subjectLocalService);
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.LINK_CRF, linkCRF);
		renderRequest.setAttribute("LinkCRFLocalService", _linkCRFLocalService);
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.CRF_ID, crfId);
		renderRequest.setAttribute("fromFlag", fromFlag);
		
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.CRF_FORM, crfForm);
		renderRequest.setAttribute("none", "¹Ì½ÃÇà");
		
		return ECRFUserJspPaths.JSP_VIEW_CRF_DATA;
	}

	private Log _log = LogFactoryUtil.getLog(ViewCRFDataRenderCommand.class);
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private LinkCRFLocalService _linkCRFLocalService;

	@Reference
	private DataTypeLocalService _dataTypeLocalService;

}
