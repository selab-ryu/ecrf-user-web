package ecrf.user.crf.data.command.render.data;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
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

		Subject subject = null;
		LinkCRF linkCRF = null;
		
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
		
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.SUBJECT, subject);
		renderRequest.setAttribute("SubjectLocalService", _subjectLocalService);
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.LINK_CRF, linkCRF);
		renderRequest.setAttribute("LinkCRFLocalService", _linkCRFLocalService);
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.CRF_ID, crfId);
		renderRequest.setAttribute("fromFlag", fromFlag);
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
