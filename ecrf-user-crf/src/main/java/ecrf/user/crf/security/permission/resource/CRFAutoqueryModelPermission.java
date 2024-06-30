package ecrf.user.crf.security.permission.resource;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.security.permission.resource.ModelResourcePermission;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.model.CRFAutoquery;

/**
 * @author SELab-Ryu
 *
 */

@Component( immediate = true )
public class CRFAutoqueryModelPermission {
	public static boolean contains(PermissionChecker permissionChecker, CRFAutoquery autoquery, String actionId) throws PortalException {
		return _crfAutoqueryModelResourcePermission.contains(permissionChecker, autoquery, actionId);
	}
	
	public static boolean contains(PermissionChecker permissionChecker, long autoqueryId, String actionId) throws PortalException {
		return _crfAutoqueryModelResourcePermission.contains(permissionChecker, autoqueryId, actionId);
	}
	
	@Reference(
		target="(model.class.name=ecrf.user.model.CRFAutoquery)",
		unbind="-"
	)
	protected void setEntryModelPermission(ModelResourcePermission<CRFAutoquery> modelResourcePermission) {
		_crfAutoqueryModelResourcePermission = modelResourcePermission;
	}
	
	private static ModelResourcePermission<CRFAutoquery> _crfAutoqueryModelResourcePermission;
}
