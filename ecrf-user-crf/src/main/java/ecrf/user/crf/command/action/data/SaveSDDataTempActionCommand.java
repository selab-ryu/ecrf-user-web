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
				"javax.portlet.name=" + IcecapWebPortletKeys.STRUCTURED_DATA,
				"javax.portlet.name=" + ECRFUserPortletKeys.CRF,
				"mvc.command.name=/temp/saveCRF"
		},
		service = MVCActionCommand.class
)
public class SaveSDDataTempActionCommand extends BaseMVCActionCommand {
	@Override
	public void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log.info("Temporary Save CRF Action");
		
		_log.info("action request : " + actionRequest.toString());
		
		String cmd = ParamUtil.getString(actionRequest, StationXWebKeys.CMD);
		
		long subjectId =  ParamUtil.getLong(actionRequest, "subjectId", 0);
		long dataTypeId = ParamUtil.getLong(actionRequest, IcecapDataTypeAttributes.DATATYPE_ID, 0);
		long structuredDataId = ParamUtil.getLong(actionRequest, IcecapWebKeys.STRUCTURED_DATA_ID,  0);
		
		_log.info("sd save cmd : " + cmd);
		_log.info("sd save sid : " + subjectId);
		_log.info("sd save did : " + dataTypeId);
		_log.info("sd save sdid : " + structuredDataId);
		
		String dataContent = ParamUtil.getString(actionRequest, "dataContent", "");
		
		_log.info("data content : " + dataContent);
	
		
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);

		ServiceContext sdServiceContext = ServiceContextFactory.getInstance(StructuredData.class.getName(), actionRequest);
		ServiceContext linkServiceContext = ServiceContextFactory.getInstance(LinkCRF.class.getName(), actionRequest);
		ServiceContext subjectServiceContext = ServiceContextFactory.getInstance(Subject.class.getName(), actionRequest);
		ServiceContext historyServiceContext = ServiceContextFactory.getInstance(CRFHistory.class.getName(), actionRequest);
		
		Date visitDate = new Date();
		JSONObject answer = JSONFactoryUtil.createJSONObject(dataContent);
		if(!answer.has("visit_date")) {
			answer.put("visit_date", visitDate.getTime());
		}
		
		Subject subject = _subjectLocalService.getSubject(subjectId);
		CRF crf = _crfLocalService.getCRFByDataTypeId(dataTypeId);
		
		dataContent = answer.toJSONString();
		_log.info("----------sdtempsave : " + dataContent);
		if( cmd.equalsIgnoreCase(StationXConstants.CMD_ADD) ) {
			StructuredData  storedData = _dataTypeLocalService.addStructuredData(
																		dataTypeId, 
																		dataTypeId, 
																		dataContent, 
																		WorkflowConstants.STATUS_DRAFT, sdServiceContext);
			structuredDataId = storedData.getStructuredDataId();
			_linkLocalService.addLinkCRF(subjectId, crf.getCrfId(), storedData.getStructuredDataId(), linkServiceContext);
			_historyLocalService.addCRFHistory(subject.getName(), subjectId, subject.getSerialId(), storedData.getPrimaryKey(), crf.getCrfId(), "", dataContent, 0, "1.0.0", historyServiceContext);
		}
		else {
			StructuredData  storedData = _dataTypeLocalService.updateStructuredData(
					structuredDataId,
					dataTypeId, 
					dataTypeId, 
					dataContent, 
					WorkflowConstants.STATUS_APPROVED, sdServiceContext);
			List<CRFHistory> prevHistoryList = _historyLocalService.getCRFHistoryByC_S(crf.getCrfId(), subjectId);
			
			CRFHistory prevHistory = prevHistoryList.get(prevHistoryList.size() - 1);
			for(int i =  prevHistoryList.size() - 1; i > -1; i--) {
				prevHistory = prevHistoryList.get(i);
				if(prevHistory.getStructuredDataId() == structuredDataId) break;
			}
			
			_historyLocalService.addCRFHistory(subject.getName(), subjectId, subject.getSerialId(), storedData.getPrimaryKey(), crf.getCrfId(), prevHistory.getCurrentJSON(), dataContent, 0, "1.0.0", historyServiceContext);
		}
		
		
		String renderCommand = ECRFUserMVCCommand.RENDER_LIST_CRF_DATA;
		
		/*
		PortletURL testURL = actionResponse.createRedirectURL(Copy.ALL); 
		_log.info(testURL.toString());
		
		testURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		testURL.setParameter(ECRFUserCRFAttributes.CRF_ID, String.valueOf(crf.getCrfId()));
		_log.info(testURL.toString());
		*/
		
		// create render url by manually
		String baseURL = ParamUtil.getString(actionRequest, "baseURL");
		_log.info("base url : " + baseURL);
		
		String paramKey = "_" + ECRFUserPortletKeys.CRF + "_";
		
		baseURL += "?p_p_id=" + ECRFUserPortletKeys.CRF;
		baseURL += "&" + paramKey + ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME + "=" + renderCommand;
		baseURL += "&" + paramKey + ECRFUserCRFAttributes.CRF_ID + "=" + String.valueOf(crf.getCrfId());
		
		_log.info(baseURL);
		
		actionResponse.sendRedirect(baseURL);
	}

	private Log _log = LogFactoryUtil.getLog(SaveSDDataTempActionCommand.class);
	
	@Reference
	private PortletURLFactory _portletURLFactory;
	
	@Reference
	private LayoutLocalService _layoutLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private CRFHistoryLocalService _historyLocalService;
	
	@Reference
	private LinkCRFLocalService _linkLocalService;
	
	@Reference
	private CRFLocalService _crfLocalService;
}
