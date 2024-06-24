package ecrf.user.researcher.security.permission.resource;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.security.permission.resource.ModelResourcePermission;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.model.Researcher;

/**
 * @author SELab-Ryu
 *
 */

@Component(immediate = true)
public class ResearcherModelPermission {
	public static boolean contains(PermissionChecker permissionChecker, Researcher researcher, String actionId) throws PortalException {
		return _researcherModelResourcePermission.contains(permissionChecker, researcher, actionId);
	}
	
	public static boolean contains(PermissionChecker permissionChecker, long researcherId, String actionId) throws PortalException {
		return _researcherModelResourcePermission.contains(permissionChecker, researcherId, actionId);
	}
	
	@Reference(
		target="(model.class.name=ecrf.user.model.Researcher)",
		unbind="-"
	)
	protected void setEntryModelPermission(ModelResourcePermission<Researcher> modelResourcePermission) {
		_researcherModelResourcePermission = modelResourcePermission;
	}
	
	private static ModelResourcePermission<Researcher> _researcherModelResourcePermission;
}
