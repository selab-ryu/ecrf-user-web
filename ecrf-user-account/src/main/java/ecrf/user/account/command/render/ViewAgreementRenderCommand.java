package ecrf.user.account.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.PortletKeys;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;

@Component(
	property = {
		"javax.portlet.name="+PortletKeys.LOGIN,
		"javax.portlet.name="+ECRFUserPortletKeys.ACCOUNT,
		"mvc.command.name="+ECRFUserMVCCommand.RENDER_VIEW_AGREEMENT,
		"service.ranking:Integer=100"
	},
	service = MVCRenderCommand.class
)
public class ViewAgreementRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log.info("View Agreement");		
		
		String login = ParamUtil.getString(renderRequest, "login");
		String password = ParamUtil.getString(renderRequest, "password");
		
		//_log.info("id / pw : " + login + " / " + password);	
		
		return ECRFUserJspPaths.JSP_VIEW_CHECK_AGREEMENT;
	}
	
	private Log _log = LogFactoryUtil.getLog(ViewAgreementRenderCommand.class);
}
