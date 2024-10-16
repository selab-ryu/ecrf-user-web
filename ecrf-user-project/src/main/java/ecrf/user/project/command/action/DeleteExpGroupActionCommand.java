package ecrf.user.project.command.action;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.Company;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Portal;
import com.liferay.portal.kernel.util.WebKeys;

import java.io.IOException;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserExpGroupAttributes;
import ecrf.user.constants.attribute.ECRFUserProjectAttributes;
import ecrf.user.model.ExperimentalGroup;
import ecrf.user.model.Project;
import ecrf.user.service.ExperimentalGroupLocalService;
import ecrf.user.service.ProjectLocalService;

@Component
(
	property = {
			"javax.portlet.name="+ECRFUserPortletKeys.PROJECT,
			"mvc.command.name="+ECRFUserMVCCommand.ACTION_DELETE_EXP_GROUP,
	},
	service = MVCActionCommand.class
)
public class DeleteExpGroupActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log.info("Delete Exp. Group");
		ServiceContext expGroupServiceContext = ServiceContextFactory.getInstance(ExperimentalGroup.class.getName(), actionRequest);
		
		long expGroupId = ParamUtil.getLong(actionRequest, ECRFUserExpGroupAttributes.EXP_GROUP_ID);
		_expGroupLocalService.deleteExpGroup(expGroupId);
		
		sendRedirect(actionRequest, actionResponse);
	}
	
	public void sendRedirect(ActionRequest actionRequest, ActionResponse actionResponse) throws IOException {
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		String renderCommand = ECRFUserMVCCommand.RENDER_LIST_EXP_GROUP;
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(), 
				PortletRequest.RENDER_PHASE);
		
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		actionResponse.sendRedirect(renderURL.toString());
	}
	
	@Reference
	private Portal _portal;
		
	@Reference
	private ExperimentalGroupLocalService _expGroupLocalService;
	
	private Log _log = LogFactoryUtil.getLog(DeleteExpGroupActionCommand.class);

}
