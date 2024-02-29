package ecrf.user.project.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.ParamUtil;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserProjectAttributes;
import ecrf.user.model.Project;
import ecrf.user.service.ProjectLocalService;

@Component(
	property = {
		"javax.portlet.name="+ECRFUserPortletKeys.PROJECT,
		"mvc.command.name="+ECRFUserMVCCommand.RENDER_ADD_PROJECT,
		"mvc.command.name="+ECRFUserMVCCommand.RENDER_UPDATE_PROJECT
		
	},
	service = MVCRenderCommand.class
)
public class UpdateProjectRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log = LogFactoryUtil.getLog(this.getClass().getName());
		_log.info("Start");
		
		String cmd = ParamUtil.getString(renderRequest, Constants.CMD);
		
		if(cmd.equals(Constants.UPDATE)) {
			long projectId = ParamUtil.getLong(renderRequest, ECRFUserProjectAttributes.PROJECT_ID, 0);
			
			Project project = null;
			if(projectId > 0) {
				try {
					project = _projectLocalService.getProject(projectId);
				} catch (Exception e) {
					throw new PortletException("Cannot find project : " + projectId);
				}
				renderRequest.setAttribute(ECRFUserProjectAttributes.PROJECT, project);
			}
		}
		
		_log.info("End");
		return ECRFUserJspPaths.JSP_UPDATE_PROJECT;
	}
	
	private Log _log;
	
	@Reference
	private ProjectLocalService _projectLocalService;
}
