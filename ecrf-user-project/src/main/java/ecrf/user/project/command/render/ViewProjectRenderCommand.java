package ecrf.user.project.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.service.ProjectLocalService;

@Component(
		property = {
			"javax.portlet.name="+ECRFUserPortletKeys.PROJECT,
			"mvc.command.name="+ECRFUserMVCCommand.RENDER_VIEW_PROJECT
		},
		service = MVCRenderCommand.class
	)
public class ViewProjectRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log = LogFactoryUtil.getLog(this.getClass().getName());
		_log.info("Start");
		
		_log.info("End");
		return ECRFUserJspPaths.JSP_VIEW_PROJECT;
	}
	
	private Log _log;
	
	@Reference
	private ProjectLocalService _projectLocalService;
}
