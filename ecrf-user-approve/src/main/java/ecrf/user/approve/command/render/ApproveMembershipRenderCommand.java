package ecrf.user.approve.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.constants.ECRFUserApproveAttibutes;
import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;

@Component(
	property = {
		"javax.portlet.name="+ECRFUserPortletKeys.APPROVE,
		"mvc.command.name="+ECRFUserMVCCommand.RENDER_APPROVE_MEMBERSHIP
		
	},
	service = MVCRenderCommand.class
)
public class ApproveMembershipRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log = LogFactoryUtil.getLog(this.getClass().getName());
		_log.info("Start");
		
		long membershipRequestId = ParamUtil.getLong(renderRequest, ECRFUserApproveAttibutes.MEMBERSHIP_REQUEST_ID, 0);
		
		return ECRFUserJspPaths.JSP_APPROVE_MEMBERSHIP;
	}
	
	private Log _log;
}
