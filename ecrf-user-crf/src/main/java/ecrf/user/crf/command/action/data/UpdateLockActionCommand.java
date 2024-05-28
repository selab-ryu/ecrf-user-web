package ecrf.user.crf.command.action.data;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.sx.icecap.service.DataTypeLocalService;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.model.CRF;
import ecrf.user.model.CRFSubject;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFAutoqueryLocalService;
import ecrf.user.service.CRFHistoryLocalService;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.CRFSubjectLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.service.SubjectLocalService;

@Component
(
	property = {
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_CHANGE_UPDATE_LOCK,
	},
	service = MVCActionCommand.class
)

public class UpdateLockActionCommand extends BaseMVCActionCommand{
	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
        ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
        
        long subjectId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
        long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
        
        _log.info("crf id : " + crfId);
        
        long dataTypeId = 0;
        
        Subject subject = null;
        CRF crf = null;
        
        CRFSubject crfSubject = null;
        
        try {        	
        	if(crfId > 0) {
        		crf = _crfLocalService.getCRF(crfId);
        		dataTypeId = crf.getDatatypeId();
        		_log.info("datatype id : " + dataTypeId);
        	}
        	
        	if(subjectId > 0 && crfId > 0)
        		crfSubject = _crfSubjectLocalService.getCRFSubjectByC_S(crfId, subjectId);
        } catch (Exception e) {
    		_log.error(e.getMessage());
    	}
        
        if(Validator.isNotNull(crfSubject)) {
        	boolean updateLock = crfSubject.getUpdateLock();
        	_crfSubjectLocalService.changeUpdateLock(crfId, subjectId, !updateLock);
        }
        
		String renderCommand = ECRFUserMVCCommand.RENDER_LIST_CRF_DATA;
		String listPath = ECRFUserJspPaths.JSP_LIST_CRF_DATA_UPDATE;
		
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(), 
				PortletRequest.RENDER_PHASE);
		
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		renderURL.setParameter(ECRFUserWebKeys.LIST_PATH, listPath);
		renderURL.setParameter(ECRFUserCRFDataAttributes.CRF_ID, String.valueOf(crfId));
		
		actionResponse.sendRedirect(renderURL.toString());
	}
	
	private Log _log = LogFactoryUtil.getLog(UpdateLockActionCommand.class);
	
	@Reference
	private CRFSubjectLocalService _crfSubjectLocalService;
		
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private CRFLocalService _crfLocalService;
}
