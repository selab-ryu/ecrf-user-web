/**
 * 
 */
package ecrf.user.subject.command.action;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.WebKeys;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.service.SubjectLocalService;

/**
 * @author SELab-Ryu
 *
 */

@Component
(
	property = {
			"javax.portlet.name="+ECRFUserPortletKeys.SUBJECT,
			"mvc.command.name="+ECRFUserMVCCommand.ACTION_DELETE_ALL_SUBJECT
	},
	service = MVCActionCommand.class
)
public class DeleteAllSubjectActionCommand extends BaseMVCActionCommand {
	private Log _log = LogFactoryUtil.getLog(DeleteAllSubjectActionCommand.class);
	
	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		_log.info("delete all subject");
		
		try {
			_subjectLocalService.deleteAllSubject(themeDisplay.getScopeGroupId());
		} catch(PortalException e) {
			_log.info("");
		}
		
		String renderCommand = ECRFUserMVCCommand.RENDER_LIST_SUBJECT;
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(), 
				PortletRequest.RENDER_PHASE);
		
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		renderURL.setParameter(Constants.CMD, Constants.UPDATE);
		
		_log.info("Move");
		actionResponse.sendRedirect(renderURL.toString());
	}
	
	@Reference
	private SubjectLocalService _subjectLocalService;
}
