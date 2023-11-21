package ecrf.user.crf.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.sx.icecap.constant.IcecapMVCCommands;
import com.sx.icecap.constant.IcecapWebPortletKeys;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;

@Component(
    immediate = true,
    property = {
        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
        "mvc.command.name="+ECRFUserMVCCommand.RENDER_UPDATE_CRF
    },
    service = MVCRenderCommand.class
)
public class UpdateCRFRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log = LogFactoryUtil.getLog(this.getClass().getName());
		
		return ECRFUserJspPaths.JSP_UPDATE_CRF;
	}
	
	private Log _log;

}
