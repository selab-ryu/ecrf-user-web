package ecrf.user.crf.form.command.action.redirect;

import com.liferay.portal.kernel.portlet.PortletURLFactory;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.LayoutLocalService;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserCRFAttributes;

@Component(
    immediate = true,
    property = {
        "javax.portlet.name=" + ECRFUserPortletKeys.CRF_FORM,
        "mvc.command.name="+ECRFUserMVCCommand.ACTION_MOVE_CRF_QUERY
    },
    service = MVCActionCommand.class
)
public class MoveCRFQueryActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFAttributes.CRF_ID, 0);
				
		String pageFriendlyURL = "/crf/query";
		String portletKey = ECRFUserPortletKeys.CRF_QUERY;
		
		long plid = 0L;
		
		try {
			plid = _layoutLocalService.getFriendlyURLLayout(themeDisplay.getScopeGroupId(), true, pageFriendlyURL).getPlid();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		PortletURL renderURL = _portletURLFactory.create(
			actionRequest, 
			portletKey, 
			plid,
			PortletRequest.RENDER_PHASE);
		
		renderURL.setParameter(ECRFUserCRFAttributes.CRF_ID, String.valueOf(crfId));
		
//		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, ECRFUserMVCCommand.RENDER_LIST_CRF_DATA);
//		renderURL.setParameter(ECRFUserWebKeys.LIST_PATH, ECRFUserJspPaths.JSP_LIST_CRF_DATA);		
		
		actionResponse.sendRedirect(renderURL.toString());
	}
	
	@Reference
	private PortletURLFactory _portletURLFactory;
	
	@Reference
	private LayoutLocalService _layoutLocalService;
}