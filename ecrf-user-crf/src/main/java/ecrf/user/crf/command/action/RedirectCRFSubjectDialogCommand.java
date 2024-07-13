/**
 * 
 */
package ecrf.user.crf.command.action;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;

/**
 * @author SELab-Ryu
 *
 */

@Component
(
	property = {
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_REDIRECT_CRF_SUBJECT_DIALOG,
	},
	service = MVCActionCommand.class
)
public class RedirectCRFSubjectDialogCommand extends BaseMVCActionCommand {
	private Log _log = LogFactoryUtil.getLog(RedirectCRFSubjectDialogCommand.class);
	
	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		
		
	}

}
