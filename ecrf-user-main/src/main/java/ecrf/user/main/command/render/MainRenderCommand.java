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
		"mvc.command.name="+ECRFUserMVCCommand.RENDER_VIEW_SITE
	},
	service = MVCRenderCommand.class
)
public class MainRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
				
		return ECRFUserJspPaths.JSP_VIEW_SITE;
	}
	
	private Log _log = LogFactoryUtil.getLog(MainRenderCommand.class);

}
