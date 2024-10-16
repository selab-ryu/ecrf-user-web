/**
 * 
 */
package ecrf.user.approve.servlet.taglib.util;

import com.liferay.frontend.taglib.clay.servlet.taglib.util.DropdownItem;
import com.liferay.frontend.taglib.clay.servlet.taglib.util.DropdownItemList;
import com.liferay.petra.function.UnsafeConsumer;
import com.liferay.portal.kernel.language.LanguageUtil;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.User;
import com.liferay.portal.kernel.portlet.LiferayWindowState;
import com.liferay.portal.kernel.security.membershippolicy.SiteMembershipPolicyUtil;
import com.liferay.portal.kernel.security.permission.ActionKeys;
import com.liferay.portal.kernel.service.permission.GroupPermissionUtil;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.WebKeys;

import java.util.List;

import javax.portlet.ActionRequest;
import javax.portlet.PortletURL;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.servlet.http.HttpServletRequest;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;

/**
 * @author SELab-Ryu
 *
 */
public class MembershipUserActionDropdownItemsProvider {
	
	public MembershipUserActionDropdownItemsProvider(User user, RenderRequest renderRequest, RenderResponse renderResponse) {
		_user = user;
		_renderResponse = renderResponse;
		_httpServletRequest = PortalUtil.getHttpServletRequest(renderRequest);
		_themeDisplay = (ThemeDisplay)_httpServletRequest.getAttribute(WebKeys.THEME_DISPLAY);
		_log.info("current group id : " + _themeDisplay.getSiteGroupIdOrLiveGroupId());
	}

	public List<DropdownItem> getActionDropdownItems() throws Exception {
		return new DropdownItemList() {
			{
				if (GroupPermissionUtil.contains(
						_themeDisplay.getPermissionChecker(),
						_themeDisplay.getSiteGroupIdOrLiveGroupId(),
						ActionKeys.ASSIGN_USER_ROLES)) {

					add(_getAssignSiteRolesActionUnsafeConsumer());
				}

				if (GroupPermissionUtil.contains(
						_themeDisplay.getPermissionChecker(),
						_themeDisplay.getSiteGroupIdOrLiveGroupId(),
						ActionKeys.ASSIGN_MEMBERS) &&
					!SiteMembershipPolicyUtil.isMembershipProtected(
						_themeDisplay.getPermissionChecker(), _user.getUserId(),
						_themeDisplay.getSiteGroupIdOrLiveGroupId()) &&
					!SiteMembershipPolicyUtil.isMembershipRequired(
						_user.getUserId(),
						_themeDisplay.getSiteGroupIdOrLiveGroupId())) {

					add(_getDeleteGroupUsersActionUnsafeConsumer());
				}
			}
		};
	}

	private UnsafeConsumer<DropdownItem, Exception>_getAssignSiteRolesActionUnsafeConsumer()throws Exception {
		PortletURL assignSiteRolesURL = _renderResponse.createRenderURL();
		assignSiteRolesURL.setParameter("mvcPath", ECRFUserJspPaths.JSP_UPDATE_SITE_ROLE);
		assignSiteRolesURL.setParameter("p_u_i_d", String.valueOf(_user.getUserId()));
		assignSiteRolesURL.setParameter("groupId",String.valueOf(_themeDisplay.getSiteGroupIdOrLiveGroupId()));

		PortletURL editUserGroupRoleURL = _renderResponse.createActionURL();
		editUserGroupRoleURL.setParameter(ActionRequest.ACTION_NAME, ECRFUserMVCCommand.ACTION_UPDATE_USER_SITE_ROLE);
		editUserGroupRoleURL.setParameter("p_u_i_d", String.valueOf(_user.getUserId()));
		editUserGroupRoleURL.setParameter("groupId",String.valueOf(_themeDisplay.getSiteGroupIdOrLiveGroupId()));

		return dropdownItem -> {
			dropdownItem.putData("action", "assignSiteRoles");
			dropdownItem.putData("assignSiteRolesURL", assignSiteRolesURL.toString());
			dropdownItem.putData("editUserGroupRoleURL", editUserGroupRoleURL.toString());
			dropdownItem.setLabel(LanguageUtil.get(_httpServletRequest, "ecrf-user.button.site-role"));
		};
	}

	private UnsafeConsumer<DropdownItem, Exception>
		_getDeleteGroupUsersActionUnsafeConsumer() {

		PortletURL deleteGroupUsersURL = _renderResponse.createActionURL();
		deleteGroupUsersURL.setParameter(ActionRequest.ACTION_NAME, "deleteGroupUsers");
		deleteGroupUsersURL.setParameter("redirect", _themeDisplay.getURLCurrent());
		deleteGroupUsersURL.setParameter("groupId",String.valueOf(_themeDisplay.getSiteGroupIdOrLiveGroupId()));
		deleteGroupUsersURL.setParameter("removeUserId", String.valueOf(_user.getUserId()));

		return dropdownItem -> {
			dropdownItem.putData("action", "deleteGroupUsers");
			dropdownItem.putData("deleteGroupUsersURL", deleteGroupUsersURL.toString());
			dropdownItem.setLabel(LanguageUtil.get(_httpServletRequest, "remove-membership"));
		};
	}
	
	private Log _log = LogFactoryUtil.getLog(this.getClass().getName());
	private final HttpServletRequest _httpServletRequest;
	private final RenderResponse _renderResponse;
	private final ThemeDisplay _themeDisplay;
	private final User _user;
}
