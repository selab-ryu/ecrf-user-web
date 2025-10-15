package ecrf.user.crf.command.action.data;

import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.PortletURLFactory;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.LayoutLocalService;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.kernel.workflow.WorkflowConstants;
import com.sx.constant.StationXConstants;
import com.sx.constant.StationXWebKeys;
import com.sx.icecap.constant.IcecapDataTypeAttributes;
import com.sx.icecap.constant.IcecapWebKeys;
import com.sx.icecap.constant.IcecapWebPortletKeys;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;

import java.awt.image.renderable.RenderContext;
import java.util.Date;
import java.util.List;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;
import javax.portlet.MimeResponse.Copy;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserCRFAttributes;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.model.CRF;
import ecrf.user.model.CRFHistory;
import ecrf.user.model.LinkCRF;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFHistoryLocalService;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.service.SubjectLocalService;

@Component(
		property = {
				"javax.portlet.name=" + ECRFUserPortletKeys.CRF,
				"mvc.command.name=" + ECRFUserMVCCommand.ACTION_LOAD_CRF_DATA
		},
		service = MVCActionCommand.class
)
public class loadCRFDataActionCommand extends BaseMVCActionCommand {
	@Override
	public void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log.info("load CRF Data Action");
				
		long historyId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.HISTORY_ID);
		long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.CRF_ID);
		_log.info("history id : " + historyId);
			
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		ServiceContext sdServiceContext = ServiceContextFactory.getInstance(StructuredData.class.getName(), actionRequest);
		ServiceContext historyServiceContext = ServiceContextFactory.getInstance(CRFHistory.class.getName(), actionRequest);
		
		CRFHistory history = null;
		
		// get history
		try {
			history = _historyLocalService.getCRFHistory(historyId);
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		if(Validator.isNotNull(history)) {
			CRF crf = null;
			
			// get crf
			try {
				crf = _crfLocalService.getCRF(crfId);
			} catch(Exception e) {
				e.printStackTrace();
			}
			
			if(Validator.isNotNull(crf)) {
				long datatypeId = crf.getDatatypeId();
				long sdId = history.getStructuredDataId();
				
				String currentJson = history.getCurrentJSON();	// get history's sd data
				String previousJson = _dataTypeLocalService.getStructuredData(sdId);	// get current sd data
				
				// update as history's sd data
				StructuredData sdData = _dataTypeLocalService.updateStructuredData(
						sdId,
						datatypeId, 
						datatypeId, 
						currentJson, 
						WorkflowConstants.STATUS_APPROVED, sdServiceContext);
				
				_historyLocalService.addCRFHistory(history.getSubjectName(), history.getSubjectId(), history.getSerialId(), sdId, crfId, previousJson, currentJson, 0, "1.0.0", historyServiceContext); 
			} else {
				_log.info("crf is null");
			}
		} else {
			_log.info("history is null");
		}
		
		String renderCommand = ECRFUserMVCCommand.RENDER_LIST_CRF_DATA_HISTORY;
		
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(), 
				PortletRequest.RENDER_PHASE);
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		renderURL.setParameter(ECRFUserCRFDataAttributes.CRF_ID, String.valueOf(crfId));
		
		actionResponse.sendRedirect(renderURL.toString());
	}

	private Log _log = LogFactoryUtil.getLog(loadCRFDataActionCommand.class);
	
	@Reference
	private CRFLocalService _crfLocalService;
		
	@Reference
	private CRFHistoryLocalService _historyLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
}
