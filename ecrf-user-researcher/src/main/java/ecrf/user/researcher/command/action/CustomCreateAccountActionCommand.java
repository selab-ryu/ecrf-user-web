package ecrf.user.researcher.command.action;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.Company;
import com.liferay.portal.kernel.model.User;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.MembershipRequestLocalService;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.service.UserLocalService;
import com.liferay.portal.kernel.servlet.SessionErrors;
import com.liferay.portal.kernel.servlet.SessionMessages;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Portal;
import com.liferay.portal.kernel.util.PortletKeys;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;

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
import ecrf.user.constants.ECRFUserUtil;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserResearcherAttributes;
import ecrf.user.exception.NoSuchResearcherException;
import ecrf.user.model.Researcher;
import ecrf.user.service.ResearcherLocalService;

@Component
(
	property = {
			"javax.portlet.name="+PortletKeys.LOGIN,
			"mvc.command.name="+ECRFUserMVCCommand.ACTION_ADD_RESEARCHER,
			"service.ranking:Integer=100"
	},
	service = MVCActionCommand.class
)
public class CustomCreateAccountActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log.info("custom user add");
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		String cmd = ParamUtil.getString(actionRequest, Constants.CMD);
		
		if(cmd.equals(Constants.ADD)) {
			addResearcherWithUser(actionRequest, actionResponse);
		} else if(cmd.equals(Constants.UPDATE)) {
			updateResearcherWithUser(actionRequest, actionResponse);
		}
		
		String renderCommand = ECRFUserMVCCommand.RENDER_LIST_RESEARCHER;
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(), 
				PortletRequest.RENDER_PHASE);
		
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		actionResponse.sendRedirect(renderURL.toString());
 
	}
	
	public void addResearcherWithUser(ActionRequest actionRequest, ActionResponse actionResponse) throws PortalException {		
		HttpServletRequest httpServletRequest = _portal.getHttpServletRequest(actionRequest);
		HttpSession session = httpServletRequest.getSession();

		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		ServiceContext researcherServiceContext = ServiceContextFactory.getInstance(Researcher.class.getName(), actionRequest);
		ServiceContext userServiceContext = ServiceContextFactory.getInstance(User.class.getName(), actionRequest);
		Company company = themeDisplay.getCompany();
		
		//_log.info("get data from request parameter");
		String email = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.EMAIL);
		String password1 = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.PASSWORD1);
		String password2 = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.PASSWORD2);
		String screenName = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.SCREEN_NAME);
		String firstName = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.FIRST_NAME);
		String lastName = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.LAST_NAME);
		
		long facebookId = ParamUtil.getLong(actionRequest, "facebookId");
		String openId = ParamUtil.getString(actionRequest, "openId");
		String languageId = ParamUtil.getString(actionRequest, "languageId");
		boolean male = ParamUtil.getBoolean(actionRequest, "male", true);
		String jobTitle = ParamUtil.getString(actionRequest, "jobTitle");
		long prefixId = ParamUtil.getInteger(actionRequest, "prefixId");
		long suffixId = ParamUtil.getInteger(actionRequest, "suffixId");
		
		DateFormat df = new SimpleDateFormat("yyyy/MM/dd");
		Calendar cal = Calendar.getInstance();
		Date birth = ParamUtil.getDate(actionRequest, ECRFUserResearcherAttributes.BIRTH, df);
				
		cal.setTime(birth);
		int birthYear = cal.get(Calendar.YEAR);
		int birthMonth = cal.get(Calendar.MONTH);
		int birthDay = cal.get(Calendar.DATE);
		
		int gender = ParamUtil.getInteger(actionRequest, ECRFUserResearcherAttributes.GENDER, 0);
		
		String phone = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.PHONE);
		String institution = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.INSTITUTION);
		String officeContact = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.OFFICE_CONTACT);
		String position = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.POSITION);
		position = "researcher";
		
		Researcher researcher = null;
		try {
		researcher = _researcherLocalService.addResarcherWithUser(
				company.getCompanyId(),
				facebookId, openId, languageId,
				male, jobTitle, prefixId, suffixId,
				email, password1, password2, screenName, firstName, lastName,
				birthYear, birthMonth, birthDay, gender, 
				phone, institution, officeContact, position, 0,
				userServiceContext, researcherServiceContext);
			SessionMessages.add(actionRequest, "researcherWithUserAdded");
		} catch(PortalException e) {
			System.out.println(e);
			_log.error("researcher is null");
			SessionErrors.add(actionRequest, e.getClass().getName());
		}
		User user = null;
		
		if(Validator.isNotNull(researcher)) {
			user = _userLocalService.getUser(researcher.getResearcherUserId());
		} else {
			_log.info("researcher is null");
		}
		
		// update researcher's agreement status when user is added from Login module(from liferay[true]) not Users module(User admin menu[false])
		boolean fromLiferay = ParamUtil.getBoolean(actionRequest, "fromLiferay");
		boolean isAdminMenu = ParamUtil.getBoolean(actionRequest, "isAdminMenu");
		
		_log.info(ECRFUserUtil.getLogMsg("from liferay / is admin menu : ", " / " , fromLiferay, isAdminMenu));
		
		if(fromLiferay && !isAdminMenu) {
			try {
				_researcherLocalService.updateAgreemnt(researcher.getResearcherId(), true);
			} catch(NoSuchResearcherException noResearcher) {
				noResearcher.printStackTrace();
			}
		}
		
		/*
		if(Validator.isNotNull(user)) {
			_log.info("user is added / " + user.getEmailAddress());
			ServiceContext membershipServiceContext = ServiceContextFactory.getInstance(MembershipRequest.class.getName(), actionRequest);
			try {
				_membershipRequestLocalService.addMembershipRequest(user.getUserId(), themeDisplay.getScopeGroupId(), "Add Researcher to Site Membership", membershipServiceContext);
			} catch(PortalException e) {
				e.printStackTrace();
				_log.error("Add Membership Request failed");
			}
		} else {
			_log.info("user is null");
		}
		*/
	}
	
	public void updateResearcherWithUser(ActionRequest actionRequest, ActionResponse actionResponse) {
		
	}
	
	public void sendRedirect() {
		
	}

	private Log _log = LogFactoryUtil.getLog(CustomCreateAccountActionCommand.class);
	
	@Reference
	private Portal _portal;
	
	@Reference
	private UserLocalService _userLocalService;
	
	@Reference
	private ResearcherLocalService _researcherLocalService;
	
	@Reference
	private MembershipRequestLocalService _membershipRequestLocalService;
}
