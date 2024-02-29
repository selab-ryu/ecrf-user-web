package ecrf.user.approve.command.action;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.Group;
import com.liferay.portal.kernel.model.MembershipRequest;
import com.liferay.portal.kernel.model.MembershipRequestConstants;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.GroupLocalService;
import com.liferay.portal.kernel.service.MembershipRequestService;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Portal;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.liveusers.LiveUsers;

import java.io.IOException;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletResponse;
import javax.portlet.PortletURL;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserApproveAttibutes;

@Component
(
	property = {
			"javax.portlet.name="+ECRFUserPortletKeys.APPROVE,
			"mvc.command.name="+ECRFUserMVCCommand.ACTION_REVIEW_MEMBERSHIP_REQUEST
	},
	service = MVCActionCommand.class
)
public class ReviewMembershipRequestActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
	
		
		replyRequest(actionRequest, actionResponse);
		
		sendRedirect(actionRequest, actionResponse);
	}
	
	public void replyRequest(ActionRequest actionRequest, ActionResponse actionResponse) throws PortalException {
		_log.info("Reply Membership Request");
		
		ServiceContext serviceContext = ServiceContextFactory.getInstance(this.getClass().getName(), actionRequest);
		String cmd = ParamUtil.getString(actionRequest, Constants.CMD);
		long statusId = MembershipRequestConstants.STATUS_DENIED;
		
		if(cmd.equals(Constants.APPROVE)) { statusId = MembershipRequestConstants.STATUS_APPROVED;}
		
		long membershipRequestId = ParamUtil.getLong(actionRequest, ECRFUserApproveAttibutes.MEMBERSHIP_REQUEST_ID);
		String replyComment = ParamUtil.getString(actionRequest, ECRFUserApproveAttibutes.REPLY_COMMENT);
		_log.info("null check : " + cmd + " / " + statusId + " / " + String.valueOf(membershipRequestId) + " / " + replyComment);
		
		_membershipRequestService.updateStatus(membershipRequestId, replyComment, statusId, serviceContext);
		_log.info("status updated");
		
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		if(statusId == MembershipRequestConstants.STATUS_APPROVED) {
			long groupId = ParamUtil.getLong(actionRequest, "groupId", themeDisplay.getSiteGroupIdOrLiveGroupId());
			Group group = _groupLocalService.fetchGroup(groupId);
			
			MembershipRequest membershipRequest = _membershipRequestService.getMembershipRequest(membershipRequestId);
			
			LiveUsers.joinGroup(group.getCompanyId(), groupId, new long[] {membershipRequest.getUserId()});
			
			_log.info("membership updated");
		}
	}
	
	public void sendRedirect(ActionRequest actionRequest, ActionResponse actionResponse) throws IOException {
		_log.info("Redirect");
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		String renderCommand = ECRFUserMVCCommand.RENDER_VIEW_MEMBERSHIP;
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(), 
				PortletRequest.RENDER_PHASE);
		
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		actionResponse.sendRedirect(renderURL.toString());
	}
	
	@Reference
	private Portal _portal;
	
	private Log _log = LogFactoryUtil.getLog(ReviewMembershipRequestActionCommand.class);
	
	@Reference
	private MembershipRequestService _membershipRequestService;
	
	@Reference
	private GroupLocalService _groupLocalService;
}
