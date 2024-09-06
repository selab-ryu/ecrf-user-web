package ecrf.user.approve.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.service.MembershipRequestLocalService;
import com.liferay.portal.kernel.service.UserLocalService;
import com.liferay.portal.kernel.util.ParamUtil;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserConstants;
import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserApproveAttibutes;
import ecrf.user.service.ResearcherLocalService;

@Component(
	property = {
		"javax.portlet.name="+ECRFUserPortletKeys.APPROVE,
		"mvc.command.name="+ECRFUserMVCCommand.RENDER_UPDATE_SITE_ROLE
		
	},
	service = MVCRenderCommand.class
)
public class UpdateSiteRoleRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log.info("Start");
				
		return ECRFUserJspPaths.JSP_UPDATE_SITE_ROLE;
	}
	
	private Log _log = LogFactoryUtil.getLog(UpdateSiteRoleRenderCommand.class);
}
