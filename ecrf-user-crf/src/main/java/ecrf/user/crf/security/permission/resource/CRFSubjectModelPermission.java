package ecrf.user.crf.security.permission.resource;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.security.permission.resource.ModelResourcePermission;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.model.CRFSubject;

/**
 * @author SELab-Ryu
 *
 */

@Component( immediate = true )
public class CRFSubjectModelPermission {
	public static boolean contains(PermissionChecker permissionChecker, CRFSubject crfSubject, String actionId) throws PortalException {
		return _crfSubjectModelResourcePermission.contains(permissionChecker, crfSubject, actionId);
	}
	
	public static boolean contains(PermissionChecker permissionChecker, long crfSubjectId, String actionId) throws PortalException {
		return _crfSubjectModelResourcePermission.contains(permissionChecker, crfSubjectId, actionId);
	}
	
	@Reference(
		target="(model.class.name=ecrf.user.model.CRFSubject)",
		unbind="-"
	)
	protected void setEntryModelPermission(ModelResourcePermission<CRFSubject> modelResourcePermission) {
		_crfSubjectModelResourcePermission = modelResourcePermission;
	}
	
	private static ModelResourcePermission<CRFSubject> _crfSubjectModelResourcePermission; 
}
