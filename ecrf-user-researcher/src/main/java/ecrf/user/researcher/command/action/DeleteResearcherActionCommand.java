package ecrf.user.researcher.command.action;

import com.liferay.portal.kernel.exception.NoSuchUserException;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.Company;
import com.liferay.portal.kernel.model.User;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.security.auth.PrincipalException;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.service.UserLocalService;
import com.liferay.portal.kernel.servlet.SessionErrors;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Portal;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserResearcherAttributes;
import ecrf.user.exception.NoSuchResearcherException;
import ecrf.user.model.Researcher;
import ecrf.user.service.ResearcherLocalService;

@Component
(
		property = {
				"javax.portlet.name="+ECRFUserPortletKeys.RESEARCHER,
				"mvc.command.name="+ECRFUserMVCCommand.ACTION_DELETE_RESEARCHER
		},
		service = MVCActionCommand.class
)
public class DeleteResearcherActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);

		_log.info("delete researcher");
		
		boolean errorOccured = false;
		
		try {
			deleteResearcherWithUser(actionRequest, actionResponse);
		} catch (Exception exception) {
			
			_log.info(exception.getClass().toString() + " / " + exception.getMessage());
			errorOccured = true;
			
			if (exception instanceof NoSuchUserException ||
				exception instanceof NoSuchResearcherException ||
				exception instanceof PrincipalException) {
				// real error
				SessionErrors.add(actionRequest, exception.getClass());	
			} else if (Validator.isNotNull(exception.getMessage()) ) {
				// user miss something
				SessionErrors.add(actionRequest, exception.getClass());
				_log.error(exception.getMessage());
			} else {
				exception.printStackTrace();
				throw exception;
			}
			
			String mvcPath = ECRFUserJspPaths.JSP_UPDATE_RESEARCHER;
			actionResponse.setRenderParameter("mvcPath", mvcPath);
		}
		
		if(!errorOccured) {
			String renderCommand = ECRFUserMVCCommand.RENDER_LIST_RESEARCHER;
			
			PortletURL renderURL = PortletURLFactoryUtil.create(
					actionRequest, 
					themeDisplay.getPortletDisplay().getId(), 
					themeDisplay.getPlid(), 
					PortletRequest.RENDER_PHASE);
			
			renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
			actionResponse.sendRedirect(renderURL.toString());
		}
	}
	
	public void deleteResearcherWithUser(ActionRequest actionRequest, ActionResponse actionResponse) throws PortalException {		
		HttpServletRequest httpServletRequest = _portal.getHttpServletRequest(actionRequest);
		HttpSession session = httpServletRequest.getSession();

		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		ServiceContext researcherServiceContext = ServiceContextFactory.getInstance(Researcher.class.getName(), actionRequest);
		ServiceContext userServiceContext = ServiceContextFactory.getInstance(User.class.getName(), actionRequest);
		Company company = themeDisplay.getCompany();
		
		long researcherId = ParamUtil.getLong(actionRequest, ECRFUserResearcherAttributes.RESEARCHER_ID);
		Researcher researcher = _researcherLocalService.getResearcher(researcherId);
		long researcherUserId = researcher.getResearcherUserId();
		
		_log.info("null check : " + researcherId + " / " + researcherUserId);
		
		researcher = _researcherLocalService.deleteResearcherWithUser(researcher);
	}
	
	@Reference
	private Portal _portal;
	
	@Reference
	private UserLocalService _userLocalService;
	
	@Reference
	private ResearcherLocalService _researcherLocalService;
	
	private Log _log = LogFactoryUtil.getLog(DeleteResearcherActionCommand.class);
}
