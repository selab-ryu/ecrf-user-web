package ecrf.user.crf.command.action;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.model.Company;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.upload.UploadPortletRequest;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Portal;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;

import java.io.File;
import java.nio.file.Files;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
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
import ecrf.user.constants.attribute.ECRFUserCRFAttributes;
import ecrf.user.model.CRFSubject;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFSubjectLocalService;
import ecrf.user.service.CRFSubjectLocalServiceUtil;
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
		
		HttpServletRequest httpServletRequest = _portal.getHttpServletRequest(actionRequest);
		HttpSession session = httpServletRequest.getSession();
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		Company company = themeDisplay.getCompany();
		
		ServiceContext subjectServiceContext = ServiceContextFactory.getInstance(Subject.class.getName(), actionRequest);
		ArrayList<CRFSubject> crfSubjectList = new ArrayList<CRFSubject>();
		
		for(int i = 0; i < jsonArray.length(); i++) {
			if(Validator.isNull(_subjectLocalService.getSubjectBySerialId(jsonArray.getJSONObject(i).getString("ID")))) {
				String dateStr = jsonArray.getJSONObject(i).getString("Visit_date");
	
				if(Validator.isNotNull(dateStr) || !dateStr.equals("")) {
					String name = jsonArray.getJSONObject(i).getString("Name");
					String serialId = jsonArray.getJSONObject(i).getString("ID");
					int age = jsonArray.getJSONObject(i).getInt("Age");
					int gender = 0;
					if(jsonArray.getJSONObject(i).getInt("Sex") == 1) {
						gender = 0;
					}else {
						gender = 1;
					}
					
					SimpleDateFormat  formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
					Calendar cal = Calendar.getInstance();
			
					Date visitDate = formatter.parse(dateStr);
					cal.setTime(visitDate);
					int birthYear = visitDate.getYear() + 1900 - age;
					int birthMonth = 0;
					int birthDay = 1;
					String lunarBirth = null;
					String address = null;
					int hospitalCode = 1001;
					int expGroupId = 45509;
					String phone = "010-0000-0000";
					String phone2 = null;
					
					Subject subject = null;
					
					try {
						subject = _subjectLocalService.addSubject(
								name, 
								birthYear, birthMonth, birthDay, lunarBirth,
								gender, phone, phone2, 
								address, serialId, hospitalCode,
								expGroupId,
								subjectServiceContext);
					} catch(PortalException e) {
						_log.error("subject is null");	
					}
					
					CRFSubject crfSubject = CRFSubjectLocalServiceUtil.createCRFSubject(0);
					
					crfSubject.setGroupId(themeDisplay.getScopeGroupId());
					
					crfSubject.setCrfId(crfId);
					crfSubject.setSubjectId(subject.getSubjectId());
					
					crfSubject.setParticipationStatus(0);
					crfSubject.setParticipationStartDate(new Date());
					crfSubject.setUpdateLock(false);
					crfSubjectList.add(crfSubject);
				}else {
					System.out.println("Wrong file input");
				}
			}else {
				System.out.println(jsonArray.getJSONObject(i).getString("ID") + " " + jsonArray.getJSONObject(i).getString("Name") + " is duplicated");
			}
		}	
		ServiceContext crfSubjectSC = ServiceContextFactory.getInstance(CRFSubject.class.getName(), actionRequest);
		
		if(crfSubjectList.size() > 0) {
			_crfSubjectLocalService.updateCRFSubjects(crfId, crfSubjectList, crfSubjectSC);
		}else {
			System.out.println("None subject detected");
		}
		
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(),
				PortletRequest.RENDER_PHASE);
		renderURL.setParameter(ECRFUserCRFAttributes.CRF_ID, String.valueOf(crfId));
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, ECRFUserMVCCommand.RENDER_UPDATE_CRF);
		
		actionResponse.sendRedirect(renderURL.toString());
	}
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private CRFSubjectLocalService _crfSubjectLocalService;

	@Reference
	private Portal _portal;
	
	private Log _log;

}
