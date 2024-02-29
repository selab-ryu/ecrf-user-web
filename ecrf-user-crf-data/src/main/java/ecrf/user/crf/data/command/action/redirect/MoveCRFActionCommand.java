package ecrf.user.crf.data.command.action.redirect;

import com.liferay.petra.string.StringPool;
import com.liferay.portal.kernel.portlet.PortletURLFactory;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.LayoutLocalService;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserConstants;
import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserCRFAttributes;

@Component(
    immediate = true,
    property = {
        "javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA,
        "mvc.command.name="+ECRFUserMVCCommand.ACTION_MOVE_CRF
    },
    service = MVCActionCommand.class
)
public class MoveCRFActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
	
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		String cmd = ParamUtil.getString(actionRequest, Constants.CMD, StringPool.BLANK);
		String renderCommand = ParamUtil.getString(actionRequest, ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, ECRFUserMVCCommand.RENDER_LIST_CRF);
		
		String listPath = ParamUtil.getString(actionRequest, ECRFUserWebKeys.LIST_PATH, ECRFUserJspPaths.JSP_LIST_CRF);
		
		String pageFriendlyURL = "/crf";
		String portletKey = ECRFUserPortletKeys.CRF;
		
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
				
		if(cmd.equals(Constants.ADD)) {
			renderURL.setParameter(ECRFUserConstants.CMD, ECRFUserConstants.ADD);
		} else {
			renderURL.setParameter(ECRFUserWebKeys.LIST_PATH, listPath);
		}
		
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		
		actionResponse.sendRedirect(renderURL.toString());
	}
	
	@Reference
	private PortletURLFactory _portletURLFactory;
	
	@Reference
	private LayoutLocalService _layoutLocalService;
}
