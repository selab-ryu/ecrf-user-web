package ecrf.user.project.security.permission.resource;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.security.permission.resource.ModelResourcePermission;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.model.ExperimentalGroup;
import ecrf.user.model.Project;

/**
 * @author SELab-Ryu
 *
 */

@Component(immediate = true)
public class ExpGroupModelPermission {
	public static boolean contains(PermissionChecker permissionChecker, ExperimentalGroup expGroup, String actionId) throws PortalException {
		return _expGroupModelResourcePermission.contains(permissionChecker, expGroup, actionId);
	}
	
	public static boolean contains(PermissionChecker permissionChecker, long expGroupId, String actionId) throws PortalException {
		return _expGroupModelResourcePermission.contains(permissionChecker, expGroupId, actionId);
	}
	
	@Reference(
		target="(model.class.name=ecrf.user.model.ExperimentalGroup)",
		unbind="-"
	)
	protected void setEntryModelPermission(ModelResourcePermission<ExperimentalGroup> modelResourcePermission) {
		_expGroupModelResourcePermission = modelResourcePermission;
	}
	
	private static ModelResourcePermission<ExperimentalGroup> _expGroupModelResourcePermission; 
}
