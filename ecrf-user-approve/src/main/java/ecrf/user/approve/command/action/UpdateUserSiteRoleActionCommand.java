/**
 * 
 */
package ecrf.user.approve.command.action;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.User;
import com.liferay.portal.kernel.model.UserGroupRole;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.UserGroupRoleLocalService;
import com.liferay.portal.kernel.service.UserGroupRoleService;
import com.liferay.portal.kernel.service.UserLocalService;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ArrayUtil;
import com.liferay.portal.kernel.util.ListUtil;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Portal;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.users.admin.kernel.util.UsersAdmin;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

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
			"mvc.command.name="+ECRFUserMVCCommand.ACTION_UPDATE_USER_SITE_ROLE
	},
	service = MVCActionCommand.class
)
public class UpdateUserSiteRoleActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		long userId = ParamUtil.getLong(actionRequest, ECRFUserAttributes.USER_ID);
		long groupId = ParamUtil.getLong(actionRequest, ECRFUserAttributes.GROUP_ID);
		
		long[] roleIds = ParamUtil.getLongValues(actionRequest, "rowIds");
		
		_log.info(Arrays.toString(roleIds));
		
		User user = _userLocalService.getUser(userId);
		
		if(user == null) {
			_log.info("user is null");
			sendRedirect(actionRequest, actionResponse);
			return;
		}
		
		List<UserGroupRole> userGroupRoles = _userGroupRoleLocalService.getUserGroupRoles(user.getUserId(), groupId);

		List<Long> curRoleIds = ListUtil.toList(
			userGroupRoles, UsersAdmin.USER_GROUP_ROLE_ID_ACCESSOR);

		List<Long> removeRoleIds = new ArrayList<>();

		for (long roleId : curRoleIds) {
			if (!ArrayUtil.contains(roleIds, roleId)) {
				removeRoleIds.add(roleId);
			}
		}
		
		_log.info(Arrays.toString(removeRoleIds.toArray()));
		
		_userGroupRoleService.updateUserGroupRoles(
				user.getUserId(), groupId, roleIds,
				ArrayUtil.toLongArray(removeRoleIds));
		
		sendRedirect(actionRequest, actionResponse);
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
	
	private Log _log = LogFactoryUtil.getLog(UpdateUserSiteRoleActionCommand.class);
	
	@Reference
	private Portal _portal;
	
	@Reference
	UserLocalService _userLocalService;
	
	@Reference
	private UserGroupRoleLocalService _userGroupRoleLocalService;
	
	@Reference
	private UserGroupRoleService _userGroupRoleService;
}
