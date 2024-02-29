package ecrf.user.subject.command.action;

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
import ecrf.user.constants.attribute.ECRFUserSubjectAttributes;
import ecrf.user.model.Subject;
import ecrf.user.service.SubjectLocalService;

@Component
(
		property = {
				"javax.portlet.name="+ECRFUserPortletKeys.SUBJECT,
				"mvc.command.name="+ECRFUserMVCCommand.ACTION_UPDATE_SUBJECT,
				"mvc.command.name="+ECRFUserMVCCommand.ACTION_ADD_SUBJECT
		},
		service = MVCActionCommand.class
)
public class UpdateSubjectActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log = LogFactoryUtil.getLog(this.getClass().getName());		
		
		String cmd = ParamUtil.getString(actionRequest, Constants.CMD);
		
		_log.info("cmd : " + cmd);
		
		if(cmd.equals(Constants.ADD)) {
			addSubject(actionRequest, actionResponse);
		} else if(cmd.equals(Constants.UPDATE)) {
			updateSubject(actionRequest, actionResponse);
		}
		
		sendRedirect(actionRequest, actionResponse);
	}
	
	public void addSubject(ActionRequest actionRequest, ActionResponse actionResponse) throws PortalException {
		HttpServletRequest httpServletRequest = _portal.getHttpServletRequest(actionRequest);
		HttpSession session = httpServletRequest.getSession();
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		Company company = themeDisplay.getCompany();
		
		ServiceContext subjectServiceContext = ServiceContextFactory.getInstance(Subject.class.getName(), actionRequest);
		
		String name = ParamUtil.getString(actionRequest, ECRFUserSubjectAttributes.NAME);
		String serialId = ParamUtil.getString(actionRequest, ECRFUserSubjectAttributes.SERIAL_ID);
		
		DateFormat df = new SimpleDateFormat("yyyy/MM/dd");
		Calendar cal = Calendar.getInstance();
		
		Date birth = ParamUtil.getDate(actionRequest, ECRFUserSubjectAttributes.BIRTH, df);
		cal.setTime(birth);
		int birthYear = cal.get(Calendar.YEAR);
		int birthMonth = cal.get(Calendar.MONTH);
		int birthDay = cal.get(Calendar.DATE);
		
		int gender = ParamUtil.getInteger(actionRequest, ECRFUserSubjectAttributes.GENDER);
		String address = ParamUtil.getString(actionRequest, ECRFUserSubjectAttributes.ADDRESS);
		String phone = ParamUtil.getString(actionRequest, ECRFUserSubjectAttributes.PHONE);
		String phone2 = ParamUtil.getString(actionRequest, ECRFUserSubjectAttributes.PHONE_2);
		
		int hospitalCode = ParamUtil.getInteger(actionRequest, ECRFUserSubjectAttributes.HOSPITAL_CODE);
		
		Subject subject = null;
		
		try {
			subject = _subjectLocalService.addSubject(
					name, 
					birthYear, birthMonth, birthDay, 
					gender, phone, phone2, 
					address, serialId, hospitalCode, 
					subjectServiceContext);
			
		} catch(PortalException e) {
			_log.error("subject is null");	
		}
	}
	
	public void updateSubject(ActionRequest actionRequest, ActionResponse actionResponse) throws PortalException {
		HttpServletRequest httpServletRequest = _portal.getHttpServletRequest(actionRequest);
		HttpSession session = httpServletRequest.getSession();
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		Company company = themeDisplay.getCompany();
		
		ServiceContext subjectServiceContext = ServiceContextFactory.getInstance(Subject.class.getName(), actionRequest);
		
		long subjectId = ParamUtil.getLong(actionRequest, ECRFUserSubjectAttributes.SUBJECT_ID);
		
		String name = ParamUtil.getString(actionRequest, ECRFUserSubjectAttributes.NAME);
		String serialId = ParamUtil.getString(actionRequest, ECRFUserSubjectAttributes.SERIAL_ID);
		
		DateFormat df = new SimpleDateFormat("yyyy/MM/dd");
		Calendar cal = Calendar.getInstance();
		
		Date birth = ParamUtil.getDate(actionRequest, ECRFUserSubjectAttributes.BIRTH, df);
		cal.setTime(birth);
		int birthYear = cal.get(Calendar.YEAR);
		int birthMonth = cal.get(Calendar.MONTH);
		int birthDay = cal.get(Calendar.DATE);
		
		int gender = ParamUtil.getInteger(actionRequest, ECRFUserSubjectAttributes.GENDER);
		String address = ParamUtil.getString(actionRequest, ECRFUserSubjectAttributes.ADDRESS);
		String phone = ParamUtil.getString(actionRequest, ECRFUserSubjectAttributes.PHONE);
		String phone2 = ParamUtil.getString(actionRequest, ECRFUserSubjectAttributes.PHONE_2);
		
		int hospitalCode = ParamUtil.getInteger(actionRequest, ECRFUserSubjectAttributes.HOSPITAL_CODE);
				
		Subject subject = null;
		
		try {
			
			subject = _subjectLocalService.updateSubject(
					subjectId, name, 
					birthYear, birthMonth, birthDay, 
					gender, phone, phone2, 
					address, serialId, hospitalCode, 
					subjectServiceContext);
			
		} catch(PortalException e) {
			_log.error("subject is null");	
		}
		
	}
	
	public void sendRedirect(ActionRequest actionRequest, ActionResponse actionResponse) throws IOException {
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		String renderCommand = ECRFUserMVCCommand.RENDER_LIST_SUBJECT;
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(), 
				PortletRequest.RENDER_PHASE);
		
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		actionResponse.sendRedirect(renderURL.toString());
	}
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private Portal _portal;
	
	private Log _log;
}
