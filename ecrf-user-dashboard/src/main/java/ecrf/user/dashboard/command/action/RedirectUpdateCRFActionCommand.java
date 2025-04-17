package ecrf.user.dashboard.command.action;

import com.liferay.alloy.util.Constants;
import com.liferay.portal.kernel.cache.thread.local.Lifecycle;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.Group;
import com.liferay.portal.kernel.model.Layout;
import com.liferay.portal.kernel.portlet.PortletURLFactory;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.security.auth.AuthTokenUtil;
import com.liferay.portal.kernel.security.permission.ActionKeys;
import com.liferay.portal.kernel.service.LayoutLocalService;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.WebKeys;

import java.util.HashMap;
import java.util.Map;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;
import javax.servlet.http.HttpServletRequest;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserCRFAttributes;

@Component
(
	property = {
		"javax.portlet.name=" + ECRFUserPortletKeys.DASHBOARD,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_REDIRECT_UPDATE_CRF,
	},
	service = MVCActionCommand.class
)
public class RedirectUpdateCRFActionCommand extends BaseMVCActionCommand{
	
	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log.info("redirect to crf data list");
				
		long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFAttributes.CRF_ID);
		String redirect = ParamUtil.getString(actionRequest, WebKeys.REDIRECT);
		
		HttpServletRequest httpRequest = PortalUtil.getHttpServletRequest(actionRequest);		
		
		PortletURL cpPortletURL = PortalUtil.getControlPanelPortletURL(httpRequest, ECRFUserPortletKeys.CRF, PortletRequest.RENDER_PHASE);
		
		String renderCommand = ECRFUserMVCCommand.RENDER_UPDATE_CRF;
		cpPortletURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		cpPortletURL.setParameter(ECRFUserCRFAttributes.CRF_ID, String.valueOf(crfId));
		cpPortletURL.setParameter(WebKeys.REDIRECT, redirect);
		
		_log.info(cpPortletURL.toString());
		
		actionResponse.sendRedirect(cpPortletURL.toString());
	}
	
	@Reference
	private PortletURLFactory _portletURLFactory;
	
	@Reference
	private LayoutLocalService _layoutLocalService;
	
	private Log _log = LogFactoryUtil.getLog(RedirectUpdateCRFActionCommand.class);
}
