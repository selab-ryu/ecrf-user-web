package ecrf.user.researcher.security.permission.resource;

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
public class ResearcherPermission {
	public static boolean contains(PermissionChecker permissionChecker, long groupId, String actionId) {
		return _portletResourcePermission.contains(permissionChecker, groupId, actionId);
	}
	
	@Reference(
		target = "(resource.name=" + ECRFUserConstants.RESOURCE_NAME + ")",
		unbind="-"
	)
	protected void setPortletResourcePermission(PortletResourcePermission portlerResourcePermission) {
		_portletResourcePermission = portlerResourcePermission;
	}
	
	private static PortletResourcePermission _portletResourcePermission;
}
