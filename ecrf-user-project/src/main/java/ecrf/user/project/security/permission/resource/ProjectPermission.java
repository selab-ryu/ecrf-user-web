package ecrf.user.project.security.permission.resource;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.security.permission.ActionKeys;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.security.permission.resource.PortletResourcePermission;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserConstants;

/**
 * @author SELab-Ryu
 *
 */

@Component( immediate = true )
public class ProjectPermission {
	public static boolean contains(PermissionChecker permissionChecker, long groupId, String actionId) {
		//_log.info("user id / group id / action id : " + permissionChecker.getUserId() + " / " + groupId + " / " + actionId);
		return _portletResourcePermission.contains(permissionChecker, groupId, actionId);
	}
	
	@Reference(
		target = "(resource.name=" + ECRFUserConstants.RESOURCE_NAME + ")",
		unbind="-"
	)
	protected void setPortletResourcePermission(PortletResourcePermission portlerResourcePermission) {
		//_log.info("resource name : " + portlerResourcePermission.getResourceName());
		_portletResourcePermission = portlerResourcePermission;
	}
	
	private static PortletResourcePermission _portletResourcePermission;
	
	private static Log _log = LogFactoryUtil.getLog(ProjectPermission.class);
}
