package ecrf.user.main.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserMainAttributes;

@Component(
	property = {
		"javax.portlet.name="+ECRFUserPortletKeys.MAIN,
		"mvc.command.name="+ECRFUserMVCCommand.RENDER_REQUEST_MEMBERSHIP
	},
	service = MVCRenderCommand.class
)
public class RequestMembershipRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		
		long groupId = ParamUtil.getLong(renderRequest, ECRFUserMainAttributes.SITE_GROUP_ID, 0);
		_log.info("site group id : " + groupId);
		
		return ECRFUserJspPaths.JSP_REQUEST_MEMBERSHIP;
	}
	
	private Log _log = LogFactoryUtil.getLog(RequestMembershipRenderCommand.class);

}
