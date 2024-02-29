package ecrf.user.main.command.action;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.MembershipRequestConstants;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.MembershipRequestLocalService;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.servlet.SessionErrors;
import com.liferay.portal.kernel.servlet.SessionMessages;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserMainAttributes;

@Component
(
	property = {
			"javax.portlet.name="+ECRFUserPortletKeys.MAIN,
			"mvc.command.name="+ECRFUserMVCCommand.ACTION_ADD_MEMBERSHIP_REQUEST
	},
	service = MVCActionCommand.class
)
public class AddMembershipRequestActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log.info("add membership request action");
		
		ServiceContext serviceContext = ServiceContextFactory.getInstance(actionRequest);
		
		long siteGroupId = ParamUtil.getLong(actionRequest, ECRFUserMainAttributes.SITE_GROUP_ID, 0);
		_log.info("site group id : " + siteGroupId);
		
		long userId = ParamUtil.getLong(actionRequest, WebKeys.USER_ID);
		_log.info("user id : " + userId);
		
		if (_membershipRequestLocalService.hasMembershipRequest(
				userId, siteGroupId, MembershipRequestConstants.STATUS_PENDING)) {
			
			_log.info("membership already requested");
			SessionErrors.add(actionRequest, "membershipAlreadyRequested");

			hideDefaultErrorMessage(actionRequest);
		}
		else {
			String comments = ParamUtil.getString(actionRequest, ECRFUserMainAttributes.REQUEST_COMMENT);
			
			_log.info("comment : " + comments);
			
			try {
				_membershipRequestLocalService.addMembershipRequest(userId, siteGroupId, comments, serviceContext);
			} catch(Exception e) {
				_log.info("add membership request error");
				e.printStackTrace();
			}
			
			_log.info("what happend");
			
			SessionMessages.add(actionRequest, "membershipRequestSent");
			
			addSuccessMessage(actionRequest, actionResponse);

			hideDefaultSuccessMessage(actionRequest);
		}
		
		_log.info("send redirect");
		
		sendRedirect(actionRequest, actionResponse);
	}
	
	private Log _log = LogFactoryUtil.getLog(AddMembershipRequestActionCommand.class);
	
	@Reference
	private MembershipRequestLocalService _membershipRequestLocalService;
}
