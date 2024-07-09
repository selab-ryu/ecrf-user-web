package ecrf.user.crf.command.action;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.LocalizationUtil;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.sx.icecap.model.DataType;
import com.sx.icecap.service.DataTypeLocalService;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.Map;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserUtil;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserCRFAttributes;
import ecrf.user.constants.type.CRFStatus;
import ecrf.user.model.CRF;
import ecrf.user.model.CRFResearcher;
import ecrf.user.model.CRFSubject;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.CRFResearcherLocalService;
import ecrf.user.service.CRFSubjectLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name="+ECRFUserMVCCommand.ACTION_ADD_CRF,
	        "mvc.command.name="+ECRFUserMVCCommand.ACTION_UPDATE_CRF,
	    },
	    service = MVCActionCommand.class
	)
public class UpdateCRFActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {		
		long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFAttributes.CRF_ID);
				
		Map<Locale, String> crfTitleMap = LocalizationUtil.getLocalizationMap(actionRequest, ECRFUserCRFAttributes.CRF_TITLE);
		Map<Locale, String> descriptionMap = LocalizationUtil.getLocalizationMap(actionRequest, ECRFUserCRFAttributes.DESCRIPTION);
		String crfName = ParamUtil.getString(actionRequest, ECRFUserCRFAttributes.CRF_NAME);
		String crfVersion = ParamUtil.getString(actionRequest, ECRFUserCRFAttributes.CRF_VERSION);
		int defaultUILayout = ParamUtil.getInteger(actionRequest, ECRFUserCRFAttributes.DEFAULT_UI_LAYOUT);
		
		ServiceContext dtsc = ServiceContextFactory.getInstance(DataType.class.getName(), actionRequest);
		ServiceContext crfsc = ServiceContextFactory.getInstance(CRF.class.getName(), actionRequest);
		ServiceContext crfSubjectSC = ServiceContextFactory.getInstance(CRFSubject.class.getName(), actionRequest);
		ServiceContext crfResearcherSC = ServiceContextFactory.getInstance(CRFResearcher.class.getName(), actionRequest);
		
		// get crf-subject list
		String subjectlistJsonStr = ParamUtil.getString(actionRequest, "subjectListInput");
		_log.info(subjectlistJsonStr);
		
		JSONArray crfSubjectJsonArr = JSONFactoryUtil.createJSONArray(subjectlistJsonStr); 
		ArrayList<CRFSubject> crfSubjectList = ECRFUserUtil.toCRFSubjectList(crfSubjectJsonArr);
		
		for(CRFSubject crfSubject : crfSubjectList) {
			_log.info(crfSubject.toString());
		}
		
		// get crf-researcher list
		String researcherListJsonStr = ParamUtil.getString(actionRequest, "researcherListInput");
		_log.info(researcherListJsonStr);
		
		JSONArray crfResearcherJsonArr = JSONFactoryUtil.createJSONArray(researcherListJsonStr);
		ArrayList<CRFResearcher> crfResearcherList = ECRFUserUtil.toCRFResearcherList(crfResearcherJsonArr);
		
		for(CRFResearcher crfResearcher : crfResearcherList) {
			_log.info(crfResearcher.toString());
		}
		
		int crfStatus = CRFStatus.IN_PROGRESS.getNum();
		
		Calendar applyDateCal = Calendar.getInstance();
		applyDateCal.setTime(new Date());
		
		CRF crf = null;
		
		if(crfId == 0) {
			crf = _crfLocalService.addCRF(
					crfName, crfVersion,
					crfTitleMap, descriptionMap,
					defaultUILayout,
					applyDateCal.get(Calendar.YEAR), applyDateCal.get(Calendar.MONTH), applyDateCal.get(Calendar.DAY_OF_MONTH),
					crfStatus, crfsc, dtsc);									
		} else {
			crf = _crfLocalService.updateCRF(
					crfId,
					crfName, crfVersion,
					crfTitleMap, descriptionMap,
					defaultUILayout,
					applyDateCal.get(Calendar.YEAR), applyDateCal.get(Calendar.MONTH), applyDateCal.get(Calendar.DAY_OF_MONTH),
					crfStatus, crfsc, dtsc);
		}
		
		_crfSubjectLocalService.updateCRFSubjects(crf.getCrfId(), crfSubjectList, crfSubjectSC);	
		_crfResearcherLocalService.updateCRFResearchers(crf.getCrfId(), crfResearcherList, crfResearcherSC);
		
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(),
				PortletRequest.RENDER_PHASE);
		
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, ECRFUserMVCCommand.RENDER_LIST_CRF);
		
		actionResponse.sendRedirect(renderURL.toString());
	}
	
	@Reference
	private CRFSubjectLocalService _crfSubjectLocalService;
	
	@Reference
	private CRFResearcherLocalService _crfResearcherLocalService;
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
	
	private Log _log = LogFactoryUtil.getLog(UpdateCRFActionCommand.class);
}
