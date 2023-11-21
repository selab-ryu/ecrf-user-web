/**
 * 
 */
package ecrf.user.subject.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;

/**
 * @author SELab-Ryu
 *
 */
@Component(
	property = {
		"javax.portlet.name="+ECRFUserPortletKeys.SUBJECT,
		"mvc.command.name="+ECRFUserMVCCommand.RENDER_LIST_SUBJECT	
	},
	service=MVCRenderCommand.class
)
public class ListSubjectRenderCommand implements MVCRenderCommand {
	private Log _log;
	
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log = LogFactoryUtil.getLog(this.getClass().getName());
		
		return ECRFUserJspPaths.JSP_LIST_SUBJECT;
	}

}
