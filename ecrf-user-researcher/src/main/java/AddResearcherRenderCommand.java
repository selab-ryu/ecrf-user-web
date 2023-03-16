import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;

@Component(
	property = {
		"javax.portlet.name="+ECRFUserPortletKeys.RESEARCHER,
		"mvc.command.name="+ECRFUserMVCCommand.RENDER_ADD_RESEARCHER
	},
	service = MVCRenderCommand.class
)
public class AddResearcherRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		
		return "/html/researcher/update-researcher.jsp";
	}

}
