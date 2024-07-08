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
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

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
import ecrf.user.constants.attribute.ECRFUserProjectAttributes;
import ecrf.user.constants.attribute.ECRFUserSubjectAttributes;
import ecrf.user.model.Project;
import ecrf.user.service.ProjectLocalService;

@Component
(
	property = {
			"javax.portlet.name="+ECRFUserPortletKeys.PROJECT,
			"mvc.command.name="+ECRFUserMVCCommand.ACTION_ADD_PROJECT,
			"mvc.command.name="+ECRFUserMVCCommand.ACTION_UPDATE_PROJECT
	},
	service = MVCActionCommand.class
)
public class UpdateProjectActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log = LogFactoryUtil.getLog(this.getClass().getName()); 
		String cmd = ParamUtil.getString(actionRequest, Constants.CMD);
		
		if(cmd.equals(Constants.ADD)) {
			addProject(actionRequest, actionResponse);
		} else if(cmd.equals(Constants.UPDATE)) {
			updateProject(actionRequest, actionResponse);
		}
		
		sendRedirect(actionRequest, actionResponse);
	}
	
	public void addProject(ActionRequest actionRequest, ActionResponse actionResponse) throws PortalException {
		_log.info("Add Project");
		ServiceContext projectServiceContext = ServiceContextFactory.getInstance(Project.class.getName(), actionRequest);
		
		String title = ParamUtil.getString(actionRequest, ECRFUserProjectAttributes.TITLE);
		String shortTitle = ParamUtil.getString(actionRequest, ECRFUserProjectAttributes.SHORT_TITLE);
		String purpose = ParamUtil.getString(actionRequest, ECRFUserProjectAttributes.PURPOSE);
		
		DateFormat df = new SimpleDateFormat("yyyy/MM/dd");
		Calendar cal = Calendar.getInstance();
		
		Date startDate = ParamUtil.getDate(actionRequest, ECRFUserProjectAttributes.START_DATE, df);
		cal.setTime(startDate);
		int startDateYear = cal.get(Calendar.YEAR);
		int startDateMonth = cal.get(Calendar.MONTH);
		int startDateDay = cal.get(Calendar.DATE);
				
		Date endDate = ParamUtil.getDate(actionRequest, ECRFUserProjectAttributes.END_DATE, df);
		cal.setTime(endDate);
		int endDateYear = cal.get(Calendar.YEAR);
		int endDateMonth = cal.get(Calendar.MONTH);
		int endDateDay = cal.get(Calendar.DATE);
				
		long principleResearcherId = ParamUtil.getInteger(actionRequest, ECRFUserProjectAttributes.PRINCIPAL_RESEARCHER_ID, 0);
		long manageResearcherId = ParamUtil.getInteger(actionRequest, ECRFUserProjectAttributes.MANAGE_RESEARCHER_ID, 0);
		
		_projectLocalService.addProject(
			title, shortTitle, purpose,
			startDateYear, startDateMonth, startDateDay,
			endDateYear, endDateMonth, endDateDay,
			principleResearcherId, manageResearcherId, projectServiceContext);
		
		_log.info("End");
	}
	
	public void updateProject(ActionRequest actionRequest, ActionResponse actionResponse) throws PortalException {
		_log.info("Update Project");
		ServiceContext projectServiceContext = ServiceContextFactory.getInstance(Project.class.getName(), actionRequest);
		
		long projectId = ParamUtil.getLong(actionRequest, ECRFUserProjectAttributes.PROJECT_ID);
		
		String title = ParamUtil.getString(actionRequest, ECRFUserProjectAttributes.TITLE);
		String shortTitle = ParamUtil.getString(actionRequest, ECRFUserProjectAttributes.SHORT_TITLE);
		String purpose = ParamUtil.getString(actionRequest, ECRFUserProjectAttributes.PURPOSE);
		
		DateFormat df = new SimpleDateFormat("yyyy/MM/dd");
		Calendar cal = Calendar.getInstance();
		
		Date startDate = ParamUtil.getDate(actionRequest, ECRFUserProjectAttributes.START_DATE, df);
		cal.setTime(startDate);
		int startDateYear = cal.get(Calendar.YEAR);
		int startDateMonth = cal.get(Calendar.MONTH);
		int startDateDay = cal.get(Calendar.DATE);
				
		Date endDate = ParamUtil.getDate(actionRequest, ECRFUserProjectAttributes.END_DATE, df);
		cal.setTime(endDate);
		int endDateYear = cal.get(Calendar.YEAR);
		int endDateMonth = cal.get(Calendar.MONTH);
		int endDateDay = cal.get(Calendar.DATE);
		
		long principleResearcherId = ParamUtil.getLong(actionRequest, ECRFUserProjectAttributes.PRINCIPAL_RESEARCHER_ID, 0);
		long manageResearcherId = ParamUtil.getLong(actionRequest, ECRFUserProjectAttributes.MANAGE_RESEARCHER_ID, 0);
		
		_projectLocalService.updateProject(
			projectId, title, shortTitle, purpose, 
			startDateYear, startDateMonth, startDateDay, 
			endDateYear, endDateMonth, endDateDay, 
			principleResearcherId, manageResearcherId, projectServiceContext);
		
		_log.info("End");
	}
	
	public void sendRedirect(ActionRequest actionRequest, ActionResponse actionResponse) throws IOException {
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		String renderCommand = ECRFUserMVCCommand.RENDER_VIEW_PROJECT;
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
	private ProjectLocalService _projectLocalService;
	
	private Log _log;

}
