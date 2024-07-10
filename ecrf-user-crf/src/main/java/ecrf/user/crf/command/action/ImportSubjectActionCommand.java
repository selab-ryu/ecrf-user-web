package ecrf.user.crf.command.action;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.model.Company;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.upload.UploadPortletRequest;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Portal;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.WebKeys;

import java.io.File;
import java.nio.file.Files;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserCRFAttributes;
import ecrf.user.constants.attribute.ECRFUserSubjectAttributes;
import ecrf.user.model.Subject;
import ecrf.user.service.SubjectLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name="+ECRFUserMVCCommand.ACTION_IMPORT_SUBJECTS	        
	    },
	    service = MVCActionCommand.class
	)

public class ImportSubjectActionCommand extends BaseMVCActionCommand{

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		System.out.println("Import Subjects Start");
		
		long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFAttributes.CRF_ID);
		long dataTypeId = ParamUtil.getLong(actionRequest, ECRFUserCRFAttributes.DATATYPE_ID);
		System.out.println(crfId + ", " + dataTypeId);
		
		UploadPortletRequest uploadPortletRequest = PortalUtil.getUploadPortletRequest(actionRequest);
		
		File file = uploadPortletRequest.getFile("jsonInput");
		
		String json = new String(Files.readAllBytes(file.toPath()));
		JSONArray jsonArray = JSONFactoryUtil.createJSONArray(json);
		System.out.println(jsonArray.get(0).toString());
		
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
		String lunarBirth = ParamUtil.getString(actionRequest, ECRFUserSubjectAttributes.LUNARBIRTH);
		int gender = ParamUtil.getInteger(actionRequest, ECRFUserSubjectAttributes.GENDER);
		String address = ParamUtil.getString(actionRequest, ECRFUserSubjectAttributes.ADDRESS);
		String phone = ParamUtil.getString(actionRequest, ECRFUserSubjectAttributes.PHONE);
		String phone2 = ParamUtil.getString(actionRequest, ECRFUserSubjectAttributes.PHONE_2);
		
		int hospitalCode = ParamUtil.getInteger(actionRequest, ECRFUserSubjectAttributes.HOSPITAL_CODE);
		
		long expGroupId = ParamUtil.getLong(actionRequest, ECRFUserSubjectAttributes.EXPERIMENTAL_GROUP_ID);
		
		Subject subject = null;
	}
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private Portal _portal;

}
