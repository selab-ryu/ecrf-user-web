/**
 * 
 */
package ecrf.user.subject.security.permission.resource;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.security.permission.resource.ModelResourcePermission;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.model.Subject;

/**
 * @author SELab-Ryu
 *
 */

@Component( immediate = true )
public class SubjectModelPermission {
	public static boolean contains(PermissionChecker permissionChecker, Subject subject, String actionId) throws PortalException {
		return _subjectModelResourcePermission.contains(permissionChecker, subject, actionId);
	}
	
	public static boolean contains(PermissionChecker permissionChecker, long subjectId, String actionId) throws PortalException {
		return _subjectModelResourcePermission.contains(permissionChecker, subjectId, actionId);
	}
	
	@Reference(
		target="(model.class.name=ecrf.user.model.Subject)",
		unbind="-"
	)
	protected void setEntryModelPermission(ModelResourcePermission<Subject> modelResourcePermission) {
		_subjectModelResourcePermission = modelResourcePermission;
	}
	
	private static ModelResourcePermission<Subject> _subjectModelResourcePermission; 
}
