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
			"mvc.command.name="+ECRFUserMVCCommand.RENDER_ADD_EXP_GROUP
		},
		service = MVCRenderCommand.class
	)
public class AddExpGroupRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log.info("Start");
		
		_log.info("End");
		
		return ECRFUserJspPaths.JSP_UPDATE_EXP_GROUP;
	}
	
	private Log _log = LogFactoryUtil.getLog(AddExpGroupRenderCommand.class);
	
	@Reference
	private ProjectLocalService _projectLocalService;
}
