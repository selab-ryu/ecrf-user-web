package ecrf.user.crf.command.action;

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

import ecrf.user.constants.ECRFUserCRFAttributes;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.model.CRF;
import ecrf.user.service.CRFLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name="+ECRFUserMVCCommand.ACTION_ADD_CRF,
	        "mvc.command.name="+ECRFUserMVCCommand.ACTION_UPDATE_CRF,
	    },
	    service = MVCActionCommand.class
	)
public class SaveCRFActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log = LogFactoryUtil.getLog(this.getClass().getName());
		
		long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFAttributes.CRF_ID);
				
		Map<Locale, String> crfTitleMap = LocalizationUtil.getLocalizationMap(actionRequest, ECRFUserCRFAttributes.CRF_TITLE);
		Map<Locale, String> descriptionMap = LocalizationUtil.getLocalizationMap(actionRequest, ECRFUserCRFAttributes.DESCRIPTION);
		String crfName = ParamUtil.getString(actionRequest, ECRFUserCRFAttributes.CRF_NAME);
		String crfVersion = ParamUtil.getString(actionRequest, ECRFUserCRFAttributes.CRF_VERSION);
		
		long managerId = ParamUtil.getLong(actionRequest, ECRFUserCRFAttributes.MANAGER_ID); 
		
		ServiceContext dtsc = ServiceContextFactory.getInstance(DataType.class.getName(), actionRequest);
		ServiceContext crfsc = ServiceContextFactory.getInstance(CRF.class.getName(), actionRequest);
		
		int crfStatus = 0;	// edit
		
		Calendar applyDateCal = Calendar.getInstance();
		applyDateCal.setTime(new Date());
		
		if(crfId == 0) {
			_crfLocalService.addCRF(
					crfName, crfVersion,
					crfTitleMap, descriptionMap,
					managerId,
					applyDateCal.get(Calendar.YEAR), applyDateCal.get(Calendar.MONTH), applyDateCal.get(Calendar.DAY_OF_MONTH),
					crfStatus, crfsc, dtsc);
		} else {
			_crfLocalService.updateCRF(
					crfId,
					crfName, crfVersion,
					crfTitleMap, descriptionMap,
					managerId,
					applyDateCal.get(Calendar.YEAR), applyDateCal.get(Calendar.MONTH), applyDateCal.get(Calendar.DAY_OF_MONTH),
					crfStatus, crfsc, dtsc);
		}
		
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(),
				PortletRequest.RENDER_PHASE);
		
		
		
		_log.info("Start Save CRF Action Command");

	}
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
	
	private Log _log;
}
