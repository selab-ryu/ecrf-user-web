package ecrf.user.crf.data.command.action.redirect;

import com.liferay.petra.string.StringPool;
import com.liferay.portal.kernel.portlet.PortletURLFactory;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.LayoutLocalService;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;

@Component(
    immediate = true,
    property = {
        "javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA,
        "mvc.command.name="+ECRFUserMVCCommand.ACTION_MOVE_OTHER_PAGE
    },
    service = MVCActionCommand.class
)
public class MoveOtherPageActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
			
		String pageFriendlyURL = ParamUtil.getString(actionRequest, ECRFUserWebKeys.PAGE_FRIENDLY_URL);
		String portletKey = ParamUtil.getString(actionRequest, ECRFUserWebKeys.PORTLET_KEY);
		
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
		
		String renderCommand = ParamUtil.getString(actionRequest, ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, StringPool.BLANK);
		
		if(Validator.isNotNull(renderCommand)) {
			renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		}

		actionResponse.sendRedirect(renderURL.toString());
	}
	
	
	@Reference
	private PortletURLFactory _portletURLFactory;
	
	@Reference
	private LayoutLocalService _layoutLocalService;
}
