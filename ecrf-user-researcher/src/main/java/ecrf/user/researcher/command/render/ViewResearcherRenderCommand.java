package ecrf.user.researcher.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
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
		"mvc.command.name="+ECRFUserMVCCommand.RENDER_VIEW_RESEARCHER
	},
	service = MVCRenderCommand.class
)
public class ViewResearcherRenderCommand implements MVCRenderCommand {
	private Log _log;
	
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log = LogFactoryUtil.getLog(this.getClass().getName());
		return "/html/researcher/view-researcher.jsp";
	}

}
