/**
 * 
 */
package ecrf.user.approve.command.action;

import com.liferay.portal.kernel.exception.RequiredUserException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.Group;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.GroupLocalServiceUtil;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.service.UserLocalService;
import com.liferay.portal.kernel.service.UserService;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ArrayUtil;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.liveusers.LiveUsers;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserAttributes;

/**
 * @author SELab-Ryu
 *
 */
@Component
(
	property = {
			"javax.portlet.name="+ECRFUserPortletKeys.APPROVE,
			"mvc.command.name="+ECRFUserMVCCommand.ACTION_DELETE_MEMBERSHIP
	},
	service = MVCActionCommand.class
)
public class DeleteMembershipActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		long userId = ParamUtil.getLong(actionRequest, ECRFUserAttributes.USER_ID);
		long groupId = ParamUtil.getLong(actionRequest, ECRFUserAttributes.GROUP_ID);
		
		Group group = GroupLocalServiceUtil.fetchGroup(groupId);
		
		long[] removeUserIds = null;
		
		if (userId > 0) {
			removeUserIds = new long[] {userId};
		}

		long[] filteredRemoveUserIds = _filterRemoveUserIds(groupId, removeUserIds);

		ServiceContext serviceContext = ServiceContextFactory.getInstance(actionRequest);

		_userService.unsetGroupUsers(groupId, filteredRemoveUserIds, serviceContext);

		LiveUsers.leaveGroup(group.getCompanyId(), groupId, filteredRemoveUserIds);

		if (removeUserIds.length != filteredRemoveUserIds.length) {
			hideDefaultErrorMessage(actionRequest);
			throw new RequiredUserException();
		}
	}
	
	private long[] _filterRemoveUserIds(long groupId, long[] userIds) {
		Set<Long> filteredUserIds = new HashSet<>();

		for (long userId : userIds) {
			if (_userLocalService.hasGroupUser(groupId, userId)) {
				filteredUserIds.add(userId);
			}
		}

		return ArrayUtil.toArray(filteredUserIds.toArray(new Long[0]));
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
	
	private Log _log = LogFactoryUtil.getLog(DeleteMembershipActionCommand.class);
	
	@Reference
	private UserLocalService _userLocalService;

	@Reference
	private UserService _userService;
}
