package ecrf.user.crf.security.permission.resource;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.security.permission.resource.ModelResourcePermission;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.model.LinkCRF;

/**
 * @author SELab-Ryu
 *
 */

@Component( immediate = true )
public class LinkCRFModelPermission {
	public static boolean contains(PermissionChecker permissionChecker, LinkCRF link, String actionId) throws PortalException {
		return _linkCRFModelResourcePermission.contains(permissionChecker, link, actionId);
	}
	
	public static boolean contains(PermissionChecker permissionChecker, long linkId, String actionId) throws PortalException {
		return _linkCRFModelResourcePermission.contains(permissionChecker, linkId, actionId);
	}
	
	@Reference(
		target="(model.class.name=ecrf.user.model.LinkCRF)",
		unbind="-"
	)
	protected void setEntryModelPermission(ModelResourcePermission<LinkCRF> modelResourcePermission) {
		_linkCRFModelResourcePermission = modelResourcePermission;
	}
	
	private static ModelResourcePermission<LinkCRF> _linkCRFModelResourcePermission;
}
