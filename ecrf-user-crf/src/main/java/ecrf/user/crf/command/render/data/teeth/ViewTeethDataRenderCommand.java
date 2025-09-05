package ecrf.user.crf.command.render.data.teeth;

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
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name=" + ECRFUserMVCCommand.RENDER_VIEW_TEETH_DATA
	    },
	    service = MVCRenderCommand.class
	)


public class ViewTeethDataRenderCommand implements MVCRenderCommand {
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		System.out.println("Render CRF View");
		
		ThemeDisplay themeDisplay = (ThemeDisplay)renderRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long linkId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.LINK_ID, 0);
				
		_log.info("s / c / link : " + subjectId + " / " + crfId + " / " + linkId);
		
		Subject subject = null;
		LinkCRF linkCRF = null;
		
		CRF crf = null;
		long dataTypeId = 0;
			
		try {
			if(subjectId > 0) {
				subject = _subjectLocalService.getSubject(subjectId);
				renderRequest.setAttribute(ECRFUserCRFDataAttributes.SUBJECT_ID, subjectId);
				
				if(linkId > 0) {
					linkCRF = _linkCRFLocalService.getLinkCRF(linkId);
					renderRequest.setAttribute(ECRFUserCRFDataAttributes.LINK_ID, linkId);
				}
				
				int crfDataCount = _linkCRFLocalService.countLinkCRFByG_S_C(themeDisplay.getScopeGroupId(), subjectId, crfId);
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
				
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.SUBJECT, subject);
		renderRequest.setAttribute("SubjectLocalService", _subjectLocalService);
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.LINK_CRF, linkCRF);
		renderRequest.setAttribute("LinkCRFLocalService", _linkCRFLocalService);
		
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.CRF_ID, crfId);
		
		return ECRFUserJspPaths.JSP_VIEW_TEETH_DATA;
	}

	private Log _log = LogFactoryUtil.getLog(ViewTeethDataRenderCommand.class);
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private LinkCRFLocalService _linkCRFLocalService;

	@Reference
	private DataTypeLocalService _dataTypeLocalService;

}
