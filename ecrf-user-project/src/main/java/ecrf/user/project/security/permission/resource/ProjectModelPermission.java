package ecrf.user.project.security.permission.resource;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.security.permission.resource.ModelResourcePermission;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.model.Project;

@Component( immediate = true )
public class ProjectModelPermission {
	public static boolean contains(PermissionChecker permissionChecker, Project project, String actionId) throws PortalException {
		return _projectModelResourcePermission.contains(permissionChecker, project, actionId);
	}
	
	public static boolean contains(PermissionChecker permissionChecker, long projectId, String actionId) throws PortalException {
		return _projectModelResourcePermission.contains(permissionChecker, projectId, actionId);
	}
	
	@Reference(
		target="(model.class.name=ecrf.user.model.Project)",
		unbind="-"
	)
	protected void setEntryModelPermission(ModelResourcePermission<Project> modelResourcePermission) {
		_projectModelResourcePermission = modelResourcePermission;
	}
	
	private static ModelResourcePermission<Project> _projectModelResourcePermission;
}
