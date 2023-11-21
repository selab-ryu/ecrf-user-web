package ecrf.user.main.command.render;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;

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

		return ECRFUserJspPaths.JSP_REQUEST_MEMBERSHIP;
	}

}
