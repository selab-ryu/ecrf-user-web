package ecrf.user.crf.security.permission.resource;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.security.permission.resource.ModelResourcePermission;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.model.CRF;

/**
 * @author SELab-Ryu
 *
 */

@Component( immediate = true )
public class CRFModelPermission {
	public static boolean contains(PermissionChecker permissionChecker, CRF crf, String actionId) throws PortalException {
		return _crfModelResourcePermission.contains(permissionChecker, crf, actionId);
	}
	
	public static boolean contains(PermissionChecker permissionChecker, long crfId, String actionId) throws PortalException {
		return _crfModelResourcePermission.contains(permissionChecker, crfId, actionId);
	}
	
	@Reference(
		target="(model.class.name=ecrf.user.model.CRF)",
		unbind="-"
	)
	protected void setEntryModelPermission(ModelResourcePermission<CRF> modelResourcePermission) {
		_crfModelResourcePermission = modelResourcePermission;
	}
	
	private static ModelResourcePermission<CRF> _crfModelResourcePermission; 
}
