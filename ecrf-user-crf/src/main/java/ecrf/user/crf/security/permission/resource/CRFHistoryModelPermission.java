package ecrf.user.crf.security.permission.resource;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.security.permission.resource.ModelResourcePermission;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.model.CRFHistory;

/**
 * @author SELab-Ryu
 *
 */

@Component( immediate = true )
public class CRFHistoryModelPermission {
	public static boolean contains(PermissionChecker permissionChecker, CRFHistory history, String actionId) throws PortalException {
		return _crfHistoryModelResourcePermission.contains(permissionChecker, history, actionId);
	}
	
	public static boolean contains(PermissionChecker permissionChecker, long historyId, String actionId) throws PortalException {
		return _crfHistoryModelResourcePermission.contains(permissionChecker, historyId, actionId);
	}
	
	@Reference(
		target="(model.class.name=ecrf.user.model.CRFHistory)",
		unbind="-"
	)
	protected void setEntryModelPermission(ModelResourcePermission<CRFHistory> modelResourcePermission) {
		_crfHistoryModelResourcePermission = modelResourcePermission;
	}
	
	private static ModelResourcePermission<CRFHistory> _crfHistoryModelResourcePermission;
}
