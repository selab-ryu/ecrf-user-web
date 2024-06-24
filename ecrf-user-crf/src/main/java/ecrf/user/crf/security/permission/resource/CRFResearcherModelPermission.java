package ecrf.user.crf.security.permission.resource;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.security.permission.resource.ModelResourcePermission;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.model.CRFResearcher;
import ecrf.user.model.Project;

/**
 * @author SELab-Ryu
 *
 */

@Component( immediate = true )
public class CRFResearcherModelPermission {
	public static boolean contains(PermissionChecker permissionChecker, CRFResearcher crfResearcher, String actionId) throws PortalException {
		return _crfResearcherModelResourcePermission.contains(permissionChecker, crfResearcher, actionId);
	}
	
	public static boolean contains(PermissionChecker permissionChecker, long crfResearcherId, String actionId) throws PortalException {
		return _crfResearcherModelResourcePermission.contains(permissionChecker, crfResearcherId, actionId);
	}
	
	@Reference(
		target="(model.class.name=ecrf.user.model.CRFResearcher)",
		unbind="-"
	)
	protected void setEntryModelPermission(ModelResourcePermission<CRFResearcher> modelResourcePermission) {
		_crfResearcherModelResourcePermission = modelResourcePermission;
	}
	
	private static ModelResourcePermission<CRFResearcher> _crfResearcherModelResourcePermission; 
}
