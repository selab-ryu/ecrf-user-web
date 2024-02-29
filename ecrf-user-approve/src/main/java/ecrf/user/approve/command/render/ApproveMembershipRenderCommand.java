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
		"mvc.command.name="+ECRFUserMVCCommand.RENDER_APPROVE_MEMBERSHIP
		
	},
	service = MVCRenderCommand.class
)
public class ApproveMembershipRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log.info("Start");
		
		long membershipRequestId = ParamUtil.getLong(renderRequest, ECRFUserApproveAttibutes.MEMBERSHIP_REQUEST_ID, 0);
		
		renderRequest.setAttribute(ECRFUserConstants.MEMBERSHIP_REQUEST_LOCAL_SERVICE, _membershipRequestLocalService);
		renderRequest.setAttribute(ECRFUserConstants.USER_LOCAL_SERVICE, _userLocalService);
		renderRequest.setAttribute(ECRFUserConstants.RESEARCHER_LOCAL_SERVICE, _researcherLocalService);
		
		return ECRFUserJspPaths.JSP_APPROVE_MEMBERSHIP;
	}
	
	private Log _log = LogFactoryUtil.getLog(ApproveMembershipRenderCommand.class);
	
	@Reference
	private MembershipRequestLocalService _membershipRequestLocalService;
	
	@Reference
	private UserLocalService _userLocalService;
	
	@Reference
	private ResearcherLocalService _researcherLocalService;
}
